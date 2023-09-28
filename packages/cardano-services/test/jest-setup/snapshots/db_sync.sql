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
1	1000	1	0	8999989979999988	0	81000010010844329	0	9155683	96
2	2003	2	83699907729568	8916290081426103	0	81000010006123481	0	4720848	201
3	3011	3	172862809015913	8738855912587132	88271272273474	81000010006123481	0	0	311
4	4009	4	260251368141784	8564952679328467	174785946406268	81000010006123481	0	0	412
5	5006	5	341618418595404	8428470159407746	229901415873369	81000010001641118	0	4482363	518
6	6001	6	425903120637717	8288560054370100	285526823351065	81000009992894009	0	8747109	616
7	7034	7	505473298034380	8154822950544396	339693758527215	81000009992894009	0	0	731
8	8020	8	587021527539823	8014708619874667	398259859691501	81000009975932421	0	16961588	842
9	9011	9	667168615434728	7884524500175207	448296908457644	81000009975932421	0	0	964
10	10000	10	746013860436480	7759288834696199	494676738204008	81000020566237359	0	425954	1070
11	11008	11	823606748826037	7630408121903604	545964563033000	81000020566237359	0	0	1165
12	12002	12	895332585171930	7511810886812536	592821382731050	81000035128362364	0	16922120	1267
13	13019	13	968948333554904	7393896576327021	637119961755711	81000035128362364	0	0	1381
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (id, hash, epoch_no, slot_no, epoch_slot_no, block_no, previous_id, slot_leader_id, size, "time", tx_count, proto_major, proto_minor, vrf_key, op_cert, op_cert_counter) FROM stdin;
1	\\xfa2df9e46e192701f78174776f77e8bda997b0ffe62043015b34416b36fc332c	\N	\N	\N	\N	\N	1	0	2023-09-28 09:28:01	11	0	0	\N	\N	\N
2	\\x5368656c6c65792047656e6573697320426c6f636b2048617368200000000000	\N	\N	\N	\N	1	2	0	2023-09-28 09:28:01	23	0	0	\N	\N	\N
3	\\x15a025b7fe349ea3e1c6bf446c316d51576c54742850ae3822e0a0b78ae28c3d	0	10	10	0	1	3	265	2023-09-28 09:28:03	1	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
4	\\xfd39060b980747e79ed1b1b8466b4e83844f625eb3b3d00dfa948b88ceec5a0f	0	11	11	1	3	4	4	2023-09-28 09:28:03.2	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
5	\\x2c5037c4738178aa4d4d9b9f7c8cc8f4229f41c106a88b4dd728817fd8f51855	0	21	21	2	4	5	341	2023-09-28 09:28:05.2	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
6	\\xb47707a9fe472a5590fefe0fce26c691423e7afb36b03e1185f08017d0974978	0	22	22	3	5	6	4	2023-09-28 09:28:05.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
7	\\x699a3695569a7411822d7c864a192cb357887d0f06f84bc2c26edcca6c396916	0	23	23	4	6	7	4	2023-09-28 09:28:05.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
8	\\xe4f4c6090fe0b6f6d0cdba2950d21ed76fdb0bc2789ae81cef63de1d8a9e991d	0	32	32	5	7	7	371	2023-09-28 09:28:07.4	1	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
9	\\x2e19c5984e39f5101195cf7acf4a6e3299a22919eed1697b7e325af3939fbcc9	0	35	35	6	8	9	4	2023-09-28 09:28:08	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
10	\\xfb09f5ccdabbb9fef03e4593f1a0a2e8c1c04d49585e29f7178716574be45e19	0	76	76	7	9	7	399	2023-09-28 09:28:16.2	1	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
11	\\xd5d88f7e4b3289c462997ae3dfe31e4527122bfd71f2d54e90387371e67c5135	0	78	78	8	10	3	4	2023-09-28 09:28:16.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
12	\\x5ac61abff5bc4cf3136e0bdc72657d0a9a11885c279a3b207dc7829a8b16a576	0	82	82	9	11	6	4	2023-09-28 09:28:17.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
13	\\x02f994223e21bc76cbd6e8e8b0430f734251d6ead75883243a0a34e468bf1a0b	0	96	96	10	12	13	655	2023-09-28 09:28:20.2	1	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
14	\\xa18b3b79491596a1c4f6399858519f3f9e0f02837ffbc410b651ad4792bced4d	0	97	97	11	13	6	4	2023-09-28 09:28:20.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
15	\\x36988005a06c0630e31143f4f741d941a7556ceba4400fddfeeb0eb3856ffa8c	0	98	98	12	14	7	4	2023-09-28 09:28:20.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
16	\\xbc98ccaad510135849f72cd225413561f567a18728bca48a07b5442dafa4b22f	0	108	108	13	15	5	265	2023-09-28 09:28:22.6	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
17	\\xa950b632897373ef4f25764f6637def2515d33b73adf6f0abb00017431a36aa0	0	110	110	14	16	3	4	2023-09-28 09:28:23	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
18	\\x8d3b4cabaa9f2630769b57a6ce8af4b5d495fe03731993809e08a8fb9b93434d	0	111	111	15	17	18	4	2023-09-28 09:28:23.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
19	\\xbd4926c787d152b31ad67f2232163302367335664de8ea92fd34b8b9fe53b4e0	0	125	125	16	18	18	341	2023-09-28 09:28:26	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
20	\\xf38d2197914b451fa5931a910dc691127693db84730cf2c9e045146c31d38efd	0	126	126	17	19	13	4	2023-09-28 09:28:26.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
21	\\xfc7d24ca5ceeb13c05175c85c8200f2a504cfadb5608377f52e95e02ac87608a	0	131	131	18	20	4	4	2023-09-28 09:28:27.2	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
22	\\x2fa3431a0c8a4bca934eb98295431719075ab4c82122700c93602a285b9e9495	0	140	140	19	21	22	371	2023-09-28 09:28:29	1	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
23	\\x5eb7f6fa1e3b67c51a241a87fbf562d1d52652be33e2b8850b8fce4ec3f3cb86	0	182	182	20	22	13	399	2023-09-28 09:28:37.4	1	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
24	\\xbb7580a37c56a9442b736d73b60279a16ff15aeb8f9ea3645823eb4e200b4a90	0	195	195	21	23	4	592	2023-09-28 09:28:40	1	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
25	\\x27dc957bb7cb6c990156fb20fdc1937fd37af4b36c688386367a1d7ba66c5eb9	0	200	200	22	24	6	4	2023-09-28 09:28:41	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
26	\\xb5445de4cf6689b28d037ae0284441ecbf458e7d90bd6d4ead80bbbc17bc7408	0	216	216	23	25	7	265	2023-09-28 09:28:44.2	1	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
27	\\x1c541bf796676f07685d56d27355e4409359d4b09fd61100f787a96fc7b95155	0	234	234	24	26	18	341	2023-09-28 09:28:47.8	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
28	\\x6b9297fa8bfdac9a63d555fae8f612c88094d97ee9f1986d9cfb264fc91029de	0	235	235	25	27	13	4	2023-09-28 09:28:48	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
29	\\x45af627d5cc430e03cce764291c39ee3b7ac6c925194e992e277a93ee9c0eab5	0	240	240	26	28	22	371	2023-09-28 09:28:49	1	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
30	\\x276bbc9cc6b2828f67bfd5ac78b69ada8ee809b1b45cf159d25df7a5c806d708	0	256	256	27	29	5	399	2023-09-28 09:28:52.2	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
31	\\xa4329f5969441f8047a3b4e49a2c0660a1a263cc0980e7baa673f9faf8bfd306	0	290	290	28	30	22	655	2023-09-28 09:28:59	1	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
32	\\xe3510a95a3c03cc9e2865403d81e995cd16199f0e0088956bf55364a67e9a0a7	0	318	318	29	31	18	265	2023-09-28 09:29:04.6	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
33	\\x981915636d729641b3109da56a0a34c9bb384eb08abed296251aabce9bff493f	0	320	320	30	32	33	4	2023-09-28 09:29:05	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
34	\\xfeced3fb3e62cc38cf8748dcb157ad961768770c3f05fc5ed8be31baba9a3068	0	331	331	31	33	18	341	2023-09-28 09:29:07.2	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
35	\\xaf045fea7f9dc66b363d6078006b9f6378bc4ce486032aa4debafbb399b17e71	0	336	336	32	34	6	4	2023-09-28 09:29:08.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
36	\\x01797757c1bc8265df12ab57eac20371adeeb2ca01329af6dc7a4acf894ab3b3	0	340	340	33	35	5	371	2023-09-28 09:29:09	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
37	\\x3afa45083c4498ef5119022b6f4b7f5d8486f1a22d1c2c30dcb442b3695b23da	0	347	347	34	36	33	4	2023-09-28 09:29:10.4	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
38	\\x3b84cc38bc511435c620b516f2cd9167b9c9b56b563e5cf127f65fe4a9ce9a63	0	353	353	35	37	6	399	2023-09-28 09:29:11.6	1	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
39	\\xde8ffadea655573a0308355aa13714f02f2a0c7baddf57a17e85acbc63e48aaf	0	373	373	36	38	9	655	2023-09-28 09:29:15.6	1	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
40	\\x6b77ff8c50601b6d26dd4592a79afd12e9bc1451de210be8a4c0e4cc7b840591	0	378	378	37	39	4	4	2023-09-28 09:29:16.6	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
41	\\x537798be17c38d969ac86fd2479f7ab2dac30f80805c69e88798b4d82891f34e	0	384	384	38	40	33	265	2023-09-28 09:29:17.8	1	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
42	\\xab2404639f43e31a253eee0358562c7969540ef1bde1b0e8bdb4afcc9ddeb183	0	405	405	39	41	6	341	2023-09-28 09:29:22	1	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
43	\\xdf6826859a7274ebc74ee573e0798dbcc42466fe36b0f71a9c0452bfd8cf6de1	0	426	426	40	42	7	371	2023-09-28 09:29:26.2	1	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
44	\\x4189228407815c28896526d2de3a6a208c02717e3aa154fe7444f5790865c77e	0	430	430	41	43	3	4	2023-09-28 09:29:27	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
45	\\xde368acb3b697e7fc42ce764b50f12a41941dbb019d80b288cde6e144becc705	0	435	435	42	44	4	4	2023-09-28 09:29:28	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
46	\\x59e93632e58e9492183d6b56111cf1252d47260839b8ff0e1e488f9c49ee4a30	0	449	449	43	45	5	399	2023-09-28 09:29:30.8	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
47	\\xe54c35a365d7b7132048d966ad282c7d357c28b8851ca854c7a5288ffafdf532	0	467	467	44	46	4	655	2023-09-28 09:29:34.4	1	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
48	\\x0e9aa6c60d929820e6c6cd962cb996e33695e18fa15782b188b288a6c686709a	0	470	470	45	47	18	4	2023-09-28 09:29:35	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
49	\\x09aef754af5f970f3acb2ca1b6d76f50d97dc454930acbeba10b47a1d2c0ee85	0	473	473	46	48	9	4	2023-09-28 09:29:35.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
50	\\xe184ec7a9c069ada40bbb5e37cbe8996d5b0e90eccd3da77c2b9667c00171b75	0	484	484	47	49	7	265	2023-09-28 09:29:37.8	1	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
51	\\x25888f199c8b483c1b38f01770ff16339a3e6185b5ee904648931e909fed0d4e	0	493	493	48	50	51	4	2023-09-28 09:29:39.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
52	\\xce5843b81c744f4a111502babba792b07f4d91337c92106573a9178c69f974a4	0	497	497	49	51	13	341	2023-09-28 09:29:40.4	1	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
53	\\x87289fad3e870026a13d236504846dbaccb61a56211aeeea0fc70671b4a6f803	0	500	500	50	52	6	4	2023-09-28 09:29:41	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
54	\\x01838ec5f36cd5b05d65ff90e88b838d2c0e24cb58bdab20dfd336b927ed322b	0	503	503	51	53	22	4	2023-09-28 09:29:41.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
55	\\x4190471210fa9fe401df35bf23be17986a1b686f13c05aab66922de3869850d0	0	557	557	52	54	18	371	2023-09-28 09:29:52.4	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
56	\\xe652d5f2f58e77e1f4a32f02171a3c5e2db4fdbf03f1d236fddd5a46546bdac3	0	574	574	53	55	33	399	2023-09-28 09:29:55.8	1	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
57	\\x0c35ccb307e5e076c59ca2ed59d6da5be39c2954057c50aa2738a920ba65e24c	0	575	575	54	56	9	4	2023-09-28 09:29:56	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
58	\\xbbfcf7f70324a834351c1b15d61bf38c509fb408fb6a5684b230862b6da0aab0	0	598	598	55	57	51	655	2023-09-28 09:30:00.6	1	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
59	\\x589d6970bfe218f77504571aa156123796f822ce066272cbc6885da67ccfe539	0	616	616	56	58	7	265	2023-09-28 09:30:04.2	1	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
60	\\x08d74816f5ae0b5ad3ccae06b5735e1d37c02ac5f134b8cac31a6b11645df0ab	0	636	636	57	59	3	341	2023-09-28 09:30:08.2	1	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
61	\\x6850695696802b34ef07bdf98900b0e57ba4e819d892f23b2a16fa2f056c3abe	0	641	641	58	60	22	4	2023-09-28 09:30:09.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
62	\\xf613b687b0ce123c437996c495fcecd3f70847cc1d77f876cf0da5b8d1340cb2	0	652	652	59	61	51	371	2023-09-28 09:30:11.4	1	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
63	\\xc08dd2d8dec30ce576903aa1939a98128473fbd1d9e363b0e983dbfa864a4e5a	0	655	655	60	62	13	4	2023-09-28 09:30:12	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
64	\\xee7d0ff89e755f66f54fa386f0a4ef5d935a881215d4eacad1e46b93427d2e52	0	678	678	61	63	18	399	2023-09-28 09:30:16.6	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
65	\\xbfd49582e4c9196443c12ebfe496f9511acfaf6cd7edf60caa0acebb81dcfcd1	0	683	683	62	64	13	4	2023-09-28 09:30:17.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
66	\\x5e4f23c8a3641185b3f38bcebce029eeb01c0769b16872ba5cc3de17c1d10f13	0	710	710	63	65	4	655	2023-09-28 09:30:23	1	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
67	\\x97f6cdf8678e70d4f5e997fa73b0c700bc8b79240985ab2b28dfe82ef0a48c83	0	720	720	64	66	13	265	2023-09-28 09:30:25	1	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
68	\\xb38161cd155b14078961036b800abb829ac67573b01e6e09e13171ae854ae868	0	722	722	65	67	33	4	2023-09-28 09:30:25.4	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
69	\\x6b50738a25dc8e16e46bee5bcffb66f613b426eeb03b6e9628a72ed5647119d0	0	745	745	66	68	22	341	2023-09-28 09:30:30	1	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
70	\\x9c82727c7038292d29f6125526e28dfdd05200249be4913a6f08af44af15fbf6	0	760	760	67	69	13	371	2023-09-28 09:30:33	1	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
71	\\x4589fd88b1c7d3f65a78473317cf13e50346bece65fadf6041aedbd20e984a61	0	774	774	68	70	3	399	2023-09-28 09:30:35.8	1	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
72	\\x1846d5866cad871f2b016bc627c861f777ec3f9b9749f5072114683e542b05e6	0	779	779	69	71	33	4	2023-09-28 09:30:36.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
73	\\x7c684a6d7b8b8f3d747cce016ea40b7d7649027f9f1ac9b97072c69086a42923	0	784	784	70	72	33	592	2023-09-28 09:30:37.8	1	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
74	\\x9ee5233f0e58ababae30c5228da5c9369bd7f26ce40f8cb62a618c820bff952f	0	798	798	71	73	5	399	2023-09-28 09:30:40.6	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
75	\\xf81d35413708bb1c273b801d33a72617146f0d77db686ca006c883178ab5affe	0	801	801	72	74	18	4	2023-09-28 09:30:41.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
76	\\xfc42b5fa44f15e25abe95de7e33b5ef77014173f3d60128c36d8ae50c8b99621	0	818	818	73	75	13	441	2023-09-28 09:30:44.6	1	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
77	\\x299a1680d97790ab0c42970b1a92d84ef92c4007ffde97871b8d19d28f7151cf	0	820	820	74	76	3	4	2023-09-28 09:30:45	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
78	\\x44d6a8f51cfd6c970eb28c41ac8eb6dbb5915012ee41bbe0d0a210c0ac58b47a	0	822	822	75	77	7	4	2023-09-28 09:30:45.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
79	\\x5c5d814235e39786701fc16207875ea2cea1fa87dfeae0ae4a15d3c60a79044e	0	835	835	76	78	3	265	2023-09-28 09:30:48	1	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
80	\\xa97ea69ee887ffc252b88c942d55db4baedde80180ec80ae015f8d947298c83f	0	839	839	77	79	6	4	2023-09-28 09:30:48.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
81	\\x0c7e5ff213c692b240bbbc8628aa19cc54de574636d46875b6057c585eb59e31	0	865	865	78	80	33	341	2023-09-28 09:30:54	1	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
82	\\x205b9e7dc5335b95bfc3aac5670f9bd02a8156ad22455c3af79ebc612903e3e7	0	871	871	79	81	18	4	2023-09-28 09:30:55.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
83	\\x17012d2da5264120b358ca88bc7719e54dad160f0abb5290890ca3a8452013db	0	873	873	80	82	51	4	2023-09-28 09:30:55.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
84	\\x03bc35c3dc94878a6597af20c17d3f0bd2169f303eb7cdb92c1dd28420349c1b	0	878	878	81	83	51	371	2023-09-28 09:30:56.6	1	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
85	\\xf64a6a7d09c8cc838129211e5d38c934f17220fddf4695ac6e47c85f42ded587	0	897	897	82	84	18	399	2023-09-28 09:31:00.4	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
86	\\x7461a92ddc748d4962826c5d03b78234689d75860a7f15481aeddc14179d39df	0	899	899	83	85	18	4	2023-09-28 09:31:00.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
87	\\x0132658beae6b6d3e3837f4733df1ce6d1608c42ba6e2cb8744ae31aa9c52c88	0	912	912	84	86	9	592	2023-09-28 09:31:03.4	1	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
88	\\x00462dc579926f7d28711d1d2c8973bf2f3e1a1b514daee91a3bd6ff8e98b20e	0	917	917	85	87	33	4	2023-09-28 09:31:04.4	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
89	\\x333c76678864fe0521f8927acd7622c785c24c1baf79401bf8ba997c406fb578	0	941	941	86	88	13	399	2023-09-28 09:31:09.2	1	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
90	\\x1297c66a2e19151c1481855b71d9bce425fc84396b2602955983e6a9f68bb5fb	0	945	945	87	89	9	4	2023-09-28 09:31:10	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
91	\\x8cd76d4fb271ab31869501d4e0b3a1fbb7a47cdc353e63b76b3a9749c0fd2c0d	0	947	947	88	90	5	441	2023-09-28 09:31:10.4	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
92	\\xbb5188bebd807b88b81a831ce784f6bba1b142c68082ecebce1f2dfd12b6cae4	0	964	964	89	91	33	265	2023-09-28 09:31:13.8	1	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
93	\\xc253daeec0d6479b335a7bf1adc4fd8ce696d5b3cb2b4b0a19b50b3455c4f32e	0	965	965	90	92	33	4	2023-09-28 09:31:14	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
94	\\x091f55b6f05fe2f902be2b602051049cc28b5ecdacbcd57475f6a84f2ed20299	0	993	993	91	93	18	341	2023-09-28 09:31:19.6	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
95	\\x08369941906fb9e441fcdcada21d457701fafb8dde0cfb66f45b06ac15f66345	0	994	994	92	94	13	4	2023-09-28 09:31:19.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
96	\\x4098a0e36d83e22d4e92c14ea7358675596f93606245cc928f64bf1ef44a740f	1	1000	0	93	95	13	4	2023-09-28 09:31:21	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
97	\\xcecb931a91f6306adb4d0c2051ca10af19a0ae3b6429888e026d6b4ab46b41dd	1	1007	7	94	96	18	371	2023-09-28 09:31:22.4	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
98	\\x4796f627833e85147fd038237e70c47699f4442324a489d0f4d3a576f09e0262	1	1020	20	95	97	13	399	2023-09-28 09:31:25	1	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
99	\\x531f91b22b3dcb1d3f78cd0d8492e52a389123fa82ad3ea515b998a3a65c9549	1	1034	34	96	98	7	656	2023-09-28 09:31:27.8	1	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
100	\\xd0095ecaf3c3a379d790bcf0b786f1a176a18aa189090c7991e56f638a5e4c78	1	1044	44	97	99	5	399	2023-09-28 09:31:29.8	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
101	\\xd5b5014dee06958df9f711114ef3c8769c231461cbb400e00bb369835f5790be	1	1073	73	98	100	18	441	2023-09-28 09:31:35.6	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
102	\\x31c63ea930f1ba76a02a81d1dd5c006469b7340ae5e868464ca3298c8e150dc3	1	1077	77	99	101	9	4	2023-09-28 09:31:36.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
103	\\x36ad7caaf7f36ef8f04655dea7ac1f3ba77a28e3a20ac56ff9fb49957a33318a	1	1086	86	100	102	6	265	2023-09-28 09:31:38.2	1	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
104	\\x84ab6392508d8cbf57f62b4a0b9a797cd5dd7dc71f3796e4435887474f38abf3	1	1100	100	101	103	3	341	2023-09-28 09:31:41	1	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
105	\\xfd5324c48be47d98372c4b8bc631911da71dbddaad58b18107ca3aadc8b5d90e	1	1106	106	102	104	4	4	2023-09-28 09:31:42.2	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
106	\\xd8fe6b66dcd6c830a45c6c951554c93e06909b7c6e89c5d8d7fade24b925d051	1	1120	120	103	105	9	371	2023-09-28 09:31:45	1	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
107	\\x54b8aa437da14959f112b84b4df1d7eb582d182b2358f6d9018219da905312d4	1	1133	133	104	106	13	399	2023-09-28 09:31:47.6	1	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
108	\\x5f70aca8ba49040e3106816a369440f82936c3feda4aa8d8036a3361d318cfb8	1	1135	135	105	107	13	4	2023-09-28 09:31:48	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
109	\\x1b8092d21b3a1575bf486bc39705bfed5d46c60ceccc0eedd3a7f30ba26c2d98	1	1168	168	106	108	5	656	2023-09-28 09:31:54.6	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
110	\\x590a42b92573f40ab32a3d89abcfcfc3247570e1522fc39ff17d3d7dc9dc8e09	1	1171	171	107	109	5	4	2023-09-28 09:31:55.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
111	\\xd27854d6c8ade28122adab5271a1fc25fa25d0e8cc490e854197297a9e9214f4	1	1178	178	108	110	7	399	2023-09-28 09:31:56.6	1	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
112	\\x08d25f51068255671cc98d86532715449b4d8332f2e27b1a470eb0ae38b1e610	1	1181	181	109	111	13	4	2023-09-28 09:31:57.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
113	\\x64d1a50dd4e690fbda4c6fdb15e19f532a96791f0ee8e56973c5b93305db2a7b	1	1185	185	110	112	6	4	2023-09-28 09:31:58	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
114	\\xbe839c05a6ddaabf1178615f01a7edf7ff57069fa0ebe3c6b16e1eefb6483063	1	1191	191	111	113	6	441	2023-09-28 09:31:59.2	1	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
115	\\x0773d545bfc85250f5a8a735180a33e4617c8b0f3b2bbe5089ec66f71e000193	1	1221	221	112	114	6	274	2023-09-28 09:32:05.2	1	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
116	\\x63f764dd5fbb52acd4cc70ca99f41beefc2de7ec9f38eac0ec8df8fe9ab5838c	1	1226	226	113	115	7	4	2023-09-28 09:32:06.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
117	\\xfab0617e211b0c0abcea309508d45023646ca6ac8f168a9d48e3a804bccf8692	1	1234	234	114	116	5	352	2023-09-28 09:32:07.8	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
118	\\x70c8985df8e40262dc3d592946f2455ae0f6a1b01c89a5655637b985a062f0db	1	1236	236	115	117	33	4	2023-09-28 09:32:08.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
119	\\x357943dec6e5386fd1ec511980146bf3ed42fe928d7c1b83321f1bd4a6937a69	1	1238	238	116	118	13	4	2023-09-28 09:32:08.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
120	\\xdb6634771caaba1c57f602e55b54ea4d099df94cc42f935d8c6a1922095d2e87	1	1244	244	117	119	22	245	2023-09-28 09:32:09.8	1	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
121	\\xaabd52b54e60876f73a9a99471807c6d60d72ee7135517e7df80783ba3d1f496	1	1252	252	118	120	18	4	2023-09-28 09:32:11.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
122	\\xf754631629d89f270ef72ae0392a84983826a9f3ede7ddb071ca8ea745301f25	1	1267	267	119	121	3	343	2023-09-28 09:32:14.4	1	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
123	\\x0b978264c0de6f17ddb1f91c46594752188f7c243ccc354472438634bd2acc50	1	1273	273	120	122	6	4	2023-09-28 09:32:15.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
124	\\x9db8425fec170dd4a6433de66d46dd1eea64c9022175a467faeccad376dd8d79	1	1318	318	121	123	18	284	2023-09-28 09:32:24.6	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
125	\\xbca828d27b86e8cc5c37a6ce545d157c0e0cc75173605b32ada02e801822a4cc	1	1323	323	122	124	4	4	2023-09-28 09:32:25.6	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
126	\\xde9975e70a37833a49a7faa3fb2cb12fa7b6903ba948bdc5920c29d00f8dbc33	1	1324	324	123	125	4	4	2023-09-28 09:32:25.8	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
127	\\xf7bbc3b9ce84a7c571ef2ffa1984f80471ee3351fa08c2cf5bc91ad2bcd7c51a	1	1326	326	124	126	3	4	2023-09-28 09:32:26.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
128	\\x7b8c3ffef76b1554db08b89b47af588a22d0db73be338906dfcbad40be9ae238	1	1330	330	125	127	22	258	2023-09-28 09:32:27	1	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
129	\\x0955ae0c1ea695ecb1dfe3aa3ded1e79d2abf408673274ccc0262164c489669f	1	1331	331	126	128	51	4	2023-09-28 09:32:27.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
130	\\x26539cab9403e97839de0cbe13eac1162d0db92926563051d691ffafb05072a2	1	1332	332	127	129	9	4	2023-09-28 09:32:27.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
131	\\x3046fa507dace532ab55cc28a44fc156a1564daffde8f3a062e364e5c9607e15	1	1346	346	128	130	18	2445	2023-09-28 09:32:30.2	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
132	\\xfa9cc48c1253967e589256502f4fc2882b37542dcc7b439b55acb8016660232a	1	1368	368	129	131	7	246	2023-09-28 09:32:34.6	1	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
133	\\x6d3c23557c7b52f1bdb013c0a84e909cfc19f9843d11cce40d50f3c3c452d845	1	1369	369	130	132	33	4	2023-09-28 09:32:34.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
134	\\x9f962d07dff58815f6ae274108ce39252c7f8f43007a2724df12beb4b987205c	1	1374	374	131	133	7	4	2023-09-28 09:32:35.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
135	\\x116ee326c65d3c32bf1704e0c2c1fa7aaa4a152093ee62d95a7b01b5d3053b45	1	1378	378	132	134	33	2615	2023-09-28 09:32:36.6	1	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
136	\\x6171d434f5c057fe68b7516d7d26f27a3ea481ae54c0c6624a04c44281674f9f	1	1387	387	133	135	4	4	2023-09-28 09:32:38.4	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
137	\\xa3e3d18a7fa20b6b5fe46d82398d381f957cea976945ada17dc66444aab204e1	1	1394	394	134	136	6	469	2023-09-28 09:32:39.8	1	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
138	\\xe4dfe2e138f51f0bb2412792c17a3b3ab777baa5a8896f33b853b3d058796abc	1	1400	400	135	137	5	553	2023-09-28 09:32:41	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
139	\\xa41160d003e370df461149d879aeb55ec2ffe01da50935a4da1483dd99cc7b66	1	1409	409	136	138	4	1755	2023-09-28 09:32:42.8	1	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
140	\\x05019d57dcf475ce803b416d065f24340ecddd07bffc07ed52068ee82c8a369f	1	1419	419	137	139	51	671	2023-09-28 09:32:44.8	1	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
141	\\x078fc49f62d20206e77e2bd96a86c0f1423b80fcba37b182ec20146927fb4661	1	1424	424	138	140	33	4	2023-09-28 09:32:45.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
142	\\x86f0903203d5d033253f47b41c3a5f42a2b420b43a5b949c123e99066ff0eb41	1	1430	430	139	141	13	4	2023-09-28 09:32:47	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
143	\\x7ebb05221817f18aae19c5cb866ca3d8dc057b67e3838eac4cc71d8c1360b115	1	1435	435	140	142	3	4	2023-09-28 09:32:48	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
144	\\xfb86c5bed8f23e66518aed971ba962368b6a790e6a238c523da9b8bd7327c6f3	1	1439	439	141	143	33	4	2023-09-28 09:32:48.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
145	\\xd983645583023457ced46647e67e6aec20f5f15ed919d494f1993ab520fe3169	1	1489	489	142	144	9	4	2023-09-28 09:32:58.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
146	\\x9caba7f18d5e2ca2da745d34fe616fa81bc2d5a01606669a63f357516a85ae31	1	1493	493	143	145	13	4	2023-09-28 09:32:59.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
147	\\xa6442d98c0f948c44239cb31862b2d9bc6b01ddc0e15141f647d93800b04f6e3	1	1497	497	144	146	7	4	2023-09-28 09:33:00.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
148	\\x2c696658f49fc35fe1f5c414067fc9781c87572b8e297e4d05ff46317faac399	1	1507	507	145	147	9	4	2023-09-28 09:33:02.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
149	\\xa6b374a4a81b560777011d9aeb02f3fa3f820abc08ce5db1d404d98d554564ae	1	1508	508	146	148	22	4	2023-09-28 09:33:02.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
150	\\xee766cb258f105683bbd76878178f541ddfa05a699f548255ee2d63b4c10366a	1	1509	509	147	149	51	4	2023-09-28 09:33:02.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
151	\\xd4d3c032676f59f8de1f1f97685101a3696bf94e04140c4369cc996c0bf41aa0	1	1512	512	148	150	22	4	2023-09-28 09:33:03.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
152	\\x7ae14a5bbe9e935654136ad449b1a8a8f915ac073f164e110de7c02e6254502c	1	1529	529	149	151	6	4	2023-09-28 09:33:06.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
153	\\x7646f10afc5486a621e2dddea28b31f8de8e7aa0aecff95be810a5b7e5f687ef	1	1557	557	150	152	3	4	2023-09-28 09:33:12.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
154	\\xb5238e6c760dffa59cffe1beabdef72911e87e4aa926d4c42ee27d9165e6b085	1	1565	565	151	153	22	4	2023-09-28 09:33:14	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
155	\\x73bd6a6f7fdf4442ecd73aef289d2222e0ac5e797bab692faa66aace06569485	1	1569	569	152	154	22	4	2023-09-28 09:33:14.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
156	\\xf522b196b04722a39333e9bd393791818d63c68d11ca4702ac78748810cb2b65	1	1570	570	153	155	9	4	2023-09-28 09:33:15	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
157	\\x9f7e18907d20ba53fa39c132859a333003e402a437edd2e507560a63c6c0af19	1	1573	573	154	156	5	4	2023-09-28 09:33:15.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
158	\\x6f897b27c911a4618ad874eb3bd3cc18dd9c3927bde10dc371ddb730f0bd58d1	1	1575	575	155	157	6	4	2023-09-28 09:33:16	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
159	\\x462c11b5e935e0d0517a100e7f3daf0d3fa8d145871ff68aa027d77a11d74b1b	1	1576	576	156	158	13	4	2023-09-28 09:33:16.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
160	\\xba5978920ced08df63f43eedf675d57635e403384570d55f8816281b8e444509	1	1577	577	157	159	4	4	2023-09-28 09:33:16.4	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
161	\\x858fef9638037550c617066339b77a3aa32e7b5101a3fcfe2b2220100d8e2d19	1	1580	580	158	160	18	4	2023-09-28 09:33:17	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
162	\\xaf686e22c0bbda1f27d497c61b099fa96679e13f1657b921aec16732654fe1c6	1	1584	584	159	161	7	4	2023-09-28 09:33:17.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
163	\\x26c6c7ce43da5154326561cef75ab89d85db75509c9e8c328dbf100e9a9296da	1	1595	595	160	162	22	4	2023-09-28 09:33:20	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
164	\\x6db75c1ebcbeab077ab32832a482934310691f66c58b027a2577c2cb8aab036f	1	1597	597	161	163	13	4	2023-09-28 09:33:20.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
165	\\xfb628361df461a30ca92351c5162457dfd52022fc97ea71139b7b2bb4a564116	1	1602	602	162	164	3	4	2023-09-28 09:33:21.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
166	\\x60804a8bd0129e96f6ba76c8f7230cf67b1ccf06231bf77a7a60965773cf1dff	1	1610	610	163	165	9	4	2023-09-28 09:33:23	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
167	\\xc76b90950d91d107dac0d4d948926df6cd659495aa642f1a5f3bcd5c2eb132ae	1	1614	614	164	166	9	4	2023-09-28 09:33:23.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
168	\\x07ea720b5e329e5ef8ab1f06d8adf76935906919116c02fadb537f6e1452893d	1	1621	621	165	167	33	4	2023-09-28 09:33:25.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
169	\\x961fadab463de07105bf178d5ba0d32387b6b315c979aba123b3585617bdd19e	1	1630	630	166	168	7	4	2023-09-28 09:33:27	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
170	\\x5033c41c26827ca99cf89c99c4abd3db2c4fbee48290c832888ff1682d719fda	1	1638	638	167	169	18	4	2023-09-28 09:33:28.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
171	\\x9ef149f72f8a2ab5c780f2540e04a965063722ca3c9b881f4b247375433e4004	1	1642	642	168	170	22	4	2023-09-28 09:33:29.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
172	\\xf2bfc1e912013cb53b9023528bdd1f6900b07517fc7736fd6ccc8cf579eaec88	1	1647	647	169	171	18	4	2023-09-28 09:33:30.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
173	\\xd976ec3986512194fb63c75f32b61d91101fcb67abdabfd416372b4a7262fb09	1	1654	654	170	172	22	4	2023-09-28 09:33:31.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
174	\\xd849dca6b8bc9bd44441ba21689ded5aa5a6b5f415d908bd48b54d89c38d4596	1	1694	694	171	173	51	4	2023-09-28 09:33:39.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
175	\\x2970881e68817b2d6fa30f30c0d979f088d150f19bac5f4bd3211adeb9116554	1	1707	707	172	174	7	4	2023-09-28 09:33:42.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
176	\\xbc348a0bcaca4b315533134de43a25e386eb9501ac61726afed7b38731e6661c	1	1714	714	173	175	4	4	2023-09-28 09:33:43.8	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
177	\\xf404591c1dc3450bb2fcece49d93c93091c488460c0f79ab692f3aaf9a1b9944	1	1734	734	174	176	4	4	2023-09-28 09:33:47.8	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
178	\\xbb8924fee1f64099523131d74e6d63628458ee1af535b6f6e1c29f68b17ecf10	1	1749	749	175	177	22	4	2023-09-28 09:33:50.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
179	\\xffd2723e325f502fbbcf00eafac6a56d73a05fb845d74f9315f62bc9cf2c2fce	1	1750	750	176	178	18	4	2023-09-28 09:33:51	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
180	\\x0fbd7f1998fffd32d4b6727b0ffb0a1fbe1ced19ce8c11d6b72a510563dc3748	1	1771	771	177	179	33	4	2023-09-28 09:33:55.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
181	\\x3bb2f65a4d3a526e5d934b9f864dfe29b97e8af295f461c38fc8142f84e1155a	1	1775	775	178	180	51	4	2023-09-28 09:33:56	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
182	\\xc945ac88678230761fd0d39afc2d145b003e0d84aacb8734bfff776766bafa8b	1	1812	812	179	181	5	4	2023-09-28 09:34:03.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
183	\\x5b93c957b45552cfc5ce67e9cc3d3a36bd10e26c64f8f33a26d6ef69bd2426ac	1	1831	831	180	182	51	4	2023-09-28 09:34:07.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
184	\\xb81c20eaa80d175c0869ee62cd240cf9f85743ee890bf98cb513faa3baaba4df	1	1846	846	181	183	22	4	2023-09-28 09:34:10.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
185	\\xe4aa3b5ea65eea85da4def96d303bf9173a86e183e84bfabed1d7c696fe4425d	1	1849	849	182	184	33	4	2023-09-28 09:34:10.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
186	\\x78319c3cebcd7a7775abf71a1319896acd9b559bd035d90fb2f82dd8f7ce862b	1	1853	853	183	185	5	4	2023-09-28 09:34:11.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
187	\\x6e078411d7bd581ff6b0fdbcc9f04f1417f6b73c10bb757ef4ce3e549a8c79cd	1	1857	857	184	186	3	4	2023-09-28 09:34:12.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
188	\\xae99ec4f3aeef512fa9081a7a6ef2e1c855e0c0f6d3fb0db444e02b263d6aee8	1	1861	861	185	187	4	4	2023-09-28 09:34:13.2	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
189	\\x9347c62e6efff8833d4f6bf919c67b735d3b721d8ff30d5b0a8c12ddcc077c2b	1	1867	867	186	188	18	4	2023-09-28 09:34:14.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
190	\\x2476a67415ea73d436d2f98f527773e3e680edb49c533b36e59c0f5ea66b8c7e	1	1876	876	187	189	7	4	2023-09-28 09:34:16.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
191	\\xab2a231ed8b83d611d41544e4fa452e1e0a004956cad383d57e8f27b2cbc74d7	1	1893	893	188	190	3	4	2023-09-28 09:34:19.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
192	\\xad818d290c2bb8774c6494bf53301351b72888c7621b97b7e1991758a6d02250	1	1904	904	189	191	13	4	2023-09-28 09:34:21.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
193	\\x3824a1fd2b45196d9ec67691c8293c1d472449268d3bc53efe2c0ccbf7402ca5	1	1916	916	190	192	13	4	2023-09-28 09:34:24.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
194	\\x4d5148155e2302555201864ce521f057c81906cc5affc5705953d17a27b242a0	1	1924	924	191	193	6	4	2023-09-28 09:34:25.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
195	\\x075f1575448a655c77d042b9c56988d870b1a2b0dcab6a37b279e5b0f4c41301	1	1941	941	192	194	6	4	2023-09-28 09:34:29.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
196	\\x0edc6734268fb344bba413907ae0c5ddbd0cd139434be3669e596c7286575f25	1	1947	947	193	195	51	4	2023-09-28 09:34:30.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
197	\\x8e4d72b3024c42a43b027ffe79243ce11e54b882f3257abdf829389f8419af06	1	1954	954	194	196	6	4	2023-09-28 09:34:31.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
198	\\x6a382463284a9814c5cefa2843c7dbf52d2756f3fb38a88a1238dd2d8f37c633	1	1959	959	195	197	6	4	2023-09-28 09:34:32.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
199	\\x15f385542f7c842b61473198c7bd5831954d8d2776e68e3cd40ae19dad6e0635	1	1989	989	196	198	9	4	2023-09-28 09:34:38.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
200	\\x5320ee1da55e7e01832ba954fbb585360020f6295b76e3f7d6deb1b3e2809ba0	1	1996	996	197	199	18	4	2023-09-28 09:34:40.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
201	\\x69715a5ec288bbf3fd8f5a77df911acdba3d50fa82557cbdb74b27fcf3c6a712	2	2003	3	198	200	9	4	2023-09-28 09:34:41.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
202	\\x3a273b4297503743a130a8ccbcf3a06ed923fe97febf0f011612d284b0ae4cc8	2	2010	10	199	201	6	4	2023-09-28 09:34:43	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
203	\\xb781f00ef4daacdf93fa1bd3391386b91df2cc4e59e9ab81fa459296d430c3c1	2	2021	21	200	202	3	4	2023-09-28 09:34:45.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
204	\\x09efdfdc3e790a5b5b4c9682c7e0435dc0fa3816db62e7acf94aafbb80286759	2	2031	31	201	203	4	4	2023-09-28 09:34:47.2	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
205	\\x1c5b0048e3ff1e9dfe3c6952ef7424e000f28774d5edee14c6e187e4f37a70ab	2	2037	37	202	204	33	4	2023-09-28 09:34:48.4	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
206	\\x522319eef9e89c7fcb6aed96c4c69f616ea9e00325309c3f05a82c69ed8c4518	2	2061	61	203	205	13	4	2023-09-28 09:34:53.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
207	\\xc6d063dc6bb856ca0e91b8e6432204a25fee1578a1480344fe8cc9ece6aac678	2	2067	67	204	206	33	4	2023-09-28 09:34:54.4	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
208	\\xb5cdfbfcf662303e855a4f4146178b9d38e6fcaa6f2ef99b47a6e3b27616533c	2	2069	69	205	207	51	4	2023-09-28 09:34:54.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
209	\\x23f4ac97c80f2f0a81316abb7fff3a1ecf09aeda594008104c89738566f6a411	2	2085	85	206	208	51	4	2023-09-28 09:34:58	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
210	\\xa941b8c70cfbe9a72aa0f04093a83ec4a099568e11bd9cdb317025e107ea99c7	2	2088	88	207	209	18	4	2023-09-28 09:34:58.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
211	\\x9471a14dd5acc832fd206e915aa35172e0e46cd15334f0ff8b1cc2732e910548	2	2093	93	208	210	7	4	2023-09-28 09:34:59.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
212	\\x5b97321d51ed5f2293e3e9cd5ccd3361ac175189b69140101f1f2eb9462851ed	2	2100	100	209	211	18	4	2023-09-28 09:35:01	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
213	\\xd4004a8769f61e9b99fe1f26bc562ec8f303884b58f09505433a27745baf841b	2	2105	105	210	212	6	4	2023-09-28 09:35:02	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
214	\\xd070065817ff4b2c68302414a8101d19bd0f6ff75cbc3a28f24a114ce80c98e7	2	2106	106	211	213	4	4	2023-09-28 09:35:02.2	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
215	\\x475a3b86477ab7d71ebd5824af2bbde50544918bb4f57a0b4dd2286031e0efab	2	2108	108	212	214	22	4	2023-09-28 09:35:02.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
216	\\x86592c69ca98b99807fb5209cde26fe6c91c3046fb3f6d9ff090a819b8c94e53	2	2111	111	213	215	22	4	2023-09-28 09:35:03.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
217	\\x2ba6a71a6bd4e778bb23f22c4bd13d49275e5989ec5da1b53ef463831e896bc8	2	2119	119	214	216	51	4	2023-09-28 09:35:04.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
218	\\xb9e6858e8f48e4d136716bd65df9099495175be352af701e0751d643475c4f87	2	2124	124	215	217	22	4	2023-09-28 09:35:05.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
219	\\x8e6cc3c8e68846ac4ca45ce5cc3af8d42fb679b127f521b7de86c39482fbb89d	2	2126	126	216	218	18	4	2023-09-28 09:35:06.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
220	\\xb5890f95991405f63a99bca8e5233fd585a3aeaecffeccda222faf9db4ab0868	2	2128	128	217	219	9	4	2023-09-28 09:35:06.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
221	\\x03fd801144235909c30c0e374acc4e79a1d393784782f426883604d28241ae86	2	2134	134	218	220	4	4	2023-09-28 09:35:07.8	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
222	\\x18bd709f49c0ccaafec9580f07e6f3f9ca6b3d7f858bccf85c144c12cd4fff90	2	2143	143	219	221	9	4	2023-09-28 09:35:09.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
223	\\xcfa1ef850b0c24c03c787d2121182430e3bb6103a113a3da24dc3cf5ee3e2de3	2	2164	164	220	222	5	4	2023-09-28 09:35:13.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
224	\\xb2e7a9ed8b955c1db1b80040b6eaebc12d0aaf46d684d68b550e004ef4df230b	2	2170	170	221	223	4	4	2023-09-28 09:35:15	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
225	\\x251e48bc672e6fee5b479b6984bb019193e225435a6151ae8ec402a4e4dec4c7	2	2177	177	222	224	51	4	2023-09-28 09:35:16.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
226	\\xe3b758d41f1920287c7043f286e9cca48639b7f49eeac3b69ba158cfefaacef6	2	2183	183	223	225	6	4	2023-09-28 09:35:17.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
227	\\xd54efc55a85dd7ea6b1016d5884a75c2d5275cd11da85bef5a893659c36ea7b3	2	2194	194	224	226	13	4	2023-09-28 09:35:19.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
228	\\xc98bf589a7e09af5c596fa3b603a56b56c00fdd87fe6b231d8bba06a4d5142bb	2	2206	206	225	227	51	4	2023-09-28 09:35:22.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
229	\\xd8f44430ee535386bab1ed103dfd21ad33de1371f61cb314104a78c0ec5dece5	2	2213	213	226	228	18	4	2023-09-28 09:35:23.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
230	\\xa81b948c0ef00ecfe37ca928f0144318a5952bdb10269daad69ae3b9ee2840e3	2	2215	215	227	229	5	4	2023-09-28 09:35:24	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
231	\\xf2bd8e02fda1b8b5ecdb19d015bd0b5fce4e0d6dc73fa90c0156a6d7e89cba40	2	2220	220	228	230	9	4	2023-09-28 09:35:25	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
232	\\x71de401dbba5dfc625b11e002c68096cfaf39fc75ae86f54e21d8c70e938e145	2	2230	230	229	231	9	4	2023-09-28 09:35:27	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
233	\\x251372b4a5e224cc5ea541d8352025d66393efeed3a0cead9fa8c85c18703fbb	2	2245	245	230	232	7	4	2023-09-28 09:35:30	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
234	\\xedf0f5127291f360fdfcc293d221049cf3dfbb9f2004a01208047dc7f56f2754	2	2263	263	231	233	22	4	2023-09-28 09:35:33.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
235	\\x349562a852455f6c9bfba73c2b780c089f2675681a6d67127d4bf76d16823a4c	2	2271	271	232	234	4	4	2023-09-28 09:35:35.2	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
236	\\x84cf759b68cf81c17e1ee3828f895d28a3fe78d6d7ff1451bb6b4f985b6149e3	2	2272	272	233	235	3	4	2023-09-28 09:35:35.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
237	\\x00d0076de289e35be2757dbe79191e63c4b87d49958352c98373d1f11139443c	2	2287	287	234	236	7	4	2023-09-28 09:35:38.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
238	\\xc903d4cf20561c7fb2ec0d91154cfff6bdd1b346ade36c59be02444d2ff37411	2	2296	296	235	237	5	4	2023-09-28 09:35:40.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
239	\\x65773c6f44728766ab2810c902732490480226bf93ca761063f40280a8cfe55a	2	2316	316	236	238	5	4	2023-09-28 09:35:44.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
240	\\x960d97a2bd19b225c8b32fa0cbf0359c7383a49737a398426b8503229323387d	2	2317	317	237	239	6	4	2023-09-28 09:35:44.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
241	\\x59172208239e52bd9e92db52bc163ea47b1a1189ccc0889572873c19485f9049	2	2319	319	238	240	9	4	2023-09-28 09:35:44.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
242	\\xc4b82850ff4e5fce06a93881745850eaeceaad3c2d13a80694b6b20bf551ac70	2	2332	332	239	241	22	4	2023-09-28 09:35:47.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
243	\\x888a2590ca9336a905c173466ec94280772956747f8c04376817e387d9990cd7	2	2346	346	240	242	7	4	2023-09-28 09:35:50.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
244	\\x3a50fd7fda152aedc4d8a84c4943f4ad09f3854af8d0208e4abc99851038582b	2	2349	349	241	243	9	4	2023-09-28 09:35:50.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
245	\\x9af723eb147f7f56e0c1139a2c37cbd47cef33e01fde5a8aa5aaa3e1e1aedfa8	2	2350	350	242	244	51	4	2023-09-28 09:35:51	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
246	\\x3bc3a8132164a59840a50139e8309d9a1a4a55a32615967e00881995e4eb0e8a	2	2353	353	243	245	4	4	2023-09-28 09:35:51.6	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
247	\\xc311f55b0c42ebb4ea060c85773393d19863ed5d42001f0de11255227c0bc18a	2	2356	356	244	246	9	4	2023-09-28 09:35:52.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
248	\\xdf8171be4cee7ffdf97de51bcaa7a07c6ff36c5eca3626638589e3bf3c83b6e8	2	2359	359	245	247	7	4	2023-09-28 09:35:52.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
249	\\x777da8123770a70c77add8ede123a5d4dd7a24fbcbdc39ba305edbba271b225d	2	2379	379	246	248	4	4	2023-09-28 09:35:56.8	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
250	\\x3052616addd57b6a48a91d38a42251e877a13465d4da5134bb0ea06aae2eee84	2	2389	389	247	249	51	4	2023-09-28 09:35:58.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
251	\\xa70425a5f4bb9dedfbd4c74a341840d0c9977a4f0eabedfd50f990127d56f79f	2	2409	409	248	250	33	4	2023-09-28 09:36:02.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
252	\\x5e20f728d27e6f8a0105f3339b5e5fb1c8a7605d182cf3af1b8e6d4616c93970	2	2419	419	249	251	4	4	2023-09-28 09:36:04.8	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
253	\\x7f2745571f9965dff66bf947d686e5c849cb63aa9b49cf9fb01b5c9d6cfe1dab	2	2444	444	250	252	13	4	2023-09-28 09:36:09.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
254	\\xd9ee7f7fdee1ab1d6f0044533c00c9a26a176d6c9f4a4e59a3456685d1ae71cc	2	2466	466	251	253	4	4	2023-09-28 09:36:14.2	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
255	\\xb71e66746dc09a43474e0297fe4d7c9fe85a78136a9421303dc5b4bd40431512	2	2480	480	252	254	51	4	2023-09-28 09:36:17	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
256	\\x24af76c84cf903c5df1c80bd98c9cf68fe1443484cebd5e9da5eb6e99a0f60d9	2	2486	486	253	255	33	4	2023-09-28 09:36:18.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
257	\\x38c22c57c857752af47af5b016dc5a5135d0953f4ee58a973e94f02d0fdbc5be	2	2489	489	254	256	22	4	2023-09-28 09:36:18.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
258	\\x1ad5b791cad9b9908a0a20c6698ded0448585593050da1bb659b907b6ce815f2	2	2498	498	255	257	13	4	2023-09-28 09:36:20.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
259	\\x25eb009ff81bbde4593b2b67a238e0e1791490d67acf02e44690dff008b8c0b7	2	2502	502	256	258	33	4	2023-09-28 09:36:21.4	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
260	\\x08b8a8ce55aa5ae6a22e8196637a53d132e5a71898e048d9db66f9488925c560	2	2514	514	257	259	22	4	2023-09-28 09:36:23.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
261	\\x2775213a5bff7d4c970d17ae85b112f7e582eef2e0a8cfc6fa1ff66298210106	2	2526	526	258	260	18	4	2023-09-28 09:36:26.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
262	\\x7503e0545477328b0f62e537b8e5cc5fb8f46ecdb1f35a36c2430fade1e92bd5	2	2531	531	259	261	51	4	2023-09-28 09:36:27.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
263	\\x00b6dd8b7ddd9b53fde48e016474641afdf8af539984dcab879567d3ab6b277f	2	2533	533	260	262	5	4	2023-09-28 09:36:27.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
264	\\x2773d20158ce103dc4fe7d4f058dabc146c43e2162fdd7c40c47e9d76c93b4ac	2	2574	574	261	263	33	4	2023-09-28 09:36:35.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
265	\\x7ee83edcb5c48b379139ed12991682ca952cd1afeea12a437b11e5db5c1f073a	2	2582	582	262	264	18	4	2023-09-28 09:36:37.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
266	\\xd4ae7532342964018ab3846db2e983fb30efe2b2ff331ad8cbaefe72e560bb5d	2	2593	593	263	265	7	4	2023-09-28 09:36:39.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
267	\\x6debe62a8c8b4c9fb28892eace4767d1424d326268324fa6561fbf04bdd7eb78	2	2596	596	264	266	33	4	2023-09-28 09:36:40.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
268	\\x9ebd93d7210c77c84b284a58b3d335788da994a765ae1ac231d2f5098e0f6e61	2	2604	604	265	267	7	4	2023-09-28 09:36:41.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
269	\\xe1c0e52d616aafb16130fef5fc5ad91d34fdb3bd5f3d987af250998b3a5c041f	2	2618	618	266	268	18	4	2023-09-28 09:36:44.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
270	\\xbeb87f93c12f09f499de8f2510c2107064d05a0d8d83bbae1db16a8cfd911e2e	2	2620	620	267	269	22	4	2023-09-28 09:36:45	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
271	\\x703f92b94594a03aaa6f771a3d6dfe7cced74aa29186a110577fdec142565198	2	2624	624	268	270	4	4	2023-09-28 09:36:45.8	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
272	\\x71314e3fb4565ec0191035d62abaf32bd0e0fb92832ca7b3893c7a98c982f8ec	2	2651	651	269	271	4	4	2023-09-28 09:36:51.2	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
273	\\x77245702342d39be9ddcf0015439f2259545d7d37a89ad6122456405af5cb644	2	2653	653	270	272	13	4	2023-09-28 09:36:51.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
274	\\x450f374a48b2486b8302f128a7326161a896c66eaa51fade86f4ee5ea3425fe7	2	2654	654	271	273	33	4	2023-09-28 09:36:51.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
275	\\xc8bc5b542dccfb81b640cd065666bec8cd2c6cc16e24cd753ef13f078cd4eb18	2	2671	671	272	274	7	4	2023-09-28 09:36:55.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
276	\\x98d435f5a7b01e1bed7cca1fe9b7b67e68d3c9a0d638af5492780fea01f71e9e	2	2675	675	273	275	33	4	2023-09-28 09:36:56	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
277	\\x2cf69185f35a964e8e01b6fcd2356ec0bba43cc7083987d6f457d5a1cf270608	2	2707	707	274	276	3	4	2023-09-28 09:37:02.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
278	\\xa4d162e2da50df0a4a54adc0e58e04eb13836c6db15993b80574fb5496fc7f28	2	2708	708	275	277	22	4	2023-09-28 09:37:02.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
279	\\x48ab708c971916a72968677fed7c2cc1b482e7c0a55e0530271d7bd7d2fc6eae	2	2711	711	276	278	51	4	2023-09-28 09:37:03.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
280	\\x5d375f356e7fed2d0e0f3e4afc80b4de1bb82904e969a2acbb837364cd197a39	2	2714	714	277	279	5	4	2023-09-28 09:37:03.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
281	\\x8a65adcb61e0bfd4b70085de75d71421e72e2388597e4ffa379715e59e958d70	2	2715	715	278	280	5	4	2023-09-28 09:37:04	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
282	\\x6dcbaa75af3600b648f7fadfdfee6f581e0ab1122b64a10f1f2e76da29a75c63	2	2723	723	279	281	9	4	2023-09-28 09:37:05.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
283	\\x36b86533bda3bfc3de4250d5a905767bcf170f86f1e3abe762e9a34823d18872	2	2731	731	280	282	9	4	2023-09-28 09:37:07.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
284	\\xa92b668538d096b55b8ccc9b22697de10f24f60612232ed49b4f07984c808bf9	2	2733	733	281	283	51	4	2023-09-28 09:37:07.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
285	\\x07ab96b1f3e4f67687396e57db3102b69898474ff1ef9b09c507770f22f1466c	2	2746	746	282	284	18	4	2023-09-28 09:37:10.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
286	\\x7d270b480fe77305bfbb71cd9209271abe541b4ff7d8e5f095541cc63b07d567	2	2760	760	283	285	5	4	2023-09-28 09:37:13	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
287	\\xf269f91f2d5f6f9da92fb533557fe417c8691f30eb9a25ac3ca012f451613f18	2	2779	779	284	286	33	4	2023-09-28 09:37:16.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
288	\\x741cf82597ddd23abdb7cfd3d8354afbeed22e98208059cbc577be2f02ab1fd5	2	2791	791	285	287	22	4	2023-09-28 09:37:19.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
289	\\x7889ae26a9decbdca8b8561b464e35005fc59ff77abc46ea5f5ef4069efd41c0	2	2810	810	286	288	33	4	2023-09-28 09:37:23	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
290	\\xe79f2652e93f23a7aafa225a0dad3a894abf940716393b8f116979e70f9b3ec7	2	2813	813	287	289	3	4	2023-09-28 09:37:23.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
291	\\x0229ec1adea480d5fa8624b70d1db92df276b6406b4600277dafb3bdf2a245b8	2	2826	826	288	290	22	4	2023-09-28 09:37:26.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
292	\\xfcd480a19a1898e23b1669931284798cb29c224cbc75f85e1f6f3c05d4fd7f64	2	2829	829	289	291	9	4	2023-09-28 09:37:26.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
293	\\x8dba57b7eff7c6ae41f97879c856a4fa87029593737ade94efbb1019485d004c	2	2835	835	290	292	9	4	2023-09-28 09:37:28	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
294	\\xea565a6441947f3f8cb54e1ab60144d72c3b8747f2b371572f12bf04b6b9079b	2	2856	856	291	293	4	4	2023-09-28 09:37:32.2	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
295	\\x37b5464c2f551d529b3375cd4586c8b459fd41444e0990dfe1cd2fd0e45217fb	2	2860	860	292	294	4	4	2023-09-28 09:37:33	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
296	\\x4784308ca9c6b74b113f06e38e20598f64485390b7efe47d04720545cb3ab99b	2	2873	873	293	295	13	4	2023-09-28 09:37:35.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
297	\\x237a98bc8d99bbeb4b4e33b98e14b9850754a3b8a80d40f92d2e6b57e4da6ba3	2	2875	875	294	296	22	4	2023-09-28 09:37:36	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
298	\\xde4fd74f9d3e6f318798207e600adbc69084df8030860dfc7b35b9c408861ee3	2	2880	880	295	297	7	4	2023-09-28 09:37:37	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
299	\\x3aab25e4509828c8641eccac15ec72a6cd7085dd00f61848a32029d7efd91ae7	2	2881	881	296	298	9	4	2023-09-28 09:37:37.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
300	\\x24af67c4b2956f41fe3b24ac2b4b22091b38e56e9b1f5e5a4f1dbaa4b1a12ce3	2	2886	886	297	299	33	4	2023-09-28 09:37:38.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
301	\\xe63b0a680e1e47ac3c0a994707851cdee3f469440c829dcf35acb277eb0d3903	2	2887	887	298	300	3	4	2023-09-28 09:37:38.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
302	\\x79922c7729004671f24f70b9287acd0ed33db05c79cbe72b89d7d50595ddf6ff	2	2889	889	299	301	5	4	2023-09-28 09:37:38.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
303	\\xa9af7b2b8e254d58304aa08f58bd4e453525696b78cd5ea8fec3125d4cf7dbfb	2	2895	895	300	302	4	4	2023-09-28 09:37:40	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
304	\\x5768f0edc2f263fb638ded41e84048a41ca00d61d3b930e6bdd0132d2d83be0c	2	2899	899	301	303	3	4	2023-09-28 09:37:40.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
305	\\xcd3766f285cdff53a60413b38f0f594d05082656340c80bd2b9acd0704c6cc0e	2	2900	900	302	304	9	4	2023-09-28 09:37:41	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
306	\\xd1e89ec9be85d8e07be43d1451d995522d471aca0a9bf8b71c12bf12ebb5fbd4	2	2901	901	303	305	3	4	2023-09-28 09:37:41.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
307	\\xe504c9f27ffe4ec621cc1056c9eea463b05d6c041ddaf3deb1a3498c7754fd7c	2	2932	932	304	306	5	4	2023-09-28 09:37:47.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
308	\\xadfc4971920bf9c4e81342608662fb73ff7b4d59f52fc6378c1096f9e6030222	2	2937	937	305	307	9	4	2023-09-28 09:37:48.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
309	\\x1cb4bcd5aaff10a170bcad425215af242b215c96ce614d0731aa11b768f9aaf3	2	2953	953	306	308	6	4	2023-09-28 09:37:51.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
310	\\x75793b29175242a6658fbd99e0c3794c733e672aa204665725c588cc3f2b747c	2	2973	973	307	309	33	4	2023-09-28 09:37:55.6	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
311	\\xc1814a928bf4902741a47c058a0aff53a3d6fd35903c3c61d37c4db35f364c95	3	3011	11	308	310	5	4	2023-09-28 09:38:03.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
312	\\x0108845230defd7a5422e646c639221651d6cc98f0a0d2b8643f8b4941c6d43a	3	3066	66	309	311	3	4	2023-09-28 09:38:14.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
313	\\x85dee9d05c195a7d1e16bc68d17851cce750fe23980cab0e94a240b23ab8cfd1	3	3069	69	310	312	51	4	2023-09-28 09:38:14.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
314	\\x33d901e6d2eb96216961b78bc360f5d4de26fa2512bba42e9fe81e60343b94b4	3	3076	76	311	313	13	4	2023-09-28 09:38:16.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
315	\\x0622976a51a07e6161ae5e1b40bde3080de4eeee11ccd0427446769576a46394	3	3098	98	312	314	51	4	2023-09-28 09:38:20.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
316	\\xbe142bcacae65eb58a4ee2de26e20cb1e80d8ec4223c7fb46fed6c76c869eaaa	3	3121	121	313	315	33	4	2023-09-28 09:38:25.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
317	\\xadb8c3a57c5910006971d8268e3207a96358af6eb8e283f3426178c011e18676	3	3138	138	314	316	18	4	2023-09-28 09:38:28.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
318	\\xba1ad2776d444579917d003bfe24ebc01c165c867b2a4bd2cf0ccf0e0308a58c	3	3147	147	315	317	3	4	2023-09-28 09:38:30.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
319	\\x946d80867fd29cd206befc270d948d8af0c98007ccf228d63f3feac1e83d2c36	3	3152	152	316	318	5	4	2023-09-28 09:38:31.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
320	\\x82c6469822d1ed9e43c70aaf4ed329d9e8d13cea2cc8d178172123a92d086294	3	3178	178	317	319	7	4	2023-09-28 09:38:36.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
321	\\x861df85ad2934fc1aff869f933e851d43da30833578964ad716ff9a8838240c3	3	3179	179	318	320	5	4	2023-09-28 09:38:36.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
322	\\x3081de20e7b0b09aff1a06756343b95e012452dbc156ee29f0de39370c9b4d9b	3	3206	206	319	321	6	4	2023-09-28 09:38:42.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
323	\\x1a6dac2a653ad4ce79a04948b4ef14b7f9f82f44f6ced2f6f47367ba955a52ed	3	3213	213	320	322	7	4	2023-09-28 09:38:43.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
324	\\xc0ca544f491661565f14da302824a7c112324023034ab4e7b566dbebc4c31e61	3	3215	215	321	323	33	4	2023-09-28 09:38:44	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
325	\\xdbb53b72c0b451bb7fd8d2e1bbdb7f18a077517eccf3be4adb09d2e4b995b826	3	3238	238	322	324	7	4	2023-09-28 09:38:48.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
326	\\x80964f6ac7ccf9cce1d3d4511d57ca922992217d43ccdba06d19a3a9f554ef7e	3	3248	248	323	325	3	4	2023-09-28 09:38:50.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
327	\\x6162bae33d61cfd115d3f4026d89c49cc674eeef2b2d6a7c58c8527979c3ff8d	3	3253	253	324	326	9	4	2023-09-28 09:38:51.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
328	\\x6c4821c919d4b35236feab4916f64eae964e0e0df45e9392b935e5d88b2e233b	3	3256	256	325	327	5	4	2023-09-28 09:38:52.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
330	\\x26f0116f3c5b9a9b59f1021c9e8f5ee387a74ebd6b6f6daec9842de576925fdb	3	3264	264	326	328	51	4	2023-09-28 09:38:53.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
331	\\xa7d0d597bfd1490e86ffc66ef43eb418ae5b371a00010bc94cf6ac15608e17eb	3	3266	266	327	330	18	4	2023-09-28 09:38:54.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
332	\\x08953e4e97350e881dbea78b06e3d0b79b3a25939300b2527a2c7ff47150174f	3	3271	271	328	331	51	4	2023-09-28 09:38:55.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
333	\\x6d878238a8ad43d8ea2a2d206d9f27e9e0601bdcfa14827afcb60786537d3096	3	3272	272	329	332	51	4	2023-09-28 09:38:55.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
335	\\x31e8b6b10af4f62573712afb7e255fb9d6557e66e8d6ffd400234c910b3c8135	3	3278	278	330	333	3	4	2023-09-28 09:38:56.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
336	\\x0a5afd4ec44f3b67f5d57ba56ddb4a38a720d7ec20b5f5e2af5b2f74385ba90a	3	3299	299	331	335	22	4	2023-09-28 09:39:00.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
337	\\x026bfdfce0d2684bc0a7d0e2cfcb2cc88dd363c95c071bc7df23766e34288295	3	3310	310	332	336	51	4	2023-09-28 09:39:03	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
338	\\x297dea1b92ff24a92a866c38c56194df65bc1c9659c6da868cecd417a1c36637	3	3313	313	333	337	6	4	2023-09-28 09:39:03.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
339	\\xa5336502bb237677f965eeaf4f5a3a7cb01e1a57c9b34dcdbb908bd4b72993b7	3	3354	354	334	338	6	4	2023-09-28 09:39:11.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
340	\\x5901af96759b736c0c38c9ae6dbba47bdb861ab7b625d1c175541f0ff9563513	3	3356	356	335	339	9	4	2023-09-28 09:39:12.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
342	\\xea35940b18929d41859bbc30be1b539685779f0a06749a12d8c450d29c575eb2	3	3366	366	336	340	22	4	2023-09-28 09:39:14.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
343	\\xd456f62b7094c7a7ca5edca17e410b5c09d7344ead5206e21de119ae63cf5bc4	3	3397	397	337	342	5	4	2023-09-28 09:39:20.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
344	\\x44e3b5648f9afc2def654ce723dfbe0d53e00819d63b9fa0372dc3bd64d6aff0	3	3409	409	338	343	5	4	2023-09-28 09:39:22.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
345	\\x1d3a48e624cb4dd80842cf415f5dcc5d71656642f48b1ab993165dc779f2d39e	3	3435	435	339	344	6	4	2023-09-28 09:39:28	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
346	\\x8fbc49bc444e41e9899608ffee60aac148c110b17f52e6a8ba791e9ccb88da30	3	3440	440	340	345	18	4	2023-09-28 09:39:29	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
348	\\xa045811286c6fb0c61af0a7982811481c8d3901ebe44abe0ef424e6c61e5489c	3	3451	451	341	346	51	4	2023-09-28 09:39:31.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
349	\\x5eba6ae31bb7da4fabc0bab8b34a6930dfd1eb7896eb1de2b1f04d9d7bcd3365	3	3454	454	342	348	3	4	2023-09-28 09:39:31.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
350	\\xb37e7e1e87c8ea4bde99f5d6a2236f4739f087903cbcace11c4bc1b0d1a4253f	3	3458	458	343	349	7	4	2023-09-28 09:39:32.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
351	\\xdd7f05d9b92ccf0970fed9d9845a4722c2ebf84e602e1f3d57579e52bb3bd570	3	3462	462	344	350	9	4	2023-09-28 09:39:33.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
352	\\xcd130c4efcf41c8d22d0b0ca6e9c727b8d315ae67440162c1a003afa9cb83fd3	3	3482	482	345	351	3	4	2023-09-28 09:39:37.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
353	\\xdc993197c239b25f3ca1daec76e33c62480bac895279f3cfa44f9dc720933d20	3	3484	484	346	352	9	4	2023-09-28 09:39:37.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
354	\\x820f60247249a29840ef98a0117d4d151767dc3b036c33945ffdc6370e3b97ec	3	3490	490	347	353	4	4	2023-09-28 09:39:39	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
355	\\xfe6784568f7ae892abcb112217d165eaf4ff1a3c542ca6ab3507dd536bbf345f	3	3501	501	348	354	7	4	2023-09-28 09:39:41.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
356	\\x025237f140d7aacc982e4648392a5d41dd0e28a809e93b45d0295190a178bd54	3	3517	517	349	355	7	4	2023-09-28 09:39:44.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
357	\\xa6caee3c99a561ed0654bb5f7c6001ed47ed46d04fab0010c5b204396b766631	3	3524	524	350	356	6	4	2023-09-28 09:39:45.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
358	\\xa0d0fc7f4afcaf9f0b865eb5724fe0aa7f2d88e5bdee33912d3af5dfdd8068dd	3	3526	526	351	357	9	4	2023-09-28 09:39:46.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
359	\\x01d80398a249b31c8a83aa909d80182822c851c5e49fa2843c0f72860873547e	3	3547	547	352	358	33	4	2023-09-28 09:39:50.4	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
360	\\xce1790000b07d44e12f99d284520300ca0516c6c0ec05cd6588a12a14be1b4ac	3	3548	548	353	359	13	4	2023-09-28 09:39:50.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
361	\\x7f357d2c6f263966954ef7319a9693b3d29159ddcdd6bfcf4fedea33eb37fc7b	3	3558	558	354	360	22	4	2023-09-28 09:39:52.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
362	\\x0c360e90ad9563883c4ac3cbecafa11f05503bc7ed3729d8edfdc2e8dc9a1c6d	3	3560	560	355	361	13	4	2023-09-28 09:39:53	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
363	\\x8406c70e7ca77081116c7930ce3f4dda57e91c027fe359045ec654553a1c80b3	3	3562	562	356	362	22	4	2023-09-28 09:39:53.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
364	\\x41a1a51f0282937d8d79fe394416f5aa6baeddcd77f042662f5e3a61075520e7	3	3571	571	357	363	51	4	2023-09-28 09:39:55.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
365	\\x4727ab1e9bdb4a1ddfd00c988eaca43ea6069b2cd29aaa8d555c52717580d581	3	3575	575	358	364	51	4	2023-09-28 09:39:56	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
366	\\x4301f457f264bf422de3cb461df9e89e396243ea975237f27d8155d7eb1441d4	3	3580	580	359	365	4	4	2023-09-28 09:39:57	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
367	\\x0eb5a975572c7d462777604ec3d9d3c7b3774c57d357e57b378f01ad8027fe3a	3	3586	586	360	366	18	4	2023-09-28 09:39:58.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
368	\\xa573e070c380f031a80d48061092bcc937883ec03e43a36e3330dae5b7a8ed25	3	3589	589	361	367	22	4	2023-09-28 09:39:58.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
369	\\xfac0b07a84db5a8a313af68bf345a640d7acc6a04640d8a85152e799c3b958da	3	3590	590	362	368	13	4	2023-09-28 09:39:59	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
370	\\x2ad6ed030e08b84ed333247f5c178531df77315051cd403d6d50533a07d757bb	3	3594	594	363	369	5	4	2023-09-28 09:39:59.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
371	\\xa55a6d8116d4235fc7b75f02e7e6363e59bd9f6f25b6aa5f8d8c2f2ec6b679c9	3	3596	596	364	370	33	4	2023-09-28 09:40:00.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
372	\\x3869c13d4edcf2ac837013e3e6aa0f288dc67a5ed4fed7e42ae4f2ac51ac28ee	3	3601	601	365	371	33	4	2023-09-28 09:40:01.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
373	\\xaaecb922321fd13f6503dd7db4263709a42f983ede8f5521a392b1202e7387bb	3	3602	602	366	372	7	4	2023-09-28 09:40:01.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
374	\\x8123b5c847618f2606ee860ab327ee5ffe2f4aad78282423176397fbf707cb92	3	3656	656	367	373	7	4	2023-09-28 09:40:12.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
375	\\x3a94e57cf88c200628dba252b51b793b8ec75a15eb82c8504ee5f2eff8e18908	3	3679	679	368	374	51	4	2023-09-28 09:40:16.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
376	\\x6574206fdfaf6674e09f0bdd5d994f128c6083f51cab7d3018b3077615ec9260	3	3683	683	369	375	9	4	2023-09-28 09:40:17.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
377	\\x445d0766c9ea292277ca2353ed0117f14d4ee5f47b225a8a55df015b286c0ab0	3	3697	697	370	376	4	4	2023-09-28 09:40:20.4	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
378	\\xa98896c527fae02590d43fae2a69453a48e7439e51335a1f01f20bd6c9a06cc9	3	3702	702	371	377	3	4	2023-09-28 09:40:21.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
379	\\xf059572daf746a08f19e3513632156feff25a53691d983d4fa07fa1580f413a7	3	3726	726	372	378	7	4	2023-09-28 09:40:26.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
380	\\x871a783b89d29338d19891d3ef20d5ada88ad84d256041d86924febde9cdb27d	3	3730	730	373	379	7	4	2023-09-28 09:40:27	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
381	\\x31aa8d8d5a5cbd1b993a9854e7b13a44e1230f0b7525fc0d692f403e236e6e31	3	3732	732	374	380	18	4	2023-09-28 09:40:27.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
382	\\xab4307ba8606a9a5a0c465ab3e9a05b977d6149411c4e41d8ea042f2b22cb162	3	3735	735	375	381	6	4	2023-09-28 09:40:28	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
383	\\xdf28a6e83a367f0a73961a919498f9862d4b6fc4690828de95388f3256ec9c12	3	3737	737	376	382	7	4	2023-09-28 09:40:28.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
384	\\x6130868d20db376dec9b77f562cdbda0d1668f0cd1073b5ab9f447b6eb40255c	3	3744	744	377	383	6	4	2023-09-28 09:40:29.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
385	\\x555f1742586e186ab6308a8f17c477e7e616296150a61e82499158c5a5bb5232	3	3745	745	378	384	9	4	2023-09-28 09:40:30	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
386	\\xaa2f541be1a1f20a75b770b9a677c32f712ce9db2a1de4c4bc1f10a9e50df49d	3	3749	749	379	385	18	4	2023-09-28 09:40:30.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
387	\\x573735e11ec6770bbc49c352ff277953e73cb24acbda8961556692d7fb2dea67	3	3759	759	380	386	9	4	2023-09-28 09:40:32.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
388	\\xd317bc3bb1cfdccc6c67d85371b4317044b944f05aa7cd4b8947497e85ba3ea4	3	3776	776	381	387	13	4	2023-09-28 09:40:36.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
389	\\xb81a43faa23e529e357424c4d65918f2a606932120a049c52fa4459529d81aee	3	3801	801	382	388	22	4	2023-09-28 09:40:41.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
390	\\xaf789f5e38684a2273086bf4b1a55f2a71308711217e8516fc17ba6b8d01e834	3	3813	813	383	389	5	4	2023-09-28 09:40:43.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
391	\\x0aa9017108ed1f4b0f6dc419011e61ddc3b38ec9294cd6ca27e72bcc194a9eaa	3	3818	818	384	390	18	4	2023-09-28 09:40:44.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
392	\\xc84dab759747d531bdcc6e1a8422bb6e11b4e7318a5bc478dac7631f2fe04650	3	3826	826	385	391	6	4	2023-09-28 09:40:46.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
393	\\xa389fe5b2713e78684f8c520e97578cd3e8631be15988f13c52c0e63ed122f1d	3	3838	838	386	392	18	4	2023-09-28 09:40:48.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
394	\\x1fe4d79e71dae71a4174ec432303f6ebe9b021866ffbeb6a8f32cf0b7b95778e	3	3842	842	387	393	51	4	2023-09-28 09:40:49.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
395	\\x81558e3929842239dadb8dca8883e4ef0b74f66788f6da59a4da33c5476ca2d9	3	3843	843	388	394	51	4	2023-09-28 09:40:49.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
396	\\xa4c93e34e652f1af33220540cb7a4f98fbbb75dee2d872366afc78450dd052a9	3	3845	845	389	395	51	4	2023-09-28 09:40:50	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
397	\\x910010a5a141af6786634681dba815c0fc1d9cc116bf1278824f7ff8c8c66189	3	3854	854	390	396	6	4	2023-09-28 09:40:51.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
398	\\x0b4acb95f306357e03a6a3240239d26cb61e8ea2513f069562cfc208c957ffc2	3	3869	869	391	397	9	4	2023-09-28 09:40:54.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
400	\\x952267e6876bb0939aea24439cb76795691ae34496be366ea1e467a47fbf05bb	3	3882	882	392	398	13	4	2023-09-28 09:40:57.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
401	\\x47dd2220ec433ff237656f96cf04a1a0808e42feace093b315269871d69de97e	3	3887	887	393	400	33	4	2023-09-28 09:40:58.4	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
402	\\xe819ae0c82fe494b4d576304924e7438b4844c2a458b89d4a8f02207f55d63a8	3	3921	921	394	401	18	4	2023-09-28 09:41:05.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
403	\\x2ea189855be13ba26b0ca12f00176351120fe5a4516c92e96cde9da4cefb3468	3	3928	928	395	402	6	4	2023-09-28 09:41:06.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
404	\\x9bf857254a7055747640d665295955a00e2cdfe343f9ef72005687ce711ab894	3	3951	951	396	403	22	4	2023-09-28 09:41:11.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
406	\\x7eb029eb0463beeaa91d0ded49b186e5614d39a10652cc227c4cd3b91d670397	3	3957	957	397	404	33	4	2023-09-28 09:41:12.4	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
407	\\xbd6583bc27e9b048faa63c747eadf7d0a82a836e2b2878a1fdbf59824354256b	3	3964	964	398	406	22	4	2023-09-28 09:41:13.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
408	\\xaa3a3c49dccfe4aae96ac87f182cd602b014bf3f065f78b081011c233f0e9ca9	3	3969	969	399	407	51	4	2023-09-28 09:41:14.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
409	\\x5047e2218af2e1d00d24a1b240c52a8f0eca03c475a797bf0293201075f8b99d	3	3970	970	400	408	18	4	2023-09-28 09:41:15	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
410	\\x3d637595c74235ddb608a3aaecce27e1d0af4858390975aef2357ad8412da91b	3	3987	987	401	409	6	4	2023-09-28 09:41:18.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
411	\\x50a3c06b0261c2cc0c78cef7b9707fb66ff247e1bec93218ea1d81172edc80ac	3	3995	995	402	410	5	4	2023-09-28 09:41:20	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
412	\\x6000bf749f93d751104a9052ec8940553e8d4559e4d5d07e826b1d267c3bf847	4	4009	9	403	411	51	4	2023-09-28 09:41:22.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
413	\\x51a2af92442236c2969140ebcaae79799749dc139c3f397035a74fbb85756620	4	4011	11	404	412	18	4	2023-09-28 09:41:23.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
414	\\x8b32add9c49917fe861cba1295666ae7b8fe798eb847bd8dfc6818968cf622a2	4	4013	13	405	413	3	4	2023-09-28 09:41:23.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
415	\\x60207f718eb7dfc2a94f7611fdfdb8fb17c4fa4f77b63f68c35513dd1722f8a2	4	4014	14	406	414	18	4	2023-09-28 09:41:23.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
416	\\xf71ce6ac557c2041f032bd9e55ed3c44cea3cda7b90e7ce3ea1290a924c0de61	4	4026	26	407	415	51	4	2023-09-28 09:41:26.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
417	\\xa3aef3dee78fc3a748c0648c980889bf6f4abb1a060e820ca181006d226ab6ad	4	4039	39	408	416	18	4	2023-09-28 09:41:28.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
418	\\x1489dd5dc900d7543a9a4fd63f3a29782642e22a3bc40689e7efff9d2f1e0904	4	4051	51	409	417	4	4	2023-09-28 09:41:31.2	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
419	\\xa2242da5940e6413f30c71a7901b2b8204d8d790b0503d4da9778a969b5f43e4	4	4058	58	410	418	3	4	2023-09-28 09:41:32.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
420	\\x55b76b0c5d2366cfa4eca6a246fa2e773b461a6ff7d66da7e89ad10a7424025b	4	4075	75	411	419	6	4	2023-09-28 09:41:36	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
421	\\x8be30b7d35a1e84ba9b5f00b45e217c31ebe3d9c30cedd8727dab9e5a9148d6c	4	4091	91	412	420	9	4	2023-09-28 09:41:39.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
422	\\x05e2217eefde0ba3661f2317bd497bf0af6a71077cff998fd83965d9837e5953	4	4097	97	413	421	33	4	2023-09-28 09:41:40.4	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
423	\\x7082f38b8bada8548ad9b0408d63d8de2e978b00d12fc7998838df93a3417853	4	4108	108	414	422	6	4	2023-09-28 09:41:42.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
424	\\xabb61f43052c73f32144604e70e7c05ac2caee2820ceddfe1a12fd425798a62a	4	4109	109	415	423	5	4	2023-09-28 09:41:42.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
425	\\x5a606203671677b143203a899ddd8862a3f5a0765d8afdb7ead493b79a81f91e	4	4151	151	416	424	5	1704	2023-09-28 09:41:51.2	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
426	\\x3047a3a85a20eaad86008b687fd56f8655de35d6a554525ab2451ba6891d3899	4	4153	153	417	425	18	4	2023-09-28 09:41:51.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
427	\\x8742b6d816536327702ace677e3247bf440e87615714ec946d14a3fa0c2720f4	4	4188	188	418	426	13	4	2023-09-28 09:41:58.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
428	\\x2b37aabc3305038e6539d44069c7be6610217033a9955cd85c6c70f0e369023d	4	4189	189	419	427	33	4	2023-09-28 09:41:58.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
429	\\x360cc402bea90d95ddc2e81619320850bcc09fbf0d4525ff25a2e6c3156d0a5e	4	4205	205	420	428	9	430	2023-09-28 09:42:02	1	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
430	\\x7a8ddaf14aad048e57fe4e3697748931f4918195d8aa91147b96343129e96545	4	4211	211	421	429	6	4	2023-09-28 09:42:03.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
431	\\x0d14051f86f0cd8076cb529104938ddcb7fdefe3ed469a91b0eae613f2a92dd6	4	4215	215	422	430	7	4	2023-09-28 09:42:04	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
432	\\x2b14d3bd10159dc94dad5609e2b90561bcf012c291fe5608cfb99999d5c7af7e	4	4222	222	423	431	33	4	2023-09-28 09:42:05.4	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
433	\\x1df231f38d2bfbe54d48605d9e88de6304b4ed9bd7b87df416fcc30b2251e902	4	4230	230	424	432	6	352	2023-09-28 09:42:07	1	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
434	\\xc19dc4b657821518e336f59f5776b69f1617a8e0c8cc4feb9b59004438df1662	4	4246	246	425	433	7	4	2023-09-28 09:42:10.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
435	\\x00e39f0c3762ffaf75e0651334493ae2403b410ec93cd24820e1c8537da80164	4	4267	267	426	434	22	4	2023-09-28 09:42:14.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
436	\\xbf79c5eb415d0eed29a298e782b634e96b366af88a001e6d5e73fd271801760c	4	4269	269	427	435	51	4	2023-09-28 09:42:14.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
437	\\xadcbd8ffa7b163b3dcc22cc87c87b20fc220cc9fad3fb0b2abce5569e784051a	4	4275	275	428	436	5	321	2023-09-28 09:42:16	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
438	\\x92d3a808e27070336d02b72819450b1cc33524726ebb08a774857d6df928e020	4	4278	278	429	437	13	4	2023-09-28 09:42:16.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
439	\\x37594441a8fd53cd9955a59a80001ee43ea71fb27ccb934d06e71de607396b91	4	4287	287	430	438	22	4	2023-09-28 09:42:18.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
440	\\x69250cdbc8d6e00c286d1651825bfc3b8aef8d8dceb7068d703dfc1965364cec	4	4296	296	431	439	33	4	2023-09-28 09:42:20.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
441	\\x4b15fa842f2a31b16e5dbb6df596fb1c2c7d6d906877ce66ed9b95fff56bd3d9	4	4315	315	432	440	4	401	2023-09-28 09:42:24	1	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
442	\\x4a311621eba1ba558124f488ed69482e0e5954ebc918dcd21bf332a11cb68e7d	4	4320	320	433	441	5	4	2023-09-28 09:42:25	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
443	\\x05a1453436f5584dc0f9275835de2012b764f40f4dd41c06639351758e836361	4	4336	336	434	442	3	4	2023-09-28 09:42:28.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
444	\\xbd82efa757ea15cae38bd32001b08e11279cddd3cbefc7230c64469a9c715a66	4	4337	337	435	443	7	4	2023-09-28 09:42:28.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
445	\\x47e2741c516fa8d75db949d8216d61291240a3261d84ff9e2cc362040c59fb08	4	4348	348	436	444	7	749	2023-09-28 09:42:30.6	1	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
446	\\x3e66ea19f2acb7f880881f765db7753640de081656bd66fad0efd1fd36edcf48	4	4349	349	437	445	7	4	2023-09-28 09:42:30.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
447	\\x044319cd82f51bb45d8298e0e51e1dfe7eee1b29ff5cf2d5759f763bd0db79a8	4	4350	350	438	446	51	4	2023-09-28 09:42:31	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
448	\\xe658fd7fc6ac5f20a7936371d8537fa2c4a501235a0856e1457446b015f8e60e	4	4380	380	439	447	3	4	2023-09-28 09:42:37	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
449	\\xe51584d1e64e6d9c950938344877d338d21dab40255848c5af5638160b406a79	4	4385	385	440	448	33	827	2023-09-28 09:42:38	1	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
450	\\xdfdf4e6df0345018ee0aec34b3cda40600aaef40a0e8e0ec56b6f7fc7695a7bb	4	4386	386	441	449	7	4	2023-09-28 09:42:38.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
451	\\x8dcf3b5bcf10904e16d8e5e47ff971091469cd2b7ff66e97b47eaf50f9d7026f	4	4391	391	442	450	5	4	2023-09-28 09:42:39.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
452	\\x6aaf18ab5d6ecd25ecef10d2a0888bef7b62302581b919707831c7664e4f8369	4	4405	405	443	451	9	4	2023-09-28 09:42:42	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
453	\\xd9232f759fb4a2edd5c7dc42126c9c4d9e4d3b4f3971f3d7cbe7907fee7d153b	4	4420	420	444	452	51	340	2023-09-28 09:42:45	1	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
454	\\xab9cf8cf675c5d035c861fef4e163a448b827b0f6d9f36eace80608adaa8cad6	4	4422	422	445	453	3	4	2023-09-28 09:42:45.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
455	\\x8ac0ae0dc4b1838dd3ca9b9759a0c362c03b2e573a3014aa2f999a03c20be20b	4	4429	429	446	454	33	4	2023-09-28 09:42:46.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
456	\\xe24a93472a79a4b06be0ca1167f46b004ee1917f4ad76679cc61007a789e4638	4	4430	430	447	455	18	4	2023-09-28 09:42:47	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
457	\\x20eb8473ca1796a0c4251dfc5a8143d0a6f9c8f25c53eca47738f5ee3e722476	4	4435	435	448	456	33	749	2023-09-28 09:42:48	1	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
458	\\x8f52d5eb0f6d62dd5793d00789c66db8c76f2091d0f8531be9aad7fdef837954	4	4437	437	449	457	9	4	2023-09-28 09:42:48.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
459	\\x36d7767cb9ab529aca966a4195fdfabb5f76c3f62385443f5138afe45e75aa14	4	4438	438	450	458	3	4	2023-09-28 09:42:48.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
460	\\x1f7e5cc27f3fcca6c77afcd267e75359592cbfb1eadd9b6805af267c85913911	4	4442	442	451	459	18	4	2023-09-28 09:42:49.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
461	\\x2bf1c86dc0e2b9687e1f240fbf76734ccabe851f836dbe415808a05f2f7cd1bb	4	4451	451	452	460	5	300	2023-09-28 09:42:51.2	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
462	\\xdedb66c7c43bee3b0b9b1c6b0a9d13e2641328158059ed9580b3606852aef611	4	4454	454	453	461	7	4	2023-09-28 09:42:51.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
463	\\xdaf7a7f08efd2092688277c1f0d13caf19eb79338b19bec57806cf0375506ddc	4	4495	495	454	462	7	4	2023-09-28 09:43:00	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
464	\\x2a7dba08e9d727143595915ebfe26096091e67fb464a226ffa6cb55044b325fa	4	4511	511	455	463	13	4	2023-09-28 09:43:03.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
465	\\xa8545bdb5893cee42fa92e2258ef3d012e49730ac0ef48b1db0a6029f6bc2d27	4	4516	516	456	464	4	749	2023-09-28 09:43:04.2	1	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
466	\\x4dbcc3f98fb352ab797b7f6444e512669ffab2c1affebdae32f3e02727df5ca0	4	4520	520	457	465	33	4	2023-09-28 09:43:05	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
467	\\x478268ab42db2698dacf8785123324141931928e273f8550b7be05ca2895723b	4	4523	523	458	466	4	4	2023-09-28 09:43:05.6	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
468	\\x523f01b6abbac9fb21619f917cc2c4341cf85438b35e76f82e986cdca835ed8e	4	4535	535	459	467	13	4	2023-09-28 09:43:08	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
469	\\x089949544060895adf2696b511929b9e6849334f07faf0a32ccbb80005a6098c	4	4540	540	460	468	4	342	2023-09-28 09:43:09	1	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
470	\\xc0cf8bae4ef007103649216f2f839f9ed8e652c9f7cbcf93239840f8e8e8a9f3	4	4573	573	461	469	33	4	2023-09-28 09:43:15.6	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
471	\\xf243e28f79157d1309603496988a038184d6ef6f35ff8411e9deb6ac8d880f8d	4	4575	575	462	470	51	4	2023-09-28 09:43:16	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
472	\\x7d3f09dc1d20843de4d7b07013a44072f8a362e044af6393dbe636b34c90c924	4	4576	576	463	471	3	4	2023-09-28 09:43:16.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
473	\\x835e6d5708920de86f4b8055158c500cb1fe2b81eba6ad023439f2c9a9a0b1e2	4	4584	584	464	472	18	300	2023-09-28 09:43:17.8	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
474	\\x45c4c09d4978a86ca2281feaf4b5dd94269b0f7e8d6b7a8f8831b18b1211a403	4	4588	588	465	473	33	4	2023-09-28 09:43:18.6	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
475	\\x0d6de23e1e621fe7830483ae2beb6a6e3529f56b6fe9edf6090879a19fd10080	4	4597	597	466	474	4	4	2023-09-28 09:43:20.4	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
476	\\xebc74865fbc682e4c7f460450a713416ea5a9f274ce79f344e0f1c364d1c2d0b	4	4607	607	467	475	51	4	2023-09-28 09:43:22.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
477	\\x0a1e4700de9423fa4620b15708a0a2789e4eeb16e9aaaf9d4e02f7d83bc58e28	4	4608	608	468	476	7	4	2023-09-28 09:43:22.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
478	\\xf91b77403ef07e93656c12def7ea0fafaac104d67d1a643797bc916350bdd491	4	4613	613	469	477	3	1104	2023-09-28 09:43:23.6	1	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
479	\\x8a785cc6efe8e8b3da6dc4cb91208c7ab6a801dffccf300b5f9a98d82c40c2cf	4	4614	614	470	478	33	4	2023-09-28 09:43:23.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
480	\\x43b936dd4f123b9319559bc3f8619d0ef0ceaf0de598329088e210a3d9a74500	4	4626	626	471	479	5	4	2023-09-28 09:43:26.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
481	\\x931fb84d32280f3a40b8a5e93e9c9f5290fe1f83eaee8ed1c691b32a9cba0a74	4	4633	633	472	480	13	4	2023-09-28 09:43:27.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
482	\\x08bb51c222e3cd5054057c40da4832f44a48d4fb49b8271bf1d8c53123a1e17c	4	4637	637	473	481	3	558	2023-09-28 09:43:28.4	1	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
483	\\xcadcf194d5f98c83d473bbce4916377efe8a7b3a7141ddc53656b06e1f6e63c1	4	4649	649	474	482	7	4	2023-09-28 09:43:30.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
484	\\x2595ac63ffa08b2863f0bc1c0134b23c7a422308306090294c256487ccc46fdc	4	4654	654	475	483	3	4	2023-09-28 09:43:31.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
485	\\x86a66c455a8f8414d6448107bc3a2448ff40b0df82bbc45961ac89416cf470eb	4	4657	657	476	484	13	4	2023-09-28 09:43:32.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
486	\\xa9e78ca717445c667a69d5529ea905681d1fc6bcc13cf9b6b356ec8a60274ac0	4	4671	671	477	485	5	722	2023-09-28 09:43:35.2	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
487	\\x64fb55ffc94f8c369fe9b3515afe36701ec83b0c1c0d8f706e91a088ea9459c8	4	4683	683	478	486	3	4	2023-09-28 09:43:37.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
489	\\x32f34167d0ece141d8cf2c0cc917b466739d413264e45377facf0274af72af81	4	4709	709	479	487	4	4	2023-09-28 09:43:42.8	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
490	\\x2aa5d77a9afd524613c7c13e81fa75693fcef759dccfcad61b83e2fadfa188e9	4	4710	710	480	489	5	4	2023-09-28 09:43:43	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
491	\\x0714022b9e9e5a658c3f77dfc27170fb3ef56718020465ec08d84fe410a6e199	4	4716	716	481	490	22	792	2023-09-28 09:43:44.2	1	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
492	\\xbb30ef52ff2dbf069616d52bc1e24f399747abd88ef7984deefcc9fb6095a690	4	4719	719	482	491	22	4	2023-09-28 09:43:44.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
493	\\xde821da6eabebf2e2b146231a2040ae455faec88719794260529de7202bc2c29	4	4728	728	483	492	22	4	2023-09-28 09:43:46.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
494	\\x7d2ce037802d8024e151fe14b7321e4c397d9d50d05700615ea93f09b54de9fb	4	4731	731	484	493	9	4	2023-09-28 09:43:47.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
495	\\x6db3e94bf5acc96365596a181406b9fd2bf7d73149c2cdadd82ebdfe9cc58beb	4	4733	733	485	494	51	662	2023-09-28 09:43:47.6	1	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
496	\\xf8fb277132c5ab6c05e6ba15efe3e322961ad3817b9b3dd46c6ca3a63a638c4a	4	4737	737	486	495	3	4	2023-09-28 09:43:48.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
497	\\x85520795dd65ba6618aa9325701b584215681fbfb9cd4ca359344de2a1e7a74a	4	4749	749	487	496	5	4	2023-09-28 09:43:50.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
498	\\x7ff54668b7cf6a41c0106a7c0494433644ea48832f57baf127880dd259e2643f	4	4769	769	488	497	6	4	2023-09-28 09:43:54.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
499	\\x69396b520ee34025edce7d9a6e3212a176a89af94a9ae86f8b7877f8f2cc054d	4	4781	781	489	498	9	571	2023-09-28 09:43:57.2	1	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
500	\\xbdf054f5a677e827cc2a2b2f12e0a921d05994a88a35f9d8565994345c963198	4	4801	801	490	499	5	4	2023-09-28 09:44:01.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
501	\\x5704109744d513b995fb6450196d190acfb33efe52a403359dc63a49a95075e2	4	4806	806	491	500	18	4	2023-09-28 09:44:02.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
502	\\xe86baa598f4ac70359da3ae73bc654a6187e0feaa86208a0415c906b40de4e09	4	4831	831	492	501	22	4	2023-09-28 09:44:07.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
503	\\x8ade71a5acbecd9ce21e165b1df149c8766131623b3d1b4336c6f0899b171ddb	4	4840	840	493	502	13	329	2023-09-28 09:44:09	1	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
504	\\x9d36578c271e6ab8b7725c607a4d5ea2e6125b8e2e91de89ac55fda6681f23a7	4	4851	851	494	503	9	4	2023-09-28 09:44:11.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
505	\\x195d86e4defde0fbb2080536dd401dd16292d0ec747363750d35d081e6273cef	4	4852	852	495	504	33	4	2023-09-28 09:44:11.4	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
506	\\xe02e6a07e9d349f35cd7a3ddeba2ba54efbc4eb9f894836c99c3a2104e27bdaa	4	4864	864	496	505	51	4	2023-09-28 09:44:13.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
507	\\x72a9f0acb28197d2ac445e736b26f9619ae354947e3984e8296b05d3f474f1fd	4	4866	866	497	506	5	3850	2023-09-28 09:44:14.2	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
508	\\x7a805828fc7dbd8e3ba823182025791f87c03f962064bfa3213f032baed8e10e	4	4871	871	498	507	3	4	2023-09-28 09:44:15.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
509	\\x1897b9bf62393b809119f58e3f84e85c200c0221f69043bbdc7d7bd393adca32	4	4872	872	499	508	51	4	2023-09-28 09:44:15.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
510	\\x9300ab317c8aaaddfc41193bd89c41a2bc2d5f308f20f42a4983bbd06f4ab272	4	4902	902	500	509	51	4	2023-09-28 09:44:21.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
511	\\x1f5c97c8776073437afb4dd9c0dfe7de0048e60a353e34d31d36d1d31550fd02	4	4916	916	501	510	33	2398	2023-09-28 09:44:24.2	1	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
512	\\xbbd001b3df5bfa33f62478390be0f371b973b983810a6947951b3126b1ff848b	4	4919	919	502	511	9	4	2023-09-28 09:44:24.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
513	\\xb575bb95b2bd4974f9b1525db1dbf5a92c62613683344f3d1c0f9722f93b5551	4	4938	938	503	512	6	4	2023-09-28 09:44:28.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
514	\\xe016925b9144cc8c14fd963c8d62fecdb2e429dd6af094560c756872c84adf94	4	4948	948	504	513	51	4	2023-09-28 09:44:30.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
515	\\x5cc9a9115366764bb5b58fa4a371d7a7579e14f6b751c6c1057ed6e8f6456b25	4	4955	955	505	514	4	1051	2023-09-28 09:44:32	1	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
516	\\x0b68de1ca44c38524892179ff8d1ac27794f7be311c8a5e6316e9033e63698de	4	4964	964	506	515	33	4	2023-09-28 09:44:33.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
517	\\xe7c09c587c3494e07f0cc406276aaa6c5a0604a3c9f432c96f7cfa4d67787c60	4	4981	981	507	516	33	4	2023-09-28 09:44:37.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
518	\\xc3429f00064242f0772f18b09d12200c41c43641566928f599af56bd75ff9342	5	5006	6	508	517	51	4	2023-09-28 09:44:42.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
519	\\x42a9116d8a6feaa72dfec82cf1465aebe783ec58248c6f8cfa3528e52dbdf9bd	5	5019	19	509	518	51	644	2023-09-28 09:44:44.8	1	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
520	\\xccfcdc2a58254408c93fdcf362e27036049ed9270ebfa62b34c25886360fe20c	5	5030	30	510	519	13	4	2023-09-28 09:44:47	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
521	\\x62875aef2ae89b4cca4c26f559cbc7f91add3094abf85e4a652e76aa6209e4fa	5	5036	36	511	520	7	4	2023-09-28 09:44:48.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
522	\\x1db1006cb125fe303b1f6a7fe5abda85067deb90002c8d9368410934cb0cd80e	5	5046	46	512	521	3	4	2023-09-28 09:44:50.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
523	\\x3c927a370c8764a7fad0cda5890d7483489b02df646a6b5dfd5e42b14604cfea	5	5062	62	513	522	18	535	2023-09-28 09:44:53.4	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
524	\\x1935e9fbf52b40c4b598fe328b9e11bd887c5ce2360ac6053ce7de2b8df9fe29	5	5071	71	514	523	3	4	2023-09-28 09:44:55.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
525	\\x58b4fe37536439ce9e4319845015f842c916032db70a0ca76e6a7ae4c35517ea	5	5074	74	515	524	5	4	2023-09-28 09:44:55.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
526	\\x98e5bdb79aa9b835f9831c6fd3cdd7c7c74dc6dc813aaefd4a236b03e1d6e367	5	5077	77	516	525	4	4	2023-09-28 09:44:56.4	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
528	\\xf157f2abc9a614c54dc8872bc40741bed77be2fc0176bdedb1b59afa9e285265	5	5123	123	517	526	4	497	2023-09-28 09:45:05.6	1	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
529	\\x16efc5151a98cc61084d4cb58b9110bd487dd731858366d1c43c64029ac1e4e0	5	5153	153	518	528	22	4	2023-09-28 09:45:11.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
530	\\x72d405030cc96f80da7b228b3b4a276a76dd6e82607e176d4d64cef9db285cdf	5	5165	165	519	529	7	4	2023-09-28 09:45:14	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
531	\\x3538663df722d65e957bdd3a53338b7605f90b4bacdd9e66798b030236e5d6b2	5	5188	188	520	530	13	4	2023-09-28 09:45:18.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
532	\\x2f35e5c7a6e7b7fbf6ef57272a62657eec2e656e654ac60e85c14fad8f4d5e50	5	5193	193	521	531	7	397	2023-09-28 09:45:19.6	1	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
533	\\xd5aafe2e766d0e30ea8e47608ffe413f62e88dc3b50345b22aca845867db08bc	5	5203	203	522	532	6	4	2023-09-28 09:45:21.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
534	\\x62dbcfd01c467a4eb601b17914b99433224a88e1e24d7c4b6cbb278e74571d9a	5	5204	204	523	533	9	4	2023-09-28 09:45:21.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
535	\\xf3c59070ae9330d21d584bb92de47e9e0f1f30b623741303e933d147aaa99eeb	5	5211	211	524	534	3	4	2023-09-28 09:45:23.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
536	\\x92926dcd7f9dd61f833b95244362283e884dbc7674b2ee8aad7ea9fe44fc7e99	5	5229	229	525	535	3	289	2023-09-28 09:45:26.8	1	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
537	\\xd4c8b466b8fedb25b0f13614ed7a5ba9cbfe22d2d92593692873b434fb6b78ba	5	5230	230	526	536	7	4	2023-09-28 09:45:27	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
538	\\xd00cc9100980496d3eda58e0f3c6f3babf15e34a60e9e3d0a4a4a715bab2bb4b	5	5239	239	527	537	18	437	2023-09-28 09:45:28.8	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
539	\\x9b286577b4f854a936027e4dab97948b992682cfbca6c9f6e7bccf3238760532	5	5247	247	528	538	22	4	2023-09-28 09:45:30.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
540	\\x46f77060c3bf979eecaee4f23787e8dd72bf49527c8917820227fd9bee342ad4	5	5262	262	529	539	5	8236	2023-09-28 09:45:33.4	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
541	\\xb1bb5ffd40533b877c02d42e0ef13cbd134cc48fed6e57a8eecf1362368d752e	5	5264	264	530	540	13	4	2023-09-28 09:45:33.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
542	\\x443ec4c17eb31aabe39abc8c3e06ea28bcc1a0e5355581a4397b1831a03eb609	5	5267	267	531	541	3	4	2023-09-28 09:45:34.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
543	\\xedc81dc2c6eead79e76bb5089c4216310526a200be43644f2e076cc824355616	5	5274	274	532	542	33	8410	2023-09-28 09:45:35.8	1	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
544	\\xc3c3ef16b6c328dac102a11539fb9f4f8612298910c405dcaeb2794661ce1698	5	5275	275	533	543	33	4	2023-09-28 09:45:36	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
546	\\xf267214991f21a53eab927b6dc05bc9817c5fe38d104ff84256c24d6184e451a	5	5293	293	534	544	3	2847	2023-09-28 09:45:39.6	2	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
547	\\x2a9811893dc587e74cfff401adf541454ca04ed72899f59a06e56d07b1a6e619	5	5301	301	535	546	33	4	2023-09-28 09:45:41.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
548	\\xe7cbd70edd5f73db1c97fc8025e96c3173bdcebbaa85e7f79adeddbb6a55beff	5	5309	309	536	547	9	4	2023-09-28 09:45:42.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
549	\\xb3e919d0cf7244e03cd3096ee65ceef4eaab92b42886ce85a0e23efa60d554e2	5	5349	349	537	548	22	4	2023-09-28 09:45:50.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
550	\\xb08bebc009dfd232207b4be8c3d72f456aa86447bdb4cc4e50f71d50fc524240	5	5371	371	538	549	22	337	2023-09-28 09:45:55.2	1	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
551	\\x4db11cf069c0e95f5158ce8be327259013ef82e60f08deccead165006bd3d9cc	5	5372	372	539	550	3	4	2023-09-28 09:45:55.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
552	\\x8faae0889711e02fae452c523cc0d606c180ef5368d99c370718a5672c9eefd1	5	5376	376	540	551	6	4	2023-09-28 09:45:56.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
553	\\x003db16b2b0b9580e48a710111a0f96dee1c5f695ccf92b7dee01d5146feaf51	5	5380	380	541	552	6	4	2023-09-28 09:45:57	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
554	\\x34db0cf1fa19d520f0ed598cf96dd7f4339a1233a2b23ecb66c875ddc41399c7	5	5407	407	542	553	33	612	2023-09-28 09:46:02.4	1	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
555	\\x1d6e8c477842d19548642aba3f5388b4e6eb7f64c7e9d95048a2f596fd680e96	5	5411	411	543	554	4	401	2023-09-28 09:46:03.2	1	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
556	\\xea593d0ecc42e7797c72fca461be516427622eb9688e01f44a5d131071d75cd8	5	5446	446	544	555	3	293	2023-09-28 09:46:10.2	1	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
557	\\x2f7145afc8262bc7dcabdba107935a2bf6b1c34576db00c0995d2ac7c20edf75	5	5451	451	545	556	13	2367	2023-09-28 09:46:11.2	1	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
558	\\xdb51a9692400669aec9cb7169bcdbd54e0c2e21aac252554e29269e9ad8ce5de	5	5456	456	546	557	4	4	2023-09-28 09:46:12.2	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
559	\\x1fc35eff7f8e1de9e5decd06b3ddad01bc7167a6019c0b10aa3d08173bd19b60	5	5463	463	547	558	4	284	2023-09-28 09:46:13.6	1	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
560	\\xe4e8470c46771d166954240673f7d8907faed6202ef36bb28c76d3cd521ecc22	5	5464	464	548	559	6	4	2023-09-28 09:46:13.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
561	\\xc649058de867291218e226cb9c68ad2feed7721a185efa36845cd91285928e58	5	5482	482	549	560	9	4	2023-09-28 09:46:17.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
562	\\x3172eafe793352efda513f43546c5220ee958d93d9f005abb5eba7c73f104274	5	5508	508	550	561	5	293	2023-09-28 09:46:22.6	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
563	\\x76b6f8cac04014aa0e1c4684bdc338406daeb4dce0fef39be47e5d2b0028833f	5	5520	520	551	562	5	4	2023-09-28 09:46:25	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
564	\\x74238a8493347962945e4bfd3287fffc4e70e80a1c951f65304bb5af81b86edb	5	5539	539	552	563	9	4	2023-09-28 09:46:28.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
565	\\x4692cdc60eb8c0a592c3e52fd3e5f1cfbfe9fd2f3a4c2f412db3777ec9284a90	5	5543	543	553	564	22	4	2023-09-28 09:46:29.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
566	\\xf273ea672cccd080f1f0cb416ef1d134f0624dd0dcf181757307be3bcde43a7e	5	5546	546	554	565	5	4	2023-09-28 09:46:30.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
567	\\x47cee5a96f05f162c0e4d082ed334760d3fd58830f2190d0d8d047bc4e1d7bb2	5	5563	563	555	566	51	567	2023-09-28 09:46:33.6	1	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
568	\\x546298d493d427dbb25891882dddbbc618184ab2b89ae40e7df50d56660c176e	5	5568	568	556	567	9	4	2023-09-28 09:46:34.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
569	\\xcd7a545da25350924994efea544f839f0d60616b0c1ffc2f0f04bc4b1913b2a1	5	5581	581	557	568	13	4	2023-09-28 09:46:37.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
570	\\x589be101562c2881b71af1faada26b7fd6785efc121d32a4eb7639372c21dea1	5	5589	589	558	569	33	4	2023-09-28 09:46:38.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
571	\\xb86a0b05d56f74acd27f0cc02f9ccd99058b6ebc61b6e285ae6da8a5e45ffc5a	5	5593	593	559	570	51	4	2023-09-28 09:46:39.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
572	\\xd9234cf814cf019796c812fbde9a7040b21f1bfc660eb6979056488fce62dce0	5	5609	609	560	571	6	4	2023-09-28 09:46:42.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
573	\\x7835505c67be3d3e2abdd11b79b5cbaa41b999cce36b8d286d775da22b66042a	5	5623	623	561	572	5	4	2023-09-28 09:46:45.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
574	\\x029e245d6d8da6c28b79f88a20556392034b6ed2189704b34506ccde477802ec	5	5632	632	562	573	7	4	2023-09-28 09:46:47.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
575	\\x9c394a6cc1ace5659ad182421ec0612303b2839373e001536d647235881a16b0	5	5647	647	563	574	3	4	2023-09-28 09:46:50.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
576	\\xa9ca144ebb99f4545695bfa83c699ecbf19a5cb902358a98646fa4c6f62d1dd0	5	5659	659	564	575	13	4	2023-09-28 09:46:52.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
577	\\x1725abe70e9c5e954cb4170308f53ce048fb0bc48c776cd46ac5f55640b1397f	5	5663	663	565	576	51	4	2023-09-28 09:46:53.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
578	\\x8390302a91bf6d731fd4f089bd16de7861284bd85a391f55427465ffd874ed5e	5	5664	664	566	577	18	4	2023-09-28 09:46:53.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
579	\\xb6883c0a39a0d87f8276d9c2a8b3ed56e8b8f950a22500201b87e58b71689665	5	5672	672	567	578	6	4	2023-09-28 09:46:55.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
580	\\xb4b978038beb3f839a922092f7d9c17ec263c3b870d1d68e454bfb5f0da7c6e2	5	5676	676	568	579	13	4	2023-09-28 09:46:56.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
581	\\x01570ebe1e048c67c99165147be43b5ac69d5eef0afa3be062ec2538472d2afa	5	5689	689	569	580	51	4	2023-09-28 09:46:58.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
582	\\xccfe51406b34fa0f7c1c0b3a2b3133209d26cda4400f7df2f9332def299f06c0	5	5694	694	570	581	9	4	2023-09-28 09:46:59.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
583	\\x92a15f0799a728c36857989f892a6cd1019901dbd0a77cfc91f1b81cc1f5d905	5	5701	701	571	582	5	4	2023-09-28 09:47:01.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
584	\\xcf7a742f7f4a99fef57ecf9dca3b8bf58a4a4b820f26acfbfbf24da6157e02dd	5	5706	706	572	583	51	4	2023-09-28 09:47:02.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
585	\\x428acc91d3402e1a5d87006811b1224cc8d7eb19b53a8fe3aecc03a673f5d918	5	5720	720	573	584	22	4	2023-09-28 09:47:05	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
586	\\xb37d47ec70ff578ab9c29a30ba6ab0e2b2656ab07283bb38e955669609a5d4e7	5	5726	726	574	585	13	4	2023-09-28 09:47:06.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
587	\\xe67fc0acc7c71319b7b28dcb36a21121f1cf9ba6cd20dd5341c55057f37c42f4	5	5751	751	575	586	33	4	2023-09-28 09:47:11.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
588	\\xa64ddbe48ec2fb6a2475b2b086eec302da37e55d684749be062ee346bc7bb372	5	5752	752	576	587	33	4	2023-09-28 09:47:11.4	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
589	\\x0e7bdbd1fe49d4503c96e5c664a8f2c426cd8c79ebb5dc81b695acb6a8dfdfe9	5	5768	768	577	588	51	4	2023-09-28 09:47:14.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
590	\\xd6c9314a796a081ff92413e65d6dfb532f0b12383658d507534977b32327054d	5	5775	775	578	589	6	4	2023-09-28 09:47:16	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
591	\\x91efe210c26ac3bfd2d6680b12a5cc7aaa7ba143e44fe1e98a0fb2eb88bdfd5f	5	5777	777	579	590	7	4	2023-09-28 09:47:16.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
592	\\xe18c7215f8b6175da01b72bc09b19f871063602947480e4f38baa2a736e11537	5	5780	780	580	591	6	4	2023-09-28 09:47:17	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
593	\\x18cfb2867ceea3ce4adc81029ed6ec959fd53a60fa706e26a7d8fcbe83b30bb7	5	5786	786	581	592	18	4	2023-09-28 09:47:18.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
594	\\x96bf5560e66d0ea9b1dd31f3faa2130fce59e2455fc01764809b9d939a338ec5	5	5791	791	582	593	51	4	2023-09-28 09:47:19.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
595	\\x0a41047915ca947155ca13dcbb3accaef537bf45f788616a265eb4d4f0ceb487	5	5834	834	583	594	9	4	2023-09-28 09:47:27.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
596	\\x1ed183205f0df9c707746c448ab7d1acf77192433565630d65c5fde8d56eac77	5	5846	846	584	595	51	4	2023-09-28 09:47:30.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
597	\\x0f9aa9e3068a9260299943f382760d3e3e73ae7e3793e0e2cac5f09f15b1150a	5	5852	852	585	596	51	4	2023-09-28 09:47:31.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
598	\\xe874f64c22403cf1f131636ec6dd65e0d14a030a5394849c6843d993ef0ef009	5	5853	853	586	597	9	4	2023-09-28 09:47:31.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
599	\\x54d14a90ef7f85fd17bb422d73304ea287e2d63235d35c1453439aa1793a58a2	5	5860	860	587	598	4	4	2023-09-28 09:47:33	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
600	\\x11ed6ec1571939ce7d92ffb115e9e8619afa51ad5df995c583f14c1605780ff1	5	5874	874	588	599	18	4	2023-09-28 09:47:35.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
601	\\xaa90e40bf93ce3e7f6328811c506d9c9d286616110de6ae9515cdba088894038	5	5880	880	589	600	18	4	2023-09-28 09:47:37	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
602	\\x4f02d4e60faac266583b0ef5294ce287a9a8dc3d0dd587d03a1b21029c7eb102	5	5886	886	590	601	51	4	2023-09-28 09:47:38.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
603	\\x5d2f2c4a0a4cffbebfa93a3f49e64ca6590f1a6900f64c5971634131baf658df	5	5901	901	591	602	33	4	2023-09-28 09:47:41.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
604	\\xe13da117ef50400c7157179ce7a3455ec574a9e80afe2ef4b9dbfbc1b8c47408	5	5903	903	592	603	5	4	2023-09-28 09:47:41.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
605	\\xb78d474ed187f89a478f95a4ece83165bc8913bf8f61c6803762c57058cd82de	5	5912	912	593	604	51	4	2023-09-28 09:47:43.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
606	\\x5353c27ee6ea43580bb3d5154f4bf73c4240f39cd1eecefe2b12fe100de2e430	5	5916	916	594	605	5	4	2023-09-28 09:47:44.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
607	\\x0c95cd46d04804b811b74bde92f9f09e2d096a5f62d9969d402a3735616e1e4c	5	5927	927	595	606	13	4	2023-09-28 09:47:46.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
608	\\xd0d3013e60f75932752061ffa838b5a26076762ad5c8840c0a94bc307f84c17f	5	5934	934	596	607	4	4	2023-09-28 09:47:47.8	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
609	\\x82a9a62db9073e84fc17a90f7268c92a1e7a87a28d294ec0e19b919d977a0928	5	5944	944	597	608	18	4	2023-09-28 09:47:49.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
610	\\x9c2828f8d67bb320a390d5f5345a4bf407db691e374f6390d1b6aa54eadb01cb	5	5957	957	598	609	18	4	2023-09-28 09:47:52.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
611	\\xccc3e134c422ed8927cbd84326b50b0fb4cb5d2153157e29efff7afe8392f9f2	5	5970	970	599	610	6	4	2023-09-28 09:47:55	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
612	\\x837f7ec359f3e5a72692c8f5a6d08334f94609f054ba0ef372aa20f59e54526b	5	5971	971	600	611	13	4	2023-09-28 09:47:55.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
613	\\x9e2f2e471e9c089a62a5b18820061dcccbdc93b295c88df6812f8d881170ab38	5	5975	975	601	612	7	4	2023-09-28 09:47:56	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
614	\\x2ce7ded7c7d303f1ff200ca345c9b8827e15ee84f730213aa3cc8a4b6d2bea47	5	5977	977	602	613	18	4	2023-09-28 09:47:56.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
615	\\x3bb825307e86ec362995ef0002f3596b7cd80abc656e2d425413c95a98327f7f	5	5993	993	603	614	33	4	2023-09-28 09:47:59.6	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
616	\\xbd62e020044bc7e4a75995f8374bcd03ec2ca9a1dca1118676d3aa22054f6518	6	6001	1	604	615	6	4	2023-09-28 09:48:01.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
617	\\x6ce5142d6a444e18e662b33026ca072dff89fd3d89c6b29dbb1c4c3796f7b2bf	6	6004	4	605	616	51	4	2023-09-28 09:48:01.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
618	\\x6bed63d905f439b1c5fc4fefe40525ad5a96c72b8d2d555b24e48cf3976965bb	6	6007	7	606	617	9	4	2023-09-28 09:48:02.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
619	\\xfe133c28e7c3b16c18927795b6601316066178a5da71b9cd9e18474ddd013b8c	6	6012	12	607	618	3	4	2023-09-28 09:48:03.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
620	\\x508015b4bdda95031bf72a3b1f2d5190d6dd4c1e415f5b1e532c6872f597cad5	6	6015	15	608	619	6	4	2023-09-28 09:48:04	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
621	\\x771f3aac72a189909fe34edde215aaf65a8ebce8424cf86a23da4176b209687f	6	6025	25	609	620	7	4	2023-09-28 09:48:06	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
622	\\xc4655ffbcfc64f9a495ab0a314408fbaf42b8bd3f9964e602d9353e9ac791a73	6	6026	26	610	621	33	4	2023-09-28 09:48:06.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
623	\\xe548319918fb919bf918249b5c4a0a6f52a0b2948513d85d12452618eda7b9fd	6	6047	47	611	622	4	4	2023-09-28 09:48:10.4	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
624	\\x597b7c2b6a11dab383ef44a25d7b833278a1a53955dbb84995d99683248339de	6	6069	69	612	623	9	4	2023-09-28 09:48:14.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
625	\\xcc8bc0793f36ef2370c250ce21388d9ab3cb174ffd4c949fb10f1b1c1cd8ceb3	6	6080	80	613	624	5	4	2023-09-28 09:48:17	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
626	\\x2d0812deeeb3735050a0a924a1451d1a7dd80d52a84c8faba1e4a8cb87244a60	6	6082	82	614	625	13	4	2023-09-28 09:48:17.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
627	\\x82472da083cc7254e0487ce58095f39b8cf6722144396b25dfafc11ce67950f4	6	6086	86	615	626	33	4	2023-09-28 09:48:18.2	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
628	\\x533d9776bf215886074fe2705ab859246bfa8d60cbeead86f7b8bf7220af9392	6	6088	88	616	627	4	4	2023-09-28 09:48:18.6	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
629	\\x51701598de3cf2ebb2348d539f0dcb0ec44cce62c577292067fd4c0d66a9b8b4	6	6097	97	617	628	3	4	2023-09-28 09:48:20.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
630	\\x64ca08728f0e0fd97accdf0fcae460c00714b3060458504f5be193bb16a6ab24	6	6118	118	618	629	6	4	2023-09-28 09:48:24.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
631	\\x67132baa10da54abdba6c82f05eee92a2e31d05843f6b752958a818f72723c37	6	6131	131	619	630	9	4	2023-09-28 09:48:27.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
632	\\x3ac12c7bf9538927c79c9318fed1a5bd32ccabb688eac640db65dd3c6f0efd4d	6	6134	134	620	631	13	4	2023-09-28 09:48:27.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
634	\\xe03e08eefd109fdd048d5c9708c0e2feffbb7d60b5d898a4f1b27bc29bb83673	6	6137	137	621	632	4	4	2023-09-28 09:48:28.4	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
635	\\xac79e48040b2a6c11fa096f00c34d9ed47e4e01fabaeb351f30ee2eaff55cf02	6	6148	148	622	634	13	4	2023-09-28 09:48:30.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
636	\\x7e002505e19337dfcfe6e6320673d9f58a9e1a47ddd1e9d03d3a2e17baac3f73	6	6174	174	623	635	5	4	2023-09-28 09:48:35.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
637	\\xd2bb3a07925fdf8c266f151738d7f89df6f548f37fcd31980c45a68ebbb180ca	6	6181	181	624	636	4	4	2023-09-28 09:48:37.2	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
638	\\xfb2f275798b79e4fe1519e740ddc6f2d8a3d592a6043acbc7808f58b07d372fa	6	6193	193	625	637	33	4	2023-09-28 09:48:39.6	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
639	\\xa4ccec1ef3b976e7910442b7bc2a4b31ed07cec23af0d3583a6e9a4aff9a7672	6	6198	198	626	638	33	4	2023-09-28 09:48:40.6	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
640	\\x698e73df5b35e9ec00939dbdfc58fba73e68d64925fe31a1322b8b9b51612ed2	6	6222	222	627	639	51	4	2023-09-28 09:48:45.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
641	\\x492f3e0a01e974de9fa1672cb7c85b49d4e1c5c88b9c3f8f9f62db764c6a5d57	6	6237	237	628	640	4	4	2023-09-28 09:48:48.4	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
642	\\xa41ae656b92897e1e62d7b89a01ef6a70b7e737a9faef4243f6bcced2e543158	6	6245	245	629	641	18	4	2023-09-28 09:48:50	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
643	\\x4e2bf778a45f114639f908f7a31a62c751d37f3960ce190064cbe85ae233047f	6	6250	250	630	642	7	4	2023-09-28 09:48:51	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
644	\\x789467cae2ad8da093a4b5e84c2959f7b01a229f9a78d434272ddb129bb8cee9	6	6259	259	631	643	5	4	2023-09-28 09:48:52.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
645	\\x4852b8ff6c1041d7312f1186301f37cee313aaa89189c6fed2f315f433adb831	6	6272	272	632	644	13	4	2023-09-28 09:48:55.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
646	\\x200c95eec48db2d6bbf506f4b90823785d446afcb4741e0c644cee38a7d47ff4	6	6294	294	633	645	51	4	2023-09-28 09:48:59.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
647	\\x9baea6d0e26180c4e6b3e27bd68ca958f49eb3ae393cdad2214c21571ac77198	6	6299	299	634	646	3	4	2023-09-28 09:49:00.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
648	\\x8fa0fd0603beed1e35de6670c45787d8c6bd9dec6732102df14ae01bf4965ff8	6	6303	303	635	647	51	4	2023-09-28 09:49:01.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
649	\\x8e1e7c457cda2a75898ab302884ee692ff6699dd78cee8568cb77849d1b3c5c3	6	6324	324	636	648	7	4	2023-09-28 09:49:05.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
650	\\x8e8605849c1c587fb112744085354e5ca17ddb6d49f75bc84d0431259f47f0db	6	6340	340	637	649	18	4	2023-09-28 09:49:09	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
651	\\x69cdc3a84ca6fa61310fb6259b1466bf5a9291e35ecfd5227acab0ddb658fb68	6	6343	343	638	650	6	4	2023-09-28 09:49:09.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
652	\\xed275b1cf2ba9bb2e7199b56caae772f3d91ee80a45d4e501aad85e08d4c0649	6	6350	350	639	651	18	4	2023-09-28 09:49:11	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
653	\\x687f05150c5f3082b86e3fb40a85d160b8ff74c2b29c9b425a38a82c9271083a	6	6356	356	640	652	6	4	2023-09-28 09:49:12.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
654	\\x5e221b096be1891c5e5af424cbe98a9402404e56c26922bd57773fb83370f838	6	6364	364	641	653	6	4	2023-09-28 09:49:13.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
655	\\xc03520d90c6bee05c869104ed33d2632380b0ce63dd6d2bd3e36783562d95f3d	6	6369	369	642	654	6	4	2023-09-28 09:49:14.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
656	\\xc9bd334c0821801fdb89dc4cb0132197eb6b71847abcc4025b68c45fc45212e8	6	6373	373	643	655	51	4	2023-09-28 09:49:15.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
657	\\x36ea9038d16573cdd13f1e9b230ddf04e5d985974734091bbe4f800aecefddcd	6	6376	376	644	656	5	4	2023-09-28 09:49:16.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
658	\\x2d239845566bf70e54ad3a231744d03ab15e3e20437a7218bc845460ee204970	6	6385	385	645	657	6	4	2023-09-28 09:49:18	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
659	\\x17df4e2accc10218d98cb457c55d677799782f275d355971b15c2b5b08700727	6	6388	388	646	658	22	4	2023-09-28 09:49:18.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
660	\\xd11e038a36a4fceec42a9295200af1597d1a529fbf61c080fe07bbe6d9966a6b	6	6391	391	647	659	7	4	2023-09-28 09:49:19.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
661	\\xf5faacc758dcd9b7aa3cc7ab9f921c93437e9cf7a8334187927ae995cc2291bb	6	6409	409	648	660	6	4	2023-09-28 09:49:22.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
662	\\x8ee7a996b9d47937d24582ad1dbab2af908f03627ec2e1605acc1738f2567c88	6	6414	414	649	661	5	4	2023-09-28 09:49:23.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
663	\\x9cf2ef3a7600446afc106c82ac0c251646ce9e502b4fc57cd1fe7a660a5f626a	6	6435	435	650	662	4	4	2023-09-28 09:49:28	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
664	\\x5c3b8bda95c420210be5f0e1a51bffc8def49126f0ed8f1e68ce74c2056739ba	6	6444	444	651	663	3	4	2023-09-28 09:49:29.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
665	\\x219ee35e97fa715034781031f787c45891ba49b251beb9256d3ac880506949eb	6	6455	455	652	664	13	4	2023-09-28 09:49:32	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
666	\\x38680b2ea809ed198bafe8b642e88e8934044f0e1e3c7d8f803c0b51881469cc	6	6470	470	653	665	5	4	2023-09-28 09:49:35	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
667	\\xa3b769fa669f0fdac1da033b065fd3df46846014373bf9c46b291b143d5719a2	6	6471	471	654	666	13	4	2023-09-28 09:49:35.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
668	\\x7bd361444685a7f856c92141cca2cb3ccc1ee4d483c232b7f6514750e60fe282	6	6472	472	655	667	3	4	2023-09-28 09:49:35.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
669	\\x0545eeafd23c60507729cc9e3950946866e07c8d87f948a0dfcace9b033e42b7	6	6477	477	656	668	22	4	2023-09-28 09:49:36.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
670	\\x8fa9d3eefe071ad5f01f1f8d8b85188e0c2130daaf35cdb92b3be9e5eef68673	6	6478	478	657	669	3	4	2023-09-28 09:49:36.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
671	\\x75e82f6f23ae91b095d2d307a9d027db85c534128e09a3e23fc3d4157b2a3286	6	6485	485	658	670	33	4	2023-09-28 09:49:38	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
672	\\x9f94401bd0fafccdeb92cea870eab3ea53c04ca375184c600fa419624599c3c5	6	6489	489	659	671	33	4	2023-09-28 09:49:38.8	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
673	\\x1fc4fde5023cc2e66b0b31f6947d3c366b7a58903c4ac0e6c6023ed15d71b39f	6	6508	508	660	672	6	4	2023-09-28 09:49:42.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
674	\\x13c95cbe0a7d0637b26cb4d13d2f925b2dbb2da6ba71d99ee82e85d8a6510a04	6	6513	513	661	673	33	4	2023-09-28 09:49:43.6	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
675	\\x3da11b0c40871a984920df11fc15dc739c95cdce279175c29e874e9f11ec512c	6	6515	515	662	674	18	4	2023-09-28 09:49:44	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
676	\\x6a1098e51bbdc45ce291761f45725b00c57c57fe8f7faec03e64a3f404a5aee0	6	6532	532	663	675	13	4	2023-09-28 09:49:47.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
677	\\xd2df308ce8f7e34a9840da33830e46f886b82a076fa01356db38e737167ce00a	6	6575	575	664	676	13	4	2023-09-28 09:49:56	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
678	\\x6b7d42aa358a4288c960afc1c973dd722f1e1790b4d5a5da01753a177d01be56	6	6581	581	665	677	4	4	2023-09-28 09:49:57.2	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
679	\\xf7b92be594c0e0d783908e6d393b73c80883cac723213d3036b1af49fc875565	6	6586	586	666	678	18	4	2023-09-28 09:49:58.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
680	\\x41a85c43a91e2c866b3672ec1c635ce2422ddfb5ae0ceefdb2f3e5899378a098	6	6589	589	667	679	7	4	2023-09-28 09:49:58.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
681	\\x29494ab2d0d413890fa158358f74b7bcab84137f19f6ab1782632cac6bdd60a4	6	6616	616	668	680	6	4	2023-09-28 09:50:04.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
682	\\x92e387efe94c1f8ea1e42e119fba200a9ada69de0afb0be2b219e79c4b1ae396	6	6618	618	669	681	51	4	2023-09-28 09:50:04.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
683	\\xbebbee09765568a8dcb998a43dc17f5ead35a87aa1e7159fc9127292ac802f40	6	6637	637	670	682	4	4	2023-09-28 09:50:08.4	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
684	\\xc6d9278b98594704f41f8b81df2b8b2b53c1b68ab63ebbe3121b64d9f9ed794f	6	6640	640	671	683	13	4	2023-09-28 09:50:09	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
685	\\xfb3df189768892ca5b2063655ec6a385155431c6e5c68e9ccea622cbc07fa017	6	6643	643	672	684	4	4	2023-09-28 09:50:09.6	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
686	\\x86e10263f77d774a2779919a4d30c70e8e640f55f11c42c5c7b0a68266c872ee	6	6669	669	673	685	22	4	2023-09-28 09:50:14.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
687	\\x36258ec79e0b42db8fa353b699c93dd0468d8a84873d5cc710d731bda26ff86c	6	6680	680	674	686	13	4	2023-09-28 09:50:17	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
688	\\x5225dcaefb2dbd910eee20b3abb6538cd6b085aec6ba088b624d18b8b6b056d7	6	6695	695	675	687	3	4	2023-09-28 09:50:20	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
689	\\x7530f3834e625691bfb01ebdd8d25b8f2cc577adeaf9e9261c2a5bc9fe096568	6	6697	697	676	688	51	4	2023-09-28 09:50:20.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
690	\\xa64b4babecb17eb90ab2ce940e60206174f5a6aaaf2d34ac3cfe524cb3116e12	6	6703	703	677	689	22	4	2023-09-28 09:50:21.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
691	\\xab9ef754567827bf2ed8c4ad37af316c73b740bc9f451a4473eb1e9f198e8f8b	6	6707	707	678	690	3	4	2023-09-28 09:50:22.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
692	\\xb131f1d2631fb2bf647d06bc336047e42c72e113f3eeb3daee636d1d363096dc	6	6710	710	679	691	33	4	2023-09-28 09:50:23	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
693	\\x95c14d9771950bb59403da541df5f82add8d1fc5c77d51cfcce7d3f37bb5d6c3	6	6718	718	680	692	7	4	2023-09-28 09:50:24.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
694	\\x248c00f6fc41dfc3ae52d2f698881cd51e6890623f7683c7199ddee26fe02da2	6	6723	723	681	693	33	4	2023-09-28 09:50:25.6	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
695	\\x186c64e0cb52de1e1ba6beeb562d6cf7accc1e0522f177962e2d6eb714dbcf22	6	6730	730	682	694	7	4	2023-09-28 09:50:27	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
696	\\xef09646233c4c2a3c1fff87bc6befc5afad8d512ce196f740a89e6bdbb7ac79e	6	6743	743	683	695	33	4	2023-09-28 09:50:29.6	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
697	\\x1eddc4440756fff29e936105c28d1bbcc9ebb631dd35ebb2232b7e4b07992e14	6	6757	757	684	696	5	4	2023-09-28 09:50:32.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
698	\\xd70379f0b06f55fecb5688f21004360aa4e4d8cbc4f6d5a88b815ec07c2c8e6d	6	6763	763	685	697	9	4	2023-09-28 09:50:33.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
699	\\xc0f836019c5b7f205f8674b9934a97ed04c07a2759f807003b7d12102d8f10c8	6	6766	766	686	698	13	4	2023-09-28 09:50:34.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
700	\\xb279412a036d47699d79d22a2d9f2aeb618eca32f567d1d941cd35863e8899ce	6	6787	787	687	699	22	4	2023-09-28 09:50:38.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
701	\\xe59c89df2cd5d3b9e37f70d103b4f7eecb82ea44b1423c50a8e2a44765f99565	6	6788	788	688	700	3	4	2023-09-28 09:50:38.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
702	\\xa3dbb188c3e3935f820a62510f3613da5f6c105c197c872fc1ba35fb99a1047a	6	6815	815	689	701	6	4	2023-09-28 09:50:44	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
703	\\x10aa57fbed8cd64c3af5148bb068524aefa7e936a8e8cf8e4dd8510d46e07793	6	6817	817	690	702	51	4	2023-09-28 09:50:44.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
704	\\x9da8ba0d6772d0b0393d9dd3885cbc008b125b206864c4b3cb8ea46b0e46264f	6	6819	819	691	703	6	4	2023-09-28 09:50:44.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
706	\\xe96f287811758bf72e6200d509abe80a02e0ce428b1c1cb59fe562e5f939ecc2	6	6833	833	692	704	3	4	2023-09-28 09:50:47.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
707	\\xdab675917af2eeacc6f4a7ea076ceff2109d7008551076e157397a86bebe6551	6	6839	839	693	706	5	4	2023-09-28 09:50:48.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
708	\\xf3697b3a868b13d2730c5ad326846288a077f997a02470857e588820bab594d1	6	6840	840	694	707	5	4	2023-09-28 09:50:49	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
709	\\x0522cbd25dfaaa5757147db438a64fda3005db315f19443537dc998757d7c095	6	6858	858	695	708	6	4	2023-09-28 09:50:52.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
710	\\xa0b0b98e77e28542de7d9688efc26493e9a4ac137acc011ad3b4a95aa9a472eb	6	6862	862	696	709	18	4	2023-09-28 09:50:53.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
711	\\x2b6f4bda89fa9e43ce1589696fea488c92e3de8d261342e6bf9d7992476c0ca2	6	6867	867	697	710	33	4	2023-09-28 09:50:54.4	0	8	0	vrf_vk18ycfza0evpfuexh6rax8xgx7hcw90pcr2xvd96ked95xs64u0npqjhqrhm	\\x2ba0a22e797a5ecbc6f4dc0a9b87e6e264ed92347ba7fb50a82284a07551b7ff	0
712	\\xbaf6cace215b5fd640a5a9c0bc6fba5fdc69746642655fa572f86f4fd3b17c52	6	6876	876	698	711	51	4	2023-09-28 09:50:56.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
713	\\x7efe40b14e8a2e0f10dde02f6771bf0bad74e9fcceed3e3567a0c89d22c9aaa6	6	6885	885	699	712	6	4	2023-09-28 09:50:58	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
714	\\xc7cb718d44b361790ae6fd9eb4e547ba60e166fb3d1f15f556963b8b4e1eaa54	6	6887	887	700	713	5	4	2023-09-28 09:50:58.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
715	\\x10312ef9837e37d7b37bf98b8dd02bb4a026652803df480f27ccc09414a1a7fc	6	6895	895	701	714	9	4	2023-09-28 09:51:00	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
716	\\xcc3b20b3339383df9988065f5538c4f90c21ba02128a981dcb9a5199a378cc15	6	6896	896	702	715	7	4	2023-09-28 09:51:00.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
717	\\x0ff06d40308ed0380e25b782cd667bc32c6c231e378d01b0f1db7863f262119e	6	6898	898	703	716	5	4	2023-09-28 09:51:00.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
718	\\x853082eb2371a27b66116b2bcc9335bea9834401f675414828c78915c5daf15b	6	6906	906	704	717	9	4	2023-09-28 09:51:02.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
719	\\x5a8a46753ba87260bd7fc7757525abaacb753ec2fc9d42f04166068e3e37475f	6	6915	915	705	718	13	4	2023-09-28 09:51:04	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
720	\\x4fabe303cc6c73e01afba60f269283d54725c2f3dea7aa0c39abaa435025bc70	6	6929	929	706	719	6	4	2023-09-28 09:51:06.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
721	\\x21106b25b0323877def3cce09177c451593940f9553367ed100304cb7a5beb54	6	6939	939	707	720	9	4	2023-09-28 09:51:08.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
722	\\xbefe28a354d029c8f862cc8f18e29b14392bde8523ab699b0bf258f0dfe58fe6	6	6947	947	708	721	7	4	2023-09-28 09:51:10.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
723	\\xcf4f789661724da6ce70b9eb4004814cf5ccdc6e55ad3416735656f0264be8c2	6	6948	948	709	722	51	4	2023-09-28 09:51:10.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
724	\\xb4738775084ff7f580a7ae976b113d937f8e6a717145e8a1adcdfca15addd9e4	6	6955	955	710	723	4	4	2023-09-28 09:51:12	0	8	0	vrf_vk1hnx8k028ss8q72u865sz9llau8w6evsd47zatug5ek7sezgk2spqdr8keg	\\xfc32fafdd55398c7d31c77233ef4f4824d0e61eb7cc511a57b60c330cf95505c	0
725	\\x517009c2ef915ea4982fdc9e41fa1956a87065a81bcc1713f889f74c0f7a7a2b	6	6962	962	711	724	9	4	2023-09-28 09:51:13.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
726	\\x1e0aa78aac6a31a9406a0849d8b46f5afd26b65685c287b5254863c7929992b3	6	6966	966	712	725	6	4	2023-09-28 09:51:14.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
727	\\xed8d345a7812b2ff17443beec1e84083314a68c0e740e8294f33ab4a26874967	6	6969	969	713	726	6	4	2023-09-28 09:51:14.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
728	\\x2edce97674cb0f4c09558776f6f59754056ff9dc515a6d2bd7a464ccea87394c	6	6986	986	714	727	51	4	2023-09-28 09:51:18.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
729	\\xc0d392efcf7075f24dddbf42cbf49ab6080749352f3e17e18ed94c94c57800d2	6	6992	992	715	728	13	4	2023-09-28 09:51:19.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
730	\\x0508cb2599599bab4e09ced0d9bd7353201e669e1ecd138835c36af34721bde7	6	6999	999	716	729	9	4	2023-09-28 09:51:20.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
731	\\x90e7af3b1d0105baab04e9ea228e4375370b1328a8b62082c71d9b561ace4ec9	7	7034	34	717	730	3	4	2023-09-28 09:51:27.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
732	\\x8e6273efb8bc102d3fc0c762c8018b779dd1017252d7db2b2fa46cf8aa4f42a3	7	7035	35	718	731	9	903	2023-09-28 09:51:28	3	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
733	\\xa5917e1ac42d339ba15df06c712a718e8fedadd3e8829bd9c9edf4d343889d8b	7	7050	50	719	732	3	30759	2023-09-28 09:51:31	97	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
734	\\xae21bdaeb6a7460639bfa76ebeb405ff5d7020b738b49ecde14085a635808c1c	7	7056	56	720	733	5	4	2023-09-28 09:51:32.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
735	\\xbfdbd34e7c8c98093ba9143ca09808f569c7bcb723380ff3a6e51557c8070dd3	7	7059	59	721	734	5	4	2023-09-28 09:51:32.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
736	\\x0a7d0dcba5711b8da9e716cbfe7dffb737a7a5bc5ccd6cf397f7c85161fafbbc	7	7068	68	722	735	51	4	2023-09-28 09:51:34.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
737	\\x25a5acd36f40770fff75b7976b44942de6562dd3d762fad600f3dbfaa716b5e9	7	7077	77	723	736	51	4	2023-09-28 09:51:36.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
738	\\x4b21c275f8c33d8eb67b2e97157fcfde21ee367ba38eeed74cf8ba3cae84848b	7	7086	86	724	737	13	4	2023-09-28 09:51:38.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
739	\\xd5ccb6d1fabac2abbd19c51cc1a43755f540e52f8bb3686eae88784721ca7930	7	7091	91	725	738	9	4	2023-09-28 09:51:39.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
740	\\x28943b1ba05f6c70f54e6bd25f1a8288bb1005aa873e961e46838f1d4889b889	7	7096	96	726	739	6	4	2023-09-28 09:51:40.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
741	\\x73977c34007669baacf66323138d7425b9ddd8ab584993e83ce1d45df683f3ff	7	7115	115	727	740	13	4	2023-09-28 09:51:44	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
742	\\xb865f380d68be757e53c39770834aee25c6bdb2c805c87d31bbd709f845201f7	7	7127	127	728	741	22	4	2023-09-28 09:51:46.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
743	\\x8ff9a32c5a76fa868e1f2f25d316a6c53f7b009ca0123caa7841d13d74948c35	7	7135	135	729	742	18	4	2023-09-28 09:51:48	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
744	\\x09824814ebf18ebd25194a041a0693b82d755ccb01d76b1ef2631a46451dc0bf	7	7143	143	730	743	6	4	2023-09-28 09:51:49.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
745	\\xfea16ca8d614d75437ba3e4130d2844275ce1e42dd4a16673431de3aa5197436	7	7157	157	731	744	9	4	2023-09-28 09:51:52.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
746	\\x8142bb26da94f398b3a89e63ca910e28436d8a7a41d38c1b55506d3a17909296	7	7160	160	732	745	5	4	2023-09-28 09:51:53	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
747	\\x8dfac2ed27c6a9b5bc0facc82f878a62608068dc9dc6cb76dcc0f096c49229d2	7	7180	180	733	746	22	4	2023-09-28 09:51:57	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
748	\\xb06f7937d3afffdde478478506b11aa848b68c51ab820fbcfc3ded40a8c8ca4f	7	7184	184	734	747	18	4	2023-09-28 09:51:57.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
749	\\x8fa3ae8e656b7395f946d8fb0ed85d6f142407271e0d72b9a3ee13fe5ec58c2e	7	7194	194	735	748	18	4	2023-09-28 09:51:59.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
750	\\x54fb2ab9da69910bd8d6bb9dc6eef318d772c85ecebbe303d485053f8eb9df0c	7	7234	234	736	749	13	4	2023-09-28 09:52:07.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
751	\\x8b8088262de8973d8ec3d55c9d67865ba922ab743f50a061eaaa5a40b95f28d1	7	7238	238	737	750	18	4	2023-09-28 09:52:08.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
752	\\x725335c7e54e318048f960112ed4e2bb7d44e7d9ca2455a5efc7d3fdf2feb020	7	7254	254	738	751	9	4	2023-09-28 09:52:11.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
753	\\xcdcfbde746e23a12b401e469471a635b0d3129d13f57ed5a052e6f5fb3db7de1	7	7265	265	739	752	9	4	2023-09-28 09:52:14	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
754	\\x9084f0a604c16d2be3448caadfb8351be3560aa070bc645284ca9ba3e7d6a46d	7	7319	319	740	753	51	4	2023-09-28 09:52:24.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
755	\\x854a316f71a88cd6d406b6d46e12007b43ac3339f600ee65f89fc4562592ea8e	7	7320	320	741	754	3	4	2023-09-28 09:52:25	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
756	\\x405ab65c4b2a547d83e0d30365f62fd65ad8096ec4aa79588bb33e87bf8e77ce	7	7324	324	742	755	5	4	2023-09-28 09:52:25.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
757	\\x312edca26695f14bc0cecff43d738e43f6fa01d23771c97bd35b25cedf94cb86	7	7328	328	743	756	6	4	2023-09-28 09:52:26.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
758	\\x697f802800e1c2707c665f180bc9088784058e8abd79ff1cab39c480f97cb37d	7	7337	337	744	757	3	4	2023-09-28 09:52:28.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
759	\\xd1d1f485fc5c5dc2aa6ca84f2bf7d05a5e3dead61e0bcc586b3bdffe3e38b9d0	7	7338	338	745	758	51	4	2023-09-28 09:52:28.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
760	\\x34147ae8bf6e6909259b8e22ba5f77425954622859367019ade94bd88103926d	7	7342	342	746	759	13	4	2023-09-28 09:52:29.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
761	\\x183db1412aaa9c9c20aedbf11305bd943070938982a54d569ba3654e7d9900ee	7	7359	359	747	760	7	4	2023-09-28 09:52:32.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
763	\\x764c5f6124f37b047d3787cd48656d3774c861ea5366c8e110df51ce1b8242c2	7	7379	379	748	761	9	4	2023-09-28 09:52:36.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
764	\\xf93c22620005df4fb133e385b0909e0ee7524c86a266cdabe2dcf135cb9de0b4	7	7383	383	749	763	5	4	2023-09-28 09:52:37.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
765	\\xee4d5947d5ee07045a89004f740025c5934f35fd58645c81ba7cefd45fba2ed8	7	7403	403	750	764	9	4	2023-09-28 09:52:41.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
766	\\x8bb3ad95b9dd2da5430177af73ef1f73fbdcbc7140e2ea32a8b8bb0d822e9ac0	7	7411	411	751	765	6	4	2023-09-28 09:52:43.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
767	\\x65e25060fbe63d9f37108ede75f9d66b078a142e3aac475c7ade6959bce65565	7	7425	425	752	766	13	4	2023-09-28 09:52:46	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
768	\\xe845f714f51d8630192a8f91f985c45feace7310b5729fa92658e96b5f4d8656	7	7443	443	753	767	5	4	2023-09-28 09:52:49.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
769	\\x1b3a06ab28085a23f3fcc56af908470816f4ff8aeb2221b6ff27fcb526296eb9	7	7445	445	754	768	18	4	2023-09-28 09:52:50	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
770	\\x18d081dbabc9de9219e51eb188963f7adb5ecbde785d1a0e5393aedd0ca6b249	7	7454	454	755	769	18	4	2023-09-28 09:52:51.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
771	\\x088f2dc5b6841c73f644400f77b4c07d3eb4d4504090d76330c5a236f089624e	7	7462	462	756	770	9	4	2023-09-28 09:52:53.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
772	\\xa0cccc464f55d55646af0a4739101cdace1146668aa9b14db03d5e3bf89f7746	7	7482	482	757	771	3	4	2023-09-28 09:52:57.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
773	\\xdf78dba9c0e47f0641443d995eacddf81040b39462a8f75b4659867cdf5cccfa	7	7483	483	758	772	7	4	2023-09-28 09:52:57.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
774	\\x45cbbfce97d5f6e434c50274f1686058cbfdc2a244dee929887be2eeaa254d18	7	7495	495	759	773	9	4	2023-09-28 09:53:00	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
775	\\x010aa233eca33fe4d79542f91e8cc37f9813a7e27e5074762a2ad61800f950a3	7	7522	522	760	774	9	4	2023-09-28 09:53:05.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
776	\\xe3a6ff5b00872af6cef96b3091d05c9a4ef548ad64369eb68ca8b6ae7cd850de	7	7531	531	761	775	6	4	2023-09-28 09:53:07.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
777	\\x2be55e39c8c453a278372528f38a40a1a822a386be999765e590bf586dd22e6a	7	7532	532	762	776	13	4	2023-09-28 09:53:07.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
778	\\x16c2c50cf22e01e0d87ca20b634d566d689105c0079c64c97ed927337657325c	7	7534	534	763	777	3	4	2023-09-28 09:53:07.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
779	\\x139d0eeec68f31790adc5e52477978634855d0a3cfbe1b1d15e0147fb4ee40b3	7	7541	541	764	778	13	4	2023-09-28 09:53:09.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
780	\\x85f6c7df06f402ab3e4764e8ece6b4dfb706b665ae090188d05499048d00f112	7	7542	542	765	779	9	4	2023-09-28 09:53:09.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
781	\\x581e71a13da6ee2fcd1d1d7401f84eeca3173749fd8ad8573e4278725560e77e	7	7552	552	766	780	6	4	2023-09-28 09:53:11.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
782	\\x35e17833703dbdc42d603b25ef624356e719bfc56841f846c3f220966b53a421	7	7561	561	767	781	51	4	2023-09-28 09:53:13.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
783	\\xc77de05b5717ac59af979c7865c7c7f395b916b254abe64ab08275a45d77383e	7	7579	579	768	782	5	4	2023-09-28 09:53:16.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
784	\\xabe096567cdbb86fd0a5cf106ab58785fd4113155881051756e839b17f2bd23a	7	7587	587	769	783	6	4	2023-09-28 09:53:18.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
786	\\x5ab7b399e6922f91109c66d5342f0c7c1d82a863e5559b3cf2b8c773390be0a2	7	7596	596	770	784	13	4	2023-09-28 09:53:20.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
787	\\x2846ee642a795e497f38c89b06d918d2b74cf4c9f7b492413aa4484aa015782d	7	7609	609	771	786	22	4	2023-09-28 09:53:22.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
788	\\x819407aa9d51b15666e25f3f917ff43de59ff41287c86819e1731e71fee9744d	7	7617	617	772	787	13	4	2023-09-28 09:53:24.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
789	\\x9be4f017bbd92133af4aa2980c04957dcdbe9d05238532593d95b4353d278d5c	7	7625	625	773	788	9	4	2023-09-28 09:53:26	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
790	\\x893e63ac62faea4388cb1d202cced885c8f22960035e024f5294af8162c1cc0c	7	7629	629	774	789	3	4	2023-09-28 09:53:26.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
791	\\x735c3155d3debe20b8783c1fcce34fdc4fe186e6b402e2eda9c38806b0b82cd1	7	7639	639	775	790	5	4	2023-09-28 09:53:28.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
792	\\x2c8541e4283204e4e095a659ef26ebff7f7a52bbfdfbe0d088542e3d52c1560b	7	7644	644	776	791	18	4	2023-09-28 09:53:29.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
794	\\x5d250e18babcf43b62bf4707f9dcf59014023b22f05183947700269db5009ae4	7	7648	648	777	792	6	4	2023-09-28 09:53:30.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
795	\\xc1a340060816e0ec2a8836037b772f5b2f57a1a67cc72383f64768530c2a66f6	7	7649	649	778	794	22	4	2023-09-28 09:53:30.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
797	\\xf11a7b0285de233ea83657aeb198e370e6feb96a904c207c2ed9307060497482	7	7653	653	779	795	5	4	2023-09-28 09:53:31.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
798	\\x00d4944b018cda6ca6d916b0af2f9a7450bea613a2b43a1cc0570cdcc9dc03c8	7	7655	655	780	797	51	4	2023-09-28 09:53:32	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
799	\\x1a1b840b9919ee2e5fb14bc84ffde7606097316d997c8c717479a924aa9007ca	7	7658	658	781	798	7	4	2023-09-28 09:53:32.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
800	\\x3f3e9d7e1dea2e39a27fcd4993f883fa6447f68da961fde8eb122151e5458126	7	7666	666	782	799	22	4	2023-09-28 09:53:34.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
801	\\x7dadd51d9730472b1c7a19deeec9873c9e8e056436bb5fd46a9f752e02c49257	7	7667	667	783	800	7	4	2023-09-28 09:53:34.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
802	\\x2d70d24611012f14e8c5cbddac4ccf80bd5858906e594e101b2984140d035017	7	7670	670	784	801	5	4	2023-09-28 09:53:35	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
803	\\xf7876b95f984631c347cfe8ee63b26f61783713710b446580515f20ca0caa210	7	7674	674	785	802	13	4	2023-09-28 09:53:35.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
804	\\xb0fb0e491305454434b5edb2d8fdafc5289d48302be905be34581bbe3e804b76	7	7678	678	786	803	9	4	2023-09-28 09:53:36.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
805	\\x9bbc938c32aa9e759d58128147b4298628c5774568a4b144b3b97403cdd566cf	7	7687	687	787	804	7	4	2023-09-28 09:53:38.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
806	\\x8ca4833626287de35ef4ad9ae6f9611767ebf108a195299d88faac215829f601	7	7699	699	788	805	51	4	2023-09-28 09:53:40.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
807	\\xef49a113f966fda51c807a20bc9bd86a195298c52a093c0e5537c328df44aea7	7	7710	710	789	806	51	4	2023-09-28 09:53:43	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
808	\\xa66d91088ac60c8971ebe9dc96bec71bee8efe75d46637eaaa8076ad7a176209	7	7719	719	790	807	9	4	2023-09-28 09:53:44.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
809	\\xc9d468bd95999ecde03cfd512f44d9d84a5626e0e7cfd84642100b87a2250b52	7	7728	728	791	808	13	4	2023-09-28 09:53:46.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
810	\\x62502f91b8c00295cdddcf55e3bed651da1a2e88cbddb315f5cd4c4c4de043de	7	7736	736	792	809	5	4	2023-09-28 09:53:48.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
811	\\x3f7678ec1a420bd49f696d55e62de625e1f148280e23d6a1b25df5050654a391	7	7753	753	793	810	7	4	2023-09-28 09:53:51.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
812	\\x57cfd041a681315f2776510e4593b11f101d2aa279b9558c1158aa2dfb868871	7	7755	755	794	811	3	4	2023-09-28 09:53:52	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
813	\\xe9db0fa11e4f851cf1da33ac41ce7c18b64c97107d61576a6251de24754cafd0	7	7759	759	795	812	7	4	2023-09-28 09:53:52.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
814	\\x9cf1bfde27722eb007725181bc986075df7210e541559469fc8405a48a155b94	7	7760	760	796	813	6	4	2023-09-28 09:53:53	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
815	\\xcf369020b0e444038863f3459f31d31e77a9e5da8a4253a856fb4152666682ea	7	7782	782	797	814	22	4	2023-09-28 09:53:57.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
816	\\x660a5f29531cb4261642e68d242067b217cb26900548381d643af7bea3e2af06	7	7785	785	798	815	6	4	2023-09-28 09:53:58	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
817	\\xda59a5927aa49ea3ec7b3ddb35538756739274a70de5b8da1982175ecdc7d8f2	7	7791	791	799	816	7	4	2023-09-28 09:53:59.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
819	\\x2975fe9a6659c0de4c287c26ad46cebcc7600897fb40fe4bd6cb4f2d0c0127c3	7	7805	805	800	817	51	4	2023-09-28 09:54:02	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
821	\\x35a1796fc30b6b06816c3fb11b318b5ed925c6856dc6e30fbf56c4b81dbddbfa	7	7812	812	801	819	7	4	2023-09-28 09:54:03.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
822	\\x2e85e55d9547b84656922fa6c35894df70a5744b804ba660eeb55019d76951b5	7	7827	827	802	821	9	4	2023-09-28 09:54:06.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
823	\\x976a248885e7f84d82e1d6a0005f88ae7e0bb608b1fc8cbf457a92a23f89276d	7	7831	831	803	822	6	4	2023-09-28 09:54:07.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
824	\\x91034d2a95d822580e54feca57bda47c382081b5d92265160ecfcb873e0f58f4	7	7836	836	804	823	5	4	2023-09-28 09:54:08.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
825	\\x311fd904c7cd81d88316658175fb86e35457d3f11637a9152f63f828ad16a8f1	7	7838	838	805	824	7	4	2023-09-28 09:54:08.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
826	\\xd7cc376c9a5207f62615912023500a860ad55f2371015924dae2d3dc3716a35b	7	7860	860	806	825	7	4	2023-09-28 09:54:13	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
827	\\xe073cc372c270a6498357896d515bc0d25867ead29ebae12de8dbdf348303d18	7	7866	866	807	826	13	4	2023-09-28 09:54:14.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
828	\\x034a9ddeea4e7eb439a3f5042d35036f695325a5e8e0e8ffdd8c27a942c5ad2c	7	7887	887	808	827	13	4	2023-09-28 09:54:18.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
829	\\xf3b7642220cee6bbf1de7b7d82f0291217e494847b1e17891558079fcca0b569	7	7895	895	809	828	7	4	2023-09-28 09:54:20	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
830	\\x7ab4b4d6cb0924b3a78dbc5f2acd512ca7e4a01e2457e7c8d12c16d8c034603d	7	7896	896	810	829	6	4	2023-09-28 09:54:20.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
831	\\x6148713f7da6c1c5d6b08146617db93a3e8486086d029f5875f942553478d272	7	7910	910	811	830	7	4	2023-09-28 09:54:23	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
832	\\x53074cabf1e76453f4cb055da717c2f98937520c0cd66d3ba885686f69cfc11f	7	7915	915	812	831	18	4	2023-09-28 09:54:24	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
833	\\x692f5776922ea157e392c88d54e75ec40fc2fce541d8389aa0de144c734af42d	7	7921	921	813	832	7	4	2023-09-28 09:54:25.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
834	\\x0a8a2e7a4e5f7c72b0816302331bed8af47d176a43dd1b6234cbeae27a9aa9dd	7	7935	935	814	833	6	4	2023-09-28 09:54:28	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
835	\\x59dcb13e16b72660ec6054cb5b58c92aebc39384085b429107d283b136204882	7	7937	937	815	834	18	4	2023-09-28 09:54:28.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
836	\\xcd4ea254ba3df746ca3ddf65847a72eaecaad30c692d2eae4903fb14f6eaf294	7	7959	959	816	835	5	4	2023-09-28 09:54:32.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
837	\\x1a6a55ca3e9934f1a3bac98cbed766d08cc19550bdcc3bacbb9a78ac68d644f1	7	7970	970	817	836	5	4	2023-09-28 09:54:35	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
838	\\x7dd6be602255575dc534075da66e55a70756ed91fa989ce46318377e2b87d69b	7	7984	984	818	837	6	4	2023-09-28 09:54:37.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
839	\\xae070a69f6b7cd93a2b229a2e1e7a96aacdea7288fd9d9c18376d0c1e8e88d6d	7	7985	985	819	838	6	4	2023-09-28 09:54:38	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
840	\\xcf0ed2ff57f4f131a235f876c5914cb5b047daef1cb82117ece3275f4eb3c544	7	7998	998	820	839	5	4	2023-09-28 09:54:40.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
841	\\x219d464d4242acf29eaaf3c836ca31d46af19465b0550c56af6deda6ace8a7e5	7	7999	999	821	840	18	4	2023-09-28 09:54:40.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
842	\\xb0d4389587c62bf15b4bdc5011949d9c4adfb755b185d74b97a0a543a38201e7	8	8020	20	822	841	51	4	2023-09-28 09:54:45	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
843	\\xc4ec1d5ad8eb69071a7a4c84368e137a3bc080164269d46006606b822b89c065	8	8021	21	823	842	3	4	2023-09-28 09:54:45.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
844	\\x09d65682a5183c7fdf4a5621cc844d9d13332e7e6a42c68dd1823fd80ab78392	8	8025	25	824	843	6	4	2023-09-28 09:54:46	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
845	\\xf91cf227a21f80aec08efb94c079ab9717e71c9a5dbb8d8bf21dbdd1dc0d8e0c	8	8032	32	825	844	13	4	2023-09-28 09:54:47.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
846	\\x0a93b5f4f5b39cd6885ff9bff614339c26a9b11459f6418279eba813502644de	8	8034	34	826	845	5	4	2023-09-28 09:54:47.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
847	\\x4b51e8267cb90e4e27d64161510178bc0571066a5c33ba9a48e6e3f1a2336641	8	8035	35	827	846	13	4	2023-09-28 09:54:48	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
848	\\x6c6dfd72766c04d827c2e10a9e8000ca6315d0db2432bad5f298e0586f0657c8	8	8039	39	828	847	9	4	2023-09-28 09:54:48.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
849	\\x5ab3f5ddf4c3715770f2dd3c7ac6947d6d9b135ed31f9c12465b538d16352595	8	8051	51	829	848	9	4	2023-09-28 09:54:51.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
850	\\x915d4cfdfeb444d637743f9a13777d305922c32cb05504570154a60533f268f6	8	8066	66	830	849	5	4	2023-09-28 09:54:54.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
851	\\xbdec9b36ea85e27ccc50ba94909b92fe27aea46b11091ab8c2fe3ac33b581a56	8	8071	71	831	850	5	4	2023-09-28 09:54:55.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
852	\\xc6649bc9f42a4e37f72e001d35cc4174d4053cc68c12cf885e82a21ac95357fb	8	8074	74	832	851	51	4	2023-09-28 09:54:55.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
853	\\x49367f04b4412aba1ff80e7e28fb25ab6f302e5b2e3552ff3f21d3efe79761e0	8	8094	94	833	852	7	4	2023-09-28 09:54:59.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
854	\\x34f607d4694b69895ede37447a4b990c42d9fd8e9f91656ff58f5798f7885060	8	8106	106	834	853	22	4	2023-09-28 09:55:02.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
855	\\xe609fc2ffb2f1f037d8247477a415059333fb1619759a7d29b5824d6f4f4e636	8	8116	116	835	854	7	4	2023-09-28 09:55:04.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
856	\\xaeb92a9c722f07290df45f3967e06c87b8eba7da95578b72d6e23c5094fe007e	8	8119	119	836	855	13	4	2023-09-28 09:55:04.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
857	\\xd0d2ccf286684c9f1af583a00245ad21cb851eb13dad9a6250ad80ed8b342aa8	8	8132	132	837	856	18	4	2023-09-28 09:55:07.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
858	\\x432fbd7c6320897c2f731f9f38858c8cdfb3318a83f696c0f4f8de4b92576369	8	8133	133	838	857	22	4	2023-09-28 09:55:07.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
859	\\x02c213533ffd450d49e1fca20909895d7635fb01eb55723cbed16e57ff915d63	8	8144	144	839	858	18	4	2023-09-28 09:55:09.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
860	\\x95c4486bb602a55182d7632bdeb81367d477ad6dde1e3e8f267b9e9cabd9f0ee	8	8152	152	840	859	6	4	2023-09-28 09:55:11.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
861	\\xa123289bb5868ffc69ed954151d25e157763f8f037924fe0d68851081ed371f0	8	8161	161	841	860	18	4	2023-09-28 09:55:13.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
862	\\x7030a04274ff114d1e37101d5ea84c43b39c8fcaecbbf5cda89d408690f5bd40	8	8191	191	842	861	9	4	2023-09-28 09:55:19.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
863	\\x36505780221255500c92311b811785951c5ace0daa51c6646455388a0a1de507	8	8194	194	843	862	22	4	2023-09-28 09:55:19.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
864	\\x6e520f5956a33bc40aef3385450c80cb80de517cda9309e3d147305bac2c4ff8	8	8204	204	844	863	18	4	2023-09-28 09:55:21.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
865	\\x57c1d9e79d78da1bdc02ac5074c437eb6c989b45c520c1125a8e9159dde73bfc	8	8208	208	845	864	51	4	2023-09-28 09:55:22.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
866	\\x990e3a6060a196dd548a411ddbdb4e4a30d2f0476a394225cdb135415f581888	8	8211	211	846	865	7	4	2023-09-28 09:55:23.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
867	\\xbe4325784b5825f5b6aed94e0882d2cf75ed8eb71e7a75d291256a2ea330e23c	8	8219	219	847	866	13	4	2023-09-28 09:55:24.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
868	\\x44cb5af6093a994ea7a54e6a5856a5ed1a8e99a224fd0e8a6920a5a3c9f2048c	8	8229	229	848	867	6	4	2023-09-28 09:55:26.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
869	\\xc0661d3245c0fe1f9ebebf722f4603780a24ee614c0845d849d8ac2070debf4a	8	8231	231	849	868	6	4	2023-09-28 09:55:27.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
870	\\x6826f0b113a028c97667ff05f23e311e4016812378c026acd8241c3b02f0273c	8	8234	234	850	869	51	4	2023-09-28 09:55:27.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
871	\\xf8a62b2d357a87e0cbdf7e80a7cf30a2af6ed0f8e80999aedaa47275471e246e	8	8235	235	851	870	18	4	2023-09-28 09:55:28	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
872	\\x9d629cdaa8c089ec3c587cfc9055e180119f516ab1bb63f2f5d156fcf4c303a1	8	8247	247	852	871	13	4	2023-09-28 09:55:30.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
873	\\x064299fcbd37b2b00ee1cae803f65f616fb3f930c3506375d8395e811c36021b	8	8250	250	853	872	9	4	2023-09-28 09:55:31	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
874	\\xa3fd96fe3e661137eff81dce5f1f4917cf434f903b0d7e890bebeb24736eb4eb	8	8258	258	854	873	3	4	2023-09-28 09:55:32.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
875	\\x6e51da76c602780459554e8bcf9f51a6e82f5307d2d53ab193ee5a4f436cdd83	8	8269	269	855	874	13	4	2023-09-28 09:55:34.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
876	\\xa41798f7d3eeb2c500948e0659ecbb8bca3efed984de503be06165fdbd876617	8	8271	271	856	875	22	4	2023-09-28 09:55:35.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
877	\\xc440efbc54f6ba30eae93412dacb4b409a34dda6b7aba9dad43502d4da9a6468	8	8273	273	857	876	6	4	2023-09-28 09:55:35.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
878	\\x90a02842b4f2842f0f69b3c81fd384b818d5fd94dbd631b819c0bede4efab4c4	8	8277	277	858	877	18	4	2023-09-28 09:55:36.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
879	\\xf676354f8fe9944f34db37a18ddad4febf412173ecf1eb02d4cde454214477cb	8	8280	280	859	878	7	4	2023-09-28 09:55:37	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
880	\\x6b8ac003c22c7978e9ec28039619c6e293bae4e18e065dceabd964f8509aed7e	8	8298	298	860	879	22	4	2023-09-28 09:55:40.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
881	\\xf22c449338e6412a775676d134d252898b89c4a0f4bed9e10477818434341f63	8	8305	305	861	880	5	4	2023-09-28 09:55:42	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
882	\\x7296f997cbffc969cc52e7a7fe4230862caf3ad09b69ef1d243ac5ce26a7499c	8	8307	307	862	881	3	4	2023-09-28 09:55:42.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
883	\\x3a947711ccb9fa79116bff223a5af33606b0d6ece354a5951451886195c2ee8e	8	8312	312	863	882	18	4	2023-09-28 09:55:43.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
884	\\x4e08c19866fc9a06e7ec1df821b6fae3a56452fbee91a62f94b2e62f02afea7e	8	8338	338	864	883	51	4	2023-09-28 09:55:48.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
885	\\x8e2abc82f470d85b754f490fc05f2ff32400df20c97c7b6924f861317d158626	8	8342	342	865	884	22	4	2023-09-28 09:55:49.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
886	\\xc54ea06c8f7ad0b62424c4ed8a68bded061dab0f69c31bc94fa69f09e6cfc43f	8	8347	347	866	885	5	4	2023-09-28 09:55:50.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
887	\\x8e9efafaca0670f0cf72b7ea1cc065c90a3117d6561ae162fd71199f34168faf	8	8348	348	867	886	9	4	2023-09-28 09:55:50.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
888	\\xf3c43daa06b3eebc1d87528f55bbb4e27c85589677518e098a84a30e6fb24921	8	8349	349	868	887	6	4	2023-09-28 09:55:50.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
889	\\xeba1b00044b6d44917c5a314c9deb4fcb923f7b1b5434338376bc94c8a79812f	8	8354	354	869	888	51	4	2023-09-28 09:55:51.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
890	\\xca42f40730907eab5dd6846769426d83baa3f96596c74041c8be01b806ad5459	8	8373	373	870	889	18	4	2023-09-28 09:55:55.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
891	\\x6e0a04502b7138e8e817843647b8c9424856a120ab20b714dde0962d398178bb	8	8392	392	871	890	6	4	2023-09-28 09:55:59.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
892	\\x9a3ebb4339c41e8eb2f8f4b0ac5a60483734baa0956ae9a10251a8cc220dccd6	8	8399	399	872	891	6	4	2023-09-28 09:56:00.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
893	\\x97251ee7501a6d645362e6933398424ca47f303a8b4136333d09cd28aa218a09	8	8415	415	873	892	51	4	2023-09-28 09:56:04	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
894	\\x067bcb8d5d09aef44bc402a857ab410698bc2665aa033e8528e0594431e23097	8	8420	420	874	893	5	4	2023-09-28 09:56:05	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
895	\\xb164efffc8c9c1ad803108245a3b60070a6c2630148a6217e7eb70c128e92892	8	8422	422	875	894	51	4	2023-09-28 09:56:05.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
896	\\x82d94930c979178be46ad6678f94a8d3530cd9a040960f242c3fac3ec365c864	8	8446	446	876	895	51	4	2023-09-28 09:56:10.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
897	\\xe4e1d9a8750362e62d0e4b4373ee613e961962d48d5a7bdbed6a402bb41ecf53	8	8447	447	877	896	9	4	2023-09-28 09:56:10.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
898	\\xafaba73916ccefc1587488b275e770358d2105684064ebf693d4f697e31b7c28	8	8464	464	878	897	3	4	2023-09-28 09:56:13.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
899	\\x80e73c5fb21a15205466b8d69c39a01ce965983caf035b6394dd649a5296d450	8	8478	478	879	898	6	4	2023-09-28 09:56:16.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
900	\\x8966d491e3f91fbcd30d850d7cea34c41ac97bc03e8f191c9c9121a8da502eb7	8	8496	496	880	899	3	4	2023-09-28 09:56:20.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
901	\\xf30b424918d687f871b42be711ca229ca28f2d4229949097af4094dae5c4d12d	8	8499	499	881	900	51	4	2023-09-28 09:56:20.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
902	\\xa470bd3eb8d3996099d4077986fe80337676fa95b1736d30a742ebf012da0d18	8	8511	511	882	901	9	4	2023-09-28 09:56:23.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
903	\\x78144a40fcedbf8b91e0690b0a264763ddae6b6fc398150118ee813c4b81a680	8	8528	528	883	902	13	4	2023-09-28 09:56:26.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
904	\\xaaa31a76aaa62f11cbda4469fb57bdb88d6bc618d686b68d5bfde11fb3349e36	8	8545	545	884	903	51	4	2023-09-28 09:56:30	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
905	\\x4c9aa2725a78ab4900b9cae0b6cf3b0ced2e3375c4ca0dbec5cbf6452f89852d	8	8548	548	885	904	3	4	2023-09-28 09:56:30.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
906	\\x3a50049282fa82415c49f2abc86a64400d86792925c1c82ba2f781214c94da1d	8	8555	555	886	905	13	4	2023-09-28 09:56:32	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
907	\\xdcea5ab0d7c977dc494adcfd67f51c7ae537019c7c592ff3dd8988c1bd3ee3b7	8	8560	560	887	906	6	4	2023-09-28 09:56:33	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
908	\\x0eac492d7f6abefe786cd8023079ae9321e6d995a1a15571708ef67dc600cbe3	8	8577	577	888	907	13	4	2023-09-28 09:56:36.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
909	\\x5e830aa4f9a6f844962abe59489d8b2b2ca8b93647fd47013bc002cb26607a92	8	8586	586	889	908	22	4	2023-09-28 09:56:38.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
910	\\xae1dec9f6a3ac0086034b2969323b20cd597f7bdd06b5939d1dfaf96e644c54e	8	8587	587	890	909	13	4	2023-09-28 09:56:38.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
912	\\x3fdfd4dba40ecebe5fa99457d1551a8931d631da9652cb8db52caec579ce1a17	8	8588	588	891	910	9	4	2023-09-28 09:56:38.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
913	\\x2af2ce0a0bdaea0a1ec1dce61f881d4e2e10dcbcdda75e60eea72811dd44eff1	8	8595	595	892	912	3	4	2023-09-28 09:56:40	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
914	\\x3bcdbba32be917acec0eaa21321a7fbce91888dbd1fa4bef67f6e3a1ac1ef910	8	8604	604	893	913	18	4	2023-09-28 09:56:41.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
915	\\x38d74b250a0e7d43219d6b419b86edaaf304b4d147b2dcd0a0da0777b8f8deab	8	8611	611	894	914	3	4	2023-09-28 09:56:43.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
916	\\x7d1c3568ad736ab6f30ae8fda3adde275b986b710712de628663f8a120794514	8	8615	615	895	915	9	4	2023-09-28 09:56:44	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
917	\\xdb7968f15b44c581d9947a5ed7a1d451918135b950aff5effdd2ca05962d427f	8	8632	632	896	916	3	4	2023-09-28 09:56:47.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
918	\\xc8c7fab853801c99c1664b48d3e0985109855a3caec7e7841973d9474e9df208	8	8633	633	897	917	6	4	2023-09-28 09:56:47.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
919	\\x46d92f392a7c40652e9407013f029a18e94ce69893394aafa8f189874e8c4455	8	8639	639	898	918	7	4	2023-09-28 09:56:48.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
920	\\x9cdc9e04035af5e9a322ed8269837b585e2c6cad45fd0532723a9a3ffa7fff8f	8	8648	648	899	919	51	4	2023-09-28 09:56:50.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
921	\\x18b0f67ef831a6eb596a8269032997de3ba5283d7a51627a762d5a18c56d315d	8	8655	655	900	920	22	4	2023-09-28 09:56:52	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
922	\\x07d8acb776d386b49d6bb36f39139c4302f6cb72e786edb2fe3de221e1187706	8	8658	658	901	921	6	4	2023-09-28 09:56:52.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
923	\\xb4c0065663cad6d90896b76677122e9c7eb8663aaba42dc03fdf2fe37dee60e0	8	8659	659	902	922	18	4	2023-09-28 09:56:52.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
924	\\xe114503379aa4be5fe4466690a88705c7e5cbfcd728f34adef020367dc33d6ce	8	8660	660	903	923	9	4	2023-09-28 09:56:53	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
925	\\xc7e37d807f6d23f01168e58a35bcdcde0963fe8db210952f29c2244641471536	8	8663	663	904	924	18	4	2023-09-28 09:56:53.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
926	\\x1cd3542c00c1feca62085aa92ea548677c77210cfe54555cc31c5d4a48394502	8	8667	667	905	925	13	4	2023-09-28 09:56:54.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
927	\\x2a93c80e2afaa03a49f50c252f834dc68f917f595ebcdaf39536a8174faf8f31	8	8676	676	906	926	18	4	2023-09-28 09:56:56.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
928	\\x7d4e6fef6e6a1032fd5a9108c1ba6f24ac6181df9591b72836e5dc82313ede4b	8	8686	686	907	927	5	4	2023-09-28 09:56:58.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
929	\\xbab2d62e36e5af1c9a9e4f5318ca06a6df293b050a01cb6299066dd3631f6dc2	8	8697	697	908	928	22	4	2023-09-28 09:57:00.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
930	\\x55390aa90d32d96f626d2d9dfb94be167d1cfda6a9585812cb3cae4a6f7078ba	8	8712	712	909	929	3	4	2023-09-28 09:57:03.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
931	\\xc4657041e9b8c6262e9757a7e195d02d2a53430f2b804ae17b8aead22d7a5153	8	8736	736	910	930	22	4	2023-09-28 09:57:08.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
932	\\x9ca27db1e9233b8da41ffa2e9308265c8b28edb6b4c79bc26e2de3cf50dc7f4d	8	8737	737	911	931	9	4	2023-09-28 09:57:08.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
933	\\x5649d3c4a76f184de74995e3acbf3d6608dad4dbe031c80cf12ce30cedf5ff2b	8	8768	768	912	932	51	4	2023-09-28 09:57:14.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
934	\\x4485654ff617c38e841a0dd189e22b662af208c057e5758d9fc0afca3f6f8c8b	8	8775	775	913	933	9	4	2023-09-28 09:57:16	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
935	\\x76b1c60486ba8d9a6c04a1b84b97aa2e384366355998bb4f21c48ff44615d7d4	8	8785	785	914	934	9	4	2023-09-28 09:57:18	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
936	\\x2e80c2f479527075bdb7cf9113a715bcd9ab1b5d34b09ac748366fda3bd08eb6	8	8798	798	915	935	3	4	2023-09-28 09:57:20.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
937	\\x03a70277a3b44e2ff051bad9fb55b867664c25da316fbad2a069d3e742ea7a6f	8	8799	799	916	936	7	4	2023-09-28 09:57:20.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
938	\\xdf1588005a12a70921fe36b5829712a9cdcba3dbd88b02a9ab116fd10144ac9b	8	8805	805	917	937	9	4	2023-09-28 09:57:22	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
939	\\x603e0799728823b9c9c6ee17a3703ea240a4eab902e51b201b54125f9d7e7b4c	8	8809	809	918	938	18	4	2023-09-28 09:57:22.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
940	\\xd6ab423e0897e479561e07748c58a5d3141dbb7a79131ea44aefae8e867afbf8	8	8816	816	919	939	18	4	2023-09-28 09:57:24.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
941	\\xd5f1910eb5d9a7f336cc54bf8fd35b68e1ff9078e954f337296df46b54554056	8	8822	822	920	940	3	4	2023-09-28 09:57:25.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
942	\\xd9270f103acab8ebbbdd0b3e0bb0ce837babd6e49528fa735b629398e2bf1eb9	8	8826	826	921	941	5	4	2023-09-28 09:57:26.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
943	\\xce2322fe3858db9a3a9143979edd4dba7308ee8ed06552bd89391df2835a5c3d	8	8856	856	922	942	5	4	2023-09-28 09:57:32.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
944	\\x286543143469dbd267d971d9ca0f4e271bf89d9a348708b1a5062f3e04763330	8	8871	871	923	943	9	4	2023-09-28 09:57:35.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
945	\\xdeed3bd50dcc0001a01a1edb4fdc4308a22e1ae35816e4859297998bd2b5fc54	8	8873	873	924	944	51	4	2023-09-28 09:57:35.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
946	\\x7fb3f8880dfd4337a49e3650f3037ecb1258a51e72fa74fb714a9a2754e4c27b	8	8877	877	925	945	3	4	2023-09-28 09:57:36.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
947	\\x2a98d5ba04da2843059900194af55d3cf8207887763999f2f36d2cae1024c43c	8	8880	880	926	946	6	4	2023-09-28 09:57:37	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
948	\\x478b0ccae78695b57fdb79a069a4e35e89f4bf55ed5c46546fddce0989c2f5c5	8	8884	884	927	947	9	4	2023-09-28 09:57:37.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
949	\\x444a594ebb9eb6bcab4b7f4c97ce3421e8e9c1573ef6cb0e94a25fa7a43e172c	8	8898	898	928	948	5	4	2023-09-28 09:57:40.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
950	\\xca7e8732947b1abfc5ee97d78558b3a98a69976729f731536103d9b3e3e812e0	8	8914	914	929	949	18	4	2023-09-28 09:57:43.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
951	\\x4113baaba2483368ebef21bae4608a4c0c2aea47216937fecea7cb532cafb22f	8	8916	916	930	950	5	4	2023-09-28 09:57:44.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
952	\\x29b449a3edaa4f9f51cbcf909622d906f970910462bfa04c5aa1bb5b2951ef1a	8	8917	917	931	951	7	4	2023-09-28 09:57:44.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
953	\\x06379a540cbb4537d626066a66a2bb2377f92b3e8d756ac3b4747e7b37164b85	8	8923	923	932	952	5	4	2023-09-28 09:57:45.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
954	\\x03dd77dcbfc852f68ecc0e70f30c046ce4ab7242d8d76abf396b26c802f5b8c6	8	8931	931	933	953	51	4	2023-09-28 09:57:47.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
955	\\x905c11a7e912575e65fbb4edd2582e4b6f1acda7b11fc52564e0ce73bceebe63	8	8944	944	934	954	5	4	2023-09-28 09:57:49.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
956	\\xe947ea7f10c409f9e3bdd8e8f28868ff75b71225d69cff3fd70f08b26d4e6b08	8	8970	970	935	955	51	4	2023-09-28 09:57:55	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
957	\\x0de7512f6ee7ef467fdf506eff328d0644b619010308ac8ad4e98df2e5f045a5	8	8976	976	936	956	6	4	2023-09-28 09:57:56.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
958	\\x010caf5e2fedc62d595c582d317e0892aa72dc24862912fb288509369257717c	8	8978	978	937	957	22	4	2023-09-28 09:57:56.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
959	\\x7ddce875abc4796cdafbfc5295dcdd39b39eb837b0126d1d3c7cc2a33b136ba4	8	8981	981	938	958	3	4	2023-09-28 09:57:57.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
960	\\x8d156d09428d1c7c4d159360a220309545a61c78dfa90e612045f119e7bfdead	8	8985	985	939	959	51	4	2023-09-28 09:57:58	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
961	\\x395bbb569714bde4035156e54e50f527e5cb38fbf754d9ca4a425cb9a90bb903	8	8986	986	940	960	7	4	2023-09-28 09:57:58.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
962	\\x4ff7c61e061ee842849af45756e706fcc71b18b04de659b99204fa04127c9a7c	8	8989	989	941	961	22	4	2023-09-28 09:57:58.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
963	\\xe24d52da95ac9dd8c5c214b7a199b38a68789238a795666274fe44235a958a4c	8	8990	990	942	962	13	4	2023-09-28 09:57:59	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
964	\\xe1caec456cc531cb6096f68ed243cf0357091b88de73d6cd00d3be998c384a42	9	9011	11	943	963	13	4	2023-09-28 09:58:03.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
965	\\xe36ee9c0a5c7cc8ecd5e995832863a31016da36e37b8101df6c4956e797c98c1	9	9013	13	944	964	18	436	2023-09-28 09:58:03.6	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
966	\\x09fd7d488e769434afdb3ffe99c5f85520f93e0020970073c577d941dbe98e76	9	9031	31	945	965	6	4	2023-09-28 09:58:07.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
967	\\x187ea1e30e4da9edbfcb8ebc8968537fefa840e8064e7c5c2e829b0d6f95a55d	9	9033	33	946	966	18	4	2023-09-28 09:58:07.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
968	\\x025510ee6c083cdaffac0cb286b032a87b822ed3773839c8d8afb2663e44727f	9	9039	39	947	967	51	4	2023-09-28 09:58:08.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
969	\\xed7bee72c0a476453397509ed1ed68c8771f121f5f15aa295dd4d321a9c0a677	9	9049	49	948	968	5	2182	2023-09-28 09:58:10.8	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
970	\\x0634637f127fed4d25c627afd7d12f49518e52b3a4892777f9e46ac7d9f81055	9	9061	61	949	969	9	4	2023-09-28 09:58:13.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
971	\\xc41a83950cbdb410781dc2ef861fe8ba0c16045bd8464f0d08963fe1364cb8e1	9	9077	77	950	970	18	4	2023-09-28 09:58:16.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
972	\\xb7daf8790f496368f5d0187ca91c235f6ea6f760364484350b83668294a14565	9	9081	81	951	971	6	4	2023-09-28 09:58:17.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
973	\\xfe2aafe018d3791ea2c25ade2cafe8282afd6b8233928bf32116ecebfbd9c2e9	9	9090	90	952	972	3	4	2023-09-28 09:58:19	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
975	\\xbefaed2b66e41e842e2431febcde31a4c28ee7fe6418274abc2e661462a22b74	9	9092	92	953	973	9	4	2023-09-28 09:58:19.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
976	\\x2e3abc409f8b9ac973e0a495fa3d929847e83900e3e5368777358e3b6eabbe75	9	9094	94	954	975	5	4	2023-09-28 09:58:19.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
977	\\xbd480fb2a0b2bc751c6839c9b74165aca59a828e5277e6f5de3a5f56a4b48783	9	9100	100	955	976	7	4	2023-09-28 09:58:21	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
978	\\xed42969901d9eb8d369914c1a787b3a1c8b9ae0ca9a566cbc719ad70f9b32e3c	9	9106	106	956	977	9	4	2023-09-28 09:58:22.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
979	\\xffdf83f7706ff3b23b886af624e25bbc39002e80db5949543f31997a3dc93560	9	9110	110	957	978	7	4	2023-09-28 09:58:23	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
980	\\x8b112216f08e5a30158f5ea48028b8bd9c37094e60eac004ca0b88064d81e9f8	9	9111	111	958	979	3	4	2023-09-28 09:58:23.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
981	\\xecfd0b14b8e8f68192432a09ae07a1fddb2426a442c39c0a3303d7f487fa2d7c	9	9114	114	959	980	18	4	2023-09-28 09:58:23.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
982	\\x0a07666810fec0cdce43e2fc320c898712c7e65ed52f0ed82031b1483ca3b8a3	9	9116	116	960	981	7	4	2023-09-28 09:58:24.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
983	\\x0838ba97046f310a8929c8ff00022122f62507135633c79894d45cdba04cc611	9	9133	133	961	982	5	4	2023-09-28 09:58:27.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
984	\\x169c1cc1b50b6f64a75ab281b758eab420cc907f1e04d083d3d2b7d496421d3a	9	9150	150	962	983	9	4	2023-09-28 09:58:31	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
985	\\x257e43b502628836d9f58d0ca953d0fc7c57b5ac010a7af73e7008a1ea3bc9fc	9	9174	174	963	984	22	4	2023-09-28 09:58:35.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
986	\\x06ad6ed15e9434732d7ed0adf17896982afce0f1cd025fa92040983a8d94bd98	9	9194	194	964	985	13	4	2023-09-28 09:58:39.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
987	\\x72b9a0dd6951ae24473d63e52fed0ffa49db85c817cef372310e061049b5b76f	9	9196	196	965	986	18	4	2023-09-28 09:58:40.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
988	\\x93cc923ac124180aaa772da37ce8cb6cc3cc0e38fcfa599f56679b17f7103b01	9	9200	200	966	987	13	4	2023-09-28 09:58:41	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
989	\\x8f4bb5e3ad01e028546ab2a1465be56a92d0c8acc277e632cae4dfcd10508eec	9	9202	202	967	988	6	4	2023-09-28 09:58:41.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
990	\\x30cf4d3a15145528c91ea809c40c5dbb596f800ecbb694a0d9d52d34c8483939	9	9208	208	968	989	18	4	2023-09-28 09:58:42.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
991	\\xb44861cb84deb425d02c717cb1ec7aa5f963d3a04821beeec25a1cd2bd606c1f	9	9221	221	969	990	3	4	2023-09-28 09:58:45.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
992	\\xa03934b2803e27ba3b96d4aa71b63420f4ba8ed674b68dcacd8d467b23737f11	9	9230	230	970	991	7	4	2023-09-28 09:58:47	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
993	\\x2a2c74cde94f990a554b2b0dcfb5b6c1b71db6a53853f3f8ef23d26f53f1f042	9	9246	246	971	992	51	4	2023-09-28 09:58:50.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
994	\\x052e2634d668499d94b8d847fa63e418e2ec9b9021c07233a8a9c9b2e1708fc5	9	9252	252	972	993	13	4	2023-09-28 09:58:51.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
995	\\x2f13e00f5251b3a0222c5b51db966a6fc507a804a82229c2ca41b6b655377da8	9	9254	254	973	994	7	4	2023-09-28 09:58:51.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
996	\\x10b0d803a2631b2db52eb074a54c52b8bf8c31dc88413969e6e4242cff4b5bab	9	9261	261	974	995	7	4	2023-09-28 09:58:53.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
997	\\x0f695579f5a853f90b49325e668b19c41004a0e54c1ce7f6a5723299b7ffe0e1	9	9263	263	975	996	18	4	2023-09-28 09:58:53.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
998	\\xfbdb5f6c6419f2fb43049679178105a281c38250b668717806b4cd49b02e24c4	9	9267	267	976	997	18	4	2023-09-28 09:58:54.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
999	\\xaf580b7f4f8f2ccd38652ab484f2ea009b9fdfeab32360516f19e30b8a7ed912	9	9278	278	977	998	6	4	2023-09-28 09:58:56.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1000	\\x3e2f4937b41237c51570af8a40b90900bd5e2c2e7e29cd4392f3831959c8961c	9	9279	279	978	999	18	4	2023-09-28 09:58:56.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1001	\\x17664ab76c12ca273760c5ae1f7a8df3003e2b6c998658c7c75c975df917ccd5	9	9282	282	979	1000	13	4	2023-09-28 09:58:57.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1002	\\x7663780f5dcdbf18122b61ee2d318578bebbd0025fde5ae8f2657b9f47a7e253	9	9291	291	980	1001	5	4	2023-09-28 09:58:59.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1003	\\xe821ed1fe0a844e33401b44a574761c8e5b5abee0a924442e281756253b17625	9	9298	298	981	1002	22	4	2023-09-28 09:59:00.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1004	\\x5145ceba44f18294e4182c8e3e5407fe260a550b621089349239a02042176af6	9	9308	308	982	1003	5	4	2023-09-28 09:59:02.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1005	\\x723142652e0964589db5ce14d6348c42868803537f6dbab8df2f023df1390955	9	9311	311	983	1004	22	4	2023-09-28 09:59:03.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1006	\\xab796e450358721f4f82c1e4cd981b58412de3d0577c471c3eea0cec2be0fbfb	9	9316	316	984	1005	13	4	2023-09-28 09:59:04.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1007	\\xe88f110b5af3480c55697583f4b0ac76c0de65e57d32abe0a04c4a2f47ad3a81	9	9321	321	985	1006	18	4	2023-09-28 09:59:05.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1008	\\x8a85c3247587c7e3930085e642fa0e5e2d91d573e65ce418cbbecd91a81d3efa	9	9325	325	986	1007	9	4	2023-09-28 09:59:06	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1009	\\xf97b7976d04fd2093a89ee90516f72c75249be5138ac9ea4709e34919ca44e74	9	9335	335	987	1008	22	4	2023-09-28 09:59:08	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1010	\\xd1924c35f4f14125bfadc74a0d01cd837057cb65ef97b8d11ea2dfc1e5b4c130	9	9337	337	988	1009	9	4	2023-09-28 09:59:08.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1011	\\x6e1b40d7649a5b96d424cb77c9197caa326ca5e6884b02469ed8b1dfab208e7b	9	9353	353	989	1010	5	4	2023-09-28 09:59:11.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1012	\\xc95f322718d021f53f739dc0e0292488cf4c3355298e8dc878e0c587f41fedcc	9	9359	359	990	1011	7	4	2023-09-28 09:59:12.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1013	\\x3563e5a2b689edaf78215f53574232bb2021cf751378d1767996768cd2e7bf54	9	9370	370	991	1012	5	4	2023-09-28 09:59:15	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1014	\\x1bd99d46ac77212961007381aa5d4ed62ad7924d09930f7cfab93d652761b137	9	9385	385	992	1013	22	4	2023-09-28 09:59:18	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1015	\\x4e4d208c355294d67ed5520a5e959001a8d6060ca4896c1c2764c4c05be1ac08	9	9389	389	993	1014	9	4	2023-09-28 09:59:18.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1016	\\xf5c4c4138bcc43c031f6f0040cf96eda0288b0e01ec3e4b9f2596638e521a74e	9	9408	408	994	1015	7	4	2023-09-28 09:59:22.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1017	\\x212397d58c9c4b6197ce2f69463bf8242d3e423b6ad180d439a7084f71b3d719	9	9422	422	995	1016	13	4	2023-09-28 09:59:25.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1018	\\x3cc77a3c9ab14dc21fc44e6fe2bd5da4c0c7773b2cda31c166a2b4bd3a0e887a	9	9428	428	996	1017	9	4	2023-09-28 09:59:26.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1019	\\x37a0b3f090c38774fef67edd3175951c99eab394dfb1ec28132a07955bebaf90	9	9433	433	997	1018	13	4	2023-09-28 09:59:27.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1020	\\x83f4141f5b66e3749b63e63fc509455b36007e20efb2c8070a52d32978d01500	9	9461	461	998	1019	13	4	2023-09-28 09:59:33.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1021	\\x57beb09643accabd385d1af93c433825f6ed39e73244ae60ff7597f555a94332	9	9495	495	999	1020	7	4	2023-09-28 09:59:40	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1022	\\xd0d46c1fe04368178436554d20ebfbb033165e732a0d99f3a0dfae02cce31172	9	9534	534	1000	1021	51	4	2023-09-28 09:59:47.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1023	\\x2156a25cd16c4849c93590b87c97c8df325b2208a09a07c77d33e6bebdad9fa6	9	9548	548	1001	1022	6	4	2023-09-28 09:59:50.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1024	\\x375d47cb62f6d9131b691c703278059b296d4a8b199c3a4bec042db8c7f3fa26	9	9557	557	1002	1023	6	4	2023-09-28 09:59:52.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1025	\\x1cda476671b2fd3422d42e92a10ce33d87292a63e12fef621adebc1cffcddc32	9	9570	570	1003	1024	18	4	2023-09-28 09:59:55	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1026	\\xda4409d90c5eae60b4486acdc5219872d1ea632a26c6327c6dca58123c4dca88	9	9575	575	1004	1025	3	4	2023-09-28 09:59:56	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1027	\\x167ef257395e577ea773dbc535d15d6b78e0e5a4111cf48faf3139e2e49fe71f	9	9576	576	1005	1026	3	4	2023-09-28 09:59:56.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1028	\\xb7703d5801d70e1b2e612b0b181f16415097c122878937d756893cf31726497b	9	9580	580	1006	1027	5	4	2023-09-28 09:59:57	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1029	\\x7ca704387ecdf350451979be0ec4a148874719207c249dac1187c0cc175e9719	9	9596	596	1007	1028	6	4	2023-09-28 10:00:00.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1030	\\x29d23c55a344bd162a8290fd0d8b2d1828861f3675518994915b63b94652ce29	9	9603	603	1008	1029	5	4	2023-09-28 10:00:01.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1031	\\xa870301f18053bc44f2f0cb35191bac871f08caba68f2de2a9a5a33c7cf45e90	9	9623	623	1009	1030	18	4	2023-09-28 10:00:05.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1032	\\xd32ece08ce1f2d98715ec320f8a7299c0e7867ca5b7cc71e01485c762adcc7b1	9	9626	626	1010	1031	7	4	2023-09-28 10:00:06.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1033	\\x25d447f2b6cfb33cc26026ec14a1a4c5c1124af771d4cb1409f77b56262ce3ab	9	9630	630	1011	1032	18	4	2023-09-28 10:00:07	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1034	\\xe18592c74fc6ce1e15e9e20c721af244901120237ef181962485bba4020acc7f	9	9639	639	1012	1033	9	4	2023-09-28 10:00:08.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1035	\\x62739d9ea52fc2a7b66ef99ccf4fa90fc0bcbb1e884e83068ccac56932e273b7	9	9647	647	1013	1034	6	4	2023-09-28 10:00:10.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1036	\\x4c558e5def4ba4e8f993e0fad2bd9a5d99d5a04ff6c025a0941068f8e56fa017	9	9649	649	1014	1035	3	4	2023-09-28 10:00:10.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1037	\\x953375de7e4927f917e8c4f2bb78a2fafd1f1bd8360e1e264902bf01656c3fff	9	9653	653	1015	1036	7	4	2023-09-28 10:00:11.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1038	\\xeaf5c90f27cd5f9b23207d919224f0c183c076d14aed2032ac0d97f3440720cd	9	9666	666	1016	1037	51	4	2023-09-28 10:00:14.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1039	\\x67656f98696ebe3443e6a766db1432b2810a8651cd427ae18a56b72da213e8e0	9	9675	675	1017	1038	22	4	2023-09-28 10:00:16	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1040	\\x013877418cb7a185eb679b8b9d6748f52199029d5786904e13acb5ddfbe76c2b	9	9683	683	1018	1039	13	4	2023-09-28 10:00:17.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1041	\\x2c70faa9ac0b2be4bb136ca47d719fc5506464e0b10f9a8efa0e694e9e4c1f34	9	9684	684	1019	1040	18	4	2023-09-28 10:00:17.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1042	\\x5ac2ea172e67270193fb575bd04ce8bbab03bf9fb53184ff310462632f6e83b1	9	9710	710	1020	1041	13	4	2023-09-28 10:00:23	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1043	\\x16173bedcf3a96cfd25cc2d4a129f071217ccbc44e4acd952b8158828a5eff25	9	9724	724	1021	1042	5	4	2023-09-28 10:00:25.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1044	\\x6d60feae386d6af8a7f07ec36c57ff0cdeef06e7e9e2ba362dfd6e7f65f412bf	9	9755	755	1022	1043	22	4	2023-09-28 10:00:32	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1045	\\x1b0a0b05f891767cb778fb5ab8c62e0b7395f3ae7865f0b6ecc49ee84596608a	9	9761	761	1023	1044	3	4	2023-09-28 10:00:33.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1046	\\x1af03f851b065b9bd8a9e33e1874d26c656da9393acc24aeccfa65af6f52d289	9	9762	762	1024	1045	18	4	2023-09-28 10:00:33.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1047	\\x1d6129e9da6cea2fb228d75fc43aad2b252156d5e390d11ecdebcc28bcdd2d0e	9	9764	764	1025	1046	22	4	2023-09-28 10:00:33.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1048	\\x3be21ade3cf65783c10175d2d0ce0f72ff235b61b889ec9421f4b17356ed17cc	9	9797	797	1026	1047	9	4	2023-09-28 10:00:40.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1049	\\xe8eb6e5b47f22cdd818bbfaa1da717e86bd503f24dc27c88b21567315fdb5289	9	9799	799	1027	1048	13	4	2023-09-28 10:00:40.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1050	\\x1a4589364bad2993324d2992dddc90e3fad073adc6ac3d79550bc3f9872222c2	9	9807	807	1028	1049	5	4	2023-09-28 10:00:42.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1051	\\xda0416d12ec6316e0a35caab9631b67b4ecd189a109755b7975669cb0876e2c0	9	9819	819	1029	1050	13	4	2023-09-28 10:00:44.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1052	\\x2e4d1dae9e45e974cb4ddcb57825759f1aa206b9b815977cf19ccef58295dd55	9	9832	832	1030	1051	6	4	2023-09-28 10:00:47.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1053	\\x40fb2c5d47bc29d9004720ce32c4d5073e7c2df050ecfee263d63d5264384e4a	9	9844	844	1031	1052	18	4	2023-09-28 10:00:49.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1054	\\x5fffc6514874ca614ed517a2b588e740b7dad7a7547870bd5a43ce97df10514b	9	9845	845	1032	1053	51	4	2023-09-28 10:00:50	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1055	\\xb65f2fb6f6db43c4b867f0872029423a32df10bcae59353408b444a3f51cfd34	9	9856	856	1033	1054	13	4	2023-09-28 10:00:52.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1056	\\x940b180ec475cdf240a9de05255cc25db43b8a01382926cef73ca9a75220318d	9	9876	876	1034	1055	51	4	2023-09-28 10:00:56.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1057	\\x7730dd71bbf0e744dad30fb3c4cfeab54a7090743a1dce1627a549dcbeaaca20	9	9881	881	1035	1056	5	4	2023-09-28 10:00:57.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1058	\\x8f101e194479584131b45375445dce9e8cfef43a3c3f55ba696365164fb0b380	9	9901	901	1036	1057	5	4	2023-09-28 10:01:01.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1059	\\xec9066d5502633a112c99bea1fee0facdc286d39e243be2966b5ae838055e4c0	9	9919	919	1037	1058	22	4	2023-09-28 10:01:04.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1060	\\xc697759d3799a0351862df86a9799bd905b1da9c7d4abfe0b88267f82c6acad4	9	9928	928	1038	1059	3	4	2023-09-28 10:01:06.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1061	\\x244e58ab358e6876d68ec97fafd55d62d960cf3a3714b04c78489dbf6e98207e	9	9932	932	1039	1060	9	4	2023-09-28 10:01:07.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1062	\\x06dada96c759689658e59c1c2e032781ed971cbea2cc3358dfb69bfd0527131f	9	9934	934	1040	1061	51	4	2023-09-28 10:01:07.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1063	\\x23b85df7d1d9bc569ed8b4505f4c61cf134dd15037506bda50dd5e637b21490d	9	9935	935	1041	1062	51	4	2023-09-28 10:01:08	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1064	\\x18155fba8a0696dd928cd03a0e8746a169df71f9c1cddacbd447171cabcff381	9	9950	950	1042	1063	5	4	2023-09-28 10:01:11	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1065	\\x5e90f9debad0f092ab6cf5c89dbdfd90979d06cbfe76b01dbfc55097cc242cdd	9	9953	953	1043	1064	18	4	2023-09-28 10:01:11.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1066	\\x8e4feedb6745aae351ecf65c94c3d5ea75b98da5d3d2bc2bde0b7c5e33b95c0e	9	9971	971	1044	1065	3	4	2023-09-28 10:01:15.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1067	\\xd71d8956c2be5c47d957c13900062263e698dc9b88073a1ab5987f99e3d5eee1	9	9973	973	1045	1066	22	4	2023-09-28 10:01:15.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1069	\\x0d426b7a6913c4b058ae464208e1d80eb0e1ed588e8e5a2a0d681182f1a8e428	9	9987	987	1046	1067	22	4	2023-09-28 10:01:18.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1070	\\x6bc78d35af3b395187fc5024d050248627f98bf36ba5b4ba1ae793be86587c44	10	10000	0	1047	1069	7	4	2023-09-28 10:01:21	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1072	\\x4ffc0a4c02f9badbd47c9917d373b30f0b42236d9e81e0b560090697cabaa7a1	10	10010	10	1048	1070	3	4	2023-09-28 10:01:23	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1073	\\xaa3cccdf6ea9deea16c71b04aca366e7ce177b668487ea48da47b112bc805feb	10	10028	28	1049	1072	7	4	2023-09-28 10:01:26.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1074	\\xcdc1343d7f7ef47e36150307723f5613d2925dbf54d3a49fa9d5ec198f0e89f3	10	10034	34	1050	1073	9	4	2023-09-28 10:01:27.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1075	\\xa5d84b4a1a86d9a1f12d285531c0d76f1b4bfac1ef3053ed431610ecbf7c01f6	10	10054	54	1051	1074	22	4	2023-09-28 10:01:31.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1076	\\xe5039c62859e7239b31b897830e77e411468791f3d1c3014848c6275d41433f7	10	10059	59	1052	1075	9	4	2023-09-28 10:01:32.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1077	\\x55722f852d6ea511edf4f647c9e8fa7b10d202daeb6ee2512fb61c58fc3ad8b4	10	10102	102	1053	1076	18	4	2023-09-28 10:01:41.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1078	\\x4cd6a27e214d3641981f3e6d54a38d141e0e262ab30f0adf91f8259df1c0f3fb	10	10119	119	1054	1077	13	4	2023-09-28 10:01:44.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1079	\\xdddaaf27caad8386fc8b6c63e773a0e4fa04ae797c78f3127eb878d6ee318a9c	10	10120	120	1055	1078	22	4	2023-09-28 10:01:45	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1080	\\xcd6dcc509309fc9d8dc99857590a03b7d6089f45ae36072f1541d55c7e9d4b66	10	10127	127	1056	1079	6	4	2023-09-28 10:01:46.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1081	\\xea9447edb45447da180610c4ccf63518fa8ab2df39034dbdedebb4b96c5fda30	10	10134	134	1057	1080	22	4	2023-09-28 10:01:47.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1082	\\x569ff7037bd751070d29c7c45ed5561d1faa5998c7f6ff7b9ccd1ede39394a93	10	10137	137	1058	1081	22	4	2023-09-28 10:01:48.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1083	\\x35de68f809fafb92116b6dfb7b67dfbc6701a2883219757690368cff392cc72a	10	10138	138	1059	1082	22	4	2023-09-28 10:01:48.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1084	\\xaab7790a2a175fb784ab93952e7769ebd0a21c33405392de032fc9a66f2798fe	10	10140	140	1060	1083	5	4	2023-09-28 10:01:49	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1085	\\x6120e7ce912d2165d99c265301ee3b1f3357dfb96d4b1e2ce78d4388103315e4	10	10147	147	1061	1084	5	4	2023-09-28 10:01:50.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1086	\\xdb1c32791ebf774fe4999a662f3f684e8e869ed64c70d6fc826f1c4f8dd3ddba	10	10163	163	1062	1085	7	4	2023-09-28 10:01:53.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1087	\\x7adf1f8858dd26d3e631872552062cef3ce019a6cdc518e0a918edcbafcb584d	10	10169	169	1063	1086	18	4	2023-09-28 10:01:54.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1088	\\xbaf63b71740f507a5328277baba089ee4298f1de79a0ce25cbc23b30f9b4007a	10	10172	172	1064	1087	22	4	2023-09-28 10:01:55.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1089	\\xbab6faa3c477fabe53e0bc6c7271decebc202ae2c256e2618bffd624ea90e765	10	10173	173	1065	1088	3	4	2023-09-28 10:01:55.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1090	\\x70f542fc3af0d7b2f5569ef6ba1ce4bc56340ffcc2e7a0b5a1709c03cf3945be	10	10192	192	1066	1089	9	4	2023-09-28 10:01:59.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1091	\\x4bb2b62164253a9454548502fda75461cb517d0892df8f17a83a59216ef4ec01	10	10235	235	1067	1090	6	4	2023-09-28 10:02:08	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1092	\\x880c43b7e7a2fa2292ea77196c48d534e7aedfb7b626d5cbd45dd1e9c461a1f0	10	10244	244	1068	1091	3	4	2023-09-28 10:02:09.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1093	\\x2f3d5017339b2963dc5b48f2d498db91f3e4c661fcc0230108690113be15301a	10	10253	253	1069	1092	7	4	2023-09-28 10:02:11.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1094	\\xc6add45f1d3e69aee6b9479202ddd9267f8d22c3e6fbbe97bf716aaba0f73012	10	10261	261	1070	1093	18	4	2023-09-28 10:02:13.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1095	\\xef5aa159dfefe803024b6efb24e35c721f59a220b13bb9b1f5ae4c7966cec656	10	10266	266	1071	1094	5	4	2023-09-28 10:02:14.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1096	\\xbceae643265f71eb40dec8881d0cb44d69455fa1b84b560803290956da54bd49	10	10289	289	1072	1095	6	4	2023-09-28 10:02:18.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1097	\\x4c234d9d84bf851a9597093d73ed4bfff93f223b064a4e99b70dc18ff6398d83	10	10291	291	1073	1096	3	4	2023-09-28 10:02:19.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1098	\\x0d57468f2076415049b15c2e6a07782f504c169aa18b190f744be1cdb9d16c2d	10	10326	326	1074	1097	7	4	2023-09-28 10:02:26.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1099	\\xc77a3e88d1be775701410cd80935fd385706365e06ee53ad01786d6603cfb2ff	10	10347	347	1075	1098	13	4	2023-09-28 10:02:30.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1100	\\xb77d5d9af20ff1a8dfd6cb357af4517ecbadd8ebf55d312a60938e88fbb255c1	10	10352	352	1076	1099	6	4	2023-09-28 10:02:31.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1101	\\xa7aaea03f1733b629d6257747ca23adf8ce553d7a2d4528fd5dbc013ce0394d4	10	10354	354	1077	1100	9	4	2023-09-28 10:02:31.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1102	\\x962c21d1e25754aa88b4b4701f4d1dcc777168e0596e0d26ce15933ea52d922f	10	10363	363	1078	1101	7	4	2023-09-28 10:02:33.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1103	\\x0152771e44f79883a6d86099d68e64e752f99a2e650ad37e1a9e384894c266e0	10	10366	366	1079	1102	5	4	2023-09-28 10:02:34.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1104	\\x58d75e02f8fd985abd13efc0ae0a4d658432728388f85248a541dd098cdf7051	10	10368	368	1080	1103	5	4	2023-09-28 10:02:34.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1105	\\x37333320f17095fa0ed60ba42a2766c2ca7dd556419c72c983a96e96f8a58534	10	10375	375	1081	1104	22	4	2023-09-28 10:02:36	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1106	\\xb396183213a8775dd4aac84fb7e126e7e902317eacd3e6bc14e67870f28adca0	10	10383	383	1082	1105	9	4	2023-09-28 10:02:37.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1107	\\x73c6093ae0e5d1783b9cbe22244f551ef5b5665501c9c8ed73b1e870d4ce3f2f	10	10387	387	1083	1106	6	4	2023-09-28 10:02:38.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1108	\\xe25c3ac73d4c9bdba740a78f534b5c423729990344f709c4e4228a5a62412c7e	10	10398	398	1084	1107	13	4	2023-09-28 10:02:40.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1109	\\x5dbae7857e7674936b984259cbf33c5686599b7fb716d7b11ececd8947ddaa41	10	10406	406	1085	1108	13	4	2023-09-28 10:02:42.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1110	\\x30f5651e17733d9fda52ac7778f993ff837e752b3eaf4cd3d6066cc5de12f681	10	10409	409	1086	1109	7	4	2023-09-28 10:02:42.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1111	\\xd8187f9c3f35a3a0c63b96c1cf566a54173e9645daed158017ab16aa74544c75	10	10422	422	1087	1110	6	4	2023-09-28 10:02:45.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1112	\\x4921b14274c2dd918ed0e69b7f16200488bfa5d887e8b8657231368ab59d86b1	10	10437	437	1088	1111	18	4	2023-09-28 10:02:48.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1113	\\xb43416d4993928e83e796985aeae28c5d503b350e89c262b5c2155cdaaf0988e	10	10438	438	1089	1112	5	4	2023-09-28 10:02:48.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1114	\\x56a37d0c60860e180015bea80e29489e109f884bc70ed2a894044be5e96a0e7a	10	10448	448	1090	1113	18	4	2023-09-28 10:02:50.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1115	\\xd36d067cd55d159e3cf2cbcc2c15fa6e3904e5b4600224224a7c8f15e4685e20	10	10450	450	1091	1114	3	4	2023-09-28 10:02:51	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1116	\\x3ace3f9dcd3b5b6d3d8fcff815eca27d50ecbf9100f3a915f7bd480841919d7e	10	10457	457	1092	1115	5	4	2023-09-28 10:02:52.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1117	\\x845565b172f8d64832b174968b6daca4d6fd0873683ce6d41e45c1170d89f0ce	10	10463	463	1093	1116	7	4	2023-09-28 10:02:53.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1118	\\x4cf6d24598ee12958510b81a0c7181197f3832ad4147699ea19d4037d79bfb8f	10	10503	503	1094	1117	22	4	2023-09-28 10:03:01.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1119	\\xc401a4ec218b58cffb87193c75a3a44a7f3351ee45bb25a4dd2e27d1d71b3278	10	10504	504	1095	1118	51	4	2023-09-28 10:03:01.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1120	\\xec31a8f50dcc7627b07fc0ec8bdcf86666bac9b266eebd4235db787fee0403df	10	10505	505	1096	1119	9	4	2023-09-28 10:03:02	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1121	\\x6e4c788295d832a9073a2bcb5b3f2681f0f1d1cce314656241c25704a023e83d	10	10509	509	1097	1120	18	4	2023-09-28 10:03:02.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1122	\\xe1234fdafe0ab4610fe02f35814aaa2c5bd6b88f5a96fad304b2ad416f5bd1d3	10	10512	512	1098	1121	5	4	2023-09-28 10:03:03.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1123	\\x533f0165ad03f4515ef58d793180ba6e042943c20b30083d431f183b4e6778f7	10	10534	534	1099	1122	9	4	2023-09-28 10:03:07.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1124	\\x762aedb903716a8b415aa025fba0d0c5d6e670848290bf3527f177dba1ff38c0	10	10536	536	1100	1123	9	4	2023-09-28 10:03:08.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1125	\\x2befa9cc712557bdb305593e6355fc9253983482e09494282d61490218fcfbc1	10	10548	548	1101	1124	3	4	2023-09-28 10:03:10.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1126	\\x9d3197a01858b90cc7fb15c4eafe3947d49e4ff011852bc6d2336b4a115161a9	10	10559	559	1102	1125	13	4	2023-09-28 10:03:12.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1127	\\x811716086dc284aa0d86377d139bce0b4ce799225fcbc38eb77a21aaca5b515c	10	10587	587	1103	1126	7	4	2023-09-28 10:03:18.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1128	\\xe962ca9b7c0b9211b6495e822fc894c0968c3bb54caab95ee2dec98cd2da9185	10	10601	601	1104	1127	18	4	2023-09-28 10:03:21.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1129	\\xe74526ffa83784f95eb2bec4e6b951466340098d9b3a97b69755ab8fac8c8bb5	10	10609	609	1105	1128	6	4	2023-09-28 10:03:22.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1130	\\x7960dc112e0a09c5431eab0daf37f628df67e578f67549eb0899db47b63ecfad	10	10612	612	1106	1129	51	4	2023-09-28 10:03:23.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1131	\\x4c21c3883e43ee4bd169b4f7278b50da85b3fd75e1d73917d9c3193181788ffb	10	10626	626	1107	1130	22	4	2023-09-28 10:03:26.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1132	\\xb14a7b901035e4ac955b2bb685f6b6813f555b04c0809dd92cc33de79ee81943	10	10637	637	1108	1131	9	4	2023-09-28 10:03:28.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1133	\\x065177fa8190152b9592f103787de0978bec1224bf24c4cbdf34f30cd92f685f	10	10651	651	1109	1132	18	4	2023-09-28 10:03:31.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1134	\\x7d71e6fe978d810580a24fb96ae378fd3d93b3bf01dd809cb5a7734066c43047	10	10658	658	1110	1133	13	4	2023-09-28 10:03:32.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1135	\\xffb8159bed5c7423d9954de648d387e9886edf62fc03dacf1ebee45ac9609092	10	10673	673	1111	1134	3	4	2023-09-28 10:03:35.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1136	\\xf7199fd2e62300cc2326e85d0cac2b767271477e697c5caa8e224c7ca283347d	10	10692	692	1112	1135	6	4	2023-09-28 10:03:39.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1137	\\x44a7836b2bc218f4318e289e1feb403e0b9f97371eeb2f837692a224713c0392	10	10699	699	1113	1136	7	4	2023-09-28 10:03:40.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1138	\\xe531d231b66299fe3a9acbd11431a3e62d877632233dd10400f4a6a78a553ad5	10	10708	708	1114	1137	3	4	2023-09-28 10:03:42.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1139	\\x7865ee3f2976163c6fd114b5ec92e33650562a849d87cf9aadcec65baa8885cb	10	10721	721	1115	1138	22	4	2023-09-28 10:03:45.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1140	\\x29a4141d3ca0f8fcd286280a06c73961c159849ce2cce320ec1e3fdc90b49b94	10	10737	737	1116	1139	22	4	2023-09-28 10:03:48.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1141	\\x5ce5ee4d830a213c56c66e9569d0a9bea73b39823e42cb1a51f2f74a037ddc59	10	10754	754	1117	1140	5	4	2023-09-28 10:03:51.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1142	\\xdc3c9f83d216630bbd662b6cf2baf644735983413057f938ee3ae65b8c73f2a0	10	10756	756	1118	1141	18	4	2023-09-28 10:03:52.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1143	\\x6cf078883027c2d534f18eb142b2b4f394c73f85d191051566c55c3123e82255	10	10779	779	1119	1142	51	4	2023-09-28 10:03:56.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1144	\\x3387acb56701194668612e42f691bc5c7f7132925b8f782f6e5ddc38a666f814	10	10783	783	1120	1143	5	4	2023-09-28 10:03:57.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1145	\\xf90e231464eed801b82ed28da5b57a963fbc7599d4aa34baa44cbbf9cf513d87	10	10786	786	1121	1144	5	4	2023-09-28 10:03:58.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1146	\\x27d579bf672e80cfa92d8d6989be3d5ec21e63617e8e1863441685b534cf38ef	10	10788	788	1122	1145	9	4	2023-09-28 10:03:58.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1147	\\x913791351cfbc83b528612a5723852cd400b55579cb29b5516efb80b764892d1	10	10803	803	1123	1146	7	4	2023-09-28 10:04:01.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1148	\\xf4d393bbf00b96c6679bf859cc16f032adbbb8a6e40f627b87e22f2c51c71e8e	10	10810	810	1124	1147	7	4	2023-09-28 10:04:03	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1149	\\x2c57ef6d9b52a90a05fe4fde20b3b9304e584c570372d3c0fba34446ae50582a	10	10824	824	1125	1148	6	4	2023-09-28 10:04:05.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1150	\\x79c737dbc9a202d45d6512089181232ed71845fa69e5791b4f7ba7009a49fcc2	10	10836	836	1126	1149	6	4	2023-09-28 10:04:08.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1151	\\xae5ec97bcf1bf633259b1e4b7b7b10edf799dbe6375bb7dd14ed1e1eef8e79a3	10	10851	851	1127	1150	51	4	2023-09-28 10:04:11.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1152	\\xf20a8ebeb4c5c1d302b83848b0c5b7439ecf929b108b3212337a5d8b17577178	10	10857	857	1128	1151	13	4	2023-09-28 10:04:12.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1153	\\x3289fcd9dfb82a43eef8fdfae6f83a979288258033fa4e37d3f31d7583ac5c15	10	10863	863	1129	1152	13	4	2023-09-28 10:04:13.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1154	\\x84dbcd72ceaa8e7b8678f6bb36f51f15beb4e3063edaf29503ba1bc47fcb9669	10	10872	872	1130	1153	6	4	2023-09-28 10:04:15.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1155	\\x112863e1b8e30f19b291dd06ff5dfe4b9882fe453e3d063b175afb8dd71e8e8a	10	10885	885	1131	1154	6	4	2023-09-28 10:04:18	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1156	\\x90ab135605edf99b79fedca00dc71264fa24398ad44815dba326d816f3509b49	10	10892	892	1132	1155	22	4	2023-09-28 10:04:19.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1157	\\x0f22c5b1755a59738a554d8abcacb4c121c7431582bfb366b4fae8acd2f03186	10	10894	894	1133	1156	51	4	2023-09-28 10:04:19.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1158	\\x876fa933581171aafd83e33b8ba4ea5de4551d45bb49e9f31241e12a943161bf	10	10901	901	1134	1157	51	4	2023-09-28 10:04:21.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1159	\\x74bf2498c255ea4e8bdcf98c59d9cee9147aac7eb49497eba420e39b625bd3bb	10	10948	948	1135	1158	51	4	2023-09-28 10:04:30.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1160	\\x8c371e64e07bfb6df49f024867a72bcc08ccf6ae840217b123ceeaa1ffba062c	10	10953	953	1136	1159	13	4	2023-09-28 10:04:31.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1161	\\xfe90ee01d6defddabb22ab585ace010d3a0a7458ef83dda04ee06affefd6d620	10	10970	970	1137	1160	5	4	2023-09-28 10:04:35	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1162	\\xa209917d2a838f320768b36c1688bc301f59303d98ef03f64503365428a96cb7	10	10971	971	1138	1161	7	4	2023-09-28 10:04:35.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1163	\\x87012161411546ec0edb0a4ce075c553fc3dfda7136c0d378f82290eb4f0bd4e	10	10978	978	1139	1162	9	4	2023-09-28 10:04:36.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1164	\\xb8ec4373ca944cbb3f749f47de10565c711ba89e7a1f43aad2afc2c35a57f58e	10	10993	993	1140	1163	18	4	2023-09-28 10:04:39.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1165	\\xfad292c7029082bceea4cd2cfbd042edb1c4e2cf77f214704720632abbf035ca	11	11008	8	1141	1164	7	4	2023-09-28 10:04:42.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1166	\\xd6e3632495613e2605f76c4025147394c27f41023742daba8a50c22ea1be6998	11	11013	13	1142	1165	3	8549	2023-09-28 10:04:43.6	28	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1167	\\xa4e5f97ae6dc7e08274ab16099851cbd5f8f6a052c03c34373669f21e693b6a5	11	11015	15	1143	1166	18	2962	2023-09-28 10:04:44	10	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1168	\\x3a9c5c7b1d7f5df46fa19f539773ab300782dce88e4660e04a83da291d4dacef	11	11025	25	1144	1167	22	18618	2023-09-28 10:04:46	60	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1169	\\x3050c14573beaf81a614ae1266cf8a6c15ca4092ff3aab3636c492dd17d90cd9	11	11044	44	1145	1168	51	646	2023-09-28 10:04:49.8	2	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1170	\\xbe069483be93fac570f658178de20a9c104263ef348f6f6b25ee879b7f3ad5cb	11	11047	47	1146	1169	5	4	2023-09-28 10:04:50.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1171	\\x67294c8c6393bf8d9bcbe93da696b86bbf95d11ae64bfc3f78ade9f8303a8167	11	11081	81	1147	1170	18	4	2023-09-28 10:04:57.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1172	\\xabef2003ec65cabe4ae4d5aae2b3d39f1ca6c4f293364437d8cd97078f72aca8	11	11082	82	1148	1171	9	4	2023-09-28 10:04:57.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1173	\\x4c421b5ef800762ea93af57732c3a02e2cc3df1e5a66a76400a174bc29b1f49a	11	11084	84	1149	1172	18	4	2023-09-28 10:04:57.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1174	\\x158fff7fcbf921fdaed9111e354d9e85cf12e81d0a1ebb6789af16857506dbd8	11	11085	85	1150	1173	18	4	2023-09-28 10:04:58	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1175	\\x7aacf598b82c50c761ae503f525961e83da3955b37f07e48b0d275b567c76bb1	11	11087	87	1151	1174	3	4	2023-09-28 10:04:58.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1176	\\x5f35864cc54893c7bbea8b566221ff4695855bb9caec8c3dedde2872f2954505	11	11089	89	1152	1175	5	4	2023-09-28 10:04:58.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1177	\\x58978eaa2cc24e342a0f8c519647d69c717df11d0f5358c1a8746781d8ebab89	11	11093	93	1153	1176	3	4	2023-09-28 10:04:59.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1178	\\x7ed2a296e290d97fc2558b3d522356399b0d6d9b8226791feaea952ef35142fd	11	11094	94	1154	1177	7	4	2023-09-28 10:04:59.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1179	\\xaf61b5559eeafc99733d591059fb15b6189d6d32bc4b2bd4390aa7d52ef60b66	11	11104	104	1155	1178	6	4	2023-09-28 10:05:01.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1180	\\x8780b84bbd8f4c59a347ecf06730f4b47476ec1238a4d96754c94df6d7d38c70	11	11105	105	1156	1179	5	4	2023-09-28 10:05:02	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1181	\\x20f1fcb2621793c91388ba9a7287a3c7ee84d84fb9006a61a8d2254e4e55294c	11	11108	108	1157	1180	9	4	2023-09-28 10:05:02.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1182	\\x534e8860ad3bb1f7b0166951f9c48dee07a6856bc1bc69ac9d09523a56847b86	11	11114	114	1158	1181	3	4	2023-09-28 10:05:03.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1183	\\xa1568b2b440092bdd134f0ff0c1aba471904dbe9708b94c1ad9cf3b0e419ad64	11	11119	119	1159	1182	5	4	2023-09-28 10:05:04.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1184	\\x8e420519be749ed855fe92ba3c2a893cab6ce0000a0bc1dc79d2ff6bdb3f3f82	11	11125	125	1160	1183	7	4	2023-09-28 10:05:06	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1185	\\xba09808d3945638377d27a5e57be1c8e422cebf81fe472ceac8ffee3c6c1e793	11	11131	131	1161	1184	51	4	2023-09-28 10:05:07.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1187	\\x1aa5151a0bcbc1dab3f9ea4f5c8b85690971f7ec1bfe5ff4748c8a8089dcde03	11	11150	150	1162	1185	5	4	2023-09-28 10:05:11	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1188	\\x71d011cb4659a28d6032bf398149a6204bc9aaee996248787ceb34c90e9a13b2	11	11166	166	1163	1187	22	4	2023-09-28 10:05:14.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1189	\\x449bd4f3b9190120139a1e6f50d3421fc9a2bd7d7ee9d1853f524c6988831488	11	11177	177	1164	1188	5	4	2023-09-28 10:05:16.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1190	\\xc618202f696df1a9cee9df276a8a375ff8adca760e07022a5d4dacfd907641e2	11	11179	179	1165	1189	6	4	2023-09-28 10:05:16.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1191	\\x87cc979f674d70c295c584042b34cd9ed3a7bcc6c3415bd46a594d8b56429989	11	11188	188	1166	1190	13	4	2023-09-28 10:05:18.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1192	\\x07a2fa38b00cb43dc6960f7e822d7ecfee22bf9a5a971015683600f05afce883	11	11190	190	1167	1191	9	4	2023-09-28 10:05:19	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1193	\\x1081d17464fd638a7edcf524e6def43f3f95a4f34acc5e93ab4516cc6170e87c	11	11193	193	1168	1192	51	4	2023-09-28 10:05:19.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1194	\\x973cd95dafbf7b6ee647cbf49a4a0e44e91fa7da944acdef955eb52628028fbe	11	11223	223	1169	1193	7	4	2023-09-28 10:05:25.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1195	\\x93f954bd1cb070f65ea8e01c2f572977cb1af9a4a9480f0893aea1a2af7f36d5	11	11259	259	1170	1194	51	4	2023-09-28 10:05:32.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1196	\\xb4467f49e3626ac72c7ebc502bd1162d83234087201683b00d81d4dcca3bd444	11	11268	268	1171	1195	5	4	2023-09-28 10:05:34.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1197	\\x39aba96ad3f2af83941cb6c73cc0aad0429c61aa487c870cc9e4d33404949ac5	11	11276	276	1172	1196	6	4	2023-09-28 10:05:36.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1198	\\x1050e43c7abc929407d480be0afe854dedec5e599faf10f4a6b16e2150a5c834	11	11295	295	1173	1197	51	4	2023-09-28 10:05:40	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1199	\\x7dc9f1e4f2da34dcab494b248068b176e6c35ea3ebd426e5cea188b7e2611d02	11	11302	302	1174	1198	22	4	2023-09-28 10:05:41.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1200	\\xb5fa45bc144e5b92df624b68ceb8bb56830a882d2c00482b73100cfbb1f6f979	11	11307	307	1175	1199	51	4	2023-09-28 10:05:42.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1201	\\x5327014628a22de460f54b8dc9166b60f3aec5bb519c860dc870fd91faf44854	11	11312	312	1176	1200	5	4	2023-09-28 10:05:43.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1202	\\x90e06ce7586261988916f9e1a9f47ee85801e5916b1961f56c6ae289a4a4a366	11	11315	315	1177	1201	6	4	2023-09-28 10:05:44	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1203	\\x2a283c86f4d08062fc1f088f504dd034ced62a3b2a759e5ba9fac8e59b8a6446	11	11337	337	1178	1202	6	4	2023-09-28 10:05:48.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1204	\\x6f762c2bcce18fe49c240489a7cc6884a3f58cacdf7aa72c0b31ac1938633d19	11	11341	341	1179	1203	18	4	2023-09-28 10:05:49.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1205	\\x8265d69fcaa8355e947f7c060f508885de3fcf22434772fe59bc1ce63be19546	11	11354	354	1180	1204	22	4	2023-09-28 10:05:51.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1206	\\x288a2aa8f83be08ef2b7c72cbf3e9552b1ef575d6f7aade0427aab5cc842066c	11	11366	366	1181	1205	22	4	2023-09-28 10:05:54.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1207	\\x82293bb8e65565989ba3bcf004907e74a79869f771fc3c9b3aee2ba7b14e4824	11	11375	375	1182	1206	7	4	2023-09-28 10:05:56	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1208	\\xfb7a70d4b992c3412c63c87824f745d4c03dbb26281429fd2f056a1b3f7e1f4d	11	11388	388	1183	1207	6	4	2023-09-28 10:05:58.6	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1209	\\x1ce106f6d79b3ae072103b87d7ed95670196f456089649907420a0b416ee986f	11	11405	405	1184	1208	51	4	2023-09-28 10:06:02	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1211	\\xe6cbe1ab0bb01dd51e843bc862c8914d8fd34242439a2d295d04f5b4b9ae8d50	11	11408	408	1185	1209	3	4	2023-09-28 10:06:02.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1212	\\xf46ff18a6f5788efe6ce5f8da630f6643ac66fe6e765063ada269abe53988382	11	11409	409	1186	1211	13	4	2023-09-28 10:06:02.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1213	\\x65ba2c3af67ca63ef27a28d1d870dc8ba64338085c7859c54a854bb5c437c6a0	11	11423	423	1187	1212	3	4	2023-09-28 10:06:05.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1214	\\xf606e464ed83f164423cda9401d5421b8f45eba765e153b7733b903dad7cd15f	11	11432	432	1188	1213	51	4	2023-09-28 10:06:07.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1215	\\x88aada6435229a87c7a430c164374a5222c5576ab0550a2d1dab5b9b88d68b76	11	11485	485	1189	1214	5	4	2023-09-28 10:06:18	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1216	\\x5ebfa8476601c728f1a85d761a9e2f548085bcc0325daa066b062bb0099cde87	11	11508	508	1190	1215	13	4	2023-09-28 10:06:22.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1217	\\x2449d89382d8b925b6a2fa0fda1acdd75acf3a8f14ff8de2f6de7e454d78b171	11	11514	514	1191	1216	9	4	2023-09-28 10:06:23.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1218	\\xf3889bbe852ce9a407c0355c61e095c9057e68d6b366703b59d10ebb168d9527	11	11517	517	1192	1217	18	4	2023-09-28 10:06:24.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1219	\\xda64aea7578656abe4efb008f78a870142eb86693bf53ae2507144e397f54b59	11	11529	529	1193	1218	18	4	2023-09-28 10:06:26.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1220	\\xba79c9fc95d2437a2397494a626e26c8be3aea03572d8a8a4d98cfbb210c3248	11	11533	533	1194	1219	5	4	2023-09-28 10:06:27.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1221	\\x5b036f5ce3967c0c87924a1bb9e928a36bdd80e811f483cb61c5a92e58a45beb	11	11569	569	1195	1220	9	4	2023-09-28 10:06:34.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1222	\\xa62e9a5f4c0a4f6e7991d565fbcf726e25b5cbda62d0212bd10f3b1461c7325c	11	11580	580	1196	1221	22	4	2023-09-28 10:06:37	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1223	\\xaf27867f8b61891c68261ae7d442a701da6c9ed24b7cfc9e2c7e1a5ff4036cb5	11	11584	584	1197	1222	3	4	2023-09-28 10:06:37.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1224	\\x4e533a326459d61a1c72e6c8f6a7fae3956d7410e6a345074f12accc3bf9207e	11	11585	585	1198	1223	18	4	2023-09-28 10:06:38	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1225	\\x504b87252aa1c5222b75e770acfe9eae8ccbe7d2fa8f798bc72fd85ecb4cd5bf	11	11612	612	1199	1224	3	4	2023-09-28 10:06:43.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1226	\\xc3fcb5a66d51a5c208372c5c7c2700648d77694aff032af89f0052ccdc9c835f	11	11616	616	1200	1225	51	4	2023-09-28 10:06:44.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1227	\\x556219ea28b18e167e77f91406987db39cdd4ddc415b6ad4e5d21b95fd3fed96	11	11632	632	1201	1226	6	4	2023-09-28 10:06:47.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1228	\\x6a36648c9afad2ebe62fdaad4d757eeebb68a71da6713565830b7fc549853bd5	11	11659	659	1202	1227	3	4	2023-09-28 10:06:52.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1229	\\x780269771a1b28fdadc47ad83b286df7c6ae96106bc7900bea7475362925232a	11	11679	679	1203	1228	7	4	2023-09-28 10:06:56.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1230	\\xa394cbaf71202d4e57543809889bd8669410b5701de79736a57d7aa326c3ea14	11	11685	685	1204	1229	18	4	2023-09-28 10:06:58	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1231	\\x579fcc5a44a3e26e48f97d8ebf4de3bc7d3c11982f31fd40cb80b22b3b0f7e81	11	11698	698	1205	1230	18	4	2023-09-28 10:07:00.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1232	\\xd6cb309a85077595295e429c63c0dd4bf4d7edcce94d92f21b9d726d722b17fa	11	11718	718	1206	1231	18	4	2023-09-28 10:07:04.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1233	\\x5e6a5c7f380d9cf31d3ddef49d1f0732c183cbbdd68af73b0b995be8c79b7912	11	11722	722	1207	1232	51	4	2023-09-28 10:07:05.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1234	\\x1bee3601292d24a0d36ca057b1838c63a4306aea8aed52e55b5305a21c6d9473	11	11727	727	1208	1233	9	4	2023-09-28 10:07:06.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1235	\\x88d5eee24309b366a4122f9e14216cfc203a097d749b088ce375258f558b0ff6	11	11742	742	1209	1234	51	4	2023-09-28 10:07:09.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1236	\\x64fd86e15183056e24c7c5406939b49b44b4aa2ab51a96c2774f8475c65a7cd9	11	11745	745	1210	1235	6	4	2023-09-28 10:07:10	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1237	\\x0fccf1f5effc21742e5518ed08ef7eed646f9176b3591456c0ffef28ec993ce7	11	11749	749	1211	1236	5	4	2023-09-28 10:07:10.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1239	\\x64b0eb661035bc7b2b24ea58c83efecbc183b5eca3ffccfe7b7e3b517c52cbaf	11	11770	770	1212	1237	51	4	2023-09-28 10:07:15	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1240	\\x134d6932e444a0874e3afd5527a1d9152dd10c2a9ab084d77d6ebfe00995501e	11	11782	782	1213	1239	51	4	2023-09-28 10:07:17.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1241	\\x4480d62ee8d1be484f3d1484e59e2c84cf6b55a4e7f6aff0991d0278d191e0f1	11	11783	783	1214	1240	3	4	2023-09-28 10:07:17.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1242	\\xd309fabe58e17900903bc4313b0a3b95a385d86f393cd143960f0791ed71e9b8	11	11787	787	1215	1241	18	4	2023-09-28 10:07:18.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1243	\\xfe82ea5161642c6cf75b697f16cdde7335589f473be1592ab3f3273ebe541012	11	11792	792	1216	1242	5	4	2023-09-28 10:07:19.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1244	\\xb87546e7d0eaeb932d715b7c55aff4518ee0afbfa58b518c102a75111c3a8b9b	11	11794	794	1217	1243	6	4	2023-09-28 10:07:19.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1245	\\x323444e2d5a3916d038999115fb492f834bdd6261d8ec57c10c2511a285e39a1	11	11798	798	1218	1244	13	4	2023-09-28 10:07:20.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1246	\\x6419dd7173b97ce215b847447ead7c616d6cb914463d1bfafc4b1ff211561efa	11	11800	800	1219	1245	13	4	2023-09-28 10:07:21	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1248	\\x837b09855ec446a18086c7c9f51fa1e5af297f4bdd7a5702ccbadd6fd08274c8	11	11810	810	1220	1246	9	4	2023-09-28 10:07:23	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1249	\\x74c96738a394d6790b48a9b9f579a02ffa7f07cdc483869d9d4954157e6aa055	11	11811	811	1221	1248	22	4	2023-09-28 10:07:23.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1250	\\xde30800896899bb9dad97677ae22d36f35faa391c285df48d696152308cd5956	11	11817	817	1222	1249	13	4	2023-09-28 10:07:24.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1251	\\x3e6cc87e83f795a21e332452e0975b9f015fe8b9464cb9092a855848c0464604	11	11832	832	1223	1250	9	4	2023-09-28 10:07:27.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1252	\\x2d795869fd5bb64fa9fd23bfe31c8a804c407e0806e2d00dd65d86de774f27c7	11	11852	852	1224	1251	5	4	2023-09-28 10:07:31.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1253	\\x20a279c4a25a020c13141c237f8145244e61e1820e894b25e95abe964ace87c2	11	11872	872	1225	1252	3	4	2023-09-28 10:07:35.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1254	\\x11b74e4d7e08a4b9940fe3de87a449130af6fd89aea7af6ec4c330e9bd543125	11	11878	878	1226	1253	9	4	2023-09-28 10:07:36.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1255	\\x851ed3ca3fdd04230e139646c0b3eb543b9ed5c209446d7bfd348f87003b3c11	11	11879	879	1227	1254	6	4	2023-09-28 10:07:36.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1256	\\x41bc2dd2173dc2e0b22490d3223f0e70426ee18e5a04e8638f1115ac5d4302c0	11	11882	882	1228	1255	6	4	2023-09-28 10:07:37.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1257	\\x3000c311b5f5181466a3da98a2131f1d052d29287b6978483260b89828ec7d3b	11	11901	901	1229	1256	6	4	2023-09-28 10:07:41.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1258	\\x95bf9d4d623cf4e835f9d16cb7eb4e7e1c64e3a27eef9c68d8dd89d757f47046	11	11917	917	1230	1257	3	4	2023-09-28 10:07:44.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1259	\\x1aa38e8e09eb6eff5d3e4300e6bdc82b10c53a1b1223f776f9e9bb8d4d54c8c5	11	11931	931	1231	1258	7	4	2023-09-28 10:07:47.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1260	\\xd988752e947ef1ca10916d892deebfc166fb6b4c83cb946d65d594ca17b9172d	11	11938	938	1232	1259	13	4	2023-09-28 10:07:48.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1261	\\x46f257fd06676476cf43eb75166f90a8dea7deec35affbe2e615a331f17914d9	11	11946	946	1233	1260	5	4	2023-09-28 10:07:50.2	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1262	\\xcef0adb2ae748f034d9d23cf46515bce155ec1bd703b63ead64b2aa47d2649a0	11	11954	954	1234	1261	9	4	2023-09-28 10:07:51.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1263	\\x08e2ac863b7cc5e0ebed4692e525313a6adb4bd3f0489eb63c0572c9003ea563	11	11960	960	1235	1262	6	4	2023-09-28 10:07:53	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1264	\\x6101d3acf1b02827632428a1e596c6f9d2c5c3463e9033e63841f0a22ced7331	11	11989	989	1236	1263	51	4	2023-09-28 10:07:58.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1265	\\x521f11e2c4591a965b03c7978b58b5fd4ae5a89466b7f3c3042ef2e94c371639	11	11990	990	1237	1264	3	4	2023-09-28 10:07:59	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1266	\\x8733cd0538c77daad161a4207a510c33efdfcfde7f1de400a7e54180ecb0dff4	11	11998	998	1238	1265	9	4	2023-09-28 10:08:00.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1267	\\x29af4c241312b808fe905813a0a7e0d7a1127e2a50298b6b5dc88a3094d22f7f	12	12002	2	1239	1266	9	4	2023-09-28 10:08:01.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1268	\\x705e725cfed49edc5ce637c2abcf695b58ecf87cdeaedb47d03a594380af0fa7	12	12014	14	1240	1267	9	4	2023-09-28 10:08:03.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1269	\\xc7ce7859c582ae6b27f56072b4920f31c3b0c2bc8337dc1e051d4870ef5e4b22	12	12019	19	1241	1268	9	4	2023-09-28 10:08:04.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1270	\\xca9c8d8d031e94f6e39af6d8415f9bd1fd581062626cd6059e30ad89e2bb41b1	12	12028	28	1242	1269	3	4	2023-09-28 10:08:06.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1271	\\x81f4941e439b7f41523c6fcfab6e934f322327cebf2bdccf7ba3657ca5058787	12	12032	32	1243	1270	51	4	2023-09-28 10:08:07.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1272	\\x81bf5a05b6dae7d76ddc5700fbc8242a8392cd848551f2d31e75e992b2308460	12	12051	51	1244	1271	22	4	2023-09-28 10:08:11.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1274	\\xb9fd122343192ba08aa89bcd30829365c430917796887e9565c0b233cc73d1d3	12	12060	60	1245	1272	22	4	2023-09-28 10:08:13	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1275	\\x50ec95368ded2d4cccddee25ceb52b728e762c8bccf32dc0900ecdbcce326687	12	12066	66	1246	1274	3	4	2023-09-28 10:08:14.2	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1276	\\x7f9a6a207d9693dd86dc7cb0d426513f22c822358fc7c428e02e592bb21762f4	12	12105	105	1247	1275	13	4	2023-09-28 10:08:22	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1277	\\x401bace9bc51f22c0680d52c1b08d7b4bfd338db5174b85f5dba41d65f473b5a	12	12115	115	1248	1276	22	4	2023-09-28 10:08:24	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1278	\\xc3db5b8504e3216dca9c60a494fafec1bae9f6ed6082855d2831ec5f6f546227	12	12125	125	1249	1277	3	4	2023-09-28 10:08:26	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1279	\\xd0baf512e5aeb5001379f2c95372c365c6e1ff7093439a22762481fd3dfee41b	12	12136	136	1250	1278	7	4	2023-09-28 10:08:28.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1280	\\x178377fabbc7dcff0883de4c2e8148fd7a97029600c1c1d03da114fb67ec4aea	12	12153	153	1251	1279	22	4	2023-09-28 10:08:31.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1281	\\xce2ae94a7b4ec16fecc84ca599581effc5e4c8f1f5612c9f8ab9a1d658aa67da	12	12157	157	1252	1280	5	4	2023-09-28 10:08:32.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1282	\\x8888600d1c72c0714c60d9a3b2f0403cbb6479708d6ce40540e37c91c68430bb	12	12181	181	1253	1281	22	4	2023-09-28 10:08:37.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1283	\\xaf291563663a06272c65bd23a493b66d8d8096b05135b2d72727c26cf77ba7e0	12	12186	186	1254	1282	51	4	2023-09-28 10:08:38.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1284	\\xdf0ef966b862262512afc263ab919d4fc28e0119a403f37b069f869a03f102c0	12	12191	191	1255	1283	7	4	2023-09-28 10:08:39.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1285	\\x7dbfdf2bcdf98dcf4cbfdc23ceddd1a5790a4dede85f38744c61a2a6d62db053	12	12205	205	1256	1284	9	4	2023-09-28 10:08:42	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1286	\\xb9353483081f2dbed8768291323df45a8be757f3fc094a25a06a95f218444f35	12	12207	207	1257	1285	13	4	2023-09-28 10:08:42.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1287	\\x19e93b94100e3d0f545837eae9fba9c2f2618184a2fb3a545e6dc1f3b9da3e61	12	12212	212	1258	1286	3	4	2023-09-28 10:08:43.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1288	\\xaf1ee4a228703f7fbab37dfb622112db5e2e23293adc43c4ec43911517b1a4f5	12	12217	217	1259	1287	9	4	2023-09-28 10:08:44.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1289	\\xfe417fa90c31b2a8d3442892ebdac6de2a427ef5b5e7dd47058a7d30a51739a3	12	12219	219	1260	1288	3	4	2023-09-28 10:08:44.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1290	\\xedfb9387c328ac7bc70da8deb3b29b5d2d009c2ef273b4f319d994c6aae78bb5	12	12220	220	1261	1289	22	4	2023-09-28 10:08:45	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1292	\\x237aa3f808ff80920603a7e67b0de880092e69c462e501f8002a2fde74f8890c	12	12231	231	1262	1290	51	4	2023-09-28 10:08:47.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1293	\\x3a7f3234039ab387e401e57807493a0d0bff8ebc409fdfcd03e9e9e829bb51d2	12	12236	236	1263	1292	51	4	2023-09-28 10:08:48.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1294	\\x4b88d16a131dc80c08b082f79c89528c67f359b98921dd7d5a5ec7ac53f4bf8e	12	12266	266	1264	1293	6	4	2023-09-28 10:08:54.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1295	\\x1918e7e399bda36f7c53091aa84e33e462783abdea07039f955f83baa08f7051	12	12270	270	1265	1294	5	4	2023-09-28 10:08:55	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1296	\\x622d8930243a7c45b24c3497c5842d8e636e8b1892070b0de927f3cf50a0842d	12	12278	278	1266	1295	7	4	2023-09-28 10:08:56.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1297	\\xa93350a46449455cc4916e91abf925913a19f889196cbc00defbe49a6905a351	12	12280	280	1267	1296	5	4	2023-09-28 10:08:57	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1298	\\xc6a451ccf222ad28f7e568f8ca4d5e11bfe15551f501d690bb95aa32e883cc22	12	12295	295	1268	1297	3	4	2023-09-28 10:09:00	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1299	\\xb2f2a39fa1ae4551cba2a517422e0a2ec05ebf02724f9e3d301efc789560cc78	12	12300	300	1269	1298	13	4	2023-09-28 10:09:01	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1300	\\xe441c1ad7ea544e58d82b77843efdb191a4e75d1cb2b98a7406b16a6a4dca3cb	12	12302	302	1270	1299	3	4	2023-09-28 10:09:01.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1301	\\x41eddd9f0ec655481101da00608dcc097dbdacaf6665e0a7815a8982e989e19d	12	12306	306	1271	1300	6	4	2023-09-28 10:09:02.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1302	\\x9a8042ef89c1056482fc38b05620ddc62607a4e9e27d3dab3bfe393d75feda15	12	12307	307	1272	1301	6	4	2023-09-28 10:09:02.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1303	\\x90cfe6dcb94bb0fc54b0e3012baecb24937b923400ffb72cc46bbbfdf2562e58	12	12324	324	1273	1302	3	4	2023-09-28 10:09:05.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1304	\\xd087bc5cdaaee2d3a7bea715a34013ebb1ace8222dd850de8114a4f3c20a0940	12	12327	327	1274	1303	9	4	2023-09-28 10:09:06.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1306	\\x67135fd0be04b4629c84aafba7d78e769947b48a9bae0d351f01267b0ada3146	12	12328	328	1275	1304	3	4	2023-09-28 10:09:06.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1307	\\xe40dcf95258cc38969989f44e880e21a873825b667890ae22fefcb634f218537	12	12331	331	1276	1306	9	4	2023-09-28 10:09:07.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1308	\\xccc0162a748ae0133db08ee1c28e019df5153ecea1bb977fb8535a894b4f361b	12	12341	341	1277	1307	9	4	2023-09-28 10:09:09.2	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1309	\\x1f587f7229ab3f30ad2a2ad9be8d6e4b0850c6d1c527db8155323a1bccb1a070	12	12347	347	1278	1308	9	4	2023-09-28 10:09:10.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1310	\\x4c9061accd7b61b1fff8fac04abfb07f5a43447291975ee2da28669427e27c08	12	12349	349	1279	1309	3	4	2023-09-28 10:09:10.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1311	\\x8383ada8d657f1e566b0f16ba2ec0bd4686d81eee33ac270c01efc5a355f1be5	12	12358	358	1280	1310	13	4	2023-09-28 10:09:12.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1312	\\xe2378e514f87411a347cfe139689dad66d921f1cb43b7203ab7b9307a327f2d4	12	12363	363	1281	1311	51	4	2023-09-28 10:09:13.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1313	\\xa74258c914e0493421e13a76c5212030374528198b6ae6bdee8c738baea049f1	12	12371	371	1282	1312	7	4	2023-09-28 10:09:15.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1314	\\x706b9b953df14ca71f918154b76472fda708aff884deb06091e71ca6fae9e4fd	12	12388	388	1283	1313	3	4	2023-09-28 10:09:18.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1315	\\x2c7cb3092129515a9bf40eaad768809e03c2f0883add66fee307d679193785f1	12	12405	405	1284	1314	3	4	2023-09-28 10:09:22	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1316	\\x262c45a127a12831775541a9f008b57a620e904cda105c8ed8654b0a9543d9ff	12	12412	412	1285	1315	7	4	2023-09-28 10:09:23.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1317	\\x892fc1f99d10a75f2b37fd68a4a5fa35ee52102d2dac3d399b2870bb78fa486a	12	12429	429	1286	1316	7	4	2023-09-28 10:09:26.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1318	\\xa91e7b5a8f43d7c824b91452da061ea705d25b129890025146115d323151b4fd	12	12430	430	1287	1317	3	4	2023-09-28 10:09:27	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1319	\\x18ce2d80aae8d493c21de58a1f54c0861cf4282d458e73a8eb1f831cdcaed754	12	12436	436	1288	1318	13	4	2023-09-28 10:09:28.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1320	\\x899ee786e4dfd5a396caa6bc56016f035b8d8656e80cd7b6125578c09eca11ed	12	12447	447	1289	1319	18	4	2023-09-28 10:09:30.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1321	\\x220e89396da3fd66b6dde5a4d746b8f323b5bc78308393c163c22b4b4c97700e	12	12451	451	1290	1320	18	4	2023-09-28 10:09:31.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1322	\\xb70f913dec0ea998bc414b94e80468f0d72efdf3b1c83c24dff859cf0bbd9a98	12	12453	453	1291	1321	13	4	2023-09-28 10:09:31.6	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1323	\\x5d34af89804dfbd9e3df0e5b9a85026cfc5b50ea1e01622165739873ab50c879	12	12454	454	1292	1322	3	4	2023-09-28 10:09:31.8	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1324	\\xc5ac096d69f701fc214768b36c5bbef83c4468c51229e434e134d6012143ba35	12	12457	457	1293	1323	22	4	2023-09-28 10:09:32.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1325	\\x145235ea907c747f32f7ee12d6dcf5bbeb6cd0ca7fca746b4aeb65b60c659c29	12	12472	472	1294	1324	22	4	2023-09-28 10:09:35.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1326	\\xfe4e29324e7da5fb2e6d596abf48c40ec8ec06a485b51ce5742d94e19c64fd0d	12	12477	477	1295	1325	9	4	2023-09-28 10:09:36.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1327	\\x31284293a53038e05e4045c24af4478bbbf1576fb3cdebf95ed5b9af39e695df	12	12486	486	1296	1326	7	4	2023-09-28 10:09:38.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1328	\\x1dbd621f77d96ad5b008e9d1c0133b0a1e2056f6eccb39afd32a853a55fc7150	12	12495	495	1297	1327	3	4	2023-09-28 10:09:40	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1329	\\xad055cd08de08847062c3fd89602d1b469a84cd884aeac53caef0b539c3561da	12	12503	503	1298	1328	18	4	2023-09-28 10:09:41.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1330	\\x4de592d255071fe09f24d1eea657063ee5b94749e6d49b25823ffe4ccef08cdc	12	12507	507	1299	1329	51	4	2023-09-28 10:09:42.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1331	\\xff6e9c17edf4c574cc4e312ce3f700289ada79b490ebb1c8372b22026fb38785	12	12553	553	1300	1330	5	4	2023-09-28 10:09:51.6	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1332	\\x80b692215f7e08f848a5267c49457c6588dd56a79d68112992097ff716374a49	12	12558	558	1301	1331	22	4	2023-09-28 10:09:52.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1333	\\x2071fd7426c51097d7aed09827fb612954d06041906e5487730aeb8130db0264	12	12564	564	1302	1332	13	4	2023-09-28 10:09:53.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1334	\\x5773357815450ee8ff97387f8ce3497ce19f4040f302211023133c98bb51b21b	12	12567	567	1303	1333	9	4	2023-09-28 10:09:54.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1335	\\x23f708aeb34e5c1d7f32eba8974ea742e81ebf007027a625afddc1158c840136	12	12569	569	1304	1334	13	4	2023-09-28 10:09:54.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1336	\\x92b75150a5768a40c90c7543cdd0d19d1b66f71378f125df151a90a112ca5a42	12	12581	581	1305	1335	22	4	2023-09-28 10:09:57.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1337	\\x2ef849183b7f90e80fd3c95a30ef961141b92b638753bc362a7bbb1d8158d193	12	12587	587	1306	1336	22	4	2023-09-28 10:09:58.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1338	\\x297370e9711663037c5f4755a0c606caac001b1ddc7466adcda7361f6e494aa1	12	12605	605	1307	1337	3	4	2023-09-28 10:10:02	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1339	\\x4236e60aca389ace859968a0ffeead065ef30555e350af0341f1e5966dc0e4e6	12	12612	612	1308	1338	9	4	2023-09-28 10:10:03.4	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1340	\\x106c171b2debdd61a44cb8e3ba723145463b42d07d40bf9c86fb987c34e9d81e	12	12627	627	1309	1339	7	4	2023-09-28 10:10:06.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1341	\\xefeaaa68e58aee270b054b167f6d44829f29c5df3a651c3b506a3d36f328cd50	12	12629	629	1310	1340	13	4	2023-09-28 10:10:06.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1342	\\x71f0769af2f5d304714b9a918e854e3ebe3d56b703c0cf7f69c86b6ed117181c	12	12634	634	1311	1341	5	4	2023-09-28 10:10:07.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1343	\\xf1a5e72e0e2eed6fe3bb6a3faccf74d5ae67abca7b1ea1c7a7702e3911020129	12	12635	635	1312	1342	6	4	2023-09-28 10:10:08	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1344	\\x5596cef4b7cbd5cdc245bdadf3cd809a890d568f4e3f397a0fa757e2cddbe71a	12	12636	636	1313	1343	13	4	2023-09-28 10:10:08.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1346	\\x9b8c95167d7999edabb3cf3dcc6d321dd25ee0310245e3109c325fca42434f10	12	12642	642	1314	1344	51	4	2023-09-28 10:10:09.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1347	\\x10c1d596b918156419fbaa7f47fd7b20ff719597d4d5248a5718359e4e0a26df	12	12650	650	1315	1346	5	4	2023-09-28 10:10:11	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1348	\\xf3e960b3c2d0cf50a2648f6d5cf3fe1677bcef8e5062ce48206e01ced092d256	12	12654	654	1316	1347	51	4	2023-09-28 10:10:11.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1349	\\xd51988c0743bf835cda6d6bcc9b43169d847734611e58382fe605be7832a258e	12	12682	682	1317	1348	6	4	2023-09-28 10:10:17.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1350	\\xe4a57fa1291d91937be5aac73220b05dc5b3a1a6da1c524a750eb0d300367059	12	12687	687	1318	1349	5	4	2023-09-28 10:10:18.4	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1351	\\xb0b9277ca69ddc3890c93fae9800652727bb7e0b3a1b10741f59d8da0edf3a16	12	12688	688	1319	1350	51	4	2023-09-28 10:10:18.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1352	\\xd94a71480a34c81b5624b00294d34fef48bf8319eb87642976da2eb349fa1f17	12	12699	699	1320	1351	7	4	2023-09-28 10:10:20.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1353	\\x9624aea00f03dfd37f6503420c16242faeaaee3c55f3248f8054248d852c19d9	12	12701	701	1321	1352	7	4	2023-09-28 10:10:21.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1354	\\xf236c11854e73ec94cb7bdcf515e11e056966e027da0cc353bfe261e6d66e9f1	12	12715	715	1322	1353	51	4	2023-09-28 10:10:24	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1355	\\x5717a3cd5c9b00281681d2cd5683c05b78644b28aa69865aabe15f56641c8d72	12	12724	724	1323	1354	51	4	2023-09-28 10:10:25.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1356	\\x31a66ea9ddc289bf1479bb62680f7444e3478e2884ae3908b3135690c515e682	12	12757	757	1324	1355	3	4	2023-09-28 10:10:32.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1357	\\x96a1f7e2c91eea706ba34b1c9ff6c2ed12bf54d26dde3dca1501d7d7ff8907aa	12	12763	763	1325	1356	7	4	2023-09-28 10:10:33.6	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1358	\\x3c2aef69a3beec33dfb717be58e00909dc59d7fc92a8b45581307d588190fb49	12	12772	772	1326	1357	51	4	2023-09-28 10:10:35.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1359	\\xf3f125d8832776249c7d7978cf6c6d679c02d242dba4c82906f8ed2e9a93ef64	12	12777	777	1327	1358	51	4	2023-09-28 10:10:36.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1360	\\x023dc718b9c31637427c8bd52feded2975d75240a2e6d69c12b8b07983131c30	12	12781	781	1328	1359	51	4	2023-09-28 10:10:37.2	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1361	\\x966775eb95b08b68056d5de11ece231b9b3728c73a7634ba110603fe9f233adc	12	12792	792	1329	1360	6	4	2023-09-28 10:10:39.4	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1362	\\x025b94642fc73b351f1f9de04bccad3a0e92f6c3bddcba747204caff32ac59e9	12	12793	793	1330	1361	51	4	2023-09-28 10:10:39.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1363	\\xf71a27ab4148c7fbe4339f0af62be02fbfb4c608bb936eb17c4b5e74e7891a11	12	12800	800	1331	1362	51	4	2023-09-28 10:10:41	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1364	\\x586e53e895d1ad0599e86fda4248d2944bb267aecf75cfef16f5b454202b1059	12	12812	812	1332	1363	18	4	2023-09-28 10:10:43.4	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1365	\\xc2bf6e64ebd2e3d9d41a508a9afaffb2d541cda492e3463422cd16d0862cbb28	12	12857	857	1333	1364	13	4	2023-09-28 10:10:52.4	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1366	\\x9787ccb321c9d4ac15bbfd4b1a34288a9bf03f8023d4a015b77f9d4d1751e332	12	12861	861	1334	1365	6	4	2023-09-28 10:10:53.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1367	\\x7d4e85060114da3faf1491c52a8d80a24182ca22d76574ec49d5e56841230fb4	12	12881	881	1335	1366	7	4	2023-09-28 10:10:57.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1368	\\x6420cd1f89afb2adf60eb000aa104f1e8af6fc11b6f9dc1e9d4b1274d0e66bda	12	12884	884	1336	1367	51	4	2023-09-28 10:10:57.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1369	\\x516d179bc971791d0a0d576a30ffb6f693b87717f75a795888872e6ad95186f9	12	12895	895	1337	1368	6	4	2023-09-28 10:11:00	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1370	\\x787a94a1ee46a0ded31955d14d161c03948268690718429ca72d329fc6acb098	12	12900	900	1338	1369	13	4	2023-09-28 10:11:01	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1371	\\x6e69f3092155b4209c4ffac738b18c25cd0020dee4af0eff0a7ad063778c84ed	12	12904	904	1339	1370	51	4	2023-09-28 10:11:01.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1372	\\x9d72202a8404df999d3b365bfb2ab8056223182ba112ff1e6829926521644e1b	12	12905	905	1340	1371	22	4	2023-09-28 10:11:02	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1373	\\x6dcc2347ff708ef14297ef9b288102c1a40cff79ed48ed73ef1f5fcaa4c8a653	12	12919	919	1341	1372	18	4	2023-09-28 10:11:04.8	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1374	\\xf1f9489d71b7df44131ee3a0ae76cb929cf9a56a4c8f99dd09be8b8a9f7272ab	12	12935	935	1342	1373	51	4	2023-09-28 10:11:08	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1375	\\xcc7d4002383942a273921ef0741ece3ce59cf15f96d27616e8deeee721590557	12	12938	938	1343	1374	22	4	2023-09-28 10:11:08.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1376	\\x8f317e13541d3291bddff48750ed93c8adbf36db19f811838eae254784fc4336	12	12950	950	1344	1375	7	4	2023-09-28 10:11:11	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1377	\\xdea40d561cc799504d843fe7993b999b251155be67ac445b8ae0f4c08ecd9036	12	12980	980	1345	1376	18	4	2023-09-28 10:11:17	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1378	\\x5cc9268ae362763eea0235e063a0efc265ea93beb4ed2d35a0d2805a522d2b83	12	12985	985	1346	1377	6	4	2023-09-28 10:11:18	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1379	\\xc62e379397b66716f96a0c162e3e74e4ae3ee4b44b803fedeec91a623c4e0023	12	12990	990	1347	1378	13	4	2023-09-28 10:11:19	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1380	\\x530879a67945d36c22baa1a5eec6897ff374360b875e6b00377297b3bd09897a	12	12991	991	1348	1379	22	4	2023-09-28 10:11:19.2	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1381	\\xb994f267ccf7935d3ec322b07a2202deb222d0265f92c7478152ce76f495dd2f	13	13019	19	1349	1380	7	4	2023-09-28 10:11:24.8	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1382	\\x17bdef56c55220cc9c405c49519e827142334f622edc7e8e4c916632f021c5c8	13	13027	27	1350	1381	9	573	2023-09-28 10:11:26.4	1	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1383	\\xf739f14d55b629f8e39676d4d492bc913b34700ac93b44eb5e004124efd44b2e	13	13041	41	1351	1382	18	4	2023-09-28 10:11:29.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1384	\\xdae69c62ce41629f76011bfed081787ef1af0c7c606e55930347244fa2888414	13	13042	42	1352	1383	3	4	2023-09-28 10:11:29.4	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1386	\\x7fd0763d7f37b4cf4a0d9ab9d81e9ef235f3a652af88884cfdd8e804b5f8cc18	13	13046	46	1353	1384	13	4	2023-09-28 10:11:30.2	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1388	\\xfb03bef87da79572cdc0245fc28e961761993403a1367aa6d102d2d55ce4ee91	13	13048	48	1354	1386	3	4	2023-09-28 10:11:30.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1389	\\x66ada3357fde2f8614df915da35142a53e2cdf73cfcfdef06bcff5116145d2c8	13	13054	54	1355	1388	9	4	2023-09-28 10:11:31.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1390	\\x7c91a0566ad1d543ec110937bd4718bc8eee724b9c15cbbb5faa537f1e264ea6	13	13055	55	1356	1389	18	4	2023-09-28 10:11:32	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1391	\\x1d138ea3c28eaabe95dbdf95c11db5425c23da9dafbcced4350beeb1798238d8	13	13064	64	1357	1390	6	1808	2023-09-28 10:11:33.8	1	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1392	\\x3765ec87dadf3b3641f58822f8b0a202902ab97b6da5691c2b88320d6a4dab9a	13	13065	65	1358	1391	3	4	2023-09-28 10:11:34	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1393	\\x5b37e444cecdf4693538a43c5ca17ff25a7dcffb0a1a8489c1a4a8adfa5a04c5	13	13069	69	1359	1392	5	4	2023-09-28 10:11:34.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1394	\\x30734f3d32d253b4a854a06a3eb8e0a6368990040a66938c520f554e49fce4a8	13	13085	85	1360	1393	6	4	2023-09-28 10:11:38	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1395	\\x888db9621b7661ff306ce71c1e3761b544af0882496ccf78ff45626b025a8634	13	13087	87	1361	1394	22	4	2023-09-28 10:11:38.4	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1396	\\xa18f0b959ba6dce12abb191292fa7d7d007344ad73e5ecfbbf93aceb8bb189f4	13	13088	88	1362	1395	51	4	2023-09-28 10:11:38.6	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1397	\\xb952ee237a4cafd1ed3f513d73ece825ecd70c6f8b9a771bfffd1ddf41b31da0	13	13093	93	1363	1396	9	4	2023-09-28 10:11:39.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1398	\\x8dd49a77248308b76878b603cee2269cb6b30ab48753fce1bc1a66f001f50939	13	13100	100	1364	1397	22	4	2023-09-28 10:11:41	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1399	\\x9aa4a181d65fb379b20d67155f6fb3634ca7675e69280746f14bda46bf012959	13	13119	119	1365	1398	13	4	2023-09-28 10:11:44.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1400	\\xee7a0537434565ab7f3e8e70f6c9816a05cded8b3faf15562cc10fa64851c392	13	13128	128	1366	1399	22	554	2023-09-28 10:11:46.6	1	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1401	\\x523badf3ec9fa78cf4e53f094f128919be718bc07e15ea45dfb771dba66c3cce	13	13129	129	1367	1400	22	4	2023-09-28 10:11:46.8	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1402	\\x18be6460ff9debb9f556e2627ffa8fe0559ee6902d5571a394b5906235391852	13	13131	131	1368	1401	6	4	2023-09-28 10:11:47.2	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1403	\\xf0a4a20fc1700144d95bdb9f4b34ea621f8e13e094862c9782c0597226144249	13	13136	136	1369	1402	18	4	2023-09-28 10:11:48.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1404	\\x7905aff0f9446343530d5d1775a0b2b4bc8fbfacadf6d2eb2680b5ba53846e67	13	13143	143	1370	1403	18	329	2023-09-28 10:11:49.6	1	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1405	\\x814041009f9fad15287e4a2fa45bd5ad04c89f631d69f6a49186be4bda4a185d	13	13148	148	1371	1404	9	4	2023-09-28 10:11:50.6	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1407	\\xb6ffbac146dbedd3340e380e973260581531766850e9de2c709fa07e4073649f	13	13154	154	1372	1405	13	4	2023-09-28 10:11:51.8	0	8	0	vrf_vk1kdehheqweywha8ph69p67f940swcsm52qqse29wu8l9w5v3vy59qzuf9wm	\\x742496704b03b7cf17a111695744011a6723c0c2be3a86b69d455a51e11a1ef6	0
1408	\\xd164c7085c24bf940f61f47b3140a2aa03ec2b88ccc2fe904f08cfcebdc35e34	13	13191	191	1373	1407	18	4	2023-09-28 10:11:59.2	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1409	\\x61c21e7ae29616fc0356bf8d2c1faef4bb824012e58b576f0db8f318ea7f5bc7	13	13202	202	1374	1408	6	460	2023-09-28 10:12:01.4	1	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1410	\\xa2ee10bdb57b5801fcfd5e035f5a0c35ba95b7858e3a7c19ddb47c16124eecaa	13	13208	208	1375	1409	3	4	2023-09-28 10:12:02.6	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1411	\\xc8548875478d45808b6ba5fbcd37472826943697c058808adee65d9b765a3cdf	13	13220	220	1376	1410	5	4	2023-09-28 10:12:05	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1412	\\xb83aeef4de4b5c4e255905d6ddd1894b931f134b24be463c1f718769dfb04b5b	13	13221	221	1377	1411	7	4	2023-09-28 10:12:05.2	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1413	\\x3b500caff673df999b7cf6a61476d020b5fa01917118528240f67a3bb24ba321	13	13230	230	1378	1412	6	631	2023-09-28 10:12:07	1	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1414	\\x00bbe7132526293002da7be95b330c9e4628187f4a6a78d017cfd6dfdef8953a	13	13248	248	1379	1413	18	4	2023-09-28 10:12:10.6	0	8	0	vrf_vk10q5zy92rklugc3kgp6qpm0edlmkt83lj0u28cehkw8pv8m7ppq9qfsm637	\\x63747ac9c6db0c825f2c429940c62191b3cd22e0c548f09cf59906b03764c04a	0
1415	\\x128e57bbb629d6ff00edbd509b30bf7af0b7ff36565b158a88bd111599209911	13	13260	260	1380	1414	6	4	2023-09-28 10:12:13	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1416	\\xfef1124ea1bbff34664c6a21263e213fddadbafcd1b8f32631238359c22212c8	13	13263	263	1381	1415	22	4	2023-09-28 10:12:13.6	0	8	0	vrf_vk1h8pjxf54s3a7wtd6t2ddwgusqepdctqt282fkqpw75yagf5ngzrse3ex9l	\\x5534f4213c25b75ece5562127b537e068b19623dc697f08a158c8b037e6c3a1e	0
1417	\\xed991b59c0a50467b795562f4fd02492e72c01381d1e28f2f8f004b6c4d6ae26	13	13264	264	1382	1416	5	4	2023-09-28 10:12:13.8	0	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1418	\\xfa51f4365ec1ed8a56a77421166eab9f224f448e3f55ae940b7cedf3020f7c09	13	13265	265	1383	1417	3	4	2023-09-28 10:12:14	0	8	0	vrf_vk1t88unwq76a8vz92vwagt73r6z5hlvxlgus3r3mn3zmj6r5t7qy4quacf59	\\x6d32b118eca87aed0cee6ec04b9ac973db54e4eae4f565dd00cdb8014eb43e68	0
1419	\\x4736f98dfbb2f5e6428c25a5e75465e246a574e57b3c456e77730e9aefcf8cf7	13	13284	284	1384	1418	7	365	2023-09-28 10:12:17.8	1	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1420	\\x4094c19f5cc387e6936d171c1aff3d3a0681ce011b17e49b8539083f1f36fb89	13	13287	287	1385	1419	51	4	2023-09-28 10:12:18.4	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1421	\\x83b550b4c4f75d265b6fb33754bd8179c0880545d861c8bcef3e384989701a84	13	13329	329	1386	1420	6	4	2023-09-28 10:12:26.8	0	8	0	vrf_vk1z9wjdwlve4ktpy3cfzy0gkx5vdldls2kf9mgdxlhgzp5pen33a2q4v2c7p	\\x040d6365aa0b9f56149f629d95f49984d4add6ba792d08cedb004f27c6295c8c	0
1422	\\x9047763ef054b36eedbea216a75e7f0746cbd8772b4176296d59cd88d4d94896	13	13334	334	1387	1421	51	4	2023-09-28 10:12:27.8	0	8	0	vrf_vk1ddqzszqa98cxs243rmjcqc073y99w5espq088s6f7477eausg6fqxekgke	\\x2de9532cf64be4781033237f063da32d0011e46315cd2d71dcc80feb550a2bf4	0
1423	\\x08233e35a1dbe2896ca02f6f247fb19efa2b9958e97cd9bb7b1b7959dc0092a9	13	13338	338	1388	1422	5	528	2023-09-28 10:12:28.6	1	8	0	vrf_vk1st7jl3r96r7kehsqnvv2vgvcgf43kpljl9g6sn736xfhxh2nvu4qd7lzef	\\x108dbcdf78e72ebb8107375d66db5b9b8079b255f6f09b8198e949a7fd74e9a3	0
1424	\\xe876f100a19281ef5a80684b379f1ac078c3ee20049654b8f36f4536ffc9b02f	13	13342	342	1389	1423	7	4	2023-09-28 10:12:29.4	0	8	0	vrf_vk1vxlgee9st2rqk7u4pcdq0pzqaeenpv5dmm4hgxs7ee40g8phcn6sdsfr38	\\xfa276f4a5ec835134623aa991403e5fa60476affa1bf95c284027d6af40ab702	0
1425	\\x135b267a9df40d7ce7780f2f711c9bf5afdd2990df64ccb6ce6fa05152973b83	13	13349	349	1390	1424	9	4	2023-09-28 10:12:30.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
1426	\\x2b68233ed325c990ec68cfc411c1b1a1c3522fef02de0f0821e2092ac1c99e24	13	13354	354	1391	1425	9	4	2023-09-28 10:12:31.8	0	8	0	vrf_vk1axr2vdl6fg4wts9gvryr4txlj2nrfd2ds9e3jv84lds8jk3ncrfq3flux9	\\x3cd1e6448475ebc3c0c9c462811439fc76a890c2b28cde3b696b9ee1277050a9	0
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
1	99	1	addr_test1vzqmaz5x8m50t59n4hk80gyyd6tcwrdvyqq0nj7tsntjmtgy09uk7	\\x6081be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	f	\\x81be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	\N	3681818081394197	\N	fromList []	\N	\N
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
1	7	1	4	2	34	0	\N
2	6	3	6	2	34	0	\N
3	11	5	1	2	34	0	\N
4	4	7	7	2	34	0	\N
5	2	9	5	2	34	0	\N
6	5	11	2	2	34	0	\N
7	3	13	10	2	34	0	\N
8	10	15	8	2	34	0	\N
9	9	17	3	2	34	0	\N
10	1	19	11	2	34	0	\N
11	8	21	9	2	34	0	\N
12	21	0	10	2	37	32	\N
13	3	0	10	2	38	76	\N
14	20	0	9	2	42	140	\N
15	8	0	9	2	43	182	\N
16	15	0	4	2	47	240	\N
17	7	0	4	2	48	256	\N
18	14	0	3	2	52	340	\N
19	9	0	3	2	53	353	\N
20	18	0	7	2	57	426	\N
21	4	0	7	2	58	449	\N
22	19	0	8	2	62	557	\N
23	10	0	8	2	63	574	\N
24	22	0	11	2	67	652	\N
25	1	0	11	2	68	678	\N
26	16	0	5	2	72	760	\N
27	2	0	5	2	73	774	\N
28	2	0	5	2	75	798	\N
29	13	0	2	2	79	878	\N
30	5	0	2	2	80	897	\N
31	5	0	2	2	82	941	\N
32	12	0	1	3	86	1007	\N
33	11	0	1	3	87	1020	\N
34	11	0	1	3	89	1044	\N
35	17	0	6	3	93	1120	\N
36	6	0	6	3	94	1133	\N
37	6	0	6	3	96	1178	\N
38	51	1	11	6	131	4866	\N
39	52	3	3	6	131	4866	\N
40	53	5	7	6	131	4866	\N
41	54	7	10	6	131	4866	\N
42	55	9	4	6	131	4866	\N
43	51	0	11	6	133	4955	\N
44	52	1	11	6	133	4955	\N
45	53	2	11	6	133	4955	\N
46	54	3	11	6	133	4955	\N
47	55	4	11	6	133	4955	\N
48	46	1	3	7	148	5407	\N
49	46	1	11	7	154	5563	\N
50	64	1	3	11	256	9049	\N
51	48	0	12	15	361	13202	\N
52	45	0	13	15	364	13338	\N
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
1	187772653479984806	9155683	51	93	0	2023-09-28 09:28:03	2023-09-28 09:31:19.8
2	81009964537288956	4720848	25	105	1	2023-09-28 09:31:21	2023-09-28 09:34:40.2
12	17899930533409	16922120	100	97	11	2023-09-28 10:04:42.6	2023-09-28 10:07:59
4	0	0	0	94	3	2023-09-28 09:38:03.2	2023-09-28 09:41:18.4
10	5020091238708	425954	2	103	9	2023-09-28 09:58:03.2	2023-09-28 10:01:15.6
7	0	0	0	112	6	2023-09-28 09:48:01.2	2023-09-28 09:51:19.4
14	21282271487544	1479372	8	42	13	2023-09-28 10:11:24.8	2023-09-28 10:12:30.8
6	40991457314546	8747109	18	95	5	2023-09-28 09:44:42.2	2023-09-28 09:47:56.4
9	0	0	0	120	8	2023-09-28 09:54:45	2023-09-28 09:57:58.8
3	0	0	0	109	2	2023-09-28 09:34:41.6	2023-09-28 09:37:51.6
11	0	0	0	93	10	2023-09-28 10:01:21	2023-09-28 10:04:36.6
5	65001782871866	4482363	23	104	4	2023-09-28 09:41:22.8	2023-09-28 09:44:33.8
13	0	0	0	109	12	2023-09-28 10:08:01.4	2023-09-28 10:11:19
8	54988321966311	16961588	100	104	7	2023-09-28 09:51:27.8	2023-09-28 09:54:40.6
\.


--
-- Data for Name: epoch_param; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_param (id, epoch_no, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, nonce, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, block_id, extra_entropy, coins_per_utxo_size) FROM stdin;
1	1	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\x2ea2c6c5304cc0724de57b5c98d66b8a46749923ac5d20f06e0fd0e38e6ccecb	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	96	\N	4310
2	2	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\xeb67fe695c85cb3751cdbc45c5888e860087a77431a915de259dd33f0d5ea259	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	201	\N	4310
3	3	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\xc5ee63377f8f352d2765138513e05397529cd3af7934f7995ca4e3c58c54c07d	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	311	\N	4310
4	4	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\x820d3ae28e29eec8963cd2123566de11fa2778da391c340d1ab5a0d9df3351ce	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	412	\N	4310
5	5	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\xe6a53d9b61f3a7d824d27f70bfcbd78887be9fd6eaec35a8d5e630ae1bcbf884	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	518	\N	4310
6	6	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\x0b658542d5f18239a470cf79c8e7c1131cb167231597d227b11907b2607469c8	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	616	\N	4310
7	7	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\x511d95d2c5e5ea3462409933718017da5ca8778673d466cdd7d488df0a2eb08e	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	731	\N	4310
8	8	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\xe1b3e8da100aefdca41189c19931544a5e74020b87348c2aa5e4a23bfe3947c1	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	842	\N	4310
9	9	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\xb68c6f170df3eb12796d44016caf9c01d9962d089bd127a656b591ad8b1fbe5f	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	964	\N	4310
10	10	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\x819c85fca153729621bce303f66f752870b1eb288f5b90c2d8ac4076810f8f0b	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1070	\N	4310
11	11	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\xc639fbee55142ba5b9b07a86d79358aaa81ac9eb3393e6060085afe39e83d83a	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1165	\N	4310
12	12	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\x868eecb1db13b776d92641e34a5e21d8c43ce72d3c66d3809dab0f3f098259f5	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1267	\N	4310
13	13	44	155381	65536	16384	1100	0	0	18	100	0	0.1	0.1	0	7	0	4310	0	\\xec4460bd33cb1c8b1a922db9609cfab9f78369e1cebf02c135108c9c8bd53f24	1	0.0577	7.21e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1381	\N	4310
\.


--
-- Data for Name: epoch_stake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_stake (id, addr_id, pool_id, amount, epoch_no) FROM stdin;
1	7	4	3681818181818181	1
2	6	6	3681818181818190	1
3	11	1	3681818181818181	1
4	4	7	3681818181818181	1
5	2	5	3681818181818181	1
6	5	2	3681818181818181	1
7	3	10	3681818181818181	1
8	10	8	3681818181818181	1
9	9	3	3681818181818181	1
10	1	11	3681818181818181	1
11	8	9	3681818181818181	1
12	13	2	300000000	2
13	7	4	3681818181443619	2
14	6	6	3681818181818190	2
15	11	1	3681818181818181	2
16	4	7	3681818181443619	2
17	21	10	500000000	2
18	2	5	3681818181265842	2
19	5	2	3681818181265842	2
20	14	3	500000000	2
21	3	10	3681818181443619	2
22	16	5	300000000	2
23	10	8	3681818181443619	2
24	9	3	3681818181443619	2
25	1	11	3681818181443619	2
26	20	9	600000000	2
27	22	11	500000000	2
28	18	7	500000000	2
29	8	9	3681818181446391	2
30	19	8	500000000	2
31	15	4	200000000	2
32	17	6	500000000	3
33	13	2	300000000	3
34	7	4	3681818181443619	3
35	6	6	3681818181263035	3
36	11	1	3681818181263026	3
37	4	7	3681818181443619	3
38	12	1	500000000	3
39	21	10	500000000	3
40	2	5	3681818181265842	3
41	5	2	3681818181265842	3
42	14	3	500000000	3
43	3	10	3681818181443619	3
44	16	5	300000000	3
45	10	8	3681818181443619	3
46	9	3	3681818181443619	3
47	1	11	3681818181443619	3
48	20	9	600000000	3
49	22	11	500000000	3
50	18	7	500000000	3
51	8	9	3681818181446391	3
52	19	8	500000000	3
53	15	4	200000000	3
54	17	6	500000000	4
55	13	2	300000000	4
56	7	4	3689384290495631	4
57	6	6	3688543611531490	4
58	11	1	3689384290315038	4
59	4	7	3691906326846302	4
60	12	1	500000000	4
61	21	10	500000000	4
62	2	5	3688543611534297	4
63	5	2	3687702932750740	4
64	14	3	500000000	4
65	3	10	3691065648062745	4
66	16	5	300000000	4
67	10	8	3691065648062745	4
68	9	3	3690224969279188	4
69	1	11	3691906326846302	4
70	20	9	600000000	4
71	22	11	500000000	4
72	18	7	500000000	4
73	8	9	3688543611714846	4
74	19	8	500000000	4
75	15	4	200000000	4
76	17	6	500000000	5
77	13	2	300704934	5
78	7	4	3701181745832090	5
79	6	6	3694049091286070	5
80	11	1	3700395249824199	5
81	4	7	3696625308211866	5
82	12	1	500000000	5
83	21	10	500854465	5
84	2	5	3698768072270985	5
85	5	2	3696354399527938	5
86	14	3	500961273	5
87	3	10	3697357623216831	5
88	16	5	300833104	5
89	10	8	3700503610793874	5
90	9	3	3697303441327535	5
91	1	11	3695838811317605	5
92	20	9	601281698	5
93	22	11	500534041	5
94	18	7	500640849	5
95	8	9	3696408580230214	5
96	19	8	501281698	5
97	15	4	200640849	5
98	17	6	500806057	6
99	54	11	0	6
100	13	2	300704934	6
101	7	4	3701181745832090	6
102	6	6	3699984602599038	6
103	11	1	3702939040386899	6
104	4	7	3700949420668291	6
105	12	1	500345453	6
106	21	10	1272728787218	6
107	2	5	3698768072270985	6
108	5	2	3696354399527938	6
109	53	11	0	6
110	14	3	1399901537308	6
111	3	10	3704564698310842	6
112	16	5	300833104	6
113	10	8	3706269196069093	6
114	51	11	499375158	6
115	9	3	3705231274080940	6
116	1	11	3703766627071012	6
117	20	9	1145639716251	6
118	52	11	0	6
119	22	11	1399918110074	6
120	18	7	763970000482	6
121	8	9	3702894914312471	6
122	19	8	1018358427890	6
123	15	4	200640849	6
124	55	11	499837675	6
125	17	6	1551013758338	7
126	54	11	0	7
127	13	2	300704934	7
128	7	4	3701181745832090	7
129	6	6	3708768624723854	7
130	4	7	3705674817456629	7
131	21	10	2226366281937	7
132	5	2	3696354399527938	7
133	53	11	0	7
134	14	3	2592119999478	7
135	3	10	3709966429236048	7
136	10	8	3710320402888010	7
137	51	11	499375158	7
138	9	3	3711985075932617	7
139	1	11	3707816919818165	7
140	20	9	2576908122389	7
141	52	11	0	7
142	22	11	2115066299026	7
143	18	7	1598254304267	7
144	8	9	3711003216487629	7
145	19	8	1733677923917	7
146	15	4	200640849	7
147	55	11	499837675	7
148	46	11	4998922339163	7
149	17	6	2660209327830	8
150	54	11	0	8
151	13	2	300704934	8
152	7	4	3701181745832090	8
153	6	6	3715051850614631	8
154	4	7	3712651350748595	8
155	21	10	3334569599542	8
156	5	2	3696354399527938	8
157	53	11	0	8
158	14	3	3454125207359	8
159	3	10	3716244032366603	8
160	10	8	3714501794512629	8
161	51	11	499375158	8
162	9	3	3716867671033537	8
163	1	11	3714097102878133	8
164	20	9	3685396023783	8
165	52	11	0	8
166	22	11	3223724898475	8
167	18	7	2829798349725	8
168	8	9	3717282431119414	8
169	19	8	2471971229937	8
170	15	4	200640849	8
171	55	11	499837675	8
172	46	11	4998922339163	8
173	17	6	3733007094574	9
174	54	11	0	9
175	13	2	300704934	9
176	7	4	3701181745832090	9
177	6	6	3721128822475918	9
178	4	7	3720546196340687	9
179	21	10	3978614390416	9
180	5	2	3696354399527938	9
181	53	11	0	9
182	14	3	4419989846200	9
183	3	10	3719883074727321	9
184	10	8	3717533288249247	9
185	51	11	500847407	9
186	9	3	3722325061333427	9
187	1	11	3725016488093113	9
188	20	9	4866213157397	9
189	52	11	0	9
190	22	11	5155921298696	9
191	18	7	4225313685665	9
192	8	9	3723957749685095	9
193	19	8	3008320657305	9
194	15	4	200640849	9
195	55	11	501311288	9
196	46	11	4998905377575	9
197	17	6	4476797134737	10
198	54	11	0	10
199	13	2	300704934	10
200	7	4	3701181745832090	10
201	6	6	3725329710576748	10
202	4	7	3727378367443814	10
203	21	10	4908754317282	10
204	5	2	3696354399527938	10
205	53	11	0	10
206	14	3	5721921184184	10
207	3	10	3725130663646682	10
208	10	8	3720682236324211	10
209	51	11	501905384	10
210	9	3	3729666398671361	10
211	1	11	3732871879421619	10
212	20	9	6261477792210	10
213	52	11	0	10
214	22	11	6549697900866	10
215	18	7	5434847656116	10
216	8	9	3731825616481183	10
217	19	8	3566148402365	10
218	15	4	200640849	10
219	55	11	502370245	10
220	46	11	5009496108467	10
221	17	6	5589068958889	11
222	54	11	0	11
223	13	2	300704934	11
224	7	4	3701181745832090	11
225	6	6	3731600439355301	11
226	4	7	3732756210000469	11
227	21	10	6101068563993	11
228	5	2	3696354399527938	11
229	53	11	0	11
230	14	3	6357947203475	11
231	3	10	3731844737648801	11
232	10	8	3726058430233788	11
233	51	11	502746205	11
234	9	3	3733246270689549	11
235	1	11	3739125481987058	11
236	20	9	7295022234157	11
237	52	11	0	11
238	22	11	7661536271783	11
239	18	7	6389091064978	11
240	8	9	3737641716914790	11
241	19	8	4519497697042	11
242	15	4	200640849	11
243	55	11	503211845	11
244	64	3	2504747966885	11
245	46	11	2513164639768	11
246	17	6	6408863541842	12
247	54	11	0	12
248	13	2	300704934	12
249	7	4	3701181745832090	12
250	6	6	3736212884203344	12
251	4	7	3739930532694441	12
252	21	10	7650268518530	12
253	5	2	3696354399527938	12
254	53	11	0	12
255	14	3	7360358540157	12
256	3	10	3740559190229437	12
257	10	8	3731703568348566	12
258	51	11	503363596	12
259	9	3	3738879908037741	12
260	1	11	3743717289190502	12
261	20	9	8570892562790	12
262	52	11	0	12
263	22	11	8480810106971	12
264	18	7	7665123499157	12
265	8	9	3744807017943292	12
266	19	8	5521472877956	12
267	15	4	200640849	12
268	55	11	503829808	12
269	64	3	2504747966885	12
270	46	11	2519326762753	12
271	17	6	7155116124793	13
272	54	11	0	13
273	13	2	300704934	13
274	7	4	3701181745832090	13
275	6	6	3740405847103218	13
276	4	7	3744642650930493	13
277	21	10	8583550516186	13
278	5	2	3696354399527938	13
279	53	11	0	13
280	14	3	8573242154387	13
281	3	10	3745799542068634	13
282	10	8	3738004087734991	13
283	51	11	504204374	13
284	9	3	3745681255948912	13
285	1	11	3749970494373767	13
286	20	9	9690610445785	13
287	52	11	0	13
288	22	11	9599096190331	13
289	18	7	8505146935597	13
290	8	9	3751079711306836	13
291	19	8	6640833752357	13
292	15	4	200640849	13
293	55	11	504671364	13
294	64	3	2504685775725	13
295	46	11	2527763803073	13
\.


--
-- Data for Name: epoch_sync_time; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_sync_time (id, no, seconds, state) FROM stdin;
1	0	1	lagging
2	1	1	lagging
3	2	1	following
4	3	183	following
5	4	200	following
6	5	200	following
7	6	207	following
8	7	198	following
9	8	199	following
10	9	198	following
11	10	202	following
12	11	199	following
13	12	204	following
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
27	1	126	15
28	1	127	16
29	1	128	17
30	-1	129	15
31	-1	129	16
32	-1	129	17
33	-1	129	12
34	-1	129	14
35	10	134	18
36	-10	135	18
38	1	137	19
39	-1	138	19
40	1	358	9
41	1	358	10
42	1	358	11
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
23	1	156	12
24	1	156	13
25	1	156	14
26	1	159	12
27	1	159	14
28	1	160	15
29	1	162	16
30	1	163	15
31	1	164	17
32	10	214	18
34	1	219	19
35	1	786	9
36	1	786	10
37	1	786	11
38	13500000000000000	795	1
39	13500000000000000	795	2
40	13500000000000000	795	3
41	13500000000000000	795	4
42	2	799	5
43	1	799	6
44	1	799	7
\.


--
-- Data for Name: meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meta (id, start_time, network_name, version) FROM stdin;
1	2023-09-28 09:28:01	testnet	Version {versionBranch = [13,1,0,2], versionTags = []}
\.


--
-- Data for Name: multi_asset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.multi_asset (id, policy, name, fingerprint) FROM stdin;
1	\\x47e4dc69d2ff54e6687d76a23073df0074609b3e2f9c1710d48f79a6	\\x	asset1dnt9l9748pah727gdfejvunk566r2gq9asrvjw
2	\\x47e4dc69d2ff54e6687d76a23073df0074609b3e2f9c1710d48f79a6	\\x74425443	asset162cc8mpd7js3c0n4jjghn6sm6r274s4gw8w84h
3	\\x47e4dc69d2ff54e6687d76a23073df0074609b3e2f9c1710d48f79a6	\\x74455448	asset13qyr8jaqsphqqfcvryx6k7p5fuegp84ffylkaw
4	\\x47e4dc69d2ff54e6687d76a23073df0074609b3e2f9c1710d48f79a6	\\x744d494e	asset1lqx7x5esnmfl72wdym3xzwjpfujyhedtqts6qz
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
1	\\x06a490b80eac2d254b27d8c03931b3a62d1dca887ec95e8c53c38221	pool1q6jfpwqw4skj2je8mrqrjvdn5ck3mj5g0my4arzncwpzzj77y57
2	\\x1ec7fbddb6f08fa52e32400f2f9bbb40b5e7f8ee6eca6f8605f4d7d6	pool1rmrlhhdk7z862t3jgq8jlxamgz67078wdm9xlps97ntavgk9cjf
3	\\x3a2ff5dc815247bc3b2af97264100a969ffec277d61157b987f22d49	pool18ghlthyp2frmcwe2l9exgyq2j60lasnh6cg40wv87gk5j93rfg8
4	\\x3f4884203fb68a67ee5ca0d9c478407b6e92495dfeeb00f10fac81b5	pool18aygggplk69x0mju5rvug7zq0dhfyj2alm4spug04jqm2yju7ts
5	\\x62eef762f61afbbf0d9933fc176c76ebf2dc42cf12b676a667fa9be0	pool1vth0wchkrtam7rvex07pwmrka0edcsk0z2m8dfn8l2d7qcsk77l
6	\\x68585cfaa56a30128936c60d5aa5d968ac8c355830e9f88cdab9a4a1	pool1dpv9e749dgcp9zfkccx44fwedzkgcd2cxr5l3rx6hxj2zgez6m8
7	\\x71ebe7cddbd11ba29fbef4961c7aef58e6e48d1cacc3579eafdfc448	pool1w8470nwm6yd698a77jtpc7h0trnwfrgu4np40840mlzysu8mp3m
8	\\x9724f6b4d850f32f10527f3471eae21b96872ea14549037d458653ed	pool1juj0ddxc2rej7yzj0u68r6hzrwtgwt4pg4ysxl29sef7655geqe
9	\\xb12d8e73cf7da3150e6540ae70c288b3271f5d8593845b75121c1d97	pool1kykcuu700k332rn9gzh8ps5gkvn37hv9jwz9kagjrswewzdnpqd
10	\\xb2b13c9b339420a201e3660abe96e0ed4373d0496708a8d623bbd1a7	pool1k2cnexenjss2yq0rvc9ta9hqa4ph85zfvuy2343rh0g6wvx6nz9
11	\\xf0bda71a98da1ced787ff76a0e60d0f43cf600346c2fe77fc53fc3b2	pool17z76wx5cmgww67rl7a4qucxs7s70vqp5dsh7wl798lpmys3628c
12	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
13	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_metadata_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata_ref (id, pool_id, url, hash, registered_tx_id) FROM stdin;
1	10	http://file-server/SP1.json	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	39
2	4	http://file-server/SP3.json	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	49
3	3	http://file-server/SP4.json	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	54
4	7	http://file-server/SP5.json	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	59
5	8	http://file-server/SP6.json	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	64
6	11	http://file-server/SP7.json	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	69
7	1	http://file-server/SP10.json	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	88
8	6	http://file-server/SP11.json	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	95
\.


--
-- Data for Name: pool_offline_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_offline_data (id, pool_id, ticker_name, hash, json, bytes, pmr_id) FROM stdin;
1	10	SP1	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	{"name": "stake pool - 1", "ticker": "SP1", "homepage": "https://stakepool1.com", "description": "This is the stake pool 1 description."}	\\x7b0a2020226e616d65223a20227374616b6520706f6f6c202d2031222c0a2020227469636b6572223a2022535031222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2031206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c312e636f6d220a7d0a	1
2	4	SP3	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	{"name": "Stake Pool - 3", "ticker": "SP3", "homepage": "https://stakepool3.com", "description": "This is the stake pool 3 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2033222c0a2020227469636b6572223a2022535033222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2033206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c332e636f6d220a7d0a	2
3	3	SP4	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	{"name": "Same Name", "ticker": "SP4", "homepage": "https://stakepool4.com", "description": "This is the stake pool 4 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535034222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2034206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c342e636f6d220a7d0a	3
4	7	SP5	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	{"name": "Same Name", "ticker": "SP5", "homepage": "https://stakepool5.com", "description": "This is the stake pool 5 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535035222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2035206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c352e636f6d220a7d0a	4
5	8	SP6a7	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	{"name": "Stake Pool - 6", "ticker": "SP6a7", "homepage": "https://stakepool6.com", "description": "This is the stake pool 6 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2036222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2036206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c362e636f6d220a7d0a	5
6	11	SP6a7	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	{"name": "", "ticker": "SP6a7", "homepage": "https://stakepool7.com", "description": "This is the stake pool 7 description."}	\\x7b0a2020226e616d65223a2022222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2037206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c372e636f6d220a7d0a	6
7	1	SP10	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	{"name": "Stake Pool - 10", "ticker": "SP10", "homepage": "https://stakepool10.com", "description": "This is the stake pool 10 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130222c0a2020227469636b6572223a202253503130222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203130206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31302e636f6d220a7d0a	7
8	6	SP11	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	{"name": "Stake Pool - 10 + 1", "ticker": "SP11", "homepage": "https://stakepool11.com", "description": "This is the stake pool 11 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130202b2031222c0a2020227469636b6572223a202253503131222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203131206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31312e636f6d220a7d0a	8
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
2	20	13
3	15	14
4	14	15
5	18	16
6	19	17
7	22	18
8	16	19
9	13	20
10	12	21
11	17	22
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
1	5	0	76	5
2	2	0	83	18
3	1	0	90	5
4	6	0	97	18
\.


--
-- Data for Name: pool_update; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_update (id, hash_id, cert_index, vrf_key_hash, pledge, active_epoch_no, meta_id, margin, fixed_cost, registered_tx_id, reward_addr_id) FROM stdin;
1	1	0	\\xf6e7724b9adc2e35e81eff12756b9a40e641a47b9421c3c6c86fcca37a4f94d2	0	2	\N	0	0	34	12
2	2	1	\\x4e9dd8e39738384ca3c3a2aba4b8002a98101325dde98ca54422d4b2e4a47d00	0	2	\N	0	0	34	13
3	3	2	\\x4299b489ea694702f0072399dde367cbc29409591cbeb443b4b11a9c3a721719	0	2	\N	0	0	34	14
4	4	3	\\x1d7f2b45e4794f5e49e72bb9eacbcf387c4dca4cd3aba1dbab5ca4cd9441b83e	0	2	\N	0	0	34	15
5	5	4	\\xb405742abe4ba06b358781c194a05b712bb8242a27022dc96b51e93cc796edac	0	2	\N	0	0	34	16
6	6	5	\\x593bdb4a05eaf806b61d1f460b28adb6708a0068953b7df9051ee79359b9038e	0	2	\N	0	0	34	17
7	7	6	\\xb4b10d353ef6478b60cdc8fa4812ccb7d9f04978abb809471426f3372a7ecf9f	0	2	\N	0	0	34	18
8	8	7	\\xe868c03e2e936d338a15aabe477df776be8a844d5a7e6b0575915ccc2605f541	0	2	\N	0	0	34	19
9	9	8	\\xa3594871b135bd238d335f7ee238f3fb1ed355ec59ac17cdd1bc50c6a7794e08	0	2	\N	0	0	34	20
10	10	9	\\x0322b3ffb521d23495ef4332eddfabebc9f15c8d50b19e15c265a502622a8c2d	0	2	\N	0	0	34	21
11	11	10	\\x91e0840b5ffa7724952aeb1ab16a9ced8daad8563c1fc54a42dc0efcd6e7549b	0	2	\N	0	0	34	22
12	10	0	\\x0322b3ffb521d23495ef4332eddfabebc9f15c8d50b19e15c265a502622a8c2d	400000000	3	1	0.15	390000000	39	21
13	9	0	\\xa3594871b135bd238d335f7ee238f3fb1ed355ec59ac17cdd1bc50c6a7794e08	500000000	3	\N	0.15	390000000	44	20
14	4	0	\\x1d7f2b45e4794f5e49e72bb9eacbcf387c4dca4cd3aba1dbab5ca4cd9441b83e	600000000	3	2	0.15	390000000	49	15
15	3	0	\\x4299b489ea694702f0072399dde367cbc29409591cbeb443b4b11a9c3a721719	420000000	3	3	0.15	370000000	54	14
16	7	0	\\xb4b10d353ef6478b60cdc8fa4812ccb7d9f04978abb809471426f3372a7ecf9f	410000000	3	4	0.15	390000000	59	18
17	8	0	\\xe868c03e2e936d338a15aabe477df776be8a844d5a7e6b0575915ccc2605f541	410000000	3	5	0.15	400000000	64	19
18	11	0	\\x91e0840b5ffa7724952aeb1ab16a9ced8daad8563c1fc54a42dc0efcd6e7549b	410000000	3	6	0.15	390000000	69	22
19	5	0	\\xb405742abe4ba06b358781c194a05b712bb8242a27022dc96b51e93cc796edac	500000000	3	\N	0.15	380000000	74	16
20	2	0	\\x4e9dd8e39738384ca3c3a2aba4b8002a98101325dde98ca54422d4b2e4a47d00	500000000	3	\N	0.15	390000000	81	13
21	1	0	\\xf6e7724b9adc2e35e81eff12756b9a40e641a47b9421c3c6c86fcca37a4f94d2	400000000	4	7	0.15	410000000	88	12
22	6	0	\\x593bdb4a05eaf806b61d1f460b28adb6708a0068953b7df9051ee79359b9038e	400000000	4	8	0.15	390000000	95	17
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
2	4	::
3	5	2:36:
4	6	::
5	7	::
6	8	3:37:
7	9	::
8	10	4:38:
9	11	::
10	12	::
11	13	5:39:
12	14	::
13	15	::
14	16	6:40:
15	17	::
16	18	::
17	19	7:42:
18	20	::
19	21	::
20	22	8:43:
21	23	9:44:
22	24	10:45:
23	25	::
24	26	11:46:
25	27	12:48:
26	28	::
27	29	13:49:
28	30	14:50:
29	31	15:51:
30	32	16:52:
31	33	::
32	34	17:54:
33	35	::
34	36	18:55:
35	37	::
36	38	19:56:
37	39	20:57:
38	40	::
39	41	21:58:
40	42	22:60:
41	43	23:61:
42	44	::
43	45	::
44	46	24:62:
45	47	25:63:
46	48	::
47	49	::
48	50	26:64:
49	51	::
50	52	27:66:
51	53	::
52	54	::
53	55	28:67:
54	56	29:68:
55	57	::
56	58	30:69:
57	59	31:70:
58	60	32:72:
59	61	::
60	62	33:73:
61	63	::
62	64	34:74:
63	65	::
64	66	35:75:
65	67	36:76:
66	68	::
67	69	37:78:
68	70	38:79:
69	71	39:80:
70	72	::
71	73	40:81:
72	74	41:82:
73	75	::
74	76	42:83:
75	77	::
76	78	::
77	79	43:84:
78	80	::
79	81	44:86:
80	82	::
81	83	::
82	84	45:87:
83	85	46:88:
84	86	::
85	87	47:89:
86	88	::
87	89	48:90:
88	90	::
89	91	49:91:
90	92	50:92:
91	93	::
92	94	51:94:
93	95	::
94	96	::
95	97	52:95:
96	98	53:96:
97	99	54:97:
98	100	55:98:
99	101	56:99:
100	102	::
101	103	57:100:
102	104	58:102:
103	105	::
104	106	59:103:
105	107	60:104:
106	108	::
107	109	61:105:
108	110	::
109	111	62:106:
110	112	::
111	113	::
112	114	63:107:
113	115	64:108:
114	116	::
115	117	65:110:
116	118	::
117	119	::
118	120	66:111:
119	121	::
120	122	67:113:
121	123	::
122	124	68:115:
123	125	::
124	126	::
125	127	::
126	128	69:117:
127	129	::
128	130	::
129	131	70:119:
130	132	71:121:
131	133	::
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
328	330	::
329	331	::
330	332	::
331	333	::
333	335	::
334	336	::
335	337	::
336	338	::
337	339	::
338	340	::
340	342	::
341	343	::
342	344	::
343	345	::
344	346	::
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
398	400	::
399	401	::
400	402	::
401	403	::
402	404	::
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
423	425	78:136:9
424	426	::
425	427	::
426	428	::
427	429	79:138:12
428	430	::
429	431	::
430	432	::
431	433	81:140:15
432	434	::
433	435	::
434	436	::
435	437	82:142:
436	438	::
437	439	::
438	440	::
439	441	83:143:
440	442	::
441	443	::
442	444	::
443	445	84:144:17
444	446	::
445	447	::
446	448	::
447	449	85:146:18
448	450	::
449	451	::
450	452	::
451	453	87:148:
452	454	::
453	455	::
454	456	::
455	457	89:149:20
456	458	::
457	459	::
458	460	::
459	461	90:151:
460	462	::
461	463	::
462	464	::
463	465	91:152:21
464	466	::
465	467	::
466	468	::
467	469	92:154:22
468	470	::
469	471	::
470	472	::
471	473	93:155:
472	474	::
473	475	::
474	476	::
475	477	::
476	478	94:156:23
477	479	::
478	480	::
479	481	::
480	482	95:158:26
481	483	::
482	484	::
483	485	::
484	486	97:160:28
485	487	::
487	489	::
488	490	::
489	491	98:162:29
490	492	::
491	493	::
492	494	::
493	495	100:164:31
494	496	::
495	497	::
496	498	::
497	499	101:166:
498	500	::
499	501	::
500	502	::
501	503	105:167:
502	504	::
503	505	::
504	506	::
505	507	107:169:
506	508	::
507	509	::
508	510	::
509	511	108:204:
510	512	::
511	513	::
512	514	::
513	515	143:213:
514	516	::
515	517	::
516	518	::
517	519	144:214:32
518	520	::
519	521	::
520	522	::
521	523	145:216:
522	524	::
523	525	::
524	526	::
526	528	147:219:34
527	529	::
528	530	::
529	531	::
530	532	148:221:
531	533	::
532	534	::
533	535	::
534	536	149:222:
535	537	::
536	538	150:224:
537	539	::
538	540	155:226:
539	541	::
540	542	::
541	543	157:346:
542	544	::
544	546	280:352:
545	547	::
546	548	::
547	549	::
548	550	343:356:
549	551	::
550	552	::
551	553	::
552	554	344:358:
553	555	345:360:
554	556	347:361:
555	557	348::
556	558	::
557	559	349:363:
558	560	::
559	561	::
560	562	350:365:
561	563	::
562	564	::
563	565	::
564	566	::
565	567	351:367:
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
696	698	::
697	699	::
698	700	::
699	701	::
700	702	::
701	703	::
702	704	::
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
730	732	352:368:
731	733	356:374:
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
784	786	::
785	787	::
786	788	::
787	789	::
788	790	::
789	791	::
790	792	::
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
815	817	::
817	819	::
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
963	965	537:568:
964	966	::
965	967	::
966	968	::
967	969	538:570:
968	970	::
969	971	::
970	972	::
971	973	::
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
1164	1166	557:584:
1165	1167	594:640:
1166	1168	606:660:
1167	1169	705:780:
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
1237	1239	::
1238	1240	::
1239	1241	::
1240	1242	::
1241	1243	::
1242	1244	::
1243	1245	::
1244	1246	::
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
1380	1382	709:784:
1381	1383	::
1382	1384	::
1384	1386	::
1386	1388	::
1387	1389	::
1388	1390	::
1389	1391	710:786:35
1390	1392	::
1391	1393	::
1392	1394	::
1393	1395	::
1394	1396	::
1395	1397	::
1396	1398	::
1397	1399	::
1398	1400	714:788:
1399	1401	::
1400	1402	::
1401	1403	::
1402	1404	715:790:
1403	1405	::
1405	1407	::
1406	1408	::
1407	1409	716:792:
1408	1410	::
1409	1411	::
1410	1412	::
1411	1413	717:794:38
1412	1414	::
1413	1415	::
1414	1416	::
1415	1417	::
1416	1418	::
1417	1419	718:796:
1418	1420	::
1419	1421	::
1420	1422	::
1421	1423	720:798:42
1422	1424	::
1423	1425	::
1424	1426	::
\.


--
-- Data for Name: reward; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward (id, addr_id, type, amount, earned_epoch, spendable_epoch, pool_id) FROM stdin;
1	7	member	7566109052012	1	3	4
2	6	member	6725430268455	1	3	6
3	11	member	7566109052012	1	3	1
4	4	member	10088145402683	1	3	7
5	2	member	6725430268455	1	3	5
6	5	member	5884751484898	1	3	2
7	3	member	9247466619126	1	3	10
8	10	member	9247466619126	1	3	8
9	9	member	8406787835569	1	3	3
10	1	member	10088145402683	1	3	11
11	8	member	6725430268455	1	3	9
12	17	leader	0	1	3	6
13	13	leader	0	1	3	2
14	12	leader	0	1	3	1
15	21	leader	0	1	3	10
16	14	leader	0	1	3	3
17	16	leader	0	1	3	5
18	20	leader	0	1	3	9
19	22	leader	0	1	3	11
20	18	leader	0	1	3	7
21	19	leader	0	1	3	8
22	15	leader	0	1	3	4
23	13	member	704934	2	4	2
24	7	member	11797455336459	2	4	4
25	6	member	5505479754580	2	4	6
27	11	member	11010959509161	2	4	1
28	4	member	4718981365564	2	4	7
29	21	member	854465	2	4	10
30	2	member	10224460736688	2	4	5
31	5	member	8651466777198	2	4	2
32	14	member	961273	2	4	3
33	3	member	6291975154086	2	4	10
34	16	member	833104	2	4	5
35	10	member	9437962731129	2	4	8
36	9	member	7078472048347	2	4	3
37	1	member	3932484471303	2	4	11
38	20	member	1281698	2	4	9
39	22	member	534041	2	4	11
40	18	member	640849	2	4	7
41	8	member	7864968515368	2	4	9
42	19	member	1281698	2	4	8
43	15	member	640849	2	4	4
44	17	leader	0	2	4	6
45	13	leader	0	2	4	2
46	12	leader	0	2	4	1
47	21	leader	0	2	4	10
48	14	leader	0	2	4	3
49	16	leader	0	2	4	5
50	20	leader	0	2	4	9
51	22	leader	0	2	4	11
52	18	leader	0	2	4	7
53	19	leader	0	2	4	8
54	15	leader	0	2	4	4
55	17	member	806057	3	5	6
56	6	member	5935511312968	3	5	6
57	11	member	2543790562700	3	5	1
58	4	member	4324112456425	3	5	7
59	12	member	345453	3	5	1
60	3	member	7207075094011	3	5	10
61	10	member	5765585275219	3	5	8
62	9	member	7927832753405	3	5	3
63	1	member	7927815753407	3	5	11
64	8	member	6486334082257	3	5	9
65	17	leader	0	3	5	6
66	13	leader	0	3	5	2
67	12	leader	0	3	5	1
68	21	leader	1272227932753	3	5	10
69	14	leader	1399400576035	3	5	3
70	16	leader	0	3	5	5
71	20	leader	1145038434553	3	5	9
72	22	leader	1399417576033	3	5	11
73	18	leader	763469359633	3	5	7
74	19	leader	1017857146192	3	5	8
75	15	leader	0	3	5	4
76	12	refund	0	5	5	1
77	16	refund	0	5	5	5
78	6	member	8784022124816	4	6	6
79	11	member	5404175798610	4	6	1
80	4	member	4725396788338	4	6	7
81	3	member	5401730925206	4	6	10
82	10	member	4051206818917	4	6	8
83	9	member	6753801851677	4	6	3
84	1	member	4050292747153	4	6	11
85	8	member	8108302175158	4	6	9
86	17	leader	1550512952281	4	6	6
87	13	leader	0	4	6	2
88	12	leader	954088943749	4	6	1
89	21	leader	953637494719	4	6	10
90	14	leader	1192218462170	4	6	3
91	16	leader	0	4	6	5
92	20	leader	1431268406138	4	6	9
93	22	leader	715148188952	4	6	11
94	18	leader	834284303785	4	6	7
95	19	leader	715319496027	4	6	8
96	15	leader	0	4	6	4
97	6	member	6283225890777	5	7	6
98	11	member	4878481264338	5	7	1
99	4	member	6976533291966	5	7	7
100	3	member	6277603130555	5	7	10
101	10	member	4181391624619	5	7	8
102	9	member	4882595100920	5	7	3
103	1	member	6280183059968	5	7	11
104	8	member	6279214631785	5	7	9
105	17	leader	1109195569492	5	7	6
106	13	leader	0	5	7	2
107	12	leader	861319233923	5	7	1
108	21	leader	1108203317605	5	7	10
109	14	leader	862005207881	5	7	3
110	16	leader	0	5	7	5
111	20	leader	1108487901394	5	7	9
112	22	leader	1108658599449	5	7	11
113	18	leader	1231544045458	5	7	7
114	19	leader	738293306020	5	7	8
115	15	leader	0	5	7	4
116	6	member	6076971861287	6	8	6
117	11	member	6072106009053	6	8	1
118	4	member	7894845592092	6	8	7
119	3	member	3639042360718	6	8	10
120	10	member	3031493736618	6	8	8
121	51	member	1472249	6	8	11
122	9	member	5457390299890	6	8	3
123	1	member	10919385214980	6	8	11
124	8	member	6675318565681	6	8	9
125	55	member	1473613	6	8	11
127	17	leader	1072797766744	6	8	6
128	13	leader	0	6	8	2
129	12	leader	1071959084503	6	8	1
130	21	leader	644044790874	6	8	10
131	14	leader	965864638841	6	8	3
132	16	leader	0	6	8	5
133	20	leader	1180817133614	6	8	9
134	22	leader	1932196400221	6	8	11
135	18	leader	1395515335940	6	8	7
136	19	leader	536349427368	6	8	8
137	15	leader	0	6	8	4
138	6	member	4200888100830	7	9	6
139	4	member	6832171103127	7	9	7
140	3	member	5247588919361	7	9	10
141	10	member	3148948074964	7	9	8
142	51	member	1057977	7	9	11
143	9	member	7341337337934	7	9	3
144	1	member	7855391328506	7	9	11
145	8	member	7867866796088	7	9	9
146	55	member	1058957	7	9	11
147	46	member	10590730892	7	9	11
148	17	leader	743790040163	7	9	6
149	13	leader	0	7	9	2
150	21	leader	930139926866	7	9	10
151	14	leader	1301931337984	7	9	3
152	20	leader	1395264634813	7	9	9
153	22	leader	1393776602170	7	9	11
154	18	leader	1209533970451	7	9	7
155	19	leader	557827745060	7	9	8
156	15	leader	0	7	9	4
157	6	member	6270728778553	8	10	6
158	4	member	5377842556655	8	10	7
159	3	member	6714074002119	8	10	10
160	10	member	5376193909577	8	10	8
161	51	member	840821	8	10	11
162	9	member	3579872018188	8	10	3
163	1	member	6253602565439	8	10	11
164	8	member	5816100433607	8	10	9
165	55	member	841600	8	10	11
166	46	member	8416924140	8	10	11
167	17	leader	1112271824152	8	10	6
168	13	leader	0	8	10	2
169	21	leader	1192314246711	8	10	10
170	14	leader	636026019291	8	10	3
171	20	leader	1033544441947	8	10	9
172	22	leader	1111838370917	8	10	11
173	18	leader	954243408862	8	10	7
174	19	leader	953349294677	8	10	8
175	15	leader	0	8	10	4
176	6	member	4612444848043	9	11	6
177	4	member	7174322693972	9	11	7
178	3	member	8714452580636	9	11	10
179	10	member	5645138114778	9	11	8
180	51	member	617391	9	11	11
181	9	member	5633637348192	9	11	3
182	1	member	4591807203444	9	11	11
183	8	member	7165301028502	9	11	9
184	55	member	617963	9	11	11
185	46	member	6162122985	9	11	11
186	17	leader	819794582953	9	11	6
187	13	leader	0	9	11	2
188	21	leader	1549199954537	9	11	10
189	14	leader	1002411336682	9	11	3
190	20	leader	1275870328633	9	11	9
191	22	leader	819273835188	9	11	11
192	18	leader	1276032434179	9	11	7
193	19	leader	1001975180914	9	11	8
194	15	leader	0	9	11	4
195	6	member	4192962899874	10	12	6
196	4	member	4712118236052	10	12	7
197	3	member	5240351839197	10	12	10
198	10	member	6300519386425	10	12	8
199	51	member	840778	10	12	11
200	9	member	6801347911171	10	12	3
201	1	member	6253205183265	10	12	11
202	8	member	6272693363544	10	12	9
203	55	member	841556	10	12	11
204	46	member	8391771280	10	12	11
205	17	leader	746252582951	10	12	6
206	13	leader	0	10	12	2
207	21	leader	933281997656	10	12	10
208	14	leader	1212883614230	10	12	3
209	20	leader	1119717882995	10	12	9
210	22	leader	1118286083360	10	12	11
211	18	leader	840023436440	10	12	7
212	19	leader	1119360874401	10	12	8
213	15	leader	0	10	12	4
214	6	member	6701890233459	11	13	6
215	4	member	3605899685737	11	13	7
216	3	member	6184236419514	11	13	10
217	10	member	3615973156639	11	13	8
218	51	member	897099	11	13	11
219	9	member	3600679721539	11	13	3
220	1	member	6672087423488	11	13	11
221	8	member	7199250542507	11	13	9
222	55	member	897930	11	13	11
223	64	member	2415805054	11	13	3
224	46	member	4484485548	11	13	11
225	17	leader	1194885772681	11	13	6
226	13	leader	0	11	13	2
227	21	leader	1103620429298	11	13	10
228	14	leader	643424714393	11	13	3
229	20	leader	1287376909105	11	13	9
230	22	leader	1194692687486	11	13	11
231	18	leader	643986367896	11	13	7
232	19	leader	643672875288	11	13	8
233	15	leader	0	11	13	4
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
5	107	\\x47e4dc69d2ff54e6687d76a23073df0074609b3e2f9c1710d48f79a6	timelock	{"type": "sig", "keyHash": "e8b5fd706d641dfb1e814a8a6774d8d1219c24361acd29a2fee9220b"}	\N	\N
6	109	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	timelock	{"type": "sig", "keyHash": "5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967"}	\N	\N
7	124	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}]}	\N	\N
8	134	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}, {"type": "sig", "keyHash": "3178bf14adf78294ac2d03d60b9edfb7323d3d719e98b4b0b3ca34cd"}]}	\N	\N
\.


--
-- Data for Name: slot_leader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slot_leader (id, hash, pool_hash_id, description) FROM stdin;
1	\\xfa2df9e46e192701f78174776f77e8bda997b0ffe62043015b34416b	\N	Genesis slot leader
2	\\x5368656c6c65792047656e6573697320536c6f744c65616465722048	\N	Shelley Genesis slot leader
18	\\xb2b13c9b339420a201e3660abe96e0ed4373d0496708a8d623bbd1a7	10	Pool-b2b13c9b339420a2
3	\\x68585cfaa56a30128936c60d5aa5d968ac8c355830e9f88cdab9a4a1	6	Pool-68585cfaa56a3012
6	\\xf0bda71a98da1ced787ff76a0e60d0f43cf600346c2fe77fc53fc3b2	11	Pool-f0bda71a98da1ced
5	\\xb12d8e73cf7da3150e6540ae70c288b3271f5d8593845b75121c1d97	9	Pool-b12d8e73cf7da315
22	\\x9724f6b4d850f32f10527f3471eae21b96872ea14549037d458653ed	8	Pool-9724f6b4d850f32f
4	\\x06a490b80eac2d254b27d8c03931b3a62d1dca887ec95e8c53c38221	1	Pool-06a490b80eac2d25
51	\\x1ec7fbddb6f08fa52e32400f2f9bbb40b5e7f8ee6eca6f8605f4d7d6	2	Pool-1ec7fbddb6f08fa5
7	\\x3a2ff5dc815247bc3b2af97264100a969ffec277d61157b987f22d49	3	Pool-3a2ff5dc815247bc
9	\\x3f4884203fb68a67ee5ca0d9c478407b6e92495dfeeb00f10fac81b5	4	Pool-3f4884203fb68a67
33	\\x62eef762f61afbbf0d9933fc176c76ebf2dc42cf12b676a667fa9be0	5	Pool-62eef762f61afbbf
13	\\x71ebe7cddbd11ba29fbef4961c7aef58e6e48d1cacc3579eafdfc448	7	Pool-71ebe7cddbd11ba2
\.


--
-- Data for Name: stake_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_address (id, hash_raw, view, script_hash) FROM stdin;
7	\\xe01dc944ce77d7bbd854957313c13d46fcdd2f8532fd81aade86a01a66	stake_test1uqwuj3xwwltmhkz5j4e38sfagm7d6tu9xt7cr2k7s6sp5esu7rfag	\N
6	\\xe01eb57292befc84cce36ceeecc3651559e5746eee4a9b0283477d33b5	stake_test1uq0t2u5jhm7gfn8rdnhwesm9z4v72arwae9fkq5rga7n8dg9x7qyy	\N
11	\\xe02b0e07d0dd282968d2f49ca477cdc254ee08257943c75ec8521dc9b5	stake_test1uq4sup7sm55zj6xj7jw2ga7dcf2wuzp909puwhkg2gwundg2l6uqn	\N
4	\\xe037f05b9740800c216fb65c36725bba2fc9c97fbd3bfe3fda08c91496	stake_test1uqmlqkuhgzqqcgt0kewrvujmhghunjtlh5alu076pry3f9sn94kkf	\N
2	\\xe0448c04a027354cd161e96fbfa65ace53b1326392d5b2ee42284e01f7	stake_test1upzgcp9qyu65e5tpa9hmlfj6eefmzvnrjt2m9mjz9p8qraceud2wv	\N
5	\\xe0468ed0972936bf05ca0601ce92846e0880bbbdef4a31e7de0cfff416	stake_test1uprga5yh9ymt7pw2qcquay5ydcygpwaaaa9rre77pnllg9sakdrl4	\N
3	\\xe05830d0279f1d37da7ffac5c83a4a660d69ade953db1dba65bed28810	stake_test1upvrp5p8nuwn0knlltzuswj2vcxknt0f20d3mwn9hmfgsyq82sk2g	\N
10	\\xe065b901745484cd2f97703395df21ec044fe0573203a4da49f2bcfff7	stake_test1upjmjqt52jzv6tuhwqeethepaszylczhxgp6fkjf7270lac6y0uvx	\N
9	\\xe0758340aa7e090b63f998dab832f053c030c3e238692dfd3973636e63	stake_test1up6cxs920cyskclenrdtsvhs20qrpslz8p5jmlfewd3kucc3v3x50	\N
1	\\xe0760f85868eced115e14d7189c2ae0fa7e0efbee07075fdd9073b0a67	stake_test1upmqlpvx3m8dz90pf4ccns4wp7n7pma7upc8tlwequas5eclum677	\N
8	\\xe0af2745b3fb6c7ebff4c8ed297515adbfa60aa0c5bbc452b0738b2a6a	stake_test1uzhjw3dnldk8a0l5erkjjag44kl6vz4qckaug54sww9j56setga4z	\N
21	\\xe03fb95394b27ef3eda89e6b166a0d057622c72916cf32a3372032295b	stake_test1uqlmj5u5kfl08mdgne43v6sdq4mz93efzm8n9gehyqezjkca4mvm4	\N
20	\\xe0855c1066149b4f371b69b68d3f59c90b8e7d52bfb6ac3532c4328e5f	stake_test1uzz4cyrxzjd57dcmdxmg606eey9cul2jh7m2cdfjcseguhc427j50	\N
15	\\xe0c27fa0f6db59f6d7fe28db2851c372f3b1720f8d12b59da2657965c9	stake_test1urp8lg8kmdvld4l79rdjs5wrwtemzus035ftt8dzv4uktjgcj2v6j	\N
14	\\xe0580d9c2e45c37b0837a10402c331138d7d786c0397b094c6f96a895d	stake_test1upvqm8pwghphkzph5yzq9se3zwxh67rvqwtmp9xxl94gjhguy3f87	\N
18	\\xe0ae105797fd432cbec2ff689cf460a504f82f4982547233c6f379a43c	stake_test1uzhpq4uhl4pje0kzla5fearq55z0st6fsf28yv7x7du6g0qm9fn0e	\N
19	\\xe0c127002d387ca5f42fd4984fabc46e6e2fa0f013428963254783d9ed	stake_test1urqjwqpd8p72tap06jvyl27ydehzlg8szdpgjce9g7panmg7p00yu	\N
22	\\xe09a5a2df5b56ea0a4751a37a2075ed61d28e1b333aeb059eacf52abdb	stake_test1uzd95t04k4h2pfr4rgm6yp676cwj3cdnxwhtqk02eaf2hkcqeeyg2	\N
16	\\xe05f70262da4edd085f3597cc218a0fa04dc342a91ddd58979a1195b29	stake_test1up0hqf3d5nkapp0nt97vyx9qlgzdcdp2j8watzte5yv4k2gjjyr9y	\N
13	\\xe01711752a2514a59a09245d4a1bdd756df71842544fa0ebd49e0828d9	stake_test1uqt3zaf2y522txsfy3w55x7aw4klwxzz2386p675ncyz3kgxyxvyp	\N
12	\\xe03ba08437c4cf5a810c2c74b07bbd5fc242765544aaab78436b66dba8	stake_test1uqa6ppphcn844qgv936tq7aatlpyyaj4gj42k7zrddndh2qxhc62e	\N
17	\\xe008c26a2df820e2a9f0a52c73cd0fac56428eec3ddbf49f98cb344f91	stake_test1uqyvy63dlqsw920s55k88ng043ty9rhv8hdlf8ucev6ylygscfwyj	\N
47	\\xe01bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	stake_test1uqdlrcfc7tuta27fv0y5es5wark5kst5gcql9md02zepalg9yxxuz	\N
49	\\xe09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j	\N
50	\\xe07d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	stake_test1up73dx2qeg7gv59739gpmycmxzffyqk3ha2ctmh9ghdgneqmy000q	\N
51	\\xe072263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	stake_test1upezv0agh8cq09rt33ardnh8pdstd3lwpa5s64g2pne0uqgcygw6k	\N
52	\\xe08de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	stake_test1uzx79ge8d7gkx27vu3k9xgj9zlra0fvat5d5lxcnzm9n7hc8yk6td	\N
53	\\xe04f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	stake_test1up85ec98csnkgus5dw3x8u25mlkgu8m63hvw650ukldv04q6rf54k	\N
54	\\xe00ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	stake_test1uq8lxxfr92332xgqp66eenhpw7z04q09czgjf6uvnku20fq023mfy	\N
55	\\xe0ce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	stake_test1ur89gkdpkj42jwy3smuznfxcjdas0jz64xtckt9s8kz8h3gj4h8zv	\N
61	\\xe0b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	stake_test1uzm2e8gnhldqfkaslg0lscayuc0z7qtsz8fc3refn64gheq6g6kyz	\N
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
1	7	0	0	34
2	6	2	0	34
3	11	4	0	34
4	4	6	0	34
5	2	8	0	34
6	5	10	0	34
7	3	12	0	34
8	10	14	0	34
9	9	16	0	34
10	1	18	0	34
11	8	20	0	34
12	21	0	0	36
13	20	0	0	41
14	15	0	0	46
15	14	0	0	51
16	18	0	0	56
17	19	0	0	61
18	22	0	0	66
19	16	0	0	71
20	13	0	0	78
21	12	0	0	85
22	17	0	1	92
23	51	0	4	131
24	52	2	4	131
25	53	4	4	131
26	54	6	4	131
27	55	8	4	131
28	46	0	5	148
29	46	0	5	154
30	64	0	9	256
31	48	0	13	360
32	45	0	13	363
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
1	\\x5f62feab4d1888fbbb23740d4fa8a7c966187aaa5cb4780c0d4d80d13358a9df	1	0	910909092	0	0	0	\N	\N	t	0
2	\\xc76d0f0bd0fafa3de80dafdfd2a7bc538496c00d50749f1eb8194a234cc3c83f	1	0	910909092	0	0	0	\N	\N	t	0
3	\\xc958e10c8c248835554f9e52bb32339e88c5e07d04063da88ba46ae4535d457f	1	0	910909092	0	0	0	\N	\N	t	0
4	\\x6641b68439ada0b51a9198fce66d095c1ec776d3e85549826871e563a870b03e	1	0	910909092	0	0	0	\N	\N	t	0
5	\\x695109dec2e4656de8a56fd958f8b0e63053bf2418c3a5a37775ef93797f1438	1	0	910909092	0	0	0	\N	\N	t	0
6	\\x0fd70fbc6f56b6e57ceec65eafeee305bcb1c551c5aaf0d7043e7621ab584440	1	0	910909092	0	0	0	\N	\N	t	0
7	\\x6557e63b4082d11bba840aaad7aed51c3a935c24e3026563ed92faf4df7229dd	1	0	910909092	0	0	0	\N	\N	t	0
8	\\x42acd4312b560b12dbcea9bc5cc63e841ff6455d1674b9160b9e690b38a25374	1	0	910909092	0	0	0	\N	\N	t	0
9	\\xcac5c2d93d7956ec0a7fa91b84db169608d74e46a5a309e47484cd4bb2b1b7d6	1	0	910909092	0	0	0	\N	\N	t	0
10	\\x17df808d84caea7a5a92e50d15223bc757a27e9ced922221eae6a795266ce47b	1	0	910909092	0	0	0	\N	\N	t	0
11	\\x86fd75b7db01a2b601dac2611787a37ff7d6581e2884dc66de008616f5bcf963	1	0	910909092	0	0	0	\N	\N	t	0
12	\\x01e65772609a8e93e74b80dcf4987688ce4a15791ceb84360ecd885c213d2aa3	2	0	3681818181818181	0	0	0	\N	\N	t	0
13	\\x0a43243f3d2653186bdb5ec4d3030117b1b7d40267360d5e86532b8860697a80	2	0	3681818181818181	0	0	0	\N	\N	t	0
14	\\x100f4fae13933a083141413221118bfdc1dc1177d7b2c3339c41be4e92cbc0b0	2	0	3681818181818181	0	0	0	\N	\N	t	0
15	\\x15f9fe5c9223e837976ca79ccc2e3532bc3664709a7dfe4385f9419bc1d4d920	2	0	3681818181818181	0	0	0	\N	\N	t	0
16	\\x1ba064d24d471e687ebfb0a9621b2fbfd71b94dfdc5405f8c122b5e5044ff667	2	0	3681818181818190	0	0	0	\N	\N	t	0
17	\\x236b46d9bdabbd8ffe78985ab1974c4ca42f16290989b83a8b41a58ef52c0b79	2	0	3681818181818181	0	0	0	\N	\N	t	0
18	\\x24fe55a726bb49c08c02f5e27118483a0fa71b12d869a059f9730cbd7cd32863	2	0	3681818181818181	0	0	0	\N	\N	t	0
19	\\x278adb1e65e5cf5ee2d300ae49dad3fd7a7d27e3ad2de79f6ecb9e7c6a147210	2	0	3681818181818181	0	0	0	\N	\N	t	0
20	\\x3ef854e841358f872589b86a2abe5aeecdee5fed935ddbb920ae5f86e4c2700a	2	0	3681818181818181	0	0	0	\N	\N	t	0
21	\\x4c93eee403ced6a9847c7fb2bb4ce9b3e5bb6fda80aecf767f5a8fb9a3a076f5	2	0	3681818181818181	0	0	0	\N	\N	t	0
22	\\x543aa672b05beba3a56fd0a9e3492a30c77cd8025c68f329d34470fbf26825bb	2	0	3681818181818190	0	0	0	\N	\N	t	0
23	\\x59839492c05912e3f85a52a22c0bc86e0ea215ddfcea9a2b0b40857ecd89b02b	2	0	3681818181818181	0	0	0	\N	\N	t	0
24	\\x887cde6169e0960d396b1d97ac3405e8fc757dfbc1ac21f96b4dd63c177c4021	2	0	3681818181818181	0	0	0	\N	\N	t	0
25	\\x91c9a1dd4a41a7c352c37cf75114064f215b357f84b932552ce2fe4093675a57	2	0	3681818181818181	0	0	0	\N	\N	t	0
26	\\xa6bad0ee85687ae8a8bab08d04036d7d6450b3ec209b33875c9680cc403bccf5	2	0	3681818181818181	0	0	0	\N	\N	t	0
27	\\xd774f248ce1f056462ba3f2a07555af8ec84693f1931293f3470a7c8e4702f33	2	0	3681818181818181	0	0	0	\N	\N	t	0
28	\\xddca6675243e05e9d10565abf9c8b625413ad5f334d88c4b5e00f0b88df9bfc0	2	0	3681818181818181	0	0	0	\N	\N	t	0
29	\\xdfbf61b13462a3bb1e0923f32ee59d1b6fee3341c3dad878ae02f789e59450bf	2	0	3681818181818181	0	0	0	\N	\N	t	0
30	\\xe73b8ca38a8a7d79f827408ca05e8a37b646c8d3b34f255e7f6260b9f878a8e6	2	0	3681818181818181	0	0	0	\N	\N	t	0
31	\\xeae3759441c2b0bf050d4975ec020414712bb66aef0aa9fe159f505e38dd7724	2	0	3681818181818181	0	0	0	\N	\N	t	0
32	\\xec44dae8e02c2b8c5c75b60173bd2d938ffeeb1c36c9fb0ca9d05931f4821f38	2	0	3681818181818181	0	0	0	\N	\N	t	0
33	\\xed4ddebcc009f2df78e666016208b9f8c38c2f6c15b25a597d86bc5c931269a0	2	0	3681818181818181	0	0	0	\N	\N	t	0
34	\\x5368656c6c65792047656e65736973205374616b696e67205478204861736820	2	0	0	0	0	0	\N	\N	t	0
35	\\x027e23487a4e9a1e842d2cd16b4134bc183ec6fd83a928f04eebab5d8d6a16cd	3	0	3681818181651228	166953	0	263	\N	\N	t	0
36	\\x71fbba2905e3387e748c368de274a5e28db08dd6f19f52ae7ffe241c9a64985e	5	0	3681817681473231	177997	0	339	\N	5000000	t	0
37	\\x8f5e7f49e83a6aef7f5cd6c14249f98d81b9595152e2b66a8e20a11e57ee5897	8	0	3681817681293914	179317	0	369	\N	5000000	t	0
38	\\x2264c7dae79e7e9348529243100e8a72a969792437f119ac84b4dbfb057056fb	10	0	3681818181637632	180549	0	397	\N	5000000	t	0
39	\\x8f22be7a78050a41c8e44125e95e8c8f9f25f94437ea940199e901237a72c897	13	0	3681818181443619	194013	0	653	\N	500000	t	0
40	\\x6f49687e2b83d4aace4b2fedc912d137e83c432116963dca5228648f1c7a9e75	16	0	3681817681126961	166953	0	263	\N	\N	t	0
41	\\x171cfb757d7e1af888ec1dde21c8ca3b756b61e5ce1522af24f1408aec8d960b	19	0	3681817080948964	177997	0	339	\N	5000000	t	0
42	\\x07cdfe17250bca661dab3fad7d340bc132f9a32154629e45a18c1fc7dcd2d437	22	0	3681817080769647	179317	0	369	\N	5000000	t	0
43	\\x7160f30c9fa0a8b11de06a0994c33bc3534bb717c48ab779f815439dedb78158	23	0	3681818181637632	180549	0	397	\N	5000000	t	0
44	\\x1db671077cb822559ed989dd58096c7075800871e380da245e2cf59cb44e62c8	24	0	3681818181446391	191241	0	590	\N	500000	t	0
45	\\xaf6b2d045319bc3dc81451c44922fe9b0fa9343c6808e210472b677a9a61916b	26	0	3681817080602694	166953	0	263	\N	\N	t	0
46	\\xd4ec7d8be654bbb10bffee4df11e2d9dd5b605aa8c1cccd2315a00366618f9ca	27	0	3681816880424697	177997	0	339	\N	5000000	t	0
47	\\x8b67d7ac46b3345ab8ae573a5ea3dd762334a26a757607b0e2dbf303a9942c8a	29	0	3681816880245380	179317	0	369	\N	5000000	t	0
48	\\xfb8dc4b48167ef949a09b9157f743c9e0a9c06c04ee3023c4f82da19d6705ccd	30	0	3681818181637632	180549	0	397	\N	5000000	t	0
49	\\x949ab6c1c8ec6afacc39af8fc6cad078f23b70b83dd075a9f35b3c05bc9ce28e	31	0	3681818181443619	194013	0	653	\N	500000	t	0
50	\\x21c4dd43068baac981bc7437094188dd333d4bbd64189e0afa8d11559d353b1d	32	0	3681816880078427	166953	0	263	\N	\N	t	0
51	\\x7cd4e8e6f7794e0b115097a7d39a9713c368b51f27fa30b0ed50e09006d3d21a	34	0	3681816379900430	177997	0	339	\N	5000000	t	0
52	\\x0a69e874d0ca44181d405c8772021f4d7658846a70ae7d2ded45653fd6a7bb8a	36	0	3681816379721113	179317	0	369	\N	5000000	t	0
53	\\xd454df416a5ab51d142ebb946eb5b8c3b6caca0492fa895abfce6a73fe208202	38	0	3681818181637632	180549	0	397	\N	5000000	t	0
54	\\x69ebffcde8e9589b128dc3327b16ba2ec48b5c350dd42e7490e367c4b671e87e	39	0	3681818181443619	194013	0	653	\N	500000	t	0
55	\\x124757cd7728c955e0de851effdb45b308c46f3611b57d4dc5fcdd6e4957a4fb	41	0	3681816379554160	166953	0	263	\N	\N	t	0
56	\\x65dbb9bb40a1fea327c6d3317a2ca6bc0d86f591ebbd864d409f156f132618a7	42	0	3681815879376163	177997	0	339	\N	5000000	t	0
57	\\x2b2c8a6faed0f9f54a565b6ee18b0cd127a02b630d44b6f6a19476289f1212e5	43	0	3681815879196846	179317	0	369	\N	5000000	t	0
58	\\xdb94944221f086816bb5fde9d345617b078d6db7fe628fb3aaf3c7820960cc35	46	0	3681818181637632	180549	0	397	\N	5000000	t	0
59	\\x93a77a7c1b0a49c5f752f9bb7e88392718c15f5feda88a8353ce23262b97132c	47	0	3681818181443619	194013	0	653	\N	500000	t	0
60	\\xdcedd21ace033c48d5188f857c9fb8ec0443ce943faf061304621de5e4b861fb	50	0	3681815879029893	166953	0	263	\N	\N	t	0
61	\\x319c2dae0ad8be7be2ddd4e71d15f89441001738ff30858852afc0dd4bb701d1	52	0	3681815378851896	177997	0	339	\N	5000000	t	0
62	\\x2747f80dcdb8f7b39b24f8eb7b51807de9c9844e67dedd8aebb4c6c8961a7264	55	0	3681815378672579	179317	0	369	\N	5000000	t	0
63	\\x1375019de3ea1dd8adbc6eb982ccaba7c7a697a82f88e0112f6a45b114629395	56	0	3681818181637632	180549	0	397	\N	5000000	t	0
64	\\xdf01bc7215ca31b9ae6ebde5e7da7051ff49fefdea6e5451cf0916669283e051	58	0	3681818181443619	194013	0	653	\N	500000	t	0
65	\\x11a118bd04dbd412a6f21249bc8e8486d9b17ae2e2807ee37f7461c73308e995	59	0	3681815378505626	166953	0	263	\N	\N	t	0
66	\\x483baa18f11738d5cbcea74fb600bb028a47d45d85415c90d3d6c2a6a79c9d98	60	0	3681814878327629	177997	0	339	\N	5000000	t	0
67	\\x46ef77c4dabd21a3ae83e4cfad4192299e105a3008cc4687fc34e8800cd2bc89	62	0	3681814878148312	179317	0	369	\N	5000000	t	0
68	\\x069093895abf12eca5ee4181454090781fab60f2566fa71d73532478cf357e3f	64	0	3681818181637632	180549	0	397	\N	5000000	t	0
69	\\xd2daf9621af5862c7aadf25e5ccd0cd460a78d8dd962829ff625f526face8cbe	66	0	3681818181443619	194013	0	653	\N	500000	t	0
70	\\x14570e01edf34487c175867f2d1eb1e53116a15368eae9d69e432213730a298e	67	0	3681814877981359	166953	0	263	\N	\N	t	0
71	\\x16b1fb57972e5a039b64aebf89ed7387cd8ca1f21fe5aa64666b4a9d2e2c0cea	69	0	3681814577803362	177997	0	339	\N	5000000	t	0
72	\\xda1925cd4074f2d0e4ee1d2ba6ce0b198bd5b7e0d71239667285b6b05bdeb5ac	70	0	3681814577624045	179317	0	369	\N	5000000	t	0
73	\\xd22df3f7f5216c3136e629f9850ca3ccd198d145301d9bce4651391947f824c5	71	0	3681818181637632	180549	0	397	\N	5000000	t	0
74	\\x7b4e91a8a9ce8d11fc5c181bf3565687b48ad07e38eb49a75adaf539d210d5f6	73	0	3681818181446391	191241	0	590	\N	500000	t	0
75	\\x68dd292b655d35aacf7d392e9ce3297663124e7cd66f240b5dc8a68749cddd39	74	0	3681818181265842	180549	0	397	\N	5000000	t	0
76	\\x342c01a9b4e1b1cd376f598f5d7e5bfec9f3522b903f3fc4aa046a71665f306a	76	0	3681814577439800	184245	0	439	\N	500000	t	0
77	\\x91378ebb4adcbd6102a45983a0723c97a3de4b9695fb1b947a7a97f82d5e5b84	79	0	3681814577272847	166953	0	263	\N	\N	t	0
78	\\xe00afefa7df6054b19ff1e92da3cd73badbcd2cf6889871e8f614ff42031412a	81	0	3681814277094850	177997	0	339	\N	5000000	t	0
79	\\xa475f5b240ecc44aebbef944dda82efadba5ad70b697955f82bb8e03395155a6	84	0	3681814276915533	179317	0	369	\N	5000000	t	0
80	\\x6ca872d25a73dfd8647e7df17c7078c6dd8f1dd27968ea586a091b6005795736	85	0	3681818181637632	180549	0	397	\N	5000000	t	0
81	\\x3630cf833ef8e717ea93cd571dfcefaa21582eddf8e8bdbaff1e501f1ed4a74d	87	0	3681818181446391	191241	0	590	\N	500000	t	0
82	\\x4bd687b0e3f4530c784c8af9908739934b0cc7e7c98a78a4561de4e02886628c	89	0	3681818181265842	180549	0	397	\N	5000000	t	0
83	\\x3f432b1a8b5e1a6987e8334f7372df97d6c2cf943e7da2b51feb5937ec50891c	91	0	3681814276731288	184245	0	439	\N	500000	t	0
84	\\x70efe7584543f6232a4c2d816b5de41a21a1a4c5bf6c736eb6be55bff932617e	92	0	3681814276564335	166953	0	263	\N	\N	t	0
85	\\x699e2140830924b697dfb08b74b974785b955307b09deb1357cba29c168eca23	94	0	3681813776386338	177997	0	339	\N	5000000	t	0
86	\\xfe4111eb2e09889bb21610434817db68dd163c8acbe861bae15253a319064b79	97	0	3681813776207021	179317	0	369	\N	5000000	t	0
87	\\x26ee4a8b1b07459085dbfd34558a9ef71eefef16be3f1006dfe39f7645bb2907	98	0	3681818181637632	180549	0	397	\N	5000000	t	0
88	\\x2f4bf5f182964271f267d508e34da04b5dc52f92cc1974d3331394621a7a7de5	99	0	3681818181443575	194057	0	654	\N	500000	t	0
89	\\xd2e71548b65b8ccd3d3eb1407d9777dbe1cce2a70e78369bfac99a274cb870e5	100	0	3681818181263026	180549	0	397	\N	5000000	t	0
90	\\x7795d63f41b33dd4fd9d0c96543a863865b7d497c96f4fc20da688683e059f6d	101	0	3681813776022776	184245	0	439	\N	500000	t	0
91	\\x546ba92e368ff5dad384c271dd7d78e9f800191e4c8c3efe67ae57f4249ed9e8	103	0	3681813775855823	166953	0	263	\N	\N	t	0
92	\\x2fbbc2900140b31954060d524680e42ddc77190c54e8959820dc18a135de9db8	104	0	3681813275677826	177997	0	339	\N	5000000	t	0
93	\\xf85bee8da2711c189fb79ab02c6ac901f43429dbf7fd6c36a31c6cd7919f69ba	106	0	3681813275498509	179317	0	369	\N	5000000	t	0
94	\\xf3f49f9de366052054e8652b8b8dce5968a8c86c1a9d3f59ce4eb16ba169e067	107	0	3681818181637641	180549	0	397	\N	5000000	t	0
95	\\x8fc20a13fa3aa351f2aef496debeb696fdc5b4506c3521ed1b13ef53858f9e1c	109	0	3681818181443584	194057	0	654	\N	500000	t	0
96	\\x0fdbcbe70751238212bf476ead501a0651697f462b617bba9b65af8190cbd024	111	0	3681818181263035	180549	0	397	\N	5000000	t	0
97	\\x470b74a1d4ee704d6454b175849e39cd3e229731962f49988484e8f6be6bd51a	114	0	3681813275314264	184245	0	439	\N	500000	t	0
98	\\x0ddff90a4a02928be5ee5550a87f209ecdcffb677420a8b8c31c74e61cd2ff86	115	0	3681818181650832	167349	0	272	\N	\N	t	0
99	\\x69285c44a2a6b148f5c01a2803342dc917708997fad4b64bdb304785306a8bfe	117	0	99828910	171090	0	350	\N	\N	t	14
100	\\xd5bff5411dd7fea6824a5bc894c2d330401d074ad917fc7490caad85961a6b0a	120	0	3681818081484759	166073	0	243	\N	\N	t	0
101	\\x81bfac40c6a1e11783b5f9cfd06aec9198dbb8f0bd8fb8d26bbcf0c26e07b508	122	0	3681817981314374	170385	0	341	\N	\N	t	0
102	\\xc899828d4a629443405ce32edcbd6f5304c28fd37173f1597447df7271cc63bc	124	0	3681817881146585	167789	0	282	\N	\N	t	0
103	\\x9a2b6a7091a190335d39f0a92128031f29f889552c9a4612871534020fa8098a	128	0	3681817780979940	166645	0	256	\N	\N	t	0
104	\\xee87d7d239cf10d9d028b60bc6cc5454fbddadcbded6c6060635bfe4de4359c8	131	0	3681817680717067	262873	0	2443	\N	\N	t	0
105	\\xe6f6c28a78d5b3e63460798467257244315f83ac979d300c235cd8eae75dbf9e	132	0	3681817580550950	166117	0	244	\N	\N	t	0
106	\\x71ba340c029ee17b02813d17e450f9117800f9169776fecab0656d338cc69d72	135	0	3681817580223603	327347	0	2613	\N	\N	t	2197
107	\\xaa035d8a0a2d9232f0cc73ea86e7c6201b2364c99dbb1465bac6021c04ce90cb	137	0	3681818181642252	175929	0	467	\N	\N	t	0
108	\\x783f71c56a75b9747a00f76e36efce7a78b183bf0f354c7b6f12ca866de327fe	138	0	3681813275134639	179625	0	551	\N	\N	t	0
109	\\x8a3a573a39fda492b417eea491d5a752c8ffcb275edbdfcbae4f8d79b8c32537	139	0	4999999767575	232425	0	1751	\N	\N	t	0
110	\\x92f06c00278e46b72001aa5fbd64536421b419e62e9537b59cb55f742096cf40	140	0	4999989582758	184817	0	669	\N	\N	t	0
111	\\xea1ff43e8a3d9873fea428a9293873e14bd84066aa57ed0fe4ea92c37fa1a12b	425	0	4999979347913	234845	0	1700	\N	5549	t	0
112	\\x01bf5befd56668a456e0e4b3fe9f62e167c02ec7537490baa640cc77c01a25c7	429	0	4999979173480	174433	0	428	\N	5629	t	0
113	\\xb11cafb8ad33ec1a69a268b97cd0f2256530098a1aaca4b315ce73c19193b673	433	0	4999959002479	171001	0	350	\N	5662	t	0
114	\\x68d825627434ad45cd3a9e08b598f66b2eac9eee360463c7b885d0a6f9579d83	437	0	4999938828398	174081	0	319	\N	5709	t	0
115	\\x141c42d03fee05fd484d82268941259a6f62da56894aed5b7db0b16252601579	441	0	19826843	173157	0	399	\N	5727	t	0
116	\\x9f277cc931bd19e08801aab39ae41b1cfafe30cc84fbdda09867404e4386d5bd	445	0	4999938635573	192825	0	745	\N	5777	t	0
117	\\xc5ccac1a71954f2060aa1b183b50a28e5f5b9305684c1058e79052089e921044	449	0	4999938439316	196257	0	823	\N	5820	t	0
118	\\x685e08b766411627abbb2a0d8b4ebdcb0c860897d381e91a18611bb90f0ed3d7	453	0	4999938264399	174917	0	338	\N	5845	t	0
119	\\xc073de293d97c89f9aaaa1df54f98e8c0146ac18571138dc6d441e13e4de9b0c	457	0	4999938071574	192825	0	745	\N	5870	t	0
120	\\xf2798914b434c6ba109d6f2637b647b4c08a05f566a33cc1eaaec4d3ec2f0118	461	0	9826843	173157	0	298	\N	5882	t	0
121	\\x93abe83982c2e92750687a553d6aca973415b8e56e0a843afb8da0e7a501a5fa	465	0	4999927878749	192825	0	745	\N	5951	t	0
122	\\xe9d02272300d3b213421b7af5c3c53de41b29269ea561c088c180159547c46f2	469	0	9824995	175005	0	340	\N	5975	t	0
123	\\x41bc66da3c5b85fae1645fc276258036ac796ace2e5aecaf1187e0dbbc702fa2	473	0	9651838	173157	0	298	\N	6016	t	0
124	\\x09c42d026ea488e5d931b08bd2eab8bea4158a65e0e2f657bf9aa55156021cb1	478	0	4999917674748	204001	0	1100	\N	6048	t	0
125	\\x5bc02dcfc515b64540ce7be6ef43246153fee194c45c87ca2fd0f9ec46a39b41	482	0	19646778	180065	0	556	\N	6073	t	0
126	\\x27edcdbb48254914b12cefb8afa240022700765a051e6fc75539514ee307b61c	486	0	4999907487555	187193	0	718	\N	6097	t	0
127	\\xd3c11b1c1fae8eea54d085f63ac7401946d14290b1426af88fc722113d549584	491	0	19461565	190273	0	788	\N	6150	t	0
128	\\xe5c9580fb22b4de871a5bf9837079f37de3ba612adb78cbe997388f6543c8379	495	0	4999897303002	184553	0	658	\N	6171	t	0
129	\\x01728941b3301af255029afa87adfaf56763acc123a66b2b2a28c36ac9c224e0	499	0	38927706	180637	0	569	\N	6209	t	0
130	\\xe61b09bcd13500d6772b749c0e934d31e7640f1f4ccf284c56349c17a4d9c0b0	503	0	4999897133013	169989	0	327	\N	6271	t	0
131	\\x98c97c7673eaad43a44c1606cec0633f547c52b3705d419c215632f44facc4fa	507	0	999675351	324649	0	3846	\N	6304	t	0
132	\\xb0683c7fa12590351e531f19df9760f6ec05d42026be1a90a7a5d7a2a90ecf8f	511	0	999414590	260761	0	2394	\N	6342	t	0
133	\\xf6f9710053a9c281c5995cb93e9c39de6f207c799b1b06cb81d4bfcd2a0f6fe4	515	0	499375158	201757	0	1049	\N	6388	t	0
134	\\x017a9ddc6c03905d1be853d09e2cdc5c20d3d6e66dbd56e01c96c6873e660e56	519	0	4998896949164	183849	0	642	\N	6446	t	0
135	\\x9d15a06ef910fb124b62d00756ed92b76248a20473caed1a01e6ed580e0087f4	523	0	2820947	179053	0	533	\N	6486	t	0
137	\\x6a156ebc62b8cb7d0d7c93dc243c5c494215a12f5ef1ccbb7e2bde571be6d289	528	0	38750325	177381	0	495	\N	6517	t	0
138	\\x26d3ce7ec11774c51af0f125355ac882e40641bf02cc039680296b632d4fd856	532	0	2827019	172981	0	395	\N	6628	t	0
139	\\x5ee65af9dd5180d68e44163f1d6c00c7b701466114fe22d411994abd04aa2321	536	0	35582096	168229	0	287	\N	6651	t	0
140	\\x36a46151e4ffe4dea7b5304723162147552f617ee911673d57f015a3427c335e	538	0	4998935004485	174741	0	435	\N	6670	t	0
141	\\xb3d780f8491761306e6b24c5a8a30d24a78a18b3c13e694e1f7f5211eda18ad8	540	0	4998934486588	517897	0	8234	\N	6679	t	0
142	\\x2c5978699bdf8cd0eb0fed76910ea19320857cba72107f8cd549fbcd3e560386	543	0	179474447	525553	0	8408	\N	6702	t	0
145	\\x5a07c597a1dce5a3f00efb13c6b7e193700478dcfcf411a5ce241b1dbfc35434	546	0	4998932720283	266305	0	2516	\N	6715	t	0
146	\\xd4a4738b391d4c7df7b3627e191942fd9c3dc2449c9adba5af56d5072286a49d	546	1	4998932550118	170165	0	331	\N	6715	t	0
147	\\xb2b89776a8092f636f73e21966f0dabe29a8238c50f85eb3a27d39d93d2409bd	550	0	2999359621699	170253	0	333	\N	6789	t	0
148	\\xe666b3f78b3ce3311dcaa5f23d17e3f0c57c446c54d62c3975b9e911da00fc30	554	0	1999572575813	182353	0	608	\N	6820	t	0
149	\\x1664f46bc8a35ea195c62bf09dcf2c5bcdce98ad06f2be0e382859e97f2fbb55	555	0	1999572372406	173157	0	399	\N	6847	t	0
150	\\x94b84c00178ebf505fe9849f0e443a676ca0113064d976c8198e08a3ca48f314	556	0	1999572204001	168405	0	291	\N	6851	t	0
151	\\xa95e2fe4110f37df0138200d2bfd85c264d4303ca067f0d2ae1ef06e4f34417a	557	0	0	5000000	0	2364	\N	\N	f	1893
152	\\x92afd9e03d881574e7e237d22e546c0abf9dd8eca1a3241f28a5d89d3abedb5b	559	0	1999567035992	168009	0	282	\N	6891	t	0
153	\\x1bf630ea74b1f1909186c068fa3d814e186efd31b05af1888d991b89b4f2965a	562	0	2999358483544	168405	0	291	\N	6922	t	0
154	\\x9173e188fdcba842d6ecc6c343d2a1fbb6089a9230858b659f2e129b30b1ac88	567	0	1999563855619	180373	0	563	\N	6986	t	0
155	\\x6973583e518dcd0ff9ebf5c5f36ff7bfef7d54ed4563d9a605a1eacee24551ce	732	0	1999563687214	168405	0	291	\N	8474	t	0
156	\\x34897f01a406447bbb8f839d683050d640ee6d19f14f868bf159b7cc7c3ef844	732	1	1999563517225	169989	0	327	\N	8474	t	0
157	\\xedc43802491632b1371a14d89a0984bfe7bec1093eee4c01f569a28a8d4a01e8	732	2	9831771	168229	0	287	\N	8474	t	0
158	\\xb203c0322682286cf218edaff0ac04ca503bc072cbc5ff0a194d31601b4b0e83	733	0	9830187	169813	0	323	\N	8474	t	0
159	\\x1824746283319de6748ae18b36a62d7ce7c6b1aae4464e4f6224cd149103787f	733	1	1999558348820	168405	0	291	\N	8474	t	0
160	\\x8b48f561cbb2769688529709d976cced7b392de7a920d9e1d1a38b87f6e09a44	733	2	1999558009018	169989	0	327	\N	8474	t	0
161	\\x36311f198b793b168e3312c31ed4a6993c39d6867f8eacef98c9e9bbf1287986	733	3	9661958	169813	0	323	\N	8475	t	0
162	\\xfceeb30be2fc7e10bab1f8bcb1fa5ea10363a32d58abb8914cddeedb22c59e7d	733	4	1999552840613	168405	0	291	\N	8475	t	0
163	\\x1c21a892e0208abba768753c5981a3d8f3fb79c6f5a7db0de480717c6693f8e2	733	5	9830187	169813	0	323	\N	8475	t	0
164	\\x9b759acf449c1047e27a585a83698c6693d48f706b126669b91b815719d6fe60	733	6	9830187	169813	0	323	\N	8475	t	0
165	\\xae2f8eb41e2f367b11a70c47125f5fb8653f5cf6addc0485b8744f1542e6032a	733	7	9492145	169813	0	323	\N	8475	t	0
166	\\xf6b8611a1060c9cc93a2681ae94ccf5051e85516af4cce3f37342114ba82e598	733	8	9660374	169813	0	323	\N	8475	t	0
167	\\x435fcc9311f42e5d954a7f8039a49034a826ca2f5e25b9100cf0c18cdfb63fc0	733	9	9490561	169813	0	323	\N	8475	t	0
168	\\xfc0dc87732e4120bb1b868e3a3007fcb70e360a5b97f2c237d7211c03f37a4bc	733	10	2999348315139	168405	0	291	\N	8475	t	0
169	\\x1d2a024212c93e454d06e513987a35e8d8c3892297185c4dcb17eb2e2567c95f	733	11	8812893	169813	0	323	\N	8475	t	0
170	\\x1e4f86e087a54c03e4a748f04c1a5a52d1561f159681d33e4d8f066e2800d96b	733	12	1999552670624	169989	0	327	\N	8475	t	0
171	\\xa3f6e65ce87dcad58dda693945814fe60467ed5588612766d30dd977aa545957	733	13	1999547502219	168405	0	291	\N	8475	t	0
172	\\xb0678af0496fcb0afc2789bb4e6aa8d429aed0ad5f4dd4500aa58a224526dc76	733	14	2999343146734	168405	0	291	\N	8475	t	0
173	\\xce7b6b4ed5c15711179709b0de3139bf6182820edd2092c70a4acd554c57ac76	733	15	9830187	169813	0	323	\N	8475	t	0
174	\\xd0c9878a51a7227620ecd50e4057a3c34a4e72c2c2701642d87b8f7bdc256e7e	733	16	9830187	169813	0	323	\N	8475	t	0
175	\\x198c218c2be472d528e740ff48060cf83e060a806486d0809622ed2a9ef3dde2	733	17	8473267	169813	0	323	\N	8475	t	0
176	\\x815228bcc0d93da0c241d1c4235397098be5c70587d0f7fc336a13df53ea1bf6	733	18	1999542333814	168405	0	291	\N	8475	t	0
177	\\x200406a7f09e0e4d207ed446cbae960c94fbbc9bc054746e68e1073726e3de11	733	19	2999341450012	169989	0	327	\N	8475	t	0
178	\\x72aa5a542c5b1461647447f16e2ff5af9e535bfeade7ad47bcd2e885fe9346cb	733	20	9830187	169813	0	323	\N	8475	t	0
179	\\x1a545cde0f287e9eeff4eb6db368d0db9ab4eb266bba36efee560e51729620aa	733	21	9830187	169813	0	323	\N	8475	t	0
180	\\xf4691819517a0f5a13685f485ffb577ecf2713aeb92b9ab19568213c25c17926	733	22	9660374	169813	0	323	\N	8475	t	0
181	\\xa181f1b2c9046162a1b44bbc1b2c932e482bb4df4e6c26065accd61a14bb0fcf	733	23	9660374	169813	0	323	\N	8475	t	0
182	\\x3e6482f5a9e0b407aeed8d4a4c2f890d80b5f498e1bc11928d3684891f5931cb	733	24	9660374	169813	0	323	\N	8475	t	0
183	\\x43fc631c7642b2dcc93482e7aa25e1cf4870e5d2d8f06f2b068bfeef018f5ea2	733	25	2999336281607	168405	0	291	\N	8475	t	0
184	\\x14443bb0eeb0f24997e7253eb50c7b7b644cab257e4959b002a17050313ad3d6	733	26	9320748	169813	0	323	\N	8475	t	0
185	\\x16f7fa54ed03f3e88d494e8b5b0f4f9e3309e03e06551decf251d9a747ce1e9d	733	27	9490561	169813	0	323	\N	8475	t	0
186	\\xe46531d5c9a3774d52026928e6192703af9753aed5ee7cec213d81ad13c3cb78	733	28	9320748	169813	0	323	\N	8475	t	0
187	\\xb0dcaac2fb28609bf08718960175bdef491ead7932347d0168593f996147cba4	733	29	9830187	169813	0	323	\N	8475	t	0
188	\\x2fa108f2e01df8112b0ca924cee0ac3180fa360a29e1888c88cf62b92d28afa5	733	30	2999331113202	168405	0	291	\N	8475	t	0
189	\\xb227b95ba5e01c65f5d8f5dc964f7791e5b4c60a2a7907c5656b78067754fd22	733	31	9150935	169813	0	323	\N	8475	t	0
190	\\x3ee19e229c128f9c2e1572186d9a86157cb61515fd06a5ffff01c0391b74b01b	733	32	8981122	169813	0	323	\N	8475	t	0
191	\\x0778556db946290994cfc7353d5f92bd98ad98abcedd876fda1d33a3f1553900	733	33	9490561	169813	0	323	\N	8475	t	0
192	\\x86d32599055a7fd07aa0812ceb7cc0b686e9d07635d2f64f75a753308e35f80d	733	34	9660374	169813	0	323	\N	8475	t	0
193	\\x61dfbe937266c66d4c6c0b80cdf835ad689df43ace83ae151efa5f78ac7db1a5	733	35	8811309	169813	0	323	\N	8475	t	0
194	\\xab5b05f97b777ca2ae564c9f758f835411f24f36f7ae743f772ffa24e430c167	733	36	9490561	169813	0	323	\N	8475	t	0
195	\\x96bf83ecf0c9a462ce8c29aace6af620f8b2e93dd3b29498a8f209b69464c7ab	733	37	9320748	169813	0	323	\N	8475	t	0
196	\\xddcdc9f02e3e714a33eeaa81254cb8ac7be715dca55b83ccc1fa8192adae0f5f	733	38	1999537165409	168405	0	291	\N	8475	t	0
197	\\x09182f277958e376ae5e33e4217d01eb69f17e091b2244b02c7bc2f307cbacba	733	39	2999325944797	168405	0	291	\N	8475	t	0
198	\\xb07f6d3de40ce135d2a81c645c1d9bac41ae8fc77dafdde128c95f5cd66a89ec	733	40	9830187	169813	0	323	\N	8475	t	0
199	\\x4d86a95c8e185673d39545bba9795441341f7af46bca3b9905ba289b31921857	733	41	9830187	169813	0	323	\N	8475	t	0
200	\\x29a197fa8d2a66a0d986f9d8de9298b0b3cc06c04ec22d76b0028ed2da8088fd	733	42	9150935	169813	0	323	\N	8475	t	0
201	\\xdb400854e7c0dd03c8659e71de344b29a7d55d63fbe75b71f6a629a3dcdb1e14	733	43	8981122	169813	0	323	\N	8475	t	0
202	\\xf5c84cb30cbdfac746650df5232af8fef12e9c3156600477ce9074de60b96e0d	733	44	1999531997004	168405	0	291	\N	8475	t	0
203	\\x65c9c2b10f1d449a333efe2bafe914cf896758cf93e7790464cfdfbc38966e6e	733	45	9150935	169813	0	323	\N	8475	t	0
204	\\x7b875d2bb98d9a39e580274369d294b0925ace23f19db33b5d803b771f34deeb	733	46	9830187	169813	0	323	\N	8475	t	0
205	\\x3d5ed674892b56e5fda59f80060659edbe3eb98560751891c4b7c108065a68b7	733	47	1999526828599	168405	0	291	\N	8475	t	0
206	\\xdc4d32a22d3e4f95bf34a70dbe7d9ac9ea226a53ba826aa31b78081bdd299174	733	48	7962244	169813	0	323	\N	8475	t	0
207	\\x1badcafeb9111e0c13a6607a1d1561f95d0bd5b1de5c0783672aafabe543d45e	733	49	1999525809545	169989	0	327	\N	8475	t	0
208	\\xce08e6362a471df78a14b6259a29ef3c1908c266f94a88f5cce6e66f7c9ecf28	733	50	9830187	169813	0	323	\N	8475	t	0
209	\\x98c56e2b8e16426c8d54c67c1975381ee58c08bb666b81da5b29433d0045e312	733	51	9830187	169813	0	323	\N	8475	t	0
210	\\x4c1253c13a809be7d0632213551fac24158bea18abf5b670a1019efbabb4ccd0	733	52	2999320776392	168405	0	291	\N	8475	t	0
211	\\xf77f9f09f99522a93ac09e0df8b7a3f9e3bb3b001a4e07610b41fa0524db9620	733	53	9830187	169813	0	323	\N	8475	t	0
212	\\x0e2ba26799bc671eab2be3bf4ee0eea248a6bdc9932cd640f67dedcae366ce27	733	54	9830187	169813	0	323	\N	8475	t	0
213	\\x4a91882b3d66378a015dd776c7a7ad17963a023f5534db110e2afe5db736d0a4	733	55	9660374	169813	0	323	\N	8475	t	0
214	\\xf756f788b9e3a516cb7b4b5217fb8bf3d115dcd2919e5317bd24b5e0f4f8bd77	733	56	9660374	169813	0	323	\N	8475	t	0
215	\\xa8ca697c6fbb99e4f221ffcc663576e5007aeeeccf045c341899c6b4f4e182e1	733	57	9830187	169813	0	323	\N	8475	t	0
216	\\x5527493d70037769708e1373cb1fb924e5ef3a431f28c222774c39f3337c8007	733	58	9660374	169813	0	323	\N	8475	t	0
217	\\x6673c2e6acc852e9c4d66f3542faab8627876b0695e4207f564482d169d4e26a	733	59	9490561	169813	0	323	\N	8475	t	0
218	\\x14d181f273b7eb67a9762774b5101d8de581f4c96d7dafea00328e2fe5d815af	733	60	9320748	169813	0	323	\N	8475	t	0
219	\\x0b5768efc608aa7fe3aecc87c853b95c6ff5548289065d0338f73dbe25e8909c	733	61	9660374	169813	0	323	\N	8475	t	0
220	\\xa080d510ef7c150bf5ccb6f3fda7c8197c7b9e0b05582ce75904aa08018e389f	733	62	9830187	169813	0	323	\N	8475	t	0
221	\\xba0f4376e53f92ae7433ef7f05ff6e6680fb3ec305ac17c3b1ce9a6461fe3ba2	733	63	9830187	169813	0	323	\N	8475	t	0
222	\\x10f9bd2f19b4c060066c89060a08fe1c21dedb9ee08f88613bc77651f1eba3b0	733	64	9490561	169813	0	323	\N	8475	t	0
223	\\x30d4c352d9bf81515fa1d0b64eb776ea47fff2e33c836bad6814a92f765a28b0	733	65	9490561	169813	0	323	\N	8475	t	0
224	\\xb1a8fa8d841e131f7710a85703093f0b150de4e1c6dc784f252047ff563f0897	733	66	8981122	169813	0	323	\N	8475	t	0
225	\\xca060a31eab5ed54b4f359258b25f3ce3abec6e19f862c42d363e508222c6f2c	733	67	1999525299930	169989	0	327	\N	8475	t	0
226	\\x5c06c5f63c3ade0a6534c44719dd2f3be6c57ca9be298eeacb63cc9cb2abc9f9	733	68	8811309	169813	0	323	\N	8475	t	0
227	\\x4a8859bf82c297f8151784b4af988a5aa83de910e9d86435c4d823a203d5ac2e	733	69	6603740	169813	0	323	\N	8475	t	0
228	\\xb098d4f63fd964b5b84a7c3e25e088fa76eac7eb6a9537989f8e4936dd837091	733	70	6433927	169813	0	323	\N	8475	t	0
229	\\xb8fcb21e15c4d3dfc66da58ff4fb1ff7293ec7fe72b6b6817ec791d616f865e0	733	71	9320748	169813	0	323	\N	8475	t	0
230	\\xf9e4bca6b2c3672ab9e226c8cbced49214a0af25b1c871d968f6ab1d8e92a6ef	733	72	9830187	169813	0	323	\N	8475	t	0
231	\\x8f98f68fe8bd7fda8e5c5994740b8392f0205a3e031bd22293c4a879b1cf7dfc	733	73	9660374	169813	0	323	\N	8475	t	0
232	\\x17bc2a1990700b1f2e5e17574809276d171b00d0758418d4eb0b2b3da335363d	733	74	9830187	169813	0	323	\N	8475	t	0
233	\\x5a96a2734c95956445b95df4ffcf151b0c8e61a70954c6e48adca3bee095ff95	733	75	2999319927151	169989	0	327	\N	8475	t	0
234	\\x34c92b503543d98f537097691f956cb2db88a489d1157571606533530fff3957	733	76	9320748	169813	0	323	\N	8475	t	0
235	\\xe32ed286d754cc9c7ac1ba9721590eb46cbeb1dd2987435fbbb713753597a902	733	77	11262530	171397	0	359	\N	8475	t	0
236	\\x81a86bf014f2daee652f3384bde36a9f5c416aaceb99174b85bdba1985b487f5	733	78	9660374	169813	0	323	\N	8475	t	0
237	\\x8e8aa3422fe317ead0fa916d90ef3313a91e0e6435f477fc6db87a3f9e161b34	733	79	9830187	169813	0	323	\N	8475	t	0
238	\\xe7b874c052b30232b33b59c3b1cfedc8aff20c2e2b15c58d24db3fffdc1f63f7	733	80	9830187	169813	0	323	\N	8475	t	0
239	\\x2574d6347bed1d7102087cd99cfc8dcb989c6a7c93b5ca05907bd68cc1043846	733	81	9150935	169813	0	323	\N	8475	t	0
240	\\x2623f14fb9effadb71db82419b571e36daeb00197ac50d79eeab3114974a4144	733	82	8981122	169813	0	323	\N	8475	t	0
241	\\xec92eb32e8ec6a107b74de275798d69bae19b04f722b6454f711835b7944562d	733	83	9490561	169813	0	323	\N	8475	t	0
242	\\x0039cff0266ddefab12df6d661ff9d8ece1eb41cd6ebdb9c16c6559b82d63a49	733	84	9320748	169813	0	323	\N	8475	t	0
243	\\x4651272eeb119710eaf6962c959865b2c3eced2c0cd1065d8ed28628a14576fc	733	85	9660374	169813	0	323	\N	8475	t	0
244	\\x83684cf4e9009591d9301966e21e4a35a410f4179ea2c4dab74f8ff07875b181	733	86	7622618	169813	0	323	\N	8475	t	0
245	\\x26d45c441fa49e3b2d0e19d5b90f6bd16ce77b3a12549931150aa71a80af050e	733	87	9150935	169813	0	323	\N	8475	t	0
246	\\xf41b7ce6e14ab98f2e8336e4578ad6773332519d73b481cc4250d273f4ca2bdb	733	88	12281408	171397	0	359	\N	8475	t	0
247	\\x2b22f8d2a70e37be999fc59542c7ff2bfddd1bbde9e3f1df6191fc748f19b5f4	733	89	10753091	169813	0	323	\N	8475	t	0
248	\\x46c5988f3a3ba39e92119747f795338a57ec3272f6a62153c310bb042a340720	733	90	9660374	169813	0	323	\N	8475	t	0
249	\\x2eb7297acbf7c3d78cb8b5f683b365c9e9857b2ddedc70637be27b64e7dc107b	733	91	1999520131525	168405	0	291	\N	8475	t	0
250	\\xf4039b82321520754d955d74d73406f42bfaa6cfe7a824d36c8f39d556a40214	733	92	10583278	169813	0	323	\N	8475	t	0
251	\\x4fba07543eb20393acd41daf537bf23d63a491f4795dfcfb34f3eb25e5af39b9	733	93	2999314758746	168405	0	291	\N	8475	t	0
252	\\xc1107b9c4bbad6764069c29f6b421b662efe85e904663e865476b0574b184a37	733	94	9490561	169813	0	323	\N	8475	t	0
253	\\x43e7b2afdf38ef3394d2877b9c324432e6935ed1ee3049a775e55aaaff69a097	733	95	12111595	169813	0	323	\N	8475	t	0
254	\\xa2c92d02c2c9065b23f852ac5a6a76504544510d37fbcf5bf691b9de3be788b7	733	96	10413465	169813	0	323	\N	8475	t	0
255	\\xa1d3fe6590f2769b490c38f1ce0c4738c09795b44950dad6d232389649957e45	965	0	10595556195	174697	0	434	\N	10451	t	0
256	\\x027a0931c2ceeba9f7f8387618db29be6bba492df6048e8fdb32175f07e9fad5	969	0	5009495682513	251257	0	2178	\N	10479	t	0
257	\\x2f8ea412a49c39c56e5c7ce0977077e75d6c3e1e1631102651a5b2c8490b9cca	1166	0	1266952604614	174697	0	434	\N	12448	t	0
258	\\x4c2eb7b670f75474cf5790c189cf3e28904ea4d2174b54ed62b49302ff0dcf5d	1166	1	39136518577	168405	0	291	\N	12448	t	0
259	\\x790ec1278ea587acc0569f6b45ea2ae7d5dccf8568d278700c7e80ca6a43c080	1166	2	39136518578	168405	0	291	\N	12448	t	0
260	\\x349cdfc8dc8fb345c2bdd9888a868713264f6c4dae81f6a2456400af8ac07357	1166	3	39131350172	168405	0	291	\N	12448	t	0
261	\\xc3ffd0e8ba1c21f83ee901162a6be7e014a3a0795e1019754287479b1ca3e591	1166	4	1252373815038	168405	0	291	\N	12448	t	0
262	\\x9b9f2d0f5d5cc753ac33b5c6ac512baafee649613ff4a76591b93e2a534639b5	1166	5	78273205560	168405	0	291	\N	12448	t	0
263	\\x01dacd01a565c28df400c50bb70a6346d066220a788cbc3783182debb8018c06	1166	6	156546579525	168405	0	291	\N	12448	t	0
264	\\xd5fe018ced87c0003631e2fee9e91cdfba34c7bc382396d422eaba76f6e251a4	1166	7	9830187	169813	0	323	\N	12448	t	0
265	\\x2f106462594ce7fd91c934cceab253603fa77a1a173d4dc85f075f8e50d6f87f	1166	8	156541411120	168405	0	291	\N	12448	t	0
266	\\x4912113014ecb13698de209a985fbb93c158236a95f67e67a8c94b8dd8f270f1	1166	9	9830187	169813	0	323	\N	12448	t	0
267	\\x732ec8bd0151d66b64b602c7cd84687a71bdb3813e5c78d13c98aecd752e7d52	1166	10	626191651919	169989	0	327	\N	12448	t	0
268	\\x1f0953957091069238431b1ecba086f747e46ed72a7ccf0526196690d78a66e1	1166	11	313093327456	168405	0	291	\N	12448	t	0
269	\\xd8e0f6d25f425917f13cd79456d0d1a7b4469dac4dda50f9776b29eacb335a4d	1166	12	313098325872	169989	0	327	\N	12448	t	0
270	\\x24f815bcaa35c67783ca9e3d21917314716f316b6f1b1bf56f80636aaac737a2	1166	13	78278203976	169989	0	327	\N	12448	t	0
271	\\xc14fa9ab40fdf3aba26bc240437139d3ecdd8b1ef71d10b9d09ff7769eff0044	1166	14	39131350173	168405	0	291	\N	12448	t	0
272	\\x830e31366524aa9b121b6d8965285610b8354b0590809a9c7c6770a269fbcb2d	1166	15	313093157467	168405	0	291	\N	12448	t	0
273	\\xf76440f3251213f629705b411921951036abb0d5de86266a64f26430a6fe4d38	1166	16	626186483514	168405	0	291	\N	12448	t	0
274	\\x89ea59d1e9785feb83f7f03cff2ec075349be0cc4238ff32bfea936754ececa0	1166	17	156546579525	168405	0	291	\N	12448	t	0
275	\\xd54e117e072c2d22a85cbd575df3e442cf311c4eed90a6a7161c7e7f09697444	1166	18	39131010370	169989	0	327	\N	12448	t	0
276	\\x22f628c1f5de765b4e174f32847b33799a193091a0766e963a75d64cbf7013a0	1166	19	156536242715	168405	0	291	\N	12448	t	0
277	\\xe154d8375fdf38d5cdb17f96b94cb5e92c81ad8b2789db5218bf3b2b69f17424	1166	20	39136518578	168405	0	291	\N	12448	t	0
278	\\xa30690f09b30299659d514d40ddd86cef5623dc7bd5fbf5459232e8852c5cde8	1166	21	1252368646633	168405	0	291	\N	12448	t	0
279	\\x7fad28d17787c0c46827f44339ed9e4dd89d1da3177ff56b752ef5ca1f84d81c	1166	22	9830187	169813	0	323	\N	12448	t	0
280	\\x9b94281c74debf53b2b75c98b099732c6d88f3aa13ccb1ce9773b8d89362a7fe	1166	23	39136518577	168405	0	291	\N	12448	t	0
281	\\xd19d4edc79879c117b6afa7f9be3e2692ec4ff3291525ebc1189c7913b2b5041	1166	24	9830187	169813	0	323	\N	12448	t	0
282	\\x8fae1d4de6d94add15b2dbf6c19ed57c8d7ccdc5831e1ace6bedc2252dc5b6ab	1166	25	1252363478228	168405	0	291	\N	12448	t	0
283	\\xf68069fe92b214c057c8b88d280db1eb7fbe0729d2197905ecd49f205fb860c0	1166	26	156531074310	168405	0	291	\N	12448	t	0
284	\\xb61f54003a83b04041ad82ddb8f5f22f1992bc86dea84d7e8d6cc5d9d5759820	1166	27	39136348588	169989	0	327	\N	12448	t	0
285	\\xd7f2da5fba7c121d2a04c1e59a66538a520c7aa16bad328b7f97b477a52de15e	1167	0	156525905905	168405	0	291	\N	12448	t	0
286	\\x2d2f220e6c080fef63752245f0328cc6a0e83635c7fc57700af5df43d84e70e5	1167	1	313088159051	168405	0	291	\N	12448	t	0
287	\\xe4a9966d8efc1bd932b9816a74dc58d208712b4ac3918d308468b73b419c9250	1167	2	626181315109	168405	0	291	\N	12448	t	0
288	\\x0845bee0436b9bf327bde73a12af4f659f7380f4336bd5c307efd2d6d0c30080	1167	3	39131350173	168405	0	291	\N	12448	t	0
289	\\xc88bc16b25f43e82b732cda2e730cde96cc910e52bb9fb4d257e1bba75ea6a01	1167	4	1252358309823	168405	0	291	\N	12453	t	0
290	\\xc0504c453379a38e848bdc85a44c19652df1daede434826d4b4a28d160ce9200	1167	5	626191651919	169989	0	327	\N	12453	t	0
291	\\x322790de1697eeb0891f3a6a3d3c6f9949bc8772345ad5d44d77551f04d78ff7	1167	6	39126181768	168405	0	291	\N	12453	t	0
292	\\xae4c604c7473913069ab851de9d8749fdaf17c7a35ab3fe87cb1c7bc27e4db95	1167	7	39125841965	168405	0	291	\N	12453	t	0
293	\\x07a0a1b44fa54782da4e39574a1f25f01122c2cef16b896a71a338be804d7aa3	1167	8	78273035571	168405	0	291	\N	12453	t	0
294	\\xf91386a369a248e552d41ed35a7c091dfb96f0f33654dbca26ba82695dfacedf	1167	9	9830187	169813	0	323	\N	12453	t	0
295	\\x74ac9ea2e6af5dd53aa88437d535f134bc729373349f230dd3f158e9168fc45a	1168	0	9830187	169813	0	323	\N	12453	t	0
296	\\x8f24fe2acf19e0af29215699d352a590f40149eb96fec6e48dfd9887675e45f6	1168	1	9830187	169813	0	323	\N	12453	t	0
297	\\xefedf521fb7bb1cca3101e9d1fd7162b5bcdf93fa76c2076b6bdac0a16261bb5	1168	2	626186483514	168405	0	291	\N	12455	t	0
298	\\xdcb64b91c6893050d5faa0247c837e8edb3f30bec3518adcc1950bd2961fda1b	1168	3	626181145120	169989	0	327	\N	12455	t	0
299	\\x60a8587c85ee5d8660e2ae192f9b9d55bf2a47db35769d3901b3e8e2a47fdfbe	1168	4	9830187	169813	0	323	\N	12455	t	0
300	\\xc0eb0302bb43d5bb84de619b4aa98d7bbeecc4484565bb8365d8dfbf36dfb91d	1168	5	9660374	169813	0	323	\N	12455	t	0
301	\\x93343bf8f5f6140ed55e923c1e758442bbd7be8e19a9f5e763a64cb33a516e44	1168	6	9490561	169813	0	323	\N	12455	t	0
302	\\x0a3669968f9d255bf4b65fdc15ab1e2922f5297d32cbbda58d47622258567bbe	1168	7	9660374	169813	0	323	\N	12455	t	0
303	\\xd0a8b31e18b7f806dc9ac41689556a919cb13cc71979b2630e3aced4d9b5cf2e	1168	8	9830187	169813	0	323	\N	12455	t	0
304	\\x31362d374d2d2bcac7e06393aba32585ace2c40f301753bb3f9e709b7362c95d	1168	9	39131180183	168405	0	291	\N	12455	t	0
305	\\x8be5e2ae722a5ca43cb1be170bba90aa8b3a9367ff1d82e2a92efc943fb4ac79	1168	10	156520737500	168405	0	291	\N	12455	t	0
306	\\x2fef2372480915cfe93b8ef642cd1cb019010358ce964e21597c33ad21ebd17f	1168	11	39120673560	168405	0	291	\N	12455	t	0
307	\\x79e01aef21537a7a0cceddea96834b4e95fe19807d9b4d190eba4432c68408b9	1168	12	9830187	169813	0	323	\N	12455	t	0
308	\\x9c336ccbdb4e8bfa286d3ce839af312bbe52fb581e6a62ca6733415f46de5a19	1168	13	9660374	169813	0	323	\N	12455	t	0
309	\\x1e68b57f034b7f79a025bd208a92363c3281173d391b65d0aa14647251ab5804	1168	14	9830187	169813	0	323	\N	12455	t	0
310	\\xb1ed9d7555b433b6c3c6ee484b3235aeb2d4976f3416980ea7e4abd1f229c3f1	1168	15	156541411120	168405	0	291	\N	12455	t	0
311	\\x6643eff9a8dd969955276dc5f3e119923c2f3194b1a1a81a03f6fad80cb0fd15	1168	16	9830187	169813	0	323	\N	12455	t	0
312	\\x4cc10a12e02f184a7d4a3453e70f89465568fe9a50ef9301e3c72343d90f9a3a	1168	17	313082990646	168405	0	291	\N	12455	t	0
313	\\xbe963c7ff6e6ffa195071ccb1dcbd8d7acb685d42fb265b069ea5eb889ed2a73	1168	18	39115505155	168405	0	291	\N	12455	t	0
314	\\xd8826770f7006b7d802e4b0d9afa25172d8107c4a6b41e01dd674577ab884fab	1168	19	9660374	169813	0	323	\N	12455	t	0
315	\\x91b47c97f40bf9446c66f92efa61cb0d8220c720bce4179eda2f54c1ab682473	1168	20	9830187	169813	0	323	\N	12455	t	0
316	\\x6b1cba99e9ae61ada69b6b62c175c5be033121d9cd8dd6c4c6300db0e4b1b159	1168	21	9320748	169813	0	323	\N	12455	t	0
317	\\xc19e9de817959a38a360c8c46d871e3e36b731ceb3ed3a69484167b5916e48af	1168	22	626175976715	168405	0	291	\N	12455	t	0
318	\\x5c43ddf8e4b67b51961d1abea252a60ba231cdf1df4d6663be9d501d104fb5ba	1168	23	39110336750	168405	0	291	\N	12455	t	0
319	\\x2d614c89246053230e2b6cc9b4d23660d95f77563491d83e421fb06859bb5bc9	1168	24	39126011778	168405	0	291	\N	12455	t	0
320	\\x20a5c52c7f039740b43b38db317c8595b475f1c9c7f1860b62d33610a1c687e2	1168	25	313077822241	168405	0	291	\N	12455	t	0
321	\\x2eec5206e74ea9564ad4149eaa0a90627efdef5e7ba322edcea18d8ab2289100	1168	26	9830187	169813	0	323	\N	12455	t	0
322	\\xff41ddbe8c94099da6b6a95d00bb8788904565c279b77010f36237dae6bdc2b2	1168	27	626175127474	169989	0	327	\N	12455	t	0
323	\\x3482f933fcbe5f46b13599de4049b077fef64f17048e72db21cb272d6e71ad81	1168	28	39126011779	169989	0	327	\N	12455	t	0
324	\\x61cc800928ac2ff53149dfb64f3ac9959c7c0878e8c032a0f5ea444486f5712d	1168	29	9490561	169813	0	323	\N	12455	t	0
325	\\x05fa2452db418ad1dfe7eb9b5fcf319023baaa7149bf006f68de35782ba635b3	1168	30	9660374	169813	0	323	\N	12455	t	0
326	\\x00fc22307359224ef7ebb420f90d61b6cd8144c1fb83e332d70326c1dbe02a5b	1168	31	9830187	169813	0	323	\N	12455	t	0
327	\\x6a474969e6ebad5ee8b9f788615976620bba45f2fc64f4abb9fd0b94d89d7dc9	1168	32	9830187	169813	0	323	\N	12455	t	0
328	\\xda2ef2bd66c509450dca5ab6da70163138a1979b317d9dc2f8ca23a3cc34fcef	1168	33	626169959069	168405	0	291	\N	12455	t	0
329	\\xb34e2a8dba3af88f9989bcc42531583c9af1d60c2bcb2d212bb0addca9d102d0	1168	34	9830187	169813	0	323	\N	12455	t	0
330	\\xdfbaefd94381c69578698c722eabd95f3e90159425a7abe4d935ab7d6a10c42f	1168	35	626181315109	168405	0	291	\N	12455	t	0
331	\\x052ecb0a2e7723585e5e5772ef9877cfedab751f42db50ec37a474e215b57eba	1168	36	9660374	169813	0	323	\N	12455	t	0
332	\\x53f5b8bdb9efe9e64e92ad62239338a9ee2fa550654eac65a7f520bbf0dc1664	1168	37	156515569095	168405	0	291	\N	12455	t	0
333	\\xc79ed8d74e302cc6d551a3f25cca45899680377ee013772ab609b2bb4e7de35a	1168	38	39120843374	168405	0	291	\N	12455	t	0
334	\\x1f5419fe46a3512fc8658c1d14088be95d1e0cc559a41a1acac26e8a5d3abef9	1168	39	9830187	169813	0	323	\N	12455	t	0
335	\\xb76505d2d8f4e3e5ebed1735b0d24194f9fb237ace08b455bf8b993687775cc3	1168	40	9490561	169813	0	323	\N	12455	t	0
336	\\xd0e345b86850659f3caf4849210548f5b516fe80ffb95ef2c335ee8d9f8c15bf	1168	41	9660374	169813	0	323	\N	12455	t	0
337	\\x3b97bfb3dcc31069eb161136c9af1ae2d0056fd812190656b28ac81b5bf70d01	1168	42	9660374	169813	0	323	\N	12455	t	0
338	\\x2f733e924bcb7711a43a45adbf097919757962c415441a300b9b6e21316632d9	1168	43	9830187	169813	0	323	\N	12455	t	0
339	\\x91c0a67395c535fdb8a4fccd5eacbeea9d2ca61f89b7497538165c420bb0393b	1168	44	156536242715	168405	0	291	\N	12455	t	0
340	\\xd9147ef51135c062e62de9ec616c9787fae79a2948e277fbd8a012100f88c9b4	1168	45	39115674969	168405	0	291	\N	12455	t	0
341	\\xdd476bba8bde4b4e8ba726535e1c9f130753269af9b80a44b17801abee8da848	1168	46	9660374	169813	0	323	\N	12455	t	0
342	\\x923840e63fdfc22d7b6916f78381cd38616a84dc5ab6ecadc8842e5870cab293	1168	47	39130670745	169989	0	327	\N	12455	t	0
343	\\x2a4e674690f45c9449655a4709c26e53d230585af7ee32bf13f1c82a707b9fa8	1168	48	78268037155	168405	0	291	\N	12455	t	0
344	\\xadaa09d76c005d5e4bcbf2dcfacfe179cef3ff3beaa33fc97336d8eb21c5b174	1168	49	9830187	169813	0	323	\N	12455	t	0
345	\\xc5176ee7c0632ad06f87919b4b8aaf4f81c4fb8037e90218b6f3f59461f2af42	1168	50	9830187	169813	0	323	\N	12455	t	0
346	\\xe611c4788ba53a461e6fa03b616cacc1338516130af05626faf0f5abf6921c24	1168	51	39109827135	169989	0	327	\N	12455	t	0
347	\\xc86488a345afd1110599fd73cd8e4bc5574d7722a9c3d981a7b40b952a9d8d4e	1168	52	9830187	169813	0	323	\N	12455	t	0
348	\\x2807b557a159cdce9175c3101f91a3226af248880b89a7ad39a2d7ce511019a5	1168	53	9150935	169813	0	323	\N	12455	t	0
349	\\xcba16b132130d5bd4bd1991a8bc49b39053016eab1e0578daf17a111595e8669	1168	54	39120843373	168405	0	291	\N	12455	t	0
350	\\x7e00e50736d3b01d6ffcfa2fe4d2d4e9b546448e89cab1984c181d5e0192bbb6	1168	55	39115674968	168405	0	291	\N	12455	t	0
351	\\x3cc432ede23a8e0c705d6461121f5defa4ad552038795cd0898b95479ed049d1	1168	56	9830187	169813	0	323	\N	12455	t	0
352	\\xe9ce1669787ab163dd55ede28a6f4fa81f8a0bfec8e38838cb5eccea985b402c	1168	57	9830187	169813	0	323	\N	12455	t	0
353	\\x290c03a435873ff3eb0302daa9bb1969d4ed86520826b33cb306f84b691f2020	1168	58	78267697353	169989	0	327	\N	12455	t	0
354	\\x151f10a03ac7d524eaa80e089af0d8cad277baa24f79ef9f0307436a194e0605	1168	59	626164790664	168405	0	291	\N	12455	t	0
355	\\x76dde6c6df743bcf3c19026a5ac83c2bc1a01f1eb8ec4adfd815512f3a6a2f49	1169	0	9830187	169813	0	323	\N	12455	t	0
356	\\x558f0b31c86ad04bd19ca01de81bb3ab7514a86b8fd81ec18ce1b6684bd83031	1169	1	9660374	169813	0	323	\N	12455	t	0
357	\\xb65d4669e0fc3b6eedac42a776fad88e80184b02f775625d12f2110935eb8662	1382	0	1282239485771	180725	0	571	\N	14459	t	0
358	\\x5c948fc8fd05589cc1bf7cc19c2fd894e6304979c2bb38644076bc55627f19dc	1391	0	19590766	239421	0	1804	\N	14488	t	0
359	\\x46f5da26861bc0b65e23dc703d1d9b065d077c18b115f2bbf3d51c84c81b2af9	1400	0	4999999820111	179889	0	552	\N	14559	t	0
360	\\xd716ad130e64ce0cf091cd8799c15e7a4ef78f772a981709ed4d3fdc2da7cd41	1404	0	4999996650122	169989	0	327	\N	14576	t	0
361	\\xac8a5ca392d906f7856f0250afdf0af368b4df38a8ecb407ae0bb91a0423a3db	1409	0	4999993474369	175753	0	458	\N	14631	t	0
362	\\xb5bedd3b5fcac329048834f76b9bccea1b36447b44226baf37c9139df5b7f84d	1413	0	9816723	183277	0	629	\N	14661	t	0
363	\\x8afcbbef0b91bb95a4354a91620c137394fc0f6d53751916c0b20efae32c6ca8	1419	0	5000002828427	171573	0	363	\N	14704	t	0
364	\\x02add8fb6a502ca7ecb2330a03de22dcfeed47fe044e940f4b0651b590b11f3d	1423	0	9821255	178745	0	526	\N	14774	t	0
\.


--
-- Data for Name: tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_in (id, tx_in_id, tx_out_id, tx_out_index, redeemer_id) FROM stdin;
1	35	19	0	\N
2	36	35	1	\N
3	37	36	0	\N
4	38	14	0	\N
5	39	38	0	\N
6	40	37	0	\N
7	41	40	1	\N
8	42	41	0	\N
9	43	26	0	\N
10	44	43	0	\N
11	45	42	0	\N
12	46	45	1	\N
13	47	46	0	\N
14	48	24	0	\N
15	49	48	0	\N
16	50	47	0	\N
17	51	50	1	\N
18	52	51	0	\N
19	53	29	0	\N
20	54	53	0	\N
21	55	52	0	\N
22	56	55	1	\N
23	57	56	0	\N
24	58	20	0	\N
25	59	58	0	\N
26	60	57	0	\N
27	61	60	1	\N
28	62	61	0	\N
29	63	30	0	\N
30	64	63	0	\N
31	65	62	0	\N
32	66	65	1	\N
33	67	66	0	\N
34	68	12	0	\N
35	69	68	0	\N
36	70	67	0	\N
37	71	70	1	\N
38	72	71	0	\N
39	73	13	0	\N
40	74	73	0	\N
41	75	74	0	\N
42	76	72	0	\N
43	77	76	0	\N
44	78	77	1	\N
45	79	78	0	\N
46	80	21	0	\N
47	81	80	0	\N
48	82	81	0	\N
49	83	79	0	\N
50	84	83	0	\N
51	85	84	1	\N
52	86	85	0	\N
53	87	31	0	\N
54	88	87	0	\N
55	89	88	0	\N
56	90	86	0	\N
57	91	90	0	\N
58	92	91	1	\N
59	93	92	0	\N
60	94	22	0	\N
61	95	94	0	\N
62	96	95	0	\N
63	97	93	0	\N
64	98	17	0	\N
65	99	98	0	1
66	100	98	1	\N
67	101	100	1	\N
68	102	101	1	\N
69	103	102	1	\N
70	104	103	1	\N
71	105	104	1	\N
72	106	105	0	2
73	106	105	1	\N
74	107	18	0	\N
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
91	121	119	1	\N
92	122	121	0	\N
93	123	122	0	\N
94	124	121	1	\N
95	125	124	0	\N
96	125	120	0	\N
97	126	124	1	\N
98	127	126	0	\N
99	127	123	0	\N
100	128	126	1	\N
101	129	125	1	\N
102	129	127	0	\N
103	129	127	1	\N
104	129	128	0	\N
105	130	125	0	\N
106	130	128	1	\N
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
147	137	129	0	\N
148	138	137	0	\N
149	139	137	1	\N
150	140	134	1	\N
151	140	138	0	\N
152	140	139	0	\N
153	140	139	1	\N
154	140	135	0	\N
155	141	140	0	\N
156	141	140	1	\N
157	142	141	0	\N
158	142	141	1	\N
159	142	141	2	\N
160	142	141	3	\N
161	142	141	4	\N
162	142	141	5	\N
163	142	141	6	\N
164	142	141	7	\N
165	142	141	8	\N
166	142	141	9	\N
167	142	141	10	\N
168	142	141	11	\N
169	142	141	12	\N
170	142	141	13	\N
171	142	141	14	\N
172	142	141	15	\N
173	142	141	16	\N
174	142	141	17	\N
175	142	141	18	\N
176	142	141	19	\N
177	142	141	20	\N
178	142	141	21	\N
179	142	141	22	\N
180	142	141	23	\N
181	142	141	24	\N
182	142	141	25	\N
183	142	141	26	\N
184	142	141	27	\N
185	142	141	28	\N
186	142	141	29	\N
187	142	141	30	\N
188	142	141	31	\N
189	142	141	32	\N
190	142	141	33	\N
191	142	141	34	\N
192	142	141	35	\N
193	142	141	36	\N
194	142	141	37	\N
195	142	141	38	\N
196	142	141	39	\N
197	142	141	40	\N
198	142	141	41	\N
199	142	141	42	\N
200	142	141	43	\N
201	142	141	44	\N
202	142	141	45	\N
203	142	141	46	\N
204	142	141	47	\N
205	142	141	48	\N
206	142	141	49	\N
207	142	141	50	\N
208	142	141	51	\N
209	142	141	52	\N
210	142	141	53	\N
211	142	141	54	\N
212	142	141	55	\N
213	142	141	56	\N
214	142	141	57	\N
215	142	141	58	\N
216	142	141	59	\N
280	145	142	0	\N
281	145	141	60	\N
282	145	141	61	\N
283	145	141	62	\N
284	145	141	63	\N
285	145	141	64	\N
286	145	141	65	\N
287	145	141	66	\N
288	145	141	67	\N
289	145	141	68	\N
290	145	141	69	\N
291	145	141	70	\N
292	145	141	71	\N
293	145	141	72	\N
294	145	141	73	\N
295	145	141	74	\N
296	145	141	75	\N
297	145	141	76	\N
298	145	141	77	\N
299	145	141	78	\N
300	145	141	79	\N
301	145	141	80	\N
302	145	141	81	\N
303	145	141	82	\N
304	145	141	83	\N
305	145	141	84	\N
306	145	141	85	\N
307	145	141	86	\N
308	145	141	87	\N
309	145	141	88	\N
310	145	141	89	\N
311	145	141	90	\N
312	145	141	91	\N
313	145	141	92	\N
314	145	141	93	\N
315	145	141	94	\N
316	145	141	95	\N
317	145	141	96	\N
318	145	141	97	\N
319	145	141	98	\N
320	145	141	99	\N
321	145	141	100	\N
322	145	141	101	\N
323	145	141	102	\N
324	145	141	103	\N
325	145	141	104	\N
326	145	141	105	\N
327	145	141	106	\N
328	145	141	107	\N
329	145	141	108	\N
330	145	141	109	\N
331	145	141	110	\N
332	145	141	111	\N
333	145	141	112	\N
334	145	141	113	\N
335	145	141	114	\N
336	145	141	115	\N
337	145	141	116	\N
338	145	141	117	\N
339	145	141	118	\N
340	145	141	119	\N
341	146	145	0	\N
342	146	145	1	\N
343	147	146	0	\N
344	148	146	1	\N
345	149	147	0	\N
346	149	148	1	\N
347	150	149	0	\N
348	151	150	0	\N
349	152	150	1	\N
350	153	147	1	\N
351	154	152	1	\N
352	155	154	0	\N
353	156	155	0	\N
354	156	155	1	\N
355	157	153	0	\N
356	158	156	0	\N
357	158	157	0	\N
358	159	156	1	\N
359	160	159	1	\N
360	160	158	1	\N
361	161	159	0	\N
362	161	157	1	\N
363	162	160	1	\N
364	163	160	0	\N
365	163	158	0	\N
366	164	161	0	\N
367	164	162	0	\N
368	165	163	0	\N
369	165	161	1	\N
370	166	164	1	\N
371	166	165	0	\N
372	167	164	0	\N
373	167	166	1	\N
374	168	153	1	\N
375	169	167	1	\N
376	169	165	1	\N
377	170	167	0	\N
378	170	162	1	\N
379	171	170	1	\N
380	172	168	1	\N
381	173	169	0	\N
382	173	168	0	\N
383	174	170	0	\N
384	174	166	0	\N
385	175	169	1	\N
386	175	173	1	\N
387	176	171	1	\N
388	177	175	1	\N
389	177	172	1	\N
390	178	175	0	\N
391	178	174	0	\N
392	179	176	0	\N
393	179	173	0	\N
394	180	163	1	\N
395	180	177	0	\N
396	181	174	1	\N
397	181	180	0	\N
398	182	179	1	\N
399	182	181	0	\N
400	183	177	1	\N
401	184	182	1	\N
402	184	178	1	\N
403	185	178	0	\N
404	185	181	1	\N
405	186	184	0	\N
406	186	185	1	\N
407	187	185	0	\N
408	187	172	0	\N
409	188	183	1	\N
410	189	184	1	\N
411	189	188	0	\N
412	190	187	0	\N
413	190	189	1	\N
414	191	189	0	\N
415	191	180	1	\N
416	192	171	0	\N
417	192	187	1	\N
418	193	182	0	\N
419	193	190	1	\N
420	194	190	0	\N
421	194	192	1	\N
422	195	191	1	\N
423	195	186	0	\N
424	196	176	1	\N
425	197	188	1	\N
426	198	179	0	\N
427	198	192	0	\N
428	199	191	0	\N
429	199	197	0	\N
430	200	199	0	\N
431	200	195	1	\N
432	201	199	1	\N
433	201	186	1	\N
434	202	196	1	\N
435	203	194	1	\N
436	203	198	1	\N
437	204	193	0	\N
438	204	201	0	\N
439	205	202	1	\N
440	206	203	1	\N
441	206	201	1	\N
442	207	200	1	\N
443	207	205	1	\N
444	208	183	0	\N
445	208	202	0	\N
446	209	198	0	\N
447	209	206	0	\N
448	210	197	1	\N
449	211	205	0	\N
450	211	194	0	\N
451	212	195	0	\N
452	212	196	0	\N
453	213	203	0	\N
454	213	208	1	\N
455	214	208	0	\N
456	214	211	1	\N
457	215	213	0	\N
458	215	204	0	\N
459	216	204	1	\N
460	216	214	0	\N
461	217	216	1	\N
462	217	211	0	\N
463	218	217	0	\N
464	218	217	1	\N
465	219	200	0	\N
466	219	215	1	\N
467	220	210	0	\N
468	220	216	0	\N
469	221	219	0	\N
470	221	207	0	\N
471	222	212	1	\N
472	222	209	1	\N
473	223	219	1	\N
474	223	222	0	\N
475	224	218	1	\N
476	224	220	1	\N
477	225	207	1	\N
478	225	213	1	\N
479	226	218	0	\N
480	226	224	1	\N
481	227	226	1	\N
482	227	206	1	\N
483	228	223	0	\N
484	228	227	1	\N
485	229	223	1	\N
486	229	228	0	\N
487	230	212	0	\N
488	230	209	0	\N
489	231	226	0	\N
490	231	230	1	\N
491	232	220	0	\N
492	232	225	0	\N
493	233	210	1	\N
494	233	229	1	\N
495	234	222	1	\N
496	234	215	0	\N
497	235	234	0	\N
498	235	233	0	\N
499	235	228	1	\N
500	236	232	0	\N
501	236	232	1	\N
502	237	227	0	\N
503	237	231	0	\N
504	238	236	0	\N
505	238	237	0	\N
506	239	234	1	\N
507	239	230	0	\N
508	240	239	1	\N
509	240	224	0	\N
510	241	240	0	\N
511	241	214	1	\N
512	242	238	0	\N
513	242	241	1	\N
514	243	238	1	\N
515	243	241	0	\N
516	244	240	1	\N
517	244	193	1	\N
518	245	242	1	\N
519	245	243	0	\N
520	246	239	0	\N
521	246	244	1	\N
522	246	221	1	\N
523	247	243	1	\N
524	247	235	1	\N
525	248	244	0	\N
526	248	237	1	\N
527	249	225	1	\N
528	250	247	1	\N
529	250	249	0	\N
530	251	233	1	\N
531	252	248	0	\N
532	252	231	1	\N
533	253	245	0	\N
534	253	246	1	\N
535	254	251	0	\N
536	254	250	1	\N
537	255	221	0	\N
538	256	242	0	\N
539	256	245	1	\N
540	256	247	0	\N
541	256	249	1	\N
542	256	253	0	\N
543	256	253	1	\N
544	256	248	1	\N
545	256	251	1	\N
546	256	236	1	\N
547	256	255	0	\N
548	256	255	1	\N
549	256	254	0	\N
550	256	254	1	\N
551	256	229	0	\N
552	256	252	0	\N
553	256	252	1	\N
554	256	235	0	\N
555	256	250	0	\N
556	256	246	0	\N
557	257	256	0	\N
558	258	256	13	\N
559	259	256	11	\N
560	260	258	1	\N
561	261	256	1	\N
562	262	256	9	\N
563	263	256	6	\N
564	264	258	0	\N
565	264	262	0	\N
566	265	263	1	\N
567	266	257	0	\N
568	266	260	0	\N
569	267	256	3	\N
570	267	266	1	\N
571	268	256	5	\N
572	269	263	0	\N
573	269	256	4	\N
574	270	256	8	\N
575	270	266	0	\N
576	271	259	1	\N
577	272	269	1	\N
578	273	267	1	\N
579	274	256	7	\N
580	275	260	1	\N
581	275	264	1	\N
582	276	265	1	\N
583	277	256	10	\N
584	278	261	1	\N
585	279	259	0	\N
586	279	264	0	\N
587	280	256	12	\N
588	281	276	0	\N
589	281	269	0	\N
590	282	278	1	\N
591	283	276	1	\N
592	284	282	0	\N
593	284	280	1	\N
594	285	283	1	\N
595	286	268	1	\N
596	287	273	1	\N
597	288	277	1	\N
598	289	282	1	\N
599	290	256	2	\N
600	290	279	1	\N
601	291	288	1	\N
602	292	275	1	\N
603	293	270	1	\N
604	294	284	0	\N
605	294	281	0	\N
606	295	272	0	\N
607	295	274	0	\N
608	296	267	0	\N
609	296	273	0	\N
610	297	290	1	\N
611	298	287	0	\N
612	298	287	1	\N
613	299	286	0	\N
614	299	298	0	\N
615	300	279	0	\N
616	300	281	1	\N
617	301	292	0	\N
618	301	300	1	\N
619	302	295	1	\N
620	302	275	0	\N
621	303	302	0	\N
622	303	290	0	\N
623	304	284	1	\N
624	305	285	1	\N
625	306	292	1	\N
626	307	261	0	\N
627	307	297	0	\N
628	308	293	0	\N
629	308	299	1	\N
630	309	291	0	\N
631	309	296	0	\N
632	310	274	1	\N
633	311	271	0	\N
634	311	277	0	\N
635	312	286	1	\N
636	313	306	1	\N
637	314	309	1	\N
638	314	289	0	\N
639	315	309	0	\N
640	315	280	0	\N
641	316	301	1	\N
642	316	314	0	\N
643	317	298	1	\N
644	318	313	1	\N
645	319	304	1	\N
646	320	312	1	\N
647	321	304	0	\N
648	321	310	0	\N
649	322	316	1	\N
650	322	317	1	\N
651	323	321	0	\N
652	323	291	1	\N
653	324	308	0	\N
654	324	308	1	\N
655	325	321	1	\N
656	325	301	0	\N
657	326	319	0	\N
658	326	294	0	\N
659	327	325	0	\N
660	327	306	0	\N
661	328	322	1	\N
662	329	312	0	\N
663	329	316	0	\N
664	330	297	1	\N
665	331	288	0	\N
666	331	307	1	\N
667	332	305	1	\N
668	333	323	1	\N
669	334	333	0	\N
670	334	322	0	\N
671	335	311	1	\N
672	335	315	1	\N
673	336	320	0	\N
674	336	303	1	\N
675	337	268	0	\N
676	337	296	1	\N
677	338	313	0	\N
678	338	285	0	\N
679	339	310	1	\N
680	340	333	1	\N
681	341	332	0	\N
682	341	327	1	\N
683	342	335	1	\N
684	342	271	1	\N
685	343	262	1	\N
686	344	326	0	\N
687	344	336	0	\N
688	345	334	0	\N
689	345	328	0	\N
690	346	318	1	\N
691	346	341	1	\N
692	347	331	0	\N
693	347	343	0	\N
694	348	324	1	\N
695	348	345	1	\N
696	349	319	1	\N
697	350	349	1	\N
698	351	299	0	\N
699	351	295	0	\N
700	352	305	0	\N
701	352	347	0	\N
702	353	343	1	\N
703	353	347	1	\N
704	354	328	1	\N
705	355	318	0	\N
706	355	340	0	\N
707	356	265	0	\N
708	356	355	1	\N
709	357	257	1	\N
710	358	338	0	\N
711	358	355	0	\N
712	358	300	0	\N
713	358	294	1	\N
714	359	108	2	\N
715	360	359	1	\N
716	361	360	1	\N
717	362	107	0	\N
718	363	108	4	\N
719	363	362	0	\N
720	364	109	0	\N
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
8	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"4349502d303032352d76312d686578": {"name": "CIP-0025-v1-hex", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1781e343334393530326433303330333233353264373633313264363836353738a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656f4349502d303032352d76312d6865786776657273696f6e63312e30	126
9	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"CIP-0025-v1-utf8": {"name": "CIP-0025-v1-utf8", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1704349502d303032352d76312d75746638a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65704349502d303032352d76312d757466386776657273696f6e63312e30	127
10	721	{"0x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"0x4349502d303032352d7632": {"name": "CIP-0025-v2", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a1581c17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029a14b4349502d303032352d7632a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656b4349502d303032352d76326776657273696f6e63312e30	128
11	6862	{"name": "Test Portfolio", "pools": [{"id": "f0bda71a98da1ced787ff76a0e60d0f43cf600346c2fe77fc53fc3b2", "weight": 1}, {"id": "3a2ff5dc815247bc3b2af97264100a969ffec277d61157b987f22d49", "weight": 1}, {"id": "71ebe7cddbd11ba29fbef4961c7aef58e6e48d1cacc3579eafdfc448", "weight": 1}, {"id": "b2b13c9b339420a201e3660abe96e0ed4373d0496708a8d623bbd1a7", "weight": 1}, {"id": "3f4884203fb68a67ee5ca0d9c478407b6e92495dfeeb00f10fac81b5", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783866306264613731613938646131636564373837666637366130653630643066343363663630303334366332666537376663353366633362326677656967687401a2626964783833613266663564633831353234376263336232616639373236343130306139363966666563323737643631313537623938376632326434396677656967687401a2626964783837316562653763646462643131626132396662656634393631633761656635386536653438643163616363333537396561666466633434386677656967687401a2626964783862326231336339623333393432306132303165333636306162653936653065643433373364303439363730386138643632336262643161376677656967687401a2626964783833663438383432303366623638613637656535636130643963343738343037623665393234393564666565623030663130666163383162356677656967687401	131
12	6862	{"name": "Test Portfolio", "pools": [{"id": "f0bda71a98da1ced787ff76a0e60d0f43cf600346c2fe77fc53fc3b2", "weight": 0}, {"id": "3a2ff5dc815247bc3b2af97264100a969ffec277d61157b987f22d49", "weight": 0}, {"id": "71ebe7cddbd11ba29fbef4961c7aef58e6e48d1cacc3579eafdfc448", "weight": 0}, {"id": "b2b13c9b339420a201e3660abe96e0ed4373d0496708a8d623bbd1a7", "weight": 0}, {"id": "3f4884203fb68a67ee5ca0d9c478407b6e92495dfeeb00f10fac81b5", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783866306264613731613938646131636564373837666637366130653630643066343363663630303334366332666537376663353366633362326677656967687400a2626964783833613266663564633831353234376263336232616639373236343130306139363966666563323737643631313537623938376632326434396677656967687400a2626964783837316562653763646462643131626132396662656634393631633761656635386536653438643163616363333537396561666466633434386677656967687400a2626964783862326231336339623333393432306132303165333636306162653936653065643433373364303439363730386138643632336262643161376677656967687400a2626964783833663438383432303366623638613637656535636130643963343738343037623665393234393564666565623030663130666163383162356677656967687401	132
13	123	"1234"	\\xa1187b6431323334	147
14	6862	{"pools": [{"id": "3a2ff5dc815247bc3b2af97264100a969ffec277d61157b987f22d49", "weight": 1}]}	\\xa1191acea165706f6f6c7381a2626964783833613266663564633831353234376263336232616639373236343130306139363966666563323737643631313537623938376632326434396677656967687401	148
15	6862	{"name": "Test Portfolio", "pools": [{"id": "f0bda71a98da1ced787ff76a0e60d0f43cf600346c2fe77fc53fc3b2", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7381a2626964783866306264613731613938646131636564373837666637366130653630643066343363663630303334366332666537376663353366633362326677656967687401	154
16	6862	{"name": "Test Portfolio", "pools": [{"id": "f0bda71a98da1ced787ff76a0e60d0f43cf600346c2fe77fc53fc3b2", "weight": 1}, {"id": "3a2ff5dc815247bc3b2af97264100a969ffec277d61157b987f22d49", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7382a2626964783866306264613731613938646131636564373837666637366130653630643066343363663630303334366332666537376663353366633362326677656967687401a2626964783833613266663564633831353234376263336232616639373236343130306139363966666563323737643631313537623938376632326434396677656967687401	256
17	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	358
\.


--
-- Data for Name: tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_out (id, tx_id, index, address, address_raw, address_has_script, payment_cred, stake_address_id, value, data_hash, inline_datum_id, reference_script_id) FROM stdin;
1	1	0	5oP9ib6ym3XYFcpqk71Q4xS7NX2gepSDebZ4wDpPQavcacyTXXqBJifiDwyf6urwo6	\\x82d818582683581c0da70e9ea33276760c5b6ee6c21fb94931bf5f60e13ccbb1d3148dc5a10243190378001a52c97091	f	\N	\N	910909092	\N	\N	\N
2	2	0	5oP9ib6ym3XZ221LA54NefrBk3ww79aW6kbYWWFUSHcon3pMMSskCki3Limd26QsC5	\\x82d818582683581c1d0f20c8a12863c2677cd481eb459e7114923895543bcc2be3585c3fa10243190378001a8cae2a12	f	\N	\N	910909092	\N	\N	\N
3	3	0	5oP9ib6ym3XcpMCfB32bCr3kTkEU2XJ8MTF6GrwoUsGxcoULK3mewUTokk9qiDjMDi	\\x82d818582683581c69835dbeb7c868beb2a60205753e52d6f854978e25d670dda91fc33da10243190378001a876308a1	f	\N	\N	910909092	\N	\N	\N
4	4	0	5oP9ib6ym3XdbciRkevhkVUH4yRdYjtP8oL7MPxSuCqnvQzDMoAEsxbKTF1o9WKEvk	\\x82d818582683581c79388655fe0466647ab05ef9cf08bf89159b2a14e8bf16a54edee2cba10243190378001af1f3ef21	f	\N	\N	910909092	\N	\N	\N
5	5	0	5oP9ib6ym3Xe9hD9528FLXLKUgAJGPHVfKXSyzR56G51EDvEsVj38MjFRt3yu45y2Z	\\x82d818582683581c845a0106b2655a9eeb302523fc74583277e0421f7bf89b31576e0973a10243190378001ad06c928a	f	\N	\N	910909092	\N	\N	\N
6	6	0	5oP9ib6ym3XeDth4HREYPhMtKohoz62RHpMi9B5pqr4mKp9bQDUiHWDdEgXdbaD8Z1	\\x82d818582683581c85cee9af577438bf913a984fb1776974f65b8e0f721e99237e55406da10243190378001a9f03206c	f	\N	\N	910909092	\N	\N	\N
7	7	0	5oP9ib6ym3XeJ2v1eFEnAbZovcdfFhpisK92UWiuydRyWVhHcQAHXYciBAq47jjHb7	\\x82d818582683581c873ed4f274bd170675b95a6ed81e99cd55102235a9b51d0f060ba6cea10243190378001aad3b4eaa	f	\N	\N	910909092	\N	\N	\N
8	8	0	5oP9ib6ym3Xh82vS8qYVPA9RgbTgYSLoNf1idmNkNSz1LTJmKqqeJFgRKzk1SHd6Wh	\\x82d818582683581cc0272429ac7f38ea920ea937ed70fb87e2d8c03cfd2947970cb1b32ca10243190378001afd79cc2e	f	\N	\N	910909092	\N	\N	\N
9	9	0	5oP9ib6ym3Xhe3rtzz7gDcU1AGESNjK2VGXceq6H6xnyHxobXAPc8cdZjYg7SzBi8Q	\\x82d818582683581cca918315b43c6004a6413680f5bd41acf09fbbedfb606390dd935739a10243190378001a9d6a7931	f	\N	\N	910909092	\N	\N	\N
10	10	0	5oP9ib6ym3Xifinxd6dYduHVg8mrH5A8hkDRdegUr7RbfPLCbqyJYQZhgdibTn1Rcr	\\x82d818582683581cdf462c67f1d8f7e0bfa45d78b48444df1c1a996ef1e72b746527799ca10243190378001a67626e8f	f	\N	\N	910909092	\N	\N	\N
11	11	0	5oP9ib6ym3Xj6BCDtVoMeiUKuHNcShdW4KGchWWR7W49EZe5QDkzFF6Tgmz5e72cL2	\\x82d818582683581ce7c28dff8ec39ae3e26ad0bfa4a40fc0f915341610eafc4d0b75567ba10243190378001a76663a63	f	\N	\N	910909092	\N	\N	\N
12	12	0	addr_test1qzl9pdvzt0xqpw3tc3pgk04l9mzpwwflyhgymzweuva2uvmkp7zcdrkw6y27znt338p2ura8urhmacrswh7ajpempfnscnxqu4	\\x00be50b5825bcc00ba2bc4428b3ebf2ec417393f25d04d89d9e33aae33760f85868eced115e14d7189c2ae0fa7e0efbee07075fdd9073b0a67	f	\\xbe50b5825bcc00ba2bc4428b3ebf2ec417393f25d04d89d9e33aae33	\N	3681818181818181	\N	\N	\N
13	13	0	addr_test1qrju2rzs9tsk98cgd07v6fwjtqdqlyu23r6ml3nu942h2qjy3sz2qfe4fngkr6t0h7n94njnkyex8yk4kthyy2zwq8msgarcnd	\\x00e5c50c502ae1629f086bfccd25d2581a0f938a88f5bfc67c2d557502448c04a027354cd161e96fbfa65ace53b1326392d5b2ee42284e01f7	f	\\xe5c50c502ae1629f086bfccd25d2581a0f938a88f5bfc67c2d557502	\N	3681818181818181	\N	\N	\N
14	14	0	addr_test1qp7j4yp4gmt4lfmxhhewuhxtjy56sw2mv6dldqtxf6q44v6cxrgz08caxld8l7k9eqay5esddxk7j57mrkaxt0kj3qgqeyek9q	\\x007d2a903546d75fa766bdf2ee5ccb9129a8395b669bf681664e815ab35830d0279f1d37da7ffac5c83a4a660d69ade953db1dba65bed28810	f	\\x7d2a903546d75fa766bdf2ee5ccb9129a8395b669bf681664e815ab3	\N	3681818181818181	\N	\N	\N
15	15	0	addr_test1vq3cewsctwxhkhy5hpy2j4heu9gwxsznet338rz8m4ly96q3dx26h	\\x60238cba185b8d7b5c94b848a956f9e150e34053cae3138c47dd7e42e8	f	\\x238cba185b8d7b5c94b848a956f9e150e34053cae3138c47dd7e42e8	\N	3681818181818181	\N	\N	\N
16	16	0	addr_test1vr4luczswtyyp5v7l738g6eyecxfrch5kp0vzaktkly2nqg05twgp	\\x60ebfe605072c840d19effa2746b24ce0c91e2f4b05ec176cbb7c8a981	f	\\xebfe605072c840d19effa2746b24ce0c91e2f4b05ec176cbb7c8a981	\N	3681818181818190	\N	\N	\N
17	17	0	addr_test1vzqmaz5x8m50t59n4hk80gyyd6tcwrdvyqq0nj7tsntjmtgy09uk7	\\x6081be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	f	\\x81be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	\N	3681818181818181	\N	\N	\N
18	18	0	addr_test1vr5ttltsd4jpm7c7s99g5em5mrgjr8pyxcdv62dzlm5jyzcxf27wq	\\x60e8b5fd706d641dfb1e814a8a6774d8d1219c24361acd29a2fee9220b	f	\\xe8b5fd706d641dfb1e814a8a6774d8d1219c24361acd29a2fee9220b	\N	3681818181818181	\N	\N	\N
19	19	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681818181818181	\N	\N	\N
20	20	0	addr_test1qqdmsh5422xm7wpzrtyul07e5n8nyqy65lc5da0yv4yf93fh7pdewsyqpsskldjuxee9hw30e8yhl0fmlcla5zxfzjtqam7xhf	\\x001bb85e95528dbf38221ac9cfbfd9a4cf32009aa7f146f5e4654892c537f05b9740800c216fb65c36725bba2fc9c97fbd3bfe3fda08c91496	f	\\x1bb85e95528dbf38221ac9cfbfd9a4cf32009aa7f146f5e4654892c5	\N	3681818181818181	\N	\N	\N
21	21	0	addr_test1qp9wx94c59r0suqanr5njplt9rts85ffpsetdwj5sdga0yjx3mgfw2fkhuzu5pspe6fggmsgszammm62x8naur8l7stqasx56p	\\x004ae316b8a146f8701d98e93907eb28d703d1290c32b6ba548351d792468ed0972936bf05ca0601ce92846e0880bbbdef4a31e7de0cfff416	f	\\x4ae316b8a146f8701d98e93907eb28d703d1290c32b6ba548351d792	\N	3681818181818181	\N	\N	\N
22	22	0	addr_test1qr5zq5963kgs9ycjx2rel5keed2sfjlgyaejf0wt3my0v7q7k4ef90husnxwxm8wanpk292eu46xamj2nvpgx3maxw6s8zdh5f	\\x00e82050ba8d9102931232879fd2d9cb5504cbe8277324bdcb8ec8f6781eb57292befc84cce36ceeecc3651559e5746eee4a9b0283477d33b5	f	\\xe82050ba8d9102931232879fd2d9cb5504cbe8277324bdcb8ec8f678	\N	3681818181818190	\N	\N	\N
23	23	0	addr_test1vp8ytuvya2kfmavt90quy8s6zpe9fjwwkj0dazy6z8uz3dg4ekw25	\\x604e45f184eaac9df58b2bc1c21e1a107254c9ceb49ede889a11f828b5	f	\\x4e45f184eaac9df58b2bc1c21e1a107254c9ceb49ede889a11f828b5	\N	3681818181818181	\N	\N	\N
24	24	0	addr_test1qq634nld5ptkskyddncyqw8upcuquq4sp0xc4y8wq84nsxsae9zvua7hh0v9f9tnz0qn63hum5hc2vhasx4dap4qrfnqea2ugu	\\x00351acfeda05768588d6cf04038fc0e380e02b00bcd8a90ee01eb381a1dc944ce77d7bbd854957313c13d46fcdd2f8532fd81aade86a01a66	f	\\x351acfeda05768588d6cf04038fc0e380e02b00bcd8a90ee01eb381a	\N	3681818181818181	\N	\N	\N
25	25	0	addr_test1vqz5gqqchezx5pazdfdfegjrxev87nswds6raarcukapejqpm0t69	\\x6005440018be446a07a26a5a9ca24336587f4e0e6c343ef478e5ba1cc8	f	\\x05440018be446a07a26a5a9ca24336587f4e0e6c343ef478e5ba1cc8	\N	3681818181818181	\N	\N	\N
26	26	0	addr_test1qquuj3scgdrah84t60mgr5ujfea0a8kadnx68utfczmckwa0yazm87mv06llfj8d9963ttdl5c92p3dmc3ftquut9f4qr8rnz2	\\x0039c946184347db9eabd3f681d3924e7afe9edd6ccda3f169c0b78b3baf2745b3fb6c7ebff4c8ed297515adbfa60aa0c5bbc452b0738b2a6a	f	\\x39c946184347db9eabd3f681d3924e7afe9edd6ccda3f169c0b78b3b	\N	3681818181818181	\N	\N	\N
27	27	0	addr_test1vqt2zwlmd8l0eyymlpqkldpvvew8e05k5taj6ayt692txccxefztz	\\x6016a13bfb69fefc909bf8416fb42c665c7cbe96a2fb2d748bd154b363	f	\\x16a13bfb69fefc909bf8416fb42c665c7cbe96a2fb2d748bd154b363	\N	3681818181818181	\N	\N	\N
28	28	0	addr_test1vq6lelgexr62gj8ycu2588wzqtg5tf5a4gjf2d8d6z2rskggujhf8	\\x6035fcfd1930f4a448e4c715439dc202d145a69daa249534edd0943859	f	\\x35fcfd1930f4a448e4c715439dc202d145a69daa249534edd0943859	\N	3681818181818181	\N	\N	\N
29	29	0	addr_test1qzru746vpqws83cpq3x7nc6wvnrxm0a44qpujndy85fzy0t4sdq25lsfpd3lnxx6hqe0q57qxrp7ywrf9h7njumrde3sdemjsc	\\x0087cf574c081d03c701044de9e34e64c66dbfb5a803c94da43d12223d758340aa7e090b63f998dab832f053c030c3e238692dfd3973636e63	f	\\x87cf574c081d03c701044de9e34e64c66dbfb5a803c94da43d12223d	\N	3681818181818181	\N	\N	\N
30	30	0	addr_test1qq3mqkq7pmn5jl7m9ul6qquj7qv4jmyfeul7u86x6v8tzym9hyqhg4yye5hewupnjh0jrmqyfls9wvsr5ndynu4ullmsmsk9l2	\\x0023b0581e0ee7497fdb2f3fa00392f019596c89cf3fee1f46d30eb11365b901745484cd2f97703395df21ec044fe0573203a4da49f2bcfff7	f	\\x23b0581e0ee7497fdb2f3fa00392f019596c89cf3fee1f46d30eb113	\N	3681818181818181	\N	\N	\N
31	31	0	addr_test1qz79952ajku25j6g5a05pk94x6g9kp57dym6k97pjc98gletpcraphfg995d9ayu53mumsj5acyz272rca0vs5saex6sykw93z	\\x00bc52d15d95b8aa4b48a75f40d8b536905b069e6937ab17c1960a747f2b0e07d0dd282968d2f49ca477cdc254ee08257943c75ec8521dc9b5	f	\\xbc52d15d95b8aa4b48a75f40d8b536905b069e6937ab17c1960a747f	\N	3681818181818181	\N	\N	\N
32	32	0	addr_test1vr4s49r3s2p8sywnq9j0r9vuhtcpy7h0xhfnvky2rv4388gsgpeug	\\x60eb0a947182827811d30164f1959cbaf0127aef35d336588a1b2b139d	f	\\xeb0a947182827811d30164f1959cbaf0127aef35d336588a1b2b139d	\N	3681818181818181	\N	\N	\N
33	33	0	addr_test1vpuxumchz8xhja9hw9mthwdtld4da0ep5l40rdrgwjl50ps6f6mf3	\\x60786e6f1711cd7974b77176bbb9abfb6adebf21a7eaf1b46874bf4786	f	\\x786e6f1711cd7974b77176bbb9abfb6adebf21a7eaf1b46874bf4786	\N	3681818181818181	\N	\N	\N
34	35	0	addr_test1qrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffj3lh9fefvn770k638ntze4q6ptkytrjj9k0x23nwgpj99dsguxf4t	\\x00cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca3fb95394b27ef3eda89e6b166a0d057622c72916cf32a3372032295b	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	21	500000000	\N	\N	\N
35	35	1	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681817681651228	\N	\N	\N
36	36	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681817681473231	\N	\N	\N
37	37	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681817681293914	\N	\N	\N
72	66	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681814878327629	\N	\N	\N
38	38	0	addr_test1qp7j4yp4gmt4lfmxhhewuhxtjy56sw2mv6dldqtxf6q44v6cxrgz08caxld8l7k9eqay5esddxk7j57mrkaxt0kj3qgqeyek9q	\\x007d2a903546d75fa766bdf2ee5ccb9129a8395b669bf681664e815ab35830d0279f1d37da7ffac5c83a4a660d69ade953db1dba65bed28810	f	\\x7d2a903546d75fa766bdf2ee5ccb9129a8395b669bf681664e815ab3	3	3681818181637632	\N	\N	\N
39	39	0	addr_test1qp7j4yp4gmt4lfmxhhewuhxtjy56sw2mv6dldqtxf6q44v6cxrgz08caxld8l7k9eqay5esddxk7j57mrkaxt0kj3qgqeyek9q	\\x007d2a903546d75fa766bdf2ee5ccb9129a8395b669bf681664e815ab35830d0279f1d37da7ffac5c83a4a660d69ade953db1dba65bed28810	f	\\x7d2a903546d75fa766bdf2ee5ccb9129a8395b669bf681664e815ab3	3	3681818181443619	\N	\N	\N
40	40	0	addr_test1qrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffj59tsgxv9ymfum3k6dk35l4njgt3e7490ak4s6n93pj3e0seq6hw2	\\x00cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca855c1066149b4f371b69b68d3f59c90b8e7d52bfb6ac3532c4328e5f	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	20	600000000	\N	\N	\N
41	40	1	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681817081126961	\N	\N	\N
42	41	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681817080948964	\N	\N	\N
43	42	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681817080769647	\N	\N	\N
44	43	0	addr_test1qquuj3scgdrah84t60mgr5ujfea0a8kadnx68utfczmckwa0yazm87mv06llfj8d9963ttdl5c92p3dmc3ftquut9f4qr8rnz2	\\x0039c946184347db9eabd3f681d3924e7afe9edd6ccda3f169c0b78b3baf2745b3fb6c7ebff4c8ed297515adbfa60aa0c5bbc452b0738b2a6a	f	\\x39c946184347db9eabd3f681d3924e7afe9edd6ccda3f169c0b78b3b	8	3681818181637632	\N	\N	\N
45	44	0	addr_test1qquuj3scgdrah84t60mgr5ujfea0a8kadnx68utfczmckwa0yazm87mv06llfj8d9963ttdl5c92p3dmc3ftquut9f4qr8rnz2	\\x0039c946184347db9eabd3f681d3924e7afe9edd6ccda3f169c0b78b3baf2745b3fb6c7ebff4c8ed297515adbfa60aa0c5bbc452b0738b2a6a	f	\\x39c946184347db9eabd3f681d3924e7afe9edd6ccda3f169c0b78b3b	8	3681818181446391	\N	\N	\N
46	45	0	addr_test1qrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjkz07s0dk6e7mtlu2xm9pguxuhnk9eqlrgjkkw6yetevhysskfydm	\\x00cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094cac27fa0f6db59f6d7fe28db2851c372f3b1720f8d12b59da2657965c9	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	15	200000000	\N	\N	\N
47	45	1	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681816880602694	\N	\N	\N
48	46	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681816880424697	\N	\N	\N
49	47	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681816880245380	\N	\N	\N
50	48	0	addr_test1qq634nld5ptkskyddncyqw8upcuquq4sp0xc4y8wq84nsxsae9zvua7hh0v9f9tnz0qn63hum5hc2vhasx4dap4qrfnqea2ugu	\\x00351acfeda05768588d6cf04038fc0e380e02b00bcd8a90ee01eb381a1dc944ce77d7bbd854957313c13d46fcdd2f8532fd81aade86a01a66	f	\\x351acfeda05768588d6cf04038fc0e380e02b00bcd8a90ee01eb381a	7	3681818181637632	\N	\N	\N
51	49	0	addr_test1qq634nld5ptkskyddncyqw8upcuquq4sp0xc4y8wq84nsxsae9zvua7hh0v9f9tnz0qn63hum5hc2vhasx4dap4qrfnqea2ugu	\\x00351acfeda05768588d6cf04038fc0e380e02b00bcd8a90ee01eb381a1dc944ce77d7bbd854957313c13d46fcdd2f8532fd81aade86a01a66	f	\\x351acfeda05768588d6cf04038fc0e380e02b00bcd8a90ee01eb381a	7	3681818181443619	\N	\N	\N
52	50	0	addr_test1qrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjjcpkwzu3wr0vyr0ggyqtpnzyud04uxcquhkz2vd7t239ws70qp46	\\x00cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca580d9c2e45c37b0837a10402c331138d7d786c0397b094c6f96a895d	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	14	500000000	\N	\N	\N
53	50	1	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681816380078427	\N	\N	\N
54	51	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681816379900430	\N	\N	\N
55	52	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681816379721113	\N	\N	\N
56	53	0	addr_test1qzru746vpqws83cpq3x7nc6wvnrxm0a44qpujndy85fzy0t4sdq25lsfpd3lnxx6hqe0q57qxrp7ywrf9h7njumrde3sdemjsc	\\x0087cf574c081d03c701044de9e34e64c66dbfb5a803c94da43d12223d758340aa7e090b63f998dab832f053c030c3e238692dfd3973636e63	f	\\x87cf574c081d03c701044de9e34e64c66dbfb5a803c94da43d12223d	9	3681818181637632	\N	\N	\N
57	54	0	addr_test1qzru746vpqws83cpq3x7nc6wvnrxm0a44qpujndy85fzy0t4sdq25lsfpd3lnxx6hqe0q57qxrp7ywrf9h7njumrde3sdemjsc	\\x0087cf574c081d03c701044de9e34e64c66dbfb5a803c94da43d12223d758340aa7e090b63f998dab832f053c030c3e238692dfd3973636e63	f	\\x87cf574c081d03c701044de9e34e64c66dbfb5a803c94da43d12223d	9	3681818181443619	\N	\N	\N
58	55	0	addr_test1qrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffj4wzpte0l2r9jlv9lmgnn6xpfgylqh5nqj5wgeudume5s7q274uz2	\\x00cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094caae105797fd432cbec2ff689cf460a504f82f4982547233c6f379a43c	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	18	500000000	\N	\N	\N
59	55	1	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681815879554160	\N	\N	\N
60	56	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681815879376163	\N	\N	\N
61	57	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681815879196846	\N	\N	\N
62	58	0	addr_test1qqdmsh5422xm7wpzrtyul07e5n8nyqy65lc5da0yv4yf93fh7pdewsyqpsskldjuxee9hw30e8yhl0fmlcla5zxfzjtqam7xhf	\\x001bb85e95528dbf38221ac9cfbfd9a4cf32009aa7f146f5e4654892c537f05b9740800c216fb65c36725bba2fc9c97fbd3bfe3fda08c91496	f	\\x1bb85e95528dbf38221ac9cfbfd9a4cf32009aa7f146f5e4654892c5	4	3681818181637632	\N	\N	\N
63	59	0	addr_test1qqdmsh5422xm7wpzrtyul07e5n8nyqy65lc5da0yv4yf93fh7pdewsyqpsskldjuxee9hw30e8yhl0fmlcla5zxfzjtqam7xhf	\\x001bb85e95528dbf38221ac9cfbfd9a4cf32009aa7f146f5e4654892c537f05b9740800c216fb65c36725bba2fc9c97fbd3bfe3fda08c91496	f	\\x1bb85e95528dbf38221ac9cfbfd9a4cf32009aa7f146f5e4654892c5	4	3681818181443619	\N	\N	\N
64	60	0	addr_test1qrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjkpyuqz6wru5h6zl4ycf74ugmnw97s0qy6z393j23urm8ksnxtk7j	\\x00cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094cac127002d387ca5f42fd4984fabc46e6e2fa0f013428963254783d9ed	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	19	500000000	\N	\N	\N
65	60	1	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681815379029893	\N	\N	\N
66	61	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681815378851896	\N	\N	\N
67	62	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681815378672579	\N	\N	\N
68	63	0	addr_test1qq3mqkq7pmn5jl7m9ul6qquj7qv4jmyfeul7u86x6v8tzym9hyqhg4yye5hewupnjh0jrmqyfls9wvsr5ndynu4ullmsmsk9l2	\\x0023b0581e0ee7497fdb2f3fa00392f019596c89cf3fee1f46d30eb11365b901745484cd2f97703395df21ec044fe0573203a4da49f2bcfff7	f	\\x23b0581e0ee7497fdb2f3fa00392f019596c89cf3fee1f46d30eb113	10	3681818181637632	\N	\N	\N
69	64	0	addr_test1qq3mqkq7pmn5jl7m9ul6qquj7qv4jmyfeul7u86x6v8tzym9hyqhg4yye5hewupnjh0jrmqyfls9wvsr5ndynu4ullmsmsk9l2	\\x0023b0581e0ee7497fdb2f3fa00392f019596c89cf3fee1f46d30eb11365b901745484cd2f97703395df21ec044fe0573203a4da49f2bcfff7	f	\\x23b0581e0ee7497fdb2f3fa00392f019596c89cf3fee1f46d30eb113	10	3681818181443619	\N	\N	\N
70	65	0	addr_test1qrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffj56tgkltdtw5zj82x3h5gr4a4sa9rsmxvawkpv74n6j40dsnljhct	\\x00cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca9a5a2df5b56ea0a4751a37a2075ed61d28e1b333aeb059eacf52abdb	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	22	500000000	\N	\N	\N
71	65	1	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681814878505626	\N	\N	\N
73	67	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681814878148312	\N	\N	\N
74	68	0	addr_test1qzl9pdvzt0xqpw3tc3pgk04l9mzpwwflyhgymzweuva2uvmkp7zcdrkw6y27znt338p2ura8urhmacrswh7ajpempfnscnxqu4	\\x00be50b5825bcc00ba2bc4428b3ebf2ec417393f25d04d89d9e33aae33760f85868eced115e14d7189c2ae0fa7e0efbee07075fdd9073b0a67	f	\\xbe50b5825bcc00ba2bc4428b3ebf2ec417393f25d04d89d9e33aae33	1	3681818181637632	\N	\N	\N
75	69	0	addr_test1qzl9pdvzt0xqpw3tc3pgk04l9mzpwwflyhgymzweuva2uvmkp7zcdrkw6y27znt338p2ura8urhmacrswh7ajpempfnscnxqu4	\\x00be50b5825bcc00ba2bc4428b3ebf2ec417393f25d04d89d9e33aae33760f85868eced115e14d7189c2ae0fa7e0efbee07075fdd9073b0a67	f	\\xbe50b5825bcc00ba2bc4428b3ebf2ec417393f25d04d89d9e33aae33	1	3681818181443619	\N	\N	\N
76	70	0	addr_test1qrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjjlwqnzmf8d6zzlxktucgv2p7syms6z4ywa6kyhnggetv5sdy85su	\\x00cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca5f70262da4edd085f3597cc218a0fa04dc342a91ddd58979a1195b29	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	16	300000000	\N	\N	\N
77	70	1	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681814577981359	\N	\N	\N
78	71	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681814577803362	\N	\N	\N
79	72	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681814577624045	\N	\N	\N
80	73	0	addr_test1qrju2rzs9tsk98cgd07v6fwjtqdqlyu23r6ml3nu942h2qjy3sz2qfe4fngkr6t0h7n94njnkyex8yk4kthyy2zwq8msgarcnd	\\x00e5c50c502ae1629f086bfccd25d2581a0f938a88f5bfc67c2d557502448c04a027354cd161e96fbfa65ace53b1326392d5b2ee42284e01f7	f	\\xe5c50c502ae1629f086bfccd25d2581a0f938a88f5bfc67c2d557502	2	3681818181637632	\N	\N	\N
81	74	0	addr_test1qrju2rzs9tsk98cgd07v6fwjtqdqlyu23r6ml3nu942h2qjy3sz2qfe4fngkr6t0h7n94njnkyex8yk4kthyy2zwq8msgarcnd	\\x00e5c50c502ae1629f086bfccd25d2581a0f938a88f5bfc67c2d557502448c04a027354cd161e96fbfa65ace53b1326392d5b2ee42284e01f7	f	\\xe5c50c502ae1629f086bfccd25d2581a0f938a88f5bfc67c2d557502	2	3681818181446391	\N	\N	\N
82	75	0	addr_test1qrju2rzs9tsk98cgd07v6fwjtqdqlyu23r6ml3nu942h2qjy3sz2qfe4fngkr6t0h7n94njnkyex8yk4kthyy2zwq8msgarcnd	\\x00e5c50c502ae1629f086bfccd25d2581a0f938a88f5bfc67c2d557502448c04a027354cd161e96fbfa65ace53b1326392d5b2ee42284e01f7	f	\\xe5c50c502ae1629f086bfccd25d2581a0f938a88f5bfc67c2d557502	2	3681818181265842	\N	\N	\N
83	76	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681814577439800	\N	\N	\N
84	77	0	addr_test1qrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjshz96j5fg55kdqjfzafgda6atd7uvyy4z05r4af8sg9rvss8dw97	\\x00cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca1711752a2514a59a09245d4a1bdd756df71842544fa0ebd49e0828d9	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	13	300000000	\N	\N	\N
85	77	1	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681814277272847	\N	\N	\N
86	78	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681814277094850	\N	\N	\N
87	79	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681814276915533	\N	\N	\N
88	80	0	addr_test1qp9wx94c59r0suqanr5njplt9rts85ffpsetdwj5sdga0yjx3mgfw2fkhuzu5pspe6fggmsgszammm62x8naur8l7stqasx56p	\\x004ae316b8a146f8701d98e93907eb28d703d1290c32b6ba548351d792468ed0972936bf05ca0601ce92846e0880bbbdef4a31e7de0cfff416	f	\\x4ae316b8a146f8701d98e93907eb28d703d1290c32b6ba548351d792	5	3681818181637632	\N	\N	\N
89	81	0	addr_test1qp9wx94c59r0suqanr5njplt9rts85ffpsetdwj5sdga0yjx3mgfw2fkhuzu5pspe6fggmsgszammm62x8naur8l7stqasx56p	\\x004ae316b8a146f8701d98e93907eb28d703d1290c32b6ba548351d792468ed0972936bf05ca0601ce92846e0880bbbdef4a31e7de0cfff416	f	\\x4ae316b8a146f8701d98e93907eb28d703d1290c32b6ba548351d792	5	3681818181446391	\N	\N	\N
90	82	0	addr_test1qp9wx94c59r0suqanr5njplt9rts85ffpsetdwj5sdga0yjx3mgfw2fkhuzu5pspe6fggmsgszammm62x8naur8l7stqasx56p	\\x004ae316b8a146f8701d98e93907eb28d703d1290c32b6ba548351d792468ed0972936bf05ca0601ce92846e0880bbbdef4a31e7de0cfff416	f	\\x4ae316b8a146f8701d98e93907eb28d703d1290c32b6ba548351d792	5	3681818181265842	\N	\N	\N
91	83	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681814276731288	\N	\N	\N
92	84	0	addr_test1qrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffj3m5zzr03x0t2qsctr5kpam6h7zgfm923924duyx6mxmw5qch04fh	\\x00cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca3ba08437c4cf5a810c2c74b07bbd5fc242765544aaab78436b66dba8	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	12	500000000	\N	\N	\N
93	84	1	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681813776564335	\N	\N	\N
94	85	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681813776386338	\N	\N	\N
95	86	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681813776207021	\N	\N	\N
96	87	0	addr_test1qz79952ajku25j6g5a05pk94x6g9kp57dym6k97pjc98gletpcraphfg995d9ayu53mumsj5acyz272rca0vs5saex6sykw93z	\\x00bc52d15d95b8aa4b48a75f40d8b536905b069e6937ab17c1960a747f2b0e07d0dd282968d2f49ca477cdc254ee08257943c75ec8521dc9b5	f	\\xbc52d15d95b8aa4b48a75f40d8b536905b069e6937ab17c1960a747f	11	3681818181637632	\N	\N	\N
97	88	0	addr_test1qz79952ajku25j6g5a05pk94x6g9kp57dym6k97pjc98gletpcraphfg995d9ayu53mumsj5acyz272rca0vs5saex6sykw93z	\\x00bc52d15d95b8aa4b48a75f40d8b536905b069e6937ab17c1960a747f2b0e07d0dd282968d2f49ca477cdc254ee08257943c75ec8521dc9b5	f	\\xbc52d15d95b8aa4b48a75f40d8b536905b069e6937ab17c1960a747f	11	3681818181443575	\N	\N	\N
98	89	0	addr_test1qz79952ajku25j6g5a05pk94x6g9kp57dym6k97pjc98gletpcraphfg995d9ayu53mumsj5acyz272rca0vs5saex6sykw93z	\\x00bc52d15d95b8aa4b48a75f40d8b536905b069e6937ab17c1960a747f2b0e07d0dd282968d2f49ca477cdc254ee08257943c75ec8521dc9b5	f	\\xbc52d15d95b8aa4b48a75f40d8b536905b069e6937ab17c1960a747f	11	3681818181263026	\N	\N	\N
99	90	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681813776022776	\N	\N	\N
100	91	0	addr_test1qrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjsgcf4zm7pqu25lpffvw0xsltzkg28wc0wm7j0e3je5f7gskdgyl9	\\x00cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca08c26a2df820e2a9f0a52c73cd0fac56428eec3ddbf49f98cb344f91	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	17	500000000	\N	\N	\N
101	91	1	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681813275855823	\N	\N	\N
102	92	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681813275677826	\N	\N	\N
103	93	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681813275498509	\N	\N	\N
104	94	0	addr_test1qr5zq5963kgs9ycjx2rel5keed2sfjlgyaejf0wt3my0v7q7k4ef90husnxwxm8wanpk292eu46xamj2nvpgx3maxw6s8zdh5f	\\x00e82050ba8d9102931232879fd2d9cb5504cbe8277324bdcb8ec8f6781eb57292befc84cce36ceeecc3651559e5746eee4a9b0283477d33b5	f	\\xe82050ba8d9102931232879fd2d9cb5504cbe8277324bdcb8ec8f678	6	3681818181637641	\N	\N	\N
105	95	0	addr_test1qr5zq5963kgs9ycjx2rel5keed2sfjlgyaejf0wt3my0v7q7k4ef90husnxwxm8wanpk292eu46xamj2nvpgx3maxw6s8zdh5f	\\x00e82050ba8d9102931232879fd2d9cb5504cbe8277324bdcb8ec8f6781eb57292befc84cce36ceeecc3651559e5746eee4a9b0283477d33b5	f	\\xe82050ba8d9102931232879fd2d9cb5504cbe8277324bdcb8ec8f678	6	3681818181443584	\N	\N	\N
106	96	0	addr_test1qr5zq5963kgs9ycjx2rel5keed2sfjlgyaejf0wt3my0v7q7k4ef90husnxwxm8wanpk292eu46xamj2nvpgx3maxw6s8zdh5f	\\x00e82050ba8d9102931232879fd2d9cb5504cbe8277324bdcb8ec8f6781eb57292befc84cce36ceeecc3651559e5746eee4a9b0283477d33b5	f	\\xe82050ba8d9102931232879fd2d9cb5504cbe8277324bdcb8ec8f678	6	3681818181263035	\N	\N	\N
107	97	0	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3681813275314264	\N	\N	\N
108	98	0	addr_test1wpnlxv2xv9a9ucvnvzqakwepzl9ltx7jzgm53av2e9ncv4sysemm8	\\x7067f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	t	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	\N	100000000	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	\N	\N
109	98	1	addr_test1vzqmaz5x8m50t59n4hk80gyyd6tcwrdvyqq0nj7tsntjmtgy09uk7	\\x6081be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	f	\\x81be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	\N	3681818081650832	\N	\N	\N
110	99	0	addr_test1vzqmaz5x8m50t59n4hk80gyyd6tcwrdvyqq0nj7tsntjmtgy09uk7	\\x6081be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	f	\\x81be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	\N	99828910	\N	\N	\N
111	100	0	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	\\x702618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	100000000	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	2	\N
112	100	1	addr_test1vzqmaz5x8m50t59n4hk80gyyd6tcwrdvyqq0nj7tsntjmtgy09uk7	\\x6081be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	f	\\x81be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	\N	3681817981484759	\N	\N	\N
113	101	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	2
114	101	1	addr_test1vzqmaz5x8m50t59n4hk80gyyd6tcwrdvyqq0nj7tsntjmtgy09uk7	\\x6081be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	f	\\x81be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	\N	3681817881314374	\N	\N	\N
115	102	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	3
116	102	1	addr_test1vzqmaz5x8m50t59n4hk80gyyd6tcwrdvyqq0nj7tsntjmtgy09uk7	\\x6081be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	f	\\x81be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	\N	3681817781146585	\N	\N	\N
117	103	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	1
118	103	1	addr_test1vzqmaz5x8m50t59n4hk80gyyd6tcwrdvyqq0nj7tsntjmtgy09uk7	\\x6081be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	f	\\x81be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	\N	3681817680979940	\N	\N	\N
119	104	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	4
120	104	1	addr_test1vzqmaz5x8m50t59n4hk80gyyd6tcwrdvyqq0nj7tsntjmtgy09uk7	\\x6081be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	f	\\x81be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	\N	3681817580717067	\N	\N	\N
121	105	0	addr_test1wzem0yuxjqyrmzvrsr8xfqhumyy555ngyjxw7wrg2pav90q8cagu2	\\x70b3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	t	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	\N	100000000	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	3	\N
122	105	1	addr_test1vzqmaz5x8m50t59n4hk80gyyd6tcwrdvyqq0nj7tsntjmtgy09uk7	\\x6081be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	f	\\x81be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	\N	3681817480550950	\N	\N	\N
123	106	0	addr_test1vzqmaz5x8m50t59n4hk80gyyd6tcwrdvyqq0nj7tsntjmtgy09uk7	\\x6081be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	f	\\x81be8a863ee8f5d0b3adec77a0846e97870dac2000f9cbcb84d72dad	\N	3681817580223603	\N	\N	\N
124	107	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\N	\N	\N
125	107	1	addr_test1vr5ttltsd4jpm7c7s99g5em5mrgjr8pyxcdv62dzlm5jyzcxf27wq	\\x60e8b5fd706d641dfb1e814a8a6774d8d1219c24361acd29a2fee9220b	f	\\xe8b5fd706d641dfb1e814a8a6774d8d1219c24361acd29a2fee9220b	\N	3681818171642252	\N	\N	\N
126	108	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000000000	\N	\N	\N
127	108	1	addr_test1qrml5hwl9s7ydm2djyup95ud6s74skkl4zzf8zk657s8thgm78sn3uhch64ujc7ffnpga68dfdqhg3sp7tk6759jrm7spy03k9	\\x00f7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd1bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	f	\\xf7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd	47	5000000000000	\N	\N	\N
128	108	2	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	5000000000000	\N	\N	\N
129	108	3	addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k	\\x00594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	f	\\x594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0	49	5000000000000	\N	\N	\N
130	108	4	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	5000000000000	\N	\N	\N
131	108	5	addr_test1vrx7j7wm332cgl8u7rj85ynz8j2yemw7v8hmgftqgpqffjs4lv99z	\\x60cde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	f	\\xcde979db8c55847cfcf0e47a12623c944cedde61efb42560404094ca	\N	3656813275134639	\N	\N	\N
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
153	121	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999917878749	\N	\N	\N
154	122	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9824995	\N	\N	\N
155	123	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9651838	\N	\N	\N
156	124	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
157	124	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999907674748	\N	\N	\N
158	125	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
159	125	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9646778	\N	\N	\N
160	126	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
161	126	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999897487555	\N	\N	\N
162	127	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
163	127	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9461565	\N	\N	\N
164	128	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
165	128	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999887303002	\N	\N	\N
166	129	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	38927706	\N	\N	\N
167	130	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	1000000000	\N	\N	\N
168	130	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998897133013	\N	\N	\N
169	131	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	99675351	\N	\N	\N
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
204	132	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	499576915	\N	\N	\N
205	132	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	249918838	\N	\N	\N
206	132	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	124959419	\N	\N	\N
207	132	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	62479709	\N	\N	\N
208	132	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	31239855	\N	\N	\N
209	132	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	15619927	\N	\N	\N
210	132	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	7809964	\N	\N	\N
211	132	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	3904982	\N	\N	\N
212	132	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	3904981	\N	\N	\N
213	133	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	499375158	\N	\N	\N
214	134	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
215	134	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998893949164	\N	\N	\N
216	135	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2820947	\N	\N	\N
219	137	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
220	137	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	35750325	\N	\N	\N
221	138	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2827019	\N	\N	\N
222	139	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
223	139	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	30582096	\N	\N	\N
224	140	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998930679226	\N	\N	\N
225	140	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4325259	\N	\N	\N
226	141	0	addr_test1qpng86sk8q0kpawqht9ekv8pcmldqzk6cgr8qv64xgerr29k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq2s3e9k	\\x006683ea16381f60f5c0bacb9b30e1c6fed00adac206703355323231a8b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x6683ea16381f60f5c0bacb9b30e1c6fed00adac206703355323231a8	61	3000000	\N	\N	\N
227	141	1	addr_test1qqm5pxthjg4mjnqz5mmyac8n7c94t6nlukdau9zl9nkzheak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqh7lz9z	\\x0037409977922bb94c02a6f64ee0f3f60b55ea7fe59bde145f2cec2be7b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x37409977922bb94c02a6f64ee0f3f60b55ea7fe59bde145f2cec2be7	61	3000000	\N	\N	\N
228	141	2	addr_test1qrtn7r8un8rnjmfmj8trl49mmdv0qp0qwc4j3ngt6xzjjy9k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqlhlnkx	\\x00d73f0cfc99c7396d3b91d63fd4bbdb58f005e0762b28cd0bd1852910b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xd73f0cfc99c7396d3b91d63fd4bbdb58f005e0762b28cd0bd1852910	61	3000000	\N	\N	\N
229	141	3	addr_test1qp7kcx3zd8kf4uh92s6x95lhz2l0ett6jx0ctns88q8dla4k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jql3uwkm	\\x007d6c1a2269ec9af2e5543462d3f712befcad7a919f85ce07380edff6b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x7d6c1a2269ec9af2e5543462d3f712befcad7a919f85ce07380edff6	61	3000000	\N	\N	\N
230	141	4	addr_test1qz8m7ywfrjadnkuhmggdv00gug7rfd0vp3pkdn6t0dcwpkak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqw4rcll	\\x008fbf11c91cbad9db97da10d63de8e23c34b5ec0c4366cf4b7b70e0dbb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x8fbf11c91cbad9db97da10d63de8e23c34b5ec0c4366cf4b7b70e0db	61	3000000	\N	\N	\N
231	141	5	addr_test1qp9jgxa5neex2sq3jg9tg38z9z8a65t637vd0y99d2vs6xak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqkf4htq	\\x004b241bb49e72654011920ab444e2288fdd517a8f98d790a56a990d1bb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x4b241bb49e72654011920ab444e2288fdd517a8f98d790a56a990d1b	61	3000000	\N	\N	\N
232	141	6	addr_test1qrcn7lmck7yuntd40f7yxrfx9vqxq7gyrce87u5wehtwha4k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqw7g9xn	\\x00f13f7f78b789c9adb57a7c430d262b006079041e327f728ecdd6ebf6b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xf13f7f78b789c9adb57a7c430d262b006079041e327f728ecdd6ebf6	61	3000000	\N	\N	\N
233	141	7	addr_test1qqmk6sc6jqdd9ph9kqyrg6rlgpf27y4g25l35czadq36ps4k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq5v4xep	\\x00376d431a901ad286e5b00834687f4052af12a8553f1a605d6823a0c2b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x376d431a901ad286e5b00834687f4052af12a8553f1a605d6823a0c2	61	3000000	\N	\N	\N
234	141	8	addr_test1qzz73e2ljrpklnmrgdq7kfnqkge7ykutz7h4ev89p5qtvz9k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqmr73j6	\\x0085e8e55f90c36fcf634341eb2660b233e25b8b17af5cb0e50d00b608b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x85e8e55f90c36fcf634341eb2660b233e25b8b17af5cb0e50d00b608	61	3000000	\N	\N	\N
235	141	9	addr_test1qrp4uza678d92fzjmkw20dc2kkpa2ccsc2mztmj7wuu45rak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqpetwtz	\\x00c35e0bbaf1da552452dd9ca7b70ab583d56310c2b625ee5e77395a0fb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xc35e0bbaf1da552452dd9ca7b70ab583d56310c2b625ee5e77395a0f	61	3000000	\N	\N	\N
236	141	10	addr_test1qppyxyclyn08vy6vzhwv52n65xk9agjlqjjf6akdcuazmn4k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqkmz7vl	\\x004243131f24de76134c15dcca2a7aa1ac5ea25f04a49d76cdc73a2dceb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x4243131f24de76134c15dcca2a7aa1ac5ea25f04a49d76cdc73a2dce	61	3000000	\N	\N	\N
237	141	11	addr_test1qpcvk0f4tvy79ad2rjpjsmvsv2lyk7n84mzyn42ltc68tu4k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqspludl	\\x0070cb3d355b09e2f5aa1c83286d9062be4b7a67aec449d55f5e3475f2b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x70cb3d355b09e2f5aa1c83286d9062be4b7a67aec449d55f5e3475f2	61	3000000	\N	\N	\N
238	141	12	addr_test1qra6lrpxajqmzy3xwtdtsramc57zun2jce4ufquz3ldafuak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq0pnkvf	\\x00fbaf8c26ec81b1122672dab80fbbc53c2e4d52c66bc483828fdbd4f3b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xfbaf8c26ec81b1122672dab80fbbc53c2e4d52c66bc483828fdbd4f3	61	3000000	\N	\N	\N
239	141	13	addr_test1qrcna2ajtv4d08k298z45de0wzywqltqz4lstfqz7qwa9edk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqm5epdh	\\x00f13eabb25b2ad79eca29c55a372f7088e07d60157f05a402f01dd2e5b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xf13eabb25b2ad79eca29c55a372f7088e07d60157f05a402f01dd2e5	61	3000000	\N	\N	\N
240	141	14	addr_test1qrxvuu9fdnh7dk505scd2mmx6w7h3et5yjsql4vxln4kzhak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqcw7x4m	\\x00ccce70a96cefe6da8fa430d56f66d3bd78e57424a00fd586fceb615fb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xccce70a96cefe6da8fa430d56f66d3bd78e57424a00fd586fceb615f	61	3000000	\N	\N	\N
241	141	15	addr_test1qq6h3lpx439qjtn7gj5tkpxfm92xm9dvvzfmtryr7ahml49k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqnxx74h	\\x003578fc26ac4a092e7e44a8bb04c9d9546d95ac6093b58c83f76fbfd4b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x3578fc26ac4a092e7e44a8bb04c9d9546d95ac6093b58c83f76fbfd4	61	3000000	\N	\N	\N
242	141	16	addr_test1qqn9nfls6xk6ue33s9vqnrqe5u6c70tmw5glhe37ecfzyp4k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqpem952	\\x002659a7f0d1adae66318158098c19a7358f3d7b7511fbe63ece122206b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x2659a7f0d1adae66318158098c19a7358f3d7b7511fbe63ece122206	61	3000000	\N	\N	\N
243	141	17	addr_test1qzmfdnhf8cufsqvk9vranw4w9lspcquf2k40j04alv2mmqdk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqvx82ys	\\x00b696cee93e389801962b07d9baae2fe01c038955aaf93ebdfb15bd81b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xb696cee93e389801962b07d9baae2fe01c038955aaf93ebdfb15bd81	61	3000000	\N	\N	\N
244	141	18	addr_test1qpmv0d8uemjsdsedkqxglv8e3u0n0grk0mmahuyplatl0v9k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqnc2gpq	\\x0076c7b4fccee506c32db00c8fb0f98f1f37a0767ef7dbf081ff57f7b0b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x76c7b4fccee506c32db00c8fb0f98f1f37a0767ef7dbf081ff57f7b0	61	3000000	\N	\N	\N
245	141	19	addr_test1qz52p2f250s6hywy5cfkmdxv77pe0ks7z5ys25we6fu2hm9k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqzlytxn	\\x00a8a0a92aa3e1ab91c4a6136db4ccf78397da1e15090551d9d278abecb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xa8a0a92aa3e1ab91c4a6136db4ccf78397da1e15090551d9d278abec	61	3000000	\N	\N	\N
246	141	20	addr_test1qqyqnmhhk0svqa2npeg843cy8cvyv6sw607ckt0wzfxn429k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqy8vz5z	\\x000809eef7b3e0c075530e507ac7043e18466a0ed3fd8b2dee124d3aa8b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x0809eef7b3e0c075530e507ac7043e18466a0ed3fd8b2dee124d3aa8	61	3000000	\N	\N	\N
247	141	21	addr_test1qrjfatd4gupcadv8v3vlvp3s8eyvmm4nhjjz08l9h3n4yddk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqvtzspg	\\x00e49eadb547038eb5876459f606303e48cdeeb3bca4279fe5bc675235b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xe49eadb547038eb5876459f606303e48cdeeb3bca4279fe5bc675235	61	3000000	\N	\N	\N
248	141	22	addr_test1qq8tt358a9xpve6mu22c5djs4l6cu5sh8s0ed59r5rzxgf4k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq9m83u6	\\x000eb5c687e94c16675be2958a3650aff58e52173c1f96d0a3a0c46426b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x0eb5c687e94c16675be2958a3650aff58e52173c1f96d0a3a0c46426	61	3000000	\N	\N	\N
249	141	23	addr_test1qr0wm8d6waurzyma5rvvxswx8lz5ek4e5v6mlna83ktwz9dk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq3wt4tf	\\x00deed9dba777831137da0d8c341c63fc54cdab9a335bfcfa78d96e115b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xdeed9dba777831137da0d8c341c63fc54cdab9a335bfcfa78d96e115	61	3000000	\N	\N	\N
250	141	24	addr_test1qq2lqg72p8l0ychzpelc3w3t65jdz9uykzujdqyus0xmg3dk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jql4tep3	\\x0015f023ca09fef262e20e7f88ba2bd524d11784b0b926809c83cdb445b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x15f023ca09fef262e20e7f88ba2bd524d11784b0b926809c83cdb445	61	3000000	\N	\N	\N
251	141	25	addr_test1qr6jdl63se52xupdwe3vwmtpq2kddzwpfqm499thgkxrymdk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqnzmkj8	\\x00f526ff518668a3702d7662c76d6102acd689c14837529577458c326db6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xf526ff518668a3702d7662c76d6102acd689c14837529577458c326d	61	3000000	\N	\N	\N
252	141	26	addr_test1qzgeuchac0am3yeuyrsqpkjtcxlcnje5yshv3440rfkyw7ak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqfjl3tq	\\x00919e62fdc3fbb8933c20e000da4bc1bf89cb34242ec8d6af1a6c477bb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x919e62fdc3fbb8933c20e000da4bc1bf89cb34242ec8d6af1a6c477b	61	3000000	\N	\N	\N
253	141	27	addr_test1qqj4dt9xc74v79t20a365v2cnzykapujzwa3sz87zwjrt3dk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq9jquz5	\\x002556aca6c7aacf156a7f63aa315898896e879213bb1808fe13a435c5b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x2556aca6c7aacf156a7f63aa315898896e879213bb1808fe13a435c5	61	3000000	\N	\N	\N
254	141	28	addr_test1qpms64m6s2luwe2csux7sd0lcnhr0pj9tl773smszw7cyrdk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq8v9nmz	\\x00770d577a82bfc76558870de835ffc4ee3786455ffde8c37013bd820db6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x770d577a82bfc76558870de835ffc4ee3786455ffde8c37013bd820d	61	3000000	\N	\N	\N
255	141	29	addr_test1qzpfacy6ta7lyxs6w6wx2yj2s34xc3zeedaryln9zd26h69k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq43l9ed	\\x00829ee09a5f7df21a1a769c65124a846a6c4459cb7a327e651355abe8b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x829ee09a5f7df21a1a769c65124a846a6c4459cb7a327e651355abe8	61	3000000	\N	\N	\N
256	141	30	addr_test1qq5vz22z2me00f5kkjsq2ztu6wped0jnun37vdhepuk9cldk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq4xx53n	\\x0028c1294256f2f7a696b4a005097cd38396be53e4e3e636f90f2c5c7db6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x28c1294256f2f7a696b4a005097cd38396be53e4e3e636f90f2c5c7d	61	3000000	\N	\N	\N
257	141	31	addr_test1qquleh7neldvfmje50tp6scx5egtgd2neagq9uxz5t9p2u9k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq0rw5a5	\\x0039fcdfd3cfdac4ee59a3d61d4306a650b43553cf5002f0c2a2ca1570b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x39fcdfd3cfdac4ee59a3d61d4306a650b43553cf5002f0c2a2ca1570	61	3000000	\N	\N	\N
258	141	32	addr_test1qzddc6ed6kvw668u759jnj48j6vf6kwgyw852n6q35svhkak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq64ccfh	\\x009adc6b2dd598ed68fcf50b29caa796989d59c8238f454f408d20cbdbb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x9adc6b2dd598ed68fcf50b29caa796989d59c8238f454f408d20cbdb	61	3000000	\N	\N	\N
259	141	33	addr_test1qr8vyckr365hm222ev52n46ckz4drlfedfdp09qaxxvvjedk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqmw80t9	\\x00cec262c38ea97da94acb28a9d758b0aad1fd396a5a17941d3198c965b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xcec262c38ea97da94acb28a9d758b0aad1fd396a5a17941d3198c965	61	3000000	\N	\N	\N
260	141	34	addr_test1qqm4zp3fg0qwz93nczqlcear9kvsccef68s5n97uzlhsxudk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqx7eg3x	\\x003751062943c0e11633c081fc67a32d990c6329d1e14997dc17ef0371b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x3751062943c0e11633c081fc67a32d990c6329d1e14997dc17ef0371	61	3000000	\N	\N	\N
261	141	35	addr_test1qz9srs7m9ec2yxt47f2wtcfuwlnxdvgd0jnunqnqkj98434k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqnef6e2	\\x008b01c3db2e70a21975f254e5e13c77e666b10d7ca7c98260b48a7ac6b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x8b01c3db2e70a21975f254e5e13c77e666b10d7ca7c98260b48a7ac6	61	3000000	\N	\N	\N
262	141	36	addr_test1qqnrwauj9cm0rey9jz6dat700kqzrezp6nnnlyxrx0uh73dk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq25pgu5	\\x00263777922e36f1e48590b4deafcf7d8021e441d4e73f90c333f97f45b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x263777922e36f1e48590b4deafcf7d8021e441d4e73f90c333f97f45	61	3000000	\N	\N	\N
263	141	37	addr_test1qpwge3vrtwdumg3u0yxc94vtu6eje0876nhe727s2zhff89k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqkq93yc	\\x005c8cc5835b9bcda23c790d82d58be6b32cbcfed4ef9f2bd050ae949cb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x5c8cc5835b9bcda23c790d82d58be6b32cbcfed4ef9f2bd050ae949c	61	3000000	\N	\N	\N
264	141	38	addr_test1qrfdf930a4z77e5zeshyky8wky3zhsxs8vn55mjvrwp8dwak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqk0esvv	\\x00d2d4962fed45ef6682cc2e4b10eeb1222bc0d03b274a6e4c1b8276bbb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xd2d4962fed45ef6682cc2e4b10eeb1222bc0d03b274a6e4c1b8276bb	61	3000000	\N	\N	\N
265	141	39	addr_test1qqandkrpejhanzn6mtesw7c9dnqv6zkxnrkg8eucffdek7dk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq8ux2em	\\x003b36d861ccafd98a7adaf3077b056cc0cd0ac698ec83e7984a5b9b79b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x3b36d861ccafd98a7adaf3077b056cc0cd0ac698ec83e7984a5b9b79	61	3000000	\N	\N	\N
266	141	40	addr_test1qqkp8tstjhgzkxdnxpv040dd478jfwundakj4n8ky9cs42ak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqqcuqrd	\\x002c13ae0b95d02b19b33058fabdadaf8f24bb936f6d2accf621710aabb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x2c13ae0b95d02b19b33058fabdadaf8f24bb936f6d2accf621710aab	61	3000000	\N	\N	\N
267	141	41	addr_test1qr5e6frj0uv9wufw0pvyrxy88ek420t6xazfk0q8rsevpedk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqlmw2w2	\\x00e99d24727f1857712e78584198873e6d553d7a37449b3c071c32c0e5b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xe99d24727f1857712e78584198873e6d553d7a37449b3c071c32c0e5	61	3000000	\N	\N	\N
268	141	42	addr_test1qpwhu2qxghzh4tfk6vdfuglhqtqgwjyed7zqrz4srd7v5c9k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqf26ge2	\\x005d7e280645c57aad36d31a9e23f702c08748996f84018ab01b7cca60b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x5d7e280645c57aad36d31a9e23f702c08748996f84018ab01b7cca60	61	3000000	\N	\N	\N
269	141	43	addr_test1qpcka749yvdyy4fqj883lunjzd6vl2grxuxy32krxfxy47ak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqww2jn4	\\x00716efaa5231a42552091cf1ff2721374cfa903370c48aac3324c4afbb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x716efaa5231a42552091cf1ff2721374cfa903370c48aac3324c4afb	61	3000000	\N	\N	\N
270	141	44	addr_test1qzqmm2lnlv6trkezw7l6kx5rl45dqf2nq7umu5cdq7jznh4k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqksrvvc	\\x0081bdabf3fb34b1db2277bfab1a83fd68d0255307b9be530d07a429deb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x81bdabf3fb34b1db2277bfab1a83fd68d0255307b9be530d07a429de	61	3000000	\N	\N	\N
271	141	45	addr_test1qzsj5vn6mmmt8msv3l8hlkj2fckhrz435zdca50fmmlwv09k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqgap58q	\\x00a12a327adef6b3ee0c8fcf7fda4a4e2d718ab1a09b8ed1e9defee63cb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xa12a327adef6b3ee0c8fcf7fda4a4e2d718ab1a09b8ed1e9defee63c	61	3000000	\N	\N	\N
272	141	46	addr_test1qq52w95jxv3m7jcdjr6rnhmgq6d6cd3yjepjgmy5vrm42u4k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqtnecxx	\\x0028a716923323bf4b0d90f439df68069bac36249643246c9460f75572b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x28a716923323bf4b0d90f439df68069bac36249643246c9460f75572	61	3000000	\N	\N	\N
273	141	47	addr_test1qzujegsmhy84hjwagvh7fz24uwqkxl3t587yjnmth0en9tak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqzjxf2l	\\x00b92ca21bb90f5bc9dd432fe48955e381637e2ba1fc494f6bbbf332afb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xb92ca21bb90f5bc9dd432fe48955e381637e2ba1fc494f6bbbf332af	61	3000000	\N	\N	\N
274	141	48	addr_test1qpgx5whzdfn83a5mg476uf38qqphlnkxe5ht0ha7ue7dp54k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqwppmcu	\\x00506a3ae26a6678f69b457dae262700037fcec6cd2eb7dfbee67cd0d2b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x506a3ae26a6678f69b457dae262700037fcec6cd2eb7dfbee67cd0d2	61	3000000	\N	\N	\N
275	141	49	addr_test1qzph2zjvexgwn7jj2vw4nxusekpss56vxwtrhn8rkg2q4fdk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqrtw7wa	\\x0083750a4cc990e9fa52531d599b90cd8308534c33963bcce3b2140aa5b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x83750a4cc990e9fa52531d599b90cd8308534c33963bcce3b2140aa5	61	3000000	\N	\N	\N
276	141	50	addr_test1qp44c7fw5ju6urp3nxz9hjdn6ewyzde6h3qynqeukme5ag9k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq2ljd7v	\\x006b5c792ea4b9ae0c3199845bc9b3d65c41373abc4049833cb6f34ea0b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x6b5c792ea4b9ae0c3199845bc9b3d65c41373abc4049833cb6f34ea0	61	3000000	\N	\N	\N
277	141	51	addr_test1qpq9lr30qwsm07wm7vwzp34zdy5xgp4fm54kazcdk6g84h9k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq2yg4sh	\\x00405f8e2f03a1b7f9dbf31c20c6a269286406a9dd2b6e8b0db6907adcb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x405f8e2f03a1b7f9dbf31c20c6a269286406a9dd2b6e8b0db6907adc	61	3000000	\N	\N	\N
278	141	52	addr_test1qr35ku7m52x6dm4kkpv0gwua958yfs630mhyhym6fjy72zdk4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqnxhsrz	\\x00e34b73dba28da6eeb6b058f43b9d2d0e44c3517eee4b937a4c89e509b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xe34b73dba28da6eeb6b058f43b9d2d0e44c3517eee4b937a4c89e509	61	3000000	\N	\N	\N
279	141	53	addr_test1qqt3v792fg222kxa06vw39g0dmwuws77nsnvldtsezxnaj4k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq8lny4n	\\x00171678aa4a14a558dd7e98e8950f6eddc743de9c26cfb570c88d3ecab6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x171678aa4a14a558dd7e98e8950f6eddc743de9c26cfb570c88d3eca	61	3000000	\N	\N	\N
280	141	54	addr_test1qzr74rmthh00zfxpr4mdkf82atnmjq7my39280mx6cgxfn9k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqw65dum	\\x0087ea8f6bbddef124c11d76db24eaeae7b903db244aa3bf66d61064ccb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x87ea8f6bbddef124c11d76db24eaeae7b903db244aa3bf66d61064cc	61	3000000	\N	\N	\N
281	141	55	addr_test1qre5cz9duahal6fj6d2u88ka5987hjcpuunmrzaus22t4jak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqev6gy9	\\x00f34c08ade76fdfe932d355c39edda14febcb01e727b18bbc8294bacbb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\xf34c08ade76fdfe932d355c39edda14febcb01e727b18bbc8294bacb	61	3000000	\N	\N	\N
282	141	56	addr_test1qzqhdahl0yqzgdvwd6nhdgwwtj49lp20tlugu9cn36s84fak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqfwxj4u	\\x008176f6ff790024358e6ea776a1ce5caa5f854f5ff88e17138ea07aa7b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x8176f6ff790024358e6ea776a1ce5caa5f854f5ff88e17138ea07aa7	61	3000000	\N	\N	\N
283	141	57	addr_test1qqnl765vfyvfglnhdgm80zkqj39w97927vuxg73hnpjf049k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqz3s7uq	\\x0027ff6a8c4918947e776a36778ac0944ae2f8aaf338647a37986497d4b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x27ff6a8c4918947e776a36778ac0944ae2f8aaf338647a37986497d4	61	3000000	\N	\N	\N
284	141	58	addr_test1qq4zsxtkppac38jfa6x4xvn54hmdepzft0wd3f92erqn5r4k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq92myc3	\\x002a281976087b889e49ee8d533274adf6dc84495bdcd8a4aac8c13a0eb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x2a281976087b889e49ee8d533274adf6dc84495bdcd8a4aac8c13a0e	61	3000000	\N	\N	\N
285	141	59	addr_test1qq0fxs8wqw5mnpvw0yetmczsgzdv4szuvut22sv26wpfj7ak4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jqpmtw6e	\\x001e9340ee03a9b9858e7932bde050409acac05c6716a5418ad382997bb6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x1e9340ee03a9b9858e7932bde050409acac05c6716a5418ad382997b	61	3000000	\N	\N	\N
286	141	60	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	97414736750	\N	\N	\N
287	141	61	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
288	141	62	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
289	141	63	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
290	141	64	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
291	141	65	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
292	141	66	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
293	141	67	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
294	141	68	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
295	141	69	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
296	141	70	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
297	141	71	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
298	141	72	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
299	141	73	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
300	141	74	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
301	141	75	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
302	141	76	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
303	141	77	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
304	141	78	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
305	141	79	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
306	141	80	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
307	141	81	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
308	141	82	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
309	141	83	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
310	141	84	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
311	141	85	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
312	141	86	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
313	141	87	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
314	141	88	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
315	141	89	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
316	141	90	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
317	141	91	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
318	141	92	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
319	141	93	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
320	141	94	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
321	141	95	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
322	141	96	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
323	141	97	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
324	141	98	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
325	141	99	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
326	141	100	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
327	141	101	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
328	141	102	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
329	141	103	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
330	141	104	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
331	141	105	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
332	141	106	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
333	141	107	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
334	141	108	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
335	141	109	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
336	141	110	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
337	141	111	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
338	141	112	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
339	141	113	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
340	141	114	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
341	141	115	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
342	141	116	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
343	141	117	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
344	141	118	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
345	141	119	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073555082	\N	\N	\N
346	142	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	178500000	\N	\N	\N
347	142	1	addr_test1qpng86sk8q0kpawqht9ekv8pcmldqzk6cgr8qv64xgerr29k4jw38076qndmp7sllp36fes79uqhqywn3z8jn84230jq2s3e9k	\\x006683ea16381f60f5c0bacb9b30e1c6fed00adac206703355323231a8b6ac9d13bfda04dbb0fa1ff863a4e61e2f017011d3888f299eaa8be4	f	\\x6683ea16381f60f5c0bacb9b30e1c6fed00adac206703355323231a8	61	974447	\N	\N	\N
352	145	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999359791952	\N	\N	\N
353	145	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999572928331	\N	\N	\N
354	146	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999359791952	\N	\N	\N
355	146	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999572758166	\N	\N	\N
356	147	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	969750	\N	\N	\N
357	147	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999358651949	\N	\N	\N
358	148	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	1000000	\N	\N	\N
359	148	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999571575813	\N	\N	\N
360	149	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999572372406	\N	\N	\N
361	150	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
362	150	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999567204001	\N	\N	\N
363	152	0	5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg	\\x82d818582683581c599d72b5e3f5a40fb4c4eb809e904d101f908a419472f542bc7032b9a10243190378001a2a94baa3	f	\N	\N	3000000	\N	\N	\N
364	152	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999564035992	\N	\N	\N
365	153	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
366	153	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999348483544	\N	\N	\N
367	154	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999563855619	\N	\N	\N
368	155	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
369	155	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999558687214	\N	\N	\N
370	156	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
371	156	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999558517225	\N	\N	\N
372	157	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
373	157	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4831771	\N	\N	\N
374	158	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
375	158	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
376	159	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
377	159	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999553348820	\N	\N	\N
378	160	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
379	160	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999553009018	\N	\N	\N
380	161	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
381	161	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4661958	\N	\N	\N
382	162	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
383	162	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999547840613	\N	\N	\N
384	163	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
385	163	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
386	164	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
387	164	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
388	165	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
389	165	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4492145	\N	\N	\N
390	166	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
391	166	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
392	167	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
393	167	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
394	168	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
395	168	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999343315139	\N	\N	\N
396	169	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
397	169	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3812893	\N	\N	\N
398	170	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
399	170	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999547670624	\N	\N	\N
400	171	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
401	171	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999542502219	\N	\N	\N
402	172	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
403	172	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999338146734	\N	\N	\N
404	173	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
405	173	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
406	174	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
407	174	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
408	175	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
409	175	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3473267	\N	\N	\N
410	176	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
411	176	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999537333814	\N	\N	\N
412	177	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
413	177	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999336450012	\N	\N	\N
414	178	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
415	178	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
416	179	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
417	179	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
418	180	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
419	180	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
420	181	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
421	181	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
422	182	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
423	182	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
424	183	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
425	183	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999331281607	\N	\N	\N
426	184	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
427	184	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
428	185	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
429	185	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
430	186	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
431	186	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
432	187	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
433	187	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
434	188	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
435	188	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999326113202	\N	\N	\N
436	189	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
437	189	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4150935	\N	\N	\N
438	190	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
439	190	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3981122	\N	\N	\N
440	191	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
441	191	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
442	192	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
443	192	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
444	193	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
445	193	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3811309	\N	\N	\N
446	194	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
447	194	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
448	195	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
449	195	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
450	196	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
451	196	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999532165409	\N	\N	\N
452	197	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
453	197	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999320944797	\N	\N	\N
454	198	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
455	198	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
456	199	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
457	199	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
458	200	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
459	200	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4150935	\N	\N	\N
460	201	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
461	201	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3981122	\N	\N	\N
462	202	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
463	202	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999526997004	\N	\N	\N
464	203	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
465	203	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4150935	\N	\N	\N
466	204	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
467	204	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
468	205	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
469	205	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999521828599	\N	\N	\N
470	206	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
471	206	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2962244	\N	\N	\N
472	207	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
473	207	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999520809545	\N	\N	\N
474	208	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
475	208	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
476	209	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
477	209	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
478	210	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
479	210	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999315776392	\N	\N	\N
480	211	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
481	211	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
482	212	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
483	212	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
484	213	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
485	213	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
486	214	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
487	214	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
488	215	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
489	215	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
490	216	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
491	216	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
492	217	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
493	217	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
494	218	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
495	218	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
496	219	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
497	219	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
498	220	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
499	220	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
500	221	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
501	221	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
502	222	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
503	222	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
504	223	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
505	223	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
506	224	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
507	224	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3981122	\N	\N	\N
508	225	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
509	225	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999520299930	\N	\N	\N
510	226	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
511	226	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3811309	\N	\N	\N
512	227	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
513	227	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1603740	\N	\N	\N
514	228	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
515	228	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1433927	\N	\N	\N
516	229	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
517	229	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
518	230	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
519	230	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
520	231	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
521	231	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
522	232	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
523	232	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
524	233	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
525	233	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999314927151	\N	\N	\N
526	234	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
527	234	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
528	235	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
529	235	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	6262530	\N	\N	\N
530	236	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
531	236	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
532	237	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
533	237	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
534	238	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
535	238	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
536	239	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
537	239	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4150935	\N	\N	\N
538	240	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
539	240	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3981122	\N	\N	\N
540	241	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
541	241	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
542	242	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
543	242	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
544	243	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
545	243	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
546	244	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
547	244	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2622618	\N	\N	\N
548	245	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
549	245	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4150935	\N	\N	\N
550	246	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
551	246	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	7281408	\N	\N	\N
552	247	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
553	247	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5753091	\N	\N	\N
554	248	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
555	248	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
556	249	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
557	249	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999515131525	\N	\N	\N
558	250	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
559	250	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5583278	\N	\N	\N
560	251	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
561	251	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999309758746	\N	\N	\N
562	252	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
563	252	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
564	253	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
565	253	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	7111595	\N	\N	\N
566	254	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
567	254	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5413465	\N	\N	\N
568	255	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
569	255	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10590556195	\N	\N	\N
570	256	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1252373732186	\N	\N	\N
571	256	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	1252373983443	\N	\N	\N
572	256	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	626186991721	\N	\N	\N
573	256	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	626186991721	\N	\N	\N
574	256	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	313093495861	\N	\N	\N
575	256	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	313093495861	\N	\N	\N
576	256	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156546747930	\N	\N	\N
577	256	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	156546747930	\N	\N	\N
578	256	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78273373965	\N	\N	\N
579	256	9	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	78273373965	\N	\N	\N
580	256	10	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39136686983	\N	\N	\N
581	256	11	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39136686983	\N	\N	\N
582	256	12	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39136686982	\N	\N	\N
583	256	13	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39136686982	\N	\N	\N
584	257	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
585	257	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1266947604614	\N	\N	\N
586	258	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
587	258	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39131518577	\N	\N	\N
588	259	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
589	259	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39131518578	\N	\N	\N
590	260	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
591	260	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39126350172	\N	\N	\N
592	261	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
593	261	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	1252368815038	\N	\N	\N
594	262	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
595	262	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	78268205560	\N	\N	\N
596	263	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
597	263	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156541579525	\N	\N	\N
598	264	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
599	264	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
600	265	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
601	265	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156536411120	\N	\N	\N
602	266	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
603	266	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
604	267	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
605	267	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	626186651919	\N	\N	\N
606	268	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
607	268	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	313088327456	\N	\N	\N
608	269	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
609	269	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	313093325872	\N	\N	\N
610	270	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
611	270	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78273203976	\N	\N	\N
612	271	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
613	271	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39126350173	\N	\N	\N
614	272	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
615	272	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	313088157467	\N	\N	\N
616	273	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
617	273	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	626181483514	\N	\N	\N
618	274	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
619	274	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	156541579525	\N	\N	\N
620	275	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
621	275	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39126010370	\N	\N	\N
622	276	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
623	276	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156531242715	\N	\N	\N
624	277	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
625	277	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39131518578	\N	\N	\N
626	278	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
627	278	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	1252363646633	\N	\N	\N
628	279	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
629	279	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
630	280	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
631	280	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39131518577	\N	\N	\N
632	281	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
633	281	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
634	282	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
635	282	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	1252358478228	\N	\N	\N
636	283	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
637	283	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156526074310	\N	\N	\N
638	284	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
639	284	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39131348588	\N	\N	\N
640	285	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
641	285	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156520905905	\N	\N	\N
642	286	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
643	286	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	313083159051	\N	\N	\N
644	287	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
645	287	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	626176315109	\N	\N	\N
646	288	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
647	288	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39126350173	\N	\N	\N
648	289	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
649	289	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	1252353309823	\N	\N	\N
650	290	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
651	290	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	626186651919	\N	\N	\N
652	291	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
653	291	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39121181768	\N	\N	\N
654	292	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
655	292	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39120841965	\N	\N	\N
656	293	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
657	293	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78268035571	\N	\N	\N
658	294	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
659	294	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
660	295	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
661	295	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
662	296	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
663	296	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
664	297	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
665	297	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	626181483514	\N	\N	\N
666	298	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
667	298	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	626176145120	\N	\N	\N
668	299	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
669	299	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
670	300	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
671	300	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
672	301	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
673	301	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4490561	\N	\N	\N
674	302	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
675	302	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
676	303	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
677	303	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
678	304	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
679	304	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39126180183	\N	\N	\N
680	305	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
681	305	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156515737500	\N	\N	\N
682	306	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
683	306	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39115673560	\N	\N	\N
684	307	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
685	307	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
686	308	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
687	308	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
688	309	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
689	309	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
690	310	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
691	310	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	156536411120	\N	\N	\N
692	311	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
693	311	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
694	312	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
695	312	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	313077990646	\N	\N	\N
696	313	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
697	313	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39110505155	\N	\N	\N
698	314	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
699	314	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
700	315	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
701	315	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
702	316	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
703	316	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4320748	\N	\N	\N
704	317	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
705	317	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	626170976715	\N	\N	\N
706	318	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
707	318	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39105336750	\N	\N	\N
708	319	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
709	319	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39121011778	\N	\N	\N
710	320	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
711	320	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	313072822241	\N	\N	\N
712	321	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
713	321	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
714	322	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
715	322	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	626170127474	\N	\N	\N
716	323	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
717	323	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39121011779	\N	\N	\N
718	324	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
719	324	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4490561	\N	\N	\N
720	325	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
721	325	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
722	326	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
723	326	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
724	327	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
725	327	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
726	328	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
727	328	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	626164959069	\N	\N	\N
728	329	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
729	329	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
730	330	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
731	330	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	626176315109	\N	\N	\N
732	331	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
733	331	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
734	332	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
735	332	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156510569095	\N	\N	\N
736	333	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
737	333	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39115843374	\N	\N	\N
738	334	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
739	334	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
740	335	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
741	335	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4490561	\N	\N	\N
742	336	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
743	336	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
744	337	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
745	337	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
746	338	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
747	338	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
748	339	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
749	339	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	156531242715	\N	\N	\N
750	340	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
751	340	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39110674969	\N	\N	\N
752	341	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
753	341	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
754	342	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
755	342	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39125670745	\N	\N	\N
756	343	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
757	343	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	78263037155	\N	\N	\N
758	344	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
759	344	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
760	345	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
761	345	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
762	346	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
763	346	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39104827135	\N	\N	\N
764	347	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
765	347	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
766	348	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
767	348	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4150935	\N	\N	\N
768	349	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
769	349	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39115843373	\N	\N	\N
770	350	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
771	350	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39110674968	\N	\N	\N
772	351	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
773	351	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
774	352	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
775	352	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
776	353	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
777	353	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	78262697353	\N	\N	\N
778	354	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
779	354	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	626159790664	\N	\N	\N
780	355	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
781	355	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
782	356	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
783	356	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
784	357	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
785	357	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1282234485771	\N	\N	\N
786	358	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	5	\N
787	358	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	9590766	\N	\N	\N
788	359	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
789	359	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999996820111	\N	\N	\N
790	360	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
791	360	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999993650122	\N	\N	\N
792	361	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
793	361	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999990474369	\N	\N	\N
794	362	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
795	362	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	6816723	\N	\N	\N
796	363	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
797	363	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	4999999828427	\N	\N	\N
798	364	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
799	364	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	6821255	\N	\N	\N
\.


--
-- Data for Name: withdrawal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.withdrawal (id, addr_id, amount, redeemer_id, tx_id) FROM stdin;
1	46	10590730892	\N	255
2	46	14579047125	\N	257
3	64	2415805054	\N	357
4	46	12876256828	\N	357
\.


--
-- Name: ada_pots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ada_pots_id_seq', 13, true);


--
-- Name: block_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.block_id_seq', 1426, true);


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

SELECT pg_catalog.setval('public.epoch_stake_id_seq', 295, true);


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

SELECT pg_catalog.setval('public.ma_tx_mint_id_seq', 42, true);


--
-- Name: ma_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_out_id_seq', 44, true);


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

SELECT pg_catalog.setval('public.reverse_index_id_seq', 1424, true);


--
-- Name: reward_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reward_id_seq', 233, true);


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

SELECT pg_catalog.setval('public.slot_leader_id_seq', 1426, true);


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

SELECT pg_catalog.setval('public.tx_id_seq', 364, true);


--
-- Name: tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_in_id_seq', 720, true);


--
-- Name: tx_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_metadata_id_seq', 17, true);


--
-- Name: tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_out_id_seq', 799, true);


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

