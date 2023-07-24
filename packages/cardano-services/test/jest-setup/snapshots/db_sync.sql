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
1	1007	1	0	8999989979999988	0	81000010010290406	0	9709606	91
2	2027	2	79199912775554	8920790076739983	0	81000010006319254	0	4165209	171
3	3022	3	150566233805994	8778771102054629	70652657820123	81000010006319254	0	0	263
4	4004	4	231330927944896	8618049360860228	150609704875622	81000010006319254	0	0	354
5	5007	5	308893372192638	8482470209290712	208626412197396	81000010002429737	0	3889517	454
6	6026	6	390325086590780	8343929360749702	265735550229781	81000009993586867	0	8842870	565
7	7023	7	473764381082564	8204379142927516	321846482403053	81000009993586867	0	0	678
8	8013	8	555808172511839	8062398958152826	381782875748468	81000009976692027	0	16894840	776
9	9001	9	634013444095405	7937208156203521	428768423009047	81000009976692027	0	0	871
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (id, hash, epoch_no, slot_no, epoch_slot_no, block_no, previous_id, slot_leader_id, size, "time", tx_count, proto_major, proto_minor, vrf_key, op_cert, op_cert_counter) FROM stdin;
1	\\xc48e05741e657c78f401cbb3379043aa90874407672f62de57b23504e41ed3e8	\N	\N	\N	\N	\N	1	0	2023-06-27 14:35:38	11	0	0	\N	\N	\N
2	\\x5368656c6c65792047656e6573697320426c6f636b2048617368200000000000	\N	\N	\N	\N	1	2	0	2023-06-27 14:35:38	23	0	0	\N	\N	\N
3	\\xee6d69abafce124b5a1ec65c2cc24251701894bcbde478ce02ae932513e76839	0	28	28	0	1	3	265	2023-06-27 14:35:43.6	1	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
4	\\xf2a8e013c78ea9c8f9be32911fc90c262ba1ff95f89568db59060c3b5464e73e	0	40	40	1	3	4	341	2023-06-27 14:35:46	1	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
5	\\x2cdbc304f605cbcfc0fb5496631fb723b80ed07a723de2b12cc1469e6217c838	0	46	46	2	4	4	4	2023-06-27 14:35:47.2	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
6	\\xb2076c654808f6b9a3cd1f38c0980ed932cab70cea91a620d5ba0ef8d2940042	0	78	78	3	5	6	371	2023-06-27 14:35:53.6	1	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
7	\\x7ad808855a8cdbc9b8691b4cb3eb2a66eb5be94bf11bfd441c2463814cfc27ea	0	85	85	4	6	7	4	2023-06-27 14:35:55	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
8	\\xc6c4e025d8dcbbff3ddefc07c1e162b5f036f26594ea4c2206e9d9167d100fb9	0	95	95	5	7	6	399	2023-06-27 14:35:57	1	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
9	\\xc46389a9ee672eeff970d52540387f3b3790c9e9642c09a821af1fc7a9c213aa	0	97	97	6	8	7	4	2023-06-27 14:35:57.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
10	\\x8be41f1851e0b5616e1cea6a9afcbc64c1ca25d0677907ce7426da202bce11d6	0	107	107	7	9	10	655	2023-06-27 14:35:59.4	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
11	\\xd8d8a2d3d1ad04f34284dc8dc66dfa47d9e75caa5475537827224634d0d99f27	0	109	109	8	10	6	4	2023-06-27 14:35:59.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
12	\\xb3343d7ef9c911f5ef6d47d0b83b624fcb8df5acf84ac392bb1fd2b455303ede	0	115	115	9	11	12	4	2023-06-27 14:36:01	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
13	\\xffe3530deef19423ea5c17c0a1b28cda98b7072edc6bafa19e0e221a4f16ff59	0	117	117	10	12	6	4	2023-06-27 14:36:01.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
14	\\x929ae842c54d9f969f46b3ae035b798e00b32b35dd4d7e1d5ac9e2ba744bbe81	0	125	125	11	13	10	265	2023-06-27 14:36:03	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
15	\\x1c780965c89071ea224ba73708b4e845a58e15ba1e0505a9efe67dbb98a55f23	0	141	141	12	14	10	341	2023-06-27 14:36:06.2	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
16	\\x87989f79c7d5b3ed3403f9d73c71900b16ec973726f60f56f492f6c073c2a207	0	145	145	13	15	12	4	2023-06-27 14:36:07	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
17	\\x95c28bd4435b929168ff1c6ac9242bc3a0a88de23c39c7d75a4b4446222d08d0	0	163	163	14	16	17	371	2023-06-27 14:36:10.6	1	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
18	\\x001d8396868eff36879960b719c7ad4c0e2c311256161852f2f702556d4b20b5	0	179	179	15	17	18	399	2023-06-27 14:36:13.8	1	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
19	\\x0b73a8334ecf023fcc66d73e3cc861f4cddaaf073328fd5dafc0cec0d8126d74	0	183	183	16	18	19	4	2023-06-27 14:36:14.6	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
20	\\x9f4c068fde5efe767d9e70cccabd3dcd41d3093a906b78b3efbcf94aeff77ab0	0	190	190	17	19	6	592	2023-06-27 14:36:16	1	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
21	\\x700c66e9c8860a3bf2660f4f32003f8896d01d1156e90e9772f46bd2b26d7f32	0	207	207	18	20	12	265	2023-06-27 14:36:19.4	1	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
22	\\x383d8a7bdc2009210086394138011d45ea9113439f98d71d021c1f15d63ab573	0	219	219	19	21	4	341	2023-06-27 14:36:21.8	1	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
23	\\x716f73999831adb0fb78d18b3aac942a98fb230b35c07d56af0faee700c68176	0	231	231	20	22	10	371	2023-06-27 14:36:24.2	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
24	\\x80dd44d48869714b23dc177c14117b9f408a929a1364ba3fdeb9a00c90f04db1	0	256	256	21	23	3	399	2023-06-27 14:36:29.2	1	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
25	\\xe878c833456dc9c18978f1ef23a785f1dd7a5eaffa7c8192cd01ba81eb4364c0	0	278	278	22	24	7	655	2023-06-27 14:36:33.6	1	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
26	\\xb4559ef391f9376eb6c06bb90a92bfe939383b30346631a09688117315c5b110	0	286	286	23	25	19	265	2023-06-27 14:36:35.2	1	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
27	\\x82dce8f83df6f171589fff792e8949a2b4650875f8a17fa0b07c2b2ad480dd2d	0	297	297	24	26	19	341	2023-06-27 14:36:37.4	1	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
28	\\x9d7f6541f6f8e6b4ac2a1efd8d778ce912ab75f1dca51debeedcdcd80362a2d4	0	301	301	25	27	6	4	2023-06-27 14:36:38.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
29	\\x36e790ddc849ed5c3777d544c2ba2e67ed3db631668c6a7e460c07e2b354d16b	0	308	308	26	28	12	371	2023-06-27 14:36:39.6	1	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
30	\\xa72cd49c9883dbe60595b67977c3277ff9e9361f8155a2d7411deda4b0971f12	0	319	319	27	29	17	399	2023-06-27 14:36:41.8	1	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
31	\\x417cf069f29416d11a1c373be52e9b81ee7f8dacc9d63cb2e6c4c71cbd0ed369	0	320	320	28	30	7	4	2023-06-27 14:36:42	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
32	\\x3def70c929f8153140867b2e360aaa0cb03a0f460cdff6d8b53bc969a36d86b1	0	325	325	29	31	10	4	2023-06-27 14:36:43	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
33	\\x5b8522d414c54c77ab0bde3e886674919712f4534173adaf22d6e3527124c8d5	0	326	326	30	32	12	4	2023-06-27 14:36:43.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
34	\\x014235882467adf4091e4d904340bf678bcc8c790f80d8f4f136c577e9266caa	0	332	332	31	33	10	655	2023-06-27 14:36:44.4	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
35	\\xb0e427314704cd274ab163898bcb8cf1e46233c553536ce4bbe5e836d1b48792	0	369	369	32	34	7	265	2023-06-27 14:36:51.8	1	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
36	\\xf4f0e72e7d331c76b8cc2252c35b653257aee50cb440a0b249e5f72f4b86b541	0	382	382	33	35	4	341	2023-06-27 14:36:54.4	1	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
37	\\x414863b19f66de452a1546dff505723c9d504a7bed287b39017f54c02b4467a7	0	403	403	34	36	10	371	2023-06-27 14:36:58.6	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
38	\\x9159778126bbc222993498112b5f6e20656bc11a14a0c099ca4c6bfec395ab8c	0	404	404	35	37	4	4	2023-06-27 14:36:58.8	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
39	\\x08fcc52924814a024d0c44d612c8e8c68c866ef7ea1fcde77db6d3e0e3da9375	0	417	417	36	38	19	399	2023-06-27 14:37:01.4	1	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
40	\\x8bd777ad27e8eb0a5775a6321db2d38da9701cbe6e3ac05dcbb7f9408feb7d7b	0	421	421	37	39	6	4	2023-06-27 14:37:02.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
41	\\x9b03c6aa498f997b2c83dc1f0e360b65d2959bcd988dc42639712732fc6a1c24	0	424	424	38	40	7	4	2023-06-27 14:37:02.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
42	\\x38cb9fec7e630bee885892d39cab3438a1abefe8433f7000d9342f0fbf1542f2	0	436	436	39	41	12	655	2023-06-27 14:37:05.2	1	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
43	\\xecdc0874efac242158272c52d76785897d4203b8e3f5437cd7ed17a95e1838c3	0	503	503	40	42	18	265	2023-06-27 14:37:18.6	1	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
44	\\xbe4940819821aad04f4c4847607af2ece70c3188df595a13402f0e9bd0978a5f	0	505	505	41	43	4	4	2023-06-27 14:37:19	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
45	\\x555fc306062032e536a53585138285a8a22899da502c00fb3782e6d5aa7832b2	0	518	518	42	44	12	341	2023-06-27 14:37:21.6	1	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
46	\\x179f639ff4251519fbb67ac95c2f6140450ea75b6d074f6e59b7c3018189a774	0	540	540	43	45	3	371	2023-06-27 14:37:26	1	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
47	\\x535be392026a3f924e99b2fa3092d83dc110c0be9a434b5799c88367deaa357c	0	544	544	44	46	17	4	2023-06-27 14:37:26.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
48	\\x7195ae04e4c3d6951ad54dcfd05a98ee41ea9fb1ce34ec7ed6f68bb5a2790f3b	0	562	562	45	47	48	399	2023-06-27 14:37:30.4	1	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
49	\\x48f3f9d775f6e7749ab69199bb479862b246607765f8fb1dc24b5431896ea414	0	571	571	46	48	7	655	2023-06-27 14:37:32.2	1	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
50	\\x12e402ccfd0e8b5d308d209cb15652c9eb695cacb2d951faa1fc06408fa9fdbc	0	587	587	47	49	12	265	2023-06-27 14:37:35.4	1	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
51	\\x61e5daf546fb3677c82f5c3e5a8fa5f5450587718ea1d6a19048317c491b2dc1	0	593	593	48	50	51	341	2023-06-27 14:37:36.6	1	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
52	\\x3e6bc10c82e9d02e41eb60499b62bf43ec59ca03598a78814cca0aaf813b2d06	0	596	596	49	51	4	4	2023-06-27 14:37:37.2	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
53	\\xac1d9fcab9e8c7b7f862ccdac3c64c3acafe567ca06b65a64be0f56206267c49	0	611	611	50	52	48	371	2023-06-27 14:37:40.2	1	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
54	\\xce10308500eb5e9fcd4b2933f81011908ef2442f7c0e5e3a7172e010aa1bc93c	0	629	629	51	53	12	399	2023-06-27 14:37:43.8	1	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
55	\\xa0c39b2c11a3967b66684cf2e22e529eebbc7623f791174c4cf312231240d86f	0	631	631	52	54	4	4	2023-06-27 14:37:44.2	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
56	\\x5fad8dcff40e93921319feaecee509151ff7b6c77d14eed131e139c5fa4370bf	0	632	632	53	55	10	4	2023-06-27 14:37:44.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
57	\\x7630a041f0084523195b6d9c265bfa0da55b55d5d8f3226b732c1abc3b768841	0	646	646	54	56	7	655	2023-06-27 14:37:47.2	1	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
58	\\xcf30ece411fde0ce7aeb1a84262dc422fc24a1b5e619684caa73570604751628	0	654	654	55	57	48	4	2023-06-27 14:37:48.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
59	\\x3b49e35782457cb54665a6adf3cdd85d59e775b2d2a50332ffad9839322765bd	0	660	660	56	58	18	265	2023-06-27 14:37:50	1	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
60	\\x02361e968a7f53c0732756951f7a4bd8305056c3e1d9bed324428a004f8b8012	0	673	673	57	59	7	341	2023-06-27 14:37:52.6	1	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
61	\\xa471ec7c96caf1010f93cdc4b4170e41babe2f68c39f4b13a63738b4dd636f76	0	675	675	58	60	10	4	2023-06-27 14:37:53	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
62	\\x644cf6edd649001dfb875500ac51f15c74b32229ec52d6c12cb3c46d5b38e5ac	0	678	678	59	61	7	4	2023-06-27 14:37:53.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
63	\\x98a3ac9b16fbf138d2f1e17b63ccd8f241fc9cb94e649a6c4d82888a8e343658	0	687	687	60	62	18	371	2023-06-27 14:37:55.4	1	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
64	\\x2de9c20b22cd3750779e0fbdb924162c9f463eb6ebc314af004b4dcc01a1bd93	0	714	714	61	63	3	399	2023-06-27 14:38:00.8	1	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
65	\\x8742fdec97e46599337b038fe9e9330eb3b2fbb266e06048c06528dd31c5c566	0	724	724	62	64	10	592	2023-06-27 14:38:02.8	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
66	\\x4baebdcff575eea540fbe19e1b55f0a07a359a0449e69c13a6fb0a479c19e4a7	0	727	727	63	65	4	4	2023-06-27 14:38:03.4	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
67	\\x63b775519534f1b2cb37c3571e732f777b3d0e4d720b0aa04eb10e8302ea5aad	0	732	732	64	66	48	399	2023-06-27 14:38:04.4	1	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
68	\\xd0607253e2d0ba889f96f91def610e69ef20c97ff39a854922427a83b0959ee5	0	733	733	65	67	7	4	2023-06-27 14:38:04.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
69	\\xde74da066ab9bf68d064a267677e3eda011ca90a372b3596e76713a798c3de3e	0	744	744	66	68	10	441	2023-06-27 14:38:06.8	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
70	\\x5cd49f0ae921aa02c023c3d6fe845828796a2ab231a6e59f9cd1c698ad5723c8	0	746	746	67	69	6	4	2023-06-27 14:38:07.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
71	\\x06e6beacd697533a3c706a38858ccc92749bb0712fc14cc1da5cc84fabab9735	0	749	749	68	70	3	4	2023-06-27 14:38:07.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
72	\\xa01edc51edfd76195047b705ed98dc9f9157c703d3aeb296aa3825b7880862c9	0	759	759	69	71	4	265	2023-06-27 14:38:09.8	1	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
73	\\xd974f22385269411feff0a52874e8d056003d149f7705d97c86721b184ade37c	0	767	767	70	72	18	341	2023-06-27 14:38:11.4	1	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
74	\\x87c7524a7633278fceda70e81b01e967b5e8a5437b0f4d6a4f2b770b3069f939	0	797	797	71	73	3	371	2023-06-27 14:38:17.4	1	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
75	\\x292f418b58ff7c35ed5146de88d8fac18b8d77581f25f41f5782f45becc615d2	0	820	820	72	74	6	399	2023-06-27 14:38:22	1	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
76	\\x3d0ffff9f88ba72ad274439465ce2745acbcc22fc73671a991fd7498200b945a	0	824	824	73	75	48	4	2023-06-27 14:38:22.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
77	\\x272275be9ac698100361a7d131fe379760be7f2f172841cbeb0c23d0c2f40772	0	828	828	74	76	51	592	2023-06-27 14:38:23.6	1	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
78	\\x0b663722a6ef2bc6e4b4ef4549363285e32cd5a3869c2ebf7c838261fe835fcc	0	837	837	75	77	18	4	2023-06-27 14:38:25.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
79	\\x1c3465aec711a5bc56993cbc643ac6d5fd5100410d14373a693b7982c730068e	0	862	862	76	78	12	399	2023-06-27 14:38:30.4	1	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
80	\\x0e2d7f0e737530be2206b5c9a260292729c536a69d417b50739a72e5613ce6f0	0	865	865	77	79	4	4	2023-06-27 14:38:31	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
81	\\xe45c8a5d2d7d1050f97ddba8b79221e04c0e701f05c6ecef2233806d9cb5e6d5	0	867	867	78	80	7	4	2023-06-27 14:38:31.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
82	\\xc3de1b7987b7f826ffe6b8e4f11e6146d35fce4a28cd9a3e9f7cd97fe02edb41	0	881	881	79	81	12	441	2023-06-27 14:38:34.2	1	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
83	\\x4b0aae564020cc6c56521d6070d130664ecbe7ef6accc6da2169cc953b4ad44a	0	884	884	80	82	4	4	2023-06-27 14:38:34.8	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
84	\\x880e570d62e7bbd283c4c2394f1ea7e4038a01583cb242a161a809ddfb293428	0	901	901	81	83	18	265	2023-06-27 14:38:38.2	1	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
85	\\x71feb0cd42b3a26c32f6b854fbac89d16e5a0ff99ed738c502929245c4d48164	0	903	903	82	84	12	4	2023-06-27 14:38:38.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
86	\\x3e8133317cb1b1a57b5b07e625ad41d6250eee253e62e7a56c699003efe9dda4	0	915	915	83	85	10	341	2023-06-27 14:38:41	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
87	\\x22baf459fb49d46142476091fddca106bacf475f3754d43705991e3d1b0bb666	0	935	935	84	86	4	371	2023-06-27 14:38:45	1	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
88	\\x32ee7699efea6ab754dc2485aaf8b656706e43f323ef0bbab78ad48620b21da2	0	942	942	85	87	6	4	2023-06-27 14:38:46.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
89	\\xbb7ebc40ad70ce65861aa71a0a5513c14221e3df7851081cdf39e596bd74c07a	0	991	991	86	88	12	399	2023-06-27 14:38:56.2	1	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
90	\\x0ba29db14a9f5f5dc00bab1958d51e83f38733f570a72c413cec88d0f9e0c1f5	0	998	998	87	89	7	4	2023-06-27 14:38:57.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
91	\\x2c318f43f871445c796d21c31aebfb2c51b3a5d31348d96b80b83e1405877f3f	1	1007	7	88	90	12	656	2023-06-27 14:38:59.4	1	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
92	\\x4158ebde57617261bbdc9056ccbe22f08015e3b5f997e2f52a270625fc29833b	1	1025	25	89	91	51	399	2023-06-27 14:39:03	1	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
93	\\x7a01cfc81a16331d3e1ec92069d2338457c66b5a81a61de1b43263af97ed8145	1	1029	29	90	92	18	4	2023-06-27 14:39:03.8	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
94	\\x336e70f3d47388c36f74d0b7494f1f3683cd68c416b1432691975b81f6972932	1	1044	44	91	93	4	441	2023-06-27 14:39:06.8	1	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
95	\\x8264e58f9c0e313afe893376aaa96d3a901ea78babe46b445fc57b86536e5baf	1	1050	50	92	94	17	4	2023-06-27 14:39:08	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
96	\\x2049ff4376231b145770dd89736bfb4a3bd1ba9d685e79b07bb42ad7427478c7	1	1051	51	93	95	48	4	2023-06-27 14:39:08.2	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
97	\\xa6a94525e65fc2d236e38528af76cf7bf65d504eb897144e46c0b1416d58aade	1	1076	76	94	96	18	265	2023-06-27 14:39:13.2	1	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
98	\\xadaf57a7b216cc19f8935773daecc47bba6afd5d5f6cf2f2058a3c27cfbeea6e	1	1077	77	95	97	12	4	2023-06-27 14:39:13.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
99	\\xb5564a2d2abf0c586478a5b0b6fe115eb3f9701266ffb0df7192dd7c93bf506f	1	1089	89	96	98	17	341	2023-06-27 14:39:15.8	1	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
100	\\xfed7662521fc171bdcb7de1276720e8ec9b762537a7935477730a51cd4dd241a	1	1090	90	97	99	19	4	2023-06-27 14:39:16	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
101	\\xe216cb9559ee6651c9bc00640e915837197eaaf61856386beafeb11f5a8416c2	1	1091	91	98	100	4	4	2023-06-27 14:39:16.2	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
102	\\xaf3befdad3989a49258da58ef93e7561f08587bc7dac09f1f5c6f386855569e1	1	1094	94	99	101	19	4	2023-06-27 14:39:16.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
103	\\x344292261d6df5ee4365dfa93f5da448e1fd8d464bd43a9fa5199ddbb720ab0d	1	1112	112	100	102	10	371	2023-06-27 14:39:20.4	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
104	\\xb51766c3f805d3d06cf8f48260c82fc041f17d5002584000ecd22f6c46f2a058	1	1124	124	101	103	3	399	2023-06-27 14:39:22.8	1	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
105	\\x5cf7043e41f5c44a08f7ddf0dd8c6591fc35eb4766c71a15395ca57875652a49	1	1133	133	102	104	4	4	2023-06-27 14:39:24.6	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
106	\\xbd9e004080375b6edd84f69610fd41104358b37b344c41089a1d11b8d1bf92fc	1	1141	141	103	105	48	656	2023-06-27 14:39:26.2	1	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
107	\\x8c314e99cf07b6fe0581c12a57b3cfaed4824b0f3d8c37800bded0bcc05d6ec7	1	1144	144	104	106	10	4	2023-06-27 14:39:26.8	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
108	\\x2ac7dbf111691ea2bc2d7e1cf39d1eb037ac27abc111fbae24c2e32ba2a2af21	1	1178	178	105	107	3	399	2023-06-27 14:39:33.6	1	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
109	\\xb99565b5f306ae69e2419e3b8c118717f1e04153c10e703bda4495fe93e654f1	1	1180	180	106	108	6	4	2023-06-27 14:39:34	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
110	\\xf76bbe1aea981e3efa719ce6b7f3e67fe4997014657dea475be40e0799fd108a	1	1212	212	107	109	6	441	2023-06-27 14:39:40.4	1	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
111	\\x16422a13e76c62a2d04c5ae7b3d71075baa92648b1a23000a8184e77032168f5	1	1213	213	108	110	19	4	2023-06-27 14:39:40.6	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
112	\\x046bb50c35c01aa4521bc4a59dcad42a6d52de5c56c22f74cdac6dbd0cbe3d78	1	1218	218	109	111	17	4	2023-06-27 14:39:41.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
113	\\x46e675f6a98fddd35fc7c0c2024f22020c74c63270c64c74bc18cf2b2307ab1a	1	1219	219	110	112	18	4	2023-06-27 14:39:41.8	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
114	\\x560bfe1f26289b85f26b95365a59d2fdf8d7055fc4edcfbc4580165ff7626d64	1	1237	237	111	113	4	274	2023-06-27 14:39:45.4	1	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
115	\\x6d0ea68d9fb13056d5e7fcc69e17cf2f4e544cf74bf8f281b8668bc1bea906f2	1	1244	244	112	114	19	4	2023-06-27 14:39:46.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
116	\\x26dc19871c2434de37bd9351147fbdfb483ea7c624fec73908e6830abebc325d	1	1259	259	113	115	48	352	2023-06-27 14:39:49.8	1	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
117	\\x296d0b30dc81466afe488730c4c4a4fed50e3ac9d96732fe1c8119839b5ac0d6	1	1276	276	114	116	17	245	2023-06-27 14:39:53.2	1	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
118	\\x504573882350adee36bb5ed8779a3068ec4936a93e9d646cb4b04011e5536035	1	1295	295	115	117	17	343	2023-06-27 14:39:57	1	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
119	\\x6f77c40b258bbf29305b3d46c4e20ac14589342ae37ed3bffc2f02b6353b27c7	1	1315	315	116	118	4	284	2023-06-27 14:40:01	1	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
120	\\x2a8a05ed5fc10ba550ce9760598869989895db4ccfbaca90f7120f436cec75bf	1	1335	335	117	119	19	258	2023-06-27 14:40:05	1	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
121	\\x3f7d39821d2edae2c4f98138d7880a6131110f9a482ec480c5f91c0f9c38e0db	1	1338	338	118	120	51	4	2023-06-27 14:40:05.6	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
122	\\xb31454fd41c8b9e8c8617d9b8cd47158aeb0b51eb60238b43d14a01bddf63d3d	1	1343	343	119	121	12	2445	2023-06-27 14:40:06.6	1	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
123	\\xa6ad1e79be9d2b7f1a873616baa7f095121aa806a5e7b95cd15554205a4e4b55	1	1354	354	120	122	3	246	2023-06-27 14:40:08.8	1	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
124	\\xc4ebdd4a1315fbae6343789d4f15283e676725b49ee2651cb8e1d1707166aa8a	1	1367	367	121	123	51	2615	2023-06-27 14:40:11.4	1	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
125	\\x34db4bbd928f60f328cc2c5fc82fed64c0dbef22e1ebb531fdca1ff8f894b317	1	1372	372	122	124	48	4	2023-06-27 14:40:12.4	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
126	\\x14c135af13fe626e79ee656d6337eb18950dcce9697e46adb8e8ad8f4bc91063	1	1394	394	123	125	12	469	2023-06-27 14:40:16.8	1	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
127	\\x6d38610f49352e666a14f72c7d93406c1559fab133a68b92ded791b3d34697a3	1	1402	402	124	126	10	4	2023-06-27 14:40:18.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
128	\\x8d8ae0d992f513fc03e4d4d1b1bc0e0c6de34a4e14254a5fa8aeb8df17b7a7b9	1	1403	403	125	127	3	4	2023-06-27 14:40:18.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
129	\\xe1fddfe7cc82dc48091c65780f6f3dd5c1b6c1383ff88e2513d8b2beb946b0a5	1	1438	438	126	128	4	2055	2023-06-27 14:40:25.6	2	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
130	\\x136b369d93d451aea10ad8823c8a208ac037208a8e1bfcab58c02a5fedac1b44	1	1485	485	127	129	3	4	2023-06-27 14:40:35	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
131	\\xf7fb2ed5811c1414f779c8f789d8785e3b86bf18e95a733df596096e82301004	1	1493	493	128	130	7	4	2023-06-27 14:40:36.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
132	\\xa2f57acb7f53c4deed80c7df80ba5aff488a883c555b157bc9d3851f28b83a66	1	1497	497	129	131	19	4	2023-06-27 14:40:37.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
133	\\x2e5fcd81f40ab383e4b54f00581e7dce2955010af19f8284f6ac264230c788ae	1	1500	500	130	132	12	4	2023-06-27 14:40:38	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
134	\\xdf351007ad73c4bb84da2b9488b57959f5633095cc590bef9a2f88cea4382270	1	1501	501	131	133	48	4	2023-06-27 14:40:38.2	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
135	\\xf9bbb5aa3c341ca9172a74fa643f3f9773d1b85cfb2817a47c0c7a3a43f54486	1	1510	510	132	134	18	4	2023-06-27 14:40:40	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
136	\\x8e8613095ec80acac308b7e32baf009297ccb490952cea523a999e39f7d6ad95	1	1516	516	133	135	17	4	2023-06-27 14:40:41.2	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
137	\\x4d5409620b6512215dc3185abf0b5856296e15d10d076a4eab805fffe89d2ef4	1	1522	522	134	136	17	4	2023-06-27 14:40:42.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
138	\\x3813eca0039673b3286e0ec7c32af6ec621943770ca3e1247f237994f4b3159b	1	1526	526	135	137	51	4	2023-06-27 14:40:43.2	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
139	\\x1a0c59b1afa1b3ce9188b9d76f0a5c026c08cd10eb53566fc7ea72c723652fbd	1	1534	534	136	138	18	4	2023-06-27 14:40:44.8	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
140	\\x6175b643d3cf390bb613a8ff4b679801efdafa4307b158d75eb07f33bc5e90ec	1	1537	537	137	139	17	4	2023-06-27 14:40:45.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
141	\\xbecc3fb0d9e0d8a4d9dd49c2e05f36da1ea8858e12247535edf19cc0e17afc12	1	1539	539	138	140	19	4	2023-06-27 14:40:45.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
142	\\x8520e9767ffc9102b1e2a7a405db7763a603974a389dc444eaad849378823680	1	1578	578	139	141	19	4	2023-06-27 14:40:53.6	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
143	\\x7e1a7bb56f4f4fd7b4217f5473b8d503dcaa886571ea66a5d2cfbcd4f32f16f8	1	1589	589	140	142	10	4	2023-06-27 14:40:55.8	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
144	\\x75c435fa02d8b8cea4dc6d182f2f21b798671a5c2b643f327b157a5ece30fd05	1	1597	597	141	143	17	4	2023-06-27 14:40:57.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
145	\\xd4d5aea1ada64c8ab6f654171debb6a279d0889faf0b98f6a927ccd100bd4aa6	1	1603	603	142	144	7	4	2023-06-27 14:40:58.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
146	\\xc58c9c57af2103e0c6a712d835b21de67b52293c3714141e6a12f07106c9f819	1	1622	622	143	145	19	4	2023-06-27 14:41:02.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
147	\\x848692eea72e456f3f44d656a0cb6ae1c6fb06cb8242d08581ce85915e6c1516	1	1641	641	144	146	51	4	2023-06-27 14:41:06.2	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
148	\\x4f2ed5576a54eedf767a5b0f1dff38f6fcfedea19db3c496cc56672bbcf3528d	1	1643	643	145	147	12	4	2023-06-27 14:41:06.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
149	\\x76420dedc60580ad6d5cb30d89262a51b0c5a5c39e17b5b27aef4a2876a01027	1	1688	688	146	148	6	4	2023-06-27 14:41:15.6	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
150	\\xa66d562eece55aeebf5464d89a9952e8aa752161677bec7d4b4545fe67935ba4	1	1690	690	147	149	3	4	2023-06-27 14:41:16	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
151	\\xfc466cb75e0905d68b66441ca021e37888f668a9b340b0d4ef427832c39c297a	1	1696	696	148	150	12	4	2023-06-27 14:41:17.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
152	\\x41b08545e1a45479e9d88a6dbe06e8e875a798455bb652e3894a44c63f49b5c2	1	1697	697	149	151	48	4	2023-06-27 14:41:17.4	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
153	\\xbbcd043c895c994df6d5db5f4b2be72f00f1b9b13ae54ad12f91d90e5607639b	1	1707	707	150	152	51	4	2023-06-27 14:41:19.4	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
154	\\xe3682dc6e1b6435eda8a95d71566fe16ba9b30b4a1ffd90a30df6fed0ae78591	1	1727	727	151	153	17	4	2023-06-27 14:41:23.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
155	\\x3cf504751611119d3da64436bd9710ef419394f699578f4beb04ab2c4ffdb629	1	1729	729	152	154	6	4	2023-06-27 14:41:23.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
156	\\xb5f9e1a3cf420fe78e3137914a5e5ccc3ab64e9cd488a433f4ea3e08d275bf02	1	1741	741	153	155	19	4	2023-06-27 14:41:26.2	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
157	\\x23d7542e2918c4eef9f755379a78b48469e756e78d0f2bfd949f729ffbb1e9b9	1	1743	743	154	156	10	4	2023-06-27 14:41:26.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
158	\\x48b5fda2b75edcc1024b9e467fcda86e3cac8e1a6bcb16b7c705deecf161514b	1	1758	758	155	157	18	4	2023-06-27 14:41:29.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
159	\\xe317c2fa2842c92c26ce67a1c1099ec510d59b32a7077127e09672e99e8184ab	1	1781	781	156	158	48	4	2023-06-27 14:41:34.2	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
160	\\x243cbd7e01bf3143a609f019744542cf2e0d4c52c26ead9c38090516e6cbf405	1	1783	783	157	159	51	4	2023-06-27 14:41:34.6	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
161	\\x51887a3de6ddf9174b9195acd0bc86bce1f88d47e89db271977a30888eb382f7	1	1809	809	158	160	51	4	2023-06-27 14:41:39.8	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
162	\\xc840ec01e403120cf22e9ebb8c55cf006641d41a583c0cd9afeb5d6d620733e7	1	1840	840	159	161	3	4	2023-06-27 14:41:46	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
163	\\x8f67ddec207fe8081213bec41fe7ee4fa1625968250df83d171526dc6f0d3367	1	1850	850	160	162	17	4	2023-06-27 14:41:48	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
164	\\xb2b8437cfbfc67305b31ff40d776b03a3852680d69663623e09212602a8a3fb2	1	1863	863	161	163	3	4	2023-06-27 14:41:50.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
165	\\x497c8b7c36417e845d091543905be164d2235840f6b31878c1ca72f128e7a245	1	1897	897	162	164	6	4	2023-06-27 14:41:57.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
166	\\x8c38f2029c56d31fd7520489bb028a2505dd02bb3bf7bff570ff058d3586f6b5	1	1903	903	163	165	4	4	2023-06-27 14:41:58.6	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
167	\\x98f3b8d39e3298c90f75c7ced21ca141dc81bbd2895fd741ed1cbcab91d84efd	1	1944	944	164	166	4	4	2023-06-27 14:42:06.8	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
168	\\x00602a6e533ce0942dcea4a490ffbcd26c07d10c0c5a55e3a939f03c1c209cd5	1	1973	973	165	167	10	4	2023-06-27 14:42:12.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
169	\\xa61673f28baca17910e69a8b272817052cab5012d62e35d80b3ca9d09fd2087e	1	1980	980	166	168	7	4	2023-06-27 14:42:14	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
170	\\xfb92927dc0314e8a6a755d0d155f59980443f4453cf618d862beaa858df43f55	1	1987	987	167	169	17	4	2023-06-27 14:42:15.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
171	\\x24a734d76affc3e6a7986197a31ced91535b001509a952768f223c56a0c7c13b	2	2027	27	168	170	18	4	2023-06-27 14:42:23.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
172	\\x75b793ce87814c94f2f1b9c0f84358620c9bcf0d2ab56a4f7c3766a4ffa731cb	2	2031	31	169	171	7	4	2023-06-27 14:42:24.2	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
173	\\x4299179ec074436d4fb5375f4157c1e2c429641c98264130c364848d497db171	2	2040	40	170	172	12	4	2023-06-27 14:42:26	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
174	\\x6a74151ef04cb60af11778368b47c9cab89700e47a526caf1911857502897c42	2	2062	62	171	173	17	4	2023-06-27 14:42:30.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
175	\\x180f7702ac97f4478fecb031ccbd3dec1e3171c1a3dc820b791d5d32a844b18a	2	2063	63	172	174	17	4	2023-06-27 14:42:30.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
176	\\xebed566f3f907adaa3942e876cf5063c800221f36a53ecb1ca1db65ddea9be1d	2	2081	81	173	175	3	4	2023-06-27 14:42:34.2	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
177	\\xded68989f165d6432a38a2f48fc06032ebf49bf2669edd9807b71f746c022f97	2	2083	83	174	176	18	4	2023-06-27 14:42:34.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
178	\\xff4cdf9a6987b8fb59bf1f85b03f5e85640db3fc3b17c603f4d12b2eaf9ecd1d	2	2089	89	175	177	3	4	2023-06-27 14:42:35.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
179	\\xf6254cd116b47122aad5d689d55b34b9e5e45f5910753dca31161f67f9bd2ea5	2	2104	104	176	178	12	4	2023-06-27 14:42:38.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
180	\\xdb12d018db01322b48ae46b077ed6b1df672ddfe56d0266ab555461607706468	2	2105	105	177	179	7	4	2023-06-27 14:42:39	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
181	\\xf11cc54306385a121513d7819855af360a5872a340d4c4a1467d655f90a76fb7	2	2113	113	178	180	51	4	2023-06-27 14:42:40.6	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
182	\\x0b0e174e6559b8f0670f6aa07376c14acae18d0cbd4a53a92450100426dfc4fa	2	2115	115	179	181	17	4	2023-06-27 14:42:41	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
183	\\x37eeb53d50421ae9ee25d09abf016de2ae68a766e0ad3457f42a5216b9162d0a	2	2117	117	180	182	17	4	2023-06-27 14:42:41.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
184	\\x5daa6e5bceac31f7c478f456e7c5c97b996ffe92fe8e76911833aa3678b2fb82	2	2124	124	181	183	7	4	2023-06-27 14:42:42.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
185	\\x33ea6b5aabaf54e0b45a7933566dc17e4b3b70656ecb6c9b1801ecfb11c7267e	2	2134	134	182	184	10	4	2023-06-27 14:42:44.8	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
186	\\x9534548dccc4aca4ead3febbb26b3fe1c3f08bc2dc3d0443ebe19e16c773e349	2	2135	135	183	185	7	4	2023-06-27 14:42:45	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
187	\\x9f73f40397173fce14c2e099f3cff2e52becae0935332d8c164a65b8828570d2	2	2150	150	184	186	7	4	2023-06-27 14:42:48	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
188	\\x56146973e56f8fb27b64eea50087a268e95159753943e6198f05cb96e4be9933	2	2161	161	185	187	4	4	2023-06-27 14:42:50.2	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
189	\\x7e91c1bf70f833e1de2f6ba5ff7aa315a9bbcc24bd06c9b1cd6aebdcc6e8cc90	2	2185	185	186	188	10	4	2023-06-27 14:42:55	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
190	\\xf2dfebe0f25c04d45f3fe00e79987b8539a31d7ac81c4be72067b73808f744d5	2	2189	189	187	189	48	4	2023-06-27 14:42:55.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
191	\\x261b7ae92b9ed3c7f7a9019b6e2b104d1876bc7c0910d036e0dc30ebade771f2	2	2246	246	188	190	48	4	2023-06-27 14:43:07.2	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
192	\\xa984b9c35d757161f7308652344cdb109dc384b1bfab292bd8feb9b047fdeb6e	2	2247	247	189	191	12	4	2023-06-27 14:43:07.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
193	\\x940fb4025c217093f98d439e507fd389ebd434fe9610f25da1d5e870c7a85998	2	2259	259	190	192	19	4	2023-06-27 14:43:09.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
194	\\x7a5c72cf746137f27e7fb577faf403b47ded185e5027d7ef23c0933964cea5e9	2	2270	270	191	193	10	4	2023-06-27 14:43:12	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
195	\\x1b773dc69a485333cc446b7ee1a65c56e086f2929af7b0edddf5889df3a45655	2	2278	278	192	194	51	4	2023-06-27 14:43:13.6	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
196	\\xa4e4ab2f5add36611abda4e6df8f60008a782af89471a64a587b6ef5914fb162	2	2292	292	193	195	48	4	2023-06-27 14:43:16.4	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
197	\\xc48098bfe520a724178f2095449d6a1e0a35a6f3912499582f1f44c9ced20563	2	2299	299	194	196	48	4	2023-06-27 14:43:17.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
198	\\x051494eba139666d984f9a030fb91c6cfc4b62160ebb33ceee54ebb44e5b7031	2	2325	325	195	197	3	4	2023-06-27 14:43:23	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
199	\\xb523018c876d60562f4d2d1bdf4dd97261dbef05e873668e54de8d52be2fe116	2	2326	326	196	198	51	4	2023-06-27 14:43:23.2	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
200	\\x3450d062ee845f317e84806083c47fff1872c6db0c457f0d7772d6a64c00740f	2	2334	334	197	199	6	4	2023-06-27 14:43:24.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
201	\\x2fd4e26b6f0866f603b354e72377398c05d8fb237e9fdb0f0edb4d80f7951dea	2	2360	360	198	200	51	4	2023-06-27 14:43:30	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
202	\\x5e858cda6ed6ec5310e4c018b482d9d69d5215245ea312a2f3b7b589dd3999f2	2	2373	373	199	201	48	4	2023-06-27 14:43:32.6	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
203	\\x234d920a0242e03f4cb45d792375fb9f34e42ac491610996decd5344623ec286	2	2374	374	200	202	7	4	2023-06-27 14:43:32.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
204	\\x4bf7ec8fd0d24494211a3e1a4bb8869b95f1bb70e48e01f1356d3b80f614d8e3	2	2377	377	201	203	18	4	2023-06-27 14:43:33.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
205	\\xb8d7881393a253c3e2f272a934c9aff9f02719e58d70e9706d1e5df57851ad63	2	2390	390	202	204	18	4	2023-06-27 14:43:36	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
206	\\x8e090c22f55ec6a47f3dc7818ec95c8f4fc183a1dfd0627dccd89a9657f7c2ec	2	2400	400	203	205	17	4	2023-06-27 14:43:38	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
207	\\xba35928067618b1e80de4755b646fd8d8ec62456741fb65247da523111a720a9	2	2444	444	204	206	51	4	2023-06-27 14:43:46.8	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
208	\\xc796a60262ad4da4761385dd3f45d477a2402253132e68922d5f5baaea55acc2	2	2451	451	205	207	18	4	2023-06-27 14:43:48.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
209	\\xcf00b86b5d194f174f0e035d1c7f33f239b5bade9fce1ef63e7e0a1c36af022d	2	2455	455	206	208	6	4	2023-06-27 14:43:49	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
210	\\x938b25c9f0cf5bb625bb1e18f1143f8911731264b5c2fad80e247e5b4b2e23d4	2	2467	467	207	209	10	4	2023-06-27 14:43:51.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
211	\\x5fb517dbef4f4a273f1ebd475a76808f2a13214f72debfa096ff239c3408764d	2	2468	468	208	210	7	4	2023-06-27 14:43:51.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
212	\\xc75e171503cba1981a3d4b98040a1d5ecc85e70f01dadda96c604ecc6ec2d404	2	2475	475	209	211	18	4	2023-06-27 14:43:53	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
213	\\xb63897a67f1bb0e3bfe00f685547f4d35e0b844c96d5ad7543c40db1d626493c	2	2478	478	210	212	3	4	2023-06-27 14:43:53.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
214	\\x65613f265c05335c99922123c3f8e2de045743405cf4e20c0811f9bea5bf49bc	2	2480	480	211	213	17	4	2023-06-27 14:43:54	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
215	\\x7df9fb9148749d2bd0b507ef39c4f2d5340449a6e4dbf6baf5b1310e856dbc25	2	2484	484	212	214	17	4	2023-06-27 14:43:54.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
216	\\x4728fa8097cc7bf83b5794d2e8dcd7bb677c93cc8cab71ae3ee778e94f40a025	2	2497	497	213	215	3	4	2023-06-27 14:43:57.4	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
217	\\xe3903a3b226c53aac8fe005a144a2c22fa7d776ed858593f3f962753b6e93d55	2	2512	512	214	216	18	4	2023-06-27 14:44:00.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
218	\\x4b89bfc0674210e245c52dccf372a6735e288b1289fb074f58ecbe9037edb822	2	2514	514	215	217	48	4	2023-06-27 14:44:00.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
219	\\xeb4185d6ba18333d64b8ba88709d18187db4578c101747e1d993eb7bab782021	2	2528	528	216	218	12	4	2023-06-27 14:44:03.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
220	\\xf105c9e72fb152cf510ba0b036a61d4ae7126e08136a1b5098b3f729e0110e51	2	2540	540	217	219	18	4	2023-06-27 14:44:06	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
221	\\xb364488ebba38547d4457f9df5c9dc5a96354e5de3bd3c1d0a229972e0011453	2	2551	551	218	220	7	4	2023-06-27 14:44:08.2	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
222	\\x753a34cecc698182bae6196832e80ad8a49610c7eb5fe88e898817d2d66b2239	2	2553	553	219	221	17	4	2023-06-27 14:44:08.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
223	\\x8cdaa6ad09cb2610e8bd880728133f25b5fed3e954edf9d458cff9fcdc0afd0a	2	2574	574	220	222	6	4	2023-06-27 14:44:12.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
224	\\xd571d029854edfd4a67241bffce0fb77bb36078051a822c9612b90d191c3b6c0	2	2576	576	221	223	19	4	2023-06-27 14:44:13.2	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
225	\\xc9d345b749f497aa9c9dd218b0047b571915768f58393cad90d3ef4940a3e6c5	2	2580	580	222	224	10	4	2023-06-27 14:44:14	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
226	\\x83155b4fe7db19cdd7584e2c196ab06b32cbafaaf999cb8bcce8a24be0a01d95	2	2581	581	223	225	12	4	2023-06-27 14:44:14.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
227	\\x62b76e5d72ad898c6a2c0eea8fd70c883dab5b89538471578a37e2cf6c5773af	2	2583	583	224	226	12	4	2023-06-27 14:44:14.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
228	\\x76abcd1c82723dd991ebb93ec8d6e2b00e974f3426654ff1d702353ca6d93201	2	2611	611	225	227	48	4	2023-06-27 14:44:20.2	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
229	\\x2300680509fb842794fbdfdee3e6cf98b0cdfd4b4be4e010082d07c7c02f7f65	2	2647	647	226	228	4	4	2023-06-27 14:44:27.4	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
230	\\xb495d19fc151a44fadc9d4a1513122455ba98dd4c0d984ec40e8bebc2589ac12	2	2668	668	227	229	6	4	2023-06-27 14:44:31.6	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
231	\\x837488962e27ae34f37a6d1cd004071a62fe3ceab57ffaebd69698ee03b6710e	2	2672	672	228	230	12	4	2023-06-27 14:44:32.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
232	\\xaefcbc11d64c3dc1c9f136a11998712ad934de6d89f50e893f0a4b327354d1f0	2	2685	685	229	231	18	4	2023-06-27 14:44:35	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
233	\\x0986949594d1821e4da9e5a14688ea3b40c01a483fbf7f1bfbe85286e2011823	2	2699	699	230	232	3	4	2023-06-27 14:44:37.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
234	\\xa37ce3552fb66d9763a61f33b55ae8da8a766c4a476930cf418febe5563461bc	2	2718	718	231	233	3	4	2023-06-27 14:44:41.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
235	\\xbad299d9fd8d2a6316efacf9f34fc0c92b112088e7b82fbbf3724d8840bb2fe4	2	2719	719	232	234	51	4	2023-06-27 14:44:41.8	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
236	\\xaea2eedbb21af0005b2b345e32359b2b010a7c8d0e03e70116559ceebe8b184a	2	2738	738	233	235	18	4	2023-06-27 14:44:45.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
237	\\x17e52dfd2c68da388d92097a77960a0550769df3c889fb9c0ad9e60711059a27	2	2745	745	234	236	6	4	2023-06-27 14:44:47	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
238	\\x72d2b44456ac8ae2e2b0ec429e523190bf42c45cb80eda00e25d0d014ad5b2a9	2	2753	753	235	237	3	4	2023-06-27 14:44:48.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
239	\\x21ea5c6d6bbe7d79ab3ca3d3d966f4f312993d59e4d959f0007e33b4c2f50001	2	2767	767	236	238	19	4	2023-06-27 14:44:51.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
240	\\xeeed23e9331cace40e156bfee9152948729f296acd82bf68dc8d44c9faf6baf9	2	2772	772	237	239	19	4	2023-06-27 14:44:52.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
241	\\xfa463c0a63716cd40f97df0250252aa567b26228d5cdc1bae55b74eb1d3d2f03	2	2790	790	238	240	17	4	2023-06-27 14:44:56	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
242	\\x12f62cd40e3bbd8d0f0c5d9891baa9fff489955c1d6567c9bab3feb6be0c36e8	2	2799	799	239	241	4	4	2023-06-27 14:44:57.8	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
243	\\x8d3fdbf4aee6b32f559996b1334f2bc625179d3a5b9119fb9d46d9083bb83fe6	2	2803	803	240	242	48	4	2023-06-27 14:44:58.6	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
244	\\x9dd3e1197e9cae95c273d805dd7a110a79a7fa8b58508bb8b4f98f1b5737dc2d	2	2806	806	241	243	10	4	2023-06-27 14:44:59.2	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
245	\\x258f674d2e6cedd6a81c52b3d12e6bbf3b2ef64bbab49e90d0eb81a6795a1e9a	2	2815	815	242	244	19	4	2023-06-27 14:45:01	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
246	\\xba5d70183f57396895d06b570ade59c6d3c985b002b23ecdf2027dcef8496353	2	2824	824	243	245	6	4	2023-06-27 14:45:02.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
247	\\xe4824f376937c239e67161eb8d32560a6448959671b5be7e7596f158d455fc3c	2	2832	832	244	246	19	4	2023-06-27 14:45:04.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
248	\\x71a5e3160e054bfac51d48bec549f8803cab6cb04ad0a2a6dbb0d43f75aa6bca	2	2833	833	245	247	10	4	2023-06-27 14:45:04.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
249	\\x90c9fa51b8dc4452cbfd9e7e1a1af1eeb46fc8425166e96e84b9b6c94a360cef	2	2839	839	246	248	12	4	2023-06-27 14:45:05.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
250	\\xf03c315b99ab834eecb2e1e815d6e0cbd1a5be7832fc18bad4f85642ee1a092d	2	2858	858	247	249	12	4	2023-06-27 14:45:09.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
251	\\x92345db20a35114b49fbeaf20468b204265d9bfc5cca0562e6bdc09e0f682443	2	2878	878	248	250	10	4	2023-06-27 14:45:13.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
252	\\x0d4b88a3e48f292fc4b6270dbf1926d8f63f05a040a89a42545ebe7079173e36	2	2892	892	249	251	51	4	2023-06-27 14:45:16.4	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
253	\\x3af520cbe14435f2193bdc96971626fa6ffb17fdfd0e0e562c463a3ffa22476a	2	2893	893	250	252	12	4	2023-06-27 14:45:16.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
254	\\xd470e5276ed752198d747c6785ac7b30d2928c44f21450dc12e603fd744c192c	2	2894	894	251	253	51	4	2023-06-27 14:45:16.8	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
255	\\x45bb3de4a3f13787ddfb8fb8f42ff84b05db7992fc34c8e566b17f4d9dc029ad	2	2907	907	252	254	17	4	2023-06-27 14:45:19.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
256	\\x18e93e4b3eb0a8285b493718300acfecc83cfa99bea27b307ccbb64bcd601242	2	2921	921	253	255	7	4	2023-06-27 14:45:22.2	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
257	\\x362f7e023bbafce1c9a071df51f4d4fce5167b138bbd3dd7f78e925e566000ce	2	2936	936	254	256	19	4	2023-06-27 14:45:25.2	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
258	\\x37e89b5cdbd594d094fcddeeee018229acf2d80a73f0a2fa68d9447a8b569e1e	2	2937	937	255	257	12	4	2023-06-27 14:45:25.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
259	\\x598bac6a90d881012f24991e88660a549d6bf171df0295bc61880a7cab468d01	2	2952	952	256	258	48	4	2023-06-27 14:45:28.4	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
260	\\x4e54b05faf7f88ecaec98c8b096d03a6659f4e791925377d9a4175e1fad26ce5	2	2967	967	257	259	3	4	2023-06-27 14:45:31.4	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
261	\\x9ab7e2d7f5c380969539d949cad25058ba7610d5d9ff796a2ae69a3f0f22b8aa	2	2979	979	258	260	17	4	2023-06-27 14:45:33.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
262	\\x92123bccf3e803ade23303e8877dfd3908e2145076c491b042bd1898dbc3e68a	2	2984	984	259	261	3	4	2023-06-27 14:45:34.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
263	\\x66293caf6a334e7d9354d198a1060cca3c018282f7e4fc55a1f095351e7074e7	3	3022	22	260	262	17	4	2023-06-27 14:45:42.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
264	\\xe22e94502fba2c9c2c42bc1bb55556455285919bb804eda2cc32f68efd3b9743	3	3028	28	261	263	12	4	2023-06-27 14:45:43.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
265	\\xa9f613da7830d02ffeeb1dd866a2d813b5eb05fdc6dbf1ddfe61891cfbff7ab0	3	3034	34	262	264	12	4	2023-06-27 14:45:44.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
266	\\x3f416c99ea596911d95c924088485898be2cfc7a33cc1f0ffb3ca328fe8f9258	3	3040	40	263	265	10	4	2023-06-27 14:45:46	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
267	\\x653907b2006324113deaaf339f7231478b4f266281d4491e06b9db7ea4578ef3	3	3044	44	264	266	12	4	2023-06-27 14:45:46.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
268	\\x16493a9089b4aad6dff8d006efc9b7d0598d0957f1fdc7e61d5638cf5d0f0815	3	3046	46	265	267	17	4	2023-06-27 14:45:47.2	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
269	\\xc7f9fdb3a53201731732d358722fe20b048e948e3d7035e44b2e63731801caa5	3	3053	53	266	268	18	4	2023-06-27 14:45:48.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
270	\\xb46a645173677e5afb0f2f36b48b20b79e502497e4da70b8899f5d5445af165e	3	3055	55	267	269	19	4	2023-06-27 14:45:49	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
271	\\x78b7ef828857c0f77d8302725ea48309dda6ced568146196ab610f2821e84dbc	3	3068	68	268	270	19	4	2023-06-27 14:45:51.6	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
272	\\xc6d6e85cd844191d5931c5d1fd54fa6538eb42e2a19cda40669f746f76bedc07	3	3069	69	269	271	12	4	2023-06-27 14:45:51.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
273	\\x4cbd22bfe68d56efbba94d9bbbcb65a8f6f52ae36c888ec589861fa118d1910e	3	3078	78	270	272	6	4	2023-06-27 14:45:53.6	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
274	\\xbebc54a404aea0ff6ba36dae6c61fc0ef04eb34ce6ec9ec304f32f7dfa8aa382	3	3082	82	271	273	4	4	2023-06-27 14:45:54.4	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
275	\\x5835d32789fdc9fbe77ea0cb9cdfe0fb913aea0f743dc130c64e02e20d768cf1	3	3096	96	272	274	48	4	2023-06-27 14:45:57.2	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
276	\\xc09fe62273392ea6639a327f0c678e0f6771334a830cecfa9f818f325352af5c	3	3109	109	273	275	48	4	2023-06-27 14:45:59.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
277	\\xc7b19fef88637474e1ecf2a4652e234e4c9b6b7df577033d7f52ac5d98a65cd1	3	3121	121	274	276	3	4	2023-06-27 14:46:02.2	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
278	\\x8e4a428998866666f8046c2ba1bcea03faef26bdeaae2ff8023ac43435e847de	3	3132	132	275	277	18	4	2023-06-27 14:46:04.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
279	\\x992bd0f76a8d8a878931b9e7fef4d18e4555895bfa754d8ba329407190eabd31	3	3140	140	276	278	51	4	2023-06-27 14:46:06	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
280	\\xfcb2b57dac855323d654fe29060eee2eef62d6831644ea2dd9e8655f90736512	3	3162	162	277	279	51	4	2023-06-27 14:46:10.4	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
281	\\x4b63c6c68178328bdd2b1632ed0195bb4597b21c5078ebb7a76dfd9a91372fd1	3	3180	180	278	280	18	4	2023-06-27 14:46:14	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
282	\\xd1911d4d5d38cae2b4461a6a83a8f638ca51925286c8d24a0fd95b7e403f0cf9	3	3182	182	279	281	51	4	2023-06-27 14:46:14.4	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
283	\\x7e9861fd5a0dad7f294899ff8338de553e5a0dfe99bbebc19d8b704b3db48adf	3	3187	187	280	282	10	4	2023-06-27 14:46:15.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
284	\\x487667410d15876ed16193e3bc229036b65dfa1976fe95a038bae49bb3ecd43f	3	3189	189	281	283	48	4	2023-06-27 14:46:15.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
285	\\xffece8d14e01537f0286d195a989bad1a83a2560f7a6ad19e966995939503b92	3	3204	204	282	284	3	4	2023-06-27 14:46:18.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
286	\\x34069296f817f7e8144443417f71187f8c8ce57d3199dd9359113f0c6eefcf80	3	3223	223	283	285	18	4	2023-06-27 14:46:22.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
287	\\x132f9f9e6b070caaf6db166e413ebcb630b968c0f2c927674f2a598cf3770630	3	3240	240	284	286	17	4	2023-06-27 14:46:26	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
288	\\xb64b4ee3b7109a9f05de1dfa1a01d5ad4ca93489fc192039a9588f4c79286a39	3	3267	267	285	287	4	4	2023-06-27 14:46:31.4	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
289	\\xd687d5698080eb136ffe687fbede7549fd79d0bd24bb112a29c31f6ebf14a3a2	3	3280	280	286	288	19	4	2023-06-27 14:46:34	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
290	\\x7bc97b7128944e0e41224933845d8c4606992f11d17291ec15f62b34d39a802d	3	3295	295	287	289	10	4	2023-06-27 14:46:37	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
291	\\x88c5a1bbe0603af9ea8cf01d7396d3af78e8da52993b4f64951f32c7d7e43051	3	3316	316	288	290	3	4	2023-06-27 14:46:41.2	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
292	\\x4cd83fa0a6b282ff63115a74cbe901ddf44923afa18797fe01328d2edf817ee4	3	3324	324	289	291	18	4	2023-06-27 14:46:42.8	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
293	\\x835ae113e99b701434ae9cf01741d8276918d4855a49b274fca2d8a6af913758	3	3352	352	290	292	4	4	2023-06-27 14:46:48.4	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
294	\\xad1d407699dae4693139378034c5fbd18f6018f5e1adbd2009db7d12641768a5	3	3357	357	291	293	10	4	2023-06-27 14:46:49.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
295	\\x3ae6d53e213eceda5486112827a4843881c8a13abe7d817a491af69e16cc9a42	3	3374	374	292	294	17	4	2023-06-27 14:46:52.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
296	\\x01a0cf7225d7755148f374f879826e93c9c4a8bd9806fd2777c43b6825e1a343	3	3381	381	293	295	18	4	2023-06-27 14:46:54.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
297	\\xcca356ea523bef69e4562babea9bc148f81d7cde2aa324bd6e054fc5da4b0b6f	3	3384	384	294	296	4	4	2023-06-27 14:46:54.8	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
298	\\xb42f61d7c9f17c38322dca3a41e229829bc63cdeecd9fce743c6c03120a8f91e	3	3405	405	295	297	18	4	2023-06-27 14:46:59	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
299	\\x0c53c6096aaa21e1426e5798717ba67746d112e67ae8dcd6cbe6c76a9993c883	3	3417	417	296	298	7	4	2023-06-27 14:47:01.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
300	\\xb5d0601272e1ced1fa7113ccfd138ff5884ebd055fe0d195e5173124a0aa3382	3	3420	420	297	299	7	4	2023-06-27 14:47:02	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
301	\\x713bd258d6836d528468966e2e8d2de5e2c4c00a56186c294fb3292a57f9df0a	3	3421	421	298	300	6	4	2023-06-27 14:47:02.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
302	\\x59a8494ba4a0fb8655c914efd4f0b40426a13f6e73ebe86e97734f27e005401d	3	3438	438	299	301	48	4	2023-06-27 14:47:05.6	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
303	\\xe1cd08ce11bf69c9e76d12268237485273b46b33a87fac006915470c5d27949e	3	3443	443	300	302	4	4	2023-06-27 14:47:06.6	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
304	\\x1b59071d4a487ab10dab74923796bd2da588990e07ef5cb291ed2948941d1064	3	3450	450	301	303	3	4	2023-06-27 14:47:08	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
305	\\x9dc2ef77fd660d21822f8c56021f5558cd25d8a34a578ad2843160ba5db28d7c	3	3463	463	302	304	48	4	2023-06-27 14:47:10.6	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
306	\\xdb8d1a31e130b9d4e87ffc115c2e076bfe0e85c2aec9c1e27472ac9899c933cf	3	3472	472	303	305	12	4	2023-06-27 14:47:12.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
308	\\xc7cfae5a50770915a2c45899db823d6c756d653d785aa6fde625639403f481a6	3	3473	473	304	306	7	4	2023-06-27 14:47:12.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
309	\\x14926d08c5d1f89efde0e30dc04dffedf6a140837aaa2e4d0d7cb1e14d3f29ff	3	3498	498	305	308	19	4	2023-06-27 14:47:17.6	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
310	\\x14f596f038f3b2a779a2b0f5f629b22b5aba4730f023600a3d406fe14a9d756f	3	3500	500	306	309	4	4	2023-06-27 14:47:18	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
311	\\xb15650f5972d44694560a7caf6c0f04a947f40ca17148db306110f614bf43f9e	3	3505	505	307	310	17	4	2023-06-27 14:47:19	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
312	\\x98db8a079a52e3c1721e863802764970fd116931032715154db5e422a938f40b	3	3510	510	308	311	19	4	2023-06-27 14:47:20	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
313	\\x1b7c20d29723530c127250f44625f36b25e083d46f3b545776950915db69603d	3	3513	513	309	312	10	4	2023-06-27 14:47:20.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
314	\\x15eec63b765241b5edadbdf82ab45bbb663ba7788453e8c1692ec7aafc4ebe39	3	3514	514	310	313	48	4	2023-06-27 14:47:20.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
315	\\xbde94bbffaa96727a0e962bb606c4084fce52be0e5277877eaa946923d63c361	3	3518	518	311	314	51	4	2023-06-27 14:47:21.6	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
316	\\x5d529ef30eac740fae9b81a2ee1dbfca06968dbeef082a1e04ed39c7ef9bab42	3	3522	522	312	315	4	4	2023-06-27 14:47:22.4	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
317	\\xdc44fd3adc56b9b420ddb0d31204d7bd3c8e9c10d18608bbd2ad6dc7ee0bbdf3	3	3525	525	313	316	6	4	2023-06-27 14:47:23	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
318	\\x42d6dcb5962cf75159995427b2af4fc80082be1e79166fa50371e72c624ca746	3	3538	538	314	317	4	4	2023-06-27 14:47:25.6	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
319	\\x242a8bc55ad6e74a8732c46c18fafb9c13a36d9fd5da588f6c11406c5e30c929	3	3574	574	315	318	19	4	2023-06-27 14:47:32.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
320	\\x001e93b3a0fb192bcb9a995b1fa9d3f53fde9f06f96765d78ebcc1a084fa828b	3	3575	575	316	319	12	4	2023-06-27 14:47:33	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
321	\\x929d28c226b191de82217856c94d3d8e30e7888ff0dab7f1be798c77dcd3356b	3	3579	579	317	320	51	4	2023-06-27 14:47:33.8	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
322	\\xe5eea686cf67878abeb5a7a36eb25fb0b1d3827c0e4815974adcefef9394726a	3	3582	582	318	321	19	4	2023-06-27 14:47:34.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
323	\\xc066c2a7330f38e4456e84821f0bed3c8e5e6c77c9c30685e09c48f4c7abd79a	3	3599	599	319	322	12	4	2023-06-27 14:47:37.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
324	\\x438bd4b858793b4a0800647b3b7c269439e7bf1301888f51d87f5c2a4cd39d03	3	3605	605	320	323	17	4	2023-06-27 14:47:39	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
325	\\x6ad76dfc55d29d51f801cb8b5bcf96bc7a80c5f23a32f40c85a0551e24d7e702	3	3609	609	321	324	17	4	2023-06-27 14:47:39.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
326	\\x54476eb83803b6c5a81922d5fa8e1a85a1daf3e38a3def5619cadd9a27010c74	3	3621	621	322	325	17	4	2023-06-27 14:47:42.2	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
327	\\x350123967ac6b2f1b98196df6865f07eebd5fbb26836be0e27d8e65d696c661b	3	3644	644	323	326	3	4	2023-06-27 14:47:46.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
328	\\x8b9f5f75bfc20fe182a12ffd5e033bb370c45f057b68513d21081621319d287c	3	3659	659	324	327	51	4	2023-06-27 14:47:49.8	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
329	\\x61d7b9d48aa941df03b1b8e1ad18cce3ef55c91f20c60952ee92a163f348c971	3	3668	668	325	328	48	4	2023-06-27 14:47:51.6	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
330	\\x32a6b18daca6babc224c2e0bf08b26f72d616c449a7ef59d31a0b3b395ab448c	3	3708	708	326	329	10	4	2023-06-27 14:47:59.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
331	\\x03ae8430fe4658a43a9b45a7c4551c86c36b984f4d9e5d4cb0fed5b1ee826790	3	3710	710	327	330	12	4	2023-06-27 14:48:00	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
332	\\x1ade757998895bee2ccfb8ccc2d3d2e7270e656c98c91f948546334fb0e5a261	3	3726	726	328	331	12	4	2023-06-27 14:48:03.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
333	\\x423029e6d56ba2d78948d8a0a37501ba437d33c0e04e947da1fcc12d8f2a3ebc	3	3727	727	329	332	51	4	2023-06-27 14:48:03.4	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
334	\\xed7fecd3d3807aa1737c1794d48d165d9272a09d5ccfc4c86790af9525979f3d	3	3732	732	330	333	18	4	2023-06-27 14:48:04.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
335	\\xa682c8dafbe0debb1db2b2ebc675b83ccfe0e252aada9965f2a6f3873d8b1f36	3	3746	746	331	334	48	4	2023-06-27 14:48:07.2	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
336	\\x3e2a8c1cd9b8a585dbb26edae43184b2a1618d145b73ab241b881b88147f5022	3	3754	754	332	335	18	4	2023-06-27 14:48:08.8	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
337	\\x268180fd8a45f2732bef89f73ab48592a94770b7dd560657f8a47336ead696f3	3	3787	787	333	336	7	4	2023-06-27 14:48:15.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
338	\\x2de1f2ceb4dd68c25a3b7b3b47a3221e2c8cb855fb385aced2de274b255b1d52	3	3795	795	334	337	51	4	2023-06-27 14:48:17	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
339	\\xab21f38eabf38c039c89fd464268526eaeb1e10b5a8034dba85f79c200b3fce3	3	3829	829	335	338	18	4	2023-06-27 14:48:23.8	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
340	\\x85324dd26f42e1ae6a3489f25888327c0f164bee78ec6e4d01ac067cf5027b99	3	3835	835	336	339	6	4	2023-06-27 14:48:25	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
341	\\x37c7e13b117a0114a1797b4159c309a0ea5679fc9780965feb870ee97d68481c	3	3862	862	337	340	4	4	2023-06-27 14:48:30.4	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
342	\\xb7315b5703b602202784c848609f2af6f3af9bea9442a57bd307656828aef837	3	3880	880	338	341	51	4	2023-06-27 14:48:34	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
343	\\x6c8ef407e178a3264920feeedf8c018f615500f13a0562878f0ac88282270241	3	3886	886	339	342	7	4	2023-06-27 14:48:35.2	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
344	\\x58698acff76f496e45c8395ccdd83b84bbae931477bf4e326c6838482e450d2c	3	3895	895	340	343	51	4	2023-06-27 14:48:37	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
345	\\xfce7b881e1d51d6f248b68f10c6cd30f30bff51a43ef5a766302021d862bae7f	3	3909	909	341	344	17	4	2023-06-27 14:48:39.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
346	\\xbf2adfd4f1ab32a0de7d7ec80cd7c5aff1d8bd5d289e7811b6f4357570f7beba	3	3915	915	342	345	18	4	2023-06-27 14:48:41	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
347	\\x623a0348f7c8ba5402f456e322a3021ac06f1355b41ee90dfd93e3302bf7a1db	3	3916	916	343	346	7	4	2023-06-27 14:48:41.2	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
348	\\x01b6d94ed99a3ec1ed7ca3d5e6865beb6a33eef4067626c44c3a6efac2170e2f	3	3932	932	344	347	48	4	2023-06-27 14:48:44.4	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
349	\\x3fc4d4cc185f51bed7b785c844404e56862c9c66f55c83142199900eb5541bb2	3	3952	952	345	348	12	4	2023-06-27 14:48:48.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
350	\\xe5f36f349e414b8d466aaee3bc00d790ebe97ef97c3a7b4b7489adbea2885047	3	3979	979	346	349	12	4	2023-06-27 14:48:53.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
351	\\xb128b80e7d279358ac9754188a8c8f6ca65ae7ff8c7d3a48205f9196ddc23923	3	3983	983	347	350	48	4	2023-06-27 14:48:54.6	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
352	\\xbdd6969d4acdde97c660bbdf67c28b5672e9ef79337d0b0467f0f7468ef44992	3	3986	986	348	351	18	4	2023-06-27 14:48:55.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
353	\\x20a1b38679260d730d499cd2fc06a2408bc026384b380b0f7cf9ab754e048607	3	3994	994	349	352	51	4	2023-06-27 14:48:56.8	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
354	\\x9410c5785bfc68ec12766150ecffa0229c621a2bc0883f8a5a67b29bb99c57f7	4	4004	4	350	353	51	4	2023-06-27 14:48:58.8	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
355	\\x20adda5b73c03511f181fe393059146e89c93a521ccd9430a4665d7827818e2b	4	4011	11	351	354	48	4	2023-06-27 14:49:00.2	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
356	\\x4e29bbf5f0d2b36309cb4ef4318b686206d5f2301b9f04b73c2495ab34f43791	4	4014	14	352	355	12	4	2023-06-27 14:49:00.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
357	\\x7f680745917d20b1aed631887aa9c6929ff149608b5200725823d65e94f4df3b	4	4036	36	353	356	6	4	2023-06-27 14:49:05.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
359	\\x48cea981b4f2856f2d4448617601176b52879c604163785a75318f89caf656e3	4	4043	43	354	357	7	4	2023-06-27 14:49:06.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
360	\\xb775a8f1a6920779ef7434680942957ea984c70332c3301424925e643c12fe6c	4	4076	76	355	359	17	4	2023-06-27 14:49:13.2	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
361	\\xf312440262bd5bde240df89fff11d4355d312fa5e03b6cc6e30f386ccf0a6550	4	4077	77	356	360	18	4	2023-06-27 14:49:13.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
362	\\xec22550b49159558f0f37b7fe54a22301d57bd8dc2605a4ecc2a84b9181260d9	4	4088	88	357	361	17	4	2023-06-27 14:49:15.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
363	\\x3459c100ed0b0a33425873d8dc1bf9f7160be50e56974d0762f19ff1acd8ba98	4	4089	89	358	362	51	4	2023-06-27 14:49:15.8	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
364	\\x82419a8892f1d52e0f2957da6f1bf4efb8e8a93c0875d9aa044c5665638356c2	4	4090	90	359	363	6	4	2023-06-27 14:49:16	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
365	\\xc48c9f5c6a070272b54125217077f8871c9bbe09cffa23f3a25e0f72d364858a	4	4092	92	360	364	12	4	2023-06-27 14:49:16.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
366	\\x58d2d0d6aa18f566da4a79f96f3c68ddefb46a6bcb045b67854ba66c0b19f88e	4	4096	96	361	365	19	4	2023-06-27 14:49:17.2	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
367	\\x4d290ea86b9c9c4b3818e562a0df7026fa1322df03c78470f6e7b135025d74df	4	4117	117	362	366	48	4	2023-06-27 14:49:21.4	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
368	\\x35a56237f8fc287d85a3c24290c2ee6e8bc83544b848ad67739de403a13e5e3d	4	4127	127	363	367	51	1113	2023-06-27 14:49:23.4	1	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
369	\\x94508938178a9f64143d6e724a1b6c7cf0cac646c1e201ea01937aa82a34eb0f	4	4137	137	364	368	3	4	2023-06-27 14:49:25.4	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
370	\\x861c4fe3e9e6bd153a7c22c68df956fb6dc2d84aa32432cec425e382617fc8c0	4	4139	139	365	369	7	4	2023-06-27 14:49:25.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
371	\\x4071aeaa8b84819eab9c06746159cbf5e7d1a64cee46d2dc14659c441f3883d4	4	4149	149	366	370	7	4	2023-06-27 14:49:27.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
372	\\x91a9263e21ed3556c34c10cacb99c5e9baa005d8109922391b720629da5fb9ab	4	4172	172	367	371	51	413	2023-06-27 14:49:32.4	1	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
373	\\xea779497bf16ce8fcaa1a79d80f9a8ff64d1fa57981360099cc78d7e219956de	4	4193	193	368	372	48	4	2023-06-27 14:49:36.6	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
374	\\xccb3aada6246ecb50aaae2c16aa7b992faa450342f55d79ef81109e1b6ee5b38	4	4206	206	369	373	6	4	2023-06-27 14:49:39.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
375	\\x0235ec2bf79ebb7991f7fc5ef750bc5da2d1844636f688ce4b02b6a0353a4efc	4	4216	216	370	374	6	4	2023-06-27 14:49:41.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
377	\\xbf5ccba6cdc986e344ce0a61c50173dd48adb3b7fce07bd8744bbf94ae52ac2f	4	4228	228	371	375	4	412	2023-06-27 14:49:43.6	1	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
378	\\x9accec85592d1bd5f4270cb7c6c291ff7080946b93eb26dee0cde6ba7e018da1	4	4232	232	372	377	3	4	2023-06-27 14:49:44.4	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
379	\\xb3ca47a9abb9fbc0a2c98cfd8afaf3ea5d830636064aa1ea9a2ce6d1151611b3	4	4242	242	373	378	4	4	2023-06-27 14:49:46.4	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
380	\\xdf34331a533d3eb81a049f7770f5402599bd43a7d0445d18c2ec2540a7409330	4	4247	247	374	379	18	4	2023-06-27 14:49:47.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
381	\\xf5c83545e9e7343d175493d1b345106b8692bbccfda753c691d79a30e65b2cad	4	4251	251	375	380	51	408	2023-06-27 14:49:48.2	1	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
382	\\x0fd4a7ae66ca864871730e8bf2da4480352c4d9865b3dce0d14e82febbbeb5fe	4	4262	262	376	381	3	4	2023-06-27 14:49:50.4	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
383	\\xbbd1004c2ebc582d6fc2f709691705689ac252038e781c0b20769540e87d3e8a	4	4268	268	377	382	17	4	2023-06-27 14:49:51.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
384	\\x3346cdc9e1847b5a424d1d25b47222cbed49c71f1d51db31ad072d8b977be1c5	4	4284	284	378	383	18	4	2023-06-27 14:49:54.8	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
385	\\x925a960e2bc6066837d21d505ae2c1d78c46eb93c20467237be420705f54905d	4	4293	293	379	384	10	857	2023-06-27 14:49:56.6	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
386	\\x39995eb1b826159b1821f0181b769e8371aa9345e65036581af0fc180093912a	4	4294	294	380	385	3	4	2023-06-27 14:49:56.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
387	\\x3df3385c89b5e03a0043fd2250003beab58ebc2eeb38480f67a3b00aab1b1692	4	4298	298	381	386	7	4	2023-06-27 14:49:57.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
388	\\xf9b303f12fe168c867a3790e532f79ba19bfd30810ab8c2f2e6c8c4efc237099	4	4302	302	382	387	4	4	2023-06-27 14:49:58.4	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
389	\\x0384ba649465d90e2a5aefad07dfcf2ff80f175681134571e17fb5ec9a989b0f	4	4303	303	383	388	4	857	2023-06-27 14:49:58.6	1	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
390	\\x40368fa6e7bdf8c03f5bad43d5208716119077205774eeed6f8224bbaf1d6084	4	4307	307	384	389	17	4	2023-06-27 14:49:59.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
391	\\x15f5cf848d870d2e2ab2830743bc7ac93ff4e6268320133e3c1b52b09ed3fef2	4	4314	314	385	390	10	4	2023-06-27 14:50:00.8	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
392	\\x697d1330b4355c0305de806d1b27df9f03d547d224091d3036b5d00e5971360f	4	4332	332	386	391	4	4	2023-06-27 14:50:04.4	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
393	\\xb4d55f82194054bcceece7db2de6ad1760cf2ec26ba3adde250687c4185a7485	4	4338	338	387	392	10	444	2023-06-27 14:50:05.6	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
394	\\x6d4b467da25d24a6fcbaa13b8f5b7178e31a5a8bbc212a9f43ef3c73c1188916	4	4344	344	388	393	19	4	2023-06-27 14:50:06.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
395	\\xf7240e1a8860fb80b5234cd0a683b0e819c3ee22f7bba754f838dddcdcfbf4f9	4	4348	348	389	394	4	4	2023-06-27 14:50:07.6	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
396	\\x445920b2b817c0b262b27e1cfbe44340f31d25bd13f612f0f9ae71c27c3481eb	4	4349	349	390	395	48	4	2023-06-27 14:50:07.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
397	\\x625f471c5a3b5484bb3141aa95ed2506289d528451662b578bab17b54c77732e	4	4356	356	391	396	7	857	2023-06-27 14:50:09.2	1	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
398	\\xc45800c078f22214be2d9ce8e9085b0a76b2512041337bdd8e72a03a7c35db5f	4	4361	361	392	397	18	4	2023-06-27 14:50:10.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
399	\\x13589459ebbd4c8bd76440e039a56dc3bcecc410953dd47b9830cd7e61bfa076	4	4369	369	393	398	6	4	2023-06-27 14:50:11.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
400	\\xd9eaff16dcafc29cc7eff84f691a351128bd9841416c595028112001b79a7612	4	4379	379	394	399	19	4	2023-06-27 14:50:13.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
401	\\x41dabb304a76bd88f7fad952a8805d4fe7aa4ff1e8bc868b8269f753d883968f	4	4408	408	395	400	18	408	2023-06-27 14:50:19.6	1	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
402	\\x716a77849b7e1f4d49ffd77d846dceda75286a05b8e9d988caa36c97f6121e04	4	4428	428	396	401	51	4	2023-06-27 14:50:23.6	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
403	\\x19bb2581224cebe0f69fd7e529e3cdefef8c15a714e5aa08cf85a13cfdb2667d	4	4434	434	397	402	19	4	2023-06-27 14:50:24.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
404	\\x9f107c50393f2e3a603859866976ff579a8c93a54b302c4e59badb4988a16486	4	4435	435	398	403	4	4	2023-06-27 14:50:25	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
405	\\x016230952a8abf48f0ccd8bed278a336c0b96994f0897f4eb6a20a6458c9ee8e	4	4446	446	399	404	19	853	2023-06-27 14:50:27.2	1	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
406	\\x17520ef2095e74e3bd91ea26a529b170010b3e4f65a213dcf9bc8527e7f477e6	4	4460	460	400	405	4	4	2023-06-27 14:50:30	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
407	\\x86aaaa356be54ec58d96ef0dbc00f6c9458c27622f636fde1f65bc7331b38bfa	4	4465	465	401	406	4	4	2023-06-27 14:50:31	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
408	\\x258958529fc61ffbb873a161d19693f961c84cb4f8934328f4f7c323024d441d	4	4471	471	402	407	7	4	2023-06-27 14:50:32.2	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
409	\\x888316bb40c1349e4fb2cb546d092c336ea53d8391119950d6900a0639c651e6	4	4472	472	403	408	51	450	2023-06-27 14:50:32.4	1	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
410	\\xf1df8608929737d6430698622a95c7cd79d45e83c8f7ed4c9fc348cae970b1eb	4	4477	477	404	409	51	4	2023-06-27 14:50:33.4	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
411	\\x36d722803fb9cc5086f9b7f123a9e2b7ac4921ab4bf427341d28cde6e33bbf51	4	4497	497	405	410	3	4	2023-06-27 14:50:37.4	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
412	\\xc92649a000eca1ac718a8af9208e857849bafa9387e07e12ab1aaca975ecb7bd	4	4516	516	406	411	12	4	2023-06-27 14:50:41.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
413	\\x7a6feb31860f92169395e2f87f74be224ff9a13e33dde811a3bcec6f0c1ebffe	4	4519	519	407	412	4	408	2023-06-27 14:50:41.8	1	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
414	\\x1455a3ef720076cec4576399f2c6beadba4e66d748557f4c9ea91cd00add93e9	4	4529	529	408	413	48	4	2023-06-27 14:50:43.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
415	\\x9675a1959f19e28138f825f6bd010dbe07fb11086532166d238406918d2e44ef	4	4547	547	409	414	19	4	2023-06-27 14:50:47.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
416	\\xfb32a8d679f5f7c65598ef02e9420ed3e0be8ab4d46009922f8d89db97595fd0	4	4548	548	410	415	48	4	2023-06-27 14:50:47.6	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
417	\\x10802e10dc21fd03a975c1218415f7ba8b524ca5d16e016c1f9a781891e55431	4	4561	561	411	416	51	1108	2023-06-27 14:50:50.2	1	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
418	\\x0ae8c47d09acea347afbcfc684ecd7f0909e61b9652c8dca3445840988daadb9	4	4572	572	412	417	12	4	2023-06-27 14:50:52.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
419	\\x806316ff69defdb7d8163088f2c9186ad773243fba86315477136d16b6ba315b	4	4583	583	413	418	19	4	2023-06-27 14:50:54.6	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
420	\\xbd77dfb08caa1a7a854fe6a293cdf2e5a3f2c94d734e29fe1efea93767849144	4	4589	589	414	419	4	4	2023-06-27 14:50:55.8	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
421	\\x895fa484b63a0b74099961b7f6b8a5c756eb0f9c4b54cad782acd43335bfd905	4	4595	595	415	420	19	566	2023-06-27 14:50:57	1	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
422	\\x54edc77625ea5574e54f25d2104abf9273376d276b89dc7cea4725604b57e20e	4	4606	606	416	421	10	4	2023-06-27 14:50:59.2	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
423	\\xa3538cf1d0fd56394418fe201fff0438325cfb81972ab10f546eef0c075e157f	4	4607	607	417	422	51	4	2023-06-27 14:50:59.4	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
424	\\x12f275b8da4c5ab4c80f052d576853c75a1b9e9fa517ed203879fc9a4c783719	4	4609	609	418	423	17	4	2023-06-27 14:50:59.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
426	\\x107b7a49a4365b4d7940b9b7533ac9da3b883f0ab6a9f0196a0cd2c1fe15efc2	4	4629	629	419	424	51	779	2023-06-27 14:51:03.8	1	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
427	\\x8790e045f7456095bb35f27b015869ba16f1fd26d8d8fe2c52e228750d9bf968	4	4631	631	420	426	48	4	2023-06-27 14:51:04.2	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
428	\\x90aed943709284608097b19a727f76154cd15ca57dcfde448fbbda1a72f57f39	4	4636	636	421	427	4	4	2023-06-27 14:51:05.2	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
429	\\xed6612cc013077d100692597283b7b4a629f35f391401bce649549b10120e97a	4	4663	663	422	428	12	4	2023-06-27 14:51:10.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
430	\\x8284cef7030cd6afd615f09c28ce8ee2c13b133f9ed1703e8d00736050883fce	4	4669	669	423	429	4	746	2023-06-27 14:51:11.8	1	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
431	\\xdd027ecd80d6b29ce80696d3cf950955985cba3e89d375445396f3adeb17df14	4	4710	710	424	430	51	4	2023-06-27 14:51:20	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
432	\\x54a93af15f26a90d8a41c01a4e683a1bc7508ae952d2f8a0d042346780311dac	4	4712	712	425	431	17	4	2023-06-27 14:51:20.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
433	\\xcc6cfee569ab2a18794ca8ce9acb1cbb61c7809a6dedd776c7dc8d1950a6da5a	4	4730	730	426	432	7	4	2023-06-27 14:51:24	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
434	\\xa11ded56de3ecc296992bb9928d675d486477c9888f6fa19b403fb9cb79605f1	4	4749	749	427	433	51	838	2023-06-27 14:51:27.8	1	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
435	\\x8756472524a435a559ca7b6feb9244d1e40919c75683f8aa95fcbb3130bbe5cd	4	4765	765	428	434	6	4	2023-06-27 14:51:31	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
436	\\x6626b959564a496bfb4a88e0b44040b77b26106e7a7a17042b55851dfad86572	4	4786	786	429	435	4	4	2023-06-27 14:51:35.2	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
437	\\x8b71a030f8c5227d63fa4f55311bece3168b5411df9561727511c325749c217a	4	4794	794	430	436	12	4	2023-06-27 14:51:36.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
438	\\xefc38c6540f608e386fbe298b269156211f235ad8f6290036449a775093972b6	4	4808	808	431	437	4	543	2023-06-27 14:51:39.6	1	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
439	\\x6594c13a5413e1220b2f25a25c8cc395738e89d6f061c97eeb6702df50785e95	4	4813	813	432	438	18	4	2023-06-27 14:51:40.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
440	\\x652d2ed2e54d5063767d9345ade1b4a456ac97eea6c1d4069a5d6f9b6cca2a37	4	4815	815	433	439	48	4	2023-06-27 14:51:41	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
441	\\x9e5637085df9cd7a9c28449705e24e57d32894039298ae783c362bfb074c8913	4	4835	835	434	440	7	4	2023-06-27 14:51:45	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
442	\\x81219ae32c4bcc94ada2764480b57330fb0048a40edff113e3d7dfc108e470ac	4	4837	837	435	441	51	4	2023-06-27 14:51:45.4	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
443	\\x7186d4a60e697decfecda4690fb6e94d9c14486727319ff52ef2cbedeca1cd7c	4	4839	839	436	442	4	4	2023-06-27 14:51:45.8	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
444	\\x03f0d86369e7fca3003b8654ef500c8602eeab94b97cd6b7f89ec40934112cb6	4	4858	858	437	443	10	293	2023-06-27 14:51:49.6	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
445	\\x1f555789f8b19eda2a2215c1eb5423d83ae01661f5909b8a4f3e50b20ffa905d	4	4870	870	438	444	3	4	2023-06-27 14:51:52	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
446	\\x7bdb8e2136a34778e5165fd56edc7ccce717d176cfe174bfa18e72ad17049561	4	4884	884	439	445	7	4	2023-06-27 14:51:54.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
447	\\xff980359237e8ac7cca4011aadd07032a2a3e553bfea1bddba114bec7586f4e6	4	4919	919	440	446	48	4	2023-06-27 14:52:01.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
448	\\x39ddbe995299ace541eed44b501aeb8104626d1ff7c64ebd9e10d31aabf82f81	4	4939	939	441	447	10	1481	2023-06-27 14:52:05.8	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
449	\\x27807b54d87e0cbc3ee4f98092040b178ee5eaea81de43f318bcdc1015a8ba5f	4	4948	948	442	448	10	4	2023-06-27 14:52:07.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
450	\\x0540a29945602c702ee888c8e6c028e0908e7ed553e08794b915483431c24283	4	4966	966	443	449	10	4	2023-06-27 14:52:11.2	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
451	\\x1a311631e900fdb80b8a33a5db385fed3a6423d4f30b547c1433cd622da3a860	4	4969	969	444	450	12	4	2023-06-27 14:52:11.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
453	\\x7bb450b84026d32b3711213a32aeffede00422f57a4c45e5d577ccd3d68ca680	4	4974	974	445	451	18	368	2023-06-27 14:52:12.8	1	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
454	\\x9481c407c11d2bb1122cb556f556a65dcc25018e6cf7bb2db25d815626440ee1	5	5007	7	446	453	19	4	2023-06-27 14:52:19.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
456	\\xd18a9e4c7ba657468016c69887495eb55b581fc232ed363b9ba7074002dfd35d	5	5014	14	447	454	4	4	2023-06-27 14:52:20.8	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
458	\\x7bc18d8ba2808c2f4aa7915562401456a9f9457fa58bbd9aa997b9b2125fbce5	5	5030	30	448	456	4	4	2023-06-27 14:52:24	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
459	\\xef30e73c4586fe7116881640978fc6f960c0487205b7bc97a362eeddea3de31d	5	5038	38	449	458	17	1051	2023-06-27 14:52:25.6	1	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
460	\\xb14b227f5cbc48ae735e6f699f9a7daf1753be7f7dc1fd9288f0b4e54ec6e4ec	5	5039	39	450	459	17	4	2023-06-27 14:52:25.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
461	\\x3a2435daed4ffb150480ee421cefdc633702b2237a48cc44bb66fd704402b16b	5	5057	57	451	460	18	4	2023-06-27 14:52:29.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
462	\\x161b0d7a849ca591c2579db760c6b3388550a73da4cf9040560d03ccf5075b85	5	5072	72	452	461	6	4	2023-06-27 14:52:32.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
463	\\xa46c2a7756c74fbf1dd2a05591710bdfcfea42566b3107dba7cf4c625cc175fe	5	5085	85	453	462	18	505	2023-06-27 14:52:35	1	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
464	\\xf261204fde5a252f42eac641711ace9b5e8b73ecd4b7b0a46a1a5eeb4d5a626d	5	5089	89	454	463	18	4	2023-06-27 14:52:35.8	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
465	\\xea231de562efd5e5b83f0cb8b03655c2f5d9218dd25d6aa3202c8f32397aefcb	5	5094	94	455	464	19	4	2023-06-27 14:52:36.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
466	\\x306442bf76da83f3229d020b2954dd97d5459217389516dfb39ba58551feb52c	5	5113	113	456	465	17	4	2023-06-27 14:52:40.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
467	\\xb82088aeb1243c340152c3c86d7dfaea82287e455057263ecf9646bf79fd50e7	5	5129	129	457	466	48	401	2023-06-27 14:52:43.8	1	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
468	\\x83c30d6e85328f9e76a9c4fe0c6aed1595e9ecc88acd638bc4b71be3e8a9bdc3	5	5130	130	458	467	7	4	2023-06-27 14:52:44	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
469	\\xda766a54643f79c26c21ff0441141b7c6ebe8afcad366a8d50b90f8e5843cd9a	5	5135	135	459	468	51	4	2023-06-27 14:52:45	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
470	\\x0b229006d05b195eabeb06190a14785637d0fc4be23d733e3d1bc6c8dbdaf686	5	5138	138	460	469	12	4	2023-06-27 14:52:45.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
471	\\x514cb7a97951aa851f4e61e7b329ae8dd1e905b28f881091b9c322f0273a9244	5	5139	139	461	470	10	4	2023-06-27 14:52:45.8	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
472	\\x79361192201a9d5bd8238d3bdeafc653837c944beafd172ea315b54b3d985c18	5	5150	150	462	471	10	684	2023-06-27 14:52:48	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
473	\\xe20f97978f1802060909bbc13aa15698b91630a5a09424243867b6973fea3c40	5	5163	163	463	472	51	4	2023-06-27 14:52:50.6	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
474	\\xf0ccbd9e3173e49fd9b4becfedfcf5d8a5ac91c08d68b75c13e950ff8166be0c	5	5171	171	464	473	51	4	2023-06-27 14:52:52.2	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
475	\\xa114da21623e8441ed18007c25db8da4cb296ba60a9199912e2f944027b2ee28	5	5182	182	465	474	10	4	2023-06-27 14:52:54.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
476	\\x693c5adbdd1ee47c795bc00db86770d748725bd2b13abf6871c7f70b2e15d6e4	5	5186	186	466	475	12	539	2023-06-27 14:52:55.2	1	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
477	\\x2cd907d134be6d120b9797ae65337d684b72cafb68b6d03e49d906c596361d0c	5	5189	189	467	476	6	4	2023-06-27 14:52:55.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
478	\\x5ef1ee64142ceb7133eeb61f7ae5e24e808724ef5043a466951a4c3c7a900c59	5	5191	191	468	477	17	4	2023-06-27 14:52:56.2	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
479	\\xd665c4f3e36e54725bca0e5a81898ffacb605abf7b94753a0367d4b694761f08	5	5206	206	469	478	7	4	2023-06-27 14:52:59.2	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
480	\\xc0d46740295a287d7acc9394733d1dde78d107735bae9575848f24852698473f	5	5208	208	470	479	17	4	2023-06-27 14:52:59.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
481	\\x57f1dc1c93f2ea259a8756123d19d858a4ee13844b8a44dbbeb18292af4d1d64	5	5215	215	471	480	19	4	2023-06-27 14:53:01	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
482	\\xbfd13fcd92ff79d27f4d01abf1063e8b3999096defad143f2d917abb30126da8	5	5220	220	472	481	10	698	2023-06-27 14:53:02	2	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
483	\\xe0de4cd123a65ff7bf59266c82f3bdf290da9eb17893fbe99966e47920fc029d	5	5264	264	473	482	4	4	2023-06-27 14:53:10.8	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
484	\\xbaf40e832bfdaca40d3cb1e5b6a850fcf00bf9e87fbeaaf960552c2284b83abd	5	5272	272	474	483	19	4	2023-06-27 14:53:12.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
485	\\x0b302e1cda705344e971f74905ffc1d98a8426b8aa498e2feda7a34f6dd5c96b	5	5283	283	475	484	10	4	2023-06-27 14:53:14.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
486	\\x3af431c299a325445e3757177d189095082078678e39b88f59b558ff0c65abe0	5	5291	291	476	485	51	4	2023-06-27 14:53:16.2	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
487	\\xa45611cfebd6075b7035be8be479c7ac8146de8688f1e041d9eb665ecaadb1ab	5	5293	293	477	486	18	4	2023-06-27 14:53:16.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
488	\\x7fa4d4d0423d6f878e6be3c80c511a0f780d60c1d20366975488f9b077b7ddcd	5	5302	302	478	487	17	284	2023-06-27 14:53:18.4	1	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
489	\\x649bfd6e84ad01febdb2cd74e502a639ce2466ff6fdcc56998cbf20d3a746623	5	5313	313	479	488	51	4	2023-06-27 14:53:20.6	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
490	\\xa76dbec8de060a38a79b191c007e3cf90491e303270890991fe4c2157d5ae896	5	5315	315	480	489	3	4	2023-06-27 14:53:21	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
491	\\xc0b2bb7c4a01fd6de86a477ad2f26743218773e0eaadadd3307b7d6b7b0d106b	5	5317	317	481	490	7	4	2023-06-27 14:53:21.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
492	\\x1e61759878418013377a9771f21340fd804e976916c31a375906e1ceab0e09c5	5	5333	333	482	491	4	293	2023-06-27 14:53:24.6	1	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
493	\\xd37c35dfb916327c9d7c1bd0307008225b098ea4f784506be7a8b4b7f34bfaac	5	5336	336	483	492	12	2371	2023-06-27 14:53:25.2	1	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
494	\\xf592512cf352709e1af9714c9b1e43d6acef9adde16a241d1eb2ef1cddbd38bb	5	5348	348	484	493	10	337	2023-06-27 14:53:27.6	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
495	\\xaa842f4e49ea3be1d1aa754dcdc349443c72da212dfe229d601ab70f75bb0d1f	5	5351	351	485	494	17	4	2023-06-27 14:53:28.2	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
496	\\x1355d2e0edd2a125d7e3b058bb0e538d78da29e5fe9899864a6fb99f1428db43	5	5379	379	486	495	6	4	2023-06-27 14:53:33.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
497	\\x45a74bdcbc30bacfd1d6ef48d5c3e5204d26fdafef811ae72d6ac36b4e141f10	5	5381	381	487	496	6	293	2023-06-27 14:53:34.2	1	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
498	\\x8dc562ec9f4d5b9447712ae6af7cbfa6d3aaafc2215ca93f598ccc9fa8c69742	5	5409	409	488	497	51	401	2023-06-27 14:53:39.8	1	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
499	\\x3d5997fa661a84a723977bc18f7383d7c0c1a25843bfa43b5044016980887aec	5	5411	411	489	498	51	4	2023-06-27 14:53:40.2	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
500	\\x434d82a8ab4b93e2fef58b09a94ee97bf068ec5104ceb2af6ec0e8d7d929f9ce	5	5457	457	490	499	7	8236	2023-06-27 14:53:49.4	1	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
501	\\x29fd21943fe6bd42b807a9ef47e6bda3e54c972995a0cd38fc5bc57707236068	5	5465	465	491	500	10	8410	2023-06-27 14:53:51	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
502	\\x7b98c42becacb5c9a28c257084a4a3b89a06f12b8e2b049719fd0ccb82e52e09	5	5478	478	492	501	19	495	2023-06-27 14:53:53.6	1	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
503	\\x72edde5671b8fa91745ed090edfbbdd070eacf07f3bacbf3f102a4118ffa8791	5	5479	479	493	502	10	366	2023-06-27 14:53:53.8	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
504	\\xec29926387ad9760a5c8effec645adbf60c8dd33568a293ceb3212a202dadbed	5	5482	482	494	503	6	4	2023-06-27 14:53:54.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
505	\\x647ae081854f67dee39e92ff12354ff2aef80cdd600c19835819ef18a07c773e	5	5483	483	495	504	4	4	2023-06-27 14:53:54.6	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
506	\\x46e97440fa087195e6634e4ce2b65bbcb9c2401c2c8a6f4a86ea5078cf4e3dc3	5	5484	484	496	505	10	4	2023-06-27 14:53:54.8	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
507	\\x2371365d64784e4557a78be79df64ce97f03e4b877d109b59a74e1ea7dfc6bd7	5	5486	486	497	506	12	4	2023-06-27 14:53:55.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
508	\\x2fb79c7d511c9ca3ab3066600f277cfedf2bdf5b304bf4e7221556741f5331fb	5	5493	493	498	507	48	294	2023-06-27 14:53:56.6	1	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
509	\\x92c4bc4ee599ffe66742e7667d308ae137495b34ebbd081b3d0bc6cbe7f1641c	5	5497	497	499	508	18	4	2023-06-27 14:53:57.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
510	\\x000ad4b68755694ccaf9ece4621f46a4ea82141a3dd197a0cd8271e112c70fb4	5	5501	501	500	509	18	4	2023-06-27 14:53:58.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
511	\\xe18ca3d4105d64cc9ad80fefb6f13ad2f29c325b4ca6dd814d9e84a78d676b97	5	5502	502	501	510	6	4	2023-06-27 14:53:58.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
512	\\x5f02a937c4a590c8ca17b067b89ce64624330110b1f62550a8c2db075d9688f2	5	5504	504	502	511	19	4	2023-06-27 14:53:58.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
513	\\xe61f29ad4aa0053cf80d77a0f5540b78916c8936f081e6c9a3eb91e4a248a36d	5	5505	505	503	512	7	4	2023-06-27 14:53:59	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
514	\\x81724e7c7392f2019fe1e00d75422271546d6911910629dc37eba0cb048c08ff	5	5510	510	504	513	18	4	2023-06-27 14:54:00	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
515	\\xe1db4ca77677e1d6143d12996ea13d590065243e559ec56435f06844bd2fb1e8	5	5519	519	505	514	51	4	2023-06-27 14:54:01.8	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
516	\\x60b5d252cd326b8b2a98b8ffbe7f397e135e3f199ede8d94a2f3ac874860e7f9	5	5521	521	506	515	3	4	2023-06-27 14:54:02.2	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
517	\\xa1f3c2f4cee915593e3d41685b9937ae2150d900d61f95a81f4d88f9886a4436	5	5525	525	507	516	17	4	2023-06-27 14:54:03	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
518	\\x5d0fcb9a76b24ecffc9c995c66a23eab1803c4f4a3703825a98216bc5d29725a	5	5526	526	508	517	19	4	2023-06-27 14:54:03.2	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
520	\\xce92ca52a3e022b925ed24cb652c43bb204c52249db4e295c76d396435ae291c	5	5529	529	509	518	6	4	2023-06-27 14:54:03.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
521	\\xed09becda2f90b88e048df965334fd43f4c8d5da2f9cccdf271c984ad2754089	5	5541	541	510	520	3	430	2023-06-27 14:54:06.2	1	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
522	\\x35fe4c3309043ba8c52fd3e569a51fcb8a60c350cae3ec691e33c91f4c99e8b3	5	5558	558	511	521	48	4	2023-06-27 14:54:09.6	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
523	\\xe5ec5f8ca4b972af2dcdd1f270f62f513a380a001e4a256d7db96fc083bfdd6e	5	5570	570	512	522	17	4	2023-06-27 14:54:12	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
524	\\x3b012bae20b9d4e42dcbad1f6630946cd5af2ee30afc76e20c91c5bfd17b2b7d	5	5577	577	513	523	18	4	2023-06-27 14:54:13.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
526	\\x87e2200337910fd35c3fbd9311440f0ee34a8e330736a27b996d3cf3806b048c	5	5581	581	514	524	4	4	2023-06-27 14:54:14.2	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
527	\\xa344606e638a81f178dcb7e4af81d721231cfe65f403bb15fbd15d8fdf92ff2c	5	5638	638	515	526	17	4	2023-06-27 14:54:25.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
528	\\x958a47167b1ced8fc805f6e4fb9eb4241190ffd6a54eea77a34f03d436efb79b	5	5674	674	516	527	17	4	2023-06-27 14:54:32.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
529	\\x60ebab0b8efd01b5e216c6f9172b1e8ffd2fa7a1b87ebed442d9bf79d4bbd0de	5	5677	677	517	528	6	4	2023-06-27 14:54:33.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
530	\\xcb8f583be350f352209df2d037bdcc6cc857eac36a024f692ed45d8c374de963	5	5683	683	518	529	6	4	2023-06-27 14:54:34.6	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
531	\\x7d801dc76a3c2ea6c20b3d7df7d93f35bb200dbf7bb37de216219c0b585db1c5	5	5684	684	519	530	51	4	2023-06-27 14:54:34.8	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
532	\\x15ea3b88b88fc9d3045d0a2ca8aa700b83d23eaf69ed31a226f557f8d204fe16	5	5687	687	520	531	7	4	2023-06-27 14:54:35.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
533	\\x0264a650eada7fd8c96ce17c8bf141089bfb88a5ff7532d6e3c47ad93965abfa	5	5723	723	521	532	10	4	2023-06-27 14:54:42.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
534	\\x34b01266ff86d0b16882408534a8523e5910b21816f84f3d13ba50048f02fc11	5	5728	728	522	533	7	4	2023-06-27 14:54:43.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
535	\\x9c061b184da0162e3d4d27619ca937c98bd86e06b8de46db68ff8849c9535d1a	5	5738	738	523	534	17	4	2023-06-27 14:54:45.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
536	\\xdc8b426e08730266647224bef94ce9ffcd372ae34262e32a992471d3dc3a5760	5	5753	753	524	535	48	4	2023-06-27 14:54:48.6	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
537	\\xd1acc99a7632f420a3cb035eb7321cf778809bf3963509c9052c4c34691131ed	5	5776	776	525	536	3	4	2023-06-27 14:54:53.2	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
538	\\x9bf1f17cbe5fb6f733cf2f6939466f84acd2a8d2a2b858cdab604a63ae0cd395	5	5795	795	526	537	17	4	2023-06-27 14:54:57	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
539	\\x24ff49c666f4f941f31add088990f240d6e3da97f211c0c59e168068dbd0f278	5	5799	799	527	538	4	4	2023-06-27 14:54:57.8	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
540	\\xcf5b5c9330143ff5855c9fa436fab5f5b92a64701e063a0d2d1b980a643cd1f7	5	5813	813	528	539	18	4	2023-06-27 14:55:00.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
541	\\xa4f90eeb58d5443ad76b4cec806d8d0953b12e8655247834743eab57548f8da2	5	5816	816	529	540	51	4	2023-06-27 14:55:01.2	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
542	\\x124389da6f18e472df137ca7bbe3cac4b8bbffc5737b2bf55a582f6af3a5dc18	5	5819	819	530	541	4	4	2023-06-27 14:55:01.8	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
543	\\x9e19b3713db44d793c7a29948068e48ecd886b26b27e0a8038f940dce04297d7	5	5823	823	531	542	12	4	2023-06-27 14:55:02.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
545	\\x14b5c9f2da35664a8c3bc44d4fe2d5bbf0e870b839abfb889d9ae903f5a85cf5	5	5835	835	532	543	10	4	2023-06-27 14:55:05	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
546	\\x2d3bab7cdc209e450b6985e8f855276bc3b648e0590b79b93c6f8e26a7d97946	5	5836	836	533	545	10	4	2023-06-27 14:55:05.2	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
547	\\x67ba2e36fecf206b64bea9ca9219158dc4f8091b284a149f85d0da31de62ce95	5	5843	843	534	546	4	4	2023-06-27 14:55:06.6	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
548	\\xc235a81549438b65dcb3586dc86aeeb2635700bf6889bd00ba277eb1c44b6846	5	5844	844	535	547	18	4	2023-06-27 14:55:06.8	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
549	\\xcd74ee1cb22622537926ce4e6523b0b589865a7dc46d8615515a8c3769883e45	5	5873	873	536	548	3	4	2023-06-27 14:55:12.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
550	\\xd0be68e9f8b1824c2c281af425dc9e5a36affe16fba98b61766b7d7fb6e237bd	5	5888	888	537	549	7	4	2023-06-27 14:55:15.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
551	\\x8e74d1f7581328b5fd7ae446466d2da74567be47b88a70e2a917cddd965c4b9c	5	5892	892	538	550	51	4	2023-06-27 14:55:16.4	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
552	\\x9f5b9b546ba4e10a269d23e938d849ae698b10e18e2e202e40dcdfc141413bb1	5	5895	895	539	551	4	4	2023-06-27 14:55:17	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
553	\\x13d3a20e76624415802ba444cfe1056f575f8b2ffe8aafe52fd384458b79a09a	5	5896	896	540	552	4	4	2023-06-27 14:55:17.2	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
554	\\x74b15cef3054b68a3e3538d0837d7c5b9b9c16c4a1e588d8c05f579cd3af4c28	5	5897	897	541	553	19	4	2023-06-27 14:55:17.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
555	\\x8554f1765d6d6c4aece25a3ce560dde5bb808b2b8a234809533e811a21e08f97	5	5904	904	542	554	10	4	2023-06-27 14:55:18.8	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
556	\\x50386400dd428dd3f6ad36e4d2707138553c0638da41d055176d8f870f76e974	5	5916	916	543	555	10	4	2023-06-27 14:55:21.2	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
557	\\xb682d50bee9c019530f47b56a33f2d3908b27dfd9237aa2fb7ecea70227d2846	5	5918	918	544	556	7	4	2023-06-27 14:55:21.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
558	\\x36fb5a82c5c44fef10c1c76b00041fb5cdee6d7ca9778f9be6399d78b67d79e4	5	5936	936	545	557	3	4	2023-06-27 14:55:25.2	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
559	\\x9b78b5a67b228873ed4fef11be26a6da7bc951b7d5bc59f7102a806f64940ce4	5	5941	941	546	558	18	4	2023-06-27 14:55:26.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
560	\\x0fe4a9deabbe4ba221502c876ff5151cd5820c029b27cb05881b49f5a33f9b4d	5	5967	967	547	559	10	4	2023-06-27 14:55:31.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
561	\\xcfb373d1264fb83ecf54a8a79fbc29f4be44ed1faecfef29fbc9a42dbaf79400	5	5969	969	548	560	4	4	2023-06-27 14:55:31.8	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
562	\\x3170173950fc91010a23792efadd2c0d957bbb0835344841a26ad619b384bbc7	5	5972	972	549	561	12	4	2023-06-27 14:55:32.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
563	\\xe33d655df9f5ee739b0a9c9eeb5660e49141837e9bf173221b790925f39665ee	5	5973	973	550	562	12	4	2023-06-27 14:55:32.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
564	\\xf5c13474b801269fc2aeb2f63fd396d256ada11c9d7cc8b5c8a7bf4f2f313674	5	5975	975	551	563	7	4	2023-06-27 14:55:33	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
565	\\xd53695b1ca91f2ff3626fee1c3e386dd2321fe1dbbd754fee3bb50847dc8d49b	6	6026	26	552	564	18	4	2023-06-27 14:55:43.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
566	\\x3f07005b1e1de1bd812fe2795f49177646ca61d46de88656100874930a5536e4	6	6028	28	553	565	18	4	2023-06-27 14:55:43.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
567	\\x94a4b4ef4e4dcf1ff5503c13e33592e5cf875d47a58f328a3a73a3ff91c6f047	6	6032	32	554	566	4	4	2023-06-27 14:55:44.4	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
568	\\xf6a566a5dd480d7c2b45f09c5203bfb009c797fe8c380c2951b7874cf4a423c6	6	6042	42	555	567	48	4	2023-06-27 14:55:46.4	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
569	\\x966f0f74a410e8b6cf44a5cbd081f5af542b804bea1c08b747f4ccf47f9af6d7	6	6044	44	556	568	51	4	2023-06-27 14:55:46.8	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
571	\\x3d96f156d7b9ebff7a73f7a786c5d807a0e7fd67af9e9db0dd7e8d0de4b04e8b	6	6053	53	557	569	7	4	2023-06-27 14:55:48.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
572	\\xe016e3140a4a83d6b8b3817da237688598d2573baa886c2d6997cabf0f29d610	6	6077	77	558	571	7	4	2023-06-27 14:55:53.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
573	\\xce171ed6d461e970309e65b654d90cbad530ff573c79d8ac384dbd189a5f77c2	6	6079	79	559	572	7	4	2023-06-27 14:55:53.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
574	\\xe4c1839eb69d8c85380b384361b74fdf0be9e20881d7a3fbb348f8f44331cd78	6	6081	81	560	573	48	4	2023-06-27 14:55:54.2	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
575	\\x874789c3fefbea126c2e9687316d3794035358eb6882cba6615f6a74e15fa011	6	6085	85	561	574	17	4	2023-06-27 14:55:55	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
576	\\x9e92d6fcba8cac8be95a92dd8044b3ef1f0b88d4f98d353a51ab9b8060cfbac9	6	6092	92	562	575	19	4	2023-06-27 14:55:56.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
577	\\x22c756ab62fa89378dd9a7f889bc9444e4a6876ab9f676bceded3023e59d87fd	6	6095	95	563	576	19	4	2023-06-27 14:55:57	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
578	\\x1b6b4c698f4942ce0067e0f3facef5918ead21c1514802a65842a8d909de178e	6	6096	96	564	577	51	4	2023-06-27 14:55:57.2	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
579	\\x11f1148f1fa83217d83c76920f6d0dab895576f17ccfbc3fbbc35ab9090d1162	6	6112	112	565	578	51	4	2023-06-27 14:56:00.4	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
580	\\xfe0a6ad4f91b0fa1c0940726efdedb05b9656526fb962f2ebfd940a86759f156	6	6117	117	566	579	7	4	2023-06-27 14:56:01.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
581	\\xbb71e7a2c5665a3e45635465ba5b9c67a6009eb1e28417e52193300c16009aec	6	6131	131	567	580	12	4	2023-06-27 14:56:04.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
583	\\xa2e1d7400427358adbb421dbff3e36106133c8c73f618b7c519fa3e3e2a3a7cc	6	6141	141	568	581	51	4	2023-06-27 14:56:06.2	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
584	\\x41746da205a4e82209bea76df80df6cecc911d649c91096bbad3231ac15b91e0	6	6155	155	569	583	3	4	2023-06-27 14:56:09	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
585	\\x9d91de6bb0dce36087bd431e081a1eee272dae4d951187b35100dae53cfa3311	6	6195	195	570	584	18	4	2023-06-27 14:56:17	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
586	\\xe54400756f49a1653aad613c09fbba913f39bbd7b99e4c4283cc55778c55dfa8	6	6203	203	571	585	7	4	2023-06-27 14:56:18.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
587	\\xe6770226c08b5291ea4e6ae94644690dddd7a1a1f91489d45e85f750b0a45f46	6	6206	206	572	586	6	4	2023-06-27 14:56:19.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
588	\\x6808727c1d9798edc75a25411b2d95870671bb5313e157915321feebf0a21bbb	6	6211	211	573	587	10	4	2023-06-27 14:56:20.2	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
589	\\x9a3f11022508a0577a690479a8552d237c4b594059d3f9a9dbe21f4dda833575	6	6212	212	574	588	17	4	2023-06-27 14:56:20.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
590	\\x9db47851f5911a84f90a847d19a8c9a065525c69552ccb9a9864b940c896c8b3	6	6218	218	575	589	4	4	2023-06-27 14:56:21.6	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
591	\\xb81a68c29803fadb41b5c1e669a90e01dbc3f109f3d73e379e61185ed6a3cb2e	6	6219	219	576	590	17	4	2023-06-27 14:56:21.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
592	\\xe652111494d9d149ef40b6959a6ee70bd03404ed62a840b1b206d625a41e95e0	6	6229	229	577	591	7	4	2023-06-27 14:56:23.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
594	\\x19452ccf17f675141ae7a4fe48b039f3c10b5452c4b96ab77f7f4932b128572f	6	6233	233	578	592	7	4	2023-06-27 14:56:24.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
595	\\x637e4f770e83bc8d80582b203c149eed054d82a2b22ebbd979c2f13e5aadd2b7	6	6247	247	579	594	12	4	2023-06-27 14:56:27.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
596	\\xe088b9d7e1c3d3051196ec2ca4906ef682be8cc1d9c379f084ec84817e7f1bb7	6	6253	253	580	595	51	4	2023-06-27 14:56:28.6	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
597	\\x393b78c7358dee50f70beda5f6c2fbf23aaf162135dc16e2718e1f854aee744f	6	6262	262	581	596	19	4	2023-06-27 14:56:30.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
598	\\xedd9c7386dc6d135dab02d3157184ef4ba211da89feed8c4c349a6ba795e1ad9	6	6272	272	582	597	19	4	2023-06-27 14:56:32.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
599	\\xa9e0e06044b49b28bab516448c269c3d27765986237f156e2601c3e999a7393d	6	6279	279	583	598	19	4	2023-06-27 14:56:33.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
600	\\x2a47eae5b4cf0545ccd98eb7686ef1e27ec14011d341fd70cd804ae79bc67c06	6	6307	307	584	599	6	4	2023-06-27 14:56:39.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
601	\\xbc8089feb15f6715b905aa38a2c16ced8712e1511d4bcb72c17e26d6e1d6b86e	6	6315	315	585	600	7	4	2023-06-27 14:56:41	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
602	\\xd5c466e3d1b48371b3bad9580585a120408fa3141f4d0f7f14fdcfba37023682	6	6316	316	586	601	10	4	2023-06-27 14:56:41.2	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
603	\\x8f13fdbe0bda9bc68e24bfafc2dff7e76ad94c41f83016bc08bf5466478c34a8	6	6329	329	587	602	19	4	2023-06-27 14:56:43.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
604	\\xaaacd104c73c3d3f976a414c20f9eecabcb1702c2dc4329a2edddf57e747751a	6	6344	344	588	603	6	4	2023-06-27 14:56:46.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
605	\\xa3edcee7d4c58989b9b93529e32026a2ff599712af6ca8145f6b46c5df7dc467	6	6359	359	589	604	19	4	2023-06-27 14:56:49.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
606	\\xfb90aaca6cb58e28002b1f0828f84ad2341032f392ee904f16613198e47dc19f	6	6361	361	590	605	7	4	2023-06-27 14:56:50.2	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
607	\\xe80b35d00cd3758a2f87385804a00b1f47cedbe14f66aa819ffbd0f7f8e01113	6	6362	362	591	606	12	4	2023-06-27 14:56:50.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
608	\\x87625dc5285180773d020369dd23bf430501e2fce296faf34e56ea97969c79fd	6	6381	381	592	607	18	4	2023-06-27 14:56:54.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
609	\\x2c974b5c90422a9ebc25aedcb2bc021d9a26212f886731ddf645b0395093d003	6	6383	383	593	608	10	4	2023-06-27 14:56:54.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
610	\\xedbf01c3b69dac379e4e1792396513d9296d1340c045eaeff037b60668ca1fb4	6	6385	385	594	609	18	4	2023-06-27 14:56:55	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
611	\\xbf619390459fcd4a7945fe089ab25d8b1c6bf896c7a8a50b4deb576892ab5bd9	6	6387	387	595	610	51	4	2023-06-27 14:56:55.4	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
612	\\x1e715779a5bdf4610ee32b413bb77156c75d10fa4908f8697f01843210ff0a20	6	6402	402	596	611	19	4	2023-06-27 14:56:58.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
613	\\xa14c9b813c7af7d098dd2cdfbebaadf02379f00d9b0dcc93fb8bea8ca221dafe	6	6405	405	597	612	48	4	2023-06-27 14:56:59	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
614	\\xa8c63ea4240ab9226a430d542446ead7074daafb5ac82c3f43f0a81dc198c371	6	6417	417	598	613	10	4	2023-06-27 14:57:01.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
615	\\xb49aae7a66eef6692a153d9814ab55b3617cc18644e42c59a3f0e81fd8f2950f	6	6442	442	599	614	4	4	2023-06-27 14:57:06.4	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
617	\\x7a4fcd7d08fef6367bf1199089c9e92e6243cdf139694f2bf7570b67f5d80b9b	6	6464	464	600	615	10	4	2023-06-27 14:57:10.8	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
618	\\xd1278e8a7bdd863d67fb9e5b1d3e23e07e79f99cbc01ceb3d025f917b2390409	6	6470	470	601	617	3	4	2023-06-27 14:57:12	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
619	\\x27d1b3c0166fc103d2a20aadb6c7112adcdb995d57063cca1c4a085f439bd935	6	6480	480	602	618	48	4	2023-06-27 14:57:14	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
620	\\x1f74595b037a96388c034fe37b5105e12e53f7e23ca089761cb7211cde5cf3cd	6	6489	489	603	619	51	4	2023-06-27 14:57:15.8	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
621	\\x985af1ac243daacdced76959afd05a76e0ef7eaa1ba7d27d05998eb575d96855	6	6495	495	604	620	48	4	2023-06-27 14:57:17	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
622	\\x214c0cedcd7643a8d0b658438032137ec393594fb03b32360d7cbffc5a080408	6	6503	503	605	621	18	4	2023-06-27 14:57:18.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
623	\\x80f5e1e3ee6478ded91b47150a27ad7dc4791e5d6c826a83ad920a2faea5cffb	6	6509	509	606	622	12	4	2023-06-27 14:57:19.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
624	\\xe02714a50aba4730c4ef50f75f36d3b2dfcbc96debe52a84a2c69daf11072137	6	6526	526	607	623	12	4	2023-06-27 14:57:23.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
625	\\x4fed34d7a8628c4a7d82c2da0f55e02d061c991638b7f5280ad55f572d6b91b0	6	6543	543	608	624	4	4	2023-06-27 14:57:26.6	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
626	\\xa08573a1312f4f362f4277e3bb764cbc9bae84dd5fae3d12aa551ca84642052f	6	6561	561	609	625	12	4	2023-06-27 14:57:30.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
627	\\x57f9546899fadfd83bd3f2956748060a7a0362b7d8b187491d7d41bc66435c05	6	6562	562	610	626	48	4	2023-06-27 14:57:30.4	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
628	\\xd386b5e70a600bf1bb79c1a670cbd3b5b4b931a34945bdf87ccc74a9f994ec64	6	6583	583	611	627	17	4	2023-06-27 14:57:34.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
629	\\x609662f24f340d8f2378721a66dadc2d6889a5c06d11f4c9a0c855e76c40939d	6	6589	589	612	628	3	4	2023-06-27 14:57:35.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
630	\\x154165651a7375bfaea7728e42b3acc002d16ccdbc23097799fab01ed756be49	6	6595	595	613	629	18	4	2023-06-27 14:57:37	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
631	\\x9fb778a07cc68c9eb7e7da6b0ba45b63421a5d83f1efef9b804ba6a86b4932ab	6	6634	634	614	630	19	4	2023-06-27 14:57:44.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
632	\\x4986bf42b384a74e9ba54a11b706d71354cf99f0ddf06bc42aeebf4a5ca3583d	6	6642	642	615	631	18	4	2023-06-27 14:57:46.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
633	\\x2dff1a42f17efa3ed803d506375ff714d472297da26462491aab6ee16d406b09	6	6651	651	616	632	18	4	2023-06-27 14:57:48.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
634	\\x2ba3549b463685dca5fea80f9288330b7415583a86f85f8e5c69cad2eba94503	6	6665	665	617	633	18	4	2023-06-27 14:57:51	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
635	\\xab2ee9c898a948e863651fbd4c10501c1fe5d04afce00a3b9af9e52a2a87cedb	6	6670	670	618	634	17	4	2023-06-27 14:57:52	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
636	\\x14610ff1800ad37c2c12aa1c92aab43fc55f18910d792e6b1446fc3df553c935	6	6690	690	619	635	6	4	2023-06-27 14:57:56	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
637	\\x2fd3af65558e6633e9f1e184df33dd99b6ad3fdfc4d4c4aa4795e0a11b04ff96	6	6693	693	620	636	10	4	2023-06-27 14:57:56.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
638	\\x0fc470b52a179f9b3c1d3b7ecbdf1bd1924902ab65258757296d9ff8b0214f33	6	6694	694	621	637	17	4	2023-06-27 14:57:56.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
639	\\x452c83fd40f030209e057c117e2cd745c53b389dc399144de5addefa6fed415e	6	6717	717	622	638	18	4	2023-06-27 14:58:01.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
640	\\xf31096877b3c6b325123a564f4da021006406be3b0c99ddea6f6bd6e5d364e4d	6	6724	724	623	639	3	4	2023-06-27 14:58:02.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
641	\\x52fdffc8cae37f61ae14c3d46004b6846d1c07d902a9396bca6703f9742af423	6	6729	729	624	640	3	4	2023-06-27 14:58:03.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
642	\\xd479b0b6e2d1fc8c5b68367566f3ba1fdef3d26a0be387d5c5ab18b068455262	6	6732	732	625	641	7	4	2023-06-27 14:58:04.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
643	\\x09d55fe50e54667150badfe7bcc65d67dd7ad7fec2d114e9f610eee3ca6e5231	6	6739	739	626	642	12	4	2023-06-27 14:58:05.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
644	\\x76932e6fd8ec0b726cc005b4b02c000706fd0a3071344467608681189b1019df	6	6746	746	627	643	19	4	2023-06-27 14:58:07.2	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
645	\\x5f3334e8a2006599bd3a8769edec6be63fdafeb2f3107526ab854801c338ba83	6	6753	753	628	644	51	4	2023-06-27 14:58:08.6	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
646	\\xb3b82151cce353144cd23d43ffcfeef87ce10573b4ba567ddf6405dfd4c3ea87	6	6760	760	629	645	48	4	2023-06-27 14:58:10	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
647	\\x66add819c9ceddac25d06d13232236d397ffbc2472379dbebc70b61cd1631193	6	6777	777	630	646	17	4	2023-06-27 14:58:13.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
648	\\xf51451f8c74c9f9bb74b79ec4dbc4005fc8426826a6ba1a40b0bb8134d668fc0	6	6778	778	631	647	4	4	2023-06-27 14:58:13.6	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
649	\\x1274f1e6416107e94de67365be33e7666d983ef64eeb7ad74539ea500c24b5be	6	6791	791	632	648	17	4	2023-06-27 14:58:16.2	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
650	\\x3a81fe1120a541c651a5c670c56ff66f10697519ede992b4830a27dd032a78df	6	6794	794	633	649	7	4	2023-06-27 14:58:16.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
651	\\xc4b25a01d61efe15cbe17768fe60d684667de8b8837a9c4b3df6f64ef1419444	6	6823	823	634	650	3	4	2023-06-27 14:58:22.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
652	\\x137269b9e2f585977457193da09e9add1edd21228284306450a5abed6d773e84	6	6843	843	635	651	19	4	2023-06-27 14:58:26.6	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
653	\\x62a2eff6d58dcbf9441e2f96ba6ee9053f5d5ddf1f1c6a98c490ea8c662cbe74	6	6844	844	636	652	17	4	2023-06-27 14:58:26.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
655	\\x8603913a49c52671077617ee014c0813331bee1a7abc4b1c4d289d9ed05f9b0e	6	6845	845	637	653	4	4	2023-06-27 14:58:27	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
656	\\xe5b511fa2c19f48721774ef10da3a44d87435a9fb46cc32a31866dbd45c2558e	6	6851	851	638	655	6	4	2023-06-27 14:58:28.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
657	\\xa23af89a6d5c2933257d01ecc61ee4e18da98407b2baba760b164e5e448061dc	6	6853	853	639	656	7	4	2023-06-27 14:58:28.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
658	\\xc5fecfa9c139fcec0dc07ab59213f5d3789bf347f6ac89cf3f64fe4c7ebb2f71	6	6863	863	640	657	18	4	2023-06-27 14:58:30.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
659	\\xdb2999662c5f8c90f7045c89931ce05339494bdb1f89eac12cf05920be550c37	6	6864	864	641	658	7	4	2023-06-27 14:58:30.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
660	\\x1c1bd9ce1516552bdb2ee8ce88d8bf418ebe170245c09a0d61abf24c6d1bd481	6	6865	865	642	659	48	4	2023-06-27 14:58:31	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
661	\\xc1762d849cbcd480e84c0952a3162d18408ba77d3e532014522d57f220dfe55f	6	6874	874	643	660	19	4	2023-06-27 14:58:32.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
662	\\xcaab43816b0f5f2a608654ae4daebc9c65cd7668876baaa00638ea4d2980ee1b	6	6875	875	644	661	17	4	2023-06-27 14:58:33	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
663	\\x104d69af80a25b6a49a30f422a44936213fe912d35f58253af026aedf1cf7148	6	6881	881	645	662	51	4	2023-06-27 14:58:34.2	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
664	\\x258c7f003ff9f8918da3829edf03a89b4b6d83d372469d9f66e1e9af659c4cae	6	6888	888	646	663	18	4	2023-06-27 14:58:35.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
665	\\xbec8581e724c32af3176bbf9fa2691686c5d2762af3be62461318251246d8e3b	6	6892	892	647	664	6	4	2023-06-27 14:58:36.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
666	\\x7a25a1e27b33d1ffa14ebb153325e07e271abf5d81d4a4eed4c7f60d3065da5e	6	6895	895	648	665	17	4	2023-06-27 14:58:37	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
667	\\x22fc0e2336e4fb038a95b1831efc9551734a5409b6d5c6ab4a070221ca6d7ce9	6	6905	905	649	666	51	4	2023-06-27 14:58:39	0	8	0	vrf_vk1fd3s676f4nw6nrshlkccx55fp835p8eu3kd4g9m9utq3egclrats37m339	\\xacb6767a8ca4e8876b30050c8aa02c3cf9fd26f42b7e2903c4f799d1b5fb8db1	0
668	\\xba77a9b493a8b3b1db308ad31f7fa2c6d84bade4cb4cc16287c5530e5169285f	6	6914	914	650	667	4	4	2023-06-27 14:58:40.8	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
669	\\xc9b688e6522ede3b8462ad58f016568ec9eda39ad8bcab4ed7b72b6f9b47b28e	6	6925	925	651	668	10	4	2023-06-27 14:58:43	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
670	\\x3f96329e74eda08dff8d0842249bb83d6b2380e38564a32631cd9155947e4f5f	6	6944	944	652	669	17	4	2023-06-27 14:58:46.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
671	\\xbcf10f3e8268bdaed0e883b4117d5555848f6eb59c5c91f9b058b9614e8e49cd	6	6957	957	653	670	6	4	2023-06-27 14:58:49.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
672	\\xd20caa5ccf530c3dee273f918d42f3fe08927ed2977d4d5c9a1326489dcb7bcd	6	6963	963	654	671	10	4	2023-06-27 14:58:50.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
673	\\x3720d88c75fc1751861bbc8bf6c23ffe27b9fd2f69c479c9f453f888e21f3e32	6	6978	978	655	672	10	4	2023-06-27 14:58:53.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
674	\\xb6b3181be74063cfd55f902b7ec4c57939ae367fc2aefecd8d43f948be7516a6	6	6984	984	656	673	17	4	2023-06-27 14:58:54.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
676	\\xa7e0eb1827d1b1a3806efe7bb73a32904f42d8cb746d472c113cd531153ac44d	6	6996	996	657	674	4	4	2023-06-27 14:58:57.2	0	8	0	vrf_vk1cldv2y4cqkcht06qukgf58v5qv2exkvwvytt98wn6z8jgr7ya6qsujgeqx	\\x0e44c36c15a76c7de2ba6e9b7fb5790589e948e6ff06b14506405509efefc50d	0
677	\\x9b518c9561e0788d2ae5e6a50b49a5fe92f12629dee7cbf110798eb2542dda6f	6	6999	999	658	676	19	4	2023-06-27 14:58:57.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
678	\\x9c3b777d6d29825f98e5579ca78ec8a0b85071a3e31215e74b761c0537b1deb3	7	7023	23	659	677	7	4	2023-06-27 14:59:02.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
679	\\xfb6425fe2baa3c0ad74b3938b95b9b7358bb30f61f05935bca901887732effa0	7	7026	26	660	678	18	5252	2023-06-27 14:59:03.2	18	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
680	\\x110bc37efa4b1f2d465bfc909d69b79582d8617663197e7faf13a06d26cd8334	7	7027	27	661	679	3	1742	2023-06-27 14:59:03.4	6	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
681	\\xc156781b1beaf161ae3aba5c9c791a630bacb772cc54476c5ea3eb91fbcf59f7	7	7055	55	662	680	19	23155	2023-06-27 14:59:09	76	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
682	\\x6dbedc9a678687cd7acfcc3f39ac1f6893a0e19cba5494806c8c3881335707d2	7	7060	60	663	681	48	4	2023-06-27 14:59:10	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
683	\\xaddff1033367687747d0522b181e43560d43c02017b867635bfc3d0b35d10959	7	7061	61	664	682	3	4	2023-06-27 14:59:10.2	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
684	\\x61d3f0dbc58632d7d809bbe286e7c4eafad5e44d58be58a45c7b773a6d8ae061	7	7064	64	665	683	48	4	2023-06-27 14:59:10.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
685	\\x3925b24a17b1244ba8a66f2d4c996ec428eeba8f70fe2d3b44f218d2142c8cba	7	7068	68	666	684	3	4	2023-06-27 14:59:11.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
686	\\xb81e71de26804a5663e67530bf29f020ca1932fb6394a5ab2652b917fca55626	7	7070	70	667	685	12	4	2023-06-27 14:59:12	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
687	\\x0b84a0462cea9952046378e099527e86eadce568438364ad7bf7b8e42fcc1d8e	7	7072	72	668	686	19	4	2023-06-27 14:59:12.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
688	\\x86135f79e302a965cf60e9965cfc13e503bfaec8a7a29d1eba5417cfa8a142cd	7	7115	115	669	687	10	4	2023-06-27 14:59:21	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
689	\\x4886d46ca4d607d023064b0389bf28d4b7189eab4b253ce2bc7f2691efe7ff0e	7	7128	128	670	688	19	4	2023-06-27 14:59:23.6	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
690	\\x4cfad8fb7a21eb9cc95990ec96d8f8134b5ff934495ceb126ba1f1a23787e955	7	7142	142	671	689	6	4	2023-06-27 14:59:26.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
691	\\x72bb78972d1a57509810696bbfc4d8105d297fb1157acadbbf5aaacddf7f4941	7	7144	144	672	690	19	4	2023-06-27 14:59:26.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
692	\\x03b212c68188edd9949b792a37bc659e350ee24fd6e735e7f927c125f1fab079	7	7145	145	673	691	18	4	2023-06-27 14:59:27	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
693	\\x59957bfbf08969657970ef7489f53ccb5c79f4fe5978df1045f6bd67a229a6c4	7	7146	146	674	692	7	4	2023-06-27 14:59:27.2	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
694	\\x2751b1d1a3cfba9ca91d3ef65d82c085425ede03c652e2da76b9fdff8e178c09	7	7148	148	675	693	12	4	2023-06-27 14:59:27.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
695	\\xfbd01a6c5adf9cce69707559057c05045bd8040f7743188d294d0693cd369b79	7	7157	157	676	694	18	4	2023-06-27 14:59:29.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
696	\\xc30564a2487b8b953880c46100272b334f53df44b9feaaf78a957023d31c0397	7	7159	159	677	695	3	4	2023-06-27 14:59:29.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
697	\\x5404e5b97abc81d0ab900b40510af420bdaa8e14662095bebbac75cadb73cc2c	7	7168	168	678	696	19	4	2023-06-27 14:59:31.6	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
698	\\x434e13236a2bcd8b09998d4f8307f049e7d85349335a542e04676f3863792238	7	7184	184	679	697	18	4	2023-06-27 14:59:34.8	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
699	\\x4dbcc5e8782cf7cc93ec5e5a6c98c37b8b39640fe65d2a77c5afb2a17b4e8a8d	7	7186	186	680	698	6	4	2023-06-27 14:59:35.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
700	\\xa5ee5c2f84ea89984451511440ae25ea8d56e0ae0eeacf9a02593f793ffc3795	7	7205	205	681	699	17	4	2023-06-27 14:59:39	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
701	\\x8f48af7989fec75e1a7fbbb6e19a0510ef07170bfa602e47d3bfc0f71db7d0de	7	7212	212	682	700	48	4	2023-06-27 14:59:40.4	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
702	\\x14472e20ccf8b5eaae4192807c47ed858f776fd5e35c80520f57902d1bb5a6dc	7	7228	228	683	701	17	4	2023-06-27 14:59:43.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
704	\\xc7a91530e13c85a2be92f054a58fddd695d0d4c017e28be56154b0b47c47a701	7	7257	257	684	702	6	4	2023-06-27 14:59:49.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
705	\\x8d4bbfa2bd613d1284a6ac76af81d0f99795dde4013bc251af1a71b591100fdc	7	7262	262	685	704	7	4	2023-06-27 14:59:50.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
706	\\x660fb4844489346553c25c6d5b6ea49817c5de4e22adfddbf42423a5480a0baf	7	7285	285	686	705	10	4	2023-06-27 14:59:55	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
707	\\x67228fd3ce9b282fe0b39e63afc0872304f8c6e7b9c4a4def542db4a2326745f	7	7290	290	687	706	6	4	2023-06-27 14:59:56	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
708	\\xaf368196840870d2f57cb342d9952a467cd2fa7e01ea1e078ec469debdeed1b1	7	7298	298	688	707	10	4	2023-06-27 14:59:57.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
709	\\x2d8cf77c715a4fadc90e681194c20c3ff9e5835e2f680203747089d48b8fccd1	7	7311	311	689	708	18	4	2023-06-27 15:00:00.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
710	\\x1212d61291dd54dfd61da25d219b8515682741ecbf5e3a8718e8a2249bc219c0	7	7314	314	690	709	7	4	2023-06-27 15:00:00.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
711	\\xb89bcf039fef084f7064adbac2f6f0df036c4f78c3a31e8dddf19a01ba921dde	7	7319	319	691	710	6	4	2023-06-27 15:00:01.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
712	\\x07d5de503ac6d812cad940ec8400418776ccb568815f4ed7e5526935811b13b4	7	7331	331	692	711	18	4	2023-06-27 15:00:04.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
713	\\xf7b3c17fbbe7a3dcd0919d2bafcd0d1d0ecc080b3e0b87858e39eea280d8c115	7	7357	357	693	712	7	4	2023-06-27 15:00:09.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
714	\\x474cc83ec805e033b2af7079b7ce46512d7883a0ab42e8c0e97d0020ba51a245	7	7363	363	694	713	19	4	2023-06-27 15:00:10.6	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
715	\\x0b3c789080244a39fd47092dbd7bccf2583f2ee4f5ae34a5e2f5865646eaecba	7	7399	399	695	714	6	4	2023-06-27 15:00:17.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
716	\\xf6c981b1592a4df68966c6cdeed32cc26d69b63fda6dc625646a1e9dcb5d303e	7	7400	400	696	715	12	4	2023-06-27 15:00:18	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
717	\\x35d7acdd5ee439d0b9e92380e438e625c85b4bad594327df58a42819e9c94e5c	7	7410	410	697	716	18	4	2023-06-27 15:00:20	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
718	\\x76cad0394146abb1ae70a3869f11c90aba132da3471d361cdfed0b54faaba711	7	7413	413	698	717	10	4	2023-06-27 15:00:20.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
719	\\x930a843b2dc9f31a4303473c436ab0bdd4a0c6222b9701b1380573f66e8c4d3a	7	7420	420	699	718	18	4	2023-06-27 15:00:22	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
720	\\xdbf1d2fb65a8af4cd1a169d61b5ab2f5e5bd745392286b77b1425efa6be84635	7	7426	426	700	719	48	4	2023-06-27 15:00:23.2	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
721	\\x5197bd0e89c7b81dd2ec98fe2fb841c79d7afe3f25c743ba171594300d1b06f1	7	7427	427	701	720	7	4	2023-06-27 15:00:23.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
722	\\x271794a8a9427a1f28645f3e09524b54fdaeca1cd32833250f02871f495eebb2	7	7434	434	702	721	6	4	2023-06-27 15:00:24.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
723	\\x2489d99f9a16b0269d65af4e22a1684efe99e97dfb9055db3c814f591a9e799f	7	7436	436	703	722	17	4	2023-06-27 15:00:25.2	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
724	\\xacbe289157e32e7e1ac8644f86662f58079731a4b78da461eb4c3cb71e7c53b4	7	7438	438	704	723	7	4	2023-06-27 15:00:25.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
725	\\x090614617b7f0cebdaee7798645c529660693c52ac462a29207de33edf1579e2	7	7441	441	705	724	19	4	2023-06-27 15:00:26.2	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
726	\\x836fb1fed7b38664d512156676851793cfefc7385e404afcc3a317f0834f39be	7	7442	442	706	725	10	4	2023-06-27 15:00:26.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
727	\\xaaff87ee7e4de93318e93948e19f63cb6e5cbb314850560921e210ff17d6836d	7	7448	448	707	726	12	4	2023-06-27 15:00:27.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
728	\\xca20cad05878c602fc4b271eb5f498209460e5ec8c321982bd664b841a12c4a9	7	7450	450	708	727	6	4	2023-06-27 15:00:28	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
729	\\x9ce36f4c8a0cd8b1005b2696737b368e20e0402dfc05262e507cabcdcca312fc	7	7456	456	709	728	10	4	2023-06-27 15:00:29.2	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
730	\\x9d419b1d34b9e4c61f86b2a3e739de38c002ba64d4c1f6054b0ff8748eb9e114	7	7461	461	710	729	10	4	2023-06-27 15:00:30.2	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
731	\\x26c264ad4bc409c6efd5308d6573dedecc568ce8d3d65c17d7b59c729e984e5f	7	7480	480	711	730	3	4	2023-06-27 15:00:34	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
732	\\xe48855b68bab23f4fa827add567148f3a0878c7ac1e1fdb3e133c7089406b975	7	7483	483	712	731	6	4	2023-06-27 15:00:34.6	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
733	\\xa5971e1d372e501302609b826f3a6de0d141d12b3a137559005a15a7cdf085be	7	7494	494	713	732	6	4	2023-06-27 15:00:36.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
734	\\x58b384f5cd2415ec79ca484e0b336b50e6edaaf7de54d9cbdcf78e125212cb99	7	7510	510	714	733	19	4	2023-06-27 15:00:40	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
735	\\xc5814abd4ab4ada562cd5930c0bebe07cbd7f7bc26076b63a631d9eaec6c8cd6	7	7511	511	715	734	10	4	2023-06-27 15:00:40.2	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
736	\\xe965999b2867482a05a25e29df8abd2dc7fbd3bb76c4b2f70622de0cceb556a4	7	7522	522	716	735	17	4	2023-06-27 15:00:42.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
737	\\x6ed0eba45888c35eee9da066f673f5dbb44acb54038fb890148c74e4c174a36b	7	7558	558	717	736	10	4	2023-06-27 15:00:49.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
738	\\x898bee958bf2d82a1ec2ea6ac29f3317c6ef4b509404010ea7aa571cdd1f2823	7	7559	559	718	737	6	4	2023-06-27 15:00:49.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
739	\\x5ccb69cd9519c6737fcda53606d48dcead753db28f80c2df5e24544e2bf3604b	7	7571	571	719	738	6	4	2023-06-27 15:00:52.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
740	\\x2a177adbfa585d142ef9e245d29845dab27510370d6e3e645341ab171323c4ba	7	7601	601	720	739	3	4	2023-06-27 15:00:58.2	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
741	\\x70e2d443ae11ed7435e2359e1c4fcb2b21802396a1778fbe5fb9fe253f9986df	7	7607	607	721	740	18	4	2023-06-27 15:00:59.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
742	\\x36df69879cc24a626d4400e2346dd039076c2a9d35b535952a2e619d3cfc1b6b	7	7612	612	722	741	12	4	2023-06-27 15:01:00.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
743	\\xc80856f9da4dddcedce6dfa8b6b576599fe6584c57224bbece7dd77b508cef9c	7	7635	635	723	742	3	4	2023-06-27 15:01:05	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
744	\\xbcf2c70f883b25ae181edfff64ad8bd07bb5aa1931dd55cac772055a1ffbc823	7	7637	637	724	743	17	4	2023-06-27 15:01:05.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
745	\\x23d9477f983e988649d289335d255c0547956c2d583c93d4076b44689979e215	7	7640	640	725	744	19	4	2023-06-27 15:01:06	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
746	\\x30f25a76258972dcec1b8ec68b18168800554f114228ca188bfc3b20a9ed1bec	7	7663	663	726	745	10	4	2023-06-27 15:01:10.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
747	\\x7e9634a7a31d8d6b028946e312afee74a80193a8a58b5f04ff95c083a3451c86	7	7682	682	727	746	6	4	2023-06-27 15:01:14.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
748	\\x58fc6992e5e9da553e4f5de64f55ee8f8c1b343607483357b76b33e447abb09a	7	7694	694	728	747	7	4	2023-06-27 15:01:16.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
749	\\xb337be00539679101a9a1cc7e9da61dbf7afda7c9dca1e794f21a6d2ae45e5be	7	7710	710	729	748	17	4	2023-06-27 15:01:20	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
750	\\xf4d8cd393b10f23725b02264ab0b3eb4f995bf733ad5e9a67d7b9f0d3888cbe1	7	7732	732	730	749	10	4	2023-06-27 15:01:24.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
751	\\x30e4442b8340976456bac00f3d63f4be99f0aa12f8c483cae57d4f060e6ad935	7	7748	748	731	750	3	4	2023-06-27 15:01:27.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
752	\\x106447df38099c1ce019b643c222591f6c9241752c0dd2901a72d3117e6b5500	7	7749	749	732	751	17	4	2023-06-27 15:01:27.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
753	\\x5e79a641ea115606ab62c2b07fe9382e70753c3e24c9d365e77da702c5307081	7	7750	750	733	752	10	4	2023-06-27 15:01:28	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
754	\\x6b33ed3b762b3f6ee8b4aabef41541a063531520c8313d28fbef48fef5f463e0	7	7756	756	734	753	12	4	2023-06-27 15:01:29.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
755	\\x35c888dffd4e33e51a29902b3e32d87ea24aec18b802970587585b3a84141d0d	7	7770	770	735	754	19	4	2023-06-27 15:01:32	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
756	\\x69864b8decd459b81e2caf83563f3e1eda728b87623381da2b9d853c0ca9f992	7	7772	772	736	755	12	4	2023-06-27 15:01:32.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
757	\\xa04bd40c4bec466c208a352c6d1dc832b81babf3261f57a2fd287350758be08e	7	7798	798	737	756	18	4	2023-06-27 15:01:37.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
758	\\x038036253ab2830a06dd720205a28a01c0a9e82914102f157b538d297243d3d3	7	7800	800	738	757	18	4	2023-06-27 15:01:38	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
759	\\x46a7ef2ed83f2bcaa2772907bb1eddea5d6e2c0982aa0291bd48c3191a326954	7	7832	832	739	758	10	4	2023-06-27 15:01:44.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
760	\\x4aa3fe71faf8aeaefc4329943be3c88ac3145bb2da375016fb06dc85ff420a86	7	7834	834	740	759	17	4	2023-06-27 15:01:44.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
761	\\x294db1ecdcd9911b5e4ba4915257eddc1086c41499d579e78cbd6ae4c87404cf	7	7852	852	741	760	7	4	2023-06-27 15:01:48.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
762	\\x30d73a3557796491e39a41591b44cec2d7a6a43a9e4a4d52a7a6c3417713268a	7	7862	862	742	761	18	4	2023-06-27 15:01:50.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
763	\\x29c8891aee3bfa131bcd927a4643a9518b4ac99e186e43e6618164f36a4662b7	7	7867	867	743	762	10	4	2023-06-27 15:01:51.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
764	\\x5e30f692146cc769840cc865821bf1fb34729280d4d0377bda6ac74327575049	7	7869	869	744	763	17	4	2023-06-27 15:01:51.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
765	\\xee0e008a1d74a0d02fa3feb297dcbf9aec708053fdfd41e8dbaa5b11b8e25986	7	7872	872	745	764	10	4	2023-06-27 15:01:52.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
766	\\x7a6c9acddee57c0ff1604558ee57dd57eed4d9fa9fa20667d4bb537eded7fc90	7	7874	874	746	765	6	4	2023-06-27 15:01:52.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
767	\\x22bf2c37355f9099140858cf01672168417f725593b425c608449a63a61f0813	7	7918	918	747	766	6	4	2023-06-27 15:02:01.6	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
768	\\xc93e6b0e6f16062ce1076590f8eb53513c606de1a523add360dd072b64253989	7	7939	939	748	767	3	4	2023-06-27 15:02:05.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
769	\\xdb6f4fbffe7b22133e8084adf7a9ff0810c4f2b5d06adbb510b26e0f9e38bbac	7	7958	958	749	768	3	4	2023-06-27 15:02:09.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
770	\\xe1b1d32cfe4db71f75a2b75a8a8e0be52dd730ae98e8d4a827087356e830b23b	7	7961	961	750	769	3	4	2023-06-27 15:02:10.2	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
771	\\x624808cfadf8139b7a96d9216e6b27942d0e0314a6a91a675f072aee27382b06	7	7967	967	751	770	17	4	2023-06-27 15:02:11.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
772	\\x0ccaadd00cf64787ab6ab74529c8da1c74d107b7bd6f466b8c44c807029faf51	7	7974	974	752	771	3	4	2023-06-27 15:02:12.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
773	\\x43afea49d0e9c886dc0be36eb1b6311172b1e501a2d582f6eae4d005e336da57	7	7976	976	753	772	18	4	2023-06-27 15:02:13.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
774	\\x992e22fbc41d63ca182ac09317f03028fe0791a2b9153824a541f26b79cd8907	7	7977	977	754	773	10	4	2023-06-27 15:02:13.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
775	\\x8c97ca1ac2cc22161bd30270b676148307466de91fd925e7ba7e685fe13fef21	7	7989	989	755	774	7	4	2023-06-27 15:02:15.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
776	\\xccb2a569346a32d79a8063a5f22363006bdebbd44bf85e64871f54a510bdea70	8	8013	13	756	775	18	4	2023-06-27 15:02:20.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
777	\\x2281578e25e71743552df2def82c4bcef67539b09724332efd748b150b4215ab	8	8034	34	757	776	6	4	2023-06-27 15:02:24.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
778	\\xe3267ec55ef6b5d24842b257700384c508c98b870b700d0939271f281151881c	8	8046	46	758	777	17	4	2023-06-27 15:02:27.2	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
779	\\x9624fe1d0685b63a4ffcf4a753a1953038cd0d11a88c735ce60b4d33a037453c	8	8057	57	759	778	17	4	2023-06-27 15:02:29.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
780	\\x3328c3a735bb241fc5e250013f5f29d639d8f6009b4b4ccd7393123a68da6f7a	8	8060	60	760	779	7	4	2023-06-27 15:02:30	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
781	\\x07312acc2a66dd2633f057da1bf3720f4a59ff00e4997207cb6b42e8e005761c	8	8064	64	761	780	6	4	2023-06-27 15:02:30.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
782	\\xe8fcf21161c2e2f8c7eb25022c20dc6d37423ca1b45694a4e4adedc0ed0e7abc	8	8067	67	762	781	48	4	2023-06-27 15:02:31.4	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
783	\\x819305c17d362ae0e9905fd097dd6d6e33e85f3ca9822d5d77f7f01206756cb5	8	8076	76	763	782	12	4	2023-06-27 15:02:33.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
784	\\x995ec8d4234bf1547b710bf404b9d3971027b8c6ec6d915593d62906073ff937	8	8079	79	764	783	10	4	2023-06-27 15:02:33.8	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
785	\\xe76abb79fc738b8fff38f5514027f9004bd9bc2723a46f214327b1675acd419a	8	8097	97	765	784	6	4	2023-06-27 15:02:37.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
786	\\xf52708e342ebe83b9e5b04d021ac2fac8303eda7816d64fa57d80a6117efe98e	8	8098	98	766	785	17	4	2023-06-27 15:02:37.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
787	\\x6aea2112294cdd18867dfbbf0d62b840ff16d32829cc23b29afab0c42c5141ab	8	8102	102	767	786	18	4	2023-06-27 15:02:38.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
788	\\x032c9ef0c78c8208f1471482bc6c210e50a90c7316aaa84adf69ff6bc51f1d32	8	8103	103	768	787	18	4	2023-06-27 15:02:38.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
789	\\x0c5bf410f2064cd6f6709b1cd981c0fed62074bf117c059094cadb082438df0a	8	8108	108	769	788	48	4	2023-06-27 15:02:39.6	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
790	\\xcaea028284656110d4c99e6e7b2b16a75ec4c8e2937aec677e327f1e958ec3f6	8	8114	114	770	789	12	4	2023-06-27 15:02:40.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
791	\\x0df5e34a7ae9317738986c42b06f15699df11bb2bb8d8647f5c1f79f4a03905c	8	8140	140	771	790	6	4	2023-06-27 15:02:46	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
792	\\x89f097854ee224e2ccebefbb3f2c8c72bab69eedf20e2ec9745aea07749d7f3c	8	8151	151	772	791	48	4	2023-06-27 15:02:48.2	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
793	\\x27dc0d8d2500fdb42bb04e06905b4d6b46d6beba5d7d5dee22e5993324c11fd4	8	8152	152	773	792	10	4	2023-06-27 15:02:48.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
794	\\x902125a79881bf0c555d8c6f1ae04a1eff885d898d045e37a6e0c186fde6bf17	8	8170	170	774	793	3	4	2023-06-27 15:02:52	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
795	\\xa458e0292f22c5be3d7cbf2ffe2eddd7f427a9756b52b46769e1942175043330	8	8177	177	775	794	3	4	2023-06-27 15:02:53.4	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
796	\\x6317a8315044ff5d66d5de6aa4081597e2699e65c69d8efd2c8873f2fc0b8ce7	8	8182	182	776	795	17	4	2023-06-27 15:02:54.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
797	\\x54d42a4557761d97579c7330152f97d5d05f2dc0f705a40947ed0db1e63d0e81	8	8189	189	777	796	3	4	2023-06-27 15:02:55.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
798	\\x7714bc60b0f0b5ea3d4eb2f94c44a9358cbfcf28a88c3e86df31597cdb5cfb8c	8	8199	199	778	797	19	4	2023-06-27 15:02:57.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
799	\\x66812adc7a3e53a2c8fed7b0f8c0a23c359d2b32302a97f0c61520a63c457cf1	8	8210	210	779	798	6	4	2023-06-27 15:03:00	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
800	\\x67e03e5daa5456ef4bf00f0f9059383f3b6a11c4aa4c41c54e11b64e6112e99f	8	8223	223	780	799	6	4	2023-06-27 15:03:02.6	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
801	\\xae866c41a82dfdb173d78506431be742f952a40ccd41bc8fd2edd3b57c8919a4	8	8233	233	781	800	12	4	2023-06-27 15:03:04.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
802	\\x360407c054db213e63bcfac0bcb20a668d82e338cc80c14501d6682d671409b4	8	8257	257	782	801	3	4	2023-06-27 15:03:09.4	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
803	\\xb3ffd3ad12c3d13650cc4ab9674e651519bba648e4a497f04a3963936399d978	8	8258	258	783	802	3	4	2023-06-27 15:03:09.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
804	\\x48c38551b351cf0d3c76af684e7956932b459a43a00d70caa028c8f8c6fe173a	8	8269	269	784	803	6	4	2023-06-27 15:03:11.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
805	\\x17b6af05baf9c01ccee3049f68e2e3d627bc83251a88e39c06f909f6f335e925	8	8271	271	785	804	6	4	2023-06-27 15:03:12.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
806	\\x02a02d304f60dc8728c701798507724446572e774e4131460ef7b73e0f1fe801	8	8281	281	786	805	12	4	2023-06-27 15:03:14.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
807	\\xad613feec7bbb357c2a64caf534fc5ee969657a199dae077ddfe76dd16dd186d	8	8298	298	787	806	6	4	2023-06-27 15:03:17.6	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
808	\\x80c3dc6b9d4c6bce95baab7f893ba0558caaedbec1ec6466c6fc8a9074ebcba2	8	8299	299	788	807	10	4	2023-06-27 15:03:17.8	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
809	\\x3dbfa1d935c548908ca0f30c649ef5ec613159e90e96e520c629335f736b687b	8	8309	309	789	808	17	4	2023-06-27 15:03:19.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
811	\\x9f3d50f41f37f1860f940a499f89892d9af98f306a096eed2d31da4da91b77f3	8	8318	318	790	809	48	4	2023-06-27 15:03:21.6	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
812	\\x99326640c5ebd242e950d160074e007d62708d35a9c3d144bcb691290cdb07e1	8	8319	319	791	811	19	4	2023-06-27 15:03:21.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
813	\\x81aa760eeec81d53f7ecd355fbe433662796a9a92a0578f850cb771c13632586	8	8332	332	792	812	17	4	2023-06-27 15:03:24.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
814	\\x0f482a1ecd333e6feb0df69b6d9669d7c30b35a4609ad76b8e6aa1993eb7240a	8	8334	334	793	813	17	4	2023-06-27 15:03:24.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
815	\\xeff6b7957ad403bc7b1b4e30fcfc9b05adfa23e1ede7b5c0dc23f3bd99895df5	8	8341	341	794	814	12	4	2023-06-27 15:03:26.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
816	\\x3a4a3bf5c556bc8fba521c1aec155ec066b72df1798eb4088cf6845e4e2007d8	8	8371	371	795	815	12	4	2023-06-27 15:03:32.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
817	\\x718cd5590e1d3a21e4efebb09c17f1aa185c74b58651f1d3fa8d89cafbb56f7a	8	8385	385	796	816	6	4	2023-06-27 15:03:35	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
818	\\x7a6132df1b4e55cade06d4d798ebf4c90169aec2b4e44ed42645d0bf88426d3f	8	8392	392	797	817	19	4	2023-06-27 15:03:36.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
819	\\x7528fc16af95e527d7a971be436b8da8d1968afbdfeeb59ceda87d9306d4af2f	8	8396	396	798	818	17	4	2023-06-27 15:03:37.2	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
820	\\x05f4ed17c6313a75eac9f5bbbec70211e145ab8d26ba59d3108711f9c308e560	8	8399	399	799	819	6	4	2023-06-27 15:03:37.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
821	\\xbfdab3d58bd35ea7b17d51cc3f60f3e8f00bd6e9e831bd2eed02c4f02481b51d	8	8410	410	800	820	18	4	2023-06-27 15:03:40	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
822	\\xa4624a89c6188527bc7612f04f7fa0f1a9cf7e4705435e5cc46081d1d40c376d	8	8413	413	801	821	6	4	2023-06-27 15:03:40.6	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
824	\\xff4c7002b2580803cdb27b98b6e1dcd1fd6e067f5b88706932e69e497d78c9dd	8	8446	446	802	822	12	4	2023-06-27 15:03:47.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
825	\\x82f86b8927b8a14e1c8c7e799da37332f2bc3d8773657559f05793a94f102990	8	8452	452	803	824	12	4	2023-06-27 15:03:48.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
826	\\x53a3bca35d491befb6dde0a4c19a0300f77f3f28f609771d901d2b3965769bd3	8	8494	494	804	825	48	4	2023-06-27 15:03:56.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
827	\\x2e18d362ad747fe1ec78b57cead013edfa37d1b3f84248d82f9a54bd11282f5b	8	8499	499	805	826	3	4	2023-06-27 15:03:57.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
828	\\x109b3ae2373fe8b7c23c9d97509c2e53edeeabc02add046c58f8db20cb14c95e	8	8522	522	806	827	18	4	2023-06-27 15:04:02.4	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
829	\\xc56219297095b6e60a7a43d5692f5ace1b965a57072e60dd9985319d361454d2	8	8525	525	807	828	3	4	2023-06-27 15:04:03	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
830	\\x350e588b012e7ea15ce81ddbd2a2bbb7b5ae7b1ab988cf50c7b99f5f63458aa8	8	8531	531	808	829	6	4	2023-06-27 15:04:04.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
831	\\xde6ddda3624c65ee82ac0911c9ee22a8d78cd6311b4d69acca854eecdfe66851	8	8562	562	809	830	12	4	2023-06-27 15:04:10.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
832	\\x73f58fc88631622cfe156bbb826a98d2522ef8fc216c2a2f05766e5cd7cbea8b	8	8568	568	810	831	3	4	2023-06-27 15:04:11.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
833	\\x8988ad54caa61f9410d82626b124eaad62c92e71a07dc57a1a2a1ebe0560c70c	8	8590	590	811	832	12	4	2023-06-27 15:04:16	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
834	\\x0589912ad232bbea442cfaf615e0abd40287647bc1084f5726bd2041b273f7b1	8	8595	595	812	833	18	4	2023-06-27 15:04:17	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
835	\\xa450fac8791d3751c796d82ca3a79abb2efcae44641a5973f4c4e3466a7d8f73	8	8607	607	813	834	10	4	2023-06-27 15:04:19.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
836	\\xf5e9682509efa3c396b73f1d70252cae4f40d0fb5bb8fa21fd22f526f240303e	8	8609	609	814	835	3	4	2023-06-27 15:04:19.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
837	\\x0ed494154260695c64e437cb9452ccd9ff0d62f725a6b3173ff12abfaf3e6c9e	8	8613	613	815	836	17	4	2023-06-27 15:04:20.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
838	\\xd45d799477162d55324b8fb1adab4f7e092fa8a903fc4db6a97cc296afcad844	8	8615	615	816	837	7	4	2023-06-27 15:04:21	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
839	\\x44673160e1014c55eddb5de627f55a9af9a8357951089b1c103e1ae30a712626	8	8619	619	817	838	6	4	2023-06-27 15:04:21.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
840	\\x26a3b756ea4b92560063b7a907be9d3a3cbf5cf633d0bc658587faacf9646698	8	8634	634	818	839	48	4	2023-06-27 15:04:24.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
841	\\x6e9c1bae11fff7bed613946d12c4b2c8774300c51ca2e5befeb77625ae2f5a1c	8	8650	650	819	840	17	4	2023-06-27 15:04:28	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
842	\\x33cea468f51cf33e9e37cec576fab2b5ee377b63ef7ed7aebb00245027f90bf7	8	8656	656	820	841	3	4	2023-06-27 15:04:29.2	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
843	\\x114df1d4464b3228300397f383dc1e4700bc1055cc8aaca113b645f09939633c	8	8657	657	821	842	12	4	2023-06-27 15:04:29.4	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
844	\\x2ef0cfd5a2bbae67f987026e0219f8df5d00db7ba3998711914136193e56ee32	8	8666	666	822	843	3	4	2023-06-27 15:04:31.2	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
845	\\xcff55e66190fe080669a56e5584bcde9b883e10abbbfecb80a4f2708044a7204	8	8679	679	823	844	17	4	2023-06-27 15:04:33.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
846	\\x13d2dda3a403bd11d392214fb48264d1f339b5b60886300ed4ac78bee4e355ad	8	8683	683	824	845	17	4	2023-06-27 15:04:34.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
847	\\x4d2ca2f7b4f7d6950c9e0750ddd5dcea7ce46dd9d59071abc8115a15ca64199e	8	8687	687	825	846	6	4	2023-06-27 15:04:35.4	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
848	\\x40fee1080db6a607ed37f9ddc71d91a8ac73d3e615c2dfb1f062003ad35ff434	8	8724	724	826	847	17	4	2023-06-27 15:04:42.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
849	\\x0c7c3d45f9800bf80f4753de2afe9b6a4e20ed4062a5a56102dc17574a71389c	8	8726	726	827	848	7	4	2023-06-27 15:04:43.2	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
850	\\x6c367cef1fcb105aa3a1ae3763a9c4be98e762519cb63fc6e8c5e1f76d1f6a61	8	8740	740	828	849	48	4	2023-06-27 15:04:46	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
851	\\xf8f4c9e4f6c8e4def59110746ebd94a58ffe16a2be5705b2447176eaab4b784e	8	8778	778	829	850	18	4	2023-06-27 15:04:53.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
852	\\x8835efa2e90a3e33f35312833e0bca8e1d024c0c1dde83de9a6d846dda418953	8	8781	781	830	851	6	4	2023-06-27 15:04:54.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
853	\\x31b3983022c811e19dd25607755af8e9402bc8b5305e29d50975da0479593be2	8	8793	793	831	852	18	4	2023-06-27 15:04:56.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
854	\\xa083c0792d724b5ca7edf276f9f786983c713d2190751a3b5b2d477094a551f0	8	8819	819	832	853	18	4	2023-06-27 15:05:01.8	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
855	\\xa07fa0ac6a1761d3af011db9b8fedc79a7c5ef4f1edf75e8636e80f51263e4a5	8	8831	831	833	854	19	4	2023-06-27 15:05:04.2	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
856	\\x62d9750c27995b6a67be7cbc7b2159da09822812dca4ea7b39b0b18978b552f5	8	8854	854	834	855	19	4	2023-06-27 15:05:08.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
857	\\xff9f01c00e1898de04d3fde3e34aea1f5c3b2fa5769a8df5bd2e7bbb3ef65730	8	8856	856	835	856	19	4	2023-06-27 15:05:09.2	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
858	\\xb2c26842f4617f456efb39326f0893a95ce78648f3e7dae8bfaf3e1c1487eaf9	8	8877	877	836	857	19	4	2023-06-27 15:05:13.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
859	\\x14105834feb00294d5168ca9c3a92d1e97c331c93a1145038c10ae08b8c71fe4	8	8916	916	837	858	6	4	2023-06-27 15:05:21.2	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
860	\\x3b385cb598c07c63c6b78d42b6176662fc94332f473dc20ad74213fa791706c9	8	8921	921	838	859	7	4	2023-06-27 15:05:22.2	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
861	\\xb1d591ef06845f5d2e75136710358cad01926e3c6543b9d3492776cfe894c9c8	8	8935	935	839	860	10	4	2023-06-27 15:05:25	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
862	\\x98e9f4a85e04ee94b206d1d1143fa641a0c87fe5352978d3a554953f44130251	8	8939	939	840	861	19	4	2023-06-27 15:05:25.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
863	\\x678f106250ac3201fa92072d16857de2b7dc4ea2a752913e74433bc9e8b1d94c	8	8947	947	841	862	10	4	2023-06-27 15:05:27.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
864	\\x250be103127a52aaad3b5fba0953ece9dce1fff9dbef2f682bf49efddcdd6b66	8	8963	963	842	863	10	4	2023-06-27 15:05:30.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
865	\\xd5233d87ee91dea5c2248f4610b112437c13c338703f8602af722e459c11d946	8	8972	972	843	864	10	4	2023-06-27 15:05:32.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
866	\\xb7c2d2f91f6f5e9c159bb9f75d31ac303722bf0b4c7d19255abb0774c6c6b8c1	8	8979	979	844	865	7	4	2023-06-27 15:05:33.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
867	\\x1a4ce69216bcec6dce80c1b0e053145254631e864696d3f38956ba883a08dc75	8	8984	984	845	866	18	4	2023-06-27 15:05:34.8	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
868	\\x7f62d5f50e0f08df8d082657c426ccb4119be1ba7be9559bb00d68e6c2afb7a7	8	8989	989	846	867	12	4	2023-06-27 15:05:35.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
870	\\x9e56ac7dbd4dfb8dba714836916ddd08bfc4553014712816858511c5fa1cd555	8	8991	991	847	868	10	4	2023-06-27 15:05:36.2	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
871	\\xfa502ac29c9c510fa2335f412d5fa8c657303074a10a4eb5f3ae3444c5701f89	9	9001	1	848	870	18	4	2023-06-27 15:05:38.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
872	\\xd5e594ab9333060c4d00e8909737438899207c07bd27bdf9b7b328fc1f5781c7	9	9004	4	849	871	19	4	2023-06-27 15:05:38.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
873	\\xf05ded5b4fedd4d8fe5f1252d119d074bd82ea12d19de50ac749a64c269910f9	9	9027	27	850	872	10	4	2023-06-27 15:05:43.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
874	\\xbc0b79a607d2fa57338c624932cd30b5098d6e83aee5e0bd254111bd1e3beac1	9	9040	40	851	873	7	4	2023-06-27 15:05:46	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
875	\\x3dcdc1d57e48cd84cef7a60cb9402d192ac8fd01c96d47ffe328c3c97e6c9014	9	9050	50	852	874	3	4	2023-06-27 15:05:48	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
876	\\x369b8909257d75d98de6ff429022fb83dd5c2d50d1686a3aa943ca61bd0ee61e	9	9055	55	853	875	17	4	2023-06-27 15:05:49	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
877	\\x27b1436fba258fac58cf49cbc9dd51faee775fb17f59c49f953d9019d66bb0b5	9	9059	59	854	876	7	4	2023-06-27 15:05:49.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
878	\\x5bd5fbbd0a0d76c6beb475821f547c8601e2f2598e3220467e7ae6c742a19855	9	9065	65	855	877	3	4	2023-06-27 15:05:51	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
879	\\x511c6779474edff649d4bb9683a9f135800441a5e84de3dd4e6dc6a9024cc225	9	9068	68	856	878	6	4	2023-06-27 15:05:51.6	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
880	\\x68043a36a7832a55ce8901c7c53702139b0a9785d5888be2eb8a92bd8372b7bd	9	9069	69	857	879	48	4	2023-06-27 15:05:51.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
882	\\x258390d022aa35015b6110e4fb61ebc85d320bcda2c277bc64e44937e9c0c410	9	9079	79	858	880	48	4	2023-06-27 15:05:53.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
883	\\x4eca999f497388bde8e818af2f21600e9d9d73d384122c3f2444410bc6375225	9	9081	81	859	882	12	4	2023-06-27 15:05:54.2	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
884	\\x2c09e6a6ebfbe512a0df418d36227cc2ceb5a1b42898361aa379e98dcf7971c4	9	9083	83	860	883	10	4	2023-06-27 15:05:54.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
885	\\xe483f377c997eaef35704c5270f89a9747b6a3e3e0a864cbd0166f7db82910da	9	9089	89	861	884	3	4	2023-06-27 15:05:55.8	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
886	\\x374ec16dfe62fce070b440bd076a1791844ad34c440fd990c506880643b69f06	9	9095	95	862	885	10	4	2023-06-27 15:05:57	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
887	\\xd162cf92ae87e4aeacb4fed5c063b053fb8a6cefe5d63ab128547791362fdc92	9	9096	96	863	886	17	4	2023-06-27 15:05:57.2	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
888	\\xa3d9add1d77ac5c4a9b63248f605616692ac095a08185442eb969f9809e23f57	9	9111	111	864	887	18	4	2023-06-27 15:06:00.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
889	\\x684ffc54165000066591c34f05a4b259abeff48046e6a4e053fab4db54c7a645	9	9135	135	865	888	17	4	2023-06-27 15:06:05	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
890	\\x82409cf0f48d6d8ece6bd36f4a43a89c6a0a31c46fdbba38d30bee4eda6925aa	9	9144	144	866	889	12	4	2023-06-27 15:06:06.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
891	\\x9c3102bfb31ad46a63bcb6ea569405848be995c51510fec4830b7a3a9a429ae7	9	9146	146	867	890	10	4	2023-06-27 15:06:07.2	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
892	\\x22ff62c59de3e2c9afbfc1e07f241515051f85b900c5256d0e3de8d16b0dd482	9	9148	148	868	891	3	4	2023-06-27 15:06:07.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
893	\\x7b7a3969039ca372ed5a2c3cac451766c0c25a584d703a19aeebd79441a8a335	9	9151	151	869	892	19	4	2023-06-27 15:06:08.2	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
894	\\x8e2b41e0ff1a809697c5deee19d2332239643be5e4c450aa9afcbe1a3056d0f0	9	9158	158	870	893	3	4	2023-06-27 15:06:09.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
895	\\xad4214cd0ccf9954f9239379ac13d2ab3bbb6de5c0fb622cc589b6d42de923c0	9	9160	160	871	894	18	4	2023-06-27 15:06:10	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
896	\\x750c35ed35e7a53794684f1b9b55a3fe144d369a90f11696b6980fc276a5b900	9	9165	165	872	895	48	4	2023-06-27 15:06:11	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
898	\\xc89ff693fe545d25f8d571b85809ec7afc56b4490fb04d83b9aba626030e6d9e	9	9170	170	873	896	6	4	2023-06-27 15:06:12	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
899	\\xd8aceb3958feeddd3e80c32d2d4d32f16078235c4bdb561c8e99e26d0e84bfd9	9	9175	175	874	898	48	4	2023-06-27 15:06:13	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
900	\\x4748ddc30c3c9d0863a0db6c80589944982e9ce42e88c3c447c832ef9e899e24	9	9194	194	875	899	12	4	2023-06-27 15:06:16.8	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
901	\\x050639d49db325e43f07ec005b64b41f76e458998b145fd8d4600e24c0894a69	9	9200	200	876	900	10	4	2023-06-27 15:06:18	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
902	\\x981ab00b1dee4cc503c8d4b2f225e9fe1bb52e4db8bd12b7a53201987ff871ee	9	9203	203	877	901	6	4	2023-06-27 15:06:18.6	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
903	\\x384baf15e595d2022c9edcebd5c3dbdeb30ed7a87fae3c2bd75c09b0c7a077e4	9	9204	204	878	902	7	4	2023-06-27 15:06:18.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
904	\\x9556d49674f6fe7d8adeaeb674642e01d1329ee73f1e330940c20a9c52a42849	9	9210	210	879	903	12	4	2023-06-27 15:06:20	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
905	\\x0e76f00dff01d5988a15525aae4133126dd33aff0075d19d000eb70e1442a715	9	9217	217	880	904	19	4	2023-06-27 15:06:21.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
906	\\x18427d456e3e64828ab8164a45eb67bb36f9ee7f69945097f8fbd5ee2e4c0682	9	9226	226	881	905	7	4	2023-06-27 15:06:23.2	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
907	\\x7975d60b7cfa981cad52f8ce7c18a85fc01678b17baba187c6a8393a9268c88b	9	9229	229	882	906	6	4	2023-06-27 15:06:23.8	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
908	\\xc7fd1d093bcf926ad9ea723a7b5b1804669d1fd77b124c9c11b980489064ba26	9	9270	270	883	907	10	4	2023-06-27 15:06:32	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
909	\\x20df16783ea8a4ed231691a893eddd1ee440747b6bfac078e5b2c57ad722a741	9	9272	272	884	908	48	4	2023-06-27 15:06:32.4	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
910	\\xffee81fa5017c63d990a3fd94b96aecea663421c8655af70416610ee1e15222e	9	9296	296	885	909	48	4	2023-06-27 15:06:37.2	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
911	\\xac93bdf36cc2abe6fbc9e1bc742d4df10f1fc2ccefef7bc8eb5d5bd155a93b2a	9	9316	316	886	910	3	4	2023-06-27 15:06:41.2	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
912	\\xab6aa98198a0ac0988e732b0ed59bf5e4e201b9ff99ee6663171fb620f8434d7	9	9327	327	887	911	17	4	2023-06-27 15:06:43.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
913	\\x712488d4fe3c3bb4f3df6ab880d3c7b4be61a0575f30c6d4498182daca19b319	9	9328	328	888	912	6	4	2023-06-27 15:06:43.6	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
914	\\xa2c76b533e479d55cc40fbabd2a4d0b8ed7e099ef344296bb2f2403df7733e0d	9	9340	340	889	913	3	4	2023-06-27 15:06:46	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
915	\\xe87db0581cc674252d8ca60e3c722a1a2c57dc97fe16eab9935ab9841cb677cd	9	9350	350	890	914	48	4	2023-06-27 15:06:48	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
917	\\xaa02c98a74f715193d956625bd441510b12dc9733db0d25bda6f8c2930185dad	9	9365	365	891	915	7	4	2023-06-27 15:06:51	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
918	\\x30314163f4e2284100468fa0106b70efa2160b3568026187ac43e5f2de811094	9	9372	372	892	917	19	4	2023-06-27 15:06:52.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
919	\\xa6f34968cacf08e16f4c84839794e41bf723d1e8ef20630a93c3bea0050d0ac1	9	9393	393	893	918	17	4	2023-06-27 15:06:56.6	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
920	\\xf649e565a796d9c179873dd20339b5252dc9d9c286fafce3ac347bd3cd8a5456	9	9402	402	894	919	17	4	2023-06-27 15:06:58.4	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
921	\\x1f9547de8e97d71fc304948b23fd99a664db0b1848dabe31a02ea1c2508025c5	9	9418	418	895	920	10	4	2023-06-27 15:07:01.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
922	\\x824ff73d90e3e577d055c0d8be5cc6aa737cd2a1f96f3a696933ef85056fdcbe	9	9419	419	896	921	7	4	2023-06-27 15:07:01.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
923	\\xb1e406c15b6b585ed5dfe0c05e25fefe3003ec559a709fa4072402e5f71a8a41	9	9428	428	897	922	19	4	2023-06-27 15:07:03.6	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
924	\\x4f0800329d50c77c66e5a429149929969abf7cdc3970e67305e19029e6189d02	9	9454	454	898	923	10	4	2023-06-27 15:07:08.8	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
925	\\x0e5978053665ed6007753ee7a221a68642e1ba141d43372f0253ffded6977bae	9	9460	460	899	924	10	4	2023-06-27 15:07:10	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
926	\\x979eba74865429b53c089fb99f4ab911ddf4b1a7a375de9044301d9bd25f9894	9	9470	470	900	925	18	4	2023-06-27 15:07:12	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
927	\\xbe9f66631a295506af82bca325fdeb46eb200527bfdfc9857ab8ebe5494a2b1b	9	9488	488	901	926	10	4	2023-06-27 15:07:15.6	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
928	\\x88beac7b0bd3e20bb037f04093660d5be1e81cd8b38ab1d44f77620a3237a578	9	9502	502	902	927	19	4	2023-06-27 15:07:18.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
929	\\x28daabcad1bf57ac0bdcf3f1da2d1152db6ef1540bb0970d50e387f127bbf1de	9	9506	506	903	928	19	4	2023-06-27 15:07:19.2	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
930	\\xb538532f89ecb388f1b77c8634ccb33358090122b1d3c86aab797c448ea15468	9	9511	511	904	929	19	4	2023-06-27 15:07:20.2	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
931	\\xf6806e9d6222df9128db51468e04a2ec1d936f642710b38f5667d2dc6508d0ca	9	9522	522	905	930	48	4	2023-06-27 15:07:22.4	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
932	\\x6ad29d37c0deecfcec3b20252f4114fc4364a02edc5bceb898ab93e02f60a607	9	9527	527	906	931	10	4	2023-06-27 15:07:23.4	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
933	\\xcea846c0dc9c54a5c9409a3421ad390e907419578730252d95077249cc34539a	9	9528	528	907	932	3	4	2023-06-27 15:07:23.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
934	\\xe2e4e8e5a7bae69ff6d57f190bffe1468f4ca67db646943db7d691d29ae6886f	9	9530	530	908	933	6	4	2023-06-27 15:07:24	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
935	\\xfab4fb5f9d3ab5b80ac63be57bb942566e357b9d835b7879e7f9dab945bbf233	9	9535	535	909	934	19	4	2023-06-27 15:07:25	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
936	\\xb1693018042643b1b862a0c0d9c9728a29887a5358c7ddd12a125fb64e71132c	9	9551	551	910	935	18	4	2023-06-27 15:07:28.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
937	\\x89c30ffc68e3f3a58ab972a81f918eb53c0e82b14570b47fe75b2898690b361b	9	9557	557	911	936	48	4	2023-06-27 15:07:29.4	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
938	\\x1c52c0430d6e91842f4776dac95a7cbe32364c3e40b08988c4786ff6dfe4b65a	9	9562	562	912	937	7	4	2023-06-27 15:07:30.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
939	\\xc4f452bbc3eb6208402dfc6c29835247ad487b208ddb217d441742651e3bda9a	9	9590	590	913	938	7	4	2023-06-27 15:07:36	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
940	\\x2d8ad4be19dea245e87616f7284fda0af1d9c4fa173e81abae159ca3a12dea60	9	9591	591	914	939	48	4	2023-06-27 15:07:36.2	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
941	\\xfd9f6ad5f1a00e42e9a84759621fc36be7abb28189edabc32aec5f23c604dba4	9	9601	601	915	940	18	4	2023-06-27 15:07:38.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
942	\\x85bb2a9df75091b0857ea33da567561d0f7904a3b7baedfac506f29b496e7e6d	9	9609	609	916	941	18	4	2023-06-27 15:07:39.8	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
943	\\xafab1ab27a4d1faa648b46f80f36e78e1c4bc0dfaf5a0c2215d2b604b3c99a01	9	9610	610	917	942	19	4	2023-06-27 15:07:40	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
944	\\xcf4ebcfb8dae48264d88409521da51e7cb72aea5961326496492e44f1a8f7723	9	9611	611	918	943	3	4	2023-06-27 15:07:40.2	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
945	\\x7a7847a4e457629dc7e133caa5b4331f8aaee249fb20e5f1dcfdfa56dae4e350	9	9615	615	919	944	12	4	2023-06-27 15:07:41	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
946	\\x5b7bdc5018271fd1217bf573bc7d53494fb4856b522ab3bd84fa157386caaf6e	9	9621	621	920	945	3	4	2023-06-27 15:07:42.2	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
947	\\x404f9d164f718d89874b23f926079f1e325de5197add635132e2231b2d954c83	9	9629	629	921	946	7	4	2023-06-27 15:07:43.8	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
948	\\x32c2064f34c642b8fa1e06d9844f5fef16b8b0c65e11254c9fed502ab4a84e9b	9	9630	630	922	947	17	4	2023-06-27 15:07:44	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
949	\\x226b3740e4ef49dd2f4bc40fc6eae86eda381354606e6622843d5c80209c32c5	9	9641	641	923	948	18	4	2023-06-27 15:07:46.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
950	\\x35b95f88021f23ca0eb47bc56bff5102343cc0ffb7058651833901423610a19d	9	9642	642	924	949	19	4	2023-06-27 15:07:46.4	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
951	\\xd11870565a73b922a4e903226cf153b0552fa9dfc4e009eb62643ff4dabdd243	9	9650	650	925	950	12	4	2023-06-27 15:07:48	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
952	\\xa9304f4815c6425d6860823cbeb86b0d38c601a6e4a8741551655cda21e8a7ec	9	9663	663	926	951	3	4	2023-06-27 15:07:50.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
953	\\x84ac9a11f29cbb2ff1c4ef644914f08b0c73adfb8b7fffc3a9899295fbf8bc86	9	9669	669	927	952	17	4	2023-06-27 15:07:51.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
954	\\x1bab72c0dc09cf5d160005592b053ff20c850c186a4d4240c9469244553306b2	9	9679	679	928	953	48	4	2023-06-27 15:07:53.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
955	\\x1cd9be7f8b9cc86fcfd1f5a2c7f3a6302228e7af929917d4781c081ccb927180	9	9691	691	929	954	10	437	2023-06-27 15:07:56.2	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
956	\\xa09a689e411364ec01b33bcd65f6fd071447c44680088935394c30ac17952719	9	9694	694	930	955	19	4	2023-06-27 15:07:56.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
957	\\x2c2c41ae79b6cde966490886860d9fbe0beb69fc51ef6b5ba9023fcfd68af1d3	9	9698	698	931	956	7	4	2023-06-27 15:07:57.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
958	\\xf0b1708a07c486ee973b7eb70609425c734a89a45d5f69286e3758e33dfd57c3	9	9706	706	932	957	10	4	2023-06-27 15:07:59.2	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
959	\\x7cf1cf618ecfbc7a1984c785a79c66c07ea3e84c94bf5beb12b2ca2e1fb58259	9	9729	729	933	958	48	4	2023-06-27 15:08:03.8	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
960	\\x7e992ab74019ea387c123b4a7f7e4d6740506b05b5c64ee5dd1ff6573c8bbda8	9	9734	734	934	959	18	4	2023-06-27 15:08:04.8	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
961	\\x3e98e8ff1a660d4fa662c324a654cc36f7b9d5ab46afdc5b958c642072f395b6	9	9743	743	935	960	3	4	2023-06-27 15:08:06.6	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
962	\\x02844084461e7edd5c0c34f2939e2e3cc797fe570297a690efdce496ee1cfff0	9	9745	745	936	961	18	4	2023-06-27 15:08:07	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
963	\\x4b94dfb1488770249659a879db0778f7bec36958ed053a5e82def21b456b9c65	9	9751	751	937	962	3	554	2023-06-27 15:08:08.2	1	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
964	\\x833ed95ebfc6063b2fc9cface3e347644d234fa947dd9ad8df6c05e8349d409c	9	9753	753	938	963	7	4	2023-06-27 15:08:08.6	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
965	\\xf882cc79989e1403d4d45d38a12b85a7d45e6e211e418d12fd8069818e306386	9	9761	761	939	964	19	4	2023-06-27 15:08:10.2	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
966	\\x6f394ddaf2dcf81bc58bd8ffeda07825de4a7cb3670856f24b3362921cfe0182	9	9764	764	940	965	19	4	2023-06-27 15:08:10.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
967	\\x47bd23e98a8a33790806796503ff9cefc5d1f99cd848da691d32048b6551b89c	9	9772	772	941	966	10	365	2023-06-27 15:08:12.4	1	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
968	\\x7c40dac3be20017ac8a0cddcdd4755ed89e2b38b23725718b79ecce9d4a07a37	9	9788	788	942	967	6	4	2023-06-27 15:08:15.6	0	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
969	\\xa47c5d7b5d6770e968995c908807c2b1d70482cc15269b703ead76b093451343	9	9789	789	943	968	19	4	2023-06-27 15:08:15.8	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
970	\\xc2f5168889c8f692e2d5a47978d988b1f8a9ede73108f2fa5f33bfea82bd697c	9	9822	822	944	969	3	4	2023-06-27 15:08:22.4	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
971	\\x20a1ce6f002119be6fbd42f69f63feb5295cf2ed6607edb4e6eb258abb0ff4e5	9	9839	839	945	970	3	460	2023-06-27 15:08:25.8	1	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
972	\\xdb4bad8c45cb62de968ab0f14e6ea20347c5591501db97818a70aed25aebe504	9	9847	847	946	971	7	4	2023-06-27 15:08:27.4	0	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
974	\\x306a1ad13fa099c3a0f6a60266aba412f4d567a6848d99360523dfaf669b3fbf	9	9859	859	947	972	10	4	2023-06-27 15:08:29.8	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
975	\\xcd526a72ddc793c82d0726cb898895dd9178d40a0ec0879d1d971248e3e45dae	9	9863	863	948	974	18	4	2023-06-27 15:08:30.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
976	\\x346d9518fab972e8acf0e62b00e62ecd6acfc2914d1384411dc2332e7803fb32	9	9878	878	949	975	17	550	2023-06-27 15:08:33.6	1	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
977	\\xda57917e3ac490b2af14061fc1d03325dfe705180ed59fed3cabd67763b5dd0c	9	9889	889	950	976	17	4	2023-06-27 15:08:35.8	0	8	0	vrf_vk1n3zznjmhe7vukp6hjn8vuc4vq37ekuwyk4hjw6jc4c3yl8tudtgqgjpcqh	\\x79462591f9373352dbd5625f8db7e6c496b4816c52a68462008e49c32d722b71	0
978	\\x43352e9d7bea3c2ddb95e636740efdbcb1245e4332d8c0378e00c71a94b78ca2	9	9890	890	951	977	10	4	2023-06-27 15:08:36	0	8	0	vrf_vk17vjj8khryahck8azu2gmavqx5a422juq2puqc6j5g29lgjamxsnsvre568	\\xb6b0f00cab54a78874a8962a258754a2bd0c8ca04a06f2ea031f9f350a151384	0
979	\\xe4e368cf2364d17d5fc4804b8cf79778de133bee417a1694e046b9b1a88b70a1	9	9893	893	952	978	19	4	2023-06-27 15:08:36.6	0	8	0	vrf_vk1lpfq4a27tkg4zz7ad5l4xn8tz2jy4tnk3yul04qacaadnwr2jfhqq6mmyh	\\xd48091c74346bf47e00c214332cbc9ce56b0760f06866f230a0e3232f3fd6fc2	0
980	\\x6dba94e8f9df29633aed207935d2c2a6d07958dfaeda48566ca59085790a4943	9	9910	910	953	979	6	365	2023-06-27 15:08:40	1	8	0	vrf_vk1csx4jqzfztx8gzg0t2wgc3guj3u2del22wd7947ujxt6kj8ygugqvc2e4y	\\xe8c285a3334a88d165ce0544831ceb263fe2b4f42563428229e9ce3582e06271	0
981	\\x77b410088a57994a465eb35fa27681b8330d3f30cf9c001cc60d4428778d5e8e	9	9913	913	954	980	12	4	2023-06-27 15:08:40.6	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
983	\\xda1f76fb78afbc48f643c7913ef6c32d1b4b740481a1597c79d9805274c72fd9	9	9920	920	955	981	12	4	2023-06-27 15:08:42	0	8	0	vrf_vk1p3u7c2nqwuu9l242wtkfuk4s2p4p0mpvja4n4h620xsstfuknmhscwyqz8	\\x4afe836375cd8cd5fcd9144e9ff76e396a516bab65c4bb0b99e1a362b8eef81c	0
984	\\x6fb3a44e656463fc421edb8c4647f137f669ca26811f4da1fd30db68ffce5dbc	9	9923	923	956	983	18	4	2023-06-27 15:08:42.6	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
985	\\x3d4c3de7d1bbde77be975ce66aadb916eae944c2324c2e57548cfd047cd7ddae	9	9939	939	957	984	7	460	2023-06-27 15:08:45.8	1	8	0	vrf_vk143sm2hsjv48yxq2982aundfhz7cdm9ax8sdlta40fzccvsf5q6wswwge9y	\\x44c85c4d48dbabbaeb1446e71daaac03590ddc1d4cea88833b82d7bb639aad1d	0
986	\\x3149a5fa262d7bbad083418f0b6480261c5b7580114e00ce4f72361bc417f132	9	9947	947	958	985	3	4	2023-06-27 15:08:47.4	0	8	0	vrf_vk10a3xhxmztzea9cjhhl9c7snrqvj4dlvvkjpelj7uwjv5r7gun6aq0ypvzy	\\x26deb9c7d913ada0d61243a988a7b1161d087650aaff22a1c95022cbdd50c2de	0
987	\\x807752a22b4635d811bcb97d2172bb5e878fdaad247f9abcd5f8268f736656ba	9	9950	950	959	986	48	4	2023-06-27 15:08:48	0	8	0	vrf_vk1mu6v2jahtlftrcer8knu5ruvmf909lrkm2hnv4srav35sf8s30rs3lrsee	\\x25f80c5fb8376a3e9e7a7b9d9cf668a36e59f18894a879eb4151266b0d2f4f8a	0
988	\\xaceb3509f8ab25520dabbc0ac4d57ad98883db58ee41467f0fdc1b0fa3a23563	9	9961	961	960	987	18	4	2023-06-27 15:08:50.2	0	8	0	vrf_vk1w000gr6ke68fr5k0ldjz6cnvxjh6nzfg0gqglzw27dxuna86x5aszs9kfs	\\xf3cf4ddf372cacfe6402f4841b0b7efec5268bede384e3191eb7e7193bfa3231	0
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
1	99	1	addr_test1vzfe02k4gmqlatrjsug0thufhu8v83dujptf0lghufh7gyq3yhpww	\\x609397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	f	\\x9397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	\N	3681818081394197	\N	fromList []	\N	\N
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
\.


--
-- Data for Name: delegation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delegation (id, addr_id, cert_index, pool_hash_id, active_epoch_no, tx_id, slot_no, redeemer_id) FROM stdin;
1	5	1	6	2	34	0	\N
2	2	3	5	2	34	0	\N
3	11	5	7	2	34	0	\N
4	3	7	8	2	34	0	\N
5	1	9	10	2	34	0	\N
6	8	11	2	2	34	0	\N
7	10	13	9	2	34	0	\N
8	6	15	11	2	34	0	\N
9	4	17	1	2	34	0	\N
10	9	19	4	2	34	0	\N
11	7	21	3	2	34	0	\N
12	22	0	11	2	37	78	\N
13	6	0	11	2	38	95	\N
14	20	0	9	2	42	163	\N
15	10	0	9	2	43	179	\N
16	21	0	10	2	47	231	\N
17	1	0	10	2	48	256	\N
18	15	0	4	2	52	308	\N
19	9	0	4	2	53	319	\N
20	14	0	3	2	57	403	\N
21	7	0	3	2	58	417	\N
22	17	0	6	2	62	540	\N
23	5	0	6	2	63	562	\N
24	12	0	1	2	67	611	\N
25	4	0	1	2	68	629	\N
26	19	0	8	2	72	687	\N
27	3	0	8	2	73	714	\N
28	3	0	8	2	75	732	\N
29	16	0	5	2	79	797	\N
30	2	0	5	2	80	820	\N
31	2	0	5	2	82	862	\N
32	13	0	2	2	86	935	\N
33	8	0	2	2	87	991	\N
34	8	0	2	3	89	1025	\N
35	18	0	7	3	93	1112	\N
36	11	0	7	3	94	1124	\N
37	11	0	7	3	96	1178	\N
38	52	1	1	6	131	4939	\N
39	53	3	4	6	131	4939	\N
40	54	5	3	6	131	4939	\N
41	55	7	11	6	131	4939	\N
42	56	9	10	6	131	4939	\N
43	52	0	1	7	134	5038	\N
44	53	1	1	7	134	5038	\N
45	54	2	1	7	134	5038	\N
46	55	3	1	7	134	5038	\N
47	56	4	1	7	134	5038	\N
48	46	1	4	7	149	5478	\N
49	46	1	1	7	152	5541	\N
50	48	0	12	11	256	9839	\N
51	50	0	13	11	259	9939	\N
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
1	195136285437829459	9515549	53	88	0	2023-06-27 14:35:43.6	2023-06-27 14:38:57.6
2	77318150761514753	4165209	22	80	1	2023-06-27 14:38:59.4	2023-06-27 14:42:15.4
4	0	0	0	89	3	2023-06-27 14:45:42.4	2023-06-27 14:48:55.2
10	30095017134573	1228995	7	112	9	2023-06-27 15:05:38.2	2023-06-27 15:08:48
7	0	0	0	106	6	2023-06-27 14:55:43.2	2023-06-27 14:58:57.2
9	0	0	0	91	8	2023-06-27 15:02:20.6	2023-06-27 15:05:35.8
6	39339940753613	8842870	19	105	5	2023-06-27 14:52:19.4	2023-06-27 14:55:32.6
5	55000979184442	3717988	20	95	4	2023-06-27 14:48:58.8	2023-06-27 14:52:11.8
3	0	0	0	91	2	2023-06-27 14:42:23.4	2023-06-27 14:45:33.8
8	6244965923843	16894840	100	96	7	2023-06-27 14:59:02.6	2023-06-27 15:02:13.4
\.


--
-- Data for Name: epoch_param; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_param (id, epoch_no, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, nonce, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, block_id, extra_entropy, coins_per_utxo_size) FROM stdin;
1	1	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xa5de7c8e554436822e412b01b40823bb55e74d72991101bec54494a7d4612c00	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	91	\N	4310
2	2	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x68f31b324c9b3c9657d46c6e6522b93fce301ef31ff41b25b6300ca4d1d4abfc	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	171	\N	4310
3	3	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x4a80851a755b5940d89ab90bac3009f68b443ae2fdad319c32fb34b302a5a989	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	263	\N	4310
4	4	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x05362005cf525241fdcfff85f68173190157338bb1d3f6af478c0cb44b5a83b7	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	354	\N	4310
5	5	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x0e84d277e3b25ea89c7d45a5236f41ca11995bf51347e74163a3156d57d4e05a	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	454	\N	4310
6	6	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xb0be8f04a052d7c984fd8bad03b645c005de3975902b8e5e1e25ede3ad7ef881	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	565	\N	4310
7	7	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xbbcc1eb38dc1d7daf2f2258550abe0e250aa085f4868ae3cb8e1ba5d453c6e38	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	678	\N	4310
8	8	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x38f889f20f764dac611d39f33d51f9b6292bcc905377d0f5b6e1b22213efa868	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	776	\N	4310
9	9	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x246e617d30e3502fb8065fcc66a7aad7b5b6c3225af0d1c61450743027039a40	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	871	\N	4310
\.


--
-- Data for Name: epoch_stake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_stake (id, addr_id, pool_id, amount, epoch_no) FROM stdin;
1	5	6	3681818181818181	1
2	2	5	3681818181818181	1
3	11	7	3681818181818190	1
4	3	8	3681818181818181	1
5	1	10	3681818181818181	1
6	8	2	3681818181818181	1
7	10	9	3681818181818181	1
8	6	11	3681818181818181	1
9	4	1	3681818181818181	1
10	9	4	3681818181818181	1
11	7	3	3681818181818181	1
12	14	3	500000000	2
13	20	9	600000000	2
14	5	6	3681818181443619	2
15	13	2	500000000	2
16	17	6	500000000	2
17	22	11	500000000	2
18	2	5	3681818181265842	2
19	21	10	200000000	2
20	11	7	3681818181818190	2
21	3	8	3681818181265842	2
22	1	10	3681818181443619	2
23	8	2	3681818181637632	2
24	10	9	3681818181446391	2
25	6	11	3681818181443619	2
26	12	1	500000000	2
27	15	4	500000000	2
28	4	1	3681818181443619	2
29	9	4	3681818181443619	2
30	7	3	3681818181443619	2
31	16	5	300000000	2
32	19	8	300000000	2
33	14	3	500000000	3
34	20	9	600000000	3
35	5	6	3681818181443619	3
36	18	7	500000000	3
37	13	2	500000000	3
38	17	6	500000000	3
39	22	11	500000000	3
40	2	5	3681818181265842	3
41	21	10	200000000	3
42	11	7	3681818181263035	3
43	3	8	3681818181265842	3
44	1	10	3681818181443619	3
45	8	2	3681818181263026	3
46	10	9	3681818181446391	3
47	6	11	3681818181443619	3
48	12	1	500000000	3
49	15	4	500000000	3
50	4	1	3681818181443619	3
51	9	4	3681818181443619	3
52	7	3	3681818181443619	3
53	16	5	300000000	3
54	19	8	300000000	3
55	14	3	500000000	4
56	20	9	600000000	4
57	5	6	3688000289002880	4
58	18	7	500000000	4
59	13	2	500000000	4
60	17	6	500000000	4
61	22	11	500000000	4
62	2	5	3686233972379600	4
63	21	10	200000000	4
64	11	7	3688000288822296	4
65	3	8	3688883447047854	4
66	1	10	3692416080116638	4
67	8	2	3688883447045038	4
68	10	9	3688883447228403	4
69	6	11	3690649763671135	4
70	12	1	500000000	4
71	15	4	500000000	4
72	4	1	3687117130780128	4
73	9	4	3687117130780128	4
74	7	3	3684467656111873	4
75	16	5	300000000	4
76	19	8	300000000	4
77	14	3	501062231	5
78	20	9	601416308	5
79	5	6	3697560369175128	5
80	18	7	500000000	5
81	13	2	500944205	5
82	17	6	501298282	5
83	22	11	500826179	5
84	2	5	3691448562131237	5
85	21	10	200519313	5
86	11	7	3695822174723257	5
87	3	8	3691490741923672	5
88	1	10	3701976161846825	5
89	8	2	3695836232624488	5
90	10	9	3697574428731064	5
91	6	11	3696733451053475	5
92	12	1	500944205	5
93	15	4	501180256	5
94	4	1	3694069916359944	5
95	9	4	3695808112754899	5
96	7	3	3692289539889166	5
97	16	5	300424892	5
98	19	8	300212446	5
99	14	3	768701339759	6
100	20	9	640823645337	6
101	55	11	0	6
102	5	6	3705537325364393	6
103	18	7	501158648	6
104	13	2	502218718	6
105	54	3	0	6
106	17	6	1408600723788	6
107	22	11	896679233303	6
108	2	5	3691448562131237	6
109	21	10	200519313	6
110	11	7	3704354042305728	6
111	52	1	0	6
112	3	8	3691490741923672	6
113	1	10	3701976161846825	6
114	53	4	0	6
115	8	2	3705221286965206	6
116	10	9	3701200140756517	6
117	6	11	3701809580764841	6
118	56	10	999607970	6
119	12	1	768701221733	6
120	15	4	1536553235361	6
121	4	1	3698420837326836	6
122	9	4	3704510303188635	6
123	7	3	3696640460856058	6
124	16	5	300424892	6
125	19	8	300212446	6
126	14	3	1903876919261	7
127	20	9	1396812313895	7
128	55	1	0	7
129	5	6	3710533910038821	7
130	18	7	1134589701941	7
131	54	1	0	7
132	17	6	2290751757406	7
133	22	11	1904071294799	7
134	2	5	3691448562131237	7
135	21	10	200519313	7
136	11	7	3710778328244579	7
137	52	1	999406213	7
138	1	10	3701976161846825	7
139	53	1	0	7
140	10	9	3705481861902178	7
141	6	11	3707515920626115	7
142	56	1	0	7
143	12	1	1777058150193	7
144	15	4	2418889985261	7
145	4	1	3704132644757696	7
146	9	4	3709508110253140	7
147	7	3	3703070906655621	7
148	46	1	4998981060418	7
149	16	5	300424892	7
150	14	3	3074166139973	8
151	20	9	2098115212407	8
152	55	1	0	8
153	5	6	3715167782687396	8
154	18	7	1602456969780	8
155	54	1	0	8
156	17	6	3108894728612	8
157	22	11	2839243828242	8
158	2	5	3691448562131237	8
159	21	10	200519313	8
160	11	7	3713427363706452	8
161	52	1	999406213	8
162	1	10	3701976161846825	8
163	53	1	0	8
164	10	9	3709453697353580	8
165	6	11	3712813016864690	8
166	56	1	0	8
167	12	1	3531480429550	8
168	15	4	3704932740794	8
169	4	1	3714072152021567	8
170	9	4	3716793582614718	8
171	7	3	3709700329575353	8
172	46	1	4998981060418	8
173	16	5	300424892	8
174	14	3	4557833141776	9
175	20	9	2782108797303	9
176	55	1	0	9
177	5	6	3719674848223107	9
178	18	7	2512827455877	9
179	54	1	0	9
180	17	6	3906674868853	9
181	22	11	4321076030308	9
182	2	5	3691448562131237	9
183	21	10	200519313	9
184	11	7	3718583915143502	9
185	52	1	999406213	9
186	1	10	3701976161846825	9
187	53	1	0	9
188	10	9	3713322984826738	9
189	6	11	3721194321472769	9
190	56	1	0	9
191	12	1	4558241658322	9
192	15	4	5186856845013	9
193	4	1	3719880207784798	9
194	9	4	3725165904780170	9
195	7	3	3718093929818826	9
196	46	1	4998964165578	9
197	16	5	300424892	9
\.


--
-- Data for Name: epoch_sync_time; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_sync_time (id, no, seconds, state) FROM stdin;
1	0	1	lagging
2	1	1	lagging
3	2	1	following
4	3	182	following
5	4	201	following
6	5	204	following
7	6	200	following
8	7	199	following
9	8	198	following
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
5	2	108	5
6	1	108	6
7	1	108	7
8	1	110	8
9	1	110	9
11	-1	113	9
12	-1	114	8
13	1	115	8
14	1	116	8
15	-2	117	8
16	2	118	8
17	-2	119	8
18	2	120	8
19	-1	121	8
20	-1	122	8
21	1	123	10
22	1	123	11
23	1	123	12
24	-1	124	11
26	1	126	13
27	1	127	14
28	1	128	15
29	-1	129	13
30	-1	129	14
31	-1	129	15
32	-1	129	10
33	-1	129	12
34	1	135	16
35	-1	136	16
36	10	137	17
37	-10	138	17
\.


--
-- Data for Name: ma_tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ma_tx_out (id, quantity, tx_out_id, ident) FROM stdin;
1	13500000000000000	124	1
2	13500000000000000	124	2
3	13500000000000000	124	3
4	13500000000000000	124	4
5	2	126	5
6	1	126	6
7	1	126	7
8	1	134	8
9	1	134	9
10	1	136	8
11	1	137	9
12	1	141	8
13	1	143	8
14	2	146	8
15	2	149	8
16	1	151	8
17	1	153	10
18	1	153	11
19	1	153	12
20	1	156	10
21	1	156	12
25	1	159	13
26	1	160	10
27	1	160	12
28	1	161	14
29	1	163	15
30	1	164	13
31	1	164	14
32	1	176	16
33	10	179	17
\.


--
-- Data for Name: meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meta (id, start_time, network_name, version) FROM stdin;
1	2023-06-27 14:35:38	testnet	Version {versionBranch = [13,1,0,0], versionTags = []}
\.


--
-- Data for Name: multi_asset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.multi_asset (id, policy, name, fingerprint) FROM stdin;
1	\\x2c74874ae85a596ad88adc391c5fd7fdb8d8f85e22ced233ee85539d	\\x	asset1y940taudnpp2ckfmsnfx3hn3kq9lhpqrc2vkp5
2	\\x2c74874ae85a596ad88adc391c5fd7fdb8d8f85e22ced233ee85539d	\\x74425443	asset1xyh8y5z7s0jl36ktzya9jwt82whj2ruxvw3nzx
3	\\x2c74874ae85a596ad88adc391c5fd7fdb8d8f85e22ced233ee85539d	\\x74455448	asset1ya6cak50t5t8dz9j54cka72ynxn4q5vz6ghsvp
4	\\x2c74874ae85a596ad88adc391c5fd7fdb8d8f85e22ced233ee85539d	\\x744d494e	asset1ytc8lsulrgdyzjkqnfyuhnv3xxm8v92c8yy4wx
5	\\x2c74874ae85a596ad88adc391c5fd7fdb8d8f85e22ced233ee85539d	\\x446f75626c6548616e646c65	asset17g39wk4ka0lyy6zj0rehrj5try0t7nz8zpvln2
6	\\x2c74874ae85a596ad88adc391c5fd7fdb8d8f85e22ced233ee85539d	\\x48656c6c6f48616e646c65	asset1rexss7nn3daprqaqs9lg043thczj9uf7mz57yr
7	\\x2c74874ae85a596ad88adc391c5fd7fdb8d8f85e22ced233ee85539d	\\x5465737448616e646c65	asset1ma08ukxrfqlp60lff58ftywaahnyvj6ugsyxkl
8	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x68616e646c6531	asset1jt0xl3me70chjg3fvekefj0ua38hvnl2dkmrqk
9	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x68616e646c6532	asset1tkug66720m2wfkl9pvpv2s65kllhjwvtmqt9l6
10	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d303031	asset1p7xl6rzm50j2p6q2z7kd5wz3ytyjtxts8g8drz
11	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d303032	asset1ftcuk4459tu0kfkf2s6m034q8uudr20w7wcxej
12	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d66696c6573	asset1xac6dlxa7226c65wp8u5d4mrz5hmpaeljvcr29
13	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d76312d686578	asset1v2z720699zh5x5mzk23gv829akydgqz2zy9f6l
14	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d76312d75746638	asset16unjfedceaaven5ypjmxf5m2qd079td0g8hldp
15	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d7632	asset1yc673t4h5w5gfayuedepzfrzmtuj3s9hay9kes
16	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x	asset1qrmynj6uhyk2hn9pc3yh0p80rg598n4yy77ays
17	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	\\x3030303030	asset1ul4zmmx2h8rqz9wswvc230w909pq2q0hne02q0
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
1	\\x1c71599216728f95def230f072a5aefe00eaad2ff68de0158da6237a	pool1r3c4nyskw28ethhjxrc89fdwlcqw4tf076x7q9vd5c3h5qrgu4n
2	\\x3778ee4c11f55b95fc378f24e3cf13e6f06e1583afa9f8912f9de164	pool1xauwunq374detlph3ujw8ncnumcxu9vr475l3yf0nhskgheq6d8
3	\\x5a9272061da51e49de4faae8a5e4c4a56000b98f8aa964d984d8f945	pool1t2f8ypsa550ynhj04t52texy54sqpwv0325kfkvymru52tk7xu3
4	\\x83c19a53381e7cf3aa1580df165d3aa526c170ce1444e0883b21979c	pool1s0qe55ecre7082s4sr03vhf655nvzuxwz3zwpzpmyxtecmuula2
5	\\x8dec2c0d1243787578b4a32b54574a4b40f35d0f168d67e1e73cbc63	pool13hkzcrgjgdu827955v44g462fdq0xhg0z6xk0c088j7xx3yrea6
6	\\x9f8c9666a0a6e322c5ef9f5ae70ba337370edae8cf916ca304b8ce09	pool1n7xfve4q5m3j9300nadwwzarxumsakhge7gkegcyhr8qjwa3vz9
7	\\xb0602cb203714453c4fa6a04274ba25a843f626dcd1bc6c0b7de422b	pool1kpszevsrw9z98386dgzzwjazt2zr7cnde5duds9hmepzkn75834
8	\\xb1698e09a4f3310a46bd59b378fd37d7548a430ed70787acf91b8786	pool1k95cuzdy7vcs534atxeh3lfh6a2g5scw6urc0t8erwrcvx3su8e
9	\\xb878f06eef15f34f67f021f1ffd150898f51f32eacf506d59467f20a	pool1hpu0qmh0zhe57elsy8cll52s3x84ruew4n6sd4v5vleq596rkzc
10	\\xb9c9fa6ec41a769fc1462a785dfe111935944dd506b29446a61c7c2c	pool1h8yl5mkyrfmfls2x9fu9mls3ry6egnw4q6efg34xr37zc243gkf
11	\\xbc705ba7d8ce6a089267a4da52fae0b473663a36f4ee73fc2400297c	pool1h3c9hf7cee4q3yn85nd997hqk3ekvw3k7nh88lpyqq5hcwfpwfv
12	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
13	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_metadata_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata_ref (id, pool_id, url, hash, registered_tx_id) FROM stdin;
1	11	http://file-server/SP1.json	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	39
2	10	http://file-server/SP3.json	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	49
3	4	http://file-server/SP4.json	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	54
4	3	http://file-server/SP5.json	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	59
5	6	http://file-server/SP6.json	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	64
6	1	http://file-server/SP7.json	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	69
7	2	http://file-server/SP10.json	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	88
8	7	http://file-server/SP11.json	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	95
\.


--
-- Data for Name: pool_offline_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_offline_data (id, pool_id, ticker_name, hash, json, bytes, pmr_id) FROM stdin;
1	11	SP1	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	{"name": "stake pool - 1", "ticker": "SP1", "homepage": "https://stakepool1.com", "description": "This is the stake pool 1 description."}	\\x7b0a2020226e616d65223a20227374616b6520706f6f6c202d2031222c0a2020227469636b6572223a2022535031222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2031206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c312e636f6d220a7d0a	1
2	10	SP3	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	{"name": "Stake Pool - 3", "ticker": "SP3", "homepage": "https://stakepool3.com", "description": "This is the stake pool 3 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2033222c0a2020227469636b6572223a2022535033222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2033206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c332e636f6d220a7d0a	2
3	4	SP4	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	{"name": "Same Name", "ticker": "SP4", "homepage": "https://stakepool4.com", "description": "This is the stake pool 4 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535034222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2034206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c342e636f6d220a7d0a	3
4	3	SP5	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	{"name": "Same Name", "ticker": "SP5", "homepage": "https://stakepool5.com", "description": "This is the stake pool 5 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535035222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2035206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c352e636f6d220a7d0a	4
5	6	SP6a7	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	{"name": "Stake Pool - 6", "ticker": "SP6a7", "homepage": "https://stakepool6.com", "description": "This is the stake pool 6 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2036222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2036206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c362e636f6d220a7d0a	5
6	1	SP6a7	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	{"name": "", "ticker": "SP6a7", "homepage": "https://stakepool7.com", "description": "This is the stake pool 7 description."}	\\x7b0a2020226e616d65223a2022222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2037206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c372e636f6d220a7d0a	6
7	2	SP10	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	{"name": "Stake Pool - 10", "ticker": "SP10", "homepage": "https://stakepool10.com", "description": "This is the stake pool 10 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130222c0a2020227469636b6572223a202253503130222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203130206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31302e636f6d220a7d0a	7
8	7	SP11	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	{"name": "Stake Pool - 10 + 1", "ticker": "SP11", "homepage": "https://stakepool11.com", "description": "This is the stake pool 11 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130202b2031222c0a2020227469636b6572223a202253503131222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203131206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31312e636f6d220a7d0a	8
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
1	22	12
2	20	13
3	21	14
4	15	15
5	14	16
6	17	17
7	12	18
8	19	19
9	16	20
10	13	21
11	18	22
12	48	23
13	50	24
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
1	8	0	76	5
2	5	0	83	18
3	2	0	90	5
4	7	0	97	18
\.


--
-- Data for Name: pool_update; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_update (id, hash_id, cert_index, vrf_key_hash, pledge, active_epoch_no, meta_id, margin, fixed_cost, registered_tx_id, reward_addr_id) FROM stdin;
1	1	0	\\x18a2e4509a5f557494a4f90cfb78b1a3b6782bf99befdd418781c6ee12732583	0	2	\N	0	0	34	12
2	2	1	\\x566ba6483d48212887ce4410e1830c30ec61fa3293ea2669650701044778fb03	0	2	\N	0	0	34	13
3	3	2	\\xcb8879dd2b69c1e63682439e1de2fcb471d94203f3a1d1135c6063edb1b0d547	0	2	\N	0	0	34	14
4	4	3	\\x6a27c7df5b532ab414fff352bdc389f52f766ab93ee8adb574ed624414152883	0	2	\N	0	0	34	15
5	5	4	\\xd14a0cea36af30036cde4d3d6bd3b52ba27a8db34c491ca1598bb1d33ff39dda	0	2	\N	0	0	34	16
6	6	5	\\xc4a359fb1cfb07cb99134bcb1bdca2996735aabc02f54adcf5a213d8ed5a351a	0	2	\N	0	0	34	17
7	7	6	\\x6ed265063df92f7668f4b49a5fcdc28d7b75b3c202867ded3f2317706c4df3d5	0	2	\N	0	0	34	18
8	8	7	\\xac1e398f71ef6fc16380916459970dc1181b2c116a02535ed005999290f67a0d	0	2	\N	0	0	34	19
9	9	8	\\xd511eb6d30bdc86ba65825c88c4c8f6cdbe9b78b0c6b1a8b512b9ff7c9b1badc	0	2	\N	0	0	34	20
10	10	9	\\xe2d99d556e2a03d47623b6d1365ef38e804edaeb7cb1e8d980903aca89cd2997	0	2	\N	0	0	34	21
11	11	10	\\x2f5a27172c77fdce0645d1742da753efcf41cae7967aef5377a8f0eb2ebdb69b	0	2	\N	0	0	34	22
12	11	0	\\x2f5a27172c77fdce0645d1742da753efcf41cae7967aef5377a8f0eb2ebdb69b	400000000	3	1	0.149999999999999994	390000000	39	22
13	9	0	\\xd511eb6d30bdc86ba65825c88c4c8f6cdbe9b78b0c6b1a8b512b9ff7c9b1badc	500000000	3	\N	0.149999999999999994	390000000	44	20
14	10	0	\\xe2d99d556e2a03d47623b6d1365ef38e804edaeb7cb1e8d980903aca89cd2997	600000000	3	2	0.149999999999999994	390000000	49	21
15	4	0	\\x6a27c7df5b532ab414fff352bdc389f52f766ab93ee8adb574ed624414152883	420000000	3	3	0.149999999999999994	370000000	54	15
16	3	0	\\xcb8879dd2b69c1e63682439e1de2fcb471d94203f3a1d1135c6063edb1b0d547	410000000	3	4	0.149999999999999994	390000000	59	14
17	6	0	\\xc4a359fb1cfb07cb99134bcb1bdca2996735aabc02f54adcf5a213d8ed5a351a	410000000	3	5	0.149999999999999994	400000000	64	17
18	1	0	\\x18a2e4509a5f557494a4f90cfb78b1a3b6782bf99befdd418781c6ee12732583	410000000	3	6	0.149999999999999994	390000000	69	12
19	8	0	\\xac1e398f71ef6fc16380916459970dc1181b2c116a02535ed005999290f67a0d	500000000	3	\N	0.149999999999999994	380000000	74	19
20	5	0	\\xd14a0cea36af30036cde4d3d6bd3b52ba27a8db34c491ca1598bb1d33ff39dda	500000000	3	\N	0.149999999999999994	390000000	81	16
21	2	0	\\x566ba6483d48212887ce4410e1830c30ec61fa3293ea2669650701044778fb03	400000000	4	7	0.149999999999999994	410000000	88	13
22	7	0	\\x6ed265063df92f7668f4b49a5fcdc28d7b75b3c202867ded3f2317706c4df3d5	400000000	4	8	0.149999999999999994	390000000	95	18
23	12	0	\\x2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	500000000000000	11	\N	0.200000000000000011	1000	254	48
24	13	0	\\x641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	50000000	11	\N	0.200000000000000011	1000	257	50
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
4	6	3:37:
5	7	::
6	8	4:38:
7	9	::
8	10	5:39:
9	11	::
10	12	::
11	13	::
12	14	6:40:
13	15	7:42:
14	16	::
15	17	8:43:
16	18	9:44:
17	19	::
18	20	10:45:
19	21	11:46:
20	22	12:48:
21	23	13:49:
22	24	14:50:
23	25	15:51:
24	26	16:52:
25	27	17:54:
26	28	::
27	29	18:55:
28	30	19:56:
29	31	::
30	32	::
31	33	::
32	34	20:57:
33	35	21:58:
34	36	22:60:
35	37	23:61:
36	38	::
37	39	24:62:
38	40	::
39	41	::
40	42	25:63:
41	43	26:64:
42	44	::
43	45	27:66:
44	46	28:67:
45	47	::
46	48	29:68:
47	49	30:69:
48	50	31:70:
49	51	32:72:
50	52	::
51	53	33:73:
52	54	34:74:
53	55	::
54	56	::
55	57	35:75:
56	58	::
57	59	36:76:
58	60	37:78:
59	61	::
60	62	::
61	63	38:79:
62	64	39:80:
63	65	40:81:
64	66	::
65	67	41:82:
66	68	::
67	69	42:83:
68	70	::
69	71	::
70	72	43:84:
71	73	44:86:
72	74	45:87:
73	75	46:88:
74	76	::
75	77	47:89:
76	78	::
77	79	48:90:
78	80	::
79	81	::
80	82	49:91:
81	83	::
82	84	50:92:
83	85	::
84	86	51:94:
85	87	52:95:
86	88	::
87	89	53:96:
88	90	::
89	91	54:97:
90	92	55:98:
91	93	::
92	94	56:99:
93	95	::
94	96	::
95	97	57:100:
96	98	::
97	99	58:102:
98	100	::
99	101	::
100	102	::
101	103	59:103:
102	104	60:104:
103	105	::
104	106	61:105:
105	107	::
106	108	62:106:
107	109	::
108	110	63:107:
109	111	::
110	112	::
111	113	::
112	114	64:108:
113	115	::
114	116	65:110:
115	117	66:111:
116	118	67:113:
117	119	68:115:
118	120	69:117:
119	121	::
120	122	70:119:
121	123	71:121:
122	124	72:123:
123	125	::
124	126	74:124:1
125	127	::
126	128	::
127	129	75:126:5
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
357	359	::
358	360	::
359	361	::
360	362	::
361	363	::
362	364	::
363	365	::
364	366	::
365	367	::
366	368	77:134:8
367	369	::
368	370	::
369	371	::
370	372	78:136:10
371	373	::
372	374	::
373	375	::
375	377	81:139:
376	378	::
377	379	::
378	380	::
379	381	82:140:
380	382	::
381	383	::
382	384	::
383	385	83:141:12
384	386	::
385	387	::
386	388	::
387	389	84:143:13
388	390	::
389	391	::
390	392	::
391	393	85:145:
392	394	::
393	395	::
394	396	::
395	397	87:146:14
396	398	::
397	399	::
398	400	::
399	401	88:148:
400	402	::
401	403	::
402	404	::
403	405	89:149:15
404	406	::
405	407	::
406	408	::
407	409	90:151:16
408	410	::
409	411	::
410	412	::
411	413	91:152:
412	414	::
413	415	::
414	416	::
415	417	92:153:17
416	418	::
417	419	::
418	420	::
419	421	93:155:20
420	422	::
421	423	::
422	424	::
424	426	96:159:25
425	427	::
426	428	::
427	429	::
428	430	97:161:28
429	431	::
430	432	::
431	433	::
432	434	99:163:29
433	435	::
434	436	::
435	437	::
436	438	103:165:
437	439	::
438	440	::
439	441	::
440	442	::
441	443	::
442	444	106:166:
443	445	::
444	446	::
445	447	::
446	448	107:168:
447	449	::
448	450	::
449	451	::
451	453	113:174:
452	454	::
454	456	::
456	458	::
457	459	118:175:
458	460	::
459	461	::
460	462	::
461	463	119:176:32
462	464	::
463	465	::
464	466	::
465	467	120:178:
466	468	::
467	469	::
468	470	::
469	471	::
470	472	121:179:33
471	473	::
472	474	::
473	475	::
474	476	123:181:
475	477	::
476	478	::
477	479	::
478	480	::
479	481	::
480	482	124:182:
481	483	::
482	484	::
483	485	::
484	486	::
485	487	::
486	488	129:186:
487	489	::
488	490	::
489	491	::
490	492	130:188:
491	493	131::
492	494	132:190:
493	495	::
494	496	::
495	497	133:192:
496	498	134:194:
497	499	::
498	500	138:196:
499	501	140:316:
500	502	200:318:
501	503	201:320:
502	504	::
503	505	::
504	506	::
505	507	::
506	508	202:321:
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
518	520	::
519	521	203:323:
520	522	::
521	523	::
522	524	::
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
674	676	::
675	677	::
676	678	::
677	679	204:324:
678	680	223:360:
679	681	229:372:
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
953	955	340:524:
954	956	::
955	957	::
956	958	::
957	959	::
958	960	::
959	961	::
960	962	::
961	963	341:526:
962	964	::
963	965	::
964	966	::
965	967	342:528:
966	968	::
967	969	::
968	970	::
969	971	344:530:
970	972	::
972	974	::
973	975	::
974	976	345:532:
975	977	::
976	978	::
977	979	::
978	980	346:534:
979	981	::
981	983	::
982	984	::
983	985	348:536:
984	986	::
985	987	::
986	988	::
\.


--
-- Data for Name: reward; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward (id, addr_id, type, amount, earned_epoch, spendable_epoch, pool_id) FROM stdin;
1	5	member	6182107559261	1	3	6
2	2	member	4415791113758	1	3	5
3	11	member	6182107559261	1	3	7
4	3	member	7065265782012	1	3	8
5	1	member	10597898673019	1	3	10
6	8	member	7065265782012	1	3	2
7	10	member	7065265782012	1	3	9
8	6	member	8831582227516	1	3	11
9	4	member	5298949336509	1	3	1
10	9	member	5298949336509	1	3	4
11	7	member	2649474668254	1	3	3
12	14	leader	0	1	3	3
13	20	leader	0	1	3	9
14	18	leader	0	1	3	7
15	13	leader	0	1	3	2
16	17	leader	0	1	3	6
17	22	leader	0	1	3	11
18	21	leader	0	1	3	10
19	12	leader	0	1	3	1
20	15	leader	0	1	3	4
21	16	leader	0	1	3	5
22	19	leader	0	1	3	8
23	14	member	1062231	2	4	3
24	20	member	1416308	2	4	9
25	5	member	9560080172248	2	4	6
26	13	member	944205	2	4	2
27	17	member	1298282	2	4	6
28	22	member	826179	2	4	11
29	2	member	5214589751637	2	4	5
30	21	member	519313	2	4	10
31	11	member	7821885900961	2	4	7
33	3	member	2607294875818	2	4	8
34	1	member	9560081730187	2	4	10
35	8	member	6952785579450	2	4	2
36	10	member	8690981502661	2	4	9
37	6	member	6083687382340	2	4	11
38	12	member	944205	2	4	1
39	15	member	1180256	2	4	4
40	4	member	6952785579816	2	4	1
41	9	member	8690981974771	2	4	4
42	7	member	7821883777293	2	4	3
43	16	member	424892	2	4	5
44	19	member	212446	2	4	8
45	14	leader	0	2	4	3
46	20	leader	0	2	4	9
47	18	leader	0	2	4	7
48	13	leader	0	2	4	2
49	17	leader	0	2	4	6
50	22	leader	0	2	4	11
51	21	leader	0	2	4	10
52	12	leader	0	2	4	1
53	15	leader	0	2	4	4
54	16	leader	0	2	4	5
55	19	leader	0	2	4	8
56	5	member	7976956189265	3	5	6
57	18	member	1158648	3	5	7
58	13	member	1274513	3	5	2
59	11	member	8531867582471	3	5	7
60	8	member	9385054340718	3	5	2
61	10	member	3625712025453	3	5	9
62	6	member	5076129711366	3	5	11
63	4	member	4350920966892	3	5	1
64	9	member	8702190433736	3	5	4
65	7	member	4350920966892	3	5	3
66	14	leader	768200277528	3	5	3
67	20	leader	640222229029	3	5	9
68	18	leader	0	3	5	7
69	13	leader	0	3	5	2
70	17	leader	1408099425506	3	5	6
71	22	leader	896178407124	3	5	11
72	21	leader	0	3	5	10
73	12	leader	768200277528	3	5	1
74	15	leader	1536052055105	3	5	4
75	16	leader	0	3	5	5
76	19	leader	0	3	5	8
77	13	refund	0	5	5	2
78	19	refund	0	5	5	8
79	5	member	4996584674428	4	6	6
80	11	member	6424285938851	4	6	7
81	8	member	9991108215335	4	6	2
82	10	member	4281721145661	4	6	9
83	6	member	5706339861274	4	6	11
84	4	member	5711807430860	4	6	1
85	9	member	4997807064505	4	6	4
86	7	member	6430445799563	4	6	3
87	14	leader	1135175579502	4	6	3
88	20	leader	755988668558	4	6	9
89	18	leader	1134088543293	4	6	7
90	13	leader	1763548337081	4	6	2
91	17	leader	882151033618	4	6	6
92	22	leader	1007392061496	4	6	11
93	21	leader	0	4	6	10
94	12	leader	1008356928460	4	6	1
95	15	leader	882336749900	4	6	4
96	16	leader	0	4	6	5
97	19	leader	0	4	6	8
98	5	member	4633872648575	5	7	6
99	11	member	2649035461873	5	7	7
100	8	member	7285382928423	5	7	2
101	10	member	3971835451402	5	7	9
102	6	member	5297096238575	5	7	11
103	4	member	9939507263871	5	7	1
104	9	member	7285472361578	5	7	4
105	7	member	6629422919732	5	7	3
106	14	leader	1170289220712	5	7	3
107	20	leader	701302898512	5	7	9
108	18	leader	467867267839	5	7	7
109	13	leader	1286066972641	5	7	2
110	17	leader	818142971206	5	7	6
111	22	leader	935172533443	5	7	11
112	21	leader	0	5	7	10
113	12	leader	1754422279357	5	7	1
114	15	leader	1286042755533	5	7	4
115	16	leader	0	5	7	5
116	19	leader	0	5	7	8
117	5	member	4507065535711	6	8	6
118	11	member	5156551437050	6	8	7
119	8	member	6444246392016	6	8	2
120	10	member	3869287473158	6	8	9
121	6	member	8381304608079	6	8	11
122	4	member	5808055763231	6	8	1
123	9	member	8372322165452	6	8	4
124	7	member	8393600243473	6	8	3
125	14	leader	1483667001803	6	8	3
126	20	leader	683993584896	6	8	9
127	18	leader	910370486097	6	8	7
128	13	leader	1137630979151	6	8	2
129	17	leader	797780140241	6	8	6
130	22	leader	1481832202066	6	8	11
131	21	leader	0	6	8	10
132	12	leader	1026761228772	6	8	1
133	15	leader	1481924104219	6	8	4
134	16	leader	0	6	8	5
135	19	leader	0	6	8	8
136	5	member	3876759516865	7	9	6
137	11	member	2216388425651	7	9	7
138	52	member	2389276	7	9	1
139	10	member	6658385580328	7	9	9
140	6	member	5544040758790	7	9	11
141	4	member	8855454922991	7	9	1
142	9	member	7201504407798	7	9	4
143	7	member	5550689737031	7	9	3
144	46	member	11951043789	7	9	1
145	14	leader	983280896778	7	9	3
146	20	leader	1178352083605	7	9	9
147	18	leader	392314630698	7	9	7
148	17	leader	687349765963	7	9	6
149	22	leader	982099847453	7	9	11
150	21	leader	0	7	9	10
151	12	leader	1570224893101	7	9	1
152	15	leader	1276748360462	7	9	4
153	16	leader	0	7	9	5
154	5	member	6541192963859	8	10	6
155	11	member	3820444909125	8	10	7
156	52	member	1316633	8	10	1
157	10	member	6008566615883	8	10	9
158	6	member	4364085185434	8	10	11
159	4	member	4892976660001	8	10	1
160	9	member	5446836805928	8	10	4
161	7	member	2729368846334	8	10	3
162	46	member	6585735723	8	10	1
163	14	leader	484704245779	8	10	3
164	20	leader	1064723547925	8	10	9
165	18	leader	676525734903	8	10	7
166	17	leader	1161167869855	8	10	6
167	22	leader	774448893227	8	10	11
168	21	leader	0	8	10	10
169	12	leader	870492334502	8	10	1
170	15	leader	967964089444	8	10	4
171	16	leader	0	8	10	5
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
5	107	\\x2c74874ae85a596ad88adc391c5fd7fdb8d8f85e22ced233ee85539d	timelock	{"type": "sig", "keyHash": "24a336d3583d58cbb261991697154bbf6fafbc1078adba6dcd5a8293"}	\N	\N
6	110	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}]}	\N	\N
7	137	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}, {"type": "sig", "keyHash": "3178bf14adf78294ac2d03d60b9edfb7323d3d719e98b4b0b3ca34cd"}]}	\N	\N
\.


--
-- Data for Name: slot_leader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slot_leader (id, hash, pool_hash_id, description) FROM stdin;
1	\\xc48e05741e657c78f401cbb3379043aa90874407672f62de57b23504	\N	Genesis slot leader
2	\\x5368656c6c65792047656e6573697320536c6f744c65616465722048	\N	Shelley Genesis slot leader
12	\\x9f8c9666a0a6e322c5ef9f5ae70ba337370edae8cf916ca304b8ce09	6	Pool-9f8c9666a0a6e322
7	\\x5a9272061da51e49de4faae8a5e4c4a56000b98f8aa964d984d8f945	3	Pool-5a9272061da51e49
48	\\xb0602cb203714453c4fa6a04274ba25a843f626dcd1bc6c0b7de422b	7	Pool-b0602cb203714453
18	\\x83c19a53381e7cf3aa1580df165d3aa526c170ce1444e0883b21979c	4	Pool-83c19a53381e7cf3
19	\\xbc705ba7d8ce6a089267a4da52fae0b473663a36f4ee73fc2400297c	11	Pool-bc705ba7d8ce6a08
6	\\x8dec2c0d1243787578b4a32b54574a4b40f35d0f168d67e1e73cbc63	5	Pool-8dec2c0d12437875
3	\\xb878f06eef15f34f67f021f1ffd150898f51f32eacf506d59467f20a	9	Pool-b878f06eef15f34f
4	\\xb1698e09a4f3310a46bd59b378fd37d7548a430ed70787acf91b8786	8	Pool-b1698e09a4f3310a
17	\\xb9c9fa6ec41a769fc1462a785dfe111935944dd506b29446a61c7c2c	10	Pool-b9c9fa6ec41a769f
10	\\x1c71599216728f95def230f072a5aefe00eaad2ff68de0158da6237a	1	Pool-1c71599216728f95
51	\\x3778ee4c11f55b95fc378f24e3cf13e6f06e1583afa9f8912f9de164	2	Pool-3778ee4c11f55b95
\.


--
-- Data for Name: stake_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_address (id, hash_raw, view, script_hash) FROM stdin;
5	\\xe02c2fe99b23bece26d3e772d4cedb55d42cf70c89dc36149e828918bd	stake_test1uqkzl6vmywlvufknuaedfnkm2h2zeacv38wrv9y7s2y330geclc03	\N
2	\\xe0620b343b5167c191d4599a63b0ac465c2ee34685552f39f2e1fa8b5d	stake_test1up3qkdpm29nuryw5txdx8v9vgewzac6xs42j7w0ju8agkhgrhuamd	\N
11	\\xe0671b0bbf48fdc8fad956e01f7e00b85685e249e6e2494d5babbcc3dd	stake_test1upn3kzalfr7u37ke2msp7lsqhptgtcjfum3yjn2m4w7v8hgrw3wz6	\N
3	\\xe0856d15685985b352ad30855834c56842ed86ff98982bb7e4ed76a506	stake_test1uzzk69tgtxzmx54dxzz4sdx9dppwmphlnzvzhdlya4m22pszjkpwn	\N
1	\\xe0860a567e4e72611c531ac5473c3d5a43ce62bd65351c9e42008c8173	stake_test1uzrq54n7feexz8znrtz5w0patfpuuc4av563e8jzqzxgzucuzzlur	\N
8	\\xe09e90342de44eb2bfc2d647c1b675bace1b88cb1b232767185dddb6b2	stake_test1uz0fqdpdu38t907z6erurdn4ht8phzxtrv3jweccthwmdvs3htnvz	\N
10	\\xe0a137a6f51b9af3a4f59de32b57f1c8441be543607baa299967ef641e	stake_test1uzsn0fh4rwd08f84nh3jk4l3epzphe2rvpa652vevlhkg8s9mnxxc	\N
6	\\xe0b9696f9159bdf2292f9a5d9f3530dddc224ea7051ed6dc0fdb161751	stake_test1uzukjmu3tx7ly2f0nfwe7dfsmhwzyn48q50ddhq0mvtpw5g7adsqh	\N
4	\\xe0da27f793e61774afe958b081e22eede8b9def6dd8b02aaf830936453	stake_test1urdz0aunucthftlftzcgrc3wah5tnhhkmk9s92hcxzfkg5cvmd8zl	\N
9	\\xe0df0a69bd2392541162246278cdad49cc0784f467c4fb44d625a82e81	stake_test1ur0s56daywf9gytzy3383nddf8xq0p85vlz0k3xkyk5zaqgp4fp0l	\N
7	\\xe0e009cb881918b488f38882c7e4734bda33c3a4c86a07f6013aa1697a	stake_test1ursqnjugryvtfz8n3zpv0ernf0dr8sayep4q0asp82skj7s8yql5j	\N
22	\\xe05ae79ee917ab13496f7a91855542d6bc1a2480e18f432aade641f20c	stake_test1updw08hfz743xjt002gc242z667p5fyqux85x24dueqlyrqha4hlc	\N
20	\\xe00c57a47cdfde1b23043b1138b4a7b42f952bfffb663a9e6a4d4702d2	stake_test1uqx90fruml0pkgcy8vgn3d98kshe22llldnr48n2f4rs95sstzqvq	\N
21	\\xe064643b3e24364342dc9bc9a8178b223d3989328e5b9c108b9dedcac8	stake_test1upjxgwe7ysmyxskun0y6s9utyg7nnzfj3edecyytnhku4jq2rscmx	\N
15	\\xe0d239fd0e883065a13b58003a2b83fd25e686bb398d64a9471831dff2	stake_test1urfrnlgw3qcxtgfmtqqr52url5j7dp4m8xxkf228rqcalusyfvft9	\N
14	\\xe00461fe727f83809d875e57c88cb7193ab47cd36d3dae5bf4f3d77744	stake_test1uqzxrlnj07pcp8v8tetu3r9hryatglxnd576ukl570thw3qe4wmu9	\N
17	\\xe058e95d9351988e4d8429320b646eed5dd42d09cc11bf09b91a935dbe	stake_test1upvwjhvn2xvgunvy9yeqkerwa4wagtgfesgm7zder2f4m0s8n6trp	\N
12	\\xe0ceb091c4433eb41bed18ac0ffa2543353f062361aa625a4601e81d02	stake_test1ur8tpywygvltgxldrzkql739gv6n7p3rvx4xykjxq85p6qs7naapq	\N
19	\\xe0fd6cfb313a81db8637900a0de5ab032b71b04793986df80ebfc5ff03	stake_test1ur7ke7e382qahp3hjq9qmedtqv4hrvz8jwvxm7qwhlzl7qcma85v2	\N
16	\\xe0fb1405ad66c5ca70f10d2cf726cf2a3d12742d99cebd3ac655d738df	stake_test1ura3gpddvmzu5u83p5k0wfk09g73yapdn88t6wkx2htn3hcu8gcrl	\N
13	\\xe03a218ea3f5f7d0e4030fd0deb33fe3eaaaed8ea13ccd8cb003265600	stake_test1uqazrr4r7hmapeqrplgdavelu0424mvw5y7vmr9sqvn9vqqln9xak	\N
18	\\xe03738644354c4e32d5eb6a86fd231c3fb65c260d9f5309a3382ec8c8d	stake_test1uqmnsezr2nzwxt27k65xl533c0aktsnqm86npx3nstkgergztry3d	\N
45	\\xe040cfe97e479103d375d23f217c431697b2e9a947d8bbfc1cc13a8542	stake_test1upqvl6t7g7gs85m46gljzlzrz6tm96dfglvthlqucyag2ssrsezzl	\N
47	\\xe01bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	stake_test1uqdlrcfc7tuta27fv0y5es5wark5kst5gcql9md02zepalg9yxxuz	\N
49	\\xe09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j	\N
51	\\xe07d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	stake_test1up73dx2qeg7gv59739gpmycmxzffyqk3ha2ctmh9ghdgneqmy000q	\N
52	\\xe072263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	stake_test1upezv0agh8cq09rt33ardnh8pdstd3lwpa5s64g2pne0uqgcygw6k	\N
53	\\xe08de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	stake_test1uzx79ge8d7gkx27vu3k9xgj9zlra0fvat5d5lxcnzm9n7hc8yk6td	\N
54	\\xe04f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	stake_test1up85ec98csnkgus5dw3x8u25mlkgu8m63hvw650ukldv04q6rf54k	\N
55	\\xe00ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	stake_test1uq8lxxfr92332xgqp66eenhpw7z04q09czgjf6uvnku20fq023mfy	\N
56	\\xe0ce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	stake_test1ur89gkdpkj42jwy3smuznfxcjdas0jz64xtckt9s8kz8h3gj4h8zv	\N
62	\\xe0f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	stake_test1urccwtxsk35gm088gm9ecswkmvsjaex3pa2lp0yxs2m7zsglc8qer	\N
46	\\xe0f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	stake_test1urc4mvzl2cp4gedl3yq2px7659krmzuzgnl2dpjjgsydmqqxgamj7	\N
48	\\xe0e0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	\N
50	\\xe0a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	\N
\.


--
-- Data for Name: stake_deregistration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_deregistration (id, addr_id, cert_index, epoch_no, tx_id, redeemer_id) FROM stdin;
1	46	0	5	150	\N
\.


--
-- Data for Name: stake_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_registration (id, addr_id, cert_index, epoch_no, tx_id) FROM stdin;
1	5	0	0	34
2	2	2	0	34
3	11	4	0	34
4	3	6	0	34
5	1	8	0	34
6	8	10	0	34
7	10	12	0	34
8	6	14	0	34
9	4	16	0	34
10	9	18	0	34
11	7	20	0	34
12	22	0	0	36
13	20	0	0	41
14	21	0	0	46
15	15	0	0	51
16	14	0	0	56
17	17	0	0	61
18	12	0	0	66
19	19	0	0	71
20	16	0	0	78
21	13	0	0	85
22	18	0	1	92
23	52	0	4	131
24	53	2	4	131
25	54	4	4	131
26	55	6	4	131
27	56	8	4	131
28	46	0	5	149
29	46	0	5	152
30	48	0	9	255
31	50	0	9	258
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
1	\\x909851d824a81ae51b7bcd9f7a028aa0161ef148b2dddcc481ac2f00f3af666c	1	0	910909092	0	0	0	\N	\N	t	0
2	\\xcbb1d2fbe16c891332f1f3e2aaf5c36d6647743a8b389a4a5da4b495310f2a1d	1	0	910909092	0	0	0	\N	\N	t	0
3	\\xad9531ecfd4a5d4a970c3ad9fb9369f020b28f7e4f3b332b6875629d49c84086	1	0	910909092	0	0	0	\N	\N	t	0
4	\\x0e7d8416cd7a992c6f302a956898736fcef61fce52150617e3a672a62e9acd96	1	0	910909092	0	0	0	\N	\N	t	0
5	\\xc893d7729717e610bce95f9702536e9559433f9a30fcd2a6c9d165b8eb9a613a	1	0	910909092	0	0	0	\N	\N	t	0
6	\\xfbe64af8228f4e9a55385b60df4363aed7c94855b2bcdeae9eb1745ca77fe34a	1	0	910909092	0	0	0	\N	\N	t	0
7	\\xd0522e67998e46c47d858874d7f6cfa75ae4838b6f9a85423db01ff6426b6e8a	1	0	910909092	0	0	0	\N	\N	t	0
8	\\xa3109fb4f62119d4c9337fa8d91eb9d77c3cd0af8e0b705bf03a4060d575a2c5	1	0	910909092	0	0	0	\N	\N	t	0
9	\\x717ac351279ac0ddf1cf0a332e823e9e942b256a0e67bd4c896f3511e56766e3	1	0	910909092	0	0	0	\N	\N	t	0
10	\\x0e1f114a8d969f12ee2d39421f117948ab1907a42a922144d67ebd398e24d912	1	0	910909092	0	0	0	\N	\N	t	0
11	\\x48f58c2a1d3019d14771ff1a8fcbdc2f7a6e1d2dfd7d60228e544f021c9bc492	1	0	910909092	0	0	0	\N	\N	t	0
12	\\x0113142e62ea4c742fb22dea2e476261cb45369ff7f7ceab54415f45c8089557	2	0	3681818181818190	0	0	0	\N	\N	t	0
13	\\x101bd41af4717f8c91d8a19dffbd89b4534404aec9e15e9118c549df0a6790bf	2	0	3681818181818181	0	0	0	\N	\N	t	0
14	\\x1a880c70cbe1cbfc485648cf70db5b0cd679c9fd4c14c0f6fbff70950311527b	2	0	3681818181818181	0	0	0	\N	\N	t	0
15	\\x2996c3c1b498bcd562478a85d9673b04039929a8c47f33ac327fdc64f331d300	2	0	3681818181818181	0	0	0	\N	\N	t	0
16	\\x2c0abdc945eb75906f7b7916b7eeb0f170a2149afa4cf6559ef47494a21d66de	2	0	3681818181818181	0	0	0	\N	\N	t	0
17	\\x44da47d5df4480115a1fe09f9d463e095d772359980bcdfc5fa8b9300be8517a	2	0	3681818181818181	0	0	0	\N	\N	t	0
18	\\x4aff53496fe2deeb63d4ce94ec2d5c33d9d6392298b07d26efc73c8c50322ff5	2	0	3681818181818181	0	0	0	\N	\N	t	0
19	\\x57862d3dca34e488038cf3295dfb4ba80590cbb76333036bc050b99b621fe241	2	0	3681818181818181	0	0	0	\N	\N	t	0
20	\\x64ca82fd648527e9a554ddef52261627b70ecd74ca1cdfcae8c399f2dc6a1041	2	0	3681818181818181	0	0	0	\N	\N	t	0
21	\\x7cfce168bd63727f6bf8436f491f8a48c03078b86b0c40a36149378e1fd3aa15	2	0	3681818181818181	0	0	0	\N	\N	t	0
22	\\x8173cbcdf215dc572e646881891695f92c748fb9150e12453dece7a8164f4458	2	0	3681818181818181	0	0	0	\N	\N	t	0
23	\\x857075609b53844a5e651c043b71d19cc996b8cb8fea01616312289abd29cedb	2	0	3681818181818181	0	0	0	\N	\N	t	0
24	\\x8cf285f4da1998fa59764910dc3f928ff5bce252c854b4f0cebbf9e51c6165fd	2	0	3681818181818181	0	0	0	\N	\N	t	0
25	\\x973980a6fbfb1c488c0237e5566ccc022ec15eb5c63c58da72169140f8861c50	2	0	3681818181818181	0	0	0	\N	\N	t	0
26	\\x9ab3084eef9c446035188b0ebf2a0c368429dbc1b7b460089bb63760bc8ef46a	2	0	3681818181818181	0	0	0	\N	\N	t	0
27	\\xae97dc84b2027badd7a15fa2991141933afea3daee3338aa715261e57932aae9	2	0	3681818181818181	0	0	0	\N	\N	t	0
28	\\xb457ea1b82a83b67aa637e88105ca901db59108efc8ef7ee14b98b089ad27a79	2	0	3681818181818181	0	0	0	\N	\N	t	0
29	\\xb655d7e119f2242199c60b316e94a3244f0b1930f7a73886c2c1b91d13c27f81	2	0	3681818181818181	0	0	0	\N	\N	t	0
30	\\xcd23056ab114bc05d6b0fd290826a14fb732dc50d7adb82fc7beb0e5ada7f85b	2	0	3681818181818181	0	0	0	\N	\N	t	0
31	\\xe60ae5e3b8b5d30c752e1e563e8e2c8d316dbed7ee6a02501477fde6b17eb012	2	0	3681818181818181	0	0	0	\N	\N	t	0
32	\\xe99a1606915c58f7359f53b6c6d5dfab273210b28f73f7b4db7db49d7202dfa6	2	0	3681818181818181	0	0	0	\N	\N	t	0
33	\\xfa4cb72cabb8fa97c9c7ac8a3713abd9d62166a28a9a7dafc1a88efde5f403a5	2	0	3681818181818190	0	0	0	\N	\N	t	0
34	\\x5368656c6c65792047656e65736973205374616b696e67205478204861736820	2	0	0	0	0	0	\N	\N	t	0
35	\\x453dcbfab0c995f9fb26ca7a0ceb7c56a5d92f1cce852db645d529d7f73e3f1b	3	0	3681818181651228	166953	0	263	\N	\N	t	0
36	\\xa598c25d60746fe9ee16114c7351bac8e0abeed4ada184b3988c8322b4feef29	4	0	3681817681473231	177997	0	339	\N	5000000	t	0
37	\\x55f5b5c8aab8afbee7199ed4595abb0ede69af7edf39d9d3c7023e928d8c5a60	6	0	3681817681293914	179317	0	369	\N	5000000	t	0
38	\\x30446026bea3a14ed2a2e2abb658852dcd4989f5f9d3d9ced62955f716eae869	8	0	3681818181637632	180549	0	397	\N	5000000	t	0
39	\\x1ff78fe27474ce23c74a73cb541a30258245c7c3fc7e0e8919aa5a4764e03d8d	10	0	3681818181443619	194013	0	653	\N	500000	t	0
40	\\x5d8a196043d9622af1a8933e40896531b239b78c2c991995d3e0ebee968750d6	14	0	3681817681126961	166953	0	263	\N	\N	t	0
41	\\x5695926dea512745c97c9e3f6a3a15f721d9246f11a79a34f2578e43056fa494	15	0	3681817080948964	177997	0	339	\N	5000000	t	0
42	\\x4abb7d15f1408c5be40ebdb6e5d15a14c92210b31d3c42e6ce6e0a9279c36fdd	17	0	3681817080769647	179317	0	369	\N	5000000	t	0
43	\\xf59e4210afbb51cb762e4a66cb15283a4042e208c9f092ee6100c4f3ccdde95b	18	0	3681818181637632	180549	0	397	\N	5000000	t	0
44	\\x355995087a0f6c7d59c7bda9ca18d3fcf0453bdca6de7a5c9bb98181aaf22381	20	0	3681818181446391	191241	0	590	\N	500000	t	0
45	\\xaed71e98c19791079b0d81b1ad42b053e92eedc8cfe8f5a9b05ca3adf6c281ee	21	0	3681817080602694	166953	0	263	\N	\N	t	0
46	\\x45838485ce93a4ba14e6fffc67a273c3129508c22d1f8e2cccb53f695a4e6c1f	22	0	3681816880424697	177997	0	339	\N	5000000	t	0
47	\\xa41a11961b99be61ccd8a269adaea26261b6e824b294e34a3b34e0134b6b57a2	23	0	3681816880245380	179317	0	369	\N	5000000	t	0
48	\\xa0f54d3fd3d9c3eb7735c9bd2672c1081c1db0615544a5124e0e7e4b3b335ae0	24	0	3681818181637632	180549	0	397	\N	5000000	t	0
49	\\xe70b3dfd7264b8f02ec4d4067be6fbb66267063df75db90a5f7eb3ad5f1ba868	25	0	3681818181443619	194013	0	653	\N	500000	t	0
50	\\x221db2be44c8c563cf4d6443d3ee7f0e2229a86e4fcfa723083d5754bd0894b9	26	0	3681816880078427	166953	0	263	\N	\N	t	0
51	\\xc6fa6e8be1ba72e7cc58f84314f394816ffa1725163f8c286160d343864760a8	27	0	3681816379900430	177997	0	339	\N	5000000	t	0
52	\\xcaebe54a5648aa5a39d64654020a8f43b5c52c03bf81508d995804b7b67b0958	29	0	3681816379721113	179317	0	369	\N	5000000	t	0
53	\\xbe288f001a3b6d72e411e9bb6b99d3cb24030c07e894bd89a9676e1cc65ba1f6	30	0	3681818181637632	180549	0	397	\N	5000000	t	0
54	\\x8b66d66359a05f71995d07f42908829daca582c14583469b66485ac619721256	34	0	3681818181443619	194013	0	653	\N	500000	t	0
55	\\xc8ecd45129e992c368df3ddb02e53451004ba54b5fafacbc41609f1bfbba3dfe	35	0	3681816379554160	166953	0	263	\N	\N	t	0
56	\\xe470e0c77afa6ad543935515b7c10ae376b799c9ccba970be8e62a812b27d2a4	36	0	3681815879376163	177997	0	339	\N	5000000	t	0
57	\\xfef7171a23263109d969171bb8b9f7f719884a6facf49f8b4708d549a903ea62	37	0	3681815879196846	179317	0	369	\N	5000000	t	0
58	\\xca2edfa5ab001bf5c2df0a0203ceaf5331eb5e7f7513700d415e726513f28e35	39	0	3681818181637632	180549	0	397	\N	5000000	t	0
59	\\x264bc5e4493967d0eb458949ee18c79ac89c1139e3b3c5761f7146b23a30b64a	42	0	3681818181443619	194013	0	653	\N	500000	t	0
60	\\x422b88020621eb42fe74a53b51bdfb9dec25db571c8d1f0e779cbe4a39951725	43	0	3681815879029893	166953	0	263	\N	\N	t	0
61	\\x080c87468d3dab332d9dc5f76473db892203c5c02bbbbeeb8a191dc15e1a6b87	45	0	3681815378851896	177997	0	339	\N	5000000	t	0
62	\\x0f15f335d2b900f9fae4891e7cee9b454dfd15f5d4608d4c3d049a0fcdcd0a17	46	0	3681815378672579	179317	0	369	\N	5000000	t	0
63	\\xf2bfbb06ba3d0b92bd28d4533d656e0ac0951c045a21e334429f4339285f0cf9	48	0	3681818181637632	180549	0	397	\N	5000000	t	0
64	\\x817750ee0d22e90e256c21080fc0136d8c0fb6284f7e1cdbf66b08441ad7b154	49	0	3681818181443619	194013	0	653	\N	500000	t	0
65	\\xfb4b7327dce4b36a72fb1cafcb20352d6901e554c0d38188eb90738fb69f0caa	50	0	3681815378505626	166953	0	263	\N	\N	t	0
66	\\x9cb467f1c33f0ff19323c76f291b7c2bce9bc244d991d199653089d90b5ac30d	51	0	3681814878327629	177997	0	339	\N	5000000	t	0
67	\\xd7f238faa15de6791b1bee8dbdd4822d945896a7c718434f8299e6dd9cb77d4c	53	0	3681814878148312	179317	0	369	\N	5000000	t	0
68	\\x81afd36868488a63678f492608e8b73feeaac9bd0635e1638a9ed8f37cad6a87	54	0	3681818181637632	180549	0	397	\N	5000000	t	0
69	\\xba827c84611b5f8741a728e1dcde9271a2d5e9534b3c088a4a205357e5adef10	57	0	3681818181443619	194013	0	653	\N	500000	t	0
70	\\xf46a3f9c0be561fafbc2c3cf5f37cb6eb3ed746a1594a1552c9954d2b6f503b5	59	0	3681814877981359	166953	0	263	\N	\N	t	0
71	\\x92fe0dad241fc3efe611c19b6343ab23a861b151b8a8c4c51218996042ca43df	60	0	3681814577803362	177997	0	339	\N	5000000	t	0
72	\\x19717f724262b85420a2ad3d44da5133d5d87eef5cbcc126b0d3f19d4e34a507	63	0	3681814577624045	179317	0	369	\N	5000000	t	0
73	\\x36ac9deccb397316a14e26c7c5258912a8020c166a3bc2512abc4972fe0c30c3	64	0	3681818181637632	180549	0	397	\N	5000000	t	0
74	\\x0820fd9c57dac0d527f731c596407b4576eebfcb747b9ceea8cdf5fa1a159018	65	0	3681818181446391	191241	0	590	\N	500000	t	0
75	\\xfcb27c9a8359a028ec1f1c17f125c655e3377a7ec23a7d9b59029f813f215166	67	0	3681818181265842	180549	0	397	\N	5000000	t	0
76	\\xf07b43a4d9059a4869fa20294a9b581c481840ec19e24ded40b5b8a2366ee5cc	69	0	3681814577439800	184245	0	439	\N	500000	t	0
77	\\x6ba7575f50471b6a2f8b7975b89b6f69537860bc79ae40ebc7d2422ec5d3a7ce	72	0	3681814577272847	166953	0	263	\N	\N	t	0
78	\\x53a9720e43c3fdadbcf84ba8b2bbd3e64959ef9c5e33ba675a16723fec1871dc	73	0	3681814277094850	177997	0	339	\N	5000000	t	0
79	\\xc79516047ffaa42ed2951e3a44fa9e46381df7a1dbacadac98f6ef338f8e24e8	74	0	3681814276915533	179317	0	369	\N	5000000	t	0
80	\\x88ac6f0cb158aa1273b60bcb2711c41f37e4202c8ef236aa3cf4298987a5dd88	75	0	3681818181637632	180549	0	397	\N	5000000	t	0
81	\\x94f0b3aea994d7bb8c8a953fc36a20047312c587dc6723e481402f9debfdc9fe	77	0	3681818181446391	191241	0	590	\N	500000	t	0
82	\\x6fe042352ca48598c14a0d4b5580c7bc02e99a579433206e94970fcc38e205e4	79	0	3681818181265842	180549	0	397	\N	5000000	t	0
83	\\xdb70a07277be5601d7e1e01fe7e7a4bd49e9682f42800ca4e61ab6a054e74acb	82	0	3681814276731288	184245	0	439	\N	500000	t	0
84	\\xda119af74ec54850367040aa5300aa2e56f35d6070481e94341d8a890180ebed	84	0	3681814276564335	166953	0	263	\N	\N	t	0
85	\\xe7adcb7eba08091b338f71d9b9e75b188ca952fe219c182645c007726c58a4a9	86	0	3681813776386338	177997	0	339	\N	5000000	t	0
86	\\x712195cb83f311c76f08a263cd02307de46e60cce9c77499315c35d0ca5e31d6	87	0	3681813776207021	179317	0	369	\N	5000000	t	0
87	\\xd4eeb22b82d7f681d49e41ee7bfb3e17e3d23da64ef0c6a9feb1203d6a929c66	89	0	3681818181637632	180549	0	397	\N	5000000	t	0
88	\\x7205ccbdd6292dc52f32f6f65475a929b1b4e729597f1a2ee8016fc9a072d020	91	0	3681818181443575	194057	0	654	\N	500000	t	0
89	\\x14c4847c4f0db0fcc21dee069517aa32b5f16d78653e5b42cd2bb6c4c6f1bf1a	92	0	3681818181263026	180549	0	397	\N	5000000	t	0
90	\\xe7fe4551ec938449747552b4fb8e648e4716da8b89a6759f4ab536d1c987cd95	94	0	3681813776022776	184245	0	439	\N	500000	t	0
91	\\xb0ec832f97276c86bd7ba7f49d8cb6dae978b6d6c0721ef674cd84a2c3cf5e75	97	0	3681813775855823	166953	0	263	\N	\N	t	0
92	\\xf9d5d939119827690476be114be8bd4c061ab4c8f0dc25bdb02d9bfb4c1f7c98	99	0	3681813275677826	177997	0	339	\N	5000000	t	0
93	\\x4c662d65e0e5beb790ac74f05ec3d9e3c1d4cb151d7fa4b4919d4b169cbd3e4c	103	0	3681813275498509	179317	0	369	\N	5000000	t	0
94	\\x26330f7ea1a7189d4fad58918cfb27138a5f11b92003fd898a34518277a1c9f0	104	0	3681818181637641	180549	0	397	\N	5000000	t	0
95	\\x4bb7252a246392a01bff448593b4824e2551f23e573bc9a6a98649ec4429861a	106	0	3681818181443584	194057	0	654	\N	500000	t	0
96	\\x78c91986581a29250b53583386f1cde1969d4da1a25e26a54de5845236111913	108	0	3681818181263035	180549	0	397	\N	5000000	t	0
97	\\x5872ec404c3185cf5947d65edf6b947befefafbca7627d62a3899290277defba	110	0	3681813275314264	184245	0	439	\N	500000	t	0
98	\\x433a2cade06e87e0d53d0e2eeb319cb2532afa9a94056606c2a12a79b92b4260	114	0	3681818181650832	167349	0	272	\N	\N	t	0
99	\\x6cb2599902acea6f2ee22c852b3bad68d8b1d136ffa83904cea38748b9e3e042	116	0	99828910	171090	0	350	\N	\N	t	14
100	\\x9be449aa97d83a1eb87ee0e306bcab8d9646d3432228d18a53b16482b04721f3	117	0	3681818081484759	166073	0	243	\N	\N	t	0
101	\\x63aa2c8f68c5012b697c7a20db2d574d103f3cfd3efb719f6d08eb1b8c6338b4	118	0	3681817981314374	170385	0	341	\N	\N	t	0
102	\\x6c37dfbc1adc078602c20c02b572a3f4cecd4c56a4a043213244c96382e80db2	119	0	3681817881146585	167789	0	282	\N	\N	t	0
103	\\x5dc7e43810279eca81429091c3ab61a5dc2fb8b44b163ab9decaa6be02987e76	120	0	3681817780979940	166645	0	256	\N	\N	t	0
104	\\x7356293fb77ca779596ea9e0e71326c456a2f492ba5cc9846ab75865ea182362	122	0	3681817680717067	262873	0	2443	\N	\N	t	0
105	\\x5e59561189320adcc333d3a04a2420fdfd6cab17564ef1299658183cd66fd8f9	123	0	3681817580550950	166117	0	244	\N	\N	t	0
106	\\x9f4f6e1e1da59d21422f2fd2224ddbc821dc0669549296545696fdb08c99ccf7	124	0	3681817580223603	327347	0	2613	\N	\N	t	2197
107	\\xa9ac93d86ad75691a760fa545c6698cecd467da49bde33a4d8707d8c32cdf1bb	126	0	3681818181642252	175929	0	467	\N	\N	t	0
108	\\x5e44a25ad4f5e52cdbb1341e0356ca7cbeec997404bbad93d4815ed14fc93ae7	129	0	3681818171420783	221469	0	1502	\N	\N	t	0
109	\\xff0e61dd21cf59ec8cdddbc037eb4268048e8166a0204a4d0a4727e073b7e01a	129	1	3681813275134639	179625	0	551	\N	\N	t	0
110	\\x6b4b30a8e05ca3c5e1f4b6c4d13ec97ffe9c773d56d00f86d027e5ec259caf64	368	0	4999999795603	204397	0	1109	\N	5536	t	0
111	\\xbd685d6557377370bf03431ebaa5f1091c0f07376490a0cafcfabf52f6de273d	372	0	4999999621918	173685	0	411	\N	5589	t	0
113	\\x02cb36be17a4e555f0366c6cef1fa91b9a8ea64d2e6a248f2c47a494324ff65b	377	0	4999997448277	173641	0	410	\N	5646	t	0
114	\\xc55ffcbb8170acb1e4b8cdc38b0367d376c8b05a1241938820c8557b6d6847ff	381	0	1826535	173465	0	406	\N	5687	t	0
115	\\x014e184c5027dc15dbf246cbb7f7ca7cd29433d670c4102bf3e53eb90c8ce552	385	0	4999997255144	193133	0	853	\N	5708	t	0
116	\\x1498344f3ebfe76e4c6360562f7017bf4dc88ad8438efcc8a2fb8b9d1e5b9685	389	0	4999995062011	193133	0	853	\N	5742	t	0
117	\\xe55db19112e8406e98d299bbde1430f471e2bd14610527afedb7e21a3322064d	393	0	3824951	175049	0	442	\N	5772	t	0
118	\\xcb34e2bed828d52bf9e1f6c30e669fe57e21b20eefff79faaec03deb286e1702	397	0	4999992868878	193133	0	853	\N	5789	t	0
119	\\xd31cc83d5a4b7fe828ff74e6920e233825b88f59e5de4961babe1f6cc68a8d97	401	0	1826535	173465	0	406	\N	5819	t	0
120	\\x2b7cae983ae06ded8884866a15497272ab55fadc4b28715eb24b20e33b6ea8d8	405	0	3631994	192957	0	849	\N	5875	t	0
121	\\x08fc8200ebeca5ed68980dba8a3f08c9618cd5eb65549a314dc3fddb8aca36eb	409	0	1824687	175313	0	448	\N	5911	t	0
122	\\x8294e8f89fd7528d5947b4388b4c19c66a76884e6d17c457dce99abb8e1dc48d	413	0	1651222	173465	0	406	\N	5956	t	0
123	\\xf401b5c6f173d28e86e30c786ef7834b2f3e60dac12915962d1912745008fa91	417	0	4999990664701	204177	0	1104	\N	5988	t	0
124	\\x294a1b3c777a0732544fc1f17607671d48f2fde78418e42fd130e40c0713a3b0	421	0	4999990484284	180417	0	564	\N	6029	t	0
126	\\x4ba9753375690800b667febcd8c9fa4d92852f20efde3f52802d829d0f6855ae	426	0	4999980294583	189701	0	775	\N	6049	t	0
127	\\x9a97160e6cc4492551604268572eddf0ff78585bb5422be9d029838ea0ad9318	430	0	11462973	188249	0	742	\N	6103	t	0
128	\\xa777199969c6143667098901924559aa7a599a14770d2d6de4c8e1c8ab9313ea	434	0	23266232	192297	0	834	\N	6170	t	0
129	\\xed30b8fcccc5b93ae52061f1266f94ac9875cee307f2e99e56099b1b679af53f	438	0	4999993381410	179405	0	541	\N	6234	t	0
130	\\xe61dde8c39d53efbf7367c46486f210d958a7e6f99936b18a3dd93c910d38515	444	0	4999993213005	168405	0	291	\N	6279	t	0
131	\\xde9cfa8667e5950da112a3f5b30957b6416fd8040b7ac733e5380989fd2282b7	448	0	999779499	220501	0	1479	\N	6359	t	0
133	\\xdb6f148e5413f4f13dbad430835650ca60907badf04077962e9cfe4fcf4b6c1d	453	0	999607970	171529	0	366	\N	6409	t	0
134	\\x6829b6b9f6ce3fb77062698c1c3fcea8cc491572eb24a75c8ef431e46ce0044d	459	0	999406213	201757	0	1049	\N	6470	t	0
135	\\xac3182f9ad863e892723ea7875c59253d39fe57df9cef82b0945bcd19ae107f1	463	0	4998993035272	177733	0	503	\N	6512	t	0
136	\\x3f9b90e3980ff1fde3674b3aa79f61bc34567eb0c84485fe65d81610830ca86e	467	0	2826843	173157	0	399	\N	6553	t	0
137	\\x0a4786cfb1ca46bbfbd10e9162ffbbc465e48b371f7461e00a31c7fa16f70886	472	0	4998992676506	185609	0	682	\N	6579	t	0
138	\\xb109b1b725236f12d06e6bbddcb555cc2707f2a02c3a63c825961c84c9fea2b1	476	0	2820771	179229	0	537	\N	6622	t	0
139	\\x02e2e7cd295a7056e113b0958f660f980832442543b25b208fcb5c0c7bb099d2	482	0	4998993788501	171749	0	367	\N	6648	t	0
140	\\xf5596554c11c5c62c79cd2bf3e1521f7b3e0fcf235aa59ebdec79861079f3f3a	482	1	4998993618336	170165	0	331	\N	6648	t	0
141	\\x045d6cf490e1e87795fdff85429b270ce76bb07be354878e102cb238300fd5d8	488	0	1999597074177	168009	0	282	\N	6733	t	0
142	\\xd9eccf7935e025e3111e66f89d9d9c477651e13379cfcac1bbf230e9ee389d75	492	0	1999593905772	168405	0	291	\N	6757	t	0
143	\\x14becada8adc8af35b5ad56d5967502895d26e17b1ee3f8eaf717f653556c4a2	493	0	0	5000000	0	2368	\N	\N	f	1893
144	\\x434a2bc4e17f3d18f30fbb90bfc09ef1c07524467e0b429a5fe23b8bba0461a9	494	0	1999588735519	170253	0	333	\N	6776	t	0
145	\\xe4a396fb09a11ded9ddf596db025574590b9b271d57109a22b573a067e05093b	497	0	2999396207745	168405	0	291	\N	6819	t	0
146	\\xb3b65f0c0878f5c33cb642bb9f120fd5927395e96b96c15cde55a6eea750c87d	498	0	4998984770107	173157	0	399	\N	6821	t	0
147	\\xe0053703c2de2fc6fb0366c404f5ca3d56a1f689dfcedb4ee13aff5a85340065	500	0	4998984252210	517897	0	8234	\N	6851	t	0
148	\\x1613a5b99de766d2c1aa670f5d5d5f6ffc8834560c3cf6a5e6d5ff493587d51c	501	0	179474447	525553	0	8408	\N	6897	t	0
149	\\x7f7fcf9b66f40b90d93c9c7b10f27189849437f2f92ec8c98f9050456e6ad434	502	0	83074204836	177293	0	493	\N	6905	t	0
150	\\x2c00567c8cad4c4e91203eeaa11beb9b3021597b9e51405be67feb73906e9c59	503	0	97415534982	171617	0	364	\N	6918	t	0
151	\\xede33bbfd1044bdc3804192dff4021a28c6bd38ba18575292020830a6e30ee9c	508	0	83074213680	168449	0	292	\N	6926	t	0
152	\\x62156319a0cf0aebd37624d71ca581a8634fc8e394605859fcd7aa673c58aa50	521	0	83074207696	174433	0	428	\N	6969	t	0
153	\\xc1c3e098afe1e778ca27082cfff71aac3eeb36585e0e5221d40868616f5eff41	679	0	83074213680	168449	0	292	\N	8463	t	0
154	\\xbd8d67fddffb9df39625d4352d256be00d02d2663ed1e867c648df8e4b992d87	679	1	83064045275	168405	0	291	\N	8463	t	0
155	\\x9ca45e810846af0b4760913f2b872da0e2feadc1225a324408d1c7893b382154	679	2	83074213680	168449	0	292	\N	8463	t	0
156	\\xba6b3886c1c76789837dc962c31cf59e167721eb1a12877886442833db28ea72	679	3	83074213680	168449	0	292	\N	8463	t	0
157	\\x01b7b68d9debfc8335d0e0e950aa93fe94bfa504350000b1488cb42dd4de75b3	679	4	83074213680	168449	0	292	\N	8463	t	0
158	\\xedfb30d6c8b31cd539c1443392781648b0bafd7af167590a88237c4f1346abd3	679	5	83074213680	168449	0	292	\N	8463	t	0
159	\\xd87919f7d9a66184cce90e7ddb3039584914ea55bab7c7ae339bd523069fb497	679	6	83074213680	168449	0	292	\N	8463	t	0
160	\\xcef45931c2032a719b3ded403f8daafbdaf24a270d163d79b2d79a6bfedbe906	679	7	83069045275	168405	0	291	\N	8463	t	0
161	\\xce953fa2cf395b02d505bcb4554b4488481572bac9b1c3f3ca8cc5d25d9c4549	679	8	83069045275	168405	0	291	\N	8463	t	0
162	\\x043b22b1846dde2aba1d140f641f8da37f5cfd6fb389565b00664423fe510f4a	679	9	83074213680	168449	0	292	\N	8463	t	0
163	\\xf8f6589ffe55188b4ae1f7ba1069c7ee32f046fba4cc93bbfcebbd23f1ca9eaf	679	10	83074213680	168449	0	292	\N	8463	t	0
164	\\x6c5b3507ff9998a4c09c2ab48a046be2df3bc0da97a3cfe68e8aa8867a45c5f4	679	11	83074213680	168449	0	292	\N	8463	t	0
165	\\xfb09ba53bc1c36c3e1dedcea4a4563530b77aadd5ee853f19b42be759862c581	679	12	83074213680	168449	0	292	\N	8463	t	0
166	\\xbbe9c8c86e491b2d74161c86496eb21669338fbae82744682a34ef0c2f6bff3f	679	13	83074213680	168449	0	292	\N	8463	t	0
167	\\xf2d0c1e0caf27ba308562b5d47a28060288f6b99137029446ee349d1bfebd987	679	14	9830187	169813	0	323	\N	8463	t	0
168	\\x7e616b67a01bfc3642e14dff251fdaaa8af304b61dbb975d744b926b2186682f	679	15	83074213680	168449	0	292	\N	8463	t	0
169	\\x6181784690aa63bc9361ca4428f6466e9b8f94c8a3555e88e0124cfa879578a6	679	16	83074213680	168449	0	292	\N	8463	t	0
170	\\xb3b3ab4d721c958b3fa4628b0855fa73ff2dedb72f2779c39ed18f2d55bb6a10	679	17	83074213680	168449	0	292	\N	8463	t	0
171	\\x31689782e00a041fcfe40b58a98bdf7269cfee73dc2d486e9f121426379384d0	680	0	83073036431	168405	0	291	\N	8463	t	0
172	\\x9523f278be8ea0cab97ce7771a463cb4f779d3dfe51a3021e20ea64488dc367c	680	1	83074213680	168449	0	292	\N	8463	t	0
173	\\x87dc880e00d50439c003cdc071c8ffad5ca9f9f39be1c610fb7f3d74ee869839	680	2	83074213680	168449	0	292	\N	8463	t	0
174	\\x4a74babc25adce28cb2f8044a2ec17565d5be4d6f893888958f69a372df40f15	680	3	83074213680	168449	0	292	\N	8463	t	0
175	\\xb047dd2456a3dd92a5a58168c7c3b4f32962e136cc862b0f14e25af738cf6ee0	680	4	83074213680	168449	0	292	\N	8466	t	0
176	\\x938ab2b2c1cd3858b5506fcc80c6b9585f3e95d048eca98397aee8f4d8960957	680	5	83074039291	168405	0	291	\N	8466	t	0
177	\\xa980fbd7e63ce4a8e28b2b1a138cb19129b8864319bc086e9212e9c47848d6a6	681	0	83074213680	168449	0	292	\N	8466	t	0
178	\\x8cacc90c629e232d11f2a73c3e03255591b7f6f5f8077fa992f48f886c7b2bc3	681	1	9830187	169813	0	323	\N	8466	t	0
179	\\x062b20f49a09023b32922208a01921754e680727d3c1213da54f46885bd48c08	681	2	9660374	169813	0	323	\N	8467	t	0
180	\\xa3c54cd4af47c14766fe6c034c6d627c6476d7d2b90df0dbed808f8a309d2443	681	3	83074043691	169989	0	327	\N	8467	t	0
181	\\x3228df31a160e3cc246d935ff348bc3c11dbcb8ce82ed1c34f3b32ddabaaafb0	681	4	83069045275	168405	0	291	\N	8467	t	0
182	\\x28cfb5cfc4dd7d9e66477ba44bb0ea980a2185e3a9d39d0c40c3aa0d22a41793	681	5	97415366577	168405	0	291	\N	8467	t	0
183	\\xd1adec53158ae1645f7fd4630035c00c0737b3652e94bc390f9dba68220b0a47	681	6	83069045275	168405	0	291	\N	8467	t	0
184	\\x99cb9255e708d39dc2a719f5bee11879a1e65ef55f10a5afcf751f4b972ba644	681	7	83074213680	168449	0	292	\N	8467	t	0
185	\\x8eeefe14416ff72d3b6e85c703f7a79c825e61dae8cd7d038808dd2256145dbd	681	8	83074043691	169989	0	327	\N	8467	t	0
186	\\x4d4fc51740a154f973bebe9efec82dc249004031ba22c3c10f37954d7163a8a1	681	9	83074213680	168449	0	292	\N	8467	t	0
187	\\x5fb14c39d2e785f9996007ec98b5b8cc323402ae9b264846d490414b17f12884	681	10	83068875286	168405	0	291	\N	8467	t	0
188	\\x3818c995bf7eb7e947ef1a5df79534bd7a334823fb7bcfc78e7aa848994130e3	681	11	83074213680	168449	0	292	\N	8467	t	0
189	\\x90e9f2def82b33fa1246c62944e59de0aee07469aebbeebb5ccfb6c5d16f634a	681	12	83069045275	168405	0	291	\N	8467	t	0
190	\\xbc1de41221ee8397666c77a42cd6ef6898fc2cb30525901ec2362a25a110a743	681	13	83063875286	169989	0	327	\N	8467	t	0
191	\\x019418e94bc65229cc3a4ca917cf903aef8afb542896234c788df107b60d0f98	681	14	83079212096	170033	0	328	\N	8467	t	0
192	\\xc2ed2b3195697a9780a6b33f4a57316ffbe788d0da2df8267168c598892123a1	681	15	83068875286	169989	0	327	\N	8467	t	0
193	\\xe5e006dd92b5f96ade475d7dfc9c5ddff780a2e3ef33a022543db7bec7f825e9	681	16	83069045275	168405	0	291	\N	8467	t	0
194	\\x461c4520decc70368debd94536d1f9d11d598cea6cb5c4b72b38da82641b07a3	681	17	83063876870	168405	0	291	\N	8467	t	0
195	\\x73d73fd6a62d1ea667c6ea16ae6a566e77debf0ab2ccc74474a08a9b77ce3e1d	681	18	9830187	169813	0	323	\N	8467	t	0
196	\\xf0e33de3537ab4deb2da666b13a9746acabb5705e2cf846c75bc6477dc616fca	681	19	9830187	169813	0	323	\N	8467	t	0
197	\\xb5187329cb16cf1ca6abf80967082a5128f5bfe0a4cca7e7546d743b00d0b17d	681	20	9830187	169813	0	323	\N	8467	t	0
198	\\x5c0b1f25c8ee29b470f003df09ea372dde1ea80adb90f3aebde279f9f37665f0	681	21	83068705297	169989	0	327	\N	8467	t	0
199	\\x0ff0cd421edaaf63ea9dca082290e103c2d05ec588c8cdc10b880f5ef1594620	681	22	83074213680	168449	0	292	\N	8467	t	0
200	\\xa4d64fc7b042f72b08985390c7f16d674517717cb58be6c332dc24630eae9e49	681	23	83074213680	168449	0	292	\N	8467	t	0
201	\\xba8780f19208d20dbf0e7921360a8b7df18f6fe2a7b6f6553b587aebf2a8957d	681	24	83069045275	168405	0	291	\N	8467	t	0
202	\\x320d77f58223bad9f3ccc443d54da274d88e41d92ded3a79b112ce2a977cb7a8	681	25	83074213680	168449	0	292	\N	8467	t	0
203	\\xb01eac6585a82f9b8083895028ed2d904773fe4325fc6b7b9cdde141dff13ff4	681	26	83063876870	168405	0	291	\N	8467	t	0
204	\\xd4c21da78201b93051bc73d42f82b1c77a2067de788d9b2a1dca5b1f0f09d652	681	27	9830187	169813	0	323	\N	8467	t	0
205	\\x136f7d7ed72c6dabd2c95bd31a460a80a82d7e9cc4999b542540d817bc6f40f7	681	28	83058706881	168405	0	291	\N	8467	t	0
206	\\xefb037d6489015d2dbda71a67217fd01e1a02f4afc81d250c1cdbde1b63202ae	681	29	83069045275	168405	0	291	\N	8467	t	0
207	\\xcb10f3dc6844695743a201ec538bad94d0cc900c50768b57ec397a446a73b260	681	30	83074043691	168405	0	291	\N	8467	t	0
208	\\x13860b6770c7137d84f8f8e4e38020dc2f3bf7565bef5b111f83c230227a4772	681	31	83074213680	168449	0	292	\N	8467	t	0
209	\\xa0a624a816226f0ffc1715feb5b76e16327b0fd08ff1883b4e937f4be874e886	681	32	9660374	169813	0	323	\N	8467	t	0
210	\\x2980e51ee858a04345e6ed1cb5db506e2b734988177db16f6490ec9e13d09979	681	33	9660374	169813	0	323	\N	8467	t	0
211	\\x96fae8ce07852f135dbf2c9ae2e675705c5fcb0536ce466e534d9e7fccc90497	681	34	83074213680	168449	0	292	\N	8467	t	0
212	\\x4e672eabcd840aca556840db79a66e7812ac0820f17d1bddb65e5a11ce2e0518	681	35	9830187	169813	0	323	\N	8467	t	0
213	\\x104d668d1e418fe9b18baf10ced8cf9647e52507f8834270ccb67d6981abd47e	681	36	83069045275	168405	0	291	\N	8467	t	0
214	\\x7017888627e1302f9fb76fab3c102d00441c6f42e8f382adb6515254f6b6d119	681	37	83069045275	168405	0	291	\N	8467	t	0
215	\\xad9cf985cc6aebae563522144896e123c45fc29f990ec4d935e42c73d4c0406e	681	38	83079212096	170033	0	328	\N	8467	t	0
216	\\xb20bc468a60dc15f935b5dab4aa19f307e555676d2918cebe249ccd3c012a0c5	681	39	9830187	169813	0	323	\N	8467	t	0
217	\\xd59737220afb8e3e2f4bb72b559fe9e0a874c306dba04851762cdb2e1f43c9bd	681	40	83074043691	169989	0	327	\N	8467	t	0
218	\\xc61ec698e0535018a63d795af1daaa2dad4c3b0ae848c3dfafa959bbf1bce941	681	41	83074213680	168449	0	292	\N	8467	t	0
219	\\x40b41fc346923325633254dbc570eb44c98396cb2bca45e9fa3b54228e1434b4	681	42	83068875286	169989	0	327	\N	8467	t	0
220	\\xc2882706bae2378334000b2f1b79c4e8d728e9ede6eafc19584825c823489831	681	43	83074213680	168449	0	292	\N	8467	t	0
221	\\x7ef54577332aac46a25b28f1ccabcd519861e1fdc11b93fa48cef85e25e8c360	681	44	83074213680	168449	0	292	\N	8467	t	0
222	\\x71dbf7e1cc3e47fa624aafba2a62afb5bef01e6ba54a2d26b8abd6de832916df	681	45	9830187	169813	0	323	\N	8467	t	0
223	\\xeb1f7921384c471cb370f47a7473d9eeffaa2dc0121990d4fee0b6290d2f5860	681	46	83074213680	168449	0	292	\N	8467	t	0
224	\\x05de484a38267e6d772ce5a67237c426bf681791cc4af8478709feb7696692a1	681	47	83074213680	168449	0	292	\N	8467	t	0
225	\\x6ab5c52614c1a6f9c7bc10f19c62cd5c71d9b944b42a0444a19bb58a38956f25	681	48	83069045275	168405	0	291	\N	8467	t	0
226	\\x026ba9950ec5f6be1c32513ce6ce136da5dee1db404df23722bbb49ef60b51bb	681	49	83074213680	168449	0	292	\N	8467	t	0
227	\\x94490ef31db151a3829b0b3411b1b6b0d096a7477bc11618ee6550b7369c6c91	681	50	9830187	169813	0	323	\N	8467	t	0
228	\\x0ebd1ba7b79b85bede02bb34b3bd17263964864dbe5086501bdce6ec1e9babc7	681	51	83079212096	170033	0	328	\N	8467	t	0
229	\\x1cbeb4784711cdd2cddfe0bd64f0f5788abf44bf0696e027a368afe495e638d7	681	52	83058708465	168405	0	291	\N	8467	t	0
230	\\xa36f02649b2e3b02c0f088bbb31d4f42de1b103431408920b70c4cfd8da0e866	681	53	9830187	169813	0	323	\N	8467	t	0
231	\\x8d276d6049228e265cde497baea9e472f9c41545fae7edc23da66f75c597d0ec	681	54	9830187	169813	0	323	\N	8467	t	0
232	\\xfd62f5f1aecad2eab281a5cfd373f429c054210935aaff9091fd9d824cc30b4f	681	55	83074213680	168449	0	292	\N	8467	t	0
233	\\xd3b6762135d09a0d3b65dda99a37c7c560c8135a80079518757c43be2fab6b2e	681	56	83063876870	168405	0	291	\N	8467	t	0
234	\\xe2bcc30d68ec574126e83d5897e71146a3fc15c54774cd4c154e64af149942c9	681	57	9830187	169813	0	323	\N	8467	t	0
235	\\x21986a9f598b26a938d617fe2aaff4b243d36249c8740129f4ba513db0815d84	681	58	83068875286	168405	0	291	\N	8467	t	0
236	\\x386321e7817acc1cc739c766d51286fbb9effb5da0fbc7fbe0a9b0b57a7d0afc	681	59	9830187	169813	0	323	\N	8467	t	0
237	\\xbf7ef5930e31a2260fe6331f9f8e9acf435e0c4f7441748baaa5ee1cc8a5c11b	681	60	9830187	169813	0	323	\N	8467	t	0
238	\\xbeba1db05dfc6f1c31f50db7102ae34095b9688fd1485bec4ed97077c678f376	681	61	9490561	169813	0	323	\N	8467	t	0
239	\\x94e999d9e3e52a715c91888c3978d792e794321a2a0fbb620697c4b351b57a50	681	62	9660374	169813	0	323	\N	8467	t	0
240	\\x232c52443172aa5496e066da7fe6c7cd93e16f615f92dd2948bbd10305e110c5	681	63	9490561	169813	0	323	\N	8467	t	0
241	\\xec956f2572cabce1066576b645d72ccb1ba6a766bf378122c88c77cc044b1ede	681	64	83074213680	168449	0	292	\N	8467	t	0
242	\\x70ed1fa8b79f90c326b88e33e251ff93a403bee504c261112de08f117b41b9a0	681	65	83069045275	168405	0	291	\N	8467	t	0
243	\\xee3a15d66b293068d75632cfbcc7119c0fad0fd8840c5c1dd064dbe755bc72c8	681	66	83053538476	168405	0	291	\N	8467	t	0
244	\\x6d3a833bdafb64ff6c21f488e5cbe350ade1817f12b2ff4a3ec9dcfeb1d0ac26	681	67	9660374	169813	0	323	\N	8467	t	0
245	\\x190da8c11a596e417f050c719e4abcf2247b02c267f362ac97979c7e47ae5273	681	68	9660374	169813	0	323	\N	8467	t	0
246	\\xc57d28839c70f015220ab09f3b29b166f430e8b33b41ea3588077f2ebc8e14a0	681	69	83068875286	168405	0	291	\N	8467	t	0
247	\\xdc955f2a7cc86fb4731280bd507b0085b7de43c78b2c092d52e9f7b2e1d38e4a	681	70	83069045275	168405	0	291	\N	8467	t	0
248	\\x4331e9f368f01dda187120a4d8c99de0f5e90f08ebf271b11ad47d2fcd9e3ac0	681	71	83079212096	170033	0	328	\N	8467	t	0
249	\\x48388ef142084bbd995af2ccf39a57987e04dd38b5f26966310317f1373df04a	681	72	83074043691	168405	0	291	\N	8467	t	0
250	\\x443370d96a6baf2a0a064eb7fd7163e6d490d0bd256637ae6cb4c5f075c36322	681	73	83074043691	168405	0	291	\N	8467	t	0
251	\\xe92e82616dee1e1bae4d1f213a2503cdc0e8c381cb8cff91b9304cd9fb1e355b	681	74	9490561	169813	0	323	\N	8467	t	0
252	\\x4fbb30e14b9a64744078391b5d321f3a844de000608635580f624bf319a75b05	681	75	9830187	169813	0	323	\N	8467	t	0
253	\\x65a4eac87ea066d56338e6d098a65e6b2f9cbd7b74b0518026f148105b341ed5	955	0	95025251177	174741	0	435	\N	11119	t	0
254	\\x408ae418ce976b47f2a1dec45c959a1e3c5f140a0c2684abc64f270afb4eb52d	963	0	4999999820111	179889	0	552	\N	11185	t	0
255	\\x7e770178da155ce3b8b3ac66018da1d81bcf451345caf5719dea5ee2ebf86fea	967	0	4999999648538	171573	0	363	\N	11204	t	0
256	\\x4c2bfeff6e7277bcbbe69ae8421b6c201ca7ac53472ed5268a7124790d603401	971	0	4999996472785	175753	0	458	\N	11262	t	0
257	\\xa168b42f352d88a875e5aebd5aac3fb75d3707ec6f3b60caab92c3b99eb7a536	976	0	4999999820287	179713	0	548	\N	11299	t	0
258	\\x98bdf7ca7aed547bf467d18e9ca99b613214ada0043226b3b6fb8a5e15d4a858	980	0	4999999648714	171573	0	363	\N	11333	t	0
259	\\xabe1e8561644a4569508292a2452977037d88ad8f1de3f586933d497a48d0938	985	0	4999996472961	175753	0	458	\N	11363	t	0
\.


--
-- Data for Name: tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_in (id, tx_in_id, tx_out_id, tx_out_index, redeemer_id) FROM stdin;
1	35	28	0	\N
2	36	35	1	\N
3	37	36	0	\N
4	38	25	0	\N
5	39	38	0	\N
6	40	37	0	\N
7	41	40	1	\N
8	42	41	0	\N
9	43	32	0	\N
10	44	43	0	\N
11	45	42	0	\N
12	46	45	1	\N
13	47	46	0	\N
14	48	16	0	\N
15	49	48	0	\N
16	50	47	0	\N
17	51	50	1	\N
18	52	51	0	\N
19	53	30	0	\N
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
34	68	22	0	\N
35	69	68	0	\N
36	70	67	0	\N
37	71	70	1	\N
38	72	71	0	\N
39	73	19	0	\N
40	74	73	0	\N
41	75	74	0	\N
42	76	72	0	\N
43	77	76	0	\N
44	78	77	1	\N
45	79	78	0	\N
46	80	17	0	\N
47	81	80	0	\N
48	82	81	0	\N
49	83	79	0	\N
50	84	83	0	\N
51	85	84	1	\N
52	86	85	0	\N
53	87	29	0	\N
54	88	87	0	\N
55	89	88	0	\N
56	90	86	0	\N
57	91	90	0	\N
58	92	91	1	\N
59	93	92	0	\N
60	94	33	0	\N
61	95	94	0	\N
62	96	95	0	\N
63	97	93	0	\N
64	98	24	0	\N
65	99	98	0	1
66	100	98	1	\N
67	101	100	1	\N
68	102	101	1	\N
69	103	102	1	\N
70	104	103	1	\N
71	105	104	1	\N
72	106	105	0	2
73	106	105	1	\N
74	107	13	0	\N
75	108	107	1	\N
76	109	97	0	\N
77	110	109	0	\N
78	111	110	0	\N
79	111	110	1	\N
81	113	111	1	\N
82	114	111	0	\N
83	115	113	0	\N
84	116	115	1	\N
85	117	115	0	\N
86	117	116	0	\N
87	118	116	1	\N
88	119	118	0	\N
89	120	117	0	\N
90	121	120	0	\N
91	122	121	0	\N
92	123	118	1	\N
93	124	123	0	\N
94	124	123	1	\N
96	126	124	1	\N
97	127	124	0	\N
98	127	122	0	\N
99	128	120	1	\N
100	128	126	0	\N
101	128	127	0	\N
102	128	119	0	\N
103	129	126	1	\N
104	129	128	0	\N
105	129	128	1	\N
106	130	129	0	\N
107	131	130	0	\N
113	133	131	0	\N
114	133	131	1	\N
115	133	131	2	\N
116	133	131	3	\N
117	133	131	4	\N
118	134	133	0	\N
119	135	130	1	\N
120	136	135	0	\N
121	137	136	0	\N
122	137	135	1	\N
123	138	137	0	\N
124	139	137	1	\N
125	139	127	1	\N
126	139	138	0	\N
127	140	139	0	\N
128	140	139	1	\N
129	141	140	1	\N
130	142	141	1	\N
131	143	142	0	\N
132	144	142	1	\N
133	145	140	0	\N
134	146	144	0	\N
135	146	144	1	\N
136	146	145	0	\N
137	146	145	1	\N
138	147	146	0	\N
139	147	146	1	\N
140	148	147	0	\N
141	148	147	1	\N
142	148	147	2	\N
143	148	147	3	\N
144	148	147	4	\N
145	148	147	5	\N
146	148	147	6	\N
147	148	147	7	\N
148	148	147	8	\N
149	148	147	9	\N
150	148	147	10	\N
151	148	147	11	\N
152	148	147	12	\N
153	148	147	13	\N
154	148	147	14	\N
155	148	147	15	\N
156	148	147	16	\N
157	148	147	17	\N
158	148	147	18	\N
159	148	147	19	\N
160	148	147	20	\N
161	148	147	21	\N
162	148	147	22	\N
163	148	147	23	\N
164	148	147	24	\N
165	148	147	25	\N
166	148	147	26	\N
167	148	147	27	\N
168	148	147	28	\N
169	148	147	29	\N
170	148	147	30	\N
171	148	147	31	\N
172	148	147	32	\N
173	148	147	33	\N
174	148	147	34	\N
175	148	147	35	\N
176	148	147	36	\N
177	148	147	37	\N
178	148	147	38	\N
179	148	147	39	\N
180	148	147	40	\N
181	148	147	41	\N
182	148	147	42	\N
183	148	147	43	\N
184	148	147	44	\N
185	148	147	45	\N
186	148	147	46	\N
187	148	147	47	\N
188	148	147	48	\N
189	148	147	49	\N
190	148	147	50	\N
191	148	147	51	\N
192	148	147	52	\N
193	148	147	53	\N
194	148	147	54	\N
195	148	147	55	\N
196	148	147	56	\N
197	148	147	57	\N
198	148	147	58	\N
199	148	147	59	\N
200	149	147	61	\N
201	150	147	60	\N
202	151	147	78	\N
203	152	147	62	\N
204	153	147	112	\N
205	154	151	1	\N
206	155	147	114	\N
207	156	147	64	\N
208	157	147	94	\N
209	158	147	87	\N
210	159	147	68	\N
211	160	153	1	\N
212	161	159	1	\N
213	162	147	107	\N
214	163	147	106	\N
215	164	147	71	\N
216	165	147	96	\N
217	166	147	67	\N
218	167	161	0	\N
219	167	163	0	\N
220	168	147	92	\N
221	169	147	118	\N
222	170	147	104	\N
223	171	149	1	\N
224	172	147	86	\N
225	173	147	72	\N
226	174	147	98	\N
227	175	147	81	\N
228	176	152	0	\N
229	177	147	109	\N
230	178	169	0	\N
231	178	153	0	\N
232	179	178	1	\N
233	179	154	0	\N
234	180	179	0	\N
235	180	165	1	\N
236	181	174	1	\N
237	182	150	0	\N
238	183	163	1	\N
239	184	147	65	\N
240	185	168	0	\N
241	185	155	1	\N
242	186	147	66	\N
243	187	185	1	\N
244	188	147	117	\N
245	189	170	1	\N
246	190	186	0	\N
247	190	154	1	\N
248	191	178	0	\N
249	191	147	101	\N
250	192	182	0	\N
251	192	183	1	\N
252	193	177	1	\N
253	194	189	1	\N
254	195	181	0	\N
255	195	188	0	\N
256	196	166	0	\N
257	196	167	0	\N
258	197	191	0	\N
259	197	190	0	\N
260	198	187	1	\N
261	198	156	0	\N
262	199	147	75	\N
263	200	147	88	\N
264	201	173	1	\N
265	202	147	84	\N
266	203	160	1	\N
267	204	189	0	\N
268	204	165	0	\N
269	205	190	1	\N
270	206	164	1	\N
271	207	191	1	\N
272	208	147	74	\N
273	209	160	0	\N
274	209	196	1	\N
275	210	195	1	\N
276	210	204	0	\N
277	211	147	82	\N
278	212	198	0	\N
279	212	207	0	\N
280	213	162	1	\N
281	214	156	1	\N
282	215	171	0	\N
283	215	147	93	\N
284	216	174	0	\N
285	216	192	0	\N
286	217	157	1	\N
287	217	201	0	\N
288	218	147	113	\N
289	219	164	0	\N
290	219	193	1	\N
291	220	147	111	\N
292	221	147	102	\N
293	222	208	0	\N
294	222	158	0	\N
295	223	147	95	\N
296	224	147	100	\N
297	225	169	1	\N
298	226	147	63	\N
299	227	194	0	\N
300	227	159	0	\N
301	228	205	0	\N
302	228	147	105	\N
303	229	194	1	\N
304	230	227	0	\N
305	230	203	0	\N
306	231	200	0	\N
307	231	223	0	\N
308	232	147	76	\N
309	233	213	1	\N
310	234	212	0	\N
311	234	170	0	\N
312	235	207	1	\N
313	236	226	0	\N
314	236	202	0	\N
315	237	210	0	\N
316	237	183	0	\N
317	238	179	1	\N
318	238	235	0	\N
319	239	236	1	\N
320	239	222	0	\N
321	240	209	1	\N
322	240	215	0	\N
323	241	147	97	\N
324	242	224	1	\N
325	243	205	1	\N
326	244	221	0	\N
327	244	167	1	\N
328	245	216	1	\N
329	245	217	0	\N
330	246	180	1	\N
331	247	168	1	\N
332	248	230	0	\N
333	248	147	99	\N
334	249	248	1	\N
335	250	228	1	\N
336	251	230	1	\N
337	251	197	1	\N
338	252	224	0	\N
339	252	155	0	\N
340	253	147	69	\N
341	254	109	2	\N
342	255	254	0	\N
343	255	254	1	\N
344	256	255	1	\N
345	257	109	4	\N
346	258	257	0	\N
347	258	257	1	\N
348	259	258	1	\N
\.


--
-- Data for Name: tx_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_metadata (id, key, json, bytes, tx_id) FROM stdin;
1	721	{"2c74874ae85a596ad88adc391c5fd7fdb8d8f85e22ced233ee85539d": {"": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "TestHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "TestHandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "HelloHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "HelloHandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "DoubleHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "DoubleHandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383263373438373461653835613539366164383861646333393163356664376664623864386638356532326365643233336565383535333964a460a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656067776562736974657468747470733a2f2f63617264616e6f2e6f72672f6c446f75626c6548616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656c446f75626c6548616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6b48656c6c6f48616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656b48656c6c6f48616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6a5465737448616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656a5465737448616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f	108
2	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "handle2": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a26768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f6768616e646c6532a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	110
3	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	115
4	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	116
5	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	118
6	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	120
7	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"NFT-001": {"name": "One", "image": ["ipfs://some_hash1"], "version": "1.0"}, "NFT-002": {"name": "Two", "image": ["ipfs://some_hash2"], "version": "1.0"}, "NFT-files": {"id": "1", "name": "NFT with files", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": ["ipfs://somehash"], "version": "1.0", "mediaType": "image/png", "description": ["NFT with different types of files"]}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a3674e46542d303031a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65634f6e656776657273696f6e63312e30674e46542d303032a365696d6167658171697066733a2f2f736f6d655f6861736832646e616d656354776f6776657273696f6e63312e30694e46542d66696c6573a76b6465736372697074696f6e8178214e4654207769746820646966666572656e74207479706573206f662066696c65736566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e79626964613165696d616765816f697066733a2f2f736f6d6568617368696d656469615479706569696d6167652f706e67646e616d656e4e465420776974682066696c65736776657273696f6e63312e30	123
9	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"4349502d303032352d76312d686578": {"name": "CIP-0025-v1-hex", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1781e343334393530326433303330333233353264373633313264363836353738a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656f4349502d303032352d76312d6865786776657273696f6e63312e30	126
10	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"CIP-0025-v1-utf8": {"name": "CIP-0025-v1-utf8", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1704349502d303032352d76312d75746638a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65704349502d303032352d76312d757466386776657273696f6e63312e30	127
11	721	{"0x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"0x4349502d303032352d7632": {"name": "CIP-0025-v2", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a1581c17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029a14b4349502d303032352d7632a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656b4349502d303032352d76326776657273696f6e63312e30	128
12	123	"1234"	\\xa1187b6431323334	144
\.


--
-- Data for Name: tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_out (id, tx_id, index, address, address_raw, address_has_script, payment_cred, stake_address_id, value, data_hash, inline_datum_id, reference_script_id) FROM stdin;
1	1	0	5oP9ib6ym3XYajVJnNUQBG1H7jWHLms96tQcGjaeDbSHMfPAGd8s4BUvktsvP9pa4m	\\x82d818582683581c14490d8d69b9eba346e9fb7376ddaa0b0f1e0965027a20aa9c2abd4aa10243190378001a1b5d1956	f	\N	\N	910909092	\N	\N	\N
2	2	0	5oP9ib6ym3XZ5ZSFFtA6WFvQm8Yjgw6GQtuwYXFApHGM9qqUyBP5NTStmbwzwrw81W	\\x82d818582683581c1e49c20818f24e9973425069e0cd97a4838bd122ef74da8617eabc77a10243190378001a32c8b999	f	\N	\N	910909092	\N	\N	\N
3	3	0	5oP9ib6ym3XZfCssGkxsijwEhPrJkknDS3NgWjiEwSTVyBp5EneGJaeZJ2K5vYxge2	\\x82d818582683581c29f6874a1b26f44fd635b4fdf9b4080ad0a1160385b2410f17d3f57fa10243190378001ab74f5f87	f	\N	\N	910909092	\N	\N	\N
4	4	0	5oP9ib6ym3XdNNdphNpAcykmJQHJumE811jCLUKSLkX42a7ZWfx6r1nQWYGEt24bcF	\\x82d818582683581c74a0283412b5fc0b992a216f40af1b8acb1ceb91f27af192a9f0a725a10243190378001a1e3e74ec	f	\N	\N	910909092	\N	\N	\N
5	5	0	5oP9ib6ym3Xe2WXZ9bfot4kp5GjVfL6oswnCbnAKrqJcVzmL6PLGrrs7moBGBMHxt7	\\x82d818582683581c81dbd34d7f32345472823a05ee8bc59bb1a2b7ff5e3c7531fa245856a10243190378001a70c38310	f	\N	\N	910909092	\N	\N	\N
6	6	0	5oP9ib6ym3XfDTgkDE7nza6q41swZbPVHAYMFHjvfHVAc6DL7TbCnAFPpwECc9d7A9	\\x82d818582683581c99c8d18246fb4dc68ec14fdb7d86c7351382289f863199aa50929d7da10243190378001a22de9d2a	f	\N	\N	910909092	\N	\N	\N
7	7	0	5oP9ib6ym3XfsArn8aEK4L6Q47PrLjMiPwfnwKMZK4Y2yxubTWKQhmBnmdD7ibjLVj	\\x82d818582683581ca6dea0c0f0fd1ebfbf4aad404a1c768beaeb212641d01e5158576fc5a10243190378001a5b6600fe	f	\N	\N	910909092	\N	\N	\N
8	8	0	5oP9ib6ym3Xg7XDhdKJ8VSurhKFqZoJ9ZcCmtXYQR8KyKfmZHaFKnXu1SUtR9oNHos	\\x82d818582683581cabd972724669f94487f7af82110f5e2da944319ce69e12b64e59325da10243190378001a31ee3a86	f	\N	\N	910909092	\N	\N	\N
9	9	0	5oP9ib6ym3XhQngpzR1kGTckWKNoA9s29qnz6g67htudxtbqKL5msrFGtAeqkavBTA	\\x82d818582683581cc5f777edb87baf827864e1b9efb25f4a27a30ba54f0d9f50cd151394a10243190378001a7ce0880d	f	\N	\N	910909092	\N	\N	\N
10	10	0	5oP9ib6ym3XiR2Pq7ihmFJrNHzKdE5fwJ3Nvdfkqa3wPtfvtY75GPmVUu3j5C8nbvy	\\x82d818582683581cda2caa270decdd8d05235a42e645c4a1f6feec2ba8e6ce90877cd3aca10243190378001aa4b7555a	f	\N	\N	910909092	\N	\N	\N
11	11	0	5oP9ib6ym3XjCY4aVgxaomEAyQzky15n6GnoN3EMRuz8xT687y8uLoii2wwSCePEKZ	\\x82d818582683581ce9f78097a654263f882132d56fce0bce0b97f3a74ab89da8582905e1a10243190378001aa1978ee8	f	\N	\N	910909092	\N	\N	\N
12	12	0	addr_test1vz7v0y498gzvwx9vqlpvawkws6eux4hrtqcsx4hzqsmwncgyj7xj6	\\x60bcc792a53a04c718ac07c2cebace86b3c356e358310356e20436e9e1	f	\\xbcc792a53a04c718ac07c2cebace86b3c356e358310356e20436e9e1	\N	3681818181818190	\N	\N	\N
13	13	0	addr_test1vqj2xdkntq743jajvxv3d9c4fwlkltauzpu2mwnde4dg9ycnv3err	\\x6024a336d3583d58cbb261991697154bbf6fafbc1078adba6dcd5a8293	f	\\x24a336d3583d58cbb261991697154bbf6fafbc1078adba6dcd5a8293	\N	3681818181818181	\N	\N	\N
14	14	0	addr_test1vrmrjl9p0tahsxd47n4ll8ny0jhaqn5dt6njqk6el9sm5ycq9kcn9	\\x60f6397ca17afb7819b5f4ebff9e647cafd04e8d5ea7205b59f961ba13	f	\\xf6397ca17afb7819b5f4ebff9e647cafd04e8d5ea7205b59f961ba13	\N	3681818181818181	\N	\N	\N
15	15	0	addr_test1vr09qcuvtc9q5jasy6ddagq74zgzgwjhxqlm0ewv98plj5cpsql4m	\\x60de50638c5e0a0a4bb0269adea01ea890243a57303fb7e5cc29c3f953	f	\\xde50638c5e0a0a4bb0269adea01ea890243a57303fb7e5cc29c3f953	\N	3681818181818181	\N	\N	\N
16	16	0	addr_test1qru0kzpa7qjkt52rdkqm6rwu7atfpcpdvelxxt59m6x63rvxpft8unnjvyw9xxk9gu7r6kjree3t6ef4rj0yyqyvs9esmpn227	\\x00f8fb083df02565d1436d81bd0ddcf75690e02d667e632e85de8da88d860a567e4e72611c531ac5473c3d5a43ce62bd65351c9e42008c8173	f	\\xf8fb083df02565d1436d81bd0ddcf75690e02d667e632e85de8da88d	\N	3681818181818181	\N	\N	\N
17	17	0	addr_test1qrj8g8nwhx8wjs6fw84t0n0fz0r8jy6rsn42s8p37yzc98tzpv6rk5t8cxgagkv6vwc2c3ju9m35dp249uul9c063dws2qsunc	\\x00e4741e6eb98ee9434971eab7cde913c679134384eaa81c31f105829d620b343b5167c191d4599a63b0ac465c2ee34685552f39f2e1fa8b5d	f	\\xe4741e6eb98ee9434971eab7cde913c679134384eaa81c31f105829d	\N	3681818181818181	\N	\N	\N
18	18	0	addr_test1vqkjgdpqapfs8kldeldca28se3nnxn6jsjhy9ch4l2du62qwxl6t2	\\x602d243420e85303dbedcfdb8ea8f0cc67334f5284ae42e2f5fa9bcd28	f	\\x2d243420e85303dbedcfdb8ea8f0cc67334f5284ae42e2f5fa9bcd28	\N	3681818181818181	\N	\N	\N
19	19	0	addr_test1qzkcm4daxw9lnpv4tcqg3m00r8a9nxqqwg46zc8vjlfrxwu9d52kskv9kdf26vy9tq6v26zzakr0lxyc9wm7fmtk55rqmh4nj0	\\x00ad8dd5bd338bf985955e0088edef19fa599800722ba160ec97d2333b856d15685985b352ad30855834c56842ed86ff98982bb7e4ed76a506	f	\\xad8dd5bd338bf985955e0088edef19fa599800722ba160ec97d2333b	\N	3681818181818181	\N	\N	\N
20	20	0	addr_test1vqwgudwlw640uz7h8ce7jhqnzgpcu29zmk7hv53nnhg8t6qekr35t	\\x601c8e35df76aafe0bd73e33e95c1312038e28a2ddbd7652339dd075e8	f	\\x1c8e35df76aafe0bd73e33e95c1312038e28a2ddbd7652339dd075e8	\N	3681818181818181	\N	\N	\N
21	21	0	addr_test1vzt69z4ld8pj627rx0f5zgm462t3ccah3zmzv7ysjt9dz8gvv5dta	\\x6097a28abf69c32d2bc333d3412375d2971c63b788b626789092cad11d	f	\\x97a28abf69c32d2bc333d3412375d2971c63b788b626789092cad11d	\N	3681818181818181	\N	\N	\N
22	22	0	addr_test1qz5awqtwe0adltj0jnd7vncw4r3hlezu0d2pnts7yuh9tvx6ylme8eshwjh7jk9ss83zam0gh800dhvtq240svynv3fsxqkz63	\\x00a9d7016ecbfadfae4f94dbe64f0ea8e37fe45c7b5419ae1e272e55b0da27f793e61774afe958b081e22eede8b9def6dd8b02aaf830936453	f	\\xa9d7016ecbfadfae4f94dbe64f0ea8e37fe45c7b5419ae1e272e55b0	\N	3681818181818181	\N	\N	\N
23	23	0	addr_test1qpke3se9tduv03ut6uec6kukfu7k3js95n57ec4qgdws0dfv9l5ekga7ecnd8emj6n8dk4w59nmsezwuxc2faq5frz7s20eg49	\\x006d98c3255b78c7c78bd7338d5b964f3d68ca05a4e9ece2a0435d07b52c2fe99b23bece26d3e772d4cedb55d42cf70c89dc36149e828918bd	f	\\x6d98c3255b78c7c78bd7338d5b964f3d68ca05a4e9ece2a0435d07b5	\N	3681818181818181	\N	\N	\N
24	24	0	addr_test1vzfe02k4gmqlatrjsug0thufhu8v83dujptf0lghufh7gyq3yhpww	\\x609397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	f	\\x9397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	\N	3681818181818181	\N	\N	\N
25	25	0	addr_test1qpht6gx08mt3s576jpzqfmy7rag69886xrta443cx4ddlxaed9hezkda7g5jlxjanu6nphwuyf82wpg76mwqlkckzags726t04	\\x006ebd20cf3ed71853da904404ec9e1f51a29cfa30d7dad638355adf9bb9696f9159bdf2292f9a5d9f3530dddc224ea7051ed6dc0fdb161751	f	\\x6ebd20cf3ed71853da904404ec9e1f51a29cfa30d7dad638355adf9b	\N	3681818181818181	\N	\N	\N
26	26	0	addr_test1vq0uwxh8v3aduk9a0zy7xjyqzumxrgtjyc2h4u03l8nrpkgugzgnp	\\x601fc71ae7647ade58bd7889e34880173661a17226157af1f1f9e630d9	f	\\x1fc71ae7647ade58bd7889e34880173661a17226157af1f1f9e630d9	\N	3681818181818181	\N	\N	\N
27	27	0	addr_test1qqzphcd0zupnkl8f4yuxfqgju28wnpjc7w80n0d4vse9jthqp89csxgckjy08zyzclj8xj76x0p6fjr2qlmqzw4pd9aq8emqxd	\\x00041be1af17033b7ce9a938648112e28ee98658f38ef9bdb56432592ee009cb881918b488f38882c7e4734bda33c3a4c86a07f6013aa1697a	f	\\x041be1af17033b7ce9a938648112e28ee98658f38ef9bdb56432592e	\N	3681818181818181	\N	\N	\N
28	28	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681818181818181	\N	\N	\N
29	29	0	addr_test1qptrfrpckqasyytznt9dgl5tgg9e9yc78h8s8umcw2te46y7jq6zmezwk2lu94j8cxm8twkwrwyvkxeryan3shwak6eqzxf8hl	\\x0056348c38b03b0211629acad47e8b420b92931e3dcf03f37872979ae89e90342de44eb2bfc2d647c1b675bace1b88cb1b232767185dddb6b2	f	\\x56348c38b03b0211629acad47e8b420b92931e3dcf03f37872979ae8	\N	3681818181818181	\N	\N	\N
30	30	0	addr_test1qr2ght47cyqs8pdk7wzehj5zqfzahk85skh3rglp2eymsqklpf5m6guj2sgkyfrz0rx66jwvq7z0ge7yldzdvfdg96qswkfhcr	\\x00d48baebec1010385b6f3859bca820245dbd8f485af11a3e15649b802df0a69bd2392541162246278cdad49cc0784f467c4fb44d625a82e81	f	\\xd48baebec1010385b6f3859bca820245dbd8f485af11a3e15649b802	\N	3681818181818181	\N	\N	\N
31	31	0	addr_test1vr6664yjew9fdel5kwz8wn8fs8vkyw9rhtszxcylgsardtg8lrxft	\\x60f5ad5492cb8a96e7f4b384774ce981d96238a3bae023609f443a36ad	f	\\xf5ad5492cb8a96e7f4b384774ce981d96238a3bae023609f443a36ad	\N	3681818181818181	\N	\N	\N
32	32	0	addr_test1qz9nqkq5vgv7xwqe7rlxrmew029fg8vu5wcfdhvuvq8kn39px7n02xu67wj0t80r9dtlrjzyr0j5xcrm4g5ejel0vs0q4c7nsp	\\x008b3058146219e33819f0fe61ef2e7a8a941d9ca3b096dd9c600f69c4a137a6f51b9af3a4f59de32b57f1c8441be543607baa299967ef641e	f	\\x8b3058146219e33819f0fe61ef2e7a8a941d9ca3b096dd9c600f69c4	\N	3681818181818181	\N	\N	\N
33	33	0	addr_test1qz69lrseek2zmdetsseq9ryupv6swkcrxkqn5ajadkyy5wr8rv9m7j8aeradj4hqralqpwzksh3ynehzf9x4h2auc0wsewasa4	\\x00b45f8e19cd942db72b8432028c9c0b35075b0335813a765d6d884a38671b0bbf48fdc8fad956e01f7e00b85685e249e6e2494d5babbcc3dd	f	\\xb45f8e19cd942db72b8432028c9c0b35075b0335813a765d6d884a38	\N	3681818181818190	\N	\N	\N
34	35	0	addr_test1qz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sn26u70wj9atzdyk7753s425944urgjgpcv0gv42mejp7gxq6efgkz	\\x00a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d5ae79ee917ab13496f7a91855542d6bc1a2480e18f432aade641f20c	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	22	500000000	\N	\N	\N
35	35	1	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681817681651228	\N	\N	\N
36	36	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681817681473231	\N	\N	\N
37	37	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681817681293914	\N	\N	\N
72	66	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681814878327629	\N	\N	\N
38	38	0	addr_test1qpht6gx08mt3s576jpzqfmy7rag69886xrta443cx4ddlxaed9hezkda7g5jlxjanu6nphwuyf82wpg76mwqlkckzags726t04	\\x006ebd20cf3ed71853da904404ec9e1f51a29cfa30d7dad638355adf9bb9696f9159bdf2292f9a5d9f3530dddc224ea7051ed6dc0fdb161751	f	\\x6ebd20cf3ed71853da904404ec9e1f51a29cfa30d7dad638355adf9b	6	3681818181637632	\N	\N	\N
39	39	0	addr_test1qpht6gx08mt3s576jpzqfmy7rag69886xrta443cx4ddlxaed9hezkda7g5jlxjanu6nphwuyf82wpg76mwqlkckzags726t04	\\x006ebd20cf3ed71853da904404ec9e1f51a29cfa30d7dad638355adf9bb9696f9159bdf2292f9a5d9f3530dddc224ea7051ed6dc0fdb161751	f	\\x6ebd20cf3ed71853da904404ec9e1f51a29cfa30d7dad638355adf9b	6	3681818181443619	\N	\N	\N
40	40	0	addr_test1qz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngv27j8eh77rv3sgwc38z620dp0j54ll7mx820x5n28qtfq6cu9dm	\\x00a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d0c57a47cdfde1b23043b1138b4a7b42f952bfffb663a9e6a4d4702d2	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	20	600000000	\N	\N	\N
41	40	1	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681817081126961	\N	\N	\N
42	41	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681817080948964	\N	\N	\N
43	42	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681817080769647	\N	\N	\N
44	43	0	addr_test1qz9nqkq5vgv7xwqe7rlxrmew029fg8vu5wcfdhvuvq8kn39px7n02xu67wj0t80r9dtlrjzyr0j5xcrm4g5ejel0vs0q4c7nsp	\\x008b3058146219e33819f0fe61ef2e7a8a941d9ca3b096dd9c600f69c4a137a6f51b9af3a4f59de32b57f1c8441be543607baa299967ef641e	f	\\x8b3058146219e33819f0fe61ef2e7a8a941d9ca3b096dd9c600f69c4	10	3681818181637632	\N	\N	\N
45	44	0	addr_test1qz9nqkq5vgv7xwqe7rlxrmew029fg8vu5wcfdhvuvq8kn39px7n02xu67wj0t80r9dtlrjzyr0j5xcrm4g5ejel0vs0q4c7nsp	\\x008b3058146219e33819f0fe61ef2e7a8a941d9ca3b096dd9c600f69c4a137a6f51b9af3a4f59de32b57f1c8441be543607baa299967ef641e	f	\\x8b3058146219e33819f0fe61ef2e7a8a941d9ca3b096dd9c600f69c4	10	3681818181446391	\N	\N	\N
46	45	0	addr_test1qz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sntyvsanufpkgdpdex7f4qtckg3a8xyn9rjmnsggh80detyqw3cxmm	\\x00a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d64643b3e24364342dc9bc9a8178b223d3989328e5b9c108b9dedcac8	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	21	200000000	\N	\N	\N
47	45	1	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681816880602694	\N	\N	\N
48	46	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681816880424697	\N	\N	\N
49	47	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681816880245380	\N	\N	\N
50	48	0	addr_test1qru0kzpa7qjkt52rdkqm6rwu7atfpcpdvelxxt59m6x63rvxpft8unnjvyw9xxk9gu7r6kjree3t6ef4rj0yyqyvs9esmpn227	\\x00f8fb083df02565d1436d81bd0ddcf75690e02d667e632e85de8da88d860a567e4e72611c531ac5473c3d5a43ce62bd65351c9e42008c8173	f	\\xf8fb083df02565d1436d81bd0ddcf75690e02d667e632e85de8da88d	1	3681818181637632	\N	\N	\N
51	49	0	addr_test1qru0kzpa7qjkt52rdkqm6rwu7atfpcpdvelxxt59m6x63rvxpft8unnjvyw9xxk9gu7r6kjree3t6ef4rj0yyqyvs9esmpn227	\\x00f8fb083df02565d1436d81bd0ddcf75690e02d667e632e85de8da88d860a567e4e72611c531ac5473c3d5a43ce62bd65351c9e42008c8173	f	\\xf8fb083df02565d1436d81bd0ddcf75690e02d667e632e85de8da88d	1	3681818181443619	\N	\N	\N
52	50	0	addr_test1qz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9snwj887sazpsvksnkkqq8g4c8lf9u6rtkwvdvj55wxp3mleqpld9qe	\\x00a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584dd239fd0e883065a13b58003a2b83fd25e686bb398d64a9471831dff2	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	15	500000000	\N	\N	\N
53	50	1	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681816380078427	\N	\N	\N
54	51	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681816379900430	\N	\N	\N
55	52	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681816379721113	\N	\N	\N
56	53	0	addr_test1qr2ght47cyqs8pdk7wzehj5zqfzahk85skh3rglp2eymsqklpf5m6guj2sgkyfrz0rx66jwvq7z0ge7yldzdvfdg96qswkfhcr	\\x00d48baebec1010385b6f3859bca820245dbd8f485af11a3e15649b802df0a69bd2392541162246278cdad49cc0784f467c4fb44d625a82e81	f	\\xd48baebec1010385b6f3859bca820245dbd8f485af11a3e15649b802	9	3681818181637632	\N	\N	\N
57	54	0	addr_test1qr2ght47cyqs8pdk7wzehj5zqfzahk85skh3rglp2eymsqklpf5m6guj2sgkyfrz0rx66jwvq7z0ge7yldzdvfdg96qswkfhcr	\\x00d48baebec1010385b6f3859bca820245dbd8f485af11a3e15649b802df0a69bd2392541162246278cdad49cc0784f467c4fb44d625a82e81	f	\\xd48baebec1010385b6f3859bca820245dbd8f485af11a3e15649b802	9	3681818181443619	\N	\N	\N
58	55	0	addr_test1qz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngyv8l8ylurszwcwhjhezxtwxf6k37dxmfa4edlfu7hwazqwqzkgd	\\x00a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d0461fe727f83809d875e57c88cb7193ab47cd36d3dae5bf4f3d77744	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	14	500000000	\N	\N	\N
59	55	1	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681815879554160	\N	\N	\N
60	56	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681815879376163	\N	\N	\N
61	57	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681815879196846	\N	\N	\N
62	58	0	addr_test1qqzphcd0zupnkl8f4yuxfqgju28wnpjc7w80n0d4vse9jthqp89csxgckjy08zyzclj8xj76x0p6fjr2qlmqzw4pd9aq8emqxd	\\x00041be1af17033b7ce9a938648112e28ee98658f38ef9bdb56432592ee009cb881918b488f38882c7e4734bda33c3a4c86a07f6013aa1697a	f	\\x041be1af17033b7ce9a938648112e28ee98658f38ef9bdb56432592e	7	3681818181637632	\N	\N	\N
63	59	0	addr_test1qqzphcd0zupnkl8f4yuxfqgju28wnpjc7w80n0d4vse9jthqp89csxgckjy08zyzclj8xj76x0p6fjr2qlmqzw4pd9aq8emqxd	\\x00041be1af17033b7ce9a938648112e28ee98658f38ef9bdb56432592ee009cb881918b488f38882c7e4734bda33c3a4c86a07f6013aa1697a	f	\\x041be1af17033b7ce9a938648112e28ee98658f38ef9bdb56432592e	7	3681818181443619	\N	\N	\N
64	60	0	addr_test1qz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sn2ca9wex5vc3excg2fjpdjxam2a6sksnnq3huymjx5ntklquwvl7r	\\x00a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d58e95d9351988e4d8429320b646eed5dd42d09cc11bf09b91a935dbe	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	17	500000000	\N	\N	\N
65	60	1	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681815379029893	\N	\N	\N
66	61	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681815378851896	\N	\N	\N
67	62	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681815378672579	\N	\N	\N
68	63	0	addr_test1qpke3se9tduv03ut6uec6kukfu7k3js95n57ec4qgdws0dfv9l5ekga7ecnd8emj6n8dk4w59nmsezwuxc2faq5frz7s20eg49	\\x006d98c3255b78c7c78bd7338d5b964f3d68ca05a4e9ece2a0435d07b52c2fe99b23bece26d3e772d4cedb55d42cf70c89dc36149e828918bd	f	\\x6d98c3255b78c7c78bd7338d5b964f3d68ca05a4e9ece2a0435d07b5	5	3681818181637632	\N	\N	\N
69	64	0	addr_test1qpke3se9tduv03ut6uec6kukfu7k3js95n57ec4qgdws0dfv9l5ekga7ecnd8emj6n8dk4w59nmsezwuxc2faq5frz7s20eg49	\\x006d98c3255b78c7c78bd7338d5b964f3d68ca05a4e9ece2a0435d07b52c2fe99b23bece26d3e772d4cedb55d42cf70c89dc36149e828918bd	f	\\x6d98c3255b78c7c78bd7338d5b964f3d68ca05a4e9ece2a0435d07b5	5	3681818181443619	\N	\N	\N
70	65	0	addr_test1qz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9snwwkzgugse7ksd76x9vplaz2se48urzxcd2vfdyvq0gr5pqrgys3l	\\x00a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584dceb091c4433eb41bed18ac0ffa2543353f062361aa625a4601e81d02	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	12	500000000	\N	\N	\N
71	65	1	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681814878505626	\N	\N	\N
73	67	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681814878148312	\N	\N	\N
74	68	0	addr_test1qz5awqtwe0adltj0jnd7vncw4r3hlezu0d2pnts7yuh9tvx6ylme8eshwjh7jk9ss83zam0gh800dhvtq240svynv3fsxqkz63	\\x00a9d7016ecbfadfae4f94dbe64f0ea8e37fe45c7b5419ae1e272e55b0da27f793e61774afe958b081e22eede8b9def6dd8b02aaf830936453	f	\\xa9d7016ecbfadfae4f94dbe64f0ea8e37fe45c7b5419ae1e272e55b0	4	3681818181637632	\N	\N	\N
75	69	0	addr_test1qz5awqtwe0adltj0jnd7vncw4r3hlezu0d2pnts7yuh9tvx6ylme8eshwjh7jk9ss83zam0gh800dhvtq240svynv3fsxqkz63	\\x00a9d7016ecbfadfae4f94dbe64f0ea8e37fe45c7b5419ae1e272e55b0da27f793e61774afe958b081e22eede8b9def6dd8b02aaf830936453	f	\\xa9d7016ecbfadfae4f94dbe64f0ea8e37fe45c7b5419ae1e272e55b0	4	3681818181443619	\N	\N	\N
76	70	0	addr_test1qz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sn0adnanzw5pmwrr0yq2phj6kqetwxcy0yucdhuqa079lups66wyur	\\x00a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584dfd6cfb313a81db8637900a0de5ab032b71b04793986df80ebfc5ff03	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	19	300000000	\N	\N	\N
77	70	1	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681814577981359	\N	\N	\N
78	71	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681814577803362	\N	\N	\N
79	72	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681814577624045	\N	\N	\N
80	73	0	addr_test1qzkcm4daxw9lnpv4tcqg3m00r8a9nxqqwg46zc8vjlfrxwu9d52kskv9kdf26vy9tq6v26zzakr0lxyc9wm7fmtk55rqmh4nj0	\\x00ad8dd5bd338bf985955e0088edef19fa599800722ba160ec97d2333b856d15685985b352ad30855834c56842ed86ff98982bb7e4ed76a506	f	\\xad8dd5bd338bf985955e0088edef19fa599800722ba160ec97d2333b	3	3681818181637632	\N	\N	\N
81	74	0	addr_test1qzkcm4daxw9lnpv4tcqg3m00r8a9nxqqwg46zc8vjlfrxwu9d52kskv9kdf26vy9tq6v26zzakr0lxyc9wm7fmtk55rqmh4nj0	\\x00ad8dd5bd338bf985955e0088edef19fa599800722ba160ec97d2333b856d15685985b352ad30855834c56842ed86ff98982bb7e4ed76a506	f	\\xad8dd5bd338bf985955e0088edef19fa599800722ba160ec97d2333b	3	3681818181446391	\N	\N	\N
82	75	0	addr_test1qzkcm4daxw9lnpv4tcqg3m00r8a9nxqqwg46zc8vjlfrxwu9d52kskv9kdf26vy9tq6v26zzakr0lxyc9wm7fmtk55rqmh4nj0	\\x00ad8dd5bd338bf985955e0088edef19fa599800722ba160ec97d2333b856d15685985b352ad30855834c56842ed86ff98982bb7e4ed76a506	f	\\xad8dd5bd338bf985955e0088edef19fa599800722ba160ec97d2333b	3	3681818181265842	\N	\N	\N
83	76	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681814577439800	\N	\N	\N
84	77	0	addr_test1qz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sn0mzsz66ek9efc0zrfv7unv723azf6zmxwwh5avv4wh8r0s74qdw8	\\x00a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584dfb1405ad66c5ca70f10d2cf726cf2a3d12742d99cebd3ac655d738df	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	16	300000000	\N	\N	\N
85	77	1	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681814277272847	\N	\N	\N
86	78	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681814277094850	\N	\N	\N
87	79	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681814276915533	\N	\N	\N
88	80	0	addr_test1qrj8g8nwhx8wjs6fw84t0n0fz0r8jy6rsn42s8p37yzc98tzpv6rk5t8cxgagkv6vwc2c3ju9m35dp249uul9c063dws2qsunc	\\x00e4741e6eb98ee9434971eab7cde913c679134384eaa81c31f105829d620b343b5167c191d4599a63b0ac465c2ee34685552f39f2e1fa8b5d	f	\\xe4741e6eb98ee9434971eab7cde913c679134384eaa81c31f105829d	2	3681818181637632	\N	\N	\N
89	81	0	addr_test1qrj8g8nwhx8wjs6fw84t0n0fz0r8jy6rsn42s8p37yzc98tzpv6rk5t8cxgagkv6vwc2c3ju9m35dp249uul9c063dws2qsunc	\\x00e4741e6eb98ee9434971eab7cde913c679134384eaa81c31f105829d620b343b5167c191d4599a63b0ac465c2ee34685552f39f2e1fa8b5d	f	\\xe4741e6eb98ee9434971eab7cde913c679134384eaa81c31f105829d	2	3681818181446391	\N	\N	\N
90	82	0	addr_test1qrj8g8nwhx8wjs6fw84t0n0fz0r8jy6rsn42s8p37yzc98tzpv6rk5t8cxgagkv6vwc2c3ju9m35dp249uul9c063dws2qsunc	\\x00e4741e6eb98ee9434971eab7cde913c679134384eaa81c31f105829d620b343b5167c191d4599a63b0ac465c2ee34685552f39f2e1fa8b5d	f	\\xe4741e6eb98ee9434971eab7cde913c679134384eaa81c31f105829d	2	3681818181265842	\N	\N	\N
91	83	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681814276731288	\N	\N	\N
92	84	0	addr_test1qz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9snf6yx828a0h6rjqxr7sm6enlcl24tkcagfuekxtqqex2cqq44vawg	\\x00a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d3a218ea3f5f7d0e4030fd0deb33fe3eaaaed8ea13ccd8cb003265600	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	13	500000000	\N	\N	\N
93	84	1	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681813776564335	\N	\N	\N
94	85	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681813776386338	\N	\N	\N
95	86	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681813776207021	\N	\N	\N
96	87	0	addr_test1qptrfrpckqasyytznt9dgl5tgg9e9yc78h8s8umcw2te46y7jq6zmezwk2lu94j8cxm8twkwrwyvkxeryan3shwak6eqzxf8hl	\\x0056348c38b03b0211629acad47e8b420b92931e3dcf03f37872979ae89e90342de44eb2bfc2d647c1b675bace1b88cb1b232767185dddb6b2	f	\\x56348c38b03b0211629acad47e8b420b92931e3dcf03f37872979ae8	8	3681818181637632	\N	\N	\N
97	88	0	addr_test1qptrfrpckqasyytznt9dgl5tgg9e9yc78h8s8umcw2te46y7jq6zmezwk2lu94j8cxm8twkwrwyvkxeryan3shwak6eqzxf8hl	\\x0056348c38b03b0211629acad47e8b420b92931e3dcf03f37872979ae89e90342de44eb2bfc2d647c1b675bace1b88cb1b232767185dddb6b2	f	\\x56348c38b03b0211629acad47e8b420b92931e3dcf03f37872979ae8	8	3681818181443575	\N	\N	\N
98	89	0	addr_test1qptrfrpckqasyytznt9dgl5tgg9e9yc78h8s8umcw2te46y7jq6zmezwk2lu94j8cxm8twkwrwyvkxeryan3shwak6eqzxf8hl	\\x0056348c38b03b0211629acad47e8b420b92931e3dcf03f37872979ae89e90342de44eb2bfc2d647c1b675bace1b88cb1b232767185dddb6b2	f	\\x56348c38b03b0211629acad47e8b420b92931e3dcf03f37872979ae8	8	3681818181263026	\N	\N	\N
99	90	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681813776022776	\N	\N	\N
100	91	0	addr_test1qz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9snfh8pjyx4xyuvk4ad4gdlfrrslmvhpxpk04xzdr8qhv3jxswrwk8c	\\x00a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d3738644354c4e32d5eb6a86fd231c3fb65c260d9f5309a3382ec8c8d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	18	500000000	\N	\N	\N
101	91	1	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681813275855823	\N	\N	\N
102	92	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681813275677826	\N	\N	\N
103	93	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681813275498509	\N	\N	\N
104	94	0	addr_test1qz69lrseek2zmdetsseq9ryupv6swkcrxkqn5ajadkyy5wr8rv9m7j8aeradj4hqralqpwzksh3ynehzf9x4h2auc0wsewasa4	\\x00b45f8e19cd942db72b8432028c9c0b35075b0335813a765d6d884a38671b0bbf48fdc8fad956e01f7e00b85685e249e6e2494d5babbcc3dd	f	\\xb45f8e19cd942db72b8432028c9c0b35075b0335813a765d6d884a38	11	3681818181637641	\N	\N	\N
105	95	0	addr_test1qz69lrseek2zmdetsseq9ryupv6swkcrxkqn5ajadkyy5wr8rv9m7j8aeradj4hqralqpwzksh3ynehzf9x4h2auc0wsewasa4	\\x00b45f8e19cd942db72b8432028c9c0b35075b0335813a765d6d884a38671b0bbf48fdc8fad956e01f7e00b85685e249e6e2494d5babbcc3dd	f	\\xb45f8e19cd942db72b8432028c9c0b35075b0335813a765d6d884a38	11	3681818181443584	\N	\N	\N
106	96	0	addr_test1qz69lrseek2zmdetsseq9ryupv6swkcrxkqn5ajadkyy5wr8rv9m7j8aeradj4hqralqpwzksh3ynehzf9x4h2auc0wsewasa4	\\x00b45f8e19cd942db72b8432028c9c0b35075b0335813a765d6d884a38671b0bbf48fdc8fad956e01f7e00b85685e249e6e2494d5babbcc3dd	f	\\xb45f8e19cd942db72b8432028c9c0b35075b0335813a765d6d884a38	11	3681818181263035	\N	\N	\N
107	97	0	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3681813275314264	\N	\N	\N
108	98	0	addr_test1wpnlxv2xv9a9ucvnvzqakwepzl9ltx7jzgm53av2e9ncv4sysemm8	\\x7067f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	t	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	\N	100000000	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	\N	\N
109	98	1	addr_test1vzfe02k4gmqlatrjsug0thufhu8v83dujptf0lghufh7gyq3yhpww	\\x609397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	f	\\x9397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	\N	3681818081650832	\N	\N	\N
110	99	0	addr_test1vzfe02k4gmqlatrjsug0thufhu8v83dujptf0lghufh7gyq3yhpww	\\x609397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	f	\\x9397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	\N	99828910	\N	\N	\N
111	100	0	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	\\x702618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	100000000	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	2	\N
112	100	1	addr_test1vzfe02k4gmqlatrjsug0thufhu8v83dujptf0lghufh7gyq3yhpww	\\x609397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	f	\\x9397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	\N	3681817981484759	\N	\N	\N
113	101	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	2
114	101	1	addr_test1vzfe02k4gmqlatrjsug0thufhu8v83dujptf0lghufh7gyq3yhpww	\\x609397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	f	\\x9397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	\N	3681817881314374	\N	\N	\N
115	102	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	3
116	102	1	addr_test1vzfe02k4gmqlatrjsug0thufhu8v83dujptf0lghufh7gyq3yhpww	\\x609397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	f	\\x9397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	\N	3681817781146585	\N	\N	\N
117	103	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	1
118	103	1	addr_test1vzfe02k4gmqlatrjsug0thufhu8v83dujptf0lghufh7gyq3yhpww	\\x609397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	f	\\x9397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	\N	3681817680979940	\N	\N	\N
119	104	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	4
120	104	1	addr_test1vzfe02k4gmqlatrjsug0thufhu8v83dujptf0lghufh7gyq3yhpww	\\x609397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	f	\\x9397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	\N	3681817580717067	\N	\N	\N
121	105	0	addr_test1wzem0yuxjqyrmzvrsr8xfqhumyy555ngyjxw7wrg2pav90q8cagu2	\\x70b3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	t	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	\N	100000000	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	3	\N
122	105	1	addr_test1vzfe02k4gmqlatrjsug0thufhu8v83dujptf0lghufh7gyq3yhpww	\\x609397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	f	\\x9397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	\N	3681817480550950	\N	\N	\N
123	106	0	addr_test1vzfe02k4gmqlatrjsug0thufhu8v83dujptf0lghufh7gyq3yhpww	\\x609397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	f	\\x9397aad546c1feac728710f5df89bf0ec3c5bc905697fd17e26fe410	\N	3681817580223603	\N	\N	\N
124	107	0	addr_test1qqen0wpmhg7fhkus45lyv4wju26cecgu6avplrnm6dgvuk6qel5hu3u3q0fht53ly97yx95hkt56j37ch07pesf6s4pqh5gd4e	\\x003337b83bba3c9bdb90ad3e4655d2e2b58ce11cd7581f8e7bd350ce5b40cfe97e479103d375d23f217c431697b2e9a947d8bbfc1cc13a8542	f	\\x3337b83bba3c9bdb90ad3e4655d2e2b58ce11cd7581f8e7bd350ce5b	45	10000000	\N	\N	\N
125	107	1	addr_test1vqj2xdkntq743jajvxv3d9c4fwlkltauzpu2mwnde4dg9ycnv3err	\\x6024a336d3583d58cbb261991697154bbf6fafbc1078adba6dcd5a8293	f	\\x24a336d3583d58cbb261991697154bbf6fafbc1078adba6dcd5a8293	\N	3681818171642252	\N	\N	\N
126	108	0	addr_test1qqen0wpmhg7fhkus45lyv4wju26cecgu6avplrnm6dgvuk6qel5hu3u3q0fht53ly97yx95hkt56j37ch07pesf6s4pqh5gd4e	\\x003337b83bba3c9bdb90ad3e4655d2e2b58ce11cd7581f8e7bd350ce5b40cfe97e479103d375d23f217c431697b2e9a947d8bbfc1cc13a8542	f	\\x3337b83bba3c9bdb90ad3e4655d2e2b58ce11cd7581f8e7bd350ce5b	45	10000000	\N	\N	\N
127	108	1	addr_test1vqj2xdkntq743jajvxv3d9c4fwlkltauzpu2mwnde4dg9ycnv3err	\\x6024a336d3583d58cbb261991697154bbf6fafbc1078adba6dcd5a8293	f	\\x24a336d3583d58cbb261991697154bbf6fafbc1078adba6dcd5a8293	\N	3681818161420783	\N	\N	\N
128	109	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000000000	\N	\N	\N
129	109	1	addr_test1qrml5hwl9s7ydm2djyup95ud6s74skkl4zzf8zk657s8thgm78sn3uhch64ujc7ffnpga68dfdqhg3sp7tk6759jrm7spy03k9	\\x00f7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd1bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	f	\\xf7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd	47	5000000000000	\N	\N	\N
130	109	2	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	5000000000000	\N	\N	\N
131	109	3	addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k	\\x00594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	f	\\x594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0	49	5000000000000	\N	\N	\N
132	109	4	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	50	5000000000000	\N	\N	\N
133	109	5	addr_test1vz3spau50fkjzzyrcm7xlww5n3vtdqccmkvh53u08um9sngsg29c6	\\x60a300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	f	\\xa300f7947a6d210883c6fc6fb9d49c58b68318dd997a478f3f36584d	\N	3656813275134639	\N	\N	\N
134	110	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
135	110	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999997795603	\N	\N	\N
136	111	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	51	2000000	\N	\N	\N
137	111	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999997621918	\N	\N	\N
139	113	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999997448277	\N	\N	\N
140	114	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	51	1826535	\N	\N	\N
141	115	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
142	115	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999995255144	\N	\N	\N
143	116	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
144	116	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999993062011	\N	\N	\N
145	117	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3824951	\N	\N	\N
146	118	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
147	118	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999990868878	\N	\N	\N
148	119	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1826535	\N	\N	\N
149	120	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
150	120	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1631994	\N	\N	\N
151	121	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1824687	\N	\N	\N
152	122	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1651222	\N	\N	\N
153	123	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
154	123	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999980664701	\N	\N	\N
155	124	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
156	124	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999980484284	\N	\N	\N
159	126	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
160	126	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999970294583	\N	\N	\N
161	127	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
162	127	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1462973	\N	\N	\N
163	128	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
164	128	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	13266232	\N	\N	\N
165	129	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999993381410	\N	\N	\N
166	130	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	1000000000	\N	\N	\N
167	130	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998993213005	\N	\N	\N
168	131	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	199779499	\N	\N	\N
169	131	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	200000000	\N	\N	\N
170	131	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	200000000	\N	\N	\N
171	131	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	200000000	\N	\N	\N
172	131	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	200000000	\N	\N	\N
174	133	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	999607970	\N	\N	\N
175	134	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	999406213	\N	\N	\N
176	135	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
177	135	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998990035272	\N	\N	\N
178	136	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2826843	\N	\N	\N
179	137	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
180	137	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998989676506	\N	\N	\N
181	138	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2820771	\N	\N	\N
182	139	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999396376150	\N	\N	\N
183	139	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999597412351	\N	\N	\N
184	140	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999396376150	\N	\N	\N
185	140	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999597242186	\N	\N	\N
186	141	0	5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg	\\x82d818582683581c599d72b5e3f5a40fb4c4eb809e904d101f908a419472f542bc7032b9a10243190378001a2a94baa3	f	\N	\N	3000000	\N	\N	\N
187	141	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999594074177	\N	\N	\N
188	142	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
189	142	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999588905772	\N	\N	\N
190	144	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	969750	\N	\N	\N
191	144	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999587765769	\N	\N	\N
192	145	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
193	145	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999391207745	\N	\N	\N
194	146	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998980443264	\N	\N	\N
195	146	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4326843	\N	\N	\N
196	147	0	addr_test1qr5zuas73uq20j0xaw9c28udtmhfrnn876lpd4kx7vd6p303sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsve87jf	\\x00e82e761e8f00a7c9e6eb8b851f8d5eee91ce67f6be16d6c6f31ba0c5f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xe82e761e8f00a7c9e6eb8b851f8d5eee91ce67f6be16d6c6f31ba0c5	62	3000000	\N	\N	\N
197	147	1	addr_test1qrg29xk4m472yr0kvldgwrffal4vd08yh4scejjau37fvn83sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qswd2dtw	\\x00d0a29ad5dd7ca20df667da870d29efeac6bce4bd618cca5de47c964cf1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xd0a29ad5dd7ca20df667da870d29efeac6bce4bd618cca5de47c964c	62	3000000	\N	\N	\N
198	147	2	addr_test1qzlzhyyx2s27fk6mhjg786j8rlkltg50u3xe4q9d33m50gl3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsz9ymy6	\\x00be2b90865415e4db5bbc91e3ea471fedf5a28fe44d9a80ad8c7747a3f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xbe2b90865415e4db5bbc91e3ea471fedf5a28fe44d9a80ad8c7747a3	62	3000000	\N	\N	\N
199	147	3	addr_test1qq3nrwjlnutynrd95tdhkm5acdejgdhy2y7yatkmp2v67u83sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsydnq49	\\x002331ba5f9f16498da5a2db7b6e9dc3732436e4513c4eaedb0a99af70f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x2331ba5f9f16498da5a2db7b6e9dc3732436e4513c4eaedb0a99af70	62	3000000	\N	\N	\N
200	147	4	addr_test1qzphtglzya3g3ak577y2j6fuz3de2mcceyngth4cklq45083sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsk0fh2j	\\x008375a3e2276288f6d4f788a9693c145b956f18c92685deb8b7c15a3cf1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x8375a3e2276288f6d4f788a9693c145b956f18c92685deb8b7c15a3c	62	3000000	\N	\N	\N
201	147	5	addr_test1qzyu0gdpqd22krm7dstnlg48vzftdy4q38uulj70phgpe483sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsksnpll	\\x0089c7a1a10354ab0f7e6c173fa2a76092b692a089f9cfcbcf0dd01cd4f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x89c7a1a10354ab0f7e6c173fa2a76092b692a089f9cfcbcf0dd01cd4	62	3000000	\N	\N	\N
202	147	6	addr_test1qrw48rse8arexfv2xq6nv9wlerchejye2uncc7nv7uaz7s83sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsju8grv	\\x00dd538e193f4793258a30353615dfc8f17cc89957278c7a6cf73a2f40f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xdd538e193f4793258a30353615dfc8f17cc89957278c7a6cf73a2f40	62	3000000	\N	\N	\N
203	147	7	addr_test1qz24vkkjwf78zz72jrhpxujsvmee2c53sal7trhnazmd4u03sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsfytww3	\\x0095565ad2727c710bca90ee13725066f3956291877fe58ef3e8b6daf1f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x95565ad2727c710bca90ee13725066f3956291877fe58ef3e8b6daf1	62	3000000	\N	\N	\N
204	147	8	addr_test1qqvrlvpsxt7f3cqjzsg4pt8k5vd5qfecam35y9s3qh2m0zh3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsc32j7a	\\x00183fb03032fc98e012141150acf6a31b402738eee342161105d5b78af1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x183fb03032fc98e012141150acf6a31b402738eee342161105d5b78a	62	3000000	\N	\N	\N
205	147	9	addr_test1qrcsc5ljwsdpr95uf04ecgrk2eajrl55m9lrnntcydnynz03sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qswqr22d	\\x00f10c53f2741a11969c4beb9c2076567b21fe94d97e39cd7823664989f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xf10c53f2741a11969c4beb9c2076567b21fe94d97e39cd7823664989	62	3000000	\N	\N	\N
206	147	10	addr_test1qrrn7sha5hgmugcfj4fagy7er6nnrv32p52smqq6y34kkgh3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsjg8r4z	\\x00c73f42fda5d1be23099553d413d91ea731b22a0d150d801a246b6b22f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xc73f42fda5d1be23099553d413d91ea731b22a0d150d801a246b6b22	62	3000000	\N	\N	\N
207	147	11	addr_test1qzhl4yly05qhx4f7asku9tvqs4qleuz36jwnwu5tgx294603sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsxlftd0	\\x00affa93e47d0173553eec2dc2ad808541fcf051d49d37728b41945ae9f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xaffa93e47d0173553eec2dc2ad808541fcf051d49d37728b41945ae9	62	3000000	\N	\N	\N
208	147	12	addr_test1qrpszvnm6etyrnlg2je2z2x8zt6eukl256yx49fea0x8hs03sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsmgtcfl	\\x00c301327bd65641cfe854b2a128c712f59e5beaa6886a9539ebcc7bc1f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xc301327bd65641cfe854b2a128c712f59e5beaa6886a9539ebcc7bc1	62	3000000	\N	\N	\N
209	147	13	addr_test1qp84fvgnl7gnm46jt7lghplzht6d24gp79wp95fu93xk6ll3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qs4ede7h	\\x004f54b113ff913dd7525fbe8b87e2baf4d55501f15c12d13c2c4d6d7ff1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x4f54b113ff913dd7525fbe8b87e2baf4d55501f15c12d13c2c4d6d7f	62	3000000	\N	\N	\N
210	147	14	addr_test1qpd87wtyxsk6nppmegu4purlll4sfzznk9k22jpw0z2wxjh3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsgucrrn	\\x005a7f3964342da9843bca3950f07fffeb048853b16ca5482e7894e34af1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x5a7f3964342da9843bca3950f07fffeb048853b16ca5482e7894e34a	62	3000000	\N	\N	\N
211	147	15	addr_test1qq3tdyeukjl7kenyk4w6dazhvy653qrm90ucgm5l8fmkc783sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsp3ulus	\\x0022b6933cb4bfeb6664b55da6f457613548807b2bf9846e9f3a776c78f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x22b6933cb4bfeb6664b55da6f457613548807b2bf9846e9f3a776c78	62	3000000	\N	\N	\N
212	147	16	addr_test1qzfngq84222d47kcsud375kp246xqa3t44cx7nnc2z226683sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsy82ald	\\x00933400f55294dafad8871b1f52c1557460762bad706f4e785094ad68f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x933400f55294dafad8871b1f52c1557460762bad706f4e785094ad68	62	3000000	\N	\N	\N
213	147	17	addr_test1qp5v5w6r354t5p4w6ulf8fj3cgs3cz9w4r4hczttdx8uxpl3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qs469faw	\\x0068ca3b438d2aba06aed73e93a651c2211c08aea8eb7c096b698fc307f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x68ca3b438d2aba06aed73e93a651c2211c08aea8eb7c096b698fc307	62	3000000	\N	\N	\N
214	147	18	addr_test1qqq2wx0ut5eegffc6vv8ulgrhcv0ev4meyrj0srtvnqcm6h3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsktng74	\\x0000a719fc5d33942538d3187e7d03be18fcb2bbc90727c06b64c18deaf1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x00a719fc5d33942538d3187e7d03be18fcb2bbc90727c06b64c18dea	62	3000000	\N	\N	\N
215	147	19	addr_test1qpcy92zhedd8xgtt760lxk6lhga8e5mrh2unmgammj5r5fl3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qszq6xj3	\\x007042a857cb5a73216bf69ff35b5fba3a7cd363bab93da3bbdca83a27f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x7042a857cb5a73216bf69ff35b5fba3a7cd363bab93da3bbdca83a27	62	3000000	\N	\N	\N
216	147	20	addr_test1qzhrtx5435ndyfsu9375geykajevp77wmyk6qy4f3r7c6h03sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsuydk6p	\\x00ae359a958d26d2261c2c7d446496ecb2c0fbced92da012a988fd8d5df1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xae359a958d26d2261c2c7d446496ecb2c0fbced92da012a988fd8d5d	62	3000000	\N	\N	\N
217	147	21	addr_test1qpdlk0fxz524fyy6rypx8gntc0n563jqcx69jeywt5za0rl3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qse9gxmx	\\x005bfb3d26151554909a190263a26bc3e74d4640c1b459648e5d05d78ff1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x5bfb3d26151554909a190263a26bc3e74d4640c1b459648e5d05d78f	62	3000000	\N	\N	\N
218	147	22	addr_test1qzgl3yf5ur5vjh9dc56k2w8pjl0ukwp8jzhtncnp7a95hh83sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qshtjy8a	\\x0091f89134e0e8c95cadc5356538e197dfcb382790aeb9e261f74b4bdcf1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x91f89134e0e8c95cadc5356538e197dfcb382790aeb9e261f74b4bdc	62	3000000	\N	\N	\N
219	147	23	addr_test1qq8fcn4033hg9n59vjawh6del59g7xv7rg7dffefkdm4e5h3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qs75fdca	\\x000e9c4eaf8c6e82ce8564baebe9b9fd0a8f199e1a3cd4a729b3775cd2f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x0e9c4eaf8c6e82ce8564baebe9b9fd0a8f199e1a3cd4a729b3775cd2	62	3000000	\N	\N	\N
220	147	24	addr_test1qp4pa3d65hgfulm7j746fvw8els74jw40akzmp9hyv98ydh3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qs282zht	\\x006a1ec5baa5d09e7f7e97aba4b1c7cfe1eac9d57f6c2d84b7230a7236f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x6a1ec5baa5d09e7f7e97aba4b1c7cfe1eac9d57f6c2d84b7230a7236	62	3000000	\N	\N	\N
221	147	25	addr_test1qrf9daqg6z7dfrky8xgnya4wh97s2xfnt386dkqmkdv9wk03sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsfe8fxu	\\x00d256f408d0bcd48ec439913276aeb97d0519335c4fa6d81bb3585759f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xd256f408d0bcd48ec439913276aeb97d0519335c4fa6d81bb3585759	62	3000000	\N	\N	\N
222	147	26	addr_test1qqx4myf44frmnqserkvfz8s4t9kph7gcm8qlkmdm4mrs6y03sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsrp24e3	\\x000d5d9135aa47b982191d98911e15596c1bf918d9c1fb6dbbaec70d11f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x0d5d9135aa47b982191d98911e15596c1bf918d9c1fb6dbbaec70d11	62	3000000	\N	\N	\N
223	147	27	addr_test1qqvz6hcj0xdt2q5zrl25wsvym0f380pj9avtjewummzwmc03sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qshfdw7h	\\x00182d5f12799ab502821fd5474184dbd313bc322f58b965dcdec4ede1f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x182d5f12799ab502821fd5474184dbd313bc322f58b965dcdec4ede1	62	3000000	\N	\N	\N
224	147	28	addr_test1qpwkmyaj0treqyyw0mc5h53ujw4klmuaxnv5w6uf77qq3cl3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qskq4ut8	\\x005d6d93b27ac790108e7ef14bd23c93ab6fef9d34d9476b89f78008e3f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x5d6d93b27ac790108e7ef14bd23c93ab6fef9d34d9476b89f78008e3	62	3000000	\N	\N	\N
225	147	29	addr_test1qp3ktc2qx33yu6970psa2trhcjx5wtsvkars54eya7fyxu83sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsgeqqqc	\\x006365e14034624e68be7861d52c77c48d472e0cb7470a5724ef924370f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x6365e14034624e68be7861d52c77c48d472e0cb7470a5724ef924370	62	3000000	\N	\N	\N
226	147	30	addr_test1qq92nvemk40j3c5t27855fed9zd7ku623wk27ah2j7xqal83sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qstyulan	\\x000aa9b33bb55f28e28b578f4a272d289beb734a8bacaf76ea978c0efcf1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x0aa9b33bb55f28e28b578f4a272d289beb734a8bacaf76ea978c0efc	62	3000000	\N	\N	\N
227	147	31	addr_test1qrr68qudghfuvuste4a5nj9k4dqrmrvmg8avtxm8lnwwe683sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qssklv4n	\\x00c7a3838d45d3c6720bcd7b49c8b6ab403d8d9b41fac59b67fcdcece8f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xc7a3838d45d3c6720bcd7b49c8b6ab403d8d9b41fac59b67fcdcece8	62	3000000	\N	\N	\N
228	147	32	addr_test1qpthh3r3x93rl28vfuqsflcfecupw5y3zman9g9k2jn3xu03sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsrw9lye	\\x00577bc47131623fa8ec4f0104ff09ce3817509116fb32a0b654a71371f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x577bc47131623fa8ec4f0104ff09ce3817509116fb32a0b654a71371	62	3000000	\N	\N	\N
229	147	33	addr_test1qzw20ehqds0rd39apsa67m64g79ax554j7xkum34qztqakl3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsn44m4a	\\x009ca7e6e06c1e36c4bd0c3baf6f55478bd35295978d6e6e3500960edbf1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x9ca7e6e06c1e36c4bd0c3baf6f55478bd35295978d6e6e3500960edb	62	3000000	\N	\N	\N
230	147	34	addr_test1qrtgvyc7e9d7c93s7a0xmvr87s7pumryxhdh2uakjzchx0l3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsyvcre8	\\x00d686131ec95bec1630f75e6db067f43c1e6c6435db7573b690b1733ff1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xd686131ec95bec1630f75e6db067f43c1e6c6435db7573b690b1733f	62	3000000	\N	\N	\N
231	147	35	addr_test1qqymppm6e200jy2vhnag86ftfxqqvln9sf70p3wgxclsa0l3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsvdh0ed	\\x0009b0877aca9ef9114cbcfa83e92b4980067e65827cf0c5c8363f0ebff1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x09b0877aca9ef9114cbcfa83e92b4980067e65827cf0c5c8363f0ebf	62	3000000	\N	\N	\N
232	147	36	addr_test1qz3r4599pkhdjeq64arcslq9w8sm5ljgttzyyn7t3dfn23h3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qs0sa0s7	\\x00a23ad0a50daed9641aaf47887c0571e1ba7e485ac4424fcb8b533546f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xa23ad0a50daed9641aaf47887c0571e1ba7e485ac4424fcb8b533546	62	3000000	\N	\N	\N
233	147	37	addr_test1qqgmqvgvhzsturj96nuwqsw8rx8slez6yk0a72jvhhdfepl3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qscjuuh5	\\x0011b0310cb8a0be0e45d4f8e041c7198f0fe45a259fdf2a4cbdda9c87f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x11b0310cb8a0be0e45d4f8e041c7198f0fe45a259fdf2a4cbdda9c87	62	3000000	\N	\N	\N
234	147	38	addr_test1qqnzhyu7uavgynpjfn4xqc8u53rlpzqx53pa9tssvrgssg03sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qs4eeurx	\\x00262b939ee758824c324cea6060fca447f08806a443d2ae1060d10821f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x262b939ee758824c324cea6060fca447f08806a443d2ae1060d10821	62	3000000	\N	\N	\N
235	147	39	addr_test1qr8x4gd982dtjrd9htwsy847nm6kvcyzdxfsfzcdnatkte83sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsxvtuxf	\\x00ce6aa1a53a9ab90da5badd021ebe9ef56660826993048b0d9f5765e4f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xce6aa1a53a9ab90da5badd021ebe9ef56660826993048b0d9f5765e4	62	3000000	\N	\N	\N
236	147	40	addr_test1qrtw5pqv8lctknguh2mqy64t9rkvg9jssxf9ahktmyd8txl3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsc6ll5n	\\x00d6ea040c3ff0bb4d1cbab6026aab28ecc4165081925edecbd91a759bf1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xd6ea040c3ff0bb4d1cbab6026aab28ecc4165081925edecbd91a759b	62	3000000	\N	\N	\N
237	147	41	addr_test1qptf4cyv8y8qg07h864n2tzy6c2vjys88ncwjt0qh7yc8rh3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qspa6z9c	\\x00569ae08c390e043fd73eab352c44d614c912073cf0e92de0bf89838ef1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x569ae08c390e043fd73eab352c44d614c912073cf0e92de0bf89838e	62	3000000	\N	\N	\N
238	147	42	addr_test1qq29yr6nhlt7xrjz7u0qc299tdwa3uhwhcgze8ggzn6m5z83sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsrgdvr9	\\x0014520f53bfd7e30e42f71e0c28a55b5dd8f2eebe102c9d0814f5ba08f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x14520f53bfd7e30e42f71e0c28a55b5dd8f2eebe102c9d0814f5ba08	62	3000000	\N	\N	\N
239	147	43	addr_test1qptt0qfng5rw53h8c07fsadys3hmhrak6tzxhw46hfnlqkh3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qs9ezgnj	\\x0056b781334506ea46e7c3fc9875a4846fbb8fb6d2c46bbababa67f05af1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x56b781334506ea46e7c3fc9875a4846fbb8fb6d2c46bbababa67f05a	62	3000000	\N	\N	\N
240	147	44	addr_test1qzmhrdfw56ksh6qt7zefvh7k2xx3uvv3sf6tn5zukypql303sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsdsek5v	\\x00b771b52ea6ad0be80bf0b2965fd6518d1e31918274b9d05cb1020fc5f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xb771b52ea6ad0be80bf0b2965fd6518d1e31918274b9d05cb1020fc5	62	3000000	\N	\N	\N
241	147	45	addr_test1qrayjms49asal8q7kf67gjgyaw7n270wt4ey6uqydlx5ty03sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsp7rcja	\\x00fa496e152f61df9c1eb275e44904ebbd3579ee5d724d70046fcd4591f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xfa496e152f61df9c1eb275e44904ebbd3579ee5d724d70046fcd4591	62	3000000	\N	\N	\N
242	147	46	addr_test1qzv42n8ummezx9mcrmammngn2anefz3z8t4rdu4uz7k4w283sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsfljaym	\\x0099554cfcdef22317781efbbdcd135767948a223aea36f2bc17ad5728f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x99554cfcdef22317781efbbdcd135767948a223aea36f2bc17ad5728	62	3000000	\N	\N	\N
243	147	47	addr_test1qzc53jnj6gnnq32swdsm9d9ylhpcafwxru7jst3rsj7xv4l3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsvsk9rz	\\x00b148ca72d2273045507361b2b4a4fdc38ea5c61f3d282e2384bc6657f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xb148ca72d2273045507361b2b4a4fdc38ea5c61f3d282e2384bc6657	62	3000000	\N	\N	\N
244	147	48	addr_test1qzeepkvmdm2ehe0rfrztdfnqwg8fpzy5ea20gumqsdruj7h3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qs4pga0t	\\x00b390d99b6ed59be5e348c4b6a660720e908894cf54f473608347c97af1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xb390d99b6ed59be5e348c4b6a660720e908894cf54f473608347c97a	62	3000000	\N	\N	\N
245	147	49	addr_test1qzsrgdyv848v6w2e34t0av3hdj22hngm6pvnp8fv0u437j83sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsrgzwyu	\\x00a034348c3d4ecd39598d56feb2376c94abcd1bd059309d2c7f2b1f48f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xa034348c3d4ecd39598d56feb2376c94abcd1bd059309d2c7f2b1f48	62	3000000	\N	\N	\N
246	147	50	addr_test1qpmnhk67cwelpug2nvftax68p9lz9wydhpfhu3pw4lgstr03sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qspk08nt	\\x00773bdb5ec3b3f0f10a9b12be9b47097e22b88db8537e442eafd1058df1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x773bdb5ec3b3f0f10a9b12be9b47097e22b88db8537e442eafd1058d	62	3000000	\N	\N	\N
247	147	51	addr_test1qpnv4du9lqkfwyh67ylljsla2ggpcrq90yqqkun58jh39703sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsnusgj5	\\x0066cab785f82c9712faf13ff943fd52101c0c0579000b72743caf12f9f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x66cab785f82c9712faf13ff943fd52101c0c0579000b72743caf12f9	62	3000000	\N	\N	\N
248	147	52	addr_test1qzpqsqg4zfxrlh0dmk5a8e5c0pjdthjwtthcjm283c0jml03sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qs4lwq88	\\x0082080115124c3fddeddda9d3e6987864d5de4e5aef896d478e1f2dfdf1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x82080115124c3fddeddda9d3e6987864d5de4e5aef896d478e1f2dfd	62	3000000	\N	\N	\N
249	147	53	addr_test1qzrx4q2dx6usz23m2nrhm02fneh2lacncx7qsday2h09ct03sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsfen8an	\\x00866a814d36b9012a3b54c77dbd499e6eaff713c1bc0837a455de5c2df1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x866a814d36b9012a3b54c77dbd499e6eaff713c1bc0837a455de5c2d	62	3000000	\N	\N	\N
250	147	54	addr_test1qqpfzuhqswwv9e2pufhlpp9yz0ag34c8xfqahsfex48f7dl3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qszxryyt	\\x00029172e0839cc2e541e26ff084a413fa88d7073241dbc139354e9f37f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x029172e0839cc2e541e26ff084a413fa88d7073241dbc139354e9f37	62	3000000	\N	\N	\N
251	147	55	addr_test1qp53kcnzsfuteuc50zkc4ac8legdnr6ha8dj7cdg5uhql2l3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qskk46xz	\\x00691b62628278bcf31478ad8af707fe50d98f57e9db2f61a8a72e0fabf1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x691b62628278bcf31478ad8af707fe50d98f57e9db2f61a8a72e0fab	62	3000000	\N	\N	\N
252	147	56	addr_test1qrnqmwgpq7rhj2fs947t8wer5luexx8z057fn6c0j2n87jl3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsqpjn8r	\\x00e60db90107877929302d7cb3bb23a7f99318e27d3c99eb0f92a67f4bf1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xe60db90107877929302d7cb3bb23a7f99318e27d3c99eb0f92a67f4b	62	3000000	\N	\N	\N
253	147	57	addr_test1qrpwh0ewzfc5tuf7p72whf28l9g8yt2awuu4mlt6p4wx7d83sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qshwfzvg	\\x00c2ebbf2e127145f13e0f94eba547f950722d5d77395dfd7a0d5c6f34f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xc2ebbf2e127145f13e0f94eba547f950722d5d77395dfd7a0d5c6f34	62	3000000	\N	\N	\N
254	147	58	addr_test1qqhc45g3rrzgf4weg4qvrl2w8687wd82uyzeerz7khyqvgl3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsrgljqq	\\x002f8ad11118c484d5d94540c1fd4e3e8fe734eae1059c8c5eb5c80623f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x2f8ad11118c484d5d94540c1fd4e3e8fe734eae1059c8c5eb5c80623	62	3000000	\N	\N	\N
255	147	59	addr_test1qzp0n2gy5ahlspy38w3x6x4hp7udtc3acfmxrnvjw0kecch3sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsjkyy05	\\x0082f9a904a76ff804913ba26d1ab70fb8d5e23dc27661cd9273ed9c62f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\x82f9a904a76ff804913ba26d1ab70fb8d5e23dc27661cd9273ed9c62	62	3000000	\N	\N	\N
256	147	60	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	97415706599	\N	\N	\N
257	147	61	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
258	147	62	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
259	147	63	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
260	147	64	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
261	147	65	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
262	147	66	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
263	147	67	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
264	147	68	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
265	147	69	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
266	147	70	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
267	147	71	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
268	147	72	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
269	147	73	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
270	147	74	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
271	147	75	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
272	147	76	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
273	147	77	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
274	147	78	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
275	147	79	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
276	147	80	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
277	147	81	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
278	147	82	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
279	147	83	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
280	147	84	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
281	147	85	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
282	147	86	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
283	147	87	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
284	147	88	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
285	147	89	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
286	147	90	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
287	147	91	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
288	147	92	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
289	147	93	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
290	147	94	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
291	147	95	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
292	147	96	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
293	147	97	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
294	147	98	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
295	147	99	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
296	147	100	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
297	147	101	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
298	147	102	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
299	147	103	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
300	147	104	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
301	147	105	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
302	147	106	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
303	147	107	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
304	147	108	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
305	147	109	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
306	147	110	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
307	147	111	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
308	147	112	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
309	147	113	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
310	147	114	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
311	147	115	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
312	147	116	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
313	147	117	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
314	147	118	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
315	147	119	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074382129	\N	\N	\N
316	148	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	178500000	\N	\N	\N
317	148	1	addr_test1qr5zuas73uq20j0xaw9c28udtmhfrnn876lpd4kx7vd6p303sukdpdrg3k7ww3ktn3qadkep9mjdzr647z7gdq4hu9qsve87jf	\\x00e82e761e8f00a7c9e6eb8b851f8d5eee91ce67f6be16d6c6f31ba0c5f1872cd0b4688dbce746cb9c41d6db212ee4d10f55f0bc8682b7e141	f	\\xe82e761e8f00a7c9e6eb8b851f8d5eee91ce67f6be16d6c6f31ba0c5	62	974447	\N	\N	\N
318	149	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	51	1000000	\N	\N	\N
319	149	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83073204836	\N	\N	\N
320	150	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	97415534982	\N	\N	\N
321	151	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
322	151	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064213680	\N	\N	\N
323	152	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074207696	\N	\N	\N
324	153	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
325	153	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
326	154	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
327	154	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83059045275	\N	\N	\N
328	155	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
329	155	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
330	156	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
331	156	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
332	157	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
333	157	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
334	158	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
335	158	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
336	159	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
337	159	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
338	160	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
339	160	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064045275	\N	\N	\N
340	161	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
341	161	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064045275	\N	\N	\N
342	162	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
343	162	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
344	163	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
345	163	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
346	164	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
347	164	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
348	165	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
349	165	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
350	166	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
351	166	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
352	167	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
353	167	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
354	168	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
355	168	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
356	169	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
357	169	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
358	170	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
359	170	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
360	171	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
361	171	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83068036431	\N	\N	\N
362	172	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
363	172	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
364	173	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
365	173	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
366	174	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
367	174	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
368	175	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
369	175	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
370	176	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
371	176	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069039291	\N	\N	\N
372	177	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
373	177	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
374	178	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
375	178	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
376	179	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
377	179	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
378	180	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
379	180	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069043691	\N	\N	\N
380	181	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
381	181	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064045275	\N	\N	\N
382	182	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
383	182	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	97410366577	\N	\N	\N
384	183	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
385	183	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064045275	\N	\N	\N
386	184	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
387	184	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
388	185	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
389	185	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069043691	\N	\N	\N
390	186	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
391	186	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
392	187	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
393	187	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063875286	\N	\N	\N
394	188	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
395	188	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
396	189	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
397	189	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064045275	\N	\N	\N
398	190	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
399	190	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83058875286	\N	\N	\N
400	191	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
401	191	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074212096	\N	\N	\N
402	192	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
403	192	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063875286	\N	\N	\N
404	193	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
405	193	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064045275	\N	\N	\N
406	194	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
407	194	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83058876870	\N	\N	\N
408	195	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
409	195	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
410	196	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
411	196	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
412	197	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
413	197	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
414	198	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
415	198	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063705297	\N	\N	\N
416	199	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
417	199	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
418	200	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
419	200	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
420	201	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
421	201	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064045275	\N	\N	\N
422	202	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
423	202	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
424	203	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
425	203	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83058876870	\N	\N	\N
426	204	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
427	204	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
428	205	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
429	205	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83053706881	\N	\N	\N
430	206	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
431	206	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064045275	\N	\N	\N
432	207	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
433	207	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069043691	\N	\N	\N
434	208	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
435	208	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
436	209	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
437	209	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
438	210	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
439	210	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
440	211	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
441	211	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
442	212	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
443	212	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
444	213	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
445	213	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064045275	\N	\N	\N
446	214	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
447	214	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064045275	\N	\N	\N
448	215	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
449	215	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074212096	\N	\N	\N
450	216	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
451	216	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
452	217	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
453	217	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069043691	\N	\N	\N
454	218	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
455	218	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
456	219	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
457	219	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063875286	\N	\N	\N
458	220	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
459	220	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
460	221	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
461	221	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
462	222	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
463	222	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
464	223	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
465	223	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
466	224	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
467	224	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
468	225	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
469	225	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064045275	\N	\N	\N
470	226	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
471	226	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
472	227	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
473	227	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
474	228	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
475	228	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074212096	\N	\N	\N
476	229	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
477	229	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83053708465	\N	\N	\N
478	230	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
479	230	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
480	231	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
481	231	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
482	232	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
483	232	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
484	233	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
485	233	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83058876870	\N	\N	\N
486	234	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
487	234	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
488	235	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
489	235	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063875286	\N	\N	\N
490	236	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
491	236	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
492	237	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
493	237	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
494	238	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
495	238	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
496	239	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
497	239	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
498	240	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
499	240	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
500	241	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
501	241	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069213680	\N	\N	\N
502	242	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
503	242	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064045275	\N	\N	\N
504	243	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
505	243	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83048538476	\N	\N	\N
506	244	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
507	244	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
508	245	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
509	245	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
510	246	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
511	246	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83063875286	\N	\N	\N
512	247	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
513	247	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83064045275	\N	\N	\N
514	248	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
515	248	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83074212096	\N	\N	\N
516	249	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
517	249	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069043691	\N	\N	\N
518	250	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
519	250	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	83069043691	\N	\N	\N
520	251	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
521	251	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
522	252	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
523	252	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
524	253	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
525	253	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	95020251177	\N	\N	\N
526	254	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
527	254	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999996820111	\N	\N	\N
528	255	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
529	255	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999996648538	\N	\N	\N
530	256	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
531	256	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999993472785	\N	\N	\N
532	257	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	50	3000000	\N	\N	\N
533	257	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	50	4999996820287	\N	\N	\N
534	258	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	50	3000000	\N	\N	\N
535	258	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	50	4999996648714	\N	\N	\N
536	259	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	50	3000000	\N	\N	\N
537	259	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	50	4999993472961	\N	\N	\N
\.


--
-- Data for Name: withdrawal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.withdrawal (id, addr_id, amount, redeemer_id, tx_id) FROM stdin;
1	46	11951043789	\N	253
\.


--
-- Name: ada_pots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ada_pots_id_seq', 9, true);


--
-- Name: block_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.block_id_seq', 988, true);


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

SELECT pg_catalog.setval('public.cost_model_id_seq', 9, true);


--
-- Name: datum_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.datum_id_seq', 3, true);


--
-- Name: delegation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delegation_id_seq', 51, true);


--
-- Name: delisted_pool_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.delisted_pool_id_seq', 1, false);


--
-- Name: epoch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_id_seq', 10, true);


--
-- Name: epoch_param_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_param_id_seq', 9, true);


--
-- Name: epoch_stake_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_stake_id_seq', 197, true);


--
-- Name: epoch_sync_time_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_sync_time_id_seq', 9, true);


--
-- Name: extra_key_witness_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.extra_key_witness_id_seq', 1, false);


--
-- Name: ma_tx_mint_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_mint_id_seq', 37, true);


--
-- Name: ma_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_out_id_seq', 33, true);


--
-- Name: meta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meta_id_seq', 1, true);


--
-- Name: multi_asset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.multi_asset_id_seq', 17, true);


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

SELECT pg_catalog.setval('public.reverse_index_id_seq', 986, true);


--
-- Name: reward_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reward_id_seq', 171, true);


--
-- Name: schema_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schema_version_id_seq', 1, true);


--
-- Name: script_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.script_id_seq', 7, true);


--
-- Name: slot_leader_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slot_leader_id_seq', 988, true);


--
-- Name: stake_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_address_id_seq', 66, true);


--
-- Name: stake_deregistration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_deregistration_id_seq', 1, true);


--
-- Name: stake_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_registration_id_seq', 31, true);


--
-- Name: treasury_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.treasury_id_seq', 1, false);


--
-- Name: tx_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_id_seq', 259, true);


--
-- Name: tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_in_id_seq', 348, true);


--
-- Name: tx_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_metadata_id_seq', 12, true);


--
-- Name: tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_out_id_seq', 537, true);


--
-- Name: withdrawal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.withdrawal_id_seq', 1, true);


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

