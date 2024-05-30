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
1	1009	1	0	8999989979999988	0	81000009984123481	5544000000	13876531	114
2	2007	2	89999901187652	8909990092688867	0	81000009979406036	5544000000	4717445	218
3	3020	3	179099802586285	8732681293623049	88208902384630	81000009971824061	5544000000	7581975	334
4	4003	4	266426616280712	8558900941682441	174662448212786	81000009957799363	5556000000	2024698	436
6	5004	5	351159735805837	8413159979188979	235671293205821	81000009957799363	4556000000	0	556
7	6013	6	435291335597726	8266756097127859	297943575475052	81000009940898495	4556000000	16900868	663
8	7010	7	517958898259091	8130813907770652	351218219071762	81000009940898495	4556000000	0	754
9	8006	8	591136223429026	8003748228445945	405101276120920	81000015235406335	4558000000	597774	837
10	9001	9	657567333784904	7896520010540859	445898384267902	81000015235406335	4558000000	0	941
11	10012	10	736532533890312	7771662086541545	491771474002367	81000034852629576	4558000000	16936200	1039
12	11022	11	811140491614730	7648666752907226	540158866848468	81000034852629576	4558000000	0	1136
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (id, hash, epoch_no, slot_no, epoch_slot_no, block_no, previous_id, slot_leader_id, size, "time", tx_count, proto_major, proto_minor, vrf_key, op_cert, op_cert_counter) FROM stdin;
1	\\xc6dc872e263ad46c600af1bb710e3607de0e7ec8f184a8717e16e6f39253c70a	\N	\N	\N	\N	\N	1	0	2024-05-28 13:56:15	11	0	0	\N	\N	\N
2	\\x5368656c6c65792047656e6573697320426c6f636b2048617368200000000000	\N	\N	\N	\N	1	2	0	2024-05-28 13:56:15	23	0	0	\N	\N	\N
3	\\x6aea488afdb7a24f9ed0ab3ccc1e348ec2afa737c9f604baa4e1294f6402a36f	0	48	48	0	1	3	2875	2024-05-28 13:56:24.6	11	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
4	\\xe96230e6548ba12e9576807274b7e98b165d63230162eaf1fb7f2ebc8de1c06c	0	49	49	1	3	4	4	2024-05-28 13:56:24.8	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
5	\\xf080cbe76e360ebdf99801bc8f64c598e909559adc85723e3879a228592971d3	0	63	63	2	4	5	3711	2024-05-28 13:56:27.6	11	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
6	\\xa8493c6a38fad0b6951d5dc6a84eb1a7b4e52332b33e1fbf964cc2a98c450a2a	0	65	65	3	5	6	4	2024-05-28 13:56:28	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
7	\\xb28d11fc839fd350686fe0ee8a309ca6ae27c48745dcb6e99d6b55539d044aa3	0	71	71	4	6	7	4	2024-05-28 13:56:29.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
8	\\x6a46a8daa5917a9df116a10fbe3c6984e71e2a6646620883032052d2e1dacf02	0	76	76	5	7	8	4041	2024-05-28 13:56:30.2	11	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
9	\\x521648e13ad429151fd1ed39496221bf983ca6db2f3865b2dcfa152583a52157	0	77	77	6	8	6	4	2024-05-28 13:56:30.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
10	\\x251b0594d38102ae9ea9c9649aaf4657e0cc08df7c51ff1efda9a26e2f3c0c29	0	79	79	7	9	10	4	2024-05-28 13:56:30.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
12	\\x953456cdb30ca03dc9b6b811739717b8b6ff088a2e6edad37c22a78d6cfeec82	0	91	91	8	10	7	4349	2024-05-28 13:56:33.2	11	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
13	\\xb51da2310cbfffeb2d23134f79989b444548319f03d3e1fc776967538dad7357	0	120	120	9	12	3	6978	2024-05-28 13:56:39	11	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
14	\\x06e9efa3239db047e4ac81d83e0790a55fef206a4352c93f2ff70d8b6449c2c7	0	123	123	10	13	10	4	2024-05-28 13:56:39.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
15	\\x0a313279f798f6f62022f990dfd66f9897e60b23c72c8a916625f8b4235bd029	0	124	124	11	14	15	4	2024-05-28 13:56:39.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
16	\\x02a431808c059fb0decda416e4dbdbc756ac3689e9f38c7a512b6a390ed86615	0	133	133	12	15	8	1584	2024-05-28 13:56:41.6	4	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
17	\\xc229e64b2550e4309fa6766ec3da7154bc23ccb9283d734e1a764804aa449994	0	152	152	13	16	15	1752	2024-05-28 13:56:45.4	4	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
18	\\x0fedd51bf4ae7b131e784936467ad81f9a25b1290b2aa06616059f0c277b605f	0	153	153	14	17	3	4	2024-05-28 13:56:45.6	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
19	\\xd4edc98cebf3c52660fe876721b8e0df2f70fb54bd9ced0f00035f32ac32de61	0	186	186	15	18	19	274	2024-05-28 13:56:52.2	1	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
20	\\x89abbb1206e350141728f8ae7e6376e3e7dce8d743328f3a6a49a33952446a47	0	202	202	16	19	3	352	2024-05-28 13:56:55.4	1	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
21	\\xcf8269e9d21673604840895d88e6131d13b1eb958ae9060333c1cb2c19308efc	0	204	204	17	20	7	4	2024-05-28 13:56:55.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
22	\\xeba894d1284d12aa40828e19ebc4f93a4d34f90b22bfae7bc12358494639638c	0	206	206	18	21	5	4	2024-05-28 13:56:56.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
23	\\x65b86d81fa3651cb0741b5885eb139ccce5cbff1cdd41d059bb1cc31e26c67b1	0	217	217	19	22	23	245	2024-05-28 13:56:58.4	1	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
24	\\x622020c926e0fa50b4f721f9e5b3f8dc5c30dd7f32151617b6efb4028dca88af	0	232	232	20	23	8	343	2024-05-28 13:57:01.4	1	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
25	\\x41d694d2bfcd948d7564b95a20c82eb37cdd72c251e1bef802e1e1dd32d60d44	0	240	240	21	24	4	284	2024-05-28 13:57:03	1	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
26	\\x5853f981b3a9e028e484719fe484bb2ca535dc334969775796c4e405e1964e44	0	260	260	22	25	19	258	2024-05-28 13:57:07	1	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
27	\\x926ab8863599cfa6ba28ce98d424ade65c02e4fa4bae8480c4c4e8312f7bb388	0	273	273	23	26	23	2445	2024-05-28 13:57:09.6	1	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
28	\\x71203a3dc74078580173126e91323aa3224a54221062f1a46e1c69f385fba056	0	280	280	24	27	28	4	2024-05-28 13:57:11	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
29	\\x03067780c397da7c2a27bf54b5d2486b553da218590cbc33f5e1a9bb04608729	0	283	283	25	28	6	4	2024-05-28 13:57:11.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
30	\\xec1dc21b5d3bd4e901cb98271db98f8b2d199511103c77e695e0ecdfd30c7a53	0	310	310	26	29	15	246	2024-05-28 13:57:17	1	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
31	\\x43cb16bdae5c18dc050daff0ac91ad5ac41b9a721e2bff9d96808ac072cef269	0	314	314	27	30	4	4	2024-05-28 13:57:17.8	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
32	\\xfae7062af7c06a76bdfe5114b327026c92857302f0d1845ca120ac83d9488a00	0	327	327	28	31	4	2615	2024-05-28 13:57:20.4	1	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
33	\\x3140f7f259ccb524f12f3b704937ee98cbdb5f4cecfb76a96856ddb3030eb87b	0	334	334	29	32	5	4	2024-05-28 13:57:21.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
34	\\x82d3a35a9f1ed137d1a7cb2bc35972e542689ed11d835be556d8b9ca782e176c	0	349	349	30	33	28	469	2024-05-28 13:57:24.8	1	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
35	\\x173d15042543f44db98e6afed7619cf355fc61e0feb201f2478dc46f4aa754ad	0	350	350	31	34	3	4	2024-05-28 13:57:25	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
36	\\xffa77045530f537cf0a85c98fee752848dc25c2bcdfa9741825fe5c796e16e75	0	353	353	32	35	7	4	2024-05-28 13:57:25.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
37	\\xebae3261a71b85e45167c99cce7f551dec3b3f5b80d39209feb6eb31a87a6360	0	356	356	33	36	3	553	2024-05-28 13:57:26.2	1	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
38	\\xf84ff2ee12e873d69b1e2fe8ada97c75479b4e016de7f579ebad77404d7f5470	0	359	359	34	37	28	4	2024-05-28 13:57:26.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
39	\\xb95c87b03f9ac862ae33234eeb8d4c70a2cf44c85bce8119f595c83c39b7c1b1	0	365	365	35	38	6	1755	2024-05-28 13:57:28	1	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
40	\\xe57334e1278328a56336d27769dfdac7ae600e2d00f4329e8a976ce90d6d6c6a	0	395	395	36	39	7	671	2024-05-28 13:57:34	1	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
41	\\x25fc24e052ef3b5ba421196ec865da1c574da917fba3af23c35656195e356544	0	416	416	37	40	15	4	2024-05-28 13:57:38.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
42	\\x9113f7b56c07a76f75cfb708901e4099e24e73ab417e21ac561fd0fd1859fedf	0	419	419	38	41	19	4	2024-05-28 13:57:38.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
43	\\xdd15e9f47160f4768d14e579d3e42cff6bac2fe5e5b28a286f856ddbf8e0a60b	0	424	424	39	42	10	4	2024-05-28 13:57:39.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
44	\\xdb1159832ee81af9df54cee46885ce7f5a13d191ed717d1413d206c5d00ec552	0	433	433	40	43	5	4	2024-05-28 13:57:41.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
45	\\x0dccbbaae00761f516c4823a3a1ca5646fd0f4de421d89b76f65e703741cedc5	0	445	445	41	44	19	4	2024-05-28 13:57:44	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
46	\\x27c6e0a07e9967630814afcc1d6b84d3a7cb7dec1457b5ae67fdf324bf7b8e92	0	469	469	42	45	23	4	2024-05-28 13:57:48.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
47	\\x2d0cd41372f8c91191af350da106bd6a4bb9d6366af9a55ddd3338c91fc1dbd8	0	485	485	43	46	3	4	2024-05-28 13:57:52	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
48	\\xd9da3ade8740db3cbf39593b200f13dd7fdbbc5c51076eb5cb4bd77154cb3f3a	0	486	486	44	47	10	4	2024-05-28 13:57:52.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
49	\\x6f061d06ea09c7183332ad1ab7ad544cde3bd820fa21ca1605667ab3208954d9	0	492	492	45	48	15	4	2024-05-28 13:57:53.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
50	\\x5927287ec9386cbf145f590294c69c1bed3ee27d344d56e23264086c2997a8f6	0	499	499	46	49	8	4	2024-05-28 13:57:54.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
51	\\x2c342f48323f958afdd542d2d9845e80d69c9867e6181ac062de8a5fafd8aeb7	0	500	500	47	50	5	4	2024-05-28 13:57:55	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
52	\\x4e670225d5f14d9ce7fb806f6c9eaa0e504114ff8769fa6f1834eb3e1c2cb839	0	502	502	48	51	15	4	2024-05-28 13:57:55.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
53	\\x8a06d16f384058a75f00f8264d5dc0e3ae4645cf449914868f89386f4feee9c6	0	515	515	49	52	5	4	2024-05-28 13:57:58	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
54	\\x958aff753a20e8b8284d514c474b3dcc87f1253f249e1832066b5337d44c2198	0	520	520	50	53	15	4	2024-05-28 13:57:59	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
55	\\xc0a7447494ea43b0604e0ec3d192436802120c214e305646fd99a13c8729131f	0	527	527	51	54	3	4	2024-05-28 13:58:00.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
56	\\xb0e799975f32f3ad8606e286bf699c7d49be43850fae66e86c0579c274d44195	0	532	532	52	55	7	4	2024-05-28 13:58:01.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
57	\\x69c03d686d14dfad87d0c80fc43a77e36334a5340496794650c7cd1bbb4948f7	0	536	536	53	56	28	4	2024-05-28 13:58:02.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
58	\\x6e995d86ed12d3a186e52afab38b2683371a6008c283296b3af0d523f8e2db5e	0	545	545	54	57	4	4	2024-05-28 13:58:04	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
59	\\x729d4bd75d557b674f1656f153973c30b1f4fd604a2a4031eb2b641c7bad7362	0	556	556	55	58	23	4	2024-05-28 13:58:06.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
60	\\x5e24e880f4b795d6ee15833bb542785fc4bdcf9637fc106beda0de7cb5bbe2ef	0	566	566	56	59	3	4	2024-05-28 13:58:08.2	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
61	\\x3e6aca0cf45269fdb0dff2fe1d1118d19a7bfc2ef9038a7353cdd7e806813c43	0	575	575	57	60	28	4	2024-05-28 13:58:10	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
62	\\x724a8c205f1b328db7f9629ca7ee14e0a147bd2be69f1b50498e06fa3b3062cf	0	577	577	58	61	15	4	2024-05-28 13:58:10.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
63	\\x6482beaad42efc14b732cd28cb35fb310cca16e949b16f3b26c57ef8110394c6	0	595	595	59	62	19	4	2024-05-28 13:58:14	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
64	\\x931d2d56f414669e8938ffdd96b32c7e26eb26d4c38416448a2fb6120be26dbe	0	597	597	60	63	4	4	2024-05-28 13:58:14.4	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
66	\\xbb4f7dab2e4986fd3755c28bf82f30e512aea00c5e8ecccd42bc0a91cfb169db	0	600	600	61	64	10	4	2024-05-28 13:58:15	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
67	\\x5e7d4b92cabe6de822f05b598da78b27233f1bfb93c7540241b92850bee5e102	0	607	607	62	66	5	4	2024-05-28 13:58:16.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
68	\\xca5f5f82c9b6d54bd57ee4912aefde513a1e15614ed559f683d69a50554340d0	0	611	611	63	67	23	4	2024-05-28 13:58:17.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
69	\\xf8cca3f0401dc3da29d8d23f837c921c200237cb6c8f8421314d814117aaf93f	0	614	614	64	68	28	4	2024-05-28 13:58:17.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
70	\\xf6a81a4b40a97a3c9f4832f4a0fda27a7e92efa6f087ca376d49736b7697d605	0	628	628	65	69	8	4	2024-05-28 13:58:20.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
71	\\xfda6c0693526bebfc2d71f6cca8f7aff8dc0756b557e7cb9bf78f11795ccb587	0	634	634	66	70	7	4	2024-05-28 13:58:21.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
72	\\xf7c2edc9489feacda71e2367d72ace5f48ae3ba4bd9d090b451c0b18e5b5164e	0	637	637	67	71	7	4	2024-05-28 13:58:22.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
73	\\x53e27d944ed3e4cfba2f41a268369913f4aa45c7695397f46ea28e01f9e781cf	0	656	656	68	72	7	4	2024-05-28 13:58:26.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
74	\\xbfd66000baf5311c739a3c9870a1e8b4229d1e352abf9e8c372af0a4496712b5	0	660	660	69	73	4	4	2024-05-28 13:58:27	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
75	\\x38a0d729315d78b1bd8057e85e79603a682dd7f5d3a979ef799a2921eabb82fb	0	676	676	70	74	23	4	2024-05-28 13:58:30.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
76	\\x68b05dd1935b19278dccd0aa07589d965a763dab8a4ec0a459b6508e097f2fae	0	694	694	71	75	15	4	2024-05-28 13:58:33.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
77	\\x174ea7ba07ee89d2f91efddb7db0dad60670b261daa077311ec15ec2a08f3b7b	0	701	701	72	76	6	4	2024-05-28 13:58:35.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
78	\\xf695fd27c386562c37d73da3d7403ad4b13b65a63a6f50f14ff4e15fa0eae497	0	702	702	73	77	4	4	2024-05-28 13:58:35.4	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
79	\\x724168a953321390303ef0026cf2b0cc8c62d48639d7a6356139aea9800ff365	0	708	708	74	78	28	4	2024-05-28 13:58:36.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
80	\\x12bb5f3257048a3036ef48cbb5d74d142391979af5c96bc77092a28d75385875	0	711	711	75	79	7	4	2024-05-28 13:58:37.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
81	\\xe1250b0f68d63d8112e4aa975db71847279348d9d691d30a16152bc8e02bc790	0	716	716	76	80	19	4	2024-05-28 13:58:38.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
82	\\xa79015b3a457dc737ccae70f9d7abce7c927af25484ee80ce949f6ba53daf445	0	717	717	77	81	8	4	2024-05-28 13:58:38.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
83	\\x9fded1ce2717a6cb0a4c3169606d1ca298da15549ffb41a8ae8ced7aa3b57d80	0	729	729	78	82	23	4	2024-05-28 13:58:40.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
84	\\x3419c53946e4352809457ac8df97fa8d1117238c3cfe390edcab2f701c16fdbd	0	739	739	79	83	3	4	2024-05-28 13:58:42.8	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
85	\\xecc7998932e637b320e9b98de65fb99e39a3dd9a8e31d466e53566bcbf3854da	0	744	744	80	84	10	4	2024-05-28 13:58:43.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
86	\\x4d043eda11e4d1ec273836742cbd1505738fe89e11eb71c6d8ac272f33be71e8	0	749	749	81	85	28	4	2024-05-28 13:58:44.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
87	\\x66467af8c81f71787416a09cd26376caa7c974dc5bdcc17721ee23772a1c60a4	0	757	757	82	86	3	4	2024-05-28 13:58:46.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
88	\\xc0b369b05f16c158af26536ae24336ee6075c589b6bac66106bfdd72e058c6c0	0	765	765	83	87	7	4	2024-05-28 13:58:48	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
90	\\xbf1700ebcb1409f0973c0cb0f4f0d3a6f2ba88ad71ab1666a5ea2b9d534595de	0	777	777	84	88	3	4	2024-05-28 13:58:50.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
91	\\x99414778f0c30137f454ef2b3579c5d6950a04b2ec250aadd54cc459c9fd3ea0	0	782	782	85	90	19	4	2024-05-28 13:58:51.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
92	\\x8ea436a4a02fdbd15bafbedc4c76502a3b64460b350191a049e49193af4f9d0e	0	791	791	86	91	6	4	2024-05-28 13:58:53.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
93	\\xc8fe969ec541abe9c39e94e54693b0526b30f55cf21c8edc49bf6ae3201d78f9	0	793	793	87	92	8	4	2024-05-28 13:58:53.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
94	\\x2bb025a30cc592cc5f264dd802725af0e2e6f10cc23a9567ae8c6ad76f78f683	0	802	802	88	93	19	4	2024-05-28 13:58:55.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
95	\\x4bde1540aea1e82dfac76c4f82dd4b56054374218a3776a58f5e02f1475da32d	0	805	805	89	94	15	4	2024-05-28 13:58:56	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
96	\\x76551a1c46637407dfc2cbce0a67b8b369b785e53de450b58bfd466c967acbd0	0	820	820	90	95	3	4	2024-05-28 13:58:59	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
97	\\x02a1ae73f4ae587bcd45b7d881ea3c9d67e8be49404e2132ad79cb624f8a0879	0	839	839	91	96	5	4	2024-05-28 13:59:02.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
98	\\x75f3be60ee26862c9e1779d2f85d175b002a28fc1e319ab6e0d46a80f771c1ae	0	869	869	92	97	10	4	2024-05-28 13:59:08.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
99	\\xa77c12c13f1c9bee46e53ac573af0bf656ccc3b68461b6b641513063352ae780	0	878	878	93	98	15	4	2024-05-28 13:59:10.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
100	\\x96a1cdcac4ce16607a414af0a1ea077eee9f6328c5114f7f16ec83da9768f9dd	0	888	888	94	99	3	4	2024-05-28 13:59:12.6	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
101	\\x7f48dac04852999f19db36eaec2845a3d82c78a9ea4356a59d1717da1751bbd6	0	906	906	95	100	10	4	2024-05-28 13:59:16.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
102	\\x641d33e55aca5be38837bc61e4398cd9a9e6b87452dda0d0c2830810c5ea55ac	0	925	925	96	101	3	4	2024-05-28 13:59:20	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
103	\\x4c43bdb6e65277d72535976504800a56020572b1fd803816ad18f04bbf33b204	0	926	926	97	102	19	4	2024-05-28 13:59:20.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
104	\\xd87367bc2984c348a0b9e1066af52f404bad2531e622fdd8a1ed182f3f3a6aa4	0	933	933	98	103	19	4	2024-05-28 13:59:21.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
106	\\x39c2b76cb68103c1852edf76644d10348fde8d77fde5bfaf84772240a70e5e16	0	955	955	99	104	3	4	2024-05-28 13:59:26	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
107	\\x45b8f0c5a6bf9a5f992aa5b6700790a0a2e879bad62c07fdf5d08971610d1e0e	0	961	961	100	106	5	4	2024-05-28 13:59:27.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
108	\\x8926951267f285b956ff3299607f29e5f11dc7350738917f5a2fbf8bec90bcb3	0	964	964	101	107	6	4	2024-05-28 13:59:27.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
109	\\x5b14d1580cce2a11a137bc159c4171baa9377db7a95da1c7b217ac00ebaf938e	0	966	966	102	108	28	4	2024-05-28 13:59:28.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
110	\\xb84d515227674561496135c54c5e0abc0b83bf7045e9f49c8529593ae05ca783	0	968	968	103	109	7	4	2024-05-28 13:59:28.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
111	\\xd0b25f9e1a2dc7b13205d470b35d3038e3cec509f29c12c8950eb32ff6ae9dc6	0	971	971	104	110	4	4	2024-05-28 13:59:29.2	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
112	\\xf34081b22a01a24c28cc6fc26fbc3456df69439d4435fcc9c9d6e2117d2f90ca	0	973	973	105	111	4	4	2024-05-28 13:59:29.6	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
113	\\xcb8decd6452e2a177f300474f25ba5bbb5112ee81f7da43b95e6329cdbe99fd5	0	992	992	106	112	8	4	2024-05-28 13:59:33.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
114	\\xe9c05b2cd2634ec3959b94c1d772b3801bcfa5296d8ece405accd74714b94c19	1	1009	9	107	113	15	4	2024-05-28 13:59:36.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
115	\\x2b43e06299e74a66530273d46ea36d339a5346a414a4d836ab4e680d5e76b827	1	1016	16	108	114	3	1704	2024-05-28 13:59:38.2	1	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
117	\\xc6e00d5ac688be0532f70f2b6a4d0c9173af73d730755aea9427755cb65c2602	1	1020	20	109	115	3	4	2024-05-28 13:59:39	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
118	\\x2eb0b7c20d04d3bb48c6a7f8a51fbb3c4a517bae021cd8884902ff5fa3136d84	1	1029	29	110	117	4	4	2024-05-28 13:59:40.8	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
119	\\xa0f0727d4db476d3c7424d782320a39775890b1ba0d01f9f3ffce32194b9aadc	1	1036	36	111	118	7	4	2024-05-28 13:59:42.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
120	\\x63ed6e35e5e41a60852151d0081d436d7c156ca5e2d8d66449d15ada7e0d8b0f	1	1044	44	112	119	4	1519	2024-05-28 13:59:43.8	1	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
121	\\xe68a28829e4a000e075626de66346b4fc54fa74930bc624455ec8dd55be446a1	1	1056	56	113	120	19	4	2024-05-28 13:59:46.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
122	\\x5c27aae3e43ec837cd613939f4a455e1dee18a81c25f27e19dd70ff9fd9dfdd6	1	1073	73	114	121	19	4	2024-05-28 13:59:49.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
123	\\x99160d62cf8e3475c8f1d41ea390cca60eee824346c87b90fa5e2297ec9e96e7	1	1085	85	115	122	15	4	2024-05-28 13:59:52	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
124	\\x6d4356645a41b2ec67dd4b4a033b882b2ab08ed5a5f71dda4da4c21796cde668	1	1087	87	116	123	7	1502	2024-05-28 13:59:52.4	1	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
125	\\xba137c29afbe6dde03fce71829b2b9676ed6d6a96dbd649118abbe9c7bb99669	1	1102	102	117	124	23	4	2024-05-28 13:59:55.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
126	\\x2a37cbac02f96386bcfc185447370a46e6bd24cded5908b2456f37e74dedf46f	1	1103	103	118	125	4	4	2024-05-28 13:59:55.6	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
127	\\x96e1a3028e6900ee98a07e0840a1cdec7a2289f419b6b7197938feb0554ae35e	1	1111	111	119	126	28	4	2024-05-28 13:59:57.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
128	\\x28183f4687fc5f488dc5ffaa91a0e959fe0eb81558be71b19210f816320d404e	1	1113	113	120	127	7	723	2024-05-28 13:59:57.6	1	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
129	\\x1b2cd9584846b2885906b5ae796103fce60bc724d2010d9e5be871d631310b5d	1	1124	124	121	128	3	4	2024-05-28 13:59:59.8	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
130	\\xfae2be4620598dbd855af5987e0f6f25ec99a091f86806bb75e9a77f9bc85d55	1	1131	131	122	129	15	4	2024-05-28 14:00:01.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
131	\\x7f7b63daad61cf42543bad63270b899905dceb80fe5996f4aa0cd780f41a2424	1	1134	134	123	130	8	4	2024-05-28 14:00:01.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
132	\\xadc5db72896bf99a25bf9eed47bf02b66c1d11cbdff2bce24e68de39f7fae290	1	1136	136	124	131	19	394	2024-05-28 14:00:02.2	1	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
134	\\x8c14dfa78dbf6d4868664f98b0652ba62fc91db5ff58380aa65ab8faa37dd773	1	1144	144	125	132	8	4	2024-05-28 14:00:03.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
135	\\x7e08a95d798b99d9c18dffb5445748cf6ab11d68c343300bb6ed3d1867a4ca24	1	1149	149	126	134	3	4	2024-05-28 14:00:04.8	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
136	\\xb315a0192b71a54a6ead341b7c704dac05602fd81ae82077956b1ce81bd82850	1	1157	157	127	135	19	4	2024-05-28 14:00:06.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
137	\\x57a64051a3fd0b0029ba7d410cf5f03eb6962e81694325f91dcc8e350bb83efe	1	1181	181	128	136	7	352	2024-05-28 14:00:11.2	1	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
138	\\xedfb16a885a02b28f83c3813d51fc1954a7c96aea9112e9631a60dc61c1e460b	1	1182	182	129	137	8	4	2024-05-28 14:00:11.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
139	\\x45b5ae48ddb4bb9060cf7d6afafac75b903df8e79f0c3abfa7d2fc4058773eaf	1	1191	191	130	138	7	4	2024-05-28 14:00:13.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
140	\\x2848582d7ed38a04a6456f6c4a571a6eb61f602cf6f1e271f2b53bd5a9bb1b47	1	1213	213	131	139	6	4	2024-05-28 14:00:17.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
141	\\x2db08f9edfe733e82ce2f696cd1c0eaf9e67557dc5423120fd7df098a9a913c0	1	1217	217	132	140	7	438	2024-05-28 14:00:18.4	1	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
142	\\x1e1f3a880a7676f3e2f4065b065b45da17cb07d0f876e72ad9baa32e1b3c7750	1	1228	228	133	141	23	4	2024-05-28 14:00:20.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
143	\\x78ee945a93662b3e1fbbe210098e3e140e27722609f1d3566836814a88b8f868	1	1250	250	134	142	8	4	2024-05-28 14:00:25	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
144	\\x30ac245f086c3e2c8b7e2bf9ef854bbdf1a7bb3f81a97edcad935c7f5207fb24	1	1254	254	135	143	8	4	2024-05-28 14:00:25.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
145	\\xd65058ffb6aa8b251763d1f02123893f02e02997e6f889b09fb759fd358b4a42	1	1259	259	136	144	6	401	2024-05-28 14:00:26.8	1	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
146	\\xaa885939a6360e41e0850b57dce50cc96787acf2c4f09fb8eb218bcbb15a0fa6	1	1267	267	137	145	23	4	2024-05-28 14:00:28.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
147	\\xd468556817fab6e1d26601d2792e9200551b0b4d62f8e710325528b2c0460e25	1	1271	271	138	146	5	4	2024-05-28 14:00:29.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
148	\\xa6f1b3b43d6d5a1cff9807ba61c3b7caa4b6424b1a9a828ace1c76511660cc1c	1	1285	285	139	147	28	4	2024-05-28 14:00:32	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
149	\\xa369eb3b3da726383769184e75cd98be35a213cce5fd835346b65ae1be0cd7b4	1	1292	292	140	148	4	749	2024-05-28 14:00:33.4	1	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
150	\\x78076d9689c19add072e7090a34f175ee8f41f24370c0977bf00d21267261c0d	1	1297	297	141	149	23	4	2024-05-28 14:00:34.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
151	\\xd056c317ffec22d930a466f23e609ce9b369dd683126b6f7ba5979d2eaced218	1	1301	301	142	150	6	4	2024-05-28 14:00:35.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
152	\\xe9ed72d3f2d3a284296b902654df933bc1aad50bf13e9fe5c73c9165f0283ea1	1	1307	307	143	151	10	4	2024-05-28 14:00:36.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
153	\\x088a33ff75d14bc20338f071b7d16d4c936dbf91f448abdd0770668e7547980b	1	1323	323	144	152	5	749	2024-05-28 14:00:39.6	1	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
154	\\x37810b433b605b8fdd083293a131edfab23cb992df9e87b040968ca0ee618a3d	1	1326	326	145	153	5	4	2024-05-28 14:00:40.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
155	\\x4f61e8620d5eee68d76d860e48c9926ac036b2dd2df9a84669ba51098464d738	1	1327	327	146	154	3	4	2024-05-28 14:00:40.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
156	\\xb48261786a89eb5ee5e710370f2a3f96648a85b26c6f98264ebcdd09563cb909	1	1336	336	147	155	10	4	2024-05-28 14:00:42.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
157	\\xdbae2faaf55315e71861a8340ab94ff0982c73f9975ca316f5344fa040b691f5	1	1342	342	148	156	23	336	2024-05-28 14:00:43.4	1	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
158	\\x90f11169ffbcced7b7675a190cdc6552d3d31e0620feb4d5f63aa0ac4f3a209a	1	1345	345	149	157	15	4	2024-05-28 14:00:44	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
159	\\xfc060e7c5f136239a8c122678bf6fffdd4fdf48b143cee99858448bf696bf003	1	1364	364	150	158	8	4	2024-05-28 14:00:47.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
160	\\xc857ee908b49ce79bd978e920698f706239b82b9b4720c97898ee65fc19a7ead	1	1369	369	151	159	23	4	2024-05-28 14:00:48.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
161	\\x4478eac0feb83f4ed668189b3f810cbdd5e248611973ff9408ca496f1e382545	1	1374	374	152	160	19	745	2024-05-28 14:00:49.8	1	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
162	\\xd638c635fe832f531c807705175504db60c1e9c8af2a3c71adf35533ec3b76f1	1	1383	383	153	161	7	4	2024-05-28 14:00:51.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
163	\\x056348a45f1730b407802fbd4cbcf9ab265819839b4f77305197be134efbc37f	1	1388	388	154	162	15	4	2024-05-28 14:00:52.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
164	\\x8cb0075193d0a312262752437b1a2649fc8769de37eeb93eb5bd576085d188d2	1	1395	395	155	163	23	4	2024-05-28 14:00:54	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
165	\\xd98769c34905cd04e11ae6e9f0987c4d536a4d8745a335ed66ec17af3a0de373	1	1450	450	156	164	10	300	2024-05-28 14:01:05	1	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
166	\\x774963e705b35172820237feeab3bf7ddaa17e45b24ce4a6ebeaf0fe18e4aa1f	1	1469	469	157	165	6	4	2024-05-28 14:01:08.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
167	\\x933fcc1b714fcd30deb5e4e7119fc0d56522bdf410a9267e34d3b1b7efdd3e3e	1	1480	480	158	166	10	4	2024-05-28 14:01:11	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
168	\\xe26696427b0a739a2beb26f6689c0de93276772054a79978bc8c749872af8a98	1	1490	490	159	167	23	4	2024-05-28 14:01:13	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
169	\\x7329f0dc30e1518451fe70426650288fc3278710b30cfc594da88ea1a2d473e4	1	1493	493	160	168	8	781	2024-05-28 14:01:13.6	1	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
170	\\xb8dc2c45161c81d8b0bab6d64848e98ab2a9e6ec4ecc5fffcc14f134f6322d66	1	1516	516	161	169	8	4	2024-05-28 14:01:18.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
171	\\x060029c81fcf3295105efd2b8132b78577f7faa856ee1eb50b96ffa560b6b05d	1	1518	518	162	170	15	4	2024-05-28 14:01:18.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
172	\\xf59c78845e77492ef787b778c81dee5ee8e7de56b89961ef53c31c1910ef5b19	1	1524	524	163	171	23	4	2024-05-28 14:01:19.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
173	\\xeb5d96474b0bef7002c05f97ca9783a4c1107a0c6a490567f90e027cd91a418d	1	1535	535	164	172	8	342	2024-05-28 14:01:22	1	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
174	\\x49350759ba9f856ea7c74892521f3e61e617519724bd7fcf546c099b9513847a	1	1541	541	165	173	19	4	2024-05-28 14:01:23.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
175	\\x740233b4e28e533ac7eb8b8de60dacdf9c73c64d6fa943553df2b05fcaf6d0e1	1	1550	550	166	174	19	4	2024-05-28 14:01:25	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
176	\\xc6d6e27d887fd568cfff12691c0461ba56fbc89d9409364f4c7e3c33a4194a76	1	1574	574	167	175	7	4	2024-05-28 14:01:29.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
177	\\xbd9c7d7d846481f809f27d34a63a9d4d1cc1b565b35da3c2886d58dad9eac085	1	1581	581	168	176	19	300	2024-05-28 14:01:31.2	1	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
178	\\x2c8fc92ebbf621b58ed6a6833fe8f3257d527ca5113ab7efbffd2d548135c622	1	1645	645	169	177	7	4	2024-05-28 14:01:44	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
179	\\x172c5027a1b268878415714468d629ecb3361e855196a93efbbe23324b594e3a	1	1655	655	170	178	3	4	2024-05-28 14:01:46	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
180	\\x2138c781c87a13c49563a8b84b3056ac245b972150dfaf14fed37f5fb103cc9c	1	1660	660	171	179	28	4	2024-05-28 14:01:47	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
181	\\x8d5e51f61f24d6b3c69a3cae8bab181640b46cfcf202b3768dfb5ff02999e5c5	1	1664	664	172	180	19	4	2024-05-28 14:01:47.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
182	\\x59978535b3168480eeffd8a253b4ab79adb0437c58b22cfedcc467750d624603	1	1676	676	173	181	3	1136	2024-05-28 14:01:50.2	1	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
183	\\x223e654c3a30386a9beedb2c65a526fab2112e5a9b9d1a8b2f9270206aa9b047	1	1688	688	174	182	19	4	2024-05-28 14:01:52.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
184	\\xff9e5f8971d02b4855b927f20c750a10c112fbe771069a5b9fe939eb2375b8dc	1	1703	703	175	183	28	4	2024-05-28 14:01:55.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
185	\\xd97e64249dfdff31e86fd0845e553ad19a0de397d38f55d118fc0a923747ac1a	1	1706	706	176	184	19	4	2024-05-28 14:01:56.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
186	\\x57f35c5f12307923f009042bace381a1e77e3b0fed287326c377b3d3c897198c	1	1707	707	177	185	7	562	2024-05-28 14:01:56.4	1	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
187	\\x3cdca8dd74c1b5e30c547668f358cda03dd08bf588b79b542e79807736bd6148	1	1718	718	178	186	5	4	2024-05-28 14:01:58.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
188	\\x181c603c11ce87f74094c7309b3056308b38cbc8d85226baba321a00562b65a9	1	1735	735	179	187	3	4	2024-05-28 14:02:02	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
189	\\xc09e8e995bf25611bd50d6c1815ab7ffd7a298c6d6c7457b8d904ec71630a919	1	1745	745	180	188	4	4	2024-05-28 14:02:04	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
190	\\x343208dec91b533cdfb7039f96ffa45bb580cf98c602210d9205388901987fff	1	1748	748	181	189	23	754	2024-05-28 14:02:04.6	1	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
191	\\x2f1b578b229503c9af38febbe52c65b7cabce1dbbc68da898f9b05b2c06f75d1	1	1749	749	182	190	6	4	2024-05-28 14:02:04.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
192	\\xc999e08b7279309c441e0f4261ba06da7124371536ef195aa791dffa04f10d6c	1	1761	761	183	191	3	4	2024-05-28 14:02:07.2	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
193	\\x8f944f44cca10d5fbfd0c1c12a12a2bac017208df4a40f0c4afd8f13dea2260f	1	1762	762	184	192	10	4	2024-05-28 14:02:07.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
195	\\x9e8228385d1755e4f3aa0412b0763154695401c33fe7201aee22a838b1fdca25	1	1766	766	185	193	23	792	2024-05-28 14:02:08.2	1	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
197	\\xe56103da29245f5947f3f25963c8d6d1076eaae4e2968755945e43ecd2c4af4c	1	1767	767	186	195	10	4	2024-05-28 14:02:08.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
198	\\x43050e6dd940619dd8b6bcf34639b40bea7b2c01855a18a1cae32dfa5660c75e	1	1769	769	187	197	7	4	2024-05-28 14:02:08.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
199	\\x4c99519f4834f49d0fe35c40f23ac7590a8dcf17529583c697c1df4452b2b28a	1	1787	787	188	198	23	4	2024-05-28 14:02:12.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
200	\\xf13b5723f01102225cf258dadd6541f1e6e4b825ccb3e9b1a32d6f9bfa803048	1	1788	788	189	199	3	768	2024-05-28 14:02:12.6	1	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
201	\\x237e8d0c9c37e655e99fad709d6894718b00cfbc07b4306b2becb3d2b4b35802	1	1790	790	190	200	5	4	2024-05-28 14:02:13	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
202	\\x2c5d3fe4427c8bb1a2967e0c8f80a4d5761dc3a4f2f40a9b9fdb78783dbc9dd5	1	1792	792	191	201	23	4	2024-05-28 14:02:13.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
203	\\x518460e80d38d5f4e2e93693ba6a458199d285588107629c5481306d1848f845	1	1806	806	192	202	3	4	2024-05-28 14:02:16.2	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
204	\\x9dd03d152c2cdfd37551c2459be801c7239ca70bec2c39d8e496ac0805023063	1	1841	841	193	203	3	539	2024-05-28 14:02:23.2	1	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
205	\\xb0c9c2b8139d87e7160ae29ab64eeec9d6fb6c5aff89fbdc400de665699928d2	1	1846	846	194	204	7	4	2024-05-28 14:02:24.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
206	\\xcb201bd614cdf5012158b00d73f61ccc58ae392b5a8f9004bd3ff2fb8f2772ad	1	1847	847	195	205	7	4	2024-05-28 14:02:24.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
207	\\xa5b8f147bf9eddfb16c89cdeb04595656463952cd0ebb36f80633e1e040552bd	1	1850	850	196	206	3	4	2024-05-28 14:02:25	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
208	\\x41197be7d561b0642b1cfbf7562d808ff44d07353364704d4c6b641dff5b57b1	1	1857	857	197	207	28	4	2024-05-28 14:02:26.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
209	\\x9eb720019f885f0eea065504e8ca18ef88715b7b5cf1099cf5e427641b59fdbc	1	1868	868	198	208	7	644	2024-05-28 14:02:28.6	1	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
210	\\x86acb2bebaf202297e553eca198573769a47358e1285b3fb0d9bd07dd31cf519	1	1879	879	199	209	10	4	2024-05-28 14:02:30.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
211	\\x45597768249a2e13b94f5c81ceadce4956e235bdfa198e8074e4c63e3a4130b0	1	1884	884	200	210	5	4	2024-05-28 14:02:31.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
212	\\x8892ff365a85a23fe27d5b2d0bb259b7659969e56f9302b1290f45faee569723	1	1887	887	201	211	5	4	2024-05-28 14:02:32.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
213	\\x91c4b0536e5da24a7f8aea34d3f5cb9f2ba8760d7975c2f1e10064cde30aad79	1	1921	921	202	212	10	535	2024-05-28 14:02:39.2	1	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
214	\\x2c9007dfca87620d91b9fdf2ec042ec0c51f17c1e360fdb584d5315ebf0e38b8	1	1927	927	203	213	6	4	2024-05-28 14:02:40.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
215	\\xf0e0b01c5f2a4fa762934b097bb35c2a5b1795e5cdee96cb8f3d7390b53f3bc8	1	1947	947	204	214	6	4	2024-05-28 14:02:44.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
216	\\x222cf84ee3132030c53fe09317125edcde86b9d18bae4a143154678a5569557e	1	1956	956	205	215	28	4	2024-05-28 14:02:46.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
217	\\xb3414ac404efa596ce6a3ccb14b75781b326dcbe36a162d994682e68d7c427ae	1	1991	991	206	216	28	501	2024-05-28 14:02:53.2	1	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
218	\\x44b24d411afd851791c52fe3086ac9e666c48cf76cba368730c3f0222ffe98ce	2	2007	7	207	217	23	4	2024-05-28 14:02:56.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
219	\\x89d74b6629c4df7c5aea5acf221577d3a1d26c6f08e9964553dbf1a50cd8c51c	2	2017	17	208	218	4	4	2024-05-28 14:02:58.4	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
220	\\xbe1de193ff4e6f76ccb3af162f4ee572495ef5b365b271f645152819305fe0e3	2	2025	25	209	219	4	4	2024-05-28 14:03:00	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
221	\\x7673c7711e7d1974afeec5aadb157fd1ed986a53d1d9526b1688cc54709bde26	2	2031	31	210	220	3	397	2024-05-28 14:03:01.2	1	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
222	\\x6f7ba40558e0154aacc803d4965b742ca9673a94276411995bd0f7eae07a7dbf	2	2042	42	211	221	8	4	2024-05-28 14:03:03.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
223	\\x66d0ababf441dd93e88faedeff1adb097d488d643dbf6434bb233d6940bfbee8	2	2049	49	212	222	7	4	2024-05-28 14:03:04.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
224	\\xaff3f22c0a0a6310892d5498de05920abd34b8949b1cb636323be32242b5793f	2	2058	58	213	223	15	4	2024-05-28 14:03:06.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
225	\\x5a3db7361a049b010fdf3e80d1663d8fb9b8da2d760e0c55124ee058ed0ff7dd	2	2066	66	214	224	19	698	2024-05-28 14:03:08.2	2	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
226	\\x9930153b9640b3f55ad57782936a31e01439fb1629a9dedfd67f2dd27cecac53	2	2086	86	215	225	23	4	2024-05-28 14:03:12.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
227	\\xfe84433594cf11751c68272ce78589d55409e03f41f2cf189ab8f663ba244647	2	2097	97	216	226	8	4	2024-05-28 14:03:14.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
228	\\x65f307fee0dcc2bdc94728802da843ad6cb1f0989854fe02bfe5338009f68f26	2	2107	107	217	227	15	4	2024-05-28 14:03:16.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
229	\\x30d494c3cb5069d7221c5e8bc4b3e67241b8964568934a327ce55fdbfa314124	2	2110	110	218	228	8	4	2024-05-28 14:03:17	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
230	\\xcc3ea346b10e3073e98bc7ccd2a19589ec78bb256abc2637a28f35bba6248889	2	2111	111	219	229	23	4	2024-05-28 14:03:17.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
231	\\xe39bbd56e7e54655b402a5f6dc42f04d0a8d9ce7a9a78273c4c1810006a9addf	2	2118	118	220	230	6	284	2024-05-28 14:03:18.6	1	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
232	\\x953481d9c168111ab5361bb4e1810287c977cd520c74891b37d45d8b8577c1b7	2	2122	122	221	231	28	4	2024-05-28 14:03:19.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
233	\\x8748cec440ef035daafce585a99a08756662cf01eb0e1f362e950d6ce18f5228	2	2129	129	222	232	8	8200	2024-05-28 14:03:20.8	1	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
234	\\x1ed75df0c43e9eafcb0c1b642310e7ad2b9eec513de57d303253f2d69a5708e6	2	2133	133	223	233	19	4	2024-05-28 14:03:21.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
235	\\xa2f0c3cc385fc33ef0db823a51d94f41497de784a9a79b645f3f9ba60fc0f41c	2	2136	136	224	234	6	4	2024-05-28 14:03:22.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
236	\\xfc4bf972f01d8ee7cf48b43f1e9f46e85c0f8ea58e28b99adfdc295ed9d261d1	2	2139	139	225	235	28	8410	2024-05-28 14:03:22.8	1	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
237	\\x5febe8dd55501036b0f9a2d7abccda62a19564e29b8c1f373c79e4ac2cf58957	2	2147	147	226	236	8	294	2024-05-28 14:03:24.4	1	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
238	\\x6fab9fe2a7fab8f5c3cc96a308f14868917ebe9c9328148c3850a6316559694c	2	2149	149	227	237	23	592	2024-05-28 14:03:24.8	1	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
239	\\x82e8da460e968f0f8aacab9f843af46d2f600e0834e9c237f0b8366c8cb09180	2	2151	151	228	238	6	4	2024-05-28 14:03:25.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
240	\\x0016db4fc2d76d0f3f0cfae0281325f74ec17a732457386d004c0d8db805ab0e	2	2159	159	229	239	28	294	2024-05-28 14:03:26.8	1	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
241	\\xffd6a92d6e1585a1f95054242f904e54be0479a45d012165925a7b5afc70730a	2	2178	178	230	240	15	2368	2024-05-28 14:03:30.6	1	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
242	\\x2db496bda826c9643fcb4451b192879ba718e95bd7b891aa379ed9b8b717d979	2	2182	182	231	241	23	4	2024-05-28 14:03:31.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
243	\\x1573143579c0c4ab057c1a698d8b29093ca20a1efdc37b1e7998f260ff5b237f	2	2197	197	232	242	4	4	2024-05-28 14:03:34.4	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
244	\\xa555725c5f449c175d8159f252c3c4babb45cd880db30c3b8f21cdb8a6cac757	2	2201	201	233	243	23	4	2024-05-28 14:03:35.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
245	\\x9fffc713b643fdde1c65089d6b249ef0ac180636dfa44f0a3cd5be9bdf06a061	2	2207	207	234	244	28	338	2024-05-28 14:03:36.4	1	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
246	\\x9946fc254a60f7af3cca5f926a5d49da7812955dd8f69a5a1f86b683fcd2957a	2	2210	210	235	245	19	4	2024-05-28 14:03:37	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
247	\\xe80ff073530de17b67a726c32917b8739eb91520aaee205bb2a842c3d4df5369	2	2215	215	236	246	3	4	2024-05-28 14:03:38	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
248	\\xa6afd52351c57745683dc4f9dbf33c8c4db521a291d87d812444d85199cd9f77	2	2216	216	237	247	7	4	2024-05-28 14:03:38.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
249	\\x46b83139cb9f4d2b2922c37ab76b360b23ee6e1fa25dbbc237ac9a99dd804284	2	2230	230	238	248	4	294	2024-05-28 14:03:41	1	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
251	\\x556a550e7d65e5e1ac7148bd9f8073fe868b386ca176d67710dae2762c0c5068	2	2233	233	239	249	7	4	2024-05-28 14:03:41.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
252	\\x50b88cde128833cf294829c3ea3af200b01062f4532ee7df0b363c08db2b6c86	2	2234	234	240	251	28	4	2024-05-28 14:03:41.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
253	\\xf7cbc532d89cdde820ef0924ff9ad2b2723aaa07a55f51f424258a67f6a94792	2	2235	235	241	252	19	4	2024-05-28 14:03:42	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
254	\\x7d4c046ec38075874f2e890e6e6779ca73130839d21a70f994af4b8661846aca	2	2251	251	242	253	15	4	2024-05-28 14:03:45.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
255	\\xf9f33a9e53115fd78fe317b231bc24c1316eb64105c0f05261230b5ed44879b6	2	2257	257	243	254	19	4	2024-05-28 14:03:46.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
256	\\xb672a8a84b67f3fb3eeb23eb138bb1f075da0b34ee1044bb2582379c4b8fa59b	2	2259	259	244	255	5	4	2024-05-28 14:03:46.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
257	\\x99f23ca8f2dac173721b7016d7b8db409107a38d1902235430d69cf8aacd8fdd	2	2273	273	245	256	19	4	2024-05-28 14:03:49.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
258	\\x1227e5a6482f6793748e39dc6b80c970258d15010bc212ccf20c09fad670ef82	2	2307	307	246	257	10	4	2024-05-28 14:03:56.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
259	\\x22bf776814dbc46ffc88bbd8d8914f97e8194a852e3b185fad946b957c87966d	2	2311	311	247	258	8	4	2024-05-28 14:03:57.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
260	\\x4cf85fdc404d48ec92108644838742866b01481721be33b48e8512015612c0fe	2	2317	317	248	259	6	4	2024-05-28 14:03:58.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
261	\\x3c874c33a98da4ffc71dada6b2a90f12aba9bca7ca74f2221d7af2301b94c5ef	2	2334	334	249	260	15	4	2024-05-28 14:04:01.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
262	\\x8316f663791d7c8f7a8d47ecc741b528f1496d3a02be7df5af2ce2efceecbefd	2	2339	339	250	261	5	4	2024-05-28 14:04:02.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
263	\\xd282cc6312d813432ea63f18e472150fff7a1ee2deb33780ec9abc120833645e	2	2340	340	251	262	10	4	2024-05-28 14:04:03	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
264	\\xb1b24632f074e2493228c1fa64cf7847df8953057cddd6168c3ca31e2ee9db56	2	2344	344	252	263	4	4	2024-05-28 14:04:03.8	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
265	\\x332d865cb8432ba4d2120a6f848600eac426cde41eec4ca85d2869668f1cc662	2	2354	354	253	264	3	4	2024-05-28 14:04:05.8	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
266	\\xac3d70dc06888aa70404c8017224977fa16519d4a7fef3e8be59ab0ee279d723	2	2378	378	254	265	6	4	2024-05-28 14:04:10.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
267	\\xa6bd6043dec3b121f414763bb91cf15fb4d2bbdeec10fb7f85cebaf9e3a37785	2	2391	391	255	266	3	4	2024-05-28 14:04:13.2	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
268	\\x85e1c1401349259d56c38f0f6b50bf8526203796957ff7bd9b5ea887a19c933e	2	2399	399	256	267	19	4	2024-05-28 14:04:14.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
269	\\xa8eb6488a9529cb8e563de80c175571b2b954f9a4813257ff2f9a6717ae3775e	2	2406	406	257	268	23	4	2024-05-28 14:04:16.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
270	\\xdb583673f84adeecd937cffcd5fe45cddffedf0a04ed63ed47fb5e9aac5a9036	2	2441	441	258	269	19	4	2024-05-28 14:04:23.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
271	\\x1ad954b35b94086e633301e04c15c16598f34812676cef4801b3131d75dae5ba	2	2442	442	259	270	6	4	2024-05-28 14:04:23.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
272	\\x3f80dc7355f0f2250e0bac8e002a6a5ead5189f4389c231bae09ad323c37d2f6	2	2446	446	260	271	4	4	2024-05-28 14:04:24.2	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
273	\\x1505367b7d4da60b50059979b8f238ec6f6363c6b7c9e585ba1fe2d0284d1e27	2	2448	448	261	272	8	4	2024-05-28 14:04:24.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
274	\\x37c9ea53070d92510ffa6e85f6c1450a4353614948cdf6bd9c575369940845ac	2	2473	473	262	273	23	4	2024-05-28 14:04:29.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
275	\\xb151efdb3697f08698c26932d7625d4f3b02d2660b937f56f7072b5ef909d09e	2	2479	479	263	274	19	4	2024-05-28 14:04:30.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
276	\\x60eabba3e991c790697d068ffdfa228dc4a38c28814643fa59f184efa2eb8afe	2	2492	492	264	275	10	4	2024-05-28 14:04:33.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
277	\\xddf49755e24462d05e60c2f90d8daffb91e91d86037aa9f7caf504a167bbf93c	2	2493	493	265	276	4	4	2024-05-28 14:04:33.6	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
278	\\xf15c81baa6cd3cc6ccbf94154ea73e7c1cc65dc4fd12f511b8d54289a7e32096	2	2496	496	266	277	23	4	2024-05-28 14:04:34.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
279	\\xf7c9544a036b10158427b0bef8111edf1ac652083c7532eb33e93ab203a3a8e6	2	2508	508	267	278	4	4	2024-05-28 14:04:36.6	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
280	\\x86a3a248884ba81a34fc4519a2b8f5bb8a4cfcb54681594ad5c1308cb8b25189	2	2511	511	268	279	23	4	2024-05-28 14:04:37.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
281	\\x5523da8cb996d4b9fb66558f760cdb70e795c5041f3ad7168eee911ee6b92f7b	2	2517	517	269	280	8	4	2024-05-28 14:04:38.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
282	\\xc2d3a6ce9bb91fc5b833f2468157a5e4906c737f954d7341f4589ded7674a1dc	2	2535	535	270	281	6	4	2024-05-28 14:04:42	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
283	\\x0497b9608f80d171d699a8d257322ab05c44ee36fc52a0717c1ab869aa9b53fb	2	2538	538	271	282	19	4	2024-05-28 14:04:42.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
284	\\x36f7d65fd263cfe79bcfc8216c665fcff7f9d94ab728bb8b3cb6cfbb4acb58c7	2	2543	543	272	283	23	4	2024-05-28 14:04:43.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
285	\\x09b1bbc661f9e44979d01fa78c1161e47e78accce035fb078c5d3d55ec2b25bf	2	2545	545	273	284	7	4	2024-05-28 14:04:44	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
286	\\xc4a58be22ffffd64ffe1062537147d94d338414c127a5e0eeec52deee8b35240	2	2549	549	274	285	10	4	2024-05-28 14:04:44.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
287	\\xff5a3de3f983103d7d222d964a572d2a0eacded38974f72d4a32f44bd4071383	2	2552	552	275	286	15	4	2024-05-28 14:04:45.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
288	\\x5c5e65e73cbbb3f5a4ac311713d54faa69dfa2acaee959e76e106e5f3426b9b9	2	2562	562	276	287	8	4	2024-05-28 14:04:47.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
289	\\x54d9aa75b23dcde24ba02945aeb03ab59580e6f4b6045ae8399768b962a93e68	2	2583	583	277	288	28	4	2024-05-28 14:04:51.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
290	\\xccb2b89abd6423089f4340134992ac92c6dd810acab8618d653a8f7f3808aed0	2	2585	585	278	289	6	4	2024-05-28 14:04:52	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
291	\\x4f121d6f4edb18324cc05ae8135159ed5d9b70cf2f16439f5b72f635d22997ff	2	2586	586	279	290	7	4	2024-05-28 14:04:52.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
292	\\x4669d91b93f7ba7e271ba5e36291c968ee7f1d29aa7ab16af2a699bb841a7a33	2	2595	595	280	291	23	4	2024-05-28 14:04:54	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
293	\\xae568fbdbcbb4957f11b360b6817b3eb8b06b8143886a1796186873917973cf5	2	2599	599	281	292	28	4	2024-05-28 14:04:54.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
294	\\xc914d030971100eb9f2c10673399be6236c9fcd6b7b634e95bd2c423e0738e34	2	2612	612	282	293	6	4	2024-05-28 14:04:57.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
295	\\x3f2f3838885957950ca5113e76f3ad17e374e9573a1aaf8b3a8251878489090c	2	2651	651	283	294	3	4	2024-05-28 14:05:05.2	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
296	\\xa699d68833a9a1a36e5101910f09fd52617966872523f6e5888288c648c6c320	2	2674	674	284	295	3	4	2024-05-28 14:05:09.8	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
297	\\xe00bf0f1470f3524878bde5fce8bfd2412e1e5c09199bc14eec24f4406992f80	2	2683	683	285	296	6	4	2024-05-28 14:05:11.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
298	\\xcd117489f7db9e3c918b762fb7a185d73f8c2913ca347175fc8a2413c4d096a4	2	2689	689	286	297	28	4	2024-05-28 14:05:12.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
299	\\xb5beb55f440c6fa77b7cfb6520857cae4c42692f677e33e0f043182ea17a145b	2	2703	703	287	298	8	4	2024-05-28 14:05:15.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
300	\\xacfe0cae5d35b0538ae482f829920f0aef6e2cbc6a738ed1bdc72575b6beecbe	2	2709	709	288	299	10	4	2024-05-28 14:05:16.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
301	\\xd29a9c1e751ab7d695dfcb32d80dc0897516b5dfa22a97b17e5813957667fd7d	2	2722	722	289	300	4	4	2024-05-28 14:05:19.4	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
302	\\xd232ba190b13fe194a18af642909f1e5c5c7774a621e101e8d0003b8d39ecddc	2	2724	724	290	301	5	4	2024-05-28 14:05:19.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
303	\\x09686cd11bc9e3e41c702baf15d3f8c18f4c8b60bd99391f64a66952735f4167	2	2730	730	291	302	7	4	2024-05-28 14:05:21	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
304	\\x022c0657d85fbc68fcb4d39fb3fea22b06c27fdad452968591808525543f5e7a	2	2733	733	292	303	7	4	2024-05-28 14:05:21.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
305	\\x5b5aca2f52fbc4dcb5285f59cb062e1a3d0005ca22ab551842af16d6f74adb38	2	2761	761	293	304	23	4	2024-05-28 14:05:27.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
306	\\xe8b07cd38f440980ad7df266e94ba6874fe526bf77ec690e86a22c4a2e1c3ac8	2	2764	764	294	305	8	4	2024-05-28 14:05:27.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
307	\\xba26f1e944f8843e6b260649d49814fb360e78f7bf45f34562a50c1b1e773f42	2	2785	785	295	306	7	4	2024-05-28 14:05:32	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
308	\\x74c26ef0dd3d95b3f38bb1d557b4d6bee0d4e61bfc0d84b286daa93e58d53174	2	2792	792	296	307	28	4	2024-05-28 14:05:33.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
310	\\xb53d909dcf66f13f99c84ec07f7347f161d5a2b5ae9f775f25bb33f645e1dbee	2	2807	807	297	308	10	4	2024-05-28 14:05:36.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
311	\\xfdc46fde64acd2ee124e21d88ce169871e63391a5eb1188568ea66a0b221cc48	2	2824	824	298	310	5	4	2024-05-28 14:05:39.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
312	\\x8c62edbac50f8ae672bd3836f98e62880c145b8913db9140318afcdb38eb5581	2	2826	826	299	311	5	4	2024-05-28 14:05:40.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
313	\\x43a72891bb7a589fe85ff818528661b45532470c753cfd9a4bcbf48a58dad3ad	2	2835	835	300	312	28	4	2024-05-28 14:05:42	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
314	\\x0953510a480fa77ce5c6667e775a625a140dedd848415f48a4eef115b0c6a77b	2	2882	882	301	313	10	4	2024-05-28 14:05:51.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
315	\\x9093bb9c0541999315747ce9de0e2a4d39c70baf56b896d06d8b75800137dd6f	2	2883	883	302	314	5	4	2024-05-28 14:05:51.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
316	\\x2f8c04518016e07268822fe2a32062744877308a036f74933487f87554c0c090	2	2891	891	303	315	6	4	2024-05-28 14:05:53.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
317	\\x31e4ead2e828c4cb7b1cff927c41fc6580791d9351900728b1ece3c5d2f4120c	2	2904	904	304	316	6	4	2024-05-28 14:05:55.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
318	\\xcb34587e4fe7ae1d8c8005131f5b27c94a4cb0f71c4e6982c6c7b425502fcc03	2	2913	913	305	317	28	4	2024-05-28 14:05:57.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
319	\\x085f77427fb6703a8565f9c1e83d9417b6f8652d9c75dfa8898697ce23b7eb2a	2	2919	919	306	318	7	4	2024-05-28 14:05:58.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
320	\\xc4fbf6e7603a1d8c51a1fb8d8a8cf0f3cb0bb44d3416b210ebf33a74c8510372	2	2932	932	307	319	19	4	2024-05-28 14:06:01.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
322	\\xd5ee9e5b10063dc003f88b65e12908a83e32c7beaf9846d376c3ea0444b8d42d	2	2935	935	308	320	19	4	2024-05-28 14:06:02	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
324	\\xa8960a2164f34f463d603bfb1b1144c4e46f1e49e1e3d82a720c363e85a9e093	2	2939	939	309	322	6	4	2024-05-28 14:06:02.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
325	\\xfc50a4723287f04bb20bf56486d66ea535ba099b123b1d2a1de797fd522b9f63	2	2942	942	310	324	10	4	2024-05-28 14:06:03.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
326	\\x1661564c9ec01cf033899c6c92a0c9ab27316b725645ecff43a2dac0926bc68a	2	2945	945	311	325	28	4	2024-05-28 14:06:04	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
327	\\x18bfaf4fbe41032dfb8961a54eb5e6648771f42bd5eab061091d36e84997e8e2	2	2947	947	312	326	15	4	2024-05-28 14:06:04.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
328	\\x5b6a9cb413228c41972d9feee7af21434b9e2432f791f99e20e55ce008b4d621	2	2953	953	313	327	15	4	2024-05-28 14:06:05.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
329	\\xc758c1297d91ab4b397bd3ba0ac7088b767b970f3f109ead2e9aedb18af2ddfb	2	2954	954	314	328	6	4	2024-05-28 14:06:05.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
330	\\x00448c8db352ee8b70903e7a3eac26393fbee0bdbaffcac2e4e5ec95fe7815a5	2	2959	959	315	329	10	4	2024-05-28 14:06:06.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
331	\\x3f373f9b72c4e3250109198dd71c1a66c26ecfa792b283c7b5551b0e3fcade00	2	2968	968	316	330	8	4	2024-05-28 14:06:08.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
332	\\x06e6b891424ec7644aa89822a48b093f8cf4d6aaa082eaa9ff56d73732068fd0	2	2972	972	317	331	4	4	2024-05-28 14:06:09.4	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
333	\\xdadc106b144a9b56b875a3708c9c3580fb2bb22aa74faf7936e3ad6e52a75dc9	2	2991	991	318	332	7	4	2024-05-28 14:06:13.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
334	\\xb89281ef4a86e3db781d18a2f03426889a5bf16e4411fbb3245326bc9597419c	3	3020	20	319	333	23	4	2024-05-28 14:06:19	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
335	\\x28c31e41f606a732a66133b3cf704859590a213ae918b7bd402674cd7b41eda1	3	3022	22	320	334	3	4	2024-05-28 14:06:19.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
336	\\x9c739235aa566aae1d7ccdf9dacfc219fa8346008d90918a6e7cd58de0f7bf00	3	3023	23	321	335	4	4	2024-05-28 14:06:19.6	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
338	\\x6fe636c9bd683df5088875a7d08aaa16c67f5cc5839f472209b7b3d293e66d98	3	3035	35	322	336	3	4	2024-05-28 14:06:22	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
339	\\x450df1f2201c7096265d0a9323cb597a0dae2a240edcb71be5f4af808d1e6fdc	3	3042	42	323	338	3	4	2024-05-28 14:06:23.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
340	\\xffb328d92cb654d2071bd15c88d485dd821283de245e22db768f16e235ef3150	3	3079	79	324	339	28	4	2024-05-28 14:06:30.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
341	\\x737563b29a00004e97468a50f0a75e74447909cf9bbb4a21101428f4feca0c18	3	3080	80	325	340	7	4	2024-05-28 14:06:31	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
342	\\x05c1e193928e7b17f3cbdce65916f79c91dfb5ee9490d7acbb3740fe3210acad	3	3081	81	326	341	6	4	2024-05-28 14:06:31.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
343	\\x2ab771f434e617fe7fa580141a01fbe2c72ded5b882f2de2df865ede9ccadf92	3	3085	85	327	342	5	4	2024-05-28 14:06:32	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
345	\\x5884614c098ae4db8472c7df9f7bfa8e4ba789d482fc6f73e1d8623111881230	3	3101	101	328	343	6	4	2024-05-28 14:06:35.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
346	\\xb968f5e0f0558bef8802596dd9628c25ae72592a1c412a650df03d8a0ab9def7	3	3108	108	329	345	10	4	2024-05-28 14:06:36.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
347	\\xae482b7aa33a4a609ca025b42b354dabf65409f96296407eb0dfbba20a6c1265	3	3113	113	330	346	7	4	2024-05-28 14:06:37.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
348	\\xc48abfec2ec6614dc6a7cb828d70e8403be32813c0b3875c0c26635181548741	3	3127	127	331	347	7	294	2024-05-28 14:06:40.4	1	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
349	\\xb3dd567c73f4b065beab2c18e792d4fbf380a91391ef86b885fbc01130b98a91	3	3129	129	332	348	28	4	2024-05-28 14:06:40.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
350	\\xa1972b1431d0b6d26533796e19c6f4ac8fca8d297582d8d9a89cb8ee034edd16	3	3131	131	333	349	19	4	2024-05-28 14:06:41.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
351	\\x7f59d7d1fab6bfa243e196b63ed98adae6caf47cd7ce1b1f449f98a493cff1a9	3	3134	134	334	350	19	4	2024-05-28 14:06:41.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
352	\\xdeb97ac30020ec478e16720d4609c00086cff45d6296b6f5906b09dc48cc98a5	3	3135	135	335	351	4	4	2024-05-28 14:06:42	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
353	\\x1a4699840b0e2d948845ddaad6e37f1eae777dfe22c9031ffc41524f06507ffe	3	3151	151	336	352	6	3850	2024-05-28 14:06:45.2	1	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
354	\\xd474903347f1333b8ba0655efc2fe0542dfec72324821f0a1c0aecd957a06baf	3	3155	155	337	353	15	4	2024-05-28 14:06:46	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
355	\\x9ad583dc86432c409f58fb68b3b7e2d1faad1719241ba93035568778fe861393	3	3159	159	338	354	6	4	2024-05-28 14:06:46.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
356	\\xdade9ab3ac3c22f14a9fbab9c9bbe235cc491cf3c20057603f2981cc3c723fca	3	3171	171	339	355	6	4	2024-05-28 14:06:49.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
357	\\x8bed4311cba8640ee1d074c6e7b1c4bfe44cd44a28b50f08ea722b14fc902aca	3	3194	194	340	356	8	2398	2024-05-28 14:06:53.8	1	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
358	\\x1d8b231e9031e8af54d0b6d32b621ab8e1a85c3c3b9367a705f6d42a0bb52e51	3	3209	209	341	357	8	4	2024-05-28 14:06:56.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
359	\\x7130f7c3729ca7626f22083f4f313d3ae01c1d6ba75958d3e128148143e68399	3	3223	223	342	358	15	4	2024-05-28 14:06:59.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
360	\\xe17de6a95aeed1455356404b2cde381fdec58aef2a45136517ee6565d4a86e12	3	3253	253	343	359	6	4	2024-05-28 14:07:05.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
361	\\xf55ae9fd74a55d8c3f1ec4d4127327c79a08dfec55cee3e58def0751c5788399	3	3254	254	344	360	23	4	2024-05-28 14:07:05.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
362	\\x65cbbb870866dd98082e5e41234391c8e17444d77fdba4de7de34e16dd279880	3	3257	257	345	361	3	4	2024-05-28 14:07:06.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
363	\\x548305cb34b22780627f5db4cdfe2c1a29a49769090adfd01986cba83266c451	3	3258	258	346	362	19	4	2024-05-28 14:07:06.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
364	\\xac20daa75daf76a0fef1c90be0f62d0313a915d2d0325f92dd210b4c8128e8c6	3	3268	268	347	363	5	1051	2024-05-28 14:07:08.6	1	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
365	\\xd89e92121326728cdb23be096216ff935e525fae5874b6fb50af95038652dcb1	3	3274	274	348	364	3	4	2024-05-28 14:07:09.8	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
366	\\xe24c8896b79046c5915b01629d08c59107674abb7efe93afa0109741ea76306d	3	3281	281	349	365	28	4	2024-05-28 14:07:11.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
367	\\x03b57bd6a3597e5eb0a47cf38776060a7b51c982306ded6c3cdfbd24393873f9	3	3293	293	350	366	19	4	2024-05-28 14:07:13.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
368	\\x816cc5eeb2a1573825267842244b845961490dd66026fe4ee0c55debe32456af	3	3311	311	351	367	3	294	2024-05-28 14:07:17.2	1	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
369	\\x323a0dbff6b717b21f213408777266e423db3b23aec31f43f6a9094a3fbc93c1	3	3312	312	352	368	28	692	2024-05-28 14:07:17.4	1	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
370	\\xe9f71be7aa262675a286baa4387ee3497bb59ee6bacc948daa8fc31e63f42ef0	3	3347	347	353	369	8	563	2024-05-28 14:07:24.4	1	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
371	\\x778854dbd249f9017e499619e7f4ab584108ce152abe2bc9ff2b1f4192650367	3	3350	350	354	370	7	4	2024-05-28 14:07:25	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
372	\\x202f3c645c6b0e37bf68f833edf99c81b496ad297445f97b92a57b61c362b19d	3	3360	360	355	371	3	613	2024-05-28 14:07:27	1	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
373	\\x9507fa881a1e5f7449c23707deec556fc48b7c66ee108eddd2691159a9e590ef	3	3366	366	356	372	7	365	2024-05-28 14:07:28.2	1	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
374	\\xa41f966a9bdce103a06fc9714a71782d786a68e7855a2e8247943eadb7e767a1	3	3371	371	357	373	10	4	2024-05-28 14:07:29.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
375	\\x3efa11cd3bdf110e36dcc0a020f30ced7b29acc164fc6c73c09ee4bef3a9857a	3	3387	387	358	374	3	4	2024-05-28 14:07:32.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
376	\\x61ed3235bde5ebb494b1726baba43f07d03224c58ab9ee09e6954ce97a948bc6	3	3389	389	359	375	7	4	2024-05-28 14:07:32.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
377	\\xb525d0e79c6060c1a30432765bd29f2fa04dd91ea323302c680da00835a9d88f	3	3397	397	360	376	4	4	2024-05-28 14:07:34.4	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
378	\\xb05ae9375da139311562a9ff95671f3d70b8150f32828d38ff3544c13314afb9	3	3417	417	361	377	15	568	2024-05-28 14:07:38.4	1	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
379	\\x23620202161bbc63cfdf431144f68b7dcd144cbbfddded8c19905052dc5f66e5	3	3436	436	362	378	8	4	2024-05-28 14:07:42.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
380	\\xb00ebd12892be37416d8b045b2cc9152f9eec4ddf467425e15cab0b5c5d7cc28	3	3460	460	363	379	8	4	2024-05-28 14:07:47	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
381	\\xbda0bc8c72e4a88a0c40af2e9122c7ca13e63df24752c00cd590af29e3377766	3	3491	491	364	380	3	4	2024-05-28 14:07:53.2	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
382	\\x4707f997ad927816d99cc0a2b2aab205fef008facfe188d4189031548e6518ba	3	3501	501	365	381	7	4	2024-05-28 14:07:55.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
383	\\x817ba1f11acdaf8687e7284230f1dd717691f32beca48788f16c6146f0af0707	3	3502	502	366	382	19	4	2024-05-28 14:07:55.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
384	\\x8b9d401e52b5787c302cd05afe391d810506c33e8fe41cec7d4e8d16c4e436da	3	3522	522	367	383	28	4	2024-05-28 14:07:59.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
385	\\x8a28b1651963db2adf1f1be230222d7cda8648ccebcbae45909dbd389c7c4b7d	3	3536	536	368	384	10	4	2024-05-28 14:08:02.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
386	\\x37d3367b9cad2be307ae042ee298824d2a47dcb4749d199053e598d5da9fa472	3	3551	551	369	385	5	4	2024-05-28 14:08:05.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
387	\\x32b1d1c038be1e2b7e27bd4b6cbc0cd974cfcdf835c9a7081b14fa7f0d9af953	3	3565	565	370	386	28	4	2024-05-28 14:08:08	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
389	\\x82c0f9741cda60cf6a6d3f0a294151ddfe62313de82079ed023b9d020c0d5b08	3	3570	570	371	387	7	4	2024-05-28 14:08:09	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
390	\\x5c3a7f506ff3a6753ab504419a9525bcd999d285200102f6758e67c0f18e8f18	3	3573	573	372	389	28	4	2024-05-28 14:08:09.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
391	\\x44249ec7ab5ea7bda26f83b2dc28c61eb3076fde2a7c3a757ee65dfcfac090e7	3	3581	581	373	390	10	4	2024-05-28 14:08:11.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
392	\\x5323a2bdbf08ee17f08e78e1403493a862d2f2c8d0e8cadb8b94629294d46bfb	3	3585	585	374	391	8	4	2024-05-28 14:08:12	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
393	\\x975bae8fca4ef001cfb022e25d66ad17efd0d0adc2122441f1f7e504b7e0de64	3	3601	601	375	392	6	4	2024-05-28 14:08:15.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
394	\\x8f5e43b2aaec3edbca5599d9b318e8977edd415a49ac77bbceeb6ab3afb03965	3	3615	615	376	393	23	4	2024-05-28 14:08:18	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
395	\\xc87273ae5058f53141276c6d74d71459dd254195d736f774045f3df2fc7ab106	3	3621	621	377	394	23	4	2024-05-28 14:08:19.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
396	\\xa9d17569224af94bed20cebf18cb2d7c04837dbfa440b1ce9a1560cea20dfc50	3	3627	627	378	395	5	4	2024-05-28 14:08:20.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
397	\\x00fa8b1a860d1777bc5aed3071f8570af0207475d559c2002c7a6824a0335294	3	3629	629	379	396	7	4	2024-05-28 14:08:20.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
398	\\x6c6080f1f60b81f526c3728292c756cb270cbea1a1b4516f2e99d82be9cb98db	3	3653	653	380	397	3	4	2024-05-28 14:08:25.6	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
399	\\x7c20b8f1e77e61fa9e3a49a2d90a0580b5457f6064897be11439c8aca4058c83	3	3657	657	381	398	19	4	2024-05-28 14:08:26.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
400	\\x82156fc90d2331ccbb145f520cba5057ae377da967afd3dcbcf63904459c2873	3	3660	660	382	399	10	4	2024-05-28 14:08:27	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
401	\\x386a4cd45054426521469fc4ba004ca446b4e6c3fa0ea855fc37891a8e75a089	3	3661	661	383	400	4	4	2024-05-28 14:08:27.2	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
402	\\xa3044d16638f8ee356f0a690a14c3e133afc056435b1ea0b62b2c670b010cc4d	3	3663	663	384	401	15	4	2024-05-28 14:08:27.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
403	\\x782cde5bf9640de248ab381278795c10222539a70e6ee3f11d776b5d80126bb2	3	3667	667	385	402	3	4	2024-05-28 14:08:28.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
404	\\x736c985f440ac58d33164198a88d9328a2349c6affe0d4cc128a98ced7f269fd	3	3668	668	386	403	5	4	2024-05-28 14:08:28.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
405	\\x0bc24a60b7a22e9adb1752599315aec75aeab215678854c6a8318d8f1fed8e73	3	3669	669	387	404	6	4	2024-05-28 14:08:28.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
406	\\x4261d745183a4282a61fcc4e9e330207a6a26afa58c65c182153d70dc598572e	3	3672	672	388	405	7	4	2024-05-28 14:08:29.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
407	\\x014fd32d0331d9d778251700c2c1be9048e84064104e2adaaeab543606dd12bf	3	3686	686	389	406	4	4	2024-05-28 14:08:32.2	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
408	\\xd431a01cc5149fdd807df3de9cf70753ce406fe78da8e0a9f014b21af5b5ea1b	3	3698	698	390	407	10	4	2024-05-28 14:08:34.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
409	\\xa306077b6a7e92ed0946e1777d3fb9ccda5ac4125ad77314093b526e65884a3d	3	3712	712	391	408	5	4	2024-05-28 14:08:37.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
410	\\x48de30c9418946fcf9779ed429b047f6f0cfbec08e5a6a12bddfba60f3d6b58d	3	3729	729	392	409	15	4	2024-05-28 14:08:40.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
411	\\xa39d3e14d9c0a3bf157d571b3be7c5d56ea8726450bb91c6e5043a60f9a162b2	3	3742	742	393	410	15	4	2024-05-28 14:08:43.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
412	\\x301451a98cfb48f6e08cf98ab9aa140a1fc809be8433d9f356f526f332bf2f4c	3	3748	748	394	411	28	4	2024-05-28 14:08:44.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
413	\\x5d870fddab75f1a3822741ed26b240a3b8ef1f54ac056ecf25b1fb6e64ee2fee	3	3752	752	395	412	8	4	2024-05-28 14:08:45.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
414	\\xb43abdb61800521bf2cb90539a6cbefdd243f0b304f680ee9110c92ceae36bb2	3	3767	767	396	413	4	4	2024-05-28 14:08:48.4	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
415	\\xccf4fee4170f52f79f2ec8b7aeac11c26d66bb82d5eec4af41632b7b37653011	3	3785	785	397	414	28	4	2024-05-28 14:08:52	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
416	\\x2135da8e6342771b4e289c3ba0c873b1925bb300619dfdcd2d90c3e79086c84a	3	3787	787	398	415	28	4	2024-05-28 14:08:52.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
417	\\xbebe00c9a3ee562ed65c81fb2333cae632ca3bc9000904ab99d8045977ac4694	3	3804	804	399	416	7	4	2024-05-28 14:08:55.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
418	\\x96431ac629497dd6deea5959059393b3f6e38476c7599520752fdb2aa1556eb1	3	3831	831	400	417	15	4	2024-05-28 14:09:01.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
419	\\xe5a8a4a76b71df4ce401c343163b1894fbd327bc8803a0f61eeec07cbee1536a	3	3835	835	401	418	19	4	2024-05-28 14:09:02	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
420	\\x569298d95a102ec4ec14ce0697cbe2155b4b8dfec391baedb6c9c3926e3dde00	3	3841	841	402	419	3	4	2024-05-28 14:09:03.2	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
421	\\x417669b5ebd2d4a0728fa3a67c34813e3b4d4b7e84d1eaf962ed35f16f2bf4cb	3	3864	864	403	420	8	4	2024-05-28 14:09:07.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
422	\\x325586388fcf5b627555fc31b5452ab60b39b5a540829719cb24b9b56425cc90	3	3874	874	404	421	28	4	2024-05-28 14:09:09.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
423	\\xcbebda66983e74400e2c0596dd2ea1c7af7665eed2f74093e47c69cbe622e4e3	3	3877	877	405	422	3	4	2024-05-28 14:09:10.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
424	\\x24bce65d7e3e857cad56af9e795f9ef45dcff0a59ee9166208cffd89926314e9	3	3883	883	406	423	7	4	2024-05-28 14:09:11.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
425	\\x71208875bd68f52318305ce1b1dd6b6f987e8c68dc5bba177e22948128c684bb	3	3894	894	407	424	8	4	2024-05-28 14:09:13.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
426	\\x86280a9a1d5c8c150e4b1535e9cfafcac3658edfeb722ca46cfe7a290d15f24c	3	3921	921	408	425	10	4	2024-05-28 14:09:19.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
427	\\x2c93e6aa72026c26ec7c848f48e261e7696e3ed14a76dd38ef67a15186103b22	3	3932	932	409	426	8	4	2024-05-28 14:09:21.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
428	\\x1838076c0dbbfa98366cb3c564a376973baec2eab082aa7a88a1e9a943f249b4	3	3933	933	410	427	3	4	2024-05-28 14:09:21.6	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
429	\\xb3ef88272dbd9054220dcb0b1715424d0eb14d7dd179b2297864a92a08ebcd8f	3	3939	939	411	428	6	4	2024-05-28 14:09:22.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
430	\\xd57cea3b7498bcb74ec90fb8cb3c63abfd41d388096febf55407831efed417a3	3	3946	946	412	429	15	4	2024-05-28 14:09:24.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
431	\\x56ffce52a9d352109a7f1817ae5ff4d60849ce72529f602ffefa8ce12f6280b3	3	3949	949	413	430	15	4	2024-05-28 14:09:24.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
432	\\x63e1171b8758300fb02bba4cd6d8db3b323cda5dd66554db0c31b358d766a034	3	3951	951	414	431	4	4	2024-05-28 14:09:25.2	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
433	\\x10ec8133b6ddc46ea19623fab7dbb971b28309db7897f714b3defcc01f9bc454	3	3959	959	415	432	19	4	2024-05-28 14:09:26.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
434	\\xa0830d91db5405143cc48b71b85c22fe80c949ac00203748e9da0d480a2dc8ef	3	3974	974	416	433	19	4	2024-05-28 14:09:29.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
435	\\xd691069fd11bf92482e988b3dc9b5710a05eb36c7e08d58e4a6bcd1c2aff962a	3	3990	990	417	434	5	4	2024-05-28 14:09:33	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
436	\\x4042cf773876f046f1b5ca190658f2e7ed9eb70cf193ae3f1c8f9e41243060c8	4	4003	3	418	435	19	4	2024-05-28 14:09:35.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
437	\\x52fa619e4954575fd4689016402d422b882f73086c64fb097c662dc37c21f96d	4	4004	4	419	436	19	4	2024-05-28 14:09:35.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
438	\\xafefd884bb11b4c212d3902b8b45c282171882d858edfe6d3a40d2c98d98f5e0	4	4008	8	420	437	6	4	2024-05-28 14:09:36.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
439	\\x2f26dddff8f4237fe6f702a15992e969f19b3f478f7acc4915b2c6443102f089	4	4033	33	421	438	7	4	2024-05-28 14:09:41.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
440	\\xa1c3827eb684ffe0e95406d351e232ba6c4cd821b56054352cc6bbc152e1f458	4	4042	42	422	439	28	4	2024-05-28 14:09:43.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
441	\\x343cd900db30f935bd34e110db281a35402cbdbaff7f61f53db13541b89e9e39	4	4047	47	423	440	8	4	2024-05-28 14:09:44.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
442	\\x86ff71770cfe0a19de173df5e2ab6505aba9e744fd81333b81e2413542882fe5	4	4051	51	424	441	3	4	2024-05-28 14:09:45.2	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
443	\\x6198af1baf8f0b247337ebadbdfcfb79dfd81feb0cedf0f8574b60acad13dc03	4	4054	54	425	442	5	4	2024-05-28 14:09:45.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
444	\\x7d6eb9e36da3faa3ab1d846ebdca704219b25ea1038c589f54d9530fa6b76856	4	4057	57	426	443	7	4	2024-05-28 14:09:46.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
445	\\xf51961022cb7a828763e0b646bdf478979278e3ddf05ae597b611b2c19f2f2df	4	4059	59	427	444	6	4	2024-05-28 14:09:46.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
446	\\xaa0c14f6199267684a6ba6ad555f7778c0a5ea7952872b8c4ccd8c7cadbce859	4	4060	60	428	445	8	4	2024-05-28 14:09:47	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
447	\\x9a31930255004fcaa737f7ee7cfb3cf81b1eb43998529d8dce34763fdb76d0da	4	4065	65	429	446	19	4	2024-05-28 14:09:48	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
448	\\x3a11c23f80ac559563685fceaeae7dd95068731015e81af885af6cd0e1c0eef6	4	4073	73	430	447	10	4	2024-05-28 14:09:49.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
449	\\x9ad053ca3fdc14c4d92cd455236aa45c189d960d48372c3abcc62609811f7350	4	4099	99	431	448	7	4	2024-05-28 14:09:54.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
450	\\xa3aaae0e8df35e569bce90665a424e9da280d9d3eb3f91f6f24cb3f78c7f7a03	4	4117	117	432	449	10	4	2024-05-28 14:09:58.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
451	\\xf1e47f3affaab688aeed50000fdb7ff7312aa20427a37471d32f720537a1e14f	4	4120	120	433	450	15	4	2024-05-28 14:09:59	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
452	\\x60f66b6f54b31fe482fb2d3d804074ca31e20a0026a93a4f47172ad4cfe44a34	4	4126	126	434	451	5	4	2024-05-28 14:10:00.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
453	\\xe8c01d92e5ba5579e5ac67611971eb0e73d792e78201e588cb17e84b9727134a	4	4142	142	435	452	23	4	2024-05-28 14:10:03.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
454	\\x48fb7172561518b6a7747f13f286c7bd542ea4ef260a7d3dfac2d035b099ad56	4	4147	147	436	453	28	4	2024-05-28 14:10:04.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
455	\\x9571047c697b06ac6319c93b5f1023af93f7c7011cb6c030fd61470c0b5f1e11	4	4151	151	437	454	7	4	2024-05-28 14:10:05.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
456	\\x62b7b7db8e04edd65b62af0e43f3cbbfeb6aba908bc1c9e71c4db048d5614fac	4	4162	162	438	455	28	4	2024-05-28 14:10:07.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
457	\\x6cf61bee1cd02781601df4622bcf4ce90e0f1d512375020ba66a404d4e6aee4c	4	4173	173	439	456	5	4	2024-05-28 14:10:09.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
458	\\xdab6e7bc85f4db383dd6dc6fa26514f654ddfecaf15fecf213870be90f0341df	4	4181	181	440	457	15	4	2024-05-28 14:10:11.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
459	\\x325b621d138925444085d5d42631ed4eb8256b9dea799751e0706993cec6a4f1	4	4196	196	441	458	7	4	2024-05-28 14:10:14.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
460	\\xbf867753816873c52dfaee2c1ca5d8128a4b990faa8a1ed2080f25ccf89ac006	4	4203	203	442	459	7	4	2024-05-28 14:10:15.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
461	\\x5b48b0be6debd3219d48f0ab7ffb27f8f84c1244b4c4e07a5dc20a402657cdb2	4	4207	207	443	460	23	4	2024-05-28 14:10:16.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
462	\\xf366d0f09ce55a0273b433ba172ae6280ae91dc8bf45a7cfb37154f58cae7eb5	4	4210	210	444	461	7	4	2024-05-28 14:10:17	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
463	\\x889c73b89049389b5f64bb7908c3e59be915e11f6b2e81b835ea7c14c69d7f3d	4	4217	217	445	462	28	4	2024-05-28 14:10:18.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
464	\\xb3741f720ae7933bfcce8acbe039152073ae1df5e92d5a55d5c85a84c6659bc8	4	4220	220	446	463	8	4	2024-05-28 14:10:19	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
465	\\x93e142ead15f12305a573dea2df7c3202fd113a246627a6ff56e6a3d7f680924	4	4222	222	447	464	7	4	2024-05-28 14:10:19.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
466	\\x62eb2fb8a1523f65d760fc82067a8298ac2426d39ff4cad6c0522f65d208a114	4	4223	223	448	465	6	4	2024-05-28 14:10:19.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
467	\\xb9b97ed878bd78e8e27f865d2ca6fd19917291c288c4fbbcc7cb521ac09222ef	4	4225	225	449	466	10	4	2024-05-28 14:10:20	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
468	\\x5e9d09baa4c24566c2b7c184d9302a56b3094ea8f342aa9733e70e98b2d44eb8	4	4231	231	450	467	6	4	2024-05-28 14:10:21.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
469	\\x99cc101495a76a9d068b4a9b6a2e8905342306f807b50cb24dedebb9d30cd5ee	4	4234	234	451	468	23	4	2024-05-28 14:10:21.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
470	\\xfebaa2d0ca0cfd00d59db449a429273fd714132f88bac1c85e884b1a407c45c6	4	4267	267	452	469	7	4	2024-05-28 14:10:28.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
471	\\xe2b2ec74c0f850eb33234da1a55dc335309f50bbff240c2b029cc371e739084d	4	4277	277	453	470	7	4	2024-05-28 14:10:30.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
472	\\x8437d8f3a85891008197f85a4469f4b5e61218ae99a12188a4794cbd2f0987aa	4	4291	291	454	471	15	4	2024-05-28 14:10:33.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
473	\\xc378bbf25518b0abb1347965e2548ab69e793844911a9f3861179a23a38120bf	4	4294	294	455	472	23	4	2024-05-28 14:10:33.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
474	\\x648fa14e2ec8c67c588896dcdb7903e3be09d22b25da870ddc4b174c0d97daa6	4	4295	295	456	473	8	4	2024-05-28 14:10:34	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
475	\\x2956eafb6a38bbe12555f04bf152ec7542da6dc63935a82c7dd7cfe288bc73e6	4	4301	301	457	474	19	4	2024-05-28 14:10:35.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
476	\\x4b2fb274256ddad6c0cc54d0c10e10088b6ee59c1115d3758a621cf767d1c9f5	4	4314	314	458	475	15	4	2024-05-28 14:10:37.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
477	\\x40416625caad0bce3475b23bba41715498b10d6c094860977e603283f21e2184	4	4344	344	459	476	15	4	2024-05-28 14:10:43.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
478	\\x9f7eef27a440e80e57ca06d5234ae4565b5fed3179c1f1b5ada7c707aee9f130	4	4347	347	460	477	5	4	2024-05-28 14:10:44.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
479	\\x7d9278e56cb30beb3f5bbe7bebb80079c2ddb5f364e5963a9bbc95521d98033b	4	4349	349	461	478	7	4	2024-05-28 14:10:44.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
481	\\x1468a5df18d6abfd0a79eb58b4566d5a6f7bba23edd4d9420c703a26abfe6368	4	4357	357	462	479	19	4	2024-05-28 14:10:46.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
482	\\x07169ee57b2f56157c284066b315119330df85d38429c99a22dcb09b85544cae	4	4363	363	463	481	5	4	2024-05-28 14:10:47.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
484	\\x22630309867c3d2aa01fbc8b3f78f31adff5df5e8006e2f2e62721990dbbeaf7	4	4384	384	464	482	7	4	2024-05-28 14:10:51.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
485	\\x4ca22c38bdb3269f6447e373d6866d2e4f8a266e587f0dec2638091531b6f56b	4	4402	402	465	484	28	4	2024-05-28 14:10:55.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
486	\\xbf5201eb99bab7088df2586ec03bb5f54f470e3fac1238056662d3f5d686b46b	4	4409	409	466	485	10	4	2024-05-28 14:10:56.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
487	\\xfe75961e01b8977bc5eaeb50f2f140af27e2274152d24fbc8e05a991ed9d75af	4	4413	413	467	486	28	4	2024-05-28 14:10:57.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
488	\\x3cf45a6994cc4983ef6ab1505fa38bdf66e8e639fa502e37e02a83461f2f8c08	4	4417	417	468	487	19	4	2024-05-28 14:10:58.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
489	\\x36e778c4fd078176ff60f93b034e787067ad8bf806eee114e362e333b7a2786c	4	4430	430	469	488	10	4	2024-05-28 14:11:01	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
490	\\x6db31622017ca9ddae439b438b1d65af328a424ae8773cf5d04502c549870623	4	4435	435	470	489	28	4	2024-05-28 14:11:02	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
491	\\xc1f167284ffbc9bc6ea290cc1b6bfa4271569c873cf2a36a0c31e99f8758f0bf	4	4444	444	471	490	23	4	2024-05-28 14:11:03.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
492	\\x954dd16321f1634527ebecbfa09ce292b5a827d94a59ff2f6cf1da6dd87f1364	4	4458	458	472	491	6	4	2024-05-28 14:11:06.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
493	\\x48f903261f06f6edbc22d32242ff343f560b5a449d4bb00d2a181e17f4f37d6b	4	4462	462	473	492	4	4	2024-05-28 14:11:07.4	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
495	\\x5af2ab2ae87e640501cd699142597b980657dedae42ccfa39a6bafe93df0ef74	4	4477	477	474	493	7	4	2024-05-28 14:11:10.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
496	\\xeb58ddf2e147195ee6426fce24a160bceb9eea3653144275abfa22fbc7b268fc	4	4491	491	475	495	5	4	2024-05-28 14:11:13.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
497	\\x3de7368ca4d7664af4dab653de4a4383859b3d70960e1b6196d2ce61bdebd39e	4	4500	500	476	496	23	4	2024-05-28 14:11:15	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
498	\\x112d636a395da7c6ce2b319256688788b26d335c6129060b1ecfad6858df6684	4	4510	510	477	497	5	4	2024-05-28 14:11:17	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
499	\\xb075a848e37de01b9068f01e5771bab543d16940a36be7bcaa796a2a75d2d744	4	4520	520	478	498	28	4	2024-05-28 14:11:19	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
500	\\x157c2797d4e8e715f0957e486796b93e6026b9b275f63fad4a280dc1ee1d83fa	4	4529	529	479	499	10	4	2024-05-28 14:11:20.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
501	\\x45e186a022e65a22487e40420df50931030b8692092b05f9dcb429056909b6e5	4	4544	544	480	500	15	4	2024-05-28 14:11:23.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
502	\\x1b1d759b72cc74edb44ee67a777a4c941adc29bdc48948b20b94ebae290e656c	4	4562	562	481	501	6	4	2024-05-28 14:11:27.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
503	\\x22f82af9f220431438fe3b9335e4cdf06b7e771c661417bf5be60a4f05b8f48e	4	4579	579	482	502	7	4	2024-05-28 14:11:30.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
504	\\xeaa5f58afa491e5ddf2706a411fb50aeffd66a3adaabd31f659717ff9322bdf7	4	4598	598	483	503	7	4	2024-05-28 14:11:34.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
505	\\x228027976de822073190e1f1b2d12f9fa7353cf0ff4dcb5547cffebf6365713e	4	4604	604	484	504	23	4	2024-05-28 14:11:35.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
506	\\xb85933413a9403ea1407cc539a1caf817146b9308226ba3a330ee521c58cbe9d	4	4610	610	485	505	7	4	2024-05-28 14:11:37	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
507	\\x4190d2eb2298ab60bc03ae9022d014aa20e5d5e797456a35aec34e9d34e4f3f1	4	4617	617	486	506	28	4	2024-05-28 14:11:38.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
508	\\x34e2bfb45bd15a64e3722adbea988ac216725632359ef3db5997588a224a190f	4	4637	637	487	507	8	4	2024-05-28 14:11:42.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
509	\\xf1daa54900672329e0bdcd3f2eb96057637cf7a471bfe00c9df34ff00a0115d7	4	4647	647	488	508	5	4	2024-05-28 14:11:44.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
510	\\x3f93498564bee066b5b2b74d9f97a79b86022851476bbff46e7e7d8ec92fbb10	4	4651	651	489	509	28	4	2024-05-28 14:11:45.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
511	\\xf3c28d5007c988481d8d0d30b3413cfe3398abf291803558be88dc769c16de0e	4	4667	667	490	510	28	4	2024-05-28 14:11:48.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
512	\\x6c69dc33673b309075993a75329ee12da9634fd2c57f81b74e17f7621ad971b1	4	4668	668	491	511	19	4	2024-05-28 14:11:48.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
513	\\xb723f491fc2cbfc4bf195446b10ef8bce3848d503ff8191b9b48864594c9807c	4	4693	693	492	512	4	4	2024-05-28 14:11:53.6	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
514	\\x859363b4530083565ec0e770d6c113e658d02d614baca24b35b65628533057c5	4	4709	709	493	513	10	4	2024-05-28 14:11:56.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
515	\\xbd490a8a1007a76e346930d560d740d0b0f8b2dc2087ae6313b0d4315b3b9fc9	4	4720	720	494	514	8	4	2024-05-28 14:11:59	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
516	\\xfb0a1e7432b640c3ac5ff8b34381cab0a75df82938c9a61961d1d02c8819b8df	4	4726	726	495	515	4	4	2024-05-28 14:12:00.2	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
517	\\x58933f20e2b122a4b90f4dc4adb8df3ec85be617473da986bb9cd386cd0d81dc	4	4743	743	496	516	4	4	2024-05-28 14:12:03.6	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
518	\\x22f9b3f7df72d9a7a5cff35ef7baf3284610e01b9b538a31371624762271a931	4	4744	744	497	517	23	4	2024-05-28 14:12:03.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
519	\\xa9731dd77fe66fae6a276e4f9349662149a9a490dac5ab938cfdcd61a2aac353	4	4746	746	498	518	6	4	2024-05-28 14:12:04.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
520	\\x2bb2e3c157d360eed2492ae8504edd1650060d9da5bc16ea819598b60b769bae	4	4747	747	499	519	15	4	2024-05-28 14:12:04.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
521	\\x313a664eaa05b489ebb430b2e3d0198ea845ff05ced41fc8511547cdde5019ef	4	4749	749	500	520	15	4	2024-05-28 14:12:04.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
522	\\x800caadb54d63be50585949d9eb5d6f66a027d3a3249f36e8cfa74801550c8a2	4	4750	750	501	521	10	4	2024-05-28 14:12:05	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
523	\\xf17d059e28434cb01ba860ca13c73e3bf8ccf7af49ddb7468ce5250c22759020	4	4751	751	502	522	28	4	2024-05-28 14:12:05.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
524	\\xac190a6b178f713149e9bfb364f56ecdb17d20520fcb372f7814171a4c938c58	4	4753	753	503	523	28	4	2024-05-28 14:12:05.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
525	\\x97716a2fd6412100a7fdaf6441167b34a95162df50beca122798a87ff5ba3cd6	4	4760	760	504	524	7	4	2024-05-28 14:12:07	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
526	\\xa9aed33ef10d0d00b84f20917e2bcc36abf61972b312ee79b1aee2a91403e3e2	4	4767	767	505	525	15	4	2024-05-28 14:12:08.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
527	\\x51aabd504757a9ec973fa6d9f76be38fc44bf493f2d2feeeda11762a48a69ad2	4	4776	776	506	526	23	4	2024-05-28 14:12:10.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
528	\\x168fff398cde3565ca0028ea1c4fed0e832107df8fbbe29fc10bf883cfdf44dc	4	4794	794	507	527	3	4	2024-05-28 14:12:13.8	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
529	\\x6999f2ea54a6673838cbeb44fdb33199c18da62d46f6aa27561062f2565e6fb1	4	4795	795	508	528	19	4	2024-05-28 14:12:14	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
530	\\x4df1ef779cce2218377817e06418c0dad976f71c05bb9b89fd086af5d5877657	4	4800	800	509	529	15	4	2024-05-28 14:12:15	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
531	\\x28d55df762285668bebfc2b8a5a8ec7ec10470979afcd04fc1112dbe01dfcf32	4	4810	810	510	530	8	4	2024-05-28 14:12:17	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
532	\\x3f5dce015975a75867fb1f768fe944f940006aecfb8d494135bb8ad74c005412	4	4818	818	511	531	5	4	2024-05-28 14:12:18.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
533	\\xb8b79bea2d2d29372e8ac09c27c37b7f74bdd0c034fa118abab3da70ce220257	4	4837	837	512	532	3	4	2024-05-28 14:12:22.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
534	\\x9d8df8f6049b15871414a81b9dd7cf6ef07d368eea0d425255d3d849e7059870	4	4839	839	513	533	8	4	2024-05-28 14:12:22.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
535	\\x188bf70794ad1234089494a2133777df87e1d30ce9fd995fe05afe301328caa7	4	4846	846	514	534	10	4	2024-05-28 14:12:24.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
536	\\xefdc629aede9e81e951461cac011c5e3aff949c916e519141dc4c18ac0267e2d	4	4864	864	515	535	4	4	2024-05-28 14:12:27.8	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
537	\\x8db41dd594a077c0b5e8fb22012c7e60cf82953860b06f4692852d46d868c0c7	4	4871	871	516	536	23	4	2024-05-28 14:12:29.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
538	\\x0039b9657f3ed91d66f15d78e21b891baa223bb51785b5abc996464731649449	4	4874	874	517	537	10	4	2024-05-28 14:12:29.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
539	\\x0a1ca9e775a080b64f45d02d6ff3d684c32ecdfd2df38d092e5b0269f948eac4	4	4875	875	518	538	3	4	2024-05-28 14:12:30	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
540	\\xa43d6ad90466f926d781897d41c9147ceeee741eee46639a5dc9a5ad39c4f15d	4	4882	882	519	539	23	4	2024-05-28 14:12:31.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
541	\\x5bc1e84c44c705d25ce91826ad51e16f700b86e5adc29562c42e1c3d75775011	4	4888	888	520	540	10	4	2024-05-28 14:12:32.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
542	\\xb785aea043b2bdec5ec694455f005a1c99d61415ffd153145ade27f1dc06d5b0	4	4890	890	521	541	28	4	2024-05-28 14:12:33	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
543	\\x1db8f766ac95bd463e31fc97a9f88b9a53391838a60a76a53cc1aa8bfa17657a	4	4891	891	522	542	15	4	2024-05-28 14:12:33.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
544	\\x46d767270e06b6524acaa59840fa4ce461a9abb80a1c7ddd5e0f5bf0d96eb094	4	4897	897	523	543	4	4	2024-05-28 14:12:34.4	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
545	\\x0c2434fde1ad67f94bfbc16caae64ec32db805407cf6bb0c1ea4db5bcee14552	4	4898	898	524	544	3	4	2024-05-28 14:12:34.6	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
546	\\x6615d34146479e1a7098d6c54a4851a6c4f5da2d6c64e047fc2d2608d690abb6	4	4912	912	525	545	3	4	2024-05-28 14:12:37.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
547	\\x244a8e1722e6727a816123eb133bbb86eef17b9226455ca271b4502a4afbfa08	4	4928	928	526	546	3	4	2024-05-28 14:12:40.6	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
548	\\x3cdefbb4f77e1a49ea8f2289172162b66ad7fd3b16dc6ac04cca87dda07a76de	4	4937	937	527	547	6	4	2024-05-28 14:12:42.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
549	\\x6be816eba346b2ab92432aaf407f3098f5c6e5f4648836d7b1e2de635400c5bc	4	4948	948	528	548	3	4	2024-05-28 14:12:44.6	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
550	\\xd3d1b5231968b59a06a087d8642283ae8d5ac95f5b8ea21b20d504e3794421d5	4	4952	952	529	549	4	4	2024-05-28 14:12:45.4	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
552	\\x31410126cdc19881643ee9fa122ee869ce34573ecc572effb18ff86b90d645d0	4	4966	966	530	550	3	4	2024-05-28 14:12:48.2	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
553	\\x179478919c146cb2ee94334a59a996083650cf299c8733d2e931f6de05b0b237	4	4971	971	531	552	10	4	2024-05-28 14:12:49.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
554	\\x06a05a8301df7720501fd1f85bdae0f86bd4b26be17fb0cefb3ce1c7354f00ba	4	4979	979	532	553	7	4	2024-05-28 14:12:50.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
556	\\x078b9a57bf930a0bf9c9e388d600728e2cb92cc96802851201ca5a53cf247335	5	5004	4	533	554	6	4	2024-05-28 14:12:55.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
557	\\xbee87a45b45e96ba0d087ac09df56cf1d5201802072a77085fc4691e2d008e62	5	5018	18	534	556	23	24709	2024-05-28 14:12:58.6	82	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
558	\\x4649487a920c0daa982e3da42c0a6a3a88e6513d6708de7d5395534e2746460e	5	5020	20	535	557	5	1288	2024-05-28 14:12:59	4	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
559	\\x5cacd6443eab05939de3eb90e61cf45abe8d9e6bafefc6458b6f6a7f62f3fd0e	5	5028	28	536	558	5	1517	2024-05-28 14:13:00.6	5	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
560	\\x77c703ac57521f8b40d934baf4301d80d3573918986799602266ac60f2205636	5	5032	32	537	559	28	2776	2024-05-28 14:13:01.4	9	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
561	\\x267b8f7cd01e12219af1e42f00298e73523fc4f3e91a84413225f2409050f6f4	5	5035	35	538	560	28	4	2024-05-28 14:13:02	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
562	\\xdc1ff8535694635225cb68aa66cd87091d60f39033360848bbcec1d18e281b7e	5	5043	43	539	561	6	4	2024-05-28 14:13:03.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
563	\\x53f71470c71241457cbca587288a5c99524abb61d34ac303767d22a616183ac7	5	5060	60	540	562	28	4	2024-05-28 14:13:07	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
564	\\x715a79888c24bb92a514b3fc41658f577877cb04f50d66bf5be968cc67adbca2	5	5066	66	541	563	3	4	2024-05-28 14:13:08.2	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
565	\\xc070a274f71a571532f8109fca97d98ffc9cd24c902ab4d1d8917f0921c212ac	5	5069	69	542	564	8	4	2024-05-28 14:13:08.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
566	\\x101234413129cd0a8c48affa97f3c2219527a2119a06d1f2e79f82be51de8574	5	5070	70	543	565	23	4	2024-05-28 14:13:09	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
567	\\xd0ef5327db97125f7e4025e06d97175a85cd7f5acfeebe74aeab3b13e8a7ae10	5	5088	88	544	566	3	4	2024-05-28 14:13:12.6	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
568	\\x5b2fbcf94300e612c4df2881c974a0ab3131f8d604fc3c2a9a158d230bb7625d	5	5092	92	545	567	8	4	2024-05-28 14:13:13.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
569	\\xdf7e44fd0f792c9ca44f1a48a7edad94ab83aa6db14da2af77786cd8e22b6cf1	5	5106	106	546	568	4	4	2024-05-28 14:13:16.2	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
570	\\x9a9499c09f6139017e987066ae8eec4bc21ce92c5df509a9f88c921f84bc4839	5	5120	120	547	569	3	4	2024-05-28 14:13:19	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
571	\\xb45c437c3fc61fe65ad905e58964829aa13c5af814a9307000ddd8f8061a6bc3	5	5121	121	548	570	6	4	2024-05-28 14:13:19.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
572	\\x47fc6d9bb08e5e63a6209b22c7d6daa4451d6a158e057928c90a231f1797a76a	5	5122	122	549	571	10	4	2024-05-28 14:13:19.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
573	\\xc5910d363caeaee957343e5f2d43abeca1a282db4f3713bc9b547f26590c065a	5	5127	127	550	572	5	4	2024-05-28 14:13:20.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
574	\\x0654664d7b3967b92f012e2ab523f16594a05546d4d84f97d90a74479109ac1e	5	5136	136	551	573	4	4	2024-05-28 14:13:22.2	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
575	\\x4c4b20d7b6c7b000eb04ea399b23df5dd1b28aba5bc257cd8c061248fb873e48	5	5164	164	552	574	6	4	2024-05-28 14:13:27.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
576	\\xf09961209b071bf0262bc0eb46a2a256ca559d5a90aa8f3b10c9d3918ceb62f1	5	5177	177	553	575	4	4	2024-05-28 14:13:30.4	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
577	\\x730d893536a1689a56fa6ff9f624d5bd0e1b9435d75ffebf4fbc96fb7269ef47	5	5178	178	554	576	28	4	2024-05-28 14:13:30.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
578	\\xe690fde5491355f916b22f4029dd08c275825b4a14e7ab9192ea81d7e677e492	5	5188	188	555	577	8	4	2024-05-28 14:13:32.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
579	\\x9b871b6ae50d2a99766b108acd99de944459dd3300917ebab09976c3b7ec45ea	5	5195	195	556	578	28	4	2024-05-28 14:13:34	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
580	\\xaa20f0dbeb21c06bd8bd50b900f4fbdcc21cfbacf79f9c90aac68083a3e54c38	5	5210	210	557	579	10	4	2024-05-28 14:13:37	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
581	\\x5cee23b02e9be2e36265daee004c7d1bb06f9ef336bbbb88c662d2584054abe7	5	5219	219	558	580	8	4	2024-05-28 14:13:38.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
582	\\xa86f24abcc6d34f2a7d3ac03743785b3ced1aba277860618dbe9045de6de838a	5	5221	221	559	581	8	4	2024-05-28 14:13:39.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
583	\\xf141213e491f76fe428a68533c3b9b65f9bd36604ea53322875d94f1a113eed9	5	5224	224	560	582	5	4	2024-05-28 14:13:39.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
584	\\xcb1574b17bd7f2a16dbdfc3b14aa3bad62c2d30d33eb6a7ab17ba2fc92a06908	5	5230	230	561	583	28	4	2024-05-28 14:13:41	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
585	\\x62dc00ca57637f151d26fa201f5113216ca953132969cd7d2102b6821d0820f0	5	5250	250	562	584	5	4	2024-05-28 14:13:45	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
586	\\x1001a960f39be85c425df15ed3003defc640da0a8d6b3e64033bb707c1cadd9d	5	5265	265	563	585	10	4	2024-05-28 14:13:48	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
587	\\x0fc7e6605bf4fdb310478e410020fa73042af3f3d591f2f1caeda19008fd3338	5	5268	268	564	586	8	4	2024-05-28 14:13:48.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
588	\\x7ac85b925e4d5da2292684a9c3541c3e750b457475af73cc05f57d5d1f54cd5b	5	5288	288	565	587	7	4	2024-05-28 14:13:52.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
589	\\x2723c53d4f9b1826bd0308349b8fa535b68fe851cd5df9e86fc62a9d505235bf	5	5301	301	566	588	7	4	2024-05-28 14:13:55.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
590	\\x1ad2cf29c812041709bb41969b7247adf3723b1e8f47fae154ace22a0ae2787b	5	5316	316	567	589	4	4	2024-05-28 14:13:58.2	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
591	\\x67f6ca9c0aeb28186fb62eeec78d6f342b21fc14581e3b08eadd35e87cc8274e	5	5329	329	568	590	6	4	2024-05-28 14:14:00.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
592	\\x3819adee4fa355958ce6af24e647f9d2960e01bf6fb909110041a22b80eadc21	5	5338	338	569	591	23	4	2024-05-28 14:14:02.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
593	\\xc38b15d9801ba7c53f9d1553fa4d43e1f3ee6f88dfd19f6ee2afe0ef298e5b49	5	5341	341	570	592	28	4	2024-05-28 14:14:03.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
594	\\x138f480570d2ecfbfb1289ba072371204f6099c3657f071a8643f8da748844bd	5	5349	349	571	593	23	4	2024-05-28 14:14:04.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
595	\\xc4b5f08de7f5c3800559e855707ff25064d0794fcc278a2554fec67dbafdde5b	5	5351	351	572	594	7	4	2024-05-28 14:14:05.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
596	\\x148f6c31d9d0a5828e7197795dc412e74b052d68ae6d92bbe288bf36d09da38d	5	5361	361	573	595	28	4	2024-05-28 14:14:07.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
597	\\x28662a7bfe38a89a3878c654926e50906e0790320cea5b923bb032cac4339fb4	5	5368	368	574	596	19	4	2024-05-28 14:14:08.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
598	\\x757883a424661d3625669630022d375fd09060cf44fd96ebf0b986e9a886b6e7	5	5381	381	575	597	7	4	2024-05-28 14:14:11.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
599	\\xba7315afbe9990089c165f0373d08151a4a7fcb130f0a47d977435263cc01a86	5	5382	382	576	598	5	4	2024-05-28 14:14:11.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
600	\\x8a2c0a9e28cbe0873ceecc848158dccd1db63c2fd33c7f4fb0dba5f9aed1d301	5	5390	390	577	599	6	4	2024-05-28 14:14:13	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
601	\\x3808de8a08d00c9da14017f71f0a391707da84cc5ec0b7e4693605eecf38e5ff	5	5392	392	578	600	28	4	2024-05-28 14:14:13.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
602	\\x3e4819c277433f8153ad2d2ba71af0bfda5ab362ede5c4e1f19ed816c89ac303	5	5410	410	579	601	3	4	2024-05-28 14:14:17	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
603	\\x63e163c7e9e96a46abf5f1b0b333a1cc7c93e4cedcd19330a25c8c74a0067aa4	5	5412	412	580	602	28	4	2024-05-28 14:14:17.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
604	\\x5ac3f5418672e0a2f9e83c67a322e84859da9faf274e2ac76bb89ce05e7e1e81	5	5419	419	581	603	15	4	2024-05-28 14:14:18.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
605	\\xe8a21c99059aa1f9f9ee50d952cfeabc7d1fef899bea158137fb7c711ef4484c	5	5447	447	582	604	28	4	2024-05-28 14:14:24.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
606	\\xdd33c44fc7ab900250604cfb95566a2afc87b40a97c3e5f9c1848bc9daf485ab	5	5448	448	583	605	28	4	2024-05-28 14:14:24.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
607	\\xd500e9caa7bef0047e447b9e4beb91bbe5c2b4e9369684d5fd6066ce184aea14	5	5489	489	584	606	23	4	2024-05-28 14:14:32.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
608	\\xfe5c4bdc670033f3558691dd27ef6d73ea12ca6300a64ea8bba7bc50e1643072	5	5495	495	585	607	15	4	2024-05-28 14:14:34	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
609	\\xef75767ec0712cc162c25e2237137b1d66a1f101dbed3b47246027f6d98c8401	5	5528	528	586	608	10	4	2024-05-28 14:14:40.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
610	\\x71a49b68aacb3b4e97834475f174a5318abb0aab6b59ead16da55a9c84512dfb	5	5535	535	587	609	28	4	2024-05-28 14:14:42	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
611	\\xc61a1c4f40955b851afb1310b43be143e9c91d7c736ae625604e6765a27b3784	5	5541	541	588	610	15	4	2024-05-28 14:14:43.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
612	\\xbce971c72d88ebc230a60c211d2a960202c15e7cda3622b3643bda54182279ae	5	5549	549	589	611	10	4	2024-05-28 14:14:44.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
613	\\xa4a48c929061573c418b7334d21eaf1100a50940f2abf11c25b1830ad52e838d	5	5572	572	590	612	3	4	2024-05-28 14:14:49.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
614	\\x5aec97b9289ec2ef5aed67341b65e07b483706d6bb097d92f0fd1aba91e5b9d7	5	5573	573	591	613	4	4	2024-05-28 14:14:49.6	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
615	\\x15c2faea743f2684d6bb5a2316b684100865836eda5aa705910215e0d7a150d0	5	5580	580	592	614	6	4	2024-05-28 14:14:51	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
616	\\x0ca11c22a0675e27a6d7b1e815624e45025fbc4160474d264902a8a4c134bdcd	5	5584	584	593	615	3	4	2024-05-28 14:14:51.8	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
617	\\x427a2489d5763dabfb80b8851a444d6b3ed19c71a15ce62436a599ac71d02a4f	5	5593	593	594	616	15	4	2024-05-28 14:14:53.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
618	\\x17b151130e9dd624a8aefecba0eb27fd62114df455ea6aee9e834d313fc20061	5	5594	594	595	617	28	4	2024-05-28 14:14:53.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
619	\\x5383f13eac6067458dd879811024571f54b5aeebcbdbf35b5523c3f485dc4c00	5	5595	595	596	618	15	4	2024-05-28 14:14:54	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
620	\\x86c2f61c14df668ffce7f2ccee0b87021d2b311ff768ae3f0d002e255d93dc78	5	5614	614	597	619	15	4	2024-05-28 14:14:57.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
621	\\xe2c016aca99a97333987e09c1e9f81b96c3be78d44c91cd563e99f0eb296e659	5	5622	622	598	620	15	4	2024-05-28 14:14:59.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
622	\\x351776d627cfa412c75807ba6cb4345001753b2411a3f7a8415a8a9a7eea1c16	5	5640	640	599	621	4	4	2024-05-28 14:15:03	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
624	\\x3a3a370d7341a414b9825b35ce8be999ff40990ac1acc8ac63623b054d9975f4	5	5645	645	600	622	10	4	2024-05-28 14:15:04	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
625	\\x754b769ee6f5b9b64a29c5d4a486aa5cead758db340493f1236bb2d1a19403e1	5	5653	653	601	624	5	4	2024-05-28 14:15:05.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
626	\\x8778f2ce559be0acc019de33976df41ea6d2313968715eb1c943d8786f0e3c98	5	5660	660	602	625	6	4	2024-05-28 14:15:07	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
627	\\xbf5683a4e7b54917688e8a7dcc0af86a60a1851dda18e45afcc9b894318ecaf0	5	5669	669	603	626	19	4	2024-05-28 14:15:08.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
628	\\xc01495265c97019426a655cbe774b3241514bda9f7f6fbd8e02907faeae0927d	5	5681	681	604	627	23	4	2024-05-28 14:15:11.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
629	\\x970cb3c25881aa0820520abe897a50d8e894c16d1c56fa71ff9c2e386574937d	5	5683	683	605	628	8	4	2024-05-28 14:15:11.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
630	\\x005c0e7f35adfb2db6e24b18f0c05fe6f2ee53f1fec220855a1d812912031802	5	5686	686	606	629	6	4	2024-05-28 14:15:12.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
631	\\xd665eef8edceaeac7dca050fffd1b1707bafc6065464593013a3c69212083d02	5	5694	694	607	630	15	4	2024-05-28 14:15:13.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
632	\\xa610f07b5b8f716f0d040b8b28e76737ffa1acf17bad89d7d02f0c1318db7f93	5	5698	698	608	631	8	4	2024-05-28 14:15:14.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
633	\\xd6d6b884a5fcbe1852631e7086e4202e32d489b2961148a7ad05d20781e95106	5	5707	707	609	632	28	4	2024-05-28 14:15:16.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
634	\\x748a620a73ee8d310ae982a720886b5d2adc09724b578f129063d161cc81e1fa	5	5715	715	610	633	28	4	2024-05-28 14:15:18	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
635	\\x9a0a43b617cdf6418c67428b35f239b332bd364a445f94df4864dfdedffe7463	5	5718	718	611	634	7	4	2024-05-28 14:15:18.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
636	\\xe2710e88ed141ff0e8aa4d169eddd2cdfd58a87d972c6536ee138ceaf6f8f4ac	5	5725	725	612	635	19	4	2024-05-28 14:15:20	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
637	\\xd1e6e09949dca41c2dac008baab2d896a9c3aba9ca82919ac291e8a8d7d818a8	5	5746	746	613	636	3	4	2024-05-28 14:15:24.2	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
638	\\x092282baa6c8351b0eee54ac0a043b5eb2fc8d1c71883d9a1cc896dad78b73b6	5	5754	754	614	637	15	4	2024-05-28 14:15:25.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
639	\\x1fb06ab30599a9040c4f26f320e8e5fa3c3d27cab805528d4fba751b3423e9cf	5	5760	760	615	638	3	4	2024-05-28 14:15:27	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
640	\\x345029e6842535226023154b77449335fb8cbe08340988eec970776fc81f98d1	5	5773	773	616	639	8	4	2024-05-28 14:15:29.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
641	\\x5cce3dd2bee73674bcf2111d46401edd21d343e3b04a439aa582ed93f9275553	5	5782	782	617	640	4	4	2024-05-28 14:15:31.4	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
642	\\x4265c6e32f13cdb2c562cce7d999b82ee332b0d197659d035cee920883fcc4e8	5	5784	784	618	641	4	4	2024-05-28 14:15:31.8	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
643	\\xfe98fe46042691e4b7f936e2a3d8dbb538ee21f8887f0e2f7dc51aee4851257e	5	5794	794	619	642	15	4	2024-05-28 14:15:33.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
644	\\x9e86348f713e2c30c03215b264fa4d9e83465d317f87e8fa528cc113f552f6df	5	5804	804	620	643	19	4	2024-05-28 14:15:35.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
645	\\x76364100a2e595ff73584121caa9e953480a362d35a92cdf04c2bf00b4e783c2	5	5805	805	621	644	19	4	2024-05-28 14:15:36	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
646	\\x21ff3147cd19df1d080f51d1f92f7cd09476e5b4c34fa399930dfc1d5783eeb4	5	5809	809	622	645	8	4	2024-05-28 14:15:36.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
647	\\x4e8fbdde6822c5fdc5ebc49c5e93189e097c0098fa6ff6e0999a6903ab003ea6	5	5844	844	623	646	6	4	2024-05-28 14:15:43.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
648	\\xb438e0a7caa19b2b33f1927ba4973acadc11f642ffbee95efedf25af4cf9ce53	5	5848	848	624	647	10	4	2024-05-28 14:15:44.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
649	\\xcba59c5ec6b02954511d81db56eae91ff7e1a4239acbbe03488bffa9a3977377	5	5851	851	625	648	5	4	2024-05-28 14:15:45.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
650	\\xd32dbcd7ebd638f22d490a0f0ceb30f5e09ea2726d5c9251f4d06dfdc35813f3	5	5858	858	626	649	23	4	2024-05-28 14:15:46.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
651	\\x7e29b6e01b76afbc0fb6b2e9d3406d554ef52121ce94c88ca6c5a33e7af7625f	5	5882	882	627	650	4	4	2024-05-28 14:15:51.4	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
652	\\x34be253f93581748fe980ac6980f03f1fc5b057e8a17e9c1bb5e66f348bfb0fc	5	5886	886	628	651	28	4	2024-05-28 14:15:52.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
653	\\x7a0c0a064459ebfb3e982f16908b840e7b0e17fb6949768f8075c17fdf033459	5	5888	888	629	652	7	4	2024-05-28 14:15:52.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
654	\\x74d7d6b92c3cce38d553790a88fc30de812f71e64439fbdf8ee4a1dcae78fca8	5	5912	912	630	653	28	4	2024-05-28 14:15:57.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
655	\\x8012b0f4b1f7d90ef199977a411baef79ed408a60c8d41c5104cd8071bcb8b0a	5	5924	924	631	654	4	4	2024-05-28 14:15:59.8	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
656	\\x8517b86b232a876ea2579960a9f0ffccf95ca625b2ad74ba1c33d9363e1f92aa	5	5930	930	632	655	28	4	2024-05-28 14:16:01	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
657	\\x709f7c6de4d05ca4a64ccf38042d3b3ea49cd4666f3cd253cb6200a5b1b6a72a	5	5952	952	633	656	28	4	2024-05-28 14:16:05.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
658	\\xa63f1b77aceec71a9a5643e1df848aff195e92d12d740433205f7156403e8af8	5	5960	960	634	657	28	4	2024-05-28 14:16:07	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
659	\\x97ad019b6a628e58a6ae3aad53adfcb385c17450e326f02aab080200c0011c16	5	5968	968	635	658	10	4	2024-05-28 14:16:08.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
660	\\x214349c3d8fbd086c0b2c598f4645cd493626424d9374d3800251578d579a5c0	5	5971	971	636	659	19	4	2024-05-28 14:16:09.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
661	\\x96303c1e2cef8ed97868a4786406458b1b3d110bb5ff0f7649f086fa9533e363	5	5972	972	637	660	6	4	2024-05-28 14:16:09.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
662	\\x4ecc5be84b2d5d50008fdfb12627d303a8088e5a90b52b9fffe4829390034b81	5	5974	974	638	661	23	4	2024-05-28 14:16:09.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
663	\\x7d7f29baedffcb4b835c3fb3b427caa7863348ec5559fa8a4b0c33775a6b8b13	6	6013	13	639	662	10	4	2024-05-28 14:16:17.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
664	\\x90f643b16a823cbd9b7af8e14d8c8278b2c47ba51cf3f506dc0563ed6fdba33c	6	6025	25	640	663	28	4	2024-05-28 14:16:20	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
665	\\x1cb8ad1d82de5d36579f25ee8048fddf195b0702fdf1b4a536c025eb83a55f38	6	6033	33	641	664	5	4	2024-05-28 14:16:21.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
666	\\xcc8c47543f235dfe82468a74a4394655394f4f36f968f232a36103955e047fac	6	6043	43	642	665	3	4	2024-05-28 14:16:23.6	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
667	\\xa7baca6ce7a697d0cd10b7532595f69a0b21c0056a2d5a4c18526287af06a6ac	6	6055	55	643	666	8	4	2024-05-28 14:16:26	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
668	\\x7fd7db286c73f43637c67ae48e4b89cec9435c7d6599c107281b816a3dba320e	6	6068	68	644	667	7	4	2024-05-28 14:16:28.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
669	\\x77ba1b52c79ade46fd18224682e09ac0f66a616f9899d338a94c29508d0ff46a	6	6074	74	645	668	4	4	2024-05-28 14:16:29.8	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
670	\\xe86044be7d5616de5bfdf6184f280d8bba0df45ce2df83ac244e37bc676e205e	6	6111	111	646	669	5	4	2024-05-28 14:16:37.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
671	\\x1d37a33c25992e6214285f40c67ecfef37e948633db30513ca3e98dba1a3f552	6	6114	114	647	670	23	4	2024-05-28 14:16:37.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
672	\\x0c59f9a295afdf5eb46aa6b67881509a7fb8d6e8c1cccf2524b5fa330f757f41	6	6117	117	648	671	23	4	2024-05-28 14:16:38.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
673	\\x0d170bb2a802800495d6af0c9a2b01f5921b29bf711252e22c0b9672614e0f24	6	6121	121	649	672	5	4	2024-05-28 14:16:39.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
674	\\xb390740a5f347910aefaa5a395d1d082a180bfcaf1dda48b1de61d517fc3e898	6	6123	123	650	673	28	4	2024-05-28 14:16:39.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
675	\\xedbaf7f21d12cacef527d8736755c418a07889b4deeecd79b5f54b135c5a204c	6	6136	136	651	674	23	4	2024-05-28 14:16:42.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
676	\\x310cae91d82f3e2ce820f534923c2c2db3a06bfed5fd0e280f3bb4986d625755	6	6139	139	652	675	8	4	2024-05-28 14:16:42.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
677	\\x2bec923a258301b225646a64c001dd09b1121ce3a8dc8e9f67f25c9759906bad	6	6147	147	653	676	3	4	2024-05-28 14:16:44.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
678	\\x0b65e975a0a6b3fa76f24c8eb83554a28b94a0aea135f17ae90808e20e993ba6	6	6149	149	654	677	23	4	2024-05-28 14:16:44.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
679	\\xf5db850ea838aa82c92bbdf35408801209aca8a0498f0a4ff8ef33819c62f969	6	6153	153	655	678	8	4	2024-05-28 14:16:45.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
680	\\x6415cc4bba5f32e657d01bdf6ab856b3eb2acad3b55fed5475c000777edc7214	6	6175	175	656	679	3	4	2024-05-28 14:16:50	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
681	\\xdad9808033ded96c3e9d1ef89545efda501d545c0482a99be69edda0b3961a46	6	6183	183	657	680	7	4	2024-05-28 14:16:51.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
682	\\xecd33f21ef2f01b3e225b12f700f9a5c5dee5e94e9fe4c87f6769cfc75aee74a	6	6186	186	658	681	4	4	2024-05-28 14:16:52.2	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
683	\\x27937a852b59067b2279b570aaa7f8a382ba2da4e7182b6693453c1331588a46	6	6196	196	659	682	23	4	2024-05-28 14:16:54.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
684	\\xcf68e553e0976fcaeba59e4ab5b3cf611e785d5d986c0ce8c88f2bfc07e2b6d0	6	6200	200	660	683	8	4	2024-05-28 14:16:55	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
685	\\xf288e311c8121071ee00de7d16f340b7d14ff613dab588fb6625127c9ae258e5	6	6202	202	661	684	3	4	2024-05-28 14:16:55.4	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
686	\\x75633e45780ed3fa640a5b4c53f9758912d376cf5b9d189c1279149b9a25878c	6	6225	225	662	685	19	4	2024-05-28 14:17:00	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
687	\\x4db5db5a8ad96e9c674862bb081c3eed3fa6b495acee2f5c172a49475281bcfa	6	6238	238	663	686	23	4	2024-05-28 14:17:02.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
688	\\xae8926241cd6f0601f9d0fb4fd32542488a6e93616dc1e5a5ddbde021a6d450d	6	6244	244	664	687	7	4	2024-05-28 14:17:03.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
689	\\x77a05dae7893233ad92d26003063ea7905af7f18c386b0b3a30f106fc4b6b6f9	6	6251	251	665	688	28	4	2024-05-28 14:17:05.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
690	\\x3a07af7c85fe801aa928877846e2dcc55782d4ab8c02c818c1a949a4483e3940	6	6276	276	666	689	6	4	2024-05-28 14:17:10.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
691	\\x1ed47bdc25cdf5d89979daf27618ecbc6304662af21226abcc7b56e9e4e93aa2	6	6279	279	667	690	19	4	2024-05-28 14:17:10.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
692	\\x0cc2b82cb4d62e5b2291218447f2768408ee49eb007cfc17e9c9cffa3c79188f	6	6287	287	668	691	5	4	2024-05-28 14:17:12.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
693	\\xd73df0ba11a0f38104fbfdda4c6f05146bb032615fef5ff0062e07ae75a58dd0	6	6294	294	669	692	7	4	2024-05-28 14:17:13.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
694	\\xf275d5a98c3ba5448b3cb07480230355e41e60df7ca9967d0b71b15c297409ca	6	6306	306	670	693	15	4	2024-05-28 14:17:16.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
695	\\x82161f5df3aa3c72e6c456f11f20d71fd990cde3aa08cab4e9da4e389294cdbb	6	6309	309	671	694	6	4	2024-05-28 14:17:16.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
696	\\x0aea32c7cef7bb75953c890380f8725b04d7fd1379a4d1d6858fcbbf4107cfb7	6	6320	320	672	695	6	4	2024-05-28 14:17:19	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
697	\\xa526a907fd7deccf1b7194e6f0e7cfe9e0056f362ae40d7a18d378db65137ac9	6	6322	322	673	696	8	4	2024-05-28 14:17:19.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
698	\\x987347033fa5bd42bee63db23cdf8a871ae7ab7eec197ad71934880f24a9cddf	6	6335	335	674	697	5	4	2024-05-28 14:17:22	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
699	\\xa2d5ba7b9eb4cfe434bfd031d60096da2bd6473d049b3f95efabc9479959be6b	6	6341	341	675	698	19	4	2024-05-28 14:17:23.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
700	\\xe78d554a01aabe3af4a17bcf84bae7313a3303426ddc838eecdb50ee1353d170	6	6348	348	676	699	4	4	2024-05-28 14:17:24.6	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
701	\\x01456aa7708a35eaae72cd4f5dd54436ecffa0450e0ecd710623f503600e1696	6	6355	355	677	700	10	4	2024-05-28 14:17:26	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
702	\\x9812ed9351c23f0ea3dbfed325c96690b49afeaa7c7ba638ee04938ae0afe3a9	6	6363	363	678	701	5	4	2024-05-28 14:17:27.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
703	\\x9367de2766a26693fb288eeda950ffb0203f8afdaa29bd2cf409b8bf4abd7191	6	6388	388	679	702	6	4	2024-05-28 14:17:32.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
704	\\x162c426b082ce304bed48ec175a6bcaa371d8e9b371fd6a61d5fa8a5bcf38787	6	6394	394	680	703	4	4	2024-05-28 14:17:33.8	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
705	\\x478af8bf4c9b0ab1c9ddfee23734ed4bbd0f41f7dcbf884ef57b4179db764ad5	6	6426	426	681	704	28	4	2024-05-28 14:17:40.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
706	\\x2697e04d69ef52c3f0b66399026ffffd3e14b36ead5ff17de2ae5f7ec8df9a1b	6	6470	470	682	705	4	4	2024-05-28 14:17:49	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
707	\\x7051e0f83b599a6066e7a0118c24b5bbf5c2c39e0222a638608c14b9bd1c2516	6	6506	506	683	706	7	4	2024-05-28 14:17:56.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
708	\\xa9e47718f05162084c1b923596c79825149124d51216a65785aca6b4ab71f4fb	6	6519	519	684	707	5	4	2024-05-28 14:17:58.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
709	\\x4729fef0f80b5383e31976eeb528fdf4dd12629492449f7367bda53571297c61	6	6530	530	685	708	28	4	2024-05-28 14:18:01	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
710	\\x30c19cec2fe656a6ef43fd4e7405583a8cb1ac635e032fd07690d8ca23cb57db	6	6551	551	686	709	28	4	2024-05-28 14:18:05.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
711	\\xfe4d14de15397019516a1d5b3d5be2b70f9141b2c7a5a213a7b56d1bf1c15d19	6	6557	557	687	710	15	4	2024-05-28 14:18:06.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
712	\\x341a7f3d1c8f5c17f5157c0583a88d260e4e221af899a0304c1487e6cc04f4fe	6	6575	575	688	711	8	4	2024-05-28 14:18:10	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
713	\\xf57684ef240a8fd7418c715ba5191da1177338705b376576a25e06b35a7a1598	6	6579	579	689	712	6	4	2024-05-28 14:18:10.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
714	\\x3b49237560db9aac13befdf689d9e01fccd6d5d32df52cbe5f7ec8068c351a0f	6	6581	581	690	713	7	4	2024-05-28 14:18:11.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
715	\\x5b8381946616e7e0dfa9c2489cf798b1874acaa5a73f2af6fd4667d1045f723a	6	6593	593	691	714	7	4	2024-05-28 14:18:13.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
716	\\x123032de6367e0e7227882596cab3fb9cf3b7050d6449fcd0b08dabca8cdcef3	6	6597	597	692	715	5	4	2024-05-28 14:18:14.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
717	\\xc96e73373e612da3a14a09161d424c336300123c9f398878fb0e103de84af687	6	6614	614	693	716	28	4	2024-05-28 14:18:17.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
718	\\x85ea8cd46eadd93d32a6a37eb7587ec72537e4dfec95783b65d72462a365a306	6	6616	616	694	717	7	4	2024-05-28 14:18:18.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
719	\\x8ac6fb409b189652f130669ce3e33374f5e59eb2a63e51129daeb4ec7155a0b3	6	6642	642	695	718	15	4	2024-05-28 14:18:23.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
720	\\xc60599c83183ba21acc33fc65788e891dbda91aa00a6f6c43c909d756b03eb97	6	6648	648	696	719	3	4	2024-05-28 14:18:24.6	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
721	\\x7a6484e54fcb69b8d78f3b2c8eeceb40b074733279b726d04864cd6c2a918530	6	6657	657	697	720	19	4	2024-05-28 14:18:26.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
723	\\x3a8856878e42238d77538540cf4a794028460dc7f675d1a58e5b21600e71dcb1	6	6663	663	698	721	10	4	2024-05-28 14:18:27.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
724	\\x3b128b7e612e98108f0f7e346d6c9ad7a224b548f723388e99fa329109e2fa94	6	6664	664	699	723	4	4	2024-05-28 14:18:27.8	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
725	\\x871e8e39a293db860be9c93ba85b2006e9e3498b86026648473370f03615d328	6	6670	670	700	724	6	4	2024-05-28 14:18:29	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
726	\\x61e54f5d454c134cd72b934a41b230b73555f03980960a1059a19df07e8763ee	6	6672	672	701	725	23	4	2024-05-28 14:18:29.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
727	\\x54b9f476139ab2506d59e2cb1b1ce61b0d97a9cda1ea2a5abd5d3d359e264b61	6	6709	709	702	726	7	4	2024-05-28 14:18:36.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
728	\\xab7429c16e83cf319eeb7c143cb9396ba444f024f23ffbecfff62dc7af708564	6	6722	722	703	727	23	4	2024-05-28 14:18:39.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
729	\\x30a8ff7fcb323362b347941035da230b3a059e0fcd9c1418c72f44f0bb5e4af8	6	6724	724	704	728	15	4	2024-05-28 14:18:39.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
730	\\x7c46a33e6e9e36efb9f9adf79c92f09d4dc2aab1034ed8b8af6a426e451af997	6	6739	739	705	729	4	4	2024-05-28 14:18:42.8	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
731	\\x8a78e1df37791df4cf8fba3b99f021e4ed91bdc01cecdd35b745634dd6574ad3	6	6742	742	706	730	5	4	2024-05-28 14:18:43.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
732	\\x589445244f9eb7b43cb77cce5e0b5e4491e7b39c3287e4da7e9e0a266e95db60	6	6763	763	707	731	8	4	2024-05-28 14:18:47.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
733	\\xf75c38b018b7293eeed1d579c8399ded3c98b050cdffaa0de708329611f82428	6	6764	764	708	732	4	4	2024-05-28 14:18:47.8	0	8	0	vrf_vk1mx5q06tfl2wg03z3zu0scv9squg5769l2uyvuvxqp56ccet7hlps26wl46	\\xbab365868a43edd99f65431a6da4b0d1e9d99dff4fe9eb3ab624cc55a2e36be0	0
734	\\x9a90fcbf31cc71b131b8ce1c25b77a7a2959fd023999306f8085a9f16470820c	6	6799	799	709	733	15	4	2024-05-28 14:18:54.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
735	\\xe303753d2bae9e00ffe4bede6af332691be6dcc78124204bc386c850bbfb4275	6	6808	808	710	734	8	4	2024-05-28 14:18:56.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
736	\\xb3fb371ec8b0ae20b15ea75608f2ca582b9e11c273f56974070a512376184be4	6	6809	809	711	735	6	4	2024-05-28 14:18:56.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
737	\\x9a6ad76f5953b2c447b101b7c8122377004b617d4e4bad02005b379f15a76b8e	6	6816	816	712	736	6	4	2024-05-28 14:18:58.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
738	\\xe3fb86cbe7181a081781051e5116229a0abfd412a933730dd43e01aa626d012f	6	6837	837	713	737	8	4	2024-05-28 14:19:02.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
739	\\x76dd59b79845205dde8c51091a7143582b26a8c4a0d9452f4a47140ae1b9b5bc	6	6840	840	714	738	7	4	2024-05-28 14:19:03	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
740	\\x20605fddec9ebf0c1999ac6297167fa6244487f1138e1ca0add74ef7493fd23d	6	6867	867	715	739	15	4	2024-05-28 14:19:08.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
741	\\xbad8e4a1661f2821e3fd385a85314f34a57cb47a0951e92e07fed6ece9a1286c	6	6874	874	716	740	10	4	2024-05-28 14:19:09.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
742	\\xd206a1a07cd5383b0664366a8a8ab3d56c932659ce99ff31da13494a00b8394b	6	6891	891	717	741	28	4	2024-05-28 14:19:13.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
743	\\x9e1c556eee7415ca49fb0e6861b72fe01fc5bc7bbc275f546b043d46de7b0d5c	6	6899	899	718	742	28	4	2024-05-28 14:19:14.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
744	\\x1b5359e84be8a9c009fa13a794bb2275a5389f81e3af7b01e7fc318ce697224d	6	6901	901	719	743	15	4	2024-05-28 14:19:15.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
745	\\xc9e67af61534036fde9028043416fe7013445d2d78de6e4d01aefde88669c150	6	6902	902	720	744	28	4	2024-05-28 14:19:15.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
746	\\x6bb51f660a91533fb75b5df2b8caf12f44f375c595e23159b90e223896097713	6	6908	908	721	745	5	4	2024-05-28 14:19:16.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
747	\\xff8b84ecb382435b3df2a65b6321b964b41cf3e168b3aebc2e52feeb2ed693d6	6	6918	918	722	746	3	4	2024-05-28 14:19:18.6	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
748	\\x20d0cd53960724a01746921bfb0e2dae03e3d8dba408f52a39e1debb0e081864	6	6921	921	723	747	28	4	2024-05-28 14:19:19.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
749	\\x704d105b14fb0af491e707128086bb4a6bd921116725f6b8e495723717a9e023	6	6924	924	724	748	3	4	2024-05-28 14:19:19.8	0	8	0	vrf_vk1qn9uwkuxnlzsr2vw4e47c4xwlcfhz4qnru976r6nm82rstmy3avq4e2meg	\\x2c0a6bbf1b603485cf08fc4cf616cf415630044550e57ec8a6d817ebe1a1321f	0
750	\\xdfa971245728d6a31bc763b1b804757f088e508b2ddf3f8387b4d0624b243ec9	6	6962	962	725	749	6	4	2024-05-28 14:19:27.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
751	\\x108952505f28c0817c84d353c235126ef7929d554ef3160ab8eabcb83e3e3515	6	6967	967	726	750	7	4	2024-05-28 14:19:28.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
752	\\x16c10533b25b58b5b796d7ff2aed83d9b2307c9aadf892db23491c478a22eb0e	6	6995	995	727	751	8	4	2024-05-28 14:19:34	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
753	\\x3409be4a444925f8333a83a17ace27ed238d73e4483c0a472cfda77a36e876a3	6	6998	998	728	752	6	4	2024-05-28 14:19:34.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
754	\\xdfc40bd20bf1f24162861344297760382ce6874b2b85348998dbb841d701d560	7	7010	10	729	753	6	4	2024-05-28 14:19:37	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
755	\\xa70a2bb81ea9eaa8eaeaf07c4389474d426560cbe866032f11b947b2e2ad8f24	7	7034	34	730	754	19	437	2024-05-28 14:19:41.8	1	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
756	\\x2e50bc7b53d8ee1cf579953706ccadb3e56ad5599d39009b58f3c2c36b131b76	7	7057	57	731	755	10	4	2024-05-28 14:19:46.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
757	\\xc4da7381cc105489e436232a8e8f38b6f2771bf13e3578b74f6c7af7d6f22df0	7	7086	86	732	756	8	4	2024-05-28 14:19:52.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
758	\\xdceefa0e12f88ad8aa845aadb7020a7bf11e7478a989108392c9128941bb383a	7	7091	91	733	757	28	4	2024-05-28 14:19:53.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
759	\\x799bf4ba3f1500626186399c6ba90f4ea45aa205f801eae90c9f06f7db97fa80	7	7103	103	734	758	28	6086	2024-05-28 14:19:55.6	1	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
760	\\x2e77ae0094eafbef88cf3af397662ec7692cb76686a55bc0890b3aa3b20c18b4	7	7117	117	735	759	5	4	2024-05-28 14:19:58.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
761	\\x1f2ccaa2decb6ba8dcba21369125af4dc8f3fc3e49fea406f7cb056b997396c3	7	7160	160	736	760	28	4	2024-05-28 14:20:07	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
762	\\xcc094befe63cca6fb5ee6956c28800fcf74aac7d9ae68d4649e90f0c16e7c0d2	7	7176	176	737	761	28	4	2024-05-28 14:20:10.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
763	\\xca3b9749092de3e6725ae4d2a5e5c076dbc88a182890d0b652a997f33117fa3d	7	7183	183	738	762	7	4	2024-05-28 14:20:11.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
764	\\xfbcbb67a52dd2f54af4de923073380c357282c835d384e808d71ed2ffa56d0f7	7	7188	188	739	763	5	4	2024-05-28 14:20:12.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
765	\\x31bc7c359fb22876eac379f7c1e8022e6596d8d9ec4767e2e204461a463d0b65	7	7189	189	740	764	5	4	2024-05-28 14:20:12.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
766	\\xad39600c7fb6500428c0ff5ce970a6029a3d7c8b5e3c345d5b3bf386aafd5527	7	7199	199	741	765	23	4	2024-05-28 14:20:14.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
767	\\x360ca27e98b79203fa6535878a4fd98a2834d2caaa8e6c0fd2daaef1e188a5fa	7	7200	200	742	766	7	4	2024-05-28 14:20:15	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
768	\\x03186adc69de5472b36bc50cab78a13934d96121a680b5773d770d938b974cbc	7	7207	207	743	767	23	4	2024-05-28 14:20:16.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
769	\\x2ac23ac229f9dffc9172de84997ae0a87dc02565b2645af7760c4b5762fbf3cd	7	7226	226	744	768	7	4	2024-05-28 14:20:20.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
770	\\x1c694be7a53656bd09b9c6b98aaf0d64edc7888f8bde0f7e105484e610eebadb	7	7247	247	745	769	6	4	2024-05-28 14:20:24.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
771	\\xce04b27ca2e6617a3a132da3753dc64eb696480e2a6cf6abef6af9e9da7a0eae	7	7260	260	746	770	10	4	2024-05-28 14:20:27	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
772	\\x76d96b2ba0510a7cd5e6210e1e53181ca6bae0e7fa7efbd5c46ccd37a8cdd73e	7	7272	272	747	771	15	4	2024-05-28 14:20:29.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
773	\\x2a527f1d32a79001a4d9c1ba67001cc2cb4866c1e68d524eed99eec9ee10dce9	7	7273	273	748	772	15	4	2024-05-28 14:20:29.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
774	\\x7f0a6a9eb4adb3f4ad2f10d87704b90d8806b932716348cbe545fc42748bc19a	7	7274	274	749	773	15	4	2024-05-28 14:20:29.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
775	\\x6433dd31c9933bd51f645d33a3335e37f9be757537fa719a3300a8e54be58561	7	7283	283	750	774	15	4	2024-05-28 14:20:31.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
776	\\x00544ef75d6e26817f9eecc34f44a4dd8ba3e8e1e879e2f1a7224f54ebe53d61	7	7284	284	751	775	5	4	2024-05-28 14:20:31.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
777	\\xa8f897076dcb6f21010f5dd63b4ab5cea4ed7ab8ce0b929063982ba44d727567	7	7290	290	752	776	23	4	2024-05-28 14:20:33	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
778	\\xb4e2d51cbae0630468408cb3a02586c8ae9a8db6c761b63bd8b6a58e05fbc561	7	7304	304	753	777	7	4	2024-05-28 14:20:35.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
779	\\xa07ce9e27c8626911aa7824e5dc2c13bb911d30bb0f3e72b9fb59b1500fb7321	7	7330	330	754	778	28	4	2024-05-28 14:20:41	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
780	\\x2c75875d1039b0dc104ce8a1eac45580d8448f3b8291003d6a43bb3b78f3cfea	7	7333	333	755	779	7	4	2024-05-28 14:20:41.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
781	\\x299c0e42d81d582bd7cdd7c6cac8e36be4d767cb672bff8e528cfbe9825b6796	7	7356	356	756	780	15	4	2024-05-28 14:20:46.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
782	\\x82927781e21f5026becee881b8e83ac87949a06dd6ccfb312271957e6936e0b5	7	7360	360	757	781	5	4	2024-05-28 14:20:47	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
783	\\xac9b85f634ddee3a27c823c17b86b23d12d638ac7a46e8867ac345715c66098f	7	7375	375	758	782	6	4	2024-05-28 14:20:50	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
784	\\x6ed5f157d51c75b25b971e83b8acc4db084150bef9257309f6359da2e46cadc5	7	7381	381	759	783	19	4	2024-05-28 14:20:51.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
785	\\x29a939d24b81f758bbb8ce4cc4c31ec37223de24b33b397da751cd5dcd536709	7	7392	392	760	784	10	4	2024-05-28 14:20:53.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
786	\\xbf5664e0d83f5158fb5ca24e7f58df97e8373ab28728fcf7ff147360e4a0aecf	7	7408	408	761	785	19	4	2024-05-28 14:20:56.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
787	\\xb7b19d9e5a63907544d3e566b3633658b9fcb89fb5fcf5b87f6b7a459c3d7d03	7	7424	424	762	786	19	4	2024-05-28 14:20:59.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
788	\\x99c52b2518c232eafe46d39e65175ed297b12c32009a27657974efce861f5725	7	7434	434	763	787	5	4	2024-05-28 14:21:01.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
789	\\xf248d1d0e18b7fa9bfcc5988d7beae609e178cf8f40a3397d2cb1e0f8e565cb4	7	7438	438	764	788	10	4	2024-05-28 14:21:02.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
790	\\xe7bf69e8fbc70f5e902fafb5d5aaa70311c9a2a8ee289134cda5f679c3b7db7b	7	7454	454	765	789	23	4	2024-05-28 14:21:05.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
791	\\x369ff40a9d17c803f7bb4100569583907293ae4e8337115caece4309420cfdc2	7	7471	471	766	790	8	4	2024-05-28 14:21:09.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
792	\\xdfd7434abe673b1c1ad0bf114f29f0d642992076b6f27db258e500798c8190e1	7	7475	475	767	791	7	4	2024-05-28 14:21:10	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
793	\\xcfe34a926cf63e58a1f2870bb97adebf83f293cea935e0b904b06c49f24c3c22	7	7491	491	768	792	19	4	2024-05-28 14:21:13.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
794	\\x2a414c7774c1432b73c1225df3d7ee9f04e59992446763dec308092636096751	7	7507	507	769	793	10	4	2024-05-28 14:21:16.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
795	\\x16b593482fe3cd0c6f7c96e566bea4eb8e94fbfb8820600eb2a5f4698fa86539	7	7509	509	770	794	6	4	2024-05-28 14:21:16.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
796	\\x52e21686aa5e724391dc4968e2959c9c962a004a25cfab142fe13a37392059f1	7	7537	537	771	795	28	4	2024-05-28 14:21:22.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
797	\\xa88701a8a1f99ce135a777224987663291b06efa2615211ec505cddda2e7c432	7	7542	542	772	796	8	4	2024-05-28 14:21:23.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
798	\\x876f515fe83bc8cbc343eca8f179bdc00d12e8791e129cf24be6cfe00ddc1155	7	7556	556	773	797	19	4	2024-05-28 14:21:26.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
799	\\x95c60b7c4048a77d81b836a42b4c76eff2841268c3503b88b802af5dd62d71ea	7	7575	575	774	798	5	4	2024-05-28 14:21:30	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
800	\\xa0feeeb6f0c356c7cf43266d1b993b599412a724e1a49750dd085c36210178b0	7	7612	612	775	799	10	4	2024-05-28 14:21:37.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
801	\\x148cafc72409c28262f82b34b42ac35a36d99a29bd59b9f78a9cdc1dbf744f47	7	7629	629	776	800	5	4	2024-05-28 14:21:40.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
802	\\x1d5e32a2208dd9a101f6fa64dbb40cd84d3de611270063daa145789756b22f3a	7	7653	653	777	801	19	4	2024-05-28 14:21:45.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
803	\\x2f4d638e116f5e147a1caf992ef276b5eddf7a7a4621e622c06fb8ff05b2714e	7	7657	657	778	802	28	4	2024-05-28 14:21:46.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
804	\\xcc03b8077678c663ba863869002a0e30ca0fed4ac07a654d7de171a0d740141a	7	7661	661	779	803	8	4	2024-05-28 14:21:47.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
805	\\x8b6a38824a81bc4371e93f2597cdf501404c19def84961f5ee70d2451977c1f6	7	7667	667	780	804	8	4	2024-05-28 14:21:48.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
806	\\xb8815400a8869bc6cb3e86fa5baaa15e51bb438c7a9e6a350ac3011d78d278a7	7	7668	668	781	805	5	4	2024-05-28 14:21:48.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
807	\\xcb407e2082d96b809c1bb38d70cb8bfcdb7bb722fd170645fe1aee361d19b79e	7	7681	681	782	806	19	4	2024-05-28 14:21:51.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
808	\\x16bfa28c4fa54fa5dfdf223524b70a151204ebe9682a0b90c8cd74cb9c91fbf0	7	7686	686	783	807	5	4	2024-05-28 14:21:52.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
809	\\xfaeb006739ec50427660b418a1a89d4f92f1dd9dc32d03776630037e8fb9ca11	7	7693	693	784	808	7	4	2024-05-28 14:21:53.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
810	\\x150de577f8915695394866370dd7a3edb8c203cde1fabc2522bcca4e5cbd7df2	7	7695	695	785	809	10	4	2024-05-28 14:21:54	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
811	\\x3fb9ff71407c4fe3f1203324549a62f27e9e8ee7af72bd1f6fba76494eff1ac4	7	7712	712	786	810	7	4	2024-05-28 14:21:57.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
812	\\xc63cec16c9c1ca8b4fa444e6efb94ba41df54fea852d0610d04d5b4cbdcedb1f	7	7741	741	787	811	7	4	2024-05-28 14:22:03.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
813	\\xe02c29a7824a47d41f0946fcf11dcebd743295e068f5f4fcf8932b7879bba9d2	7	7747	747	788	812	15	4	2024-05-28 14:22:04.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
814	\\x65f380927e4a649d4fdbcfd240effe532bc93a7d14a405a8d9d82ee418aa81b5	7	7749	749	789	813	7	4	2024-05-28 14:22:04.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
815	\\xb2a1d489581fd2689ccf70ab8c247832af366c31fe50511e2bc6981366a23bc4	7	7762	762	790	814	7	4	2024-05-28 14:22:07.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
816	\\xedcaa05cb27b3e4c1fe73e3b93905717e71eca4865c0371cd30cd679f9bfc05f	7	7785	785	791	815	23	4	2024-05-28 14:22:12	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
817	\\x4e906ee8fe169c1d7bc4c568aadb5764c4d4be1ccc58aea924d6015fd63e0a46	7	7789	789	792	816	23	4	2024-05-28 14:22:12.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
818	\\x93e86105fb4c8edef5b17058b170a468df3b3552cc10dbaf4e2a6c065dd8a9ee	7	7804	804	793	817	8	4	2024-05-28 14:22:15.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
819	\\x57408521f5a6a90eba93d3e3a753aef81c5f3eb92264a591c2cf1b56cd791e82	7	7818	818	794	818	10	4	2024-05-28 14:22:18.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
820	\\x7cb70b333365fe8219d9b38589658c0c4e580a19593104d13074ef337599f2ee	7	7824	824	795	819	15	4	2024-05-28 14:22:19.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
821	\\x231555147056692b09080a7c0e17a6c55ff91afdcccac5b310b8b518e2e747b0	7	7830	830	796	820	28	4	2024-05-28 14:22:21	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
822	\\x9fb167c0f7c9dd29355bda5203e53ef41dcb870bb2f19a8c374bca923b9114a5	7	7831	831	797	821	23	4	2024-05-28 14:22:21.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
823	\\xf318131087d9ceeedd1c57b52d2f2b897dbdb554b06b73920c01098a9a7b7434	7	7846	846	798	822	19	4	2024-05-28 14:22:24.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
824	\\x2c527ac15e589d71f485d7b0300bcfea26e3916a01cf39bac1024fe1b9eda23e	7	7858	858	799	823	23	4	2024-05-28 14:22:26.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
825	\\xac0ff4dd8519cfdd438466113e3770d309c917213cf6330ace836f5bc17a34ba	7	7860	860	800	824	5	4	2024-05-28 14:22:27	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
826	\\xe6e089996dd89f19b19e2e512f7fe90d1b975f5fc19ad6bb15110ce6a796db3e	7	7867	867	801	825	23	4	2024-05-28 14:22:28.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
827	\\xaf30e2b8cf23673518410635428c3edcf839ffb830b08f7e9e630ab7e0e7a057	7	7868	868	802	826	10	4	2024-05-28 14:22:28.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
828	\\x4756bb9ac845c0490c103e9b0af58b7ee06ac231953ce5d4811160e2c64797b3	7	7890	890	803	827	28	4	2024-05-28 14:22:33	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
829	\\x141073b591e3747bc5d2428eec8956193dc6ad543cf2cec154a40fac535b606b	7	7893	893	804	828	8	4	2024-05-28 14:22:33.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
830	\\x97b4bfa3d606087c0c25183d93507ae38b6fc6003aea8e0150e96bfa05605eb3	7	7920	920	805	829	8	4	2024-05-28 14:22:39	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
831	\\x8fc4c46701efce0bcdd0cde7a48e8b9b9b7d33c6c52263ef4628b1a4ef497fba	7	7939	939	806	830	28	4	2024-05-28 14:22:42.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
832	\\x58c3e4bffa6c974d2348bc3fb144237630385cb5cadb8a25f85f4718cf28247e	7	7957	957	807	831	7	4	2024-05-28 14:22:46.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
833	\\xdfcd255c0dfeab6bc521a8b9b41c807cb1f967789fe0cdebdfc61277c6040a91	7	7958	958	808	832	7	4	2024-05-28 14:22:46.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
834	\\x90651008e284603d1f1179596924a7fe99b66e13517c2cafb455c22b88a9d060	7	7966	966	809	833	28	4	2024-05-28 14:22:48.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
835	\\xcc11fae5a97431c941892c9d38c9b60abe5189b3c8757816187d89b5bb3cba4d	7	7968	968	810	834	23	4	2024-05-28 14:22:48.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
836	\\x5a0c7386fca2d28f1e4a67f0da63dc553c8946785781b0b103ed7e6ed7621b49	7	7980	980	811	835	15	4	2024-05-28 14:22:51	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
837	\\xc2339ed53343bf3b294053f0d63ee9719b1dca2ec5f61ed6354214e8bccdcd90	8	8006	6	812	836	7	4	2024-05-28 14:22:56.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
838	\\x0ba90dce21f3ee89e7de95624b94b78e4ff13f86212b6a9cc7584468ee8e01c8	8	8013	13	813	837	6	4	2024-05-28 14:22:57.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
839	\\x6c404a43aa708b7b669525b7043a0f2fd89b6d2b86992b12403dfec6451c5c36	8	8043	43	814	838	23	4	2024-05-28 14:23:03.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
840	\\xf3d96482ce44601aeb103cce5de863380c88ca3abe5fe3bf9cf203280c11f47b	8	8068	68	815	839	28	4	2024-05-28 14:23:08.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
841	\\x5813d70da8f7413d81e55c1bb18ba6d0dacd05d4790a2d4879e500222bd88cd6	8	8071	71	816	840	10	4	2024-05-28 14:23:09.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
842	\\x58fd12c3b65b3a7f8eaa069ebef3f5f6de89eca9cd117654907f0fa9262825d4	8	8072	72	817	841	10	4	2024-05-28 14:23:09.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
843	\\xf8bd61cb6e1d6f8eabfd9a89ce1ab19df9fd1f1abff75abd748a30c844fcd9ba	8	8079	79	818	842	15	4	2024-05-28 14:23:10.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
844	\\x1dc778c70dd60a6a303e42d9c050c5d146e01f8e03688499423f027f5d4054e9	8	8113	113	819	843	19	4	2024-05-28 14:23:17.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
845	\\x5bae55f3443a70d6f92761d94dd0ead9b90a2461e7ca9e0176f81e08109a1f13	8	8118	118	820	844	7	4	2024-05-28 14:23:18.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
846	\\x8cd195355e0172223682215ccf744bfecf8570e3160ce8978559890b0c9f5b4d	8	8178	178	821	845	5	4	2024-05-28 14:23:30.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
847	\\x5487f3a81de3d04c87cdf3a126db1b827fd6d33af675e902a2530396882349fd	8	8179	179	822	846	6	4	2024-05-28 14:23:30.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
848	\\x0a5efa5b398fd6ecb2adca53200a19522d66fed04f6b218e054095e1f2c26b47	8	8181	181	823	847	19	4	2024-05-28 14:23:31.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
849	\\x548e8f0e94d05c95c181dcd32ce7d82336918d7c5f61cff193c3f077280becc7	8	8190	190	824	848	8	4	2024-05-28 14:23:33	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
850	\\xdde308ee1a5254d2a835795dadae6c8ae05b1c67b66142745e4e2f32ad79a2bb	8	8227	227	825	849	23	4	2024-05-28 14:23:40.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
851	\\x4b4cfc3f02b89510658da8d12b881c26e16e87d08c3df9a7373f2677614582f5	8	8230	230	826	850	19	4	2024-05-28 14:23:41	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
852	\\x08fb1d0650c88411393e9c309c3ba610dd93ab33003143e3380b290794e7492d	8	8231	231	827	851	8	4	2024-05-28 14:23:41.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
853	\\xb911f86a63b005067ab72fdd04ff2a98f8a87dcd304e66943f4eca46ef558a2d	8	8239	239	828	852	28	4	2024-05-28 14:23:42.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
854	\\x106a6053bd9e4d76423e3c10ca9ab2bf445e3f67fff175ca4faf43204c554352	8	8244	244	829	853	28	4	2024-05-28 14:23:43.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
855	\\xfabf6e54bc8732c4d5096c7509779f7d3030c02d27a8da8a4fa672a0fe2970da	8	8251	251	830	854	23	4	2024-05-28 14:23:45.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
856	\\x9b83bc4157b7686a8fbf1fc479c570e93ffca2b72a22b673825cb1a57fd43709	8	8252	252	831	855	19	4	2024-05-28 14:23:45.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
857	\\x8a1fcc479762adf4730f765c27fefb775c0742cdb74cfc3560022512a43cf6e5	8	8253	253	832	856	28	4	2024-05-28 14:23:45.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
858	\\x998b3d9a751324aee93dfe0d32c24f66613a13035c8227e30f0521dcec53c2c2	8	8282	282	833	857	10	4	2024-05-28 14:23:51.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
859	\\x4b5390cd4ce9349704735584beea011237f000c1cf805074df4015493df3a024	8	8285	285	834	858	10	4	2024-05-28 14:23:52	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
860	\\x6e02fd88a8e3e09cfdb5295af4f17d84faa1db264dec79d0f5aef055e3f5f04a	8	8291	291	835	859	6	4	2024-05-28 14:23:53.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
861	\\x0bcf5911e9418083c0cfbfaa3e8fefff13280e26fe70c0661ecec6142dd444bd	8	8296	296	836	860	19	4	2024-05-28 14:23:54.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
863	\\xed35ea71717c8f13f1322ba63e179a3f8eebc05399ad522ca21996dfa17bb03a	8	8301	301	837	861	15	4	2024-05-28 14:23:55.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
864	\\x09584bc83b57312ac6331bcd0571f90ec13069075c0bfa9c593a699a8dcfea92	8	8302	302	838	863	10	4	2024-05-28 14:23:55.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
865	\\x228acec9a99d59fc9978a38016e39be87ed0724b28112f46a47bcd3772963fc5	8	8314	314	839	864	5	4	2024-05-28 14:23:57.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
866	\\xf0b873281a71f78107a3134e6761b9e803610bd434e988b5479af7026bd6a824	8	8327	327	840	865	28	4	2024-05-28 14:24:00.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
867	\\x9e6c133a6cdb9394b419cd1282eff8e207deaa8db0922a8cfb7a687168d25451	8	8329	329	841	866	19	4	2024-05-28 14:24:00.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
868	\\x5dbadbd8c66335a3ad209c3bc7e780fd866ccf73b8a1ecffc81ec2850e336189	8	8330	330	842	867	6	4	2024-05-28 14:24:01	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
869	\\xfd4a05d32001fa4220809f1f6adb313ab32adaddb8edc39c3dfd6448b232fadb	8	8337	337	843	868	15	4	2024-05-28 14:24:02.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
870	\\xb10c3120f5ea3642328188ca721b6e3fe9b620f038b8541e55694c9b0846548e	8	8341	341	844	869	19	4	2024-05-28 14:24:03.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
871	\\xa9b8525698f36837c0cd60b912c2eef077b8a5bc664ee2af72d5261ac141afa3	8	8344	344	845	870	8	4	2024-05-28 14:24:03.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
872	\\x0c3e6325cf6be7b6a78fa8cf394944390ee54477486ec605d65ce55b20292eb7	8	8349	349	846	871	28	4	2024-05-28 14:24:04.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
873	\\x61bad97e4a018a8fc4bd94070d553e3437daaa1970800d96285e1ef396837462	8	8352	352	847	872	15	4	2024-05-28 14:24:05.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
874	\\x5e18132442fa86158432aba8704c98682b640cced29d8b164687d4dbe2eb78cc	8	8365	365	848	873	15	4	2024-05-28 14:24:08	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
875	\\xff133812bbfcebd023504e7883d1ec5c7f8e6a8b27723e21f1f2e8b42b0a0cc6	8	8370	370	849	874	23	4	2024-05-28 14:24:09	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
876	\\x6f4add6736d8ac86c2c2a299944ba0dd4e40cffcbd28f322afdb8684d03ff3d1	8	8378	378	850	875	28	4	2024-05-28 14:24:10.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
877	\\x6c2aba10e0b0fe361ff61aff05930cdf2b623d1b76036ffc7ef973ab88ebcc25	8	8386	386	851	876	7	4	2024-05-28 14:24:12.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
878	\\xc8443d7a20412d7329ea452561eb9c93a41e051a4576935e982a906a4a484c33	8	8393	393	852	877	10	4	2024-05-28 14:24:13.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
879	\\xdfd47880a5a2b5b9f7429ededaf0f8c663631ed4d7b1ec8391580cd62f8a8670	8	8401	401	853	878	7	4	2024-05-28 14:24:15.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
880	\\x958544cee44cff7ea83cfdb4e322603f24e3d3ad064d593672955329e2e39f11	8	8405	405	854	879	19	4	2024-05-28 14:24:16	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
881	\\x253d34244bec785535db5ebd184f716bb8570c8454f84bb39ca16dc87ed9d09d	8	8421	421	855	880	5	4	2024-05-28 14:24:19.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
882	\\xcec89acf41cd1cff2137b901385fc1140dbb0a7db019f56f23ff773e6d41f9a5	8	8437	437	856	881	28	4	2024-05-28 14:24:22.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
883	\\xdbddce5ba687d6384e37b51c8cf619db6c987120f4cd0a6c615312ca376d2b4e	8	8445	445	857	882	5	4	2024-05-28 14:24:24	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
884	\\x4b86d823e6de8e7036dec9d3117dedabae4c99ce6dfea480e247faf8abd78ed9	8	8456	456	858	883	23	4	2024-05-28 14:24:26.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
885	\\x35b183fe0f50f9c7c06d8cbb858821bdb0927cf809497d674e31ca5de78d6347	8	8466	466	859	884	15	4	2024-05-28 14:24:28.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
886	\\x8a67a5fe2c8a039369d61bb5fcf822b55d89a8e97a0044874e39653d1ae7a1b6	8	8472	472	860	885	5	4	2024-05-28 14:24:29.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
887	\\xe75c85978d81b46d2bdbcd54e8879feb473fc71c18b1c7ba56dd4fce65244889	8	8480	480	861	886	8	4	2024-05-28 14:24:31	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
888	\\xc6402ca67895db3cd3e797ddb6125c30707ac6839e92a4a807a497623af821d4	8	8486	486	862	887	28	4	2024-05-28 14:24:32.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
889	\\x5744ccd76a69df139c49a30907174885ed88fc800578a2d1ae91e1331f84c34b	8	8493	493	863	888	8	4	2024-05-28 14:24:33.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
890	\\x3087076bb855f7b030f83d11c1e0fc30902b5c51a906a2fa1695b227cf9ae999	8	8505	505	864	889	19	4	2024-05-28 14:24:36	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
891	\\x6aee7033171f28d27bfc887ffc7b1d756056bce44b983f9c60fb2835ee71bdf2	8	8541	541	865	890	19	4	2024-05-28 14:24:43.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
892	\\xee79a1252b84cd0583db4cdd5d4347a0d2f54b9ff42eb0dbc79e316feef512d1	8	8543	543	866	891	7	4	2024-05-28 14:24:43.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
893	\\xf778efa0f37a913d1534a788ae763ec071a5df1082e3434b0ed4db180eb96798	8	8568	568	867	892	10	4	2024-05-28 14:24:48.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
894	\\xb907ae790fc838a40c834675f9b8dad76024dd857e3146f159d0b5bcd5659a5f	8	8570	570	868	893	19	4	2024-05-28 14:24:49	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
895	\\x546510225c03e18292133ded5169553d17523103d957116ab7e35c119f6de2d4	8	8610	610	869	894	23	4	2024-05-28 14:24:57	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
896	\\xce024dd9b95fa14b7b35d6bc860dbe082bb41d0eeac99191162f3e951a35e70a	8	8629	629	870	895	6	4	2024-05-28 14:25:00.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
897	\\x1ec05992337ae1f20abfb0ab881ba312ac8926a1e6bc7132fa966a2a33ace5d9	8	8636	636	871	896	23	4	2024-05-28 14:25:02.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
898	\\x0e1281903f3c4c72b6e87aaf100c08b5645ecec4e9b915235bab26329c185230	8	8662	662	872	897	23	4	2024-05-28 14:25:07.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
899	\\xa3b6c03ced8bc837d28ff78316660b686c9fbecbe8e2cb483c39d6ced24090de	8	8670	670	873	898	6	4	2024-05-28 14:25:09	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
900	\\x3e4fea817eb4f89844cf27ed04821efc8056ad38f650fae3179531452ca95c75	8	8671	671	874	899	5	4	2024-05-28 14:25:09.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
901	\\x1ce49f76907d360dc4244f3fa3a8f9abb91b25038ef71c282235f387b3519248	8	8680	680	875	900	8	4	2024-05-28 14:25:11	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
902	\\xd07617513f23309a05e09585ccfcea86eba5619e73c60b24a67cc03c44bc63b0	8	8691	691	876	901	8	4	2024-05-28 14:25:13.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
903	\\x4f2df0ff5c997e1ef40534ca226d682b92779d0bc7d1405440ff4632a9096e48	8	8693	693	877	902	7	4	2024-05-28 14:25:13.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
904	\\x05c06d1765ed5b734613f1a5b2d4dd86662077bb57dac44d8f772cc7cb107804	8	8694	694	878	903	8	4	2024-05-28 14:25:13.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
905	\\x39e128b1906c9c32091186a2cf2885f9322c99ac6180f60d3cae047cf7ed8c66	8	8705	705	879	904	19	4	2024-05-28 14:25:16	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
906	\\x074519cd7a56829ef1a52b2df30e9bc635276c8cbacbc733afab6893199e4ddd	8	8724	724	880	905	15	4	2024-05-28 14:25:19.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
907	\\xfeaf0d9764ccf8e750ec137f813dd0f504e8d53542fa4749f93987676a0e0de0	8	8740	740	881	906	15	4	2024-05-28 14:25:23	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
908	\\x6750f74bf045358081e63e31185d8d72ce22efb79a6f70d4dae003393d309bfc	8	8747	747	882	907	8	4	2024-05-28 14:25:24.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
909	\\x711de78ba8ee866efb4e6145ca11b490d5ffbce30a65060b0d0d5bb04ad280ef	8	8757	757	883	908	7	4	2024-05-28 14:25:26.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
910	\\x2f27e4aedb07ab7bfcaf5e29875927a5fffaec970a62870a643fb140b1cd7166	8	8759	759	884	909	8	4	2024-05-28 14:25:26.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
911	\\x8ecb3fc60d387cacd6e499f929dfb74bc2ca6cf1aea075948d74cda5323c31e6	8	8777	777	885	910	5	4	2024-05-28 14:25:30.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
912	\\xd9599980895e804f3f1f1d73f04d9a4dc42fdd585fde29d37587dddc9ed1b02f	8	8789	789	886	911	10	4	2024-05-28 14:25:32.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
913	\\xbdfe6621365a1f0d4ba47d783f84337dd65851348b92327a4425fdbc134046f7	8	8805	805	887	912	10	4	2024-05-28 14:25:36	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
914	\\xb86265381e8bd9f227bf88f0556704b0c630730ae569bc90a396c05f0aae2004	8	8812	812	888	913	23	4	2024-05-28 14:25:37.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
915	\\x490fbcf8a351beedf92474f8fa17e9fb5baa38fd169581ca8b2d6f14982f4c11	8	8813	813	889	914	19	4	2024-05-28 14:25:37.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
916	\\x5e659da0437ce9dd2433b62ee11330f7aea7fbaa35409b810e244196944d8320	8	8818	818	890	915	19	4	2024-05-28 14:25:38.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
917	\\x93b0d7cc0305982f9156d2bdc65fc485892e0091de921ef5b44ead3f2aa978f2	8	8843	843	891	916	23	4	2024-05-28 14:25:43.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
918	\\xc6868f0a10e66453c25452d0136cee7838354ea422f909f63f97737db8826128	8	8846	846	892	917	6	4	2024-05-28 14:25:44.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
919	\\x58ad710da2087dbd94d3dd9f28f643765a63ed208e6c6fa658b863bb83c7fddf	8	8872	872	893	918	15	4	2024-05-28 14:25:49.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
920	\\x66b0d9c1a9a3f353467f548e3e1d01cf68a58666f2c429b03bc75f9a53f224c5	8	8874	874	894	919	8	4	2024-05-28 14:25:49.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
921	\\x50886e20c803610326b55c88270236f28b2b886fc5c4acb3228eeec5fd033dc5	8	8892	892	895	920	15	4	2024-05-28 14:25:53.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
922	\\xcc4a6c1534cadf3e29c625d527b4ce7f426ac4fce1e00433d1e578258f98fa33	8	8898	898	896	921	19	4	2024-05-28 14:25:54.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
923	\\x7e3c7dd13ff38cdc574fd79605a84dc966430149750baecaa5614583f68ed3ed	8	8905	905	897	922	7	4	2024-05-28 14:25:56	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
924	\\x39c1394fa4241859e19c5814ec6e20cdd8ca9b0443497b84e53562028953c015	8	8906	906	898	923	19	4	2024-05-28 14:25:56.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
925	\\x00eed05230e7540689eafa70ecca35805cdb8cd58a55e18c5c84c48cd131e4bb	8	8912	912	899	924	15	4	2024-05-28 14:25:57.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
926	\\x641894668fb789b95ebaf69cfd4ed3109deb997cbc52ba111d735d3be0ebe96d	8	8919	919	900	925	8	4	2024-05-28 14:25:58.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
927	\\xad3451a8e75369348034ac9645ce7d61fa02763d4904e6aec854a1bffc1fdb17	8	8929	929	901	926	6	4	2024-05-28 14:26:00.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
928	\\x076f51dc5d1fb2e4cd75f40bfbb64763897f3eafd534aad0c26fe98ac6bd98f5	8	8937	937	902	927	6	4	2024-05-28 14:26:02.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
929	\\x39b4b03be1353f36dd45803aa7bb362e7e6e5773fb77d451736103b52df984e2	8	8940	940	903	928	15	4	2024-05-28 14:26:03	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
930	\\x7f56c1525933322c1ec7ce505e93f066381ad49167cf311d260ecc7a5dc603f7	8	8941	941	904	929	28	4	2024-05-28 14:26:03.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
931	\\xbeae8f4a63bd3ecc317efdbd2a97d3ce105bc7f54960709c0c7e5937da959592	8	8952	952	905	930	15	4	2024-05-28 14:26:05.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
932	\\xe2d6b1c15ca8be38ad86641f324d5acd13a71c8e6cfe2e24fe3fc7c6c761c494	8	8960	960	906	931	8	4	2024-05-28 14:26:07	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
933	\\xd9b4942fc04d19862d16fa7d2bb5053c3682d7e69fd385374b3d7b53bbf9656e	8	8961	961	907	932	23	4	2024-05-28 14:26:07.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
934	\\x914ca5f919283822156302e1a1d002e27a49a46fcce9dfd31d24a5d4b7fb258c	8	8969	969	908	933	23	4	2024-05-28 14:26:08.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
935	\\xeabdd4e0931149ef6da8ef518d10e84a927c37abe7e7ec0e1e90f1ce6e770744	8	8979	979	909	934	19	4	2024-05-28 14:26:10.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
936	\\x8886f84ba87bbfe97cf9ee7b0fa7c6123eb7a646c5aad2975d368f8adc44546a	8	8982	982	910	935	5	4	2024-05-28 14:26:11.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
937	\\x599e8ff868cdca34ae6c4c9852bdca17464170a508e7935d1289e0ce15ce7d70	8	8985	985	911	936	28	4	2024-05-28 14:26:12	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
938	\\xce48132e52b6e589c7a04dc771180d58f15109130aca428fb7e75584a2d77ab9	8	8988	988	912	937	19	4	2024-05-28 14:26:12.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
939	\\x2556b96f7c8b3c03a0e363513ea1a8962ffa84a19c436a71e8270e47b28203d2	8	8990	990	913	938	7	4	2024-05-28 14:26:13	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
940	\\x3ff28dfb3bb49e596718fdb3f2152a16dd194f52034bdfeeda458ef88949899e	8	8996	996	914	939	7	4	2024-05-28 14:26:14.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
941	\\xb18be8c81362b4b24ae0225af412eb655fe0543631f455f005f598a64be52adf	9	9001	1	915	940	19	4	2024-05-28 14:26:15.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
942	\\x1dfaa98b0a48b339f9eb8a557bcde2d5d966e8539c6d7aca569523ecfa054039	9	9002	2	916	941	19	4	2024-05-28 14:26:15.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
943	\\x80c14f7f0563f20a96e9975f03ad908d34448f7107860555474021ab742b7212	9	9011	11	917	942	8	9833	2024-05-28 14:26:17.2	32	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
944	\\x11ed19fa029493e95065a35363673e6dd6b86f8b45bd432d1b56fea76012ef97	9	9015	15	918	943	7	7071	2024-05-28 14:26:18	23	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
945	\\x972801236991fab152b67e73839d38a838856ca8841ef105d4bbcbf6452e7892	9	9016	16	919	944	28	935	2024-05-28 14:26:18.2	3	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
946	\\xfa3047d63699fd9dfa414d1efb57f12bed41f8295218b13509359a41e6f6874a	9	9038	38	920	945	5	13256	2024-05-28 14:26:22.6	42	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
947	\\x319ee53de148df50cb289154308aea6fe6750d58192c6ca9d41870e6acf5ba04	9	9040	40	921	946	19	4	2024-05-28 14:26:23	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
948	\\x7e3a9a904ceaeb2b256e0cdb2d04493b658cb153a1ff4baacdfd85cff837b054	9	9049	49	922	947	5	4	2024-05-28 14:26:24.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
949	\\x22831b9850c0a425564d482e33bddb1090ea106d7605e86cf8676058dc1b5645	9	9050	50	923	948	15	4	2024-05-28 14:26:25	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
950	\\x35aea233ef7082afd472b3206c4db8ae4e17009356c038e1e631fcce380c1e24	9	9078	78	924	949	5	4	2024-05-28 14:26:30.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
951	\\xed7e2c2fc8721b8f679f759eecd9989387e2e144b2cd481a8b5ff3d4dc04cd39	9	9082	82	925	950	15	4	2024-05-28 14:26:31.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
952	\\x768618bf5af5f9d6d60bd6f57a908faf41a384e83754c82248b888f12d93eb0c	9	9084	84	926	951	6	4	2024-05-28 14:26:31.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
953	\\xb176f29a0b27b4909c1c9c87981730c95a6e3be9044de19a3d4a6e89ce11d6e6	9	9111	111	927	952	7	4	2024-05-28 14:26:37.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
954	\\xc0301ba839a6baec37b0c5a65ac1ed07c7f6ca4062baccc212c99234c2e40a23	9	9112	112	928	953	23	4	2024-05-28 14:26:37.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
955	\\x5ffea2c31dbc0c51d5a8f9741c054d064490f90843dfbd136650ec7d7198e39e	9	9115	115	929	954	23	4	2024-05-28 14:26:38	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
956	\\xd989e55061b36e1e98e1b5b2bd6b24500fb38af060815b1df66a00b118fde82c	9	9116	116	930	955	28	4	2024-05-28 14:26:38.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
957	\\x67f95d82a4c2fc38fd76f18b37d5074a1d211737d02dfaefc084e0ece82c19d7	9	9120	120	931	956	8	4	2024-05-28 14:26:39	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
958	\\x6c10ecec483e8820b3730c57d3f59c94cb300dd06cec95aa6a7a91b63d87e5a0	9	9142	142	932	957	8	4	2024-05-28 14:26:43.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
959	\\x3813c7218743c746264fc1a8802823103c82b80186c2aef0c7b0d7bfb3bf92ed	9	9202	202	933	958	6	4	2024-05-28 14:26:55.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
960	\\xb950d5aac21724074a4d871e7c107eef2e637d18557db7951fb61bc4a03aea1a	9	9204	204	934	959	6	4	2024-05-28 14:26:55.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
961	\\x51d32549ac53c711f16aed7daaaeacf6eb3965281cdc93db7d853cabbe7f328e	9	9205	205	935	960	19	4	2024-05-28 14:26:56	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
962	\\x8229a825f4f0fd91b31483e5e8a3f53a0faae12c549bacf675a77db6cf91d676	9	9221	221	936	961	5	4	2024-05-28 14:26:59.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
963	\\x0081ffdbf9eb140e8c4640a5380d6d9c73011da0d670856e9e2cf52d5e6cceaf	9	9223	223	937	962	15	4	2024-05-28 14:26:59.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
964	\\x18e08d0b8a0db7f36ceed1a2d705820252b7edb24606fa572cfbcec688d6d54a	9	9225	225	938	963	6	4	2024-05-28 14:27:00	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
965	\\x0e6d7c12d0b71cc2dea5d5278179a0b3b078df85c58b7f19ef18aa2602992d4d	9	9226	226	939	964	28	4	2024-05-28 14:27:00.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
966	\\x439d57992825e1a315d41f7319672f4455e4cd7f910895ac042a65c5857bca33	9	9250	250	940	965	7	4	2024-05-28 14:27:05	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
967	\\x52cfe8022ef2f823dbc4ade50464cec2b2da9c0091f60886c1c35e69e9e5fadf	9	9251	251	941	966	8	4	2024-05-28 14:27:05.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
968	\\xdf2eb7aa3827428957b8092e42aaa043580ef7cc8e59e8a7b277f61be6d67c44	9	9262	262	942	967	8	4	2024-05-28 14:27:07.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
969	\\xbe0ffffc64e0b72c1c5bd292015fc837076106afd8c501b466b9da9b3476882f	9	9263	263	943	968	5	4	2024-05-28 14:27:07.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
970	\\x54f33c961c554b5346fb52dd5394b15cfa88e198aec55ef80be5f5e41b96f1d1	9	9271	271	944	969	15	4	2024-05-28 14:27:09.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
971	\\x4fe7cb2cd6ab83da17f1cb1b5dd80a0b7e9a0ade3d0dfb684a5aaa989a34fe5b	9	9278	278	945	970	15	4	2024-05-28 14:27:10.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
972	\\x5dcbf86981ad1f417b69a3e7ec575dc8748940a44bbd63a444ac0aec55a5351a	9	9287	287	946	971	15	4	2024-05-28 14:27:12.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
973	\\x2e7586b6f37d29cf5b7a3d1bbb9abcf79df749ea10b6a04f49568bd8905f12fc	9	9299	299	947	972	5	4	2024-05-28 14:27:14.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
974	\\x4a7391d03c490432736793bdad96cd908d3d72d224d29c7e35005f962073799d	9	9325	325	948	973	5	4	2024-05-28 14:27:20	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
975	\\x11d2a6dc69f670fa342cb54e2f7024527f8c832fccb45eb63ae96ddf2d526dae	9	9327	327	949	974	10	4	2024-05-28 14:27:20.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
976	\\x9618670fdb1c73c21e31850b77cf8c88c98d80997f28745f3c40ef6f9956f264	9	9339	339	950	975	7	4	2024-05-28 14:27:22.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
977	\\x7a82e4911f795af1ba83b459ffd4f11bb37dcb16d969035a5325baffe43d9b2d	9	9353	353	951	976	5	4	2024-05-28 14:27:25.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
978	\\xb0a2927682e14551e39661277eb6902e3c0204c0aca7ef208c71dd0a25748f38	9	9360	360	952	977	23	4	2024-05-28 14:27:27	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
980	\\xe0ff0614d8a7352b9073d3408f26d15f0df222da71b3d9ab25dd09e07b1493b2	9	9374	374	953	978	7	4	2024-05-28 14:27:29.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
981	\\x335d9279ad0f48de0f764b6e9a8b9b01e6bdbdd01b868d77b5ba8351de8ca12f	9	9376	376	954	980	10	4	2024-05-28 14:27:30.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
982	\\x3815c289d0aef6f78bf27e0d5ce5ff972d11812281c756ae4431835e2df54be5	9	9378	378	955	981	15	4	2024-05-28 14:27:30.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
983	\\xa3a0d6118665f26a3bb6ec6a0e4c49c9b30abfedd04a9ea9036561ca2c438129	9	9392	392	956	982	6	4	2024-05-28 14:27:33.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
984	\\xa632fb7145be6481ff05421fe1b14d1360abef1491371a5dd569d61e5e37eeb8	9	9394	394	957	983	28	4	2024-05-28 14:27:33.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
985	\\x07f566606b01d472ff1f010f7db360b9efce1d2ac34e89c56209bf206b360a8e	9	9395	395	958	984	8	4	2024-05-28 14:27:34	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
986	\\x7f400eaea2a2439e8450ed1615aad5dc8314bd5803d67b10dcd23809223c3bb2	9	9418	418	959	985	6	4	2024-05-28 14:27:38.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
987	\\x99111a4148e391b16e49f5e1339698c1f6ca3737e0fff230cb71090a5976bb0f	9	9450	450	960	986	19	4	2024-05-28 14:27:45	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
988	\\x8f8241d7320d69d8485756dcf33fa6b1f2fa7f8c352961a4224a517041a5172c	9	9474	474	961	987	5	4	2024-05-28 14:27:49.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
989	\\x440a560107e099ac2aeabc442a79aad18916103b7926d1960346ed8141671691	9	9478	478	962	988	10	4	2024-05-28 14:27:50.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
990	\\xda1164db6bc3d3da28c278bafd5d4acabbc6bff54cb5af1c270bb70056d03e82	9	9492	492	963	989	19	4	2024-05-28 14:27:53.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
991	\\x6ff7493a7be4761f6219bc08e7b1c8822c8521a2a888801511516f36ddbe59ad	9	9494	494	964	990	23	4	2024-05-28 14:27:53.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
992	\\x8a08c6b61042c488ae4b17f46dbfc7a5b421f5038a7e606b861a01889ecc3ea1	9	9514	514	965	991	15	4	2024-05-28 14:27:57.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
993	\\xa4f628888cbf9afca36c9d965038dff7fa3cfd4f66ce9381802258d488cf9718	9	9515	515	966	992	5	4	2024-05-28 14:27:58	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
994	\\x85b37057c7785d74438bc8bfaee1cad1769c13bbc9661597d889862d7f4ebea5	9	9531	531	967	993	8	4	2024-05-28 14:28:01.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
995	\\xc9e890d9aad97a96cd0dad0b86c5bc569d928340b98e93ca32e71519b3126e10	9	9543	543	968	994	28	4	2024-05-28 14:28:03.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
996	\\xff0773e93ca5a6bfd857a82b0ab9f5c3d7d03a280765598644bc7085ae3b5705	9	9564	564	969	995	23	4	2024-05-28 14:28:07.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
997	\\x6058a06328d86886f62f1c6b7ccebe6f71d08dafc4bb240b5623dbbb3a12e552	9	9582	582	970	996	5	4	2024-05-28 14:28:11.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
998	\\xc35718b108e0f7577a5b72ebf31db3936d962ff4651cc28ef2b77da428aaff38	9	9596	596	971	997	7	4	2024-05-28 14:28:14.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
999	\\x36c19b888280f7f635ddbea458d81187b94cb60e45eee3eaa610b698a2a700fa	9	9617	617	972	998	6	4	2024-05-28 14:28:18.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1001	\\xf0d86d66f431f27b601eaaae3c8ec8daa898b4e80600e0f57e1cf65f80d1e4da	9	9619	619	973	999	6	4	2024-05-28 14:28:18.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1002	\\x88fe33f2e65d462f5ef9c64c6cb64529356f2f1717ba516b55ff7ea248688a46	9	9646	646	974	1001	15	4	2024-05-28 14:28:24.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
1003	\\xffa96017878d648be6a95d2a49972a849e7771959d458955d2c980723a3db10f	9	9662	662	975	1002	5	4	2024-05-28 14:28:27.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1004	\\x76064036dd67f712254ff35453274e21679cce2b72bfe6f0d870ce4305490b47	9	9663	663	976	1003	23	4	2024-05-28 14:28:27.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1005	\\xccfb3d9f07247d554236ad941a769f3ce17eb79327d1f56650ad670b2d004da4	9	9666	666	977	1004	6	4	2024-05-28 14:28:28.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1006	\\x270251c1157e28457943959af03cdaac4d658267ff256ab1683c20d7c637ea0d	9	9671	671	978	1005	10	4	2024-05-28 14:28:29.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1007	\\xcd6571e58f3355e9697429479f8fd019934afbde2343a1d0b619361ab8805638	9	9674	674	979	1006	19	4	2024-05-28 14:28:29.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1008	\\xabcc03234cd20ffa9b22b95080482320f07d6f6b797cb88033154602d308b07a	9	9694	694	980	1007	15	4	2024-05-28 14:28:33.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
1009	\\xe62037b10dee49a26bc337e92726e9cd931de78633c893c1d7ad07c5ea517880	9	9695	695	981	1008	23	4	2024-05-28 14:28:34	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1010	\\x0b8e9f5ccbb956fddacc22766d4f3aaba221c27263d465b2d85ac7e77a4451ad	9	9702	702	982	1009	7	4	2024-05-28 14:28:35.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1011	\\x256a116eeaf2bb91a11e0a1ae4f208147c5b5c046ccb1746c3670511b83825bb	9	9718	718	983	1010	7	4	2024-05-28 14:28:38.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1012	\\x5d1b26006423ca8b49915d93dae4cd8b06227b7ffbd5e36b580e12b19bb57d99	9	9722	722	984	1011	7	4	2024-05-28 14:28:39.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1013	\\x90d6b8bf0ee1ccf186c7086e1940f53ea4403daf4bdc3240ac3b380d41a723b7	9	9727	727	985	1012	8	4	2024-05-28 14:28:40.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1014	\\x71a8e4d80dd279ef4c48baffa3b0474f5cadf57f0b4f6a6b635e2cc1271e1a09	9	9749	749	986	1013	28	4	2024-05-28 14:28:44.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1015	\\x335204480c975e97fad8b824610355ba51b63bf974d3d15b6c0783a0c67bd59b	9	9755	755	987	1014	5	4	2024-05-28 14:28:46	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1016	\\xf483ed590b8c040804bb471e0d36dfb20407fa84c6d59850c7335ea7cef0fcae	9	9765	765	988	1015	7	4	2024-05-28 14:28:48	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1017	\\x71e0a4d8ec13a77fc9d933c841e62e9ad320e0e52ec41d2127e4d6f629d9ef29	9	9773	773	989	1016	23	4	2024-05-28 14:28:49.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1018	\\x44df0b328ef6d5c56f9092a120f98bfaa5a1113a0b7746fc2984e50eab47fdba	9	9775	775	990	1017	10	4	2024-05-28 14:28:50	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1019	\\x65aab8018f89c34232443df5ff1f46c512ed6b23ff453e52ae17efee95ab44aa	9	9787	787	991	1018	6	4	2024-05-28 14:28:52.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1020	\\x366378e02a0c5d377bf978d7fd4ad42634320b4b9fa75a4c4a0d5603fe506c1d	9	9789	789	992	1019	23	4	2024-05-28 14:28:52.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1021	\\xdf67ce9e1dc46e4514e2c9edaf30260c0390d2cb2a49b91cd83dc5418dd1e56f	9	9795	795	993	1020	19	4	2024-05-28 14:28:54	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1022	\\xd9afcc67c31f63bfca612d628c75472934062b71ca6250c454dbfd51178c09d7	9	9803	803	994	1021	7	4	2024-05-28 14:28:55.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1023	\\xd259972edce7bd320f8cb381a71dce68779ec991fe429ab50adaf3933daced52	9	9807	807	995	1022	23	4	2024-05-28 14:28:56.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1024	\\x864e87e978880e2e9c09862d97be0b4633d4ca6b63e867bff673898a97a5a8a8	9	9809	809	996	1023	15	4	2024-05-28 14:28:56.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
1025	\\x5c6ce66a32cd1d02c265c7d6c33e0936cbd5325e51539f7a66b99cc3203f972e	9	9835	835	997	1024	23	4	2024-05-28 14:29:02	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1026	\\xdcee0c9fa6cfb2500ce773d58045aa5ea770e961f9119e85887752aa1dbe5f7d	9	9841	841	998	1025	19	4	2024-05-28 14:29:03.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1027	\\x7a725a9acddcce9211fbef6a522ffe15b6e28a6b0be4f2340ef852aadbdd236d	9	9851	851	999	1026	8	4	2024-05-28 14:29:05.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1028	\\x38ba47181a0256d666f189eb41c41f991662d8dce8fa9bc1b727580885036f1b	9	9854	854	1000	1027	7	4	2024-05-28 14:29:05.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1029	\\x4eaaa998fe6bc10c1fceb08dbc2216e6c419f149792b74c9266d3c2dc6fa0c3e	9	9872	872	1001	1028	10	4	2024-05-28 14:29:09.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1030	\\x3913b0479935996ee62fe605895855332e644c617ba72eaf28cc67a2b1f76094	9	9881	881	1002	1029	28	4	2024-05-28 14:29:11.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1031	\\xd23744d0b5e7a5c329f898d7e0b38effc1bfc412e772826b399dd73b29187eed	9	9882	882	1003	1030	6	4	2024-05-28 14:29:11.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1032	\\x098e447e008538b26fc97b544eb664f3dd6bd25e2b5d271e5255f32c3f4f675e	9	9886	886	1004	1031	10	4	2024-05-28 14:29:12.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1033	\\xd543d81b3db26b752675947e602afd3c80a9c601f726aa8fd3bf82192df35ea9	9	9889	889	1005	1032	10	4	2024-05-28 14:29:12.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1034	\\x419099c00800d5c4b72ec70f468b7a2c560d988a429631c2e171bf61db2e667f	9	9913	913	1006	1033	19	4	2024-05-28 14:29:17.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1035	\\xb1f979a68d12ba067f3844ff543e04d178f5c19cf4cd8d1e72393f4e0959c646	9	9934	934	1007	1034	28	4	2024-05-28 14:29:21.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1036	\\x98facc600c05ec7a65a70bc3fd8fc1006f1b1e019411c98d97a9c775259177b4	9	9954	954	1008	1035	6	4	2024-05-28 14:29:25.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1037	\\x6873cbf38a60d6a8abc7056212fdec9c48542d2207e5d96b6fc612705c2ecb5e	9	9961	961	1009	1036	8	4	2024-05-28 14:29:27.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1038	\\x3204a7f8e2c12152e6cca16d47c72fb42b5d84f9f1f2af2e10b7d0bbc5abe384	9	9975	975	1010	1037	19	4	2024-05-28 14:29:30	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1039	\\x5838ee9fa3133fb709a65a79cb74236d662a00aa424c3ade96790a4e06a57771	10	10012	12	1011	1038	15	4	2024-05-28 14:29:37.4	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
1040	\\x3de104224659ad1d3900deec58d9e3487ecb2c819d7aab90c62a9f3edd07e22f	10	10030	30	1012	1039	6	4	2024-05-28 14:29:41	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1041	\\x709f5d679cd6d8ea42409592f602dc8577ad394cd6ca059f9d15aebfe84d14dc	10	10034	34	1013	1040	8	4	2024-05-28 14:29:41.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1042	\\x3580fde2c4075934c93732eb922d231ffed3c0e27c0abc951e5c82124f31883f	10	10044	44	1014	1041	7	4	2024-05-28 14:29:43.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1044	\\x4cce7ff64bb180352fa4f96d68b3e61befeea0a6dbcd8ca958e0007c08205544	10	10048	48	1015	1042	6	4	2024-05-28 14:29:44.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1045	\\x0c718077884f10c7c21300653884bfebce25ba61202da720584e3e6cbfba79e1	10	10067	67	1016	1044	19	4	2024-05-28 14:29:48.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1046	\\xf5bf4fd29ededa6940e50c5c6a3a64986059719a0b287ca4a3b46f53b2c5f0f6	10	10078	78	1017	1045	23	4	2024-05-28 14:29:50.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1047	\\xd64a8f243b88cce709b0a730f4a94deeafe434f1297b4d3c4cab46baba93494c	10	10079	79	1018	1046	5	4	2024-05-28 14:29:50.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1048	\\xb1641725f1ece49e867811f4f1d00f46004fa2cc9705101301a4ee4b22112404	10	10085	85	1019	1047	15	4	2024-05-28 14:29:52	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
1049	\\xe4dabbdc99a4748c6eb95a754cdc8a529d2fb86612958f67b80aab0a922c3925	10	10095	95	1020	1048	5	4	2024-05-28 14:29:54	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1050	\\x9bcece05957062e22ae1a24c7eaa930d2f315159f1ea0cda6ba6ae8eee15cfb8	10	10100	100	1021	1049	5	4	2024-05-28 14:29:55	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1051	\\xa60c9cdbddeee1167fe0caaca612200847d352ea9bcb8d32db498490c8b771c9	10	10101	101	1022	1050	15	4	2024-05-28 14:29:55.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
1052	\\x02c8afc7d1a05345916a41546712b9c710f4e586a707c78a81b338e5ba9b667e	10	10106	106	1023	1051	6	4	2024-05-28 14:29:56.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1053	\\xeffcf489e29d590ab3973c0428dd1596d7a331fa7080fa232245fc2a6fba2e5f	10	10111	111	1024	1052	23	4	2024-05-28 14:29:57.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1054	\\x30eb8fb089e0e6c34158f0ea735871dfdc7b34fdf742d040924674a40945c55d	10	10119	119	1025	1053	5	4	2024-05-28 14:29:58.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1055	\\x028afefebf5caac8438f643c2f08b6364b32a33a1233c009baff07221a7ade69	10	10126	126	1026	1054	7	4	2024-05-28 14:30:00.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1056	\\x1ca98a95eed71a524c3ac34506cba36b1ebe016c9d80a9d5989b1b0de79cf646	10	10151	151	1027	1055	15	4	2024-05-28 14:30:05.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
1057	\\x9ec9a126b2f0f92d3259f9301d2a36b763ea27c2b4b69a4ddd4869b740dab09d	10	10161	161	1028	1056	8	4	2024-05-28 14:30:07.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1058	\\xd06f6805456fe84273697a2aa4819dbcdce60ca465bf2de68bb6b5d57a34f89c	10	10178	178	1029	1057	7	4	2024-05-28 14:30:10.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1059	\\x83414c93730333c6d97a8aaf4afad4835c31c151f5baac89c36d33d8e927f355	10	10181	181	1030	1058	23	4	2024-05-28 14:30:11.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1060	\\x6acababaecf197abc6e29f595a4436ac2fc0adf9244a040f1fdb57e97209917a	10	10188	188	1031	1059	19	4	2024-05-28 14:30:12.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1061	\\xa3a921110cb62dee69709f26db9abc43e89a29659628f8f6b37302424d6f0527	10	10202	202	1032	1060	7	4	2024-05-28 14:30:15.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1062	\\x4889b13ec19f687e93b1c686c27c17f0e84235a9b3e06c0341e8c7b0e35e8d30	10	10207	207	1033	1061	7	4	2024-05-28 14:30:16.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1063	\\xd1d94e6244d3639c78844f56b4f0a69b2d5f2e1211b2a1be472c14366dab6883	10	10216	216	1034	1062	10	4	2024-05-28 14:30:18.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1064	\\xd404c613fc508b3680cdbb6ced86e80e53e94f797e06642f6f6897a1aec2fc69	10	10228	228	1035	1063	7	4	2024-05-28 14:30:20.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1065	\\xf58dab7b0b2d3c2894a3a383f6387ff251915caa7b77348368c7f2670ba50279	10	10238	238	1036	1064	6	4	2024-05-28 14:30:22.6	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1066	\\x41232cd9599b22821a5b6ba2b6060b8cde3929c733f56e20c0b334d56e7c64aa	10	10240	240	1037	1065	7	4	2024-05-28 14:30:23	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1067	\\x0a2bb736ab175e89ca72f7004aad2836e31f4a3956dbcf007eac6462d5ccef53	10	10245	245	1038	1066	5	4	2024-05-28 14:30:24	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1068	\\x6ebbd013846d15ca35fa213420386ffd61ade1c0fe8ad9bf51e3bb7dee37f133	10	10252	252	1039	1067	5	4	2024-05-28 14:30:25.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1069	\\x8f067be8f52a5d2960867ed195696899f327d12d100e26e221ff7e3f69e4965e	10	10260	260	1040	1068	23	4	2024-05-28 14:30:27	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1070	\\x03715a24a5882fa15a9f9718de00415d612e8e423469a9878b2303f05cabdd6e	10	10261	261	1041	1069	8	4	2024-05-28 14:30:27.2	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1071	\\xebd1f83f78f7a20e1c2fe282888079cac40dd0ff18acd1d824bf9603447deb16	10	10269	269	1042	1070	10	4	2024-05-28 14:30:28.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1072	\\x98aa6f896865e649e3a2f93cd690b549af628a403f97d18922092e9f7c54fa91	10	10274	274	1043	1071	10	4	2024-05-28 14:30:29.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1073	\\xdaa31e720fa1db01b733dcc1c0c3fe7b1b352d75d41b1abc3675197e1187b40e	10	10286	286	1044	1072	5	4	2024-05-28 14:30:32.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1074	\\xea1e644972e763b56277658b7bacbb144bc3a40b7e14f7d68555b6979c9ade1c	10	10324	324	1045	1073	19	4	2024-05-28 14:30:39.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1075	\\x046246a816db31348c0b2c37c6e5467b447d6b04b6ca13726b8aa9beb7147846	10	10336	336	1046	1074	6	4	2024-05-28 14:30:42.2	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1076	\\x005f2416b792cec93d848cde769472c8ef0de5e3418ae963db770d82f1a00ff4	10	10353	353	1047	1075	5	4	2024-05-28 14:30:45.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1077	\\xd26e9eeefbbdb8b790ddfb377e79e65e42b697feb1bd658ac986720984d09b8a	10	10374	374	1048	1076	5	4	2024-05-28 14:30:49.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1078	\\xf8e3eaead07ff2ce304865e7417d944c0efbb412e9c56648aedaadba5ace9715	10	10376	376	1049	1077	28	4	2024-05-28 14:30:50.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1079	\\x4e24ffb83efa36992994491ef78d9257da46a6f9545d1d0c774fd43259f4f88a	10	10383	383	1050	1078	5	4	2024-05-28 14:30:51.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1080	\\xda5ec78ed97539af4d8faeda2fc01392168b58c11faab7a8fa3c2c2956e5cf4b	10	10404	404	1051	1079	23	4	2024-05-28 14:30:55.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1081	\\x9083538b3b7e748f55a385ce9833d261dfbfa643bdbe5391b23ce8a34fa0bd88	10	10440	440	1052	1080	19	4	2024-05-28 14:31:03	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1082	\\xb48e1c463f875e2ecc85262be51b118045460e142dc1e955081ee78f1b529420	10	10463	463	1053	1081	8	4	2024-05-28 14:31:07.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1083	\\xd8c1d6e9f110762bb645da22176c3c0287c1f255dc6761c3c6a7b3e925efbe68	10	10475	475	1054	1082	5	4	2024-05-28 14:31:10	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1084	\\x2433891a34d91f7bafd84d0ffed8a3393753e9ca55cdcf832b7f03a3658f4409	10	10480	480	1055	1083	19	4	2024-05-28 14:31:11	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1085	\\xaf490c621fc7982286c87ebef3709c1f0c6edbdaa7d6cc0caeb7c8df1c195ea8	10	10493	493	1056	1084	7	4	2024-05-28 14:31:13.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1086	\\x1f1234040e13c98f298d70b726eb6b57739f6529c0eb8356209325e56a5920b6	10	10506	506	1057	1085	5	4	2024-05-28 14:31:16.2	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1087	\\x0e37d930543627a97d8f3b3e1704834ce4d8ef6876195a3bd9bc6d6a41f82ee0	10	10518	518	1058	1086	8	4	2024-05-28 14:31:18.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1088	\\x7096846b2110fb9f64e5bba1f7595759444235c3372b0609abf2351830c9b8e5	10	10534	534	1059	1087	28	4	2024-05-28 14:31:21.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1089	\\x5219e8aecb44df4ef251988db062907bb38902253ba349e5ada1cad45625c098	10	10536	536	1060	1088	28	4	2024-05-28 14:31:22.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1091	\\x5649711e6b8850c6649007fa2adbb8ab5302c9bf72a557b7d422a0244251c9fa	10	10539	539	1061	1089	23	4	2024-05-28 14:31:22.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1092	\\xfefb56fd5ebc51f04a54417b02954c4a9aa1c54a3b38d00897a27f9d7ba96aa3	10	10550	550	1062	1091	8	4	2024-05-28 14:31:25	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1093	\\xbf24fc3b32ff2effeb066586acebb82db3673c8c6d38c9e4e67da7ffc3c38cc9	10	10554	554	1063	1092	10	4	2024-05-28 14:31:25.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1094	\\x87895b07c3a0fc9e6251ffbbbcfc34410ae0eee58feaa13a1bbbcb51e5306375	10	10564	564	1064	1093	8	4	2024-05-28 14:31:27.8	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1095	\\x2355d4e29215180406bf197eeecab7c8ddde03808fdb3cc44aef9721d406cd8f	10	10585	585	1065	1094	8	4	2024-05-28 14:31:32	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1096	\\x0484b6b1d65d909c81dd60a637723d6490fea5bd263901a09b78efca0613ea57	10	10618	618	1066	1095	10	4	2024-05-28 14:31:38.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1097	\\x558b1eb185773c1906c6ea9e248f1f9aa68a803bb971e5b761cc1e1b04e681fd	10	10619	619	1067	1096	6	4	2024-05-28 14:31:38.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1098	\\x5e77b4011d0353be6351272c7f107ff80b979543d800d5eee23baa3361cbf4e4	10	10631	631	1068	1097	10	4	2024-05-28 14:31:41.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1099	\\xd7b12a825700b5d98ab61dbf99284b5fdb5ded316830a121e735d101e468d791	10	10655	655	1069	1098	6	4	2024-05-28 14:31:46	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1100	\\x8e45cd694b3fb288c101e3fdc346390a9cb039256bb7f4307af34a58d47e4f49	10	10667	667	1070	1099	10	4	2024-05-28 14:31:48.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1101	\\x8660d5106675e23344ea7188ac3735a69c7f5e325961864c1bcd8bc37708e12e	10	10680	680	1071	1100	8	4	2024-05-28 14:31:51	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1102	\\xdc08d03665f573bf7cfdee2c528fd7b3cf9fee4f7d1c0e48dca64167872c2e3e	10	10703	703	1072	1101	5	4	2024-05-28 14:31:55.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1103	\\xfe37fdbb790059e0b580661c90cb7e5e893a2615f44de70336839e2c6bb2a02d	10	10705	705	1073	1102	23	4	2024-05-28 14:31:56	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1104	\\x7fd2eaccd587bc1d3f5591a919b6565d15b9c319baab8a6994aec1f5809eefb9	10	10713	713	1074	1103	23	4	2024-05-28 14:31:57.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1105	\\x2c7626e6d6316a77fe5c8418b987421cc73ec30ac6883e4af3642b1932630051	10	10740	740	1075	1104	8	4	2024-05-28 14:32:03	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1106	\\x177c1e5902abfd525bcf4f5c9d6dfe030fc56db2adc2157f1d12900ea80bfbe6	10	10747	747	1076	1105	28	4	2024-05-28 14:32:04.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1107	\\x0f94d19fec5230ac1b355d3aeb454b0e4755969d67ecd75f3f637829f9ae58f5	10	10768	768	1077	1106	8	4	2024-05-28 14:32:08.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1108	\\xcbaf9871b4e8fbd14f352104b818c3a8b5c3c262d862fa6f31ccf61db27a8a05	10	10771	771	1078	1107	28	4	2024-05-28 14:32:09.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1109	\\x10cec7eac67ad7b93e1b38a4b04a3168e26cee22c35845a68120f8821cabd38b	10	10774	774	1079	1108	19	4	2024-05-28 14:32:09.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1110	\\x3327d1a3d31be7b7de367dc1865e45a7ca711c1fc3f7dc1685936609680969e1	10	10776	776	1080	1109	10	4	2024-05-28 14:32:10.2	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1111	\\x30b11b825b2ed185f4608c5d61bf5c763b5ea0438fc9cafd22996c7b5031ca75	10	10779	779	1081	1110	15	4	2024-05-28 14:32:10.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
1112	\\xf9aafa3017a42f1f6acdca3e849cc3530bef1db05866d7c0e973bbba7509af7d	10	10780	780	1082	1111	23	4	2024-05-28 14:32:11	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1113	\\x59a7d94ff9cb0728610fa8a6f448f1514ea0bfc76e6f726f8f6a76a9ad3ae801	10	10794	794	1083	1112	19	4	2024-05-28 14:32:13.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1114	\\x87fd45f6a7bd42075a2026978c2f12e6b00a5b7cfeee9aee7a0c2045754b2ed5	10	10818	818	1084	1113	5	4	2024-05-28 14:32:18.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1115	\\xc27ba8ecb6d1bc991648483b4ef90933b821e729ba429a2133d6d37b03712d77	10	10836	836	1085	1114	23	4	2024-05-28 14:32:22.2	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1116	\\x85d38a750b65e88574490ecaf7cf3ba8a5facc6b16bc328a6dd315dc05d4a0b1	10	10840	840	1086	1115	8	4	2024-05-28 14:32:23	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1117	\\x0238f009c98a148a603de0e73c270aaeaf22cf162fe2c06840ed18c0d605fccc	10	10853	853	1087	1116	23	4	2024-05-28 14:32:25.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1118	\\x545b2cc6dba97ff6c7304ef23fb25e22542c776cb83817acb9bf4b7634da74d3	10	10859	859	1088	1117	15	4	2024-05-28 14:32:26.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
1119	\\x550468331312f37fb19d24302c92138a96f4c88c9d85df40483de60a92f5ef3d	10	10880	880	1089	1118	10	4	2024-05-28 14:32:31	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1120	\\xab7c5d1b14c3b7683c35607dcdf64e19d79d28dcf95032d773d7f4d14f10824c	10	10882	882	1090	1119	6	4	2024-05-28 14:32:31.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1121	\\x1950f26a48db778e7bb9c6eddac2ce1555237f2344d08d2de03cbf4de5e0f611	10	10884	884	1091	1120	19	4	2024-05-28 14:32:31.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1122	\\xabae37e678b3cce4afc855d6b6e3b3ad4a98a9256249335577a62e93974f47f8	10	10889	889	1092	1121	28	4	2024-05-28 14:32:32.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1123	\\x76423c807097888c085157179add96d89d117121d0de224c0837ebf0e1dd7fc8	10	10898	898	1093	1122	15	4	2024-05-28 14:32:34.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
1124	\\xb6e01981f9bb116e3059bb9b20a1f7ecc4262c93e9b6fc766d2d20733b044333	10	10899	899	1094	1123	19	4	2024-05-28 14:32:34.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1125	\\x7894ad448c43489537555e2a0ac58eb8db2d5112c1b5d469a909637db6809e27	10	10904	904	1095	1124	10	4	2024-05-28 14:32:35.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1126	\\x61f951ea87e3c3c8b4eb924bec2a196a9ad2add317e4a9dfb8d82c19cce9e0e8	10	10917	917	1096	1125	8	4	2024-05-28 14:32:38.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1127	\\xd1eb84ef06bb37c754fa5dcaa2cda806bd216b03fa0984b7aee038df9a4ef203	10	10927	927	1097	1126	10	4	2024-05-28 14:32:40.4	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1128	\\x9cc135907995a6a1d1fe40940a8c0f7f1641a8412becf0da333ef12ef121e7f5	10	10931	931	1098	1127	28	4	2024-05-28 14:32:41.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1129	\\x200625584e4076687be1678c606b117fa539764464f342103df81c37482ed52a	10	10939	939	1099	1128	19	4	2024-05-28 14:32:42.8	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1130	\\x5181cae062896b00b3fca2a2fde4f6d9753aef7dc012c5e28ee9f08c8cdd5aa8	10	10941	941	1100	1129	7	4	2024-05-28 14:32:43.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1131	\\x74c1c604e7885fb7721a24b4b7a13133e175f38c56960b12f76016b048e6dabe	10	10943	943	1101	1130	5	4	2024-05-28 14:32:43.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1132	\\xec2563fdcf76536a1f8edadffa06ed9237889aa8438008914df475fc30a35ab5	10	10951	951	1102	1131	28	4	2024-05-28 14:32:45.2	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1133	\\x1baf5b8fe8d3535df0e5a2e2df072581cdab7b2999c73aa85071e3b475abf221	10	10964	964	1103	1132	23	4	2024-05-28 14:32:47.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1134	\\x6042c8f078ceea00a0c4ef71fd3ffec872997b83592e177914887ffefa444d72	10	10977	977	1104	1133	28	4	2024-05-28 14:32:50.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1135	\\xabbdd8b3aaa8848c08ad40a7b3f2f6ecbace2e5d63a8d4ece1cc71ca5a12dd28	10	10982	982	1105	1134	19	4	2024-05-28 14:32:51.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1136	\\x6f757819bc5d6294f3e661a356bb2b3505bb3eff884aa5642d9372032d2482f6	11	11022	22	1106	1135	6	4	2024-05-28 14:32:59.4	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1137	\\x7f7a9c3083539542d1c70e3fe6de634cd0c6302aafc10ce8644663a0c7af1e84	11	11028	28	1107	1136	28	573	2024-05-28 14:33:00.6	1	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1138	\\x0bdc5d5409711ec53b81fbbb4a27da99e12e53208ee267db055f5ac807e4cc90	11	11060	60	1108	1137	23	4	2024-05-28 14:33:07	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1139	\\x1e8135dbc40e78f934832fe625ec7715498b71a461b4b05f86b9a08d9ee41fe4	11	11095	95	1109	1138	8	4	2024-05-28 14:33:14	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1140	\\xa552c548f0068f959c86df56af50ddd3dad3c8f9d711f2f9afae25e9f21b0ab8	11	11103	103	1110	1139	7	4	2024-05-28 14:33:15.6	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1141	\\xe0214febcc0041fa545ae4c59386d60aea7f45407cb90d5175857f11414cee29	11	11113	113	1111	1140	19	4	2024-05-28 14:33:17.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1142	\\x4430c657d806902afb2ddeafcabbcd9c312f6697c311fe8b26aae9f122c6e880	11	11120	120	1112	1141	7	4	2024-05-28 14:33:19	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1143	\\xea921063132a2083d5627e52dcd7aabcbcc8d31165eb3605fc2f860f43684d6a	11	11163	163	1113	1142	6	554	2024-05-28 14:33:27.6	1	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1144	\\x82986fb5315f0efa0345ed6731c792b02bc1b97cb914f077375d36338d1483e8	11	11187	187	1114	1143	28	4	2024-05-28 14:33:32.4	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1145	\\xcd961cb01dee0c55d9451638e18a86c54762c0ec70bdd636e82bc53845c4b21d	11	11193	193	1115	1144	28	4	2024-05-28 14:33:33.6	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1146	\\x20a6f8bbbcf5ffaf95a24800f7a075cbdca5efa8240299793749850755dcdba3	11	11209	209	1116	1145	23	4	2024-05-28 14:33:36.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1147	\\x6564717da88a8acb0f6d189e3be58f4a03df7571617dab0133af8a2c3d9f8dbe	11	11215	215	1117	1146	8	329	2024-05-28 14:33:38	1	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1148	\\x4757a39169611613965e3310b964720e2074581d6a50e8b77e19148617b0a514	11	11229	229	1118	1147	23	4	2024-05-28 14:33:40.8	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1149	\\x3e998f94bcc3888030b687d5e31f1f4ccc91fad6591320e8f8fa9ef21a43fd21	11	11234	234	1119	1148	7	4	2024-05-28 14:33:41.8	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1150	\\x41bb3060ba24d82d370654ed4da973f7ad6b10ab787cf08ca5a739aefb48d018	11	11238	238	1120	1149	23	4	2024-05-28 14:33:42.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1151	\\x60a6b672321b3d805a921a5152824189ec3a602866a329d3c05db7a25351d648	11	11259	259	1121	1150	5	492	2024-05-28 14:33:46.8	1	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1152	\\x599c881ae5655e8d3ebdb0dc813b9574b2425c67d2609a4dc7b49b4604a398be	11	11283	283	1122	1151	15	4	2024-05-28 14:33:51.6	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
1153	\\x61d29c2145657f04cef663b53febab3092e1ec4c7ea00a9f30bb855ea931935a	11	11313	313	1123	1152	5	4	2024-05-28 14:33:57.6	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1154	\\x6f1c5e68ce8e01ddfac80ab89356fc06805ba7c9f7f469a5533af95d0f5df071	11	11314	314	1124	1153	10	4	2024-05-28 14:33:57.8	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1155	\\x8d51a4698d4351ce4131d796c5b6cada6dec28d00228edc011ce47f0bfa5ac47	11	11319	319	1125	1154	7	365	2024-05-28 14:33:58.8	1	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1156	\\xeff089acbb73d4daf6bdf05d55222f9289034be5742f9a17761dfd7a944f6db3	11	11329	329	1126	1155	6	4	2024-05-28 14:34:00.8	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1157	\\xb00955c27d0cf3d8f38cd1189e137637874d85cd9e1a00918fe9483e3e88c813	11	11339	339	1127	1156	10	828	2024-05-28 14:34:02.8	1	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1158	\\x9d41f98d40aea692459c7cf871037d9ebaab07911f03fdb1669c8c4987f78cec	11	11344	344	1128	1157	28	4	2024-05-28 14:34:03.8	0	8	0	vrf_vk1ktjv59j36taqjdcd7q9myud7crc5l7mmgzawxzvjg4kk5vdtyl7qs6dl02	\\xae95caf6b6766cf6ef51f77729d4e9cb1bbf2ad61e0ecf7ad0f2adde52524271	0
1159	\\x99de207f6f0385c889c93e7a5b1c9f6d08ec6724031f4c4a3c4761feb764c872	11	11347	347	1129	1158	23	4	2024-05-28 14:34:04.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1160	\\x7212e096364cf4e4574b3d12e52373e023158a174936e371940e6ada61598798	11	11348	348	1130	1159	23	4	2024-05-28 14:34:04.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1161	\\x9d8637cd12e95a1c2dd9d755d8e99ed60b0cc396bbe6a6642a285427b78ef017	11	11349	349	1131	1160	5	4	2024-05-28 14:34:04.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1162	\\x97be235a16139dfd69290f558f810a2060dd5e912af37a74bc105b11343ef285	11	11351	351	1132	1161	10	535	2024-05-28 14:34:05.2	1	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1163	\\x17e3f612ba3f04871390762b00cbfcf42bb7fed53c0136ca48d8af5d05e69c69	11	11370	370	1133	1162	5	4	2024-05-28 14:34:09	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1164	\\x039d965a91628c1ef958c3ae30b3bceee7d87abeb787672a7a927b3574cbc8d4	11	11372	372	1134	1163	7	4	2024-05-28 14:34:09.4	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1165	\\x3fe2bc6796b8362fa241a2ed6e8254e57012ebcd7c14d5d17a79ce4f093fb8b6	11	11376	376	1135	1164	15	4	2024-05-28 14:34:10.2	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
1166	\\x5a412c3c312c12a83a7f90e4189edcddbb3e63c13fe34ee7392f87ceb4dad097	11	11383	383	1136	1165	8	630	2024-05-28 14:34:11.6	1	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1167	\\x8d2fa1badeaa34d84097787ee91dceb8bcff42f2745f6741271804afe654ee0f	11	11403	403	1137	1166	8	4	2024-05-28 14:34:15.6	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1169	\\x335aff8098c45722b1fe6ebf571f350e52a5d0451ee27cd17937d6c6343a87c0	11	11431	431	1138	1167	19	4	2024-05-28 14:34:21.2	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1170	\\xa8bc8135f400fee30c2ae7771e1ba1f52ffd6eb0d43454a646ac476143a26360	11	11452	452	1139	1169	8	4	2024-05-28 14:34:25.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1171	\\xbf5511f9ed1ed4f53e73b0754496fbd28a62343b2545b1e31141ffe1d98f14a3	11	11453	453	1140	1170	23	4	2024-05-28 14:34:25.6	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1172	\\x51eab4bc9602f2555b70bc1e689c8ebe8981735126500bc082038b85cbd66773	11	11460	460	1141	1171	7	4	2024-05-28 14:34:27	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1173	\\x8b7db30ade0feb55a936de0d1f3db662f22d5ade7729a72766ce05168c06798f	11	11461	461	1142	1172	7	4	2024-05-28 14:34:27.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1174	\\x71e840a20df7e30728ffcd8191e484e9b576a241105a1d05b1e677267be5e370	11	11480	480	1143	1173	5	1740	2024-05-28 14:34:31	1	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1175	\\x1bd08c0660d466f90c8445b9f43ceda0845ed2617733897eaf36bd6286c89f41	11	11503	503	1144	1174	10	4	2024-05-28 14:34:35.6	0	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1176	\\xca5a7bb3a858b88893b57c3619732c749737e06d224a1a230d408a417545dc26	11	11510	510	1145	1175	6	4	2024-05-28 14:34:37	0	8	0	vrf_vk1506xjc4jdlx2c0txv99pumthur6dhn8dyk2gze09ygm7atm8a2qsn8e0dh	\\xab55cce9165d88144f864817c6d21784921361a9115d9eb67238a981b4a52495	0
1177	\\xee63270cddc25e129c845821e4cbdc7543ae5722c46b8e0d419148ef850fae8b	11	11557	557	1146	1176	5	4	2024-05-28 14:34:46.4	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1178	\\xc193ff29639db55701a1e61548a5bcf38a889219d32bdb611405a0abe78d6f2d	11	11564	564	1147	1177	10	1415	2024-05-28 14:34:47.8	1	8	0	vrf_vk19jf6k4cwgrhhapgd25lzv3tupj3zaknpkw6hck0mxfx58usm5rds0hxnm3	\\x9a3c4b57e707eddd8ab78cd8443253bdf189cadd684345ac3cdd5d25c085b69d	0
1179	\\x45d5ccf29e3781b6a81393a9d724bd551f65d7f577de6b77ec54cf1c95a8ac63	11	11577	577	1148	1178	8	4	2024-05-28 14:34:50.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
1180	\\x1dfb754401e0e0304c68ed033bd9775a906f32c2f217c57699cb51a44419a6e2	11	11578	578	1149	1179	19	4	2024-05-28 14:34:50.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1181	\\x376a99a16170109cb4be11c81625f5046d3a6caf701e43fcbd2aa94ea0481671	11	11594	594	1150	1180	5	4	2024-05-28 14:34:53.8	0	8	0	vrf_vk15f8qqu8a6gzrtwu60u5dwy3a8rut04prrqswhkr2j9hwmkn6r65qnl7zqe	\\xb6fe4947c57b94047ed3a88dd78892afdb2e58adaa1ef63e3fe0036dd6162668	0
1182	\\x7882e9284b89594430eba54db5ab6da6f7f69664767fb33cb9245a14e343ab06	11	11608	608	1151	1181	19	1434	2024-05-28 14:34:56.6	1	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1183	\\x95e7795c5ef45e82de8c38beb663fbf36e1be5f0db174d7faab3b8b7f88703ab	11	11609	609	1152	1182	15	4	2024-05-28 14:34:56.8	0	8	0	vrf_vk137e887pdrgjjx8ur25z85xehsaw653uzuvekvg60vmym3djsduvq7j79u9	\\xac7ee28455bca032c72d5552e11f630eeb66c2a88025583547dc0ffdd754e511	0
1184	\\x2c508f98c31567503a50b79ce1733fd8bce928cf478c7fc899787352f2980e5a	11	11613	613	1153	1183	19	4	2024-05-28 14:34:57.6	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1185	\\xfe613400defc1ea70d04c8317fb4d8f33a139aa4d53baf7ba1217a595ab28ee7	11	11616	616	1154	1184	7	4	2024-05-28 14:34:58.2	0	8	0	vrf_vk1nm4ulu7x9l6q22e3n2wg57rddfj82zyma25pmyzgvw95ds2e3nts3nf3su	\\x29698a1971a14966d9744a74b8410ef573fc9877666aaf90fd041af37c18db34	0
1186	\\xbd6aacfe9143d6b6961f86ea7a0efaef119bbfeecc31c4424d9d41c4f9322cee	11	11621	621	1155	1185	23	712	2024-05-28 14:34:59.2	1	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1187	\\xf3b5e977bf59fbed37a3e2ab4d30b692919a69857d89c1d9279551acd17d12ba	11	11627	627	1156	1186	19	4	2024-05-28 14:35:00.4	0	8	0	vrf_vk1k5y029nxrvrm0ce9tzmfya07sddezwqfdp23yjfspfkq374j6g3qa0qwcg	\\xe173f5bb97dbcadd009604a8b2ae90ca046c26e816b68a3f6dc025a5d98fcfcf	0
1188	\\x7d782867e76012c43cb11c706ff6a4a29868237c1ae2f33328daf3feb30eb3d6	11	11632	632	1157	1187	23	4	2024-05-28 14:35:01.4	0	8	0	vrf_vk1ndtsz32zm5dt606f7fwgqhtjhyfmc2jgdlaxltr8c9nrffh77wfsm3uas9	\\x74ef05666cb3def971e583424af2fc371c0fd26d0661631c4004733e54f6738b	0
1189	\\x607511852a81713c95d7117ab8789f4d01330164ee6fa81437fedbd1ed2fdc36	11	11637	637	1158	1188	8	4	2024-05-28 14:35:02.4	0	8	0	vrf_vk10rlpujwm37pfj5wazzx9tl6ce2sj6q6pw27k999h6tr2u6utkdtsfez5h3	\\x01dc028c7dd1690c95a9c1cad68109a058b9ae6b0d8d5d1b18e7e0b6f7d80ac6	0
\.


--
-- Data for Name: collateral_tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collateral_tx_in (id, tx_in_id, tx_out_id, tx_out_index) FROM stdin;
1	110	109	1
2	117	116	1
\.


--
-- Data for Name: collateral_tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collateral_tx_out (id, tx_id, index, address, address_raw, address_has_script, payment_cred, stake_address_id, value, data_hash, multi_assets_descr, inline_datum_id, reference_script_id) FROM stdin;
1	110	1	addr_test1vq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaqekncyn	\\x60232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	\N	3681817478869939	\N	fromList []	\N	\N
2	117	1	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	\\x702618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	3681816876576692	\N	fromList []	\N	\N
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
1	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	110	{"int": 12}	\\x0c
2	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	111	{"int": 42}	\\x182a
3	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	116	{"fields": [], "constructor": 0}	\\xd87980
4	\\x81cb2989cbf6c49840511d8d3451ee44f58dde2c074fc749d05deb51eeb33741	121	{"fields": [{"map": [{"k": {"bytes": "636f7265"}, "v": {"map": [{"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "707265666978"}, "v": {"bytes": "24"}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 0}}, {"k": {"bytes": "7465726d736f66757365"}, "v": {"bytes": "68747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f"}}, {"k": {"bytes": "68616e646c65456e636f64696e67"}, "v": {"bytes": "7574662d38"}}]}}, {"k": {"bytes": "6e616d65"}, "v": {"bytes": "283130302968616e646c653638"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f736f6d652d68617368"}}, {"k": {"bytes": "77656273697465"}, "v": {"bytes": "68747470733a2f2f63617264616e6f2e6f72672f"}}, {"k": {"bytes": "6465736372697074696f6e"}, "v": {"bytes": "5468652048616e646c65205374616e64617264"}}, {"k": {"bytes": "6175676d656e746174696f6e73"}, "v": {"list": []}}]}, {"int": 1}, {"map": []}], "constructor": 0}	\\xd8799fa644636f7265a5426f67004670726566697841244776657273696f6e004a7465726d736f66757365583668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f4e68616e646c65456e636f64696e67457574662d38446e616d654d283130302968616e646c65363845696d61676550697066733a2f2f736f6d652d6861736847776562736974655468747470733a2f2f63617264616e6f2e6f72672f4b6465736372697074696f6e535468652048616e646c65205374616e646172644d6175676d656e746174696f6e738001a0ff
5	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	122	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "24706861726d65727332"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "6261736963"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 9}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c6574746572732c6e756d62657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "62675f696d616765"}, "v": {"bytes": "697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f"}}, {"k": {"bytes": "7066705f696d616765"}, "v": {"bytes": "697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b524244"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": "697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b"}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879"}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "01e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c980"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "312e31352e30"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "7066705f6173736574"}, "v": {"bytes": "e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e044503036383136"}}, {"k": {"bytes": "62675f6173736574"}, "v": {"bytes": "9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65"}}]}], "constructor": 0}	\\xd8799faa446e616d654a24706861726d6572733245696d6167655838697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e677468094a636861726163746572734f6c6574746572732c6e756d62657273516e756d657269635f6d6f64696669657273404776657273696f6e0101b34862675f696d6167655835697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f497066705f696d6167655835697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b52424446706f7274616c404864657369676e65725838697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b47736f6369616c73404676656e646f72404764656661756c74004e7374616e646172645f696d6167655838697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879536c6173745f7570646174655f61646472657373583901e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d4c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f686173685820bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de537374616e646172645f696d6167655f686173685820b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c9804b7376675f76657273696f6e46312e31352e304c6167726565645f7465726d7340546d6967726174655f7369675f726571756972656400446e7366770045747269616c00497066705f61737365745823e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e0445030363831364862675f6173736574582c9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65ff
6	\\xff1a404ece117cc4482d26b072e30b5a6b3cd055a22debda3f90d704957e273a	123	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "24686e646c"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d73627162317366736356365970"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "636f6d6d6f6e"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 4}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c657474657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d73627162317366736356365970"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": ""}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "00f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df40"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "32646465376163633062376532333931626633326133646537643566313763356365663231633336626432333564636663643738376463663439656661363339"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "32646465376163633062376532333931626633326133646537643566313763356365663231633336626432333564636663643738376463663439656661363339"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "322e302e31"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}]}], "constructor": 0}	\\xd8799faa446e616d654524686e646c45696d6167655838697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d73627162317366736356365970496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d626572004672617269747946636f6d6d6f6e466c656e677468044a63686172616374657273476c657474657273516e756d657269635f6d6f64696669657273404776657273696f6e0101af4e7374616e646172645f696d6167655838697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d7362716231736673635636597046706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f61646472657373583900f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df404c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f68617368584032646465376163633062376532333931626633326133646537643566313763356365663231633336626432333564636663643738376463663439656661363339537374616e646172645f696d6167655f686173685840326464653761636330623765323339316266333261336465376435663137633563656632316333366264323335646366636437383764636634396566613633394b7376675f76657273696f6e45322e302e314c6167726565645f7465726d7340546d6967726174655f7369675f72657175697265640045747269616c00446e73667700ff
7	\\x29294f077464c36e67b304ad22547fb3dfa946623b0b2cbae8acea7fb299353c	124	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "2473756240686e646c"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d3534726472455032776366"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "6261736963"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 8}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c657474657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d3534726472455032776366"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": ""}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "00f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df40"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "34333831373362613630333931353466646232643137383763363765633636333863393462643331633835336630643964356166343365626462313864623934"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "34333831373362613630333931353466646232643137383763363765633636333863393462643331633835336630643964356166343365626462313864623934"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "322e302e31"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}]}], "constructor": 0}	\\xd8799faa446e616d65492473756240686e646c45696d6167655838697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d3534726472455032776366496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e677468084a63686172616374657273476c657474657273516e756d657269635f6d6f64696669657273404776657273696f6e0101af4e7374616e646172645f696d6167655838697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d353472647245503277636646706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f61646472657373583900f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df404c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f68617368584034333831373362613630333931353466646232643137383763363765633636333863393462643331633835336630643964356166343365626462313864623934537374616e646172645f696d6167655f686173685840343338313733626136303339313534666462326431373837633637656336363338633934626433316338353366306439643561663433656264623138646239344b7376675f76657273696f6e45322e302e314c6167726565645f7465726d7340546d6967726174655f7369675f72657175697265640045747269616c00446e73667700ff
\.


--
-- Data for Name: delegation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delegation (id, addr_id, cert_index, pool_hash_id, active_epoch_no, tx_id, slot_no, redeemer_id) FROM stdin;
1	3	1	4	2	34	0	\N
2	5	3	1	2	34	0	\N
3	9	5	2	2	34	0	\N
4	4	7	7	2	34	0	\N
5	10	9	6	2	34	0	\N
6	2	11	11	2	34	0	\N
7	8	13	3	2	34	0	\N
8	6	15	9	2	34	0	\N
9	7	17	10	2	34	0	\N
10	1	19	5	2	34	0	\N
11	11	21	8	2	34	0	\N
12	12	0	1	2	57	76	\N
13	13	0	2	2	58	76	\N
14	20	0	9	2	59	76	\N
15	17	0	6	2	60	76	\N
16	19	0	8	2	61	76	\N
17	14	0	3	2	62	76	\N
18	22	0	11	2	63	76	\N
19	21	0	10	2	64	76	\N
20	16	0	5	2	65	76	\N
21	15	0	4	2	66	76	\N
22	18	0	7	2	67	76	\N
34	6	0	9	2	79	91	\N
35	5	0	1	2	80	91	\N
36	9	0	2	2	81	91	\N
37	4	0	7	2	82	91	\N
38	11	0	8	2	83	91	\N
39	8	0	3	2	84	91	\N
40	2	0	11	2	85	91	\N
41	10	0	6	2	86	91	\N
42	7	0	10	2	87	91	\N
43	3	0	4	2	88	91	\N
44	1	0	5	2	89	91	\N
45	6	0	9	2	101	133	\N
46	9	0	2	2	102	133	\N
47	1	0	5	2	103	133	\N
48	7	0	10	2	104	133	\N
49	53	1	7	5	161	3151	\N
50	54	3	3	5	161	3151	\N
51	55	5	8	5	161	3151	\N
52	56	7	4	5	161	3151	\N
53	57	9	11	5	161	3151	\N
54	53	0	7	5	163	3268	\N
55	54	1	7	5	163	3268	\N
56	55	2	7	5	163	3268	\N
57	56	3	7	5	163	3268	\N
58	57	4	7	5	163	3268	\N
59	63	1	3	5	165	3312	\N
60	46	1	7	5	167	3360	\N
61	46	1	7	5	169	3417	\N
62	67	1	3	9	271	7103	\N
63	48	0	12	13	375	11259	\N
64	45	0	13	13	379	11383	\N
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
2	59999528998286	4539888	24	99	1	2024-05-28 13:59:36.8	2024-05-28 14:02:46.2
5	0	0	0	114	4	2024-05-28 14:09:35.6	2024-05-28 14:12:49.2
11	0	0	0	94	10	2024-05-28 14:29:37.4	2024-05-28 14:32:50.4
4	2201873797093	2024698	10	98	3	2024-05-28 14:06:19	2024-05-28 14:09:29.8
1	268782707655286121	13876531	76	106	0	2024-05-28 13:56:24.6	2024-05-28 13:59:29.6
7	0	0	0	89	6	2024-05-28 14:16:17.6	2024-05-28 14:19:34
10	20525635404487	16936200	100	95	9	2024-05-28 14:26:15.2	2024-05-28 14:29:27.2
8	5059329617970	597774	2	82	7	2024-05-28 14:19:37	2024-05-28 14:22:48.6
3	16199391799035	7581975	12	111	2	2024-05-28 14:02:56.4	2024-05-28 14:06:09.4
6	3712299648464	16900868	100	105	5	2024-05-28 14:12:55.8	2024-05-28 14:16:09.4
9	0	0	0	102	8	2024-05-28 14:22:56.2	2024-05-28 14:26:13
12	30081979446070	2306288	12	52	11	2024-05-28 14:32:59.4	2024-05-28 14:35:01.4
\.


--
-- Data for Name: epoch_param; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_param (id, epoch_no, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, nonce, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, block_id, extra_entropy, coins_per_utxo_size) FROM stdin;
1	1	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x1ebb0e6cf3b4aacbc2288d8ece368b9c05db200cdde5bcefbeedc3c2f899f2ea	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	114	\N	4310
2	2	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xee077a953502f74754b5877266275558bcd44c120c184a6c66876f91cb0d97c2	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	218	\N	4310
3	3	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x29eefaa1ac7700ca821a62005a4a314bb352583f991188d3f2628258f45eeb68	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	334	\N	4310
4	4	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x7ca0d71d9e1d8d943860ec065ead6c5884f001d74e4b9c7c42aa4fcfde2fae73	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	436	\N	4310
6	5	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x1c200c2e765d763da5bf39917f8ff7df9d5eef4cc5697293d2dcbf040e07a8be	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	556	\N	4310
7	6	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x581206fbf0e5ed0b3eb03d485844f3f12cbf0fa5d2520595c9d0e3fcf586590f	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	663	\N	4310
8	7	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x1ab97119af278884cd6b92179ffe3885ab272a42485b62b344874ad0dfde2000	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	754	\N	4310
9	8	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x4f70967b05459af9b1e7bffad6ee3d3480f50a5cd47dccdaf20a2cecf18b970e	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	837	\N	4310
10	9	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x3687505d8cc0906052db5fe44d42b667aadaf4f445b5a593d122119d1e79c334	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	941	\N	4310
11	10	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xf504f4857798d029e1b70e210133a9a63e4ae0d79498907993bf00c152ca67a0	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1039	\N	4310
12	11	44	155381	65536	16384	1100	2000000	500000000	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x559f8dc513ef91f95ece65a0045aa52c6bec4e4b9326b8945ce8183a937b4a9f	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1136	\N	4310
\.


--
-- Data for Name: epoch_stake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_stake (id, addr_id, pool_id, amount, epoch_no) FROM stdin;
1	3	4	3681818181818181	1
2	5	1	3681818181818181	1
3	9	2	3681818181818181	1
4	4	7	3681818181818181	1
5	10	6	3681818181818181	1
6	2	11	3681818181818181	1
7	8	3	3681818181818181	1
8	6	9	3681818181818181	1
9	7	10	3681818181818190	1
10	1	5	3681818181818181	1
11	11	8	3681818181818181	1
12	3	4	3681818181443619	2
13	5	1	3681818181446391	2
14	22	11	200000000	2
15	19	8	500000000	2
16	9	2	3681818181265842	2
17	4	7	3681818181443619	2
18	10	6	3681818181443619	2
19	13	2	300000000	2
20	2	11	3681818181443619	2
21	8	3	3681818181443619	2
22	16	5	500000000	2
23	18	7	500000000	2
24	6	9	3681818181265842	2
25	12	1	600000000	2
26	15	4	500000000	2
27	7	10	3681818181263035	2
28	20	9	300000000	2
29	17	6	500000000	2
30	14	3	500000000	2
31	1	5	3681818181263026	2
32	11	8	3681818181443619	2
33	21	10	500000000	2
34	3	4	3681818181443619	3
35	5	1	3681818181446391	3
36	22	11	200000000	3
37	19	8	500000000	3
38	9	2	3681818181265842	3
39	4	7	3681818181443619	3
40	10	6	3681818181443619	3
41	13	2	300000000	3
42	2	11	3681818181443619	3
43	8	3	3681818181443619	3
44	16	5	500000000	3
45	18	7	500000000	3
46	6	9	3681818181265842	3
47	12	1	600000000	3
48	15	4	500000000	3
49	7	10	3681818181263035	3
50	20	9	300000000	3
51	17	6	500000000	3
52	14	3	500000000	3
53	1	5	3681818181263026	3
54	11	8	3681818181443619	3
55	21	10	500000000	3
56	3	4	3688874893634389	4
57	5	1	3687992804613315	4
58	22	11	200000000	4
59	19	8	500000000	4
60	9	2	3686228626385073	4
61	4	7	3694167427777468	4
62	10	6	3689756982658236	4
63	13	2	300000000	4
64	2	11	3687992804610543	4
65	8	3	3687110715586697	4
66	16	5	500000000	4
67	18	7	500000000	4
68	6	9	3691521160528151	4
69	12	1	600000000	4
70	15	4	500000000	4
71	7	10	3687992804429959	4
72	20	9	300000000	4
73	17	6	500000000	4
74	14	3	500000000	4
75	1	5	3693285338573028	4
76	11	8	3693285338753621	4
77	21	10	500000000	4
78	3	4	3695822052498772	5
79	5	1	3692624243604648	5
80	56	7	0	5
81	22	11	200503168	5
82	19	8	501362748	5
83	9	2	3693947692628931	5
84	4	7	3701886493182338	5
85	55	7	0	5
86	10	6	3699019861144081	5
87	13	2	300628960	5
88	2	11	3697255684605894	5
89	8	3	3693285967910593	5
90	53	7	0	5
91	16	5	500628960	5
92	18	7	501048268	5
93	6	9	3700784040020780	5
94	54	7	0	5
95	12	1	600754753	5
96	15	4	500943441	5
97	7	10	3698799495997308	5
98	20	9	300754753	5
99	17	6	501257921	5
100	14	3	500838614	5
101	57	7	989212833	5
102	1	5	3697916777816177	5
103	11	8	3703320123779953	5
104	46	7	4998901792324	5
105	21	10	501467575	5
134	3	4	3700863340851117	6
135	5	1	3697665531683132	6
136	56	7	0	6
137	22	11	200503168	6
138	19	8	509231963549	6
139	9	2	3693947692628931	6
140	4	7	3710528938572040	6
141	55	7	0	6
142	10	6	3706221835218842	6
143	13	2	300628960	6
144	2	11	3697255684605894	6
145	8	3	3699767736077879	6
146	53	7	0	6
147	16	5	1780245981963	6
148	18	7	1526029850763	6
149	6	9	3700784040020780	6
150	54	7	0	6
151	12	1	890630793948	6
152	15	4	890530869877	6
153	7	10	3705281247164914	6
154	20	9	300754753	6
155	17	6	1271839009991	6
156	14	3	1144713315476	6
157	57	7	989212833	6
158	1	5	3707999669021320	6
159	11	8	3706200717909883	6
160	46	7	4998901792324	6
161	21	10	1144730944491	6
162	3	4	3708252421378478	7
163	5	1	3703208584444710	7
164	56	7	0	7
165	22	11	200503168	7
166	19	8	1703483147094	7
167	4	7	3721596845200076	7
168	55	7	0	7
169	10	6	3711146592207870	7
170	2	11	3697255684605894	7
171	8	3	3706544290257750	7
172	53	7	0	7
173	18	7	3479581606327	7
174	6	9	3700784040020780	7
175	54	7	0	7
176	12	1	1869207636344	7
177	15	4	2194877435335	7
178	7	10	3710208368609331	7
179	20	9	300754753	7
180	17	6	2141314557884	7
181	14	3	2340946898926	7
182	57	7	989212833	7
183	11	8	3712965925177448	7
184	46	7	4998884891456	7
185	21	10	2014613749970	7
186	3	4	3713505567801707	8
187	5	1	3708466280089082	8
188	56	7	0	8
189	22	11	200503168	8
190	19	8	2629022764370	8
191	4	7	3725519563537656	8
192	55	7	0	8
193	10	6	3717707422562130	8
194	2	11	3697255684605894	8
195	8	3	3713115332446323	8
196	53	7	0	8
197	18	7	4173151611798	8
198	6	9	3700784040020780	8
199	54	7	0	8
200	12	1	2797427285794	8
201	15	4	3122294112408	8
202	7	10	3717425754485859	8
203	20	9	300754753	8
204	17	6	3299509195770	8
205	14	3	3500913627597	8
206	57	7	990261056	8
207	11	8	3718208434943741	8
208	46	7	5004181997070	8
209	21	10	3288661232301	8
210	3	4	3716242846761005	9
211	5	1	3715315890236932	9
212	56	7	0	9
213	22	11	200503168	9
214	19	8	3595261317423	9
215	4	7	3733005308830809	9
216	55	7	0	9
217	10	6	3724539812535851	9
218	2	11	3697255684605894	9
219	8	3	3717906595971617	9
220	53	7	0	9
221	18	7	5499957493918	9
222	6	9	3700784040020780	9
223	54	7	0	9
224	12	1	4008512979666	9
225	15	4	3606508241238	9
226	7	10	3724260355017726	9
227	20	9	300754753	9
228	17	6	4508383455752	9
229	14	3	4348544748108	9
230	57	7	992256727	9
231	11	8	3723676567934709	9
232	67	3	2502089911164	9
233	46	7	2512174439949	9
234	21	10	4497641350725	9
235	3	4	3721198908589032	10
236	5	1	3721382680247074	10
237	56	7	0	10
238	22	11	200503168	10
239	19	8	4569428511014	10
240	4	7	3740114554540467	10
241	55	7	0	10
242	10	6	3728941850769216	10
243	2	11	3697255684605894	10
244	8	3	3722313645197696	10
245	53	7	0	10
246	18	7	6764425673791	10
247	6	9	3700784040020780	10
248	54	7	0	10
249	12	1	5083115609366	10
250	15	4	4484948497142	10
251	7	10	3726461918999388	10
252	20	9	300754753	10
253	17	6	5288601915599	10
254	14	3	5129903865290	10
255	57	7	994146388	10
256	11	8	3729177812478142	10
257	67	3	2502089911164	10
258	46	7	2521723647573	10
259	21	10	4887949031959	10
260	3	4	3725943751079444	11
261	5	1	3725606742593499	11
262	56	7	0	11
263	22	11	200503168	11
264	19	8	5690414837042	11
265	4	7	3745352634977211	11
266	55	7	0	11
267	10	6	3735787265028971	11
268	2	11	3697255684605894	11
269	8	3	3729166793368934	11
270	53	7	0	11
271	18	7	7697327564867	11
272	6	9	3700784040020780	11
273	54	7	0	11
274	12	1	5832677034776	11
275	15	4	5327357096935	11
276	7	10	3731201342018701	11
277	20	9	300754753	11
278	17	6	6504163709569	11
279	14	3	6347254714318	11
280	57	7	995538695	11
281	11	8	3735498066037632	11
282	67	3	2502063388168	11
283	46	7	2528769114163	11
284	21	10	5729640485082	11
\.


--
-- Data for Name: epoch_sync_time; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_sync_time (id, no, seconds, state) FROM stdin;
1	0	193	following
2	1	200	following
3	2	203	following
4	3	197	following
5	4	201	following
6	5	202	following
7	6	200	following
8	7	200	following
9	8	200	following
10	9	203	following
11	10	203	following
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
1	13500000000000000	118	1
2	13500000000000000	118	2
3	13500000000000000	118	3
4	13500000000000000	118	4
5	2	120	5
6	1	120	6
7	1	120	7
8	1	121	8
9	1	122	9
10	1	122	10
11	1	122	11
12	1	123	12
13	1	124	13
14	1	125	14
15	-1	128	14
16	-1	128	9
17	-1	128	12
18	-1	128	10
19	-1	128	13
20	-1	129	11
21	1	130	11
22	1	131	11
23	-2	132	11
24	2	133	11
25	-2	134	11
26	2	135	11
27	-1	136	11
28	-1	137	11
29	1	138	15
30	1	138	16
31	1	138	17
32	-1	139	16
33	1	140	18
35	1	142	19
36	1	143	20
37	-1	144	18
38	-1	144	19
39	-1	144	20
40	-1	144	15
41	-1	144	17
42	10	145	21
43	-10	146	21
44	1	147	22
45	-1	148	22
46	1	380	9
47	1	380	10
48	1	380	11
49	1	381	12
50	1	382	13
51	1	383	14
\.


--
-- Data for Name: ma_tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ma_tx_out (id, quantity, tx_out_id, ident) FROM stdin;
1	13500000000000000	135	1
2	13500000000000000	135	2
3	13500000000000000	135	3
4	13500000000000000	135	4
5	2	143	5
6	1	143	6
7	1	143	7
8	1	145	8
9	1	147	9
10	1	147	10
11	1	147	11
12	1	149	12
13	1	150	9
14	1	150	10
15	1	150	11
16	1	151	13
17	1	152	9
18	1	152	10
19	1	152	11
20	1	153	14
21	1	153	12
22	1	154	11
23	1	155	9
24	1	155	10
25	1	157	9
26	1	157	10
27	1	160	11
28	1	162	11
29	2	165	11
30	2	168	11
31	1	170	11
32	1	172	15
33	1	172	16
34	1	172	17
35	1	175	15
36	1	175	17
37	1	176	18
40	1	180	19
41	1	181	18
42	1	182	20
43	1	183	18
44	1	183	15
45	1	183	17
46	10	185	21
47	1	188	22
48	1	811	8
49	2	811	5
50	1	811	6
51	1	811	7
52	13500000000000000	811	1
53	13500000000000000	811	2
54	13500000000000000	811	3
55	13500000000000000	811	4
56	1	813	8
57	2	813	5
58	1	813	6
59	1	813	7
60	13500000000000000	813	1
61	13500000000000000	813	2
62	13500000000000000	813	3
63	13500000000000000	813	4
64	1	815	8
65	2	815	5
66	1	815	6
67	1	815	7
68	13500000000000000	815	1
69	13500000000000000	815	2
70	13500000000000000	815	3
71	13500000000000000	815	4
72	1	816	9
73	1	816	10
74	1	816	11
75	1	818	12
76	1	820	13
77	1	822	14
\.


--
-- Data for Name: meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meta (id, start_time, network_name, version) FROM stdin;
1	2024-05-28 13:56:15	testnet	Version {versionBranch = [13,1,0,2], versionTags = []}
\.


--
-- Data for Name: multi_asset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.multi_asset (id, policy, name, fingerprint) FROM stdin;
1	\\xd6eecaa6767bf706c33c273641121061deb1bbbed2419222bd89acfb	\\x	asset1lfasu5srp35l4qr6sgvwqjxq05f4lt5rwlfger
2	\\xd6eecaa6767bf706c33c273641121061deb1bbbed2419222bd89acfb	\\x74425443	asset1jhvem3s8hq2eew4g0ppujj7z76kwfscrcyp2cd
3	\\xd6eecaa6767bf706c33c273641121061deb1bbbed2419222bd89acfb	\\x74455448	asset1q8k94fcwwa36gk29d46jln7z8439h7tuewtw3e
4	\\xd6eecaa6767bf706c33c273641121061deb1bbbed2419222bd89acfb	\\x744d494e	asset1l5ms60jl22qw90ycs3yslpr4rn322zc3ydge64
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
-- Data for Name: param_proposal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.param_proposal (id, epoch_no, key, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, entropy, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, registered_tx_id, coins_per_utxo_size) FROM stdin;
\.


--
-- Data for Name: pool_hash; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_hash (id, hash_raw, view) FROM stdin;
1	\\x10e8eb0bbc8b01efcbbfb20df659c69d018e1e9ffcb7bdfded42b205	pool1zr5wkzau3vq7ljalkgxlvkwxn5qcu85lljmmml0dg2eq2yxd3cu
2	\\x1382638c2ebc3f978eb25a740b4d685d4434dad137294792c9a49290	pool1zwpx8rpwhsle0r4jtf6qkntgt4zrfkk3xu550ykf5jffqmshgv5
3	\\x1fcda2a751c476ecdd45936d5115037f1617ca266cfdf9d4f85f5583	pool1rlx69f63c3mweh29jdk4z9gr0utp0j3xdn7ln48cta2cxg3vuvp
4	\\x264e011a7bbd275c413f2ee6b6fa3b6bba403f1bfd6946f6bdbe3391	pool1ye8qzxnmh5n4csfl9mntd73mdwayq0cml455da4ahceez4lf3g7
5	\\x3c14be5ca907bb99d8e8ad6d584711887afee854184d0832bf6ead30	pool18s2tuh9fq7aenk8g44k4s3c33pa0a6z5rpxssv4ld6knqv0ukfh
6	\\x438d202759456411e2430b8d2a2fc64e107ebf4bb9c6f97a3ca49b90	pool1gwxjqf6eg4jprcjrpwxj5t7xfcg8a06th8r0j73u5jdeq845rl2
7	\\x5042dc1f20a769aa694f0cffe5ecff7fcf27c206c3212a622b3836a5	pool12ppdc8eq5a565620pnl7tm8l0l8j0ssxcvsj5c3t8qm220pxw7e
8	\\x76687c8c1ac150006ca6b59dd7fb4244d627a1ae16ac0548acbe8442	pool1we58erq6c9gqqm9xkkwa076zgntz0gdwz6kq2j9vh6zyygmje56
9	\\x8cd47bbc8a2ff2212fdca6f6b379c00bb94341c82164dd90a024e86c	pool13n28h0y29lezzt7u5mmtx7wqpwu5xswgy9jdmy9qyn5xc9apmhq
10	\\xa1c865cc9a6517b1fcdc32cc188261eb14963aaadf3ee8ba2155dff4	pool158yxtny6v5tmrlxuxtxp3qnpav2fvw42mulw3w3p2h0lgy9x3np
11	\\xe0bab0b4bb55862bed0fdbc9a729b359fda1d79d3a04e8101cdcebb1	pool1uzatpd9m2krzhmg0m0y6w2dnt876r4ua8gzwsyqumn4mzjdmfcv
12	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
13	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_metadata_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata_ref (id, pool_id, url, hash, registered_tx_id) FROM stdin;
1	5	http://file-server/SP10.json	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	93
2	8	http://file-server/SP5.json	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	94
3	7	http://file-server/SP7.json	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	95
4	6	http://file-server/SP6.json	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	96
5	4	http://file-server/SP1.json	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	97
6	3	http://file-server/SP4.json	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	98
7	11	http://file-server/SP3.json	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	99
8	10	http://file-server/SP11.json	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	100
\.


--
-- Data for Name: pool_offline_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_offline_data (id, pool_id, ticker_name, hash, json, bytes, pmr_id) FROM stdin;
1	5	SP10	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	{"name": "Stake Pool - 10", "ticker": "SP10", "homepage": "https://stakepool10.com", "description": "This is the stake pool 10 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130222c0a2020227469636b6572223a202253503130222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203130206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31302e636f6d220a7d0a	1
2	8	SP5	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	{"name": "Same Name", "ticker": "SP5", "homepage": "https://stakepool5.com", "description": "This is the stake pool 5 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535035222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2035206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c352e636f6d220a7d0a	2
3	7	SP6a7	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	{"name": "", "ticker": "SP6a7", "homepage": "https://stakepool7.com", "description": "This is the stake pool 7 description."}	\\x7b0a2020226e616d65223a2022222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2037206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c372e636f6d220a7d0a	3
4	6	SP6a7	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	{"name": "Stake Pool - 6", "ticker": "SP6a7", "homepage": "https://stakepool6.com", "description": "This is the stake pool 6 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2036222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2036206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c362e636f6d220a7d0a	4
5	4	SP1	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	{"name": "stake pool - 1", "ticker": "SP1", "homepage": "https://stakepool1.com", "description": "This is the stake pool 1 description."}	\\x7b0a2020226e616d65223a20227374616b6520706f6f6c202d2031222c0a2020227469636b6572223a2022535031222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2031206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c312e636f6d220a7d0a	5
6	3	SP4	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	{"name": "Same Name", "ticker": "SP4", "homepage": "https://stakepool4.com", "description": "This is the stake pool 4 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535034222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2034206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c342e636f6d220a7d0a	6
7	11	SP3	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	{"name": "Stake Pool - 3", "ticker": "SP3", "homepage": "https://stakepool3.com", "description": "This is the stake pool 3 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2033222c0a2020227469636b6572223a2022535033222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2033206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c332e636f6d220a7d0a	7
8	10	SP11	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	{"name": "Stake Pool - 10 + 1", "ticker": "SP11", "homepage": "https://stakepool11.com", "description": "This is the stake pool 11 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130202b2031222c0a2020227469636b6572223a202253503131222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203131206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31312e636f6d220a7d0a	8
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
1	20	12
2	13	13
3	12	14
4	16	15
5	19	16
6	18	17
7	17	18
8	15	19
9	14	20
10	22	21
11	21	22
12	48	23
13	45	24
\.


--
-- Data for Name: pool_relay; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_relay (id, update_id, ipv4, ipv6, dns_name, dns_srv_name, port) FROM stdin;
1	12	127.0.0.1	\N	\N	\N	3009
2	13	127.0.0.1	\N	\N	\N	3008
3	14	127.0.0.1	\N	\N	\N	3002
4	15	127.0.0.1	\N	\N	\N	30010
5	16	127.0.0.1	\N	\N	\N	3005
6	17	127.0.0.1	\N	\N	\N	3007
7	18	127.0.0.1	\N	\N	\N	3006
8	19	127.0.0.1	\N	\N	\N	3001
9	20	127.0.0.1	\N	\N	\N	3004
10	21	127.0.0.1	\N	\N	\N	3003
11	22	127.0.0.1	\N	\N	\N	30011
12	23	127.0.0.1	\N	\N	\N	6000
13	24	127.0.0.2	\N	\N	\N	6000
\.


--
-- Data for Name: pool_retire; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retire (id, hash_id, cert_index, announced_tx_id, retiring_epoch) FROM stdin;
1	9	0	105	18
2	2	0	106	5
3	5	0	107	5
4	10	0	108	18
\.


--
-- Data for Name: pool_update; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_update (id, hash_id, cert_index, vrf_key_hash, pledge, active_epoch_no, meta_id, margin, fixed_cost, registered_tx_id, reward_addr_id) FROM stdin;
1	1	0	\\x893b5788cbc1b415a02656b7af568bd7f9545319eba2ba4c74679df10c21cccb	0	2	\N	0	0	34	12
2	2	1	\\xb281b4e6d5ab81a667f7753f0059212a9392e2cac46054be0a00d3f774962288	0	2	\N	0	0	34	13
3	3	2	\\x7d3c31583393693cbf4c29306e3aa92f86f4daa8e165fc346f1273d8ff630cb5	0	2	\N	0	0	34	14
4	4	3	\\x8c01107dc2f8bae37f54df5639b49e67ab6ffaf5bacb23a30a0fedb34b2028bf	0	2	\N	0	0	34	15
5	5	4	\\x709197f31cffebcedf7bd1d83757cf2fec21682f6b16842038a4cf28fcf6bde8	0	2	\N	0	0	34	16
6	6	5	\\x7ef092090d4ac8973e4bf29b0a259372594c89689b89e057191c9c07a422687b	0	2	\N	0	0	34	17
7	7	6	\\xf45d2ce0960d28368b6063aef7e90f7e872b0312fd43ee2e4bd3f5f4b5df27b7	0	2	\N	0	0	34	18
8	8	7	\\x7db52907bcf7834d47f1004a1d11f2c73bba5e187d03951a38ebb0b78968a22d	0	2	\N	0	0	34	19
9	9	8	\\xc9c93d6ddab928a74a60e375c46c7327b1919cf529988a9ab9c9a4df2823eae0	0	2	\N	0	0	34	20
10	10	9	\\xa134db32d78ab4e2f09c73262c1c087f3667508a71ae0a6dd2907a428f084171	0	2	\N	0	0	34	21
11	11	10	\\x6e4892cc71cf271129e5d5be90485bb794ec9f7a92448b6af7a5f4ffe9c90c99	0	2	\N	0	0	34	22
12	9	0	\\xc9c93d6ddab928a74a60e375c46c7327b1919cf529988a9ab9c9a4df2823eae0	500000000	3	\N	0.149999999999999994	390000000	90	20
13	2	0	\\xb281b4e6d5ab81a667f7753f0059212a9392e2cac46054be0a00d3f774962288	500000000	3	\N	0.149999999999999994	380000000	91	13
14	1	0	\\x893b5788cbc1b415a02656b7af568bd7f9545319eba2ba4c74679df10c21cccb	500000000	3	\N	0.149999999999999994	390000000	92	12
15	5	0	\\x709197f31cffebcedf7bd1d83757cf2fec21682f6b16842038a4cf28fcf6bde8	400000000	3	1	0.149999999999999994	410000000	93	16
16	8	0	\\x7db52907bcf7834d47f1004a1d11f2c73bba5e187d03951a38ebb0b78968a22d	410000000	3	2	0.149999999999999994	390000000	94	19
17	7	0	\\xf45d2ce0960d28368b6063aef7e90f7e872b0312fd43ee2e4bd3f5f4b5df27b7	410000000	3	3	0.149999999999999994	390000000	95	18
18	6	0	\\x7ef092090d4ac8973e4bf29b0a259372594c89689b89e057191c9c07a422687b	410000000	3	4	0.149999999999999994	400000000	96	17
19	4	0	\\x8c01107dc2f8bae37f54df5639b49e67ab6ffaf5bacb23a30a0fedb34b2028bf	400000000	3	5	0.149999999999999994	390000000	97	15
20	3	0	\\x7d3c31583393693cbf4c29306e3aa92f86f4daa8e165fc346f1273d8ff630cb5	420000000	3	6	0.149999999999999994	370000000	98	14
21	11	0	\\x6e4892cc71cf271129e5d5be90485bb794ec9f7a92448b6af7a5f4ffe9c90c99	600000000	3	7	0.149999999999999994	390000000	99	22
22	10	0	\\xa134db32d78ab4e2f09c73262c1c087f3667508a71ae0a6dd2907a428f084171	400000000	3	8	0.149999999999999994	390000000	100	21
23	12	0	\\x2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	500000000000000	13	\N	0.200000000000000011	1000	373	48
24	13	0	\\x641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	50000000	13	\N	0.200000000000000011	1000	377	45
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
1	110	1700	476468	133	spend	0	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	1
2	117	656230	203682571	52550	spend	0	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	2
\.


--
-- Data for Name: redeemer_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.redeemer_data (id, hash, tx_id, value, bytes) FROM stdin;
1	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	110	{"int": 12}	\\x0c
2	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	117	{"int": 42}	\\x182a
\.


--
-- Data for Name: reference_tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reference_tx_in (id, tx_in_id, tx_out_id, tx_out_index) FROM stdin;
1	117	111	0
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
3	5	12:56:
4	6	::
5	7	::
6	8	23:67:
7	9	::
8	10	::
10	12	45:89:
11	13	56:100:
12	14	::
13	15	::
14	16	67:111:
15	17	71:115:
16	18	::
17	19	75:119:
18	20	76:121:
19	21	::
20	22	::
21	23	77:122:
22	24	78:124:
23	25	79:126:
24	26	80:128:
25	27	81:130:
26	28	::
27	29	::
28	30	82:132:
29	31	::
30	32	83:134:
31	33	::
32	34	85:135:1
33	35	::
34	36	::
35	37	86:137:
36	38	::
37	39	87:143:5
38	40	88:145:8
39	41	::
40	42	::
41	43	::
42	44	::
43	45	::
44	46	::
45	47	::
46	48	::
47	49	::
48	50	::
49	51	::
50	52	::
51	53	::
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
104	106	::
105	107	::
106	108	::
107	109	::
108	110	::
109	111	::
110	112	::
111	113	::
112	114	::
113	115	89:147:9
115	117	::
116	118	::
117	119	::
118	120	90:149:12
119	121	::
120	122	::
121	123	::
122	124	92:151:16
123	125	::
124	126	::
125	127	::
126	128	93:153:20
127	129	::
128	130	::
129	131	::
130	132	94:154:22
132	134	::
133	135	::
134	136	::
135	137	95:156:25
136	138	::
137	139	::
138	140	::
139	141	96:158:
140	142	::
141	143	::
142	144	::
143	145	99:159:
144	146	::
145	147	::
146	148	::
147	149	100:160:27
148	150	::
149	151	::
150	152	::
151	153	101:162:28
152	154	::
153	155	::
154	156	::
155	157	102:164:
156	158	::
157	159	::
158	160	::
159	161	104:165:29
160	162	::
161	163	::
162	164	::
163	165	105:167:
164	166	::
165	167	::
166	168	::
167	169	106:168:30
168	170	::
169	171	::
170	172	::
171	173	108:170:31
172	174	::
173	175	::
174	176	::
175	177	109:171:
176	178	::
177	179	::
178	180	::
179	181	::
180	182	110:172:32
181	183	::
182	184	::
183	185	::
184	186	112:174:35
185	187	::
186	188	::
187	189	::
188	190	114:176:37
189	191	::
190	192	::
191	193	::
193	195	118:180:40
195	197	::
196	198	::
197	199	::
198	200	120:182:42
199	201	::
200	202	::
201	203	::
202	204	122:184:
203	205	::
204	206	::
205	207	::
206	208	::
207	209	125:185:46
208	210	::
209	211	::
210	212	::
211	213	126:187:
212	214	::
213	215	::
214	216	::
215	217	127:188:47
216	218	::
217	219	::
218	220	::
219	221	128:190:
220	222	::
221	223	::
222	224	::
223	225	129:191:
224	226	::
225	227	::
226	228	::
227	229	::
228	230	::
229	231	134:195:
230	232	::
231	233	135:197:
232	234	::
233	235	::
234	236	136:317:
235	237	196:319:
236	238	197:321:
237	239	::
238	240	198:323:
239	241	199::
240	242	::
241	243	::
242	244	::
243	245	200:325:
244	246	::
245	247	::
246	248	::
247	249	201:327:
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
320	322	::
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
336	338	::
337	339	::
338	340	::
339	341	::
340	342	::
341	343	::
343	345	::
344	346	::
345	347	::
346	348	202:329:
347	349	::
348	350	::
349	351	::
350	352	::
351	353	203:331:
352	354	::
353	355	::
354	356	::
355	357	204:366:
356	358	::
357	359	::
358	360	::
359	361	::
360	362	::
361	363	::
362	364	239:375:
363	365	::
364	366	::
365	367	::
366	368	240:376:
367	369	241:378:
368	370	242:380:
369	371	::
370	372	243:381:
371	373	244:383:
372	374	::
373	375	::
374	376	::
375	377	::
376	378	245:384:
377	379	::
378	380	::
379	381	::
380	382	::
381	383	::
382	384	::
383	385	::
384	386	::
385	387	::
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
441	443	::
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
479	481	::
480	482	::
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
550	552	::
551	553	::
552	554	::
554	556	::
555	557	246:385:
556	558	357:549:
557	559	365:557:
558	560	372:567:
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
614	616	::
615	617	::
616	618	::
617	619	::
618	620	::
619	621	::
620	622	::
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
753	755	386:585:
754	756	::
755	757	::
756	758	::
757	759	387:587:
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
941	943	514:601:
942	944	559:665:
943	945	595:711:
944	946	600:717:
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
1135	1137	676:801:
1136	1138	::
1137	1139	::
1138	1140	::
1139	1141	::
1140	1142	::
1141	1143	677:803:
1142	1144	::
1143	1145	::
1144	1146	::
1145	1147	678:805:
1146	1148	::
1147	1149	::
1148	1150	::
1149	1151	679:807:
1150	1152	::
1151	1153	::
1152	1154	::
1153	1155	681:809:
1154	1156	::
1155	1157	682:810:48
1156	1158	::
1157	1159	::
1158	1160	::
1159	1161	::
1160	1162	686:812:56
1161	1163	::
1162	1164	::
1163	1165	::
1164	1166	688:814:64
1165	1167	::
1167	1169	::
1168	1170	::
1169	1171	::
1170	1172	::
1171	1173	::
1172	1174	689:816:72
1173	1175	::
1174	1176	::
1175	1177	::
1176	1178	691:818:75
1177	1179	::
1178	1180	::
1179	1181	::
1180	1182	692:820:76
1181	1183	::
1182	1184	::
1183	1185	::
1184	1186	693:822:77
1185	1187	::
1186	1188	::
1187	1189	::
\.


--
-- Data for Name: reward; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward (id, addr_id, type, amount, earned_epoch, spendable_epoch, pool_id) FROM stdin;
1	3	member	7056712190770	1	3	4
2	5	member	6174623166924	1	3	1
3	9	member	4410445119231	1	3	2
4	4	member	12349246333849	1	3	7
5	10	member	7938801214617	1	3	6
6	2	member	6174623166924	1	3	11
7	8	member	5292534143078	1	3	3
8	6	member	9702979262309	1	3	9
9	7	member	6174623166924	1	3	10
10	1	member	11467157310002	1	3	5
11	11	member	11467157310002	1	3	8
12	22	leader	0	1	3	11
13	19	leader	0	1	3	8
14	13	leader	0	1	3	2
15	16	leader	0	1	3	5
16	18	leader	0	1	3	7
17	12	leader	0	1	3	1
18	15	leader	0	1	3	4
19	20	leader	0	1	3	9
20	17	leader	0	1	3	6
21	14	leader	0	1	3	3
22	21	leader	0	1	3	10
23	3	member	6947158864383	2	4	4
24	5	member	4631438991333	2	4	1
25	22	member	503168	2	4	11
26	19	member	1362748	2	4	8
27	9	member	7719066243858	2	4	2
28	4	member	7719065404870	2	4	7
29	10	member	9262878485845	2	4	6
30	13	member	628960	2	4	2
31	2	member	9262879995351	2	4	11
32	8	member	6175252323896	2	4	3
34	16	member	628960	2	4	5
35	18	member	1048268	2	4	7
36	6	member	9262879492629	2	4	9
37	12	member	754753	2	4	1
38	15	member	943441	2	4	4
39	7	member	10806691567349	2	4	10
40	20	member	754753	2	4	9
41	17	member	1257921	2	4	6
42	14	member	838614	2	4	3
43	1	member	4631439243149	2	4	5
44	11	member	10034785026332	2	4	8
45	21	member	1467575	2	4	10
46	22	leader	0	2	4	11
47	19	leader	0	2	4	8
48	13	leader	0	2	4	2
49	16	leader	0	2	4	5
50	18	leader	0	2	4	7
51	12	leader	0	2	4	1
52	15	leader	0	2	4	4
53	20	leader	0	2	4	9
54	17	leader	0	2	4	6
55	14	leader	0	2	4	3
56	21	leader	0	2	4	10
57	3	member	5041288352345	3	5	4
58	5	member	5041288078484	3	5	1
59	4	member	8642445389702	3	5	7
60	10	member	7201974074761	3	5	6
61	8	member	6481768167286	3	5	3
62	7	member	6481751167606	3	5	10
63	1	member	10082891205143	3	5	5
64	11	member	2880594129930	3	5	8
65	22	leader	0	3	5	11
66	19	leader	508730600801	3	5	8
67	13	leader	0	3	5	2
68	16	leader	1779745353003	3	5	5
69	18	leader	1525528802495	3	5	7
70	12	leader	890030039195	3	5	1
71	15	leader	890029926436	3	5	4
72	20	leader	0	3	5	9
73	17	leader	1271337752070	3	5	6
74	14	leader	1144212476862	3	5	3
75	21	leader	1144229476916	3	5	10
76	13	refund	500000000	5	5	2
77	16	refund	500000000	5	5	5
80	3	member	7389080527361	4	6	4
81	5	member	5543052761578	4	6	1
82	4	member	11067906628036	4	6	7
83	10	member	4924756989028	4	6	6
84	8	member	6776554179871	4	6	3
85	7	member	4927121444417	4	6	10
86	1	member	5535092310107	4	6	5
87	11	member	6765207267565	4	6	8
89	22	leader	0	4	6	11
90	19	leader	1194251183545	4	6	8
91	13	leader	0	4	6	2
92	16	leader	977191877483	4	6	5
93	18	leader	1953551755564	4	6	7
94	12	leader	978576842396	4	6	1
95	15	leader	1304346565458	4	6	4
96	20	leader	0	4	6	9
97	17	leader	869475547893	4	6	6
98	14	leader	1196233583450	4	6	3
99	21	leader	869882805479	4	6	10
100	3	member	5253146423229	5	7	4
101	5	member	5257695644372	5	7	1
102	4	member	3922718337580	5	7	7
103	10	member	6560830354260	5	7	6
104	8	member	6571042188573	5	7	3
105	7	member	7217385876528	5	7	10
106	57	member	1048223	5	7	7
107	1	member	5250153535025	5	7	5
108	11	member	5242509766293	5	7	8
109	46	member	5297105614	5	7	7
110	22	leader	0	5	7	11
111	19	leader	925539617276	5	7	8
112	13	leader	0	5	7	2
113	16	leader	926908518855	5	7	5
114	18	leader	693570005471	5	7	7
115	12	leader	928219649450	5	7	1
116	15	leader	927416677073	5	7	4
117	20	leader	0	5	7	9
118	17	leader	1158194637886	5	7	6
119	14	leader	1159966728671	5	7	3
120	21	leader	1274047482331	5	7	10
121	3	member	2737278959298	6	8	4
122	5	member	6849610147850	6	8	1
123	4	member	7485745293153	6	8	7
124	10	member	6832389973721	6	8	6
125	8	member	4791263525294	6	8	3
126	7	member	6834600531867	6	8	10
127	57	member	1995671	6	8	7
128	1	member	4778960699510	6	8	5
129	11	member	5468132990968	6	8	8
130	46	member	10084951817	6	8	7
131	22	leader	0	6	8	11
132	19	leader	966238553053	6	8	8
133	13	leader	0	6	8	2
134	16	leader	846455328831	6	8	5
135	18	leader	1326805882120	6	8	7
136	12	leader	1211085693872	6	8	1
137	15	leader	484214128830	6	8	4
138	20	leader	0	6	8	9
139	17	leader	1208874259982	6	8	6
140	14	leader	847631120511	6	8	3
141	21	leader	1208980118424	6	8	10
142	3	member	4956061828027	7	9	4
143	5	member	6066790010142	7	9	1
144	4	member	7109245709658	7	9	7
145	10	member	4402038233365	7	9	6
146	8	member	4407049226079	7	9	3
147	7	member	2201563981662	7	9	10
148	57	member	1889661	7	9	7
149	11	member	5501244543433	7	9	8
150	46	member	9549207624	7	9	7
151	22	leader	0	7	9	11
152	19	leader	974167193591	7	9	8
153	18	leader	1264468179873	7	9	7
154	12	leader	1074602629700	7	9	1
155	15	leader	878440255904	7	9	4
156	20	leader	0	7	9	9
157	17	leader	780218459847	7	9	6
158	14	leader	781359117182	7	9	3
159	21	leader	390307681234	7	9	10
160	3	member	4744842490412	8	10	4
161	5	member	4224062346425	8	10	1
162	4	member	5238080436744	8	10	7
163	10	member	6845414259755	8	10	6
164	8	member	6853148171238	8	10	3
165	7	member	4739423019313	8	10	10
166	57	member	1392307	8	10	7
167	11	member	6320253559490	8	10	8
168	46	member	7035879794	8	10	7
169	22	leader	0	8	10	11
170	19	leader	1120986326028	8	10	8
171	18	leader	932901891076	8	10	7
172	12	leader	749561425410	8	10	1
173	15	leader	842408599793	8	10	4
174	20	leader	0	8	10	9
175	17	leader	1215561793970	8	10	6
176	14	leader	1217350849028	8	10	3
177	21	leader	841691453123	8	10	10
178	3	member	4277353923919	9	11	4
179	5	member	6951135143421	9	11	1
180	4	member	6372400405378	9	11	7
181	10	member	5332298014150	9	11	6
182	8	member	5868639448609	9	11	3
184	7	member	6399349910185	9	11	10
185	57	member	1693824	9	11	7
186	11	member	5869801883350	9	11	8
187	67	member	3949497701	9	11	3
188	46	member	4288389674	9	11	7
189	22	leader	0	9	11	11
190	19	leader	1042904891231	9	11	8
191	18	leader	1136733808250	9	11	7
192	12	leader	1235884071740	9	11	1
193	15	leader	760100752010	9	11	4
194	20	leader	0	9	11	9
195	17	leader	948987297223	9	11	6
196	14	leader	1044784624479	9	11	3
197	21	leader	1138779090957	9	11	10
198	3	member	5785018312285	10	12	4
200	5	member	7885860770360	10	12	1
201	4	member	4697198583153	10	12	7
202	10	member	6819792078358	10	12	6
203	8	member	3673964237561	10	12	3
204	7	member	4200360102494	10	12	10
205	57	member	1248545	10	12	7
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
1	110	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	plutusV1	\N	\\x4d01000033222220051200120011	14
2	112	\\x477e52b3116b62fe8cd34a312615f5fcd678c94e1d6cdb86c1a3964c	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "e09d36c79dec9bd1b3d9e152247701cd0bb860b5ebfd1de8abb6735a"}, {"type": "sig", "keyHash": "a687dcc24e00dd3caafbeb5e68f97ca8ef269cb6fe971345eb951756"}, {"type": "sig", "keyHash": "0bd1d702b2e6188fe0857a6dc7ffb0675229bab58c86638ffa87ed6d"}]}	\N	\N
3	113	\\x120125c6dea2049988eb0dc8ddcc4c56dd48628d45206a2d0bc7e55b	timelock	{"type": "all", "scripts": [{"slot": 1000, "type": "after"}, {"type": "sig", "keyHash": "966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37"}]}	\N	\N
4	115	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	plutusV2	\N	\\x5908920100003233223232323232332232323232323232323232332232323232322223232533532323232325335001101d13357389211e77726f6e67207573616765206f66207265666572656e636520696e7075740001c3232533500221533500221333573466e1c00800408007c407854cd4004840784078d40900114cd4c8d400488888888888802d40044c08526221533500115333533550222350012222002350022200115024213355023320015021001232153353235001222222222222300e00250052133550253200150233355025200100115026320013550272253350011502722135002225335333573466e3c00801c0940904d40b00044c01800c884c09526135001220023333573466e1cd55cea80224000466442466002006004646464646464646464646464646666ae68cdc39aab9d500c480008cccccccccccc88888888888848cccccccccccc00403403002c02802402001c01801401000c008cd405c060d5d0a80619a80b80c1aba1500b33501701935742a014666aa036eb94068d5d0a804999aa80dbae501a35742a01066a02e0446ae85401cccd5406c08dd69aba150063232323333573466e1cd55cea801240004664424660020060046464646666ae68cdc39aab9d5002480008cc8848cc00400c008cd40b5d69aba15002302e357426ae8940088c98c80c0cd5ce01901a01709aab9e5001137540026ae854008c8c8c8cccd5cd19b8735573aa004900011991091980080180119a816bad35742a004605c6ae84d5d1280111931901819ab9c03203402e135573ca00226ea8004d5d09aba2500223263202c33573805c06005426aae7940044dd50009aba1500533501775c6ae854010ccd5406c07c8004d5d0a801999aa80dbae200135742a00460426ae84d5d1280111931901419ab9c02a02c026135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d55cf280089baa00135742a00860226ae84d5d1280211931900d19ab9c01c01e018375a00a6666ae68cdc39aab9d375400a9000100e11931900c19ab9c01a01c016101b132632017335738921035054350001b135573ca00226ea800448c88c008dd6000990009aa80d911999aab9f0012500a233500930043574200460066ae880080608c8c8cccd5cd19b8735573aa004900011991091980080180118061aba150023005357426ae8940088c98c8050cd5ce00b00c00909aab9e5001137540024646464646666ae68cdc39aab9d5004480008cccc888848cccc00401401000c008c8c8c8cccd5cd19b8735573aa0049000119910919800801801180a9aba1500233500f014357426ae8940088c98c8064cd5ce00d80e80b89aab9e5001137540026ae854010ccd54021d728039aba150033232323333573466e1d4005200423212223002004357426aae79400c8cccd5cd19b875002480088c84888c004010dd71aba135573ca00846666ae68cdc3a801a400042444006464c6403666ae7007407c06406005c4d55cea80089baa00135742a00466a016eb8d5d09aba2500223263201533573802e03202626ae8940044d5d1280089aab9e500113754002266aa002eb9d6889119118011bab00132001355018223233335573e0044a010466a00e66442466002006004600c6aae754008c014d55cf280118021aba200301613574200222440042442446600200800624464646666ae68cdc3a800a400046a02e600a6ae84d55cf280191999ab9a3370ea00490011280b91931900819ab9c01201400e00d135573aa00226ea80048c8c8cccd5cd19b875001480188c848888c010014c01cd5d09aab9e500323333573466e1d400920042321222230020053009357426aae7940108cccd5cd19b875003480088c848888c004014c01cd5d09aab9e500523333573466e1d40112000232122223003005375c6ae84d55cf280311931900819ab9c01201400e00d00c00b135573aa00226ea80048c8c8cccd5cd19b8735573aa004900011991091980080180118029aba15002375a6ae84d5d1280111931900619ab9c00e01000a135573ca00226ea80048c8cccd5cd19b8735573aa002900011bae357426aae7940088c98c8028cd5ce00600700409baa001232323232323333573466e1d4005200c21222222200323333573466e1d4009200a21222222200423333573466e1d400d2008233221222222233001009008375c6ae854014dd69aba135744a00a46666ae68cdc3a8022400c4664424444444660040120106eb8d5d0a8039bae357426ae89401c8cccd5cd19b875005480108cc8848888888cc018024020c030d5d0a8049bae357426ae8940248cccd5cd19b875006480088c848888888c01c020c034d5d09aab9e500b23333573466e1d401d2000232122222223005008300e357426aae7940308c98c804ccd5ce00a80b80880800780700680600589aab9d5004135573ca00626aae7940084d55cf280089baa0012323232323333573466e1d400520022333222122333001005004003375a6ae854010dd69aba15003375a6ae84d5d1280191999ab9a3370ea0049000119091180100198041aba135573ca00c464c6401866ae700380400280244d55cea80189aba25001135573ca00226ea80048c8c8cccd5cd19b875001480088c8488c00400cdd71aba135573ca00646666ae68cdc3a8012400046424460040066eb8d5d09aab9e500423263200933573801601a00e00c26aae7540044dd500089119191999ab9a3370ea00290021091100091999ab9a3370ea00490011190911180180218031aba135573ca00846666ae68cdc3a801a400042444004464c6401466ae7003003802001c0184d55cea80089baa0012323333573466e1d40052002200623333573466e1d40092000200623263200633573801001400800626aae74dd5000a4c244004244002921035054310012333333357480024a00c4a00c4a00c46a00e6eb400894018008480044488c0080049400848488c00800c4488004448c8c00400488cc00cc0080080041	2197
5	118	\\xd6eecaa6767bf706c33c273641121061deb1bbbed2419222bd89acfb	timelock	{"type": "sig", "keyHash": "4c16dd5207b7857e04a596d6e81b83ccb1eebcbf002ddae68fd771b1"}	\N	\N
6	120	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	timelock	{"type": "sig", "keyHash": "5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967"}	\N	\N
7	138	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}]}	\N	\N
8	145	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}, {"type": "sig", "keyHash": "3178bf14adf78294ac2d03d60b9edfb7323d3d719e98b4b0b3ca34cd"}]}	\N	\N
9	155	\\x298d92cd67868dfb49a18e775e44ad2cb7b4176b8a99ce38fbc294fd	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "e6ada13d5aeab71a016976fed4e98719626a09083fd2036a37006a2d"}, {"type": "sig", "keyHash": "bd4faf18a5c442f5436de682c0484f664118f8e0f1d7d25ae6e1421d"}, {"type": "sig", "keyHash": "606c75d9c88a97d82e4106f6effec13809eb06e8ae27ea42d17e0929"}]}	\N	\N
10	165	\\x063ce8b42742a856120554a8076e3a399ff55fad51c790d04f086f4d	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "b2a5344a52af95df7d58de427aa309629bd2e186c5d53777be9f8ebf"}, {"type": "sig", "keyHash": "5382960b0d03621badc2e4520192db66a3e9960b34762790fe4d1893"}, {"type": "sig", "keyHash": "ff492809d3ceabdef5ebe99b701db7a9f411783c3303f0b25322ae84"}]}	\N	\N
\.


--
-- Data for Name: slot_leader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slot_leader (id, hash, pool_hash_id, description) FROM stdin;
1	\\xc6dc872e263ad46c600af1bb710e3607de0e7ec8f184a8717e16e6f3	\N	Genesis slot leader
2	\\x5368656c6c65792047656e6573697320536c6f744c65616465722048	\N	Shelley Genesis slot leader
4	\\x1382638c2ebc3f978eb25a740b4d685d4434dad137294792c9a49290	2	Pool-1382638c2ebc3f97
3	\\x3c14be5ca907bb99d8e8ad6d584711887afee854184d0832bf6ead30	5	Pool-3c14be5ca907bb99
28	\\xe0bab0b4bb55862bed0fdbc9a729b359fda1d79d3a04e8101cdcebb1	11	Pool-e0bab0b4bb55862b
6	\\xa1c865cc9a6517b1fcdc32cc188261eb14963aaadf3ee8ba2155dff4	10	Pool-a1c865cc9a6517b1
10	\\x264e011a7bbd275c413f2ee6b6fa3b6bba403f1bfd6946f6bdbe3391	4	Pool-264e011a7bbd275c
5	\\x10e8eb0bbc8b01efcbbfb20df659c69d018e1e9ffcb7bdfded42b205	1	Pool-10e8eb0bbc8b01ef
15	\\x1fcda2a751c476ecdd45936d5115037f1617ca266cfdf9d4f85f5583	3	Pool-1fcda2a751c476ec
7	\\x5042dc1f20a769aa694f0cffe5ecff7fcf27c206c3212a622b3836a5	7	Pool-5042dc1f20a769aa
19	\\x8cd47bbc8a2ff2212fdca6f6b379c00bb94341c82164dd90a024e86c	9	Pool-8cd47bbc8a2ff221
23	\\x76687c8c1ac150006ca6b59dd7fb4244d627a1ae16ac0548acbe8442	8	Pool-76687c8c1ac15000
8	\\x438d202759456411e2430b8d2a2fc64e107ebf4bb9c6f97a3ca49b90	6	Pool-438d202759456411
\.


--
-- Data for Name: stake_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_address (id, hash_raw, view, script_hash) FROM stdin;
3	\\xe00503bff8014be7403e68d5073a742cca33a18b6f096988b13777de96	stake_test1uqzs80lcq997wsp7dr2swwn59n9r8gvtduyknz93xamaa9s6zgqcz	\N
5	\\xe00cf0a4ec53ce87dc47323dcd7289ad12049e16d73af7491a17c928e9	stake_test1uqx0pf8v208g0hz8xg7u6u5f45fqf8sk6ua0wjg6zlyj36g8rhu9s	\N
9	\\xe0332ab82768aa66bad423d8c3630c91f186ce91a70817573e378267d0	stake_test1uqej4wp8dz4xdwk5y0vvxccvj8ccdn535uypw4e7x7px05qtr0yxa	\N
4	\\xe0383a702fd6fcb61c15a2a5bad17c3280b0fabd0ef175057a8df36d29	stake_test1uqur5up06m7tv8q452jm45tux2qtp74apmch2pt63hek62gg0kl97	\N
10	\\xe05a0bda4f0baf5bd592391fae4b7e3036a6acb4fc1f2b9e267330d932	stake_test1updqhkj0pwh4h4vj8y06ujm7xqm2dt95ls0jh83xwvcdjvsrangzq	\N
2	\\xe0691520d3dbdd4cfa5c3748997c3fcb803469df6f84ddd39e7253ed03	stake_test1up532gxnm0w5e7juxayfjlplewqrg6wld7zdm5u7wff76qc4lha7m	\N
8	\\xe0691f93490725582988df51848388a8e2ad7519a177a519f644c9884e	stake_test1up53ly6fquj4s2vgmagcfqug4r326age59m62x0kgnycsnse0p5d9	\N
6	\\xe0817a33c82e58fb13fdbcb16fe6e0c7953303f096e135fc3bf7c73129	stake_test1uzqh5v7g9ev0kylahjcklehqc72nxqlsjmsntlpm7lrnz2g4p7z22	\N
7	\\xe09b55967ae6b45835c9e4f825521ba1ab8dc5c13498b1f7e6e45bf011	stake_test1uzd4t9n6u669sdwfunuz25sm5x4cm3wpxjvtralxu3dlqyg0srfv8	\N
1	\\xe0d8648d6595a3afbc6b7113c165f02c04e80f1c8d49361e094a124f96	stake_test1urvxfrt9jk36l0rtwyfuze0s9szwsrcu34ynv8sffgfyl9sppm9hn	\N
11	\\xe0ecc04e25eebbb383f01ed56c8893cd66f27d704e5d426b54879a5ecf	stake_test1urkvqn39a6am8qlsrm2kezyne4n0yltsfew5y665s7d9ancpzmawn	\N
12	\\xe09309506c3e5161904bfa283428dbbd61a21c81a34202ba1e09757a3f	stake_test1uzfsj5rv8egkryztlg5rg2xmh4s6y8yp5dpq9ws7p96h50c5cv2ts	\N
13	\\xe060d4eae1e116530ee9ee672ca01a8da653e6503c101d558c8423e27c	stake_test1upsdf6hpuyt9xrhfaenjegq63kn98ejs8sgp64vvss37ylqdv950c	\N
20	\\xe0a89261dbc2079f1ad1ce56ba3293f889767049da636b4786eb87e5be	stake_test1uz5fycwmcgre7xk3eett5v5nlzyhvuzfmf3kk3uxawr7t0sw45w88	\N
16	\\xe0748d4ba291a02a15df9f3aa7673d42d23b6f20b652576266c325a068	stake_test1up6g6jazjxsz59wlnua2weeagtfrkmeqkef9wcnxcvj6q6qdc375a	\N
21	\\xe0ff2e79cb347c65e2fa125cee2e09dd187fe1a5e78eedf0c2a51dd802	stake_test1urlju7wtx37xtch6zfwwutsfm5v8lcd9u78wmuxz55wasqs2zqtwt	\N
18	\\xe077c9d3224fe2176ed900ee45c34e8e9ffd40502cbe1ea3f7b2c49c69	stake_test1upmun5ezfl3pwmkeqrhyts6w360l6szs9jlpaglhktzfc6g55dg0n	\N
17	\\xe0c0d4ed2c40661465e43e029ac32577a48c9539e300c65caa9019467d	stake_test1urqdfmfvgpnpge0y8cpf4se9w7jge9feuvqvvh92jqv5vlg9pcyz0	\N
15	\\xe093935b3eade1589a3339bf51620cbf3d48b3057728d997cc418dd994	stake_test1uzfexke74hs43x3n8xl4zcsvhu753vc9wu5dn97vgxxan9q7w089z	\N
14	\\xe0c72fc5b5237489b69bf846ce112c0c8d7c503d7dfef13eb08a849352	stake_test1urrjl3d4yd6gnd5mlprvuyfvpjxhc5pa0hl0z04s32zfx5sk3yqzs	\N
19	\\xe02814bad02e3411146c5b0c7bb665528142d5bc9fd02e3a672c3ae37a	stake_test1uq5pfwks9c6pz9rvtvx8hdn922q594dunlgzuwn89sawx7sjs859y	\N
22	\\xe014773f7fe88eedef46e7cdc97f59cd234c6d3f8fb6eb1a63ec96fadd	stake_test1uq28w0mlaz8wmm6xulxujl6ee535cmfl37mwkxnrajt04hgnztxq9	\N
47	\\xe01bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	stake_test1uqdlrcfc7tuta27fv0y5es5wark5kst5gcql9md02zepalg9yxxuz	\N
49	\\xe09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j	\N
50	\\xe07d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	stake_test1up73dx2qeg7gv59739gpmycmxzffyqk3ha2ctmh9ghdgneqmy000q	\N
51	\\xe0e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	stake_test1ur3qm0k70hqp8wqknj2s04ndmhapk3w59a3d34j4s5zezgc9feq6f	\N
52	\\xf0298d92cd67868dfb49a18e775e44ad2cb7b4176b8a99ce38fbc294fd	stake_test17q5cmykdv7rgm76f5x88whjy45kt0dqhdw9fnn3cl0pfflgp0tfh8	\\x298d92cd67868dfb49a18e775e44ad2cb7b4176b8a99ce38fbc294fd
53	\\xe072263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	stake_test1upezv0agh8cq09rt33ardnh8pdstd3lwpa5s64g2pne0uqgcygw6k	\N
54	\\xe08de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	stake_test1uzx79ge8d7gkx27vu3k9xgj9zlra0fvat5d5lxcnzm9n7hc8yk6td	\N
55	\\xe04f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	stake_test1up85ec98csnkgus5dw3x8u25mlkgu8m63hvw650ukldv04q6rf54k	\N
56	\\xe00ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	stake_test1uq8lxxfr92332xgqp66eenhpw7z04q09czgjf6uvnku20fq023mfy	\N
57	\\xe0ce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	stake_test1ur89gkdpkj42jwy3smuznfxcjdas0jz64xtckt9s8kz8h3gj4h8zv	\N
63	\\xf0063ce8b42742a856120554a8076e3a399ff55fad51c790d04f086f4d	stake_test17qrre695yap2s4sjq422spmw8guela2l44gu0yxsfuyx7nga44pd8	\\x063ce8b42742a856120554a8076e3a399ff55fad51c790d04f086f4d
46	\\xe0f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	stake_test1urc4mvzl2cp4gedl3yq2px7659krmzuzgnl2dpjjgsydmqqxgamj7	\N
67	\\xe0f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	stake_test1urcqjef42euycw37mup524mf4j5wqlwylwwm9wzjp4v42ksjgsgcy	\N
48	\\xe0e0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	\N
45	\\xe0a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	\N
\.


--
-- Data for Name: stake_deregistration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_deregistration (id, addr_id, cert_index, epoch_no, tx_id, redeemer_id) FROM stdin;
1	63	0	3	166	\N
2	46	0	3	168	\N
3	48	0	11	376	\N
\.


--
-- Data for Name: stake_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_registration (id, addr_id, cert_index, epoch_no, tx_id) FROM stdin;
1	3	0	0	34
2	5	2	0	34
3	9	4	0	34
4	4	6	0	34
5	10	8	0	34
6	2	10	0	34
7	8	12	0	34
8	6	14	0	34
9	7	16	0	34
10	1	18	0	34
11	11	20	0	34
12	12	0	0	46
13	13	0	0	47
14	20	0	0	48
15	16	0	0	49
16	21	0	0	50
17	18	0	0	51
18	17	0	0	52
19	15	0	0	53
20	14	0	0	54
21	19	0	0	55
22	22	0	0	56
23	53	0	3	161
24	54	2	3	161
25	55	4	3	161
26	56	6	3	161
27	57	8	3	161
28	63	0	3	165
29	46	0	3	167
30	46	0	3	169
31	67	0	7	271
32	48	0	11	374
33	45	0	11	378
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
1	\\x10d9c18d1a12c225a63638e28bd9bff09100f6f5fad5f13d9c1413463f66ef67	1	0	910909092	0	0	0	\N	\N	t	0
2	\\x0c3c62948c5c52e30867f9290869e1fb08050117f981714ec7633d183f0d3f15	1	0	910909092	0	0	0	\N	\N	t	0
3	\\x1fe243f20cf24f937f4b1031355ab56288dad145de8e54cdd4668542daa4d505	1	0	910909092	0	0	0	\N	\N	t	0
4	\\x602bab8678b352e2b898290cd7a20f799bd1502c18391baafad9747f6e8b1229	1	0	910909092	0	0	0	\N	\N	t	0
5	\\xd057d7b45c1ee993bb50ca713ba80b5e904eb4653bcdc75fbe7b5470c5c07769	1	0	910909092	0	0	0	\N	\N	t	0
6	\\x110409ba390686b1917eda44bd8e925e06e4ff505a2167787095a5fa94a80f92	1	0	910909092	0	0	0	\N	\N	t	0
7	\\xa1e357ca29fe68facce72d3ecb1521e878725aae462dbe28aaf14f525db5d5bf	1	0	910909092	0	0	0	\N	\N	t	0
8	\\x111a8c35b91db161d5087ef72ea524b8025253a02a274d97e737e83c7f3483f1	1	0	910909092	0	0	0	\N	\N	t	0
9	\\x5cd2d01b09dbe492bfc0167b0aeee9a3b66f0d3bd092928d2a6efada17171ad2	1	0	910909092	0	0	0	\N	\N	t	0
10	\\xba59985c86fd2ead8eb0c39788b4815aa6975aa47d4f3dced1760f2ddf03fb45	1	0	910909092	0	0	0	\N	\N	t	0
11	\\x80bc34f1164a9b3f6da87923e6e64f94bb7281a6e2ec38e4007ef5fd8a743c31	1	0	910909092	0	0	0	\N	\N	t	0
12	\\x20d6080126ef7d731329d90694ddaae85def18cf06f6967e4fdde6040b812dec	2	0	3681818181818181	0	0	0	\N	\N	t	0
13	\\x2547badbd19fd5ae250d991dea0815c655891cf8fb4380f2ad9631aa1ab879c3	2	0	3681818181818181	0	0	0	\N	\N	t	0
14	\\x270562c00b76e885d0c357a2b5ea38369ceaf478be816e2bb8af21aa51133ec3	2	0	3681818181818181	0	0	0	\N	\N	t	0
15	\\x35f658dc4087956c09827bc0dd0941f42e4b78c68e5a32ffe8f02c230a20d699	2	0	3681818181818181	0	0	0	\N	\N	t	0
16	\\x38863a674f3eeb4a8ff5d16771d55cc161d95b22f70f73cdebe4b872b07c52ad	2	0	3681818181818190	0	0	0	\N	\N	t	0
17	\\x47caad298e1b7fe9ff8c9c79e9b58186395d0a75e176666cd3102aed13785ce1	2	0	3681818181818181	0	0	0	\N	\N	t	0
18	\\x660f7d1bc96f5004e08bee47e75395ff54272bf562b93b8e009df8887d32e4bd	2	0	3681818181818181	0	0	0	\N	\N	t	0
19	\\x6ecb47974b7734427a7002c49ae73cae04a0af53932f7ac7e6b84b2b58a053ca	2	0	3681818181818181	0	0	0	\N	\N	t	0
20	\\x77e0186de7e910bc5fe93c558b383d19ff68e27a13475bf52f79f9b4db300698	2	0	3681818181818181	0	0	0	\N	\N	t	0
21	\\x7c18862005462fa8d56ab4357b7ab152e1b0fb98e66dbbf640622f988fc6266c	2	0	3681818181818181	0	0	0	\N	\N	t	0
22	\\x92c26b1643ac4e26279206e24a2e37fcdca5be716bd5d144fd6ae250ea153460	2	0	3681818181818181	0	0	0	\N	\N	t	0
23	\\x941e3ab5568daedbd48dfdbf6ef159f2547608e5ef2d49fee24a74c5e90763e6	2	0	3681818181818181	0	0	0	\N	\N	t	0
24	\\x9462ea11b80be2c0c0d081e57ee79b3b0441e7ee4deabbcab4aa97cf13d3a77b	2	0	3681818181818181	0	0	0	\N	\N	t	0
25	\\xa5c43c0805d97ff9148ed7982350ec53bae9d391862271950be66e72af283f4a	2	0	3681818181818181	0	0	0	\N	\N	t	0
26	\\xb22dbcb87d8fb6ecd25906a7c84929d1c6172fb52cf4816b012bf607af951c26	2	0	3681818181818181	0	0	0	\N	\N	t	0
27	\\xb4619d0ecdb51ed4e9b2a3c459d154e11133f73d8fcefc6f09446332f4482a2f	2	0	3681818181818181	0	0	0	\N	\N	t	0
28	\\xb617be7744ff05c76a09da401f3d669ab8c383b17684f9a1d19502eab7a7be56	2	0	3681818181818190	0	0	0	\N	\N	t	0
29	\\xb6506992d8e86fba0641b8abda959eefc160c5655823a4f76c1e3f31a903bb20	2	0	3681818181818181	0	0	0	\N	\N	t	0
30	\\xc2f99e995e4e5338dfae6909cb5f68752380aebb399e83f2b6b362498fdb186e	2	0	3681818181818181	0	0	0	\N	\N	t	0
31	\\xd35cff0b51712686564626ba39591e293a4a5068862e275775a15c61c4bda833	2	0	3681818181818181	0	0	0	\N	\N	t	0
32	\\xd35e31fdfd1a3c4309c510f0db7e33dc077f2e0bb423e7c4c347e1755df85e72	2	0	3681818181818181	0	0	0	\N	\N	t	0
33	\\xfe650831b10073a02598bc784d28111bf9dd603734014618107a2440531241e2	2	0	3681818181818181	0	0	0	\N	\N	t	0
34	\\x5368656c6c65792047656e65736973205374616b696e67205478204861736820	2	0	0	0	0	0	\N	\N	t	0
35	\\xfca835f0f1fcb15d7bc023aabb12400ab9a15764d3281cc5c7c09feb5542c145	3	0	3681818181651228	166953	0	263	\N	\N	t	0
36	\\x2e7275fd1b468f20a4699c65686d38ca625d1c86ebccdd98706aa156a3a53ca9	3	1	3681818181651237	166953	0	263	\N	\N	t	0
37	\\xb9b5f0a86f77aeb3d1339d010d82760cdda56a26cea3c29ef9084d2cf04822a0	3	2	3681818181651228	166953	0	263	\N	\N	t	0
38	\\x11e23bd6b98d967e90830f745ea7c1820b091758da89e58b1c9129d1f4a3046b	3	3	3681818181651228	166953	0	263	\N	\N	t	0
39	\\xab18fe85f883876e4a1411bc4cf8e2298b693de77467b5eddae05b1cac7d14d0	3	4	3681818181651228	166953	0	263	\N	\N	t	0
40	\\xfab23761b60ed5b17b211695411640747d41dfba2918e57e26d6cc808b477390	3	5	3681818181651228	166953	0	263	\N	\N	t	0
41	\\x13ea849c135137a482e386dd4280cbf2094e7654415e0ac0dcc61bca8cbdd30e	3	6	3681818181651228	166953	0	263	\N	\N	t	0
42	\\x98a82f02f1e1cc0b4f8d9af439ee44b7a459ca29d2525486913f154e4ffa217d	3	7	3681818181651228	166953	0	263	\N	\N	t	0
43	\\x408373f55b8e5f0ccacdba0a21647b5ecd5b45bbe5583caf3ad0144ca4b1921f	3	8	3681818181651228	166953	0	263	\N	\N	t	0
44	\\x3dab42ef840122d31f65f02d4f4915491d0d4088b4c5e775030c8c84ecc4747f	3	9	3681818181651228	166953	0	263	\N	\N	t	0
45	\\xfb89037f5c633072129ab7baca4731336038610f8361567bbde0573f8d265c2b	3	10	3681818181651228	166953	0	263	\N	\N	t	0
46	\\x3c7edbd8ba542d3577ebdebe50c5848c409bff16d2e4e1fd38b609416cab7558	5	0	3681817579473240	177997	2000000	339	\N	5000000	t	0
47	\\xdb3ce86260e1340def6c56fc5adb8e2fa188b5bd871e846ffa3e286678783a81	5	1	3681817879473231	177997	2000000	339	\N	5000000	t	0
48	\\x30092b2c7c0fa31ec31ff505ed735b2c3dc4f13fd70b4212ac7bb27a6714589e	5	2	3681817879473231	177997	2000000	339	\N	5000000	t	0
49	\\x49fd6f7430313aaa9932a32c9f626320d093214e2f6c5aff7d1327c7a8cebc52	5	3	3681817679473231	177997	2000000	339	\N	5000000	t	0
50	\\xced6211621a12eabdcc21c0c00cac38368195a9fb0e75c2ca6665e91f24f31e9	5	4	3681817679473231	177997	2000000	339	\N	5000000	t	0
51	\\x6ee4c9a3eb4559b2bdd80bb9b2068595d25b005fda893b93fc77021c68d8ba01	5	5	3681817679473231	177997	2000000	339	\N	5000000	t	0
52	\\x71a2b3aa720301514b321c189f67afbf072002af1ac5b20797189379e1193a5c	5	6	3681817679473231	177997	2000000	339	\N	5000000	t	0
53	\\x24ec7b9cec395321fafa8b270843b1217902b16da3939f138aa3ea5e6c75519c	5	7	3681817679473231	177997	2000000	339	\N	5000000	t	0
54	\\x0a18098d379fdb3105095f8bde379ce0fd67367709c0bb10d4764cc815bd71ba	5	8	3681817679473231	177997	2000000	339	\N	5000000	t	0
55	\\x5cab8e26f9dee8793955057c6679f84b220935c84c21ddb7987062b713b832e2	5	9	3681817679473231	177997	2000000	339	\N	5000000	t	0
56	\\xb40821c7bffb11969922d542c45b1920375b8498df1742d0eaf32ce0bb4e6d04	5	10	3681817979473231	177997	2000000	339	\N	5000000	t	0
57	\\x3ac9eae7c85c8e09cce5d6405177f6c09aa6e18853d8b3e3d3130ef737f84263	8	0	3681817579293923	179317	0	369	\N	5000000	t	0
58	\\x0af786515e90ec543bb288782578dd65c0b76164f9ea69dfde1961b49582c006	8	1	3681817879293914	179317	0	369	\N	5000000	t	0
59	\\xfac14392aa6a8994aa3118bf888edad4575c1ca661ab0cbb2ab427a9b08616d7	8	2	3681817879293914	179317	0	369	\N	5000000	t	0
60	\\x6b99660b7346516a7838733de78593093ecf0e545d5e8a54bd60381a6ecab5c6	8	3	3681817679293914	179317	0	369	\N	5000000	t	0
61	\\xdff7bda487184b481f19db55481cde9607c1a12a5a2d672285374b02687bb223	8	4	3681817679293914	179317	0	369	\N	5000000	t	0
62	\\x69e4c2ffe575d77a3cdaf1477968f1da3af17dc0f2c8118d04102aec4af0dd9a	8	5	3681817679293914	179317	0	369	\N	5000000	t	0
63	\\x76f1760ebdc4d5623bd390a9a1148f0c7b5fd04b98bec2913df2d6d1c9c9b4ec	8	6	3681817979293914	179317	0	369	\N	5000000	t	0
64	\\x34a5af258652afc16d2d33ff59e295196b4afc207e83a469e3a7c4adb989ee41	8	7	3681817679293914	179317	0	369	\N	5000000	t	0
65	\\xc09e757ce4860d1ae5042baa8f4faa92cdf5a4bdf77274a36c56d5b443048c4b	8	8	3681817679293914	179317	0	369	\N	5000000	t	0
66	\\x5f0b9d9d124dc3fd738fa8f74d17e33d0189d81cea5f5dcbbb67b8bd0f2695b7	8	9	3681817679293914	179317	0	369	\N	5000000	t	0
67	\\x36371383487db7f058a7a0b75f3a051ce23fb526a4aa4c0ae3f2fb5f9e0efe86	8	10	3681817679293914	179317	0	369	\N	5000000	t	0
79	\\x4c6a05b69a4b39b67191bdc0b0f661c41760f21c57908d98e1fee40530f32df5	12	0	3681818181637632	180549	0	397	\N	5000000	t	0
80	\\x89094f830a0bfbf4ee7af63e701d2110bb2bc5a4201d6f2ee26e4a48dc64d749	12	1	3681818181637632	180549	0	397	\N	5000000	t	0
81	\\xf89d2ade71aa0f015dd5382fc6b4e46e63caf4c9c78d6fd1f995ec1703045c09	12	2	3681818181637632	180549	0	397	\N	5000000	t	0
82	\\x3e70ceb6228e5fdd32206d8faa7d2b8b8738e2bebfee2610b074c4d500a097b5	12	3	3681818181637632	180549	0	397	\N	5000000	t	0
83	\\x0dd6487a927b0a6e54e42d34c467e7d8477c64bc1b1aee16f18ac7f8ba10a74e	12	4	3681818181637632	180549	0	397	\N	5000000	t	0
84	\\xc3dce9b4485f4475b1dd849626da4849dc8278cad71509e243fd6b01754fa9f0	12	5	3681818181637632	180549	0	397	\N	5000000	t	0
85	\\x8adcc84e185b2d65293b45153ac8646cb400d19ad461379003f2d7e602f7cfc5	12	6	3681818181637632	180549	0	397	\N	5000000	t	0
86	\\x8bb31a85b4916d4f6087bc98541e26282e1dbe430157cd89255a3641d0649ed0	12	7	3681818181637632	180549	0	397	\N	5000000	t	0
87	\\xf36bff1297d50d93d13c7505fede19dc42007344a4d47314165bd0225bcc4121	12	8	3681818181637641	180549	0	397	\N	5000000	t	0
88	\\xa2f423d047c2ed10131c21f1fea281fc5239f618a9e5c8f8d153134b244ca2d4	12	9	3681818181637632	180549	0	397	\N	5000000	t	0
89	\\xd9e3ac9872761394e43ef7f497f1024b6f3b0e0eef8476d4b46e02b7e2566f74	12	10	3681818181637632	180549	0	397	\N	5000000	t	0
90	\\x855155a6eefa32d4f40e2816216eadc5e16d4b51b9469b0865bc7d8ffde60c67	13	0	3681818181446391	191241	0	590	\N	500000	t	0
91	\\x7895bc95b3d1d705a01fc479cc0b0466cc0291d114ea28267279df63abcfab5b	13	1	3681818181446391	191241	0	590	\N	500000	t	0
92	\\x70af557e75057282be79adf3cacccb6b8ce6a0a4e6b2670943a9d9e63d63ca35	13	2	3681818181446391	191241	0	590	\N	500000	t	0
93	\\xebcb6d0af8b5323562b4e1e947c07264129a1aacf8eb4d9ac1be3e304993511d	13	3	3681818181443575	194057	0	654	\N	500000	t	0
94	\\x9acf8f2ffb9b6fdd26128fd926594886eff3329346163b895b75998e342fdc2a	13	4	3681818181443619	194013	0	653	\N	500000	t	0
95	\\xcb5f3c6a09b4e530c84da66656c5fd592bdbc86ae4fd029366e251030fc953a5	13	5	3681818181443619	194013	0	653	\N	500000	t	0
96	\\x37b1cbd8ceec6eaec41138a5e74bcdfd25c15ff6ba7333263d80f3755b3c6d77	13	6	3681818181443619	194013	0	653	\N	500000	t	0
97	\\x1dc8fb8e3f3e56b7bf04206b64fda5153d438108ee9f714aaa22169ae59dadad	13	7	3681818181443619	194013	0	653	\N	500000	t	0
98	\\x59f04d91df6f71ce72e6e6a5f022b882b29c154d81fd09a6321ff3a2376cd765	13	8	3681818181443619	194013	0	653	\N	500000	t	0
99	\\x1834b39c684bdd4fcaa79ae4691bc32994b136b8a9e1cb6f35a3c4ccb9663acf	13	9	3681818181443619	194013	0	653	\N	500000	t	0
100	\\x824bbd503ac45e34ee130ae92072ee677ff9b71e5459974688338b37d2dfb193	13	10	3681818181443584	194057	0	654	\N	500000	t	0
101	\\xf3809fb364f13d717f7e9fc75b30e460b862f93544775b0db1f984a70518faf1	16	0	3681818181265842	180549	0	397	\N	5000000	t	0
102	\\xbad2237139a26c08b05d22dc26584f1a2e3707fdc982146168a071ef87df953a	16	1	3681818181265842	180549	0	397	\N	5000000	t	0
103	\\x7bf156f95b86c9a7b4fb6fe32033e2cfdc68ef87c1f473ea56f42c130171e5a8	16	2	3681818181263026	180549	0	397	\N	5000000	t	0
104	\\x851b673c83739a61ee77296a4a6143efac02be0d354305e6083790e1b792010a	16	3	3681818181263035	180549	0	397	\N	5000000	t	0
105	\\x4d26ed61bd07fbf1c17ff3991e106735d22a9ac435c0d2aa811d47451c496822	17	0	3681817879109669	184245	0	439	\N	500000	t	0
106	\\xa849c7f0aa468e9855d9fc27f30273a91355c966e3c27f1dd5272c1e8406a8c6	17	1	3681817879109669	184245	0	439	\N	500000	t	0
107	\\x22b5f731fa65507173d20112027d05896118ea26ef39bcb5597c98f93289acbd	17	2	3681817679109669	184245	0	439	\N	500000	t	0
108	\\x724eb692e9d99ccd5a30106ad4765360a9e2d425bb40ae05dc1fe2bbb0b23e8f	17	3	3681817679109669	184245	0	439	\N	500000	t	0
109	\\x976dcfeb4dd18d810efd4610dd97ed6c61b8c07c40863f8537f447baf91ac1eb	19	0	3681817579126574	167349	0	272	\N	\N	t	0
110	\\x60aa382d5216c4893d4ab47dc207f9eae8520ae8da86bc00045e3eade368f921	20	0	99828910	171090	0	350	\N	\N	t	14
111	\\x93fcddb535abf408c3425bacc99a335a1aeaa28ebd448031d35cfab833b038e3	23	0	3681817478960501	166073	0	243	\N	\N	t	0
112	\\x9ee63bd0d993eff7e3ecd48e242846fe3c8827e4bddd873f9a6e154f8a6c8a5e	24	0	3681817378790116	170385	0	341	\N	\N	t	0
113	\\xe75dd50286954c2c529e38d3fcb657e3bbb88762e90c935d4c4036f71c2727be	25	0	3681817278622327	167789	0	282	\N	\N	t	0
114	\\xcbd001b006082f64f861b1a02d1159ab10a51650ab6ff56428d66d0e5a5b204f	26	0	3681817178455682	166645	0	256	\N	\N	t	0
115	\\x34e7875eb8ee15d92df8bdf4a6111f5bd3a4ecebc8139aed8edd921d63b8081e	27	0	3681817078192809	262873	0	2443	\N	\N	t	0
116	\\xb944bc245862ec646a42f06f33a4a314e4617b5696a18a754c7dbb06845652d7	30	0	3681816978026692	166117	0	244	\N	\N	t	0
117	\\x32fb130407720a2ac06a3df9e8436da3e883932147c12085967c33266c577664	32	0	3681816977699345	327347	0	2613	\N	\N	t	2197
118	\\x6ba4a58be07c6920588dbaf5e7e93cf693ffdbd4b624dd21a3c83e3c8ea1ab01	34	0	3681817679117985	175929	0	467	\N	\N	t	0
119	\\xf3e2b6ade6b05ff983caab04a92bd737430547ebb30d8f4f893f503805b3be4f	37	0	3681817979114289	179625	0	551	\N	\N	t	0
120	\\x6f6be432faf550fc3b505630ff665102b166320fbbcf6483d345367a06040492	39	0	4999999767575	232425	0	1751	\N	\N	t	0
121	\\xc48f61a8b0f48716a81c936a7bf372a03c8f9d6dbb18f0f57b631bbef5c88ab6	40	0	4999989582758	184817	0	669	\N	\N	t	0
122	\\x437830e7d042ca18cdc93677f8bbd4d806a96064ab053d95523cf6ba53691d08	115	0	4999979347913	234845	0	1700	\N	2449	t	0
123	\\x39de500cf72feb03c93fe0dcbedbd30e021e294a2d843141c0357d8bd823f3e0	120	0	4999979121208	226705	0	1515	\N	2476	t	0
124	\\x093c654cede6a05609616dfd50df6b68005fc44884aa75fc43754184cefda8a5	124	0	4999968895251	225957	0	1498	\N	2525	t	0
125	\\xfa54278091e128d8d3893079b4677ebf828e516da22bb50a695c5bc3f0bdf307	128	0	9808319	191681	0	719	\N	2551	t	0
126	\\x3037206ea2396e750125fe210b65539cafc2b87d05e5cf8a53626a288e916928	132	0	4999958722402	172849	0	392	\N	2574	t	0
127	\\xc28be6231f81f491180ee858af086f65a1027e1112a2ff8cc9cd783c74e1c4d0	137	0	4999938551401	171001	0	350	\N	2597	t	0
128	\\xce5d641aa080542a07e9d188aa1618f6b8e48f7a7372a6457578e4751a3c2555	141	0	4999938180491	179229	0	436	\N	2653	t	0
129	\\x987404276ff3ed76f1bda629a8062f3e13e028a48841ea5783f1d92335ba0543	145	0	19826843	173157	0	399	\N	2690	t	0
130	\\xba50e457935ae0104e4709cb814062ecee534230c548a20a2666c65d9a8ea3f9	149	0	4999937987666	192825	0	745	\N	2711	t	0
131	\\x12a4d8c3f7df2ae8d406b693646af87915d38bd995e5c09c7917c6484440754a	153	0	4999927794841	192825	0	745	\N	2747	t	0
132	\\x52bcf744c1ee73387b50b4721af394cf1a2deb2af29a34f80342d47368ab2966	157	0	19825259	174741	0	334	\N	2776	t	0
133	\\x835bd6b6861b109a08adc72cde339c39bc9c3fc012a93c9cd96c3f7e35b167f2	161	0	19632610	192649	0	741	\N	2809	t	0
134	\\xea16de4e7aaae4fd23ce72674ab65376fab06f3df6fa920973ccf53a0e88783b	165	0	9826843	173157	0	298	\N	2835	t	0
135	\\x7bec182f380de681147b6812bfc2dee0f2ba525306299eee5607f52a1504022e	169	0	19265220	194233	0	777	\N	2930	t	0
136	\\xc8db4842b7a6548d46d019883eaf824bc5e5504111753b2a4d43e16c5584d8a9	173	0	9824995	175005	0	340	\N	2964	t	0
137	\\x65313390617f0caca2d753c3af3c7977d588a4f35c48ca7db135155832bf812b	177	0	9651838	173157	0	298	\N	3014	t	0
138	\\x8044044fcfbff6c98d2c3fc66426083f298dc10230c6d07fccc0ab596715cb16	182	0	18711649	205409	0	1132	\N	3104	t	0
139	\\xd06959fa9e42d10dee6436d883aca68338d7fb023ae26d2fc6a6ee6308bd8e95	186	0	4999927614600	180241	0	560	\N	3146	t	0
140	\\x9a5003ee980c21a7368c9fa3eba9a54de8e622e626df327e06ae0e04c7626feb	190	0	18523048	188601	0	750	\N	3185	t	0
142	\\x984113a3255de376b17d52d4a3b31f2763c04742866275c9ee709960ae7446b5	195	0	18332775	190273	0	788	\N	3202	t	0
143	\\x7e41ac2e0df25158d947341ee058c55ed450a48dcb40c549348b28d4f15a10a9	200	0	4999925758158	189217	0	764	\N	3227	t	0
144	\\xf0ff3afa69e0001ce5281dd1c823956ea5b09d212b5ba8a598781b72760df1f2	204	0	4999935578929	179229	0	537	\N	3246	t	0
145	\\x349274e323968d535066d99eb31bda58d855145e377f8ff43ae8f553a3b11296	209	0	4999935395080	183849	0	642	\N	3290	t	0
146	\\x34e565ebc8ff12649f6797b2d8549156c10f73abd43716d5cbd1a4f84bace44b	213	0	2820947	179053	0	533	\N	3327	t	0
147	\\x46a98a88fb1ab94518066164dfbe62e060247d1813102f64cce3d057eacc5d43	217	0	4999932217523	177557	0	499	\N	3396	t	0
148	\\xa26ea926b23de7bb9b0cbc19a896d0355bd6cbb701958c922081b65853f7899f	221	0	2827019	172981	0	395	\N	3465	t	0
149	\\xbc0a940589e28ee1db021ef0ce2a2e14115dc7af69f80111c8a3bc8bc4fd1f99	225	0	4999934693740	171749	0	367	\N	3498	t	0
150	\\x1ac20a6c1457b721b53816036a06b590a47afd360cc6dcb36921a06ac0e5be67	225	1	4999934523575	170165	0	331	\N	3498	t	0
151	\\x8c2d0f7ad7e5535984941890a88cb6c86dd479dd2e63c3f6eb7ff5443a020ffb	231	0	2999960751284	168009	0	282	\N	3551	t	0
152	\\x1c6627fff0ef23dd4ec66a51aaa47984c58016bfd8c96ea1af4a50b4133c3d63	233	0	2999957234971	516313	0	8198	\N	3562	t	0
153	\\x996f100aa11d6a5dd8cd9e99665340947a198c4b1b577ce7e7ffdf194c8fac14	236	0	179474447	525553	0	8408	\N	3569	t	0
154	\\x68c56e2f422875447503e59c329eaff1df34a04c1f8b70ee9d59aacbaea31a93	237	0	49853119352	168449	0	292	\N	3579	t	0
155	\\x41ff721ea7f2ba3e0d4e4c2ceeec6de8dbc8d2746d0974dce119eaf6c3f21fbc	238	0	9818439	181561	0	590	\N	3587	t	0
156	\\x07e4ccf6f540e3ad1a7ef37adb7e2eb1c47add7639769bf522fe81a3c7708bd6	240	0	49853119352	168449	0	292	\N	3591	t	0
157	\\x987292c3f225ddd9c6ea7a9473459a130f994f34c74f67db35c1235f2ccafdc2	241	0	0	5000000	0	2365	\N	\N	f	1893
158	\\x92462c9ad6657f1e94a8af1cd7863b1a5f1fa0ec05cebf751f924746380f4563	245	0	49853117504	170297	0	334	\N	3641	t	0
159	\\xb4398e467109d3003fb623fd74e2221d9378ee5c71113eebe81d17475ad4120f	249	0	49853119352	168449	0	292	\N	3655	t	0
160	\\xc0453b53961eae5f48e575f614f9cb1fa24ae5a0bf4bf14484443395931ecc54	348	0	49853119352	168449	0	292	\N	4548	t	0
161	\\x7e8c95109e936fae799b201c9e32e3b877b9ad5aa0e0e85eab716288cf2a3526	353	0	989675351	324649	10000000	3846	\N	4574	t	0
162	\\xa04432a35d67cca5351c600c11266e5a615ea94fd554517e2c928e520674769e	357	0	989414590	260761	0	2394	\N	4611	t	0
163	\\x5662c5bdb50079f833b3074d09103b7b9bfcd70b2c8b2a3ecd5b7e553ec8ce34	364	0	494375158	201757	0	1049	\N	4697	t	0
164	\\x3ae77e468074f6d8b5f74fab41f7d2a2c04cf44025ed7211d3299770d49c4726	368	0	49853119352	168449	0	292	\N	4733	t	0
165	\\x6f62ab366305356bdd23e86afd79dae8d696a20e5e2e835e7470e6fda2bf98c1	369	0	7814039	185961	2000000	690	\N	4751	t	0
166	\\x27f62821aa32f23672b9b78a6ea339cc08f45be48f4be2fbd2e10b1492fff321	370	0	8633754	180285	-2000000	561	\N	4752	t	0
167	\\xea752952a7b0167432fba563609f300d3d600d8bd5c7b69101ebf7a42b39dc66	372	0	49851105404	182397	2000000	609	\N	4790	t	0
168	\\x7bd10adcf3a8dc3fd11294efb36e18b3e4860b5c7024338e4cadf6dac549983c	373	0	1999975432709	171573	-2000000	363	\N	4800	t	0
169	\\x85747ca0c14589e78e2a216e36e0abfd1bb122f6b2be0572849501cd1389dd94	378	0	49851107384	180417	2000000	564	\N	4837	t	0
170	\\x40e21cae2df1ff3f1f2ef5783c9ac382c25a1922eeb01c287d7d4644f9992cf2	557	0	49842950947	168405	0	291	\N	6444	t	0
171	\\x6c203ae01875ef5beeb19fa10369233d73d24371190cfc7b1699feb65eb3baba	557	1	49853119352	168449	0	292	\N	6444	t	0
172	\\xb1c33a28323bf782a54f0bcda321c13f6fd9a04f840a6c0dcba43196a085251d	557	2	49853119352	168449	0	292	\N	6444	t	0
173	\\x529b32ec50aa99d06272ab63cdaf40d31322ca40f22dde7844b725d33225f86a	557	3	49853119352	168449	0	292	\N	6444	t	0
174	\\xb9c7db87b294e87e351797c8879179b44d0b366ff52eb431399d665841d7a5bc	557	4	49853119352	168449	0	292	\N	6444	t	0
175	\\x285dd0c06d869f952919782e7bdc0cb5c01413bc9ec00531a950e2f6c38e203e	557	5	49853119352	168449	0	292	\N	6444	t	0
176	\\x3aca6445f051b941821a2299073eab43c498162bd38bec29ac2e274f9a1bf982	557	6	178331771	168229	0	287	\N	6444	t	0
177	\\xa275d6dea332b800ac3b06c16def5f206ccec0cebdcd343ca1e5277421e70ce0	557	7	49847950947	168405	0	291	\N	6444	t	0
178	\\x0443b19fcd9fddd0aa7e0d0a3b56f6ac663f748620fc9fb1d5171e18dff506ff	557	8	49853119352	168449	0	292	\N	6444	t	0
179	\\xcf5ad88de77ccf12d6a95d26481309942f503f784f3a0af06d74dfad9fef759c	557	9	49853119352	168449	0	292	\N	6444	t	0
180	\\x3e4e0e579344e4e3762a048e344033aa2db23d056a75e22b6df85a21979a0672	557	10	49853119352	168449	0	292	\N	6444	t	0
181	\\x11bad3484b6b19cf4495be284d3cd85a6a32db02c103303bf90de0f3f11de6f7	557	11	49853119352	168449	0	292	\N	6444	t	0
182	\\x3b568835b8d83f5cf6222dbc8f1db61f6bf05975c55a7d8e2ebbfb764936f088	557	12	9831771	168229	0	287	\N	6444	t	0
183	\\x202c65b9a1b12eeaef4fff18f053c3a90cdfeccf7ff73523c9ec0d0c0ecab289	557	13	49853119352	168449	0	292	\N	6444	t	0
184	\\x94d8c9a829e6b51ecb8513f9b7b40ee51132d2aba9c1302632d5609848783c69	557	14	49858117768	170033	0	328	\N	6444	t	0
185	\\x4b0fee779b46839d89cf9a5e695d29a387f6a351d7b6298a599b54fdeada36a2	557	15	49853119352	168449	0	292	\N	6444	t	0
186	\\x561c64addd307fc63264e4d4a6469c5e76015eb9f1109116f5c5af587d08f36e	557	16	49853119352	168449	0	292	\N	6444	t	0
187	\\xcf9a306f6bcd108f895d0bea9342d4c4316720142380ea41897695d55165d7af	557	17	49853119352	168449	0	292	\N	6444	t	0
188	\\xfd5b9a6b3949866da169221b83abb72ec7ced5e68af54bc3c33837762e45026a	557	18	49853119352	168449	0	292	\N	6444	t	0
189	\\x7e29804c32f90b2fc0a9cefc7d2b0510a41fe6f0ce205e2c8cb83c050483a209	557	19	49853119352	168449	0	292	\N	6444	t	0
190	\\x49c56c60597c907842a5980c084d4eb7c76f1f18bbbe9b6a9ebbaaaf2723b6cd	557	20	49853119352	168449	0	292	\N	6444	t	0
191	\\x5d654133cee3858d893f439a6dfcf786a14804a421ff6d4e3ff947c7bd8f091c	557	21	49850938979	168405	0	291	\N	6444	t	0
192	\\xc00f4a2618f544bedcf5df9d2148a91706b4507cfdb3958a1ce973c4cd03549e	557	22	58433086263	168449	0	292	\N	6444	t	0
193	\\x5275947e6d4750bb56d5043d6455c2d8720c045a2460987ed77e8d12f1f6b3c5	557	23	49853119352	168449	0	292	\N	6444	t	0
194	\\x3ecc35728dc1b927623d392360867d995a34ed610ccedb3c11de68900bef5054	557	24	49853119352	168449	0	292	\N	6444	t	0
195	\\x895c62f456df6b695550d7be6e60a65dfd1439d5ccb7d826d6382eed0d4b68a6	557	25	49853119352	168449	0	292	\N	6444	t	0
196	\\x500c9fca6cb931b09165f4dd7beb90449aa07e6c90012d10408c666353394ce8	557	26	49852949363	169989	0	327	\N	6444	t	0
197	\\xedc4c0ba070d2b3850d88708372803c115b93158d40189ebe93c16ab8e0ae662	557	27	49847950947	168405	0	291	\N	6444	t	0
198	\\x0cef2e4faf390466086af519060060b872840241bb0d4490030c7ba1dfd716fc	557	28	49847950947	168405	0	291	\N	6444	t	0
199	\\xefa9d12aa394d851b3e5a3e57fee7fd08900ddd9081f4383dec3343160001b3b	557	29	49848779374	171573	0	363	\N	6444	t	0
200	\\x7c98e134d03dff30c3dd6789dd88db90946b626458d0bc47d33eda37002c1823	557	30	9830187	169813	0	323	\N	6444	t	0
201	\\x4289e2d3b02d4ed123bf13927bbb25b4967869c165cc9a9c3f9184bda3448216	557	31	49853119352	168449	0	292	\N	6444	t	0
202	\\xc3ab15ca911e1bc688fd9b467406f1afa78c6025e046f8444dddcf690163e137	557	32	49847950947	168405	0	291	\N	6444	t	0
203	\\x61158201d6bc1e819db9043c694f5740dae5978c4fa0b50d5470efe330570824	557	33	49847780958	169989	0	327	\N	6444	t	0
204	\\xfadfb923f8ab8065c6bc3f12216efe77b894f16662ba6927624c27bf1875f753	557	34	49858117768	170033	0	328	\N	6444	t	0
205	\\x9c2945f2edd00f2603f273227a9381426e0c185e9ed5063a9754c8eda9409cf6	557	35	49853119352	168449	0	292	\N	6444	t	0
206	\\xd428c1fad7c50dd15e17ae57f832de251119b8bdff1a0a04e17f20ab8644dd72	557	36	49842612553	168405	0	291	\N	6444	t	0
207	\\xa5dbd19263caacd8269194dd4657788eca43897b77b89a0fc782f245cb430895	557	37	49847950947	168405	0	291	\N	6444	t	0
208	\\x7933edaa17f568a2fc12ff5e734012c0d6e640f945762c70957c062b60ec629c	557	38	49847950947	168405	0	291	\N	6444	t	0
209	\\xba9846b24febc5f30398e58c6d0b97c19aa07fbb6f9011ff5afde723ca9a5340	557	39	49853119352	168449	0	292	\N	6444	t	0
210	\\x31e61c422ad50f551bf0d1ea7dfdc95335d8cba26da3d66ee1b76e6189039698	557	40	49858117768	170033	0	328	\N	6444	t	0
211	\\x9b935c0da430c08af716bd5cbcaf398459091c58db62236b0a18afe6dbfb90d2	557	41	49852949363	168405	0	291	\N	6444	t	0
212	\\x05d4c4bc5bb5b54565833ac1a5e7a5256ea7b21cce04037ab42cc5f259567561	557	42	49853119352	168449	0	292	\N	6444	t	0
213	\\x7943ef04863700b95d59be3751f18e0a579faf10fde2cb797be5ec7c0770688d	557	43	49853119352	168449	0	292	\N	6444	t	0
214	\\xb96aa999d18b1086eb59fb6fa147101d413dac7b1a338608bd9d0a40284290b2	557	44	49842950947	168405	0	291	\N	6444	t	0
215	\\x296bcb9c9757da509ef3f385ca1b137e3dd6ca3cb49c36a2ae8a22b1ac1245cc	557	45	49847950947	168405	0	291	\N	6444	t	0
216	\\xa7d206bff6972840206682b7d0ad92fd8af88a8bc5f307d7329a3dbb9415b2e0	557	46	49853119352	168449	0	292	\N	6444	t	0
217	\\x07d29f949162d3794eeb4f693d31b86b0ed00491fc2a8097e53111d7d02ab13d	557	47	49852949363	169989	0	327	\N	6444	t	0
218	\\x0d3fef9e9835f598d237b76987c31944318fb1775a959036f735ff5ef5a874cc	557	48	9830187	169813	0	323	\N	6444	t	0
219	\\x0e82249c120df5cb17186c73b84df103ae415812ecc661b3c0df08175a3156c7	557	49	58427917858	168405	0	291	\N	6444	t	0
220	\\xa23aeb83c0f36605a1afb88b9bb5f8b9bdcd4ec07b015eae3a27b78b6c84eaa2	557	50	49847950947	168405	0	291	\N	6444	t	0
221	\\xa6733a9f9cf33ead7c5d5b489a1e569130ee48bb1500b409f00050b2206ad246	557	51	49842782542	168405	0	291	\N	6444	t	0
222	\\x898c356e8d3104bb4b1a438a7e851c23664198180be2b53c97853893a6f3a2e6	557	52	9830187	169813	0	323	\N	6444	t	0
223	\\x1a91206c85591e26a7cdba36c8bf5df474d2ec64bb264ee000ff39ec7c221b4d	557	53	49843610969	168405	0	291	\N	6444	t	0
224	\\xb8dd50cba78e15736d13ebf8e4285eea4c9ab2c7aadd319ed95c72037631cd87	557	54	49853119352	168449	0	292	\N	6444	t	0
225	\\x9c89622242321a408ec8a526b4f8853f09c9a551faeb6bda34a4763e799c98f4	557	55	49842780958	169989	0	327	\N	6444	t	0
226	\\x0454ee534df4151512962634fd183e856cee8c41e10deead693d561eb385b4f1	557	56	9830187	169813	0	323	\N	6444	t	0
227	\\xf675c33f2d6b9085659fbe7be013d6b59d16ab6c9b2f32ae78ba44fde3b4cea7	557	57	49853119352	168449	0	292	\N	6444	t	0
228	\\xa8c2ebeef08011bf5d64ee2f10c8eff6a4a8f1050e34195f39092895c56aee7d	557	58	49847950947	168405	0	291	\N	6444	t	0
229	\\xc8d0639b7cb1193f4a296b4f1c6354ee156cb709247313abf6e660b933309b3d	557	59	49847950947	168405	0	291	\N	6444	t	0
230	\\x8561cf429cca3fb6ef411f5467cfe308a8dd3903ac54911c049a88f806a8236c	557	60	48857949363	169989	0	327	\N	6444	t	0
231	\\x3820e69e812e3a7959593b72e89384a68b87681785c31465c9538576965590e5	557	61	49847950947	168405	0	291	\N	6444	t	0
232	\\x3cb2e0fba853db3314ac06fcf7b64a0ffeb2448e8e7cea9072cc9ce01d101eaf	557	62	49857947779	169989	0	327	\N	6444	t	0
233	\\x801db1c09bdc15f3743b6832545e7f9caaeb20c08ca60129c83e0094b806e206	557	63	58422749453	168405	0	291	\N	6444	t	0
234	\\x107d4f2b694396fe2d31d2a618d5023f483aa12a836138d84ec2495d8ed97e92	557	64	49852779374	168405	0	291	\N	6444	t	0
235	\\x52536565ee38e126427e1ca3d6cdfb81a0672928b6062335e252f76038c1bb50	557	65	178161958	169813	0	323	\N	6444	t	0
236	\\x4c7c81cf466923725e03ed1f19dec409dd5e014f6d6629c99609a651d2d2e6cb	557	66	9830187	169813	0	323	\N	6444	t	0
237	\\xc14fb48905d53a01492000015f047184e5b2eece7fb78035a97c3b0758d8a5d8	557	67	9830187	169813	0	323	\N	6444	t	0
238	\\xecf43ec8d88a28b3165783cc1102c2904e7ce541d9acae47542cadc7542e965f	557	68	48852780958	168405	0	291	\N	6444	t	0
239	\\x1ba235a2995b12d75908ce37e773da892920744037e08a4b53d90fb7f3a37677	557	69	9830187	169813	0	323	\N	6444	t	0
240	\\xa66d426a316f28d276488fc6123cb93023bc4d9adb7d316b1ae349f4992f68a8	557	70	49853119352	168449	0	292	\N	6444	t	0
241	\\x8e1c1981b2bcdaf6dc936ca6782eda65fb9cada3068cde0369d51a28f207df7a	557	71	9830187	169813	0	323	\N	6444	t	0
242	\\xe620149610c350220031f9a3db7d7ebf4f98cb1dce4dc2616443b77e43a8509a	557	72	49853119352	168449	0	292	\N	6444	t	0
243	\\xb60bbb0c775b451d78ca67d9533d716e00d7f2a31a2f2f97cca0d1942e8dfb55	557	73	10828603	171397	0	359	\N	6444	t	0
244	\\xcc2773107086ff261d1e7f5a1f1408b9576f8b0ab7dcf3f17d8deb903d93f10e	557	74	9830187	169813	0	323	\N	6444	t	0
245	\\x6c68c26cc15f14308c79b92a6e943f950968238757e096b582726e2b9d677043	557	75	9830187	169813	0	323	\N	6444	t	0
246	\\xf9b0a499e61e9a6f6da21e13d6387b4f140fad66b88c303b9bd00ef57bfc5de1	557	76	9830187	169813	0	323	\N	6444	t	0
247	\\x2baf6aaa98261e496968b8228912361485158dabb46bf9b48561bc2d19eddd4e	557	77	9830187	169813	0	323	\N	6444	t	0
248	\\x9c362667a2c8656e63b61e68fe8aaf776998b5686eca00e41c9e388496bb9cc7	557	78	9830187	169813	0	323	\N	6444	t	0
249	\\xf4b4f81cb218683a36f810fb87aff814fa00f9ddf5615eaa19ab2b5018fb9ea1	557	79	49847950947	168405	0	291	\N	6444	t	0
250	\\xe973a9012ed8eaf7d92ad7fab39a86c0a72160580f7a73fb4bbf0bd2c321a56c	557	80	9830187	169813	0	323	\N	6444	t	0
251	\\x9d64d8ee4a666f64040270317188de7797fa9fcd9bbe09481f52a389f1df81a2	557	81	49847780958	169989	0	327	\N	6444	t	0
252	\\x6c546e982f1984613840e059bdafdae6ee78341f34fe1042b493a405d8c80a8f	558	0	9830187	169813	0	323	\N	6444	t	0
253	\\x650c5198110ef9de08017293d9210cab1b947f293eba6ad495937baf9763a01a	558	1	9660374	169813	0	323	\N	6444	t	0
254	\\xa7875f10f2c31e6398a0996bb77c9f399ec7977bc92b88d469bd9f279721413a	558	2	9830187	169813	0	323	\N	6444	t	0
255	\\x25367b1162adbb3a390ea940dc9ce1e7f7185dd6755e761c34d4cfe02287a23e	558	3	9490561	169813	0	323	\N	6444	t	0
256	\\x8d222e734cce602e61bc1ab92b52b75878b7b341945ac3df1d4e6109710bf051	559	0	48852610969	169989	0	327	\N	6444	t	0
257	\\xa8145751b9e714d0d12e8e18d0a8f11ded046b18be3a8253102106b771fe360d	559	1	49847950947	168405	0	291	\N	6460	t	0
258	\\x55ab231249234c9219adbd991e853ce27bb51ae6262e60b5fb8c2dea6118019d	559	2	10658790	169813	0	323	\N	6460	t	0
259	\\x66419bca29cac2a32a9324f59bbc73805f84c1cd6a818105c49d01433916186f	559	3	49842782542	168405	0	291	\N	6460	t	0
260	\\x6ff776f7db6612647fe8a0e57e57d53b733c636d2f1c4dee7d4a1a83fc4174ca	559	4	49847950947	168405	0	291	\N	6460	t	0
261	\\x5977e67c921c81439865197ba4831049688ad62140b6e0269a694201d898a55d	560	0	49852779374	169989	0	327	\N	6460	t	0
262	\\xe238a6f04b10c3cc36db25135d498da1e2cb38217ad301f428181c70d8a4beef	560	1	49857947955	170033	0	328	\N	6460	t	0
263	\\xd3b16dcd30d54db667bbcd145550226e1ac8f0f43c5523743220271d658359c2	560	2	9830187	169813	0	323	\N	6468	t	0
264	\\xba41cb3f2a831574b372a6c0e4b377b98b56848851b27920b536e3441ce07a0b	560	3	9492145	169813	0	323	\N	6468	t	0
265	\\x61f05cb5854d53b213ad5871615dade247e83e2e64742efda83fa91619be72b2	560	4	49853119352	168449	0	292	\N	6468	t	0
266	\\x12cc3968f2319a0ab76c99f9c08bfa631054d0073edc373a64677fc92eb88151	560	5	49842782542	168405	0	291	\N	6468	t	0
267	\\xbfd79ce35cead78abf14f01347777d123992858a407a492cb1de7d7d93d21dd7	560	6	49853119352	168449	0	292	\N	6468	t	0
268	\\xf34ede3ebea770214152f7e03ccf66fcb4959daf319add3458268e6fa31cafbc	560	7	49847950947	168405	0	291	\N	6468	t	0
269	\\x7db5adef0a4d88c3679a13765c804ad7e89ffdb51e15e620985f351623074f7c	560	8	9830187	169813	0	323	\N	6468	t	0
270	\\x87d57c634b4920044b43f443b49c3aaf992d66dc0b31f5e460cb494560ca5cf8	755	0	55150218674	174741	0	435	\N	8450	t	0
271	\\x1804fda89b9e19a6aa91a77ed2a341abdd35e5a8fd1fccbb3938f65ee75e4dcd	759	0	5004179399296	423033	2000000	6082	\N	8531	t	0
272	\\xea8d2b74e558cf7166d38e921291b786ecde4e1e2834dd426821c394eaae642f	943	0	1270678517294	174697	0	434	\N	10442	t	0
273	\\x204c202bfcf95e6f40b6e7a24fc97329b9f21d636eb3c165679e44c2b5f0ac63	943	1	156380451043	168405	0	291	\N	10442	t	0
274	\\xb14844e51c252445a975280fa44abac47a4567d990d24d71212515f7fb60f0d7	943	2	39094986457	168405	0	291	\N	10442	t	0
275	\\x2d36e9091037716968bae791f1a2584f9ea922aeeae63f64b9763f5366bf084d	943	3	156375282638	168405	0	291	\N	10442	t	0
276	\\x20a819d8c78040d8e2cb6cea4f3492ed19a55734d224b4663fe00b927f061b56	943	4	312761070491	168405	0	291	\N	10442	t	0
277	\\x88ce735706e0fe0b53119230beb6f151aafd5925905a4ba372d7ae81318b7e4e	943	5	1251044787177	168405	0	291	\N	10442	t	0
278	\\x13c58f79ff3baada2e8cd1db21c24158cdf0e61e547bbf0be2e653c817309f80	943	6	78190141319	168405	0	291	\N	10442	t	0
279	\\xf4741d48031a81c8c111a8eba53aa20f34d1da27280eafcb7e15e9090f512a6a	943	7	39094986457	168405	0	291	\N	10442	t	0
280	\\xad0273cd7ff55627d55c141f79aaddab89611a76c1a37200c818ed26318391f5	943	8	1270678347305	169989	0	327	\N	10442	t	0
281	\\x63a87f0c2dee785e6a1b27c457456c7fe75ff36f2606ed7deb6f0e8760a4ceb6	943	9	625522309386	168405	0	291	\N	10442	t	0
282	\\x8d37189da0bde8dc7d30148efe24bd40e21264ab214d5b53b98bc28326403162	943	10	1270673178900	168405	0	291	\N	10442	t	0
283	\\xf99fa4c55139bfd74fe79821aa3d680a2df64c8072d24d9d4c3c62ea4815053c	943	11	39094986456	168405	0	291	\N	10442	t	0
284	\\x4efb1cc87d0207706d33a4db79bdc0a18b8747ed6518df0a931c611615bc8e66	943	12	312761070491	168405	0	291	\N	10442	t	0
285	\\xe37b7bb45d7a14e3ee27c93c0365173a1eac188f9166dd1dedeeaa8d93ac3249	943	13	9830187	169813	0	323	\N	10442	t	0
286	\\x5c32a26a063a45c5498f433010a89eb88155bfde73da48100bc011f1549ab51c	943	14	625522309386	168405	0	291	\N	10442	t	0
287	\\x2ac5451d105ad7437d67c4541bc5abdeffe552da495b6ba3185c9a52e7f4e495	943	15	39089818052	168405	0	291	\N	10442	t	0
288	\\xf07087237d25847cfdb24afbcf1775a40142806cfab3869390736918ec736865	943	16	78195139735	169989	0	327	\N	10442	t	0
289	\\xf5412d788f92acbb28ea759d0cfb5b72e3ae19f29888138cfb2642c8cce8ab31	943	17	312755902086	168405	0	291	\N	10442	t	0
290	\\x783de9f2903bdba001260ca4195e3ac7498ce774f3ec2a5086cd08e536e72ca3	943	18	9830187	169813	0	323	\N	10442	t	0
291	\\xaeeea2cb96574d0a6ded0f669effdeb3cbb78c50ad5fdd94bd2a7b86d55506b9	943	19	9830187	169813	0	323	\N	10442	t	0
292	\\x71394c9ce75a7167645fed8b362a13361a3af99d04c5ba590cba71904a300cf4	943	20	9660374	169813	0	323	\N	10442	t	0
293	\\x5aa1bb4d3f99016bd201e07c2154e2ca222c33316d86aa21d6bb9c497d49de12	943	21	39094816468	169989	0	327	\N	10442	t	0
294	\\xc2ed2cbf5f2ab7e304cb59f9e9ffd8cac6566adaaefa5d8b033f7b186efd5b56	943	22	39094986456	168405	0	291	\N	10442	t	0
295	\\x50d7ebf0e123b9aad37d82c75aaa529de9a75a832c66b45edbe6060f848906b0	943	23	9830187	169813	0	323	\N	10442	t	0
296	\\x240aca40eff2195e40c0ac6e7597e03b2f04141fb3e8c13b13a9e9f22e508031	943	24	1251039618772	168405	0	291	\N	10442	t	0
297	\\xf5d5af86a5ea2efb8b91b4d92da6c6cb6d6ba9f1fe234f52b90962d63e0fe248	943	25	9830187	169813	0	323	\N	10442	t	0
298	\\x47b5132993492bdab616e2b7f95821df2b13818f45bf551ef0d7b670488d11c9	943	26	1270668010495	168405	0	291	\N	10442	t	0
299	\\xcf6dbca2ca6766eec38aed94abdd87876a1e8b06e2a3ede0baed76cc6b102278	943	27	9830187	169813	0	323	\N	10442	t	0
300	\\xb3997c30ba183dc9e84cfad255124081d1d26958fc256ef59807ebc70f658681	943	28	9830187	169813	0	323	\N	10442	t	0
301	\\x3f4223b4120eeaccc9cb148369759701e75bfc889f01693a6e31bce04c077057	943	29	39094816467	169989	0	327	\N	10442	t	0
302	\\x4db59d2edd53b315789dbfe0c01d55af1716a0252ad4544f1ba52c4d4d4e7116	943	30	625521969584	169989	0	327	\N	10442	t	0
303	\\xb856019c4e60760dcbabcfa66b959de12cdeb67d0eb61cf0fa9972b74777c9cf	943	31	39089648063	168405	0	291	\N	10442	t	0
304	\\xf4bc5aba994445f121cfce989b7c56ab83f7f97b9cce29cef1828e7d87e3e634	944	0	9830187	169813	0	323	\N	10442	t	0
305	\\x5ff5531e5e3bbe97762853ab98dc49efc1266a902c3898c96f1795a7740bb4be	944	1	9660374	169813	0	323	\N	10442	t	0
306	\\x4ae81224afc48552db602a67aec7a4a73a4f7e7e9f69c0e5d106b43adede6f75	944	2	9490561	169813	0	323	\N	10442	t	0
307	\\xa8f03666b08c9950ef38bb90cf6bb67e5eb4e08e653e3dcabee5a47895e8f0d3	944	3	312755902086	168405	0	291	\N	10451	t	0
308	\\x2afe08b2c4e00af1b3f4637bdccfdd89b635105c98bb73c0b632f4e9a496c8df	944	4	9660374	169813	0	323	\N	10451	t	0
309	\\x45ac8f2d2146404afd326b58a2fa9307486fe3dab734f66ebfb9cb2ba76c1b97	944	5	156374942836	169989	0	327	\N	10451	t	0
310	\\x00edca0a2b88436a6823e57d623e9364f6b911989bce274ebd1b6a8beb8b987b	944	6	78189971330	168405	0	291	\N	10451	t	0
311	\\x5aa13536fc3686215162556858392ec55f2265525ebfa00166de5785cea1f084	944	7	78184972914	168405	0	291	\N	10451	t	0
312	\\xf22072cf63f23a61697a0b3187afbcce56f6d44eb46eb68b72d7886226a727aa	944	8	78184802925	168405	0	291	\N	10451	t	0
313	\\x53239842aa1dae51e3ea25c51a5ad234ea6d00faccac4a9bd3ff8375de8eeffc	944	9	39089818051	168405	0	291	\N	10451	t	0
314	\\x80ae534ff7b1ddc49a8f416c6e3d397a4c75543bf27f76111b1f128ff4f744e2	944	10	9830187	169813	0	323	\N	10451	t	0
315	\\x168db34170eb42bec13f8e913f7486149d822478392a118a6c43ef133bd12d48	944	11	9830187	169813	0	323	\N	10451	t	0
316	\\x5dfc1620871c02671f7f3c1eda948d14bbbaeca51d7a05bd7307c8b350bcdbfb	944	12	1251034450367	168405	0	291	\N	10451	t	0
317	\\xd7f1708ecee94173b4973c769e3813f2bd43515b1ea77bbf76f371ca46411d0f	944	13	156369774431	168405	0	291	\N	10451	t	0
318	\\xd1e19f035e94eaa7b922721990ba1f9869b5e5eeb059a14c699de6ad7d8d6f85	944	14	156380451043	168405	0	291	\N	10451	t	0
319	\\xaf0e3ab77a4674eda9a9f67d4c51ce4ae96ef9ae4579ec61d163a6a64bb1bdd1	944	15	1270662842090	168405	0	291	\N	10451	t	0
320	\\xe1e566e98002b73a8f98806538b4bdce43658c6b79f93fe0f88a47d52eb96e3f	944	16	39084479658	168405	0	291	\N	10451	t	0
321	\\x62a28fb1b949ecc770022f31bd06b9f283346eb226ea3df61dc54e4623e761a2	944	17	9830187	169813	0	323	\N	10451	t	0
322	\\x4d7571403a5847218bb6912d081749ea898d882cbab7e55ad04854d6caf9f18b	944	18	9660374	169813	0	323	\N	10451	t	0
323	\\xa09086c91e08cc3dc6ed000a346921347f12f1a670f22c5b387ddf2979377d45	944	19	9830187	169813	0	323	\N	10451	t	0
324	\\x0e7ca691d76b2143024a80bc33f3ad2068ff63d825541293efa5aa77daf6016b	944	20	9830187	169813	0	323	\N	10451	t	0
325	\\xacc86ff3c9b5ee1462a32e0291cf6a7f7515c52e14557031aba5726eb3960e2b	944	21	9490561	169813	0	323	\N	10451	t	0
326	\\x46e12716b02035f4f32e3098138d441e75286a5618da2a60809912cca8184fc8	944	22	9830187	169813	0	323	\N	10451	t	0
327	\\x517a0c16713b6ddd1148b9c6d0841a74b708161455c43ef965b739a441bc0b5d	945	0	9830187	169813	0	323	\N	10451	t	0
328	\\x8b81496f03dada75d1cd3d38b65c6f7b1f467653ef90385e8cd448c28373c7e5	945	1	1270657673685	168405	0	291	\N	10451	t	0
329	\\xb71e1132214c246d718f631497080dff6119fc6978178bf6a4ae73a87d9d67e6	945	2	9660374	169813	0	323	\N	10451	t	0
330	\\xddb9b43ba64ca30efc219c81f077e6c01396f009e4ace3ac0f658d9e66bbff2a	946	0	9660374	169813	0	323	\N	10455	t	0
331	\\x21ac86d0ba4659c133638897cb6b8132cbd4d76e010fc7ab4eb8b5800eb65f38	946	1	156364606026	168405	0	291	\N	10455	t	0
332	\\xc13ada8e436c18d82b2afb17ba58d094e6ae842cfce4109c55bf351da27daf72	946	2	9490561	169813	0	323	\N	10456	t	0
333	\\xbf0177413383b780917eb19c4a3cf2447d5d627d513fc015e88d0133220418d5	946	3	9830187	169813	0	323	\N	10456	t	0
334	\\xdfb9cdfae759fa442dacfbf07b3a1920f8bb9a156fdac118f8c5b56491b88f14	946	4	9830187	169813	0	323	\N	10456	t	0
335	\\xfbf3f134cf2f3ed2b01105becbc5ac0d6d5ada84b302e88cd748a52e7b0e22d0	946	5	9830187	169813	0	323	\N	10456	t	0
336	\\xc3aae822890cf6a25e8cfb0f005418ae9952d59aeb5a49ac249c4a30db0539d7	946	6	625521969584	169989	0	327	\N	10456	t	0
337	\\xd44e4f940fa1d5ead8335620c4f361a27b12c09b50bc6443be1504c1e3cbc864	946	7	156364096411	169989	0	327	\N	10456	t	0
338	\\xb5a2c270e2c2543e934e9dc60f1d16e2e2c4c622f355ca9801dee3c7798d82d1	946	8	9660374	169813	0	323	\N	10456	t	0
339	\\x086333cd6a98fc1a9be62e9a7ea9e434d7682ffb780d9e2ee48bf13ac57b5aab	946	9	9490561	169813	0	323	\N	10456	t	0
340	\\x998dbc374a73ac11807aab198a7e12745798232783e18eec96e309156744629a	946	10	9830187	169813	0	323	\N	10456	t	0
341	\\x5605930205e0570cb5dd6a5b21563fe8851044c4c0cffacba486c9752fc0d4ee	946	11	1251029281962	168405	0	291	\N	10456	t	0
342	\\x37df70d7e3972608ad624efef83982d471af9021fac71e83600be3428980664e	946	12	312750733681	168405	0	291	\N	10456	t	0
343	\\xdc1ba9b72431c4a5ebe2af02796c71136d7ef6fddff5c5de02c2f5dba6d22c3d	946	13	39084649646	168405	0	291	\N	10456	t	0
344	\\xa5f73f70f42ffdca9f7b40093d8310a6b78c2f4fa240a62db56d9b66622e0f8b	946	14	9830187	169813	0	323	\N	10456	t	0
345	\\x451b3d5910291db405412840a528ae389929996535721f29aabbcc5b6f933e49	946	15	9320748	169813	0	323	\N	10456	t	0
346	\\x80315df07f28408dd7be8d30ad2da10278341b9d2ab0296ec0046f495e483c0d	946	16	9320748	169813	0	323	\N	10456	t	0
347	\\xf8b0886c4d1631368d5279d9908958db1d23fa95a002230f22945d416b9ea904	946	17	9830187	169813	0	323	\N	10456	t	0
348	\\xb0c68f5a58fc70f3313cf4ea76497439e00c15f4c777628012dc25bd364dd162	946	18	9660374	169813	0	323	\N	10456	t	0
349	\\x937d491629c062cc6e28dcb73319d8f2ec2cd5394c464a57b8ab04d0e31aa083	946	19	9660374	169813	0	323	\N	10456	t	0
350	\\x81311b025f153b00893bd201961e0811f1cfd0f9f7492aa54f8e366eb609c7de	946	20	9490561	169813	0	323	\N	10456	t	0
351	\\x6401350c79ab68e351cc6d3995d52816d49cb10bd330698f35b080eca1842e86	946	21	9660374	169813	0	323	\N	10456	t	0
352	\\xb348523f640b6c13a184e5b614b75de09923568a0e61bdbda8485b9a9d3a9cf3	946	22	9830187	169813	0	323	\N	10456	t	0
353	\\xe72f8b273fb0ec186bf382795b23fb3caa553d99c50934679b58b9d179798445	946	23	9150935	169813	0	323	\N	10456	t	0
354	\\xc7096e7fafc751a5bd218d57e34a0a37ab91cca4379505667be80bead891a0f9	946	24	9660374	169813	0	323	\N	10456	t	0
355	\\x5b8c29f842a843470f45cf23c6d33b3b13571004e0ce2a57bf9a1412a72bf009	946	25	1251028772347	169989	0	327	\N	10456	t	0
356	\\xea62689130ce8e10e23907587d4e5b58eed80ae963a3ff0e4db4526f19b6454b	946	26	9660374	169813	0	323	\N	10456	t	0
357	\\xa92a2925dedf3425a2b625b30e7c8eed7c013f9e6671c976de339890bc022925	946	27	312750733681	168405	0	291	\N	10456	t	0
358	\\x42d9e4b232049df370f514c7a72f0082ed11f4f8cb7c68cb1f2b1c7088ce6bba	946	28	9490561	169813	0	323	\N	10456	t	0
359	\\x0686f8a5e881de6fd452f8df26b27b219402b371c7d0b8bd930ebcdcf272f5a1	946	29	9830187	169813	0	323	\N	10456	t	0
360	\\x3bbfb737d38742144e1a0c00847b642876df5b48cf192c99411b45813980a117	946	30	39084309844	169989	0	327	\N	10456	t	0
361	\\x45db82eb0f0afdda6dd74c967ae992776df5f001c96b11c5231f17246b60a887	946	31	39079141439	168405	0	291	\N	10456	t	0
362	\\x313bfc9927a0a304d049925eb62f3f12398b7fcef316896590b714a43f1e5cf4	946	32	9490561	169813	0	323	\N	10456	t	0
363	\\x559c042c302d010cceb63111e21327dedfb55b0984207e03c03434f930237a63	946	33	9660374	169813	0	323	\N	10456	t	0
364	\\xad788faa3222210085512060715d40f7e2fa1d9e361dc5b594e08852d8ea19f6	946	34	9660374	169813	0	323	\N	10456	t	0
365	\\x7c6c8a7134579966e4296387d60f47e48d839aec4b2f48c45d59b232a2e102fe	946	35	39079311253	168405	0	291	\N	10456	t	0
366	\\x443e67d613dfcb6d8b2ceabf94e1237f9239b440283aa7d55fd26b588269552a	946	36	39089138624	169989	0	327	\N	10456	t	0
367	\\x52293fe52ae30d2b496712d7acae0656baff09bfc7c58df3c6057fb13e01df81	946	37	156358928006	168405	0	291	\N	10456	t	0
368	\\x1b4895b3d001a5590ff88e77d4ac707736e942e484aee315acbf2cb98132c208	946	38	9490561	169813	0	323	\N	10456	t	0
369	\\x31288bf4a1af6b0e04c442fa258dcd2240f7616e9af8c670d2e0c3531e0a01f9	946	39	9830187	169813	0	323	\N	10456	t	0
370	\\x136016429e180cc8ed0c680d65ef44dda2d9c8f79b2f3a8281314d5c9408fd58	946	40	9320748	169813	0	323	\N	10456	t	0
371	\\xfccd6c8adf39d02cff1d7160cce86884fc8b3cfb53c29635e5d08cf71e19058a	946	41	39078292198	169989	0	327	\N	10456	t	0
372	\\x8585b67c4012b7dad04ed6d9f0f6aca62204bdae8cb5b224b487a508f0d1ab9e	1137	0	15278586444	180725	0	571	\N	12462	t	0
373	\\xb48060c5dcdbeed2ac0d610dd5ca5eaae818be22729ce4a1a14fb2c2ba978533	1143	0	4999499820111	179889	500000000	552	\N	12560	t	0
374	\\x77f8220d4d4be07dc21c031b600fad6655ee73065baf23e11e8c681e98f9fc83	1147	0	4999494650122	169989	2000000	327	\N	12649	t	0
375	\\x6aa81201b145ce92fdb2e6ae0d2dee93b67a191ae788f4c26a75c3f8e9a70034	1151	0	5822839	177161	0	490	\N	12678	t	0
376	\\x0517688809d2deddd562f4fc5af148819545e4317595bae0493764c07fafd0c0	1155	0	4999493478549	171573	-2000000	363	\N	12754	t	0
377	\\x3fcdb1e061077cc7acf92905f10977db48cd53f0710f8a010933469b52190e1d	1157	0	4999529808055	191945	500000000	826	\N	12769	t	0
378	\\xb007e7809febae094067cfc5816a6e969730ccdfc8f10fdc5db8d02dad39168d	1162	0	4999527629002	179053	2000000	533	\N	12789	t	0
379	\\xacda539f730f32ae0d24d6a824b880730240bc5d847f35d880e43b32e752eea1	1166	0	4999524445769	183233	0	628	\N	12816	t	0
380	\\x96d316179f794fb14a0632c21a3c9d97cce81e879a9c20c3ab140bc552ba96fb	1174	0	15278350015	236429	0	1736	\N	12893	t	0
381	\\xeb49eebaaa1d2b2ca0063252653410b398cf5ab3597a4e131abcb2d6da0fe349	1178	0	15268127886	222129	0	1411	\N	12997	t	0
382	\\x5925fe837c614a0613a878bacc6b05591bcfddb430f4abf07b995c04adb3bbaf	1182	0	39074088288	222965	0	1430	\N	13034	t	0
383	\\x20d67af5b3d6b2740af7665fe80523fb30540786d2586ef4da67ffb7f65b3d56	1186	0	4638990	191197	0	708	\N	13056	t	0
\.


--
-- Data for Name: tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_in (id, tx_in_id, tx_out_id, tx_out_index, redeemer_id) FROM stdin;
1	35	25	0	\N
2	36	16	0	\N
3	37	18	0	\N
4	38	13	0	\N
5	39	19	0	\N
6	40	12	0	\N
7	41	23	0	\N
8	42	26	0	\N
9	43	31	0	\N
10	44	15	0	\N
11	45	14	0	\N
12	46	36	1	\N
13	47	35	1	\N
14	48	37	1	\N
15	49	43	1	\N
16	50	44	1	\N
17	51	39	1	\N
18	52	38	1	\N
19	53	42	1	\N
20	54	41	1	\N
21	55	40	1	\N
22	56	45	1	\N
23	57	46	0	\N
24	58	47	0	\N
25	59	48	0	\N
26	60	52	0	\N
27	61	55	0	\N
28	62	54	0	\N
29	63	56	0	\N
30	64	50	0	\N
31	65	49	0	\N
32	66	53	0	\N
33	67	51	0	\N
45	79	27	0	\N
46	80	24	0	\N
47	81	30	0	\N
48	82	22	0	\N
49	83	33	0	\N
50	84	29	0	\N
51	85	20	0	\N
52	86	32	0	\N
53	87	28	0	\N
54	88	21	0	\N
55	89	17	0	\N
56	90	79	0	\N
57	91	81	0	\N
58	92	80	0	\N
59	93	89	0	\N
60	94	83	0	\N
61	95	82	0	\N
62	96	86	0	\N
63	97	88	0	\N
64	98	84	0	\N
65	99	85	0	\N
66	100	87	0	\N
67	101	90	0	\N
68	102	91	0	\N
69	103	93	0	\N
70	104	100	0	\N
71	105	59	0	\N
72	106	58	0	\N
73	107	65	0	\N
74	108	64	0	\N
75	109	57	0	\N
76	110	109	0	1
77	111	109	1	\N
78	112	111	1	\N
79	113	112	1	\N
80	114	113	1	\N
81	115	114	1	\N
82	116	115	1	\N
83	117	116	0	2
84	117	116	1	\N
85	118	66	0	\N
86	119	63	0	\N
87	120	119	0	\N
88	121	120	1	\N
89	122	121	1	\N
90	123	122	0	\N
91	123	122	1	\N
92	124	123	1	\N
93	125	123	0	\N
94	126	124	1	\N
95	127	126	1	\N
96	128	124	0	\N
97	128	127	1	\N
98	128	125	0	\N
99	129	126	0	\N
100	130	128	0	\N
101	131	130	1	\N
102	132	131	0	\N
103	132	130	0	\N
104	133	132	0	\N
105	134	133	0	\N
106	135	133	1	\N
107	135	134	0	\N
108	136	135	0	\N
109	137	136	0	\N
110	138	137	0	\N
111	138	135	1	\N
112	139	131	1	\N
113	139	138	0	\N
114	140	138	1	\N
115	140	139	0	\N
118	142	140	0	\N
119	142	140	1	\N
120	143	142	1	\N
121	143	139	1	\N
122	144	143	0	\N
123	144	143	1	\N
124	144	142	0	\N
125	145	144	0	\N
126	146	145	0	\N
127	147	145	1	\N
128	148	147	0	\N
129	149	146	0	\N
130	149	147	1	\N
131	149	148	0	\N
132	150	149	0	\N
133	150	149	1	\N
134	151	150	0	\N
135	152	151	1	\N
136	153	152	0	\N
137	153	152	1	\N
138	153	152	2	\N
139	153	152	3	\N
140	153	152	4	\N
141	153	152	5	\N
142	153	152	6	\N
143	153	152	7	\N
144	153	152	8	\N
145	153	152	9	\N
146	153	152	10	\N
147	153	152	11	\N
148	153	152	12	\N
149	153	152	13	\N
150	153	152	14	\N
151	153	152	15	\N
152	153	152	16	\N
153	153	152	17	\N
154	153	152	18	\N
155	153	152	19	\N
156	153	152	20	\N
157	153	152	21	\N
158	153	152	22	\N
159	153	152	23	\N
160	153	152	24	\N
161	153	152	25	\N
162	153	152	26	\N
163	153	152	27	\N
164	153	152	28	\N
165	153	152	29	\N
166	153	152	30	\N
167	153	152	31	\N
168	153	152	32	\N
169	153	152	33	\N
170	153	152	34	\N
171	153	152	35	\N
172	153	152	36	\N
173	153	152	37	\N
174	153	152	38	\N
175	153	152	39	\N
176	153	152	40	\N
177	153	152	41	\N
178	153	152	42	\N
179	153	152	43	\N
180	153	152	44	\N
181	153	152	45	\N
182	153	152	46	\N
183	153	152	47	\N
184	153	152	48	\N
185	153	152	49	\N
186	153	152	50	\N
187	153	152	51	\N
188	153	152	52	\N
189	153	152	53	\N
190	153	152	54	\N
191	153	152	55	\N
192	153	152	56	\N
193	153	152	57	\N
194	153	152	58	\N
195	153	152	59	\N
196	154	152	74	\N
197	155	154	0	\N
198	156	152	77	\N
199	157	156	0	\N
200	158	152	72	\N
201	159	152	69	\N
202	160	152	114	\N
203	161	160	0	\N
204	162	161	0	\N
205	162	161	1	\N
206	162	161	2	\N
207	162	161	3	\N
208	162	161	4	\N
209	162	161	5	\N
210	162	161	6	\N
211	162	161	7	\N
212	162	161	8	\N
213	162	161	9	\N
214	162	161	10	\N
215	162	161	11	\N
216	162	161	12	\N
217	162	161	13	\N
218	162	161	14	\N
219	162	161	15	\N
220	162	161	16	\N
221	162	161	17	\N
222	162	161	18	\N
223	162	161	19	\N
224	162	161	20	\N
225	162	161	21	\N
226	162	161	22	\N
227	162	161	23	\N
228	162	161	24	\N
229	162	161	25	\N
230	162	161	26	\N
231	162	161	27	\N
232	162	161	28	\N
233	162	161	29	\N
234	162	161	30	\N
235	162	161	31	\N
236	162	161	32	\N
237	162	161	33	\N
238	162	161	34	\N
239	163	162	0	\N
240	164	152	65	\N
241	165	164	0	\N
242	166	165	1	\N
243	167	152	91	\N
244	168	150	1	\N
245	169	152	98	\N
246	170	154	1	\N
247	171	152	90	\N
248	172	152	97	\N
249	173	152	81	\N
250	174	152	92	\N
251	175	152	94	\N
252	176	153	0	\N
253	177	172	1	\N
254	178	152	93	\N
255	179	152	67	\N
256	180	152	116	\N
257	181	152	88	\N
258	182	159	0	\N
259	183	152	87	\N
260	184	152	105	\N
261	184	177	0	\N
262	185	152	118	\N
263	186	152	70	\N
264	187	152	112	\N
265	188	152	96	\N
266	189	152	101	\N
267	190	152	119	\N
268	191	169	0	\N
269	192	152	60	\N
270	193	152	66	\N
271	194	152	115	\N
272	195	152	99	\N
273	196	156	1	\N
274	196	194	0	\N
275	197	186	1	\N
276	198	173	1	\N
277	199	165	0	\N
278	199	177	1	\N
279	199	174	0	\N
280	200	175	0	\N
281	200	196	0	\N
282	201	152	107	\N
283	202	183	1	\N
284	203	198	1	\N
285	203	187	0	\N
286	204	178	0	\N
287	204	152	104	\N
288	205	152	61	\N
289	206	203	1	\N
290	207	189	1	\N
291	208	178	1	\N
292	209	152	75	\N
293	210	152	109	\N
294	210	189	0	\N
295	211	210	1	\N
296	212	152	103	\N
297	213	152	89	\N
298	214	164	1	\N
299	215	174	1	\N
300	216	152	73	\N
301	217	191	0	\N
302	217	187	1	\N
303	218	193	0	\N
304	218	197	0	\N
305	219	192	1	\N
306	220	213	1	\N
307	221	208	1	\N
308	222	180	0	\N
309	222	192	0	\N
310	223	199	1	\N
311	224	152	108	\N
312	225	170	0	\N
313	225	170	1	\N
314	226	223	0	\N
315	226	207	0	\N
316	227	152	117	\N
317	228	227	1	\N
318	229	188	1	\N
319	230	205	0	\N
320	230	160	1	\N
321	231	179	1	\N
322	232	210	0	\N
323	232	184	1	\N
324	233	219	1	\N
325	234	232	1	\N
326	235	212	0	\N
327	235	176	1	\N
328	236	171	0	\N
329	236	213	0	\N
330	237	234	0	\N
331	237	204	0	\N
332	238	230	1	\N
333	239	215	0	\N
334	239	221	0	\N
335	240	152	80	\N
336	241	211	0	\N
337	241	214	0	\N
338	242	152	83	\N
339	243	155	0	\N
340	243	242	0	\N
341	243	199	0	\N
342	244	222	0	\N
343	244	220	0	\N
344	245	183	0	\N
345	245	203	0	\N
346	246	182	0	\N
347	246	227	0	\N
348	247	198	0	\N
349	247	245	0	\N
350	248	239	0	\N
351	248	202	0	\N
352	249	201	1	\N
353	250	181	0	\N
354	250	190	0	\N
355	251	233	0	\N
356	251	220	1	\N
357	252	231	0	\N
358	252	230	0	\N
359	253	218	1	\N
360	253	251	0	\N
361	254	236	0	\N
362	254	240	0	\N
363	255	247	1	\N
364	255	244	1	\N
365	256	238	1	\N
366	256	188	0	\N
367	257	240	1	\N
368	258	176	0	\N
369	258	243	1	\N
370	259	228	1	\N
371	260	193	1	\N
372	261	217	1	\N
373	261	247	0	\N
374	262	152	79	\N
375	262	241	1	\N
376	263	173	0	\N
377	263	241	0	\N
378	264	182	1	\N
379	264	263	1	\N
380	265	152	64	\N
381	266	215	1	\N
382	267	152	76	\N
383	268	212	1	\N
384	269	258	0	\N
385	269	244	0	\N
386	270	152	62	\N
387	271	226	0	\N
388	271	226	1	\N
389	271	217	0	\N
390	271	218	0	\N
391	271	219	0	\N
392	271	234	1	\N
393	271	181	1	\N
394	271	266	0	\N
395	271	266	1	\N
396	271	223	1	\N
397	271	239	1	\N
398	271	152	63	\N
399	271	152	68	\N
400	271	152	71	\N
401	271	152	78	\N
402	271	152	82	\N
403	271	152	84	\N
404	271	152	85	\N
405	271	152	86	\N
406	271	152	95	\N
407	271	152	100	\N
408	271	152	102	\N
409	271	152	106	\N
410	271	152	110	\N
411	271	152	111	\N
412	271	152	113	\N
413	271	255	0	\N
414	271	255	1	\N
415	271	175	1	\N
416	271	231	1	\N
417	271	232	0	\N
418	271	180	1	\N
419	271	194	1	\N
420	271	201	0	\N
421	271	190	1	\N
422	271	185	0	\N
423	271	185	1	\N
424	271	236	1	\N
425	271	196	1	\N
426	271	235	0	\N
427	271	235	1	\N
428	271	258	1	\N
429	271	186	0	\N
430	271	261	0	\N
431	271	261	1	\N
432	271	191	1	\N
433	271	265	0	\N
434	271	265	1	\N
435	271	253	0	\N
436	271	253	1	\N
437	271	259	0	\N
438	271	259	1	\N
439	271	171	1	\N
440	271	252	0	\N
441	271	252	1	\N
442	271	245	1	\N
443	271	260	0	\N
444	271	260	1	\N
445	271	208	0	\N
446	271	168	0	\N
447	271	200	0	\N
448	271	200	1	\N
449	271	269	0	\N
450	271	269	1	\N
451	271	233	1	\N
452	271	270	0	\N
453	271	270	1	\N
454	271	195	0	\N
455	271	195	1	\N
456	271	222	1	\N
457	271	256	0	\N
458	271	256	1	\N
459	271	158	0	\N
460	271	158	1	\N
461	271	184	0	\N
462	271	211	1	\N
463	271	205	1	\N
464	271	248	0	\N
465	271	248	1	\N
466	271	225	0	\N
467	271	225	1	\N
468	271	251	1	\N
469	271	207	1	\N
470	271	221	1	\N
471	271	254	0	\N
472	271	254	1	\N
473	271	216	0	\N
474	271	216	1	\N
475	271	257	0	\N
476	271	257	1	\N
477	271	228	0	\N
478	271	172	0	\N
479	271	159	1	\N
480	271	243	0	\N
481	271	224	0	\N
482	271	224	1	\N
483	271	214	1	\N
484	271	264	0	\N
485	271	264	1	\N
486	271	209	0	\N
487	271	209	1	\N
488	271	267	0	\N
489	271	267	1	\N
490	271	237	0	\N
491	271	237	1	\N
492	271	202	1	\N
493	271	229	0	\N
494	271	229	1	\N
495	271	179	0	\N
496	271	263	0	\N
497	271	206	0	\N
498	271	206	1	\N
499	271	262	0	\N
500	271	262	1	\N
501	271	242	1	\N
502	271	250	0	\N
503	271	250	1	\N
504	271	167	1	\N
505	271	238	0	\N
506	271	197	1	\N
507	271	268	0	\N
508	271	268	1	\N
509	271	249	0	\N
510	271	249	1	\N
511	271	246	0	\N
512	271	246	1	\N
513	271	204	1	\N
514	272	271	0	\N
515	273	271	7	\N
516	274	271	11	\N
517	275	273	1	\N
518	276	271	5	\N
519	277	271	1	\N
520	278	271	9	\N
521	279	271	10	\N
522	280	272	0	\N
523	280	272	1	\N
524	281	271	3	\N
525	282	280	1	\N
526	283	271	12	\N
527	284	271	4	\N
528	285	281	0	\N
529	285	283	0	\N
530	286	271	2	\N
531	287	274	1	\N
532	288	271	8	\N
533	288	276	0	\N
534	289	276	1	\N
535	290	274	0	\N
536	290	279	0	\N
537	291	273	0	\N
538	291	282	0	\N
539	292	284	0	\N
540	292	290	1	\N
541	293	280	0	\N
542	293	279	1	\N
543	294	271	13	\N
544	295	293	0	\N
545	295	292	0	\N
546	296	277	1	\N
547	297	290	0	\N
548	297	289	0	\N
549	298	282	1	\N
550	299	288	0	\N
551	299	297	0	\N
552	300	298	0	\N
553	300	291	0	\N
554	301	278	0	\N
555	301	294	1	\N
556	302	286	1	\N
557	302	291	1	\N
558	303	293	1	\N
559	304	286	0	\N
560	304	285	0	\N
561	305	294	0	\N
562	305	299	1	\N
563	306	305	1	\N
564	306	303	0	\N
565	307	284	1	\N
566	308	275	0	\N
567	308	304	1	\N
568	309	275	1	\N
569	309	285	1	\N
570	310	288	1	\N
571	311	278	1	\N
572	312	310	1	\N
573	313	283	1	\N
574	314	301	0	\N
575	314	305	0	\N
576	315	306	0	\N
577	315	295	0	\N
578	316	296	1	\N
579	317	309	1	\N
580	318	271	6	\N
581	319	298	1	\N
582	320	303	1	\N
583	321	310	0	\N
584	321	300	0	\N
585	322	287	0	\N
586	322	321	1	\N
587	323	296	0	\N
588	323	322	0	\N
589	324	316	0	\N
590	324	307	0	\N
591	325	292	1	\N
592	325	323	0	\N
593	326	315	0	\N
594	326	299	0	\N
595	327	319	0	\N
596	327	304	0	\N
597	328	319	1	\N
598	329	308	0	\N
599	329	327	1	\N
600	330	295	1	\N
601	330	313	0	\N
602	331	317	1	\N
603	332	308	1	\N
604	332	330	0	\N
605	333	324	0	\N
606	333	331	0	\N
607	334	302	0	\N
608	334	321	0	\N
609	335	314	0	\N
610	335	333	0	\N
611	336	281	1	\N
612	336	323	1	\N
613	337	331	1	\N
614	337	329	1	\N
615	338	334	0	\N
616	338	297	1	\N
617	339	322	1	\N
618	339	329	0	\N
619	340	336	0	\N
620	340	318	0	\N
621	341	316	1	\N
622	342	307	1	\N
623	343	313	1	\N
624	344	341	0	\N
625	344	335	0	\N
626	345	325	0	\N
627	345	332	1	\N
628	346	339	1	\N
629	346	340	0	\N
630	347	309	0	\N
631	347	338	0	\N
632	348	340	1	\N
633	348	317	0	\N
634	349	326	0	\N
635	349	347	1	\N
636	350	338	1	\N
637	350	312	0	\N
638	351	339	0	\N
639	351	314	1	\N
640	352	328	0	\N
641	352	344	0	\N
642	353	324	1	\N
643	353	306	1	\N
644	354	326	1	\N
645	354	327	0	\N
646	355	341	1	\N
647	355	351	1	\N
648	356	348	0	\N
649	356	335	1	\N
650	357	289	1	\N
651	358	352	0	\N
652	358	330	1	\N
653	359	337	0	\N
654	359	343	0	\N
655	360	344	1	\N
656	360	343	1	\N
657	361	360	1	\N
658	362	354	0	\N
659	362	354	1	\N
660	363	352	1	\N
661	363	347	0	\N
662	364	315	1	\N
663	364	353	0	\N
664	365	320	1	\N
665	366	287	1	\N
666	366	350	1	\N
667	367	337	1	\N
668	368	365	0	\N
669	368	364	1	\N
670	369	358	0	\N
671	369	366	0	\N
672	370	358	1	\N
673	370	345	0	\N
674	371	345	1	\N
675	371	361	1	\N
676	372	277	0	\N
677	373	119	2	\N
678	374	373	1	\N
679	375	374	0	\N
680	375	373	0	\N
681	376	374	1	\N
682	377	118	0	\N
683	377	120	0	\N
684	377	121	0	\N
685	377	119	4	\N
686	378	377	0	\N
687	378	377	1	\N
688	379	378	1	\N
689	380	372	0	\N
690	380	372	1	\N
691	381	380	1	\N
692	382	365	1	\N
693	383	300	1	\N
\.


--
-- Data for Name: tx_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_metadata (id, key, json, bytes, tx_id) FROM stdin;
1	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "testhandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "testhandle", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": "ipfs://some-hash", "website": "https://cardano.org/", "mediaType": "image/jpeg", "description": "The Handle Standard", "augmentations": []}, "hellohandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "hellohandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "doublehandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "doublehandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a460a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656067776562736974657468747470733a2f2f63617264616e6f2e6f72672f6c646f75626c6568616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656c646f75626c6568616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6b68656c6c6f68616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656b68656c6c6f68616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6a7465737468616e646c65a86d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e646172646566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e7965696d61676570697066733a2f2f736f6d652d68617368696d65646961547970656a696d6167652f6a706567646e616d656a7465737468616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f	120
2	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	122
3	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16568616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65662468616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	123
4	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"sub@handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$sub@handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a1697375624068616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656a247375624068616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	124
5	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"virtual@handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$virtual@handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16d7669727475616c4068616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656e247669727475616c4068616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	125
6	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	130
7	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	131
8	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	133
9	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	135
10	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"NFT-001": {"name": "One", "image": ["ipfs://some_hash1"], "version": "1.0"}, "NFT-002": {"name": "Two", "image": ["ipfs://some_hash2"], "version": "1.0"}, "NFT-files": {"id": "1", "name": "NFT with files", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": ["ipfs://somehash"], "version": "1.0", "mediaType": "image/png", "description": ["NFT with different types of files"]}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a3674e46542d303031a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65634f6e656776657273696f6e63312e30674e46542d303032a365696d6167658171697066733a2f2f736f6d655f6861736832646e616d656354776f6776657273696f6e63312e30694e46542d66696c6573a76b6465736372697074696f6e8178214e4654207769746820646966666572656e74207479706573206f662066696c65736566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e79626964613165696d616765816f697066733a2f2f736f6d6568617368696d656469615479706569696d6167652f706e67646e616d656e4e465420776974682066696c65736776657273696f6e63312e30	138
11	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"4349502d303032352d76312d686578": {"name": "CIP-0025-v1-hex", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1781e343334393530326433303330333233353264373633313264363836353738a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656f4349502d303032352d76312d6865786776657273696f6e63312e30	140
13	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"CIP-0025-v1-utf8": {"name": "CIP-0025-v1-utf8", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1704349502d303032352d76312d75746638a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65704349502d303032352d76312d757466386776657273696f6e63312e30	142
14	721	{"0x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"0x4349502d303032352d7632": {"name": "CIP-0025-v2", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a1581c17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029a14b4349502d303032352d7632a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656b4349502d303032352d76326776657273696f6e63312e30	143
15	123	"1234"	\\xa1187b6431323334	158
16	6862	{"name": "Test Portfolio", "pools": [{"id": "5042dc1f20a769aa694f0cffe5ecff7fcf27c206c3212a622b3836a5", "weight": 1}, {"id": "1fcda2a751c476ecdd45936d5115037f1617ca266cfdf9d4f85f5583", "weight": 1}, {"id": "76687c8c1ac150006ca6b59dd7fb4244d627a1ae16ac0548acbe8442", "weight": 1}, {"id": "264e011a7bbd275c413f2ee6b6fa3b6bba403f1bfd6946f6bdbe3391", "weight": 1}, {"id": "e0bab0b4bb55862bed0fdbc9a729b359fda1d79d3a04e8101cdcebb1", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783835303432646331663230613736396161363934663063666665356563666637666366323763323036633332313261363232623338333661356677656967687401a2626964783831666364613261373531633437366563646434353933366435313135303337663136313763613236366366646639643466383566353538336677656967687401a2626964783837363638376338633161633135303030366361366235396464376662343234346436323761316165313661633035343861636265383434326677656967687401a2626964783832363465303131613762626432373563343133663265653662366661336236626261343033663162666436393436663662646265333339316677656967687401a2626964783865306261623062346262353538363262656430666462633961373239623335396664613164373964336130346538313031636463656262316677656967687401	161
17	6862	{"name": "Test Portfolio", "pools": [{"id": "5042dc1f20a769aa694f0cffe5ecff7fcf27c206c3212a622b3836a5", "weight": 0}, {"id": "1fcda2a751c476ecdd45936d5115037f1617ca266cfdf9d4f85f5583", "weight": 0}, {"id": "76687c8c1ac150006ca6b59dd7fb4244d627a1ae16ac0548acbe8442", "weight": 0}, {"id": "264e011a7bbd275c413f2ee6b6fa3b6bba403f1bfd6946f6bdbe3391", "weight": 0}, {"id": "e0bab0b4bb55862bed0fdbc9a729b359fda1d79d3a04e8101cdcebb1", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783835303432646331663230613736396161363934663063666665356563666637666366323763323036633332313261363232623338333661356677656967687400a2626964783831666364613261373531633437366563646434353933366435313135303337663136313763613236366366646639643466383566353538336677656967687400a2626964783837363638376338633161633135303030366361366235396464376662343234346436323761316165313661633035343861636265383434326677656967687400a2626964783832363465303131613762626432373563343133663265653662366661336236626261343033663162666436393436663662646265333339316677656967687400a2626964783865306261623062346262353538363262656430666462633961373239623335396664613164373964336130346538313031636463656262316677656967687401	162
18	6862	{"pools": [{"id": "5042dc1f20a769aa694f0cffe5ecff7fcf27c206c3212a622b3836a5", "weight": 1}]}	\\xa1191acea165706f6f6c7381a2626964783835303432646331663230613736396161363934663063666665356563666637666366323763323036633332313261363232623338333661356677656967687401	167
19	6862	{"name": "Test Portfolio", "pools": [{"id": "5042dc1f20a769aa694f0cffe5ecff7fcf27c206c3212a622b3836a5", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7381a2626964783835303432646331663230613736396161363934663063666665356563666637666366323763323036633332313261363232623338333661356677656967687401	169
20	6862	{"name": "Test Portfolio", "pools": [{"id": "5042dc1f20a769aa694f0cffe5ecff7fcf27c206c3212a622b3836a5", "weight": 1}, {"id": "1fcda2a751c476ecdd45936d5115037f1617ca266cfdf9d4f85f5583", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7382a2626964783835303432646331663230613736396161363934663063666665356563666637666366323763323036633332313261363232623338333661356677656967687401a2626964783831666364613261373531633437366563646434353933366435313135303337663136313763613236366366646639643466383566353538336677656967687401	271
21	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	380
22	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16568616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65662468616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	381
23	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"sub@handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$sub@handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a1697375624068616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656a247375624068616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	382
24	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"virtual@handl": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$virtual@handl", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16d7669727475616c4068616e646ca66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656e247669727475616c4068616e646c67776562736974657468747470733a2f2f63617264616e6f2e6f72672f	383
\.


--
-- Data for Name: tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_out (id, tx_id, index, address, address_raw, address_has_script, payment_cred, stake_address_id, value, data_hash, inline_datum_id, reference_script_id) FROM stdin;
1	1	0	5oP9ib6ym3XYgr2uc4hPryGeQ9Mdy4m4zCr5T7ToNbvtQXC3jC54fvvFBXUMEPNR71	\\x82d818582683581c16681036d18cc2b71d1c1975a0c3bf73515d668f3ed076908f06e973a10243190378001a1f9b0504	f	\N	\N	910909092	\N	\N	\N
2	2	0	5oP9ib6ym3XYhPo8xCXxF8B3mvZiwfHjdM4HbmyLgcoChttD87Je9xWwBRxuQePQzX	\\x82d818582683581c1698b5c12a65aa027d75819bd5e8d21bae1dd2ad52a89976077a1cdea10243190378001a20d921e4	f	\N	\N	910909092	\N	\N	\N
3	3	0	5oP9ib6ym3XZSCNKwzB7TsfwtDSHTKRnDyMndn3UeBMp22fGA7e9ykmLqSMTv24gc8	\\x82d818582683581c2572f1bd5edc38f09a67f4fa1bca90c05605beb036315452a5984f48a10243190378001a20bcc799	f	\N	\N	910909092	\N	\N	\N
4	4	0	5oP9ib6ym3XaS8aDGGsQnbHbmJ8VJ7Ms4942tY1k9PyPrWZpoc6Somv2Y24aMupWFR	\\x82d818582683581c398d55bbf478b45f489c8804ca9ee9b66b01af4b826c8063bb21548aa10243190378001a71734630	f	\N	\N	910909092	\N	\N	\N
5	5	0	5oP9ib6ym3XaqQUbq3SQjEGpnLQ3aSCe95dEEyAz6u1oScSE3rbr8FYjFbYycLZ1NT	\\x82d818582683581c41a0ce8eb7cbfc9947e238fc98bc5ed137b75cc1e75bf2f9c0ee7e45a10243190378001a854ec86c	f	\N	\N	910909092	\N	\N	\N
6	6	0	5oP9ib6ym3XcGYydcyiaSxf1UhuiyFVErhpgvzZr5P1LYGtFno6xVF3qTsC8c8gudK	\\x82d818582683581c5e7ace6708fa259e94ac4e771ba6a67d710f44a988ee245c93f91189a10243190378001ab06fc532	f	\N	\N	910909092	\N	\N	\N
7	7	0	5oP9ib6ym3XdNrzyjFkqJ1VWANEFxVDs3VtCk4iR7XnmnKcy1oYMmaXZgLM3qt9acM	\\x82d818582683581c74cb998395c77e67125c0d8c7b22a7c5979420289bbb29e26a5f379ea10243190378001a1c507a96	f	\N	\N	910909092	\N	\N	\N
8	8	0	5oP9ib6ym3XdYoLRaKrj59DXRPXUsaf4A6jwM4Xk6dzDEgrURTm873GcRwoq5vdanu	\\x82d818582683581c783e4c38cf97b73ff1145f316b0512c6ab30c9cc5903988a4b904531a10243190378001a61d72d7a	f	\N	\N	910909092	\N	\N	\N
9	9	0	5oP9ib6ym3XemWMSixRYTxSMs7jo8V5X2ME7vDQ5dPki53D3LnmCpRbBJJCYTTGB6h	\\x82d818582683581c90c74b8f751b78de4e8f268b714c07f5cf6f374d86b0192d3dd4f9daa10243190378001a381c4b2a	f	\N	\N	910909092	\N	\N	\N
10	10	0	5oP9ib6ym3XfCz2Xb7xYG5dwJ54TbpDtXnWJvALUqTv9vJ4Mihgp8SDX4gcFbVt3nk	\\x82d818582683581c999e74f0f95d6ed79e1c9b69d4500a7ec1a32923935d435e846c3071a10243190378001ac3adab9d	f	\N	\N	910909092	\N	\N	\N
11	11	0	5oP9ib6ym3XifxT88Y44W6MydoDfb3uwmnRTsGEX5ATJeaujX7FEb2XCgQ8CvuRWk8	\\x82d818582683581cdf5b17764684f3c095b45dd113ae2c095bbfb57011acbcf5ac84b66ba10243190378001a7ce8e339	f	\N	\N	910909092	\N	\N	\N
12	12	0	addr_test1vpqwr6a4fqkq9dt97r3hvjrslyf9fkpjdwr8x5y9p97hpashjtpna	\\x6040e1ebb5482c02b565f0e3764870f91254d8326b86735085097d70f6	f	\\x40e1ebb5482c02b565f0e3764870f91254d8326b86735085097d70f6	\N	3681818181818181	\N	\N	\N
13	13	0	addr_test1vpw2vfg5v7umxhznq557xunctzdvn23lmylp5uxr62m3mygvdgyjv	\\x605ca6251467b9b35c530529e37278589ac9aa3fd93e1a70c3d2b71d91	f	\\x5ca6251467b9b35c530529e37278589ac9aa3fd93e1a70c3d2b71d91	\N	3681818181818181	\N	\N	\N
14	14	0	addr_test1vr3sj8g858g0z3mcma4v73x4jyul5jsmzw43rtym36t5k9cufpa3u	\\x60e3091d07a1d0f14778df6acf44d59139fa4a1b13ab11ac9b8e974b17	f	\\xe3091d07a1d0f14778df6acf44d59139fa4a1b13ab11ac9b8e974b17	\N	3681818181818181	\N	\N	\N
15	15	0	addr_test1vzyyk2heuelfa7528qkjk2lncj3ynu63xk6h4hkhlehrfcgadvgt8	\\x60884b2af9e67e9efa8a382d2b2bf3c4a249f35135b57aded7fe6e34e1	f	\\x884b2af9e67e9efa8a382d2b2bf3c4a249f35135b57aded7fe6e34e1	\N	3681818181818181	\N	\N	\N
16	16	0	addr_test1vq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaqekncyn	\\x60232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	\N	3681818181818190	\N	\N	\N
17	17	0	addr_test1qrje7dnzk37f4p6xjpr27mr6xxuxfrkyhujk0pfgr9x3saxcvjxkt9dr477xkugnc9jlqtqyaq83er2fxc0qjjsjf7tq86569p	\\x00e59f3662b47c9a87469046af6c7a31b8648ec4bf25678528194d1874d8648d6595a3afbc6b7113c165f02c04e80f1c8d49361e094a124f96	f	\\xe59f3662b47c9a87469046af6c7a31b8648ec4bf25678528194d1874	\N	3681818181818181	\N	\N	\N
18	18	0	addr_test1vq34u8s6dx2up8v3rcmnmx6qr3qjfak269fafsnxkgssswq4tjkz7	\\x60235e1e1a6995c09d911e373d9b401c4124f6cad153d4c266b2210838	f	\\x235e1e1a6995c09d911e373d9b401c4124f6cad153d4c266b2210838	\N	3681818181818181	\N	\N	\N
19	19	0	addr_test1vrvs95e8ymkapdg4qlknwdaezsx0klk34hkdnvc0reqv68gkwsa9e	\\x60d902d32726edd0b51507ed3737b9140cfb7ed1adecd9b30f1e40cd1d	f	\\xd902d32726edd0b51507ed3737b9140cfb7ed1adecd9b30f1e40cd1d	\N	3681818181818181	\N	\N	\N
20	20	0	addr_test1qqn08wqz06gjc6tywjp0wgggd3r25jkasgmrfjydqhdw2wnfz5sd8k7afna9cd6gn97rljuqx35a7muymhfeuujna5psswtz37	\\x0026f3b8027e912c69647482f721086c46aa4add823634c88d05dae53a691520d3dbdd4cfa5c3748997c3fcb803469df6f84ddd39e7253ed03	f	\\x26f3b8027e912c69647482f721086c46aa4add823634c88d05dae53a	\N	3681818181818181	\N	\N	\N
21	21	0	addr_test1qrhdqh79t95n5uahxazc3mw9j27msshgrjz3x55ye6k9hks9qwllsq2tuaqru6x4qua8gtx2xwsckmcfdxytzdmhm6tquu9z3q	\\x00eed05fc559693a73b7374588edc592bdb842e81c85135284ceac5bda0503bff8014be7403e68d5073a742cca33a18b6f096988b13777de96	f	\\xeed05fc559693a73b7374588edc592bdb842e81c85135284ceac5bda	\N	3681818181818181	\N	\N	\N
22	22	0	addr_test1qpcrx0xxnz77sg2u065ljkq7kuuhwa4hsclmt9tk9fdhfxec8fczl4hukcwptg49htghcv5qkrat6rh3w5zh4r0nd55scekdnn	\\x0070333cc698bde8215c7ea9f9581eb7397776b7863fb595762a5b749b383a702fd6fcb61c15a2a5bad17c3280b0fabd0ef175057a8df36d29	f	\\x70333cc698bde8215c7ea9f9581eb7397776b7863fb595762a5b749b	\N	3681818181818181	\N	\N	\N
23	23	0	addr_test1vrlgq892z9ywq3g38y05yplvcmanlrqtk5qu5vy790d4kycrxvc6d	\\x60fe801caa1148e04511391f4207ecc6fb3f8c0bb501ca309e2bdb5b13	f	\\xfe801caa1148e04511391f4207ecc6fb3f8c0bb501ca309e2bdb5b13	\N	3681818181818181	\N	\N	\N
24	24	0	addr_test1qp4ng92hkt934r4tztqwdy3esqpegg7zqechflm9h06vl3cv7zjwc57wslwywv3ae4egntgjqj0pd4e67ay3597f9r5sk9llf4	\\x006b341557b2cb1a8eab12c0e6923980039423c2067174ff65bbf4cfc70cf0a4ec53ce87dc47323dcd7289ad12049e16d73af7491a17c928e9	f	\\x6b341557b2cb1a8eab12c0e6923980039423c2067174ff65bbf4cfc7	\N	3681818181818181	\N	\N	\N
25	25	0	addr_test1vqh4pyf6xn2kjx9rvnaqjkgdstm4jyazclt4edn9q4k3xegmnaysw	\\x602f50913a34d56918a364fa09590d82f75913a2c7d75cb665056d1365	f	\\x2f50913a34d56918a364fa09590d82f75913a2c7d75cb665056d1365	\N	3681818181818181	\N	\N	\N
26	26	0	addr_test1vpxpdh2jq7mc2lsy5ktdd6qms0xtrm4uhuqzmkhx3lthrvgu2prng	\\x604c16dd5207b7857e04a596d6e81b83ccb1eebcbf002ddae68fd771b1	f	\\x4c16dd5207b7857e04a596d6e81b83ccb1eebcbf002ddae68fd771b1	\N	3681818181818181	\N	\N	\N
27	27	0	addr_test1qr6ndrfussukyqsafkr24r42t6wm7tr26qleqh32r78lf3yp0geustjclvflm093dlnwp3u4xvplp9hpxh7rha78xy5steltyc	\\x00f5368d3c843962021d4d86aa8eaa5e9dbf2c6ad03f905e2a1f8ff4c4817a33c82e58fb13fdbcb16fe6e0c7953303f096e135fc3bf7c73129	f	\\xf5368d3c843962021d4d86aa8eaa5e9dbf2c6ad03f905e2a1f8ff4c4	\N	3681818181818181	\N	\N	\N
28	28	0	addr_test1qqzh5w73wm7vncf85aqy2hdhk4ea9ckcd05k0hhp7rc6kz5m2kt84e45tq6une8cy4fphgdt3hzuzdyck8m7dezm7qgslf6j83	\\x00057a3bd176fcc9e127a740455db7b573d2e2d86be967dee1f0f1ab0a9b55967ae6b45835c9e4f825521ba1ab8dc5c13498b1f7e6e45bf011	f	\\x057a3bd176fcc9e127a740455db7b573d2e2d86be967dee1f0f1ab0a	\N	3681818181818190	\N	\N	\N
29	29	0	addr_test1qqv0066m7vxytwvarnrp344pz36nzrtk75rcuzmv9wzc9ptfr7f5jpe9tq5c3h63sjpc328z4463ngth55vlv3xf3p8qr9r6g9	\\x0018f7eb5bf30c45b99d1cc618d6a11475310d76f5078e0b6c2b858285691f93490725582988df51848388a8e2ad7519a177a519f644c9884e	f	\\x18f7eb5bf30c45b99d1cc618d6a11475310d76f5078e0b6c2b858285	\N	3681818181818181	\N	\N	\N
30	30	0	addr_test1qrstngenk93f08mxw90wxm9pm95cugwtmw6klvxu4jj4gdfn92uzw692v6adgg7ccd3sey03sm8frfcgzatnuduzvlgq47zrhv	\\x00e0b9a333b162979f66715ee36ca1d9698e21cbdbb56fb0dcaca55435332ab82768aa66bad423d8c3630c91f186ce91a70817573e378267d0	f	\\xe0b9a333b162979f66715ee36ca1d9698e21cbdbb56fb0dcaca55435	\N	3681818181818181	\N	\N	\N
31	31	0	addr_test1vqs48y8f4y3fdm996fr76uy59y9dw3lts37n7z95qsk7vjcxp6qv8	\\x60215390e9a92296eca5d247ed7094290ad747eb847d3f08b4042de64b	f	\\x215390e9a92296eca5d247ed7094290ad747eb847d3f08b4042de64b	\N	3681818181818181	\N	\N	\N
32	32	0	addr_test1qzmw5cg76ucrpzu9y0gznhndv2wdmcflhl9rj6f3rtk2mt26p0dy7za0t02eywgl4e9huvpk56ktflql9w0zvuesmyeqewty3h	\\x00b6ea611ed730308b8523d029de6d629cdde13fbfca3969311aecadad5a0bda4f0baf5bd592391fae4b7e3036a6acb4fc1f2b9e267330d932	f	\\xb6ea611ed730308b8523d029de6d629cdde13fbfca3969311aecadad	\N	3681818181818181	\N	\N	\N
33	33	0	addr_test1qzswjsanpr7xqw6v38usk32qylgms6gc22en52fp795rwflvcp8ztm4mkwplq8k4djyf8ntx7f7hqnjagf44fpu6tm8swf0f6f	\\x00a0e943b308fc603b4c89f90b454027d1b8691852b33a2921f1683727ecc04e25eebbb383f01ed56c8893cd66f27d704e5d426b54879a5ecf	f	\\xa0e943b308fc603b4c89f90b454027d1b8691852b33a2921f1683727	\N	3681818181818181	\N	\N	\N
34	35	0	addr_test1qqh4pyf6xn2kjx9rvnaqjkgdstm4jyazclt4edn9q4k3xetq6n4wrcgk2v8wnmn89jsp4rdx20n9q0qsr42ceppruf7qehnnle	\\x002f50913a34d56918a364fa09590d82f75913a2c7d75cb665056d136560d4eae1e116530ee9ee672ca01a8da653e6503c101d558c8423e27c	f	\\x2f50913a34d56918a364fa09590d82f75913a2c7d75cb665056d1365	13	300000000	\N	\N	\N
35	35	1	addr_test1vqh4pyf6xn2kjx9rvnaqjkgdstm4jyazclt4edn9q4k3xegmnaysw	\\x602f50913a34d56918a364fa09590d82f75913a2c7d75cb665056d1365	f	\\x2f50913a34d56918a364fa09590d82f75913a2c7d75cb665056d1365	\N	3681817881651228	\N	\N	\N
36	36	0	addr_test1qq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaynp9gxc0j3vxgyh73gxs5dh0tp5gwgrg6zq2apuzt40gls3hhlj3	\\x00232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f49309506c3e5161904bfa283428dbbd61a21c81a34202ba1e09757a3f	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	12	600000000	\N	\N	\N
37	36	1	addr_test1vq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaqekncyn	\\x60232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	\N	3681817581651237	\N	\N	\N
38	37	0	addr_test1qq34u8s6dx2up8v3rcmnmx6qr3qjfak269fafsnxkgsssw9gjfsahss8nuddrnjkhgef87yfwecynknrddrcd6u8uklqxz47q8	\\x00235e1e1a6995c09d911e373d9b401c4124f6cad153d4c266b2210838a89261dbc2079f1ad1ce56ba3293f889767049da636b4786eb87e5be	f	\\x235e1e1a6995c09d911e373d9b401c4124f6cad153d4c266b2210838	20	300000000	\N	\N	\N
39	37	1	addr_test1vq34u8s6dx2up8v3rcmnmx6qr3qjfak269fafsnxkgssswq4tjkz7	\\x60235e1e1a6995c09d911e373d9b401c4124f6cad153d4c266b2210838	f	\\x235e1e1a6995c09d911e373d9b401c4124f6cad153d4c266b2210838	\N	3681817881651228	\N	\N	\N
40	38	0	addr_test1qpw2vfg5v7umxhznq557xunctzdvn23lmylp5uxr62m3mywq6nkjcsrxz3j7g0szntpj2aay3j2nnccqcew24yqege7s574xd4	\\x005ca6251467b9b35c530529e37278589ac9aa3fd93e1a70c3d2b71d91c0d4ed2c40661465e43e029ac32577a48c9539e300c65caa9019467d	f	\\x5ca6251467b9b35c530529e37278589ac9aa3fd93e1a70c3d2b71d91	17	500000000	\N	\N	\N
41	38	1	addr_test1vpw2vfg5v7umxhznq557xunctzdvn23lmylp5uxr62m3mygvdgyjv	\\x605ca6251467b9b35c530529e37278589ac9aa3fd93e1a70c3d2b71d91	f	\\x5ca6251467b9b35c530529e37278589ac9aa3fd93e1a70c3d2b71d91	\N	3681817681651228	\N	\N	\N
42	39	0	addr_test1qrvs95e8ymkapdg4qlknwdaezsx0klk34hkdnvc0reqv68the8fjynlzzahdjq8wghp5ar5ll4q9qt97r63l0vkyn35skfe6fa	\\x00d902d32726edd0b51507ed3737b9140cfb7ed1adecd9b30f1e40cd1d77c9d3224fe2176ed900ee45c34e8e9ffd40502cbe1ea3f7b2c49c69	f	\\xd902d32726edd0b51507ed3737b9140cfb7ed1adecd9b30f1e40cd1d	18	500000000	\N	\N	\N
43	39	1	addr_test1vrvs95e8ymkapdg4qlknwdaezsx0klk34hkdnvc0reqv68gkwsa9e	\\x60d902d32726edd0b51507ed3737b9140cfb7ed1adecd9b30f1e40cd1d	f	\\xd902d32726edd0b51507ed3737b9140cfb7ed1adecd9b30f1e40cd1d	\N	3681817681651228	\N	\N	\N
44	40	0	addr_test1qpqwr6a4fqkq9dt97r3hvjrslyf9fkpjdwr8x5y9p97hpa3gzjadqt35zy2xckcv0wmx255pgt2me87s9caxwtp6udaq83yenw	\\x0040e1ebb5482c02b565f0e3764870f91254d8326b86735085097d70f62814bad02e3411146c5b0c7bb665528142d5bc9fd02e3a672c3ae37a	f	\\x40e1ebb5482c02b565f0e3764870f91254d8326b86735085097d70f6	19	500000000	\N	\N	\N
45	40	1	addr_test1vpqwr6a4fqkq9dt97r3hvjrslyf9fkpjdwr8x5y9p97hpashjtpna	\\x6040e1ebb5482c02b565f0e3764870f91254d8326b86735085097d70f6	f	\\x40e1ebb5482c02b565f0e3764870f91254d8326b86735085097d70f6	\N	3681817681651228	\N	\N	\N
46	41	0	addr_test1qrlgq892z9ywq3g38y05yplvcmanlrqtk5qu5vy790d4ky789lzm2gm53xmfh7zxecgjcryd03gr6l077yltpz5yjdfqetgz7u	\\x00fe801caa1148e04511391f4207ecc6fb3f8c0bb501ca309e2bdb5b13c72fc5b5237489b69bf846ce112c0c8d7c503d7dfef13eb08a849352	f	\\xfe801caa1148e04511391f4207ecc6fb3f8c0bb501ca309e2bdb5b13	14	500000000	\N	\N	\N
47	41	1	addr_test1vrlgq892z9ywq3g38y05yplvcmanlrqtk5qu5vy790d4kycrxvc6d	\\x60fe801caa1148e04511391f4207ecc6fb3f8c0bb501ca309e2bdb5b13	f	\\xfe801caa1148e04511391f4207ecc6fb3f8c0bb501ca309e2bdb5b13	\N	3681817681651228	\N	\N	\N
48	42	0	addr_test1qpxpdh2jq7mc2lsy5ktdd6qms0xtrm4uhuqzmkhx3lthrvvnjddnat0ptzdrxwdl293qe0eafzes2aegmxtucsvdmx2qv9c0f9	\\x004c16dd5207b7857e04a596d6e81b83ccb1eebcbf002ddae68fd771b193935b3eade1589a3339bf51620cbf3d48b3057728d997cc418dd994	f	\\x4c16dd5207b7857e04a596d6e81b83ccb1eebcbf002ddae68fd771b1	15	500000000	\N	\N	\N
49	42	1	addr_test1vpxpdh2jq7mc2lsy5ktdd6qms0xtrm4uhuqzmkhx3lthrvgu2prng	\\x604c16dd5207b7857e04a596d6e81b83ccb1eebcbf002ddae68fd771b1	f	\\x4c16dd5207b7857e04a596d6e81b83ccb1eebcbf002ddae68fd771b1	\N	3681817681651228	\N	\N	\N
50	43	0	addr_test1qqs48y8f4y3fdm996fr76uy59y9dw3lts37n7z95qsk7vjm534969ydq9g2al8e65ann6skj8dhjpdjj2a3xdse95p5qe4qlpq	\\x00215390e9a92296eca5d247ed7094290ad747eb847d3f08b4042de64b748d4ba291a02a15df9f3aa7673d42d23b6f20b652576266c325a068	f	\\x215390e9a92296eca5d247ed7094290ad747eb847d3f08b4042de64b	16	500000000	\N	\N	\N
51	43	1	addr_test1vqs48y8f4y3fdm996fr76uy59y9dw3lts37n7z95qsk7vjcxp6qv8	\\x60215390e9a92296eca5d247ed7094290ad747eb847d3f08b4042de64b	f	\\x215390e9a92296eca5d247ed7094290ad747eb847d3f08b4042de64b	\N	3681817681651228	\N	\N	\N
52	44	0	addr_test1qzyyk2heuelfa7528qkjk2lncj3ynu63xk6h4hkhlehrfc0l9euukdruvh305yjuachqnhgc0ls6teuwahcv9fgamqpqthlzeq	\\x00884b2af9e67e9efa8a382d2b2bf3c4a249f35135b57aded7fe6e34e1ff2e79cb347c65e2fa125cee2e09dd187fe1a5e78eedf0c2a51dd802	f	\\x884b2af9e67e9efa8a382d2b2bf3c4a249f35135b57aded7fe6e34e1	21	500000000	\N	\N	\N
53	44	1	addr_test1vzyyk2heuelfa7528qkjk2lncj3ynu63xk6h4hkhlehrfcgadvgt8	\\x60884b2af9e67e9efa8a382d2b2bf3c4a249f35135b57aded7fe6e34e1	f	\\x884b2af9e67e9efa8a382d2b2bf3c4a249f35135b57aded7fe6e34e1	\N	3681817681651228	\N	\N	\N
54	45	0	addr_test1qr3sj8g858g0z3mcma4v73x4jyul5jsmzw43rtym36t5k9c5wulhl6ywahh5de7de9l4nnfrf3knlrakavdx8mykltwsnlte2u	\\x00e3091d07a1d0f14778df6acf44d59139fa4a1b13ab11ac9b8e974b1714773f7fe88eedef46e7cdc97f59cd234c6d3f8fb6eb1a63ec96fadd	f	\\xe3091d07a1d0f14778df6acf44d59139fa4a1b13ab11ac9b8e974b17	22	200000000	\N	\N	\N
55	45	1	addr_test1vr3sj8g858g0z3mcma4v73x4jyul5jsmzw43rtym36t5k9cufpa3u	\\x60e3091d07a1d0f14778df6acf44d59139fa4a1b13ab11ac9b8e974b17	f	\\xe3091d07a1d0f14778df6acf44d59139fa4a1b13ab11ac9b8e974b17	\N	3681817981651228	\N	\N	\N
56	46	0	addr_test1vq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaqekncyn	\\x60232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	\N	3681817579473240	\N	\N	\N
57	47	0	addr_test1vqh4pyf6xn2kjx9rvnaqjkgdstm4jyazclt4edn9q4k3xegmnaysw	\\x602f50913a34d56918a364fa09590d82f75913a2c7d75cb665056d1365	f	\\x2f50913a34d56918a364fa09590d82f75913a2c7d75cb665056d1365	\N	3681817879473231	\N	\N	\N
58	48	0	addr_test1vq34u8s6dx2up8v3rcmnmx6qr3qjfak269fafsnxkgssswq4tjkz7	\\x60235e1e1a6995c09d911e373d9b401c4124f6cad153d4c266b2210838	f	\\x235e1e1a6995c09d911e373d9b401c4124f6cad153d4c266b2210838	\N	3681817879473231	\N	\N	\N
59	49	0	addr_test1vqs48y8f4y3fdm996fr76uy59y9dw3lts37n7z95qsk7vjcxp6qv8	\\x60215390e9a92296eca5d247ed7094290ad747eb847d3f08b4042de64b	f	\\x215390e9a92296eca5d247ed7094290ad747eb847d3f08b4042de64b	\N	3681817679473231	\N	\N	\N
60	50	0	addr_test1vzyyk2heuelfa7528qkjk2lncj3ynu63xk6h4hkhlehrfcgadvgt8	\\x60884b2af9e67e9efa8a382d2b2bf3c4a249f35135b57aded7fe6e34e1	f	\\x884b2af9e67e9efa8a382d2b2bf3c4a249f35135b57aded7fe6e34e1	\N	3681817679473231	\N	\N	\N
61	51	0	addr_test1vrvs95e8ymkapdg4qlknwdaezsx0klk34hkdnvc0reqv68gkwsa9e	\\x60d902d32726edd0b51507ed3737b9140cfb7ed1adecd9b30f1e40cd1d	f	\\xd902d32726edd0b51507ed3737b9140cfb7ed1adecd9b30f1e40cd1d	\N	3681817679473231	\N	\N	\N
62	52	0	addr_test1vpw2vfg5v7umxhznq557xunctzdvn23lmylp5uxr62m3mygvdgyjv	\\x605ca6251467b9b35c530529e37278589ac9aa3fd93e1a70c3d2b71d91	f	\\x5ca6251467b9b35c530529e37278589ac9aa3fd93e1a70c3d2b71d91	\N	3681817679473231	\N	\N	\N
63	53	0	addr_test1vpxpdh2jq7mc2lsy5ktdd6qms0xtrm4uhuqzmkhx3lthrvgu2prng	\\x604c16dd5207b7857e04a596d6e81b83ccb1eebcbf002ddae68fd771b1	f	\\x4c16dd5207b7857e04a596d6e81b83ccb1eebcbf002ddae68fd771b1	\N	3681817679473231	\N	\N	\N
64	54	0	addr_test1vrlgq892z9ywq3g38y05yplvcmanlrqtk5qu5vy790d4kycrxvc6d	\\x60fe801caa1148e04511391f4207ecc6fb3f8c0bb501ca309e2bdb5b13	f	\\xfe801caa1148e04511391f4207ecc6fb3f8c0bb501ca309e2bdb5b13	\N	3681817679473231	\N	\N	\N
65	55	0	addr_test1vpqwr6a4fqkq9dt97r3hvjrslyf9fkpjdwr8x5y9p97hpashjtpna	\\x6040e1ebb5482c02b565f0e3764870f91254d8326b86735085097d70f6	f	\\x40e1ebb5482c02b565f0e3764870f91254d8326b86735085097d70f6	\N	3681817679473231	\N	\N	\N
66	56	0	addr_test1vr3sj8g858g0z3mcma4v73x4jyul5jsmzw43rtym36t5k9cufpa3u	\\x60e3091d07a1d0f14778df6acf44d59139fa4a1b13ab11ac9b8e974b17	f	\\xe3091d07a1d0f14778df6acf44d59139fa4a1b13ab11ac9b8e974b17	\N	3681817979473231	\N	\N	\N
67	57	0	addr_test1vq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaqekncyn	\\x60232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	\N	3681817579293923	\N	\N	\N
68	58	0	addr_test1vqh4pyf6xn2kjx9rvnaqjkgdstm4jyazclt4edn9q4k3xegmnaysw	\\x602f50913a34d56918a364fa09590d82f75913a2c7d75cb665056d1365	f	\\x2f50913a34d56918a364fa09590d82f75913a2c7d75cb665056d1365	\N	3681817879293914	\N	\N	\N
69	59	0	addr_test1vq34u8s6dx2up8v3rcmnmx6qr3qjfak269fafsnxkgssswq4tjkz7	\\x60235e1e1a6995c09d911e373d9b401c4124f6cad153d4c266b2210838	f	\\x235e1e1a6995c09d911e373d9b401c4124f6cad153d4c266b2210838	\N	3681817879293914	\N	\N	\N
70	60	0	addr_test1vpw2vfg5v7umxhznq557xunctzdvn23lmylp5uxr62m3mygvdgyjv	\\x605ca6251467b9b35c530529e37278589ac9aa3fd93e1a70c3d2b71d91	f	\\x5ca6251467b9b35c530529e37278589ac9aa3fd93e1a70c3d2b71d91	\N	3681817679293914	\N	\N	\N
71	61	0	addr_test1vpqwr6a4fqkq9dt97r3hvjrslyf9fkpjdwr8x5y9p97hpashjtpna	\\x6040e1ebb5482c02b565f0e3764870f91254d8326b86735085097d70f6	f	\\x40e1ebb5482c02b565f0e3764870f91254d8326b86735085097d70f6	\N	3681817679293914	\N	\N	\N
72	62	0	addr_test1vrlgq892z9ywq3g38y05yplvcmanlrqtk5qu5vy790d4kycrxvc6d	\\x60fe801caa1148e04511391f4207ecc6fb3f8c0bb501ca309e2bdb5b13	f	\\xfe801caa1148e04511391f4207ecc6fb3f8c0bb501ca309e2bdb5b13	\N	3681817679293914	\N	\N	\N
73	63	0	addr_test1vr3sj8g858g0z3mcma4v73x4jyul5jsmzw43rtym36t5k9cufpa3u	\\x60e3091d07a1d0f14778df6acf44d59139fa4a1b13ab11ac9b8e974b17	f	\\xe3091d07a1d0f14778df6acf44d59139fa4a1b13ab11ac9b8e974b17	\N	3681817979293914	\N	\N	\N
74	64	0	addr_test1vzyyk2heuelfa7528qkjk2lncj3ynu63xk6h4hkhlehrfcgadvgt8	\\x60884b2af9e67e9efa8a382d2b2bf3c4a249f35135b57aded7fe6e34e1	f	\\x884b2af9e67e9efa8a382d2b2bf3c4a249f35135b57aded7fe6e34e1	\N	3681817679293914	\N	\N	\N
75	65	0	addr_test1vqs48y8f4y3fdm996fr76uy59y9dw3lts37n7z95qsk7vjcxp6qv8	\\x60215390e9a92296eca5d247ed7094290ad747eb847d3f08b4042de64b	f	\\x215390e9a92296eca5d247ed7094290ad747eb847d3f08b4042de64b	\N	3681817679293914	\N	\N	\N
76	66	0	addr_test1vpxpdh2jq7mc2lsy5ktdd6qms0xtrm4uhuqzmkhx3lthrvgu2prng	\\x604c16dd5207b7857e04a596d6e81b83ccb1eebcbf002ddae68fd771b1	f	\\x4c16dd5207b7857e04a596d6e81b83ccb1eebcbf002ddae68fd771b1	\N	3681817679293914	\N	\N	\N
77	67	0	addr_test1vrvs95e8ymkapdg4qlknwdaezsx0klk34hkdnvc0reqv68gkwsa9e	\\x60d902d32726edd0b51507ed3737b9140cfb7ed1adecd9b30f1e40cd1d	f	\\xd902d32726edd0b51507ed3737b9140cfb7ed1adecd9b30f1e40cd1d	\N	3681817679293914	\N	\N	\N
89	79	0	addr_test1qr6ndrfussukyqsafkr24r42t6wm7tr26qleqh32r78lf3yp0geustjclvflm093dlnwp3u4xvplp9hpxh7rha78xy5steltyc	\\x00f5368d3c843962021d4d86aa8eaa5e9dbf2c6ad03f905e2a1f8ff4c4817a33c82e58fb13fdbcb16fe6e0c7953303f096e135fc3bf7c73129	f	\\xf5368d3c843962021d4d86aa8eaa5e9dbf2c6ad03f905e2a1f8ff4c4	6	3681818181637632	\N	\N	\N
90	80	0	addr_test1qp4ng92hkt934r4tztqwdy3esqpegg7zqechflm9h06vl3cv7zjwc57wslwywv3ae4egntgjqj0pd4e67ay3597f9r5sk9llf4	\\x006b341557b2cb1a8eab12c0e6923980039423c2067174ff65bbf4cfc70cf0a4ec53ce87dc47323dcd7289ad12049e16d73af7491a17c928e9	f	\\x6b341557b2cb1a8eab12c0e6923980039423c2067174ff65bbf4cfc7	5	3681818181637632	\N	\N	\N
91	81	0	addr_test1qrstngenk93f08mxw90wxm9pm95cugwtmw6klvxu4jj4gdfn92uzw692v6adgg7ccd3sey03sm8frfcgzatnuduzvlgq47zrhv	\\x00e0b9a333b162979f66715ee36ca1d9698e21cbdbb56fb0dcaca55435332ab82768aa66bad423d8c3630c91f186ce91a70817573e378267d0	f	\\xe0b9a333b162979f66715ee36ca1d9698e21cbdbb56fb0dcaca55435	9	3681818181637632	\N	\N	\N
92	82	0	addr_test1qpcrx0xxnz77sg2u065ljkq7kuuhwa4hsclmt9tk9fdhfxec8fczl4hukcwptg49htghcv5qkrat6rh3w5zh4r0nd55scekdnn	\\x0070333cc698bde8215c7ea9f9581eb7397776b7863fb595762a5b749b383a702fd6fcb61c15a2a5bad17c3280b0fabd0ef175057a8df36d29	f	\\x70333cc698bde8215c7ea9f9581eb7397776b7863fb595762a5b749b	4	3681818181637632	\N	\N	\N
93	83	0	addr_test1qzswjsanpr7xqw6v38usk32qylgms6gc22en52fp795rwflvcp8ztm4mkwplq8k4djyf8ntx7f7hqnjagf44fpu6tm8swf0f6f	\\x00a0e943b308fc603b4c89f90b454027d1b8691852b33a2921f1683727ecc04e25eebbb383f01ed56c8893cd66f27d704e5d426b54879a5ecf	f	\\xa0e943b308fc603b4c89f90b454027d1b8691852b33a2921f1683727	11	3681818181637632	\N	\N	\N
94	84	0	addr_test1qqv0066m7vxytwvarnrp344pz36nzrtk75rcuzmv9wzc9ptfr7f5jpe9tq5c3h63sjpc328z4463ngth55vlv3xf3p8qr9r6g9	\\x0018f7eb5bf30c45b99d1cc618d6a11475310d76f5078e0b6c2b858285691f93490725582988df51848388a8e2ad7519a177a519f644c9884e	f	\\x18f7eb5bf30c45b99d1cc618d6a11475310d76f5078e0b6c2b858285	8	3681818181637632	\N	\N	\N
95	85	0	addr_test1qqn08wqz06gjc6tywjp0wgggd3r25jkasgmrfjydqhdw2wnfz5sd8k7afna9cd6gn97rljuqx35a7muymhfeuujna5psswtz37	\\x0026f3b8027e912c69647482f721086c46aa4add823634c88d05dae53a691520d3dbdd4cfa5c3748997c3fcb803469df6f84ddd39e7253ed03	f	\\x26f3b8027e912c69647482f721086c46aa4add823634c88d05dae53a	2	3681818181637632	\N	\N	\N
96	86	0	addr_test1qzmw5cg76ucrpzu9y0gznhndv2wdmcflhl9rj6f3rtk2mt26p0dy7za0t02eywgl4e9huvpk56ktflql9w0zvuesmyeqewty3h	\\x00b6ea611ed730308b8523d029de6d629cdde13fbfca3969311aecadad5a0bda4f0baf5bd592391fae4b7e3036a6acb4fc1f2b9e267330d932	f	\\xb6ea611ed730308b8523d029de6d629cdde13fbfca3969311aecadad	10	3681818181637632	\N	\N	\N
97	87	0	addr_test1qqzh5w73wm7vncf85aqy2hdhk4ea9ckcd05k0hhp7rc6kz5m2kt84e45tq6une8cy4fphgdt3hzuzdyck8m7dezm7qgslf6j83	\\x00057a3bd176fcc9e127a740455db7b573d2e2d86be967dee1f0f1ab0a9b55967ae6b45835c9e4f825521ba1ab8dc5c13498b1f7e6e45bf011	f	\\x057a3bd176fcc9e127a740455db7b573d2e2d86be967dee1f0f1ab0a	7	3681818181637641	\N	\N	\N
98	88	0	addr_test1qrhdqh79t95n5uahxazc3mw9j27msshgrjz3x55ye6k9hks9qwllsq2tuaqru6x4qua8gtx2xwsckmcfdxytzdmhm6tquu9z3q	\\x00eed05fc559693a73b7374588edc592bdb842e81c85135284ceac5bda0503bff8014be7403e68d5073a742cca33a18b6f096988b13777de96	f	\\xeed05fc559693a73b7374588edc592bdb842e81c85135284ceac5bda	3	3681818181637632	\N	\N	\N
99	89	0	addr_test1qrje7dnzk37f4p6xjpr27mr6xxuxfrkyhujk0pfgr9x3saxcvjxkt9dr477xkugnc9jlqtqyaq83er2fxc0qjjsjf7tq86569p	\\x00e59f3662b47c9a87469046af6c7a31b8648ec4bf25678528194d1874d8648d6595a3afbc6b7113c165f02c04e80f1c8d49361e094a124f96	f	\\xe59f3662b47c9a87469046af6c7a31b8648ec4bf25678528194d1874	1	3681818181637632	\N	\N	\N
100	90	0	addr_test1qr6ndrfussukyqsafkr24r42t6wm7tr26qleqh32r78lf3yp0geustjclvflm093dlnwp3u4xvplp9hpxh7rha78xy5steltyc	\\x00f5368d3c843962021d4d86aa8eaa5e9dbf2c6ad03f905e2a1f8ff4c4817a33c82e58fb13fdbcb16fe6e0c7953303f096e135fc3bf7c73129	f	\\xf5368d3c843962021d4d86aa8eaa5e9dbf2c6ad03f905e2a1f8ff4c4	6	3681818181446391	\N	\N	\N
101	91	0	addr_test1qrstngenk93f08mxw90wxm9pm95cugwtmw6klvxu4jj4gdfn92uzw692v6adgg7ccd3sey03sm8frfcgzatnuduzvlgq47zrhv	\\x00e0b9a333b162979f66715ee36ca1d9698e21cbdbb56fb0dcaca55435332ab82768aa66bad423d8c3630c91f186ce91a70817573e378267d0	f	\\xe0b9a333b162979f66715ee36ca1d9698e21cbdbb56fb0dcaca55435	9	3681818181446391	\N	\N	\N
102	92	0	addr_test1qp4ng92hkt934r4tztqwdy3esqpegg7zqechflm9h06vl3cv7zjwc57wslwywv3ae4egntgjqj0pd4e67ay3597f9r5sk9llf4	\\x006b341557b2cb1a8eab12c0e6923980039423c2067174ff65bbf4cfc70cf0a4ec53ce87dc47323dcd7289ad12049e16d73af7491a17c928e9	f	\\x6b341557b2cb1a8eab12c0e6923980039423c2067174ff65bbf4cfc7	5	3681818181446391	\N	\N	\N
103	93	0	addr_test1qrje7dnzk37f4p6xjpr27mr6xxuxfrkyhujk0pfgr9x3saxcvjxkt9dr477xkugnc9jlqtqyaq83er2fxc0qjjsjf7tq86569p	\\x00e59f3662b47c9a87469046af6c7a31b8648ec4bf25678528194d1874d8648d6595a3afbc6b7113c165f02c04e80f1c8d49361e094a124f96	f	\\xe59f3662b47c9a87469046af6c7a31b8648ec4bf25678528194d1874	1	3681818181443575	\N	\N	\N
104	94	0	addr_test1qzswjsanpr7xqw6v38usk32qylgms6gc22en52fp795rwflvcp8ztm4mkwplq8k4djyf8ntx7f7hqnjagf44fpu6tm8swf0f6f	\\x00a0e943b308fc603b4c89f90b454027d1b8691852b33a2921f1683727ecc04e25eebbb383f01ed56c8893cd66f27d704e5d426b54879a5ecf	f	\\xa0e943b308fc603b4c89f90b454027d1b8691852b33a2921f1683727	11	3681818181443619	\N	\N	\N
105	95	0	addr_test1qpcrx0xxnz77sg2u065ljkq7kuuhwa4hsclmt9tk9fdhfxec8fczl4hukcwptg49htghcv5qkrat6rh3w5zh4r0nd55scekdnn	\\x0070333cc698bde8215c7ea9f9581eb7397776b7863fb595762a5b749b383a702fd6fcb61c15a2a5bad17c3280b0fabd0ef175057a8df36d29	f	\\x70333cc698bde8215c7ea9f9581eb7397776b7863fb595762a5b749b	4	3681818181443619	\N	\N	\N
106	96	0	addr_test1qzmw5cg76ucrpzu9y0gznhndv2wdmcflhl9rj6f3rtk2mt26p0dy7za0t02eywgl4e9huvpk56ktflql9w0zvuesmyeqewty3h	\\x00b6ea611ed730308b8523d029de6d629cdde13fbfca3969311aecadad5a0bda4f0baf5bd592391fae4b7e3036a6acb4fc1f2b9e267330d932	f	\\xb6ea611ed730308b8523d029de6d629cdde13fbfca3969311aecadad	10	3681818181443619	\N	\N	\N
107	97	0	addr_test1qrhdqh79t95n5uahxazc3mw9j27msshgrjz3x55ye6k9hks9qwllsq2tuaqru6x4qua8gtx2xwsckmcfdxytzdmhm6tquu9z3q	\\x00eed05fc559693a73b7374588edc592bdb842e81c85135284ceac5bda0503bff8014be7403e68d5073a742cca33a18b6f096988b13777de96	f	\\xeed05fc559693a73b7374588edc592bdb842e81c85135284ceac5bda	3	3681818181443619	\N	\N	\N
108	98	0	addr_test1qqv0066m7vxytwvarnrp344pz36nzrtk75rcuzmv9wzc9ptfr7f5jpe9tq5c3h63sjpc328z4463ngth55vlv3xf3p8qr9r6g9	\\x0018f7eb5bf30c45b99d1cc618d6a11475310d76f5078e0b6c2b858285691f93490725582988df51848388a8e2ad7519a177a519f644c9884e	f	\\x18f7eb5bf30c45b99d1cc618d6a11475310d76f5078e0b6c2b858285	8	3681818181443619	\N	\N	\N
109	99	0	addr_test1qqn08wqz06gjc6tywjp0wgggd3r25jkasgmrfjydqhdw2wnfz5sd8k7afna9cd6gn97rljuqx35a7muymhfeuujna5psswtz37	\\x0026f3b8027e912c69647482f721086c46aa4add823634c88d05dae53a691520d3dbdd4cfa5c3748997c3fcb803469df6f84ddd39e7253ed03	f	\\x26f3b8027e912c69647482f721086c46aa4add823634c88d05dae53a	2	3681818181443619	\N	\N	\N
110	100	0	addr_test1qqzh5w73wm7vncf85aqy2hdhk4ea9ckcd05k0hhp7rc6kz5m2kt84e45tq6une8cy4fphgdt3hzuzdyck8m7dezm7qgslf6j83	\\x00057a3bd176fcc9e127a740455db7b573d2e2d86be967dee1f0f1ab0a9b55967ae6b45835c9e4f825521ba1ab8dc5c13498b1f7e6e45bf011	f	\\x057a3bd176fcc9e127a740455db7b573d2e2d86be967dee1f0f1ab0a	7	3681818181443584	\N	\N	\N
111	101	0	addr_test1qr6ndrfussukyqsafkr24r42t6wm7tr26qleqh32r78lf3yp0geustjclvflm093dlnwp3u4xvplp9hpxh7rha78xy5steltyc	\\x00f5368d3c843962021d4d86aa8eaa5e9dbf2c6ad03f905e2a1f8ff4c4817a33c82e58fb13fdbcb16fe6e0c7953303f096e135fc3bf7c73129	f	\\xf5368d3c843962021d4d86aa8eaa5e9dbf2c6ad03f905e2a1f8ff4c4	6	3681818181265842	\N	\N	\N
112	102	0	addr_test1qrstngenk93f08mxw90wxm9pm95cugwtmw6klvxu4jj4gdfn92uzw692v6adgg7ccd3sey03sm8frfcgzatnuduzvlgq47zrhv	\\x00e0b9a333b162979f66715ee36ca1d9698e21cbdbb56fb0dcaca55435332ab82768aa66bad423d8c3630c91f186ce91a70817573e378267d0	f	\\xe0b9a333b162979f66715ee36ca1d9698e21cbdbb56fb0dcaca55435	9	3681818181265842	\N	\N	\N
113	103	0	addr_test1qrje7dnzk37f4p6xjpr27mr6xxuxfrkyhujk0pfgr9x3saxcvjxkt9dr477xkugnc9jlqtqyaq83er2fxc0qjjsjf7tq86569p	\\x00e59f3662b47c9a87469046af6c7a31b8648ec4bf25678528194d1874d8648d6595a3afbc6b7113c165f02c04e80f1c8d49361e094a124f96	f	\\xe59f3662b47c9a87469046af6c7a31b8648ec4bf25678528194d1874	1	3681818181263026	\N	\N	\N
114	104	0	addr_test1qqzh5w73wm7vncf85aqy2hdhk4ea9ckcd05k0hhp7rc6kz5m2kt84e45tq6une8cy4fphgdt3hzuzdyck8m7dezm7qgslf6j83	\\x00057a3bd176fcc9e127a740455db7b573d2e2d86be967dee1f0f1ab0a9b55967ae6b45835c9e4f825521ba1ab8dc5c13498b1f7e6e45bf011	f	\\x057a3bd176fcc9e127a740455db7b573d2e2d86be967dee1f0f1ab0a	7	3681818181263035	\N	\N	\N
115	105	0	addr_test1vq34u8s6dx2up8v3rcmnmx6qr3qjfak269fafsnxkgssswq4tjkz7	\\x60235e1e1a6995c09d911e373d9b401c4124f6cad153d4c266b2210838	f	\\x235e1e1a6995c09d911e373d9b401c4124f6cad153d4c266b2210838	\N	3681817879109669	\N	\N	\N
116	106	0	addr_test1vqh4pyf6xn2kjx9rvnaqjkgdstm4jyazclt4edn9q4k3xegmnaysw	\\x602f50913a34d56918a364fa09590d82f75913a2c7d75cb665056d1365	f	\\x2f50913a34d56918a364fa09590d82f75913a2c7d75cb665056d1365	\N	3681817879109669	\N	\N	\N
117	107	0	addr_test1vqs48y8f4y3fdm996fr76uy59y9dw3lts37n7z95qsk7vjcxp6qv8	\\x60215390e9a92296eca5d247ed7094290ad747eb847d3f08b4042de64b	f	\\x215390e9a92296eca5d247ed7094290ad747eb847d3f08b4042de64b	\N	3681817679109669	\N	\N	\N
118	108	0	addr_test1vzyyk2heuelfa7528qkjk2lncj3ynu63xk6h4hkhlehrfcgadvgt8	\\x60884b2af9e67e9efa8a382d2b2bf3c4a249f35135b57aded7fe6e34e1	f	\\x884b2af9e67e9efa8a382d2b2bf3c4a249f35135b57aded7fe6e34e1	\N	3681817679109669	\N	\N	\N
119	109	0	addr_test1wpnlxv2xv9a9ucvnvzqakwepzl9ltx7jzgm53av2e9ncv4sysemm8	\\x7067f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	t	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	\N	100000000	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	\N	\N
120	109	1	addr_test1vq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaqekncyn	\\x60232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	\N	3681817479126574	\N	\N	\N
121	110	0	addr_test1vq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaqekncyn	\\x60232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	\N	99828910	\N	\N	\N
122	111	0	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	\\x702618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	100000000	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	2	\N
123	111	1	addr_test1vq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaqekncyn	\\x60232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	\N	3681817378960501	\N	\N	\N
124	112	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	2
125	112	1	addr_test1vq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaqekncyn	\\x60232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	\N	3681817278790116	\N	\N	\N
126	113	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	3
127	113	1	addr_test1vq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaqekncyn	\\x60232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	\N	3681817178622327	\N	\N	\N
128	114	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	1
129	114	1	addr_test1vq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaqekncyn	\\x60232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	\N	3681817078455682	\N	\N	\N
130	115	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	4
131	115	1	addr_test1vq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaqekncyn	\\x60232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	\N	3681816978192809	\N	\N	\N
132	116	0	addr_test1wzem0yuxjqyrmzvrsr8xfqhumyy555ngyjxw7wrg2pav90q8cagu2	\\x70b3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	t	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	\N	100000000	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	3	\N
133	116	1	addr_test1vq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaqekncyn	\\x60232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	\N	3681816878026692	\N	\N	\N
134	117	0	addr_test1vq3jmpqa98gf69gcaamdm0qtr9uxxny3n46p607y9rmndaqekncyn	\\x60232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	f	\\x232d841d29d09d1518ef76ddbc0b1978634c919d741d3fc428f736f4	\N	3681816977699345	\N	\N	\N
135	118	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\N	\N	\N
136	118	1	addr_test1vpxpdh2jq7mc2lsy5ktdd6qms0xtrm4uhuqzmkhx3lthrvgu2prng	\\x604c16dd5207b7857e04a596d6e81b83ccb1eebcbf002ddae68fd771b1	f	\\x4c16dd5207b7857e04a596d6e81b83ccb1eebcbf002ddae68fd771b1	\N	3681817669117985	\N	\N	\N
137	119	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000000000	\N	\N	\N
138	119	1	addr_test1qrml5hwl9s7ydm2djyup95ud6s74skkl4zzf8zk657s8thgm78sn3uhch64ujc7ffnpga68dfdqhg3sp7tk6759jrm7spy03k9	\\x00f7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd1bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	f	\\xf7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd	47	5000000000000	\N	\N	\N
139	119	2	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	5000000000000	\N	\N	\N
140	119	3	addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k	\\x00594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	f	\\x594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0	49	5000000000000	\N	\N	\N
141	119	4	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	5000000000000	\N	\N	\N
142	119	5	addr_test1vr3sj8g858g0z3mcma4v73x4jyul5jsmzw43rtym36t5k9cufpa3u	\\x60e3091d07a1d0f14778df6acf44d59139fa4a1b13ab11ac9b8e974b17	f	\\xe3091d07a1d0f14778df6acf44d59139fa4a1b13ab11ac9b8e974b17	\N	3656817979114289	\N	\N	\N
143	120	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\N	\N	\N
144	120	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999989767575	\N	\N	\N
145	121	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\\x81cb2989cbf6c49840511d8d3451ee44f58dde2c074fc749d05deb51eeb33741	4	\N
146	121	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999979582758	\N	\N	\N
147	122	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	5	\N
148	122	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999969347913	\N	\N	\N
149	123	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\\xff1a404ece117cc4482d26b072e30b5a6b3cd055a22debda3f90d704957e273a	6	\N
150	123	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999969121208	\N	\N	\N
151	124	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\\x29294f077464c36e67b304ad22547fb3dfa946623b0b2cbae8acea7fb299353c	7	\N
152	124	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999958895251	\N	\N	\N
153	125	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9808319	\N	\N	\N
154	126	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	20000000	\N	\N	\N
155	126	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999938722402	\N	\N	\N
156	127	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	20000000	\N	\N	\N
157	127	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999918551401	\N	\N	\N
158	128	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999938180491	\N	\N	\N
159	129	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	19826843	\N	\N	\N
160	130	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
161	130	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999927987666	\N	\N	\N
162	131	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
163	131	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999917794841	\N	\N	\N
164	132	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	19825259	\N	\N	\N
165	133	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
166	133	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9632610	\N	\N	\N
167	134	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9826843	\N	\N	\N
168	135	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
169	135	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9265220	\N	\N	\N
170	136	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9824995	\N	\N	\N
171	137	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9651838	\N	\N	\N
172	138	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
173	138	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	8711649	\N	\N	\N
174	139	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
175	139	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999917614600	\N	\N	\N
176	140	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
177	140	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	8523048	\N	\N	\N
180	142	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
181	142	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	8332775	\N	\N	\N
182	143	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
183	143	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999915758158	\N	\N	\N
184	144	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999935578929	\N	\N	\N
185	145	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
186	145	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999932395080	\N	\N	\N
187	146	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2820947	\N	\N	\N
188	147	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
189	147	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999929217523	\N	\N	\N
190	148	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2827019	\N	\N	\N
191	149	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999960919293	\N	\N	\N
192	149	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999973774447	\N	\N	\N
193	150	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999960919293	\N	\N	\N
194	150	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999973604282	\N	\N	\N
195	151	0	5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg	\\x82d818582683581c599d72b5e3f5a40fb4c4eb809e904d101f908a419472f542bc7032b9a10243190378001a2a94baa3	f	\N	\N	3000000	\N	\N	\N
196	151	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999957751284	\N	\N	\N
197	152	0	addr_test1qp4erezdn0c2tpdah0k4wttxl0kdxdxdz4shlvpswge4dy0zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sutlp8k	\\x006b91e44d9bf0a585bdbbed572d66fbecd334cd15617fb03072335691e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x6b91e44d9bf0a585bdbbed572d66fbecd334cd15617fb03072335691	51	3000000	\N	\N	\N
198	152	1	addr_test1qre0ayd9huqug64zc8hydm543ewccwqjv57ymlylyad7030zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s5lgqfm	\\x00f2fe91a5bf01c46aa2c1ee46ee958e5d8c3812653c4dfc9f275be7c5e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xf2fe91a5bf01c46aa2c1ee46ee958e5d8c3812653c4dfc9f275be7c5	51	3000000	\N	\N	\N
199	152	2	addr_test1qqvsaqwz4asckpywysrkfpllfyllxczhad0436ux5lxyyslzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sdc7z7j	\\x00190e81c2af618b048e24076487ff493ff36057eb5f58eb86a7cc4243e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x190e81c2af618b048e24076487ff493ff36057eb5f58eb86a7cc4243	51	3000000	\N	\N	\N
200	152	3	addr_test1qqeudcupl6yn9qcsgld6nu6n4hdf4xzwqe6kugk0l2swkvhzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sm6yp6h	\\x0033c6e381fe8932831047dba9f353adda9a984e06756e22cffaa0eb32e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x33c6e381fe8932831047dba9f353adda9a984e06756e22cffaa0eb32	51	3000000	\N	\N	\N
201	152	4	addr_test1qr742ragm5t3ceyp9zedx5e8kux60yg8tl0tj3qwx2exw2lzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s6vaa2w	\\x00fd550fa8dd171c648128b2d35327b70da791075fdeb9440e32b2672be20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xfd550fa8dd171c648128b2d35327b70da791075fdeb9440e32b2672b	51	3000000	\N	\N	\N
202	152	5	addr_test1qrg6rf05sdys4lhqpxh66a77j949tee3aa3fpr6arc7rjn0zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s4n2yf9	\\x00d1a1a5f483490afee009afad77de916a55e731ef62908f5d1e3c394de20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xd1a1a5f483490afee009afad77de916a55e731ef62908f5d1e3c394d	51	3000000	\N	\N	\N
203	152	6	addr_test1qptqhhwmjzjllrfe8wd74f3wlks2qwlwv6v9ls2nh9p737hzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sk6r8z4	\\x00560bdddb90a5ff8d393b9beaa62efda0a03bee66985fc153b943e8fae20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x560bdddb90a5ff8d393b9beaa62efda0a03bee66985fc153b943e8fa	51	3000000	\N	\N	\N
204	152	7	addr_test1qpmtlqrahvuxdaz5pfw67are2yp4vw0va9lyfpg8cny6tr8zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sgf2qrm	\\x0076bf807dbb3866f4540a5daf747951035639ece97e448507c4c9a58ce20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x76bf807dbb3866f4540a5daf747951035639ece97e448507c4c9a58c	51	3000000	\N	\N	\N
205	152	8	addr_test1qrprusmes8ntjxxg5usggeh3ulz92e4drk8mm82yalpe8thzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3swhaaqs	\\x00c23e437981e6b918c8a7208466f1e7c45566ad1d8fbd9d44efc393aee20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xc23e437981e6b918c8a7208466f1e7c45566ad1d8fbd9d44efc393ae	51	3000000	\N	\N	\N
206	152	9	addr_test1qzwr50vgrasc7e0r34nrzkpxghqq2afetsl9w0z7vsg47slzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sw25vv8	\\x009c3a3d881f618f65e38d6631582645c00575395c3e573c5e64115f43e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x9c3a3d881f618f65e38d6631582645c00575395c3e573c5e64115f43	51	3000000	\N	\N	\N
207	152	10	addr_test1qzcnefhd9wrc5nkxxkcl7uemhg63p4jgjglddfz23cx9nyhzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3slxlh4j	\\x00b13ca6ed2b878a4ec635b1ff733bba3510d648923ed6a44a8e0c5992e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xb13ca6ed2b878a4ec635b1ff733bba3510d648923ed6a44a8e0c5992	51	3000000	\N	\N	\N
208	152	11	addr_test1qzjz0xt2y3grkt3qtju8rs8p8v5slnq5auw8nj3mkfm9zl8zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sh2rsgw	\\x00a427996a24503b2e205cb871c0e13b290fcc14ef1c79ca3bb276517ce20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xa427996a24503b2e205cb871c0e13b290fcc14ef1c79ca3bb276517c	51	3000000	\N	\N	\N
209	152	12	addr_test1qqt9l3xmuml4hzktsefpf95pp9jn4a2c07na4r993vwfrhhzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s4kv8rm	\\x00165fc4dbe6ff5b8acb865214968109653af5587fa7da8ca58b1c91dee20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x165fc4dbe6ff5b8acb865214968109653af5587fa7da8ca58b1c91de	51	3000000	\N	\N	\N
210	152	13	addr_test1qrge4eslr0wzvlpxzq8nl28954zt7k605wct8v7emuduw6lzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sqs4yhv	\\x00d19ae61f1bdc267c26100f3fa8e5a544bf5b4fa3b0b3b3d9df1bc76be20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xd19ae61f1bdc267c26100f3fa8e5a544bf5b4fa3b0b3b3d9df1bc76b	51	3000000	\N	\N	\N
211	152	14	addr_test1qrd2uxzfgg8mjck3sczt7ukt5k3th8ttdfmjrqdx3p3c6khzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3szujfzl	\\x00daae1849420fb962d18604bf72cba5a2bb9d6b6a772181a688638d5ae20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xdaae1849420fb962d18604bf72cba5a2bb9d6b6a772181a688638d5a	51	3000000	\N	\N	\N
212	152	15	addr_test1qpcfxl46pt9jdctkr3v4v06w8x4v0z7k88x5za22rvy02x0zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sf5955l	\\x0070937eba0acb26e1761c59563f4e39aac78bd639cd41754a1b08f519e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x70937eba0acb26e1761c59563f4e39aac78bd639cd41754a1b08f519	51	3000000	\N	\N	\N
213	152	16	addr_test1qzlcr53fexms4n60m7pqnudt9scpwqm8ly2dt2qeh4pvqf0zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sd07ywd	\\x00bf81d229c9b70acf4fdf8209f1ab2c30170367f914d5a819bd42c025e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xbf81d229c9b70acf4fdf8209f1ab2c30170367f914d5a819bd42c025	51	3000000	\N	\N	\N
214	152	17	addr_test1qq28y3vld327y6uywn0txmgf2rm63hu5fkqzrn7gmexhc50zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sq0s3uy	\\x001472459f6c55e26b8474deb36d0950f7a8df944d8021cfc8de4d7c51e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x1472459f6c55e26b8474deb36d0950f7a8df944d8021cfc8de4d7c51	51	3000000	\N	\N	\N
215	152	18	addr_test1qpx69s0j2auv7g8r8ejy6e7k576yw5h7wkw8qemx47azeklzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sgqk68e	\\x004da2c1f25778cf20e33e644d67d6a7b44752fe759c706766afba2cdbe20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x4da2c1f25778cf20e33e644d67d6a7b44752fe759c706766afba2cdb	51	3000000	\N	\N	\N
216	152	19	addr_test1qqxx6askq6e0ypm46sjd923m0mywkz4zrvry79wp3ruq03hzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sxzpzy4	\\x000c6d761606b2f20775d424d2aa3b7ec8eb0aa21b064f15c188f807c6e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x0c6d761606b2f20775d424d2aa3b7ec8eb0aa21b064f15c188f807c6	51	3000000	\N	\N	\N
217	152	20	addr_test1qp4npgnuuv8s9t7uk2q4z0e66k2fznlvke2dp0qkf2zla40zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s2a5q9d	\\x006b30a27ce30f02afdcb281513f3ad594914fecb654d0bc164a85fed5e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x6b30a27ce30f02afdcb281513f3ad594914fecb654d0bc164a85fed5	51	3000000	\N	\N	\N
218	152	21	addr_test1qqlrc73kz78w4pel7typuux4mx3w2g3gzcf9wqvq5me0qglzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s47qdqx	\\x003e3c7a36178eea873ff2c81e70d5d9a2e522281612570180a6f2f023e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x3e3c7a36178eea873ff2c81e70d5d9a2e522281612570180a6f2f023	51	3000000	\N	\N	\N
219	152	22	addr_test1qzt4steq0s0d3awp8mdfwtscmzpgfc04vcuzlkqdccm0y08zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sk2ry0d	\\x0097582f207c1ed8f5c13eda972e18d88284e1f566382fd80dc636f23ce20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x97582f207c1ed8f5c13eda972e18d88284e1f566382fd80dc636f23c	51	3000000	\N	\N	\N
220	152	23	addr_test1qqx4csu0y2mrynpktq3xc665lj65qs9d8tvvjh9amkmw8e0zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s6d0tgt	\\x000d5c438f22b6324c3658226c6b54fcb54040ad3ad8c95cbdddb6e3e5e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x0d5c438f22b6324c3658226c6b54fcb54040ad3ad8c95cbdddb6e3e5	51	3000000	\N	\N	\N
221	152	24	addr_test1qzs6swcdkt42llrt0j8n8ayv4kt5gq3mvyx0kmj87zw5qk8zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sltwqsk	\\x00a1a83b0db2eaaffc6b7c8f33f48cad9744023b610cfb6e47f09d4058e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xa1a83b0db2eaaffc6b7c8f33f48cad9744023b610cfb6e47f09d4058	51	3000000	\N	\N	\N
222	152	25	addr_test1qpnjsm4ht54rnu6wqgpeefc48yw3zsksyap8g9el5mhfj00zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s9500em	\\x0067286eb75d2a39f34e02039ca715391d1142d0274274173fa6ee993de20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x67286eb75d2a39f34e02039ca715391d1142d0274274173fa6ee993d	51	3000000	\N	\N	\N
223	152	26	addr_test1qpqxy2k35ccm80p6f25fy0qxw6vayfd32xvvlaxj3zcqnplzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sp5a57u	\\x0040622ad1a631b3bc3a4aa8923c067699d225b15198cff4d288b00987e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x40622ad1a631b3bc3a4aa8923c067699d225b15198cff4d288b00987	51	3000000	\N	\N	\N
224	152	27	addr_test1qqas3rz2ja0ktcpqzc656gpw70w6whsh44m5hl6ld0xk4tlzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sez7k5f	\\x003b088c4a975f65e02016354d202ef3dda75e17ad774bff5f6bcd6aafe20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x3b088c4a975f65e02016354d202ef3dda75e17ad774bff5f6bcd6aaf	51	3000000	\N	\N	\N
225	152	28	addr_test1qzm7eaqcexq64lzrqalhn60u2a07z9cwsvp3zt8nqfxuzg8zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3shqcanm	\\x00b7ecf418c981aafc43077f79e9fc575fe1170e8303112cf3024dc120e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xb7ecf418c981aafc43077f79e9fc575fe1170e8303112cf3024dc120	51	3000000	\N	\N	\N
226	152	29	addr_test1qqlgwcy56sul9hl5wejmupupr7wc5w0f5gtsg23779mmxwhzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sg3dxdr	\\x003e876094d439f2dff47665be07811f9d8a39e9a217042a3ef177b33ae20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x3e876094d439f2dff47665be07811f9d8a39e9a217042a3ef177b33a	51	3000000	\N	\N	\N
227	152	30	addr_test1qqmk3885mkadcd2n0402cwwplr9tjf2fmnng3u5x04edzrhzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sfc3xd6	\\x0037689cf4ddbadc35537d5eac39c1f8cab92549dce688f2867d72d10ee20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x37689cf4ddbadc35537d5eac39c1f8cab92549dce688f2867d72d10e	51	3000000	\N	\N	\N
228	152	31	addr_test1qzte0vyutukln6f98099xn8e5nrgkwte3x0u0yjxcr9ctr8zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sap4wyf	\\x009797b09c5f2df9e9253bca534cf9a4c68b3979899fc79246c0cb858ce20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x9797b09c5f2df9e9253bca534cf9a4c68b3979899fc79246c0cb858c	51	3000000	\N	\N	\N
229	152	32	addr_test1qzq9ev3qx45r0tedkht5ppjswsan7g0rrf6lpcgpcjtl89lzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sujcvzd	\\x00805cb220356837af2db5d7408650743b3f21e31a75f0e101c497f397e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x805cb220356837af2db5d7408650743b3f21e31a75f0e101c497f397	51	3000000	\N	\N	\N
230	152	33	addr_test1qqlpg3ytk2wj6w9cy0xsd9xxrc2eqqkpxl9pdy5aj4gse0hzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sl8tjff	\\x003e14448bb29d2d38b823cd0694c61e159002c137ca16929d95510cbee20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x3e14448bb29d2d38b823cd0694c61e159002c137ca16929d95510cbe	51	3000000	\N	\N	\N
231	152	34	addr_test1qz6rm8qnrge5gk5a6f8a4rm5mgj9dz0rkpzfn4mmj3886thzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s8tyzaz	\\x00b43d9c131a33445a9dd24fda8f74da245689e3b04499d77b944e7d2ee20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xb43d9c131a33445a9dd24fda8f74da245689e3b04499d77b944e7d2e	51	3000000	\N	\N	\N
232	152	35	addr_test1qq6tj36n9fk7dlz676twsjxrgeydy2w4ds42x7gyrwwwdnhzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sxknp00	\\x0034b947532a6de6fc5af696e848c34648d229d56c2aa379041b9ce6cee20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x34b947532a6de6fc5af696e848c34648d229d56c2aa379041b9ce6ce	51	3000000	\N	\N	\N
233	152	36	addr_test1qqpq95hpdd2qdf56dslp2m2p6fjr2yrav0j9g56npseacrlzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3srka2wn	\\x000202d2e16b5406a69a6c3e156d41d26435107d63e45453530c33dc0fe20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x0202d2e16b5406a69a6c3e156d41d26435107d63e45453530c33dc0f	51	3000000	\N	\N	\N
234	152	37	addr_test1qzl98wt0s9c93vmk4rq2v2tgxqahfuh6u4upepunsm6mkdlzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sf83vdn	\\x00be53b96f817058b376a8c0a62968303b74f2fae5781c879386f5bb37e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xbe53b96f817058b376a8c0a62968303b74f2fae5781c879386f5bb37	51	3000000	\N	\N	\N
235	152	38	addr_test1qrzpnj0dhs3zdltv7rlpypkmv290ye9m3yzsk07l2ed7940zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sf5ypaq	\\x00c419c9edbc2226fd6cf0fe1206db628af264bb89050b3fdf565be2d5e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xc419c9edbc2226fd6cf0fe1206db628af264bb89050b3fdf565be2d5	51	3000000	\N	\N	\N
236	152	39	addr_test1qp2talc3txnh5srw6xk6r7r95mekv73puhpjlpre5cscsvhzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3snnn4fx	\\x0054beff1159a77a406ed1ada1f865a6f3667a21e5c32f8479a6218832e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x54beff1159a77a406ed1ada1f865a6f3667a21e5c32f8479a6218832	51	3000000	\N	\N	\N
237	152	40	addr_test1qz0e3y9cj0tslkqfy2323u5hynfexcghauh4nr2vsrxq008zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sd45z9s	\\x009f9890b893d70fd80922a2a8f29724d3936117ef2f598d4c80cc07bce20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x9f9890b893d70fd80922a2a8f29724d3936117ef2f598d4c80cc07bc	51	3000000	\N	\N	\N
238	152	41	addr_test1qrgsyw37gtp62lftf93ah80j8xkhgu20rx0lkeknxks7nklzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3skgnkaj	\\x00d1023a3e42c3a57d2b4963db9df239ad74714f199ffb66d335a1e9dbe20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xd1023a3e42c3a57d2b4963db9df239ad74714f199ffb66d335a1e9db	51	3000000	\N	\N	\N
239	152	42	addr_test1qqf930nlleh47su6c5tu84j4dzhs4fkv35xwvhxnev8evrhzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s3vmqzr	\\x001258be7ffe6f5f439ac517c3d65568af0aa6cc8d0ce65cd3cb0f960ee20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x1258be7ffe6f5f439ac517c3d65568af0aa6cc8d0ce65cd3cb0f960e	51	3000000	\N	\N	\N
240	152	43	addr_test1qpaja7y35ne68ht20f8w4re0etscxp3gd8qpkskuyyc05d0zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sleum7l	\\x007b2ef891a4f3a3dd6a7a4eea8f2fcae183062869c01b42dc2130fa35e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x7b2ef891a4f3a3dd6a7a4eea8f2fcae183062869c01b42dc2130fa35	51	3000000	\N	\N	\N
241	152	44	addr_test1qqyprff52gutuprh7jrlm35x9kkr3l37gw7geyg30aujg78zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s6yjel6	\\x000811a5345238be0477f487fdc6862dac38fe3e43bc8c91117f792478e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x0811a5345238be0477f487fdc6862dac38fe3e43bc8c91117f792478	51	3000000	\N	\N	\N
242	152	45	addr_test1qrvr6tq00c28rustjudaqj3daj0s24kcat3wjtpey3t8jmhzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sythwgp	\\x00d83d2c0f7e1471f20b971bd04a2dec9f0556d8eae2e92c392456796ee20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xd83d2c0f7e1471f20b971bd04a2dec9f0556d8eae2e92c392456796e	51	3000000	\N	\N	\N
243	152	46	addr_test1qzkjfylgyp5p39vgravumu0e3sqsc37tln3576zsn7apn80zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sp4mpv2	\\x00ad2493e820681895881f59cdf1f98c010c47cbfce34f68509fba199de20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xad2493e820681895881f59cdf1f98c010c47cbfce34f68509fba199d	51	3000000	\N	\N	\N
244	152	47	addr_test1qqje4352384e63a5fudhwdy37v2hprh6t2twq0mt2juzpz8zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s5mtktv	\\x00259ac68a89eb9d47b44f1b773491f315708efa5a96e03f6b54b82088e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x259ac68a89eb9d47b44f1b773491f315708efa5a96e03f6b54b82088	51	3000000	\N	\N	\N
245	152	48	addr_test1qz9wc4r9rqd7lsy5emmnum7stgd4xf9vt893c5q7au8rn98zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s6t4tza	\\x008aec5465181befc094cef73e6fd05a1b5324ac59cb1c501eef0e3994e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x8aec5465181befc094cef73e6fd05a1b5324ac59cb1c501eef0e3994	51	3000000	\N	\N	\N
246	152	49	addr_test1qqsg9lmpppzqzkjsl6tgtrxngsvu9gen359jpk9944kvxa8zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sztut57	\\x002082ff610844015a50fe96858cd34419c2a3338d0b20d8a5ad6cc374e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x2082ff610844015a50fe96858cd34419c2a3338d0b20d8a5ad6cc374	51	3000000	\N	\N	\N
247	152	50	addr_test1qrmyxd0kza22vsa40r5nrtvl7cs8elcpxqejz2763k63y38zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sk3jdl6	\\x00f64335f61754a643b578e931ad9ff6207cff013033212bda8db51244e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xf64335f61754a643b578e931ad9ff6207cff013033212bda8db51244	51	3000000	\N	\N	\N
248	152	51	addr_test1qrxx03wylmyw5kgutqkveel2ysum2kd5hh0tg9kd9f2ccqhzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sgtya28	\\x00cc67c5c4fec8ea591c582ccce7ea2439b559b4bddeb416cd2a558c02e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xcc67c5c4fec8ea591c582ccce7ea2439b559b4bddeb416cd2a558c02	51	3000000	\N	\N	\N
249	152	52	addr_test1qrnz49u6s5ff7kf9sumk008h5umpnnm968uax823ddasffhzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s9tdnpd	\\x00e62a979a85129f5925873767bcf7a73619cf65d1f9d31d516b7b04a6e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xe62a979a85129f5925873767bcf7a73619cf65d1f9d31d516b7b04a6	51	3000000	\N	\N	\N
250	152	53	addr_test1qz5asfhlrnk2ac0cdwwradfkddshq2vfuyeqakcrf8u5wvlzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sng58gf	\\x00a9d826ff1cecaee1f86b9c3eb5366b61702989e1320edb0349f94733e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xa9d826ff1cecaee1f86b9c3eb5366b61702989e1320edb0349f94733	51	3000000	\N	\N	\N
251	152	54	addr_test1qr339mtcefe4g4fzqx8srkpawkhepneul3jjwr2auaavjrlzpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s7wgv9f	\\x00e312ed78ca73545522018f01d83d75af90cf3cfc65270d5de77ac90fe20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xe312ed78ca73545522018f01d83d75af90cf3cfc65270d5de77ac90f	51	3000000	\N	\N	\N
252	152	55	addr_test1qzahr0fnvvvp8qscgnharj96zp5d5p4xce7twd9t09wzqf8zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3scs0lvx	\\x00bb71bd33631813821844efd1c8ba1068da06a6c67cb734ab795c2024e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xbb71bd33631813821844efd1c8ba1068da06a6c67cb734ab795c2024	51	3000000	\N	\N	\N
253	152	56	addr_test1qr3nvqgn05rk3zzs4vc4xc0yu6qz86tdnnzacgnfqt4k3j0zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3spqxrdk	\\x00e33601137d07688850ab315361e4e68023e96d9cc5dc226902eb68c9e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xe33601137d07688850ab315361e4e68023e96d9cc5dc226902eb68c9	51	3000000	\N	\N	\N
254	152	57	addr_test1qr5pplf0fgmjg9smzzrh0yh3935tmtm6uhkl2e8alk56690zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3shsdq7d	\\x00e810fd2f4a3724161b10877792f12c68bdaf7ae5edf564fdfda9ad15e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xe810fd2f4a3724161b10877792f12c68bdaf7ae5edf564fdfda9ad15	51	3000000	\N	\N	\N
255	152	58	addr_test1qrudp6ftywsftq42ax6yq79u35mjrvj6sl5vyuhlk4muwm8zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3st364ex	\\x00f8d0e92b23a09582aae9b44078bc8d3721b25a87e8c272ffb577c76ce20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\xf8d0e92b23a09582aae9b44078bc8d3721b25a87e8c272ffb577c76c	51	3000000	\N	\N	\N
256	152	59	addr_test1qqstu7jcyktzzfyfdnltxdzfrg2kmank3k5tunrpjvhdzu8zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3s4hnmlq	\\x0020be7a5825962124896cfeb334491a156df6768da8be4c61932ed170e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x20be7a5825962124896cfeb334491a156df6768da8be4c61932ed170	51	3000000	\N	\N	\N
257	152	60	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	58433254712	\N	\N	\N
258	152	61	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
259	152	62	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
260	152	63	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
261	152	64	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
262	152	65	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
263	152	66	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
264	152	67	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
265	152	68	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
266	152	69	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
267	152	70	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
268	152	71	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
269	152	72	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
270	152	73	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
271	152	74	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
272	152	75	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
273	152	76	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
274	152	77	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
275	152	78	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
276	152	79	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
277	152	80	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
278	152	81	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
279	152	82	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
280	152	83	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
281	152	84	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
282	152	85	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
283	152	86	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
284	152	87	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
285	152	88	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
286	152	89	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
287	152	90	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
288	152	91	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
289	152	92	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
290	152	93	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
291	152	94	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
292	152	95	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
293	152	96	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
294	152	97	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
295	152	98	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
296	152	99	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
297	152	100	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
298	152	101	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
299	152	102	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
300	152	103	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
301	152	104	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
302	152	105	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
303	152	106	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
304	152	107	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
305	152	108	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
306	152	109	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
307	152	110	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
308	152	111	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
309	152	112	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
310	152	113	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
311	152	114	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
312	152	115	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
313	152	116	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
314	152	117	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
315	152	118	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
316	152	119	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853287801	\N	\N	\N
317	153	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	178500000	\N	\N	\N
318	153	1	addr_test1qp4erezdn0c2tpdah0k4wttxl0kdxdxdz4shlvpswge4dy0zpkldulwqzwupd8y4qltxmh06rdzagtmzmrt9tpg9jy3sutlp8k	\\x006b91e44d9bf0a585bdbbed572d66fbecd334cd15617fb03072335691e20dbede7dc013b8169c9507d66dddfa1b45d42f62d8d65585059123	f	\\x6b91e44d9bf0a585bdbbed572d66fbecd334cd15617fb03072335691	51	974447	\N	\N	\N
319	154	0	addr_test1xq5cmykdv7rgm76f5x88whjy45kt0dqhdw9fnn3cl0pfflff3kfv6eux3ha5ngvwwa0yftfvk76pw6u2n88r377zjn7s4gu32s	\\x30298d92cd67868dfb49a18e775e44ad2cb7b4176b8a99ce38fbc294fd298d92cd67868dfb49a18e775e44ad2cb7b4176b8a99ce38fbc294fd	t	\\x298d92cd67868dfb49a18e775e44ad2cb7b4176b8a99ce38fbc294fd	52	10000000	\N	\N	\N
320	154	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843119352	\N	\N	\N
321	155	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1000000	\N	\N	\N
322	155	1	addr_test1xq5cmykdv7rgm76f5x88whjy45kt0dqhdw9fnn3cl0pfflff3kfv6eux3ha5ngvwwa0yftfvk76pw6u2n88r377zjn7s4gu32s	\\x30298d92cd67868dfb49a18e775e44ad2cb7b4176b8a99ce38fbc294fd298d92cd67868dfb49a18e775e44ad2cb7b4176b8a99ce38fbc294fd	t	\\x298d92cd67868dfb49a18e775e44ad2cb7b4176b8a99ce38fbc294fd	52	8818439	\N	\N	\N
323	156	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
324	156	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
325	158	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	969750	\N	\N	\N
326	158	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49852147754	\N	\N	\N
327	159	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
328	159	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843119352	\N	\N	\N
329	160	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	1000000000	\N	\N	\N
330	160	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	48853119352	\N	\N	\N
331	161	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	98675351	\N	\N	\N
332	161	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	99000000	\N	\N	\N
333	161	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	99000000	\N	\N	\N
334	161	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	99000000	\N	\N	\N
335	161	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	99000000	\N	\N	\N
336	161	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	49500000	\N	\N	\N
337	161	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	49500000	\N	\N	\N
338	161	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	49500000	\N	\N	\N
339	161	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	49500000	\N	\N	\N
340	161	9	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	49500000	\N	\N	\N
341	161	10	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	24750000	\N	\N	\N
342	161	11	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	24750000	\N	\N	\N
343	161	12	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	24750000	\N	\N	\N
344	161	13	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	24750000	\N	\N	\N
345	161	14	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	24750000	\N	\N	\N
346	161	15	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	12375000	\N	\N	\N
347	161	16	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	12375000	\N	\N	\N
348	161	17	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	12375000	\N	\N	\N
349	161	18	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	12375000	\N	\N	\N
350	161	19	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	12375000	\N	\N	\N
351	161	20	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	6187500	\N	\N	\N
352	161	21	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	6187500	\N	\N	\N
353	161	22	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	6187500	\N	\N	\N
354	161	23	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	6187500	\N	\N	\N
355	161	24	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	6187500	\N	\N	\N
356	161	25	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	3093750	\N	\N	\N
357	161	26	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	3093750	\N	\N	\N
358	161	27	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	3093750	\N	\N	\N
359	161	28	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	3093750	\N	\N	\N
360	161	29	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	3093750	\N	\N	\N
361	161	30	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	3093750	\N	\N	\N
362	161	31	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	3093750	\N	\N	\N
363	161	32	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	3093750	\N	\N	\N
364	161	33	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	3093750	\N	\N	\N
365	161	34	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	3093750	\N	\N	\N
366	162	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	494576915	\N	\N	\N
367	162	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	247418838	\N	\N	\N
368	162	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	123709419	\N	\N	\N
369	162	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	61854709	\N	\N	\N
370	162	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	30927355	\N	\N	\N
371	162	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	15463677	\N	\N	\N
372	162	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	7731839	\N	\N	\N
373	162	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	3865919	\N	\N	\N
374	162	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	3865919	\N	\N	\N
375	163	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	57	494375158	\N	\N	\N
376	164	0	addr_test1xqrre695yap2s4sjq422spmw8guela2l44gu0yxsfuyx7ngx8n5tgf6z4ptpyp254qrkuw3enl64lt23c7gdqncgdaxs46a2zc	\\x30063ce8b42742a856120554a8076e3a399ff55fad51c790d04f086f4d063ce8b42742a856120554a8076e3a399ff55fad51c790d04f086f4d	t	\\x063ce8b42742a856120554a8076e3a399ff55fad51c790d04f086f4d	63	10000000	\N	\N	\N
377	164	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843119352	\N	\N	\N
378	165	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1000000	\N	\N	\N
379	165	1	addr_test1xqrre695yap2s4sjq422spmw8guela2l44gu0yxsfuyx7ngx8n5tgf6z4ptpyp254qrkuw3enl64lt23c7gdqncgdaxs46a2zc	\\x30063ce8b42742a856120554a8076e3a399ff55fad51c790d04f086f4d063ce8b42742a856120554a8076e3a399ff55fad51c790d04f086f4d	t	\\x063ce8b42742a856120554a8076e3a399ff55fad51c790d04f086f4d	63	6814039	\N	\N	\N
380	166	0	addr_test1xqrre695yap2s4sjq422spmw8guela2l44gu0yxsfuyx7ngx8n5tgf6z4ptpyp254qrkuw3enl64lt23c7gdqncgdaxs46a2zc	\\x30063ce8b42742a856120554a8076e3a399ff55fad51c790d04f086f4d063ce8b42742a856120554a8076e3a399ff55fad51c790d04f086f4d	t	\\x063ce8b42742a856120554a8076e3a399ff55fad51c790d04f086f4d	63	8633754	\N	\N	\N
381	167	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	1000000	\N	\N	\N
382	167	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49850105404	\N	\N	\N
383	168	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999975432709	\N	\N	\N
384	169	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49851107384	\N	\N	\N
385	170	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
386	170	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49837950947	\N	\N	\N
387	171	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
388	171	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
389	172	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
390	172	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
391	173	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
392	173	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
393	174	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
394	174	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
395	175	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
396	175	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
397	176	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
398	176	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	173331771	\N	\N	\N
399	177	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
400	177	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
401	178	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
402	178	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
403	179	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
404	179	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
405	180	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
406	180	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
407	181	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
408	181	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
409	182	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
410	182	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4831771	\N	\N	\N
411	183	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
412	183	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
413	184	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
414	184	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853117768	\N	\N	\N
415	185	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
416	185	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
417	186	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
418	186	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
419	187	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
420	187	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
421	188	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
422	188	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
423	189	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
424	189	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
425	190	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
426	190	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
427	191	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
428	191	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49845938979	\N	\N	\N
429	192	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
430	192	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	58428086263	\N	\N	\N
431	193	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
432	193	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
433	194	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
434	194	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
435	195	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
436	195	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
437	196	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
438	196	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49847949363	\N	\N	\N
439	197	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
440	197	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
441	198	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
442	198	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
443	199	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
444	199	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49843779374	\N	\N	\N
445	200	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
446	200	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
447	201	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
448	201	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
449	202	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
450	202	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
451	203	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
452	203	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842780958	\N	\N	\N
453	204	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
454	204	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853117768	\N	\N	\N
455	205	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
456	205	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
457	206	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
458	206	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49837612553	\N	\N	\N
459	207	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
460	207	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
461	208	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
462	208	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
463	209	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
464	209	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
465	210	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
466	210	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49853117768	\N	\N	\N
467	211	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
468	211	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49847949363	\N	\N	\N
469	212	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
470	212	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
471	213	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
472	213	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
473	214	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
474	214	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49837950947	\N	\N	\N
475	215	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
476	215	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
477	216	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
478	216	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
479	217	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
480	217	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49847949363	\N	\N	\N
481	218	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
482	218	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
483	219	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
484	219	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	58422917858	\N	\N	\N
485	220	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
486	220	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
487	221	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
488	221	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49837782542	\N	\N	\N
489	222	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
490	222	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
491	223	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
492	223	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49838610969	\N	\N	\N
493	224	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
494	224	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
495	225	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
496	225	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49837780958	\N	\N	\N
497	226	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
498	226	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
499	227	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
500	227	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
501	228	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
502	228	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
503	229	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
504	229	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
505	230	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
506	230	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	48852949363	\N	\N	\N
507	231	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
508	231	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
509	232	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
510	232	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49852947779	\N	\N	\N
511	233	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
512	233	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	58417749453	\N	\N	\N
513	234	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
514	234	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49847779374	\N	\N	\N
515	235	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
516	235	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	173161958	\N	\N	\N
517	236	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
518	236	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
519	237	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
520	237	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
521	238	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
522	238	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	48847780958	\N	\N	\N
523	239	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
524	239	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
525	240	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
526	240	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
527	241	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
528	241	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
529	242	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
530	242	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
531	243	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
532	243	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5828603	\N	\N	\N
533	244	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
534	244	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
535	245	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
536	245	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
537	246	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
538	246	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
539	247	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
540	247	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
541	248	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
542	248	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
543	249	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
544	249	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
545	250	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
546	250	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
547	251	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
548	251	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842780958	\N	\N	\N
549	252	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
550	252	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
551	253	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
552	253	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
553	254	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
554	254	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
555	255	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
556	255	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
557	256	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
558	256	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	48847610969	\N	\N	\N
559	257	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
560	257	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
561	258	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
562	258	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5658790	\N	\N	\N
563	259	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
564	259	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49837782542	\N	\N	\N
565	260	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
566	260	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
567	261	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
568	261	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49847779374	\N	\N	\N
569	262	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
570	262	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49852947955	\N	\N	\N
571	263	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
572	263	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
573	264	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
574	264	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4492145	\N	\N	\N
575	265	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
576	265	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
577	266	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
578	266	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49837782542	\N	\N	\N
579	267	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
580	267	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49848119352	\N	\N	\N
581	268	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
582	268	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	49842950947	\N	\N	\N
583	269	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
584	269	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
585	270	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
586	270	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	55145218674	\N	\N	\N
587	271	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1251044532550	\N	\N	\N
588	271	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	1251044955582	\N	\N	\N
589	271	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625522477791	\N	\N	\N
590	271	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	625522477791	\N	\N	\N
591	271	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312761238896	\N	\N	\N
592	271	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	312761238896	\N	\N	\N
593	271	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156380619448	\N	\N	\N
594	271	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	156380619448	\N	\N	\N
595	271	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78190309724	\N	\N	\N
596	271	9	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	78190309724	\N	\N	\N
597	271	10	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39095154862	\N	\N	\N
598	271	11	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	39095154862	\N	\N	\N
599	271	12	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39095154861	\N	\N	\N
600	271	13	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	39095154861	\N	\N	\N
601	272	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
602	272	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1270673517294	\N	\N	\N
603	273	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
604	273	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	156375451043	\N	\N	\N
605	274	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
606	274	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	39089986457	\N	\N	\N
607	275	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
608	275	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	156370282638	\N	\N	\N
609	276	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
610	276	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	312756070491	\N	\N	\N
611	277	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
612	277	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	1251039787177	\N	\N	\N
613	278	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
614	278	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	78185141319	\N	\N	\N
615	279	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
616	279	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39089986457	\N	\N	\N
617	280	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
618	280	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1270673347305	\N	\N	\N
619	281	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
620	281	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	625517309386	\N	\N	\N
621	282	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
622	282	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1270668178900	\N	\N	\N
623	283	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
624	283	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39089986456	\N	\N	\N
625	284	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
626	284	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312756070491	\N	\N	\N
627	285	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
628	285	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
629	286	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
630	286	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625517309386	\N	\N	\N
631	287	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
632	287	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	39084818052	\N	\N	\N
633	288	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
634	288	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78190139735	\N	\N	\N
635	289	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
636	289	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	312750902086	\N	\N	\N
637	290	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
638	290	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
639	291	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
640	291	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
641	292	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
642	292	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4660374	\N	\N	\N
643	293	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
644	293	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39089816468	\N	\N	\N
645	294	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
646	294	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	39089986456	\N	\N	\N
647	295	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
648	295	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
649	296	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
650	296	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	1251034618772	\N	\N	\N
651	297	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
652	297	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
653	298	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
654	298	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1270663010495	\N	\N	\N
655	299	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
656	299	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
657	300	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
658	300	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
659	301	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
660	301	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	39089816467	\N	\N	\N
661	302	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
662	302	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625516969584	\N	\N	\N
663	303	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
664	303	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39084648063	\N	\N	\N
665	304	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
666	304	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
667	305	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
668	305	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4660374	\N	\N	\N
669	306	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
670	306	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4490561	\N	\N	\N
671	307	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
672	307	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312750902086	\N	\N	\N
673	308	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
674	308	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4660374	\N	\N	\N
675	309	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
676	309	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	156369942836	\N	\N	\N
677	310	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
678	310	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78184971330	\N	\N	\N
679	311	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
680	311	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	78179972914	\N	\N	\N
681	312	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
682	312	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78179802925	\N	\N	\N
683	313	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
684	313	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39084818051	\N	\N	\N
685	314	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
686	314	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
687	315	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
688	315	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
689	316	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
690	316	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	1251029450367	\N	\N	\N
691	317	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
692	317	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	156364774431	\N	\N	\N
693	318	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
694	318	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156375451043	\N	\N	\N
695	319	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
696	319	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1270657842090	\N	\N	\N
697	320	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
698	320	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39079479658	\N	\N	\N
699	321	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
700	321	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
701	322	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
702	322	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4660374	\N	\N	\N
703	323	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
704	323	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
705	324	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
706	324	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
707	325	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
708	325	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4490561	\N	\N	\N
709	326	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
710	326	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
711	327	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
712	327	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
713	328	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
714	328	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1270652673685	\N	\N	\N
715	329	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
716	329	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4660374	\N	\N	\N
717	330	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
718	330	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4660374	\N	\N	\N
719	331	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
720	331	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	156359606026	\N	\N	\N
721	332	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
722	332	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4490561	\N	\N	\N
723	333	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
724	333	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
725	334	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
726	334	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
727	335	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
728	335	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
729	336	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
730	336	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	625516969584	\N	\N	\N
731	337	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
732	337	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	156359096411	\N	\N	\N
733	338	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
734	338	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4660374	\N	\N	\N
735	339	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
736	339	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4490561	\N	\N	\N
737	340	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
738	340	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
739	341	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
740	341	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	1251024281962	\N	\N	\N
741	342	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
742	342	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312745733681	\N	\N	\N
743	343	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
744	343	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39079649646	\N	\N	\N
745	344	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
746	344	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
747	345	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
748	345	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4320748	\N	\N	\N
749	346	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
750	346	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4320748	\N	\N	\N
751	347	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
752	347	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
753	348	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
754	348	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4660374	\N	\N	\N
755	349	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
756	349	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4660374	\N	\N	\N
757	350	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
758	350	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4490561	\N	\N	\N
759	351	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
760	351	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4660374	\N	\N	\N
761	352	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
762	352	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
763	353	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
764	353	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4150935	\N	\N	\N
765	354	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
766	354	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4660374	\N	\N	\N
767	355	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
768	355	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	1251023772347	\N	\N	\N
769	356	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
770	356	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4660374	\N	\N	\N
771	357	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
772	357	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	312745733681	\N	\N	\N
773	358	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
774	358	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4490561	\N	\N	\N
775	359	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
776	359	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
777	360	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
778	360	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39079309844	\N	\N	\N
779	361	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
780	361	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39074141439	\N	\N	\N
781	362	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
782	362	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4490561	\N	\N	\N
783	363	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
784	363	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4660374	\N	\N	\N
785	364	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
786	364	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4660374	\N	\N	\N
787	365	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
788	365	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39074311253	\N	\N	\N
789	366	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
790	366	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	39084138624	\N	\N	\N
791	367	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
792	367	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	156353928006	\N	\N	\N
793	368	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
794	368	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4490561	\N	\N	\N
795	369	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
796	369	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4830187	\N	\N	\N
797	370	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
798	370	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4320748	\N	\N	\N
799	371	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
800	371	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39073292198	\N	\N	\N
801	372	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
802	372	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	15273586444	\N	\N	\N
803	373	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
804	373	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999496820111	\N	\N	\N
805	374	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
806	374	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999491650122	\N	\N	\N
807	375	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
808	375	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	2822839	\N	\N	\N
809	376	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999493478549	\N	\N	\N
810	377	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
811	377	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	4999526808055	\N	\N	\N
812	378	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
813	378	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	4999524629002	\N	\N	\N
814	379	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
815	379	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	4999521445769	\N	\N	\N
816	380	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	5	\N
817	380	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	15268350015	\N	\N	\N
818	381	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\\xff1a404ece117cc4482d26b072e30b5a6b3cd055a22debda3f90d704957e273a	6	\N
819	381	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	15258127886	\N	\N	\N
820	382	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\\x29294f077464c36e67b304ad22547fb3dfa946623b0b2cbae8acea7fb299353c	7	\N
821	382	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39064088288	\N	\N	\N
822	383	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	67	4638990	\N	\N	\N
\.


--
-- Data for Name: withdrawal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.withdrawal (id, addr_id, amount, redeemer_id, tx_id) FROM stdin;
1	46	5297105614	\N	270
2	46	19634159441	\N	272
3	67	3949497701	\N	372
4	46	11324269468	\N	372
\.


--
-- Name: ada_pots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ada_pots_id_seq', 12, true);


--
-- Name: block_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.block_id_seq', 1189, true);


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

SELECT pg_catalog.setval('public.cost_model_id_seq', 12, true);


--
-- Name: datum_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.datum_id_seq', 7, true);


--
-- Name: delegation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delegation_id_seq', 64, true);


--
-- Name: delisted_pool_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delisted_pool_id_seq', 1, false);


--
-- Name: epoch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_id_seq', 12, true);


--
-- Name: epoch_param_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_param_id_seq', 12, true);


--
-- Name: epoch_stake_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_stake_id_seq', 284, true);


--
-- Name: epoch_sync_time_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_sync_time_id_seq', 11, true);


--
-- Name: extra_key_witness_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.extra_key_witness_id_seq', 1, false);


--
-- Name: ma_tx_mint_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_mint_id_seq', 51, true);


--
-- Name: ma_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_out_id_seq', 77, true);


--
-- Name: meta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meta_id_seq', 1, true);


--
-- Name: multi_asset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.multi_asset_id_seq', 22, true);


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

SELECT pg_catalog.setval('public.reverse_index_id_seq', 1187, true);


--
-- Name: reward_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reward_id_seq', 205, true);


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

SELECT pg_catalog.setval('public.slot_leader_id_seq', 1189, true);


--
-- Name: stake_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_address_id_seq', 70, true);


--
-- Name: stake_deregistration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_deregistration_id_seq', 3, true);


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

SELECT pg_catalog.setval('public.tx_id_seq', 383, true);


--
-- Name: tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_in_id_seq', 693, true);


--
-- Name: tx_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_metadata_id_seq', 24, true);


--
-- Name: tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_out_id_seq', 822, true);


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

