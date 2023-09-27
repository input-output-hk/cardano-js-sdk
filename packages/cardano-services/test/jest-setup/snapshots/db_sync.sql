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
1	1006	1	0	8999989979999988	0	81000010009758659	0	10241353	113
2	2014	2	89999900807439	8909990089266949	0	81000010006123481	0	3802131	212
3	3029	3	178208803071394	8734454377563813	87326813241312	81000010006123481	0	0	313
4	4003	4	265553346847032	8560638735798513	173797911230974	81000010006123481	0	0	424
5	5000	5	351159734205017	8412424002455690	236406257215812	81000010001845207	0	4278274	522
6	6022	6	432760247456664	8270033665465421	297196085232708	81000009992992613	0	8852594	631
7	7020	7	515460584996577	8126129230104034	358400191906776	81000009992992613	0	0	746
8	8006	8	596721877297617	7986338808223314	416929321486456	81000009976104989	0	16887624	849
9	9016	9	676585267068612	7856899167352018	466505589474381	81000009976104989	0	0	966
10	10003	10	755154258742132	7723111236205311	521715916450539	81000018587996324	0	605694	1086
11	11011	11	832385371164754	7595800166708679	571795874130243	81000018587996324	0	0	1175
12	12000	12	897709252598448	7489339733407331	612917379627724	81000033617440505	0	16925992	1294
13	13001	13	972602651625120	7367492578359381	659871152574994	81000033617440505	0	0	1413
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (id, hash, epoch_no, slot_no, epoch_slot_no, block_no, previous_id, slot_leader_id, size, "time", tx_count, proto_major, proto_minor, vrf_key, op_cert, op_cert_counter) FROM stdin;
1	\\x115874cae636c9320fbd207f533ed91491c1adb9c69477d6d1646e88da5a3da1	\N	\N	\N	\N	\N	1	0	2023-09-27 12:33:58	11	0	0	\N	\N	\N
2	\\x5368656c6c65792047656e6573697320426c6f636b2048617368200000000000	\N	\N	\N	\N	1	2	0	2023-09-27 12:33:58	23	0	0	\N	\N	\N
3	\\xaf2a5ad3c25dd6059e574a1d2616b3c56e4290d6d91facebc55c971e0bcfbb53	0	5	5	0	1	3	265	2023-09-27 12:33:59	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
4	\\x9c7c377f64dacc96d8bdb5dc1ed5e3657fdb43b95c4c9ffc60a65aa6bada692e	0	18	18	1	3	4	341	2023-09-27 12:34:01.6	1	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
5	\\x671c6399393d773ec2d9904c14d52eeaa5ac07d155eb594ead213389a8e3b098	0	23	23	2	4	5	4	2023-09-27 12:34:02.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
6	\\x7309a3d83a20f77c6d9dd8f73230587dfa8de66a383cb1e9df6eee0d6e37a79a	0	25	25	3	5	6	4	2023-09-27 12:34:03	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
7	\\x4b03ed345ee0ad668c52e6197c1b848cc272ac5c84c4552d835e638140382684	0	39	39	4	6	7	371	2023-09-27 12:34:05.8	1	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
8	\\xa471baf1c81807d8d29dccb29cfb7db2d20077a2b4cc6795ceb8d268d7c57487	0	46	46	5	7	8	4	2023-09-27 12:34:07.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
9	\\xb4f30891a5e7186b88d94d2b4eec08caf45f55d4717cf1657f8a7e712363ec50	0	51	51	6	8	9	399	2023-09-27 12:34:08.2	1	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
10	\\xe6d57f175023c670219ea2c4b4309669c301e6058edf28740b929e4cf7db8423	0	55	55	7	9	5	4	2023-09-27 12:34:09	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
11	\\x6db6a7e66e1ea3fbc3c954f94c651e8107d6700347bd07c36b2729a4959569f7	0	74	74	8	10	11	655	2023-09-27 12:34:12.8	1	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
12	\\x4ecf9e4243928071027d9e42a61601d4b354862a631ea19293e9f41ded6b73a7	0	82	82	9	11	12	4	2023-09-27 12:34:14.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
13	\\xb08c9f109a11025bc5881ff4f84b700898187c3cbfc69dd3e7ea20c2dc69449a	0	95	95	10	12	9	265	2023-09-27 12:34:17	1	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
14	\\xcfc6aa795ecd0065033de8eb5c1a7bbdae87dc59885f49fad8c7ca65acad793d	0	107	107	11	13	3	341	2023-09-27 12:34:19.4	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
15	\\xedebd2cdf3f17cdcd761a9d06d65f17418f86be101dda1851b619615bf0a26fe	0	110	110	12	14	7	4	2023-09-27 12:34:20	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
16	\\x9656e5fa8f2009d75b1b196dfb0450c531a1db265063d629c273b011cb479d95	0	113	113	13	15	11	4	2023-09-27 12:34:20.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
17	\\xc74791f8147d7f437d68f81f8aad9cba1892d32fc4a78081e82a242f0d0f0861	0	115	115	14	16	5	4	2023-09-27 12:34:21	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
18	\\xc023c44946f583fcac8ac71fd9e97d99baf1f0299b7b08af91f55d387214bf09	0	131	131	15	17	7	371	2023-09-27 12:34:24.2	1	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
19	\\x7fedb8397eba5e33651fd4e641baea6de3e203a0af7ec06622a8ef7b229088a8	0	139	139	16	18	19	399	2023-09-27 12:34:25.8	1	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
20	\\xb677328f12ebd83502b707b3e5fbb6789a504ff29ae970800767262a66daad17	0	155	155	17	19	19	592	2023-09-27 12:34:29	1	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
21	\\xa7428e503bf82feaeadefceaa6e695913a50ddf5733112c431ea451a703ce1f6	0	157	157	18	20	8	4	2023-09-27 12:34:29.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
22	\\xd0dfca64f38b8adfc818022c36f3d8a76b27ed2c76837e8d79c3e685895aa6d6	0	164	164	19	21	8	4	2023-09-27 12:34:30.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
23	\\xf7bcde8e2dd90e42dcebd0a2b35423bb16f3e9fd460b0c1de8e84d4caa66d45a	0	166	166	20	22	5	265	2023-09-27 12:34:31.2	1	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
24	\\x426baa3c7b19be3f02a35af10dac9de9e809cba5b3a34416eb8ee2b93a1811ee	0	167	167	21	23	19	4	2023-09-27 12:34:31.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
25	\\x4d6cbe6f42f4b031966c3c32101d74ffb575697fbb6b3fe30ee5f9bfa6ee53e7	0	175	175	22	24	5	4	2023-09-27 12:34:33	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
26	\\x0498a88bc8aa603cc7ff112b4758c24023a22cabd20dea83e07c4158962e59f4	0	176	176	23	25	6	4	2023-09-27 12:34:33.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
27	\\x138b8501079e83e33329c672715384fc9b0bdae57c30fa5c3cece21f28bafaec	0	183	183	24	26	27	341	2023-09-27 12:34:34.6	1	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
28	\\xf69ed878af5f399dedff827ba2fb973d9189c0b9602b93db6665880da03d5ad2	0	186	186	25	27	7	4	2023-09-27 12:34:35.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
29	\\x4797b5cfafd03b85d63d64d8c5927a05211370772548b15e5f1bedce1666b1bf	0	193	193	26	28	27	371	2023-09-27 12:34:36.6	1	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
30	\\xec0a9827cd4541e5f59cf425b94fd6bbea32e8df7d35a80a3e657b6681092ff7	0	196	196	27	29	8	4	2023-09-27 12:34:37.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
31	\\x374739fe99dabb0f8a3ea109c77d77aca9011cc5e2d27378f71024cbf35b8f4f	0	197	197	28	30	11	4	2023-09-27 12:34:37.4	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
32	\\xe53073032f6ba0a63a311d4b7d94f42cddf445ac5a6fd1ebb8756ca5167990e7	0	206	206	29	31	6	399	2023-09-27 12:34:39.2	1	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
33	\\xfa1dfb196d0b4774e2e6e6d2834a36a2f10f06a38577259d9496a1de577de637	0	213	213	30	32	8	4	2023-09-27 12:34:40.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
34	\\x74c099c6dd7fd2a952991bf4db2f6ec327afc6d3c7b623bfa50492d12bcc32ee	0	214	214	31	33	12	655	2023-09-27 12:34:40.8	1	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
35	\\xec4cc16d464a51d3a669c2d6e79a6fd8cd36a87da084bfdc226f88036d51ec86	0	219	219	32	34	7	4	2023-09-27 12:34:41.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
36	\\xc94edc7d979362a9aaefb941799ec75ba2823c23c23e974faefd5161e47cce4e	0	247	247	33	35	19	265	2023-09-27 12:34:47.4	1	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
37	\\x51db2a0dccd0a2ebb3848e0090b6f3f51d127f7c8f2e2449b300cfd6be1e47bc	0	254	254	34	36	6	4	2023-09-27 12:34:48.8	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
38	\\x4def76767c179c7f65a0cdee73046cac3bb76686b45f194461e6d9aa619870d2	0	256	256	35	37	19	4	2023-09-27 12:34:49.2	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
39	\\x830cdc295afebd06f3de913c01a5e50414121daa90598e05b46a57bb388fd410	0	257	257	36	38	9	341	2023-09-27 12:34:49.4	1	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
40	\\xf0b541dcf10d27750158fd908ec303c23ae6901fefbdb00e46bd0ed4f58fbbc5	0	265	265	37	39	6	4	2023-09-27 12:34:51	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
41	\\x0f00b0ce11c55a2c0d92c4566d3e6ac7b2dbdc04ec013691feeb4eeddf624f8f	0	284	284	38	40	3	371	2023-09-27 12:34:54.8	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
42	\\xb08e9dce5c918f0f41fc07ac8c99fad985700fbb727ef5fee4b1ebc527ab19e5	0	301	301	39	41	3	399	2023-09-27 12:34:58.2	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
43	\\x71ddf4cab9ad95bb5e016a82f00b0938a845580bf139962002078ad5c91bae9a	0	305	305	40	42	27	4	2023-09-27 12:34:59	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
44	\\xec89cd9cb0cde4b91147dafdeaa75c90d2e005ded2d66c16875c4cab43f5f808	0	310	310	41	43	5	655	2023-09-27 12:35:00	1	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
45	\\xc9d5c46bd95cf9806d5ca8ee276782d4f1b8f832fb14ec4b93a4f565f30f51cf	0	320	320	42	44	5	4	2023-09-27 12:35:02	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
46	\\xff0e50a6234a169bbfdbe0a9679eeb7731e5f3d71ccb1e47cc458094797bf13a	0	322	322	43	45	11	265	2023-09-27 12:35:02.4	1	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
47	\\x34ac6e450ebfab93baa70378fbaa46f04706ef759011473194cccc5ebe2fe0a6	0	324	324	44	46	11	4	2023-09-27 12:35:02.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
48	\\x57370f12973b9fdfab689c0d0aaa9dd424c63774b89ef6e3302d1e9ff8a95e79	0	334	334	45	47	5	341	2023-09-27 12:35:04.8	1	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
49	\\x3fa8cf7ea81a2600eb7b01dcdb167f002c8977e4761a996be7f2710fa32b9090	0	345	345	46	48	27	371	2023-09-27 12:35:07	1	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
50	\\xd31855f8847ddf625ae2625365fc5f4cef97b9e40eaf6b6331b1e3885ba975ef	0	354	354	47	49	11	399	2023-09-27 12:35:08.8	1	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
51	\\xf9b067479fa786668a575cd3783742ee9df3b652439ac5a75e5f464597912f2d	0	356	356	48	50	11	4	2023-09-27 12:35:09.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
52	\\x8fc5ebc884b4a539cd6d74de05a87252ed5a441f4976c49c4d839ba7a97349e1	0	359	359	49	51	4	4	2023-09-27 12:35:09.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
53	\\x240b28eb6882567bb4002d3ebe79c05bc0211a084ac452e231c482c9e3716553	0	365	365	50	52	19	655	2023-09-27 12:35:11	1	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
54	\\xc2449735665ad35021860c13d4463cc077e0909cd783c492a9515714bf2f46c3	0	385	385	51	53	9	265	2023-09-27 12:35:15	1	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
55	\\x5aa3fa5c6262fa037ad5ccd79f239337d3a173545c6674d3bafcb205c000b4b0	0	397	397	52	54	9	341	2023-09-27 12:35:17.4	1	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
56	\\xff496f548e5308ab8e201963b82cb28b39b1559ab9616388343941e74754dbeb	0	402	402	53	55	19	4	2023-09-27 12:35:18.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
57	\\xa76070cd2388a683db0ec1449a603417a2d47dc3ca3087306eecf6cba2bfb310	0	419	419	54	56	12	371	2023-09-27 12:35:21.8	1	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
58	\\x6b03f87b254345d2dea886ab57701a08b0ae0a7a0768593a0699bbce1f6bf1ec	0	420	420	55	57	3	4	2023-09-27 12:35:22	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
59	\\xcef3e48c3562abb02df1785683badb439dcd19a17823dac3b3af79832488d6ba	0	422	422	56	58	19	4	2023-09-27 12:35:22.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
60	\\xa8991926c0d0a91e6cebda4f547d3a143f1ea2dbc631dddca17484eb5186f742	0	427	427	57	59	27	4	2023-09-27 12:35:23.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
61	\\x60deab4a7f520bca9eb56828423c1c47ea6b5ea99fb45a18606a110232a90fc4	0	440	440	58	60	9	399	2023-09-27 12:35:26	1	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
62	\\x0fd80f96a8f9bab014732a0658fb51901c3068f8ea295f6bd819a5e63acd3f32	0	449	449	59	61	3	655	2023-09-27 12:35:27.8	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
63	\\x0633970cf8036ae6af5055872865ccbce068ab47567d867b300d0d1569df90fb	0	455	455	60	62	5	4	2023-09-27 12:35:29	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
64	\\x4e4aac0744bb1d47996f4b2a5efebf0b645f838cf2f96da6fda6fceb7c833a21	0	459	459	61	63	19	4	2023-09-27 12:35:29.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
65	\\x55de50e43ddedcefd941aa4caf54f48eb529a6b6f07e9f52ae0757c632d5962a	0	461	461	62	64	12	265	2023-09-27 12:35:30.2	1	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
66	\\x0377e5ae9c1c451e92d732aa0f729189320b15445bfb2ec8026d5710473f82bd	0	467	467	63	65	11	4	2023-09-27 12:35:31.4	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
67	\\x98b853b18601ff61395c4f68fd4f8fce0235d372d7514cce2ad638b6b0360272	0	493	493	64	66	7	341	2023-09-27 12:35:36.6	1	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
68	\\x81ad65fa49a0fc8120c3fb06e926ff992f308f3ca0f0203d4b9810a819da0632	0	495	495	65	67	8	4	2023-09-27 12:35:37	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
69	\\xa2d616f15f85e828f7279800adefaac9bff1e4c42f247a517748165783163e12	0	501	501	66	68	7	4	2023-09-27 12:35:38.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
70	\\xe5bb5822f1169c13f9d670619ebcaf71a04ec792a55a96af32ca048a33e8efc2	0	528	528	67	69	7	371	2023-09-27 12:35:43.6	1	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
71	\\x9b9d28fefacd4fc3f2d58cf3e1475b321ec70b86f68a63592b0b3c3137c29b60	0	557	557	68	70	11	399	2023-09-27 12:35:49.4	1	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
72	\\xb229283c77eafb0391ffbc9496b37f326abd5ba22bf9de24c08b1a41eb53d84a	0	559	559	69	71	27	4	2023-09-27 12:35:49.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
73	\\x09d612aa200e729b51f557605909a8a60b1611a915291fac0280560e59f22776	0	569	569	70	72	19	655	2023-09-27 12:35:51.8	1	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
74	\\x1e9a69792c17b50f7b58881ca0ab60206e1aff8c498a15ddb5fe9d569c30eb6d	0	573	573	71	73	4	4	2023-09-27 12:35:52.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
75	\\x0c25d1252d64a88c73f9063715a4e57818b04a52eca33b200faf3b3eee81913f	0	580	580	72	74	5	265	2023-09-27 12:35:54	1	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
76	\\xc9f57e4824a0293f7d5c596053317bd15c6f715d40e464afaaff44d0e0940bc5	0	585	585	73	75	3	4	2023-09-27 12:35:55	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
77	\\x2a1276d12c6a5ad0d2970764a305847309797e94f4509bf29df0e315195f893a	0	591	591	74	76	6	341	2023-09-27 12:35:56.2	1	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
78	\\x254cdea440631228db7d8b2e7b2e33470d7463009f4fb4a316b1294b692e851f	0	613	613	75	77	5	371	2023-09-27 12:36:00.6	1	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
79	\\xf15794895f15645ec52baa38fe9ac83deb0ab7b5ec553c6ab7b746638844eb71	0	614	614	76	78	19	4	2023-09-27 12:36:00.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
80	\\xd2a52b4ba96a73b1584a467002de7017495331e000ca15f98d30c0fa70224ac8	0	628	628	77	79	8	399	2023-09-27 12:36:03.6	1	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
81	\\x44db4db284515f584eaa9abc4e2881590e4444cd0efca82072beca2337347c11	0	661	661	78	80	7	592	2023-09-27 12:36:10.2	1	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
82	\\xe5397ff373a9e7b50d9972f58b9fff89358f84f9c6331400cb0b4be616329cdc	0	667	667	79	81	8	4	2023-09-27 12:36:11.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
83	\\xb0ffbcaf7cc5613cf551a30f05da33586b2430b8f8bcb1fab402650fbe05df9e	0	704	704	80	82	27	399	2023-09-27 12:36:18.8	1	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
84	\\x7b5f843385bcab5ef7949f5ae2917fda266f61db7aa82fd3a7ff2d06cd0510c1	0	713	713	81	83	6	441	2023-09-27 12:36:20.6	1	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
85	\\x018fe71d00bdfbc4078baea551bebf84d32c8f78443ab0f70733e303a4dd5540	0	721	721	82	84	7	4	2023-09-27 12:36:22.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
86	\\x334da8764b4e0f111af485a0850e42f52b44d9442426bb42caae701b02e416ab	0	724	724	83	85	8	265	2023-09-27 12:36:22.8	1	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
87	\\x626fd36f6dec2c34c18f7d18d52131a461d8ea025f5e0204bf9ca7f961099b7d	0	732	732	84	86	19	4	2023-09-27 12:36:24.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
88	\\xa14fae1b1c13768d67ed339154ba947706602acc3dc55b501827c3ac8a29eb34	0	736	736	85	87	3	341	2023-09-27 12:36:25.2	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
89	\\x393d6d98643085f43e16068064e7b57e0165dc2df21473c79f664cb4db90503b	0	745	745	86	88	12	4	2023-09-27 12:36:27	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
90	\\x2694a187c47a1568927b4006a18d635e48f37fcfc0691a5093b496dd3f6303c9	0	748	748	87	89	3	371	2023-09-27 12:36:27.6	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
91	\\xa2ebeb344fb97bc0ba57f72b073249b432740c8ce170b4fcf129d1a019843c71	0	751	751	88	90	27	4	2023-09-27 12:36:28.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
92	\\x68decfa39b2a4bfc76b85b64692a97921118d2f5492529ba03918e2a861efe9c	0	761	761	89	91	19	399	2023-09-27 12:36:30.2	1	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
93	\\x048cc382599bdedd0051f142349f1bf889b506e8a932c297ed6b8ff432087458	0	782	782	90	92	8	592	2023-09-27 12:36:34.4	1	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
94	\\xf2ee6fb83c394a736f94fcad57f5b597aba8540a4180a01faf354e9df274388c	0	787	787	91	93	12	4	2023-09-27 12:36:35.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
95	\\xcb15a0540713ee892a06e81a63211c2a1d5b1d32513f5c2ce32e339693cbc88a	0	789	789	92	94	27	399	2023-09-27 12:36:35.8	1	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
96	\\x4422b9d40496bedac14687106d89f4310b152824d98f7c7db85367dc3b3c2f54	0	790	790	93	95	12	4	2023-09-27 12:36:36	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
97	\\xa9515a65c7636c02f518295f1fb1f500153146b7bf669f179453768b7185cf1f	0	796	796	94	96	9	4	2023-09-27 12:36:37.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
98	\\x73c2c3c68fa657704a5f33946fbc3463c7a3621fbbe921b7c6689411acc4fc68	0	799	799	95	97	3	441	2023-09-27 12:36:37.8	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
99	\\x27e7fae09016143af3545bbd260f798d19cb0d37d08e180980825abc833a1034	0	810	810	96	98	3	265	2023-09-27 12:36:40	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
100	\\x4e510d76b2fbfd830d4c4af76dda9966a08e3d885cb078663860a5f6ec3bf1ff	0	820	820	97	99	3	341	2023-09-27 12:36:42	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
101	\\x7692f2beea3e7fb47703db73534ae5b6e128b3ccc2ecfd0f8d10cf99784a67c1	0	823	823	98	100	7	4	2023-09-27 12:36:42.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
102	\\xd5000217a4dd26c59f4cf4e58f6a13a0e494becea7f4af1a3468e9018bfacd4f	0	826	826	99	101	5	4	2023-09-27 12:36:43.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
103	\\xb99fdda57b71dc083fd2f4f4063d5351e488db69ad48dd77f78d1b520c4e4c0a	0	834	834	100	102	27	371	2023-09-27 12:36:44.8	1	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
104	\\x1ae04070a993eee3001d8f1e5581ccb1b5add71675d7a742f6fb01c829fdaf7f	0	869	869	101	103	11	399	2023-09-27 12:36:51.8	1	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
105	\\xa576d38f4847da60fe5ab9c130d4b1c281fb85b6d0a4f43556e95d44a9c7c846	0	874	874	102	104	8	4	2023-09-27 12:36:52.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
106	\\xefc5ff9f433db9c1fbd5640a50f39c0472de6365a7c1324684e82ec3692c3ee1	0	877	877	103	105	9	4	2023-09-27 12:36:53.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
107	\\xad7beb59a22c6c69717030c1f91c0ff9186b38438a98d0f36d837609ea15c8ce	0	899	899	104	106	7	656	2023-09-27 12:36:57.8	1	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
108	\\x8db2a0d3f0660e2ed2dfd2736189b525903c2ad3e259884ca930deeb87e7161f	0	919	919	105	107	27	399	2023-09-27 12:37:01.8	1	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
109	\\xccd75ebf2814d005bf532a1071d7bfea4ad69f8b33e5d3406e105e6f64af0e77	0	920	920	106	108	8	4	2023-09-27 12:37:02	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
110	\\x10401a516ce59e42db4feb06a38642462c0108b8c597bf86d407cda96408a2be	0	924	924	107	109	4	4	2023-09-27 12:37:02.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
111	\\x63b92e244f5a4e94a97644e66c203188f3c3078c0cf8a1524ffbdb0c2f797fc6	0	938	938	108	110	6	441	2023-09-27 12:37:05.6	1	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
112	\\xa90022bc643192b24e8857c85066f8ddbbb883aaca9f5199686e8d9a3394e206	0	943	943	109	111	6	4	2023-09-27 12:37:06.6	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
113	\\x984363f3f2b991bcf3dfe556a68972b30c8a99cb012d2edb7f68833f87d4f790	1	1006	6	110	112	12	265	2023-09-27 12:37:19.2	1	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
114	\\x7da7cd05598b77729cc3adb936caba25d5c18bc038cf587f02897d985004d3db	1	1022	22	111	113	9	341	2023-09-27 12:37:22.4	1	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
115	\\x4828f15d771f1ad6d466b82ff0dbb19a3ffb7617ebe1e95b671c17c232f6801c	1	1024	24	112	114	27	4	2023-09-27 12:37:22.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
116	\\xe329ed7833a37df224fee42946cf6fe9a1cd06d9a8d29ae0243f45999eb56e0c	1	1031	31	113	115	27	4	2023-09-27 12:37:24.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
117	\\xf157b096fce50dba9669347e814fc7d96ba3ffaef8e1bd2ce0b1215ab77e4ecc	1	1035	35	114	116	4	371	2023-09-27 12:37:25	1	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
118	\\x538d48d9bcb94845223927a7930e678cd66dee296e167dd74b0fd289eda1ceed	1	1037	37	115	117	5	4	2023-09-27 12:37:25.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
119	\\x445c95807e8eaaa00bf768c2f9066f19d031e4590011f35bf0ce48d18fb38135	1	1058	58	116	118	4	399	2023-09-27 12:37:29.6	1	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
120	\\x385d810eef66ae2998d320898a6614e355e32468a7b45675504aa34f67cf8599	1	1071	71	117	119	19	656	2023-09-27 12:37:32.2	1	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
121	\\xbc5cb946b26f4a925fd875954751a4cc9e8d94b416657200fee3c44b2384ae21	1	1080	80	118	120	12	399	2023-09-27 12:37:34	1	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
122	\\xd3f4d6f27a3a5d4ba8d0d2de0b14a61586921673826a7ac34d5ca22bf6da9c25	1	1088	88	119	121	19	4	2023-09-27 12:37:35.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
123	\\x973ff3334ccff38797251866a112a931414140ecc1eadd409724ebde98ec4d18	1	1092	92	120	122	5	441	2023-09-27 12:37:36.4	1	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
124	\\x9284c1ca0af82c4e0c5b88dfa7d5e356ade0c8a54c79d4484e0ee9b5acb5e05d	1	1100	100	121	123	5	4	2023-09-27 12:37:38	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
125	\\xe66b1f9e7adc520e75a6f4dc7075f320a15756346d965cbdeb2e92ec2c7514b8	1	1117	117	122	124	19	274	2023-09-27 12:37:41.4	1	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
126	\\xe0446a9521d58c192ab454e3e73b564a6f3eb281710eeab94d4de33ef820594d	1	1195	195	123	125	3	352	2023-09-27 12:37:57	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
127	\\xd5f7919bb23372f1af6985651dc7a2e924401621735992b321f7512299a885d5	1	1206	206	124	126	6	245	2023-09-27 12:37:59.2	1	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
128	\\x956bcd1deee2c5bc57bfd3cc82d402d3ac0c74c2503af3f13bffd28a4c51e5f3	1	1209	209	125	127	8	4	2023-09-27 12:37:59.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
129	\\xf6005005a187468b6db0e7ca6b700e8a369f73acd43579eed22bbfe7362a5d26	1	1220	220	126	128	5	343	2023-09-27 12:38:02	1	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
130	\\x158bb193e872fe8b1b29c5bee8b49ed3f832090ce10b05529cf2f64315320562	1	1225	225	127	129	3	4	2023-09-27 12:38:03	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
131	\\x881eb587c315232a830d6282591998d6a37deb65f40787684d21edcc598bba65	1	1227	227	128	130	6	4	2023-09-27 12:38:03.4	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
132	\\x1d579733ade4d7cfe8dad3ff40cb63bda44b51e4bd15d87e736322a45983db06	1	1237	237	129	131	3	284	2023-09-27 12:38:05.4	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
133	\\xdfc699df7b08185fbc4a806967bf2937d94bd61856496cd245921c20b3c93b12	1	1257	257	130	132	6	258	2023-09-27 12:38:09.4	1	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
134	\\xf7828330e2ae8c1fa1319f404724a9acb7a26048089e7c44bfe8645cf2036595	1	1259	259	131	133	27	4	2023-09-27 12:38:09.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
135	\\xc6295195a89b90c896dc5f72048de4c076cb6d70f63d5737846a2c080aa37640	1	1261	261	132	134	11	4	2023-09-27 12:38:10.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
136	\\x370d3b4d60079ad1eda4d08b37f2d751d54487dabaeef49d4f2b6578190eee87	1	1265	265	133	135	19	4	2023-09-27 12:38:11	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
137	\\xb60b3ead4e1eea2af134bb2052b53c27192d9b19c8b87af88412410bc096e65f	1	1274	274	134	136	27	2445	2023-09-27 12:38:12.8	1	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
138	\\x5a933e8ce5a1dc86fe034c40eec33071f271eec0b8977f5d89671e901f51ed18	1	1280	280	135	137	6	4	2023-09-27 12:38:14	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
139	\\x6f8a4cdd02b0c3eac36d1bd665391f24bcac58534789bc64f8ee42883b5b0f19	1	1283	283	136	138	5	4	2023-09-27 12:38:14.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
140	\\x947bbc860c27d04bf64b85f0cb72633cd4c0d864d02ebdc6dff17f59f428716d	1	1298	298	137	139	3	246	2023-09-27 12:38:17.6	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
141	\\x3e7441670a8db80c0144eb77924e172a125ddb37d5ece804a7a0c2c02d1b57e2	1	1317	317	138	140	9	2615	2023-09-27 12:38:21.4	1	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
142	\\x8aad6c27c5e6b27295e89d93787e481fe1c1ebe7a64ac50dd95124ca63f4e05d	1	1327	327	139	141	4	469	2023-09-27 12:38:23.4	1	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
143	\\x7aff3a8734724eb43ebb43cb583c2b5b5801f818564e5900c1937e8f05fd553e	1	1330	330	140	142	8	4	2023-09-27 12:38:24	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
144	\\x09145eba7ec03146910fa4fd11435139205191b97e00f9e428bb89b6436e3e10	1	1333	333	141	143	27	4	2023-09-27 12:38:24.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
145	\\x7acd9199f55acf06240dcf142856342294166ff9f4f162616114639ea3adf5ab	1	1343	343	142	144	11	553	2023-09-27 12:38:26.6	1	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
146	\\x00083d970c5dd6a79fcd245de169ff9e6f032067242f15a6a47726ac9b40c377	1	1345	345	143	145	7	1755	2023-09-27 12:38:27	1	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
147	\\xace7d1c442cf5e0d67007f67f69423cae25e2b49559f7aff30d0ec9b5a3e80a3	1	1351	351	144	146	9	671	2023-09-27 12:38:28.2	1	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
148	\\xf429b88e99eb40618407b6ab4bdd62f424871a5960fbf911ace3f75f6f2fee12	1	1363	363	145	147	5	4	2023-09-27 12:38:30.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
149	\\xfbc86dfca49feb1ae736464c7acd0760811e8c4f370e26d59a6d17514cff91d5	1	1367	367	146	148	8	4	2023-09-27 12:38:31.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
150	\\xd579ec56afea669e7e111b58edc010f6ce9c2179d0e3be77d0d8c99a8c95fefd	1	1376	376	147	149	5	4	2023-09-27 12:38:33.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
151	\\x995853de83d8f2c0659083958e59e2fd78dc8ed38229602d181a0b772a6f7af3	1	1396	396	148	150	3	4	2023-09-27 12:38:37.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
152	\\x681229730d00c694b9a7d969a3a720beeebea56ac138267e138af1f0937f6fbf	1	1399	399	149	151	19	4	2023-09-27 12:38:37.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
153	\\x5e590eac379a3292fb6ac9b2d9710d0025bc17c0be8de8052082317e4d2d2aad	1	1407	407	150	152	8	4	2023-09-27 12:38:39.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
154	\\x204fcb9a3aeec571fbd06c64fd182de122fbe89e372ee823b558cf95d5f973aa	1	1409	409	151	153	12	4	2023-09-27 12:38:39.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
155	\\x02317d0aba34dbf46f13ae03f5d5aef0e8f873ca3a787ed1bfbc9adfd1e05621	1	1415	415	152	154	3	4	2023-09-27 12:38:41	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
156	\\x98241e0ad1f6c483f7e70cb52a4dd9a08f6b9b51fef2f645c6a6cd811f670ee4	1	1430	430	153	155	7	4	2023-09-27 12:38:44	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
157	\\xbf633e16a3525319b699a0889f5aff77c9e1c1cbd1476aa4740a2c807f0b594e	1	1435	435	154	156	5	4	2023-09-27 12:38:45	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
158	\\xc25d2effcb452ac3df49f9f9c6eb3d529f58f86979819de16b4d1e531f346675	1	1446	446	155	157	19	4	2023-09-27 12:38:47.2	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
159	\\xddc43d85e9e69fa1a59e95647195384b84d7240ff984f0473051f95c40c70790	1	1449	449	156	158	11	4	2023-09-27 12:38:47.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
160	\\x10a646563bad68c18dcacc6310f5a1b7b5c4e9527b6519ac672a9b6dd0c1b08d	1	1450	450	157	159	4	4	2023-09-27 12:38:48	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
161	\\xc1b80a0a81e8c871728578cdd83bcf444cea3e1fd290143b18afb924a072036d	1	1451	451	158	160	6	4	2023-09-27 12:38:48.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
162	\\xe93d4308892bfdf2e7643ab4455e560f7b26d2f953594ae46bcb8be21f89d1fc	1	1460	460	159	161	4	4	2023-09-27 12:38:50	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
163	\\x8b4204a8d4807ac91d62dd8785ac2498c22f9345ae0a2ae44cd56555476299cc	1	1463	463	160	162	19	4	2023-09-27 12:38:50.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
164	\\x6113dcd2889d472c02714eb3e1b4c6b953c5674acb73017d85c525c3d6c181b1	1	1484	484	161	163	27	4	2023-09-27 12:38:54.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
165	\\xe9d1fd8bd43ab1e0439bf621066e7f9dc4742232cb35182be65848cd4ec378c7	1	1501	501	162	164	11	4	2023-09-27 12:38:58.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
166	\\xf886e1cb434258c1c6fe9cdbf48b41709d802ec9f0ff692d5c2ea970f104db79	1	1505	505	163	165	7	4	2023-09-27 12:38:59	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
167	\\x47c9d7eb3ca2d204f6f1388ef57817bf43b2704fd777450869a0d95d673d0575	1	1524	524	164	166	27	4	2023-09-27 12:39:02.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
168	\\xe9eab5c7d934a1e423f2f2b78e14b94bc17b16029a8d0b55322855216532b58e	1	1544	544	165	167	11	4	2023-09-27 12:39:06.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
169	\\x1df0c66de00460c9c75ca77870e45de3c00c5570f2ca1fb6c56313064fd7f8f9	1	1555	555	166	168	5	4	2023-09-27 12:39:09	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
170	\\xde6cdd982435d0e15d882e1c7d58a2069c8cfee78d2941e7a668824d00d6e413	1	1570	570	167	169	4	4	2023-09-27 12:39:12	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
171	\\xa104fbaf3c5e16bac66c4f22c892ebc81ee84f1b49c023f797b6efc4a6a2dcbb	1	1578	578	168	170	12	4	2023-09-27 12:39:13.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
172	\\xfdb48fba4199ef6d4c7b28d92a5823a03cafcfbbe19b7537af75b99a050b80da	1	1592	592	169	171	19	4	2023-09-27 12:39:16.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
173	\\xb60b9232ed17c0864eb193cf160fcb8a92a9c18e138c1ab19b1f1fc282e9f5f3	1	1607	607	170	172	5	4	2023-09-27 12:39:19.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
174	\\x2262b9c646339cece349f0340fe4d06f3f76ededc5d75f4e96a00b1c85c72d27	1	1608	608	171	173	27	4	2023-09-27 12:39:19.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
175	\\xf9574d99e989a9d7f00846c00c50eac55f561c9df9ef8cc742e88469f829e08b	1	1629	629	172	174	3	4	2023-09-27 12:39:23.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
176	\\x34087b47879bdc09e7bb1707b281559d35e0afcc289731bf5e400f9f7d32f09a	1	1650	650	173	175	11	4	2023-09-27 12:39:28	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
177	\\xf03e66969bde9d067d1706ab85fc3d3642cd3ded50a0696c1da258e86ef4143f	1	1661	661	174	176	6	4	2023-09-27 12:39:30.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
178	\\xac786fadca7a1bce35d2b6c9ec6fcff77a12c188c2a74fb0a1da344ddff8b0c6	1	1663	663	175	177	6	4	2023-09-27 12:39:30.6	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
179	\\x30745ac6c96ab4e2aefc75bfaaf76de33e02e8be93a308059ed07ce1066f6b4a	1	1674	674	176	178	12	4	2023-09-27 12:39:32.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
180	\\x207bca79b16b195a79a56cfe4378e150f68977f4073d3e940b387fd9ab5da4a1	1	1675	675	177	179	19	4	2023-09-27 12:39:33	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
181	\\x9bb3dfca7ad5e338a934311ba9e7d9f655e51116971bbdabb551acfe8862079f	1	1677	677	178	180	11	4	2023-09-27 12:39:33.4	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
182	\\x60d0a1b48bcb301c35b1866fcbb66466d6cce147f413b0e3e58889076cc16e0b	1	1691	691	179	181	4	4	2023-09-27 12:39:36.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
183	\\xc6041f09fc8f70c23bbb604d6382f451bc103bcb082671e8de71a3d815a4e9a8	1	1695	695	180	182	12	4	2023-09-27 12:39:37	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
184	\\xf867bb33a0b44863b7c387a8d9df9c378207322bae16111c17329d6808b4c34b	1	1707	707	181	183	11	4	2023-09-27 12:39:39.4	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
185	\\x7fad4490177fecbd031ad475749002c5321f3941e2797ec29c4d54415cf31681	1	1711	711	182	184	3	4	2023-09-27 12:39:40.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
186	\\x70615bd21384b2fd3bb4d0bec94072def3149ab7f74e0044bcf900b1e0af2571	1	1713	713	183	185	3	4	2023-09-27 12:39:40.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
187	\\x335f08b716475c2d8388b86aaece757943f55e8218729eb465c1c25f3214afa6	1	1716	716	184	186	9	4	2023-09-27 12:39:41.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
188	\\x3c2ef7e54a95745899195a17509cd5ad2bbc0ba1fd17da4de7b18f481fc29d4a	1	1724	724	185	187	19	4	2023-09-27 12:39:42.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
189	\\x3f32f96a37e7844592af93b52312af6655ba6a04c403d42d7bb1564712fc3d7a	1	1743	743	186	188	11	4	2023-09-27 12:39:46.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
190	\\xb4b78949018e98a19a637a2985feacf1e8df6d2b38c9e5aac70f8b008a75ed7b	1	1746	746	187	189	5	4	2023-09-27 12:39:47.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
191	\\x03fe84b8a617bf13fb2b05941351f82686e4b5f22cf126fe509b9eddad398b02	1	1754	754	188	190	8	4	2023-09-27 12:39:48.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
192	\\x778ab82779dfaa05883dcb4b01182f3b6edf767b0785baab8ceac4bb0d8ae5cd	1	1756	756	189	191	9	4	2023-09-27 12:39:49.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
193	\\xc03d116a3d0cc8e85e4c83ca37909ff13cdce29700ab5aab698e138de9359ee5	1	1765	765	190	192	27	4	2023-09-27 12:39:51	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
194	\\x6421c4e0754dc181a1444a19b2b18e1b77ef5db46dc5a1b98a56998d86ec47c9	1	1773	773	191	193	3	4	2023-09-27 12:39:52.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
195	\\xe189ec96e9e936affbbdff91f5b78dfb3ad471f7d13d3496c1d2d6d4f0d88902	1	1774	774	192	194	7	4	2023-09-27 12:39:52.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
196	\\xfe188ae874a2c07cab5585f3f2c1c5c7f0358ab8749db0b6c60c6b308201269c	1	1807	807	193	195	9	4	2023-09-27 12:39:59.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
197	\\x0fa777059bf018141e649c52feeab4b39aea79c9435845478b58efb9024f2d24	1	1816	816	194	196	19	4	2023-09-27 12:40:01.2	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
198	\\x85b5a379d254320e1bd6c129bc35e6dc7f9dd8137b3d8a091faa1957343d71dd	1	1836	836	195	197	3	4	2023-09-27 12:40:05.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
199	\\xaddc96248257d8ac706e55ef82f2b99e6a42414155152029e7376b98d44d97be	1	1854	854	196	198	9	4	2023-09-27 12:40:08.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
200	\\xdc818678e7923b442bd17a6852e495d9f85540546efb5bc4427dea124b520bd5	1	1864	864	197	199	11	4	2023-09-27 12:40:10.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
201	\\x9d47f7d4140d2f13cb2dedbe62bb3128775a3c0bf1f7a1c422f49ae0df689698	1	1875	875	198	200	5	4	2023-09-27 12:40:13	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
202	\\xd1769d1430fba7fa809a4c842dbd3c04e57ae6b35e8cbdc7a2c486e1d639b327	1	1888	888	199	201	12	4	2023-09-27 12:40:15.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
203	\\x43bb296657d10cd43167f7b8661e49632e2a5532207cd756b2daaf38d2c34113	1	1907	907	200	202	8	4	2023-09-27 12:40:19.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
204	\\xf4e52e82cceabd27bf5be34c96f1aee50e7e97f80ff34feeb3a01f08b02932d7	1	1926	926	201	203	6	4	2023-09-27 12:40:23.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
205	\\x6cad9f92523bab115ceb7f74ef0710f56ef66d4ba2e315cacf4a0fb8a9e662cd	1	1937	937	202	204	12	4	2023-09-27 12:40:25.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
206	\\xacd7e15b322b0bf1d80dce5b30f70ce3487a99402edd0547c5d2ef7b3e021d04	1	1958	958	203	205	11	4	2023-09-27 12:40:29.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
207	\\xa90451e5ee0d01891b8bc857c30490d40f022ea847da01bb3a516e9c24f397b1	1	1964	964	204	206	8	4	2023-09-27 12:40:30.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
208	\\xa8475a6bb0faf4d805f7450e1b81987a1fd2d6919bbea682552f60dc94bef4b9	1	1982	982	205	207	12	4	2023-09-27 12:40:34.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
209	\\x45ed71e1622c233c874470597dfb7ce3ee0cb5c9330d247e7301e47bf0fa092a	1	1984	984	206	208	3	4	2023-09-27 12:40:34.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
210	\\x10abdeace7cc666c6a4f35b990674e4f9dcb0d34dd62192ff67360cc2a0135bc	1	1997	997	207	209	3	4	2023-09-27 12:40:37.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
211	\\x3b087f304f61c9bd4df980505ce826c936c430c7d88d43556b12667ad29b3045	1	1999	999	208	210	9	4	2023-09-27 12:40:37.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
212	\\x3c1a55b5892640fb36f68afeca3c51a0b95a82312a5ade0ca3af80eab0595abc	2	2014	14	209	211	19	4	2023-09-27 12:40:40.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
213	\\xb8391ef342156ceb271cb3f21035d61a93667596527195b4a514f467d5ff2a25	2	2015	15	210	212	9	4	2023-09-27 12:40:41	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
214	\\xe4c27ee263a004cac8b6f169858cd8eb9d529feb66b80e4cdb335b3d9f5b5342	2	2018	18	211	213	27	4	2023-09-27 12:40:41.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
215	\\x8534a942158dcff116f1a11f8704ea9c313a0a425feb078a546089b1dc20484e	2	2028	28	212	214	27	4	2023-09-27 12:40:43.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
216	\\x6a7fa92fc3ac0ee0328b090c614aa69dfadaa682d626199a360fe0f247d40791	2	2037	37	213	215	9	4	2023-09-27 12:40:45.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
217	\\xe4ea22893a9c51d13487730d7986c95449d1c1f12fd82000453093213b5c9d48	2	2045	45	214	216	7	4	2023-09-27 12:40:47	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
218	\\xc5e788ff01b4515a5e431b41c9614af479133f77acff0fdff3372b8c9b6123cc	2	2048	48	215	217	7	4	2023-09-27 12:40:47.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
219	\\x26a96fef25fee2f0287886ec9b6614437c8f9d3dd3ef7b405fc5d4c19638e61d	2	2058	58	216	218	11	4	2023-09-27 12:40:49.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
220	\\x8f4a07e204c0dc0bd4f407209e925e0f4fb2c9da5247b57e3c5494dbae7304b7	2	2064	64	217	219	27	4	2023-09-27 12:40:50.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
221	\\x207a9ced079671d7a0f080fb623000f4f53f5b31e4290a0c706492bf1e78d363	2	2068	68	218	220	7	4	2023-09-27 12:40:51.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
222	\\x2c4a93855c780d61a1be2dfd6aad86e65eafc99eb7ccb640d1b5f510551e1ec4	2	2072	72	219	221	5	4	2023-09-27 12:40:52.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
223	\\x8ce344fce90f525f9bb1f23176bb30eb251ab079ce706d2d38348da33811170f	2	2075	75	220	222	4	4	2023-09-27 12:40:53	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
224	\\xd40ac81f24ce628e1aec39193c35d6ad7df622fc28c4444017dc899c15e3afd0	2	2089	89	221	223	19	4	2023-09-27 12:40:55.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
225	\\xbce6b8c43ffef50011f75d549418ae7b62b0ca775d2c484d584ea152fcb7a095	2	2097	97	222	224	19	4	2023-09-27 12:40:57.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
226	\\x740ffa1a26044b4ff326b17f78363344f86aff1cab20859c4441afbd00d12b77	2	2098	98	223	225	27	4	2023-09-27 12:40:57.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
227	\\x0d1588d4a509c45eb0225d471c82c31eca6bf7e78b71ee52acdc414750852eb8	2	2115	115	224	226	12	4	2023-09-27 12:41:01	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
228	\\x6dc968414c4664b65c2044b2f3a95d548124de5a8585b8c18ac916ad22583a39	2	2122	122	225	227	5	4	2023-09-27 12:41:02.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
229	\\x79089a2bbb21c281229444e145bf700acbdcd35ae1de920ae3a76f1ee5381e28	2	2134	134	226	228	4	4	2023-09-27 12:41:04.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
230	\\x93bfe0419d91983cff0ee8251920cbb53674c560475bc365df3efc13d3bf107d	2	2139	139	227	229	3	4	2023-09-27 12:41:05.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
231	\\x0c829905643d9f978f227d80a953036ef6b8b71a35ffb9ead78cb00c0df5f6df	2	2141	141	228	230	9	4	2023-09-27 12:41:06.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
232	\\xe170adfb0f6ccb9e59f5bfcb55f8ebdc994c4770a3605c39fdfff25ca2af790a	2	2152	152	229	231	7	4	2023-09-27 12:41:08.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
233	\\xf556cd1390ccc9323612f005a6627a00d0d856b574899a948f7a19eeaa2b10b3	2	2173	173	230	232	9	4	2023-09-27 12:41:12.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
234	\\xbbd5cdddadba19672bce26c09d60bb5800708c463c1676511115cfcf6e914db9	2	2186	186	231	233	5	4	2023-09-27 12:41:15.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
235	\\x33fabf37d86ead7776c6a40eb62ac92e66198c051006951edd62c5200b6d0691	2	2194	194	232	234	3	4	2023-09-27 12:41:16.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
236	\\x76b9334ea0a9485d5cbdbd623745c6f3ecaf21ec078e613b0ab61d79b1915cc4	2	2202	202	233	235	5	4	2023-09-27 12:41:18.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
237	\\x93c1458679d196b8cff8afb803ea3fa67fc4940752218b5ecddb1e8840935bce	2	2208	208	234	236	11	4	2023-09-27 12:41:19.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
238	\\x60cf0a1b9d8d8a1b10b861535bb6f6daff068cfb66cd684ad4659207ef19ee94	2	2227	227	235	237	9	4	2023-09-27 12:41:23.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
239	\\x24cb9deeb0340153306bb5dc3be5418924a514bdee82938c3170ea1ebddac64e	2	2237	237	236	238	19	4	2023-09-27 12:41:25.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
240	\\x5feffad1229116a7db7c847ed4888ce52c5be706fadc47f4eafe172f12e86fa5	2	2238	238	237	239	6	4	2023-09-27 12:41:25.6	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
241	\\xdbff9d3cdb41258fb828bf34315d9476f3161eaf505dbd21db00762a5b561297	2	2247	247	238	240	4	4	2023-09-27 12:41:27.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
242	\\xb387c8443cfc0092a92b0c06a4d68ce5f4ea19b85a38f2654b842267cf0d821e	2	2251	251	239	241	6	4	2023-09-27 12:41:28.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
243	\\x9378d1c7a90cf3e7d377e4fc5f327e6c3fed74e4c95c2b2c0213b21c7c48359b	2	2260	260	240	242	11	4	2023-09-27 12:41:30	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
244	\\x0a898d24d18f21e7b8ad54a40dc4100d5c7280931764b2e9c2ff2e092d705eb0	2	2270	270	241	243	4	4	2023-09-27 12:41:32	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
245	\\x056d0e3db837e168dc4fb3871cb971244a54390d51dca050e1c14df2e4957b79	2	2273	273	242	244	4	4	2023-09-27 12:41:32.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
246	\\xacfb9cea2ad1d4a62969e4a81e07bc147bc2146cb32ee1d8b45b0e7dc5dabad6	2	2301	301	243	245	27	4	2023-09-27 12:41:38.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
247	\\x8279cbc477c20b111274a638fca3c9f3829586f3b7e766091b4a983f698f60ea	2	2323	323	244	246	27	4	2023-09-27 12:41:42.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
248	\\xe0f6a7f0dc203c65341065c93b11c7835aaf6e49781a234cca920543e49b20c1	2	2328	328	245	247	3	4	2023-09-27 12:41:43.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
249	\\xd27ef1714553305b8a08dd96d4f5703935847ea03c1becd74e5187b1be2455a9	2	2329	329	246	248	27	4	2023-09-27 12:41:43.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
250	\\xc40c862cb8e75f799aedf2be2314485e522b2fd04ed44b5e11f72a1e793bd282	2	2342	342	247	249	4	4	2023-09-27 12:41:46.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
251	\\x4d7a23e728756b885e00824abbf185557beed355b38d6c564e82c99f3b5aa918	2	2347	347	248	250	9	4	2023-09-27 12:41:47.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
252	\\x6f3daf85ec223f7cc4859866ce5f5244e657a2bb1902b0281b1700ec14508c40	2	2366	366	249	251	27	4	2023-09-27 12:41:51.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
253	\\x97dd26b70ba8731201f6328e0a1d1a38927b7653ea11c8b34a46ab7ebd6918fe	2	2373	373	250	252	5	4	2023-09-27 12:41:52.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
254	\\x35023bf0298601d97f98e28f627b678e84fc3ce670753a7fa6860318c004660d	2	2385	385	251	253	5	4	2023-09-27 12:41:55	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
255	\\xe8f08f7d830675ce13537e7e0c4401ff02992fd56246056399c14921b36593cb	2	2389	389	252	254	6	4	2023-09-27 12:41:55.8	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
256	\\xf80ddcf2393d00af3ac1921a47d85cb9ddbcac078bfd64c458f7efa0182adb3a	2	2395	395	253	255	3	4	2023-09-27 12:41:57	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
257	\\x7dd257ec727288d5accd529193cc017b791ee7d0671d94fdece00a928b7aafcf	2	2402	402	254	256	7	4	2023-09-27 12:41:58.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
258	\\x3abd14c62b368a135430455630264521f86c76b97899bf83dd86d98d3ad56ef9	2	2409	409	255	257	3	4	2023-09-27 12:41:59.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
259	\\xe0dae68ce5eebee8ae6b05689faefe4963891fd08c138e7a7c082ee4847602e6	2	2424	424	256	258	12	4	2023-09-27 12:42:02.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
260	\\x88cffbd10988e5e2e49945ecc76c9651ae4be4ead6d6adbe1b2303bedd79eac9	2	2427	427	257	259	5	4	2023-09-27 12:42:03.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
261	\\x216375c83286111914bea2b3edc2bdc199af80f9805578ece50a20421b60d9a8	2	2432	432	258	260	3	4	2023-09-27 12:42:04.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
262	\\xce59850d3bc4e3eaadef611c64afaee726cf8ad8b13fcc0810feb05b625a4928	2	2438	438	259	261	3	4	2023-09-27 12:42:05.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
263	\\x086583c186ccc00debbc58fc33c86df03a4ada3b1e82d0187911d85d98f408ad	2	2441	441	260	262	7	4	2023-09-27 12:42:06.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
264	\\xbd5ec10b636c9f1f962c9c3dd720a9b24c78755cd65610f61ac1368a96291dc0	2	2455	455	261	263	5	4	2023-09-27 12:42:09	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
265	\\xf652a1fd5b4cfc7224a56a8ee610bb09ebefbde3a1a06539cd0406683569d032	2	2463	463	262	264	5	4	2023-09-27 12:42:10.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
266	\\x57e4e83d189c53d02643558119697c2fc75ebf53d33e666222fcea636dd4aa9d	2	2464	464	263	265	3	4	2023-09-27 12:42:10.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
267	\\x3d62382973a785823990af182f6041feed57ff4a84994a995e2fc938c77f314d	2	2466	466	264	266	9	4	2023-09-27 12:42:11.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
268	\\x7fe146679035437f77aed00f2b046cd938d72efa9345f2bed35ddceea9363a4d	2	2470	470	265	267	7	4	2023-09-27 12:42:12	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
269	\\x98c773ea97f6f6ed1112d3bb7762e2a8ed187f47d7ee5cbe5a65ca2024eb430b	2	2481	481	266	268	8	4	2023-09-27 12:42:14.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
270	\\x30f6ba5ca14ffe497bf99782eae7e782b779eb09e66930f16bef6e049843a686	2	2484	484	267	269	4	4	2023-09-27 12:42:14.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
271	\\x92221ee8543bb2c4de9b17c2a5ff1445eaff401c483cf4ce1ba249237ae413fc	2	2486	486	268	270	7	4	2023-09-27 12:42:15.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
272	\\x222694c73d6b4383a53ee492d4fc1fd0aeb9c227ca95e84de9ab6c7738d2318f	2	2493	493	269	271	19	4	2023-09-27 12:42:16.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
273	\\xc8de6e127e77cb8b1ea67e037d61c5dbaf89b0a72448f36562110d1262cd8a81	2	2504	504	270	272	8	4	2023-09-27 12:42:18.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
274	\\x7b9ecbc9d3e6c45494754fb1be2b0f65082234607a98b4454ecb92cab88b8b8d	2	2511	511	271	273	9	4	2023-09-27 12:42:20.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
275	\\xcedad293dfb221d06e46613f96f32e53cc9b633e255e237c90a09c5bfc65afd1	2	2516	516	272	274	19	4	2023-09-27 12:42:21.2	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
276	\\xec23dbc375b04701996efe9326c857c71fb26ccb8fbaddc498d48f185949ba72	2	2534	534	273	275	27	4	2023-09-27 12:42:24.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
277	\\x50124fab0fa4ec5ef15e8bd0d50dd96088c14c12a90715999893d483dab9f181	2	2546	546	274	276	3	4	2023-09-27 12:42:27.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
278	\\x7104acc0cc80fb13673fc010f7413f23bc12d7021580ded35209dedede5a0b6a	2	2558	558	275	277	7	4	2023-09-27 12:42:29.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
279	\\xab80b54e88b4c2ecfce5841119fcad3ce37de8c05f5930564e37eb2f9a928914	2	2570	570	276	278	19	4	2023-09-27 12:42:32	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
280	\\x681952c0e043a3f1125079dfe2490538b1177c70a64130829966974f2cb92258	2	2584	584	277	279	8	4	2023-09-27 12:42:34.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
281	\\xa98ba67adbaeb00f5184c837e46199032ba42b0c89cb1cd158b09f8db1f3c6bd	2	2598	598	278	280	3	4	2023-09-27 12:42:37.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
282	\\x6927567386c92c1af08a8fc625f29f60398c691d323c466311e4271d0541d0e0	2	2612	612	279	281	11	4	2023-09-27 12:42:40.4	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
283	\\xef97d596f5c0c1a503368233c623c67cc02d9ef791e933760494a4243cefe51d	2	2654	654	280	282	19	4	2023-09-27 12:42:48.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
284	\\xfecc791e73b4f78cadb44893bfe71e789df92ee58ec8c471623fe699191641e0	2	2658	658	281	283	4	4	2023-09-27 12:42:49.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
285	\\xdd91188e7d812563a3fbf42b4cd5ece62a57a1bf1b6060fae0833688266d4c11	2	2663	663	282	284	27	4	2023-09-27 12:42:50.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
286	\\x0e05f69a20f47b00ab9f50b321fdadd17e5daa9426d1a01a73aa9346a2d75aac	2	2674	674	283	285	19	4	2023-09-27 12:42:52.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
287	\\xe0d88940043201d991cc4193b1da88408c96dbf8256ffe5c3eb796eaa3d3fe5b	2	2682	682	284	286	19	4	2023-09-27 12:42:54.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
288	\\xdf47b69566900f155b7a51baa572c9da987e4a8708fb15fa6a97758a5b8b104a	2	2685	685	285	287	12	4	2023-09-27 12:42:55	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
289	\\x764f77c4b9013e870afafecb001f04ab9fe923f30370882bee71038e7cf1fa29	2	2710	710	286	288	19	4	2023-09-27 12:43:00	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
290	\\x90747f61afe517431f75427eaef502326dfa0fce91bac8c3a35eded716469c26	2	2711	711	287	289	11	4	2023-09-27 12:43:00.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
291	\\xa6dd28985c1f66dae305d211b13cc19d350f30c1b69c2f4b8e9f654d16d39da6	2	2726	726	288	290	11	4	2023-09-27 12:43:03.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
292	\\x9602380fe64da2fb8fa112136320ccdc92ee875d3c6834ffccfc525baafb3361	2	2739	739	289	291	4	4	2023-09-27 12:43:05.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
293	\\x73fbe706b17b5a221e6d1f1c67ca6907c7b4554fbd0780fba8c78304163f309c	2	2747	747	290	292	5	4	2023-09-27 12:43:07.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
294	\\xbd2844351843c376fae2c044e4297a4a850ca035b91d7c8d5b39c6241c8ac724	2	2759	759	291	293	9	4	2023-09-27 12:43:09.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
295	\\xe61c228ec35c801235e08113092e79da4e0c51f71ca9311b80b0b4ea3b6c8c49	2	2776	776	292	294	4	4	2023-09-27 12:43:13.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
296	\\x65adf372f864ec231e2412d02d591c03cc8d819f502ae87443d6ef58548ec79d	2	2782	782	293	295	9	4	2023-09-27 12:43:14.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
297	\\xe3b240fac36d1c4c5dd6326000a97407a88f0d0a4411ed81226c92184bbc4f1b	2	2800	800	294	296	27	4	2023-09-27 12:43:18	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
298	\\x916015454e34030cf6a7ad30e361b6a348b440a35ce9e18a6a9c179f68fb43fe	2	2816	816	295	297	7	4	2023-09-27 12:43:21.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
299	\\x370982a337cc640d54974e0ac806847461d0aa3650ccd2c3137251e3a3c8e3ca	2	2818	818	296	298	7	4	2023-09-27 12:43:21.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
300	\\x0fd1a77679b52cc424003d6c313772eff909de8c0878bf09da3482f88942aa49	2	2845	845	297	299	3	4	2023-09-27 12:43:27	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
301	\\xf2017c86ce40feb13ffd9d8ed18ee9b372bd40a73c1ebd0785c46e2041562f51	2	2866	866	298	300	12	4	2023-09-27 12:43:31.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
302	\\xd11a80db1ac461542d243889d6a326a49bc840e6ab3b6c6e9fab14d5bfbda627	2	2875	875	299	301	19	4	2023-09-27 12:43:33	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
303	\\x232a9ac2fe1a3248630a179968ffddd07c0c644223893307e7d56680a4169f9e	2	2880	880	300	302	19	4	2023-09-27 12:43:34	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
304	\\xacfb58a6a341b8652f4a933f762355eea47bc3ff7910d249167920fe2e0ab8ad	2	2885	885	301	303	6	4	2023-09-27 12:43:35	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
305	\\x0022e933bff3887cb62a31df7b3c0f04f207647a2beefc155904b5497c880c71	2	2895	895	302	304	8	4	2023-09-27 12:43:37	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
306	\\xe694e9aa194dee2e818b455a8ac7f918dd56a52ddabefdb512c92f2b8bd2d5ab	2	2917	917	303	305	27	4	2023-09-27 12:43:41.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
307	\\x6f02dad20c84d2a9a82713b8e5e7aff6064eae91b8b708c0818797dfcda93deb	2	2937	937	304	306	5	4	2023-09-27 12:43:45.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
308	\\x9c9b3ed5eddcee9b631da474484371c8521da969de0911b8eaa29edebf061b67	2	2941	941	305	307	5	4	2023-09-27 12:43:46.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
309	\\xc90fecde7e0058ea2e512c6a8ba7cd153d3ab529be43cdebbbda594e19ef347e	2	2949	949	306	308	3	4	2023-09-27 12:43:47.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
310	\\x05c521b572faae149b1bc4e259f96b7f81cbe9748df99cbb27d0899f02c2ccd4	2	2957	957	307	309	19	4	2023-09-27 12:43:49.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
311	\\xe20f0d97227c2b0747a25b41926c95f44c6e022290a588c6d7ab35c37dd5fb80	2	2982	982	308	310	7	4	2023-09-27 12:43:54.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
312	\\xc54b7d3896fe29a286cbe8827ec3d4234120b572727cb953d3c0f90cb7d7ee05	2	2995	995	309	311	7	4	2023-09-27 12:43:57	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
313	\\xbb8842e11b54cc57bde05249dcd9b3f77525b17cecf6d537527b950b26ddfca3	3	3029	29	310	312	11	4	2023-09-27 12:44:03.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
314	\\x8ca6bdfc31cc33364e41b16f18c9459e4e6a17285708402deea8e1b48695607a	3	3034	34	311	313	4	4	2023-09-27 12:44:04.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
315	\\xc6d1994235f7b51070f111c2a6c219dea31c38ced53970864dd687b896d98b7b	3	3039	39	312	314	4	4	2023-09-27 12:44:05.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
316	\\x8e17f2ef4aae1fc2205c1c6622c97ca81d59dd697bf60bb36f1a5d48d72d91a3	3	3044	44	313	315	11	4	2023-09-27 12:44:06.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
317	\\x2c3ab510b1dffe1eb3b7cdc9908dc0c443a4ac682e037f7d2f7d3423bc586703	3	3047	47	314	316	3	4	2023-09-27 12:44:07.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
318	\\xc56f102a22bb11cc002a018b87eb15f68117f6c8d4e39f62d2f72b9a7425a027	3	3078	78	315	317	4	4	2023-09-27 12:44:13.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
319	\\x1ad4cdd4af2081b376016251dca3250b393f11c0d3774e6aa60a8404a66de3a8	3	3084	84	316	318	9	4	2023-09-27 12:44:14.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
320	\\xc17576848db0cbc43e476bab1a1dc3cf7a9ea766e5b497fc354eff9944acdd62	3	3089	89	317	319	11	4	2023-09-27 12:44:15.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
321	\\xcede22d8e0fa0d955614283cec463d3d100c7703192acf0f41cc75bc6ad2531e	3	3091	91	318	320	6	4	2023-09-27 12:44:16.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
322	\\x2a7ae42150a4a811fb104636b98176b042c764342af5f4c28305adbfe9dbfba0	3	3097	97	319	321	11	4	2023-09-27 12:44:17.4	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
323	\\xb1c89acbe746719811c1a6103e1e1bcfa6ac2c0f7af0100bcdae3bed5e9fe4a1	3	3103	103	320	322	19	4	2023-09-27 12:44:18.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
324	\\xb79efc51322162d750468df4c375f2585611f2aa6712b1c5b9ebfb4fee35ab3b	3	3127	127	321	323	11	4	2023-09-27 12:44:23.4	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
325	\\x46db1f56a6d36bd7ad6a10743d51a3068d9107c7b1d61237a723cf08e44b955d	3	3133	133	322	324	11	4	2023-09-27 12:44:24.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
326	\\xae2cef7cd22f9613959d844dfb08f3a912ed0780e8a43a7f3316c1aa18190001	3	3153	153	323	325	9	4	2023-09-27 12:44:28.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
327	\\x253bce648b4cc20a67b19812bb8939bb9ee99e8500d7d54cf26704e3d7b18f19	3	3157	157	324	326	19	4	2023-09-27 12:44:29.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
328	\\xc7ce43a3d631ccd8b03be2d58bb22e10e11771cb6d2dc362b6219980c32aabab	3	3169	169	325	327	11	4	2023-09-27 12:44:31.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
329	\\xae74462a32196bbc43299f8e1b3ec2000e67c5cdfe7f3900ccc5c13cb25b5749	3	3171	171	326	328	3	4	2023-09-27 12:44:32.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
330	\\xaa297458ce9de902e2d18766efb754e2a9382f814909aa22ebb6391424f002b8	3	3198	198	327	329	5	4	2023-09-27 12:44:37.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
331	\\xce75c43158bafcefa7eaa3112d12f27f8938d7b38abf00134417657a44ff7657	3	3219	219	328	330	19	4	2023-09-27 12:44:41.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
332	\\xe2370a052fef00efad7a2f19d907c70f966a7d74b8106e44c663e4d31bb61a0f	3	3225	225	329	331	9	4	2023-09-27 12:44:43	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
333	\\x1606e38efc4c790ea7c087d9e6ae58bc519526d49bed1997c827aab3efd1ca6d	3	3226	226	330	332	9	4	2023-09-27 12:44:43.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
334	\\x4bd0a804b296646fdf9435cfb9fee9746d98bc4dc69802f3b84bded3c8403fe1	3	3232	232	331	333	3	4	2023-09-27 12:44:44.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
335	\\x23f244c6696fc5a83340c43b11cea1cb1888a5ecbbe6bb3fcd15ff8e0232ca97	3	3236	236	332	334	6	4	2023-09-27 12:44:45.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
336	\\x2c566e28067270dcb6e062b7d205c5908c1d4d47d2cbee786027fbea6929847f	3	3260	260	333	335	19	4	2023-09-27 12:44:50	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
337	\\x73d0f2f64200155956208684a9a7e4e81aa337d4ea12944d288fc2eb82cf5233	3	3284	284	334	336	6	4	2023-09-27 12:44:54.8	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
338	\\xfefce092b9c081d70c06da218089e029d5bbb61a8513af70f6e1649de9c84ec5	3	3287	287	335	337	3	4	2023-09-27 12:44:55.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
339	\\x19415b3b125412b95b6114b3465fe44891235267383fef47f1fa3d1e858aa563	3	3291	291	336	338	19	4	2023-09-27 12:44:56.2	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
340	\\x5339211faed1d6ee2b1ac71e908aabe5affe71b3aee9f3b016a56051bdc21c5f	3	3293	293	337	339	11	4	2023-09-27 12:44:56.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
341	\\x1140dca58a66bb5ce634ee9dae560a89c1465aba6b1c227e006f5d08324aaa69	3	3304	304	338	340	19	4	2023-09-27 12:44:58.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
342	\\x9a6688a5f6603842fff2093cbd0dcc55b2e0052e53b863483cfdf3b74f0fe19a	3	3306	306	339	341	11	4	2023-09-27 12:44:59.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
343	\\x857b9d7b359de2171502a99f57434f306280b7bee76b979045545124356628ae	3	3307	307	340	342	3	4	2023-09-27 12:44:59.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
344	\\xaa27315a58ba29cea850de4afe9231bbf8de05164b11490fea9ea431dbfa4454	3	3323	323	341	343	5	4	2023-09-27 12:45:02.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
345	\\x7153e3339266cd5bae646c359ac73ee3597ed2a77587530c12b4e7bf1c015877	3	3327	327	342	344	12	4	2023-09-27 12:45:03.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
346	\\x4159f880739cc8523a4ab66c7a60bb97381eefaf06865d5fc8584b61ad9ab41c	3	3330	330	343	345	7	4	2023-09-27 12:45:04	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
347	\\x0a37f853537634111d96eddc71369a580c0a1e55bd9e0f4ce82506ce34674553	3	3355	355	344	346	3	4	2023-09-27 12:45:09	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
348	\\xf71081b34f4e2b492619b27d03dd77fc74cfdf9fed9946891fe07910af74b24a	3	3362	362	345	347	4	4	2023-09-27 12:45:10.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
349	\\xfba3235d51eb43131c170a8715e2263521bf6640ca1e2b0c1b43afdef8c59959	3	3379	379	346	348	8	4	2023-09-27 12:45:13.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
350	\\x31983547d28e3238ab54f30bc3ebc06ffc9475e90d57ba8a72f2dce368b79c84	3	3398	398	347	349	9	4	2023-09-27 12:45:17.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
351	\\x4752633b6bf8902ae78ff4b247b4796c52c1a7a1856631c0501d43371514090c	3	3399	399	348	350	11	4	2023-09-27 12:45:17.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
352	\\x2245eae33f14830fbfdf40bd71ad77ea047621f175526312891bff17d6f27e75	3	3408	408	349	351	11	4	2023-09-27 12:45:19.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
353	\\x1935b5f4fec0025953a56cdd7b9e11c636b77eccc25d11d53ac48bdf3ea1c05c	3	3409	409	350	352	8	4	2023-09-27 12:45:19.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
354	\\xf7b90ab054a668e8e72d50b4bd4f2f80e310c222209bbb70513c410501a1a315	3	3418	418	351	353	19	4	2023-09-27 12:45:21.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
355	\\xa7fc7b69922504383d9ddf8aaa1fced924ff122e0796641159df3c9275819ed3	3	3421	421	352	354	8	4	2023-09-27 12:45:22.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
356	\\xf943ac1450caa4e9901c5228ccd4243ada098fb4e936db2aaf5eed01cf88ae18	3	3426	426	353	355	6	4	2023-09-27 12:45:23.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
357	\\x34167549511ea31a1cf130d6ae058d7015c63a46683d77487e30a1f9398ed694	3	3430	430	354	356	4	4	2023-09-27 12:45:24	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
358	\\x701d0d0fd9eb03f6b2179f8559ab527377ace2c896d70ed6344c2366b9302a7f	3	3433	433	355	357	9	4	2023-09-27 12:45:24.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
359	\\xcdf6b9ac771092bc17454c1f8de2bc3b297c574029694e810f72fc88f7e30094	3	3434	434	356	358	27	4	2023-09-27 12:45:24.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
360	\\xe5cbb249b19edfad7ae09e81eac3cc42d65edaa0b854617218ca8828bc2d5a1d	3	3447	447	357	359	4	4	2023-09-27 12:45:27.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
361	\\x4fff8ed2bd4cc99fb448559393333ca2adb6eae182b90e28048a58370625f355	3	3473	473	358	360	27	4	2023-09-27 12:45:32.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
362	\\x5d4efe61d1eb8f353776089d48aadfbf3679b9768d3890f4544b15d5d7707ad7	3	3477	477	359	361	6	4	2023-09-27 12:45:33.4	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
363	\\x0e87880012a6deff9fa6b2e2631b6b72d5dffab32e71863514b1e5e9a1d835d9	3	3516	516	360	362	3	4	2023-09-27 12:45:41.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
364	\\xfe706bd198bb393b1f49c152068a45e66fa305fce42baf02dc32279120fbf1ef	3	3527	527	361	363	3	4	2023-09-27 12:45:43.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
365	\\x4fe95766f8cb3b78368140162668dc680f4637968be770ff292e640df280298a	3	3534	534	362	364	8	4	2023-09-27 12:45:44.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
366	\\xf90919f75427c610b33cf9b29179bb1619d07943ba25e2ae4497ab4d47263b29	3	3543	543	363	365	3	4	2023-09-27 12:45:46.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
367	\\x7c40abff086fada635fc355daf1fa1dc90d811516c40fa70a3c1bf93d9909d77	3	3545	545	364	366	12	4	2023-09-27 12:45:47	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
368	\\x5b8511372b92529798dc10df2ebffebfdd656d28a3d9d920408bd89d61657502	3	3552	552	365	367	6	4	2023-09-27 12:45:48.4	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
369	\\x4c4c6f2be47f94a51f66f5ad2e7db8025e2b89d8e38f1bf9502689f9bc9ef920	3	3554	554	366	368	27	4	2023-09-27 12:45:48.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
370	\\x93ac09726e74f58c203466ca2817e4ebb86aa66f28320cd526593e06cb13a656	3	3570	570	367	369	4	4	2023-09-27 12:45:52	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
371	\\xa683c7740cc99658c0eb4804177187042e057296784869df08a6e581121ac392	3	3571	571	368	370	12	4	2023-09-27 12:45:52.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
372	\\xc8f51139436d2f20f446af727846fae4a3f6df9b43c66a0b4cb7ad697cd0f8a2	3	3585	585	369	371	3	4	2023-09-27 12:45:55	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
373	\\x4c3cfd93030ed48290fbbbe61f40aba4a512bf753213de34700532e4ccb6eb31	3	3588	588	370	372	7	4	2023-09-27 12:45:55.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
374	\\x51f38bea5c4f23c53266efb28403add71453f63069313713f95e2890300e9c20	3	3594	594	371	373	5	4	2023-09-27 12:45:56.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
375	\\xb7c07bd6485380b611a2e2ef3668eb25408471e133f3ad045d1c44384928b21b	3	3612	612	372	374	12	4	2023-09-27 12:46:00.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
376	\\x93056dd89887c68bb2cb1e05f21a5cde3140fa53f445c768c1cfb108a45ca52f	3	3613	613	373	375	9	4	2023-09-27 12:46:00.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
377	\\x023c2db01255d340f6b9ec52498e4aaafdf960b9872d3fe3597a490d7c304e66	3	3620	620	374	376	8	4	2023-09-27 12:46:02	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
378	\\x1048018999f5493314a2f9bea4f192b5034fb84d5d8ef500ef7e29fcafa4dda2	3	3626	626	375	377	3	4	2023-09-27 12:46:03.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
379	\\xa55640a26ca2f1826ad940b2c00cabab7d81422a63bdb5e736c446f6a4f32386	3	3629	629	376	378	4	4	2023-09-27 12:46:03.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
380	\\x2c8b43abfef9205fd349c50240d351bd53e604b2e52f720d359e445d2949e310	3	3653	653	377	379	7	4	2023-09-27 12:46:08.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
381	\\xa845db1cc3072704705cdfd0f3e2231b6a51ff3f94488aeca890ba9524ab2771	3	3654	654	378	380	4	4	2023-09-27 12:46:08.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
382	\\x8f518ce4f6b8babdf1412ece8d71efc0f95ccd3cb91e1f0bb7109e94b28a7460	3	3658	658	379	381	12	4	2023-09-27 12:46:09.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
383	\\x64129524d0a401a5d350d80765dc7615ef749d17025237186193b0235f2d61bb	3	3697	697	380	382	8	4	2023-09-27 12:46:17.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
384	\\x8d35eac242becb4e482fcb96cbacbb436eefb850b8ba43e99837bbc9872db9ab	3	3698	698	381	383	19	4	2023-09-27 12:46:17.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
385	\\x403e5ce3786544d292406ac70913324f18663926186dc9776fd5d6efde74cb0b	3	3707	707	382	384	7	4	2023-09-27 12:46:19.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
386	\\x7e49b2298c5e76440053b91aacab19db86f5df5f3c8c5a3b76129a85c6c9547c	3	3713	713	383	385	6	4	2023-09-27 12:46:20.6	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
387	\\x2c4e685058eb0bd76a571a3fea41043a8c7657d6fd238cabdf71ed9282762e51	3	3715	715	384	386	12	4	2023-09-27 12:46:21	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
388	\\x9cef8cc5160d76135aba759b2c8a43d6d8ab3de0c690fdc74597d1f9de171fab	3	3717	717	385	387	27	4	2023-09-27 12:46:21.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
389	\\x0f6e00a4a41770e4c6a36fec2b70b8bdea12d8a4bb108e5ac3ff5392e7fd1bca	3	3734	734	386	388	4	4	2023-09-27 12:46:24.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
390	\\xeabef9e21f3cf1f466859adcf295339c3c343037b76c1c504b1496be4d857638	3	3739	739	387	389	11	4	2023-09-27 12:46:25.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
391	\\xa596756b1f2205d7bd24d5683e096f2a11a0b80499dbf7cdead582d91513ef20	3	3742	742	388	390	19	4	2023-09-27 12:46:26.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
392	\\x7f6bf530084dfc26a285d1199eaea29fd3a86c2476461e94c98bf1494065615a	3	3745	745	389	391	8	4	2023-09-27 12:46:27	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
393	\\x090ff742bf8e41ee1f953d582fd6efe4ea1768f5996b45ec3013e7130fe8b887	3	3754	754	390	392	19	4	2023-09-27 12:46:28.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
394	\\x94886648fe343a8cef7c268ce6358d37a90aaa92bdf21d70aac4458c111848fa	3	3758	758	391	393	9	4	2023-09-27 12:46:29.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
395	\\xe76d10c40b891bc1fec5efac0e16004434fbfc9a55080d76b3195af2db9ebe65	3	3759	759	392	394	9	4	2023-09-27 12:46:29.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
396	\\xc841b714033b503bfb3e32f19e36b2799da527ce24fcebc040048cfe3b29fdfe	3	3760	760	393	395	27	4	2023-09-27 12:46:30	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
397	\\xb7c8864ef0126bdea26cc27b305991162c014ba9568304d29526f665bb698b4c	3	3769	769	394	396	11	4	2023-09-27 12:46:31.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
398	\\x1ae3a1c1445a036ca362b66494d5ab27ef777dc538001b535a996642b400937d	3	3772	772	395	397	7	4	2023-09-27 12:46:32.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
399	\\xc9119228c7de49fcffc61bb461d229eea9d993661ce3fd9c7b4f2dd4c7eee8c4	3	3776	776	396	398	9	4	2023-09-27 12:46:33.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
400	\\xdcd62496b5d7f0490692d6ede129e5d971da4a32fb2d66a58e35229f8d9128cd	3	3777	777	397	399	11	4	2023-09-27 12:46:33.4	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
401	\\x7044904f2550cfe69e3e86024f384c6f1fc336fe96bc86dd3b10a412a12effc5	3	3786	786	398	400	3	4	2023-09-27 12:46:35.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
402	\\x7e99aaaa2be50cd55f1407955d238fdeb32c72d59bcdaa42700708cfee4e6e61	3	3793	793	399	401	3	4	2023-09-27 12:46:36.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
403	\\x82ea6e0a6735259cd513c9b5a344db8a98cb07226244eb60c57c14b4bae188da	3	3796	796	400	402	9	4	2023-09-27 12:46:37.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
404	\\xb394272108f963f22f2c0dee048722dc9724b76eed238dc07add697c73dc5885	3	3803	803	401	403	5	4	2023-09-27 12:46:38.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
405	\\x8c46900b6b64f8d6a46c4a7d1a274fed016dc0e1cbfb4c3a2f46999031841cda	3	3812	812	402	404	12	4	2023-09-27 12:46:40.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
406	\\x0d250dd9ee867084eb4caf24a79bf9077cd64929716349f3d281dd26e6ef47cb	3	3840	840	403	405	8	4	2023-09-27 12:46:46	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
407	\\xc5da5500b98ce6274216fd557c410b3403dc1c45b101317395f5427d8a446f87	3	3841	841	404	406	8	4	2023-09-27 12:46:46.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
408	\\x1d18cb57df9f1b1c5819713aadf6608ea0ca63b5961cb79aa717d0d8e18f0978	3	3859	859	405	407	5	4	2023-09-27 12:46:49.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
409	\\xef559c3ecff2794150e5a79315521cd947ebe9deea15a81a203b5144ff885451	3	3866	866	406	408	3	4	2023-09-27 12:46:51.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
410	\\x6689763d34ac77951087be94a42f81ae25150f8656b8f71811a95bfc7e0a3560	3	3869	869	407	409	7	4	2023-09-27 12:46:51.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
411	\\x35c52f15c0acd7f187b1c16ba282bd99c0fd324ad9a626aed57c3fb49e7dd5a4	3	3892	892	408	410	8	4	2023-09-27 12:46:56.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
412	\\x71bd99e66af877406a53ab2b476628ff25fafd9654a52e3fdc8ac01eb0e4ee1b	3	3897	897	409	411	5	4	2023-09-27 12:46:57.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
413	\\xc8f041c83e5c92bef1cbc9a91e5e79646fbd259bbae1d641619361cd846c13e8	3	3901	901	410	412	19	4	2023-09-27 12:46:58.2	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
414	\\x430d093ab36ea1ada3522445ac94ca098c39733e24e4aa8043b7469f966a9c33	3	3904	904	411	413	3	4	2023-09-27 12:46:58.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
415	\\x4f2bcbeea39e950cf2dad5869eacdd50bc8a783e0939d61bb7506ef40c4f18ab	3	3906	906	412	414	4	4	2023-09-27 12:46:59.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
416	\\xc1a6a8d7f09179ffaccb4250bae387b575e08ee75f2e01bc5d32094a23edd9e9	3	3916	916	413	415	5	4	2023-09-27 12:47:01.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
417	\\xe423120a100a48671584487bad6c694ae45a50881040d4728f3bbef6f46eb7a9	3	3921	921	414	416	4	4	2023-09-27 12:47:02.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
418	\\x99b6c953b897334d176c46a5bbb61364b42b10d96403b737fee5dc61af474f25	3	3928	928	415	417	5	4	2023-09-27 12:47:03.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
419	\\x0952daff881e88352604de5eacbe55d06af0117a107f291f07de1e7d3eb57dec	3	3940	940	416	418	19	4	2023-09-27 12:47:06	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
420	\\xad9caf734a1e471445757619ef754dacfe675565d155a068cd7d13bbcca8f785	3	3945	945	417	419	12	4	2023-09-27 12:47:07	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
421	\\x94b54e17029aa211e938fa1a0e5459407e4c47bfc1cbe28623b7221fd87db7ad	3	3948	948	418	420	7	4	2023-09-27 12:47:07.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
422	\\xc2213547d86eb22ea1dbf535f6fd4feda4a211bdd647b64bc151bd1688739659	3	3966	966	419	421	11	4	2023-09-27 12:47:11.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
423	\\x8bb230a8bdc6b1e867d12b239ff5a0e26e9ed4cd68557f587e253c02b697d75e	3	3979	979	420	422	11	4	2023-09-27 12:47:13.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
424	\\xd092709b05ee0aca1c14f849f7a784424da29355f45c36e8cdda6f95e483272c	4	4003	3	421	423	6	4	2023-09-27 12:47:18.6	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
425	\\xf7665445012e6be9d686ff96155aa83572e868e1d19bd52e632bb94e87267685	4	4007	7	422	424	4	4	2023-09-27 12:47:19.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
426	\\x593537ad86a3973eb0b56e405cc9e3a9aa6b8a8a5701e65adb1ed8edcc78bde9	4	4043	43	423	425	7	4	2023-09-27 12:47:26.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
427	\\x55e82f8a4bb893eb9423813a686e63f157a9fa5fcc9c59e3f433acbd3b7f0799	4	4053	53	424	426	3	4	2023-09-27 12:47:28.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
428	\\x1ea885e4f868faf56e946a0cfcafa6b2fe4599041e128cf7986791a4f3665b22	4	4062	62	425	427	9	4	2023-09-27 12:47:30.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
429	\\x3d2ccbffbb6a20c9865d990b0fd3b63265fa5c0c7d254963218212f2ff6a86b3	4	4076	76	426	428	7	4	2023-09-27 12:47:33.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
430	\\x49487424bd57acdb54e0af683b29c75fd8ba6b6103e4dcaeb72036c015f296b8	4	4078	78	427	429	12	4	2023-09-27 12:47:33.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
431	\\xb0803a8ce63329806fd99651ed0b3d03b651c61137cf2532eccbe545e424facc	4	4085	85	428	430	12	4	2023-09-27 12:47:35	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
432	\\x3ae942c71959b380bd35a3adab72d57b9477ae29772f3573f9224daf826a2f68	4	4089	89	429	431	11	4	2023-09-27 12:47:35.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
433	\\x56de1203dad6358eaa189d083753f12548d50f0fe1753c68774278e137a79f5c	4	4115	115	430	432	4	1704	2023-09-27 12:47:41	1	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
434	\\x81ebe5017bfc9a281743ed05db86d121f16fac5f36e5f949da5660149f4c17be	4	4124	124	431	433	9	4	2023-09-27 12:47:42.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
435	\\x8340c81e665e97d1b92d918bed70da1c13923760367ad0575e7043a26c873263	4	4128	128	432	434	19	4	2023-09-27 12:47:43.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
436	\\x46df48159b7c0083c0dd22d9afd34d6c23095259c22aaad47128a7817c4f3499	4	4155	155	433	435	9	4	2023-09-27 12:47:49	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
437	\\xdaf46bc572ab808241d3cd532187487eb027d29e3cb3466e936a3bfc7cf4e350	4	4159	159	434	436	8	430	2023-09-27 12:47:49.8	1	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
438	\\x07c12846c8bb1ece1fab964f22e1facd2eaf0848ce8dced65ecaa25646461383	4	4173	173	435	437	4	4	2023-09-27 12:47:52.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
439	\\x67f6682b61a1813fb587bc5663f784a64efcfc2c31f9cb06639060e6c1009d15	4	4178	178	436	438	6	4	2023-09-27 12:47:53.6	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
440	\\xde5aa897749344de81b0d854d22272524b2681e673fa0db54c7383124d6c9b66	4	4188	188	437	439	19	4	2023-09-27 12:47:55.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
441	\\x770a2f700a38e779d88761426c9abb7cc47def1d31dee4651dfc9738eabe107b	4	4215	215	438	440	27	352	2023-09-27 12:48:01	1	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
442	\\x05dc76b1da74ecb509860e6e332967e81a3bf5e93a09a0dc4914062b86a7f1f4	4	4241	241	439	441	12	4	2023-09-27 12:48:06.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
443	\\xf3cc9450c99023cb2301003c2470ea2b7991af2a3960996a8d9a027b4350beef	4	4245	245	440	442	9	4	2023-09-27 12:48:07	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
444	\\xd80ce12cce34630d52ad718159efa9f369ba0cfba394f4009e8479de6aef9253	4	4248	248	441	443	3	4	2023-09-27 12:48:07.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
445	\\xb7942946a799d8140035e75b1bf451cffdee33426ed763192052084611248e4d	4	4262	262	442	444	4	321	2023-09-27 12:48:10.4	1	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
446	\\x86461028908b7fb0bee685d5b644a8282004112860407f50839ead79d0445e6e	4	4267	267	443	445	5	4	2023-09-27 12:48:11.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
447	\\x906138456db116f5b68c5fe93e7a1dbb461ef7d093b65c6dcd76404395b56d20	4	4279	279	444	446	19	4	2023-09-27 12:48:13.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
448	\\x46807ef401c3049a092a08ca4a218c9ea0e057a3dd49086100f34b9613abb6b5	4	4286	286	445	447	3	4	2023-09-27 12:48:15.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
449	\\x9b76f3efb52c6cbcca2a391581a81753ec113f4aec70ffd0733a0c806c6ade25	4	4298	298	446	448	3	401	2023-09-27 12:48:17.6	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
450	\\x730c1ce230ad45e610cb3faecb733e5a87be1786d3289f0936d3ec0c5a948db9	4	4303	303	447	449	11	4	2023-09-27 12:48:18.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
451	\\x3d7b32388ccca08d6585f3975bbd5b4609764ab7c13f8ae5dd802cfb29f39979	4	4305	305	448	450	27	4	2023-09-27 12:48:19	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
452	\\xf7f8dca3882a222751371b188555b1d9bb8ec010380f3583eb6ce4952de72d0e	4	4314	314	449	451	5	4	2023-09-27 12:48:20.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
453	\\x834054119857917443170b0fb8e9b3203c5c3e8c3871b6fe3105437ed54e3d57	4	4316	316	450	452	11	749	2023-09-27 12:48:21.2	1	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
454	\\x4fef34ff291bad7f77f559de843ef3dccbe5762ae5bcbf62a583dc5b3cf7df80	4	4322	322	451	453	6	4	2023-09-27 12:48:22.4	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
455	\\x963e6fb85ff7398c76992ca891441866489e368ff522518364a20838aaadead9	4	4325	325	452	454	11	4	2023-09-27 12:48:23	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
456	\\xcc1390a5bae99ee37781682fb9bb62b18529cff7082db12e615e49d3254fa5e3	4	4326	326	453	455	3	4	2023-09-27 12:48:23.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
457	\\xcaaf3d3cbab2000aade9716c0b0a0d3dc8c718ba20f0f6dde4f80751aedd11e5	4	4327	327	454	456	19	749	2023-09-27 12:48:23.4	1	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
458	\\x5e04ab0bb562897ea6970b254a8d39413bc875ed67e3c34f8413ba7ce6ea7125	4	4334	334	455	457	19	4	2023-09-27 12:48:24.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
459	\\x370d151ad354f65c106e361fe4683f9b820e41367e1151ddc750aed5dcc16a6f	4	4335	335	456	458	12	4	2023-09-27 12:48:25	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
460	\\x53b9aa69d20621fb313070019f5a0830f0c765184a7b98d6e44ce5a5169578be	4	4345	345	457	459	6	4	2023-09-27 12:48:27	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
461	\\x1f8d2668d9e04f314dcd23d355607cfc84ffd54ebf59bfa1d833781ba3f18ae7	4	4364	364	458	460	27	336	2023-09-27 12:48:30.8	1	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
462	\\x61570ecad1a91b7d1780068691519043acc8517612e15e460d08d6f1e3e2bf35	4	4372	372	459	461	19	4	2023-09-27 12:48:32.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
463	\\xd563d557af506754617ff441b4bf556bd4d53b73f08d9a4ad192d8724ff293b7	4	4381	381	460	462	9	4	2023-09-27 12:48:34.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
464	\\xc952d20b23002ee18d7402a0ace4379454aab671ac6abdb5eb417de1bd246b34	4	4388	388	461	463	12	4	2023-09-27 12:48:35.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
465	\\x71087168c6e7f85351b0b483bcf91ef3178448f5d8464d027460c9dbc580b44d	4	4396	396	462	464	9	749	2023-09-27 12:48:37.2	1	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
466	\\xca998e51c43c67c693090c422f961e7aad08526f443524901cdec7395a40e19e	4	4410	410	463	465	12	4	2023-09-27 12:48:40	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
467	\\xfebc55ff175629ba1802f2c88e78512653d8da407f71941fd49da95d13681f6f	4	4427	427	464	466	9	4	2023-09-27 12:48:43.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
468	\\xcd7f09e514f25343fabd45110f29b1f737b5850716a0fe21bfd7774a1630e559	4	4428	428	465	467	3	4	2023-09-27 12:48:43.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
469	\\x4b4f5591a06765439c1c55459316ced594bed76c83bc3c843fc4d7abfd46a63e	4	4431	431	466	468	11	300	2023-09-27 12:48:44.2	1	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
470	\\xb17e2bab766cc6944282cae58b26b087acb7c2952ad681eed20f297a2037a3c5	4	4437	437	467	469	12	4	2023-09-27 12:48:45.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
471	\\xe74e12649371ed6e28ade19a1d554a97a65d0109a4bef152b2435e1399ce9945	4	4438	438	468	470	19	4	2023-09-27 12:48:45.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
472	\\xab245e8e7696a916e82a7635e6c70b3ddf2f79669568e28a666fe321e0964098	4	4445	445	469	471	7	4	2023-09-27 12:48:47	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
473	\\x03058cc4d3fe80794334c61597199ccfb041d4626aaaeef4ae8d889432d5cb1f	4	4450	450	470	472	8	745	2023-09-27 12:48:48	1	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
474	\\xae57c481f0dd1a93e5c18fd0b4a1e2c2c259ca188ca78f5035e7f3551326b39e	4	4456	456	471	473	12	4	2023-09-27 12:48:49.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
475	\\xbcae8fc388890950d2c95b3485e1b1d1d5e78e3808cb976300e4c35f8322e122	4	4457	457	472	474	5	4	2023-09-27 12:48:49.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
476	\\x141b4911d226ae3f292b3c50734d7428936ff0b0ac2fd82fe86b62bdbfed2e6a	4	4480	480	473	475	9	4	2023-09-27 12:48:54	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
477	\\x7d24390eb2bf9779b715c86b309ac66bebd07ce398697fa986ba65a7142d3270	4	4489	489	474	476	8	342	2023-09-27 12:48:55.8	1	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
478	\\xf13d8cf16cb241535680f44b242b9822138162d45d76579dda93a29e198a2f17	4	4491	491	475	477	7	4	2023-09-27 12:48:56.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
479	\\xe46f42406e1c26b20ba55d38991ad33743cc4872c22437a13f9027362253ce83	4	4515	515	476	478	19	4	2023-09-27 12:49:01	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
480	\\xc81245c9fdca48dec52ec0be0e5a592665e3347a06ff8f179c60c19582e3c12e	4	4518	518	477	479	12	4	2023-09-27 12:49:01.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
481	\\x161f1ae36bf88de0d752f5b6167a0f62c1bbc4de7f7b387628a70998872eaead	4	4526	526	478	480	5	300	2023-09-27 12:49:03.2	1	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
482	\\x0a8ff11f2034d88f0d5cbd8b51db326f9f581e66f0f915982964967481225829	4	4554	554	479	481	27	4	2023-09-27 12:49:08.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
483	\\xc49838383e696b5bd8c5bc62e8c1b0fba947a1691fbef4ff8577c85aa5c0b2c7	4	4581	581	480	482	6	4	2023-09-27 12:49:14.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
484	\\x16610af4b6b8b0bbe38f386fa5c8215fac8501f8f915472d6c01485eb2e3e9dc	4	4582	582	481	483	11	4	2023-09-27 12:49:14.4	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
485	\\xb9d89a1d1be31ec103617b6fa2706a7d25e1febb25ff219d1b414a4672238b14	4	4586	586	482	484	12	4	2023-09-27 12:49:15.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
486	\\xbc5ec157c0ae36ddb0e8b2f19a21a4399177bd53d5625c21a6f49feb9ead940f	4	4594	594	483	485	12	1136	2023-09-27 12:49:16.8	1	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
487	\\x0f2f9bfc3b7a82643aa56989a6a8d386a413639bddf1c61864d9173da8423dec	4	4596	596	484	486	7	4	2023-09-27 12:49:17.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
488	\\x4fa8416c9cc92f8bc977074b7d41df5f98cf1928d3ee3018a0a0a992dab41791	4	4616	616	485	487	6	4	2023-09-27 12:49:21.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
489	\\x6c3e69bcd44dcf59cb435f69e810e63c651722e0c635f7315f9fb0e7f8c080b9	4	4617	617	486	488	7	4	2023-09-27 12:49:21.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
490	\\x760611e1e39dd3ea461042b382ce3fe07cd4f589f2fb53524b9b6f423ff953b6	4	4629	629	487	489	19	558	2023-09-27 12:49:23.8	1	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
491	\\x0cf46e86bb301da361fc03650f06006dd52de97fbaf7adde13bf5b18f5e7d6ed	4	4630	630	488	490	19	4	2023-09-27 12:49:24	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
492	\\xfdc6743f8d2f7f403cd3c3678c3b2da324894144ad576fbb234cc18722e6ca03	4	4631	631	489	491	4	4	2023-09-27 12:49:24.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
493	\\x3fc3da597f05d8c1247b2a74d268f5f5f108ef541ccbef6f7a568eedad4e433d	4	4663	663	490	492	4	4	2023-09-27 12:49:30.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
495	\\x0231f03322c5368e19f739f01966ac14df05232c66147343a13957ed8fc21e3a	4	4669	669	491	493	19	722	2023-09-27 12:49:31.8	1	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
496	\\xc68538eb6d468013dbfc0ede014d29d6b9c45abf7d911c96e504832d7af4d571	4	4707	707	492	495	11	4	2023-09-27 12:49:39.4	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
497	\\x776b27def7b075e8d9a32d200300919b577b96a9f8a6e3032051d1d95458e6f7	4	4728	728	493	496	8	4	2023-09-27 12:49:43.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
498	\\x919cecb1a1256c8103876adf2945304074e494d11aa72391ade3f98d281f0eb2	4	4745	745	494	497	7	4	2023-09-27 12:49:47	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
499	\\xcfe44313cb63024e09ba573997ba5a6faadcba15c4e67334c77561f896f60257	4	4748	748	495	498	11	710	2023-09-27 12:49:47.6	1	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
500	\\xbe9332431c5d026753782f1820e4dbf0fbed803571b920cbe57c0b5bf237dd67	4	4754	754	496	499	5	4	2023-09-27 12:49:48.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
501	\\x220b40126c22be2abdbcd40d80049e1313e117e06fcff54a5ad28a5450128040	4	4777	777	497	500	12	4	2023-09-27 12:49:53.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
502	\\x7e87adfc7a9bb978c1cc7604038514005b841204aa290084b3ceef4fa2cfdfb8	4	4788	788	498	501	5	4	2023-09-27 12:49:55.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
503	\\x5acc0c6d668d8d5339bfd5b76e0d832fc8b6afd11cddd41b55eed827e69c08e6	4	4798	798	499	502	12	745	2023-09-27 12:49:57.6	1	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
504	\\x85dfdb98dbf77f0875f48094b3e13a52d87d9128ba7fdee317586ef7288fd9a8	4	4815	815	500	503	19	4	2023-09-27 12:50:01	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
505	\\x37b4b16ab4eb0573ad1f9dad7c8fd703156447bf9b6bbcde694aeb97e652e65d	4	4819	819	501	504	9	4	2023-09-27 12:50:01.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
506	\\x1904be5e6b7b7a541768976c462bae96d3eca57aa78b404345ef0b131245cb9a	4	4827	827	502	505	6	4	2023-09-27 12:50:03.4	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
507	\\x5916f1abaccad73a424841c7f2ab8b49349cc1053668936ae6ae9d5746d81ede	4	4833	833	503	506	12	571	2023-09-27 12:50:04.6	1	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
508	\\xccd635c5eff23198f10e66dd703a60de5c133a4f7c5c84f15c319f60263501f5	4	4836	836	504	507	12	4	2023-09-27 12:50:05.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
509	\\x36dc412a805f30af9c4d4386c2a4e670adf744d0509ea69469e6478892058cf4	4	4844	844	505	508	11	4	2023-09-27 12:50:06.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
510	\\xe43549594ee088f769ccfda1c604d3b11de4131e1b0d68cc8863a3caccc7f793	4	4859	859	506	509	8	4	2023-09-27 12:50:09.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
511	\\x882d622536c04deedc7c2fe4e32c60f487ce0170fc4015e62b6027a0164c0336	4	4870	870	507	510	4	329	2023-09-27 12:50:12	1	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
512	\\x98f896c81531b1aacf7952597f428c9549d1a417e8c12e956634d5eaa46f3456	4	4901	901	508	511	6	4	2023-09-27 12:50:18.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
513	\\xea4121269b50f59bb48dec30883d9ca62c0fb82db487afb0cb12c69bc65635e6	4	4902	902	509	512	7	4	2023-09-27 12:50:18.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
514	\\x1bf4319e638013982b33c5eeec60cfe65ac439328d4698fc831ee32fdc99787e	4	4924	924	510	513	12	4	2023-09-27 12:50:22.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
515	\\x7ec70aecda7d1733bdb876f7addcd68d74d5ae5afdb7c9750b9dae8d2ca7f3ad	4	4934	934	511	514	11	3850	2023-09-27 12:50:24.8	1	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
516	\\x61e3b20296f73564b0857db360c762218e35ca7e05e4fdf3ed1f0b74d9714c43	4	4954	954	512	515	27	4	2023-09-27 12:50:28.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
517	\\xf2681b1c28540d998740be1850b6a425fa5d6700b9bb4d01f99297c76d9ed950	4	4972	972	513	516	5	4	2023-09-27 12:50:32.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
518	\\xb77ff63d5373e5eca82d038d4dd908d185c06e12aa9dfa3841ba0b763dcbbee5	4	4974	974	514	517	27	4	2023-09-27 12:50:32.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
519	\\xf0ebbe49c4c0ffb82d954aa0dbd36749439a6b1ee106c2d3527317594cc3e6a2	4	4975	975	515	518	19	2398	2023-09-27 12:50:33	1	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
520	\\xc74576dd7f3393a3762135211bbbae061f68a794547113bdd94db402a48be51b	4	4980	980	516	519	6	4	2023-09-27 12:50:34	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
521	\\xf7cd2134554197273afc650ff818777d1775ee00962b5b3ed4de9b40d8349ce4	4	4989	989	517	520	7	4	2023-09-27 12:50:35.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
522	\\xcf49ded5ecbdde657ecabc100db2a7aae1ab98d5e8c3d3f59ca8b1ebaba8ad23	5	5000	0	518	521	7	4	2023-09-27 12:50:38	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
523	\\x1577c3035ffe66a3bc1e2e140f567dea75fbb4d23321ccdee05eec66967500ba	5	5006	6	519	522	3	1051	2023-09-27 12:50:39.2	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
524	\\xdd1737eb6ebf2ece285bbda7b531e75e9db0c41aed03d8b58fd2b30eb4603b82	5	5019	19	520	523	12	4	2023-09-27 12:50:41.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
525	\\x3ba521c7768c918119457ea9eda479f3ea9b2e4c9e03904fec533eff764c1fd0	5	5025	25	521	524	7	4	2023-09-27 12:50:43	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
526	\\x79f6f03637456b1e77c2769972f8145da1f95f02d4de9432c5425e30e73e0788	5	5026	26	522	525	9	4	2023-09-27 12:50:43.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
527	\\xf3d8ff2a8f545d03770876b70a00df6c0d18a1d4bab73d6516bf10cd2046066c	5	5029	29	523	526	4	4	2023-09-27 12:50:43.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
528	\\xd1a6aec8f3c00e279fccc49add5a4d2d858fb66dda2ef0de1e217573c1afe574	5	5041	41	524	527	11	640	2023-09-27 12:50:46.2	1	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
529	\\x99794c94b9457d9d6e9b1ea75b1b8e310e4df0ed7c7915ce878743df0d7b47bc	5	5059	59	525	528	27	4	2023-09-27 12:50:49.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
530	\\xd065b0ab018df1ed4ec64d7faf9a1da1bd3617c8385ee6769aa4a9e91fcffe72	5	5077	77	526	529	8	4	2023-09-27 12:50:53.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
531	\\x41ac42b5cd99da892d9c82d3ea383a8ea78b17be1e09bbd8567307a4b4df9301	5	5108	108	527	530	8	4	2023-09-27 12:50:59.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
532	\\xfb5b834b3b84158f21ee3df239bd1f9fd78ea16dadf827fc86c5686a44d094a0	5	5130	130	528	531	11	535	2023-09-27 12:51:04	1	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
533	\\x2c5fcec5214f8432883c50b4131b5127488a59694dc95a7df782695fa15fe357	5	5134	134	529	532	6	4	2023-09-27 12:51:04.8	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
534	\\xa8c28b6221d05386399bc8f69897897d95201559e42a4fae17924db2119643c3	5	5136	136	530	533	7	4	2023-09-27 12:51:05.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
535	\\x2e852703654689e2f49222006f390c98e6ac2febecb52bbd6d033e63a2d292e0	5	5156	156	531	534	12	4	2023-09-27 12:51:09.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
536	\\xd54e10097c88544d8961ec4482ffa25db694120bd8294148e0bc29fade8212fb	5	5163	163	532	535	4	4	2023-09-27 12:51:10.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
537	\\x66821e7e3fdd56dea3f7dfbc270e682076acd0a9ed5ec5e2051a9bcf4f919b99	5	5171	171	533	536	19	497	2023-09-27 12:51:12.2	1	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
538	\\x5d146d411a5d873a294754761370701c88131c07232619a01bb83ebc7f32d8d4	5	5178	178	534	537	11	4	2023-09-27 12:51:13.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
539	\\x9c955277798b663497c2ccfd9f502a72835e016bbf60b8ef951c4b0d095cb4e2	5	5179	179	535	538	27	4	2023-09-27 12:51:13.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
540	\\xf7fbf83046e1d1d938d2adec1ee48462553e6341661c5b67010fbdba934f4806	5	5199	199	536	539	5	4	2023-09-27 12:51:17.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
542	\\x12a435131d8e1ea7538a093aee140da85dddeaf77534a2b620b170cf4907e744	5	5203	203	537	540	8	397	2023-09-27 12:51:18.6	1	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
543	\\xfe809a049995c70386713ce0d16d9732bd9df905b7ddc0d34dfa0bc9e0200790	5	5205	205	538	542	5	4	2023-09-27 12:51:19	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
544	\\x91e216a8179ffee79daf07f374f046b596b15401c9f9108bfb5e6580f679cb49	5	5207	207	539	543	3	4	2023-09-27 12:51:19.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
545	\\x4ca9fd6af296a0390f1335e6de77b8e3d13ac26368173064988dd2d6fd8121ec	5	5217	217	540	544	6	4	2023-09-27 12:51:21.4	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
546	\\x8a13b4abe8e6dbe62298cae5f3198a706e3543499fec55cd86a80d694fe3773b	5	5223	223	541	545	7	734	2023-09-27 12:51:22.6	2	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
547	\\xf3271ecffec74c7e6e51b1d702138e518159f75c35158e75969695a323e8918e	5	5231	231	542	546	12	4	2023-09-27 12:51:24.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
548	\\x4abc0dc7328f8bbb8f2b8ee02befdc388f0268081e084ffa9c238a58969c2207	5	5233	233	543	547	4	4	2023-09-27 12:51:24.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
549	\\x95343c8455d950eb0df7694873e6c860be0d1f532b3d758fd60f085fb0d06e52	5	5234	234	544	548	5	4	2023-09-27 12:51:24.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
550	\\x80ed0e74ad2c366648ed2ea6871e0ee8c531b2335e54793eca6c1d85cfe57688	5	5238	238	545	549	12	4	2023-09-27 12:51:25.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
551	\\xefb55a0c9b7dfc431bf5fe02db347fad690dc3e7b3ccbfdfd73fb39c2b5f2c55	5	5241	241	546	550	6	4	2023-09-27 12:51:26.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
552	\\x7b342ebbee569814e5934d9422f712f1d2c2339760cc9f442e47d4b9c9e264c1	5	5246	246	547	551	6	4	2023-09-27 12:51:27.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
553	\\xe71c481ca457964d2be8729a0e72f46552f7725dc2d2178a52ca321547cd0c09	5	5248	248	548	552	27	4	2023-09-27 12:51:27.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
554	\\x8d64a18777cda91d11ac71d78e1655b73e47b40aa38bcd30fd8258d71948096f	5	5253	253	549	553	6	4	2023-09-27 12:51:28.6	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
555	\\x62ed4d467791d2f1fa452b9d06ec12d673f3993d782f7039610f23d09e04f735	5	5270	270	550	554	11	293	2023-09-27 12:51:32	1	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
556	\\xc589bc11dc9c99d7e6701dbe218dc791f4115928ae174c322dc68d700b6895ff	5	5284	284	551	555	4	365	2023-09-27 12:51:34.8	1	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
557	\\x2987636171f98cfb5835db25d72922e82d541c0bb595d33227689ee8431f96f0	5	5289	289	552	556	19	4	2023-09-27 12:51:35.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
558	\\xf1c3b487ac8a90e1bea169e0dab38fc8306ea0c1f4a969dbe07cd1ad5042d09f	5	5291	291	553	557	5	329	2023-09-27 12:51:36.2	1	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
559	\\x6f43aa00f2de267662c4c0fc734d5d4dcef3c3350fd2986122137d9b70783a7c	5	5302	302	554	558	9	2367	2023-09-27 12:51:38.4	1	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
560	\\xbb06a7336f44d3fce1a1013123f41f9481ba425d3d02e894c950e7fbae8c57b9	5	5307	307	555	559	11	4	2023-09-27 12:51:39.4	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
561	\\x6cc9f986102af995362646a0abc7c65ccdecb7836a23ed15f451feb72df5fcb1	5	5310	310	556	560	12	612	2023-09-27 12:51:40	1	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
562	\\x875915203fcd1c34fb9df231fefb9741d71f532bbbc2e57f1ec7919f682bf5a8	5	5323	323	557	561	5	365	2023-09-27 12:51:42.6	1	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
563	\\xa9b396f5b18c312b2e942adabf0dddfd0f4af295018aeac4f5ca1fbf47206b78	5	5333	333	558	562	9	337	2023-09-27 12:51:44.6	1	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
564	\\xa2753a2fe299c6d14e52afb42f0cfe0ad1670440e63f179f2ec1f95f3ace10f6	5	5340	340	559	563	27	4	2023-09-27 12:51:46	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
565	\\x48cc0ea9c5b8272c9cf22a63e50319da0b238b192e585bd5db20e8a8d9e3c55c	5	5351	351	560	564	7	4	2023-09-27 12:51:48.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
566	\\x63dfcfec75f162f3cca49f92d47a287e8b5d736cedb7cbc4a37ae709aaa42b27	5	5353	353	561	565	8	4	2023-09-27 12:51:48.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
567	\\xc485b945b93cf350fdc22a18db6fe2c1294fe9f19e636e174c2a5e5c02a076b9	5	5364	364	562	566	19	329	2023-09-27 12:51:50.8	1	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
568	\\x4fd1b8e8cb9aad4a48d3e6a62a9ae16d12f87173aae77a21d947ee02aa28fa69	5	5368	368	563	567	5	4	2023-09-27 12:51:51.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
569	\\x742362363ea924528a561294b27680877dd3979e0c4d73c77f395c509c336c61	5	5379	379	564	568	4	8200	2023-09-27 12:51:53.8	1	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
570	\\x9f34f01417e0a88b0444171a1dc4cb9674c3e23cd9ecf5dac1f049ee2a2b497f	5	5380	380	565	569	4	4	2023-09-27 12:51:54	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
571	\\x2d3455e15b53b8ea6116ba32ca42219d3fe79e6c2115d809a162b494570e18ba	5	5384	384	566	570	8	4	2023-09-27 12:51:54.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
572	\\xc00fed57cbf4fa76a9b2b55a7815668d6b8a4a344e9eba9fee84bae0209e2485	5	5396	396	567	571	9	8410	2023-09-27 12:51:57.2	1	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
573	\\x66566da3328a12e2ac198601481b8b88a34210ad8ae55ffea75d6a144749b395	5	5414	414	568	572	6	285	2023-09-27 12:52:00.8	1	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
574	\\x23f00f69eba3c5df1046e677759ea775f14910825790c3199edfd248a4438e4c	5	5424	424	569	573	4	4	2023-09-27 12:52:02.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
575	\\xfe99a77dd83682f68fa3546d1176e547caec840d4dfc90f8ddf63acf05114da1	5	5450	450	570	574	19	4	2023-09-27 12:52:08	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
576	\\x68c9ab39ad566a974fefafa28c2498b1f7043c02230928375223d80ce9e1f478	5	5456	456	571	575	19	4	2023-09-27 12:52:09.2	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
577	\\xa39073ff0f00b749be9e2ee64a94fb0f9c9a2ca9e4d3f4d88a323fcf965e0c73	5	5457	457	572	576	5	4	2023-09-27 12:52:09.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
578	\\x11a4a82f2ad4b20723e9c1c8fd2740966662d3ebbb240f7c768430cbfb45765e	5	5458	458	573	577	27	4	2023-09-27 12:52:09.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
580	\\xa1f77c50cd3783a9df11ad43b45acea9c12615833835b80b2704709dd4c99e13	5	5481	481	574	578	11	563	2023-09-27 12:52:14.2	1	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
581	\\x0bf104f0cf539f85e33b6a19ac76e0a7b336aa79ae0270a9113df789abae02b7	5	5483	483	575	580	8	4	2023-09-27 12:52:14.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
582	\\x6f8fbc736767fa8e42e2d39e14b44a3ad9b8a637e7ae0344b3c72bb9a0802b4d	5	5490	490	576	581	11	4	2023-09-27 12:52:16	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
583	\\x8944e5d3662d573630236beea19f1686238b788fb166140929bb1d1dc17c935f	5	5504	504	577	582	11	4	2023-09-27 12:52:18.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
584	\\xc6b6dab5810e7c942e78493f661e410f693d3eae4bb4864eecbad2ca59440338	5	5515	515	578	583	7	4	2023-09-27 12:52:21	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
585	\\x9a311b60b5313d8b7ec3426529dd2d7b2a301f39995f267f1ba35546a2e7b322	5	5519	519	579	584	6	4	2023-09-27 12:52:21.8	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
586	\\x7be3f45b39412fd8207fcae23255b4a6c8d983723f5df7486620fe10ca835fa2	5	5524	524	580	585	5	4	2023-09-27 12:52:22.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
587	\\xa1e6a61a33db15a39ddf1e20c3a0c441cff59dd3c41315fcc79ce2ebc3715ada	5	5530	530	581	586	3	4	2023-09-27 12:52:24	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
588	\\xa22f9065bd56113ada1826eab38953bbba2bde4439844885a267249c0b275347	5	5537	537	582	587	19	4	2023-09-27 12:52:25.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
589	\\xf6aaa7a0ab619840d19414ea3acc00e9a5d53b62140389416f6c99dcef6c54a8	5	5549	549	583	588	5	4	2023-09-27 12:52:27.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
590	\\x58151144de658c20f2b492b7b879985c0c537c90b7c107694bc141b67cb1ff40	5	5550	550	584	589	27	4	2023-09-27 12:52:28	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
591	\\x3049e1209b7aa8335a230480045b512ff2ba2a3846b9e61b75fb4e7e0598cc4a	5	5554	554	585	590	27	4	2023-09-27 12:52:28.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
592	\\x26da507a1f5f0dadfe826e79745c3413faaf1a461f5268c4dcca337668c0836c	5	5564	564	586	591	5	4	2023-09-27 12:52:30.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
593	\\xe5221bc5189253fbb9f7752e0fb6cb3737f5edd255cdcc801cf1c4a21883f0fd	5	5576	576	587	592	9	4	2023-09-27 12:52:33.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
594	\\xc75c99b1349c42afcb6fef4d5f52fb18edd43f62b45bb29c3229781596a2efb1	5	5596	596	588	593	9	4	2023-09-27 12:52:37.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
595	\\xbb31f12812e24362dc3f385cc3c70bf5d79cb13e133ead333c4dbeaf13bb29ce	5	5601	601	589	594	12	4	2023-09-27 12:52:38.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
596	\\xabb46fb40d00fd5a1090db6ea2fd95325f73fab1ffc61f4949a047ebb0b53071	5	5608	608	590	595	6	4	2023-09-27 12:52:39.6	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
597	\\xec738e3b04235b36ed0730b044b0205690db0343a67eba1360123c86b3610fcf	5	5643	643	591	596	5	4	2023-09-27 12:52:46.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
598	\\x6ca2181934120d159387c7d76428f30c92c724bff333340e381fc8cf8d90ac43	5	5644	644	592	597	7	4	2023-09-27 12:52:46.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
599	\\x06f000ecb718a99240794ad229666b67280193fb334e385852ba7e402c126824	5	5646	646	593	598	8	4	2023-09-27 12:52:47.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
600	\\x81d15d8cb4e6e2b39ffd82faba8b61440edf521fa3d079e7d22e8b9be5116d62	5	5667	667	594	599	9	4	2023-09-27 12:52:51.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
601	\\xd2165927eda01fe4017fdfdbcaa9588371a54f9f8f515070e4e1048662e5bee5	5	5668	668	595	600	27	4	2023-09-27 12:52:51.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
602	\\x6607bdd9b914026febd84435ab2d28c365ff51534d5922abc888c6e1375fbe04	5	5691	691	596	601	7	4	2023-09-27 12:52:56.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
603	\\x049281b9b6eb0932383e3b53d4e699f7fff2f50772e1c2bcd3acdb7bfcae06ef	5	5706	706	597	602	7	4	2023-09-27 12:52:59.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
604	\\xfb7148de9d2c67aae8aadef5cb4abd4a3c8c23452ae93b5f19b708b27c38e1e8	5	5707	707	598	603	27	4	2023-09-27 12:52:59.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
605	\\x86a3a3f1f7ada44420df97fce33e45c97236df1297cd654cb5b4ce49464abcb3	5	5729	729	599	604	19	4	2023-09-27 12:53:03.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
606	\\x86d999d2eea95f3938a3810dcd23ce5cc09ef7a1cfe4043f9fc65c43ccec5e6b	5	5740	740	600	605	3	4	2023-09-27 12:53:06	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
607	\\x710ca8c04e0b0ac5f49226d32c04146698e2707914e78776c93ecee22bb1c053	5	5748	748	601	606	3	4	2023-09-27 12:53:07.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
608	\\x9cb834610afd07647b725bfd31b589a731fa3b4b161ea62c0fbb84d5560caaf5	5	5759	759	602	607	12	4	2023-09-27 12:53:09.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
609	\\x966a02b9c876797a300c52c09e150a4fb41f8a04fa370c36eb2038c975b2b3b8	5	5778	778	603	608	3	4	2023-09-27 12:53:13.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
610	\\x156f3b043537ac27f6ba02985cd28740d7205c0a3ee520499635b489b4aedd9d	5	5780	780	604	609	12	4	2023-09-27 12:53:14	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
611	\\xda1d66349b440bc8a76c4d076d902f7a97b57dd8248f3248a5083cc6f99c819c	5	5783	783	605	610	19	4	2023-09-27 12:53:14.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
612	\\x1c26b4fcfa457becacb70d41c1b2960aef989c1fc4d5994ac6b767eefa1d8a57	5	5807	807	606	611	19	4	2023-09-27 12:53:19.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
613	\\x53317cda03b0cca3b94938c4fb6e1ab614caba554064819c82e9139f2e20ef10	5	5810	810	607	612	5	4	2023-09-27 12:53:20	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
614	\\x7d7594136e6e888833e686c5eb493ad5a244785bd947f2a2f888c082fc6cdf57	5	5855	855	608	613	3	4	2023-09-27 12:53:29	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
615	\\x31e0233babb01f07205391ce9c99d452f1ad01bc196257179f2de54015e432e1	5	5863	863	609	614	5	4	2023-09-27 12:53:30.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
616	\\xe40a516d547085964ba388533e0b390bf157ef94ad7bb46a01e5cdd096c60258	5	5871	871	610	615	6	4	2023-09-27 12:53:32.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
617	\\x4783ca93513c14658d6a7e498e6c1b1821b7698ee80a520cd9fe1557aa050911	5	5874	874	611	616	11	4	2023-09-27 12:53:32.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
618	\\x60530dc97da6e150f5d6a0bf67aba456eef0a95cc3c05e055bc6a9e2c0f55816	5	5882	882	612	617	19	4	2023-09-27 12:53:34.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
619	\\x7d3d07b7125bdc6f05b7fb1b2bccbc9a6ab3330dc0eb027decaab7dec2d92a6b	5	5891	891	613	618	27	4	2023-09-27 12:53:36.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
620	\\x6f922363b6ef51553f4186cae871f6605742e4a90d829dd90fe54e5411b72787	5	5895	895	614	619	9	4	2023-09-27 12:53:37	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
621	\\xee7947ff2805d33d65ee3cdec33979d18f56a04db0b892b97c19a5fd6581135a	5	5926	926	615	620	3	4	2023-09-27 12:53:43.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
622	\\x616ab8099c4862b74d012c858fbf40afdf2cd5a4c72146850695c40a773c81ef	5	5934	934	616	621	4	4	2023-09-27 12:53:44.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
623	\\xd40490f543221adee1f86086fb9570e3cd48c1b793e244fdecc5d50e785c737d	5	5936	936	617	622	12	4	2023-09-27 12:53:45.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
624	\\x7202a9eacea5112f75e0f08a48079b63847be983a78026a810bfa8276348eeda	5	5944	944	618	623	4	4	2023-09-27 12:53:46.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
625	\\x29e82147c73cae7f970b0117914a1f3e4f1554f5dd98385db0bcae51fa8360ff	5	5945	945	619	624	12	4	2023-09-27 12:53:47	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
626	\\x7f792af2bf7c30e2b91c538a11c8971719ebc60ff7e156325e45145e820ff854	5	5973	973	620	625	8	4	2023-09-27 12:53:52.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
627	\\x4daf02e912525adae83767eb63b1e56b30baad4bd3d4f33762ca1d172cb9160a	5	5977	977	621	626	9	4	2023-09-27 12:53:53.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
628	\\x0b7daf556f8a9e802cbc7bd78dacf42852dd3457375045afcfe42e5796bd23e3	5	5979	979	622	627	19	4	2023-09-27 12:53:53.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
629	\\xe9362c0b0dc2072d7bbcbd39e4ab2307aadbb67b9eaed00bf87e70d5056afb69	5	5989	989	623	628	19	4	2023-09-27 12:53:55.8	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
630	\\x882ab02a4790cf6d74e5f70e8e344c02b4a452899777d35effcf7f487ebd1140	5	5991	991	624	629	7	4	2023-09-27 12:53:56.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
631	\\x29df4ca6bef670ec991ea5620218c066b4ce87071e9d79dff77aa74e1dd76944	6	6022	22	625	630	4	4	2023-09-27 12:54:02.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
632	\\x25efc527334623781aaddfb3fcb8fb43b46f3346e7161c1c94228bfe73cd2e0d	6	6038	38	626	631	11	4	2023-09-27 12:54:05.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
633	\\x2fb4941fe37d354f844cbbda311484767d251057e200311a5b62403fba6b5f03	6	6054	54	627	632	9	4	2023-09-27 12:54:08.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
634	\\x5304c5e47c60ce10602ee96f33a958900a4b68c1fd5b9f770345193b8e287d7c	6	6059	59	628	633	6	4	2023-09-27 12:54:09.8	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
635	\\xe16a53252e68759938ec61fb14189894079150e57c79c7f51192c0a22695e91b	6	6071	71	629	634	3	4	2023-09-27 12:54:12.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
636	\\xfb6977ec51f66f324f2cb56a6cae006eb58a6d3b2ba6e274aea554a98e5d23b7	6	6073	73	630	635	8	4	2023-09-27 12:54:12.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
637	\\xc1ee842a7c7c68f8a15fce057bbd86472f7ec90708df9ec9c7178d60e49fcde6	6	6125	125	631	636	27	4	2023-09-27 12:54:23	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
638	\\x970b2e959eb2dc3cb5d909d136ba037c2739ac07e89538829046e83daff6c789	6	6126	126	632	637	3	4	2023-09-27 12:54:23.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
639	\\x275ac24f57209027e3b62e201d49f9c6845fd94a4f433548f59c4ed224a6ee9e	6	6131	131	633	638	5	4	2023-09-27 12:54:24.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
640	\\x6ad1f0d055304bc2c6ac029f6bbc04016d72b537dc9543f9a371989fe3edb91d	6	6134	134	634	639	8	4	2023-09-27 12:54:24.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
641	\\x9c02196eaecf00e07bd6ff143d5cb0f1075748c3113d95e515e6ffeddf1ad7a1	6	6140	140	635	640	5	4	2023-09-27 12:54:26	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
642	\\xf713886119b54718d0a0261234adcf58323530455b737181f93cf1efd866c0a4	6	6145	145	636	641	7	4	2023-09-27 12:54:27	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
643	\\x1c4aa2c32dab4d88e20c5fb36971e270341c53c17e5e55a530db62aebea28b25	6	6153	153	637	642	4	4	2023-09-27 12:54:28.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
644	\\x749852d967aae6112e504a849e8a2abc842a5323660b91841727e622d3c2f0ee	6	6167	167	638	643	5	4	2023-09-27 12:54:31.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
645	\\xe0ca073b3b655c71ff4d6f6e10bf9aa23debd6dd441c6b1d5853768fef91c9e2	6	6186	186	639	644	11	4	2023-09-27 12:54:35.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
646	\\xe34e6a4bb8661007158073bc9f0cbed0e822456937568da27e8038b9e2b730c9	6	6188	188	640	645	8	4	2023-09-27 12:54:35.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
647	\\x9104fcf9dffd1eae178b112cdf345d0590b3fb2f4782ae6a5caaacaaff7eb7c1	6	6212	212	641	646	4	4	2023-09-27 12:54:40.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
648	\\xbb9d28da356859384ddac4fc9c27ab8793aae6fe0cbe71b22dd45dc60b5b6d01	6	6240	240	642	647	9	4	2023-09-27 12:54:46	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
649	\\x2b59278e8b7a744009aaeca7ab089e2701a7605fd68e6f13444e8786e6c20bc9	6	6251	251	643	648	6	4	2023-09-27 12:54:48.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
650	\\x737592be21ed3209163bca3312fd1a832025363925bbe2c78bca92fc600bed7c	6	6258	258	644	649	27	4	2023-09-27 12:54:49.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
651	\\x72fa120da335bcb7904ad0cb5bf8d4c40cc4f8563a3656fde9b1aa6d0c97a92f	6	6275	275	645	650	8	4	2023-09-27 12:54:53	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
652	\\x1a1872a475cdd00d2d933a5bb5428aab8a2419d5c5cada417827c421c02b415d	6	6295	295	646	651	8	4	2023-09-27 12:54:57	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
653	\\xb2741e46b8d05a4c201c9f919b505bdd045a4075091663f3da7f8f7e9a0919e1	6	6298	298	647	652	19	4	2023-09-27 12:54:57.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
654	\\x9365eb006d16bcbb202606a5b87b692887e5a2a8115278a5d3e187f8942320dc	6	6300	300	648	653	4	4	2023-09-27 12:54:58	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
655	\\x405e237ba03997dbe9e684b4042a93e868fc58b2c34819d51db6af7aea3d6bc5	6	6308	308	649	654	5	4	2023-09-27 12:54:59.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
656	\\xf91af48f55832e6128092d7c8caf479074b23808f1bd58b7b49370df572a590e	6	6309	309	650	655	27	4	2023-09-27 12:54:59.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
657	\\x76c6a57b15ae9f385920b97ce4ae1da3194948f86701e6f906a85ed038607277	6	6318	318	651	656	7	4	2023-09-27 12:55:01.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
658	\\x344b6fcad80a5245b4bf7adb1faf3107b1f02aef2dc01faee56104728ea956f1	6	6326	326	652	657	3	4	2023-09-27 12:55:03.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
659	\\x842ed182776e6788382036e8bb70802b224b96be30983071136b172666726fef	6	6333	333	653	658	4	4	2023-09-27 12:55:04.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
660	\\xf2395d82045c5eb661f8dc0ff30f32fb9a671914eaa090893e3fbc9ca9ae37e5	6	6354	354	654	659	27	4	2023-09-27 12:55:08.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
661	\\x954228c41ecdb18f7875d7b8b77e30548664f699be398fbd39609ded8473d6d5	6	6365	365	655	660	3	4	2023-09-27 12:55:11	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
662	\\x15b1eec20c463bf8effe215fefcba133269cca1471591e5ac89a7c93341ef6b8	6	6373	373	656	661	3	4	2023-09-27 12:55:12.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
663	\\x228aeac60c39b606c1641a42e1ff34793a66023b54db960feb183e8ed14dd1c8	6	6386	386	657	662	9	4	2023-09-27 12:55:15.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
664	\\xe750ee6c4fd37bdd114f914a5e683f547ff15f31f05326902d47fd49fb7aaa7d	6	6399	399	658	663	9	4	2023-09-27 12:55:17.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
665	\\x27fa55d9aaee56c8317e18b085d66ab8e8c2e7815a2e529d4d926b9bfb10e947	6	6413	413	659	664	3	4	2023-09-27 12:55:20.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
666	\\x049a65ca3a7be83f4ab0bde8ea24bd8ed3c33b9429b929d93b5c9ee194f6f3f1	6	6420	420	660	665	8	4	2023-09-27 12:55:22	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
667	\\xad87f613700bc9e0973e3d038d3a5a508813b84614ce8ab9d5bd73d8d22a9b70	6	6425	425	661	666	9	4	2023-09-27 12:55:23	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
668	\\xbf73249b3b072286e594284c99f33566dadf4b9786847964f0a6ba2cb19732ea	6	6433	433	662	667	19	4	2023-09-27 12:55:24.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
669	\\xb62ce022aaf57d48c6ab0a1adc321ec324c9ca299280604990483a5369ec76e7	6	6448	448	663	668	9	4	2023-09-27 12:55:27.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
670	\\xb202d28a0420909196f3a6c0d24600cc902fdc8853531448bd9507000a4826a3	6	6478	478	664	669	19	4	2023-09-27 12:55:33.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
671	\\x9668834e303ced064f6b1c79bf55e31c8b9143ccb57a10051c825495b21f8a2e	6	6491	491	665	670	6	4	2023-09-27 12:55:36.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
672	\\x85540ef4e1854bcf4611b9ea233fa5331c392a95639b8a721c7e0ce2ca4b74c6	6	6492	492	666	671	5	4	2023-09-27 12:55:36.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
673	\\xa765f1828c185732d7790800b00f4412f717ace88f70f0110d0752fb1e3c817d	6	6506	506	667	672	5	4	2023-09-27 12:55:39.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
674	\\x5df803e34d86084f07daddc59da591684d0546d8bcd8d1e57d01457ca1fd4fcb	6	6511	511	668	673	9	4	2023-09-27 12:55:40.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
675	\\xe0a6ef3343071b0214440098180fd60a67f5e7b4a72830a3457130135ff4c53d	6	6523	523	669	674	11	4	2023-09-27 12:55:42.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
676	\\x489a8994c1bfa8061ba5c9c4cfa1840ef714bfcf9db90619de7738a6072c217d	6	6530	530	670	675	3	4	2023-09-27 12:55:44	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
677	\\x674ea6e1acbc6c488ea3359071c637ba141aa7a5b818e005bf3924f999a20ee7	6	6536	536	671	676	8	4	2023-09-27 12:55:45.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
678	\\x316491338dd44515e8f3365e210cae55757af47fca8b56ecae41ed9bd60a3c5b	6	6537	537	672	677	9	4	2023-09-27 12:55:45.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
679	\\xa1d90349e07a012dd378f1ad1618cbd26c00788e4afa30dab4972afa042a86d6	6	6544	544	673	678	27	4	2023-09-27 12:55:46.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
680	\\x90a0a3e834f37cc77c7f18e75b9671a6f36c8195903a58641a60ae3390ff8243	6	6549	549	674	679	4	4	2023-09-27 12:55:47.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
681	\\xcb6a9f2333f31c4c137c894d44d89aba3500f9626460350aa5da3b0bd749193d	6	6551	551	675	680	6	4	2023-09-27 12:55:48.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
682	\\x80a700dab4f5d82101712b22131dd6d53692a5ba14abc4a5f76c78285bc8faf5	6	6574	574	676	681	8	4	2023-09-27 12:55:52.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
683	\\x74a20fe10011a72b57e7381082e4262cd6ba44e0c18bcd3693d8f1a29ea127ef	6	6578	578	677	682	19	4	2023-09-27 12:55:53.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
684	\\x3b069dca7a200fd0149f1793308785dfbcd7833383781796cf8b02c1d6cbedcf	6	6586	586	678	683	4	4	2023-09-27 12:55:55.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
685	\\xf26738b0e285849ae031ac59ce23526b4b10600f883159ea1dfe75c3a5ca16b1	6	6595	595	679	684	11	4	2023-09-27 12:55:57	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
686	\\x31957353d8b0bde13f9b5debb415bfdcbe11ac1df0407fa2a1b9177bbcecf78a	6	6602	602	680	685	5	4	2023-09-27 12:55:58.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
687	\\xcf7dc7ae499055c573e950cdf1e0c5a7dc273e633cd3e504ab8fc3389afaa2ea	6	6603	603	681	686	9	4	2023-09-27 12:55:58.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
688	\\xd40927adc22526fcfacaa9697f07e6668b505560c43fba2aa64b3cef94cbd694	6	6606	606	682	687	12	4	2023-09-27 12:55:59.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
689	\\x31e688d089432a9c091db2c7c0fe3114bff3199eb476a40b5cba51941534fd66	6	6613	613	683	688	9	4	2023-09-27 12:56:00.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
690	\\x366f7999e4448f7c3ad7d7ec80aea9e33df6bccd0de65705de0479d37c55f833	6	6623	623	684	689	4	4	2023-09-27 12:56:02.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
691	\\xd0735bdbe20abda9810383106accaa9a3ff2fb83963acf9f834832b1cbef7e8e	6	6633	633	685	690	6	4	2023-09-27 12:56:04.6	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
692	\\x6eb387d7aab1745bc46f6b1af683cfe7f137a4cfe83ab0d87dbcb8c3ef468536	6	6650	650	686	691	7	4	2023-09-27 12:56:08	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
693	\\x7cc71027e1d09da023c2cf8debe25f88b02d7b3e1fd4b2dd7f3e854103674252	6	6658	658	687	692	5	4	2023-09-27 12:56:09.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
694	\\x79c0e59204b7acd499d2ef722891377728aa53b756c3081d363b645da34502de	6	6660	660	688	693	5	4	2023-09-27 12:56:10	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
695	\\x2bbbc4833011dcdb003ad42b422f9908c5dab7a9e860252922cdf0844274b520	6	6681	681	689	694	12	4	2023-09-27 12:56:14.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
696	\\xeadfe9089a4cf76de452d5029f809cd472aa14484ffd0a831ef005ea18506fb9	6	6682	682	690	695	19	4	2023-09-27 12:56:14.4	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
697	\\xb1bfdbcf0c05344a4a5b5a835776ac0aa8784477008e35b50db9015f939103ad	6	6691	691	691	696	4	4	2023-09-27 12:56:16.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
699	\\xe9bf9d991176e5f8380d8e96ee007099fa62244deeeef050eebdce81bbb86708	6	6694	694	692	697	7	4	2023-09-27 12:56:16.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
700	\\x477feea78cb0042820b86be1b08c4a28be07f4b476feaa4a1e3df26f451fb036	6	6698	698	693	699	19	4	2023-09-27 12:56:17.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
701	\\xee2781fd62788bfd0fbdf6574e19b2018d0b7ef3b4b41062aa600b1f243a4335	6	6700	700	694	700	3	4	2023-09-27 12:56:18	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
702	\\x9f4d6b0585a8cdd90446a1792242f122b5d144695e85f39c84dacd5a8f916d96	6	6701	701	695	701	12	4	2023-09-27 12:56:18.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
703	\\x7dadb1750c36aae9ee65e50bcc2f70614405cf43abda201c0e9ca256cb7635ec	6	6703	703	696	702	4	4	2023-09-27 12:56:18.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
704	\\x5315fafd81af14580a01944f2ba8a68f7424c7a79eaeb6a7c61665dae5c8a447	6	6715	715	697	703	3	4	2023-09-27 12:56:21	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
705	\\xa0f48263aad66897ffc475426dc26578d766254d9bbdee8da83ee59bfeeb267a	6	6721	721	698	704	12	4	2023-09-27 12:56:22.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
706	\\xe9074cf2edaca36f98b73dc0622332b3a60481783a79271420325c1e392be39a	6	6729	729	699	705	27	4	2023-09-27 12:56:23.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
707	\\x94cd2fc867a2ac8c1ccfbb95000d4e93062a42de27ed29a60b53c8c95e64adf5	6	6738	738	700	706	19	4	2023-09-27 12:56:25.6	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
708	\\x31a5a54f36652735d61faf6465e15b4da79975403c4e6ace2edb25ef5ce28c4e	6	6743	743	701	707	12	4	2023-09-27 12:56:26.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
709	\\x2b10f7248583ddb06948d6595157d108b92b07b2d1f4b6181efbc12a0dd67df3	6	6745	745	702	708	7	4	2023-09-27 12:56:27	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
710	\\x0ac5f99c578cc0eb133f7347e08d55a32d6979c761e36bd87d64027d8bb73918	6	6749	749	703	709	11	4	2023-09-27 12:56:27.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
711	\\xa03143e7cb1a0bcf67b1563aa8895ed93a603a6482a1d93908c4828497c971fd	6	6759	759	704	710	5	4	2023-09-27 12:56:29.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
712	\\x144555ad57bca707ad45d70feae52002040a17b2c677c06fcbd42779eb49a6bd	6	6764	764	705	711	3	4	2023-09-27 12:56:30.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
713	\\x958543559a307931de79d724868baa10c367268c5df5b1fb8cf349f94f16e624	6	6771	771	706	712	4	4	2023-09-27 12:56:32.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
714	\\xa91bd48c670c4375e4dccce83fece24e8a6e9140fda3866aa6c143bbbb7fe044	6	6785	785	707	713	27	4	2023-09-27 12:56:35	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
715	\\xaed9b02505c490f48c043e1b96b0a31b46feb72744d173e67f114fcf1ef8c0d9	6	6794	794	708	714	8	4	2023-09-27 12:56:36.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
716	\\x258fd51b55be9b75099bd0ed4f535ef54b340c5972009e8bfedb16467d59bc72	6	6801	801	709	715	7	4	2023-09-27 12:56:38.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
717	\\x535c82c2c26ac3a667b258f50b27827b5f10044d8c7658d0b23b4866eb916a5d	6	6808	808	710	716	27	4	2023-09-27 12:56:39.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
718	\\xfd39c8edc2d786237615f222031ae54c73d75b71ec6ce2f3a5f0f87f1552e4aa	6	6816	816	711	717	5	4	2023-09-27 12:56:41.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
719	\\x137ada5d2ec0f2c35f48eca8b08553902ce43bc20e6239c1d4bee33161dfd277	6	6818	818	712	718	5	4	2023-09-27 12:56:41.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
720	\\x510c8373c438e41fd4df90eab50bba5cb46bb1fb5c33ba188b058c2c9fa2c6e4	6	6824	824	713	719	5	4	2023-09-27 12:56:42.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
721	\\xbda31241537fb147abcd329910b4d2b558962274a88d3ac6ffa0d2b8351dba96	6	6829	829	714	720	11	4	2023-09-27 12:56:43.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
722	\\x79d0cfb168de754c4b418a7bbeb84ac50aabcbd32705713871fcc7dbccc3fc97	6	6833	833	715	721	3	4	2023-09-27 12:56:44.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
723	\\x8e41ad78b642abd1f4459bb41609c2fb2ac3d0adc7cd133c335c6ebf509cade4	6	6834	834	716	722	3	4	2023-09-27 12:56:44.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
724	\\xc74f4ec6dec538f57783ec335aed6a0b631ec4e502f1e09d0b3513418a34c1ac	6	6839	839	717	723	7	4	2023-09-27 12:56:45.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
725	\\xa967336fa276266f22fb9e0e1c59ea5d70564bbcb621482121963876639cd132	6	6840	840	718	724	4	4	2023-09-27 12:56:46	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
726	\\x3784e7fa65b5a83410c6679436f2617c102273ad1e39a2331cc1c1e86aadbc9a	6	6846	846	719	725	9	4	2023-09-27 12:56:47.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
727	\\xc872dcca9d32fdf4f02418d74ad8dc54171f917a4e921421f1ae0f4e7c13657f	6	6847	847	720	726	7	4	2023-09-27 12:56:47.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
728	\\x6053b8f774f58431f494b72edc6e072a8e1d8864738cffddc1d80f2a121a89a9	6	6861	861	721	727	6	4	2023-09-27 12:56:50.2	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
729	\\x7595f20b0353f9122cae5aa5223f32c6b05855366a1091eb90383b60639d879b	6	6869	869	722	728	7	4	2023-09-27 12:56:51.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
730	\\x21a5457f2fac48bf388d45b238d14f6655c888468ba685f807108706dd0979be	6	6871	871	723	729	4	4	2023-09-27 12:56:52.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
731	\\xd7e24f9cff56cacbd0557d3ea90c9c307d8f104c64ea76c2cb147a9eec5f4738	6	6898	898	724	730	5	4	2023-09-27 12:56:57.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
732	\\x9a1f90839f772afd3f0be2245db49d061b25053026da02de66b584a9a4888e55	6	6905	905	725	731	11	4	2023-09-27 12:56:59	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
733	\\xa52ad4616de85396c1f825d43399187cba7f0f4d0f65daf83bfc2ba46e68b44f	6	6909	909	726	732	5	4	2023-09-27 12:56:59.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
734	\\xff5a3ebf9c1cb72cbfb6f1f659c95579a685654adf28cf0cd946dddb47e40afb	6	6912	912	727	733	5	4	2023-09-27 12:57:00.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
735	\\xba5d94479564de19637bc66f90f8079db0dff884b8ad2b26d383fdcaf69c2e66	6	6913	913	728	734	7	4	2023-09-27 12:57:00.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
736	\\xe7ba7157f57c37deccd85613bb34c3f44980082f7f1609a88a290ba831d10882	6	6921	921	729	735	5	4	2023-09-27 12:57:02.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
737	\\xc0bc95af11b89d5ba914c395ea1b0a95d61682380cab549ca71f1ec311760966	6	6925	925	730	736	9	4	2023-09-27 12:57:03	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
738	\\x0946d7a996b1f14c693ec7f1a2373a0db85056a08b0687bffd7db9b4b243f6c3	6	6930	930	731	737	5	4	2023-09-27 12:57:04	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
739	\\x623824351160485096a961ae5de7a3045c48ef8597be2ec14403d8bc85ab6a3e	6	6941	941	732	738	11	4	2023-09-27 12:57:06.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
740	\\x672d670b0358a164448b6edbaaeac0e0b323a6aa324c572c12ab43426d1ed774	6	6945	945	733	739	19	4	2023-09-27 12:57:07	0	8	0	vrf_vk18gc2k5dzk2prgy7cfruen6w305w02l4w0p8kd46rtfwusyt76p4qsnvn3z	\\x7487db0ab1c0fee33e10505d645f2ca147dea6593c9d992a2b8e68ffe2d4c461	0
741	\\x10410f1ac7afc4ffbc7d6a333eaf0a55f0895e2eeeeeac350a9ef9066a02d4a5	6	6958	958	734	740	7	4	2023-09-27 12:57:09.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
742	\\xa67b5eb2b3cc0e9454d0bc28a5fbf6ba6fb250d745a4e9f97486e3b7ccd2e951	6	6963	963	735	741	11	4	2023-09-27 12:57:10.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
743	\\xb7af897d0c6f9c50e5943cbea3b3088da83cbcdb2e99f866d222c2a13e351d14	6	6984	984	736	742	6	4	2023-09-27 12:57:14.8	0	8	0	vrf_vk1fcnhch9q7d0tn72vke0wt3vyxpjsyvhe8hsruvws2nwg9s67jq3spsdraa	\\x16c1ad0d0ce90060e242b34628e9453935be0db3a1601b9991b2ff026ea94f42	0
744	\\x1f0cbf041c9968b853ad23e7b66f98b0259bab840d9bf7880c1df06cdd90bb3b	6	6988	988	737	743	7	4	2023-09-27 12:57:15.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
745	\\xeb9a48b6295bc3033a366a24c60b7d377242ded906205b0c0d6e0295d18adabb	6	6997	997	738	744	12	4	2023-09-27 12:57:17.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
746	\\xee51839fb9ee409fc8b9961813810b1b3e3b3e47aa63cf2caf54d373d29f54fd	7	7020	20	739	745	9	4	2023-09-27 12:57:22	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
747	\\xa63681ce676c6573b80cb04693882b83050f30c80e54c9fe35a88d5470469b3e	7	7022	22	740	746	3	2904	2023-09-27 12:57:22.4	10	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
748	\\x0a2a4e229529d4b16e3be56b41cf14f02167db519919fbe8395eb807194a8cde	7	7030	30	741	747	7	15895	2023-09-27 12:57:24	53	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
749	\\xdaa8e9d015278d9f6224c1c86a0060262f6441d64c54e79b787242e2bb6917cd	7	7041	41	742	748	8	11188	2023-09-27 12:57:26.2	37	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
750	\\x5d23eb49c322133661fa51ad52e54446c9dc8ee746c39d7875775af9031ab961	7	7058	58	743	749	12	4	2023-09-27 12:57:29.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
751	\\x9101f56d36022081d3f974a3d5385231c9c6be85d22881bc68c2958c2256b833	7	7077	77	744	750	27	4	2023-09-27 12:57:33.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
752	\\x47c047707fccc2f77e1c57aa00be530348b9d54a71eec90c6eb3862770311ff0	7	7084	84	745	751	8	4	2023-09-27 12:57:34.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
753	\\x47fbf0647952d22c359f80b67ffa9f82046e6548daa1edc7e40305381fea585e	7	7087	87	746	752	7	4	2023-09-27 12:57:35.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
754	\\xd0ac81c9a2a28a06d3279d32eb171dd3a052e8e29955abf3c6f10e2d36f577fe	7	7108	108	747	753	11	4	2023-09-27 12:57:39.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
755	\\x8454c42a5d4dd2114a730a4587c1db94f207498339139621bba921a331530677	7	7114	114	748	754	5	4	2023-09-27 12:57:40.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
756	\\xa2f53539f399bb2087a9cdceb33a1c49cc9dfb713163a3f06644dffbb0404dc8	7	7123	123	749	755	4	4	2023-09-27 12:57:42.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
757	\\xc5378c7b2b26c01e61a52273d416b7b2f5b2a6320395c02174072c33e17e5d1b	7	7126	126	750	756	12	4	2023-09-27 12:57:43.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
758	\\x9c05328dc434a72d4d3c089d837b6d019060d76d6680f5f54f1d87f75814cb71	7	7129	129	751	757	11	4	2023-09-27 12:57:43.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
759	\\x70db2a841adbea52925c4cbebf0244c73f542b739e837af552b1275ab5c95363	7	7132	132	752	758	27	4	2023-09-27 12:57:44.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
760	\\xec39f687c3e1b46512f44e39e5c63dab93123ff3c6599e61a5c440082925e9b4	7	7143	143	753	759	11	4	2023-09-27 12:57:46.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
761	\\xb953f004e146724768c01b614e06c76e9b234f2fdb8f6ebf1ad6d9b311585147	7	7154	154	754	760	27	4	2023-09-27 12:57:48.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
762	\\x4acece030dd12f50f0a442ba83a7c5bcab6aea7aefbff91fc1c3019a84b9abcd	7	7180	180	755	761	11	4	2023-09-27 12:57:54	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
763	\\x8f3633bc699f5cb8465ba66926baafff2c3ae388bf27ecbf244de60c48a12726	7	7198	198	756	762	7	4	2023-09-27 12:57:57.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
764	\\xda61b03856ea6d301e9357348b999fb0c86859a799925623c26d6953e6ded999	7	7201	201	757	763	11	4	2023-09-27 12:57:58.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
765	\\x4f67516d7d760de643259d97cfcb8f3ebafc6b21831c8c52905acf2cce58acea	7	7220	220	758	764	7	4	2023-09-27 12:58:02	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
766	\\x71f6dbbd1dc28ab3fa86bbe0f0b9e96c28f6bacb2a6d0eb44e989b3d83d6180a	7	7232	232	759	765	8	4	2023-09-27 12:58:04.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
767	\\x301b2fb124fff6cc12f85a709d258c1fff37838ffd7672e6af8300b90dce9e7c	7	7233	233	760	766	3	4	2023-09-27 12:58:04.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
768	\\x054d1ce83ba5c7b5bc20dedab5f39fc0bef8d1415a79b7af55c3bcf04c1244de	7	7239	239	761	767	4	4	2023-09-27 12:58:05.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
769	\\x76503b22a166b6c64007c8fe47691dc462ed83af4bac09d6af0b8e492268e559	7	7253	253	762	768	5	4	2023-09-27 12:58:08.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
770	\\xfb4e68324ce4a009a9360aa58b45b664d66f318a36d895fbc20ab40114cbb668	7	7271	271	763	769	3	4	2023-09-27 12:58:12.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
771	\\x85632059409eaf3425bb0060aa07caa139ef7b585910b40e76e5b7390d37a2d9	7	7274	274	764	770	7	4	2023-09-27 12:58:12.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
772	\\x5dadd21704b25119f801237514e4cce10901fe7b8570625f9c9b847b5aeb185d	7	7282	282	765	771	5	4	2023-09-27 12:58:14.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
773	\\xb2e7844a19885967b56f1048905317de6c2ccb559cf9eabc285a37c51fd4f9d7	7	7299	299	766	772	12	4	2023-09-27 12:58:17.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
774	\\x5f9cfa77e61443441f25cc28f5272013409e18402f68b5c88fab317ece9e69fa	7	7300	300	767	773	4	4	2023-09-27 12:58:18	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
775	\\x8b64d21b8139afccbc3c6f2f0f5924f5652497873616ebe3173d92174710e21a	7	7304	304	768	774	12	4	2023-09-27 12:58:18.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
776	\\xaf9f0da86b3503ccb26a297c9fb6a15493d9ce6df1e06b81a7d9c066650d64f0	7	7308	308	769	775	11	4	2023-09-27 12:58:19.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
777	\\xe77b070147df463c6cc9062486da40be2974d636ea1270f7065ac4dfa4442efb	7	7313	313	770	776	27	4	2023-09-27 12:58:20.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
778	\\x1c90247cecd12691ba194dd3236f10cb1e006fa7cd9f8d911ae03869ce798628	7	7317	317	771	777	27	4	2023-09-27 12:58:21.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
779	\\x1ecd2171539d05debc60168b72d49a76cbc78fc827dfb94066bbecdd909b9900	7	7324	324	772	778	27	4	2023-09-27 12:58:22.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
780	\\x4ed0a20a3304d92a4a75f222cfb1867a7d71bb83852b8856339d93d11f5f1d97	7	7333	333	773	779	5	4	2023-09-27 12:58:24.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
781	\\x8cf873d880591d40ff91201281c6bb9b3e4501eb0ec29646df98a810ed32e3d3	7	7349	349	774	780	11	4	2023-09-27 12:58:27.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
782	\\xfe7429870c99efb5713874f3d862e4dee9b1b9b5b728c9722347c5c2b25d4037	7	7359	359	775	781	4	4	2023-09-27 12:58:29.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
783	\\x1da35a3a889ebdaa3d69f093c9eefd8cfd44c82f926769e1166146209e9320d1	7	7368	368	776	782	3	4	2023-09-27 12:58:31.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
784	\\xcb6fe3ebb055320367b716bcb64a603d544be577ba0b0440540a0a5000f0a196	7	7372	372	777	783	5	4	2023-09-27 12:58:32.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
785	\\xa1ba5d29e9c292442e117ae3e701c1a6bfb2e8570a5751786d51e65fa4fb1cee	7	7403	403	778	784	3	4	2023-09-27 12:58:38.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
786	\\xc0ae8d886c9ffb4b7b0d292d09a8e7f90d9218535bbf81d25c4c7770503e923e	7	7404	404	779	785	12	4	2023-09-27 12:58:38.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
787	\\x2254b2bf7c0743e294c6010d0d59efeb4df4c4361c3e7c559778ba201972cf13	7	7411	411	780	786	12	4	2023-09-27 12:58:40.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
788	\\x4c420ea8b8a60fe28bb48c5d82424f55e919b53c5736a14b931093d4015d4d99	7	7414	414	781	787	4	4	2023-09-27 12:58:40.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
789	\\x42e4a814bd79f64e6ac95e86c957d8c2ebe6e3483c125dc198588ec4ab1bdedc	7	7421	421	782	788	9	4	2023-09-27 12:58:42.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
790	\\x5c299d6d311729da0a21af76307c8c70062eb9c25576a926fd94828656b57008	7	7422	422	783	789	7	4	2023-09-27 12:58:42.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
791	\\x77e2d92bb64957db0cb07cdab20b7b0c97a2bae9990ff6a09acf4b4b3a4a254a	7	7455	455	784	790	4	4	2023-09-27 12:58:49	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
792	\\x515a79ba2f43a7b79e743d972c4a26889694f16855d28472f95f1fe1222c2159	7	7464	464	785	791	27	4	2023-09-27 12:58:50.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
793	\\x6d1c3ce8037ae75ab1d9547a5cf8da70e89efe90c0a91fa3e068f3f09d5992c7	7	7469	469	786	792	27	4	2023-09-27 12:58:51.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
794	\\xf48c504057314009853fb6f5802c21d16f8ba8ff1111048141ae2a95b5911308	7	7486	486	787	793	11	4	2023-09-27 12:58:55.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
795	\\xcbc1e6ff024c5f4e5f68246f314010c6e55f459f7067ccb2f5387904e5294baf	7	7504	504	788	794	11	4	2023-09-27 12:58:58.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
796	\\x6aa49fd0a44404bef7d476ce27da88997364e559817572e5335c902e329eea99	7	7508	508	789	795	3	4	2023-09-27 12:58:59.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
797	\\x38f9d0741307643953c418adb983cf51b4bfb73c6315d48ec522092c913472a0	7	7544	544	790	796	27	4	2023-09-27 12:59:06.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
798	\\x251d8d5abf449cb6cb1e8197c47312dcfa3bdb18508a26db22f18f1e0a2dba47	7	7570	570	791	797	5	4	2023-09-27 12:59:12	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
799	\\xdfbb824da5b607aa4bf6ccba5778d3bfd0b33df26c063ed7ef86fdb51a21eafa	7	7587	587	792	798	9	4	2023-09-27 12:59:15.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
800	\\xc9172f1cb82cc959cadc51c6255cc848f7d4a650ba67af43f7220509dd73d8bf	7	7588	588	793	799	3	4	2023-09-27 12:59:15.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
801	\\x8540d811c1d2af1e27a0a968251865a690fa2d5ce1e8f4353e9619d8b920198e	7	7596	596	794	800	8	4	2023-09-27 12:59:17.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
802	\\xfb2b239d234977ff40bafb9d8e80c13ccdca3412125b999565df0f8ea86639e9	7	7609	609	795	801	9	4	2023-09-27 12:59:19.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
803	\\xec877bab6815ac92909bef38dc537e14f6c4fc0b978c77a072d776af81c2b17e	7	7613	613	796	802	4	4	2023-09-27 12:59:20.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
804	\\x91a7a0480c5a81d8a6abc862e2f232f1ee5999efcd27fdd1d436b8d2d1400437	7	7620	620	797	803	4	4	2023-09-27 12:59:22	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
805	\\xe4d39d1916d1f2b5abe13051f3ae1db65026ddc209008867686a8450d415226f	7	7622	622	798	804	8	4	2023-09-27 12:59:22.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
806	\\xe0a85dd69113af8da7b05d4765e2d33e58ff5a65dd65f36e8752d5e4ea311bef	7	7633	633	799	805	9	4	2023-09-27 12:59:24.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
807	\\x6f302191d5d55fbe65cd6edb07b1798f2811f60c3c7b54a9c7c4e57a7b9c458e	7	7644	644	800	806	12	4	2023-09-27 12:59:26.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
808	\\x611e7aae95c462b8e300f90731b55b85f48c8bb0b1e09294c5137f0b36500ffe	7	7654	654	801	807	12	4	2023-09-27 12:59:28.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
809	\\xce89713ef9fb748378ab12e785372d1f73ba605ba316dcfab0f4eb7780a7dbdf	7	7655	655	802	808	3	4	2023-09-27 12:59:29	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
810	\\x8ae6e8cc5c46331dad523b59de983434250f5675651372f63e9bbbca2cfdc13b	7	7658	658	803	809	3	4	2023-09-27 12:59:29.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
811	\\xd5b491bf0472bddd2d8ad858f92a69ba6b8fceb503492e42a0edfda85e80516d	7	7665	665	804	810	11	4	2023-09-27 12:59:31	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
812	\\x1723f1b3f469c6ee50fe2d376a80d1528f585097ffd2825de88530e7efc0f3c0	7	7684	684	805	811	7	4	2023-09-27 12:59:34.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
813	\\x066171269ad437776f506167501b20c1edab36258c9a116a1690f1884be3c6fe	7	7686	686	806	812	5	4	2023-09-27 12:59:35.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
814	\\xa4e9dcfb8b80d6120c66854f0feb85c750e0260e0ea9b59dadcecb4c156506a5	7	7693	693	807	813	9	4	2023-09-27 12:59:36.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
815	\\x61d1e46f7134be2ad21a1a6fb610ab5c08740e995849a21444d4948f6bf1ba5b	7	7721	721	808	814	4	4	2023-09-27 12:59:42.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
816	\\xbc0bce435a7aad2fd5ae22f7c756a9d78bcd547808beb26d222c39f700269160	7	7724	724	809	815	12	4	2023-09-27 12:59:42.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
817	\\x6e4a8eeb47af951444723766bb37067cf889a92b467c696d5bc6b3da350a35b5	7	7727	727	810	816	8	4	2023-09-27 12:59:43.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
818	\\xabab8d99c0280abb0aa46562fd05c53d377d5003b5cc6a5ecdc26d4f5287e6ac	7	7731	731	811	817	7	4	2023-09-27 12:59:44.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
819	\\xead1c5e43f95d569521b16f5b38098f42f88180715728899fe6c640dc39fcbd2	7	7733	733	812	818	4	4	2023-09-27 12:59:44.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
820	\\x47dffe10f4ab425cd9a39f106e2b6a6137b906a813f917dfc87d462ca240b869	7	7741	741	813	819	27	4	2023-09-27 12:59:46.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
821	\\x47b77060d5d359453d4ef9df7d544670fd1bad31f3b0f23772e5032a23fb6d34	7	7743	743	814	820	11	4	2023-09-27 12:59:46.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
822	\\xad05d16aa41edb371fd5845f46f4e44e3b014cdb9fbc144233ebb007c421c029	7	7747	747	815	821	8	4	2023-09-27 12:59:47.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
823	\\x5c39e1d1ed9875acf677e2354055aa4b7d8f7909043832ffe3a139bf50a72f1a	7	7759	759	816	822	9	4	2023-09-27 12:59:49.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
824	\\x45cee308f5ed049f17e35eb083b9621ba31cf1d5d8e55250a6b349f5713f9977	7	7771	771	817	823	27	4	2023-09-27 12:59:52.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
825	\\x17f8923a148baad7c6e8c602ca1a70dd6308d666e2ae686d7f012836e1b7fa75	7	7780	780	818	824	5	4	2023-09-27 12:59:54	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
826	\\x484dd433694a45592254cf02540b8c85af0ec2ead72df0310f824df4002ea679	7	7786	786	819	825	12	4	2023-09-27 12:59:55.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
827	\\x32f48727084fcf12e581fb97e11b587ebd45f61da32b6b74f95fe9345496e43d	7	7793	793	820	826	4	4	2023-09-27 12:59:56.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
828	\\xb0355a83a3e9f8da0a9cf320c05c60f762b4519e564279ff072e21a621c75855	7	7794	794	821	827	4	4	2023-09-27 12:59:56.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
829	\\x8b0bb78cd019db9384df6fa2760b95f8d6264908cea75b7363f173b07436fa98	7	7797	797	822	828	5	4	2023-09-27 12:59:57.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
830	\\xe5c5f19bd41af25167513575e5bb432fad21c33ad66c54cfc8508a1665c40de1	7	7823	823	823	829	11	4	2023-09-27 13:00:02.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
831	\\x061d9fa17bcf20cc804a11da95d519e622c66c6f033e5c68fed1be4d00d684fa	7	7844	844	824	830	8	4	2023-09-27 13:00:06.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
832	\\x9c091da7eb55d8e9c2dfaa999c6262747dce36941557cda97d1bc942d64154f5	7	7851	851	825	831	3	4	2023-09-27 13:00:08.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
833	\\xa9eccacc10eb810a157437136622f12ac4e5ff70174318b3ef8ee44138ab6bc1	7	7865	865	826	832	12	4	2023-09-27 13:00:11	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
834	\\xfdcfb3c4e9212230c38cb2afe700720cdc1685cb15c1609f6c5073f9aa808362	7	7866	866	827	833	7	4	2023-09-27 13:00:11.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
835	\\xf0856bcd5a8d31da18e0d77cb00deb47c6d58e2d862acfe420e22ab16bd15e36	7	7888	888	828	834	27	4	2023-09-27 13:00:15.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
836	\\x6f2cfe56f417fa3b160baa64efe5cbdf3a90ea67896bbbbedf353f44821f8717	7	7895	895	829	835	3	4	2023-09-27 13:00:17	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
837	\\x86ff20b1736f769ab95123a53d4ed881c1f03d54be34111223957d797656a086	7	7900	900	830	836	4	4	2023-09-27 13:00:18	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
838	\\x1c89dd558d656a1402f12906c7960094cc35bc390ac468657aa8edb59ad7aaa4	7	7911	911	831	837	4	4	2023-09-27 13:00:20.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
839	\\x4f0350447c0d0dcaf7a1517588d8fb93dd9123f041d89fc19ec35af488c232de	7	7915	915	832	838	8	4	2023-09-27 13:00:21	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
840	\\x0f04bdece22ca4fa350f7d965ce1dddc0b318cfa099f734908f80e1f1c4f41ad	7	7921	921	833	839	5	4	2023-09-27 13:00:22.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
841	\\x397d780ada3640bc56e09cdd9b4d090bc118fe0a2314ebded453d68e237b317b	7	7930	930	834	840	5	4	2023-09-27 13:00:24	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
842	\\xa675647e8b6658f648a35cab70c638e2f61026a50b734878455e16c56c3dbad4	7	7934	934	835	841	9	4	2023-09-27 13:00:24.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
843	\\x6611cd1fa7aeed44a1bd8e9c8d663e07be2f356fafd9143961dc25e093b8eac5	7	7961	961	836	842	7	4	2023-09-27 13:00:30.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
844	\\xf5831abda2105989a40e8ab30dc3f69bf21d4dd49e7baeea3546875d8ff04300	7	7974	974	837	843	7	4	2023-09-27 13:00:32.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
845	\\x04edbf5be78f52fd4b64e7a8b9c9cbcea9b9c8e9e5c0d501ad29110556b7b228	7	7975	975	838	844	4	4	2023-09-27 13:00:33	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
846	\\x6d40dbe9703c0c53fb8ff20bd6b96bcc3d97bf4aa022846dd000a515cb0c4662	7	7979	979	839	845	7	4	2023-09-27 13:00:33.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
847	\\xf95433137cde592376507e8749f35d38277962c30c198ca115f8c6404378c982	7	7983	983	840	846	9	4	2023-09-27 13:00:34.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
848	\\xb4dd67e01bee04915d94ec105c7ec9e74ff5ae321204645ed8d3a4c93ca11470	7	7992	992	841	847	3	4	2023-09-27 13:00:36.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
849	\\xe63432e2534f4cf5cf1f61ebfc6d018849916039e56be1c8db9fa5fba6517b56	8	8006	6	842	848	7	4	2023-09-27 13:00:39.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
850	\\x4d6b1875dc30c37a540bf304c9f293880bb585681c3f8d7deab76c7fe9d88f08	8	8010	10	843	849	27	4	2023-09-27 13:00:40	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
851	\\x33a9ffac57d3558e7d941ca63bababef51eedbac5da10ccdccfba3becb9555a3	8	8012	12	844	850	9	4	2023-09-27 13:00:40.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
852	\\x29ece97da0a7a4834d0380466ce1d6a9cf46e20f0259fdabc0bba578a3e50d22	8	8015	15	845	851	4	4	2023-09-27 13:00:41	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
853	\\xc1bf11a1384b9b0ea918d410af79521fd64f7640a0a4457f86bff661e35b5df6	8	8016	16	846	852	4	4	2023-09-27 13:00:41.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
854	\\x7aa59c2497aada54092155ea35e8c302c11e188ac3d209d36678b680c7e8835d	8	8019	19	847	853	5	4	2023-09-27 13:00:41.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
855	\\xa1b7a76a8e33105d1d65f1c1677fe87eba1d3f3c9d831ded94de13fad3abd605	8	8027	27	848	854	12	4	2023-09-27 13:00:43.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
856	\\x104b9fd1e1dcb2027d6e56b85044fed8fe628527c068611834c804dc6f2e42d7	8	8044	44	849	855	4	4	2023-09-27 13:00:46.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
857	\\x1ec659c3481491aedef74f295126be8a81a3cec9e2eea68c06106a1e5f3cc2b9	8	8060	60	850	856	9	4	2023-09-27 13:00:50	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
858	\\xf499da8b1b58a073ea7189f4facbb71beed550b6b8630ae0985fae8b231561e4	8	8067	67	851	857	8	4	2023-09-27 13:00:51.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
859	\\x85ec8438c92fd19622520178d40392af5fd31392a1d979e44ea001b616d8d37e	8	8081	81	852	858	11	4	2023-09-27 13:00:54.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
860	\\x79df786c17b655b2acc440e98f4413b11d2b2a300493e190b3f1805e99c66752	8	8095	95	853	859	11	4	2023-09-27 13:00:57	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
861	\\x1b56753239b737003f878f9eae3fce7d9ef53f64af82bd5516ae57fbf29cb4f6	8	8104	104	854	860	9	4	2023-09-27 13:00:58.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
862	\\x7efdcb26f6700438f4e71c30a723107a26978acf5a4485727bf97490877de624	8	8114	114	855	861	27	4	2023-09-27 13:01:00.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
863	\\xbcc4115a68e7c1cf86032a294170a4f599efd107e5917ef675003dd683f81b27	8	8123	123	856	862	12	4	2023-09-27 13:01:02.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
864	\\xd9fbc898b292dd315e6f038ba8aeff7ffe51ffb16563cc2cd19c17bdd052becd	8	8139	139	857	863	3	4	2023-09-27 13:01:05.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
865	\\xa4d11d3a18af55316148151ad9880ba435db90417144214ec825dd8eace7aca6	8	8146	146	858	864	4	4	2023-09-27 13:01:07.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
866	\\x0430ee7eaf07a05062e8928eb6bde5cd89b4ee398dc010ab3339b77e160c73fa	8	8175	175	859	865	3	4	2023-09-27 13:01:13	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
867	\\x482e3c9c6f8df90a618c1b1bd2c8bfd18e1c50588dc55d5b0a95aa80e7094565	8	8181	181	860	866	8	4	2023-09-27 13:01:14.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
868	\\xc973d0bc6b85958bb7be24db3373cea03bc87ab9765ff613028eccfc0d9f6f62	8	8183	183	861	867	11	4	2023-09-27 13:01:14.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
869	\\x85bf10b5d721c6a69b81af50197b50e2e696ce06c3ddf275cbf024ad128c016b	8	8185	185	862	868	27	4	2023-09-27 13:01:15	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
870	\\x49f874afdda9b16a0491237f4b1e30d728dc126a28529946382a424958d778df	8	8190	190	863	869	12	4	2023-09-27 13:01:16	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
871	\\xf602eb8fc3778f4def29e4048eaba510d77aff6938d9ddd05c189910e8a6062f	8	8196	196	864	870	27	4	2023-09-27 13:01:17.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
872	\\xc533927c6dfecc7ba60e40dbbffc96ffb95f3c7879e1844a8dcf4a5ff7225871	8	8197	197	865	871	9	4	2023-09-27 13:01:17.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
873	\\xf07a5330fc9149617c0871c8b3a0357b8675955d2a2851820da9f23bbd1eddeb	8	8204	204	866	872	12	4	2023-09-27 13:01:18.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
874	\\x20071158e246abc4d81df821421c86500ab335606494109a965fa7b0f570d1aa	8	8226	226	867	873	8	4	2023-09-27 13:01:23.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
875	\\xdcc31cd82c9418054ed21102b38ae872172b34c986be49909df39193c4da5e4f	8	8232	232	868	874	4	4	2023-09-27 13:01:24.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
876	\\xd4ea65eb55eb7defc69ed0cd4cc383d74129c03de36ed31534481df3084efc3e	8	8255	255	869	875	4	4	2023-09-27 13:01:29	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
877	\\xbd9c41bc93ebc6a3149f5ce0e55b7c09dfe51097c61b49975026b3c4cc9eef13	8	8268	268	870	876	11	4	2023-09-27 13:01:31.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
878	\\xa6f54331e5163e125b28550c7b57563fbc1860a70bb6af0e6558f33c8070575f	8	8269	269	871	877	4	4	2023-09-27 13:01:31.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
879	\\xdcade280197292c750f3adacf2693e3bbe9d0fc59fa606024df54dd8069cdbfa	8	8284	284	872	878	11	4	2023-09-27 13:01:34.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
880	\\x610f94adffd9ac8d76928f979e83934da952146feb5c188637b12dae6071821f	8	8285	285	873	879	4	4	2023-09-27 13:01:35	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
882	\\x827991a5158b76e9310382b604ff3111c4b61c047270fd44c44ed0af1abd293e	8	8294	294	874	880	8	4	2023-09-27 13:01:36.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
883	\\x54b7d6d867dd058947687a6e71a962843ef9112cb1d5503da799245a43822928	8	8303	303	875	882	5	4	2023-09-27 13:01:38.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
884	\\xaac5e7683d16cd9f299db468133e90003b82709232800a5538ed6b7eb6efe754	8	8304	304	876	883	9	4	2023-09-27 13:01:38.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
885	\\x2e225d422b54f62a3e2a4ab20fe76d5dedc161266c39d9c7bfb9187f29d594ea	8	8321	321	877	884	4	4	2023-09-27 13:01:42.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
886	\\xe83dd56735807f676666ef918cbd8edf8ba4eb79dbba056ff4e50a250fc85624	8	8322	322	878	885	12	4	2023-09-27 13:01:42.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
887	\\x4b12b76ae38567f203bec853b430e1782c083f76c9c9ccdc7efe8b483ec4bc92	8	8332	332	879	886	12	4	2023-09-27 13:01:44.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
888	\\x70a17b8d87253e0e5f973b859c8319dd282b48ef7358ae0024660fee048d00fd	8	8345	345	880	887	4	4	2023-09-27 13:01:47	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
889	\\x2dc84bc9b6828c74621a1d458242f1300fd1fdce746ea4d4e53a803b4dc133b9	8	8346	346	881	888	27	4	2023-09-27 13:01:47.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
890	\\x3035d11c44a11eb4790c68793795aa493f220343d2e6c18e117ccf11c682941f	8	8359	359	882	889	12	4	2023-09-27 13:01:49.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
891	\\x5ba07a5739fb54d73530c315bb7db4e75ad475716a99e887a2a0187985419f08	8	8361	361	883	890	4	4	2023-09-27 13:01:50.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
892	\\xaa53690e8dcbc1ec3ad5f58cfda0779688cf53c1310d70a8fd4aeb2f2a6c35fb	8	8369	369	884	891	12	4	2023-09-27 13:01:51.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
893	\\xaf0402ef0b6188165634d184fc882e6c166d860bece2edbbbb4956970720b59a	8	8370	370	885	892	8	4	2023-09-27 13:01:52	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
894	\\x764dcf23a354047ee8c0152b1ec8f249d5f49ad6b4ed03fefbd93992bfbcb203	8	8371	371	886	893	9	4	2023-09-27 13:01:52.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
895	\\x3b64444cb99d0dc680314c20a4b631960a69177b70787570849322ce8115d6b2	8	8372	372	887	894	9	4	2023-09-27 13:01:52.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
896	\\x568deb859c692393a437e672db12f61151a86681a05f5464e012c9778e0de451	8	8383	383	888	895	3	4	2023-09-27 13:01:54.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
897	\\xb1fb29ffe3627fe47f53f20d4021d1a51c40af9f56f5417068db65a690810c70	8	8388	388	889	896	4	4	2023-09-27 13:01:55.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
898	\\x21dfd0e83fda2a3fd72ea498730e52195479718ebff31750f439d57b1bab1af4	8	8395	395	890	897	7	4	2023-09-27 13:01:57	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
899	\\xf9c3022152e40a2507b71e1f2556cd2b84d694349919cfeacc4dcfef9ccc9e42	8	8397	397	891	898	7	4	2023-09-27 13:01:57.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
900	\\x8a676948063b69d4cfd01483f3d0409cb1951affac53c863f4c199de0067ed87	8	8410	410	892	899	9	4	2023-09-27 13:02:00	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
901	\\x5e7fe42acd9b52ae87fb87f66af0186dd3fa2990b236ffde9daa805337e13376	8	8415	415	893	900	8	4	2023-09-27 13:02:01	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
902	\\xac44cbe1d02eac1889d2180fa619e71cc9f7f70aeffbe423e49b1ee2e250af3b	8	8430	430	894	901	12	4	2023-09-27 13:02:04	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
903	\\x03c1df3f3a2609444869b15089e84c6b3ad9ee6ab4b43c0cb67aba712758dab1	8	8471	471	895	902	9	4	2023-09-27 13:02:12.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
904	\\x6da02d9d708a2b9ee20c2ccca3834057dfbe5e9636aadd8cb830bdd0aa344f97	8	8474	474	896	903	4	4	2023-09-27 13:02:12.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
905	\\xc2c439e5953583de58c72a55826943ff70536e22b74790b89a053f1f52811521	8	8489	489	897	904	4	4	2023-09-27 13:02:15.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
906	\\xd86cd6b96925d92bd0f3cc853cce2b2c0ee25a6cd3913d090d81ae2a123a7dfd	8	8490	490	898	905	12	4	2023-09-27 13:02:16	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
907	\\xebe3a1e9da7304b4b38c16eeab237a98600c1decd3065e5407fb4a832b1ed232	8	8510	510	899	906	8	4	2023-09-27 13:02:20	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
909	\\x5029732c359740ff3f4ae2f6d57c77286d40e19f9f8f1e0185b5ffd28948192f	8	8513	513	900	907	8	4	2023-09-27 13:02:20.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
910	\\x4a86d4bb93d8bc502e979cf23ec03b7a31c634e959f46edd4a846f6f0b48d2d5	8	8516	516	901	909	8	4	2023-09-27 13:02:21.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
911	\\x08caa8b80e2dc7de53de2ece3ed3ee4e476b95e4b351a909b5e9e27c240d6fd3	8	8517	517	902	910	4	4	2023-09-27 13:02:21.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
912	\\x5c81a4abe9b5bb2070b422e4daa62dd96a0d888a1cad5efdb49dcbe571beb3e5	8	8531	531	903	911	12	4	2023-09-27 13:02:24.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
913	\\xd90b4716a47e38d7dc580a78c01d2c4a77d0a34ba1c665a7c35ec9c092a54811	8	8541	541	904	912	8	4	2023-09-27 13:02:26.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
914	\\x582f93990820cb00de225fbf359dd10ee7f08673edb3d4f99376b754f87f581f	8	8550	550	905	913	8	4	2023-09-27 13:02:28	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
915	\\x6dfdd87bcd9988de343ab6ecd3460b5f99aee0eb79e768cf0741ae503a64f512	8	8557	557	906	914	9	4	2023-09-27 13:02:29.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
916	\\xf57ad7b575caf4ac85dda9003f0030588949f20daf210956521ab9b1c9b9b89c	8	8574	574	907	915	12	4	2023-09-27 13:02:32.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
917	\\xd5510f671b16b271a062e996adcd6cc8ef821cd81f305aacc9b97574c13009f6	8	8575	575	908	916	27	4	2023-09-27 13:02:33	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
918	\\x14094b5ec3a11bd628c89c4e7b9d5aa4478f87dad4d3a694148ca4a7e663aa06	8	8576	576	909	917	7	4	2023-09-27 13:02:33.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
919	\\x5cb942d5a598f7484d3565a45c1d0edd01c1a0113e4ba0f6a83ac274eaa580bf	8	8592	592	910	918	27	4	2023-09-27 13:02:36.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
920	\\xb6678bf9939015f25ecaa6a3bb2ed252c621a464fb2a554a8fa1835c58ada6c0	8	8595	595	911	919	9	4	2023-09-27 13:02:37	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
921	\\x662ab5857170f61b0edbd5209205293a92bdba194c0d60bf1ef10d88ac76045f	8	8596	596	912	920	27	4	2023-09-27 13:02:37.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
922	\\xa1474cc7791c6f42abd64927cf7106ba617cb62ecd6cd320c69da78d0769cb66	8	8607	607	913	921	8	4	2023-09-27 13:02:39.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
923	\\xffb5364f68ffd43d4c955c0ae9182d53297e94db5b013842569f2030df2a98fb	8	8610	610	914	922	7	4	2023-09-27 13:02:40	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
924	\\x024cef8e3da66e83416804e3b0f0577f7876d11ab3e7d932bf608c112162c482	8	8614	614	915	923	7	4	2023-09-27 13:02:40.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
925	\\x4d763244d55bb361b6af96974e87b67d21399480786a5e8cb9d7eb35b4b4e2ec	8	8622	622	916	924	27	4	2023-09-27 13:02:42.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
926	\\xfb75fa06b1027a32caf50624322979adfda2238c412e00502cefc966f1cdc225	8	8636	636	917	925	8	4	2023-09-27 13:02:45.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
927	\\x4d9e1e6fdd012010798d18ac9936e6a042e7f0337b36b5e6a4526cd9a521781d	8	8641	641	918	926	12	4	2023-09-27 13:02:46.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
928	\\x4509d3a6da1e5724064cdf723ca0762259fbe372177d97ab22593387b6ad1327	8	8669	669	919	927	8	4	2023-09-27 13:02:51.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
929	\\xf267eb33ab59c167cba77d18100789f2fb71339c642615d550cfe568ac23414a	8	8679	679	920	928	7	4	2023-09-27 13:02:53.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
930	\\xe3263b2c8e808e27826198c6587bf4283bbf4246996e5f71e86709d77047b19b	8	8706	706	921	929	8	4	2023-09-27 13:02:59.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
931	\\xf2eb4fce00cdbc65ae9db8c1b89477fb434eef1ff1025caffe68c80c03570b3f	8	8718	718	922	930	12	4	2023-09-27 13:03:01.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
933	\\x15484c303e289dc3ef7b7eb493b170f0d36d47384c7678649cf04b44206b2a44	8	8722	722	923	931	5	4	2023-09-27 13:03:02.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
934	\\x6941179dfc0a908b55f1bb486afef6c663a1fd7726ddfec57bb90a8675077763	8	8731	731	924	933	3	4	2023-09-27 13:03:04.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
935	\\x01e75a673aa082be8cbf3fd90eeb9c72096e96342fc9d1808cb8019a67ae728c	8	8733	733	925	934	8	4	2023-09-27 13:03:04.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
936	\\x6fd0509ee25cff56b929670f8ddadac35198f9a527796d208d85ce45e1490f5d	8	8735	735	926	935	8	4	2023-09-27 13:03:05	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
937	\\x86f7c48ee1e1b110e0ee7efceec8f45c0007de96a61527b10a876ab33cd23742	8	8744	744	927	936	3	4	2023-09-27 13:03:06.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
938	\\x66dab6c02eee8e3bd5209cfe97fdb207d20083b848fa3b0530502692d67f206d	8	8752	752	928	937	9	4	2023-09-27 13:03:08.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
939	\\x813062b4a4ea9e13cee71c93552388bfa943f3766748eaf6a878c4459b10ce89	8	8756	756	929	938	3	4	2023-09-27 13:03:09.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
940	\\x63136d21e3eb49a3af9cd8eb73bf0bbff72b16e1c0bba26bffa087fb63a6b528	8	8760	760	930	939	7	4	2023-09-27 13:03:10	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
941	\\x24d705ab092d1d230e0be6cdf83fe63f5f8377425a819c1e34f19153ac1db559	8	8772	772	931	940	12	4	2023-09-27 13:03:12.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
942	\\x077f0643b91e1f3f04838bee2f84c1e7ec7b030eb9f25e363a57d47ae723b35a	8	8773	773	932	941	9	4	2023-09-27 13:03:12.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
943	\\xcfb2b7e3cb7aa89957dc995c704c5b1f8901f63acecfaf20f4911257fcc5b46c	8	8780	780	933	942	27	4	2023-09-27 13:03:14	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
944	\\x453122648bd7ed20a516acc981a10a553405f46920abf95814b74dc34fb7c536	8	8799	799	934	943	27	4	2023-09-27 13:03:17.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
945	\\xedcf7233ab1c0ef50bf0cdc3036db0ff9bb312902cf89097c500de895d6740ae	8	8803	803	935	944	9	4	2023-09-27 13:03:18.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
946	\\x77ba9b78dbd1fa2553ee3f170003a8cc406196292eb4809910e4aeab8356bf6f	8	8809	809	936	945	8	4	2023-09-27 13:03:19.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
947	\\x4cc24bc8418c4585fa13c7f701b418158978c824b3c1768340067c7979d21d07	8	8812	812	937	946	4	4	2023-09-27 13:03:20.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
948	\\xa5e64251dcaa2e8b323b1e2be3c42b7e9ce7be88a3a922be854ccfbcd50083ab	8	8818	818	938	947	12	4	2023-09-27 13:03:21.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
949	\\x9bcac0fea98bc7e944f52bebe0acaf0f3b721ecad99201ebcf0c79ab1c563f3a	8	8821	821	939	948	5	4	2023-09-27 13:03:22.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
950	\\xce26effd72f3212d5894af2592b004a3e99a6357cc4ac3e00900d0b3f8b721af	8	8826	826	940	949	27	4	2023-09-27 13:03:23.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
951	\\xa2d17f58619dbe73c3b79f951a4c6a24a7162529c1ffa92e75d020849b931d7a	8	8836	836	941	950	27	4	2023-09-27 13:03:25.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
952	\\x353c83d4cbaf2e6f42cdc0da38968730f0d99a163ebb3fa55d626a8b2e9d431d	8	8844	844	942	951	5	4	2023-09-27 13:03:26.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
953	\\xc840aa850321a3ff0cc042861044fb57503c5e34a9bea4f0a7602558c9d67f23	8	8851	851	943	952	12	4	2023-09-27 13:03:28.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
954	\\x669bc4842a5b806b70a3ae02bbc88c97e70eab6d38f2744a4db4c716e3a2d73f	8	8864	864	944	953	3	4	2023-09-27 13:03:30.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
955	\\x39e4c309ccf636d5993fddbfca446d18bb5d15bf8144924c19acd0542c11c63b	8	8876	876	945	954	9	4	2023-09-27 13:03:33.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
956	\\xd1bbf6c588eb952457cebffccf290f55224b8992263fb34798432fe05c4719c3	8	8894	894	946	955	9	4	2023-09-27 13:03:36.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
957	\\x70124aa08e76b69d24530c56db44af0e9759a25b72bc3ff983c5b9d35fc491a2	8	8904	904	947	956	27	4	2023-09-27 13:03:38.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
958	\\x2a65de6da70bec42949f10749fdcbc79f3a7be14af6ec7b3a2451fa6fbe2b197	8	8918	918	948	957	11	4	2023-09-27 13:03:41.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
959	\\xacb758f05776f4e81b2cf20c8e6edcba96d8ede3078069fda4136859d752e29b	8	8922	922	949	958	4	4	2023-09-27 13:03:42.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
960	\\xf551980a0ff40144936d650c8fc6ad0b9d42d53fc000b571526bdedfeaa0e523	8	8942	942	950	959	12	4	2023-09-27 13:03:46.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
961	\\x882a198140c0c94b41868cca5e2a61402fa8560030c48b214f40966ab1634674	8	8943	943	951	960	12	4	2023-09-27 13:03:46.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
962	\\x8302bc5b64a04803c08fcfc8e22c2ec460c21b94b38a254e4a3e9ec28d4e0e2b	8	8959	959	952	961	4	4	2023-09-27 13:03:49.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
963	\\xd76f12e2f19312c403e9691a1b20449f0fdded53e0937be78221f18c131fb105	8	8964	964	953	962	5	4	2023-09-27 13:03:50.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
964	\\x368576313d7b3e3042a1b21a3c0f00bb5d74b0a6f2305472fa7062994c8fd071	8	8975	975	954	963	11	4	2023-09-27 13:03:53	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
965	\\xc1e372e2a327973ff410813fde388d9ca622e3096eba913beac4967841a5e104	8	8976	976	955	964	4	4	2023-09-27 13:03:53.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
966	\\x7de12e5ef273184d815c76d5920a8bad875235833a9dbdbb0e03954d23054bde	9	9016	16	956	965	27	4	2023-09-27 13:04:01.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
967	\\x3f9571ed3036845955893fe81c479e2c6991eb13637b4e3813b4e1f3cbdcef0b	9	9018	18	957	966	27	437	2023-09-27 13:04:01.6	1	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
968	\\x2988162adda7a7344a261ec10eae90b948fbecde4bdf55126414baecbb3b970d	9	9020	20	958	967	5	4	2023-09-27 13:04:02	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
969	\\x4072ccf4ee61fad41f0f98af7e80d0a7b98f326a99f4639b5dc55cd354d14153	9	9021	21	959	968	3	4	2023-09-27 13:04:02.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
970	\\x6a30a82632c47bdaea40c7ecc90c45e5c451abcc571d9b06e72e233696b41d2c	9	9044	44	960	969	5	4	2023-09-27 13:04:06.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
971	\\xc347e3b3ac085f6aa6d565fcf29154ad7425339977f9212b8a9cf19f0e8e3fb2	9	9048	48	961	970	12	4	2023-09-27 13:04:07.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
972	\\xc0c6c2701358b095d6f856c0f97096f0716162574b13c14b5ebda5d2589ffeb7	9	9066	66	962	971	5	6266	2023-09-27 13:04:11.2	1	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
973	\\x3c5fbaab3ff3c8afab74b84604c334477032b30ad8bf291f9335c42c795150e8	9	9080	80	963	972	7	4	2023-09-27 13:04:14	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
974	\\xcff32fc5d62505ee904951f2c86b1c5a30657385b349ad91d0b25fae181c55f6	9	9083	83	964	973	8	4	2023-09-27 13:04:14.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
975	\\xfa589abbcaf49cbe80b082240a9ad59019892e0b7185375cebea11b4c016e14c	9	9085	85	965	974	27	4	2023-09-27 13:04:15	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
976	\\x66414a2a3ec3df05034eba6f3603b476d4ff8f354faef47554bcb441ceab8694	9	9095	95	966	975	9	4	2023-09-27 13:04:17	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
977	\\x43157d18fcf51c5ea6eea70f166702646e5074988acb6573434eba1351382ae0	9	9132	132	967	976	5	4	2023-09-27 13:04:24.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
978	\\xb93678ac6d0695193735767ee12384a0f3195bd31c9059c8491ed125464a9ba6	9	9133	133	968	977	5	4	2023-09-27 13:04:24.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
979	\\x357f41a692c9c6e2bba6865b6552f44ef9aeb55e16568045a151a91f9f05b5f8	9	9139	139	969	978	9	4	2023-09-27 13:04:25.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
980	\\xa4a4eb53963a33b7eedb2c874404e777a1439a69af99010c9034455ef05f361a	9	9149	149	970	979	4	4	2023-09-27 13:04:27.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
981	\\xa336d10322c0b687ab37faca255fe16ec7a832bc1b8cac1aabb55b1c78f8aa99	9	9151	151	971	980	8	4	2023-09-27 13:04:28.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
982	\\x6e3c474ff27e4547bb7a5829c4cb7f70d820b9a2b336b7f285b97e967417925a	9	9153	153	972	981	12	4	2023-09-27 13:04:28.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
983	\\xe3c9dec8b31af7dedb3c3d0f9e7d9c8c07e9cad91fa309e41928026a3516a699	9	9156	156	973	982	8	4	2023-09-27 13:04:29.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
984	\\x6fbc5acd87ce9b76f1f8c8816b5bdb4ffcc9fe9fa0b6197f7c17147a22c8fb05	9	9182	182	974	983	12	4	2023-09-27 13:04:34.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
985	\\xb2ccb0a87f431217835c61c1bc755d8a8e5bebdb3a65bd88f7b2312314918e8a	9	9188	188	975	984	3	4	2023-09-27 13:04:35.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
986	\\xa35090718c3291efe840364af9ec99e06328a68b52d0cd7ac04d8d64a81bb2bb	9	9191	191	976	985	12	4	2023-09-27 13:04:36.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
987	\\xae6efa7ca6e77d4afe2b7868fa69ee94e810b8b26cb599c4d0bae21f4c05888c	9	9215	215	977	986	12	4	2023-09-27 13:04:41	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
988	\\xfbf99cb3181f0b39a38d29de5e0aca53d64cf053a166fde4f5706fc2f173e8db	9	9219	219	978	987	5	4	2023-09-27 13:04:41.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
990	\\x517210f3f9185d03a168f34af61250fce7feb2d204d702dbd06f3d045893aa59	9	9233	233	979	988	7	4	2023-09-27 13:04:44.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
991	\\x767d5fe8d7c3c3c167fad313ebf2da40d791bade885709de43b80a14886aa74b	9	9266	266	980	990	3	4	2023-09-27 13:04:51.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
992	\\x7aea8c40b483d350f27ec7ffa5bb91374afd5abb8a7200558ce2850532897968	9	9273	273	981	991	7	4	2023-09-27 13:04:52.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
993	\\xb577938f49dcc46fd122694039395489018d43a3d62a8b1f842356b2669f8b63	9	9279	279	982	992	12	4	2023-09-27 13:04:53.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
994	\\x62c29f7119169d05070f5372167039e8d0d743d9c545f38d6d3bd8ddee829824	9	9301	301	983	993	4	4	2023-09-27 13:04:58.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
995	\\xfde42b5602445de1571da355c575e76c9b1f3d99e35a253e4ec4500b1a9c6119	9	9309	309	984	994	8	4	2023-09-27 13:04:59.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
996	\\x478b2005a38ca9c9d37d8b8b95954a574bb9ad57bbcb721435f9dcc806bd40a6	9	9310	310	985	995	27	4	2023-09-27 13:05:00	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
997	\\xf381db7306a8ff58c68379cd981ce155eb991f792977694e1b57146584665de2	9	9311	311	986	996	7	4	2023-09-27 13:05:00.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
998	\\x8d623ed6db489ecfd484528090edd8008739f55a26d3b5c61d945cb30239c34e	9	9319	319	987	997	8	4	2023-09-27 13:05:01.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
999	\\xa400e0b4feff98da0fbefed2e9616a4897385e3c01d5009e1615d4eb5ba0661e	9	9329	329	988	998	9	4	2023-09-27 13:05:03.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1000	\\xed8e48767c4a27c0a09b09ade1c1a2819d37e247cf1a81c45810d058aa20cdb7	9	9342	342	989	999	4	4	2023-09-27 13:05:06.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1001	\\x9562c1df39a9bfaed8b4f5c38120396a77602b30d74f4f3d43135850d1d35b59	9	9346	346	990	1000	5	4	2023-09-27 13:05:07.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1002	\\xff8411f5076b655b2abd724e8509704bf0c789c43cbae4843cd107fc148c5fee	9	9353	353	991	1001	8	4	2023-09-27 13:05:08.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1003	\\xb9faf4c4167725d3bd2becb75ccc6abbe7ec7c2b2c776dc87d92b240488102ac	9	9365	365	992	1002	5	4	2023-09-27 13:05:11	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1004	\\xb67522b341f5db96c0139eac1636ec932d6c0a5f4b1a5042314358d36bd68f41	9	9366	366	993	1003	9	4	2023-09-27 13:05:11.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1005	\\x146164dba2d345dd519f62f21e688f0609d4e53fee3daaedda3fe6563ecae772	9	9373	373	994	1004	8	4	2023-09-27 13:05:12.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1007	\\xae7e50dc66dedf05e7bdf1b6669dc72dcbfed1c9654a2f613d5360646403d11a	9	9376	376	995	1005	27	4	2023-09-27 13:05:13.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1008	\\x37f917293e022df24d83df2ab750aa48b474a15e7a48b5d47983eafcdf87e759	9	9377	377	996	1007	5	4	2023-09-27 13:05:13.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1009	\\xb012b6575b182b1b86ee44ad5db68579eb8e0518c5604efa180aa39d0d501b56	9	9399	399	997	1008	5	4	2023-09-27 13:05:17.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1010	\\xaffeafa7099d51d4403b84258dc5b5d69ce5884964a0c74896a99f72d87e224c	9	9402	402	998	1009	4	4	2023-09-27 13:05:18.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1011	\\x4970dba1ce2db8c182223c72077a009fbe067c5e314575001fa806b15b45d313	9	9405	405	999	1010	11	4	2023-09-27 13:05:19	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1012	\\xb0a3ae91c7a8523d1a57f8f0a24664d1fa38e0b4f252edce208ec2eccb5334d9	9	9419	419	1000	1011	11	4	2023-09-27 13:05:21.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1013	\\xaa542bd294b64967d59abcf86e19473f7a1d272d0b9a0504b4d0af0459c2704c	9	9438	438	1001	1012	11	4	2023-09-27 13:05:25.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1014	\\xe7abf063726221e3934e3ebd2f4627e29f690e1b80894e839b0296bde5512116	9	9439	439	1002	1013	4	4	2023-09-27 13:05:25.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1015	\\x7878f7bf3fcf4fd253ec33541083c7dcaf9f05d2ea905d925346fa868644b685	9	9446	446	1003	1014	12	4	2023-09-27 13:05:27.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1016	\\x4ca9ac41d2b5cb9100825aa5d5a20b2f309fdb00175539a349ac4ae08c92a2f4	9	9448	448	1004	1015	4	4	2023-09-27 13:05:27.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1017	\\xcb041f7b440d9dfb2d63c202f9950afeac58164fd008a1227bffe1cfa90b21dc	9	9458	458	1005	1016	7	4	2023-09-27 13:05:29.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1018	\\x62cb6cb57fbba222b292390e707c66f478bea16f71b55bc504c1a3897a3b6b96	9	9466	466	1006	1017	11	4	2023-09-27 13:05:31.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1019	\\x97195d144de22032cdbd42f60925784051304c71208a28a28027779a9d2727f7	9	9470	470	1007	1018	11	4	2023-09-27 13:05:32	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1020	\\x4cb969ba0e3bc2255d4bad8d445024f1d1b88cfa57c42d11447fda10d2fa668f	9	9483	483	1008	1019	12	4	2023-09-27 13:05:34.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1021	\\x63ad1ac293b29be2606eba493f1bb15df43b62d5561a5949e05cbd15a1916997	9	9489	489	1009	1020	4	4	2023-09-27 13:05:35.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1022	\\x6162d1e03999e3cd342343d0daea3fe91a9ac5bd224e0fa905b1a1422036e09e	9	9490	490	1010	1021	27	4	2023-09-27 13:05:36	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1023	\\xd1f8a6b18021bf93c7c4d876e296f22ed868f524de3fcbac432c1c2ba3204a6e	9	9508	508	1011	1022	27	4	2023-09-27 13:05:39.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1024	\\x3de9680d2dcba7fab7cd0e5cfbf892c2285974fa1df0a9b8f7f597c702fe4eab	9	9509	509	1012	1023	12	4	2023-09-27 13:05:39.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1025	\\x6b1dae2c823336adcf4a3e34c075e14a15c0f1df7802af87fa6083843cf55089	9	9510	510	1013	1024	11	4	2023-09-27 13:05:40	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1026	\\x24e9caf96d6276676e9653b38bbf0603f5710787f0152fae33854198e76cdd32	9	9517	517	1014	1025	27	4	2023-09-27 13:05:41.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1027	\\xd468ef417cce92374d80f29b721ecf664993bc3626619cd1a181835dc0941ee9	9	9523	523	1015	1026	7	4	2023-09-27 13:05:42.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1028	\\xdee9c4c522c3c76e056bedc1c018e57b9c28e6ecf78933b1bca325a9b642dec9	9	9527	527	1016	1027	3	4	2023-09-27 13:05:43.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1029	\\x0abe612a4dcb24857c9b67686f61f6b9588f2cc381389ca28fd841140635fb2f	9	9531	531	1017	1028	8	4	2023-09-27 13:05:44.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1030	\\x3cd0e1e7d4dffe4ff630ad236480b3eaf06085a700d2e71facc6e3eb72b85fe3	9	9535	535	1018	1029	12	4	2023-09-27 13:05:45	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1031	\\x1c5484c6f988886f9651edd5c8e81ab1844f83ac9feafbec9c2b7d3f49fd3390	9	9542	542	1019	1030	8	4	2023-09-27 13:05:46.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1032	\\x6ac33986c298ceca4a3a539720c872b19b8d16b679a9d98023ba41e555a739cb	9	9544	544	1020	1031	4	4	2023-09-27 13:05:46.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1033	\\xc78436d8ee90689aa8f3541968d79004cf6eae8c9918cf2bd2634cc9d65a0204	9	9558	558	1021	1032	8	4	2023-09-27 13:05:49.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1034	\\x96c9782e3e897123f327e0a26e56a84bc3be08fdc027a691956a9b410b5c955d	9	9575	575	1022	1033	8	4	2023-09-27 13:05:53	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1035	\\x25e34cd08a53d876a10241654c8e9c3e4a2e57534351322f27ba8be4f77d2183	9	9584	584	1023	1034	3	4	2023-09-27 13:05:54.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1036	\\x9091138d14e16f51ec5b87d8a53391a0a1ff4c9640d6a001b1f34431c0452a8c	9	9601	601	1024	1035	7	4	2023-09-27 13:05:58.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1037	\\xb8a45ec1abbc41a80fe6cc43978cce51b64e98c41e2b35c5c372e73256095980	9	9620	620	1025	1036	12	4	2023-09-27 13:06:02	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1038	\\x2703b45ed7ec2d8d62b745f548457b00b101c9e8c30cf6c775cbe7eadd11e893	9	9643	643	1026	1037	12	4	2023-09-27 13:06:06.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1039	\\x586b2ae91e94594fa8c8d47827bc2706472cf2253a3be9960fe6b9947216e190	9	9646	646	1027	1038	7	4	2023-09-27 13:06:07.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1040	\\xd78708e374f28558dce63196d7d78ba10983ca4fac566a6abe42aa772c559dff	9	9653	653	1028	1039	4	4	2023-09-27 13:06:08.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1041	\\x68e804f25b4c18f0d6b342092d058ffd7356c5fedc7a640911bf37cc2dd867b7	9	9678	678	1029	1040	8	4	2023-09-27 13:06:13.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1042	\\x31598570071d4cf0eb819fc8432b807bf12717100227942c84d9579c674e1699	9	9688	688	1030	1041	5	4	2023-09-27 13:06:15.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1043	\\x78b81f0da90e50429ece378f58268529dcce9a164d51ba837eb3b445c9b47246	9	9691	691	1031	1042	3	4	2023-09-27 13:06:16.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1044	\\x86548cc7bb1161db698f702d30002b561f0b327ba2058bbccc604cb3e890502f	9	9692	692	1032	1043	8	4	2023-09-27 13:06:16.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1046	\\x728dce424a38a37e1d8678cfdf4fec772a518f819a3e33cecb6638f9c8b95562	9	9710	710	1033	1044	5	4	2023-09-27 13:06:20	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1047	\\xac7664aaab74d2759beee0bc9a01f1cb9e18fca63fd4243978ec8a354556a143	9	9712	712	1034	1046	8	4	2023-09-27 13:06:20.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1048	\\x6a3434827580f9a71cf56f7a7c7d1f57973624a3ba057c474f80cfd1df995e10	9	9713	713	1035	1047	4	4	2023-09-27 13:06:20.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1049	\\x0360b0417d42a158e1198d34497a53b96d72c565bbb2f31408eb3b0e5964b17d	9	9720	720	1036	1048	7	4	2023-09-27 13:06:22	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1050	\\x40f885fadb6ca74b7bcc04eaf5fe0cf061c5fdd79a20ff22a34391e94d69d8b6	9	9740	740	1037	1049	12	4	2023-09-27 13:06:26	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1051	\\xe1363775a0f14387d775de9276b98fb046ac0740147a46b15981ba3cfbf3a0e8	9	9741	741	1038	1050	9	4	2023-09-27 13:06:26.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1053	\\xb2e260fc9afadf3ad52ff3e6305b7d5439f834be7ca67a9f88aa1f94485b746c	9	9744	744	1039	1051	7	4	2023-09-27 13:06:26.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1054	\\xe78b32a996eb867eca2e11d11c2c568cf68f4dcdb2023bca77a74e09ea1beac5	9	9754	754	1040	1053	12	4	2023-09-27 13:06:28.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1055	\\xa4e5f42c24ac77474bfcf8681e49c82cf8b88d4327daaf48c99109c6c45747a6	9	9755	755	1041	1054	7	4	2023-09-27 13:06:29	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1056	\\x1bb3a90c9d366e4304713b74b1b585fdabb2d45f6f8e9f971b3a4e361c0e9e41	9	9793	793	1042	1055	11	4	2023-09-27 13:06:36.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1057	\\x1e46097a813936be1ae3a4e2b4bd75f1e4d28f303aef80dc5947e5c1ab4b83fa	9	9802	802	1043	1056	27	4	2023-09-27 13:06:38.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1058	\\xa0884f0a81b1f64ffbc9f121bf199a69e6a73ea03661ee05868d0ccd00a6806a	9	9803	803	1044	1057	7	4	2023-09-27 13:06:38.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1059	\\xc6c8842bf8a161d5d32e7acd99426bcab161855e4b568c7cfe5d7c57c6156af4	9	9813	813	1045	1058	8	4	2023-09-27 13:06:40.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1060	\\xb0e4af6d2c53f1449438982cf24584f932d701552fdbf92d733a9fcfbd928f16	9	9815	815	1046	1059	7	4	2023-09-27 13:06:41	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1061	\\x1095fc5e49c1b5ce4993b4a3e4931a9ebd3c3c9cd7b880148abfb1d0b3b13b5f	9	9816	816	1047	1060	11	4	2023-09-27 13:06:41.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1062	\\xdde376cf47ba00b9e5acd707ec9953603c21a05c71b0313cab0e375abb6972f2	9	9828	828	1048	1061	3	4	2023-09-27 13:06:43.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1063	\\x843fda1b821724915885e461b91ce03546ae21f9c0c1a64b1e974c11c6f44548	9	9836	836	1049	1062	9	4	2023-09-27 13:06:45.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1064	\\x645a959770ae779c7853bcbcb1e7f2ddab478120c7b13ce7f61c39421cbb5084	9	9838	838	1050	1063	7	4	2023-09-27 13:06:45.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1065	\\x9ec810c180d39fe02310b2393f287707336c9b4eb2b7b389da68a42b9dfa5d8c	9	9840	840	1051	1064	4	4	2023-09-27 13:06:46	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1066	\\x1d321fa335d71457aa5764bd9c25b3d4170c53ad87c9e390b18c2c3e9f238589	9	9845	845	1052	1065	9	4	2023-09-27 13:06:47	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1067	\\xf8678396ac1fa96d6fd5c2942cd161e1ebe95b3d9fface3f1e035b166e69d095	9	9848	848	1053	1066	8	4	2023-09-27 13:06:47.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1068	\\xc6b771b8045436e79be49e8aad7a44cb6dcc55348b8bd5b373f9d53efd9e019b	9	9849	849	1054	1067	5	4	2023-09-27 13:06:47.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1069	\\xf662af5aeb0e0992e125a0239764bc3c851c962617014bab624b40287f1d6474	9	9861	861	1055	1068	11	4	2023-09-27 13:06:50.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1070	\\x96d6ae633167fc31056c0a0034aadb26f49e6f7b0da3448eec87e43f4b38cfaa	9	9876	876	1056	1069	8	4	2023-09-27 13:06:53.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1071	\\x32d8002a924fe6dd85bce9a3a27af575932d83ed7d90c41a14643fa3006c1fd5	9	9878	878	1057	1070	3	4	2023-09-27 13:06:53.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1072	\\x5e9495028708d9b41657743f7f30503c0ecb49e59f610fcac25a2ac5a95ee59b	9	9881	881	1058	1071	5	4	2023-09-27 13:06:54.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1073	\\xa66269c53b646254f0ecfaf071e23ed1458fefec1858b11c1778877e527abdc4	9	9883	883	1059	1072	12	4	2023-09-27 13:06:54.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1074	\\x852ff68b10f9d78ee67e3321cc26cf5c5f438b99773ba0e97d893d95aef62cca	9	9923	923	1060	1073	7	4	2023-09-27 13:07:02.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1075	\\x42b6f97bd378cc1b0d5f15ffbe35e34d0679360f5365b3ca47b12f55595e88d4	9	9949	949	1061	1074	12	4	2023-09-27 13:07:07.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1076	\\xda623f0af182d978f729c8f2298abfcd9be66eeac4ec398df252ecbf2e823ef7	9	9950	950	1062	1075	4	4	2023-09-27 13:07:08	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1077	\\x1cf0c1ca9d1e67b187db469341dfac6ddc7cb5b17c679047187a43d698788b30	9	9955	955	1063	1076	9	4	2023-09-27 13:07:09	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1078	\\x568082310d047597b59ba061de7c30a52738e006ee4a85bbc915bc918642051c	9	9958	958	1064	1077	5	4	2023-09-27 13:07:09.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1079	\\x12ab2f57ee093b38c796c0a8d343c8a57ba0ec2c0f03ace0749a396a20c5fa83	9	9961	961	1065	1078	8	4	2023-09-27 13:07:10.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1080	\\xdab166d006d082d291020ccab13a25d1e36a44fb46a50fece83b1f3a0b3fd458	9	9965	965	1066	1079	5	4	2023-09-27 13:07:11	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1081	\\x87799c9a41aa934da2509c248f6cb5cb3127ccde59b29e0386263831327a061c	9	9973	973	1067	1080	27	4	2023-09-27 13:07:12.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1082	\\x4f604f8def3a5c55bc7f04420984df6177b182f0bbae0b2273cc78090a5c3e8c	9	9977	977	1068	1081	5	4	2023-09-27 13:07:13.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1083	\\xb0da35f46ae92cc7ab1f82635a34b7bcdb9ac148189e6697f5d331f3c860e41a	9	9979	979	1069	1082	12	4	2023-09-27 13:07:13.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1084	\\x79769d6c1122b395ca6b27e6dbdb55a58afba58d3033db9d7e7f3a9b0aee8c9c	9	9994	994	1070	1083	12	4	2023-09-27 13:07:16.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1085	\\x14207641f12440165b8c564637654eb2419ead93fe0ad031a79911b942d420c2	9	9995	995	1071	1084	12	4	2023-09-27 13:07:17	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1086	\\xe073c2b834954c1d7825fb7ba66041924fdf5c90bc030aef6035db5e143bd0ff	10	10003	3	1072	1085	8	4	2023-09-27 13:07:18.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1087	\\x1cc63135761f58a3bde04d82d92f2ca32dc0b4bb001d3aabecfd31fff69fa8a2	10	10022	22	1073	1086	3	4	2023-09-27 13:07:22.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1088	\\xf153e75de7f395e83304d5243f0c6738da302039137c289b1ca3d13c502aa1be	10	10026	26	1074	1087	12	4	2023-09-27 13:07:23.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1089	\\xbf9cf10bd32a7e47e879152f5280dce4a508febed0c80d69bac3fb278de06626	10	10036	36	1075	1088	5	4	2023-09-27 13:07:25.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1090	\\x27d104376cde522a6277c072b943a55f4433111fe80fe6a6c67c36e20d186a07	10	10042	42	1076	1089	3	4	2023-09-27 13:07:26.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1091	\\x40a14ed419ab10a06863921bc7569a2d27a7130ffbbdbee9ca891581122d96cb	10	10068	68	1077	1090	8	4	2023-09-27 13:07:31.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1092	\\x5cdca768472c45b6b7230414c4ee339b6276480d39716c7f3162bb221bdbd78e	10	10071	71	1078	1091	9	4	2023-09-27 13:07:32.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1093	\\xbe677777a1ffb49332c71f0af823864e711ae9a95cab3f2ccc6714e0ccba1574	10	10082	82	1079	1092	27	4	2023-09-27 13:07:34.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1094	\\xb9182521f6a7e30ccb223c50c47730eed7f8be3065aabe35cd807df91621eafb	10	10084	84	1080	1093	8	4	2023-09-27 13:07:34.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1095	\\xd3506bf89eff6e04e0f16afb13a8869e2b6a6425e8530527fa08c6608c758f1f	10	10101	101	1081	1094	7	4	2023-09-27 13:07:38.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1096	\\xa70cbea2c598a59ee208ef4df9e1ddca12644b66d12a431a3aedc1ed20a12330	10	10105	105	1082	1095	9	4	2023-09-27 13:07:39	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1097	\\x61c98f109df554b788dfdcc6ebf2e91f7de4096d2f294c457a1f883437042f3d	10	10120	120	1083	1096	4	4	2023-09-27 13:07:42	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1098	\\x93834f3f92291d962d9d555fb5907c682dfd620958b063f23b02654f349f7a6a	10	10126	126	1084	1097	9	4	2023-09-27 13:07:43.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1099	\\xa7b3387b705b557b0329130abb670b6f5f483a7b23234d0159659d7f23757a9b	10	10144	144	1085	1098	8	4	2023-09-27 13:07:46.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1100	\\x3caab229175885284cc330dee5dc27f1bd7f4c6cf86ec2cbcf0ebe8e1a1c37c0	10	10151	151	1086	1099	4	4	2023-09-27 13:07:48.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1101	\\x43af4c67a497f627056965cb75615acbdee68a25a3d20e1533ee5da4ac978e96	10	10159	159	1087	1100	7	4	2023-09-27 13:07:49.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1102	\\x500dfb464f9272f1202bb413face5ff7552d2ac98415eda70652421d32942a46	10	10165	165	1088	1101	9	4	2023-09-27 13:07:51	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1103	\\x2b104fee239f01c3705e4d9f4e7d025e75b98233f76268ec0ae5ea83a0a8fa80	10	10192	192	1089	1102	4	4	2023-09-27 13:07:56.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1104	\\x4b8b3d209b66dade1e729cdb305569631e26ac95e4579757a94b20c06e0626f2	10	10204	204	1090	1103	11	4	2023-09-27 13:07:58.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1105	\\x2e5bfe65aeefeae62535c1334e5b1596045678610d67ce83c60b97c1c8144fb1	10	10208	208	1091	1104	3	4	2023-09-27 13:07:59.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1106	\\x9122b83cccb9ee2284b9d17b51c855a44eae2a61cde24434d6030ffea28ff939	10	10210	210	1092	1105	9	4	2023-09-27 13:08:00	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1107	\\x2ab10a288a96520aa0bda36210aadbb67c69f5607d9062eae7e0778864b3dee9	10	10213	213	1093	1106	9	4	2023-09-27 13:08:00.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1108	\\x7d4c3106603ca5d5447a9273ac5d684fc1427ce78ea2c1c03ddeb4de3aaed1fa	10	10214	214	1094	1107	5	4	2023-09-27 13:08:00.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1109	\\x2a9b925e0a326fd807f8eda112cdebd8bdb733f0eddc1d27e6a7cad4a1719e2d	10	10237	237	1095	1108	3	4	2023-09-27 13:08:05.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1110	\\xbf5b883cb660b4d19fe40e25e28384cede868625fe377f374519c25e83181fb5	10	10238	238	1096	1109	7	4	2023-09-27 13:08:05.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1111	\\x921d7b94ab4a38aa2926d63fec646d4338740358b7b6997d6114e701e3a93ae6	10	10239	239	1097	1110	27	4	2023-09-27 13:08:05.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1112	\\x605a055d95489b9dc4555a366b654916ebdfe4ad2679ec26273ac9e6abc9a745	10	10252	252	1098	1111	9	4	2023-09-27 13:08:08.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1113	\\xa24e65ee9c42115677cdbec22f0b6825e9fca4f1d2eeb94665f70478fa9c0220	10	10275	275	1099	1112	4	4	2023-09-27 13:08:13	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1114	\\x24579f11f6cef6cf21c33d1fac18565f8829d16354f5d22ffa1dab6a01936647	10	10322	322	1100	1113	12	4	2023-09-27 13:08:22.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1115	\\xe3c1a193c1337e521e2a63e774c86c6c531383b3381888a8869b1f062a20c062	10	10344	344	1101	1114	5	4	2023-09-27 13:08:26.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1116	\\x7a27dbe69e7ef4de1cefeeac663485f0c60b3ea0f919f7fb8dbd16a4d6f56d0a	10	10389	389	1102	1115	9	4	2023-09-27 13:08:35.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1117	\\x95380d7f2cee32fea88af208aed8d961f38230958623f3a9babcb5564d6dfa40	10	10398	398	1103	1116	7	4	2023-09-27 13:08:37.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1118	\\x319bc98aad042c5aa38fdaed3909d6e27f0986dd81040324163b149ea142032e	10	10406	406	1104	1117	7	4	2023-09-27 13:08:39.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1119	\\x4a58840532635b4c504ec3696d1ee3b4c0f5bb927e3668d3fd555472cb23b4c0	10	10414	414	1105	1118	3	4	2023-09-27 13:08:40.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1120	\\xd64a58854f3cd191c6cffaa11461a69a601d6d4b064989a6ef6e4841eeadf4f8	10	10422	422	1106	1119	9	4	2023-09-27 13:08:42.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1121	\\x1972adafc67566bcdeefbab70aea31ab19e0180c20c87ab1c2bcad780f1bf313	10	10424	424	1107	1120	3	4	2023-09-27 13:08:42.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1122	\\xeeb312eb0dd2817889033f21c3b4e88ab04f24397a9968e91c98e4250f85b971	10	10455	455	1108	1121	27	4	2023-09-27 13:08:49	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1123	\\x4c3d42af0d0c0613005ca66adb29f39f0085fac1c74b92148fbe3e8298a1ed60	10	10469	469	1109	1122	12	4	2023-09-27 13:08:51.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1124	\\xe4318f718a78a4fb9d34cd2ce18ef57dd358d21c1941c4d0566b8d2307c2e1c4	10	10476	476	1110	1123	5	4	2023-09-27 13:08:53.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1125	\\x0eeed89fba6bd5b3ecdcc4c4222b6beac34e127ff7424240ce8d0c69e63ef7e9	10	10479	479	1111	1124	7	4	2023-09-27 13:08:53.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1126	\\xeff6b097836008a6cd7d9d92f6206321ac450bf6f2fe4b5da8cc95aaa4c43fbf	10	10480	480	1112	1125	5	4	2023-09-27 13:08:54	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1127	\\x688b5e79bb57be137b2b45ec9bf9fd0bfd323071e6c3e7417b0510c0fba8d993	10	10485	485	1113	1126	9	4	2023-09-27 13:08:55	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1128	\\xf0f3e9ad9f3a7bbf82283c702535efd2bd0f7d03d0aabc69b27cb3caf9c2dd91	10	10503	503	1114	1127	9	4	2023-09-27 13:08:58.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1129	\\x7a26a0782c8b1d2794c5d3e1311f48bf0a6b80be465ba4b630b9253ad6c749d0	10	10505	505	1115	1128	7	4	2023-09-27 13:08:59	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1130	\\xb11356575d735d5ac75744d67b6d3daac73b6b1493deed58300ab9c02252b075	10	10517	517	1116	1129	4	4	2023-09-27 13:09:01.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1131	\\x20ac9fb10e0347f194ec4b1b05851afcafff06f855713e014b3ccd87881661a8	10	10525	525	1117	1130	9	4	2023-09-27 13:09:03	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1132	\\xdb9ea8ea79816ac65b5f45e1497d53bada01c518d5298d663f9e5f5b493e3cc0	10	10540	540	1118	1131	9	4	2023-09-27 13:09:06	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1133	\\xf9e6f06c3bff8999e1cf3e52396608841fb346095f3f5565269431a58749d7c9	10	10543	543	1119	1132	12	4	2023-09-27 13:09:06.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1134	\\xe5d1c1b9fa4fc94e0c0728e37f022539dc38af4eb7100507c93ed45e55604c76	10	10560	560	1120	1133	3	4	2023-09-27 13:09:10	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1135	\\x8d8b496439394a6ccf3f927aaa1c9fb01bc13b62b2f6c682b295e3bfe856957c	10	10573	573	1121	1134	9	4	2023-09-27 13:09:12.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1136	\\xa9158932ec1074af8e335adeaacb650b637361bc6c9e6086f73e1f0f6686a8f5	10	10575	575	1122	1135	11	4	2023-09-27 13:09:13	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1137	\\xb9979065c4c700dbb5206586151e2406962add36538294cc491c3361607d5dcb	10	10587	587	1123	1136	27	4	2023-09-27 13:09:15.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1138	\\xfb9dfd678c8013ff9ae65ece04cbc992abfb96d363ebc499fdd622a428ba7f30	10	10601	601	1124	1137	4	4	2023-09-27 13:09:18.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1139	\\x61b5d0f6b585ff8450d4fce94822091bf6b84199ce13557b6a584ac79b934d15	10	10607	607	1125	1138	9	4	2023-09-27 13:09:19.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1140	\\xc367bba57f5de14970b08b9a51f6c1f4dfbb2f452e3fcc216637916c39dd0570	10	10653	653	1126	1139	4	4	2023-09-27 13:09:28.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1141	\\x8d5b02d4d49921a015af2eb09da16cb054e657c7e98ee8d5c993d5611ce87a4d	10	10657	657	1127	1140	3	4	2023-09-27 13:09:29.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1142	\\x2f039278b4eaf112b74466c62cf73918316547c3ce96b7ca2b260c026e297432	10	10681	681	1128	1141	3	4	2023-09-27 13:09:34.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1143	\\x57e64a2ebb6be1d7c66aaeacefc0c78051fd1fffcda4d62d24f4f88669574ddd	10	10703	703	1129	1142	8	4	2023-09-27 13:09:38.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1144	\\x1bce8cdca5b1c33823b4036a40046760b46a84c0ead40422fae749610f634f9c	10	10730	730	1130	1143	9	4	2023-09-27 13:09:44	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1145	\\x4047fa107c2a164c75c24373e4b0fc0d70cb3d5ad969e8e005217068498b5330	10	10731	731	1131	1144	27	4	2023-09-27 13:09:44.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1146	\\x98110eb36c5f956e476d8e5c6e88946dab47c43d439787462c58a3c4efa3b81f	10	10737	737	1132	1145	27	4	2023-09-27 13:09:45.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1147	\\xdc2680b11386013f985253bfd5d891f5b6d4986ec05ec8facef78aa673ccaba6	10	10749	749	1133	1146	11	4	2023-09-27 13:09:47.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1148	\\x7693d7c0e65d98534cd55394195286151067c8452b7823b42361b0956211a958	10	10757	757	1134	1147	27	4	2023-09-27 13:09:49.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1149	\\x86383caabbc9e288315dbcc328401e845ac585ac1d9ba4be61d5ee75c2940494	10	10765	765	1135	1148	11	4	2023-09-27 13:09:51	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1150	\\xd79bdf13150ad8b4c27f5c08ac9e55791e9cbb5f24ba9df6b91bfe0d08c7bb99	10	10767	767	1136	1149	4	4	2023-09-27 13:09:51.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1152	\\x657b53acc37b0faa30c71480b36df3d728ddb6783644337a9beb77a5e69a4a72	10	10785	785	1137	1150	8	4	2023-09-27 13:09:55	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1153	\\xed385ad61e74f08bd2e36a19a4dcdefd458a90c9edb9a50560fc97157ccfdafd	10	10789	789	1138	1152	27	4	2023-09-27 13:09:55.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1154	\\xf0b7e6fbb26837ad25a18afb7e09e41223a8d71b5ba0d1b6ea80bdb9beb79142	10	10817	817	1139	1153	4	4	2023-09-27 13:10:01.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1155	\\x4afe0bc0672de3ceb0d591bd8912efa5444b5d55c622a326d03280c31276a9ff	10	10820	820	1140	1154	9	4	2023-09-27 13:10:02	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1156	\\x5626f01d95bd9ff885c5d4786ed03d331c446c219678bd86940d066153c68bc4	10	10821	821	1141	1155	27	4	2023-09-27 13:10:02.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1157	\\x1ea257b5654521f63d29441e267b0a0b742ddc6dc7af203c85506346d1b6abbc	10	10836	836	1142	1156	27	4	2023-09-27 13:10:05.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1159	\\x21138a892715783b73e229ffd7071280b392c94729b16cface7185d1d1eaac63	10	10848	848	1143	1157	7	4	2023-09-27 13:10:07.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1160	\\x76d33e034fb0c7065a6aeedb482f5bdf71f572a3cbd22765b6ba212d1536e963	10	10864	864	1144	1159	8	4	2023-09-27 13:10:10.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1162	\\xb0d54c401056c337302926f3d8497fafc53ce10bf2ae37e6a8b364a983a4d27d	10	10898	898	1145	1160	11	4	2023-09-27 13:10:17.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1163	\\x14f845b5f0b5758bc7c5abfbaa89d3a9ec18fabb494831e2327c3c8e05aae6c5	10	10905	905	1146	1162	5	4	2023-09-27 13:10:19	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1164	\\x41b4b497867d1086c315f13035d0cdc52000140589a9ca09d13b88bdfd9748b6	10	10926	926	1147	1163	7	4	2023-09-27 13:10:23.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1165	\\xa482c2cee605f25c7b9d6afaed3dcd0b2aa044b20994a8bddd8fd2e1a680c301	10	10929	929	1148	1164	11	4	2023-09-27 13:10:23.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1166	\\xe74848b8fadcdc736a9ec300f5783b74e6afc36e0ff8c8341011fb04db295a8c	10	10933	933	1149	1165	3	4	2023-09-27 13:10:24.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1167	\\xdb307a1949c99ec2f699125548a628eaf93e6f3f1ca1a0d5b8ef74229675d4e8	10	10944	944	1150	1166	8	4	2023-09-27 13:10:26.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1168	\\x302b896dbd2f52f0b99a4fb11ad3b536091c2728174e3da1d6029221c288ccf7	10	10945	945	1151	1167	9	4	2023-09-27 13:10:27	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1169	\\xa8a06b74a3824ac52a9b44debc80cd0501ffd829258975c471c1a0c4d58efae4	10	10950	950	1152	1168	4	4	2023-09-27 13:10:28	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1170	\\x1c331d75608f80ed4d54aedad36546bb291e24e3ff4e969a465091281d8f3412	10	10962	962	1153	1169	5	4	2023-09-27 13:10:30.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1171	\\x19e7277e16c2fbe4680f389d602ef70c36c1976ae4be9b500de1a7cf00771490	10	10964	964	1154	1170	4	4	2023-09-27 13:10:30.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1172	\\x38a2e850eb5fdf58e9400f7df85b8330a1c3ea1120d85ecd1aa0704a6b054121	10	10973	973	1155	1171	27	4	2023-09-27 13:10:32.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1173	\\x13faffa3138f451c54dc7382c5f8e0cfe9c7103797cc679b46b98aed3fa47494	10	10981	981	1156	1172	12	4	2023-09-27 13:10:34.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1174	\\xeff4963eb7c7636712f380e79ad1c4604e830df8a989b7e0143741640486d7cf	10	10998	998	1157	1173	5	4	2023-09-27 13:10:37.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1175	\\x2d5fd06e1a90cc8a3a428062fcf34ef2018607e1efc285352b9826454ff5c094	11	11011	11	1158	1174	27	4	2023-09-27 13:10:40.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1176	\\xd1e7d728221847adf3ec082d2ac32aaee3b64cf44ef2388051a850b67f2c7445	11	11013	13	1159	1175	12	4	2023-09-27 13:10:40.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1177	\\xf07c0ebd10009e4abbaa9361a9d53678c36e0c3872d5dec2e2c2085b5d878f07	11	11015	15	1160	1176	5	4	2023-09-27 13:10:41	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1178	\\xa71506f848f2b437d93476ec6051d9de096e630b8b9111db8acf681b55b1933b	11	11019	19	1161	1177	27	6416	2023-09-27 13:10:41.8	21	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1179	\\x87669a80d6bb82db056422b93a44e9969e962cc973c06e7c7c257b777221fb74	11	11022	22	1162	1178	11	6116	2023-09-27 13:10:42.4	20	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1180	\\x31564ed57a49c4146b93da856b6e88cd7c54a8c79113e367c58d30f937a9fba4	11	11033	33	1163	1179	5	18325	2023-09-27 13:10:44.6	59	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1181	\\xeb730c0f7ada03a9ecdf3e1eebb1e63ea7e7e9efd4180a5009e4fcc5cd7c0477	11	11038	38	1164	1180	3	4	2023-09-27 13:10:45.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1182	\\x134f7d635eecfabe703b7297e2aafe9b78bc3e60d977999349a6bf22eae5fa5d	11	11040	40	1165	1181	8	4	2023-09-27 13:10:46	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1183	\\xfd503f28b96210c702b486350f1409964321e70beca3dde6fd8ffc77632a4cee	11	11048	48	1166	1182	27	4	2023-09-27 13:10:47.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1185	\\x195463bc4546c9c7185701c8a059b3fb273c8fb7e54b2fd944f0ff425a78be3b	11	11052	52	1167	1183	4	4	2023-09-27 13:10:48.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1186	\\x69460c423714cc5ee0a5790d200803f3f2e222b7a35c3d7a623575c691f3710a	11	11074	74	1168	1185	27	4	2023-09-27 13:10:52.8	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1187	\\xa59e3693ab3a6334fe94d961c4a968bb6b642d810af7e68e8b68773f5e64f5e7	11	11075	75	1169	1186	8	4	2023-09-27 13:10:53	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1188	\\xc1263fb6625607eabdc454d37981c77f049f282ad728ed4e2f1ae10c438efec2	11	11076	76	1170	1187	11	4	2023-09-27 13:10:53.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1189	\\x612e4f2a853d94124e07482b0803fc89635d1bf6391524432516c3e1109997e6	11	11088	88	1171	1188	7	4	2023-09-27 13:10:55.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1190	\\xc311d575deb0242ce58c6283caf61c9776cd2aabb83bc933c834e0961a0f4f1a	11	11110	110	1172	1189	27	4	2023-09-27 13:11:00	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1191	\\x38319bbfad4e1b51e1cc1cd934a6391b210adf60d6ea66210c87ad2a01b35361	11	11164	164	1173	1190	12	4	2023-09-27 13:11:10.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1192	\\xe0930e123af1fee8f2458930322e610529d28eb9e55d27da9e0b2fa1cf610c11	11	11165	165	1174	1191	8	4	2023-09-27 13:11:11	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1193	\\xe570da2708184114b1e4764f7db32955c2693043a0a009234f4e74fc04b6f8de	11	11166	166	1175	1192	5	4	2023-09-27 13:11:11.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1194	\\xe2806dd2196452c2d80b14df7b3b81c2cf163b63dd47c289b15427a06c385c66	11	11168	168	1176	1193	11	4	2023-09-27 13:11:11.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1195	\\xdee1279ef7bdfa394a143591f2aa994ae9180e1b56e54b3784eb772e1ec173e0	11	11173	173	1177	1194	8	4	2023-09-27 13:11:12.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1196	\\xbbad5c3c85a57eb42c54b6842dd5af09715abe483b823a5c53ef2d23c43f3e23	11	11182	182	1178	1195	27	4	2023-09-27 13:11:14.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1197	\\x317e8390e44ac1b4964367322993bfbeae9029b7d8302c9543b0808c0c124bf0	11	11196	196	1179	1196	27	4	2023-09-27 13:11:17.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1198	\\x0b32e6d6258942bf02a294ca38372f357e64413f3d01109cb12cd81c2e32ba0d	11	11198	198	1180	1197	3	4	2023-09-27 13:11:17.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1199	\\x47f84ed8abdd1bcb020af9d8ea0b7f9450cd9eb632b60fff1c1511064dc7817c	11	11233	233	1181	1198	7	4	2023-09-27 13:11:24.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1200	\\xfcc1dc8aff930a28f63185bf6f40b770f46f64fbfef650c40c6717ddacd14176	11	11263	263	1182	1199	8	4	2023-09-27 13:11:30.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1201	\\x8968f7522f27d256599f85500d57ab079c18bd22f6ac82753057f3435ba61fe1	11	11274	274	1183	1200	9	4	2023-09-27 13:11:32.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1202	\\x7a6f16804db10cb96fce29a18c7a57664e45398942eb3b223177c39e14f4fc3d	11	11291	291	1184	1201	9	4	2023-09-27 13:11:36.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1203	\\xee140597ab5083ad2fd6ec0aa9d4b2f177ca96c7086d23f937a273229c00db07	11	11294	294	1185	1202	5	4	2023-09-27 13:11:36.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1204	\\x63a14dd14673f7211c37289970182e106b58155760dafe8937881bd1a20a76ce	11	11304	304	1186	1203	7	4	2023-09-27 13:11:38.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1205	\\x1d43057ed2feeeae62b180f035cce4c804f8c16d8851d0ca722e2a10722f9fbd	11	11305	305	1187	1204	12	4	2023-09-27 13:11:39	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1206	\\x910b9cab6440cf30e9f64ff65aaf38501f7784d94eb99e8e0a55339f670c617c	11	11323	323	1188	1205	4	4	2023-09-27 13:11:42.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1207	\\x08eb6cc860172360639597e9dc5225bf5f5d0e869d2995d5756066b55bc52aff	11	11325	325	1189	1206	27	4	2023-09-27 13:11:43	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1208	\\xa25d5f9b2045272b398f3938e0459a05a65d4d6ae83cdd3d75eeb16efc1c28b1	11	11340	340	1190	1207	8	4	2023-09-27 13:11:46	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1209	\\xdf890ab2e8f66e1f273ab8870919d693bd5de04bc4db53e5ee947790164e1d02	11	11344	344	1191	1208	8	4	2023-09-27 13:11:46.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1210	\\x2a23f0d14ad2a6b5248571820d554f49d490c4390e9d06fb6c547e52c058d439	11	11358	358	1192	1209	5	4	2023-09-27 13:11:49.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1211	\\x5ab987626077c6ebfa53fc9c19426cf916d59162a4529e891ee78e7c94a99727	11	11365	365	1193	1210	9	4	2023-09-27 13:11:51	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1212	\\xc42575f44e0013bd37489fd270eb3c9dabf440a475954b867546ffeea9f58330	11	11366	366	1194	1211	12	4	2023-09-27 13:11:51.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1213	\\x3c6325ece211441c7066f699b78d3da06c15924447ba9e9aca84b7b6503eb667	11	11369	369	1195	1212	11	4	2023-09-27 13:11:51.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1215	\\x94f9fb1df292609c24c0882b08a9402bdb69f1fb4349b4e03214378e177daa70	11	11394	394	1196	1213	8	4	2023-09-27 13:11:56.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1216	\\xf19f8fa2634cd3f19d2e54ed9af8301a3e2dd0346d89c03ff494503134058ea9	11	11403	403	1197	1215	12	4	2023-09-27 13:11:58.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1217	\\x9d5364a369a1d4e7a97e48102f9fb5681e6da54e5322db577ce701b4c5da501d	11	11406	406	1198	1216	3	4	2023-09-27 13:11:59.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1218	\\x96950f9a782615e6b4c5493a8448a29dc1e25e9e50efd6b1103ed9117b8d78a0	11	11408	408	1199	1217	8	4	2023-09-27 13:11:59.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1219	\\x656dbd6e7a1c4befb5b61d6ded0dd9644a92360caef9aa06daa476378c2f9769	11	11421	421	1200	1218	7	4	2023-09-27 13:12:02.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1220	\\xe537a075bd9a7c4a986cd3b647271c123dc2da08f44d3197f27a1d0f69bbd7d7	11	11423	423	1201	1219	7	4	2023-09-27 13:12:02.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1221	\\x90eaaca446934a09daefaf89ed0d78cf401fd78f9e5a5a878fa94564db63f545	11	11433	433	1202	1220	4	4	2023-09-27 13:12:04.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1222	\\xc31c52f66d812861d26a11f7e3cfee68fcad140f0c89e3edba517eb99016e92a	11	11476	476	1203	1221	27	4	2023-09-27 13:12:13.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1223	\\x66ba113ec0cf848c6c43b6df50733bb40fbee31ace4504f4ec76559360f68177	11	11500	500	1204	1222	3	4	2023-09-27 13:12:18	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1224	\\x543112d1dc6c86f64cc2dca7a63e8e14fc846aea516de5270484d637a46827c3	11	11504	504	1205	1223	11	4	2023-09-27 13:12:18.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1225	\\x3fb36207e3873b894bf04a534f27867eb21a1c95da58aee7331557475fcd5d0b	11	11509	509	1206	1224	3	4	2023-09-27 13:12:19.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1226	\\x97aeffe39479fc9366e9f3b24938c151a2c9c716362c5ce3315288168e2a00bb	11	11524	524	1207	1225	4	4	2023-09-27 13:12:22.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1227	\\x8640024d3ff6230a0225672946eef1813b1705eae3ffc3ecbce2efac2f585e9c	11	11537	537	1208	1226	27	4	2023-09-27 13:12:25.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1228	\\x3eddf6bb6c5a34412d48b0272652eea2f192119ef640b81d26c66cfb00da6f29	11	11549	549	1209	1227	4	4	2023-09-27 13:12:27.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1229	\\x00ad1b4d1e24206f07aee41b91f4d4adeef7bae4f9bab5ff8f95d8425339d624	11	11552	552	1210	1228	27	4	2023-09-27 13:12:28.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1230	\\xf4f46bb32f758838998418e66d4ac2b5e43a189cca3c97ac973a6ba567b1d069	11	11553	553	1211	1229	7	4	2023-09-27 13:12:28.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1231	\\x1f8de6e4b93a4d730686c4525c3f6c498cb6c190f23ee9f8c78cb4b34d1289ff	11	11561	561	1212	1230	3	4	2023-09-27 13:12:30.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1232	\\x958ba91ce9e245dc3f1f12c08d8619477eceed7d78161bbe49dace3eb0831220	11	11563	563	1213	1231	9	4	2023-09-27 13:12:30.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1233	\\x0da3143d85097a10b3ca1b99f4563568a3087459b0f52796aab6dbd66d07660d	11	11571	571	1214	1232	3	4	2023-09-27 13:12:32.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1234	\\x0017f946cf51a1eb255221dc92fe22986f54c9c333292ffe35b184544a3b79cb	11	11576	576	1215	1233	12	4	2023-09-27 13:12:33.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1235	\\xc4b8068af57ac76c19e041a1f84862731cd016df6c6c5a538d27d4f6b943df32	11	11583	583	1216	1234	5	4	2023-09-27 13:12:34.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1236	\\x02539babb0a37136d21344442aca1abd4a36beb3c8c55706f594bfa6b47ae7ef	11	11585	585	1217	1235	3	4	2023-09-27 13:12:35	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1237	\\x31876561e65abb04d1b73fe216da75da8bd38e735c031a736c88a795290862ff	11	11591	591	1218	1236	8	4	2023-09-27 13:12:36.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1238	\\xc65f449c423f185a72d29f48171e9022480d35c1c3179ea667d24b45e643a286	11	11593	593	1219	1237	5	4	2023-09-27 13:12:36.6	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1239	\\x21fb775a93410ff15637a74facf32800622a23fda040a987f26c4a60448ae916	11	11597	597	1220	1238	7	4	2023-09-27 13:12:37.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1240	\\x67c387e7380d27b26cdee6d5eededa9c810a05da19e88a6ed0ee83159fce051d	11	11599	599	1221	1239	8	4	2023-09-27 13:12:37.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1241	\\x5b392bd72b1afc10eca5bdbc8eebc15f9181430adfd12a67bf8a0b38be28cff6	11	11614	614	1222	1240	3	4	2023-09-27 13:12:40.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1242	\\xe0a0f82bb2b15531ee226d7f45a563414f91aa561e7c3039c641c6d9224b5bd1	11	11628	628	1223	1241	3	4	2023-09-27 13:12:43.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1243	\\xed1e0f753f5f864346d52bcdd91950696a9681dac51beb627ef68eae67f57ff6	11	11634	634	1224	1242	9	4	2023-09-27 13:12:44.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1244	\\xc4e3ddfafa400454c319b93d8cd5b66eb65d35d4d555d20f3779b868d7c09509	11	11637	637	1225	1243	4	4	2023-09-27 13:12:45.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1245	\\xa5d36ae76a00f4f0862e231b7ed6b84fa427fa67d9ef00b0b031809e9eb42825	11	11645	645	1226	1244	5	4	2023-09-27 13:12:47	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1246	\\x66f45d039aa692c7b51f6d7fa65f7900c8f0a99575e875414289ea90a59e060d	11	11649	649	1227	1245	11	4	2023-09-27 13:12:47.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1247	\\x428dbfebb030800dff55dad04b6532838bb067fdadbe3e8a5bdb7b6c81329c46	11	11651	651	1228	1246	3	4	2023-09-27 13:12:48.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1248	\\x6426688b141bf087ea890d9efa2198c7b790e482470f17c9aadde6a46db6d5cc	11	11664	664	1229	1247	5	4	2023-09-27 13:12:50.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1249	\\x4bcbff3389828b09c8eb5f3f042462e042fe1f5a643aa85ddfc81add27f64442	11	11666	666	1230	1248	4	4	2023-09-27 13:12:51.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1250	\\x9306c9e2961119dc492abceb43b0a46c8b42f00e458943eb8207c737030f708e	11	11672	672	1231	1249	12	4	2023-09-27 13:12:52.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1252	\\x27ca7cc91d870b6457f7e1f624f58e9cdf965d954c46e8af33be878ff4bf17c1	11	11673	673	1232	1250	27	4	2023-09-27 13:12:52.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1253	\\x6cf3399a6bdaefa911af2c70b7183bb7f3806024a4a90d129753786e5e67857a	11	11682	682	1233	1252	4	4	2023-09-27 13:12:54.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1254	\\xb7335714fce8b3a94096e58b048c5ac358edce72b23cf072ce944ea808152536	11	11692	692	1234	1253	12	4	2023-09-27 13:12:56.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1255	\\xe72012fae1e840207099ab6c2ecc310457c382cb153d01a84a970c52c3bd1d76	11	11701	701	1235	1254	8	4	2023-09-27 13:12:58.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1256	\\xa9deae29c105d3e11375e4b1290afa8229e10e59d341036e5bab36eae74b4d79	11	11707	707	1236	1255	3	4	2023-09-27 13:12:59.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1257	\\x37e3df02b1a49eb4bc67d5dfe0e7459e46858c69f8ea27a563ecedf543064473	11	11710	710	1237	1256	4	4	2023-09-27 13:13:00	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1258	\\x576c3149c3644a5999cd733ae609a40778d3d2dce28d0722e02288c44efe319f	11	11713	713	1238	1257	4	4	2023-09-27 13:13:00.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1259	\\x08165aee026de44da967ae860111cac1f9877a218e8d70c97dda179d1250cf9d	11	11717	717	1239	1258	7	4	2023-09-27 13:13:01.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1260	\\x154be2a4afd5cb9a0ca62e88c45345fc9ad95903a02f9e68052dc72804b1488f	11	11720	720	1240	1259	9	4	2023-09-27 13:13:02	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1261	\\xecee8a7625e767fc437af7f66f793e3c798105bcec89e4f5b6182df947aaa5bb	11	11727	727	1241	1260	3	4	2023-09-27 13:13:03.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1262	\\x9782f73b8b9e621568b4d17b597a9128d21753dfa4c191086b90e8787144037e	11	11734	734	1242	1261	5	4	2023-09-27 13:13:04.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1263	\\x3bc72c4d2c7e0cb044c7caf7fff7bdf08b9e28ee4b25b154e0bc153f5571454a	11	11743	743	1243	1262	11	4	2023-09-27 13:13:06.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1264	\\x44bb107c70f1ce06f344660395773052f77291741640776276223bf2345bbc8c	11	11754	754	1244	1263	7	4	2023-09-27 13:13:08.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1265	\\x0e25c3c2ee887f97c535acab95da397c3bc69610598dd26cd6c8a368060e517e	11	11756	756	1245	1264	8	4	2023-09-27 13:13:09.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1266	\\xbae55c62d83d4011a2ed14f6487a78ba720fb37f1208f393ae9a26c619363ba6	11	11778	778	1246	1265	27	4	2023-09-27 13:13:13.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1267	\\x6abdeac769d975c730557602ec79cbb03da93db777a0a7d466d8c49059aa12a1	11	11787	787	1247	1266	3	4	2023-09-27 13:13:15.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1268	\\xa4bbf0b25b86016906987e791dc5554aedda0322ba2c849fcd694863e7edcef6	11	11807	807	1248	1267	4	4	2023-09-27 13:13:19.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1269	\\x0c93f9e95903c026f88cc34707b924f12c225bd5acbe9333af71476b26714b21	11	11813	813	1249	1268	7	4	2023-09-27 13:13:20.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1270	\\x9e63570d96132b8a3117f2c67c78f2067d06a9aaa9cebcc97b74948795e56099	11	11815	815	1250	1269	9	4	2023-09-27 13:13:21	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1271	\\x669687a79a4a678618dc8840cd97b4094ff50a909bdaaa5dcba21cfa73e98819	11	11817	817	1251	1270	8	4	2023-09-27 13:13:21.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1272	\\x3c2e6b619554109d5a384d20e10b168aa8347d13b0ba19dda3f479bb830a69f3	11	11822	822	1252	1271	12	4	2023-09-27 13:13:22.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1273	\\x5a4ebd17714db2b9d6637f2bb18b3c3576e32f760f18c76552d14628442bf8c5	11	11825	825	1253	1272	12	4	2023-09-27 13:13:23	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1274	\\xc0c08925d4c678c974edc5e17ef5968552c1fb7d2dc04d2add7fa77a2465ac34	11	11830	830	1254	1273	9	4	2023-09-27 13:13:24	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1275	\\x2d64bc46b69b99b907d6aa6987f3274355e512623c18d4470f5f8541aed97b0d	11	11831	831	1255	1274	5	4	2023-09-27 13:13:24.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1276	\\x627d0c493e7ea90af4347ead5ed0aef94243c1ca72a111ac6c0daa466c3e92cd	11	11840	840	1256	1275	7	4	2023-09-27 13:13:26	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1277	\\xb803f35a80ae728049756a3417621f4ee6f64e83316c10bd8108c53f9d7db6bd	11	11873	873	1257	1276	11	4	2023-09-27 13:13:32.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1278	\\x6623e8a0624a22e0806a3964c20cd1a148dd8565902180ca7790ed8823ce6ea2	11	11882	882	1258	1277	12	4	2023-09-27 13:13:34.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1279	\\xc1e0a482b3d90e9733508dbc7b59214836badd9f4617ea1f91bbbe2a970a5e2e	11	11890	890	1259	1278	5	4	2023-09-27 13:13:36	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1280	\\x2f3e7d450e1adce3e90c6c315e4859882dbf7505108f56aa5dc38ebfda7de2ac	11	11896	896	1260	1279	11	4	2023-09-27 13:13:37.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1281	\\xdf93495f4d64763be2d732ce29c6b7307119ba46ab4e4881c4acb2cb8822fbb5	11	11910	910	1261	1280	12	4	2023-09-27 13:13:40	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1282	\\xc79d7a993740ae523482056484039ce1069e6d9ed0201977da47a4c581494596	11	11914	914	1262	1281	5	4	2023-09-27 13:13:40.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1283	\\x99f81c0c8afa6b98a78343fcd6f430166f6455c5d67c0a06d78c4e2a8f2d85a7	11	11918	918	1263	1282	12	4	2023-09-27 13:13:41.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1284	\\x870aebb703de4302b9b6dc382297678fec3636d77747c6dcfc74b9183bfe27d8	11	11924	924	1264	1283	9	4	2023-09-27 13:13:42.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1285	\\xa57180a2f9f7dd899225a1e8adb31c7ed1724f0f8a2fef41bd457d36bff93019	11	11929	929	1265	1284	9	4	2023-09-27 13:13:43.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1286	\\xd6aabfefa1bdc1734d7879fb234205bd40aa3d506dde08736de841e4f289815e	11	11936	936	1266	1285	7	4	2023-09-27 13:13:45.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1287	\\x42a66ab45911e6ef111a82a24b5db0b655cc238a73448a1a93d1f0e508c14be5	11	11945	945	1267	1286	27	4	2023-09-27 13:13:47	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1288	\\x06cb78123ad3bc216788489f691a3ab8b7a5f5c936b2f4b558f4df5b2647d35b	11	11946	946	1268	1287	8	4	2023-09-27 13:13:47.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1289	\\xb80d1316d5bca66e48c51131a20a978445bbc57184bb43919f382275f7f56974	11	11971	971	1269	1288	9	4	2023-09-27 13:13:52.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1290	\\x42ed05a06d44216724cfe3e98adb0f70fb76fe3b1e0acc8094151ac3c4e1b2ce	11	11976	976	1270	1289	5	4	2023-09-27 13:13:53.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1291	\\xf042183c4a5b653775f55562294e4e561ae3d4a9a2164cc0d31cbd6ac9eabc39	11	11978	978	1271	1290	9	4	2023-09-27 13:13:53.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1292	\\xcbb2edc4d46ffca83a531a5e56fc8c06b22494dde8e2470135b3eb3e96f0df51	11	11980	980	1272	1291	8	4	2023-09-27 13:13:54	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1293	\\x9ff89c3f5bb9fa5f6a1be087c6ee6da5ddbd0d354a29c136359a18b01520b3c7	11	11991	991	1273	1292	12	4	2023-09-27 13:13:56.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1294	\\xc35bc78032c38d7574fb78977107a50aa47ed348cc47f040876e7c401fd1d6cf	12	12000	0	1274	1293	3	4	2023-09-27 13:13:58	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1295	\\xbe31f8e68a5d7b004f452c13a062b133145bd8f3b0a46e178214da052e879476	12	12012	12	1275	1294	4	4	2023-09-27 13:14:00.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1296	\\x74872edd3dc8edace5a8ffcdddc52fc811a43c1b4ec46a8f9a3271263b37ae17	12	12018	18	1276	1295	11	4	2023-09-27 13:14:01.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1297	\\x64cffad647c568a988b10a3a4b05a5b2a24abcf0d6a62dd8fc2d0ea772321c51	12	12030	30	1277	1296	3	4	2023-09-27 13:14:04	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1298	\\x25975dc41686e31430d8d9805d2ad844006ad6b6c32922182a4210c10ae380e3	12	12037	37	1278	1297	7	4	2023-09-27 13:14:05.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1299	\\xa952cd1abb31496b9818718a17bb062cb1c59318add255b293e8ded81013a8b5	12	12042	42	1279	1298	27	4	2023-09-27 13:14:06.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1300	\\xffb3360905589b81d70b9ab48bc0d6fd3be73d6aad0d84b960e0c8bb490d55da	12	12045	45	1280	1299	4	4	2023-09-27 13:14:07	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1301	\\x6d45a81447a60551070051add0a0bfa118ce651508c4f1986205c25f39f47a54	12	12064	64	1281	1300	8	4	2023-09-27 13:14:10.8	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1302	\\xc02c11c1c09ba5fb30d0942ba8b43e96e9840953768b61ad125725f7b6d1462e	12	12068	68	1282	1301	27	4	2023-09-27 13:14:11.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1303	\\x3344c6929ac42e3beb917a65001604a2cc99ba17c1da662df834848483dda825	12	12071	71	1283	1302	3	4	2023-09-27 13:14:12.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1304	\\xac2a2d58736ff3cceda31165ca46e7eb339961829a0b9c275d6a6f5926e8a949	12	12080	80	1284	1303	3	4	2023-09-27 13:14:14	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1305	\\x1b3e463a30ab32ef4eaf7628794fded335a52303404dc709483cb46c30927485	12	12085	85	1285	1304	4	4	2023-09-27 13:14:15	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1306	\\xd7dc28602c8613c8254914cc887284866983c3aff77900f368ebaba9ec0bee18	12	12093	93	1286	1305	9	4	2023-09-27 13:14:16.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1307	\\xcf84e4ab89a5c04f7abb5822adf062d16256557ea94cb82ad45a5f2595708d3b	12	12099	99	1287	1306	5	4	2023-09-27 13:14:17.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1308	\\x46268e2bdb4651d71971eb48131b9558aceafd4d9a09bec3cbd60dc77778402a	12	12115	115	1288	1307	12	4	2023-09-27 13:14:21	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1309	\\x44857fe658611fd2ae867c82b189c66fe3609e3ab00ee57a3b707918f081d621	12	12137	137	1289	1308	5	4	2023-09-27 13:14:25.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1310	\\x48c01a0ae6eb10f3146a8f27e24a35224beaab757c33a2df546a737e61d975c3	12	12142	142	1290	1309	5	4	2023-09-27 13:14:26.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1312	\\x0d5701e4b3382c6f2556121b6fa28c75dcf12d0ff92fc68b31daa335aaf02347	12	12156	156	1291	1310	7	4	2023-09-27 13:14:29.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1313	\\x5e123b3bb94c8e42ac130b752e1701c6ef1898b932b961b11f8a2ca79c88f762	12	12201	201	1292	1312	11	4	2023-09-27 13:14:38.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1314	\\x8635758001172ef5a6b809b66e1fd9ac435c74d84636e46ddcd80e8b5ac74a95	12	12202	202	1293	1313	7	4	2023-09-27 13:14:38.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1315	\\x6450550b0842818187858e2743bf4cbc622fe2f89698509538c051f8f830d414	12	12204	204	1294	1314	12	4	2023-09-27 13:14:38.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1316	\\xc87aed2457509432e0001bb0f44323f6ff183536d828e41df28f78dc126a2d4e	12	12209	209	1295	1315	4	4	2023-09-27 13:14:39.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1317	\\x525bf351bbc2eb7dd4f8d5f9b84b7a2f089deb2a05b1bc91b14a86b32238e82b	12	12212	212	1296	1316	7	4	2023-09-27 13:14:40.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1318	\\x0cff671fd6ce937b721ad0dd4688825e62fadb20efab02bbb1a5507a2781f834	12	12216	216	1297	1317	7	4	2023-09-27 13:14:41.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1319	\\x159da45b506521426fa93e9a2aeb30504400daa510ce6aff74dad07d692a9f27	12	12233	233	1298	1318	8	4	2023-09-27 13:14:44.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1320	\\xea5f7a9ccd778258dce9c060b577c43779e5b20cb50fc1cec2d05542e0342420	12	12242	242	1299	1319	9	4	2023-09-27 13:14:46.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1321	\\x9ea6356ebcb8484cbd47eb5f404583b913b36599ff571345a0b48bb732ae2543	12	12251	251	1300	1320	9	4	2023-09-27 13:14:48.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1323	\\x3e6998bd93eba73eb5e026a7b07ed2ea836def9904982a93ad9cc4f5b26a2fbf	12	12256	256	1301	1321	11	4	2023-09-27 13:14:49.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1325	\\xfc3d1ee431c352de22b8e4598c05917bedfd303b1fe62bffbb6db51a478921ab	12	12262	262	1302	1323	27	4	2023-09-27 13:14:50.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1326	\\x459e44b31a12c641fca94a46e0c3c17c244cb260eb6390ed8604f39669926744	12	12267	267	1303	1325	7	4	2023-09-27 13:14:51.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1327	\\x687b6f50a3eb4e2d87123efd3bdf9fd1f3e10f32434b4824db34ad54c9fc91ed	12	12269	269	1304	1326	4	4	2023-09-27 13:14:51.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1328	\\x6e779234ea56fad64ad18e334d727e94fea303851048221a4c5f79e55c85ca05	12	12270	270	1305	1327	12	4	2023-09-27 13:14:52	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1329	\\x64ed9f6b07358cccc2c63f207aa425cac1b2356fc7ee8a3e27d28b7c88b74ff1	12	12283	283	1306	1328	11	4	2023-09-27 13:14:54.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1330	\\x6dca41b4c481046ca1cf871b8914e0c153e8a391c0b4500ec19adb877b5949dc	12	12301	301	1307	1329	4	4	2023-09-27 13:14:58.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1331	\\xc7a31c7e16c608a2ca8269fb62d063fb1cd17d87f493595d8894906c7022977f	12	12311	311	1308	1330	7	4	2023-09-27 13:15:00.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1332	\\x7d72e8943eee768111e8f63ce8eed2ed1d489f40d4df409705e1d461b6bbdc23	12	12313	313	1309	1331	3	4	2023-09-27 13:15:00.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1333	\\xb524617fb906907a9845bb3374577136017715647186fccfd93708962ca03325	12	12317	317	1310	1332	7	4	2023-09-27 13:15:01.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1334	\\x8045da973d491eeaac57dd183fe2f11f422c1beebc26d05e1820fb484d25c715	12	12323	323	1311	1333	4	4	2023-09-27 13:15:02.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1335	\\x478c06e961d83dcaf14e75b6061a69f6734aaca506d1f913ecac14d80514e382	12	12352	352	1312	1334	8	4	2023-09-27 13:15:08.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1336	\\xcdf8781f1ce15f93205b696f9a26b5c3aef824d43269c9559fb59b79e77f0523	12	12370	370	1313	1335	8	4	2023-09-27 13:15:12	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1337	\\x829bb665201bca965b31f4efb183a4affc7b58c057dd71c2b6fdd05ab81278e2	12	12371	371	1314	1336	12	4	2023-09-27 13:15:12.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1338	\\x9b14b0af54e0a0e6b517979699c3532a47b4c0f128c1778ac50f88f38bab27e7	12	12376	376	1315	1337	8	4	2023-09-27 13:15:13.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1339	\\x29e5b93b6e6502598d671c614e015cd6526121630266b9d88566949cc3f2ac55	12	12377	377	1316	1338	7	4	2023-09-27 13:15:13.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1340	\\xe302213e37c6480ec3585960f57373faa4c5e8d7331c145bece4373f4ffe54d0	12	12382	382	1317	1339	7	4	2023-09-27 13:15:14.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1341	\\xa54b1f9597eace686f3fb04d65fc273f77fbb25bca01784e758a34e3fdf84a0e	12	12393	393	1318	1340	3	4	2023-09-27 13:15:16.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1342	\\x6592f2d7263296785627422dfb4ec9d915f4535ec36f1156ca2ef5aebd025c1a	12	12406	406	1319	1341	9	4	2023-09-27 13:15:19.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1343	\\xca399096cfa0ef6ebd84f72107b96edf4ed671ac99de79c4434c0d5454770fff	12	12412	412	1320	1342	9	4	2023-09-27 13:15:20.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1344	\\x7a85418eac9afc6e16f5b70e440dae9c1b503191cea215f80987c641355389d5	12	12416	416	1321	1343	3	4	2023-09-27 13:15:21.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1345	\\xfef441745676fd6d419208417fa020e40f0ff64191045a435aca64054aabc76f	12	12437	437	1322	1344	12	4	2023-09-27 13:15:25.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1346	\\x3d03f412a44ad787539606289ae8e4afb98ab2b53f3af86553261b5f7ff12567	12	12442	442	1323	1345	8	4	2023-09-27 13:15:26.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1347	\\x2573e22ca08c00333efeabd5c8a121ec946e9f864cadfae402c385e05f104e92	12	12444	444	1324	1346	4	4	2023-09-27 13:15:26.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1348	\\x2234d72b3a4910ca08423a9403afb924805a46b2358f5bd5f6f91c07b4d9563c	12	12446	446	1325	1347	8	4	2023-09-27 13:15:27.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1349	\\x69e10768643d4b2a5570adc6eb49191858b3de38cfa5674f76bb1a76c9ffeb3c	12	12454	454	1326	1348	9	4	2023-09-27 13:15:28.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1350	\\x5824b16485421a6b923b58dac0d293bb0ac77465ec69cd7fe5ca6f0b2608a7b7	12	12462	462	1327	1349	27	4	2023-09-27 13:15:30.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1351	\\x65a519e130f344569197eb707e159f67f2b439860f1698f5a5a08149db438bd3	12	12489	489	1328	1350	11	4	2023-09-27 13:15:35.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1352	\\x8f5ce2ccc2df80cd794813b8cbd46bb08e5dec3c3815396f90b5f3a476480c40	12	12504	504	1329	1351	9	4	2023-09-27 13:15:38.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1353	\\x58840fa18ce1286a84deff8e91add37a531ec455c0e8a994655481d4c52e9004	12	12506	506	1330	1352	7	4	2023-09-27 13:15:39.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1354	\\xe06f5e8f6a277469a1553ead1af4fb58e5c22517e7b191b49478788ec3e56426	12	12508	508	1331	1353	3	4	2023-09-27 13:15:39.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1355	\\x06dec000c3d3cf0e18004a11bcd44afd1c5f6e3cbf8bd61c43c9da8f87aa7fe6	12	12518	518	1332	1354	27	4	2023-09-27 13:15:41.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1356	\\x2bb1dc2983df082e4eb8dd609ab5d36cb736e3387d848852dc63eafec4a38690	12	12520	520	1333	1355	4	4	2023-09-27 13:15:42	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1357	\\x321e27c2b16d87ed0fe7a6cafd1ec7f23c275f52d39fc51ae9a90ed6596fe28b	12	12528	528	1334	1356	12	4	2023-09-27 13:15:43.6	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1358	\\xc67be3d04f6b27d36e6386e91f6072a5032e27921a70ee23a7810a7d35b52d85	12	12540	540	1335	1357	3	4	2023-09-27 13:15:46	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1359	\\x0008e578608cf8408d478bf3c2c762d7dbabd00b9395f8c17090a6206ae81b04	12	12557	557	1336	1358	7	4	2023-09-27 13:15:49.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1360	\\xcfa625f1a1ae9f4c1cebc141396768530937c08f0ab7b0b705fa7bba11f59355	12	12562	562	1337	1359	12	4	2023-09-27 13:15:50.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1361	\\x823396e89fc598be855c76e33dd433b9772db59a560166b59c6174ecd7868f0b	12	12568	568	1338	1360	4	4	2023-09-27 13:15:51.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1362	\\xe2327c7c43686c8d34ac540da15c4d98da53d8a8854b2addc937548641f4a1bd	12	12569	569	1339	1361	3	4	2023-09-27 13:15:51.8	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1363	\\xa4e8d9e3baf18c7ac8b26ca1e97ff6c301755534d66b07cde63b91da31c6c1ca	12	12571	571	1340	1362	3	4	2023-09-27 13:15:52.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1364	\\x770f9f5a91f010e1487688cf26bb9a20eb97181e56e1e61c5b644839ef6dc32d	12	12582	582	1341	1363	4	4	2023-09-27 13:15:54.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1365	\\x700def3b76bfcd9fccb8abbb93174aabfdb158b32e3fd7f6cc7de510747c0ff8	12	12591	591	1342	1364	4	4	2023-09-27 13:15:56.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1366	\\x4e5f8379d3160a171c48aa360360c41552865588b573e519ef8aca463e298173	12	12592	592	1343	1365	11	4	2023-09-27 13:15:56.4	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1367	\\xf1877951458bc470d04c963acd3a8151ef183c54080b6fd69906adaea076f400	12	12598	598	1344	1366	4	4	2023-09-27 13:15:57.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1368	\\x06279c09d21f3df68fda139a6f35854287ef4262c851bbbdc36bd546840290bb	12	12630	630	1345	1367	12	4	2023-09-27 13:16:04	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1369	\\x6ef1633e266dced2d9e718c42e9a8d155072e3ddbe98e8fce5639d8dc69c75f9	12	12637	637	1346	1368	3	4	2023-09-27 13:16:05.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1370	\\x9baa22c0c964ec150830a83747b6b3df3f5f70099f131fce6eed1e7b271d2426	12	12650	650	1347	1369	9	4	2023-09-27 13:16:08	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1371	\\xfd1422b30184692b0b720b875ea173dc09d1574c394ff6946402412d531e4002	12	12662	662	1348	1370	7	4	2023-09-27 13:16:10.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1372	\\xbeb16c80e1e4746e9c76b69fea1443232bbe2a4f62911fa7875a3cb354a989e2	12	12673	673	1349	1371	8	4	2023-09-27 13:16:12.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1373	\\xf4b5f4cfe46339414d17a7ca2cbd29666cae19e98f580e10c8ba59cb792ae801	12	12686	686	1350	1372	5	4	2023-09-27 13:16:15.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1374	\\x83f5b3a0ed498d6c816364444f0ebe2ebd4938aa5818cc196e75ff47e46727e3	12	12689	689	1351	1373	5	4	2023-09-27 13:16:15.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1375	\\xacd54b86a7eff1d42f8cee31d708355f76b6590e7d4ad507c78fdfa82c357690	12	12695	695	1352	1374	3	4	2023-09-27 13:16:17	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1376	\\x751be5453df9f83753b389da3509672e016c763cfadc0fdf270859829bbf9a8e	12	12699	699	1353	1375	7	4	2023-09-27 13:16:17.8	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1377	\\xba716d6ad537f0f7ad9d6f99b85137b5b62011462d631ce48afa5c91dda9ee2c	12	12714	714	1354	1376	5	4	2023-09-27 13:16:20.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1378	\\xc2137d1275f0bfca49855c6db448f71b85b2d0d839286b6099f5216c53097b9b	12	12718	718	1355	1377	4	4	2023-09-27 13:16:21.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1379	\\xf75b8b1bc933eea019276e5ee2b304faf3f1ea21fd91a2f00c2d5c5eb55a07d4	12	12720	720	1356	1378	3	4	2023-09-27 13:16:22	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1380	\\x405289f8212a5e279c93a59adfe943a4b62891f8daaaea0615f3fe0ccad85208	12	12723	723	1357	1379	4	4	2023-09-27 13:16:22.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1381	\\x15a6a534d132f784d813f5dca0fda560763ce605cb4c8f251e50fe0b6604d2e2	12	12724	724	1358	1380	4	4	2023-09-27 13:16:22.8	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1382	\\x956f7c614c8cf3ec3530351ca98581e84b4bbc10dc3a544ae99d574e65a1e590	12	12725	725	1359	1381	8	4	2023-09-27 13:16:23	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1383	\\xba2fa67eb901292831ba1fcb61d38f90ac2409953737e53ffc56a4aaef7ff171	12	12727	727	1360	1382	5	4	2023-09-27 13:16:23.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1384	\\x518fd128728d167fe36a4263c6b54b8ea537a6ecae404883d38d8296b6466da6	12	12740	740	1361	1383	3	4	2023-09-27 13:16:26	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1385	\\x2a1f179cff87e61685a9b309ad116fb60d50f6f091708225094eff77bfc8c9d0	12	12741	741	1362	1384	9	4	2023-09-27 13:16:26.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1386	\\x1ac8cdc2b95429eb559a1fcd30b54bbf778c273d0631f97ca45b4f7062713013	12	12747	747	1363	1385	27	4	2023-09-27 13:16:27.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1387	\\x3ea95c8a417f5197cb3e2a52fe69034fd88468c634142df7c6e6e7d7ed1a211e	12	12749	749	1364	1386	12	4	2023-09-27 13:16:27.8	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1388	\\xeed30d54da6fd5dbb3c3721bcfd8e1df2847926ab7c9487f6f29dfb604db9e4b	12	12750	750	1365	1387	7	4	2023-09-27 13:16:28	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1389	\\x80153f53df33bf95f995269000107491a19ff72cfeef7e88bdffe788fb1ff6c0	12	12758	758	1366	1388	3	4	2023-09-27 13:16:29.6	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1390	\\x95bd8149f7e8e481fe0d5e0e8706d8543ad98cfe74ca1b4ee507c0a778cfc96c	12	12776	776	1367	1389	9	4	2023-09-27 13:16:33.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1391	\\x93c1852f61b6a32dc7412f373233b480cc481ec15ec2cd3f4fbeab4e71d8d666	12	12782	782	1368	1390	5	4	2023-09-27 13:16:34.4	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1392	\\x200f05589e5b0d3a2ebe9403bdb88dbe80380daa690094d95a70add30cfb18d0	12	12783	783	1369	1391	4	4	2023-09-27 13:16:34.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1393	\\xfdc92ea1f492e1bc449352e63d5d70d4925930069046648da97fd4780df6d2d7	12	12796	796	1370	1392	9	4	2023-09-27 13:16:37.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1394	\\xc6b90100c475530c6c208bf89d882c19c7b6f32333f025b0f655f5cbf3f5ad0e	12	12806	806	1371	1393	9	4	2023-09-27 13:16:39.2	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1395	\\xc3f28ddc0c81d9041692b7df1b524a795902637f6aa2db4835e42e10cce823bf	12	12810	810	1372	1394	27	4	2023-09-27 13:16:40	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1396	\\x09fb43082e729b5dd026f38e5d39f534ffa7fbcd5404606c2502bd619d6f5a1a	12	12814	814	1373	1395	9	4	2023-09-27 13:16:40.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1398	\\x130dcffdf5e82f9f106cdfabe1f26f05e24e0a4a42d18bab6d4e6a0df82d9024	12	12828	828	1374	1396	4	4	2023-09-27 13:16:43.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1399	\\x8aff02e73e967ea845efb0a568e20ac2557f874ed824909f5ef35c159e8715bf	12	12833	833	1375	1398	4	4	2023-09-27 13:16:44.6	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1400	\\xbc3e3874665c899df8a790e166453db46cce938e81a1ebde4ad3d9e333c0f116	12	12849	849	1376	1399	9	4	2023-09-27 13:16:47.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1401	\\x99423b9955a422bcc3edc90fccddc6a72048884536bc43327a513af7333d1076	12	12859	859	1377	1400	5	4	2023-09-27 13:16:49.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1402	\\xbac507bd8618918c21f034c1251b9b09cabfb2276ed1d031e97c6b2d3ef58f3f	12	12878	878	1378	1401	7	4	2023-09-27 13:16:53.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1403	\\x4de5f815734d63bc52c0b27fa162fc36fe3fbf1aad18cadddea98185676e0bc3	12	12886	886	1379	1402	3	4	2023-09-27 13:16:55.2	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1404	\\x46635bb7981ea727744101544d4b2593090dc9cb6a04a1189881783c5f591bed	12	12892	892	1380	1403	12	4	2023-09-27 13:16:56.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1405	\\x0813889a7a0b759c8fc5530b7267d784e98c9a45fe9883b977b96d909fe9703d	12	12897	897	1381	1404	12	4	2023-09-27 13:16:57.4	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1406	\\xc209a1963c14469a745ad3ff145ad266535a80299aa1ccda256f26bf42f96490	12	12908	908	1382	1405	9	4	2023-09-27 13:16:59.6	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1407	\\xa47f6ecc65d72390242df51ca9223b95eebba878ba2e3d1eb984f8221ae69aec	12	12943	943	1383	1406	8	4	2023-09-27 13:17:06.6	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1408	\\x4adbff8627601286eacc48ed828826606d6fe4a80f9695a6f461b05befa3cf76	12	12947	947	1384	1407	27	4	2023-09-27 13:17:07.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1409	\\xa8eb383c098084d501150d609c027d9a574ede2715350af141d642b955e2f86e	12	12958	958	1385	1408	27	4	2023-09-27 13:17:09.6	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1410	\\x8593d4bbbaeb173703688d98ff42726f428ac6043cc1fe29add4b34f60d4361f	12	12972	972	1386	1409	4	4	2023-09-27 13:17:12.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1411	\\xcb1300369bc2340cab5d35e03c571c59e0e570ba936dfd024baa77182bb7ec32	12	12974	974	1387	1410	9	4	2023-09-27 13:17:12.8	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1412	\\xc5ab943d13deff9a82fd0099bfb00abe02769e1b3594bda97f9a61b852689148	12	12978	978	1388	1411	11	4	2023-09-27 13:17:13.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1413	\\x6517f8923e0d91d47e4ce80edbbf7f1e570d2c09b056d84c0ef257d41bcac4fe	13	13001	1	1389	1412	27	4	2023-09-27 13:17:18.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1414	\\xc180f823c49cf0f7874def059e3d18091c3d77411a1854868ce8c72bdeb8089f	13	13004	4	1390	1413	5	573	2023-09-27 13:17:18.8	1	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1415	\\x9f6ebf0ca3e98f30e6f697211c8f487fd26cad94c016a82e88bbd8420ecac872	13	13007	7	1391	1414	8	4	2023-09-27 13:17:19.4	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1416	\\x677f5965524253b382058e61102b9e2bdef29e82a738d4881e671171b9a00336	13	13010	10	1392	1415	7	4	2023-09-27 13:17:20	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1417	\\x801dfc41f9f4981410e46154c4ca857428b7f0d1fcfc8a15dd90cdfc60a590af	13	13012	12	1393	1416	7	4	2023-09-27 13:17:20.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1418	\\xbd3ec79ca24f5740d7618acc37ff62fa420b1a9c5776ccdd7aa2ce548261fadf	13	13038	38	1394	1417	9	1740	2023-09-27 13:17:25.6	1	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1419	\\x31044c3be96c0f8004b00b984721b88e471175eb91b5a913c8c29117ecd2ecbe	13	13050	50	1395	1418	27	4	2023-09-27 13:17:28	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1420	\\x897dd2201700e216b94e078f698ab5d49683f8f1233eb1f626b354c265dde962	13	13053	53	1396	1419	7	4	2023-09-27 13:17:28.6	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1421	\\x3eb2194135f22e024845f0ac6b910943a88434d9540097739f6bcded32406664	13	13094	94	1397	1420	11	4	2023-09-27 13:17:36.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1422	\\xe057ef19cd89038f46123b72590da56a0752fa4972d008a16215ace39d1ad022	13	13095	95	1398	1421	12	4	2023-09-27 13:17:37	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1423	\\xff2ac76c5d7a20f6c5b7cccaeac9520ea2195e7bd541b15361d8283c7f13225d	13	13097	97	1399	1422	11	4	2023-09-27 13:17:37.4	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1424	\\x9c95905e595169fa701ee764c7a6046e6edb9fb62dd07c70ad758ca591aea242	13	13112	112	1400	1423	3	4	2023-09-27 13:17:40.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1425	\\xdafe507d671ce73f35fd1186685ab4b3bc5160c46c72784d8161195073ac68e1	13	13116	116	1401	1424	5	4	2023-09-27 13:17:41.2	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1426	\\x9bae91f826190011296431b2713f9748ae219ad0f90f50d83c6f646b8799b5af	13	13127	127	1402	1425	7	4	2023-09-27 13:17:43.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1427	\\x883a7eccfe23f0a7933ca6975500d04d305d1f11f30e2204e95a57c9bb157243	13	13135	135	1403	1426	4	554	2023-09-27 13:17:45	1	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1428	\\x16565095909f2c9c960abfdd4ab334590f2e3a11bd81aa34f7cfd6f94ab13229	13	13156	156	1404	1427	11	4	2023-09-27 13:17:49.2	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1429	\\xb1084172a8b713a8c14e37f5e4dd4d90d433436806eb60bbd1873829aab5d759	13	13165	165	1405	1428	8	4	2023-09-27 13:17:51	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1430	\\xde4d3dde82b7e2bfd83ee6ac1cc94a30407f134f29e26fb5295e3a6e02dc6238	13	13180	180	1406	1429	4	4	2023-09-27 13:17:54	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1431	\\x62a7cad4d9e9c4ed4cb8530f1b457dadec618444b8154402dc542c2549abb4b5	13	13183	183	1407	1430	27	365	2023-09-27 13:17:54.6	1	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1432	\\xbf05275e66536087496c7f1f75d1de158f7ba8518da76088b0181bea7e921bfa	13	13191	191	1408	1431	7	4	2023-09-27 13:17:56.2	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
1433	\\x2251b370b0315c352f2df72514946cb02490cce7184227b7ec60794b8273fb69	13	13203	203	1409	1432	11	4	2023-09-27 13:17:58.6	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1434	\\x7295c9235a59e17da1c870a954b73469265ce5c4caeb886684dc64efc75ecf49	13	13209	209	1410	1433	11	4	2023-09-27 13:17:59.8	0	8	0	vrf_vk1n88dll3ja508z6gldn5ysfwnr7hd2hsdu5kzhj4l6lxj0q0mvvksk7gyma	\\x1bfe30dbf2d18c26f32d1f8a8bb81b07cb77f94d8c9d4fb2ce1f4a2afd9e1621	0
1435	\\x6e7967a4fc811402c18c5d29fc096efc57c8b6666f5127440b76cab4ba2bddf3	13	13211	211	1411	1434	8	496	2023-09-27 13:18:00.2	1	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1436	\\xc6f8c0ae9e365f43ec8a6d09789d87d87df9d78e4102fd84cc430afe81ebacd1	13	13226	226	1412	1435	4	4	2023-09-27 13:18:03.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1437	\\xd275da51b3538f974b586800025b821ee9ed5bc21031eb35ce13dcb5896014c7	13	13230	230	1413	1436	3	4	2023-09-27 13:18:04	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1438	\\xbb6cc9780d0c9103f6d9029481cdad6c711375c081d451e71da49e7ce40c1f9f	13	13231	231	1414	1437	4	4	2023-09-27 13:18:04.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1439	\\xd0b9c292eae19c267ccbec05b433df2bf6c6b909786827b2972e47161fda0ea5	13	13232	232	1415	1438	27	4	2023-09-27 13:18:04.4	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1440	\\xe3baea8f202e6ced47af0ba09c307e093c8b98e89e341b68fc824aae01b5f0ad	13	13235	235	1416	1439	4	550	2023-09-27 13:18:05	1	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1441	\\x172c6754463e5a8a33fc857d8d862d5b78deaef4ac512f2d6f08b28c9e7ba6d6	13	13247	247	1417	1440	4	4	2023-09-27 13:18:07.4	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1442	\\xe6c8f4458a8c1f70b47660370e2977231902e18bf3fa72e0ec35995f385406ba	13	13281	281	1418	1441	4	4	2023-09-27 13:18:14.2	0	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1443	\\x221fd4e201bb5bb353992843b2101d8ac941ec37e2918d1f0046bae301b41ce4	13	13287	287	1419	1442	3	4	2023-09-27 13:18:15.4	0	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1444	\\x91ef83e1f7a012e1e0a8d0cc7bebf0089aa56490acc925b9b0e1225984962791	13	13289	289	1420	1443	3	329	2023-09-27 13:18:15.8	1	8	0	vrf_vk1g9d983kx9h3fh9u53s8k0m2ldjse8wmjndpa5jxxtjnt82sus6mqew52k7	\\x9d8b5bc4c181c87ebc3cb18230d87be2c333db5954083f3a6e183443fbe9717b	0
1445	\\x5011755e940ec552be996a5c5cb637d98f50c4a7230d7f85df224e381a50a738	13	13299	299	1421	1444	5	4	2023-09-27 13:18:17.8	0	8	0	vrf_vk162qaed0auj3grrqtzke6w2u2ljn6kxcra5ntqmp5xzxqu2ulwxrq9rd97d	\\x5bbc7a29eafbdaaf536779c827d41ae2a87575f0f9616d329f10cf53ca99aa69	0
1446	\\x4059e1b98c606831f0b7fb0c6740c1f7c1359b871e53caf448f158c812cd24e3	13	13327	327	1422	1445	9	4	2023-09-27 13:18:23.4	0	8	0	vrf_vk1uf8309xq6xgmcv9pdpkfjqa4vtvsjg5nggytwc57v6cs6dpkrw8qn3rsqv	\\x1164fd5c20e29c9066c82a1490f873dae1ecde4a812cef7501949dcb72cc06d9	0
1447	\\x4b9499c3d654e3ba2300295f8fa469d498300ac58cfa664ef55f4eb12171e375	13	13341	341	1423	1446	8	4	2023-09-27 13:18:26.2	0	8	0	vrf_vk1rf68w2444g2xygyuegwvzya303vcqwjnzh8d55373kz3frgp40eq3safz8	\\x7d4e640cee43f4ecea8b5a3b9334b37656d2df67b96aa2d74552d773d070a1d8	0
1448	\\xf24a67af4af7d29ad6037897c50f5ab56b53d5ec1823d1ae23cdec08c6969b79	13	13345	345	1424	1447	4	528	2023-09-27 13:18:27	1	8	0	vrf_vk1v28ddck64uulfs4yxwwvuwt0dmrxqj94ycz4sgf4h877sz83qm5s3lkzlq	\\x37121c497df69bd4141faaa5ca16418fb2d4da4fa05eb2cb3c9c159008df8196	0
1449	\\xb6442bda5731d25b07b1c346e064b433a8d981a456c8132a9bce794f7faebd3a	13	13386	386	1425	1448	27	4	2023-09-27 13:18:35.2	0	8	0	vrf_vk1jf2x8pug46pyvrtecgjqjk5k0k0ckql38jq4khvmmsuqnladkmksdzkru5	\\x5ea523c3e77f650c79aa2773a5a78c18cb4c27907192b39a7c45e5f1dd6bd565	0
1450	\\xcb04b6dc774b5a63f2e900c2cf0227127861d1dacf154baecb0b88eb70d7a976	13	13396	396	1426	1449	12	4	2023-09-27 13:18:37.2	0	8	0	vrf_vk1v8q4p00umwuja3d07dnmgkqwwg2639c9aypk80f87pcm3tc2cgcqc4046v	\\x17304d42f19ba87d266dddb476f059b258693759af0620bb6c08c05f6b710e4d	0
1451	\\xadcf8a905ceb17dacbfa3b1abaea839562c9d96346149aba796ef8788928abab	13	13407	407	1427	1450	7	4	2023-09-27 13:18:39.4	0	8	0	vrf_vk1fmsn70dt6muttqn7ecdjzkd2v8943y9ey4tglgt0mdd39dl2u23szvjcjx	\\xa378518e8343957a1ba0e73363d6cc20b0b6bf367142d04e42f4ed9a29a35583	0
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
1	99	1	addr_test1vz5xk2kh8d3u6s2ge7cwwv4m4xzvr4n6vlpycrmhenrdcwcx4kjqn	\\x60a86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	f	\\xa86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	\N	3681818081394197	\N	fromList []	\N	\N
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
1	2	1	9	2	34	0	\N
2	7	3	4	2	34	0	\N
3	1	5	10	2	34	0	\N
4	9	7	1	2	34	0	\N
5	11	9	2	2	34	0	\N
6	8	11	5	2	34	0	\N
7	5	13	8	2	34	0	\N
8	4	15	7	2	34	0	\N
9	10	17	6	2	34	0	\N
10	3	19	11	2	34	0	\N
11	6	21	3	2	34	0	\N
12	16	0	5	2	37	39	\N
13	8	0	5	2	38	51	\N
14	14	0	3	2	42	131	\N
15	6	0	3	2	43	139	\N
16	17	0	6	2	47	193	\N
17	10	0	6	2	48	206	\N
18	12	0	1	2	52	284	\N
19	9	0	1	2	53	301	\N
20	19	0	8	2	57	345	\N
21	5	0	8	2	58	354	\N
22	15	0	4	2	62	419	\N
23	7	0	4	2	63	440	\N
24	18	0	7	2	67	528	\N
25	4	0	7	2	68	557	\N
26	22	0	11	2	72	613	\N
27	3	0	11	2	73	628	\N
28	3	0	11	2	75	704	\N
29	13	0	2	2	79	748	\N
30	11	0	2	2	80	761	\N
31	11	0	2	2	82	789	\N
32	21	0	10	2	86	834	\N
33	1	0	10	2	87	869	\N
34	1	0	10	2	89	919	\N
35	20	0	9	3	93	1035	\N
36	2	0	9	3	94	1058	\N
37	2	0	9	3	96	1080	\N
38	51	1	7	6	132	4934	\N
39	52	3	8	6	132	4934	\N
40	53	5	1	6	132	4934	\N
41	54	7	5	6	132	4934	\N
42	55	9	6	6	132	4934	\N
43	51	0	7	7	134	5006	\N
44	52	1	7	7	134	5006	\N
45	53	2	7	7	134	5006	\N
46	54	3	7	7	134	5006	\N
47	55	4	7	7	134	5006	\N
48	46	1	8	7	146	5310	\N
50	46	1	7	7	154	5481	\N
51	65	1	8	11	256	9066	\N
52	48	0	12	15	361	13211	\N
53	45	0	13	15	364	13345	\N
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
1	206181735576558836	10074400	56	110	0	2023-09-27 12:33:59	2023-09-27 12:37:06.6
2	62600882440714926	3802131	20	99	1	2023-09-27 12:37:19.2	2023-09-27 12:40:37.8
13	0	0	0	114	12	2023-09-27 13:13:58	2023-09-27 13:17:12.8
4	0	0	0	110	3	2023-09-27 12:44:03.8	2023-09-27 12:47:11.2
8	6479776349311	16887624	100	102	7	2023-09-27 12:57:22	2023-09-27 13:00:34.6
6	47073726640866	8852594	19	106	5	2023-09-27 12:50:38	2023-09-27 12:53:55.8
3	0	0	0	100	2	2023-09-27 12:40:40.8	2023-09-27 12:43:54.4
5	50001559708732	4278274	22	96	4	2023-09-27 12:47:18.6	2023-09-27 12:50:34
12	21239854985769	16925992	100	115	11	2023-09-27 13:10:40.2	2023-09-27 13:13:54
14	25211600261084	1474400	8	38	13	2023-09-27 13:17:18.2	2023-09-27 13:18:37.2
10	5113501157045	605694	2	115	9	2023-09-27 13:04:01.2	2023-09-27 13:07:16.8
7	0	0	0	113	6	2023-09-27 12:54:02.4	2023-09-27 12:57:15.6
9	0	0	0	113	8	2023-09-27 13:00:39.2	2023-09-27 13:03:53
11	0	0	0	85	10	2023-09-27 13:07:18.6	2023-09-27 13:10:34.2
\.


--
-- Data for Name: epoch_param; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_param (id, epoch_no, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, nonce, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, block_id, extra_entropy, coins_per_utxo_size) FROM stdin;
1	1	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\x870d599f35e30fecfee49a38659d9cd029deb2779bb858cb462178eca1ec10b2	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	113	\N	4310
2	2	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\xfbd328e41810a0aece00e31d5fa82837a32b41eabb987815fabd99833dc65ce6	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	212	\N	4310
3	3	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\xbefa3310638dd71a1e26c9a7b9ec62532b4d9316fc51234d10874e44bc370417	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	313	\N	4310
4	4	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\xc3e80a4841e8a5e1537a4a988dac20d72ffa1ecd7a20f1bf3dedbe6e937fdc6f	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	424	\N	4310
5	5	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\xe52778f5efb84d9128b2a418aea03d5737dc4e6926c09dc0e92ab142da15c594	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	522	\N	4310
6	6	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\x56596d92dfd2e4c30a240d098ae82d12c7fb06a582bed43a461305690837abbd	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	631	\N	4310
7	7	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\x9e60870395a8fa8933185bb4711ccb81f52908dfda975cac9295f5ea8305e769	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	746	\N	4310
8	8	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\x46305853e50ca66ec735003786ab5e9563975eb7a382ad9c4658c8072624aa00	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	849	\N	4310
9	9	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\x568db85af5122d5748d4fed9c819d31830c9baeea198457e1cdbd3603f7098e3	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	966	\N	4310
10	10	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\x2f7680011c3e412a56221f148c24d004f139bd1034dd09c322b790ae96157633	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1086	\N	4310
11	11	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\xf583d33a1ebdba1f1357c9643c642a7ccf2b18e57060815a83cbd86dab9c99e2	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1175	\N	4310
12	12	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\x44f7055403a62187a21b6d73128dccb27b9af62cbab9cdca3bf98447c8ac1d4d	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1294	\N	4310
13	13	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\xc7c5bd50d444fc4660393b9ad95a5503ed778631b81b0ee4e534522564db92ec	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1413	\N	4310
\.


--
-- Data for Name: epoch_stake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_stake (id, addr_id, pool_id, amount, epoch_no) FROM stdin;
1	2	9	3681818181818190	1
2	7	4	3681818181818181	1
3	1	10	3681818181818181	1
4	9	1	3681818181818181	1
5	11	2	3681818181818181	1
6	8	5	3681818181818181	1
7	5	8	3681818181818181	1
8	4	7	3681818181818181	1
9	10	6	3681818181818181	1
10	3	11	3681818181818181	1
11	6	3	3681818181818181	1
12	2	9	3681818181818190	2
13	18	7	500000000	2
14	7	4	3681818181443619	2
15	12	1	500000000	2
16	22	11	300000000	2
17	15	4	500000000	2
18	19	8	500000000	2
19	1	10	3681818181263026	2
20	9	1	3681818181443619	2
21	11	2	3681818181265842	2
22	8	5	3681818181443619	2
23	14	3	600000000	2
24	21	10	500000000	2
25	16	5	500000000	2
26	5	8	3681818181443619	2
27	4	7	3681818181443619	2
28	17	6	200000000	2
29	13	2	300000000	2
30	10	6	3681818181443619	2
31	3	11	3681818181265842	2
32	6	3	3681818181446391	2
33	2	9	3681818181263035	3
34	18	7	500000000	3
35	7	4	3681818181443619	3
36	12	1	500000000	3
37	22	11	300000000	3
38	15	4	500000000	3
39	19	8	500000000	3
40	1	10	3681818181263026	3
41	9	1	3681818181443619	3
42	11	2	3681818181265842	3
43	8	5	3681818181443619	3
44	20	9	500000000	3
45	14	3	600000000	3
46	21	10	500000000	3
47	16	5	500000000	3
48	5	8	3681818181443619	3
49	4	7	3681818181443619	3
50	17	6	200000000	3
51	13	2	300000000	3
52	10	6	3681818181443619	3
53	3	11	3681818181265842	3
54	6	3	3681818181446391	3
55	2	9	3687992804421511	4
56	18	7	500000000	4
57	7	4	3687992804602095	4
58	12	1	500000000	4
59	22	11	300000000	4
60	15	4	500000000	4
61	19	8	500000000	4
62	1	10	3691521160512061	4
63	9	1	3691521160692654	4
64	11	2	3685346537356400	4
65	8	5	3688874893624735	4
66	20	9	500000000	4
67	14	3	600000000	4
68	21	10	500000000	4
69	16	5	500000000	4
70	5	8	3692403249715293	4
71	4	7	3689756982647375	4
72	17	6	200000000	4
73	13	2	300000000	4
74	10	6	3693285338737933	4
75	3	11	3688874893446958	4
76	6	3	3689756982650147	4
77	2	9	3691417402747179	5
78	18	7	501395206	5
79	7	4	3696554298091793	5
80	12	1	500697603	5
81	22	11	300279041	5
82	15	4	501162671	5
83	19	8	501395206	5
84	1	10	3703507251398226	5
85	9	1	3696658056786472	5
86	11	2	3696476480102723	5
87	8	5	3697436387114433	5
88	20	9	500000000	5
89	14	3	600558082	5
90	21	10	501627740	5
91	16	5	501162671	5
92	5	8	3702677041902930	5
93	4	7	3700030774835012	5
94	17	6	200558082	5
95	13	2	300906884	5
96	10	6	3703559132599818	5
97	3	11	3692299491215057	5
98	6	3	3693181579859995	5
99	54	5	0	6
100	2	9	3699052565875304	6
101	53	1	0	6
102	18	7	573470648179	6
103	7	4	3704341824482145	6
104	12	1	1833256007218	6
105	22	11	300279041	6
106	15	4	1375171769868	6
107	19	8	917053299990	6
108	51	7	0	6
109	1	10	3711294769288961	6
110	9	1	3707041564140256	6
111	52	8	0	6
112	11	2	3696476480102723	6
113	8	5	3704574933138925	6
114	20	9	501036874	6
115	14	3	917152578986	6
116	21	10	1375180735004	6
117	16	5	1260635719266	6
118	5	8	3707868621329845	6
119	4	7	3703275387664350	6
120	17	6	200558082	6
121	13	2	300906884	6
122	10	6	3703559132599818	6
123	3	11	3692299491215057	6
124	55	6	999414590	6
125	6	3	3698373159004886	6
126	54	7	0	7
127	2	9	3702593454418922	7
128	53	7	0	7
129	18	7	1323349695159	7
130	7	4	3709299192542951	7
131	12	1	3082219403858	7
132	15	4	2250402218358	7
133	19	8	1791230222117	7
134	51	7	499375158	7
135	9	1	3714116920332381	7
136	52	7	0	7
137	11	2	3696476480102723	7
138	8	5	3710947273510652	7
139	20	9	625754285814	7
140	14	3	2916277790465	7
141	16	5	2385557389246	7
142	5	8	3712820076085287	7
143	4	7	3707522488427068	7
144	17	6	200558082	7
145	13	2	300906884	7
146	10	6	3703559132599818	7
147	55	7	499837675	7
148	6	3	3709699312924785	7
149	46	7	4998922437767	7
150	54	7	0	8
151	2	9	3707805027215329	8
152	53	7	0	8
153	18	7	2470690629376	8
154	7	4	3715154096845612	8
155	12	1	4115784241115	8
156	15	4	3284021558571	8
157	19	8	3281608302587	8
158	51	7	499375158	8
159	9	1	3719971685790139	8
160	52	7	0	8
161	11	2	3696476480102723	8
162	8	5	3716800789441322	8
163	20	9	1545834433302	8
164	14	3	4065746057931	8
165	16	5	3418921722193	8
166	5	8	3721263334252371	8
167	4	7	3714021871182708	8
168	17	6	200558082	8
169	13	2	300906884	8
170	10	6	3703559132599818	8
171	55	7	499837675	8
172	6	3	3716210749381482	8
173	46	7	4998922437767	8
174	54	7	0	9
175	2	9	3713209437788933	9
176	53	7	0	9
177	18	7	3318470003507	9
178	7	4	3722943676890215	9
179	12	1	5070015385733	9
180	15	4	4662455383653	9
181	19	8	5187155984067	9
182	51	7	499375158	9
183	9	1	3725359137110840	9
184	52	7	0	9
185	11	2	3696476480102723	9
186	8	5	3723991145691795	9
187	20	9	2499944807500	9
188	14	3	4702782054237	9
189	16	5	4691076728523	9
190	5	8	3732041456362805	9
191	4	7	3718818792122043	9
192	17	6	200558082	9
193	13	2	300906884	9
194	10	6	3703559132599818	9
195	55	7	499837675	9
196	6	3	3719812455491887	9
197	46	7	4998905550143	9
198	54	7	0	10
199	2	9	3718021170005764	10
200	53	7	0	10
201	18	7	4450282799149	10
202	7	4	3730941942174182	10
203	12	1	6203813242322	10
204	15	4	6080022767551	10
205	19	8	6225203090693	10
206	51	7	500235516	10
207	9	1	3731746556947255	10
208	52	7	0	10
209	11	2	3696476480102723	10
210	8	5	3728787499471334	10
211	20	9	3350420732267	10
212	14	3	5743166460432	10
213	16	5	5541509517418	10
214	5	8	3737902661918183	10
215	4	7	3725206374009313	10
216	17	6	200558082	10
217	13	2	300906884	10
218	10	6	3703559132599818	10
219	55	7	500698830	10
220	6	3	3725675032439258	10
221	46	7	5007518047172	10
222	54	7	0	11
223	2	9	3726572439401768	11
224	53	7	0	11
225	18	7	5625424697143	11
226	7	4	3739942030602398	11
227	12	1	6792585730896	11
228	15	4	7678033260816	11
229	19	8	6729228733166	11
230	51	7	501125439	11
231	9	1	3735056424090899	11
232	52	7	0	11
233	11	2	3696476480102723	11
234	8	5	3736362574744173	11
235	20	9	4864052555937	11
236	14	3	7342266926863	11
237	16	5	6886875128953	11
238	5	8	3740739916941081	11
239	4	7	3731825038163813	11
240	17	6	200558082	11
241	13	2	300906884	11
242	10	6	3703559132599818	11
243	55	7	501589578	11
244	6	3	3734668793836874	11
245	65	8	2503758936215	11
246	46	7	2512666958120	11
247	54	7	0	12
248	2	9	3734829954231975	12
249	53	7	0	12
250	18	7	6437484642116	12
251	7	4	3745426177752257	12
252	12	1	7524740043957	12
253	15	4	8654304065219	12
254	19	8	8109633642388	12
255	51	7	501738597	12
256	9	1	3739165916529239	12
257	52	7	0	12
258	11	2	3696476480102723	12
259	8	5	3740017486164595	12
260	20	9	6328191562338	12
261	14	3	8889208054420	12
262	16	5	7537666035670	12
263	5	8	3748488205897963	12
264	4	7	3736391198102549	12
265	17	6	200558082	12
266	13	2	300906884	12
267	10	6	3703559132599818	12
268	55	7	502203304	12
269	6	3	3743359336625598	12
270	65	8	2503758936215	12
271	46	7	2518804875436	12
272	54	7	0	13
273	2	9	3739015685545247	13
274	53	7	0	13
275	18	7	7457688517805	13
276	7	4	3751153400521325	13
277	12	1	8082323669722	13
278	15	4	9676370677042	13
279	19	8	8851777244916	13
280	51	7	502507459	13
281	9	1	3742288849107602	13
282	52	7	0	13
283	11	2	3696476480102723	13
284	8	5	3749397632151221	13
285	20	9	7071677545166	13
286	14	3	9354428558691	13
287	16	5	9209776190319	13
288	5	8	3752645320513006	13
289	4	7	3742116844699078	13
290	17	6	200558082	13
291	13	2	300906884	13
292	10	6	3703559132599818	13
293	55	7	502972878	13
294	6	3	3745966582177210	13
295	65	8	2503732755837	13
296	46	7	2526510690974	13
\.


--
-- Data for Name: epoch_sync_time; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_sync_time (id, no, seconds, state) FROM stdin;
1	0	1	lagging
2	1	1	lagging
3	2	1	following
4	3	177	following
5	4	200	following
6	5	205	following
7	6	200	following
8	7	198	following
9	8	202	following
10	9	198	following
11	10	202	following
12	11	198	following
13	12	201	following
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
23	1	124	12
24	1	124	13
25	1	124	14
26	-1	125	13
28	1	127	15
29	1	128	16
30	1	129	17
31	-1	130	15
32	-1	130	16
33	-1	130	17
34	-1	130	12
35	-1	130	14
36	10	135	18
37	-10	136	18
38	1	137	19
40	-1	139	19
41	1	358	9
42	1	358	10
43	1	358	11
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
19	2	149	11
20	2	152	11
21	1	154	11
22	1	156	12
23	1	156	13
24	1	156	14
25	1	159	12
26	1	159	14
28	1	162	15
29	1	164	16
30	1	166	17
31	1	167	16
32	10	216	18
33	1	219	19
34	1	784	9
35	1	784	10
36	1	784	11
37	2	797	5
38	1	797	6
39	1	797	7
\.


--
-- Data for Name: meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meta (id, start_time, network_name, version) FROM stdin;
1	2023-09-27 12:33:58	testnet	Version {versionBranch = [13,1,0,2], versionTags = []}
\.


--
-- Data for Name: multi_asset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.multi_asset (id, policy, name, fingerprint) FROM stdin;
1	\\xe26f7f0bb3c1df15a72a7777a82624420548b5a4ed606f93097f6e54	\\x	asset18fl7utn6c38stv7lw5jmfpvwyw94wvvk44k26m
2	\\xe26f7f0bb3c1df15a72a7777a82624420548b5a4ed606f93097f6e54	\\x74425443	asset1mqlu34e6nhrl3lu3v0gj05297q2eue7nln6yj7
3	\\xe26f7f0bb3c1df15a72a7777a82624420548b5a4ed606f93097f6e54	\\x74455448	asset1hztuh54cezcs8zq6kkk4dtcmw0yx9r2weh2tza
4	\\xe26f7f0bb3c1df15a72a7777a82624420548b5a4ed606f93097f6e54	\\x744d494e	asset13qddszw9zmh997l67spn6khukynl0q0fqxa297
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
1	\\x113104a69508f2bc629d67c9a202a41d114960ce3541d2e3dad953e8	pool1zycsff54pretcc5avly6yq4yr5g5jcxwx4qa9c76m9f7s3d0qet
2	\\x22da702c66e77e4ef93383962bff03e49318dd505b42d9d55dd87a43	pool1ytd8qtrxualya7fnswtzhlcrujf33h2stdpdn42ampayxtc48xk
3	\\x3046520e763319fe9b71c3f216f5f1c00024982abfb9f7ed6c414408	pool1xpr9yrnkxvvlaxm3c0epda03cqqzfxp2h7ul0mtvg9zqsz4upzs
4	\\x3f8a639841a8ded753dee1453637d22fc9087f60d8a68bc5bf925a20	pool1879x8xzp4r0dw577u9znvd7j9lysslmqmzngh3dljfdzqrvpxgj
5	\\x5ae4f3c1648dc6cff686c82e52a28bcf85f6f95d8df4cf7e52863d4b	pool1ttj08sty3hrvla5xeqh99g5te7zld72a3h6v7ljjsc75k90zsep
6	\\x61a34b4c64319736cdbf2374d5082d3867a7871cf90e3a6d259ea55b	pool1vx35knryxxtndndlyd6d2zpd8pn60pculy8r5mf9n6j4k6rne5g
7	\\x7c6650b98817d99528db45fea9ba86520c748a932377549447a5a823	pool103n9pwvgzlve22xmghl2nw5x2gx8fz5nydm4f9z85k5zxe348sq
8	\\x7d1f8ae7b5330208dac263c69d98d0bd2a113d54014a96aab991b806	pool1050c4ea4xvpq3kkzv0rfmxxsh54pz025q99fd24ejxuqv9954hz
9	\\x7eaaab7668bb08d7b8ec533e3e9395d205218640c46106390a253d56	pool10642kanghvyd0w8v2vlrayu46gzjrpjqc3ssvwg2y574v9407ql
10	\\x93bf0873eb7afd7d87ce9321e6a0b33217f865dc3244f379c4887197	pool1jwlssult0t7hmp7wjvs7dg9nxgtlsewuxfz0x7wy3pcewh4wkr5
11	\\x9f37628b233a3f37c91d6606d51c39446b293921f39d8c11446e98df	pool1numk9zer8gln0jgavcrd28peg34jjwfp7wwccy2yd6vd7nsafgc
12	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
13	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_metadata_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata_ref (id, pool_id, url, hash, registered_tx_id) FROM stdin;
1	5	http://file-server/SP1.json	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	39
2	6	http://file-server/SP3.json	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	49
3	1	http://file-server/SP4.json	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	54
4	8	http://file-server/SP5.json	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	59
5	4	http://file-server/SP6.json	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	64
6	7	http://file-server/SP7.json	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	69
7	10	http://file-server/SP10.json	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	88
8	9	http://file-server/SP11.json	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	95
\.


--
-- Data for Name: pool_offline_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_offline_data (id, pool_id, ticker_name, hash, json, bytes, pmr_id) FROM stdin;
1	5	SP1	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	{"name": "stake pool - 1", "ticker": "SP1", "homepage": "https://stakepool1.com", "description": "This is the stake pool 1 description."}	\\x7b0a2020226e616d65223a20227374616b6520706f6f6c202d2031222c0a2020227469636b6572223a2022535031222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2031206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c312e636f6d220a7d0a	1
2	6	SP3	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	{"name": "Stake Pool - 3", "ticker": "SP3", "homepage": "https://stakepool3.com", "description": "This is the stake pool 3 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2033222c0a2020227469636b6572223a2022535033222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2033206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c332e636f6d220a7d0a	2
3	1	SP4	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	{"name": "Same Name", "ticker": "SP4", "homepage": "https://stakepool4.com", "description": "This is the stake pool 4 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535034222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2034206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c342e636f6d220a7d0a	3
4	8	SP5	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	{"name": "Same Name", "ticker": "SP5", "homepage": "https://stakepool5.com", "description": "This is the stake pool 5 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535035222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2035206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c352e636f6d220a7d0a	4
5	4	SP6a7	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	{"name": "Stake Pool - 6", "ticker": "SP6a7", "homepage": "https://stakepool6.com", "description": "This is the stake pool 6 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2036222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2036206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c362e636f6d220a7d0a	5
6	7	SP6a7	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	{"name": "", "ticker": "SP6a7", "homepage": "https://stakepool7.com", "description": "This is the stake pool 7 description."}	\\x7b0a2020226e616d65223a2022222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2037206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c372e636f6d220a7d0a	6
7	10	SP10	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	{"name": "Stake Pool - 10", "ticker": "SP10", "homepage": "https://stakepool10.com", "description": "This is the stake pool 10 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130222c0a2020227469636b6572223a202253503130222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203130206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31302e636f6d220a7d0a	7
8	9	SP11	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	{"name": "Stake Pool - 10 + 1", "ticker": "SP11", "homepage": "https://stakepool11.com", "description": "This is the stake pool 11 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130202b2031222c0a2020227469636b6572223a202253503131222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203131206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31312e636f6d220a7d0a	8
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
1	16	12
2	14	13
3	17	14
4	12	15
5	19	16
6	15	17
7	18	18
8	22	19
9	13	20
10	21	21
11	20	22
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
1	11	0	76	5
2	2	0	83	18
3	10	0	90	5
4	9	0	97	18
\.


--
-- Data for Name: pool_update; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_update (id, hash_id, cert_index, vrf_key_hash, pledge, active_epoch_no, meta_id, margin, fixed_cost, registered_tx_id, reward_addr_id) FROM stdin;
1	1	0	\\xb09acb5ac2e0d1f05f4cae8a8cd4676fc609433442ae1845372793702892f1ea	0	2	\N	0	0	34	12
2	2	1	\\x3218ce946a17a1bd0e8e52499d80b232fe7f8d81c5bf3592faaad05bc1c901ba	0	2	\N	0	0	34	13
3	3	2	\\x9f201da836a2bb498037ea76f824c2c43ab0643b97ea3c22e7125410989f8eec	0	2	\N	0	0	34	14
4	4	3	\\xf4d3baa6a7aa18158f6d2528e8ac4b6d057ccd1e1a273ea8d90ba7a5b634e7f3	0	2	\N	0	0	34	15
5	5	4	\\xb47b54d3e33698b978a34b9ef844c0c137b074a11ca4314fdd6af3e16ec82c29	0	2	\N	0	0	34	16
6	6	5	\\xf12baebfc68a52ef373942578a4543f5fbc21a5ef237980c751ff1ab26d5805d	0	2	\N	0	0	34	17
7	7	6	\\x513ab726ebc3b22eff65c58fcbcca824e09485edffb05f93b6802b50df6c512c	0	2	\N	0	0	34	18
8	8	7	\\xde0875b7f2134602034f5cace7a82e47dcd3521c9fcccd3bf8cc55f8ac99c040	0	2	\N	0	0	34	19
9	9	8	\\x7cf598bb7226be677689888549fbc464907f14772bee6979279712f69bde9902	0	2	\N	0	0	34	20
10	10	9	\\xdb7ea24c9fd88407345dce6054e42a9c4b895bcc9f9e4cc42f532b8bbca713d9	0	2	\N	0	0	34	21
11	11	10	\\x521ac09e9488ded6394bd4520ba62532d9b6031b415cafce6667ef4e3c0890f6	0	2	\N	0	0	34	22
12	5	0	\\xb47b54d3e33698b978a34b9ef844c0c137b074a11ca4314fdd6af3e16ec82c29	400000000	3	1	0.15	390000000	39	16
13	3	0	\\x9f201da836a2bb498037ea76f824c2c43ab0643b97ea3c22e7125410989f8eec	500000000	3	\N	0.15	390000000	44	14
14	6	0	\\xf12baebfc68a52ef373942578a4543f5fbc21a5ef237980c751ff1ab26d5805d	600000000	3	2	0.15	390000000	49	17
15	1	0	\\xb09acb5ac2e0d1f05f4cae8a8cd4676fc609433442ae1845372793702892f1ea	420000000	3	3	0.15	370000000	54	12
16	8	0	\\xde0875b7f2134602034f5cace7a82e47dcd3521c9fcccd3bf8cc55f8ac99c040	410000000	3	4	0.15	390000000	59	19
17	4	0	\\xf4d3baa6a7aa18158f6d2528e8ac4b6d057ccd1e1a273ea8d90ba7a5b634e7f3	410000000	3	5	0.15	400000000	64	15
18	7	0	\\x513ab726ebc3b22eff65c58fcbcca824e09485edffb05f93b6802b50df6c512c	410000000	3	6	0.15	390000000	69	18
19	11	0	\\x521ac09e9488ded6394bd4520ba62532d9b6031b415cafce6667ef4e3c0890f6	500000000	3	\N	0.15	380000000	74	22
20	2	0	\\x3218ce946a17a1bd0e8e52499d80b232fe7f8d81c5bf3592faaad05bc1c901ba	500000000	3	\N	0.15	390000000	81	13
21	10	0	\\xdb7ea24c9fd88407345dce6054e42a9c4b895bcc9f9e4cc42f532b8bbca713d9	400000000	3	7	0.15	410000000	88	21
22	9	0	\\x7cf598bb7226be677689888549fbc464907f14772bee6979279712f69bde9902	400000000	4	8	0.15	390000000	95	20
23	12	0	\\x2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	500000000000000	15	\N	0.2	1000	359	48
24	13	0	\\x641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	50000000	15	\N	0.2	1000	362	45
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
1	3	1:34:
2	4	2:36:
3	5	::
4	6	::
5	7	3:37:
6	8	::
7	9	4:38:
8	10	::
9	11	5:39:
10	12	::
11	13	6:40:
12	14	7:42:
13	15	::
14	16	::
15	17	::
16	18	8:43:
17	19	9:44:
18	20	10:45:
19	21	::
20	22	::
21	23	11:46:
22	24	::
23	25	::
24	26	::
25	27	12:48:
26	28	::
27	29	13:49:
28	30	::
29	31	::
30	32	14:50:
31	33	::
32	34	15:51:
33	35	::
34	36	16:52:
35	37	::
36	38	::
37	39	17:54:
38	40	::
39	41	18:55:
40	42	19:56:
41	43	::
42	44	20:57:
43	45	::
44	46	21:58:
45	47	::
46	48	22:60:
47	49	23:61:
48	50	24:62:
49	51	::
50	52	::
51	53	25:63:
52	54	26:64:
53	55	27:66:
54	56	::
55	57	28:67:
56	58	::
57	59	::
58	60	::
59	61	29:68:
60	62	30:69:
61	63	::
62	64	::
63	65	31:70:
64	66	::
65	67	32:72:
66	68	::
67	69	::
68	70	33:73:
69	71	34:74:
70	72	::
71	73	35:75:
72	74	::
73	75	36:76:
74	76	::
75	77	37:78:
76	78	38:79:
77	79	::
78	80	39:80:
79	81	40:81:
80	82	::
81	83	41:82:
82	84	42:83:
83	85	::
84	86	43:84:
85	87	::
86	88	44:86:
87	89	::
88	90	45:87:
89	91	::
90	92	46:88:
91	93	47:89:
92	94	::
93	95	48:90:
94	96	::
95	97	::
96	98	49:91:
97	99	50:92:
98	100	51:94:
99	101	::
100	102	::
101	103	52:95:
102	104	53:96:
103	105	::
104	106	::
105	107	54:97:
106	108	55:98:
107	109	::
108	110	::
109	111	56:99:
110	112	::
111	113	57:100:
112	114	58:102:
113	115	::
114	116	::
115	117	59:103:
116	118	::
117	119	60:104:
118	120	61:105:
119	121	62:106:
120	122	::
121	123	63:107:
122	124	::
123	125	64:108:
124	126	65:110:
125	127	66:111:
126	128	::
127	129	67:113:
128	130	::
129	131	::
130	132	68:115:
131	133	69:117:
132	134	::
133	135	::
134	136	::
135	137	70:119:
136	138	::
137	139	::
138	140	71:121:
139	141	72:123:
140	142	74:124:1
141	143	::
142	144	::
143	145	75:126:
144	146	76:132:5
145	147	77:134:8
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
431	433	78:136:9
432	434	::
433	435	::
434	436	::
435	437	79:138:12
436	438	::
437	439	::
438	440	::
439	441	81:140:15
440	442	::
441	443	::
442	444	::
443	445	82:142:
444	446	::
445	447	::
446	448	::
447	449	83:143:
448	450	::
449	451	::
450	452	::
451	453	84:144:17
452	454	::
453	455	::
454	456	::
455	457	85:146:18
456	458	::
457	459	::
458	460	::
459	461	86:148:
460	462	::
461	463	::
462	464	::
463	465	88:149:19
464	466	::
465	467	::
466	468	::
467	469	89:151:
468	470	::
469	471	::
470	472	::
471	473	90:152:20
472	474	::
473	475	::
474	476	::
475	477	91:154:21
476	478	::
477	479	::
478	480	::
479	481	92:155:
480	482	::
481	483	::
482	484	::
483	485	::
484	486	93:156:22
485	487	::
486	488	::
487	489	::
488	490	95:158:25
489	491	::
490	492	::
491	493	::
493	495	98:162:28
494	496	::
495	497	::
496	498	::
497	499	99:164:29
498	500	::
499	501	::
500	502	::
501	503	100:166:30
502	504	::
503	505	::
504	506	::
505	507	102:168:
506	508	::
507	509	::
508	510	::
509	511	106:169:
510	512	::
511	513	::
512	514	::
513	515	108:171:
514	516	::
515	517	::
516	518	::
517	519	109:206:
518	520	::
519	521	::
520	522	::
521	523	144:215:
522	524	::
523	525	::
524	526	::
525	527	::
526	528	145:216:32
527	529	::
528	530	::
529	531	::
530	532	146:218:
531	533	::
532	534	::
533	535	::
534	536	::
535	537	147:219:33
536	538	::
537	539	::
538	540	::
540	542	149:222:
541	543	::
542	544	::
543	545	::
544	546	150:223:
545	547	::
546	548	::
547	549	::
548	550	::
549	551	::
550	552	::
551	553	::
552	554	::
553	555	156:227:
554	556	157:229:
555	557	::
556	558	160:231:
557	559	162::
558	560	::
559	561	163:233:
560	562	164:235:
561	563	165:236:
562	564	::
563	565	::
564	566	::
565	567	166:238:
566	568	::
567	569	168:240:
568	570	::
569	571	::
570	572	169:360:
571	573	229:362:
572	574	::
573	575	::
574	576	::
575	577	::
576	578	::
578	580	231:365:
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
688	690	::
689	691	::
690	692	::
691	693	::
692	694	::
693	695	::
694	696	::
695	697	::
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
745	747	232:366:
746	748	242:386:
747	749	311:492:
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
965	967	363:566:
966	968	::
967	969	::
968	970	::
969	971	::
970	972	364:568:
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
1044	1046	::
1045	1047	::
1046	1048	::
1047	1049	::
1048	1050	::
1049	1051	::
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
1148	1150	::
1150	1152	::
1151	1153	::
1152	1154	::
1153	1155	::
1154	1156	::
1155	1157	::
1157	1159	::
1158	1160	::
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
1176	1178	496:582:
1177	1179	523:624:
1178	1180	553:664:
1179	1181	::
1180	1182	::
1181	1183	::
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
1308	1310	::
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
1321	1323	::
1323	1325	::
1324	1326	::
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
1335	1337	::
1336	1338	::
1337	1339	::
1338	1340	::
1339	1341	::
1340	1342	::
1341	1343	::
1342	1344	::
1343	1345	::
1344	1346	::
1345	1347	::
1346	1348	::
1347	1349	::
1348	1350	::
1349	1351	::
1350	1352	::
1351	1353	::
1352	1354	::
1353	1355	::
1354	1356	::
1355	1357	::
1356	1358	::
1357	1359	::
1358	1360	::
1359	1361	::
1360	1362	::
1361	1363	::
1362	1364	::
1363	1365	::
1364	1366	::
1365	1367	::
1366	1368	::
1367	1369	::
1368	1370	::
1369	1371	::
1370	1372	::
1371	1373	::
1372	1374	::
1373	1375	::
1374	1376	::
1375	1377	::
1376	1378	::
1377	1379	::
1378	1380	::
1379	1381	::
1380	1382	::
1381	1383	::
1382	1384	::
1383	1385	::
1384	1386	::
1385	1387	::
1386	1388	::
1387	1389	::
1388	1390	::
1389	1391	::
1390	1392	::
1391	1393	::
1392	1394	::
1393	1395	::
1394	1396	::
1396	1398	::
1397	1399	::
1398	1400	::
1399	1401	::
1400	1402	::
1401	1403	::
1402	1404	::
1403	1405	::
1404	1406	::
1405	1407	::
1406	1408	::
1407	1409	::
1408	1410	::
1409	1411	::
1410	1412	::
1411	1413	::
1412	1414	651:782:
1413	1415	::
1414	1416	::
1415	1417	::
1416	1418	652:784:34
1417	1419	::
1418	1420	::
1419	1421	::
1420	1422	::
1421	1423	::
1422	1424	::
1423	1425	::
1424	1426	::
1425	1427	654:786:
1426	1428	::
1427	1429	::
1428	1430	::
1429	1431	655:788:
1430	1432	::
1431	1433	::
1432	1434	::
1433	1435	657:790:
1434	1436	::
1435	1437	::
1436	1438	::
1437	1439	::
1438	1440	659:792:
1439	1441	::
1440	1442	::
1441	1443	::
1442	1444	660:794:
1443	1445	::
1444	1446	::
1445	1447	::
1446	1448	661:796:37
1447	1449	::
1448	1450	::
1449	1451	::
\.


--
-- Data for Name: reward; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward (id, addr_id, type, amount, earned_epoch, spendable_epoch, pool_id) FROM stdin;
1	2	member	6174623158476	1	3	9
2	7	member	6174623158476	1	3	4
3	1	member	9702979249035	1	3	10
4	9	member	9702979249035	1	3	1
5	11	member	3528356090558	1	3	2
6	8	member	7056712181116	1	3	5
7	5	member	10585068271674	1	3	8
8	4	member	7938801203756	1	3	7
9	10	member	11467157294314	1	3	6
10	3	member	7056712181116	1	3	11
11	6	member	7938801203756	1	3	3
12	18	leader	0	1	3	7
13	12	leader	0	1	3	1
14	22	leader	0	1	3	11
15	15	leader	0	1	3	4
16	19	leader	0	1	3	8
17	20	leader	0	1	3	9
18	14	leader	0	1	3	3
19	21	leader	0	1	3	10
20	16	leader	0	1	3	5
21	17	leader	0	1	3	6
22	13	leader	0	1	3	2
23	2	member	3424598325668	2	4	9
24	18	member	1395206	2	4	7
25	7	member	8561493489698	2	4	4
26	12	member	697603	2	4	1
27	22	member	279041	2	4	11
28	15	member	1162671	2	4	4
29	19	member	1395206	2	4	8
30	1	member	11986090886165	2	4	10
31	9	member	5136896093818	2	4	1
32	11	member	11129942746323	2	4	2
33	8	member	8561493489698	2	4	5
34	14	member	558082	2	4	3
35	21	member	1627740	2	4	10
36	16	member	1162671	2	4	5
37	5	member	10273792187637	2	4	8
38	4	member	10273792187637	2	4	7
39	17	member	558082	2	4	6
40	13	member	906884	2	4	2
41	10	member	10273793861885	2	4	6
42	3	member	3424597768099	2	4	11
43	6	member	3424597209848	2	4	3
44	18	leader	0	2	4	7
45	12	leader	0	2	4	1
46	22	leader	0	2	4	11
47	15	leader	0	2	4	4
48	19	leader	0	2	4	8
49	20	leader	0	2	4	9
50	14	leader	0	2	4	3
51	21	leader	0	2	4	10
52	16	leader	0	2	4	5
53	17	leader	0	2	4	6
54	13	leader	0	2	4	2
55	2	member	7635163128125	3	5	9
56	7	member	7787526390352	3	5	4
57	1	member	7787517890735	3	5	10
58	9	member	10383507353784	3	5	1
59	8	member	7138546024492	3	5	5
60	20	member	1036874	3	5	9
61	5	member	5191579426915	3	5	8
62	4	member	3244612829338	3	5	7
63	6	member	5191579144891	3	5	3
64	18	leader	572969252973	3	5	7
65	12	leader	1832755309615	3	5	1
66	22	leader	0	3	5	11
67	15	leader	1374670607197	3	5	4
68	19	leader	916551904784	3	5	8
69	20	leader	0	3	5	9
70	14	leader	916552020904	3	5	3
71	21	leader	1374679107264	3	5	10
72	16	leader	1260134556595	3	5	5
73	17	leader	0	3	5	6
74	13	leader	0	3	5	2
75	22	refund	0	5	5	11
76	21	refund	0	5	5	10
77	2	member	3540888543618	4	6	9
78	7	member	4957368060806	4	6	4
79	1	member	9198023400206	4	6	10
80	9	member	7075356192125	4	6	1
81	8	member	6372340371727	4	6	5
82	5	member	4951454755442	4	6	8
83	4	member	4247100762718	4	6	7
84	6	member	11326153919899	4	6	3
85	18	leader	749879046980	4	6	7
86	12	leader	1248963396640	4	6	1
87	22	leader	0	4	6	11
88	15	leader	875230448490	4	6	4
89	19	leader	874176922127	4	6	8
90	20	leader	625253248940	4	6	9
91	14	leader	1999125211479	4	6	3
92	21	leader	1623592065719	4	6	10
93	16	leader	1124921669980	4	6	5
94	17	leader	0	4	6	6
95	13	leader	0	4	6	2
96	2	member	5211572796407	5	7	9
97	7	member	5854904302661	5	7	4
98	1	member	7791987081631	5	7	10
99	9	member	5854765457758	5	7	1
100	8	member	5853515930670	5	7	5
101	5	member	8443258167084	5	7	8
102	4	member	6499382755640	5	7	7
103	6	member	6511436456697	5	7	3
104	18	leader	1147340934217	5	7	7
105	12	leader	1033564837257	5	7	1
106	22	leader	0	5	7	11
107	15	leader	1033619340213	5	7	4
108	19	leader	1490378080470	5	7	8
109	20	leader	920080147488	5	7	9
110	14	leader	1149468267466	5	7	3
111	21	leader	1375467785462	5	7	10
112	16	leader	1033364332947	5	7	5
113	17	leader	0	5	7	6
114	13	leader	0	5	7	2
115	2	member	5404410573604	6	8	9
116	7	member	7789580044603	6	8	4
117	1	member	4784474167856	6	8	10
118	9	member	5387451320701	6	8	1
119	8	member	7190356250473	6	8	5
120	5	member	10778122110434	6	8	8
121	4	member	4796920939335	6	8	7
122	6	member	3601706110405	6	8	3
123	18	leader	847779374131	6	8	7
124	12	leader	954231144618	6	8	1
125	22	leader	0	6	8	11
126	15	leader	1378433825082	6	8	4
127	19	leader	1905547681480	6	8	8
128	20	leader	954110374198	6	8	9
129	14	leader	637035996306	6	8	3
130	21	leader	846814660124	6	8	10
131	16	leader	1272155006330	6	8	5
132	17	leader	0	6	8	6
133	13	leader	0	6	8	2
134	2	member	4811732216831	7	9	9
135	7	member	7998265283967	7	9	4
136	51	member	860358	7	9	7
137	9	member	6387419836415	7	9	1
138	8	member	4796353779539	7	9	5
139	5	member	5861205555378	7	9	8
140	4	member	6387581887270	7	9	7
141	55	member	861155	7	9	7
142	6	member	5862576947371	7	9	3
143	46	member	8612497029	7	9	7
144	18	leader	1131812795642	7	9	7
145	12	leader	1133797856589	7	9	1
146	15	leader	1417567383898	7	9	4
147	19	leader	1038047106626	7	9	8
148	20	leader	850475924767	7	9	9
149	14	leader	1040384406195	7	9	3
150	16	leader	850432788895	7	9	5
151	17	leader	0	7	9	6
152	13	leader	0	7	9	2
153	2	member	8551269396004	8	10	9
154	7	member	9000088428216	8	10	4
155	51	member	889923	8	10	7
156	9	member	3309867143644	8	10	1
157	8	member	7575075272839	8	10	5
158	5	member	2837255022898	8	10	8
159	4	member	6618664154500	8	10	7
160	55	member	890748	8	10	7
161	6	member	8993761397616	8	10	3
162	46	member	8908452857	8	10	7
163	18	leader	1175141897994	8	10	7
164	12	leader	588772488574	8	10	1
165	15	leader	1598010493265	8	10	4
166	19	leader	504025642473	8	10	8
167	20	leader	1513631823670	8	10	9
168	14	leader	1599100466431	8	10	3
169	16	leader	1345365611535	8	10	5
170	17	leader	0	8	10	6
171	13	leader	0	8	10	2
172	2	member	8257514830207	9	11	9
173	7	member	5484147149859	9	11	4
174	51	member	613158	9	11	7
175	9	member	4109492438340	9	11	1
176	8	member	3654911420422	9	11	5
177	5	member	7748288956882	9	11	8
178	4	member	4566159938736	9	11	7
179	55	member	613726	9	11	7
180	6	member	8690542788724	9	11	3
181	46	member	6137917316	9	11	7
182	18	leader	812059944973	9	11	7
183	12	leader	732154313061	9	11	1
184	15	leader	976270804403	9	11	4
185	19	leader	1380404909222	9	11	8
186	20	leader	1464139006401	9	11	9
187	14	leader	1546941127557	9	11	3
188	16	leader	650790906717	9	11	5
189	17	leader	0	9	11	6
190	13	leader	0	9	11	2
191	2	member	4185731313272	10	12	9
192	7	member	5727222769068	10	12	4
193	51	member	768862	10	12	7
194	9	member	3122932578363	10	12	1
195	8	member	9380145986626	10	12	5
196	5	member	4157114615043	10	12	8
197	4	member	5725646596529	10	12	7
198	55	member	769574	10	12	7
199	6	member	2607245551612	10	12	3
200	46	member	7696561152	10	12	7
201	18	leader	1020203875689	10	12	7
202	12	leader	557583625765	10	12	1
203	15	leader	1022066611823	10	12	4
204	19	leader	742143602528	10	12	8
205	20	leader	743485982828	10	12	9
206	14	leader	465220504271	10	12	3
207	16	leader	1672110154649	10	12	5
208	17	leader	0	10	12	6
209	13	leader	0	10	12	2
210	2	member	7105482374356	11	13	9
211	7	member	4860181482899	11	13	4
212	51	member	832248	11	13	7
213	9	member	3983541025837	11	13	1
214	8	member	5309358060746	11	13	5
215	5	member	6179344522758	11	13	8
216	4	member	6197658137192	11	13	7
217	55	member	833018	11	13	7
218	6	member	6195597037529	11	13	3
219	65	member	4135970265	11	13	8
220	46	member	4172931651	11	13	7
221	18	leader	1105822210541	11	13	7
222	12	leader	711870746481	11	13	1
223	15	leader	869817749416	11	13	4
224	19	leader	1104670136632	11	13	8
225	20	leader	1265209623549	11	13	9
226	14	leader	1108060525779	11	13	3
227	16	leader	948848746373	11	13	5
228	17	leader	0	11	13	6
229	13	leader	0	11	13	2
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
5	107	\\xe26f7f0bb3c1df15a72a7777a82624420548b5a4ed606f93097f6e54	timelock	{"type": "sig", "keyHash": "0aec81811dab827e8cabe062cbf291115bdcc21c66030f0b3164894f"}	\N	\N
6	109	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	timelock	{"type": "sig", "keyHash": "5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967"}	\N	\N
7	124	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}]}	\N	\N
8	135	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}, {"type": "sig", "keyHash": "3178bf14adf78294ac2d03d60b9edfb7323d3d719e98b4b0b3ca34cd"}]}	\N	\N
\.


--
-- Data for Name: slot_leader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slot_leader (id, hash, pool_hash_id, description) FROM stdin;
1	\\x115874cae636c9320fbd207f533ed91491c1adb9c69477d6d1646e88	\N	Genesis slot leader
2	\\x5368656c6c65792047656e6573697320536c6f744c65616465722048	\N	Shelley Genesis slot leader
7	\\x22da702c66e77e4ef93383962bff03e49318dd505b42d9d55dd87a43	2	Pool-22da702c66e77e4e
11	\\x113104a69508f2bc629d67c9a202a41d114960ce3541d2e3dad953e8	1	Pool-113104a69508f2bc
3	\\x61a34b4c64319736cdbf2374d5082d3867a7871cf90e3a6d259ea55b	6	Pool-61a34b4c64319736
5	\\x7d1f8ae7b5330208dac263c69d98d0bd2a113d54014a96aab991b806	8	Pool-7d1f8ae7b5330208
9	\\x5ae4f3c1648dc6cff686c82e52a28bcf85f6f95d8df4cf7e52863d4b	5	Pool-5ae4f3c1648dc6cf
8	\\x7eaaab7668bb08d7b8ec533e3e9395d205218640c46106390a253d56	9	Pool-7eaaab7668bb08d7
19	\\x93bf0873eb7afd7d87ce9321e6a0b33217f865dc3244f379c4887197	10	Pool-93bf0873eb7afd7d
4	\\x3f8a639841a8ded753dee1453637d22fc9087f60d8a68bc5bf925a20	4	Pool-3f8a639841a8ded7
27	\\x7c6650b98817d99528db45fea9ba86520c748a932377549447a5a823	7	Pool-7c6650b98817d995
6	\\x9f37628b233a3f37c91d6606d51c39446b293921f39d8c11446e98df	11	Pool-9f37628b233a3f37
12	\\x3046520e763319fe9b71c3f216f5f1c00024982abfb9f7ed6c414408	3	Pool-3046520e763319fe
\.


--
-- Data for Name: stake_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_address (id, hash_raw, view, script_hash) FROM stdin;
2	\\xe01be28ded355d275802d3ad50e8e327c2114db60083415634cd632c85	stake_test1uqd79r0dx4wjwkqz6wk4p68rylppzndkqzp5z435e43jepg5fh0qp	\N
7	\\xe0537a5c2f2ea9c650e7abdee1ed8c4686ae9a1c2b25fc35ccf0370374	stake_test1upfh5hp0965uv588400wrmvvg6r2axsu9vjlcdwv7qmsxaqy7fdld	\N
1	\\xe081f93b2ddcc3d51410c24bc3bd46948bb098ee75bc1c662da23e9a35	stake_test1uzqljwedmnpa29qscf9u802xjj9mpx8wwk7pce3d5glf5dg6lswx4	\N
9	\\xe08b1d6f3db5071ce7d0083a73ceb6a912c0a0b61353c6da5a2b247101	stake_test1uz936meak5r3ee7spqa88n4k4yfvpg9kzdfudkj69vj8zqgxlp693	\N
11	\\xe093e1242ecfb41af608885fbc3579342aeb897d33942d85e8351dc59a	stake_test1uzf7zfpwe76p4asg3p0mcdtexs4whztaxw2zmp0gx5wutxshcyy60	\N
8	\\xe094b1180bf1b98e1efa837189a00eec23c05f3cd29694680a82262653	stake_test1uz2tzxqt7xucu8h6sdccngqwas3uqheu62tfg6q2sgnzv5c6fjxld	\N
5	\\xe0b37a177d2e15b97ced8e40b71f88c7b0ffcf8cc8100f99aff9608499	stake_test1uzeh59ma9c2mjl8d3eqtw8ugc7c0lnuveqgqlxd0l9sgfxghyg3pz	\N
4	\\xe0ba755c20c5e86e6f72feb188d6af027cf41cde1b21d2ab2cd83e58b8	stake_test1uza82hpqch5xummjl6cc3440qf70g8x7rvsa92evmql93wqd2ssnw	\N
10	\\xe0c32f3bc1fc83a155c961c2004c32d07f270a7d9be9bf2f40c91b3dbf	stake_test1urpj7w7pljp6z4wfv8pqqnpj6pljwznan05m7t6qeydnm0c60ctkh	\N
3	\\xe0c4f68b05c9aee0124feac94ab1f56a19de9a1074279684400726a95c	stake_test1urz0dzc9exhwqyj0aty54v04dgvaaxsswsnedpzqqun2jhqz0rlj8	\N
6	\\xe0d2dcc376381c292cbee34f7790bbb06ade116ce9bb31e00ee471be57	stake_test1urfdesmk8qwzjt97ud8h0y9mkp4duytvaxanrcqwu3cmu4cxd6792	\N
16	\\xe0a95a97b4dedce6fd7978f64d67f91e9b54e79b4a06887be9cf6e59d5	stake_test1uz5449a5mmwwdlte0rmy6eler6d4feumfgrgs7lfeah9n4ga8vp4u	\N
14	\\xe0a8afb2f78b3f505ee22ca4a0bd9faf758c5232b85a1a07418fe2df7a	stake_test1uz52lvhh3vl4qhhz9jj2p0vl4a6cc53jhpdp5p6p3l3d77sllu2zv	\N
17	\\xe0bb84cebb65e36124d4129734aa4e3c8dc7a38dbf8172d42f40b501a3	stake_test1uzacfn4mvh3kzfx5z2tnf2jw8jxu0gudh7qh94p0gz6srgcps4rhf	\N
12	\\xe05958a1cf1c8bf8e5f2a2aa00cbcf40eaf7b34d53e55100c3b465539e	stake_test1upv43gw0rj9l3e0j524qpj70gr400v6d20j4zqxrk3j488svdjdas	\N
19	\\xe06f74a6cfd937424632103777fece21e9c2e63a50b6feffdc489cb263	stake_test1uphhffk0mym5y33jzqmh0lkwy85u9e362zm0al7ufzwtycculfmdg	\N
15	\\xe067f0c148e25f659d8ebf3c4380a65f273ef07c79925e13da6b7b76c1	stake_test1upnlps2guf0kt8vwhu7y8q9xtunnauru0xf9uy76ddahdsgptwx05	\N
18	\\xe051f6e3a7e5abd5c7fcfda7fd44eb5766bc2f2a791748232312a5a995	stake_test1upgldca8uk4at3lulknl638t2antcte20yt5sgerz2j6n9g8zdgg5	\N
22	\\xe0657b7a63f1c8e2477ba747108b0dadd2c802238c916aa272f5a78984	stake_test1upjhk7nr78ywy3mm5ar3pzcd4hfvsq3r3jgk4gnj7kncnpqu05557	\N
13	\\xe0c0710e5084cbf97e21d91b6e83b04e10c9e0e594ad5abc35969e8000	stake_test1urq8zrjssn9ljl3pmydkaqasfcgvnc89jjk440p4j60gqqql5w77j	\N
21	\\xe0a93680fac831171a752304de3f3ac41f2a9ef45d40df16d4bd2b5078	stake_test1uz5ndq86eqc3wxn4yvzdu0e6cs0j48h5t4qd79k5h544q7q7f3vyg	\N
20	\\xe094cddc140b1bfa4c93f394657b55cfbac104eb77ff81efc749ef9434	stake_test1uz2vmhq5pvdl5nyn7w2x2764e7avzp8twllcrm78f8hegdq4d57nj	\N
47	\\xe01bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	stake_test1uqdlrcfc7tuta27fv0y5es5wark5kst5gcql9md02zepalg9yxxuz	\N
49	\\xe09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j	\N
50	\\xe07d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	stake_test1up73dx2qeg7gv59739gpmycmxzffyqk3ha2ctmh9ghdgneqmy000q	\N
51	\\xe072263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	stake_test1upezv0agh8cq09rt33ardnh8pdstd3lwpa5s64g2pne0uqgcygw6k	\N
52	\\xe08de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	stake_test1uzx79ge8d7gkx27vu3k9xgj9zlra0fvat5d5lxcnzm9n7hc8yk6td	\N
53	\\xe04f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	stake_test1up85ec98csnkgus5dw3x8u25mlkgu8m63hvw650ukldv04q6rf54k	\N
54	\\xe00ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	stake_test1uq8lxxfr92332xgqp66eenhpw7z04q09czgjf6uvnku20fq023mfy	\N
55	\\xe0ce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	stake_test1ur89gkdpkj42jwy3smuznfxcjdas0jz64xtckt9s8kz8h3gj4h8zv	\N
62	\\xe03c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	stake_test1uq787vm0znxp40ugac3hx3psql63rmxzwwued8yvx2auqfqk9cn87	\N
46	\\xe0f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	stake_test1urc4mvzl2cp4gedl3yq2px7659krmzuzgnl2dpjjgsydmqqxgamj7	\N
65	\\xe0f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	stake_test1urcqjef42euycw37mup524mf4j5wqlwylwwm9wzjp4v42ksjgsgcy	\N
48	\\xe0e0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	\N
45	\\xe0a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	\N
\.


--
-- Data for Name: stake_deregistration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_deregistration (id, addr_id, cert_index, epoch_no, tx_id, redeemer_id) FROM stdin;
1	46	0	5	147	\N
\.


--
-- Data for Name: stake_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_registration (id, addr_id, cert_index, epoch_no, tx_id) FROM stdin;
1	2	0	0	34
2	7	2	0	34
3	1	4	0	34
4	9	6	0	34
5	11	8	0	34
6	8	10	0	34
7	5	12	0	34
8	4	14	0	34
9	10	16	0	34
10	3	18	0	34
11	6	20	0	34
12	16	0	0	36
13	14	0	0	41
14	17	0	0	46
15	12	0	0	51
16	19	0	0	56
17	15	0	0	61
18	18	0	0	66
19	22	0	0	71
20	13	0	0	78
21	21	0	0	85
22	20	0	1	92
23	51	0	4	132
24	52	2	4	132
25	53	4	4	132
26	54	6	4	132
27	55	8	4	132
28	46	0	5	146
30	46	0	5	154
31	65	0	9	256
32	48	0	13	360
33	45	0	13	363
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
1	\\x59efe59ea611368942c34a3740c23b99f1c13161ab4f247ccf10b4e3a7825622	1	0	910909092	0	0	0	\N	\N	t	0
2	\\x0fecd6c4754f558d6f2629969e002f5174d4c930878ae5406e5be90d3bf41697	1	0	910909092	0	0	0	\N	\N	t	0
3	\\x70b6827d67f66972e420ac03fb138fabc366aa66eef560eff2577ac0998d8361	1	0	910909092	0	0	0	\N	\N	t	0
4	\\xa6147c1d1aabe965622054862d8eef18e4991c6da0c7440a22d95200ab4010a8	1	0	910909092	0	0	0	\N	\N	t	0
5	\\xdc9cb3acda36af70ee293838fb8694807c407a8976a3dd1bdb45ed1f43d227cd	1	0	910909092	0	0	0	\N	\N	t	0
6	\\xce68a393f986632ccd09561e5cc72921eabff351788265bdb1ccbe04f4929d06	1	0	910909092	0	0	0	\N	\N	t	0
7	\\xff243a32527e34b6cb4b0ac20702a3ff224f03694fd70c412d09a2b263598157	1	0	910909092	0	0	0	\N	\N	t	0
8	\\x4743a11ca0948a9bec6679dba8030cb9d8e94f8ec1261383042dac945bbc254c	1	0	910909092	0	0	0	\N	\N	t	0
9	\\x685924b5298d0e95d16936e6ebca3f7e2e177920c0514f80000c48302629a142	1	0	910909092	0	0	0	\N	\N	t	0
10	\\x417bc23c49c37e26c601720ee4bc490d029673d6eb22e9296e0ac78d101ed5b2	1	0	910909092	0	0	0	\N	\N	t	0
11	\\xb4ae24dcaa0c6b2affcc4e25d095b5a4361cc78abb0685e2448598266b64e145	1	0	910909092	0	0	0	\N	\N	t	0
12	\\x0d1335f2195cd204f1c87d99e4f88878da8b270dae5bf1f4415436d581f4036c	2	0	3681818181818181	0	0	0	\N	\N	t	0
13	\\x1884519f8db58a5bb15e5db37f33bab6b541196ca2e2479a0dacf23782a7c5ee	2	0	3681818181818190	0	0	0	\N	\N	t	0
14	\\x2d6ff1ba9a9ad2a7190c2c5201924f5a9ec856522be24193e6e6c39c75663e79	2	0	3681818181818181	0	0	0	\N	\N	t	0
15	\\x407bd5803d72af7b096c0ed92a6df01927c22cb112d8a7dd96c1faee018d5e8c	2	0	3681818181818181	0	0	0	\N	\N	t	0
16	\\x45e15c7b0b203fe0a21752c3c1234da1ae697565d5aa6959973ab9d5d53708ea	2	0	3681818181818190	0	0	0	\N	\N	t	0
17	\\x4dd46d71e115d29ff4d5a3a16d4922a87fbc493973fd339d11323cccd009f3ac	2	0	3681818181818181	0	0	0	\N	\N	t	0
18	\\x506d32ff7d19665be2b80d91f281e43f7974bf021d5dc3bb551c125dff48d4e1	2	0	3681818181818181	0	0	0	\N	\N	t	0
19	\\x56374da000f2ffe5ded313cf0469002a387c470659906f641b42919c08949ab8	2	0	3681818181818181	0	0	0	\N	\N	t	0
20	\\x5c5ac92c9fab006d419fe188983f8c89aab930e1d450b99d458bf7e438995db5	2	0	3681818181818181	0	0	0	\N	\N	t	0
21	\\x6f0ac620e7ca5a56eb15af4105a67f49fae13c63651377425f00484ec731cda9	2	0	3681818181818181	0	0	0	\N	\N	t	0
22	\\x7b65292f1ed69af0234e786acb6233402c3c21337bbdb4505ef4dd6b95165d19	2	0	3681818181818181	0	0	0	\N	\N	t	0
23	\\x7c74a765b8c1a59324d2e20729f1237c8a5a6de82c9be84092553cbd9bc93f9c	2	0	3681818181818181	0	0	0	\N	\N	t	0
24	\\x83cc805fcd78113f7296da7ae81740ddde4e4f6eea3c6f29036d78149b2be27c	2	0	3681818181818181	0	0	0	\N	\N	t	0
25	\\x87af3c85a27b9fed6396b4ad4ed6c0fa4f3f92db4b06997b6cf46941e57acc7f	2	0	3681818181818181	0	0	0	\N	\N	t	0
26	\\x8cdc658559a7490fbf2a0bcefcda43987a7efd64b3f29843441fd3d885aed7ef	2	0	3681818181818181	0	0	0	\N	\N	t	0
27	\\x9850786a396bb026d6464099d94bd8c650f78871f53b0b9d1d3ea04fd8e400ae	2	0	3681818181818181	0	0	0	\N	\N	t	0
28	\\xa9b3b237949abe0e2d3419ada6c59a82480c5373adf9b14148f1871a8d59da36	2	0	3681818181818181	0	0	0	\N	\N	t	0
29	\\xadd269185ca37f52d264a73ff3fd9df1b94de9892933092d1b270330eeb8312d	2	0	3681818181818181	0	0	0	\N	\N	t	0
30	\\xaddc6bb92ed8ad9764dd4dd4603a2ec4ee2d026d622eb8921fa9632477f7d7d2	2	0	3681818181818181	0	0	0	\N	\N	t	0
31	\\xb2d341e1b476f1b977a873d7589a74a84ba70f946e2b5462577775b93d8bfa73	2	0	3681818181818181	0	0	0	\N	\N	t	0
32	\\xc089a45bc055106d15dabc2f835925f608801c5765bc7693d8ca9ac446b5aa80	2	0	3681818181818181	0	0	0	\N	\N	t	0
33	\\xc55b6e604ad8a15311812d09cb29dade4f315aaf15af491e10457c64813849f3	2	0	3681818181818181	0	0	0	\N	\N	t	0
34	\\x5368656c6c65792047656e65736973205374616b696e67205478204861736820	2	0	0	0	0	0	\N	\N	t	0
35	\\x4e6e7cde0f9aed2a82ee99997ed7d1a17a7aade11d5cce4884d08ce051e624d2	3	0	3681818181651228	166953	0	263	\N	\N	t	0
36	\\xf661ac796c882ff640c7ef0566810e932e16b79cd79014bc83d2d7164c368bb2	4	0	3681817681473231	177997	0	339	\N	5000000	t	0
37	\\x49a714b05d15af1f763f569dbef5cdab29d596d1174eb2257cfd6fa769f4bb11	7	0	3681817681293914	179317	0	369	\N	5000000	t	0
38	\\x4066804eda3be60cf59a5cb02d10fabfb7148a58497a8bbac2500c0b76b91474	9	0	3681818181637632	180549	0	397	\N	5000000	t	0
39	\\xc21b4bf1c4a83c1b1573b0d1dee68196c823875ca6facfe13d9dad7ae3065655	11	0	3681818181443619	194013	0	653	\N	500000	t	0
40	\\xf19245ad5a156e96dfd701f599d1408c3c2cfbd1e8609433af054da34110c59d	13	0	3681817681126961	166953	0	263	\N	\N	t	0
41	\\x4eeb63391a5d41d240cc59c43bead0b07810d57da7ad8d5cafb93af8f52a05e8	14	0	3681817080948964	177997	0	339	\N	5000000	t	0
42	\\xd7a62b10b6f7bff9709d733d450f14d9217dd6192b6f28d31b330e59c5f87ecb	18	0	3681817080769647	179317	0	369	\N	5000000	t	0
43	\\xccea85aa0eacfeb59af6f66ae6cd3ccf55f7f1b83e57ff861c1592a9929d8f50	19	0	3681818181637632	180549	0	397	\N	5000000	t	0
44	\\xf0dd7b46a2d8b1e06815dbe6b415cfef0a0c1f956d9b69e7469335015348aaab	20	0	3681818181446391	191241	0	590	\N	500000	t	0
45	\\xe6f3597de537e71f26bfa070ca42b6d90602e1a2b78943d464ac00eadee2e7c4	23	0	3681817080602694	166953	0	263	\N	\N	t	0
46	\\x7183dc1e2ceb163e94f3727653e26fc523ea1c5c2cb11cbde9805500eebe436b	27	0	3681816880424697	177997	0	339	\N	5000000	t	0
47	\\xaf517e6e8a18ec989cf3d9b14c9bab80e56c855df382a4327eddb268b149d921	29	0	3681816880245380	179317	0	369	\N	5000000	t	0
48	\\xede744194823ed0ca65c9f2bcef112c128c07f75bf256f7779e9f33eb7abc35b	32	0	3681818181637632	180549	0	397	\N	5000000	t	0
49	\\x714e1839895f2e8810294cc1cfa52fc3b4af9a76375be98eb00908449b251e28	34	0	3681818181443619	194013	0	653	\N	500000	t	0
50	\\x9ed7d725e781c94927ae85daa408eadb0040b10b3557a510299adb191d61391b	36	0	3681816880078427	166953	0	263	\N	\N	t	0
51	\\xdda08b28503fca20c46b7d5b7cabb6e6b24f8009546cfaa9174f862899031b3c	39	0	3681816379900430	177997	0	339	\N	5000000	t	0
52	\\x1f8cb6f15ad0404ebe24e568642ccf21068d2304c67e4468d365e71f31589120	41	0	3681816379721113	179317	0	369	\N	5000000	t	0
53	\\x79281924e4dcfccfc6f0768632ab5e4fcdc32e3e15f7c9c68734a5c0719ff87a	42	0	3681818181637632	180549	0	397	\N	5000000	t	0
54	\\xda3944a5b77b8c9e44ce07aabf2fa49c1e853a5dfb5a3315590d1e96cff600fe	44	0	3681818181443619	194013	0	653	\N	500000	t	0
55	\\x49ae353b5dbb4afbd632d9975ec19900325c5c3d41ff0606f9a8d61bd061b622	46	0	3681816379554160	166953	0	263	\N	\N	t	0
56	\\x3a88cde5920d7ef3a46bfc02b3cd78660e6f1046b5acfcddfeef9651c60b48f9	48	0	3681815879376163	177997	0	339	\N	5000000	t	0
57	\\x07893d93ece0942aecfc19101072b82ee7fbb66efb8590926484fcd0eb22cfdb	49	0	3681815879196846	179317	0	369	\N	5000000	t	0
58	\\xa7284f072f387798e1a4e97eb9c53007044b65932c5b4c12bf7215ebaa180c41	50	0	3681818181637632	180549	0	397	\N	5000000	t	0
59	\\x8b9dcb39d65adcf28998014d2a650b19497e2cf0ee24bc8c5f3cbf25b5bb08aa	53	0	3681818181443619	194013	0	653	\N	500000	t	0
60	\\xac4747c5ee0765e056f8e9d060c32ba4254d49172d856fa50d7ea4e34df0209e	54	0	3681815879029893	166953	0	263	\N	\N	t	0
61	\\xf51ddbd7fe71810663ee17a48643b77678226bc317e07f8312731c5a3d57abd3	55	0	3681815378851896	177997	0	339	\N	5000000	t	0
62	\\xd5a1e206edab3def28b87a7452e5e6da4d08becbc83f5414f935616a1c58a72d	57	0	3681815378672579	179317	0	369	\N	5000000	t	0
63	\\x8c047a9e568831a613f253e8049fde615e7d9dc51de0fa69d5a16684f9e3dea4	61	0	3681818181637632	180549	0	397	\N	5000000	t	0
64	\\xf723943e995c4083d545512e9f23435056f33483e28dde6e3ebeb6fd73b44c17	62	0	3681818181443619	194013	0	653	\N	500000	t	0
65	\\xd4e935c228394e76ad249c70db530abcf879b73bd762eb9967cd5c35a85efc6c	65	0	3681815378505626	166953	0	263	\N	\N	t	0
66	\\x3103887daa57e9c000e0ef2e87f6ec3ea0f035adee435918014e8df33c3c3ef1	67	0	3681814878327629	177997	0	339	\N	5000000	t	0
67	\\xc08b11501b1e22acb46b729ee643fab92e6bca4e7ac8902e43aab471f45896bd	70	0	3681814878148312	179317	0	369	\N	5000000	t	0
68	\\x8375cba45b66c538fd68dc0446f4115c16c2329e99c48602a733613192ada368	71	0	3681818181637632	180549	0	397	\N	5000000	t	0
69	\\x36d2ec67debb72958d83709cdf74c3f55afb516bb4a3a50708663d91fc317f3e	73	0	3681818181443619	194013	0	653	\N	500000	t	0
70	\\xdb140f4bf77a9b0c6cb3094f774f4885997cbc0ae9cce79e5f85337102a8b3ef	75	0	3681814877981359	166953	0	263	\N	\N	t	0
71	\\x336ff08d2d9f96987fc91ae9898ec477581950df3a65a7f864883fd0bd9a6cc7	77	0	3681814577803362	177997	0	339	\N	5000000	t	0
72	\\x300da1f9712a8a7317e96fe85be6a4ccee8c83d27239f38665fa5ac4260635d8	78	0	3681814577624045	179317	0	369	\N	5000000	t	0
73	\\x3fd19402cff7442cb22dac35fde892dd989d80cfe8f8f787df3b10f24761eddb	80	0	3681818181637632	180549	0	397	\N	5000000	t	0
74	\\x182b9c9a81c3d9c881ff0cb97ba31f42f436d6cda027b2474a16d832e35f9f99	81	0	3681818181446391	191241	0	590	\N	500000	t	0
75	\\x85a66c3dafc960faba2e06391e4161e86db9623e73130a15f6968b25c39b0ba5	83	0	3681818181265842	180549	0	397	\N	5000000	t	0
76	\\xce95c5c9907a01fed3a8d24912116d4ed2b870ce394065bca613fdb9e91401e1	84	0	3681814577439800	184245	0	439	\N	500000	t	0
77	\\x673d6cd698a2a622e5058db56b0be2d45432a63f6960fa5836441e4abeefb0f9	86	0	3681814577272847	166953	0	263	\N	\N	t	0
78	\\x6a0d23ce340d1b6170639f3841bd3a9e96a398083a47f7a8ebc8a534a7708109	88	0	3681814277094850	177997	0	339	\N	5000000	t	0
79	\\x2fcbcde1b359d9110c90872332afeb257a2c60a9b5f445809ee77c54dcc0c11c	90	0	3681814276915533	179317	0	369	\N	5000000	t	0
80	\\x8805b5a5d258e281f68cea975204356e3f9592044268d04f3f4af994d41f4802	92	0	3681818181637632	180549	0	397	\N	5000000	t	0
81	\\xeab69ad8702e89d6cd4c09d848e7fe83c972f8d00077e22455168d0c53362452	93	0	3681818181446391	191241	0	590	\N	500000	t	0
82	\\x3239b9a3f446cb75f25e7373d0ed1a066c25a2790824873311030d1fac9e827d	95	0	3681818181265842	180549	0	397	\N	5000000	t	0
83	\\xe4a0e25cd8dff15ee525ddefb2bd53e8232a916634a969532a12bd5fdc1fc6a4	98	0	3681814276731288	184245	0	439	\N	500000	t	0
84	\\xc98ed03c1f85b914c39a79caae02f64253d17a741edc9cf78b682e677b7705c7	99	0	3681814276564335	166953	0	263	\N	\N	t	0
85	\\x4e38f38a080a4b853d140cf2210ee51989541482cb5d43e09b300a71dd698beb	100	0	3681813776386338	177997	0	339	\N	5000000	t	0
86	\\x6bc469357451bdd7fd6e8ad1a611cc908c0d5faa4ecf69487a70d54fa30210a7	103	0	3681813776207021	179317	0	369	\N	5000000	t	0
87	\\x02d7b27019e2982c05dac86e3345f871cc6e60e9399ef2dd2070c6b93ece8171	104	0	3681818181637632	180549	0	397	\N	5000000	t	0
88	\\x5d34ad243a4166d923b6f6aee691b865a11b0df3d2797580b03e70c9b5c69048	107	0	3681818181443575	194057	0	654	\N	500000	t	0
89	\\x45a4e9c78a8a2f6f62e56f6965b6713a3ab45f911242359d1418f5ca2cebcbe0	108	0	3681818181263026	180549	0	397	\N	5000000	t	0
90	\\x0bb8bf376486aa9ae51ccc663de375002df459e73d9bf6e9fb6f50d3673e81fa	111	0	3681813776022776	184245	0	439	\N	500000	t	0
91	\\x5af0799e226e83ab9e4a38032c55049a03d5c341d62c5b06830ef694704fe621	113	0	3681813775855823	166953	0	263	\N	\N	t	0
92	\\xf63521163174076aa0601a6b194fa85c3ef9c3641efe881bfda884f873f29072	114	0	3681813275677826	177997	0	339	\N	5000000	t	0
93	\\x26d4e8df5b3b7aa9e626d575d5f454c2a750ce1fd3847b24f125a51ae3ac1bef	117	0	3681813275498509	179317	0	369	\N	5000000	t	0
94	\\x69dc7608140d3c173c7b11b66ac997f351b42bbb2cca752b373fb00bd13b5997	119	0	3681818181637641	180549	0	397	\N	5000000	t	0
95	\\xd9a3a14aa066f79878dbddc1eb7aee3f263742a22adb889e7546fc1bbbbbe559	120	0	3681818181443584	194057	0	654	\N	500000	t	0
96	\\xa28c5d8938a337309912a24295defe3e6cb2cd2398de4cfc5b0ebbe439689163	121	0	3681818181263035	180549	0	397	\N	5000000	t	0
97	\\xcbfbc04933ece6b35dacd5c7297bb15a23746401b950815a610c8df9813a841f	123	0	3681813275314264	184245	0	439	\N	500000	t	0
98	\\xa99b7fdbcc5657ec92324cd1568d1153ff2f13fb5bdf2b36ae9cc979e957ad52	125	0	3681818181650832	167349	0	272	\N	\N	t	0
99	\\x7f37383fe00cd35ce66a90d746c3245653264c6f2a99978a1c1b4e4b6d6a062c	126	0	99828910	171090	0	350	\N	\N	t	14
100	\\xbcfc775755bdfad737a3816942fc2b48b1737d1c8194a1dcae2a472893be2ebc	127	0	3681818081484759	166073	0	243	\N	\N	t	0
101	\\x5b79481be58f1cb77351bd63a8ce64bc733f8485a8c476ae6f71421ee941e472	129	0	3681817981314374	170385	0	341	\N	\N	t	0
102	\\x8c00bd56cd34c487fe9cf0a71ba91bf25f2746da37309add5ef9791e0c768698	132	0	3681817881146585	167789	0	282	\N	\N	t	0
103	\\x2f13fbe0ffde9d7085195096be3a897bd5be1642494e8cc7d35da45d8f9329fc	133	0	3681817780979940	166645	0	256	\N	\N	t	0
104	\\x85762a8bf832af0e0ac5e22e23179fbd2f047f7565a2d81eeaf48f8c25e3fa98	137	0	3681817680717067	262873	0	2443	\N	\N	t	0
105	\\x52460b6561454cf34d2d687b977b38f7263a6d78dbcb817a5e187a96852ffbe0	140	0	3681817580550950	166117	0	244	\N	\N	t	0
106	\\x97e7ed3e150961661a93c318f8ffc4c1e58e30dc3141430288f3990549a4179e	141	0	3681817580223603	327347	0	2613	\N	\N	t	2197
107	\\x513a5fb7b50f87421465982b98a9e0b51cc315af62f59be015a31e9bbe968526	142	0	3681818181642252	175929	0	467	\N	\N	t	0
108	\\x219ffd8202fcbe1237b8e26942e51e1a284eb33a228a8cc94168db5c45654aa6	145	0	3681813275134639	179625	0	551	\N	\N	t	0
109	\\x1a04f51c0cceb421949057422a896b1f058ba56a827002da264652e6e30a44a9	146	0	4999999767575	232425	0	1751	\N	\N	t	0
110	\\x96859f395268f510932ac4eb570219f7cfa1d990a21c03c2dc0485f4ae3ba980	147	0	4999989582758	184817	0	669	\N	\N	t	0
111	\\x830e78930f4caa6b01e98f9b568f8479e1b68c2b10c3e77a3727a9356d3938fd	433	0	4999979347913	234845	0	1700	\N	5529	t	0
112	\\x872846be0aa593faef732b62a73f682bec03e3220fbf84e1403f7e6ee0f1065e	437	0	4999979173480	174433	0	428	\N	5595	t	0
113	\\x718dc64389d57b23db3d2f2f7f7339e91dbcd66215382215f799c613b17bd3e8	441	0	4999959002479	171001	0	350	\N	5628	t	0
114	\\x83997f7f4d11a89e8a8615157bd1cedb629a784001b5b942dad9d63f9516a367	445	0	4999938828398	174081	0	319	\N	5688	t	0
115	\\xc82193adcc937f2bbdeea8873103fb06635a8858bf69492ec687de79cc873281	449	0	19826843	173157	0	399	\N	5719	t	0
116	\\x6a1613aa161c4dbdb3fac2470ac96f45bdfcf150ea965ad62827c9fee8c37c3e	453	0	4999938635573	192825	0	745	\N	5745	t	0
117	\\x9d42a08fdc483fa30d64a4b7ce3bdb6bda83877510c4c82d8784f6b79bcf8f7a	457	0	4999928442748	192825	0	745	\N	5766	t	0
118	\\x7210162fb06c70ae1f4abdbf7fe7613858b83c9c0ffbca93d9aede00d6ff1a75	461	0	19825259	174741	0	334	\N	5785	t	0
119	\\x51611e5ffa4eb11435a05ce1f4cbd03259a607b4f8088a535eca7ff07f334770	465	0	4999918249923	192825	0	745	\N	5828	t	0
120	\\xaabe954be42e64b9731bcbce8fcded0fce0683c9fab53d3426d582694edb8e5e	469	0	9826843	173157	0	298	\N	5868	t	0
121	\\x632368c456ba92edd178b63a7cffcca8e05b29cf44c78a588733f5186f4de17d	473	0	19632610	192649	0	741	\N	5885	t	0
122	\\xb51e7cea3195ba1e556ff851433268a8aef0bf67252bdaffd68eba6ed3913c6b	477	0	9824995	175005	0	340	\N	5920	t	0
123	\\xef3ef836b2148bd7eda1af645a6dd69e17b8084cead7782bcac5270a5a94820f	481	0	9651838	173157	0	298	\N	5958	t	0
124	\\x47351df27ed916d99ce242cb4bef524946a94a430b86f6797d083990ca393356	486	0	19273272	205409	0	1132	\N	6022	t	0
125	\\x04c057bb00efa1964a86fd73068c11e4f7bef84d3dfe36f07f092ea631804f4e	490	0	19452545	180065	0	556	\N	6057	t	0
127	\\xbd95256c9a9d78145b603bdd37e70617f192c57bd2f8c034738effa9c8283dde	495	0	4999908062730	187193	0	718	\N	6103	t	0
128	\\xff48e5b56359a6e000aeac59d652b0258a738151519a81b690ecb810a15a2522	499	0	4999897876065	186665	0	706	\N	6185	t	0
129	\\x7e6f2d88d8fb2e9d5abcaa448b0bd35c11d73feb735ab33d8d34be200d4bce5d	503	0	19811795	188205	0	741	\N	6228	t	0
130	\\x90047c5f0e1c3ea913a48aab6c7a5f5a4d0b6c0483cf6f931f0e0ce547e9d5c5	507	0	39083703	180637	0	569	\N	6267	t	0
131	\\xa9e9c6eb96670fc7aa81b10a9f9433316e6561b435d3547e304c36ec33546a14	511	0	4999926789779	169989	0	327	\N	6299	t	0
132	\\xb142a9b2f07fa638fb3502017072e9dfbed0931565d09979dc9d4b9ac0ee762a	515	0	999675351	324649	0	3846	\N	6364	t	0
133	\\x59560ad740c4f08fe95ffd0f428bedd4e01df1d3b19fd2466428c0deac175a2f	519	0	999414590	260761	0	2394	\N	6414	t	0
134	\\x0c350c63926f64a80c7c8f871a45b542b29cc31e705a1c9486aa0a0d03b8741d	523	0	499375158	201757	0	1049	\N	6440	t	0
135	\\x2766577ac5fdbd996377eee16c9eedf6f5682e53dfd187f8c9a859adb912308a	528	0	9089599	183673	0	638	\N	6469	t	0
136	\\xeb3d49aa02f3774b51f808a80b475e8e75bdf046c7c1287bff8f029f0f5a1561	532	0	2820947	179053	0	533	\N	6548	t	0
137	\\xa96e5376f1e4a63d76a9fcd0b8eff8cd0d2e1288173269a693a9932b748189f9	537	0	5912218	177381	0	495	\N	6603	t	0
139	\\x82821e22d5435f9e1770363faf20fa058fb195b641c33012b400d2797d172de7	542	0	2827019	172981	0	395	\N	6639	t	0
140	\\x17815b5147248527b95613d15d9b028794c83ca90303113c1dbf32aabe6ee6a4	546	0	4998935176630	173333	0	403	\N	6657	t	0
141	\\x6129c27cb9ba556c455d6187093bfba41e71ffbda1c9ee52d037016aef2c456f	546	1	4998935006465	170165	0	331	\N	6657	t	0
142	\\x145ec7d725485006c0217f2c83d97ee62f31d648e2800a620dc2e07f94ebad91	555	0	1999573628083	168405	0	291	\N	6693	t	0
143	\\x4aecf489c3840e7f5062b158dae8fee837eeb354d81f54483a436bc1bca55e3c	556	0	4998934666487	171573	0	363	\N	6710	t	0
144	\\xfb7bddb0bb431a15d52de6fac27dd12125a7c9d61fccf564d65881d93246e89e	558	0	4998934496498	169989	0	327	\N	6724	t	0
145	\\x17f853bd39e972035ae3c1aa9e8845ef0d01b08f9f8e0646611f735f051971c0	559	0	0	5000000	0	2364	\N	\N	f	1893
146	\\x6386ce8b706b5a714eb0d20d17d65b22ed683289d5bf8f77f582adcac20c2dd8	561	0	4998929314145	182353	0	608	\N	6742	t	0
147	\\x20f4fc784a4305c368f15f88d39a92ce5541fe173b30390a21f73d83239dc1da	562	0	4998928142572	171573	0	363	\N	6750	t	0
148	\\xaadbff07c1e5f880e020acbe15e263f69b67f1a2af54560647a7b86ed62ca0af	563	0	4998927972319	170253	0	333	\N	6763	t	0
149	\\x02f1c2a24fffef2291b3dd8fb8619319028ec9ddade3180b0ef0509fdf288603	567	0	4998927802330	169989	0	327	\N	6793	t	0
150	\\x81ac8052d91f7bbd1c89b975c1773436c7b6fa8a363b1cbb129a07f7b9f77646	569	0	4998917286017	516313	0	8198	\N	6804	t	0
151	\\x6862d385b978f0d1dfb2ccdb24386ca50b91754642684677999daea9b5047dc4	572	0	179474447	525553	0	8408	\N	6819	t	0
152	\\x5a9c1ed85ffc2e6f41e1e7fe5810b9f7c1416fa4ffd9afaad9b73dde53452a44	573	0	83073830129	168053	0	283	\N	6836	t	0
154	\\x7301509fafb3e127242ca57c210bc4f1b4b49eadad289bf5cbe789a6739164e2	580	0	9819803	180197	0	559	\N	6898	t	0
155	\\xfe2218eda6d3d22a7794e4e8fd8aeb9f0d0ee0ce91153cd18d3c9b2f5860fcc0	747	0	83073829733	168449	0	292	\N	8460	t	0
156	\\x1786079708593cc138c0615f104e74d8f59e668e6599018a5ec65ee583a75df8	747	1	83073829733	168449	0	292	\N	8460	t	0
157	\\x20b4ea91dcf0c776835c1affa23e125c06b9c8e1b90608effa6a56cfa6910f27	747	2	83073829733	168449	0	292	\N	8460	t	0
158	\\xa08ff3cfa2c918e06e50a81865413c68fb344e302fe6470c3ebe06fe7eb3f315	747	3	83073829733	168449	0	292	\N	8460	t	0
159	\\x769cac212a7f5cec1f4bdc57807eda668786c2b465a76a2d85797afbd3f3646a	747	4	83073829733	168449	0	292	\N	8460	t	0
160	\\x80381f6bd3b5826dbbf66d35c99052ef67bf0c3f690c13649228ee7e91d21926	747	5	83073829733	168449	0	292	\N	8460	t	0
161	\\x49082cb2ffeb3f45fa1c47351f4f49fdc487053768804ad82714fa9b38b2f0c5	747	6	83073829733	168449	0	292	\N	8460	t	0
162	\\x5f0c6dfb3a3354af3844abb9df7e095ce0ac20c3feb07a915be6c8ad8cefde5d	747	7	83073829733	168449	0	292	\N	8460	t	0
163	\\x7b62ca8625c9b4b4d490c031564eb24978d264d29234bef43b03a3db1836e647	747	8	83073829733	168449	0	292	\N	8460	t	0
164	\\xac776c8452cbf11db7393fdacdca7b441020ef79a28f5080b2819b247aae29fe	747	9	83073829733	168449	0	292	\N	8460	t	0
165	\\xa3d1567d931e5557ebe153fffb7d1a799c559523fa8630172bdfff5ff3ad2527	748	0	83068661328	168405	0	291	\N	8460	t	0
166	\\x74496a565fe7bb0a08a55f5436157836875c5605b64e8bd341e203c411cc0058	748	1	83073829733	168449	0	292	\N	8460	t	0
167	\\xb39f459a45d899629a8f63c036b3f41280e3bc91ccc99f6fa4fb7a3b621fbb24	748	2	83073829733	168449	0	292	\N	8460	t	0
168	\\xc2f3e6b83cd7f8265661bdeea01da21cf57406ec7846505ba1dc3ab35eb3060a	748	3	83073829733	168449	0	292	\N	8460	t	0
169	\\x865595f8d638b8e843e2d30bf4661621a409e3cae2acbd06cf8a9f6927feceb1	748	4	83073829733	168449	0	292	\N	8462	t	0
170	\\x9db5bef51f0838492bd5030e4e0fc469e8d0b27e3527a5d53ad59f03144a3a16	748	5	83068661328	168405	0	291	\N	8462	t	0
171	\\x9578c0ddac9f8ad0d6ad38a1568932c307cdd15928098fae9ccab01fbd9cc06a	748	6	83078828149	170033	0	328	\N	8462	t	0
172	\\xc5ec30f45337403d4b22881b18b85ef315bd586e557676081045e89c505b02e1	748	7	83073829733	168449	0	292	\N	8462	t	0
173	\\x5760b8f79182aa2475b093e187946e319757137d51af73f59db4e7cefb0f1640	748	8	83073829733	168449	0	292	\N	8462	t	0
174	\\x823c3aa92678b422e1d35466ed96efeb119183985448254d4f113f37d404e6c6	748	9	83070661724	168405	0	291	\N	8462	t	0
175	\\x8f2702ad534eaae639c470eb7882a764e17247edc4a2e4e5380416383b8cb01f	748	10	83068661328	168405	0	291	\N	8462	t	0
176	\\xe4c7ea865a39bc967cb754ce8894c36c178f94430560015887426ab85168c812	748	11	9830187	169813	0	323	\N	8462	t	0
177	\\x2b8723c7da88c785ea24eca59cdf91cf6693fdb79c402895ed5b1d0111128614	748	12	83073829733	168449	0	292	\N	8462	t	0
178	\\xc3164564a4881814f9101fd46a014180fa4574e74d8c3e5135e0b19d873aba5e	748	13	83078828149	170033	0	328	\N	8462	t	0
179	\\xc5410d70bddbe7cfd873b32a4d209ee7b51fad9b14aef5b5f2c1bd6a25cd6a6e	748	14	83063492923	168405	0	291	\N	8462	t	0
180	\\x81a6cdae3f205ba43be1573ed0212b822d54b678a101ddc68117cf0649a0317a	748	15	83068661328	168405	0	291	\N	8462	t	0
181	\\x502a0e3a80da9176ef3507efaf7096fdb0c1e2a3fb2cd90ad1279c7a24874c73	748	16	83068661328	168405	0	291	\N	8462	t	0
182	\\x8cb75f851af85628733c63c5d62695e6fdff3ac0b29ca353067de4f73a548a5d	748	17	83078828149	170033	0	328	\N	8462	t	0
183	\\xc96cf8344947259bc73ebc75b30635beaf8eaf9c186cca946aa71a04ce5d996f	748	18	9830187	169813	0	323	\N	8462	t	0
184	\\x9c77ba952f30104d6562c4ddbb84e303b4363c28e343c7290062b7399d519fdf	748	19	83073829733	168449	0	292	\N	8462	t	0
185	\\x5ddb9860691c599caef89cb851578e6734673526ea421b7240f68bc70926be4a	748	20	83073829733	168449	0	292	\N	8462	t	0
186	\\x1a98374aa9e548d48983c17b4d17a2c3659e3956f9e007d09c39afd286bd7792	748	21	83073829733	168449	0	292	\N	8462	t	0
187	\\x61aca2d38d1a8dbce502f58181608baa80c21d93c61ec9b66fee09192cb372fd	748	22	83073829733	168449	0	292	\N	8462	t	0
188	\\xc685d7a2b199eca75c97b0c3169ab6b0e128ad52dff692faa991ff6ee8198c4d	748	23	83065493319	168405	0	291	\N	8462	t	0
189	\\xdf050fa2a1ca27865fbcde801237804e381722d27204b1def970758c435cfe8c	748	24	83068661328	168405	0	291	\N	8462	t	0
190	\\x94442212e79e13b4b7271991c4d8ccf4d53d57ad63bb09fd04bc4fab7f323c4c	748	25	83073829733	168449	0	292	\N	8462	t	0
191	\\x3dbf5acff4bafa65fd25a6f1d4bfa87ef08f20f2f5b01aa69029f9f2fbccc0f2	748	26	83078828149	170033	0	328	\N	8462	t	0
192	\\xf77321a5c72a3d91741979e46771de55cac7bed0cd9e7656be11dce72d8a54bc	748	27	83073829733	168449	0	292	\N	8462	t	0
193	\\x6e2fff9e01839d705db0af6daf2ad09006122301a58e20b87092b951e4ba02b7	748	28	83073829733	168449	0	292	\N	8462	t	0
194	\\xbf88ed68cae921be3935612d74511fa66be53179a2b5941b359648694ba616da	748	29	83078828149	170033	0	328	\N	8462	t	0
195	\\x40c620f9057914359c1dd83cf2df7fd75ca5a08667171882c3fe112bb4a97a45	748	30	9830187	169813	0	323	\N	8462	t	0
196	\\xd44f532aafae7a7bf941bf687c57775abc6b7011f9f96d3175072a86b92c922d	748	31	83073829733	168449	0	292	\N	8462	t	0
197	\\xf4d8d26a1083b9577d488d2d908e09b6300e77cc4028a81e368bac11bceac0a9	748	32	9830187	169813	0	323	\N	8462	t	0
198	\\x52c9c533e932adad2eba9cafdd0e79ba807a36a3115f8412687505ee5e8ffac7	748	33	83063492923	168405	0	291	\N	8462	t	0
199	\\xca6ed10c6fb9d288f3fb058a352faddcfd96d011aea3f12adb1076f14768eef3	748	34	9830187	169813	0	323	\N	8462	t	0
200	\\xb56afcc27f740dd176e4206022deac938b1c5e24e9845a7b0443147b319b5fb9	748	35	83073829733	168449	0	292	\N	8462	t	0
201	\\xb1669116852f88f4994cc12ffed29e7134d65ff1768ef501c94989399a7cf3af	748	36	9830187	169813	0	323	\N	8462	t	0
202	\\xc505088d1c49f32addab968a4b7fbddc803a870ef0204a4e8cae57dfaf5ab9c3	748	37	83073829733	168449	0	292	\N	8462	t	0
203	\\xcc10bc79ab2aa1fa2e272c3afc747e7b5f4366fc583924bfbac437a57835ce77	748	38	83068661328	168405	0	291	\N	8462	t	0
204	\\x78609ee70dcce39e87f622425bd8425d768b87e372ccba2a4d8195e6c16d720f	748	39	83063153121	169989	0	327	\N	8462	t	0
205	\\x8bb5a877f0366ec81903083b9b460bcee2625ab378fa1b1e647f34af8acf76f2	748	40	83068661328	168405	0	291	\N	8462	t	0
206	\\x6dd87ea5b3665c751debf019d898d5c90368d14b241dc2e74b73f4dab6cf5e09	748	41	9830187	169813	0	323	\N	8462	t	0
207	\\x1ecb0f2b567b19ddbac2a469bf4a89ee11ff9c4d6c70822c92e354e8bb7e7eab	748	42	83073829733	168449	0	292	\N	8462	t	0
208	\\x6ca132e4a8e16c875ad2499065bcd427aba38ffbf73bb9e7482d935ccfc1a594	748	43	83073829733	168449	0	292	\N	8462	t	0
209	\\xf7da59c82ea4c7d4e7fcae3a1adeea0639d8d322def9cf93ff7e47a834433f75	748	44	83073829733	168449	0	292	\N	8462	t	0
210	\\x389634395005ca025594d9c6c88baf9daf80d3185a7628d4f557c44e5d1cb194	748	45	83068661328	168405	0	291	\N	8462	t	0
211	\\x7396c2c7ea272ca234661b0aa706de2df7ba133d166494f7e2dc6a2e39dabecb	748	46	83073659744	169989	0	327	\N	8462	t	0
212	\\xc9accc9cfc0d8b26538eef36b3498ebe8a30e727072852b0e0da3f320c023e72	748	47	83073829733	168449	0	292	\N	8462	t	0
213	\\xad65afefc81b3c9b72d4758831116889e1f59a2f263bbe25b2fa06f3b89cf2f6	748	48	83060324914	168405	0	291	\N	8462	t	0
214	\\x28f658b6fd25c537f740aa17d4d53521d005ca2d922f057ce744e4d84370742c	748	49	9830187	169813	0	323	\N	8462	t	0
215	\\xaa596fe7b5f9573ccf00b27194ea35cf0f6f1d16696f74093db282364f288ff6	748	50	83073829733	168449	0	292	\N	8462	t	0
216	\\xcd64be2af1c05ef1654c33b12c41318046d405d0f249f310557e201a33ecfefd	748	51	83063492923	168405	0	291	\N	8462	t	0
217	\\x742f626ab2980eb48a678d10555e9d57c52152bd1f6f2cca72c637fb8ede753a	748	52	83078828149	170033	0	328	\N	8462	t	0
218	\\xddf02dfb26906828a651320aa2661e1246b5c4392058a58e3ab2a0672a669839	749	0	9830187	169813	0	323	\N	8462	t	0
219	\\x18a676053c61d8d44c1d386a7740e7f0328c34b76a97cad1d308aa8fd349ae88	749	1	83063492923	168405	0	291	\N	8462	t	0
220	\\x709e8298d93c6a09f26365081021a67b4fd127a10941addabb0ea04c72c1e101	749	2	9830187	169813	0	323	\N	8462	t	0
221	\\xe1aeb3dc71e2ddb7f77714b5ce7ec393b207dfdeda7950a57af1115fbb47789e	749	3	83068661328	168405	0	291	\N	8462	t	0
222	\\xa48ce749ea6c3d15c8a7d45e2abe2b8bb6fc55eb531f3394570431919af0f19a	749	4	83068661328	168405	0	291	\N	8462	t	0
223	\\x2e74462fe45969b28b432d58453839ce8512c9cb763156727083594b84d6faf1	749	5	83063492923	168405	0	291	\N	8462	t	0
224	\\xab3cfe25a7e5f06a50d234aa44a4d934c318d176d7a7d6bd2ca6b43fd6ebbe2c	749	6	83073829733	168449	0	292	\N	8470	t	0
225	\\xe6aa37530bc90b40dce50c4c1c15d7ff128c79db2cbf52d2c9ca01a4f861117b	749	7	83073829733	168449	0	292	\N	8470	t	0
226	\\xde32d37d8c37ea322200eef48bb76242bdb8d3ade5dd6824d64ef4c1bc0a4ca4	749	8	9830187	169813	0	323	\N	8470	t	0
227	\\x92553227d7c27838cb10cd00f244948ad28bc0d76b5410151cd57aee617c8afd	749	9	83068661328	168405	0	291	\N	8470	t	0
228	\\xb0bc11737dd1af65510b0ee31d88db1053a287cd1557ba974803477b97ee6079	749	10	83068661328	168405	0	291	\N	8470	t	0
229	\\xece30d1984f098637edad5f00269a14271ea0abb6922c90278766dbfdf3e4ee4	749	11	9651574	168229	0	287	\N	8470	t	0
230	\\x3f29791658fc2150fc3fd62b85100562de392fa2a4ab8ca3e41d23d1aac8da5e	749	12	9660374	169813	0	323	\N	8470	t	0
231	\\x76efb25a5134c20b168fcff5a434b06f73e270998d03fdd8caf94919b764d01d	749	13	9830187	169813	0	323	\N	8470	t	0
232	\\x2512bdf0822048c8a66e5530f685f3c3e0925b09690ad6707c0855c3135cb093	749	14	83073829733	168449	0	292	\N	8470	t	0
233	\\x5598d0f946b647c06d0cef2a67d34dc31238cba67e438fc76f00a3d8173143f2	749	15	83073659744	168405	0	291	\N	8470	t	0
234	\\x4c5dab757754c21d3b412275f35448cd719b7d3eaa5626e958170c8ef1b73021	749	16	83073829733	168449	0	292	\N	8470	t	0
235	\\x9b7d899d0192f3ff47af9180c880d9aaa74700d57274e774a418d441a4f06c52	749	17	83058324518	168405	0	291	\N	8470	t	0
236	\\x45bada6e14b0b80b39c148ab8f777f83fd642e3c7750b8c12a4bc5e47c74e514	749	18	83073659744	169989	0	327	\N	8470	t	0
237	\\x7f729eee92ff0c25f7f569b5a218847c69207db26c267b1a7832a384a9c1b18d	749	19	9830187	169813	0	323	\N	8470	t	0
238	\\x553bca9fc7f8a8b1895ac71a9f426e8ec9ad1e4747a9b0ec0438e2338b719499	749	20	9830187	169813	0	323	\N	8470	t	0
239	\\x202fb403ebcc340d786fb60f5af66b9d11ebf17efd84a04284423e2a98d13208	749	21	83068661328	168405	0	291	\N	8470	t	0
240	\\x98f7e1f4eb024418d32c843079a76b87f2064611dc53bac400d4af9cfe46f2b0	749	22	83068661328	168405	0	291	\N	8470	t	0
241	\\x819c4eb34acd05f74f5d709bf8028a4ad288435ac06ca8111023a5ce6a2b3951	749	23	83073829733	168449	0	292	\N	8470	t	0
242	\\xdc352b004aae040f4e1abb1f681b4e543ff049524a8cfe596a60c8531b6a5626	749	24	83073659744	169989	0	327	\N	8470	t	0
243	\\xade11c4d85d87fa73608e0db42bbb0f56fb5060e0ff13088c82f1875acb86207	749	25	9830187	169813	0	323	\N	8470	t	0
244	\\x55386f74ce58af804a3366ea250ada7f8229b893a68fa7f87572fe5e7e47c17d	749	26	83068661328	168405	0	291	\N	8470	t	0
245	\\x965516bd47bb8200f6c43e0f61e240ccdba3d99d052a9b937a3d443094bc6a44	749	27	83063492923	168405	0	291	\N	8470	t	0
246	\\x75fbb41340c1a95aa1a26148887cfdf23d0db3021932b79b3a9e34e30117fbe0	749	28	83068661328	168405	0	291	\N	8470	t	0
247	\\x6418fdc208155ba884d4ee688efaa3ab7d6f2fa3dbb5005c6a84cedde862ec8e	749	29	9660374	169813	0	323	\N	8470	t	0
248	\\x3944558be6f29fcc654519561ffb7af0deffd8ec33e8e3d358ed2acc9abf9a9a	749	30	9660374	169813	0	323	\N	8470	t	0
249	\\x82229792c5f06f683c9e66e60f1fa92ee7ffaf4a5c0a0881d720445d6a9cdae0	749	31	9660374	169813	0	323	\N	8470	t	0
250	\\xa5983b0361b58332c52288857bcbd50d10991b2ed0cc440246e63d89d95a79b6	749	32	83063492923	168405	0	291	\N	8470	t	0
251	\\x25afed74398d0b309fe0d7ec41974b76cc31c1b5a90a77f987f5024e5c86e3b8	749	33	9830187	169813	0	323	\N	8470	t	0
252	\\xab3428b4fdd169f6f1aa9949e77b54f983b827162561f739e196bbd32be8a34e	749	34	83068661328	168405	0	291	\N	8470	t	0
253	\\x8a22af1fa7f847e9d73704c129ed7948a4d16e79200af50a52621c2cb77d52f9	749	35	9660374	169813	0	323	\N	8470	t	0
254	\\xab516b70e4db05c87760f0899980f50aa203f2c3e79a4aa3a02eaf96f1b0c40a	749	36	83063492923	168405	0	291	\N	8470	t	0
255	\\x066c629c7fb2cfeabf2e3eda10675761608e8b10c580ca6d618dd2582a465b79	967	0	105983715567	174741	0	435	\N	10456	t	0
256	\\x406d47f8cc44f6c44780f7a5330b821b6f2415be4d725655b6d6cb1ca53ba174	972	0	5007517441478	430953	0	6262	\N	10488	t	0
257	\\x989392ba9846927b9564287f72f3949c8ad69cd01f57d7e4deb3d8a10b36357b	1178	0	1266925232631	174697	0	434	\N	12455	t	0
258	\\xd6e0284a9717ff0df83be7939f71e9ac73c0ce2c1ece4bcbea83306aaedbeb62	1178	1	1266925062642	169989	0	327	\N	12455	t	0
259	\\x6921cb78e7d803eb9db3a071bcb6c8a27ed45855c5d23ed8c0a1321b63a87a25	1178	2	78247296768	169989	0	327	\N	12455	t	0
260	\\x0ed2ecc17cb949bf20a30f28009d16c3c68feae5a7093c47678ff516d72f73a9	1178	3	39121064973	168405	0	291	\N	12455	t	0
261	\\x2516397235deb0dbf3ee5b6d538312bfac8e52a520b9b0692b6235c8b8297a93	1178	4	78242298352	168405	0	291	\N	12455	t	0
262	\\x130012a2fcd1417415c94ca4080465ce9a29cdbec65481a5c0e913f2c0fe8340	1178	5	312969698622	168405	0	291	\N	12455	t	0
263	\\x9cdd57b126476259bce31ef810271490b9ebc26821626f3d1e9a8b64a09808f9	1178	6	312969698622	168405	0	291	\N	12455	t	0
264	\\x5173d33d1c7e53de454ab4a3dfa9cbfd91f839739c7e74d9f941458a44486e4b	1178	7	1251879299703	168405	0	291	\N	12455	t	0
265	\\x439c3b7354f21ad1412f3c05bbf9ee6c9f1a36946b7672c1f166609b4a13202f	1178	8	625939565649	168405	0	291	\N	12455	t	0
266	\\xd6a6819145c22a0d5df5ce104cc0ee6cb8da2b7ca4bd8201171efa9dd3661e2d	1178	9	312964530217	168405	0	291	\N	12455	t	0
267	\\x576ca31fcafce2c08f9fa5972027cf3bae194a115286f4d732593df15de24e23	1178	10	39121064973	168405	0	291	\N	12455	t	0
268	\\x86ecf2d43532aaea0db6fb660bcc96a2db6b4355e4e544839121555124fd90bb	1178	11	39115896568	168405	0	291	\N	12455	t	0
269	\\x1b24caf8a0c8bdb3517c3f54216d06bdbdb69c3bea6addc9b16ae1d045badc1b	1178	12	1251874131298	168405	0	291	\N	12455	t	0
270	\\x2dbd9f1186e4f98078f738e0f3331355d168dd460c4769d7ac9ecf33ce6f0725	1178	13	156484765108	168405	0	291	\N	12455	t	0
271	\\x28044646eae5c26bfa0c43f8a08e46869efb683ea53e40cdaf2cbe21e0c45879	1178	14	312959361812	168405	0	291	\N	12455	t	0
272	\\xc83aa9e7d76772499d6092d4544cdc38932b12efc50c96da60c8e5fa6168ff8a	1178	15	9830187	169813	0	323	\N	12455	t	0
273	\\x3540280423e07c34d0320accc634c38c98f96a37791dcb9602cac969cb1ee7d5	1178	16	9830187	169813	0	323	\N	12455	t	0
274	\\xab400d7556db184ddb9cc71fdc3a056aea6800a1db95cffdb95a302428c79830	1178	17	39121064973	168405	0	291	\N	12455	t	0
275	\\xb75261ca37f7079feeea74594af7dea2210defbd6cd01134aa138f7ce52eb16c	1178	18	312954193407	168405	0	291	\N	12455	t	0
276	\\x06089640b1de8a05b8aaa8f6b01bf064e415e0dcfebce3b84a2b9eac41303c1f	1178	19	9830187	169813	0	323	\N	12455	t	0
277	\\xea9517d25b4477ff6efa21a28643529265d228ef059a9780904bfbce20d3e5da	1178	20	9830187	169813	0	323	\N	12455	t	0
278	\\x15050a95d1e83a69f45850f711670d9a2337ce280cb6024b2db12014ef1699b1	1179	0	78237129947	168405	0	291	\N	12455	t	0
279	\\xc45ccd741cd179743ecb00851d5fcfb05c8f383829bd393fa9289aa64731bbf4	1179	1	9830187	169813	0	323	\N	12455	t	0
280	\\x7472db4b79b29e7cd06590acff044d97db00ceb622d609791dbbcf0c9d680c67	1179	2	9830187	169813	0	323	\N	12455	t	0
281	\\xfb31913ff37454da8ca75e5d2bb7f929bef3eeffa64fa0837fd3b4ae388f60bc	1179	3	1266924722840	169989	0	327	\N	12455	t	0
282	\\x8e152a8c854757cb0b0ae0d8ac75f6d313bd65add1caedd941d5bc4a37c436d7	1179	4	156484595119	169989	0	327	\N	12459	t	0
283	\\xbd53ae24a03594d1b290b6602cd0191b7450aaf8402b8c52bc7b290e10320b03	1179	5	312949025002	168405	0	291	\N	12459	t	0
284	\\x039cfbb788a4d612b5f4ecdd628569d77d78fc85926890242832e2a0df4ed737	1179	6	39115896568	168405	0	291	\N	12459	t	0
285	\\x57e493c352e9050efbb69c2e0e4addb5aabc561efb3ff1fe0d70de0d82ff803e	1179	7	39121064973	168405	0	291	\N	12459	t	0
286	\\x3ceb4de1a8d266f6d0041ec129051c8a2c7f7584feeada95ac00f744693d9ed6	1179	8	39120725171	169989	0	327	\N	12459	t	0
287	\\x37fdb6e846c443a250ecd0a841604fbfc90cb7cc3f230e1e67415cdc1f120b1c	1179	9	156479426714	168405	0	291	\N	12459	t	0
288	\\x7bf47ab3c0c47aecb83d50dcb698b320aee90f7e032e7f50657ce5e668b0491c	1179	10	156484765109	168405	0	291	\N	12459	t	0
289	\\xa19a35b1b7d107a139fcfc358e78607183bb93589ab09ca45f1177641cf21c99	1179	11	9660374	169813	0	323	\N	12459	t	0
290	\\xdbd32d70efc1528b0d24a615a620e6078cd08a90e8b3fd50c8c63fe995c8dd00	1179	12	625934397244	168405	0	291	\N	12459	t	0
291	\\x2c9f92dc865458d2ce81a6f54e5c96f29cd0efc5667f7bb4ecc04c9753837933	1179	13	312964530217	168405	0	291	\N	12459	t	0
292	\\x06f001dffb1cba21a915d31388c4f247a0fadadd90d735f55a91f03eec3c80d0	1179	14	625939565649	168405	0	291	\N	12459	t	0
293	\\x1e7ed2516e34a7d94574a32e4473c28b9b8c2fd44bea208466aa818a3a57a42f	1179	15	9660374	169813	0	323	\N	12459	t	0
294	\\x0485249aba41cd709fcc7cf17c58bf398aa6476baf5f5951a7e7d04136e8caa0	1179	16	9830187	169813	0	323	\N	12459	t	0
295	\\x101ae2d019200dfa081f24f4e4c4d4d7a7dd3c32ff581776b3df84a1b7f412b3	1179	17	78242128363	168405	0	291	\N	12459	t	0
296	\\xe0899d35f0a6f46d61908486645d12bc6478af0fa46193b57d9ddbe7c340a81c	1179	18	9490561	169813	0	323	\N	12459	t	0
297	\\xfba364e8a1695ed912feed042cd894138a486fcafc62d873d2b935323d4f5848	1179	19	9830187	169813	0	323	\N	12459	t	0
298	\\x48a620b92446c7c1d9aa4073fc7b5028fecd434a77a0ad260361ba68279afcbf	1180	0	9830187	169813	0	323	\N	12459	t	0
299	\\x112dba9d8bd1b134411babe9852862182837bf4ad4f076adada1957551a4467a	1180	1	9830187	169813	0	323	\N	12459	t	0
300	\\x3324ca4bae811378d3360927cf4d41e69b573caeba620f0044f9f9b0ef5f5e46	1180	2	9830187	169813	0	323	\N	12459	t	0
301	\\x6b850dceb815e8d6f0e32dff4cf801db4925c269a4f74039de8aea197f8722f6	1180	3	9660374	169813	0	323	\N	12459	t	0
302	\\xae9a2440665fdb8e9c7cf2cc69acbb76622a664db73e6257bada7c299f2db17d	1180	4	39110728163	168405	0	291	\N	12459	t	0
303	\\x61ad704ddf06048742984797b2ca8dcea7eed207a3a8418b9915dbf26cdbfdc7	1180	5	39110728163	168405	0	291	\N	12459	t	0
304	\\x0c564ed90625ed8d1927fcfd799ae4a12376a50ec611b9fa4ce11fb8c1a3bab3	1180	6	9490561	169813	0	323	\N	12459	t	0
305	\\x25fa1793e6b46ed08b1788f25923ecdd8b8f71872df52783ca154a6f9fd6a5f4	1180	7	9830187	169813	0	323	\N	12459	t	0
306	\\xf8bdef0ce45418e3883121a4eb7dc0d6e2d2a07d41ae31acfa01cdd88e6878c5	1180	8	9490561	169813	0	323	\N	12459	t	0
307	\\xe0228989dda17c297f8ab31d4ad4c21cab14a2efd0110942c563565061a12a06	1180	9	9660374	169813	0	323	\N	12459	t	0
308	\\xba7d56914e9bb6a08781fe0220e89087d9d8ddbbe49ffbdb561f37b60fa3278a	1180	10	1251868962893	168405	0	291	\N	12459	t	0
309	\\x990442ec6e299bf12fbd47ec1e8e181a3659a37ba17af10669ef1b92d6843212	1180	11	1251863794488	168405	0	291	\N	12459	t	0
310	\\x15df3bcd7cf846b9c4ed84d5919c1b94c0b1b77f9564d1484077b1e9974c56a2	1180	12	9830187	169813	0	323	\N	12459	t	0
311	\\x3775f5e61c39a86400316621871b2739219cc1d7081a903e6028cf96d0438c0b	1180	13	9490561	169813	0	323	\N	12459	t	0
312	\\x894201cac00f279e879f7d2a74bf8e3b846ffdd3065b0e781f60392a8acc9c83	1180	14	39115556766	168405	0	291	\N	12459	t	0
313	\\x18a435cf97b65a0777db73a3ef0f1279febbb2cb3ed93e420a45a93e6bb1a7a4	1180	15	156479596704	168405	0	291	\N	12459	t	0
314	\\x893aa3b530bbe7b7e41339b79967496031ca01ce43e90bc99a43d5869aed29ea	1180	16	9830187	169813	0	323	\N	12459	t	0
315	\\xe399e7e5dc8febefaf84768da37d6bd012d86188ee42ae5466eab483d6de99fa	1180	17	156479256902	169989	0	327	\N	12459	t	0
316	\\x36a8f3147989bf30ca10091ebeae3596436c75249cb21c2bdb0ab0dab0180cd4	1180	18	9830187	169813	0	323	\N	12459	t	0
317	\\x9a1cd33755603c469e2d545ec1b6c862a59c439b3a8dc7e4927d55bad0e451a8	1180	19	1266919554435	168405	0	291	\N	12459	t	0
318	\\x0fdfdf553de13466970e5d621499083a1fd3690683de4c7b220918712c08fe01	1180	20	312943856597	168405	0	291	\N	12459	t	0
319	\\xa0177c5ed45e885b4f6f81a858658e40aab562c85f0d4921b722aa4a9a48986e	1180	21	156479086912	169989	0	327	\N	12459	t	0
320	\\x43c1216a5ca81d4b6c913ca3656a7c1d44651e78982e5eb8d4dde3379ed58e28	1180	22	9320748	169813	0	323	\N	12459	t	0
321	\\x372ffca927c252d5e18e363097944606b5ba99e1e47f2aea0afdce8555ecb1f1	1180	23	9830187	169813	0	323	\N	12459	t	0
322	\\x0a90fc03010291c74a51cb16f6e7a367423190a2d1a6c0ebe2da10d4ee809a48	1180	24	312943516795	169989	0	327	\N	12459	t	0
323	\\xdeeae439fe1eded4f581b2f4727b1c1a3d408a735b4dd98b9f36ca4333f74023	1180	25	78236959958	168405	0	291	\N	12459	t	0
324	\\x00d6dabc1627aa42efa012ea22c0e86898920c019c6517f20e15546f2254182f	1180	26	9830187	169813	0	323	\N	12459	t	0
325	\\xf5001badfdeb776826180e85da1276dbf8530ce39ccc81a49a30cc291eb4eb2d	1180	27	9830187	169813	0	323	\N	12459	t	0
326	\\x4ba1c05247d2ebdb35c04302a07987e82730e9f60203335cb2031de8de3de1d1	1180	28	1266914386030	168405	0	291	\N	12459	t	0
327	\\x3e6929419d471ad49fb1d43122366ba846e4c01a41c801ad71823573f7f21790	1180	29	78236790145	169989	0	327	\N	12459	t	0
328	\\x54ad0847c77e64e5e98e533b215efa67f88c02ffffdab061e48560acc92b772c	1180	30	78231621740	168405	0	291	\N	12459	t	0
329	\\x1e7ab3b7a601afbef9fddc67e87890376bd3f652969f7c9ceadc9b142ca991b1	1180	31	9830187	169813	0	323	\N	12459	t	0
330	\\x6784a6c843f73c3ab96cb667f0ccec4d0c902b50c6a42458b4cf09c47e6c5483	1180	32	1251858626083	168405	0	291	\N	12459	t	0
331	\\xfc3472b7e109e6eaec29735229e74c27319fbd6bacfac5f03844207a302eaaaf	1180	33	39105559758	168405	0	291	\N	12462	t	0
332	\\xf277712246ac0adbf2fb427957965b4da2c039e26d36e6551ea51b24ca3df14d	1180	34	625934397244	168405	0	291	\N	12462	t	0
333	\\x677db9ec635013e58580a97d4fde34d7028382b008ee8193bc6db11fc3a7cf8b	1180	35	312959361812	168405	0	291	\N	12462	t	0
334	\\x1db90ff109d83a29a8e41b65fe51502887c5d0daf942e02cf1fbfe759617c6d3	1180	36	9830187	169813	0	323	\N	12462	t	0
335	\\x5862f4b782f545cd05fc30305ad7af836c40a558c657bf65431927183a0086b3	1180	37	39100391353	168405	0	291	\N	12462	t	0
336	\\x3ea9a33e9d12592f905d0d6cdc6f49aa101dba4adff710d34a3f3783141b42e1	1180	38	156473918507	168405	0	291	\N	12462	t	0
337	\\x468b62f29f5caced64156aeb431f578c9ce20db286d7a420116c2cf6560ef0dc	1180	39	9830187	169813	0	323	\N	12462	t	0
338	\\xe049e1211c8e3caa1f10e538dfe2a27b7eb29821245c9e3c7dbad8330b3e2714	1180	40	9490561	169813	0	323	\N	12462	t	0
339	\\x58393c9d28d8cb643f95ad2f86dcaa215def3fb8efbb118b321238ef43401b55	1180	41	9320748	169813	0	323	\N	12462	t	0
340	\\x16189f5c345edd7fb3c1350056d60a4469bcc492fa08125e352e7754095f4bba	1180	42	9830187	169813	0	323	\N	12462	t	0
341	\\x92db73b118bc60c9957713718693a6631f4cfd314be25f211ab92abea8db3e44	1180	43	9660374	169813	0	323	\N	12462	t	0
342	\\x8e51aa5e6afb8ff08fddc4910725e3bfbf9eb70164bcaa853ac88840528832d6	1180	44	9320748	169813	0	323	\N	12462	t	0
343	\\xf459a855ff72cadfe2a5fe85577f86b9d7c450b49154d5a656864e35bd2c0b7e	1180	45	9830187	169813	0	323	\N	12462	t	0
344	\\x7c47e19dfd1bcb527eaa95f81d4d79515a01c063eacbee820ff78f0745933421	1180	46	9660374	169813	0	323	\N	12462	t	0
345	\\xb26ab3f3de56c4f01d48184196bb7a777eeb874e7a0cb721129533cc49063e50	1180	47	9660374	169813	0	323	\N	12462	t	0
346	\\x91e6da63d3cb3047a3df1796a61e9e60879a96b30f0a788bfee677ce3407c9a5	1180	48	8981122	169813	0	323	\N	12462	t	0
347	\\xea89b76e089fdf6512d7a3a1db1c5d48c62a7ea5c552b6810fff1e98b6aac72a	1180	49	39110388361	168405	0	291	\N	12462	t	0
348	\\x2d620dae7dc5ab149772a491f656a00524415e7127e970911819218bc344fbc5	1180	50	9830187	169813	0	323	\N	12462	t	0
349	\\x3202018e525a0c45a6bce7aea11148e9d7220f3b0e0ec416ce5f3f51765d95f7	1180	51	9830187	169813	0	323	\N	12462	t	0
350	\\x22b2e99db907d5c66bf0c72b3c12ad5e24db9245f6cda95eaea06b200f26c3d8	1180	52	9830187	169813	0	323	\N	12462	t	0
351	\\x95af2cfdf20b1c6e32be5f183882bc9e93ec561a7b3be8b13180be84f404eb7a	1180	53	9830187	169813	0	323	\N	12462	t	0
352	\\x1603c43ef4ac8d87ead374c0123a6ec92c918bef612f9239cbf8e8c515226857	1180	54	312938348390	168405	0	291	\N	12462	t	0
353	\\xfc7fea6e5f8402e4cf864718ff9c0573140732aa0675fd4c36c0fa23678da0ca	1180	55	78236620156	169989	0	327	\N	12462	t	0
354	\\x3e3a12cf7865998d80c115acc9c663e74b87d8d84318869db7a81397fcde45a2	1180	56	312954193407	168405	0	291	\N	12462	t	0
355	\\xc80e47d5a2f6be3ed40480889472c6b3a6a54e48427cf75d080cedc177705b30	1180	57	9830187	169813	0	323	\N	12462	t	0
356	\\x061c336ad3125e8249e57836b732d4d2f57fc2cc89b8aecec541be594554536c	1180	58	9320748	169813	0	323	\N	12462	t	0
357	\\x55665579935a371feef4d7ea79b51f1b72acc62b491b6acc4f607fd9a7618267	1414	0	55121347316	180725	0	571	\N	14441	t	0
358	\\x3afc4d020cba6747bd310d154df2281a4bbc4b0630448c8ffec096b298bc46fe	1418	0	156473682078	236429	0	1736	\N	14452	t	0
359	\\x34f7b278111383f8d2729378652ebc81e37ddabba000d64cd6482c6f75d89703	1427	0	4999999820111	179889	0	552	\N	14567	t	0
360	\\xd7c7e5f696335e61171ce5155b6db1e1ee120ca28f019d182f04940b757ebeab	1431	0	4999999648538	171573	0	363	\N	14620	t	0
361	\\x6976aded56cba8c22dd61295fe004a6d061b4a2f589d5f566335ebc053278a82	1435	0	4999999471201	177337	0	494	\N	14649	t	0
362	\\x91b9b0cbbea794281489b86256b73cbcd25aad03e70b50074737fabc7b8dba7a	1440	0	4999999820287	179713	0	548	\N	14671	t	0
363	\\xa006de8cc7d81a3fb71e22d2e3f4bd220f5057822f3f46bda49f8c5d94ca86d5	1444	0	4999996650298	169989	0	327	\N	14727	t	0
364	\\x509e2c9c94fabc2cb042d8a40cc16b1d30100b396a2a897b103d5c43060aaeb7	1448	0	9821255	178745	0	526	\N	14781	t	0
\.


--
-- Data for Name: tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_in (id, tx_in_id, tx_out_id, tx_out_index, redeemer_id) FROM stdin;
1	35	22	0	\N
2	36	35	1	\N
3	37	36	0	\N
4	38	27	0	\N
5	39	38	0	\N
6	40	37	0	\N
7	41	40	1	\N
8	42	41	0	\N
9	43	23	0	\N
10	44	43	0	\N
11	45	42	0	\N
12	46	45	1	\N
13	47	46	0	\N
14	48	29	0	\N
15	49	48	0	\N
16	50	47	0	\N
17	51	50	1	\N
18	52	51	0	\N
19	53	28	0	\N
20	54	53	0	\N
21	55	52	0	\N
22	56	55	1	\N
23	57	56	0	\N
24	58	20	0	\N
25	59	58	0	\N
26	60	57	0	\N
27	61	60	1	\N
28	62	61	0	\N
29	63	25	0	\N
30	64	63	0	\N
31	65	62	0	\N
32	66	65	1	\N
33	67	66	0	\N
34	68	19	0	\N
35	69	68	0	\N
36	70	67	0	\N
37	71	70	1	\N
38	72	71	0	\N
39	73	17	0	\N
40	74	73	0	\N
41	75	74	0	\N
42	76	72	0	\N
43	77	76	0	\N
44	78	77	1	\N
45	79	78	0	\N
46	80	32	0	\N
47	81	80	0	\N
48	82	81	0	\N
49	83	79	0	\N
50	84	83	0	\N
51	85	84	1	\N
52	86	85	0	\N
53	87	12	0	\N
54	88	87	0	\N
55	89	88	0	\N
56	90	86	0	\N
57	91	90	0	\N
58	92	91	1	\N
59	93	92	0	\N
60	94	16	0	\N
61	95	94	0	\N
62	96	95	0	\N
63	97	93	0	\N
64	98	15	0	\N
65	99	98	0	1
66	100	98	1	\N
67	101	100	1	\N
68	102	101	1	\N
69	103	102	1	\N
70	104	103	1	\N
71	105	104	1	\N
72	106	105	0	2
73	106	105	1	\N
74	107	33	0	\N
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
85	117	116	1	\N
86	118	116	0	\N
87	118	117	0	\N
88	119	117	1	\N
89	120	119	0	\N
90	121	118	0	\N
91	122	121	0	\N
92	123	122	0	\N
93	124	120	0	\N
94	124	123	0	\N
95	125	124	0	\N
96	125	121	1	\N
98	127	119	1	\N
99	128	127	1	\N
100	129	125	0	\N
101	129	128	0	\N
102	130	125	1	\N
103	130	129	0	\N
104	130	129	1	\N
105	130	127	0	\N
106	131	130	0	\N
107	131	128	1	\N
108	132	131	0	\N
109	133	132	0	\N
110	133	132	1	\N
111	133	132	2	\N
112	133	132	3	\N
113	133	132	4	\N
114	133	132	5	\N
115	133	132	6	\N
116	133	132	7	\N
117	133	132	8	\N
118	133	132	9	\N
119	133	132	10	\N
120	133	132	11	\N
121	133	132	12	\N
122	133	132	13	\N
123	133	132	14	\N
124	133	132	15	\N
125	133	132	16	\N
126	133	132	17	\N
127	133	132	18	\N
128	133	132	19	\N
129	133	132	20	\N
130	133	132	21	\N
131	133	132	22	\N
132	133	132	23	\N
133	133	132	24	\N
134	133	132	25	\N
135	133	132	26	\N
136	133	132	27	\N
137	133	132	28	\N
138	133	132	29	\N
139	133	132	30	\N
140	133	132	31	\N
141	133	132	32	\N
142	133	132	33	\N
143	133	132	34	\N
144	134	133	0	\N
145	135	124	1	\N
146	136	135	0	\N
147	137	135	1	\N
149	139	137	0	\N
150	140	139	0	\N
151	140	137	1	\N
152	140	131	1	\N
153	140	136	0	\N
154	141	140	0	\N
155	141	140	1	\N
156	142	141	1	\N
157	143	142	0	\N
158	143	142	1	\N
159	143	141	0	\N
160	144	143	0	\N
161	144	143	1	\N
162	145	144	0	\N
163	146	144	1	\N
164	147	146	1	\N
165	148	147	0	\N
166	149	148	0	\N
167	149	148	1	\N
168	150	149	1	\N
169	151	150	0	\N
170	151	150	1	\N
171	151	150	2	\N
172	151	150	3	\N
173	151	150	4	\N
174	151	150	5	\N
175	151	150	6	\N
176	151	150	7	\N
177	151	150	8	\N
178	151	150	9	\N
179	151	150	10	\N
180	151	150	11	\N
181	151	150	12	\N
182	151	150	13	\N
183	151	150	14	\N
184	151	150	15	\N
185	151	150	16	\N
186	151	150	17	\N
187	151	150	18	\N
188	151	150	19	\N
189	151	150	20	\N
190	151	150	21	\N
191	151	150	22	\N
192	151	150	23	\N
193	151	150	24	\N
194	151	150	25	\N
195	151	150	26	\N
196	151	150	27	\N
197	151	150	28	\N
198	151	150	29	\N
199	151	150	30	\N
200	151	150	31	\N
201	151	150	32	\N
202	151	150	33	\N
203	151	150	34	\N
204	151	150	35	\N
205	151	150	36	\N
206	151	150	37	\N
207	151	150	38	\N
208	151	150	39	\N
209	151	150	40	\N
210	151	150	41	\N
211	151	150	42	\N
212	151	150	43	\N
213	151	150	44	\N
214	151	150	45	\N
215	151	150	46	\N
216	151	150	47	\N
217	151	150	48	\N
218	151	150	49	\N
219	151	150	50	\N
220	151	150	51	\N
221	151	150	52	\N
222	151	150	53	\N
223	151	150	54	\N
224	151	150	55	\N
225	151	150	56	\N
226	151	150	57	\N
227	151	150	58	\N
228	151	150	59	\N
229	152	150	97	\N
231	154	149	0	\N
232	155	150	96	\N
233	156	150	99	\N
234	157	150	80	\N
235	158	150	94	\N
236	159	150	114	\N
237	160	150	102	\N
238	161	150	115	\N
239	162	150	119	\N
240	163	150	93	\N
241	164	150	68	\N
242	165	162	1	\N
243	166	150	113	\N
244	167	150	76	\N
245	168	150	71	\N
246	169	150	81	\N
247	170	158	1	\N
248	171	156	0	\N
249	171	150	106	\N
250	172	150	89	\N
251	173	150	108	\N
252	174	152	1	\N
253	175	166	1	\N
254	176	163	0	\N
255	176	168	0	\N
256	177	150	61	\N
257	178	150	100	\N
258	178	171	0	\N
259	179	165	1	\N
260	180	163	1	\N
261	181	157	1	\N
262	182	150	116	\N
263	182	164	0	\N
264	183	169	0	\N
265	183	175	0	\N
266	184	150	70	\N
267	185	150	85	\N
268	186	150	77	\N
269	187	150	83	\N
270	188	174	1	\N
271	189	177	1	\N
272	190	150	87	\N
273	191	150	118	\N
274	191	158	0	\N
275	192	150	73	\N
276	193	150	65	\N
277	194	150	112	\N
278	194	155	0	\N
279	195	157	0	\N
280	195	190	0	\N
281	196	150	67	\N
282	197	193	0	\N
283	197	166	0	\N
284	198	180	1	\N
285	199	182	0	\N
286	199	176	0	\N
287	200	150	66	\N
288	201	181	0	\N
289	201	178	0	\N
290	202	150	78	\N
291	203	161	1	\N
292	204	195	1	\N
293	204	198	1	\N
294	205	172	1	\N
295	206	195	0	\N
296	206	187	0	\N
297	207	150	107	\N
298	208	150	62	\N
299	209	150	109	\N
300	210	200	1	\N
301	211	200	0	\N
302	211	155	1	\N
303	212	150	88	\N
304	213	188	1	\N
305	214	186	0	\N
306	214	209	0	\N
307	215	150	86	\N
308	216	203	1	\N
309	217	150	69	\N
310	217	179	0	\N
311	218	159	0	\N
312	218	197	0	\N
313	219	181	1	\N
314	220	214	0	\N
315	220	201	0	\N
316	221	186	1	\N
317	222	207	1	\N
318	223	170	1	\N
319	224	150	110	\N
320	225	150	103	\N
321	226	217	0	\N
322	226	213	0	\N
323	227	209	1	\N
324	228	168	1	\N
325	229	154	0	\N
326	230	218	1	\N
327	230	225	0	\N
328	231	207	0	\N
329	231	215	0	\N
330	232	150	104	\N
331	233	191	1	\N
332	234	150	91	\N
333	235	219	1	\N
334	236	173	0	\N
335	236	225	1	\N
336	237	223	0	\N
337	237	230	0	\N
338	238	204	0	\N
339	238	235	0	\N
340	239	169	1	\N
341	240	208	1	\N
342	241	150	98	\N
343	242	232	1	\N
344	242	227	0	\N
345	243	231	0	\N
346	243	212	0	\N
347	244	192	1	\N
348	245	244	1	\N
349	246	224	1	\N
350	247	243	1	\N
351	247	183	0	\N
352	248	198	0	\N
353	248	226	1	\N
354	249	218	0	\N
355	249	197	1	\N
356	250	246	1	\N
357	251	247	0	\N
358	251	240	0	\N
359	252	196	1	\N
360	253	231	1	\N
361	253	174	0	\N
362	254	227	1	\N
363	255	150	60	\N
364	256	255	0	\N
365	256	255	1	\N
366	256	156	1	\N
367	256	219	0	\N
368	256	239	0	\N
369	256	239	1	\N
370	256	232	0	\N
371	256	251	0	\N
372	256	251	1	\N
373	256	214	1	\N
374	256	177	0	\N
375	256	223	1	\N
376	256	210	0	\N
377	256	210	1	\N
378	256	248	0	\N
379	256	248	1	\N
380	256	191	0	\N
381	256	230	1	\N
382	256	236	0	\N
383	256	236	1	\N
384	256	161	0	\N
385	256	234	0	\N
386	256	234	1	\N
387	256	244	0	\N
388	256	238	0	\N
389	256	238	1	\N
390	256	233	0	\N
391	256	233	1	\N
392	256	173	1	\N
393	256	185	0	\N
394	256	185	1	\N
395	256	162	0	\N
396	256	187	1	\N
397	256	247	1	\N
398	256	151	0	\N
399	256	208	0	\N
400	256	206	0	\N
401	256	206	1	\N
402	256	193	1	\N
403	256	220	0	\N
404	256	220	1	\N
405	256	211	0	\N
406	256	211	1	\N
407	256	217	1	\N
408	256	246	0	\N
409	256	159	1	\N
410	256	204	1	\N
411	256	237	0	\N
412	256	237	1	\N
413	256	160	0	\N
414	256	160	1	\N
415	256	241	0	\N
416	256	241	1	\N
417	256	180	0	\N
418	256	150	63	\N
419	256	150	64	\N
420	256	150	72	\N
421	256	150	74	\N
422	256	150	75	\N
423	256	150	79	\N
424	256	150	82	\N
425	256	150	84	\N
426	256	150	90	\N
427	256	150	92	\N
428	256	150	95	\N
429	256	150	101	\N
430	256	150	105	\N
431	256	150	111	\N
432	256	150	117	\N
433	256	249	0	\N
434	256	249	1	\N
435	256	253	0	\N
436	256	253	1	\N
437	256	205	0	\N
438	256	205	1	\N
439	256	182	1	\N
440	256	175	1	\N
441	256	190	1	\N
442	256	171	1	\N
443	256	245	0	\N
444	256	245	1	\N
445	256	240	1	\N
446	256	235	1	\N
447	256	184	0	\N
448	256	184	1	\N
449	256	170	0	\N
450	256	165	0	\N
451	256	222	0	\N
452	256	222	1	\N
453	256	250	0	\N
454	256	250	1	\N
455	256	215	1	\N
456	256	252	0	\N
457	256	252	1	\N
458	256	224	0	\N
459	256	254	0	\N
460	256	254	1	\N
461	256	164	1	\N
462	256	213	1	\N
463	256	243	0	\N
464	256	228	0	\N
465	256	228	1	\N
466	256	201	1	\N
467	256	167	0	\N
468	256	167	1	\N
469	256	194	0	\N
470	256	194	1	\N
471	256	178	1	\N
472	256	202	0	\N
473	256	202	1	\N
474	256	179	1	\N
475	256	172	0	\N
476	256	188	0	\N
477	256	183	1	\N
478	256	212	1	\N
479	256	199	0	\N
480	256	199	1	\N
481	256	203	0	\N
482	256	216	0	\N
483	256	216	1	\N
484	256	196	0	\N
485	256	242	0	\N
486	256	242	1	\N
487	256	226	0	\N
488	256	189	0	\N
489	256	189	1	\N
490	256	221	0	\N
491	256	221	1	\N
492	256	176	1	\N
493	256	229	0	\N
494	256	229	1	\N
495	256	192	0	\N
496	257	256	0	\N
497	258	257	0	\N
498	258	257	1	\N
499	259	256	9	\N
500	259	258	0	\N
501	260	256	10	\N
502	261	256	8	\N
503	262	256	5	\N
504	263	256	4	\N
505	264	256	1	\N
506	265	256	3	\N
507	266	263	1	\N
508	267	256	11	\N
509	268	267	1	\N
510	269	264	1	\N
511	270	256	7	\N
512	271	266	1	\N
513	272	259	0	\N
514	272	266	0	\N
515	273	265	0	\N
516	273	268	0	\N
517	274	256	12	\N
518	275	271	1	\N
519	276	264	0	\N
520	276	263	0	\N
521	277	262	0	\N
522	277	275	0	\N
523	278	261	1	\N
524	279	276	0	\N
525	279	269	0	\N
526	280	267	0	\N
527	280	272	0	\N
528	281	258	1	\N
529	281	277	1	\N
530	282	270	1	\N
531	282	277	0	\N
532	283	275	1	\N
533	284	260	1	\N
534	285	256	13	\N
535	286	285	1	\N
536	286	272	1	\N
537	287	282	1	\N
538	288	256	6	\N
539	289	280	1	\N
540	289	281	0	\N
541	290	265	1	\N
542	291	262	1	\N
543	292	256	2	\N
544	293	260	0	\N
545	293	273	1	\N
546	294	293	0	\N
547	294	286	0	\N
548	295	259	1	\N
549	296	293	1	\N
550	296	273	0	\N
551	297	291	0	\N
552	297	287	0	\N
553	298	270	0	\N
554	298	296	0	\N
555	299	294	0	\N
556	299	289	0	\N
557	300	271	0	\N
558	300	290	0	\N
559	301	294	1	\N
560	301	274	0	\N
561	302	268	1	\N
562	303	284	1	\N
563	304	299	1	\N
564	304	297	1	\N
565	305	295	0	\N
566	305	279	0	\N
567	306	289	1	\N
568	306	302	0	\N
569	307	300	1	\N
570	307	297	0	\N
571	308	269	1	\N
572	309	308	1	\N
573	310	261	0	\N
574	310	298	0	\N
575	311	301	0	\N
576	311	307	1	\N
577	312	286	1	\N
578	313	288	1	\N
579	314	299	0	\N
580	314	312	0	\N
581	315	310	1	\N
582	315	313	1	\N
583	316	292	0	\N
584	316	300	0	\N
585	317	281	1	\N
586	318	283	1	\N
587	319	316	1	\N
588	319	287	1	\N
589	320	311	0	\N
590	320	311	1	\N
591	321	319	0	\N
592	321	308	0	\N
593	322	318	1	\N
594	322	298	1	\N
595	323	295	1	\N
596	324	288	0	\N
597	324	307	0	\N
598	325	304	0	\N
599	325	313	0	\N
600	326	317	1	\N
601	327	324	1	\N
602	327	278	1	\N
603	328	327	1	\N
604	329	280	0	\N
605	329	323	0	\N
606	330	309	1	\N
607	331	302	1	\N
608	332	292	1	\N
609	333	291	1	\N
610	334	310	0	\N
611	334	333	0	\N
612	335	331	1	\N
613	336	319	1	\N
614	337	322	0	\N
615	337	317	0	\N
616	338	329	1	\N
617	338	279	1	\N
618	339	304	1	\N
619	339	318	0	\N
620	340	316	0	\N
621	340	336	0	\N
622	341	340	1	\N
623	341	309	0	\N
624	342	282	0	\N
625	342	338	1	\N
626	343	328	0	\N
627	343	335	0	\N
628	344	321	1	\N
629	344	315	0	\N
630	345	276	1	\N
631	345	306	0	\N
632	346	344	1	\N
633	346	296	1	\N
634	347	312	1	\N
635	348	305	0	\N
636	348	347	0	\N
637	349	326	0	\N
638	349	325	0	\N
639	350	303	0	\N
640	350	330	0	\N
641	351	284	0	\N
642	351	321	0	\N
643	352	322	1	\N
644	353	349	1	\N
645	353	323	1	\N
646	354	333	1	\N
647	355	340	0	\N
648	355	346	0	\N
649	356	337	1	\N
650	356	345	1	\N
651	357	274	1	\N
652	358	349	0	\N
653	358	336	1	\N
654	359	108	2	\N
655	360	359	0	\N
656	360	359	1	\N
657	361	360	0	\N
658	361	360	1	\N
659	362	108	4	\N
660	363	362	1	\N
661	364	109	0	\N
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
7	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"NFT-001": {"name": "One", "image": ["ipfs://some_hash1"], "version": "1.0"}, "NFT-002": {"name": "Two", "image": ["ipfs://some_hash2"], "version": "1.0"}, "NFT-files": {"id": "1", "name": "NFT with files", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": ["ipfs://somehash"], "version": "1.0", "mediaType": "image/png", "description": ["NFT with different types of files"]}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a3674e46542d303031a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65634f6e656776657273696f6e63312e30674e46542d303032a365696d6167658171697066733a2f2f736f6d655f6861736832646e616d656354776f6776657273696f6e63312e30694e46542d66696c6573a76b6465736372697074696f6e8178214e4654207769746820646966666572656e74207479706573206f662066696c65736566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e79626964613165696d616765816f697066733a2f2f736f6d6568617368696d656469615479706569696d6167652f706e67646e616d656e4e465420776974682066696c65736776657273696f6e63312e30	124
9	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"4349502d303032352d76312d686578": {"name": "CIP-0025-v1-hex", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1781e343334393530326433303330333233353264373633313264363836353738a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656f4349502d303032352d76312d6865786776657273696f6e63312e30	127
10	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"CIP-0025-v1-utf8": {"name": "CIP-0025-v1-utf8", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1704349502d303032352d76312d75746638a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65704349502d303032352d76312d757466386776657273696f6e63312e30	128
11	721	{"0x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"0x4349502d303032352d7632": {"name": "CIP-0025-v2", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a1581c17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029a14b4349502d303032352d7632a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656b4349502d303032352d76326776657273696f6e63312e30	129
12	6862	{"name": "Test Portfolio", "pools": [{"id": "7c6650b98817d99528db45fea9ba86520c748a932377549447a5a823", "weight": 1}, {"id": "7d1f8ae7b5330208dac263c69d98d0bd2a113d54014a96aab991b806", "weight": 1}, {"id": "113104a69508f2bc629d67c9a202a41d114960ce3541d2e3dad953e8", "weight": 1}, {"id": "5ae4f3c1648dc6cff686c82e52a28bcf85f6f95d8df4cf7e52863d4b", "weight": 1}, {"id": "61a34b4c64319736cdbf2374d5082d3867a7871cf90e3a6d259ea55b", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783837633636353062393838313764393935323864623435666561396261383635323063373438613933323337373534393434376135613832336677656967687401a2626964783837643166386165376235333330323038646163323633633639643938643062643261313133643534303134613936616162393931623830366677656967687401a2626964783831313331303461363935303866326263363239643637633961323032613431643131343936306365333534316432653364616439353365386677656967687401a2626964783835616534663363313634386463366366663638366338326535326132386263663835663666393564386466346366376535323836336434626677656967687401a2626964783836316133346234633634333139373336636462663233373464353038326433383637613738373163663930653361366432353965613535626677656967687401	132
13	6862	{"name": "Test Portfolio", "pools": [{"id": "7c6650b98817d99528db45fea9ba86520c748a932377549447a5a823", "weight": 0}, {"id": "7d1f8ae7b5330208dac263c69d98d0bd2a113d54014a96aab991b806", "weight": 0}, {"id": "113104a69508f2bc629d67c9a202a41d114960ce3541d2e3dad953e8", "weight": 0}, {"id": "5ae4f3c1648dc6cff686c82e52a28bcf85f6f95d8df4cf7e52863d4b", "weight": 0}, {"id": "61a34b4c64319736cdbf2374d5082d3867a7871cf90e3a6d259ea55b", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783837633636353062393838313764393935323864623435666561396261383635323063373438613933323337373534393434376135613832336677656967687400a2626964783837643166386165376235333330323038646163323633633639643938643062643261313133643534303134613936616162393931623830366677656967687400a2626964783831313331303461363935303866326263363239643637633961323032613431643131343936306365333534316432653364616439353365386677656967687400a2626964783835616534663363313634386463366366663638366338326535326132386263663835663666393564386466346366376535323836336434626677656967687400a2626964783836316133346234633634333139373336636462663233373464353038326433383637613738373163663930653361366432353965613535626677656967687401	133
14	6862	{"pools": [{"id": "7d1f8ae7b5330208dac263c69d98d0bd2a113d54014a96aab991b806", "weight": 1}]}	\\xa1191acea165706f6f6c7381a2626964783837643166386165376235333330323038646163323633633639643938643062643261313133643534303134613936616162393931623830366677656967687401	146
15	123	"1234"	\\xa1187b6431323334	148
17	6862	{"name": "Test Portfolio", "pools": [{"id": "7c6650b98817d99528db45fea9ba86520c748a932377549447a5a823", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7381a2626964783837633636353062393838313764393935323864623435666561396261383635323063373438613933323337373534393434376135613832336677656967687401	154
18	6862	{"name": "Test Portfolio", "pools": [{"id": "7c6650b98817d99528db45fea9ba86520c748a932377549447a5a823", "weight": 1}, {"id": "7d1f8ae7b5330208dac263c69d98d0bd2a113d54014a96aab991b806", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7382a2626964783837633636353062393838313764393935323864623435666561396261383635323063373438613933323337373534393434376135613832336677656967687401a2626964783837643166386165376235333330323038646163323633633639643938643062643261313133643534303134613936616162393931623830366677656967687401	256
19	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	358
\.


--
-- Data for Name: tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_out (id, tx_id, index, address, address_raw, address_has_script, payment_cred, stake_address_id, value, data_hash, inline_datum_id, reference_script_id) FROM stdin;
1	1	0	5oP9ib6ym3XYXVHKmyAcfsDkuBHmSLKm9zCPPamUVzzDU4g2DUn7BadsG4EQGxFK4z	\\x82d818582683581c1328cd1fcfed05b470299b62658449d1bbefe9e5effd5e1b93c48239a10243190378001a83ef07af	f	\N	\N	910909092	\N	\N	\N
2	2	0	5oP9ib6ym3XbMw7hJnS1EdvPG9qc5A123EStQKJUdRmrpa7VMf2JzhJQm8ia8Q8v47	\\x82d818582683581c4c38aa87070507608a56e0acc4f896f672a9b36c51daf1381428f408a10243190378001a3a1a73d0	f	\N	\N	910909092	\N	\N	\N
3	3	0	5oP9ib6ym3Xc3WtKeRtF1WQbqnSDqevAAdZffZFs7N5yYJ9d35bVE67kX4JBYev2vp	\\x82d818582683581c59f4cc7c3dbbaf30f9f03452d671241544b9485a29ef7e2c264d8c1ba10243190378001accc5514d	f	\N	\N	910909092	\N	\N	\N
4	4	0	5oP9ib6ym3XcEYNDz6F13qxfX1WVeSvqRr8HeQVUzAzQeRpC5Ra9pbskM6uY5uXkK2	\\x82d818582683581c5dc83587a2754e416916796d3a5be7d49762b55eeaeec735fe06c56ca10243190378001a117ad451	f	\N	\N	910909092	\N	\N	\N
5	5	0	5oP9ib6ym3XcmvC4pT9yG1cipuukXVMgmwpr7hGyNM7ED8FwfkmjRQ8c5ypR5oFzgK	\\x82d818582683581c68ab662c5aca5fdcb84c6730f4b531c18fa2a4824be999886204bbbba10243190378001a95570afc	f	\N	\N	910909092	\N	\N	\N
6	6	0	5oP9ib6ym3XdUcUEDThDAUwoLv1VbubYbKVSosm6yJTyzjocVFWynVHPyhsfDTcVZo	\\x82d818582683581c76ca550ae57bcd8265fed0ca6bb123b0232be6e084e9ebc4dc71053ca10243190378001a1f528c76	f	\N	\N	910909092	\N	\N	\N
7	7	0	5oP9ib6ym3XekPg43xDijKZV1HsBwrcn6ycExpaw78JyDhRtEFcep5aKhsQJPrCZJd	\\x82d818582683581c90643c06a4331d03926c704c48317bbd7f49d952d7091aee544a1b40a10243190378001a4d3991c6	f	\N	\N	910909092	\N	\N	\N
8	8	0	5oP9ib6ym3Xf5aHsA2vASF7qgkb34Dh1RpqDwCb1gHm7aimcnfmx8E8DQPHUib4Uwc	\\x82d818582683581c970c49586dbc8fdb165079c010bfa56b312327f8ef5dd174ae84c361a10243190378001a1f5d2523	f	\N	\N	910909092	\N	\N	\N
9	9	0	5oP9ib6ym3XfDoFrNxn29Eu4ZE8HvfFe3C6kkKLDYirRPHfMbdbvLephVG3BS1muA8	\\x82d818582683581c99e6cade20b8a27707b6b8956f994224726a7ed1093bdfab4e90d2ada10243190378001aa0abeb61	f	\N	\N	910909092	\N	\N	\N
10	10	0	5oP9ib6ym3Xfqt99VgnJ315zHNxjGZu9B77kmhmMs6RyTPFSg5qhGqZi2FVTNi9gjt	\\x82d818582683581ca66c314054c28049da0eee87d96a4a2d6d4963d8945d6c6f53dbbff3a10243190378001ab6ee6da3	f	\N	\N	910909092	\N	\N	\N
11	11	0	5oP9ib6ym3XfxojpyZ4MvnpPW4Not7i5TuWAGe9Mv3r9ardfNUfHoRUCyeGEuY2xmH	\\x82d818582683581ca8d34497882b40312602ab66269bffca596cb9d4e36554dacff6b8b0a10243190378001ad5c9181c	f	\N	\N	910909092	\N	\N	\N
12	12	0	addr_test1qz2v6hfzfxc97yw6wuy0knz89jtgaa8q3qm27genfeph0yvplyajmhxr652ppsjtcw75d9ytkzvwuadur3nzmg37ng6sxp2vtk	\\x0094cd5d2249b05f11da7708fb4c472c968ef4e08836af23334e43779181f93b2ddcc3d51410c24bc3bd46948bb098ee75bc1c662da23e9a35	f	\\x94cd5d2249b05f11da7708fb4c472c968ef4e08836af23334e437791	\N	3681818181818181	\N	\N	\N
13	13	0	addr_test1vqua03cz688eyx3yd46744rvk386m2qw0eysgnlx67cra9g66xye9	\\x6039d7c702d1cf921a246d75ead46cb44fada80e7e49044fe6d7b03e95	f	\\x39d7c702d1cf921a246d75ead46cb44fada80e7e49044fe6d7b03e95	\N	3681818181818190	\N	\N	\N
14	14	0	addr_test1vz5dz0cst7z0n9ux2m7yuqsytvws47ca0jzh2p82n4y38jqjt0qkj	\\x60a8d13f105f84f9978656fc4e02045b1d0afb1d7c857504ea9d4913c8	f	\\xa8d13f105f84f9978656fc4e02045b1d0afb1d7c857504ea9d4913c8	\N	3681818181818181	\N	\N	\N
15	15	0	addr_test1vz5xk2kh8d3u6s2ge7cwwv4m4xzvr4n6vlpycrmhenrdcwcx4kjqn	\\x60a86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	f	\\xa86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	\N	3681818181818181	\N	\N	\N
16	16	0	addr_test1qr8zen0nu8tkz6rqenxzz6puaec52zehmtdxnfft2wvekjgmu2x76d2ayavq95ad2r5wxf7zz9xmvqyrg9trfntr9jzsm02cmy	\\x00ce2ccdf3e1d7616860cccc21683cee71450b37dada69a52b53999b491be28ded355d275802d3ad50e8e327c2114db60083415634cd632c85	f	\\xce2ccdf3e1d7616860cccc21683cee71450b37dada69a52b53999b49	\N	3681818181818190	\N	\N	\N
17	17	0	addr_test1qph8n5pfags09hcjdest2470w26mepfpzpxv4y0lrrjwcxwy769stjdwuqfyl6kff2cl26sem6dpqap8j6zyqpex49wqe88pee	\\x006e79d029ea20f2df126e60b557cf72b5bc8521104cca91ff18e4ec19c4f68b05c9aee0124feac94ab1f56a19de9a1074279684400726a95c	f	\\x6e79d029ea20f2df126e60b557cf72b5bc8521104cca91ff18e4ec19	\N	3681818181818181	\N	\N	\N
18	18	0	addr_test1vqcgqpjatj8j2xxhdwv9a5a0fycn5dcchtlrgquv798566q2qz26s	\\x603080065d5c8f2518d76b985ed3af49313a3718bafe34038cf14f4d68	f	\\x3080065d5c8f2518d76b985ed3af49313a3718bafe34038cf14f4d68	\N	3681818181818181	\N	\N	\N
19	19	0	addr_test1qrak0s853cjez4jcnh3wf52v94fgm76dggrrsa5qdefvurd6w4wzp30gdehh9l433rt27qnu7swduxep624jekp7tzuqqmw6rc	\\x00fb67c0f48e259156589de2e4d14c2d528dfb4d42063876806e52ce0dba755c20c5e86e6f72feb188d6af027cf41cde1b21d2ab2cd83e58b8	f	\\xfb67c0f48e259156589de2e4d14c2d528dfb4d42063876806e52ce0d	\N	3681818181818181	\N	\N	\N
20	20	0	addr_test1qpn9qr9dcpk9cxjcr0wl5wn40r5h8tayhshwzk24hlypa94n0gth6ts4h97wmrjqku0c33asll8cejqsp7v6l7tqsjvs087xfw	\\x0066500cadc06c5c1a581bddfa3a7578e973afa4bc2ee15955bfc81e96b37a177d2e15b97ced8e40b71f88c7b0ffcf8cc8100f99aff9608499	f	\\x66500cadc06c5c1a581bddfa3a7578e973afa4bc2ee15955bfc81e96	\N	3681818181818181	\N	\N	\N
21	21	0	addr_test1vrn5cjln9l473xs9htku6u24lw54u3uxj5s527ukt9p4mmcemzgtl	\\x60e74c4bf32febe89a05baedcd7155fba95e47869521457b9659435def	f	\\xe74c4bf32febe89a05baedcd7155fba95e47869521457b9659435def	\N	3681818181818181	\N	\N	\N
22	22	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681818181818181	\N	\N	\N
23	23	0	addr_test1qq4v8ufj6v8atgq98jq6nyfqs6egjnckw53wvfftrr2x9zwjmnphvwqu9yktac60w7gthvr2mcgke6dmx8sqaer3hets0h9vsh	\\x002ac3f132d30fd5a0053c81a9912086b2894f167522e6252b18d46289d2dcc376381c292cbee34f7790bbb06ade116ce9bb31e00ee471be57	f	\\x2ac3f132d30fd5a0053c81a9912086b2894f167522e6252b18d46289	\N	3681818181818181	\N	\N	\N
24	24	0	addr_test1vr9u53m4nd4kc5gm9tdl6gjrnht590ed4p3pscntd9s86acqah44c	\\x60cbca47759b6b6c511b2adbfd22439dd742bf2da86218626b69607d77	f	\\xcbca47759b6b6c511b2adbfd22439dd742bf2da86218626b69607d77	\N	3681818181818181	\N	\N	\N
25	25	0	addr_test1qpep4xn38ntjmvtm0rm8mj7ej9k4sddm37ht2g0v3uzcs2zn0fwz7t4fcegw0277u8kcc35x46dpc2e9ls6ueuphqd6qknjcee	\\x00721a9a713cd72db17b78f67dcbd9916d5835bb8faeb521ec8f058828537a5c2f2ea9c650e7abdee1ed8c4686ae9a1c2b25fc35ccf0370374	f	\\x721a9a713cd72db17b78f67dcbd9916d5835bb8faeb521ec8f058828	\N	3681818181818181	\N	\N	\N
26	26	0	addr_test1vp2ql60nvs6jpvjghhsjq4vaux5p9fckxs33s6e2wah9z3gvt9gxc	\\x60540fe9f3643520b248bde120559de1a812a7163423186b2a776e5145	f	\\x540fe9f3643520b248bde120559de1a812a7163423186b2a776e5145	\N	3681818181818181	\N	\N	\N
27	27	0	addr_test1qramjuhp2lq8z78xe08rg7anzjg8vcrvj3y2szpa7fygex55kyvqhude3c004qm33xsqamprcp0ne55kj35q4q3xyefst2ae35	\\x00fbb972e157c07178e6cbce347bb3149076606c9448a8083df2488c9a94b1180bf1b98e1efa837189a00eec23c05f3cd29694680a82262653	f	\\xfbb972e157c07178e6cbce347bb3149076606c9448a8083df2488c9a	\N	3681818181818181	\N	\N	\N
28	28	0	addr_test1qpsl2r250d97vwwzytxtn6yh3kmcvnynfvqzjer9egfaqhutr4hnmdg8rnnaqzp6w08td2gjczstvy6ncmd952eywyqsv7j9hy	\\x0061f50d547b4be639c222ccb9e8978db7864c934b00296465ca13d05f8b1d6f3db5071ce7d0083a73ceb6a912c0a0b61353c6da5a2b247101	f	\\x61f50d547b4be639c222ccb9e8978db7864c934b00296465ca13d05f	\N	3681818181818181	\N	\N	\N
29	29	0	addr_test1qzahja7gd46ttdzkc3l8z0fdqyz4ns4mrnwdvrq92whw7zkr9uaurlyr592ujcwzqpxr95rlyu98mxlfhuh5pjgm8kls8g5x5h	\\x00bb7977c86d74b5b456c47e713d2d010559c2bb1cdcd60c0553aeef0ac32f3bc1fc83a155c961c2004c32d07f270a7d9be9bf2f40c91b3dbf	f	\\xbb7977c86d74b5b456c47e713d2d010559c2bb1cdcd60c0553aeef0a	\N	3681818181818181	\N	\N	\N
30	30	0	addr_test1vpvfst30v5aznrxn94yvwe32vc6l6hvje2k6c5e5u3gekvqq8ej85	\\x6058982e2f653a298cd32d48c7662a6635fd5d92caadac5334e4519b30	f	\\x58982e2f653a298cd32d48c7662a6635fd5d92caadac5334e4519b30	\N	3681818181818181	\N	\N	\N
31	31	0	addr_test1vqa0k6qm56drx5rp8ddua3m9cdzj5ngurev3yqc624npr5grpepj5	\\x603afb681ba69a3350613b5bcec765c3452a4d1c1e5912031a556611d1	f	\\x3afb681ba69a3350613b5bcec765c3452a4d1c1e5912031a556611d1	\N	3681818181818181	\N	\N	\N
32	32	0	addr_test1qqtakscq4rmxgx0mue3pq6vl7aq88rq67347j0rgue93q3unuyjzana5rtmq3zzlhs6hjdp2awyh6vu59kz7sdgackdqv6qyg2	\\x0017db4300a8f66419fbe66210699ff740738c1af46be93c68e64b104793e1242ecfb41af608885fbc3579342aeb897d33942d85e8351dc59a	f	\\x17db4300a8f66419fbe66210699ff740738c1af46be93c68e64b1047	\N	3681818181818181	\N	\N	\N
33	33	0	addr_test1vq9weqvprk4cyl5v40sx9jljjyg4hhxzr3nqxrctx9jgjncqp5q9p	\\x600aec81811dab827e8cabe062cbf291115bdcc21c66030f0b3164894f	f	\\x0aec81811dab827e8cabe062cbf291115bdcc21c66030f0b3164894f	\N	3681818181818181	\N	\N	\N
34	35	0	addr_test1qq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5aft2tmfhkuum7hj78kf4nlj85m2nnekjsx3pa7nnmwt82sl356vv	\\x001e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3a95a97b4dedce6fd7978f64d67f91e9b54e79b4a06887be9cf6e59d5	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	16	500000000	\N	\N	\N
35	35	1	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681817681651228	\N	\N	\N
36	36	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681817681473231	\N	\N	\N
37	37	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681817681293914	\N	\N	\N
72	66	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681814878327629	\N	\N	\N
38	38	0	addr_test1qramjuhp2lq8z78xe08rg7anzjg8vcrvj3y2szpa7fygex55kyvqhude3c004qm33xsqamprcp0ne55kj35q4q3xyefst2ae35	\\x00fbb972e157c07178e6cbce347bb3149076606c9448a8083df2488c9a94b1180bf1b98e1efa837189a00eec23c05f3cd29694680a82262653	f	\\xfbb972e157c07178e6cbce347bb3149076606c9448a8083df2488c9a	8	3681818181637632	\N	\N	\N
39	39	0	addr_test1qramjuhp2lq8z78xe08rg7anzjg8vcrvj3y2szpa7fygex55kyvqhude3c004qm33xsqamprcp0ne55kj35q4q3xyefst2ae35	\\x00fbb972e157c07178e6cbce347bb3149076606c9448a8083df2488c9a94b1180bf1b98e1efa837189a00eec23c05f3cd29694680a82262653	f	\\xfbb972e157c07178e6cbce347bb3149076606c9448a8083df2488c9a	8	3681818181443619	\N	\N	\N
40	40	0	addr_test1qq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5ag47e00zel2p0wyt9y5z7eltm433fr9wz6rgr5rrlzmaaqekwr8w	\\x001e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3a8afb2f78b3f505ee22ca4a0bd9faf758c5232b85a1a07418fe2df7a	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	14	600000000	\N	\N	\N
41	40	1	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681817081126961	\N	\N	\N
42	41	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681817080948964	\N	\N	\N
43	42	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681817080769647	\N	\N	\N
44	43	0	addr_test1qq4v8ufj6v8atgq98jq6nyfqs6egjnckw53wvfftrr2x9zwjmnphvwqu9yktac60w7gthvr2mcgke6dmx8sqaer3hets0h9vsh	\\x002ac3f132d30fd5a0053c81a9912086b2894f167522e6252b18d46289d2dcc376381c292cbee34f7790bbb06ade116ce9bb31e00ee471be57	f	\\x2ac3f132d30fd5a0053c81a9912086b2894f167522e6252b18d46289	6	3681818181637632	\N	\N	\N
45	44	0	addr_test1qq4v8ufj6v8atgq98jq6nyfqs6egjnckw53wvfftrr2x9zwjmnphvwqu9yktac60w7gthvr2mcgke6dmx8sqaer3hets0h9vsh	\\x002ac3f132d30fd5a0053c81a9912086b2894f167522e6252b18d46289d2dcc376381c292cbee34f7790bbb06ade116ce9bb31e00ee471be57	f	\\x2ac3f132d30fd5a0053c81a9912086b2894f167522e6252b18d46289	6	3681818181446391	\N	\N	\N
46	45	0	addr_test1qq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5amsn8tke0rvyjdgy5hxj4yu0ydc73cm0upwt2z7s94qx3sa4c6rc	\\x001e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3bb84cebb65e36124d4129734aa4e3c8dc7a38dbf8172d42f40b501a3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	17	200000000	\N	\N	\N
47	45	1	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681816880602694	\N	\N	\N
48	46	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681816880424697	\N	\N	\N
49	47	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681816880245380	\N	\N	\N
50	48	0	addr_test1qzahja7gd46ttdzkc3l8z0fdqyz4ns4mrnwdvrq92whw7zkr9uaurlyr592ujcwzqpxr95rlyu98mxlfhuh5pjgm8kls8g5x5h	\\x00bb7977c86d74b5b456c47e713d2d010559c2bb1cdcd60c0553aeef0ac32f3bc1fc83a155c961c2004c32d07f270a7d9be9bf2f40c91b3dbf	f	\\xbb7977c86d74b5b456c47e713d2d010559c2bb1cdcd60c0553aeef0a	10	3681818181637632	\N	\N	\N
51	49	0	addr_test1qzahja7gd46ttdzkc3l8z0fdqyz4ns4mrnwdvrq92whw7zkr9uaurlyr592ujcwzqpxr95rlyu98mxlfhuh5pjgm8kls8g5x5h	\\x00bb7977c86d74b5b456c47e713d2d010559c2bb1cdcd60c0553aeef0ac32f3bc1fc83a155c961c2004c32d07f270a7d9be9bf2f40c91b3dbf	f	\\xbb7977c86d74b5b456c47e713d2d010559c2bb1cdcd60c0553aeef0a	10	3681818181443619	\N	\N	\N
52	50	0	addr_test1qq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t56etzsu78ytlrjl9g42qr9u7s8277e565l92yqv8dr92w0qua8kay	\\x001e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d35958a1cf1c8bf8e5f2a2aa00cbcf40eaf7b34d53e55100c3b465539e	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	12	500000000	\N	\N	\N
53	50	1	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681816380078427	\N	\N	\N
54	51	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681816379900430	\N	\N	\N
55	52	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681816379721113	\N	\N	\N
56	53	0	addr_test1qpsl2r250d97vwwzytxtn6yh3kmcvnynfvqzjer9egfaqhutr4hnmdg8rnnaqzp6w08td2gjczstvy6ncmd952eywyqsv7j9hy	\\x0061f50d547b4be639c222ccb9e8978db7864c934b00296465ca13d05f8b1d6f3db5071ce7d0083a73ceb6a912c0a0b61353c6da5a2b247101	f	\\x61f50d547b4be639c222ccb9e8978db7864c934b00296465ca13d05f	9	3681818181637632	\N	\N	\N
57	54	0	addr_test1qpsl2r250d97vwwzytxtn6yh3kmcvnynfvqzjer9egfaqhutr4hnmdg8rnnaqzp6w08td2gjczstvy6ncmd952eywyqsv7j9hy	\\x0061f50d547b4be639c222ccb9e8978db7864c934b00296465ca13d05f8b1d6f3db5071ce7d0083a73ceb6a912c0a0b61353c6da5a2b247101	f	\\x61f50d547b4be639c222ccb9e8978db7864c934b00296465ca13d05f	9	3681818181443619	\N	\N	\N
58	55	0	addr_test1qq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5m0wjnvlkfhgfrryyphwllvug0fctnr559klmlacjyukf3szc68yd	\\x001e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d36f74a6cfd937424632103777fece21e9c2e63a50b6feffdc489cb263	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	19	500000000	\N	\N	\N
59	55	1	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681815879554160	\N	\N	\N
60	56	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681815879376163	\N	\N	\N
61	57	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681815879196846	\N	\N	\N
62	58	0	addr_test1qpn9qr9dcpk9cxjcr0wl5wn40r5h8tayhshwzk24hlypa94n0gth6ts4h97wmrjqku0c33asll8cejqsp7v6l7tqsjvs087xfw	\\x0066500cadc06c5c1a581bddfa3a7578e973afa4bc2ee15955bfc81e96b37a177d2e15b97ced8e40b71f88c7b0ffcf8cc8100f99aff9608499	f	\\x66500cadc06c5c1a581bddfa3a7578e973afa4bc2ee15955bfc81e96	5	3681818181637632	\N	\N	\N
63	59	0	addr_test1qpn9qr9dcpk9cxjcr0wl5wn40r5h8tayhshwzk24hlypa94n0gth6ts4h97wmrjqku0c33asll8cejqsp7v6l7tqsjvs087xfw	\\x0066500cadc06c5c1a581bddfa3a7578e973afa4bc2ee15955bfc81e96b37a177d2e15b97ced8e40b71f88c7b0ffcf8cc8100f99aff9608499	f	\\x66500cadc06c5c1a581bddfa3a7578e973afa4bc2ee15955bfc81e96	5	3681818181443619	\N	\N	\N
64	60	0	addr_test1qq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5m87rq53cjlvkwca0eugwq2vhe88mc8c7vjtcfa56mmwmqsu7enef	\\x001e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d367f0c148e25f659d8ebf3c4380a65f273ef07c79925e13da6b7b76c1	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	15	500000000	\N	\N	\N
65	60	1	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681815379029893	\N	\N	\N
66	61	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681815378851896	\N	\N	\N
67	62	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681815378672579	\N	\N	\N
68	63	0	addr_test1qpep4xn38ntjmvtm0rm8mj7ej9k4sddm37ht2g0v3uzcs2zn0fwz7t4fcegw0277u8kcc35x46dpc2e9ls6ueuphqd6qknjcee	\\x00721a9a713cd72db17b78f67dcbd9916d5835bb8faeb521ec8f058828537a5c2f2ea9c650e7abdee1ed8c4686ae9a1c2b25fc35ccf0370374	f	\\x721a9a713cd72db17b78f67dcbd9916d5835bb8faeb521ec8f058828	7	3681818181637632	\N	\N	\N
69	64	0	addr_test1qpep4xn38ntjmvtm0rm8mj7ej9k4sddm37ht2g0v3uzcs2zn0fwz7t4fcegw0277u8kcc35x46dpc2e9ls6ueuphqd6qknjcee	\\x00721a9a713cd72db17b78f67dcbd9916d5835bb8faeb521ec8f058828537a5c2f2ea9c650e7abdee1ed8c4686ae9a1c2b25fc35ccf0370374	f	\\x721a9a713cd72db17b78f67dcbd9916d5835bb8faeb521ec8f058828	7	3681818181443619	\N	\N	\N
70	65	0	addr_test1qq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5637m360edt6hrleld8l4zwk4mxhshj57ghfq3jxy494x2syvf0ft	\\x001e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d351f6e3a7e5abd5c7fcfda7fd44eb5766bc2f2a791748232312a5a995	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	18	500000000	\N	\N	\N
71	65	1	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681814878505626	\N	\N	\N
73	67	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681814878148312	\N	\N	\N
74	68	0	addr_test1qrak0s853cjez4jcnh3wf52v94fgm76dggrrsa5qdefvurd6w4wzp30gdehh9l433rt27qnu7swduxep624jekp7tzuqqmw6rc	\\x00fb67c0f48e259156589de2e4d14c2d528dfb4d42063876806e52ce0dba755c20c5e86e6f72feb188d6af027cf41cde1b21d2ab2cd83e58b8	f	\\xfb67c0f48e259156589de2e4d14c2d528dfb4d42063876806e52ce0d	4	3681818181637632	\N	\N	\N
75	69	0	addr_test1qrak0s853cjez4jcnh3wf52v94fgm76dggrrsa5qdefvurd6w4wzp30gdehh9l433rt27qnu7swduxep624jekp7tzuqqmw6rc	\\x00fb67c0f48e259156589de2e4d14c2d528dfb4d42063876806e52ce0dba755c20c5e86e6f72feb188d6af027cf41cde1b21d2ab2cd83e58b8	f	\\xfb67c0f48e259156589de2e4d14c2d528dfb4d42063876806e52ce0d	4	3681818181443619	\N	\N	\N
76	70	0	addr_test1qq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5m90dax8uwgufrhhf68zz9smtwjeqpz8ry3d2389ad83xzqrhjcjy	\\x001e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3657b7a63f1c8e2477ba747108b0dadd2c802238c916aa272f5a78984	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	22	300000000	\N	\N	\N
77	70	1	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681814577981359	\N	\N	\N
78	71	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681814577803362	\N	\N	\N
79	72	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681814577624045	\N	\N	\N
80	73	0	addr_test1qph8n5pfags09hcjdest2470w26mepfpzpxv4y0lrrjwcxwy769stjdwuqfyl6kff2cl26sem6dpqap8j6zyqpex49wqe88pee	\\x006e79d029ea20f2df126e60b557cf72b5bc8521104cca91ff18e4ec19c4f68b05c9aee0124feac94ab1f56a19de9a1074279684400726a95c	f	\\x6e79d029ea20f2df126e60b557cf72b5bc8521104cca91ff18e4ec19	3	3681818181637632	\N	\N	\N
81	74	0	addr_test1qph8n5pfags09hcjdest2470w26mepfpzpxv4y0lrrjwcxwy769stjdwuqfyl6kff2cl26sem6dpqap8j6zyqpex49wqe88pee	\\x006e79d029ea20f2df126e60b557cf72b5bc8521104cca91ff18e4ec19c4f68b05c9aee0124feac94ab1f56a19de9a1074279684400726a95c	f	\\x6e79d029ea20f2df126e60b557cf72b5bc8521104cca91ff18e4ec19	3	3681818181446391	\N	\N	\N
82	75	0	addr_test1qph8n5pfags09hcjdest2470w26mepfpzpxv4y0lrrjwcxwy769stjdwuqfyl6kff2cl26sem6dpqap8j6zyqpex49wqe88pee	\\x006e79d029ea20f2df126e60b557cf72b5bc8521104cca91ff18e4ec19c4f68b05c9aee0124feac94ab1f56a19de9a1074279684400726a95c	f	\\x6e79d029ea20f2df126e60b557cf72b5bc8521104cca91ff18e4ec19	3	3681818181265842	\N	\N	\N
83	76	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681814577439800	\N	\N	\N
84	77	0	addr_test1qq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t57qwy89ppxtl9lzrkgmd6pmqnsse8swt99dt27rt957sqqqj0j04j	\\x001e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3c0710e5084cbf97e21d91b6e83b04e10c9e0e594ad5abc35969e8000	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	13	300000000	\N	\N	\N
85	77	1	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681814277272847	\N	\N	\N
86	78	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681814277094850	\N	\N	\N
87	79	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681814276915533	\N	\N	\N
88	80	0	addr_test1qqtakscq4rmxgx0mue3pq6vl7aq88rq67347j0rgue93q3unuyjzana5rtmq3zzlhs6hjdp2awyh6vu59kz7sdgackdqv6qyg2	\\x0017db4300a8f66419fbe66210699ff740738c1af46be93c68e64b104793e1242ecfb41af608885fbc3579342aeb897d33942d85e8351dc59a	f	\\x17db4300a8f66419fbe66210699ff740738c1af46be93c68e64b1047	11	3681818181637632	\N	\N	\N
89	81	0	addr_test1qqtakscq4rmxgx0mue3pq6vl7aq88rq67347j0rgue93q3unuyjzana5rtmq3zzlhs6hjdp2awyh6vu59kz7sdgackdqv6qyg2	\\x0017db4300a8f66419fbe66210699ff740738c1af46be93c68e64b104793e1242ecfb41af608885fbc3579342aeb897d33942d85e8351dc59a	f	\\x17db4300a8f66419fbe66210699ff740738c1af46be93c68e64b1047	11	3681818181446391	\N	\N	\N
90	82	0	addr_test1qqtakscq4rmxgx0mue3pq6vl7aq88rq67347j0rgue93q3unuyjzana5rtmq3zzlhs6hjdp2awyh6vu59kz7sdgackdqv6qyg2	\\x0017db4300a8f66419fbe66210699ff740738c1af46be93c68e64b104793e1242ecfb41af608885fbc3579342aeb897d33942d85e8351dc59a	f	\\x17db4300a8f66419fbe66210699ff740738c1af46be93c68e64b1047	11	3681818181265842	\N	\N	\N
91	83	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681814276731288	\N	\N	\N
92	84	0	addr_test1qq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5afx6q04jp3zud82gcymcln43ql9200gh2qmutdf0ft2puq33t23e	\\x001e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3a93680fac831171a752304de3f3ac41f2a9ef45d40df16d4bd2b5078	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	21	500000000	\N	\N	\N
93	84	1	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681813776564335	\N	\N	\N
94	85	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681813776386338	\N	\N	\N
95	86	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681813776207021	\N	\N	\N
96	87	0	addr_test1qz2v6hfzfxc97yw6wuy0knz89jtgaa8q3qm27genfeph0yvplyajmhxr652ppsjtcw75d9ytkzvwuadur3nzmg37ng6sxp2vtk	\\x0094cd5d2249b05f11da7708fb4c472c968ef4e08836af23334e43779181f93b2ddcc3d51410c24bc3bd46948bb098ee75bc1c662da23e9a35	f	\\x94cd5d2249b05f11da7708fb4c472c968ef4e08836af23334e437791	1	3681818181637632	\N	\N	\N
97	88	0	addr_test1qz2v6hfzfxc97yw6wuy0knz89jtgaa8q3qm27genfeph0yvplyajmhxr652ppsjtcw75d9ytkzvwuadur3nzmg37ng6sxp2vtk	\\x0094cd5d2249b05f11da7708fb4c472c968ef4e08836af23334e43779181f93b2ddcc3d51410c24bc3bd46948bb098ee75bc1c662da23e9a35	f	\\x94cd5d2249b05f11da7708fb4c472c968ef4e08836af23334e437791	1	3681818181443575	\N	\N	\N
98	89	0	addr_test1qz2v6hfzfxc97yw6wuy0knz89jtgaa8q3qm27genfeph0yvplyajmhxr652ppsjtcw75d9ytkzvwuadur3nzmg37ng6sxp2vtk	\\x0094cd5d2249b05f11da7708fb4c472c968ef4e08836af23334e43779181f93b2ddcc3d51410c24bc3bd46948bb098ee75bc1c662da23e9a35	f	\\x94cd5d2249b05f11da7708fb4c472c968ef4e08836af23334e437791	1	3681818181263026	\N	\N	\N
99	90	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681813776022776	\N	\N	\N
100	91	0	addr_test1qq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5u5ehwpgzcmlfxf8uu5v4a4tna6cyzwkalls8huwj00js6q3yklzr	\\x001e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d394cddc140b1bfa4c93f394657b55cfbac104eb77ff81efc749ef9434	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	20	500000000	\N	\N	\N
101	91	1	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681813275855823	\N	\N	\N
102	92	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681813275677826	\N	\N	\N
103	93	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681813275498509	\N	\N	\N
104	94	0	addr_test1qr8zen0nu8tkz6rqenxzz6puaec52zehmtdxnfft2wvekjgmu2x76d2ayavq95ad2r5wxf7zz9xmvqyrg9trfntr9jzsm02cmy	\\x00ce2ccdf3e1d7616860cccc21683cee71450b37dada69a52b53999b491be28ded355d275802d3ad50e8e327c2114db60083415634cd632c85	f	\\xce2ccdf3e1d7616860cccc21683cee71450b37dada69a52b53999b49	2	3681818181637641	\N	\N	\N
105	95	0	addr_test1qr8zen0nu8tkz6rqenxzz6puaec52zehmtdxnfft2wvekjgmu2x76d2ayavq95ad2r5wxf7zz9xmvqyrg9trfntr9jzsm02cmy	\\x00ce2ccdf3e1d7616860cccc21683cee71450b37dada69a52b53999b491be28ded355d275802d3ad50e8e327c2114db60083415634cd632c85	f	\\xce2ccdf3e1d7616860cccc21683cee71450b37dada69a52b53999b49	2	3681818181443584	\N	\N	\N
106	96	0	addr_test1qr8zen0nu8tkz6rqenxzz6puaec52zehmtdxnfft2wvekjgmu2x76d2ayavq95ad2r5wxf7zz9xmvqyrg9trfntr9jzsm02cmy	\\x00ce2ccdf3e1d7616860cccc21683cee71450b37dada69a52b53999b491be28ded355d275802d3ad50e8e327c2114db60083415634cd632c85	f	\\xce2ccdf3e1d7616860cccc21683cee71450b37dada69a52b53999b49	2	3681818181263035	\N	\N	\N
107	97	0	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3681813275314264	\N	\N	\N
108	98	0	addr_test1wpnlxv2xv9a9ucvnvzqakwepzl9ltx7jzgm53av2e9ncv4sysemm8	\\x7067f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	t	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	\N	100000000	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	\N	\N
109	98	1	addr_test1vz5xk2kh8d3u6s2ge7cwwv4m4xzvr4n6vlpycrmhenrdcwcx4kjqn	\\x60a86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	f	\\xa86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	\N	3681818081650832	\N	\N	\N
110	99	0	addr_test1vz5xk2kh8d3u6s2ge7cwwv4m4xzvr4n6vlpycrmhenrdcwcx4kjqn	\\x60a86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	f	\\xa86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	\N	99828910	\N	\N	\N
111	100	0	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	\\x702618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	100000000	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	2	\N
112	100	1	addr_test1vz5xk2kh8d3u6s2ge7cwwv4m4xzvr4n6vlpycrmhenrdcwcx4kjqn	\\x60a86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	f	\\xa86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	\N	3681817981484759	\N	\N	\N
113	101	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	2
114	101	1	addr_test1vz5xk2kh8d3u6s2ge7cwwv4m4xzvr4n6vlpycrmhenrdcwcx4kjqn	\\x60a86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	f	\\xa86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	\N	3681817881314374	\N	\N	\N
115	102	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	3
116	102	1	addr_test1vz5xk2kh8d3u6s2ge7cwwv4m4xzvr4n6vlpycrmhenrdcwcx4kjqn	\\x60a86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	f	\\xa86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	\N	3681817781146585	\N	\N	\N
117	103	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	1
118	103	1	addr_test1vz5xk2kh8d3u6s2ge7cwwv4m4xzvr4n6vlpycrmhenrdcwcx4kjqn	\\x60a86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	f	\\xa86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	\N	3681817680979940	\N	\N	\N
119	104	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	4
120	104	1	addr_test1vz5xk2kh8d3u6s2ge7cwwv4m4xzvr4n6vlpycrmhenrdcwcx4kjqn	\\x60a86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	f	\\xa86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	\N	3681817580717067	\N	\N	\N
121	105	0	addr_test1wzem0yuxjqyrmzvrsr8xfqhumyy555ngyjxw7wrg2pav90q8cagu2	\\x70b3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	t	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	\N	100000000	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	3	\N
122	105	1	addr_test1vz5xk2kh8d3u6s2ge7cwwv4m4xzvr4n6vlpycrmhenrdcwcx4kjqn	\\x60a86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	f	\\xa86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	\N	3681817480550950	\N	\N	\N
123	106	0	addr_test1vz5xk2kh8d3u6s2ge7cwwv4m4xzvr4n6vlpycrmhenrdcwcx4kjqn	\\x60a86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	f	\\xa86b2ad73b63cd4148cfb0e732bba984c1d67a67c24c0f77ccc6dc3b	\N	3681817580223603	\N	\N	\N
124	107	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\N	\N	\N
125	107	1	addr_test1vq9weqvprk4cyl5v40sx9jljjyg4hhxzr3nqxrctx9jgjncqp5q9p	\\x600aec81811dab827e8cabe062cbf291115bdcc21c66030f0b3164894f	f	\\x0aec81811dab827e8cabe062cbf291115bdcc21c66030f0b3164894f	\N	3681818171642252	\N	\N	\N
126	108	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000000000	\N	\N	\N
127	108	1	addr_test1qrml5hwl9s7ydm2djyup95ud6s74skkl4zzf8zk657s8thgm78sn3uhch64ujc7ffnpga68dfdqhg3sp7tk6759jrm7spy03k9	\\x00f7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd1bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	f	\\xf7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd	47	5000000000000	\N	\N	\N
128	108	2	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	5000000000000	\N	\N	\N
129	108	3	addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k	\\x00594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	f	\\x594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0	49	5000000000000	\N	\N	\N
130	108	4	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	5000000000000	\N	\N	\N
131	108	5	addr_test1vq08tc8ufvpfz2qyc7cwnanr0ql89pyn2nnrcujg6wf6t5cr3qcr9	\\x601e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	f	\\x1e75e0fc4b02912804c7b0e9f663783e72849354e63c7248d393a5d3	\N	3656813275134639	\N	\N	\N
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
147	117	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999918442748	\N	\N	\N
148	118	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	19825259	\N	\N	\N
149	119	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
150	119	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999908249923	\N	\N	\N
151	120	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9826843	\N	\N	\N
152	121	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
153	121	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9632610	\N	\N	\N
154	122	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9824995	\N	\N	\N
155	123	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9651838	\N	\N	\N
156	124	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
157	124	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9273272	\N	\N	\N
158	125	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
159	125	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9452545	\N	\N	\N
162	127	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
163	127	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999898062730	\N	\N	\N
164	128	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
165	128	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999887876065	\N	\N	\N
166	129	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
167	129	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9811795	\N	\N	\N
168	130	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39083703	\N	\N	\N
169	131	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	1000000000	\N	\N	\N
170	131	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998926789779	\N	\N	\N
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
215	134	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	499375158	\N	\N	\N
216	135	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
217	135	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	6089599	\N	\N	\N
218	136	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2820947	\N	\N	\N
219	137	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
220	137	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2912218	\N	\N	\N
222	139	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2827019	\N	\N	\N
223	140	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999361209977	\N	\N	\N
224	140	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999573966653	\N	\N	\N
225	141	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999361209977	\N	\N	\N
226	141	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999573796488	\N	\N	\N
227	142	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
228	142	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999568628083	\N	\N	\N
229	143	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998930338060	\N	\N	\N
230	143	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4328427	\N	\N	\N
231	144	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
232	144	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998929496498	\N	\N	\N
233	146	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	1000000	\N	\N	\N
234	146	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998928314145	\N	\N	\N
235	147	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998928142572	\N	\N	\N
236	148	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	969750	\N	\N	\N
237	148	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998927002569	\N	\N	\N
238	149	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
239	149	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998917802330	\N	\N	\N
240	150	0	addr_test1qpj0l9hm9v5s3qt7kmt96yme555sgn5v3dr40xs86mns3ypu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqztmmwc	\\x0064ff96fb2b2908817eb6d65d1379a529044e8c8b47579a07d6e708903c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x64ff96fb2b2908817eb6d65d1379a529044e8c8b47579a07d6e70890	62	3000000	\N	\N	\N
241	150	1	addr_test1qr08qsrs6u3j4r4dtnuhv4a3hvt6lrxdrj5knlqweeume0fu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqgy33fc	\\x00de704070d7232a8ead5cf97657b1bb17af8ccd1ca969fc0ece79bcbd3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xde704070d7232a8ead5cf97657b1bb17af8ccd1ca969fc0ece79bcbd	62	3000000	\N	\N	\N
242	150	2	addr_test1qpmze8rahakqq9k593hq5u2ccgv7qjvfqnt35gsuke7pgyeu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqepfcjg	\\x00762c9c7dbf6c0016d42c6e0a7158c219e0498904d71a221cb67c14133c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x762c9c7dbf6c0016d42c6e0a7158c219e0498904d71a221cb67c1413	62	3000000	\N	\N	\N
243	150	3	addr_test1qzdlw98cku3fsnlj239v7v8ukp2q55yj77gcn207lhgqnvpu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqpn4nas	\\x009bf714f8b722984ff2544acf30fcb0540a5092f79189a9fefdd009b03c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x9bf714f8b722984ff2544acf30fcb0540a5092f79189a9fefdd009b0	62	3000000	\N	\N	\N
244	150	4	addr_test1qp8hqpx5qjsn6a84hpruh93w6upl6jrdueqznts4rucv56fu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqw4jwm8	\\x004f7004d404a13d74f5b847cb962ed703fd486de64029ae151f30ca693c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x4f7004d404a13d74f5b847cb962ed703fd486de64029ae151f30ca69	62	3000000	\N	\N	\N
245	150	5	addr_test1qrzwh4fkm0qcwf78vfdcmz9z4y45szmc3vwmcytnae98hj3u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq7y2gfn	\\x00c4ebd536dbc18727c7625b8d88a2a92b480b788b1dbc1173ee4a7bca3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xc4ebd536dbc18727c7625b8d88a2a92b480b788b1dbc1173ee4a7bca	62	3000000	\N	\N	\N
246	150	6	addr_test1qzvz7ch68znfsv4sags3gp76lw7jy298uu0njmjw8az4pq3u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq409ucs	\\x00982f62fa38a69832b0ea211407dafbbd2228a7e71f396e4e3f4550823c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x982f62fa38a69832b0ea211407dafbbd2228a7e71f396e4e3f455082	62	3000000	\N	\N	\N
247	150	7	addr_test1qqse43h98ttp07v4x7zdwzd8jpyfl058zly7n52csx67ereu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq5vn0fd	\\x00219ac6e53ad617f9953784d709a790489fbe8717c9e9d15881b5ec8f3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x219ac6e53ad617f9953784d709a790489fbe8717c9e9d15881b5ec8f	62	3000000	\N	\N	\N
248	150	8	addr_test1qz52hac3n8p4g3cuqug3axrxl7edcg46fx8qlxgw8xnpuleu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqx3t2kt	\\x00a8abf71199c354471c07111e9866ffb2dc22ba498e0f990e39a61e7f3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xa8abf71199c354471c07111e9866ffb2dc22ba498e0f990e39a61e7f	62	3000000	\N	\N	\N
249	150	9	addr_test1qzg7q3wtg2k4lz8yvl6n9ujwspw2jke7swplyq86yua3tueu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqrc0www	\\x0091e045cb42ad5f88e467f532f24e805ca95b3e8383f200fa273b15f33c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x91e045cb42ad5f88e467f532f24e805ca95b3e8383f200fa273b15f3	62	3000000	\N	\N	\N
250	150	10	addr_test1qzv64n6ffqhmnrle9vq3dscell63zepee92drkl64zxgetpu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqcq84l8	\\x0099aacf49482fb98ff92b0116c319fff5116439c954d1dbfaa88c8cac3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x99aacf49482fb98ff92b0116c319fff5116439c954d1dbfaa88c8cac	62	3000000	\N	\N	\N
251	150	11	addr_test1qpgk8l4ceqf5hsscznqpmswfqguezf2ynw0q5z88hymvup3u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq4exa2l	\\x005163feb8c8134bc21814c01dc1c902399125449b9e0a08e7b936ce063c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x5163feb8c8134bc21814c01dc1c902399125449b9e0a08e7b936ce06	62	3000000	\N	\N	\N
252	150	12	addr_test1qz4lut2s7z5lkzt27fk3xuuzugunmke37xcgdvff3t3u8vpu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqw9kssn	\\x00abfe2d50f0a9fb096af26d137382e2393ddb31f1b086b1298ae3c3b03c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xabfe2d50f0a9fb096af26d137382e2393ddb31f1b086b1298ae3c3b0	62	3000000	\N	\N	\N
253	150	13	addr_test1qq75r77v9xfk82ghnpvj33w4s66sej989xjm42a75qzjhypu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq84hfuk	\\x003d41fbcc299363a917985928c5d586b50cc8a729a5baabbea0052b903c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x3d41fbcc299363a917985928c5d586b50cc8a729a5baabbea0052b90	62	3000000	\N	\N	\N
254	150	14	addr_test1qz2jryd282ry2l5htm7pw3qu720v52w8whn8sra07r6csgeu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqdzd87r	\\x00952191aa3a86457e975efc17441cf29eca29c775e6780faff0f588233c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x952191aa3a86457e975efc17441cf29eca29c775e6780faff0f58823	62	3000000	\N	\N	\N
255	150	15	addr_test1qpf878r5z4g76rzaavhavfvwh488gkaxvvg2c770n7hdnxfu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqgfxasd	\\x00527f1c741551ed0c5deb2fd6258ebd4e745ba66310ac7bcf9faed9993c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x527f1c741551ed0c5deb2fd6258ebd4e745ba66310ac7bcf9faed999	62	3000000	\N	\N	\N
256	150	16	addr_test1qqeau2g5j5hj82l355crjk30gm2w3x0jcaqmd6v83wljv63u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqjtn69d	\\x0033de2914952f23abf1a530395a2f46d4e899f2c741b6e9878bbf266a3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x33de2914952f23abf1a530395a2f46d4e899f2c741b6e9878bbf266a	62	3000000	\N	\N	\N
257	150	17	addr_test1qre98sw87zfxjsua5sg2sepgtxwcfmxhsckamlq7l8d8hefu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqxlwf6a	\\x00f253c1c7f09269439da410a86428599d84ecd7862dddfc1ef9da7be53c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xf253c1c7f09269439da410a86428599d84ecd7862dddfc1ef9da7be5	62	3000000	\N	\N	\N
258	150	18	addr_test1qpjx4jkxdy9sa87rt2tza5cpskv3gvxzpha54f6e9yzwpaeu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq4aqs8j	\\x00646acac6690b0e9fc35a962ed30185991430c20dfb4aa7592904e0f73c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x646acac6690b0e9fc35a962ed30185991430c20dfb4aa7592904e0f7	62	3000000	\N	\N	\N
259	150	19	addr_test1qznfrfh4jzlnxup4pu3l3uklvml3xe6zrf5mgx65kf26ygpu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq3rl4rr	\\x00a691a6f590bf3370350f23f8f2df66ff1367421a69b41b54b255a2203c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xa691a6f590bf3370350f23f8f2df66ff1367421a69b41b54b255a220	62	3000000	\N	\N	\N
260	150	20	addr_test1qrah0e7gvfgz3cyxq8jz4ksz7mm6gw0y5n92v3752puc7cfu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqznn4hk	\\x00fb77e7c8625028e08601e42ada02f6f7a439e4a4caa647d450798f613c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xfb77e7c8625028e08601e42ada02f6f7a439e4a4caa647d450798f61	62	3000000	\N	\N	\N
261	150	21	addr_test1qqa385ydh4kxrgr3d6g8tqf47surpul6wx2mw24yq7uaj9eu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqf2adus	\\x003b13d08dbd6c61a0716e90758135f43830f3fa7195b72aa407b9d9173c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x3b13d08dbd6c61a0716e90758135f43830f3fa7195b72aa407b9d917	62	3000000	\N	\N	\N
262	150	22	addr_test1qrgk3f57ssqmu9znwgta40hlmxx0cnh97rcvayrv3a373dfu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqzevyva	\\x00d168a69e8401be14537217dabeffd98cfc4ee5f0f0ce906c8f63e8b53c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xd168a69e8401be14537217dabeffd98cfc4ee5f0f0ce906c8f63e8b5	62	3000000	\N	\N	\N
263	150	23	addr_test1qrd7cyah5umvlwfp4e6hp9azfya3l6qnsxsqaxzrvqpjgr3u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq2wjlqa	\\x00dbec13b7a736cfb921ae757097a2493b1fe81381a00e98436003240e3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xdbec13b7a736cfb921ae757097a2493b1fe81381a00e98436003240e	62	3000000	\N	\N	\N
264	150	24	addr_test1qpqfj5sy0p2rnmdgtt42z4u9kg3jnf7wl2y0fjss4c9yu7eu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqmj990r	\\x0040995204785439eda85aeaa15785b22329a7cefa88f4ca10ae0a4e7b3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x40995204785439eda85aeaa15785b22329a7cefa88f4ca10ae0a4e7b	62	3000000	\N	\N	\N
265	150	25	addr_test1qpu3dpczcshjgx9e6c4n9pcpn3gta65yc0uh0g8576t797fu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqalltwr	\\x0079168702c42f2418b9d62b3287019c50beea84c3f977a0f4f697e2f93c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x79168702c42f2418b9d62b3287019c50beea84c3f977a0f4f697e2f9	62	3000000	\N	\N	\N
266	150	26	addr_test1qr8x9e79tv8xn2mkgaw04547ht3uj22cnfxvtgp6pl5z4v3u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq2puzkz	\\x00ce62e7c55b0e69ab76475cfad2bebae3c929589a4cc5a03a0fe82ab23c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xce62e7c55b0e69ab76475cfad2bebae3c929589a4cc5a03a0fe82ab2	62	3000000	\N	\N	\N
267	150	27	addr_test1qzyx42ayp0ce8jquyyyzumhx8w2ngx25guhxz4256enqyzpu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq5080we	\\x00886aaba40bf193c81c21082e6ee63b95341954472e615554d66602083c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x886aaba40bf193c81c21082e6ee63b95341954472e615554d6660208	62	3000000	\N	\N	\N
268	150	28	addr_test1qz453pwu6vfeaz7pl8pxgujpcpmmh4gchtsvcgg4n8h9qd3u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqyjd8q2	\\x00ab4885dcd3139e8bc1f9c2647241c077bbd518bae0cc211599ee50363c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xab4885dcd3139e8bc1f9c2647241c077bbd518bae0cc211599ee5036	62	3000000	\N	\N	\N
269	150	29	addr_test1qquaqq3uz02z3st4zv2yxu9rdpu8c9d4egaq4udutpjfatpu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqghy9tn	\\x0039d0023c13d428c17513144370a368787c15b5ca3a0af1bc58649eac3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x39d0023c13d428c17513144370a368787c15b5ca3a0af1bc58649eac	62	3000000	\N	\N	\N
270	150	30	addr_test1qpe20tkc9kg3np87yr68x68hydw0rhvct7qy072vkau3q63u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqtepsjd	\\x0072a7aed82d911984fe20f47368f7235cf1dd985f8047f94cb779106a3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x72a7aed82d911984fe20f47368f7235cf1dd985f8047f94cb779106a	62	3000000	\N	\N	\N
271	150	31	addr_test1qqsutty6e5gk3c6dpu0lk6e0hl9f99zs9pmdrmrr5fjgj43u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq9pa0lq	\\x0021c5ac9acd1168e34d0f1ffb6b2fbfca9294502876d1ec63a26489563c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x21c5ac9acd1168e34d0f1ffb6b2fbfca9294502876d1ec63a2648956	62	3000000	\N	\N	\N
272	150	32	addr_test1qr2z50p546j7dumupyxh4pdlrennvkh65qjj3hkkuvpzk33u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq64pfz7	\\x00d42a3c34aea5e6f37c090d7a85bf1e67365afaa02528ded6e3022b463c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xd42a3c34aea5e6f37c090d7a85bf1e67365afaa02528ded6e3022b46	62	3000000	\N	\N	\N
273	150	33	addr_test1qrqsn4jt30hnhm3m5jkvtm7888t6pzzk5uwwa9scs0a60g3u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq53wcwu	\\x00c109d64b8bef3bee3ba4acc5efc739d7a08856a71cee961883fba7a23c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xc109d64b8bef3bee3ba4acc5efc739d7a08856a71cee961883fba7a2	62	3000000	\N	\N	\N
274	150	34	addr_test1qqvnnae6stg5we2h3fcy2nn5zn3kd7x2n88ua6d0xkrkrmeu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqwvj980	\\x001939f73a82d14765578a70454e7414e366f8ca99cfcee9af358761ef3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x1939f73a82d14765578a70454e7414e366f8ca99cfcee9af358761ef	62	3000000	\N	\N	\N
275	150	35	addr_test1qq6ywrh7h27xkdn9ly6vhwxtws8dngefw3cmtmv2h3gkrzeu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqlc3sj3	\\x0034470efebabc6b3665f934cbb8cb740ed9a3297471b5ed8abc51618b3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x34470efebabc6b3665f934cbb8cb740ed9a3297471b5ed8abc51618b	62	3000000	\N	\N	\N
276	150	36	addr_test1qrl7y2khg3nsz0jl7yfz2zk33dtvsyl656gqq8wj72pvnsfu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqja49rx	\\x00ffe22ad74467013e5ff112250ad18b56c813faa690001dd2f282c9c13c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xffe22ad74467013e5ff112250ad18b56c813faa690001dd2f282c9c1	62	3000000	\N	\N	\N
277	150	37	addr_test1qq2tuju0hc86ydw0xjhkt9stm4pe25kshusdwwe5m03rm93u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqc96x5h	\\x0014be4b8fbe0fa235cf34af65960bdd439552d0bf20d73b34dbe23d963c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x14be4b8fbe0fa235cf34af65960bdd439552d0bf20d73b34dbe23d96	62	3000000	\N	\N	\N
278	150	38	addr_test1qpgfz8a94tf947rf77yr2snpj267gy9xumy6vnwad5mkwtfu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqcza4t2	\\x0050911fa5aad25af869f78835426192b5e410a6e6c9a64ddd6d37672d3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x50911fa5aad25af869f78835426192b5e410a6e6c9a64ddd6d37672d	62	3000000	\N	\N	\N
279	150	39	addr_test1qpd5z7396ngx9mmcrxsmjpvs5kzfll97ga0hnp9y44wg8kpu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqqj7hfu	\\x005b417a25d4d062ef7819a1b90590a5849ffcbe475f7984a4ad5c83d83c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x5b417a25d4d062ef7819a1b90590a5849ffcbe475f7984a4ad5c83d8	62	3000000	\N	\N	\N
280	150	40	addr_test1qrwj5cj6vg7kdsqgfzuc6kgxf0wgujaf85c0wdn5w5hflcfu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq53mlmz	\\x00dd2a625a623d66c00848b98d59064bdc8e4ba93d30f73674752e9fe13c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xdd2a625a623d66c00848b98d59064bdc8e4ba93d30f73674752e9fe1	62	3000000	\N	\N	\N
281	150	41	addr_test1qp4g03vgqur4rvru5s70vha5sznmtk5cnnn4k3p5ast7gh3u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq5enjqx	\\x006a87c588070751b07ca43cf65fb480a7b5da989ce75b4434ec17e45e3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x6a87c588070751b07ca43cf65fb480a7b5da989ce75b4434ec17e45e	62	3000000	\N	\N	\N
282	150	42	addr_test1qz0kjuln5rt08hus4yjqv02uzwau3jcd376z5wkczrlfnceu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqcf9zen	\\x009f6973f3a0d6f3df90a924063d5c13bbc8cb0d8fb42a3ad810fe99e33c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x9f6973f3a0d6f3df90a924063d5c13bbc8cb0d8fb42a3ad810fe99e3	62	3000000	\N	\N	\N
283	150	43	addr_test1qryjq9qprjtgmy2v90zlatnwmrffcyygrq6986leklejlufu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq7spqwp	\\x00c92014011c968d914c2bc5feae6ed8d29c1088183453ebf9b7f32ff13c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xc92014011c968d914c2bc5feae6ed8d29c1088183453ebf9b7f32ff1	62	3000000	\N	\N	\N
284	150	44	addr_test1qz6deme902f4e2ahau0p3xm6sp0zqvd995lnh86clt6r7afu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqa88vmf	\\x00b4dcef257a935cabb7ef1e189b7a805e2031a52d3f3b9f58faf43f753c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xb4dcef257a935cabb7ef1e189b7a805e2031a52d3f3b9f58faf43f75	62	3000000	\N	\N	\N
285	150	45	addr_test1qq9wps2y9js7ejmzlv4draclknaydajuzmzw0r7kjx6y5xpu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqfk6gwk	\\x000ae0c1442ca1eccb62fb2ad1f71fb4fa46f65c16c4e78fd691b44a183c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x0ae0c1442ca1eccb62fb2ad1f71fb4fa46f65c16c4e78fd691b44a18	62	3000000	\N	\N	\N
286	150	46	addr_test1qphmdprm635zam2j7wknl287wwjyqaxwjtm0agh0suh4u0eu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqn7060v	\\x006fb6847bd4682eed52f3ad3fa8fe73a44074ce92f6fea2ef872f5e3f3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x6fb6847bd4682eed52f3ad3fa8fe73a44074ce92f6fea2ef872f5e3f	62	3000000	\N	\N	\N
287	150	47	addr_test1qre2lcumy4fvpd3593jthrc6mllh6jmnrx59ar6y6vcd8reu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqwwxs3l	\\x00f2afe39b2552c0b6342c64bb8f1adfff7d4b7319a85e8f44d330d38f3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xf2afe39b2552c0b6342c64bb8f1adfff7d4b7319a85e8f44d330d38f	62	3000000	\N	\N	\N
288	150	48	addr_test1qpmttezgj4x0m9ra608fuvltzyyjgkac07a2mjcs45a40zeu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqaz9ru7	\\x0076b5e448954cfd947dd3ce9e33eb1109245bb87fbaadcb10ad3b578b3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x76b5e448954cfd947dd3ce9e33eb1109245bb87fbaadcb10ad3b578b	62	3000000	\N	\N	\N
289	150	49	addr_test1qpeearzphy6asypnfvyxyze90kl45uz66tu257570sgcmqpu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqjrgt59	\\x00739e8c41b935d810334b08620b257dbf5a705ad2f8aa7a9e7c118d803c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x739e8c41b935d810334b08620b257dbf5a705ad2f8aa7a9e7c118d80	62	3000000	\N	\N	\N
290	150	50	addr_test1qp0k27whm3vjkgft22tzvh6qk5hmpvdpkukr7c5xg5zuzpfu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq2m7v0t	\\x005f6579d7dc592b212b5296265f40b52fb0b1a1b72c3f62864505c1053c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x5f6579d7dc592b212b5296265f40b52fb0b1a1b72c3f62864505c105	62	3000000	\N	\N	\N
291	150	51	addr_test1qrnd2skszz7j904d5eh66dcxv7ngxcez7hl2n60ke008pvpu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqu0xdpa	\\x00e6d542d010bd22beada66fad370667a6836322f5fea9e9f6cbde70b03c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xe6d542d010bd22beada66fad370667a6836322f5fea9e9f6cbde70b0	62	3000000	\N	\N	\N
292	150	52	addr_test1qqc7n7awjaq6qpd24wkhyw8hvvfzwxqwc5h6794zm73dd83u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqkel4zj	\\x0031e9fbae9741a005aaabad7238f7631227180ec52faf16a2dfa2d69e3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x31e9fbae9741a005aaabad7238f7631227180ec52faf16a2dfa2d69e	62	3000000	\N	\N	\N
293	150	53	addr_test1qz603kuzraf7ufl97893acs56502fh8uced9xwmvrq45g83u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqptgmpu	\\x00b4f8db821f53ee27e5f1cb1ee214d51ea4dcfcc65a533b6c182b441e3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xb4f8db821f53ee27e5f1cb1ee214d51ea4dcfcc65a533b6c182b441e	62	3000000	\N	\N	\N
294	150	54	addr_test1qq9h2uldzhmfsfffmp3n69yxclnc0cm8t0ekevk5z4gpnupu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqe2crkl	\\x000b7573ed15f6982529d8633d1486c7e787e3675bf36cb2d4155019f03c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x0b7573ed15f6982529d8633d1486c7e787e3675bf36cb2d4155019f0	62	3000000	\N	\N	\N
295	150	55	addr_test1qqtjhznvvqjmxxgj05p67yqtnzudsanaejvpcz9yzh0dfjpu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqu79wug	\\x00172b8a6c6025b319127d03af100b98b8d8767dcc981c08a415ded4c83c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x172b8a6c6025b319127d03af100b98b8d8767dcc981c08a415ded4c8	62	3000000	\N	\N	\N
296	150	56	addr_test1qqjcvgvrutgtdlfl33qym2y5pupdqj5t0cwyu4ttz4w9lyfu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjql77p6l	\\x0025862183e2d0b6fd3f8c404da8940f02d04a8b7e1c4e556b155c5f913c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x25862183e2d0b6fd3f8c404da8940f02d04a8b7e1c4e556b155c5f91	62	3000000	\N	\N	\N
297	150	57	addr_test1qq2l0vsjh3pcypwzxc7aasrzegpkynnaed5xxevx5e6zf23u0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjq3m3hlj	\\x0015f7b212bc438205c2363ddec062ca03624e7dcb68636586a67424aa3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x15f7b212bc438205c2363ddec062ca03624e7dcb68636586a67424aa	62	3000000	\N	\N	\N
298	150	58	addr_test1qzue89wt4mh98v8pwh0e8fehdjkvg9dqrutks5nt3hyjr5fu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqejywtw	\\x00b99395cbaeee53b0e175df93a7376cacc415a01f1768526b8dc921d13c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\xb99395cbaeee53b0e175df93a7376cacc415a01f1768526b8dc921d1	62	3000000	\N	\N	\N
299	150	59	addr_test1qzr8nr3n9jsd380fp8jkdmvq3tu0e6rumyp59x8z627jzkeu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqtnp2u3	\\x0086798e332ca0d89de909e566ed808af8fce87cd9034298e2d2bd215b3c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x86798e332ca0d89de909e566ed808af8fce87cd9034298e2d2bd215b	62	3000000	\N	\N	\N
300	150	60	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	97371393279	\N	\N	\N
301	150	61	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
302	150	62	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
303	150	63	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
304	150	64	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
305	150	65	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
306	150	66	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
307	150	67	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
308	150	68	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
309	150	69	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
310	150	70	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
311	150	71	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
312	150	72	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
313	150	73	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
314	150	74	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
315	150	75	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
316	150	76	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
317	150	77	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
318	150	78	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
319	150	79	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
320	150	80	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
321	150	81	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
322	150	82	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
323	150	83	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
324	150	84	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
325	150	85	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
326	150	86	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
327	150	87	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
328	150	88	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
329	150	89	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
330	150	90	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
331	150	91	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
332	150	92	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
333	150	93	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
334	150	94	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
335	150	95	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
336	150	96	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
337	150	97	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
338	150	98	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
339	150	99	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
340	150	100	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
341	150	101	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
342	150	102	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
343	150	103	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
344	150	104	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
345	150	105	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
346	150	106	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
347	150	107	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
348	150	108	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
349	150	109	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
350	150	110	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
351	150	111	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
352	150	112	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
353	150	113	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
354	150	114	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
355	150	115	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
356	150	116	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
357	150	117	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
358	150	118	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
359	150	119	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073998182	\N	\N	\N
360	151	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	178500000	\N	\N	\N
361	151	1	addr_test1qpj0l9hm9v5s3qt7kmt96yme555sgn5v3dr40xs86mns3ypu0uek79xvr2lc3m3rwdzrqpl4z8kvyuaej6wgcv4mcqjqztmmwc	\\x0064ff96fb2b2908817eb6d65d1379a529044e8c8b47579a07d6e708903c7f336f14cc1abf88ee2373443007f511ecc273b9969c8c32bbc024	f	\\x64ff96fb2b2908817eb6d65d1379a529044e8c8b47579a07d6e70890	62	974447	\N	\N	\N
362	152	0	5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg	\\x82d818582683581c599d72b5e3f5a40fb4c4eb809e904d101f908a419472f542bc7032b9a10243190378001a2a94baa3	f	\N	\N	3000000	\N	\N	\N
363	152	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83070830129	\N	\N	\N
365	154	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9819803	\N	\N	\N
366	155	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
367	155	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
368	156	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
369	156	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
370	157	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
371	157	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
372	158	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
373	158	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
374	159	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
375	159	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
376	160	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
377	160	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
378	161	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
379	161	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
380	162	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
381	162	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
382	163	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
383	163	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
384	164	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
385	164	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
386	165	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
387	165	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
388	166	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
389	166	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
390	167	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
391	167	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
392	168	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
393	168	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
394	169	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
395	169	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
396	170	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
397	170	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
398	171	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
399	171	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073828149	\N	\N	\N
400	172	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
401	172	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
402	173	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
403	173	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
404	174	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
405	174	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83065661724	\N	\N	\N
406	175	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
407	175	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
408	176	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
409	176	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
410	177	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
411	177	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
412	178	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
413	178	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073828149	\N	\N	\N
414	179	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
415	179	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83058492923	\N	\N	\N
416	180	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
417	180	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
418	181	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
419	181	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
420	182	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
421	182	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073828149	\N	\N	\N
422	183	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
423	183	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
424	184	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
425	184	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
426	185	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
427	185	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
428	186	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
429	186	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
430	187	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
431	187	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
432	188	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
433	188	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83060493319	\N	\N	\N
434	189	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
435	189	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
436	190	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
437	190	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
438	191	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
439	191	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073828149	\N	\N	\N
440	192	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
441	192	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
442	193	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
443	193	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
444	194	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
445	194	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073828149	\N	\N	\N
446	195	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
447	195	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
448	196	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
449	196	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
450	197	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
451	197	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
452	198	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
453	198	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83058492923	\N	\N	\N
454	199	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
455	199	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
456	200	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
457	200	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
458	201	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
459	201	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
460	202	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
461	202	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
462	203	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
463	203	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
464	204	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
465	204	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83058153121	\N	\N	\N
466	205	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
467	205	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
468	206	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
469	206	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
470	207	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
471	207	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
472	208	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
473	208	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
474	209	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
475	209	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
476	210	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
477	210	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
478	211	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
479	211	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068659744	\N	\N	\N
480	212	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
481	212	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
482	213	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
483	213	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83055324914	\N	\N	\N
484	214	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
485	214	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
486	215	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
487	215	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
488	216	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
489	216	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83058492923	\N	\N	\N
490	217	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
491	217	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073828149	\N	\N	\N
492	218	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
493	218	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
494	219	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
495	219	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83058492923	\N	\N	\N
496	220	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
497	220	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
498	221	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
499	221	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
500	222	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
501	222	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
502	223	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
503	223	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83058492923	\N	\N	\N
504	224	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
505	224	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
506	225	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
507	225	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
508	226	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
509	226	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
510	227	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
511	227	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
512	228	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
513	228	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
514	229	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
515	229	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4651574	\N	\N	\N
516	230	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
517	230	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
518	231	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
519	231	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
520	232	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
521	232	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
522	233	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
523	233	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068659744	\N	\N	\N
524	234	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
525	234	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
526	235	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
527	235	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83053324518	\N	\N	\N
528	236	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
529	236	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068659744	\N	\N	\N
530	237	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
531	237	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
532	238	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
533	238	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
534	239	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
535	239	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
536	240	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
537	240	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
538	241	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
539	241	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068829733	\N	\N	\N
540	242	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
541	242	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068659744	\N	\N	\N
542	243	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
543	243	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
544	244	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
545	244	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
546	245	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
547	245	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83058492923	\N	\N	\N
548	246	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
549	246	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
550	247	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
551	247	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
552	248	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
553	248	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
554	249	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
555	249	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
556	250	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
557	250	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83058492923	\N	\N	\N
558	251	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
559	251	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
560	252	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
561	252	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063661328	\N	\N	\N
562	253	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
563	253	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
564	254	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
565	254	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83058492923	\N	\N	\N
566	255	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
567	255	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	105978715567	\N	\N	\N
568	256	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1251879037155	\N	\N	\N
569	256	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	1251879468108	\N	\N	\N
570	256	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625939734054	\N	\N	\N
571	256	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	625939734054	\N	\N	\N
572	256	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312969867027	\N	\N	\N
573	256	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	312969867027	\N	\N	\N
574	256	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156484933514	\N	\N	\N
575	256	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	156484933513	\N	\N	\N
576	256	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78242466757	\N	\N	\N
577	256	9	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	78242466757	\N	\N	\N
578	256	10	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39121233378	\N	\N	\N
579	256	11	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39121233378	\N	\N	\N
580	256	12	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39121233378	\N	\N	\N
581	256	13	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39121233378	\N	\N	\N
582	257	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
583	257	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1266920232631	\N	\N	\N
584	258	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
585	258	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1266920062642	\N	\N	\N
586	259	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
587	259	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	78242296768	\N	\N	\N
588	260	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
589	260	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39116064973	\N	\N	\N
590	261	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
591	261	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78237298352	\N	\N	\N
592	262	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
593	262	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	312964698622	\N	\N	\N
594	263	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
595	263	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312964698622	\N	\N	\N
596	264	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
597	264	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	1251874299703	\N	\N	\N
598	265	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
599	265	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	625934565649	\N	\N	\N
600	266	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
601	266	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312959530217	\N	\N	\N
602	267	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
603	267	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39116064973	\N	\N	\N
604	268	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
605	268	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39110896568	\N	\N	\N
606	269	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
607	269	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	1251869131298	\N	\N	\N
608	270	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
609	270	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	156479765108	\N	\N	\N
610	271	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
611	271	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312954361812	\N	\N	\N
612	272	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
613	272	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
614	273	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
615	273	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
616	274	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
617	274	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39116064973	\N	\N	\N
618	275	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
619	275	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312949193407	\N	\N	\N
620	276	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
621	276	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
622	277	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
623	277	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
624	278	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
625	278	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78232129947	\N	\N	\N
626	279	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
627	279	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
628	280	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
629	280	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
630	281	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
631	281	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1266919722840	\N	\N	\N
632	282	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
633	282	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	156479595119	\N	\N	\N
634	283	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
635	283	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312944025002	\N	\N	\N
636	284	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
637	284	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39110896568	\N	\N	\N
638	285	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
639	285	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39116064973	\N	\N	\N
640	286	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
641	286	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39115725171	\N	\N	\N
642	287	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
643	287	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	156474426714	\N	\N	\N
644	288	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
645	288	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156479765109	\N	\N	\N
646	289	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
647	289	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
648	290	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
649	290	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	625929397244	\N	\N	\N
650	291	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
651	291	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	312959530217	\N	\N	\N
652	292	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
653	292	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625934565649	\N	\N	\N
654	293	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
655	293	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
656	294	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
657	294	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
658	295	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
659	295	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	78237128363	\N	\N	\N
660	296	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
661	296	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4490561	\N	\N	\N
662	297	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
663	297	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
664	298	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
665	298	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
666	299	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
667	299	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
668	300	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
669	300	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
670	301	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
671	301	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
672	302	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
673	302	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39105728163	\N	\N	\N
674	303	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
675	303	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39105728163	\N	\N	\N
676	304	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
677	304	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4490561	\N	\N	\N
678	305	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
679	305	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
680	306	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
681	306	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4490561	\N	\N	\N
682	307	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
683	307	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
684	308	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
685	308	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	1251863962893	\N	\N	\N
686	309	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
687	309	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	1251858794488	\N	\N	\N
688	310	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
689	310	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
690	311	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
691	311	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4490561	\N	\N	\N
692	312	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
693	312	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39110556766	\N	\N	\N
694	313	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
695	313	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156474596704	\N	\N	\N
696	314	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
697	314	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
698	315	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
699	315	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156474256902	\N	\N	\N
700	316	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
701	316	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
702	317	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
703	317	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1266914554435	\N	\N	\N
704	318	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
705	318	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312938856597	\N	\N	\N
706	319	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
707	319	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	156474086912	\N	\N	\N
708	320	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
709	320	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4320748	\N	\N	\N
710	321	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
711	321	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
712	322	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
713	322	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312938516795	\N	\N	\N
714	323	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
715	323	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	78231959958	\N	\N	\N
716	324	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
717	324	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
718	325	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
719	325	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
720	326	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
721	326	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1266909386030	\N	\N	\N
722	327	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
723	327	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78231790145	\N	\N	\N
724	328	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
725	328	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78226621740	\N	\N	\N
726	329	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
727	329	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
728	330	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
729	330	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	1251853626083	\N	\N	\N
730	331	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
731	331	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39100559758	\N	\N	\N
732	332	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
733	332	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625929397244	\N	\N	\N
734	333	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
735	333	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	312954361812	\N	\N	\N
736	334	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
737	334	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
738	335	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
739	335	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39095391353	\N	\N	\N
740	336	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
741	336	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	156468918507	\N	\N	\N
742	337	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
743	337	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
744	338	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
745	338	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4490561	\N	\N	\N
746	339	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
747	339	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4320748	\N	\N	\N
748	340	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
749	340	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
750	341	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
751	341	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
752	342	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
753	342	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4320748	\N	\N	\N
754	343	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
755	343	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
756	344	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
757	344	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
758	345	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
759	345	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4660374	\N	\N	\N
760	346	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
761	346	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	3981122	\N	\N	\N
762	347	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
763	347	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	39105388361	\N	\N	\N
764	348	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
765	348	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
766	349	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
767	349	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
768	350	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
769	350	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
770	351	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
771	351	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
772	352	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
773	352	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312933348390	\N	\N	\N
774	353	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
775	353	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	78231620156	\N	\N	\N
776	354	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
777	354	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	312949193407	\N	\N	\N
778	355	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
779	355	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4830187	\N	\N	\N
780	356	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
781	356	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	4320748	\N	\N	\N
782	357	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
783	357	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	55116347316	\N	\N	\N
784	358	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	5	\N
785	358	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	65	156463682078	\N	\N	\N
786	359	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
787	359	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999996820111	\N	\N	\N
788	360	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
789	360	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999996648538	\N	\N	\N
790	361	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
791	361	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999996471201	\N	\N	\N
792	362	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
793	362	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	4999996820287	\N	\N	\N
794	363	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
795	363	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	4999993650298	\N	\N	\N
796	364	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
797	364	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	6821255	\N	\N	\N
\.


--
-- Data for Name: withdrawal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.withdrawal (id, addr_id, amount, redeemer_id, tx_id) FROM stdin;
1	46	8612497029	\N	255
2	46	15046370173	\N	257
3	65	4135970265	\N	357
4	46	11869492803	\N	357
\.


--
-- Name: ada_pots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ada_pots_id_seq', 13, true);


--
-- Name: block_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.block_id_seq', 1451, true);


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

SELECT pg_catalog.setval('public.ma_tx_mint_id_seq', 43, true);


--
-- Name: ma_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_out_id_seq', 39, true);


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

SELECT pg_catalog.setval('public.reverse_index_id_seq', 1449, true);


--
-- Name: reward_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reward_id_seq', 229, true);


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

SELECT pg_catalog.setval('public.slot_leader_id_seq', 1451, true);


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

SELECT pg_catalog.setval('public.tx_id_seq', 364, true);


--
-- Name: tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_in_id_seq', 661, true);


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

