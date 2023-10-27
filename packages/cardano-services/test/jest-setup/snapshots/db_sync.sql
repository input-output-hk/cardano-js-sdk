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
1	1004	1	0	8999989979999988	0	81000010009925612	0	10074400	110
2	2000	2	89999900789015	8909990089101128	0	81000010006123481	0	3986376	213
3	3018	3	179099802078663	8732681289521118	88208902276738	81000010006123481	0	0	315
4	4007	4	266426614973874	8558900932043838	174662446858807	81000010006123481	0	0	425
5	5003	5	352015624294312	8416016195508599	231958174073608	81000010002235372	0	3888109	528
6	6006	6	436175786638208	8274379716436128	289434494690292	81000009992886441	0	9348931	615
7	7013	7	508162891106095	8148340996311828	343486119695636	81000009992886441	0	0	722
8	8010	8	589646301069213	8004858029884972	405485676159374	81000009975926437	0	16960004	816
9	9023	9	662490510837166	7883443702427825	454055810808572	81000009975926437	0	0	912
10	10003	10	735806537269744	7761668331714719	502509266771966	81000015863817617	0	425954	1010
11	11004	11	808766219630457	7644153229586710	547064686965216	81000015863817617	0	0	1114
12	12000	12	885207751926324	7517074113927561	597682178636915	81000035938575640	0	16933560	1210
13	13010	13	953613128056420	7405566629470754	640784303897186	81000035938575640	0	0	1313
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (id, hash, epoch_no, slot_no, epoch_slot_no, block_no, previous_id, slot_leader_id, size, "time", tx_count, proto_major, proto_minor, vrf_key, op_cert, op_cert_counter) FROM stdin;
1	\\x269f7149b832e4c47571e820601d07bcc28222335d8c7cd1232bd793edce6bbc	\N	\N	\N	\N	\N	1	0	2023-10-25 17:32:23	11	0	0	\N	\N	\N
2	\\x5368656c6c65792047656e6573697320426c6f636b2048617368200000000000	\N	\N	\N	\N	1	2	0	2023-10-25 17:32:23	23	0	0	\N	\N	\N
3	\\xdfecb3e3dc99283a83f561c12941ce484d1c3953ca265e1bd300443af6bc535a	0	16	16	0	1	3	265	2023-10-25 17:32:26.2	1	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
4	\\x509945b2110b9753987e849c3f5073af9b018d4bb8571713e46885f5cc875a1c	0	39	39	1	3	3	341	2023-10-25 17:32:30.8	1	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
5	\\x6e57f38e783eb29bdf1a945b9addb996b0988873d2e6d675aac9b9305a4cfc25	0	41	41	2	4	5	4	2023-10-25 17:32:31.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
6	\\x59005e41d6e610f04f77bce529225918eaca7c32ded96383eff00b5eebe0379f	0	45	45	3	5	6	4	2023-10-25 17:32:32	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
7	\\xa9a441212b5c1487da0b1101d292b5537edcac9bf86faed3e2be98d03959974e	0	47	47	4	6	7	4	2023-10-25 17:32:32.4	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
8	\\x5c82b78670a9e1757644647fbf99e325794c16b1da32a2678f28466d94309798	0	81	81	5	7	8	371	2023-10-25 17:32:39.2	1	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
9	\\xba5a28ba4a81cb98ec5f3bb55e25b94dea2ecf2b010f551fba39828795643721	0	95	95	6	8	9	399	2023-10-25 17:32:42	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
10	\\x941e3fcf64d4ce913e9ddaf263f66571396994f93287680c9e3e8377a3ded59b	0	100	100	7	9	5	4	2023-10-25 17:32:43	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
11	\\xa69d93e2be318b00716c55e9d6a5b4fce64f0bd0ca8c44613b70ce98fd38af60	0	101	101	8	10	11	4	2023-10-25 17:32:43.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
12	\\x15cb9b142207e0c499294ad071ba2bad356327ac39f7f200be2cffae41236b57	0	103	103	9	11	9	655	2023-10-25 17:32:43.6	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
13	\\xba807bd31a44dfa3d64b0a6229065071a2034004ae5a16de03be31e8fa3f48c8	0	114	114	10	12	13	265	2023-10-25 17:32:45.8	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
14	\\xabdc3991583cf3954a8b4a7fb5c2d5ee326893773fd2ab3e2b3cbd24d246687c	0	118	118	11	13	6	4	2023-10-25 17:32:46.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
15	\\xc47c2435c19a8bc73625b1531880c73770bcc95bd89401ced0f42a91c5696127	0	119	119	12	14	15	4	2023-10-25 17:32:46.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
16	\\xa2de026a4ccea6d50af3a2824252ad90e04bdc9254c6dc42215af7ab35e3a85a	0	120	120	13	15	9	4	2023-10-25 17:32:47	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
17	\\xed06691caa0885160ac6d99806fc72c968f2581a25d4b165ccb6a654d2bd28c1	0	141	141	14	16	17	341	2023-10-25 17:32:51.2	1	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
18	\\x551da97edf2a6cef4ef63817b556f3c249aa9a0263bd34ae29218cfb61c0956d	0	146	146	15	17	5	4	2023-10-25 17:32:52.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
19	\\x63defea097fc24a462be2a68cc232848eb0d7e3c7075d4f575984c595c3b62f4	0	155	155	16	18	19	371	2023-10-25 17:32:54	1	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
20	\\x084a615adcf3bf38fe4e0dd37eb947b9cef2460aba3686a5f31d1768ee712efa	0	159	159	17	19	7	4	2023-10-25 17:32:54.8	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
21	\\x6d966c1d8da0d85f5dd187078170a14e8b244adb2d6c1119a3b238fa5fbe93da	0	183	183	18	20	11	399	2023-10-25 17:32:59.6	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
22	\\x82ed322465d7834ad47e0cbc1962d9656739102195c2ffad8aee7be05c5b440f	0	194	194	19	21	6	592	2023-10-25 17:33:01.8	1	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
23	\\x7dcdb94cb50267aad590684cf1cf9dba895183c98c0bc90ce6ab6fd287abe5af	0	196	196	20	22	9	4	2023-10-25 17:33:02.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
24	\\x8d2fd35ecc7a0edee9ca1152b1494484a1201125e22d24c12fca102aade7a1e3	0	198	198	21	23	17	4	2023-10-25 17:33:02.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
25	\\xd60a68a6c38ba1d5434a3a96b97bfe5cfd92fb4221386ac01a03f867637422ac	0	204	204	22	24	6	4	2023-10-25 17:33:03.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
26	\\xbbee5bc1c48a44cc2b4be63d85b4dbf5429ff08f9a1dcd295609a9ff29ea8c01	0	207	207	23	25	9	265	2023-10-25 17:33:04.4	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
27	\\x1f81474222b1be03b352fdf116758e22320328eed20a0ea3add51410ad04b25e	0	209	209	24	26	17	4	2023-10-25 17:33:04.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
28	\\x38f006f373fbd6a3ff0ca524b8c739724e4f4cf7929c605b5d912cef05948134	0	212	212	25	27	5	4	2023-10-25 17:33:05.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
29	\\xa346933c26b417dfad4ec038184d0b984ce4ab20f6c2237f95955128868257fa	0	213	213	26	28	8	4	2023-10-25 17:33:05.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
30	\\x58bb97beeb073ce892a99a544ae0640edb84b1060dec6ea81588171b071759fd	0	221	221	27	29	11	341	2023-10-25 17:33:07.2	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
31	\\x77c3aefb9f684554a4442ad803b1b82a49e5d0b0408cbfe7daececbfb37807d5	0	222	222	28	30	11	4	2023-10-25 17:33:07.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
32	\\xaf7998e15df77808369fa9754433ed4c08976a03691416eee5c35be643901765	0	227	227	29	31	9	4	2023-10-25 17:33:08.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
33	\\x9cd931c6f7dd8d0420c70dd3e930afe7922277e8b227d9d05787bac54635965d	0	231	231	30	32	19	4	2023-10-25 17:33:09.2	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
34	\\x25e866f73dae6c79498adbfd023e2ba8570f96d9614d4c8860b02cee410c0323	0	247	247	31	33	9	371	2023-10-25 17:33:12.4	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
35	\\x2290dd2d66b762decefc21032f19f5d73d5fb658a30de9e69175f32f63141826	0	249	249	32	34	5	4	2023-10-25 17:33:12.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
36	\\xe750db2424888c07a85b6093e4f74bca4d8f3de661590935d92ff6773a40f467	0	251	251	33	35	7	4	2023-10-25 17:33:13.2	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
37	\\xa2f0e11198c79cb79df81212f1eb2ccb61d435f079da29f42be8adb94bf87de8	0	267	267	34	36	8	399	2023-10-25 17:33:16.4	1	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
38	\\x87b733cfac25bff89160c7f294cc9cce7d7bf8eaf9559de7ff581664efa4f959	0	277	277	35	37	13	655	2023-10-25 17:33:18.4	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
39	\\x4cf1a9d130c5878434e5da7911aad5129c495eee15323f57b00072399b707859	0	287	287	36	38	6	265	2023-10-25 17:33:20.4	1	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
40	\\x3af930f419b57ef9cf0aabdc925d23fbc82eb3fe0e0f701bdd25251bb36b3765	0	303	303	37	39	9	341	2023-10-25 17:33:23.6	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
41	\\x19e1ae91d662ce28ff8b7d25be0692cb9bc33817a5d4408bf065064828987b2e	0	321	321	38	40	9	371	2023-10-25 17:33:27.2	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
42	\\x611c804b89ea86f2e370412770d111e02a20cd2ebdeb2958528a2ddffad99967	0	327	327	39	41	5	4	2023-10-25 17:33:28.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
43	\\x428ca5acada027aef4aa85a1268d18374ab3410fcf2ec20627a37ff13d1e8586	0	346	346	40	42	7	399	2023-10-25 17:33:32.2	1	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
44	\\xa51b440eec8673b6d9394e572067897fe303b1c3646a8acd33968cb6fd983a59	0	361	361	41	43	11	655	2023-10-25 17:33:35.2	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
45	\\xe83fba2e9549a167ec192bb18c10c3a89eea621fc196f362de16d25c388ed575	0	362	362	42	44	5	4	2023-10-25 17:33:35.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
46	\\x8c154eade949a6c998c98d6192cb5581f948cf54eb09f2be822e66832d23e87c	0	372	372	43	45	6	265	2023-10-25 17:33:37.4	1	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
47	\\xfa147d0ec1a39c8ce2f9de533c733ed4763b338f75e290a73fa800c8c3c952ea	0	376	376	44	46	3	4	2023-10-25 17:33:38.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
48	\\xde5f4a25e9f94baffd7c6d06fbed87eb1fd403c682a1dbb807a30e52502fceca	0	409	409	45	47	5	341	2023-10-25 17:33:44.8	1	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
49	\\xbd47300d84385b861dc04942f991131a0c58d5e17c3a9b85f13fedf1868af45d	0	411	411	46	48	13	4	2023-10-25 17:33:45.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
50	\\x4e6f50772896b7f64edabce55b15a1e3d21550da5c07a6ea77dce42a4d863948	0	431	431	47	49	7	371	2023-10-25 17:33:49.2	1	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
51	\\x55cd4a8114a1afea3539b1c4173df030319205c6c348068f173b59d4917b78a7	0	432	432	48	50	5	4	2023-10-25 17:33:49.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
52	\\x900978bd7116eca1079570d4e246679c57fc19e8beecf3c4acd57414c0566568	0	438	438	49	51	8	399	2023-10-25 17:33:50.6	1	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
53	\\x9e004ccb608b1ba5da498c8803b82e019f8c3373aa4ec79d1fbe7edd3a5d8eb9	0	440	440	50	52	11	4	2023-10-25 17:33:51	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
54	\\x59712f0c60808054d194d1dd2ff745592b0499ef92353c812c3499f945177a1e	0	450	450	51	53	6	655	2023-10-25 17:33:53	1	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
55	\\x696412bdeda280c75e58db9fc14edbb0183fd7c616ff0c02b9f5d8f8911b1c1e	0	458	458	52	54	3	4	2023-10-25 17:33:54.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
56	\\x8e0235e6aba3e9938032d9bf22599d8c79117aac72d36f49bc1b084cf250d9e8	0	482	482	53	55	19	265	2023-10-25 17:33:59.4	1	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
57	\\x087b75b09bede36dd57ca11e0b0638432977a401bec968dc60d794f58d6f29ee	0	502	502	54	56	15	341	2023-10-25 17:34:03.4	1	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
58	\\xf1d2022ce1f15cc2ca06fc37ba437aa47c4e10a393ce67a138dd139a87d47b61	0	506	506	55	57	11	4	2023-10-25 17:34:04.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
59	\\x8da96ba8c01067874c67c5baf5f80bde617da4d2ee38812c3dc8a4e1d9e4bfe3	0	507	507	56	58	6	4	2023-10-25 17:34:04.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
60	\\xe1276f6ad2d7e0f5ebd69573e0263331a6aab60a728122b50355f2e9015e6cb8	0	508	508	57	59	8	4	2023-10-25 17:34:04.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
61	\\x9e0f54087586f5b8d4dd96501a1201d603c5226325398c3851380483b8aee745	0	520	520	58	60	9	371	2023-10-25 17:34:07	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
62	\\x2be2cda07723507a3e6f868765b2e2e162c04436b830ce667e0d5abae3e3558f	0	530	530	59	61	3	399	2023-10-25 17:34:09	1	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
63	\\xc9a887b28e858275e14d9481c44c062808c8d75d3e7af55f6feb893061211413	0	566	566	60	62	3	655	2023-10-25 17:34:16.2	1	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
64	\\x2a5862e07f543a429d4ee77ce62550bf60776fee7587c555a43c9dc91a6fd31d	0	587	587	61	63	3	265	2023-10-25 17:34:20.4	1	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
65	\\x711b73cc15d05b274724d4937622fdb976648b24b42964f3847b63587f76a23c	0	600	600	62	64	8	341	2023-10-25 17:34:23	1	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
66	\\x34250865948345dd9e821a71124ceba754b4421eea374bf95bfc8fe1d45efe37	0	607	607	63	65	13	4	2023-10-25 17:34:24.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
67	\\x9d898f884dc30b343951a360749bd140e51996d9738ec99e87edb951602c083b	0	612	612	64	66	11	371	2023-10-25 17:34:25.4	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
68	\\x7d799a41d6d424aaf78a746b073b47f6e14736679de84e04ba277ce6db048220	0	625	625	65	67	13	399	2023-10-25 17:34:28	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
69	\\x88124b8ed2a3a50c477a6b4b6e9a684b158da565afc7b376818def2273071d78	0	642	642	66	68	13	655	2023-10-25 17:34:31.4	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
70	\\x419731e29e30ca177a0bbd7a0d9cb28317376ed33e430314c38f3b86b76edd0b	0	646	646	67	69	3	4	2023-10-25 17:34:32.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
71	\\x3a9c9b02b7ce38b093b4c11ae089d3c6766d04c136f605c206c39f8922d85512	0	663	663	68	70	3	265	2023-10-25 17:34:35.6	1	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
72	\\xd03843f41aedc9f070ca3c9d543ca21cfcf6bc3c10d81a334755ca5c3d72ba9d	0	693	693	69	71	19	341	2023-10-25 17:34:41.6	1	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
73	\\xb1a36944a71f04f87d76e1aefd1f60bf7404843f94ad1803a71e45b95c6a1b13	0	711	711	70	72	3	371	2023-10-25 17:34:45.2	1	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
74	\\x7a1f5c4dcddb4a38481650f4ed6a1462f658a1721b4fa86ae388359bde8aca67	0	712	712	71	73	11	4	2023-10-25 17:34:45.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
75	\\xb23f69c0adccbd376e8ef0fbd40f4e401d2654370c07a3d32855160d0cdc9a6d	0	716	716	72	74	6	4	2023-10-25 17:34:46.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
76	\\x32bea0fcece58f6b50c365595d6c1b3fea243ad811661fb794fbc2640cbb49c4	0	719	719	73	75	5	399	2023-10-25 17:34:46.8	1	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
77	\\x1c62e287ac0a5d5ea2bf1305595d68873221898002e84af1450abbfde5e58212	0	731	731	74	76	8	592	2023-10-25 17:34:49.2	1	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
78	\\x16049599937516e07f25544303645e594c76035102e825cc44c139387b1f45d6	0	744	744	75	77	5	399	2023-10-25 17:34:51.8	1	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
79	\\xeb6c7fb302c3369d9d01ce389e272001b4e343171d8ae76051c71be706e3f8cc	0	751	751	76	78	13	4	2023-10-25 17:34:53.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
80	\\x20ff94606f7a46e5dd1a9952fcc96c9be74853548221e81236d7dff8877beee9	0	753	753	77	79	11	441	2023-10-25 17:34:53.6	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
81	\\xd647053d44bc70f2f10e42ac85eee265b56eef81b97300b0717333058b117a1f	0	762	762	78	80	7	4	2023-10-25 17:34:55.4	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
82	\\x31e224cef4aa6adc482797a50bf46ab17864bf51c33b2930631c0efb39d8c759	0	765	765	79	81	11	265	2023-10-25 17:34:56	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
83	\\x44e89177ec041ef07bd77fb44c852fbe7ab11b9a4f6654aeab10367e9572220a	0	775	775	80	82	15	341	2023-10-25 17:34:58	1	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
84	\\x2b1bcb70a371ebb566f4d44fc7db57120147f087fa9a68c78b89bf7b9f0ccbbd	0	797	797	81	83	6	371	2023-10-25 17:35:02.4	1	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
85	\\x11da9258bcf0f6273744fef829d728f340d60d3090db5b1906dd7c24bc5d0edf	0	800	800	82	84	5	4	2023-10-25 17:35:03	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
86	\\x6414882c06b41c2645ffd2dc3770911fd9f16ea08826bd1da886d48994058580	0	801	801	83	85	13	4	2023-10-25 17:35:03.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
87	\\xb03df6a3f0bd50a426d9d23e79630478e4842caccc575e762961f74add3fcdb8	0	803	803	84	86	17	4	2023-10-25 17:35:03.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
88	\\x5b4c4a2930d9aad0179f8add7351b6c5f9e88b477e349073765aaef08de9cfe8	0	805	805	85	87	3	4	2023-10-25 17:35:04	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
89	\\x3c95924d3133584f1a1c7a99a81f724e47b108d371a643d64461ef5a643dc8ad	0	814	814	86	88	17	399	2023-10-25 17:35:05.8	1	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
90	\\x90d1d4f79d32a92f04ee7cfd8da67b8b7d5285077242830b82f7457ad2e59ba9	0	828	828	87	89	13	592	2023-10-25 17:35:08.6	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
91	\\x88d60b7dc39cef43dabeafdc209fe59487efca28463c669e6a589652c2a339c1	0	844	844	88	90	13	399	2023-10-25 17:35:11.8	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
92	\\xd095573adc6f77aabba592d6d1ab211ed2139c75bbd1f8d387947d7f35232df0	0	846	846	89	91	6	4	2023-10-25 17:35:12.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
93	\\x05a95f7a1617beb567b8df53cbad7c2ee4818275c8da6ea0e75c5163978b6099	0	861	861	90	92	9	441	2023-10-25 17:35:15.2	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
94	\\x97044e5c8cd8d2c4f967ae0b1bd93790dc5a0675de3fc9cb2123bd9263a9c73f	0	862	862	91	93	7	4	2023-10-25 17:35:15.4	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
95	\\x09d470f9fe29ddaebd9d4cbc81bf34356cbbf3732ecad1f3e65a8630e46d431e	0	870	870	92	94	5	4	2023-10-25 17:35:17	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
96	\\x8b816dd781eac383390bd60d93487407b2654349fa5119e9e0b91a468696cc48	0	878	878	93	95	9	265	2023-10-25 17:35:18.6	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
97	\\xb31d411d5580817b416ce137a481893a3ffda519a16a0c9ab29100b0ba7b636d	0	879	879	94	96	9	4	2023-10-25 17:35:18.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
98	\\x7413d74daf79bdc73203144c7a451bf336ae0c4bdccae99f628ff35e8479c340	0	907	907	95	97	11	341	2023-10-25 17:35:24.4	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
99	\\xdec53b0427d85801f6f026addea77d18fcdea87473da440943cfaf374beceb3c	0	911	911	96	98	3	4	2023-10-25 17:35:25.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
100	\\x2865024c0d1bac6e6fff4f0e56b90312c84c31dfb28f85b38738fe86ca9fdd6b	0	926	926	97	99	15	371	2023-10-25 17:35:28.2	1	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
101	\\x5e80d0b617765425f3abad1f3259e6d9903463e2edec4db728f61053cec34b59	0	927	927	98	100	5	4	2023-10-25 17:35:28.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
102	\\x2f630829767839192698e14d76ee519e8678284a1b8e0f9692fdd3d37058502e	0	931	931	99	101	8	4	2023-10-25 17:35:29.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
103	\\x1d45d1dd02e1154b398995c3be58a68f4d0f2f6fe5700c226ccfd1091bd18e0d	0	933	933	100	102	19	4	2023-10-25 17:35:29.6	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
104	\\xef0070b72412e6b77e99966d7922bc58f7c27bc42139f35c4815927b6aa93fd8	0	934	934	101	103	7	4	2023-10-25 17:35:29.8	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
105	\\x4de12c28bd6ca1238050473f047d3b42c7c909178c49c5a2df6ecc6a21cfb839	0	958	958	102	104	13	399	2023-10-25 17:35:34.6	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
106	\\x32596410c60cf600425dd3a41695245ff5d5cd1591b3d235ede7c8a0d6d9889a	0	960	960	103	105	15	4	2023-10-25 17:35:35	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
107	\\x1e333c371f79a6e03cd84d449adb7f96132ec65a2bbaef7b8d187fe5abd85a4c	0	971	971	104	106	17	656	2023-10-25 17:35:37.2	1	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
108	\\xf290984ca1b824677e1e3d731c693390c9f142ee8aeb39ec23d0ba63b5da4b86	0	988	988	105	107	6	399	2023-10-25 17:35:40.6	1	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
109	\\x7cc775ddcf93d22b852a7fcee25cad98987a4cb7fe38113e8e77c224aa4c39d7	0	993	993	106	108	13	4	2023-10-25 17:35:41.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
110	\\xd75e164411f389f60f2586ec3dfb581f40e7ecc23010a14efc5e784556566392	1	1004	4	107	109	8	441	2023-10-25 17:35:43.8	1	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
111	\\xe41f66ac51939b84e7f07b7adad11152a4381f841dc67ab198abcd4a7d2d9731	1	1011	11	108	110	8	4	2023-10-25 17:35:45.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
112	\\xfb0bf0344804cbee7c1f4000269d42cd2182907ba905f650308a5809da1f081b	1	1012	12	109	111	9	4	2023-10-25 17:35:45.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
113	\\xa10934cfd73a9e39bc5fd92db28a20beaee09ca5e78424a0782e043226d790ba	1	1019	19	110	112	15	265	2023-10-25 17:35:46.8	1	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
114	\\xb6fb21915a4c60a031acb6a898226dad196587c68f263363ab5246b9f7057260	1	1027	27	111	113	9	341	2023-10-25 17:35:48.4	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
115	\\xef227bd969b822441b92152d25b9cd272e07fbd88d98c6df459f3e3c63f80886	1	1035	35	112	114	5	4	2023-10-25 17:35:50	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
116	\\x310fb2148fae0b028fb645aca2ae83eaf302a565e80da81a5c221d305614da19	1	1041	41	113	115	9	371	2023-10-25 17:35:51.2	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
117	\\x7da19f1e2768a059c7de3a9942fe24eef8eb7f93b40b76e5f1e29867747d17ad	1	1042	42	114	116	11	4	2023-10-25 17:35:51.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
118	\\x82c4fbeadd552e58a2e186f300a9850f340a1d94206af33535922e81f326ba32	1	1056	56	115	117	11	399	2023-10-25 17:35:54.2	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
119	\\xec9516be2d9d62d58c9557166060424404b5b477deb3ae0d2619d4739a59d852	1	1063	63	116	118	3	4	2023-10-25 17:35:55.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
120	\\xcb151f3bb88aabf2a586c0ed034f04f8c25ea8bb625aeaea20a3e59d2b127cca	1	1071	71	117	119	9	656	2023-10-25 17:35:57.2	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
121	\\x869049fc4dce7a2eab2d3994d4c07d7e3a1cfde691b44acea9c0f5ec2957ab08	1	1085	85	118	120	13	399	2023-10-25 17:36:00	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
122	\\x046d979b9fa602f69496757cb2843f44a52b1c32ca29dbf2cdcd6b1d26efbb70	1	1088	88	119	121	8	4	2023-10-25 17:36:00.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
123	\\xf1ea3da960d50390f1f5ef21f05dc89e2ed1afa3d370b04787e30eef51af8945	1	1089	89	120	122	6	4	2023-10-25 17:36:00.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
124	\\xcfd276c4ee80c1b6f1275115b4217533a6d8024509a768c5ea9a6a3b9dcd3303	1	1093	93	121	123	19	441	2023-10-25 17:36:01.6	1	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
125	\\xbf559a585bf111413534bcc913ee5f162772e0ae31024d1d41fe61af0b16bf25	1	1094	94	122	124	9	4	2023-10-25 17:36:01.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
126	\\x950fbca5f8370406db5fa2dab0dce5a39508ba4ffd68bf3b3212764f3bdf25fa	1	1098	98	123	125	6	4	2023-10-25 17:36:02.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
127	\\x082044c855853f3e0b90dbf8a04b4d321529f961598eb2b26cb2ef78c7e0ead4	1	1099	99	124	126	19	4	2023-10-25 17:36:02.8	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
128	\\xfc481eff1a134227241e9da44cbc18b444836f07bfdf1e8155687fe7ef5ba53a	1	1107	107	125	127	6	274	2023-10-25 17:36:04.4	1	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
129	\\x8af443c87585f424b7b35d63b035556a4370576d3f9a45ffad278fb0074c77f0	1	1119	119	126	128	15	352	2023-10-25 17:36:06.8	1	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
130	\\x2b4dbe972321a76bba7b117f46c5875520da4c7c14b9bf4ecfed7c60206ddfcb	1	1124	124	127	129	6	4	2023-10-25 17:36:07.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
131	\\x5478a552f178155f767caf35146f9a0a2923cf3f7ad7207c80cebc21715b06a4	1	1127	127	128	130	19	245	2023-10-25 17:36:08.4	1	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
132	\\x9f019f1880689e1fb77db5dc854057220e208dd8df8deafde50545c450929e87	1	1135	135	129	131	7	4	2023-10-25 17:36:10	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
133	\\xa00d477657e6f2e082bac441fe3b3f89cd30495cafba9fffbde605e505cfcda0	1	1143	143	130	132	9	343	2023-10-25 17:36:11.6	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
134	\\xf4be64e297fb3e23bba001b7828e62eb31e7438f2fb0985a385abf4c76223be6	1	1170	170	131	133	11	284	2023-10-25 17:36:17	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
135	\\xf6337759cf2ccf7aa3757bbcb9099b391c5daaf952add2bed5fce1004e4a556a	1	1173	173	132	134	5	4	2023-10-25 17:36:17.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
136	\\x732d75cafa48a0bc5ba65315c4545c408a5c1055d739052bdd682f3c3d544188	1	1175	175	133	135	19	4	2023-10-25 17:36:18	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
137	\\x4ef4bf357635c0055ebae545b6fc89826ddcb2681cd609662c2fb55ae83cb5e5	1	1178	178	134	136	6	4	2023-10-25 17:36:18.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
138	\\x1abbb804d5fb12bb03f5dbdb14cc5b1fa238c751808ff4cc9f2a5dd30677b5b6	1	1183	183	135	137	15	258	2023-10-25 17:36:19.6	1	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
139	\\x395db2216b674485b571f96175692f17056894fce704cc3a79f6d541ae402ccc	1	1193	193	136	138	13	2445	2023-10-25 17:36:21.6	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
140	\\xe49f5421a3cfecbca223c9a594f30b861902ce825416857b23c50b98021f092e	1	1204	204	137	139	7	246	2023-10-25 17:36:23.8	1	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
141	\\x812408f9ee60145697aaf8a897cb8677672e611defa95e6fdc1b0cdb4a14b5f9	1	1205	205	138	140	11	4	2023-10-25 17:36:24	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
142	\\x7468fa5286afc96c94d6b2c655f64651362eda6c66d4e74ebf7081cf3192bdd0	1	1221	221	139	141	7	2615	2023-10-25 17:36:27.2	1	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
143	\\x5d76e3e31f7e83ec53d302f23227d72b48483c6d4d3166f4bcf4d4d32fdb6633	1	1236	236	140	142	11	469	2023-10-25 17:36:30.2	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
144	\\xa38134024ad0050be61dda2e8adb8793545bb6705009cec39edf023baf99fef2	1	1249	249	141	143	9	553	2023-10-25 17:36:32.8	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
145	\\x6ea09ec614c84f3cfdcb199637b69cfbadd479cd497898aad2f3e48c157aadb7	1	1262	262	142	144	17	1755	2023-10-25 17:36:35.4	1	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
146	\\x09755cace75d555e6359be0a237f8160ee8eafb6c241f9e886ab1f22a7d79369	1	1282	282	143	145	7	671	2023-10-25 17:36:39.4	1	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
147	\\x5a09515c6d6f89f83d6b1dcb142dad11f0586d3d02d80e90dec1e36e37a78b32	1	1319	319	144	146	9	4	2023-10-25 17:36:46.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
148	\\xe795ffdfcc62e787b075543834ebd35d6b4350d17c3585c72ce99d242413222d	1	1341	341	145	147	19	4	2023-10-25 17:36:51.2	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
149	\\x8d787a7ed32d599a1a78b20a038e26c424f8b17645352bed9c2f1bf8e0b466b8	1	1353	353	146	148	3	4	2023-10-25 17:36:53.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
150	\\x7f121b0b7f596c48ec4973ed15d9b889b4ff5eecf238fc9e1fc481785dfde2d2	1	1356	356	147	149	7	4	2023-10-25 17:36:54.2	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
151	\\x4a9461676581df06ce7f200ed8bb411e33413ddefda3c8077e2a25115512fc69	1	1366	366	148	150	11	4	2023-10-25 17:36:56.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
152	\\x7955dd1bd43ff0b6bd4819647281b521bcecdaa238b1c752f8e36a3e6bc58e70	1	1370	370	149	151	11	4	2023-10-25 17:36:57	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
153	\\xdd23d91de0be28ff51a74be002dea4dc703412d2c17ea38a34777d8a5e38bfde	1	1371	371	150	152	5	4	2023-10-25 17:36:57.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
154	\\x6124fdeb4a38f7c3f0d970d45f9c1f4f243418aef78998d1188e42113556b8ba	1	1383	383	151	153	17	4	2023-10-25 17:36:59.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
155	\\xbcf40f1824fcf32732d1eda195b654a5648770871876c933a32f44f19c06e528	1	1388	388	152	154	5	4	2023-10-25 17:37:00.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
156	\\x8e80750b6d9ff8a23f7ef0d3edd1e7989beb57e42ac464eeadce5b05fd6f0fed	1	1390	390	153	155	8	4	2023-10-25 17:37:01	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
157	\\xb741666fbf07182f9224c88472d4af733d2c998812c9a9038e861b472af3d4bc	1	1394	394	154	156	15	4	2023-10-25 17:37:01.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
158	\\x4501115406dbc1f38711589e8c1b141f86340aa6bad95d515e37229b5db85148	1	1395	395	155	157	3	4	2023-10-25 17:37:02	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
159	\\x16ff406e7eca2b5faaaf57142db5c4086de214e0f8c97f04facd51c426d84d3b	1	1405	405	156	158	6	4	2023-10-25 17:37:04	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
160	\\x37bb32a6a40cc1c0ed7ae87d02b8d811c36f42df5f2afbd0109ab7bab2fdf620	1	1406	406	157	159	7	4	2023-10-25 17:37:04.2	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
161	\\x9df3cf29629e76714883f125a2383e335b55ce14c907cabce36ccce673deb604	1	1415	415	158	160	11	4	2023-10-25 17:37:06	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
162	\\xf79a218a6637e71b44b0fdb960a80c38b540e62bd64e656067a4f359c7e56ff1	1	1429	429	159	161	17	4	2023-10-25 17:37:08.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
163	\\xaa280374fe5db15a86b411db17887e7317d5eb78e887c27fc4d7ea77dddd6ff5	1	1435	435	160	162	9	4	2023-10-25 17:37:10	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
164	\\x835814a380a6aa4d532a021fa58860856d65bf61b1a00d3f0666abacb829c777	1	1438	438	161	163	13	4	2023-10-25 17:37:10.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
165	\\x7e349aa9b20e360eff9bfc42a7e8507a947d290c556fdf7c45d561a734bbf8a8	1	1442	442	162	164	8	4	2023-10-25 17:37:11.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
166	\\xfb64ef4050fbc727d6f65f4d5b7ad9fae455251a81f4746ba8f00c9d92298a9f	1	1478	478	163	165	9	4	2023-10-25 17:37:18.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
167	\\x41281b531def7bcba42b6418fd06d58a24331d178b507d9cb2efe48de87a433e	1	1493	493	164	166	15	4	2023-10-25 17:37:21.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
168	\\x4940401ba9cd4f69378f5fc8f5a0c07d4a9883394c16ba15e8a916f49fcdef73	1	1506	506	165	167	6	4	2023-10-25 17:37:24.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
169	\\x53f7e5c387771ddd940c35d8c64d7febb9d672194fbc52c69879d7662e408a4d	1	1512	512	166	168	15	4	2023-10-25 17:37:25.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
170	\\x5e98f8ce3522b28f68b908253890ddec35cfba597531251002071a243fd5da73	1	1541	541	167	169	6	4	2023-10-25 17:37:31.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
171	\\x4ed85ff92954c0ed5da255fc9cca2852d797e4263f4bdb2b07ee156c7cf6719a	1	1559	559	168	170	6	4	2023-10-25 17:37:34.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
172	\\xe560180c47470d5a7330649824ec6ac8ecf49a8a4f39bf6a75b024b6b57b8a81	1	1562	562	169	171	6	4	2023-10-25 17:37:35.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
173	\\x6e387321cf3976c4ec832195126278b6aaa6ac6abfbd4da79e7957b15d9cee35	1	1573	573	170	172	15	4	2023-10-25 17:37:37.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
174	\\xda236585d6f8390ffc4633fadad63088b0f4517300ccb6080c6434b12eb6b4ae	1	1574	574	171	173	3	4	2023-10-25 17:37:37.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
175	\\xa5df30c6bd88af7b8a79602aede7ff6f64726b7998bc02c9dcfb7499bd3ab9a7	1	1581	581	172	174	3	4	2023-10-25 17:37:39.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
176	\\xafca426e07da8be7cb274786d933fe622156064dbaa140c78ce6354e667a38b6	1	1582	582	173	175	15	4	2023-10-25 17:37:39.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
177	\\xf0e8079a66ee99bd232e6ec07661fbce0a136714d5d48457d0e7edf007dc0f4d	1	1590	590	174	176	15	4	2023-10-25 17:37:41	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
178	\\xa6de53bda242fdbaba3580b3e7203e744c6bb4adf6b0d9a2669e18e9bdb2e298	1	1593	593	175	177	7	4	2023-10-25 17:37:41.6	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
179	\\xf0500fae17cb714f344660d20cb043355ba5832f29c42d01d27061d1f08b1eca	1	1618	618	176	178	8	4	2023-10-25 17:37:46.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
180	\\x30bcc38e2b52d5801e895e7e60529ea8fe55f6c38b777b76345846a2a6e3a65a	1	1619	619	177	179	3	4	2023-10-25 17:37:46.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
181	\\xba48c538388feb3abdfc8d69fd531a91edf0e2d2c8001611e7db5af480adf00a	1	1629	629	178	180	17	4	2023-10-25 17:37:48.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
182	\\x316e4867bebe6d5b818d106b4cf1ed4a3809414e9f38c1e42ecff0bef39d3bde	1	1674	674	179	181	17	4	2023-10-25 17:37:57.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
183	\\xdcf266b251301839702aa9e94adb822d2ca89bb4379b37355a5e7dca7c993311	1	1690	690	180	182	11	4	2023-10-25 17:38:01	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
184	\\x1735e198090508864eaf7afae604c03da1ea4eb51c98112fa53accac0b566381	1	1692	692	181	183	15	4	2023-10-25 17:38:01.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
185	\\xf8a3b4af08b236af264589300b1e9d6ee87abe33710d527b0c2e8f3f7d51eac2	1	1699	699	182	184	11	4	2023-10-25 17:38:02.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
186	\\xb4f6d0cb37ce00451bd8d68216c1a6284546d1db9a1d30392ffb40930af2d4ee	1	1707	707	183	185	7	4	2023-10-25 17:38:04.4	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
187	\\xf7884109f2282b0099dbf02e0e064a7ce480cdc054e1b9604aaeba346fe090da	1	1709	709	184	186	5	4	2023-10-25 17:38:04.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
188	\\x99748f8ded36954303273d8642d1f7ab6f7a828d1f04fa26449adcc8547868b2	1	1711	711	185	187	8	4	2023-10-25 17:38:05.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
189	\\xcb48969c64c3d5eccf0f54d78600c4f25870d396bc427bbd8062238d86dbd2cc	1	1713	713	186	188	15	4	2023-10-25 17:38:05.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
190	\\x1351802fe6fe2b31dbc3c0df98207deb61b8fb4535eeb16abc2518dceb8f345d	1	1730	730	187	189	9	4	2023-10-25 17:38:09	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
191	\\x850135ac230bf9bef2ac51ef3d0ec523b757ade3260b27e635fc43e7b71217c9	1	1736	736	188	190	19	4	2023-10-25 17:38:10.2	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
192	\\xd14b4e2e7708f1b85d6549bb8e11aca4e66e18c54de3f6208f5ba7d9b33c8fba	1	1739	739	189	191	3	4	2023-10-25 17:38:10.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
193	\\x35bafd7ee0fae837f6ef3f6e8fdf59d9d294ccc5dfe85a26fb5d4e2dc1987018	1	1741	741	190	192	3	4	2023-10-25 17:38:11.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
194	\\x3dedbf75d28fa95f6ef14708d6e46d056423fcefd95050a842eb795ca4d66649	1	1749	749	191	193	15	4	2023-10-25 17:38:12.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
195	\\x24b951be8ababfcfecce307b78d69fb0e3e77f149c5d416339400b0faed154c6	1	1780	780	192	194	15	4	2023-10-25 17:38:19	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
196	\\x91b767a65d0b833ee3beefe91ee8182f8f99708fcfc2683b6a1d1e3a011c0da4	1	1787	787	193	195	3	4	2023-10-25 17:38:20.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
197	\\x299aebd4c44a2069ea375347ccceb89c7c88ff7c6209b18d2e25c433bce4fabe	1	1794	794	194	196	15	4	2023-10-25 17:38:21.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
198	\\x71a0c95d6e4162b6b0b99ef3189e56a531081d2dcbc0b825c81801e4bbc7ae24	1	1799	799	195	197	7	4	2023-10-25 17:38:22.8	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
199	\\x3c08e53b0908bb0fe1e41ae20554c8b4c359b45d3b3a17744c6659b05e2d9afa	1	1814	814	196	198	5	4	2023-10-25 17:38:25.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
200	\\x694d0316613c4cdf15e6071e409c4f85ab63e0c01c3f3b62baf74cc0d27ba448	1	1825	825	197	199	6	4	2023-10-25 17:38:28	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
201	\\x97d882f30afa3696c042c941c773a7056f595832d3cb57c1bb16aae81e06bc20	1	1848	848	198	200	15	4	2023-10-25 17:38:32.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
202	\\x311e3f7d6f56637027a10f9ed5cef3f73136e16a5688d23503ada92da6f8a875	1	1886	886	199	201	9	4	2023-10-25 17:38:40.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
203	\\xa5c37aa43f10f6ad93e2aa5853f2366aea738cba698ee74e004c9f790fe5c513	1	1901	901	200	202	11	4	2023-10-25 17:38:43.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
204	\\xe70262b929ff0a3f5a0fa35d7ac4501e066af65ee8c5657a2f330400c7bb293d	1	1912	912	201	203	19	4	2023-10-25 17:38:45.4	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
205	\\xa6fe710c79a2ccec0eebd729b60902d1f64aa8bae2141d6f23c24a7622b714ff	1	1916	916	202	204	5	4	2023-10-25 17:38:46.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
206	\\x2825226ca5bed33c7acecb7cc9625e1aafa619cba0e08f669f44aecfc6bdf7b9	1	1921	921	203	205	19	4	2023-10-25 17:38:47.2	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
207	\\xd19d17f277a71ac01f7ca21613e34d534709a675f925c830557ff5a38bb52ad7	1	1922	922	204	206	3	4	2023-10-25 17:38:47.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
208	\\xd7ed99cf5375d43fc256b93efa93c75381d60a74465b9dc31481723965c58a54	1	1929	929	205	207	8	4	2023-10-25 17:38:48.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
209	\\xab86da5f39c4e935efc9778e087212d44b834a32f49c04cf779c84440f0bfb15	1	1945	945	206	208	7	4	2023-10-25 17:38:52	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
210	\\xe10332b0b5e6255e068e18407d3daf4be8ca32d73885568c400b13573059ebf5	1	1972	972	207	209	17	4	2023-10-25 17:38:57.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
211	\\x27b6ec0738ba7f930fd5a546d7e138139c7e3a67ea1c301e935093659960d724	1	1982	982	208	210	8	4	2023-10-25 17:38:59.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
212	\\xd12c3ced8a01907602eaa084c613eec747f4fddb6d9b63c68a6d72faad2d87ef	1	1990	990	209	211	7	4	2023-10-25 17:39:01	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
213	\\x621be2f90bef8d2ae54b2469eb39553f626727efbfd52c5de7ee73b3724ee71d	2	2000	0	210	212	19	4	2023-10-25 17:39:03	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
214	\\xc975caf3bcc4e2840e684f9c458f55dfb9f0ae39266f37b905496596665808b6	2	2007	7	211	213	19	4	2023-10-25 17:39:04.4	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
215	\\x416d24efbb3e185fbc640eaecda2539f5d2f4fd431e3c191858aa19c30638e70	2	2010	10	212	214	11	4	2023-10-25 17:39:05	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
216	\\x93826e0764bf226465f35d44f5849742caf4fb52256e22cedb52a614235a2811	2	2021	21	213	215	11	4	2023-10-25 17:39:07.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
217	\\x7eebc020d8bd1daf645529e589508d22142e5034c7432f98e81b4a2e56535522	2	2026	26	214	216	7	4	2023-10-25 17:39:08.2	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
218	\\x16e596fb3c0e9850da02d0e9d618763397aaa6da1b9d662b6d9b72c64a0277fc	2	2064	64	215	217	6	4	2023-10-25 17:39:15.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
219	\\x04682e0fa3ddd4cc7900cf0daeb1fccc2593eaa2419ada93840b3a3fe7bd5d27	2	2065	65	216	218	3	4	2023-10-25 17:39:16	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
220	\\x08d2e8be7cfcaabd553337ef0c5d32e41a129ef48ad4a8d528e5cb52a1b648cc	2	2068	68	217	219	11	4	2023-10-25 17:39:16.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
221	\\xd79ff587e38d451d4719ea1aa47059b4f61b4924475ffe19c90df1e05fd1c7d9	2	2070	70	218	220	7	4	2023-10-25 17:39:17	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
222	\\x1826207da41f246b5c6ff17c69ac96bd14747e267ace685772e0d7446b1db27d	2	2071	71	219	221	3	4	2023-10-25 17:39:17.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
223	\\x56afd580ff40a6b156899411d6adb6d49c7755e863768417fe2bcfda7dd0b64e	2	2073	73	220	222	7	4	2023-10-25 17:39:17.6	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
224	\\x90c052beb0098d6a07779b708a51e2c587fe9d84e4d3b73dafcf23f71cba9bd3	2	2075	75	221	223	17	4	2023-10-25 17:39:18	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
225	\\xf588341512b0cf27e8a0e342af7c7e47b452a81a0317d7f0a8abe94059a345ec	2	2083	83	222	224	7	4	2023-10-25 17:39:19.6	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
226	\\x082970b3c5363f86dc54424660c6a576df3bba878ef98b93247effa691371976	2	2087	87	223	225	6	4	2023-10-25 17:39:20.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
227	\\xa7c462c26e521f55501cbdc78f4470457d15881db3faf2c87c08eab4f89058b6	2	2089	89	224	226	3	4	2023-10-25 17:39:20.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
228	\\xf208eda77cef7b4dc4d0ca05b6f59a3667b672b013f14a2ffb23109cc4e5dd0e	2	2091	91	225	227	9	4	2023-10-25 17:39:21.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
229	\\xe5cc73365b253de42257f7b7af6c362931e0ac64eeb1a39e667d631926d18709	2	2092	92	226	228	8	4	2023-10-25 17:39:21.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
230	\\xc8a7a407bb92c82ae3169d7ea449b4d2e1b9dceebd6816c85e947965d2daae95	2	2102	102	227	229	15	4	2023-10-25 17:39:23.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
231	\\xfc92eb4693f2ac1cbd99cf5bbe2164f674339c81ce5d7f958b94c36981335e45	2	2104	104	228	230	11	4	2023-10-25 17:39:23.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
232	\\x8ce2e596890eaa4b99181871d422689072dcc951437315e9c160378e6470a8c3	2	2105	105	229	231	13	4	2023-10-25 17:39:24	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
233	\\x5980ebbb5b4b613735a8830329f0c544a8bb62ddadd9746ab0c7ffad64762c3f	2	2135	135	230	232	7	4	2023-10-25 17:39:30	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
234	\\x10104f5f84dc310c28cedce675fc4b377e930fa4ee45a1abdd5be16acc37b42a	2	2141	141	231	233	15	4	2023-10-25 17:39:31.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
235	\\x79eb71fafef6fd5e7091e4107f6f995497bddd2c89f72c37c3bc815f33a22a16	2	2145	145	232	234	9	4	2023-10-25 17:39:32	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
236	\\x995033a000e2e95b9b4a57d034ed1e028b9bd8812f70c3031ffd2f92756be0d1	2	2156	156	233	235	11	4	2023-10-25 17:39:34.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
237	\\xe2c2e040d5fbfcbefe47f9352efcd9fb19b56e3e73279aa3db6b4548ec134869	2	2170	170	234	236	9	4	2023-10-25 17:39:37	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
238	\\xaf28fed0012ad8d0b0ce09d7310a1c3d344f6a5797245e7b3a26b32261b7a51f	2	2171	171	235	237	13	4	2023-10-25 17:39:37.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
239	\\xf0b90a92ae6155972c4f444e994de8c722c3b7944797d0340f8c7e05124183ad	2	2178	178	236	238	6	4	2023-10-25 17:39:38.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
240	\\x42fb4892bce30caf19031cb17e9b77c3181326edfd7588a3c15aa7fd3fade997	2	2184	184	237	239	6	4	2023-10-25 17:39:39.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
241	\\x30fc38e5caa330a5dccc1019216a566bc493a2b2a91536fd885a3ef22a9e0da0	2	2214	214	238	240	3	4	2023-10-25 17:39:45.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
242	\\x83062549b68bca0b43bd068a05be16563f39c5d71862583f38bd593afab5b7d8	2	2229	229	239	241	13	4	2023-10-25 17:39:48.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
243	\\x78dfc54d8372be3c37e563a852d43535c8f4561e9fef7696d5c11e3914a12925	2	2259	259	240	242	7	4	2023-10-25 17:39:54.8	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
244	\\xa1b2d369daa6266c5942452e865fe3ac0f20765cbb4d5f9a664c51ddce5ef965	2	2282	282	241	243	9	4	2023-10-25 17:39:59.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
245	\\x90e3f551af097e731461f324b02b78a285d9d725d43d9c2a6d3658950e47b700	2	2284	284	242	244	8	4	2023-10-25 17:39:59.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
246	\\x94033bc2b386b992ae360b5c1b480ef1c8ff0da24b07820d9ca582a0893341ea	2	2294	294	243	245	19	4	2023-10-25 17:40:01.8	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
247	\\x6de96631283c2fee0ed4a4e0039c4b989618f30dc592774d5d7510e21c80119c	2	2319	319	244	246	11	4	2023-10-25 17:40:06.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
248	\\x76912e4de7885a782fdad3669b688a1774cde6817889dda57843600cb4384cad	2	2325	325	245	247	5	4	2023-10-25 17:40:08	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
249	\\x4a500ef839e79044b35265d6b05fda7e6593cd01173be8a91b7d5e197c97b68a	2	2335	335	246	248	17	4	2023-10-25 17:40:10	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
250	\\xeadff244f627509792a1b410b3a893868576504cc8cc3ab8092fbdfdb07a9da1	2	2337	337	247	249	3	4	2023-10-25 17:40:10.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
251	\\xbfd94a20d7935a505384fbc315ac27f378022a3647a85689d1561cfdfcd0cfd8	2	2338	338	248	250	15	4	2023-10-25 17:40:10.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
252	\\xdc2b9a418d5164e9b8354795342b7316672ab51e04a497e2fa3c4a4f23fadcd4	2	2388	388	249	251	19	4	2023-10-25 17:40:20.6	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
253	\\xad0b69f886a1486156a7905433e4a11c634dd0a5226f5249a4e083797f2cdf0f	2	2389	389	250	252	7	4	2023-10-25 17:40:20.8	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
254	\\xe32ac0a0cb49a42d90c10fee392f55e791075e2bc87617c3d28225aad428e13b	2	2391	391	251	253	17	4	2023-10-25 17:40:21.2	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
255	\\x37eb39939375a23b5070422375697374887ac4856a985d817803327de551b532	2	2392	392	252	254	5	4	2023-10-25 17:40:21.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
256	\\x1f558a48d8c2ab6734ca80f7aeef9313b21299349fc52c963360116d8a91fdea	2	2397	397	253	255	11	4	2023-10-25 17:40:22.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
257	\\xd57239be43525eb8cf241a3b6ae4a4c446cb12e2fec8a50e84fdb2136080833d	2	2399	399	254	256	13	4	2023-10-25 17:40:22.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
258	\\x9757ed7a47392f4418b3edd5939589c690d95cc868107bff48ce16f554005f49	2	2400	400	255	257	5	4	2023-10-25 17:40:23	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
259	\\x77f74d07b64e9749790a21d097622ed0219247ea75a60fc8ef3a0144e653977c	2	2414	414	256	258	9	4	2023-10-25 17:40:25.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
260	\\xf94b3607fc2b78bd6bdf1c249a6c74cf791c08364778a9928f23d6529a2b9f7c	2	2418	418	257	259	15	4	2023-10-25 17:40:26.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
261	\\xdee23ffefa38dba7a1e31621753c6cb1fb3e702803b5c58013edad7c411e3cdb	2	2423	423	258	260	8	4	2023-10-25 17:40:27.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
262	\\x22e486bd38a1caf4aaba50930feab7d0e8d2fcc8265e1d8a14ad665585781eb5	2	2433	433	259	261	6	4	2023-10-25 17:40:29.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
263	\\xa5645d25b0f4105e3c2baa91d8357dc721285eef17421bdd7bcd79f224197f41	2	2451	451	260	262	6	4	2023-10-25 17:40:33.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
264	\\x8b959d17f146f2f765bc3729981aac707f78515bef9ecfcc3b617d3cb5b6d0a3	2	2457	457	261	263	5	4	2023-10-25 17:40:34.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
265	\\xdfdd6e37d98778f205203a6f7fc195658e6151dae0b66a8982524e7db3dd9669	2	2464	464	262	264	3	4	2023-10-25 17:40:35.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
266	\\xddd917c9bfb871ad0317e937eb0c5e400a42dd44765a5cafb2ef9a854348b158	2	2468	468	263	265	15	4	2023-10-25 17:40:36.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
267	\\x83c94c234ef871afc343005092067d81d59ad9c6f1665261203c159723333a3e	2	2477	477	264	266	3	4	2023-10-25 17:40:38.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
268	\\x128d256dbc95342cc56e68cb1fa41cee3d0da00aff4c8fa499f99aacf7aeb2eb	2	2481	481	265	267	8	4	2023-10-25 17:40:39.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
269	\\x93033276a4bb934b1ed737dfa41cc1b74b0d1fa4562bfeb7226fc1130e96b830	2	2493	493	266	268	9	4	2023-10-25 17:40:41.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
270	\\xa30a5189c69392293eeba1d73a6800c329dbdd32c8081c6bd6f1173b8b00aa22	2	2503	503	267	269	11	4	2023-10-25 17:40:43.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
271	\\x50b217738cf0c128b7187465bbefa34f9cde7c2968bd098bdad5352c6a4cf0f7	2	2510	510	268	270	13	4	2023-10-25 17:40:45	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
272	\\x2a27e848e3580b34a0449181b4b9f7d96839fec16346393797a15909531f7c5b	2	2527	527	269	271	15	4	2023-10-25 17:40:48.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
273	\\x55f8b5008a297b8aa3974ff1d1362cd3a413234cf9d5b5158c43cc7566cae72d	2	2552	552	270	272	19	4	2023-10-25 17:40:53.4	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
274	\\x403cc10c3bebde88d7c0d2c8919378f0a5805cea21fa41fae574bc3eb5782900	2	2554	554	271	273	8	4	2023-10-25 17:40:53.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
275	\\x3feae63097ed1df21dadb1a22911462450f698e1a916df8e72821a35d5837051	2	2555	555	272	274	19	4	2023-10-25 17:40:54	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
276	\\xd9756435f05103c95bbd9b2d8a2b3daebbeab9bada9e61282e543fabbf7b672e	2	2559	559	273	275	3	4	2023-10-25 17:40:54.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
277	\\xf8ae37750101a271b4b39080009dfecbb56e98a1ef9a0be8ce5bd56a3eb2905c	2	2562	562	274	276	17	4	2023-10-25 17:40:55.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
278	\\x237860b8096c621c13e974bcbb285fdbb77f1de55ca6220be8ea06245d5b7eb3	2	2567	567	275	277	15	4	2023-10-25 17:40:56.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
279	\\xd8a19d8cf957f52a2561a6ff4fd0fdf1ea45df2acdcd36ca3601ab73b73b3ed6	2	2568	568	276	278	9	4	2023-10-25 17:40:56.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
280	\\x1b9a23ff8d81023ffc791d10f5f32a9d672985ffaf6f08e11f59f0dfbe3e7496	2	2571	571	277	279	15	4	2023-10-25 17:40:57.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
281	\\x16daba68003cbcff0bca777bfe578e68428ca51f69ce2a92c7c2a72a5297d671	2	2601	601	278	280	8	4	2023-10-25 17:41:03.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
282	\\x6cc12ae30bc40fcf4940419c56d19c74513a2ce6dbb9651551f050a24d259d8b	2	2605	605	279	281	17	4	2023-10-25 17:41:04	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
283	\\xf37b166032ab24249287af925afe7622cfe3cafc13842bf5867eeea6767b5d18	2	2609	609	280	282	11	4	2023-10-25 17:41:04.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
284	\\xa6baf7cff98682bd1846a77bfa869ceaa8e30aab1410f12ca04f114427cf254a	2	2617	617	281	283	6	4	2023-10-25 17:41:06.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
285	\\xcf2305773e32af8a947c4a4050aa1380711fb65fc1a6638ccc84c5d0ab323eda	2	2630	630	282	284	17	4	2023-10-25 17:41:09	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
286	\\xc424a6ac5314d2092d9a60800c5ee4b13e181b889f9f97353549621f53ab4ad5	2	2654	654	283	285	13	4	2023-10-25 17:41:13.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
287	\\x181cf2e416a26a25a4e48986c4d814f5008837189a2ad10f06cbe660922d8a24	2	2659	659	284	286	5	4	2023-10-25 17:41:14.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
288	\\xe63020a84cc10311ecbae8aeb8937c39a54a2a257fe33f866fd0df40165860a8	2	2664	664	285	287	17	4	2023-10-25 17:41:15.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
289	\\xd8b5078b32a705f42d72e26ed0816bcb7025798bd4448bc460cadcbedcf516a6	2	2690	690	286	288	3	4	2023-10-25 17:41:21	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
290	\\xfd1d590484776ff828435a9ce3b0e8003a798f8cf85ee81bc2625195bc7dd906	2	2696	696	287	289	13	4	2023-10-25 17:41:22.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
291	\\x0fd9227e6f2253812a512143acb76a77b1fb78a3ad0ce3802ea2fbb995503814	2	2700	700	288	290	7	4	2023-10-25 17:41:23	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
292	\\x9af02e03ee42b3f8056ca9e055e342924f3cd88554882734161c1542dd1557a6	2	2720	720	289	291	6	4	2023-10-25 17:41:27	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
293	\\xd64b678628fef675ed1039445e1631ac32e8e1524f736a878fb9d4467fa91592	2	2734	734	290	292	13	4	2023-10-25 17:41:29.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
294	\\xfeb4e17c8f1bf16e94eff5834041cf0c2bce563dd6b9c337fff64b5b76f2cb85	2	2744	744	291	293	11	4	2023-10-25 17:41:31.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
295	\\xe63a2997f3208d47184d1372578bda2a624333ce620b37ab6d991ec195abea02	2	2760	760	292	294	15	4	2023-10-25 17:41:35	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
296	\\x8add5fd92be020a150f284a4e0ba5ecf3fe0eb3ced19f3618a6ef60caa721a7b	2	2795	795	293	295	15	4	2023-10-25 17:41:42	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
297	\\xed1669f4e389ed2709a760b7e9a83ca3e997380a0d5aa992c4ddb35dfcd3066f	2	2799	799	294	296	19	4	2023-10-25 17:41:42.8	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
298	\\x9ac774975d67ca41190374d31c1d8f08995a35b58d3eb5bb801b42bacf108a98	2	2802	802	295	297	7	4	2023-10-25 17:41:43.4	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
299	\\xb210484276ca87782a79d23ea50462030a2b4171f885f630aad8ca62db7e1c7c	2	2817	817	296	298	5	4	2023-10-25 17:41:46.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
300	\\x31b81f24b49284d7f98d994c8ecf3e9da73d30d3367586dd141ec71d6314006d	2	2855	855	297	299	9	4	2023-10-25 17:41:54	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
301	\\x7e6697f01a1ac021149f8c9a837e07b94be92c2d5d2235c8af193867a92503e9	2	2880	880	298	300	15	4	2023-10-25 17:41:59	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
302	\\xfd9f62608de015b8f46598db3afc249bf984bd915812fcd228829111152cf474	2	2887	887	299	301	19	4	2023-10-25 17:42:00.4	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
303	\\x967b4eaf3fb4c88e3c3dc282137e7023180d41f6e721b2b84f16db9cc04a20dc	2	2892	892	300	302	15	4	2023-10-25 17:42:01.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
304	\\x85b6fa77fbbc54ab532b6b44047988e661c3f69c81739615b2afbb443ebaa4f3	2	2919	919	301	303	5	4	2023-10-25 17:42:06.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
305	\\x18170b718fd6a3c0c9ce426f6585e816a5d16f57ba012c085c7491b0f861d1f9	2	2929	929	302	304	19	4	2023-10-25 17:42:08.8	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
306	\\x281e33a0ff1d31f969f65f0891cb075d117ce684e6c8aed525a95ab171ab871f	2	2935	935	303	305	9	4	2023-10-25 17:42:10	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
307	\\x29b0b00a72b69938a6e241efd1d14035714884eab7185332aa5ccda53ed73366	2	2937	937	304	306	13	4	2023-10-25 17:42:10.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
308	\\x1ed00064dc99b6a6f643fa93e3ee4ac3785aab17b4b43747a81dea00337e81e9	2	2952	952	305	307	19	4	2023-10-25 17:42:13.4	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
309	\\x1d0bb24b6dc91737460768994da3275b035243c514d21ffcfa872d01bc551df4	2	2961	961	306	308	3	4	2023-10-25 17:42:15.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
310	\\x149da24013ebc00607779a7bafd8ebe6aaa8c5d301ca854accc5d09bdaff0789	2	2967	967	307	309	17	4	2023-10-25 17:42:16.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
311	\\x6479aee2989bd8f554d72c0ad279284f811c745c41749fa51b6f209309f695c5	2	2979	979	308	310	11	4	2023-10-25 17:42:18.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
312	\\x9685a2cd156904819e829c3ea9b214dfa130e36dad5bebc46790b599cd85d866	2	2984	984	309	311	8	4	2023-10-25 17:42:19.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
313	\\x9b559ac7fa281d8e4599b73f9d4963fa92602a2d13ef2091d64f61f6f68daf41	2	2990	990	310	312	7	4	2023-10-25 17:42:21	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
314	\\x60829361d3f9062cb7f9387d9308c5034d870a1185248c0c55c53caebfc9ad83	2	2995	995	311	313	6	4	2023-10-25 17:42:22	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
315	\\x3daafba23cf30c56f5b1bf6cff0334c4d427e171e75f53dc19367aace3192bf6	3	3018	18	312	314	8	4	2023-10-25 17:42:26.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
316	\\x2a56b8a5b9a6bb266c362fb36421566b7b8aef16607f21aefd38e8a584af4591	3	3024	24	313	315	9	4	2023-10-25 17:42:27.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
317	\\x3bd3533bd5dadbc1ed28b18e0833e79c64eec70dbe97024dac6333c840a0d7ff	3	3061	61	314	316	11	4	2023-10-25 17:42:35.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
318	\\xcb97dd475510ad9d5cd03a9884f349c09103156c715c60966ea66d0f3a5b1c2c	3	3066	66	315	317	8	4	2023-10-25 17:42:36.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
319	\\xcabceabbaf35c0cd114697b525127422085f8a75a4e5e3f4737b6e6b59984f65	3	3067	67	316	318	6	4	2023-10-25 17:42:36.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
320	\\x6716016b64f6df07c7c5f8241d3c1dd1c95b73604a03043f1e83cff34189ffe9	3	3070	70	317	319	6	4	2023-10-25 17:42:37	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
321	\\xae2346a4216e7ccee1b0b9d97b39d4c0219fa457d97a2fa8260b3d5fccbf030a	3	3071	71	318	320	11	4	2023-10-25 17:42:37.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
322	\\x8ffd6d9885fb93b01f54d960e8db5e02ce1c95be3d9bcef2f6a14d3cf878184c	3	3110	110	319	321	8	4	2023-10-25 17:42:45	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
323	\\x52debd430fd840879b9f2bcedb068755d7d40c90d4a1c664a5b2358662855d7c	3	3121	121	320	322	3	4	2023-10-25 17:42:47.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
324	\\xc4feeed7262295b63399c5c7c5b6cc84f2d539d0d679b2ce15c805d0fccd8658	3	3136	136	321	323	15	4	2023-10-25 17:42:50.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
325	\\x1d8c93530b89d68af7c14a59a85649212db3debda29e5feaaecbc6b7f1e2941d	3	3140	140	322	324	13	4	2023-10-25 17:42:51	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
326	\\xc64e72e4c5c7f7fa801d9df66e89c9d2a5127f7c9d3835659e26837f3ba1f3e1	3	3145	145	323	325	8	4	2023-10-25 17:42:52	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
327	\\x0a37e445b8f3f52257fb3164e99a14191405e77c4555ffbdced616e8568747aa	3	3148	148	324	326	11	4	2023-10-25 17:42:52.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
328	\\x4a8b341fae865405e9286bd84fdfec7d82d34d1be7fd59cd04be921394967ca9	3	3160	160	325	327	17	4	2023-10-25 17:42:55	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
329	\\xb703d11b773667fc797b8a4777e9e0003ba208e287113c7332d1d6769efc7759	3	3179	179	326	328	7	4	2023-10-25 17:42:58.8	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
330	\\xe76cb11156f7725d9f308ea59f521b529ebdc142b3066576ce0a123fd6da3e91	3	3186	186	327	329	19	4	2023-10-25 17:43:00.2	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
331	\\x54b65c8bb8176a570f50012167c26ebd9ffc51c0882feaab9461642aca4a55ba	3	3201	201	328	330	17	4	2023-10-25 17:43:03.2	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
332	\\x5486aa71ed4f42e650e47acf5219d6e2763680e58dbd97c7c2fce3e91463408e	3	3203	203	329	331	7	4	2023-10-25 17:43:03.6	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
333	\\x7ff7457cf78f26a14c2ad699016c05ae8cf1be3bcfec75f63f71755c77c65597	3	3209	209	330	332	6	4	2023-10-25 17:43:04.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
334	\\x0fddec4b5bcbd4b4800ab4ef2d0e1e73848d30bd343026599178e5c25371327c	3	3213	213	331	333	17	4	2023-10-25 17:43:05.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
335	\\xdcb518613e4aab184d0e2bed1106f0e48ebe14d79cac6a8f213500c7d9ce9de8	3	3215	215	332	334	9	4	2023-10-25 17:43:06	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
336	\\x298818264cea268d7ced922acf4c12b8b36b84bae9ad85a86633dd8533239045	3	3240	240	333	335	19	4	2023-10-25 17:43:11	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
337	\\x5ef09e396ba7784a836ab039582dd43a38076b36c3a105aa4289dfb8ec299f3f	3	3242	242	334	336	19	4	2023-10-25 17:43:11.4	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
338	\\xd61af81119e17f5b40634dc136df0441948df191a2a52ffe99f413a20fea3205	3	3244	244	335	337	15	4	2023-10-25 17:43:11.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
339	\\x7089ce410d67e42bc22be21658b8c3aa9e523b940e5ea001141ee4438b9899aa	3	3247	247	336	338	3	4	2023-10-25 17:43:12.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
340	\\x08351ca10b42db24f1c7fca91cadf968de0cc7964eacc189b876a5e05c5fc2b5	3	3285	285	337	339	5	4	2023-10-25 17:43:20	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
341	\\x0bc7e45bed84fb27e0a7cf5ba071adf2ee23406f1572f731f8375dbf1d26c29e	3	3286	286	338	340	6	4	2023-10-25 17:43:20.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
342	\\xc269e30c2a41e8a0968e923a29b76fd83bf38c5bb885cf837ca15008a77b2bc5	3	3291	291	339	341	6	4	2023-10-25 17:43:21.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
343	\\x1f426a44b1913f1a1f94c0474c971d6c1bf4e86692b98c27193ee615df114ad2	3	3295	295	340	342	9	4	2023-10-25 17:43:22	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
344	\\x3575823ff80a26ab61a2cce5a11ec83faa184b71a11edef306c0c90edca769fc	3	3296	296	341	343	9	4	2023-10-25 17:43:22.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
345	\\x2eb2923bfb6705673eb89bba963b7c5484b0d562781c509f44ea2e79fc99840f	3	3303	303	342	344	8	4	2023-10-25 17:43:23.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
346	\\xbc7e2ab32a44f3989457ac3d7ca0152249db29d1f1726d0edc477aff4c2766f8	3	3307	307	343	345	17	4	2023-10-25 17:43:24.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
348	\\x29124ca6bfd5b719660fb2255b9de576a476018f7f6a6a026433781123e40a20	3	3310	310	344	346	7	4	2023-10-25 17:43:25	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
349	\\x763fecea58a22230705b457759fbcdc2837ef087e7009e2b5c4ec8d01f975982	3	3333	333	345	348	9	4	2023-10-25 17:43:29.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
350	\\x1486f9a0d34288c2aa7d55a806cdc3c583366d74eef82488eba056a0e86a9f0d	3	3341	341	346	349	15	4	2023-10-25 17:43:31.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
351	\\x0d33ac285e40fa8377d88b732dd3fb84212ac033bfbb62256c5016f3b656a8fc	3	3343	343	347	350	5	4	2023-10-25 17:43:31.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
352	\\xb450179f59b81335c54da78afb68977c140cce73bb1e870ad1269f61dfc85e48	3	3373	373	348	351	6	4	2023-10-25 17:43:37.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
353	\\x7f96107f869db392abbc74ec5e18714f9d19d97948a8de5be0a9aeee43da013c	3	3376	376	349	352	11	4	2023-10-25 17:43:38.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
354	\\x2ff642ef4506a777d1876699889300fb6addc602ee3bb6790efc9674d66ffad8	3	3402	402	350	353	17	4	2023-10-25 17:43:43.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
355	\\x53526eab4ad3ab97bc7caa58836e15d80c78136235717273824fa535ecde9ec2	3	3429	429	351	354	3	4	2023-10-25 17:43:48.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
356	\\x20bdcaeab3a9bd722012307a8280c6a794223b9eae1dfa23e378cb640777a42a	3	3439	439	352	355	15	4	2023-10-25 17:43:50.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
357	\\x0865b52a116fb11e717fec6650ceecd6fbe49b97e2e3343e2150ac34e48de498	3	3449	449	353	356	13	4	2023-10-25 17:43:52.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
358	\\x3937adda84771d7758fb45086cd337402df53ba046e08ae2ea5d3c705d023ef7	3	3450	450	354	357	19	4	2023-10-25 17:43:53	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
359	\\x7ebebedafe29e24b1a5e0858a7c5b7b85f83355cc680c39aaafa936507ddcc13	3	3466	466	355	358	17	4	2023-10-25 17:43:56.2	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
360	\\xd1b5f13b3f4a3500d6a1422737570467e4bf74408574943044a802b121ef9433	3	3510	510	356	359	9	4	2023-10-25 17:44:05	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
361	\\x6daff1ca8b123a726708e1b27820f2b25c8850b25f8d5efa7d6d739328242c55	3	3517	517	357	360	11	4	2023-10-25 17:44:06.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
362	\\x35f2c7652282271728d6a2bd20b2099922f2c0dd4996ed46ff31f6761518bdd7	3	3525	525	358	361	5	4	2023-10-25 17:44:08	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
363	\\xdb8f031aa7e27a19098c1fe4678f6bf74bafd49d5ee42014f1d68670cb675c7c	3	3530	530	359	362	13	4	2023-10-25 17:44:09	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
364	\\x3deb4447afbddcfd0c803b4e90b3a7a412ff0fb789a6487530e3e4d7723a5aca	3	3540	540	360	363	15	4	2023-10-25 17:44:11	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
366	\\xabaa8fc8fe93c29a4280e5514b1769cb534944eedca990fca4ce1cc1a34b5a6a	3	3549	549	361	364	9	4	2023-10-25 17:44:12.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
367	\\x1e39743e080de5ab7315e5c381a938e5303ba27b5ab12450f95d0343f7df16ac	3	3563	563	362	366	19	4	2023-10-25 17:44:15.6	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
368	\\x73887d903d1c6bf35ef28147bd64b18cc8cf946b5153e59e9c0f333feb289a72	3	3574	574	363	367	3	4	2023-10-25 17:44:17.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
369	\\x0a259678754c3e73172b28726946e7083103f13e60ff87161b464dd1e46eb43e	3	3594	594	364	368	6	4	2023-10-25 17:44:21.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
370	\\xb2d314266b4e69ef394e46424194535ac21e7c6fef768ed0da5f230ffa835958	3	3607	607	365	369	11	4	2023-10-25 17:44:24.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
371	\\x09a5117b1c3afcf08b437ff9b54d426bb570a12b54db552367377ba0484df34f	3	3610	610	366	370	15	4	2023-10-25 17:44:25	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
372	\\x604201bbe1490386b98c655fa75c7605b74a9f40c8227ea92860af7617ebf666	3	3616	616	367	371	13	4	2023-10-25 17:44:26.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
373	\\xe13af51096031c943e59cbfe8e10c0fedc20a40c2e5dc27588bb505ee03db913	3	3617	617	368	372	15	4	2023-10-25 17:44:26.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
374	\\x697ac3c02adb2ece1b514d47b3a610056ba9436a21e5f6b0bcea21adb67e4939	3	3625	625	369	373	7	4	2023-10-25 17:44:28	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
375	\\x420c53afc7be1b89459880cf67223eb7b1eb271f0a566c472bbae4e78db3f9fe	3	3629	629	370	374	8	4	2023-10-25 17:44:28.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
376	\\xa2d259a7fc267654f2156824c76b7c1e59ae392212d3ecae920ad210b7bb269e	3	3638	638	371	375	19	4	2023-10-25 17:44:30.6	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
377	\\x91fe3ed48d13f9f39d2f645093f21a03a7e67dc5ef762943559b1c2f09cc5b3e	3	3639	639	372	376	17	4	2023-10-25 17:44:30.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
378	\\xf426336e0f186bc44d898f55fd8993cff9641d08d3f4d58c7660202ef9e1e805	3	3640	640	373	377	11	4	2023-10-25 17:44:31	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
379	\\xa4c7d50e7b2a704d1236cadc180c4ff9de76abd48473fcff61c98bf6ffbf7af5	3	3643	643	374	378	6	4	2023-10-25 17:44:31.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
380	\\xbe95e344ad8e4efe48322b15254d4e19ffe1ba6a07d5d1cfbfc2c6110d0baf47	3	3652	652	375	379	8	4	2023-10-25 17:44:33.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
381	\\x2a0eeaf0eb037b678b983b4b26a3d7f3cc46ab308f1bfa6cceeb82897800dfb3	3	3663	663	376	380	5	4	2023-10-25 17:44:35.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
382	\\xd7710be03e3e250c0b24d496e774723540d08a775656bb930bb3dd05ed125741	3	3671	671	377	381	7	4	2023-10-25 17:44:37.2	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
383	\\xdc154fde5235a60ba3659f1ea1f2cff81c8eb30a64b7e017742afd108d52199e	3	3675	675	378	382	3	4	2023-10-25 17:44:38	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
384	\\x72a74c0b4a4f33afd8291af381b76ff9db6e8f6dfd7309e5a337cbb6d3a54a12	3	3678	678	379	383	7	4	2023-10-25 17:44:38.6	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
385	\\xc0042426bead277ec078dffde84a828f119ecce1e2cda7323773ed95e86bc9fc	3	3687	687	380	384	19	4	2023-10-25 17:44:40.4	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
386	\\x1632565edfbeeb708ef531c999a3e4aa470f00c30c9416ab13a39bf3b9c52894	3	3688	688	381	385	19	4	2023-10-25 17:44:40.6	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
387	\\x8f9b7c2b278321bd8d597e7e333e0eab2222d7cacfd9d71ce92faf2b074d5099	3	3693	693	382	386	3	4	2023-10-25 17:44:41.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
388	\\x9541ed7954ef33c5d7ba8fb5e1634f73ad0aebd07b36a5ce1cbd1071f4bae7f9	3	3695	695	383	387	8	4	2023-10-25 17:44:42	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
389	\\x0573bb7a60732c63c6c3822cca8bc5d94d591b4a7152cfca33324bc7fffeff91	3	3701	701	384	388	7	4	2023-10-25 17:44:43.2	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
390	\\xba11bd0dc9ee7f5a46c3c4254bbd4f577c5052ba9316631e9efea61bdf89ddf6	3	3706	706	385	389	11	4	2023-10-25 17:44:44.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
391	\\x3f3b454f32775f91aebbab1ee57270978f4981e4e20e89a1daaf4b6a1dc9dbca	3	3722	722	386	390	5	4	2023-10-25 17:44:47.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
392	\\x6012c9f9b5eaabc2fc0a119380665e0b57d2277789409b557606d4d599efc5ba	3	3730	730	387	391	6	4	2023-10-25 17:44:49	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
393	\\x070fddb3ca4c5e9adee9011ebe340810bbf4d819c460364d348397c71efd63f6	3	3738	738	388	392	11	4	2023-10-25 17:44:50.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
395	\\xc5753a6fb5030b68490d9d1aca11bb4a6b7e7595d7be37f02e3142495904a439	3	3742	742	389	393	7	4	2023-10-25 17:44:51.4	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
397	\\x69b075a0695bcdb800621a78c89903f1843c1e43f2ef123fa6f502ba38fe661c	3	3749	749	390	395	13	4	2023-10-25 17:44:52.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
398	\\x21aea4a321fa58752307c45ea2fbb63e90b1c9d41e6db55e3d10d522826761a0	3	3752	752	391	397	11	4	2023-10-25 17:44:53.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
400	\\x24d66b88da44bcb0416cae56bd25bc4fe8ea511f6b2b8734bb24bd2a7fb446bc	3	3768	768	392	398	3	4	2023-10-25 17:44:56.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
401	\\xd5fae7ce69b9214d212ab59d088fbe51f527c0546e70851c49312b257e31a36f	3	3787	787	393	400	3	4	2023-10-25 17:45:00.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
402	\\x6f3987d318d4773562f569ac9d9518e831a5c0451816687c76acf196b9d8f154	3	3799	799	394	401	17	4	2023-10-25 17:45:02.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
403	\\xebf1a97f2eff08549253f722486f1e1b692cccc4e22b21572bc7039f28fc7f82	3	3815	815	395	402	17	4	2023-10-25 17:45:06	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
404	\\x33a665b5af86fa2a85ff735c7bc1716eb51107c1cf85831446e2ebbe278161ff	3	3823	823	396	403	17	4	2023-10-25 17:45:07.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
405	\\xacb8a8252430886a38c1afd913fa05537fa976dc8425d7dee870b094546f0abf	3	3833	833	397	404	11	4	2023-10-25 17:45:09.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
406	\\xcd88eb6ab259c8be04427a762da8099f0ba27436db3d1f43ee99afba970c05d2	3	3837	837	398	405	8	4	2023-10-25 17:45:10.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
407	\\x2a46e278cc97bc13ac384401d1f3384edb5d3b6386fbf0d395e778a244ff975c	3	3846	846	399	406	6	4	2023-10-25 17:45:12.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
408	\\xcc532c0c4074cac16ecff5e82c3b8fe6404070662c09eb794a40c09017fbb9a4	3	3853	853	400	407	11	4	2023-10-25 17:45:13.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
409	\\x9ab879554587fac4cb7eeaa532f2aa9a68ce3ae8b335932d36dfb2855e1dbb4d	3	3858	858	401	408	19	4	2023-10-25 17:45:14.6	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
410	\\xfd347d4677ac685335d5896ec9bf7e5afcefaf8ceed2b17b7b256fe441c355a0	3	3865	865	402	409	8	4	2023-10-25 17:45:16	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
411	\\x7e3976a3254913b6a94e2140e49f81f5905b96f28eda9f0c65d38c015aeaebe1	3	3867	867	403	410	6	4	2023-10-25 17:45:16.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
412	\\x9c0470d3ed3e6b23a776f3b5605a601a4bc661b51f37ccf84a16cf269ade3ef5	3	3869	869	404	411	8	4	2023-10-25 17:45:16.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
413	\\x9aba2b003ded402f565b49e9af01fcb561e3c634ab6ffe5db52a543b7a1cc7b7	3	3883	883	405	412	7	4	2023-10-25 17:45:19.6	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
414	\\xd7400218531716e936bba4aec45b0558818817e48f75e40bc41fd7079fc36d07	3	3912	912	406	413	19	4	2023-10-25 17:45:25.4	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
415	\\xeb324889a6d228e73f4b8b65faab8247fb24b390513ffd40499277a044bf1c65	3	3921	921	407	414	3	4	2023-10-25 17:45:27.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
416	\\xa8fe5184e76c41306f85e24e8d40f751d76ac49ea3fd7c58bae1305816305c8d	3	3945	945	408	415	8	4	2023-10-25 17:45:32	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
417	\\xbbc8d07562881f46dc0795f672dc4417bf36c760defa2b3e95f386a520717635	3	3960	960	409	416	5	4	2023-10-25 17:45:35	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
418	\\x94728a2cae4805548aa01b11ed64fd2688cb7711005ac919e3937e55b8209fc4	3	3963	963	410	417	9	4	2023-10-25 17:45:35.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
419	\\xe07e9dc83f84b8a744b2ed939437447602c37528414f492ea993ba5b3898e32b	3	3971	971	411	418	7	4	2023-10-25 17:45:37.2	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
420	\\xbb6be4bab8169f8b981c0d6726d225ff21d4ce9557ee297df638d0fbecdd5928	3	3977	977	412	419	3	4	2023-10-25 17:45:38.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
421	\\x886a53006e2222d6170bd3ba0f594b49b90fbeef0edf70af7570ee2a8faa3339	3	3979	979	413	420	19	4	2023-10-25 17:45:38.8	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
422	\\xf25202e1b8ee2f2035d1e20c0e84a44662240933eeabc6ac3dc1a6ccff7b24d3	3	3988	988	414	421	8	4	2023-10-25 17:45:40.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
423	\\xa0b11447a9a992ed79d7e18df9ec98073c224d02f76a5efed3336975e1e50054	3	3989	989	415	422	15	4	2023-10-25 17:45:40.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
424	\\x3afdf41cbbb61b73474540234931ad70558ff87b01aa28b79f2a5962cc992b90	3	3996	996	416	423	7	4	2023-10-25 17:45:42.2	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
425	\\x57b82932a569b36906e09e9fa7af4ef12825ebbf58aabab0fafc7955649a58a2	4	4007	7	417	424	9	4	2023-10-25 17:45:44.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
426	\\x9fce3e9317b9469f1f44f42189d1455f61f7d551dd5eee7cd43951814cbfdded	4	4010	10	418	425	6	4	2023-10-25 17:45:45	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
427	\\xe252b85dd0d11a436f2467b62c711fd1e4605009e36ec9dab599e14c87bc0919	4	4021	21	419	426	11	4	2023-10-25 17:45:47.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
428	\\x898e9105775bf134027d755d0bf468f4eb861dcc4603fe7b3114ba5e32aa386f	4	4033	33	420	427	3	4	2023-10-25 17:45:49.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
429	\\x98fb709c04643fb7151a23fb3d0cf7dbdfd7c55da8192b30dd2dc43a9ef8fb3a	4	4042	42	421	428	17	4	2023-10-25 17:45:51.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
430	\\x1ecd987cb14341b5247c936e03bd9093ffd0fbc4a0f9b37e4a47b2e78d6e77e4	4	4063	63	422	429	9	4	2023-10-25 17:45:55.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
431	\\x262cf6fc6c3a5a231962f56e1dc8c51fed5f7e2be88e67aa74add43bf584772b	4	4070	70	423	430	9	4	2023-10-25 17:45:57	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
432	\\x3ea000cb990c05a207fb7ddcd4560f544ec0385a3b5107cd64d219baf1feced5	4	4078	78	424	431	17	4	2023-10-25 17:45:58.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
433	\\x1afd6ecaf4504f1b5d714c6b7b71f2b2501f18e2ad853d6705f3d5a889ca05af	4	4105	105	425	432	9	4	2023-10-25 17:46:04	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
434	\\x2185c46231e055023ab1add23d050d6ae17b7c65a742a3dbee9846e61567b2af	4	4113	113	426	433	7	4	2023-10-25 17:46:05.6	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
435	\\x86ba20d044ce403f38d94d2f36df2f9cb5b3c919ac3162b1eb8301fb00f16ff6	4	4124	124	427	434	13	4	2023-10-25 17:46:07.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
436	\\x1b930aaefd75a40a5fde869303024076cf51e9825461aa519b669c189856a172	4	4134	134	428	435	15	4	2023-10-25 17:46:09.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
437	\\x3e99822944f361de91c6d7ec141e485fd4006b66f297c2a142bd317769c36877	4	4153	153	429	436	5	4	2023-10-25 17:46:13.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
438	\\x27566e5c2fb157487f5891cbfd35839a8c0041ea8a96c01fc9c2e16bb844f0a8	4	4154	154	430	437	13	4	2023-10-25 17:46:13.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
439	\\xabdcbf42dfa68be5fd59cb99a5d1a6eeaac2e62440756c71fa36a0a37f8b8926	4	4156	156	431	438	15	4	2023-10-25 17:46:14.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
440	\\xa490ee3f823f61a52c929b9f748dc86ee0953ce984c370733b47378b8aaabcac	4	4165	165	432	439	3	4	2023-10-25 17:46:16	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
441	\\xe670419966562d04bcb530dfc2e98c62be4da3bc5b580d0e2fafa71e8fd2390c	4	4170	170	433	440	8	4	2023-10-25 17:46:17	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
442	\\x8cdd4bab8eef8364b7617bbbb7f40fa3e9580b1dda12fa28f4ef2e618dff93e2	4	4172	172	434	441	17	4	2023-10-25 17:46:17.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
443	\\x20e544c0974573abaed1e99c08d0b2500c1da841ed17036fb35e74438c6e1cb6	4	4173	173	435	442	19	4	2023-10-25 17:46:17.6	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
444	\\x85b320a42f3483bc3176b131e88ba9c62149ddb4ba684d426f7d58e920bed9a8	4	4184	184	436	443	5	4	2023-10-25 17:46:19.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
445	\\xce24cd3343e54464371d08ee959f7e7d13fc0ba50b94266576eabe8e2e7dbf54	4	4187	187	437	444	11	4	2023-10-25 17:46:20.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
446	\\xa04310a35fea23c685d5f1e42d30533b3f84b4ef297d80c052553aae2aafb908	4	4193	193	438	445	8	4	2023-10-25 17:46:21.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
447	\\xd0c198dd2458f26ce9d452dc4e70e4f8a0c124914e3f8c97f6e79a4dba907812	4	4208	208	439	446	9	612	2023-10-25 17:46:24.6	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
448	\\x8673ed6eb67e747eddea4209330b30bfaa52a9a0faa96a82e7688703fbaca811	4	4209	209	440	447	6	365	2023-10-25 17:46:24.8	1	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
449	\\x7019c1c0088003219fb6441fe5605f50f715e60ade1c26307c68b897df0f242f	4	4213	213	441	448	3	4	2023-10-25 17:46:25.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
450	\\x4828ec88d43e2d86a19acbeb3d8df2e97a2e27f673e3eda243d8496302ee0eca	4	4233	233	442	449	8	1704	2023-10-25 17:46:29.6	1	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
451	\\x1052413ce0b977eae956ace4fdfb2342b773a13087bb504bd7331638da629ff7	4	4253	253	443	450	17	4	2023-10-25 17:46:33.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
452	\\xce8a3a1c38a597c4493d9355a477e8adab1f44d7046ddf2c72f0b5442f95feb7	4	4258	258	444	451	6	4	2023-10-25 17:46:34.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
453	\\x8b96a56c062639056a5b0fbc9e3a99b075dceef94ea6c37a6e33e2e5a4c0d3ec	4	4303	303	445	452	19	4	2023-10-25 17:46:43.6	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
454	\\xd6522d6e0f986aa4677a275cc4b2d16c030d67cd51bb9999b53776fb7ecb9af4	4	4313	313	446	453	6	430	2023-10-25 17:46:45.6	1	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
456	\\xc94ab7c8ca726d681f54d30ba21069dc0f9efb376cd6652930b64d6a44a09e0c	4	4321	321	447	454	13	4	2023-10-25 17:46:47.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
457	\\x1a86b46961b76148f804dcdee646218eb4997ab677d157ae7f59dfb357f2f713	4	4337	337	448	456	3	4	2023-10-25 17:46:50.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
458	\\xa16403ad835855444096e93b42b6368dee0e62076b38ad724737fcccf47fa1dc	4	4344	344	449	457	19	4	2023-10-25 17:46:51.8	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
459	\\x754b0a74f19763b45b6f23c34381f3ac649a58b4e955ed69c36846a4c7e2cd98	4	4354	354	450	458	19	352	2023-10-25 17:46:53.8	1	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
460	\\x60043508db8a8f49151cc69877355c75ee9c73b5f95fc3cc74b26e76080357e3	4	4365	365	451	459	11	4	2023-10-25 17:46:56	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
461	\\x33947c0d932e8ddbf498ef2ef5f1d321c3ff5fa32fdb7040a8c9cb46244ec335	4	4367	367	452	460	17	4	2023-10-25 17:46:56.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
462	\\x507536600c0b1e7f7598cd39e2e9a09165a49cb484a261315c00e6fc5cfa6c12	4	4369	369	453	461	9	4	2023-10-25 17:46:56.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
463	\\x4a4cabb8338ee0f57646e3d1b1f2bff3e6d9e37bba4bb641b5c756f81b37c202	4	4371	371	454	462	9	321	2023-10-25 17:46:57.2	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
464	\\x351bf9050f3fb51a5dcaa6ad8a95589f8f7a80d937d162007ace9fbbcb420425	4	4390	390	455	463	5	4	2023-10-25 17:47:01	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
465	\\x0d9492e3d97691bfe1d3b5df4b89341e02d3468c68f1fd864f4f3b4d14bd4b60	4	4395	395	456	464	3	4	2023-10-25 17:47:02	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
466	\\x49b196e616cd10f3ec271562f6b21bc3c2d4192aa63e03aa868c355ebcb8b6a2	4	4407	407	457	465	15	4	2023-10-25 17:47:04.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
467	\\x241b3f7b15892693218c7d5d2ff2ac30834da721d2175093c24c78d70b3726b6	4	4411	411	458	466	11	401	2023-10-25 17:47:05.2	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
468	\\x7562caddf4a6a87638c6b4459583201e775132543ed98a4ecf792d0d9737d05d	4	4418	418	459	467	9	4	2023-10-25 17:47:06.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
469	\\x924bb843c90a58d67e5900401a741b11a435bebcb7b60fc2934cf64e796de727	4	4429	429	460	468	8	4	2023-10-25 17:47:08.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
470	\\x819b92883a10c5acf9dc7e7d2ff68e58d4a6b75a4473c405475ec505c98e1575	4	4443	443	461	469	17	4	2023-10-25 17:47:11.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
471	\\x07300ab368f3fa934481bd413504b5ca33842638fe3058b96f4373f2bae2e319	4	4445	445	462	470	17	749	2023-10-25 17:47:12	1	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
472	\\x352fb727e95dd3bca7c783ca6832d0f35ec536687dc2cdde1543da79e31f5d9b	4	4455	455	463	471	19	4	2023-10-25 17:47:14	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
473	\\x5714d467575d06c0f61401190b38e68db9c71f010c0e7f77570e93207938e542	4	4460	460	464	472	13	4	2023-10-25 17:47:15	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
474	\\x3d27001acd3259767c395d97937030bee3b70205fc2565edfab08aff29cad0b4	4	4478	478	465	473	9	4	2023-10-25 17:47:18.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
475	\\x233a6e867d9a5d0750e17f7c8ba1923d9116c8cd7630f46300f700ecab4fbe63	4	4485	485	466	474	7	827	2023-10-25 17:47:20	1	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
476	\\xd193a86aa947045c2850d555485646a03b2f233aaa4c04903b63b9bb00dcd4fd	4	4509	509	467	475	11	4	2023-10-25 17:47:24.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
477	\\x16009aa31c757391e67c95a65ef7ba45bccd0d5d6d55c4e6f70dd26b47025074	4	4510	510	468	476	19	4	2023-10-25 17:47:25	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
478	\\x158d73b121590fbbe70c5007e279018cfb3362eb9979881432bb197c05b2a7c3	4	4513	513	469	477	6	4	2023-10-25 17:47:25.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
479	\\xcdb8f4b56cb40ddd8cbc7701a83525205dfe87d151ec0c4bf0467ecdd6756891	4	4532	532	470	478	17	340	2023-10-25 17:47:29.4	1	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
480	\\x986728209c0d3b08c812dd5922015f2f11ef2f4664900604d2d59cefb4787872	4	4545	545	471	479	9	4	2023-10-25 17:47:32	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
481	\\x58965fe4426485fb22c56c6b26b01838f355920bcec242dafb05e882e3485665	4	4560	560	472	480	15	4	2023-10-25 17:47:35	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
482	\\x2ad9c94955e44ba206ce27ed3653cb011687d64fd51815631ebf30c139ca560d	4	4564	564	473	481	7	4	2023-10-25 17:47:35.8	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
483	\\x50c46626b0c24565f4f65eb9f04b7697ff5fc02944dd613740ae2f5a36c967cd	4	4576	576	474	482	6	749	2023-10-25 17:47:38.2	1	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
484	\\x0d4353c197fdd627f1675b5786e49608587c52169eb195d0829744ec6f641824	4	4591	591	475	483	9	4	2023-10-25 17:47:41.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
485	\\x679a31ffe1dfb9df3e9e57c52b0465e90d3633fd023e0e52be18ccee29f7f2e5	4	4604	604	476	484	17	4	2023-10-25 17:47:43.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
486	\\x369254bd147041b24bf5b0016f0c6355cd1dc0296d9b88671f3520204062e15b	4	4607	607	477	485	15	4	2023-10-25 17:47:44.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
487	\\x691b2a7a5e6590ac26c30f049f343ba5731482b71af77dae773e30a636bfbaff	4	4629	629	478	486	17	300	2023-10-25 17:47:48.8	1	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
488	\\x7ad40c85b71fb8e6549dfebe39af4818b3f5502fce4a44e6857cd8f3ddcb29b1	4	4643	643	479	487	9	4	2023-10-25 17:47:51.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
489	\\xca4ef5ed6caa45b615a2adfece57121949bb286cf091d76405e1f6c0388ad042	4	4667	667	480	488	11	4	2023-10-25 17:47:56.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
490	\\xb37ba54fea30029c5b81e3ba5b63314d0a6b523cb437e500b452cc5eff34dfe2	4	4682	682	481	489	13	4	2023-10-25 17:47:59.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
491	\\x2d43af709c7f415768850314e081ff09204e9926a94c6e514d52d632ce29e8e0	4	4703	703	482	490	11	785	2023-10-25 17:48:03.6	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
493	\\xfe8a7019edfc529920d98071e4fd8634599604c6fcef02e622b2821530972033	4	4718	718	483	491	7	4	2023-10-25 17:48:06.6	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
494	\\x425e2c09c7bae9d1cd9f46470e9b75075149621fd68de86bac17267e8f782fcf	4	4724	724	484	493	9	4	2023-10-25 17:48:07.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
495	\\x48e94414548921bea452e3e3667ff49a5f936f20910c23e5f0ce5fbc23542e08	4	4752	752	485	494	15	4	2023-10-25 17:48:13.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
496	\\xf8d277c33ce9ef8bd7564c7c5baae812ee7538c68c9e96c5b4fd12ec7ad5bf6b	4	4763	763	486	495	11	342	2023-10-25 17:48:15.6	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
497	\\x46ae9c41fa4b753d21d8a3a87cc43c4ba1bf184782401c65e13f4d91b7cef028	4	4772	772	487	496	3	4	2023-10-25 17:48:17.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
498	\\x6b19cc9c407d42967ef8ae5012832dc6882cd361e43939099333f62bddd6906a	4	4794	794	488	497	17	4	2023-10-25 17:48:21.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
499	\\x3760bdd0b7a5c74d29786ca3c0178c0857bcf608bd622d7a0c35c11623dc801d	4	4801	801	489	498	8	4	2023-10-25 17:48:23.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
500	\\x601c848931f6b9057e494279d22bf78a936521cb1e896873d625c3fdc3d11df8	4	4818	818	490	499	11	300	2023-10-25 17:48:26.6	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
501	\\xdef9a5aa116edfee10ae548321a5526ae79a866162f1f491151895b0d45f5f41	4	4821	821	491	500	6	4	2023-10-25 17:48:27.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
502	\\x5ecb67b58b5cf782a0c49c19fa644848e8770caa0648395fb1ded3eb6aeb5d79	4	4832	832	492	501	19	4	2023-10-25 17:48:29.4	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
503	\\x5c11ca0ef5230b06c823193ad6d2bfb546c5a611edd9bc62a5e4ffd0bda5268b	4	4833	833	493	502	3	4	2023-10-25 17:48:29.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
504	\\xb59ae6c3ec8123ef425e4d75fec50422113c407525759f1611cc81e73a28381b	4	4841	841	494	503	9	4	2023-10-25 17:48:31.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
505	\\x2d13d95fabdca43b3c228aa01fcfe33ef24df4dbe80438fc4fe2955b36541e48	4	4842	842	495	504	19	4	2023-10-25 17:48:31.4	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
506	\\x791901dc41cef10cd3ae4ee3033e0df4aa8bccf3a5d9a5cf733bf6d0c28d9bdc	4	4856	856	496	505	17	1140	2023-10-25 17:48:34.2	1	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
507	\\xf738d32ad30e1cea7dd8575f6e152c39ae7def80b91a3dd74e89aecf2b74e028	4	4857	857	497	506	11	4	2023-10-25 17:48:34.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
508	\\xf42d7ef7e54537b069942b8f897212c8c0bc4e3d7ff5d870b9406f863d722df9	4	4859	859	498	507	6	4	2023-10-25 17:48:34.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
509	\\x25f0755a409b17b6912c7d9a4cb6522d8d385b3ed43c01c75ca5767e65fcbe7c	4	4872	872	499	508	11	4	2023-10-25 17:48:37.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
510	\\x3051caa75e0de89c0160754527310defd86167025ef165ae3ef7f08caf85abb6	4	4899	899	500	509	15	562	2023-10-25 17:48:42.8	1	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
511	\\x06ab5c5e10b03451bfae2a4d0b63b73d104a999340ebacd5b3c0eb331c0b6b5b	4	4903	903	501	510	11	4	2023-10-25 17:48:43.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
512	\\x8eae29dc8d4fb03632b279f5d4fd28d16d160f3471d7fb8f3c8c4a18ad2fbabd	4	4913	913	502	511	17	4	2023-10-25 17:48:45.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
513	\\x3d9b01bb7831cc3e2948cbba3acee6241b3385c43147d1a161e86c7f42fdc52b	4	4925	925	503	512	19	4	2023-10-25 17:48:48	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
514	\\xfebb66100770a5001932e8b211e7603dc813cefce39075ccee4042621846b341	4	4935	935	504	513	13	811	2023-10-25 17:48:50	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
515	\\xd5d22d99c765667eaec3549c178d86c605ee844f406742390528f82e51bc5777	4	4936	936	505	514	11	4	2023-10-25 17:48:50.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
516	\\x983b9fbd1f1376b10deb9217e8a04d4031f7d66872a7a2c66cafc223edebe43b	4	4940	940	506	515	7	4	2023-10-25 17:48:51	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
517	\\xdadc26df21e88c464bf679a0f4ff8c5bd9ff49178e7abef851e932a5e1cc4935	4	4941	941	507	516	8	4	2023-10-25 17:48:51.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
518	\\x165776ebbc1fb7ab8b78d006a7c8ddf92387aa23285aa2a3bd5df0c6170836bb	4	4948	948	508	517	9	763	2023-10-25 17:48:52.6	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
520	\\x01db7da156e44568bb994d8ea15e9cf581f51e391d91badbc2b727db3857007a	4	4951	951	509	518	6	4	2023-10-25 17:48:53.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
521	\\x776540fb2588f3f331401190011cbeebed8dbbc9eefe58774edf764cd4372b73	4	4952	952	510	520	5	4	2023-10-25 17:48:53.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
522	\\xf9a973da38d0fd3b2dccdcb0da2eed2d33547316b110cdd5958f81f59f13633f	4	4957	957	511	521	13	4	2023-10-25 17:48:54.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
523	\\xfc8b0c501401e201bdbc905a6a2c17a14a1a35c30ce9610d5527790669b1d533	4	4961	961	512	522	19	762	2023-10-25 17:48:55.2	1	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
524	\\x798667b49eb709354268cee7c2f24df187ba8300ded6df76fc54eb17197ed395	4	4963	963	513	523	9	4	2023-10-25 17:48:55.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
525	\\x40b2436dc533c21149ffd221686bf0df289f3c634beb829d16c40e580f8fc42d	4	4964	964	514	524	13	4	2023-10-25 17:48:55.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
526	\\xa687ca69dcdede3054f28115634833ef5fbfcd0a697d261e5731782095a0ea4d	4	4978	978	515	525	17	4	2023-10-25 17:48:58.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
527	\\x601249c71343c3c8e0a90e0766f577147b90eed7b25811a3f72e805591e3c779	4	4999	999	516	526	19	539	2023-10-25 17:49:02.8	1	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
528	\\xb2022b2581acf13483fa2eab39a5d85023e834f76a27c8318978436d712965ab	5	5003	3	517	527	17	4	2023-10-25 17:49:03.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
529	\\x7b4a1d72fbf0c04932ec8253119e1b7a1eaef2d0b2121bb37785c4e2cf78c927	5	5009	9	518	528	9	4	2023-10-25 17:49:04.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
530	\\x201d4cbe300c4b9b574d44e5bfa3dacb05eaad1c6a25a1113dccca8068feedea	5	5010	10	519	529	17	4	2023-10-25 17:49:05	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
531	\\xe064a065d8283b6ac3a1ef65ea95f43e9d3fe030598b575bf045ebae7cd34acd	5	5012	12	520	530	9	4	2023-10-25 17:49:05.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
532	\\x9dab8bea5e4f76afe804aeee8f99019fcb6f3150ae24d4347d0395746c7a141c	5	5018	18	521	531	3	4	2023-10-25 17:49:06.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
533	\\x2a74bf798aef7ccd7a1509d12ebadc50b672ea1634f2f6d918b3d6f3c58b2e2b	5	5023	23	522	532	17	293	2023-10-25 17:49:07.6	1	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
534	\\x7acb12f5e4dc26c40bb860d3395a2ad9733fa45ce8fb6ddb64fc3034e5aecbbe	5	5085	85	523	533	13	4	2023-10-25 17:49:20	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
535	\\x20091ad9486da8e85d76e35e198ca54a023e2eb3525f6373f5711e28f092c474	5	5086	86	524	534	15	4	2023-10-25 17:49:20.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
536	\\x9cf1d42a601cb6d6f0513b010cb13c2fada1d7b5fd63d234b410a485c7be47e2	5	5114	114	525	535	13	4	2023-10-25 17:49:25.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
537	\\x071dc36eb54cddb134486ef85bfac58a94831fb6483de926f4c57eb361c5e582	5	5130	130	526	536	13	3850	2023-10-25 17:49:29	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
538	\\xf4763142f7b99b9e08e1816187bcbe77b808ec50206d65ba2e080f7f29856b52	5	5144	144	527	537	15	4	2023-10-25 17:49:31.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
539	\\xc1a964b9fffedbb0e8e54d2fbbb9a2a0483fbfc46d14dca1f623aa5055a8714d	5	5164	164	528	538	13	4	2023-10-25 17:49:35.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
540	\\xb3050ffe43879d3386568f284a2af18eeba8c8448f48ebf9fefb55cbbce4951a	5	5176	176	529	539	9	4	2023-10-25 17:49:38.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
541	\\xd84f00d655d855473c107d206804630db616b50d1757e98341c5cb4803bba4a3	5	5190	190	530	540	3	2398	2023-10-25 17:49:41	1	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
542	\\xf4088f0464d0eea20dce0e819e9cc7d57ccf25f94217c94f72cb68b73b23e2ff	5	5202	202	531	541	17	4	2023-10-25 17:49:43.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
543	\\x36ce2eeeb15148ceb3a228f734672f2a2b1b37eaf39115a59199b28caedda41d	5	5215	215	532	542	3	4	2023-10-25 17:49:46	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
544	\\xe8c257021bc0d5ca4ad47f676d7c515429e29e2ecdff62e02f99af578fde003e	5	5239	239	533	543	7	4	2023-10-25 17:49:50.8	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
545	\\x9a394b2f777894346329eba893536521c44e8ce9f86c407ffa6f8ecf294906c7	5	5261	261	534	544	7	1051	2023-10-25 17:49:55.2	1	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
546	\\xd7afeddd5b26ba461ab24600e256a5c57a31feea826463844964f2fe12f09b2b	5	5280	280	535	545	5	4	2023-10-25 17:49:59	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
547	\\x86a437b588c33281725b483bf0ad2627721fad6e016845cda833d37b1f631bde	5	5286	286	536	546	15	4	2023-10-25 17:50:00.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
548	\\xdbf23a14b55611d2ef53d8eab3b28b47a767e2bcc2e820f4c2d83c20a5201afd	5	5287	287	537	547	6	4	2023-10-25 17:50:00.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
549	\\x7210af7373eb4cef9a42a6351aacd532214faea93f6ed4655bc985efc68ea40c	5	5291	291	538	548	15	4	2023-10-25 17:50:01.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
550	\\x9ceb9fc13d7e96e5e28a9044f3704ae4bfa7d80eded75fdcc3efab91a5afa7e6	5	5304	304	539	549	13	501	2023-10-25 17:50:03.8	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
551	\\x180a134df63740497da7845620b22f505aacc4b2813e71afe5960650a66b521c	5	5305	305	540	550	17	4	2023-10-25 17:50:04	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
552	\\xb2e85e83a7927be226dd7e08b6865e7568de41fbdbb317a3c1e72ec74b9ea6d6	5	5319	319	541	551	7	4	2023-10-25 17:50:06.8	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
553	\\xd41a17a5986c908a6d358c40772018c7c1d182809c36eb8c0ca78fe4d4a37742	5	5330	330	542	552	3	4	2023-10-25 17:50:09	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
554	\\xc6ad7b59e1b8ae7d5560dd9ea38358ee4a659a20d62a8e6943c9ba6eb5e51680	5	5333	333	543	553	9	4	2023-10-25 17:50:09.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
555	\\x6bfada428d0335936828b3a7c0999427b73138a4c3581b0dcd738ec01e482ce5	5	5335	335	544	554	19	397	2023-10-25 17:50:10	1	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
556	\\xacb35d6ebdef3367e88d5450e8dbf4722b26df652c9ee6ab891d1a895fc66302	5	5341	341	545	555	5	4	2023-10-25 17:50:11.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
557	\\xb76da0d122311d5604137b9134639a920dd06ed418abc06556a0f2e6d2146814	5	5363	363	546	556	13	4	2023-10-25 17:50:15.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
558	\\x37c49e8cf46dcf2257800ef89c97d42bc15b3c1307e42b65144a17656371571b	5	5380	380	547	557	6	4	2023-10-25 17:50:19	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
559	\\x3d21a820156d231accfda094a37e4ce6dabd3be20f56aecb73ba59a99841c56a	5	5399	399	548	558	3	644	2023-10-25 17:50:22.8	1	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
560	\\x37ac4d8c235316e4994360906e46fc41da6a494c5e27697fa47e14643ecb7698	5	5425	425	549	559	8	4	2023-10-25 17:50:28	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
561	\\xc2fe6dbeb2b8f2d9e875f9ff26294f1a067b0580ece65bc89b40a5273befb36b	5	5431	431	550	560	19	4	2023-10-25 17:50:29.2	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
562	\\x0e4f05d14a29681d6945eb0ab9f1a906c22496c2a54806a185e89d0a2887341d	5	5444	444	551	561	3	4	2023-10-25 17:50:31.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
563	\\xd9ab618f87074b61466b1f6e1826cb2b8fad222f31999dc469fe9e54c420e2b2	5	5450	450	552	562	13	535	2023-10-25 17:50:33	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
564	\\xd6183c40af0d03b7295853721ec4b6db71d329bcdb1d619d43fadfad77789f19	5	5461	461	553	563	3	4	2023-10-25 17:50:35.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
565	\\x3c9e93d04ef2c51e12f97865bcfc67d420945eeac06db8947146a51af511b8d8	5	5464	464	554	564	3	4	2023-10-25 17:50:35.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
566	\\x1f510a34eedc11d7232813b36739fd50801e8ac179f396f6800145dee56621b3	5	5471	471	555	565	15	4	2023-10-25 17:50:37.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
567	\\x9e7b9dd2234f493e45cd18f221056585b55996c376907464b4aefa829ed97da9	5	5474	474	556	566	9	4	2023-10-25 17:50:37.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
568	\\x541b7992fc6311a9e8c3cb8f7ad70a19e13a233382788523750871b0efa6eaed	5	5495	495	557	567	9	293	2023-10-25 17:50:42	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
569	\\x810102820af230c31afa6ef3a64e6a77820120b97bafef87bd6533c59c36eb58	5	5502	502	558	568	19	2439	2023-10-25 17:50:43.4	1	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
570	\\xdfc3b28ee011e2fb617d59e916a1d0d3b880ac8be26c729c416ec8fd8ba2c748	5	5510	510	559	569	11	4	2023-10-25 17:50:45	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
571	\\xbea216779e9ed88d536f31512addc196e99ca2789aef9c4d7e032d82168aea08	5	5512	512	560	570	17	698	2023-10-25 17:50:45.4	2	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
572	\\x29b65e360de050308970715c289da6e8fed7926d66d373ca49888941c7782783	5	5514	514	561	571	9	4	2023-10-25 17:50:45.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
573	\\x90b6a7d7bf30c1071264880d210dc1548cdb941a700373420821a09de8410d71	5	5548	548	562	572	7	4	2023-10-25 17:50:52.6	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
574	\\xbd5e95ad71f74a35b6a68a7e9dce7aae39b1072fe8118bc447ee332c34c02bbb	5	5558	558	563	573	3	4	2023-10-25 17:50:54.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
575	\\x90e633159e7c04a17fe90e679db80f2e96330e6d0ea73d64d11547708a7db9b4	5	5572	572	564	574	6	293	2023-10-25 17:50:57.4	1	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
576	\\x5921be07a2496a16401d09b477a621f6dde77e4c3cf9ba141d37e38250835566	5	5627	627	565	575	6	8236	2023-10-25 17:51:08.4	1	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
577	\\x0dbefe69e379ecae282af4208ff6c4437cca3c08e895c1e29c606b6966eea1bd	5	5650	650	566	576	11	8410	2023-10-25 17:51:13	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
578	\\x043ec977e557c015eba986f15c4691870a1a5e5e6086e4d26539fd1428fb3f4f	5	5651	651	567	577	15	4	2023-10-25 17:51:13.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
579	\\x223570e9df0112adfff5acca19d79c2aa0ddcf72360346dff3b9cd71c0ae757a	5	5653	653	568	578	3	4	2023-10-25 17:51:13.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
580	\\xf317c71c3a3a55137aab75e5517fdcbc76a4b2b191ba1f157d103e1e67541c96	5	5655	655	569	579	3	4	2023-10-25 17:51:14	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
581	\\xfac88442e78391de265dffa6345e9189f3526fbc76ed2f801c1ae5203e6c1800	5	5671	671	570	580	17	338	2023-10-25 17:51:17.2	1	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
582	\\xd8cd1a17ecaff29920cdb2c341b31f41a7a4a1777eac15b060baf3bd36c114b8	5	5673	673	571	581	7	4	2023-10-25 17:51:17.6	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
583	\\xafa5322139a3bf2d2d3e04392fedc47e40b9c308e15abb4823ed2fae6db8b520	5	5687	687	572	582	5	4	2023-10-25 17:51:20.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
584	\\x00411fe612a931aab4ff44c545b015c3feb68e757bda5a020dac9dc536582b6b	5	5689	689	573	583	5	4	2023-10-25 17:51:20.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
585	\\x95fa48596806dccd9c2e56678f0fa0a00879b360e85a7044f09086564ed20e01	5	5696	696	574	584	5	4	2023-10-25 17:51:22.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
586	\\xed528660e3f179862b1fb860c669073062eda2f9f1a9ef7adc6355d1268eebdd	5	5702	702	575	585	19	294	2023-10-25 17:51:23.4	1	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
587	\\x9a6675b4acae6bcc1ec2bf98b20f5e55dcdc2d47361b3f64cf7e3b2123a60430	5	5706	706	576	586	3	2620	2023-10-25 17:51:24.2	1	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
588	\\x6d9bfb4eaaa14253c136e891152d559d38db6ce3120c5ce859590adb1a9abc6c	5	5738	738	577	587	19	4	2023-10-25 17:51:30.6	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
589	\\xafe5e7b6a3765c57c6909246d900b33c9009a61ba5c52087cea858a2678239c0	5	5741	741	578	588	5	4	2023-10-25 17:51:31.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
590	\\x4f0137488f75866ba51bce2891e7e757b0d8f264e8a3239b03688c34714b0a72	5	5745	745	579	589	9	4	2023-10-25 17:51:32	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
591	\\x64f6218d65af6776c457d517353dfabc0a666d155779c01afa17a42066ac8fc4	5	5753	753	580	590	15	4	2023-10-25 17:51:33.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
592	\\x5f5d36c7fb80150768c2cebd7242a6f54bc197cdd5d20062cf5be2f105c46e5a	5	5759	759	581	591	17	284	2023-10-25 17:51:34.8	1	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
593	\\x59838c41d519fcba04631decc84097b7042ee533800dd5ddde7af24fab72cc57	5	5774	774	582	592	9	4	2023-10-25 17:51:37.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
594	\\x98ed92daaf2c172409f351b6d1024cca35a24794b9e9ab77cccfebad96752cd6	5	5776	776	583	593	8	4	2023-10-25 17:51:38.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
595	\\x2cbe109ee3676f5576f902145507567495a894133d05c2c292c4f2208fa91826	5	5780	780	584	594	19	4	2023-10-25 17:51:39	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
596	\\xb4f17f1f2f41e8add9017d235a1f52aec39ca6ab0f29c99ff2c85d88ea356ad9	5	5786	786	585	595	9	4	2023-10-25 17:51:40.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
597	\\x9f9a0bb462e533c83b45edd912fb9d53a9f32fe4b609bc642314090421955601	5	5790	790	586	596	17	4	2023-10-25 17:51:41	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
598	\\x88dfc3320d95c9c613e8d4de5de0fe31811de2801482f9724d9afdd8f902b740	5	5793	793	587	597	15	4	2023-10-25 17:51:41.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
599	\\xf5e788c823bf1ade8d2d6bb200df1f824bfe55f451007f2fec7963865156178d	5	5815	815	588	598	17	563	2023-10-25 17:51:46	1	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
600	\\xf96165b75520d5c7661d201eefde87e8915dc781baadf5651a2896901f5b6bf9	5	5824	824	589	599	3	4	2023-10-25 17:51:47.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
601	\\x968637b4baba07e608278d21ae6e52544f218733e76016248ae4ae62d8842fda	5	5827	827	590	600	5	4	2023-10-25 17:51:48.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
602	\\x2ac680ea75b7c94612f1b0bbabecfa775f31254e74d087e1c8e4130a2dd03ec5	5	5836	836	591	601	3	4	2023-10-25 17:51:50.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
603	\\x74cda4234be1399e9d722e867a95145cc8507b628df07a8d015592cf278925a2	5	5850	850	592	602	15	4	2023-10-25 17:51:53	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
604	\\x5202f1ea663b1266bd5364e279fecb946a8ef5e51201c9ac48588a78dabbe6d6	5	5861	861	593	603	19	4	2023-10-25 17:51:55.2	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
605	\\x198ed51d4520730f417bd1ddfc34828bce76a6bd444a2ff5dcd92d56ca0e6990	5	5863	863	594	604	11	4	2023-10-25 17:51:55.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
606	\\xd222a80f7d796b1d3edd61bfd62bb898cb2c17920dfc9f9ed47830cbce5d4346	5	5865	865	595	605	9	4	2023-10-25 17:51:56	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
607	\\xbf375df81c3227f04a2f03ff56eda439c4a20d89881522d2c465a78cbf8cbdf0	5	5894	894	596	606	17	4	2023-10-25 17:52:01.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
608	\\x258efafd0e4438f6fef4f5d6164298cd9804a8aa9cdf60a38ac07e17ed521972	5	5898	898	597	607	13	4	2023-10-25 17:52:02.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
609	\\x2fa0ff58478c3bd6346a5e70fedcacd3e5becb03d8d20fe5003514132e8b14ae	5	5901	901	598	608	6	4	2023-10-25 17:52:03.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
610	\\xc06c1776835b02dfc4b4f1cf9264f75549713996da91229dfb1475d0676d8856	5	5912	912	599	609	19	4	2023-10-25 17:52:05.4	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
611	\\xce88fc884144e05a0cfac723959e7f23f77eb6ec9677f236ae376dae394a17f8	5	5940	940	600	610	13	4	2023-10-25 17:52:11	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
612	\\x3c9a0967426c7cb1a1835823c71631ed07ad8d905b70270c305cfc83fd97daff	5	5990	990	601	611	15	4	2023-10-25 17:52:21	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
613	\\x7d39fde7e5a7a85f541bd4909af01307b680cbe8e089dbcbc5dec07f240234ee	5	5992	992	602	612	7	4	2023-10-25 17:52:21.4	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
614	\\x2afb4f60dacdbed710185aaee485fd02404009c60cc6d8ae2fe2b66af865124c	5	5998	998	603	613	9	4	2023-10-25 17:52:22.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
615	\\x34da8ce29a2ee9afc15b35460da21d0b39b05581f786028a588668c6b2efc0d7	6	6006	6	604	614	11	4	2023-10-25 17:52:24.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
616	\\x9c179a3babae1cb894ee875258018b81b466219428f7a806d06bbe75576f565a	6	6016	16	605	615	6	4	2023-10-25 17:52:26.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
617	\\xbcd90473c13d3991798f3d35ff8ef12de8d8d6e3977fffdcaeb5bdc5c02cc45b	6	6032	32	606	616	15	4	2023-10-25 17:52:29.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
618	\\x140113ccf1d937b7f2f0adaa7190cde8e0a4ac6f18ff5802d53597496924c705	6	6040	40	607	617	3	4	2023-10-25 17:52:31	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
619	\\xde4189929258dc14df52c400cdae14c43de2d591cc8787b3266bf0ede62e4923	6	6041	41	608	618	6	4	2023-10-25 17:52:31.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
620	\\xd6b4dad8a28ee69f52601d532e7ae9ba29bb2568104d15cde39b88c81a5c1ce7	6	6043	43	609	619	9	4	2023-10-25 17:52:31.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
621	\\x29f25eb8177f5cfaf13419e427abb69860a934cea21cf5f31096e56998741f66	6	6060	60	610	620	17	4	2023-10-25 17:52:35	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
622	\\x8234721026076a44a9ed668fbdd27e40ffe1994209936ef4e64cb6a6f244e49f	6	6062	62	611	621	7	4	2023-10-25 17:52:35.4	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
623	\\x4c409dae42642c3fccd7c5b0d34c7de1bc341214b509b38bca57192230a2a092	6	6073	73	612	622	5	4	2023-10-25 17:52:37.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
624	\\x659546df393f97b9b5f3130e70df22aa053c201eee978b009048eb8553618908	6	6074	74	613	623	15	4	2023-10-25 17:52:37.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
626	\\xb6a6e2811cd38e48c7e54b892e006a69171157ae6fce6b2c82b1446f0246030f	6	6082	82	614	624	6	4	2023-10-25 17:52:39.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
627	\\x735707693e1b0277431fdcb5abc3a99ee32b2b1476d28878b8856eacaebf40e6	6	6086	86	615	626	13	4	2023-10-25 17:52:40.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
628	\\x6dff7f614255e1db6da34c01f61c66bc4d4d18fb9b3c0602f5dba73d4a8e4927	6	6090	90	616	627	19	4	2023-10-25 17:52:41	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
629	\\x1ca290f72a05374f35cbfbb591f60614c1239db9ef5e427ac2151bf3f29f3308	6	6095	95	617	628	8	4	2023-10-25 17:52:42	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
630	\\x5c45afa287ceebbc8c2ef2675c03c7deba47679189a4415e3ba1eb2d95062c2f	6	6118	118	618	629	8	4	2023-10-25 17:52:46.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
631	\\x7b2145aed3340d26c79fba73b0359af62c979809b66a1897ec3dc627dbb37ff9	6	6121	121	619	630	17	4	2023-10-25 17:52:47.2	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
632	\\x9e8d76c49bc7098e4e7c6dfdce7881a01017c8af7c37a5d6c02a960741cb4054	6	6146	146	620	631	3	4	2023-10-25 17:52:52.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
633	\\xb5f4a7ebfe4c8dff6dd4bf9bfccce0e602c29fd064dbd9603887551459d42570	6	6150	150	621	632	5	4	2023-10-25 17:52:53	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
634	\\xaea04c440b63367ea785bce2264442039e9dd7ce993d3f119cca731c024a87e0	6	6183	183	622	633	7	4	2023-10-25 17:52:59.6	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
635	\\xec4ee3332333197009fd303fafd61681753b1126a8af79e3193790aec293889c	6	6194	194	623	634	15	4	2023-10-25 17:53:01.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
636	\\xce280137610ca254c6ba267a471dc0f434b633235281e26b6f5dc26c8571bac2	6	6199	199	624	635	7	4	2023-10-25 17:53:02.8	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
637	\\xdbf7f932a8b3eaf0b1e83ee6c5aa0166bd7e01c285a3e66fbd71afa60edc95c4	6	6200	200	625	636	11	4	2023-10-25 17:53:03	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
638	\\x54fac287cdc9d917a3dc2a319ad3c27ee149510b89a4c498c8043b9a22a3e461	6	6210	210	626	637	17	4	2023-10-25 17:53:05	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
639	\\xa01680992703f3ae12cfd5477c308d6fb7506c7ffcbdcde2b7ff9c1a7e799011	6	6226	226	627	638	15	4	2023-10-25 17:53:08.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
640	\\xed25e452bada59c09ed67860953e1fdcb00f4e983eed9a0b805a53483b8092a8	6	6228	228	628	639	6	4	2023-10-25 17:53:08.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
641	\\xad03faa329dbf42b3becb21cd76ebf295178775102efa1b1dfd66a734289b10a	6	6241	241	629	640	5	4	2023-10-25 17:53:11.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
642	\\x35ee807b90e8cac180f725a7d4cc7122c0b3235d45d71bc69fca6202920635d6	6	6246	246	630	641	5	4	2023-10-25 17:53:12.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
643	\\x0cda4960ecee7ad69a3445a77012a4937bd5caa6361023670c153e3bb9312a12	6	6254	254	631	642	7	4	2023-10-25 17:53:13.8	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
644	\\xc57c86f6918eac62b0981ce8889d36415972b00c3ccef65b7c05df08c9a33dc8	6	6260	260	632	643	6	4	2023-10-25 17:53:15	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
645	\\xec187b83d1dad391fd38b18a2aa0f2e0cc382fcc3cf966be315a42843842f666	6	6264	264	633	644	3	4	2023-10-25 17:53:15.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
646	\\xedcb10f1155faa20df99789d05fbf1fb4bda9f6d434162ec80af9b583c51aee8	6	6269	269	634	645	7	4	2023-10-25 17:53:16.8	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
647	\\xcd7e15ad2a125b9ca03977fe8e445c62f19c8f9874973774be4eb64c05170df6	6	6292	292	635	646	13	4	2023-10-25 17:53:21.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
648	\\x8c227cf608228cfbd1551aa0688596e75aa9901478ba7fb196968f2365732aae	6	6298	298	636	647	11	4	2023-10-25 17:53:22.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
649	\\xb97eac0dab320714dff921baa6d9ad0fbf1347de6df12ca38c5e4e6fcc533bff	6	6303	303	637	648	19	4	2023-10-25 17:53:23.6	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
650	\\x08df04e8aa6cf3df4ca2b05d2d1c92c89a44224d99204997c4473ab76f87ae2a	6	6332	332	638	649	17	4	2023-10-25 17:53:29.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
651	\\xbcec9267414cd32c2ba94cb9c5aee2cff394ec20b0572c59d90403e1e655c439	6	6341	341	639	650	9	4	2023-10-25 17:53:31.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
652	\\x676034ab6a171833e7d653383c91a9e2a781a0df61daff6633096a96fa02e14e	6	6349	349	640	651	13	4	2023-10-25 17:53:32.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
653	\\x74fcb51f3b5e8708f9aaacd890aa6cfca5174ac0aed3dadf985475dc520f3f61	6	6353	353	641	652	9	4	2023-10-25 17:53:33.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
654	\\x6966ce2379f145a212a90c860210ae904c7bd16c741adae1cc6cbc355209ba7c	6	6367	367	642	653	5	4	2023-10-25 17:53:36.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
655	\\x388d9b9acf93078b26bc462411c5c69a25c0a872ca09623e6a002c6afce1bcc3	6	6391	391	643	654	8	4	2023-10-25 17:53:41.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
656	\\x4fd1da42b30a4c56e7975261e3e624c8fd16a6272bbefe19b6977eb5df4b7ed6	6	6418	418	644	655	9	4	2023-10-25 17:53:46.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
657	\\xae454873781e54946dcb50b4c879b829d93f6d9939fa0b6e70b7f74dee5e9875	6	6421	421	645	656	3	4	2023-10-25 17:53:47.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
658	\\xfa61b7623b7616170767e8416f48e524ec0afdf06e879c0918964e516f54d5e7	6	6442	442	646	657	17	4	2023-10-25 17:53:51.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
659	\\xa6e5627c27b586c9d563d99e3bdf847315d72e0387dca91738c27159c075766b	6	6461	461	647	658	17	4	2023-10-25 17:53:55.2	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
660	\\x6e676106934f705af34f1deed3f7c35d9e1e69bd7dfd301caaa8154242345f40	6	6468	468	648	659	11	4	2023-10-25 17:53:56.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
661	\\xa674f74205455edc6136f37b0537015ab6309777fab010b0dc4aa9355adb94f8	6	6474	474	649	660	9	4	2023-10-25 17:53:57.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
662	\\x46d94460207405e7601c37ef609a5d919f8e3d205fd79fe583ded1c224a8d8aa	6	6486	486	650	661	9	4	2023-10-25 17:54:00.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
663	\\x564b0f77f74baa33820c8348d613b284481b8bcd46b59799fe008d4698dd4678	6	6514	514	651	662	9	4	2023-10-25 17:54:05.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
664	\\x228c1adb79c5ac2746b2944c32583f1668e84e7a8b265868d42578ba8d58b3b0	6	6520	520	652	663	5	4	2023-10-25 17:54:07	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
665	\\x69b27121eff974ef18292edab4d6f55916aa074ac8a6f1528e881309d5352f7d	6	6525	525	653	664	6	4	2023-10-25 17:54:08	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
666	\\x8139a8f46426fa378a8ebc2be70440422f8a51b80b91308136d8f6ca3e0f3e26	6	6531	531	654	665	8	4	2023-10-25 17:54:09.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
667	\\xb3e79070325389f620e59f31c3cbb4843445dec3b3ba614caceab36226a201a5	6	6565	565	655	666	3	4	2023-10-25 17:54:16	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
668	\\x7ed2ae597f3d390b41024fbeb2fab4137ede82de16fa781ddbe7a81c41ff16a0	6	6567	567	656	667	11	4	2023-10-25 17:54:16.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
670	\\x76a2bd467c184b18051340f024071ac0f840500702e33ce02878f922bcc9a02a	6	6568	568	657	668	6	4	2023-10-25 17:54:16.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
671	\\x6f2864ce344e61606b4a25fc1628b8230b854312ecb9ab94cbf82b0160184de1	6	6572	572	658	670	9	4	2023-10-25 17:54:17.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
672	\\x8f2448142b6b818c3bce1d189f25eca24fde16881f8778cfd3909fef2bb6c0ca	6	6578	578	659	671	8	4	2023-10-25 17:54:18.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
673	\\x62e836caa97406816979ee33c7db10e165141aedec0c31a1ee9a4753f57713ee	6	6581	581	660	672	3	4	2023-10-25 17:54:19.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
674	\\xe0e4abd924bc00dff1ad6a030f4e316aef46383735b45dc76d356aadbc4b219e	6	6586	586	661	673	7	4	2023-10-25 17:54:20.2	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
675	\\xc3167f811d4eb73ee8541d6996ed5369ad14d2191ac162d2f52ef14a6b0e1dd5	6	6597	597	662	674	6	4	2023-10-25 17:54:22.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
676	\\x9a3081bedadd84b364e11a126861dac0afd04f1b5a144498af95b19d18e24c34	6	6604	604	663	675	11	4	2023-10-25 17:54:23.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
677	\\x59a05bf243c63597dd72ec9c59ace74ab0c91b1c6e7ec309d21a9b61cc1ae532	6	6629	629	664	676	3	4	2023-10-25 17:54:28.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
678	\\xef23e191111e0f4ca136daa4b03ed88d6837462bf46e20633dc8b3653453770b	6	6637	637	665	677	11	4	2023-10-25 17:54:30.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
679	\\x4c50a4482f27c2ec5c790bd0965cf53a682875e3c3a38e4b3c283d4b04893132	6	6645	645	666	678	5	4	2023-10-25 17:54:32	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
680	\\xa5a327721ea916738ecbf3db40617bec91cf62344b090c0377c120e866f98d20	6	6647	647	667	679	8	4	2023-10-25 17:54:32.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
681	\\x5e15efffe4f333aabc1d8894be03dacae33ce6ac2f34fb0fd0122c36e2c5353f	6	6654	654	668	680	7	4	2023-10-25 17:54:33.8	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
682	\\x07216b3852f8a7ea29d80b4e5e83ad9f8419c9933b9e1757dbe52c5e63cb0667	6	6662	662	669	681	17	4	2023-10-25 17:54:35.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
683	\\x9d23a8636f55fa402918e80edc3740ecbffac5c04aa3c6eacef17a44064dcfb0	6	6681	681	670	682	11	4	2023-10-25 17:54:39.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
684	\\x11dd58db8db7a30cb3ed52212fe55a4b7081adaea0dfb1135c978ef8907d5863	6	6690	690	671	683	7	4	2023-10-25 17:54:41	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
685	\\x37441cc64593ef07987b2f544f171c6fcaaa76b0b04e839b1741d2ccb25e27e4	6	6707	707	672	684	6	4	2023-10-25 17:54:44.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
686	\\xf12239489692b136f0738dc9226f152acf9409acd7c5f1133a2c488437a25697	6	6712	712	673	685	15	4	2023-10-25 17:54:45.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
687	\\xdcc3be3baf3dec28cba7f7d128c21b7992c1be9fe8d33d1dcfd5e662464f9759	6	6715	715	674	686	19	4	2023-10-25 17:54:46	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
688	\\x8fe0c770313f359ebf22292625dcd5749fef1fc99c6ce334ca35c63db55531cf	6	6717	717	675	687	5	4	2023-10-25 17:54:46.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
689	\\x1c7cfb98df65208ca610da3e0ffad4a9de8d593f726e9a8575f189889b962a1f	6	6727	727	676	688	11	4	2023-10-25 17:54:48.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
690	\\x979c9daf95bd4028e7ed90d2cfe1aaf1a3670fa369c11e9af48c29c7391a6875	6	6746	746	677	689	5	4	2023-10-25 17:54:52.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
691	\\x09c3531f0f50ecfd1fd292069d51e5da611fe3b6fd9ba50eb61b738dba6bbbe3	6	6752	752	678	690	3	4	2023-10-25 17:54:53.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
692	\\xda363712ee5e0bff37dafeb46835e2240c733df102df3218e53980a863448205	6	6763	763	679	691	15	4	2023-10-25 17:54:55.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
694	\\x2414e40143892df652f17b30d07a8c541949e7a3f26d729c2735418e654267e3	6	6764	764	680	692	13	4	2023-10-25 17:54:55.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
695	\\xf135a09eac0c92b3df54cbb77f1b83274ba5d84a3a58720b6c1fc315c1279bcc	6	6778	778	681	694	7	4	2023-10-25 17:54:58.6	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
696	\\x1e0e04afcc5eefeb77c14bc380c1aba9fee1688d0691ed6f5083a82f2a2df46a	6	6796	796	682	695	13	4	2023-10-25 17:55:02.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
697	\\x8fe647e054b61fb245ade095b73a629496fefdc07e4bb7de897835f5b4235a4b	6	6799	799	683	696	5	4	2023-10-25 17:55:02.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
698	\\x96673a6b2e974d819eabbe952891f1fef417fe03982bff4cd916967d7a086028	6	6812	812	684	697	5	4	2023-10-25 17:55:05.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
699	\\xc209ea495285c62e881aeb3fe7b0e95d36a7cdd77d88a173e67585e267d0388b	6	6828	828	685	698	3	4	2023-10-25 17:55:08.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
700	\\xf9c0fd161cb362cd2356e285ab090669661f38635ab91fd7112009152d17bc43	6	6831	831	686	699	15	4	2023-10-25 17:55:09.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
701	\\xd21ce0d037b8c132a36e124b9abf54f9190d4b22ce44c1d8f99d04eb5057ff62	6	6836	836	687	700	7	4	2023-10-25 17:55:10.2	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
702	\\x5e22af4b7384741cade925fc69440931fec0c5967ed1d050b33cf2c563132f42	6	6848	848	688	701	3	4	2023-10-25 17:55:12.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
703	\\x9f7dcc69c718d1f9bd36b795d09f67b4cbac30b3b3ea068fbc6ae8cee57f3abc	6	6849	849	689	702	15	4	2023-10-25 17:55:12.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
704	\\x12a350c77d04fa6d8d80f8c0a82df459713470eb2a5eedf834d10c958e585517	6	6855	855	690	703	19	4	2023-10-25 17:55:14	0	8	0	vrf_vk1fy34ngtumw52y0wu49hw7wxjlhu9h5xk8kgt5um5300sepueaglsf5l6v8	\\xe5fb5cf77cac13b7fe6afe07d26610e53e759a04cdaa0876acefbefedd406512	0
705	\\xd0352a9b309f8e1f56fcfe0b9d12b596a77ff6b320c9c72a16d299d0e4270b33	6	6859	859	691	704	8	4	2023-10-25 17:55:14.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
706	\\xdbec29be304f8750fe56c859310428205fd998706a9448ee231e59a2762b9707	6	6861	861	692	705	7	4	2023-10-25 17:55:15.2	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
707	\\x2b2321c5c9ff12957cf3ae722e382a15f7bc1f5edad5d70e5494c0d2aa42c9b8	6	6868	868	693	706	17	4	2023-10-25 17:55:16.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
708	\\x82fc44e246e7fdb626aa8491e4372e0a779931661fb2b1340d11632215789217	6	6885	885	694	707	17	4	2023-10-25 17:55:20	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
709	\\x59183d5dd5ab31af801535496eaa906d645fab533aecaa74884b04e8593fe1a1	6	6886	886	695	708	7	4	2023-10-25 17:55:20.2	0	8	0	vrf_vk1r2l2cp5xt7ewhal448fzsqk6devh7ajkn25duahmw9nq8aqqpjaq4gj9km	\\x391eb46ec2099da505eea8554b5ad4d67bbe08049332a48de99483f486b6ba6a	0
710	\\x3980ffa9ae349d484f007954b39e62abfd96bff50fe691167272a75bea3390a6	6	6887	887	696	709	15	4	2023-10-25 17:55:20.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
711	\\x6bfcd7c3ad83a31b16730c5e99284bba1700b7793eb5fd588491fa8b6c443e99	6	6905	905	697	710	13	4	2023-10-25 17:55:24	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
712	\\x39cc9b54a3f26f0e21d6f768195b9df73824be89586256ec3535d2733bb35f3f	6	6925	925	698	711	5	4	2023-10-25 17:55:28	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
713	\\x1e913ffa1e7e494fe6961256fcaad6c508e944cb23fd733eddbc003f034a283f	6	6928	928	699	712	8	4	2023-10-25 17:55:28.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
714	\\xba5dc84270829c6a127889c65aadaab734505380d649343c1290e8526253f5c4	6	6929	929	700	713	8	4	2023-10-25 17:55:28.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
715	\\x5f8271671be619b06a8a01939d8826f3bf869a5332235fa19ae4ccadcd3d291d	6	6935	935	701	714	8	4	2023-10-25 17:55:30	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
716	\\xf88a2f7c0ebffd27897e04848b886693f479a2076e51c4ef0cd761ffaf37ab78	6	6944	944	702	715	8	4	2023-10-25 17:55:31.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
717	\\xe62d8f70aa5ab91fe507e05c333d2724f603da0a9233ed41852276d1cf78a780	6	6950	950	703	716	3	4	2023-10-25 17:55:33	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
718	\\xc57d0688b6b533d486c4454e199e335b5c8af340294b46bef26ec4f37bb88695	6	6951	951	704	717	6	4	2023-10-25 17:55:33.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
719	\\xb22bc372e9aa39644351330d7506321c546f77ee220760f64ee22cff04b2074a	6	6954	954	705	718	9	4	2023-10-25 17:55:33.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
720	\\xd2077ac9a0f4da4ab7e0ef9917a0e781dd013706ceb7ca854258679001989a00	6	6968	968	706	719	15	4	2023-10-25 17:55:36.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
721	\\xd3f3a9b17c7ba4a31b682eb9249e5bca7f66fc65cdb11881305048bc31d3a5df	6	6977	977	707	720	11	4	2023-10-25 17:55:38.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
722	\\x6ce45b534fbf4a1d95dae0526e5b42eb790f50774bd3c418459af1bacf03aa60	7	7013	13	708	721	9	4	2023-10-25 17:55:45.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
723	\\x6ca1e9904d497cca606ca007384fca5bb7e24e705d8bceb61e877aa9d18c10a1	7	7031	31	709	722	17	31622	2023-10-25 17:55:49.2	100	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
724	\\xe6522dd7106f43bcc328d8aee2b1a17a75398c6a19429cd787af44b27c736519	7	7054	54	710	723	13	4	2023-10-25 17:55:53.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
725	\\xe96a322588ef8215f25b14109936a4db023fa691d5052dd7364c56e345722d8c	7	7065	65	711	724	9	4	2023-10-25 17:55:56	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
726	\\x321268250514481bccf6e64fb51c42ebe9b605496978a5fa864d5d3ed8c6d6a6	7	7094	94	712	725	17	4	2023-10-25 17:56:01.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
727	\\x4b1e210ba6ad0b61878cf60cedbab0cdbb6084ec7a088e28d4375b8533978644	7	7104	104	713	726	3	4	2023-10-25 17:56:03.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
728	\\xb2bb8240dce887def32c146b3b397569a8011b71e22a2bd1e8ceb6b43e3d4cd2	7	7106	106	714	727	3	4	2023-10-25 17:56:04.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
729	\\x4f2c65848622b579c3a0970fa44b812c7e60233455cd6357c86256e3e6ee5914	7	7120	120	715	728	6	4	2023-10-25 17:56:07	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
730	\\x1d7ae47b6985454aed55af6505ceebb17b2b5fd9528673ec2d0cdaaf18699e6d	7	7122	122	716	729	8	4	2023-10-25 17:56:07.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
731	\\xc4b48113b52d85d3a0f26c742a5d58828a8701d1a6ca4c2c1d3f87ac09e873c2	7	7143	143	717	730	8	4	2023-10-25 17:56:11.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
732	\\x3844934e526007729e05aacfff96123e3fae56a3161fb3e665cebefdef4fd6d4	7	7149	149	718	731	5	4	2023-10-25 17:56:12.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
733	\\x872c18036711acf4a3aa3eb51d883823a9549edba169f54fbe695b9f9735ba3b	7	7157	157	719	732	3	4	2023-10-25 17:56:14.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
734	\\x9417665903a9fc1eb1307b95f9ac7a5835177c87296f42cbbcf897a796ef57c1	7	7182	182	720	733	3	4	2023-10-25 17:56:19.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
735	\\x4f0b997ea6243c24c3e7ab7616080fd82b711acdaae99dea5543a0f1c9dc9bc4	7	7183	183	721	734	8	4	2023-10-25 17:56:19.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
736	\\xdc40eb8bc7469911d9b0291ab0f3ca63f7c6e0fb6f084917f766f7bf9d8513d9	7	7189	189	722	735	8	4	2023-10-25 17:56:20.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
737	\\x7cf593f0daaff98a8c5b35db40fd05517724f8f2f6ce64014fbf274dfc0a375d	7	7205	205	723	736	11	4	2023-10-25 17:56:24	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
738	\\x213f4a7135eb4223f87e20e2514fd258fdfb7580b0e622a02b6c39d05cd34309	7	7210	210	724	737	8	4	2023-10-25 17:56:25	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
739	\\xcd3696f2a4e05e88071705f0b0f9124258cb7474f309133b86cbd42cc1fcdb56	7	7221	221	725	738	3	4	2023-10-25 17:56:27.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
740	\\x1ab3040fae2fa395e51d814d1c1aef318ac6284ac8df6d0ef660b39318f285ad	7	7226	226	726	739	15	4	2023-10-25 17:56:28.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
741	\\xdff9ca0491421e6b43d9e9852db456500fdbfd0b9570810b6e96803b8b4d6432	7	7234	234	727	740	5	4	2023-10-25 17:56:29.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
742	\\x4f393fa547c5dc1b33309ed49311241cc6ec9c41f9c6860560c3a71c496f50be	7	7242	242	728	741	11	4	2023-10-25 17:56:31.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
743	\\xa540c1b3bb01c78068b0842c8f1bf32507ed71c1e0e82341ec57a1f7570fe5f5	7	7258	258	729	742	3	4	2023-10-25 17:56:34.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
744	\\xadd3d8d96c8e77419b22e7cf72723009eb4b0916dd4d47ad4663876134d6c3b3	7	7263	263	730	743	13	4	2023-10-25 17:56:35.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
745	\\xaf3c616b7beb455a163cb04a7fcc7259ec369637203e0e9f5e753ac047b56566	7	7265	265	731	744	11	4	2023-10-25 17:56:36	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
746	\\xaa56e273b9e951ab66a4ae003524638fb73d44dcc4f2b58020355ef78871db3e	7	7276	276	732	745	6	4	2023-10-25 17:56:38.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
747	\\xf40c4c4bca70d237c6fc3940d1250c3aa46c43b448680392e7453559904c7eb6	7	7278	278	733	746	9	4	2023-10-25 17:56:38.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
748	\\x1a54662d4e0e41219bad0429a5e6c7bf4d4789c23511bf90e4d58e8639c057b2	7	7287	287	734	747	6	4	2023-10-25 17:56:40.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
749	\\x856ab39a4a3000285b3aa49bc9550afc2c287593eb23b3276dab930a6ec177de	7	7312	312	735	748	3	4	2023-10-25 17:56:45.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
750	\\x3843635d5eac5380b01af874ad9f3f0a51cdd8341303bb9f312fa2dad9fe5de9	7	7316	316	736	749	9	4	2023-10-25 17:56:46.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
751	\\x72d0c11a6286b49d6a04b45d95b21c8328461b2738dee141690dd715132729fe	7	7319	319	737	750	17	4	2023-10-25 17:56:46.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
752	\\x63e7adec28a4feff5133267b24236c291ce496b8c380c1ea43a939b4b3e44a32	7	7323	323	738	751	3	4	2023-10-25 17:56:47.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
753	\\x953f48ff1f98f1d257170680b5ceb09ee5fea467936248e33083c3ca9337d33d	7	7329	329	739	752	11	4	2023-10-25 17:56:48.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
754	\\x2d29763881d5b0a5cd4bf5b2ca7e56ceb5d76d0d8bc315c05f9399a1d31fb05f	7	7340	340	740	753	13	4	2023-10-25 17:56:51	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
755	\\x9abe03db685cfce86a13ae9d99ee57cf615a3aacf901c86adaaa731ff57367ed	7	7342	342	741	754	6	4	2023-10-25 17:56:51.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
756	\\xc5ed8d5b21840864871b8c466598b8641f37376f8e34f015f4829e139017c56a	7	7378	378	742	755	6	4	2023-10-25 17:56:58.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
757	\\xd27b200917e391c97b843276874dbdd5facc8e03955fc4fc508d2e461b56036f	7	7389	389	743	756	9	4	2023-10-25 17:57:00.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
758	\\x09873275d132b1f357b4f7761ca8c32f03e8378519b5d6fdab8a39b1f339acbc	7	7391	391	744	757	15	4	2023-10-25 17:57:01.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
759	\\xce5c8d2e347629a08d72ce60bf90e70154465a8bf885d78cc908d2ceedb830c2	7	7394	394	745	758	5	4	2023-10-25 17:57:01.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
760	\\x8b278c3524dca24866242f373296ffd01be593758a800e100adf0a568a770dfe	7	7416	416	746	759	13	4	2023-10-25 17:57:06.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
761	\\xed1e4fa98c0a93a42589d0db11d60369ea1d2da3781ed03d668fd4b991fcc350	7	7418	418	747	760	6	4	2023-10-25 17:57:06.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
763	\\x83badee05afe9e69907c52b471262762105bf543f9351c25ccd424cc68fa83ef	7	7425	425	748	761	3	4	2023-10-25 17:57:08	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
764	\\xee893bec5cb9f4c0818f90188e841e8760133247adb2751ab837b660527038a2	7	7433	433	749	763	13	4	2023-10-25 17:57:09.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
765	\\x077abf7ccd94414f146bdae9ca66b94de512d943961553414f96209ec2e754ed	7	7438	438	750	764	3	4	2023-10-25 17:57:10.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
766	\\x8311cae112113a6a372cd41a91cc736466557d576ff2fa72889741ed268d45e4	7	7443	443	751	765	6	4	2023-10-25 17:57:11.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
767	\\xb9993178475f8119ed5dbc15a292d119eed5d9354a2099fa30169c11dbe71216	7	7487	487	752	766	5	4	2023-10-25 17:57:20.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
768	\\xec5234b916f74d3de7dbabc634f3e99ee544e28024ffa41d2a190f59695652ac	7	7490	490	753	767	13	4	2023-10-25 17:57:21	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
770	\\xa4604ba77d59517249ff5c3a733642bd045e5a91f89566044eebe8f8c213083d	7	7521	521	754	768	6	4	2023-10-25 17:57:27.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
772	\\x5e2eb014e1596431c203d5fb794df5599f0e6e848cbfb2b6174387a46c5b448f	7	7522	522	755	770	13	4	2023-10-25 17:57:27.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
773	\\xc419764bfe789dd6ecf6d82571674330c62c90bb302c6ad5592bd2424b72f589	7	7533	533	756	772	6	4	2023-10-25 17:57:29.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
774	\\x87dff5f95628b968d5fa02219a0dbd99d9869404bd6ea79db152997bd09f02fe	7	7563	563	757	773	3	4	2023-10-25 17:57:35.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
775	\\x43abeb3aa3dcc4f5e0d0280692005ac823400ea24d54c305fc47926ff3717409	7	7567	567	758	774	13	4	2023-10-25 17:57:36.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
776	\\x967f6aa3b086f554a9bab576890718db648ba910efeffeda1279fbcbb0f5284a	7	7570	570	759	775	15	4	2023-10-25 17:57:37	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
777	\\x1fc28d70172815e0821eac71643a783f379627f022d95a8b7b09949f0d2a9f64	7	7574	574	760	776	9	4	2023-10-25 17:57:37.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
778	\\xac640d41e2a77db31c1daf464382c11cb4a25d6c1f4154dfbcba55585e90410b	7	7580	580	761	777	6	4	2023-10-25 17:57:39	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
779	\\x9721409768013539148e8523e3f96b2851a0ff26d6df81def70f0934bd6e6881	7	7596	596	762	778	15	4	2023-10-25 17:57:42.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
780	\\x024f06d78dc585560d2b688633897daefe68aa3fc5b88206b622dcff33432fa0	7	7597	597	763	779	8	4	2023-10-25 17:57:42.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
781	\\xe05023fd50e7a2c960ebb604a4cf8cd9e0504831ce33b97b1b87c48e7b0905df	7	7607	607	764	780	15	4	2023-10-25 17:57:44.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
782	\\x809d682e13f1c6fb0496817b20afd1ed5351f90c2727c47275f91f14a49312e2	7	7609	609	765	781	11	4	2023-10-25 17:57:44.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
783	\\x5799283ff9d83c31a32c5727e569b93f7e88a103f37ce3a5671eb8323343591d	7	7617	617	766	782	11	4	2023-10-25 17:57:46.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
784	\\x02a359f67890b132585a4407191337be21275515bc36eb4d87e86788c7a2771d	7	7634	634	767	783	13	4	2023-10-25 17:57:49.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
785	\\x8c0c459688f810539a34bc9ee4fba6d17ece9d959fb833ff2f4055c50f48ac2b	7	7673	673	768	784	3	4	2023-10-25 17:57:57.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
786	\\x6a56abddcd8e5adfd414b8bb90c7aed167e9becd98811da8e7d9aad28b8ecf37	7	7677	677	769	785	15	4	2023-10-25 17:57:58.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
787	\\xd8842a284d8876c53f516b327b9ef7332b26365e3ad577c66277e07a0f4a99ea	7	7679	679	770	786	17	4	2023-10-25 17:57:58.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
788	\\xc993e19c575c016b2369ce076e37cbe46f734a0f58c350ba5f956f2a1f5c4ae1	7	7685	685	771	787	3	4	2023-10-25 17:58:00	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
789	\\x955fe62283db98270508353598ff2db7f55ac9d9c8a1348ec06a25a26802e622	7	7712	712	772	788	17	4	2023-10-25 17:58:05.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
790	\\xfd0e9e219aa1109aba9ab62090662d86bf3ae896f963e0f12428cdac5d4c39fe	7	7732	732	773	789	8	4	2023-10-25 17:58:09.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
791	\\x3e6cd263e40cd1014e597cd0d0e632cce8f1dbd5e62819977796c6860e1ea9dc	7	7781	781	774	790	3	4	2023-10-25 17:58:19.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
792	\\xfebaeba128173f9a1d5e021e0d9fd5213d39a5902644cde416ea3ae9dd06e124	7	7782	782	775	791	3	4	2023-10-25 17:58:19.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
793	\\xa28d05394a9f97eb46026e8218cb6ba42206b0e9c399fe20132148ac4e078440	7	7786	786	776	792	3	4	2023-10-25 17:58:20.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
794	\\x775fd0b801a290cab7c4670a57b431790a94c8d38a3976321513d6cb988e7ff8	7	7797	797	777	793	6	4	2023-10-25 17:58:22.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
795	\\xaeb7b59bdc05831859b217b4f10bb4dc52db60bbf4f99a899f7b6da025dbf00c	7	7831	831	778	794	6	4	2023-10-25 17:58:29.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
796	\\x62764dd2cb6c99fb318a6b54f5723fa339e2888536b0d686c3dc1d98d57262c5	7	7839	839	779	795	15	4	2023-10-25 17:58:30.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
797	\\x68bd8310d0545641b838ec24975405ac9ba8938a4afaa192698c4a0484e695a1	7	7841	841	780	796	8	4	2023-10-25 17:58:31.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
798	\\x161b42078673ab5f2f4f7880928b0b3bcc4e36a9cb9dde0e216230b202284931	7	7842	842	781	797	6	4	2023-10-25 17:58:31.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
799	\\xe1fcafedde6584572d5dd6524e9f1112fdb1926d9285f036182b87927c71c45d	7	7848	848	782	798	9	4	2023-10-25 17:58:32.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
800	\\xab85effea5d9f837889e7b6afb0007556d18364d19c5f504e6a17eaae4a7cbb5	7	7853	853	783	799	15	4	2023-10-25 17:58:33.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
801	\\x4d65e314685ad2caab58df2bc6e95238c3a470f20de8b189640d98d7950286de	7	7868	868	784	800	8	4	2023-10-25 17:58:36.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
802	\\x74f4637675e83b38999c99653184af68cc2dc5d2bbac7c170a8921217c3213f3	7	7872	872	785	801	15	4	2023-10-25 17:58:37.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
803	\\xdd9b3e0e96058b79ac21778c3a87e3fdb2245c78c02226daeccc975bfd202c43	7	7876	876	786	802	15	4	2023-10-25 17:58:38.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
804	\\xfed13764640c2ffeebd301ef4774fe9c2a36e2970fe494e2d907219526da0200	7	7900	900	787	803	3	4	2023-10-25 17:58:43	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
805	\\xb749838b5895e688d2ed8a70aba26d203ca37b619627b42d7ee01f78bec94bee	7	7902	902	788	804	9	4	2023-10-25 17:58:43.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
806	\\x1acb2a371aa54259b32a2ed05b6103a3b7827ec759476d342c8716b11a138b01	7	7910	910	789	805	17	4	2023-10-25 17:58:45	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
807	\\x3c9e3827cbcba534c23858a0eebb056ace39626d4bb3dccee3fc46ef5af42f50	7	7914	914	790	806	11	4	2023-10-25 17:58:45.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
808	\\xf487936bb20cf5a481e5ec5df4aebdfa68146f5923c3ed3c2c7c226cd6bbb385	7	7926	926	791	807	3	4	2023-10-25 17:58:48.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
809	\\xd15bb92c83ecfba90df3fcaef939130d8bbc5b3b608ba9cf106de0dca98e6034	7	7932	932	792	808	5	4	2023-10-25 17:58:49.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
810	\\xc662a3cd0925299ce9ba64f08ce2ecf3c3be0cdccc121bd068a6a443faed783b	7	7936	936	793	809	11	4	2023-10-25 17:58:50.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
811	\\xf93fc71515d28707b7b5fa75ff1f4a924c4a8794c3936be82298368615333649	7	7964	964	794	810	6	4	2023-10-25 17:58:55.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
812	\\x815bcd373fc29d300184337c019500fd035bc019c0278ba1e72da98adcc5d021	7	7977	977	795	811	13	4	2023-10-25 17:58:58.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
813	\\xd7bd7b11fcca216b7dd31f205051df22e8f877a136e3ed5a68180ad0b280e52b	7	7981	981	796	812	17	4	2023-10-25 17:58:59.2	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
814	\\x9529c905749884ae3c7dca8a9d725f06f03e13e8459785c8c009a6078af05242	7	7983	983	797	813	3	4	2023-10-25 17:58:59.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
815	\\x7511ef882e8ec73ed4e08581749b4a7ebd4c5fd44658a531c34703edf7792cce	7	7990	990	798	814	15	4	2023-10-25 17:59:01	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
816	\\x44fa87f7833e20c0ccdd998a6ff51b91694159fc10bf3e8bf22b27a13281f325	8	8010	10	799	815	6	4	2023-10-25 17:59:05	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
818	\\x22f9a5c21f1ce1a8d77615c8e6ef6672724cb047c703d81aae06788a469cfdc3	8	8029	29	800	816	3	4	2023-10-25 17:59:08.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
819	\\x9239e2e39deffc87251ed4a63c00adcc0667af45de08216b7ab6e79239c2a105	8	8030	30	801	818	17	4	2023-10-25 17:59:09	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
820	\\xa3921e031cfb9773d1617c1254e60dc9304c11815f89e5572019699aa327bdae	8	8038	38	802	819	5	4	2023-10-25 17:59:10.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
821	\\x8aabff4b114dad1c7dc13a81d10f6484b74b479dc7a01554200c67ef74107fdb	8	8047	47	803	820	17	4	2023-10-25 17:59:12.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
822	\\x7116a398e604e60475778ec11ac38d55de1a61574470053285a2dfa29f328900	8	8056	56	804	821	5	4	2023-10-25 17:59:14.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
823	\\xb1b746998776bd8c7a9ec28c45331b572cf5523d1ebd809663cea33d32ed1706	8	8063	63	805	822	9	4	2023-10-25 17:59:15.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
824	\\x19ec400e69d6b33e9852b0f81edd6eb06d51cc2d32a02f0b95efd28a45a915ab	8	8120	120	806	823	6	4	2023-10-25 17:59:27	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
825	\\xf0ce1fa55721c27dc80af5689ff42a3693eff878b638cde1079f4537b05ec18a	8	8136	136	807	824	8	4	2023-10-25 17:59:30.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
826	\\x3f69c31617ba5adb352537b9609521030d2d532065c278c24cef3b0e5f8df436	8	8183	183	808	825	13	4	2023-10-25 17:59:39.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
827	\\x20770e0ec6874d7897cb89c8f386afc7575feeec9a84b762aea7c93b3fea9df2	8	8192	192	809	826	6	4	2023-10-25 17:59:41.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
828	\\xbb9cc9a79924b2695bc2ac3714daa74b543201d8d5a6bb813e5676ab8fc1b486	8	8204	204	810	827	17	4	2023-10-25 17:59:43.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
829	\\xc88afd6fb46d6673d804ca043b88f006189e59822de3ab90697e12a6fea3538a	8	8217	217	811	828	6	4	2023-10-25 17:59:46.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
830	\\x24b98865522ffba0e0ed068d2270da34ab56d1e71154a781d49f91d15f1090db	8	8226	226	812	829	3	4	2023-10-25 17:59:48.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
831	\\xc4461bea80bc171f8074bafb6a01a60fbec5afb295e5a8ca2c1a83545c2f9c55	8	8240	240	813	830	8	4	2023-10-25 17:59:51	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
832	\\xc056ff777a4dad88e8effbe1ab222141d15bd9d3ff5f7de15ede64d528f0b430	8	8241	241	814	831	9	4	2023-10-25 17:59:51.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
833	\\x908736a418563933f506ae70f1c43f9b6373ee20909bbf59f8bccad3977c45fb	8	8257	257	815	832	3	4	2023-10-25 17:59:54.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
834	\\x71b1b4982aecd810e7a80cd92d81d1dd02f5c86bc5a7b5df0b41b12a97eeb938	8	8272	272	816	833	8	4	2023-10-25 17:59:57.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
835	\\x005909b353e3610b2b3fdabddf148d80ec25a4633912bb0d3feee8b16253e0e9	8	8274	274	817	834	3	4	2023-10-25 17:59:57.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
836	\\x77b185a7bfe6b8c9f6bd5b446879a8ee8aa79c75968d7a837d35984119f0b5cf	8	8281	281	818	835	9	4	2023-10-25 17:59:59.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
837	\\xb1129cc197760b470f0320ecbcda8623fceed2860a459f723b0d50020a10aa3b	8	8290	290	819	836	17	4	2023-10-25 18:00:01	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
838	\\xa687573413db64eeb9ffad62429b5afc20cec72cdd32d72adfcc2a1700e7be83	8	8301	301	820	837	3	4	2023-10-25 18:00:03.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
839	\\x5b323b2ff9d073a0e1c602ced8b16de236adf03a4cbd75c34ca7e485a5672baf	8	8337	337	821	838	9	4	2023-10-25 18:00:10.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
840	\\x5ea50e791c63c4f6fc9c3b168189f1f3e19331f13dab5af4964a7483c46405da	8	8346	346	822	839	3	4	2023-10-25 18:00:12.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
841	\\x6de04b001d7e8200f42dc30720cdbef76e63a8e0b76a0db7a2457bfefc883a94	8	8365	365	823	840	11	4	2023-10-25 18:00:16	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
842	\\x37df6644054dcbbf2eae83ac6c056ba8906b24090644ddab970829e4899dc12a	8	8370	370	824	841	13	4	2023-10-25 18:00:17	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
843	\\x8a333b2c8e375945d3d33059418387ae05e1fab92aecea76cdff3a87da7c4365	8	8374	374	825	842	3	4	2023-10-25 18:00:17.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
844	\\xd6fbbb32b896784d30024ded93d8e7409f261402a401fb1549c141d9625e5b14	8	8408	408	826	843	3	4	2023-10-25 18:00:24.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
845	\\x9b19b958edf5d3fba840a9cf273f8bd58a94c476eecb520b03acc29be19ca05e	8	8413	413	827	844	15	4	2023-10-25 18:00:25.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
846	\\x8b3f7ae44d5c368307037de4cead525b8d3a8f7e3af022c5af3fe78ce51c7939	8	8427	427	828	845	15	4	2023-10-25 18:00:28.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
847	\\xf18b50185b03b50b9be8aaf08730116e8467d88e83f06df771b0c7d993b4b0b8	8	8434	434	829	846	3	4	2023-10-25 18:00:29.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
848	\\xef0847988b408389e0ca414b69fe6f9499d28df1e95473ca31884ab3f140f9d2	8	8441	441	830	847	5	4	2023-10-25 18:00:31.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
849	\\x4649cc042ddae92918ecd5c85f496ad28fdfbc5af84f37c3a1a8f5e5dc42dd06	8	8445	445	831	848	17	4	2023-10-25 18:00:32	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
850	\\xa766a3de31e7f60e0c04c440e596c47a82b24e52b95e520acc95ea1a06db57d9	8	8457	457	832	849	11	4	2023-10-25 18:00:34.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
851	\\xb5b1808a86c1ed2b3732e12e51536d15a7caece9105d4b2bdc62ff97358ec933	8	8463	463	833	850	11	4	2023-10-25 18:00:35.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
852	\\x18297bbdf06641c1cb180b9d141542b969c37e836eaacddcef54ed5fd4b50523	8	8470	470	834	851	9	4	2023-10-25 18:00:37	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
853	\\xe7c55c468cee6d695bddfcf23d47df8c1f2980b5ead34980b59b31861d6e2e0a	8	8484	484	835	852	15	4	2023-10-25 18:00:39.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
854	\\x0d6823cd90d39de65ca53948b5dd8d9ade7777cabe38d35403df9665e5c361aa	8	8492	492	836	853	11	4	2023-10-25 18:00:41.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
855	\\x2acf50856705443f798d7d5c9a2c12c4ea0f5c23581dc5d88c3eafa2e7c025e3	8	8502	502	837	854	13	4	2023-10-25 18:00:43.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
856	\\x970c148d12d10f8c6085682e653ff1a9bc337816cad565bbbe52d912610a9aea	8	8503	503	838	855	5	4	2023-10-25 18:00:43.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
857	\\xf91692e22e99e18bd93fd9a1713c55635b8c815b3037f91aa1bd433b58e7b0a9	8	8509	509	839	856	11	4	2023-10-25 18:00:44.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
858	\\x4fd29759a46e38365d9816831ba51c13437588e5b2033b1831896553614a0d17	8	8510	510	840	857	11	4	2023-10-25 18:00:45	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
859	\\xd3e8a6c346917a74229dab47472c6a760c2205858c5d58a8ca198f1ef50c8c74	8	8512	512	841	858	3	4	2023-10-25 18:00:45.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
860	\\x1267cf3be24f9c2bdadc24ac6a7a85e3a1f473d80299fefde60acd49de15fd4a	8	8523	523	842	859	13	4	2023-10-25 18:00:47.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
861	\\xa86cd3f6eda20a3ce289c9eede279730935c51d11c5746f37f861129e9196f50	8	8540	540	843	860	15	4	2023-10-25 18:00:51	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
862	\\x0b1a7f91541751889ffd710755765b9c4f1ed1b460f4802425efc876b1dd00bd	8	8542	542	844	861	5	4	2023-10-25 18:00:51.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
863	\\x6fdd0145a6cf9b8dd111d4f03af3f3ede04382387f281fe18a2b4950d3456a7d	8	8551	551	845	862	15	4	2023-10-25 18:00:53.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
864	\\x0e00858a3fa54a26122bf4298dd79e0ca97383f2aeb31a9f5fa1abc9fba2d903	8	8558	558	846	863	5	4	2023-10-25 18:00:54.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
865	\\xf60a4f5f25125bf29898754f89ab7685b54392a3f9c00794ea7344b27fbd07d9	8	8573	573	847	864	8	4	2023-10-25 18:00:57.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
866	\\x1553c9bcb06a264a6b520a81a2019fae145a8c04ca56afae794215d2a38a1b55	8	8581	581	848	865	11	4	2023-10-25 18:00:59.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
867	\\xfaf1e796705da9a8fb67b9a5d9a9224d054977ba856be3210b89d2218389e8f5	8	8639	639	849	866	6	4	2023-10-25 18:01:10.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
868	\\x1a704b621d9c19218cbeea9fa22097f9585da0600b9223253859c9f0160eeb75	8	8645	645	850	867	8	4	2023-10-25 18:01:12	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
869	\\xbc0d82a2e1e54c6ffd0c477d2783f7eb3558b61eeef21f2de2648c1fc4411e87	8	8657	657	851	868	3	4	2023-10-25 18:01:14.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
870	\\xcdd17bb3f7af90a8e66b494d9a9fc6311d9a29e3b7733533949c32d78ae3e5e8	8	8670	670	852	869	13	4	2023-10-25 18:01:17	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
872	\\x1158457c7a06502ac1a460d8284648d1e4534ee84e261dea1665595ea74a9ad6	8	8676	676	853	870	15	4	2023-10-25 18:01:18.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
873	\\xbe537c63cceb8c61e2855a3741fb26ba4a897e1ffca1b4efcdcb234ba5ed25a4	8	8690	690	854	872	11	4	2023-10-25 18:01:21	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
874	\\xd3f64bbd1a0f0d957c312f2679747d3bfbff3966653110ab93eb592cd40a80f5	8	8691	691	855	873	9	4	2023-10-25 18:01:21.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
875	\\x1f65776ec96f7104583d19d974da8f1a1cb5e65fb7893e362a2f63547fe4b582	8	8698	698	856	874	11	4	2023-10-25 18:01:22.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
877	\\x162171321c16cca8fb9999a8949537d47a8d960030f0d553d991bf10f0b63398	8	8719	719	857	875	3	4	2023-10-25 18:01:26.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
878	\\x3fb52cafefc1a7e29e669d55d0b3cad5cd58b3a26e2edb2ba9d9b25bf30ea63f	8	8720	720	858	877	5	4	2023-10-25 18:01:27	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
879	\\x9f13f73795869f72ee29f958eb8204629a96100ea5359ea06947580edf83f111	8	8732	732	859	878	15	4	2023-10-25 18:01:29.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
880	\\xdde82c13d8e9a3bd2134ca19171112969a1049fbf042914a3c76f7ee8750dc7a	8	8751	751	860	879	9	4	2023-10-25 18:01:33.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
881	\\x7af16e6c45641b1bca63309683fcf0b1b111c2ba8358abb479a46a9f8bb0c3c4	8	8756	756	861	880	5	4	2023-10-25 18:01:34.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
882	\\xc0083602f0a6985bb516175795035052d14a4b3c65bb05c1ea34a010f1ff43a8	8	8759	759	862	881	13	4	2023-10-25 18:01:34.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
883	\\xa738f428e6fbc72e0386ec49d239e2df2b38ef184d0d75dffd2f44bbf1c25b0d	8	8761	761	863	882	5	4	2023-10-25 18:01:35.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
884	\\x8f8d4f2de7b2e9c0bd8442491a7569816643131b89bb9a57bba8f82852950c1e	8	8764	764	864	883	3	4	2023-10-25 18:01:35.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
885	\\xa9f29fac43867a4110a878152b4a23398b8e5b62873ddc13ac35ce83170035c4	8	8768	768	865	884	11	4	2023-10-25 18:01:36.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
886	\\x484098c9472a84cb7dee8517605b652ab25ff567ac91cb1fcd863f715c6fde66	8	8823	823	866	885	3	4	2023-10-25 18:01:47.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
887	\\x8cf6251d96579da6943e52d400e78f1f27c0db0eed3bbcf3a0a489b65dad1037	8	8827	827	867	886	15	4	2023-10-25 18:01:48.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
888	\\x3460f4a6b807c87c0d8d12d59aa478853d6d0c06f52846f5ef5964722e0f8ca5	8	8840	840	868	887	8	4	2023-10-25 18:01:51	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
889	\\x96521143f3219aa4d127d26d788c8e73028145a232a27bfd015b5ab6e6facb37	8	8852	852	869	888	8	4	2023-10-25 18:01:53.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
890	\\x7071c0e22dd5784aa286a7dd5bcf4ff52cc4ee2c565e07cca15bdded32d08c32	8	8858	858	870	889	6	4	2023-10-25 18:01:54.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
891	\\x4e14e48f055873651506bfd94b0c8d76dfff9758a84170baa9b58bc0abf79a5b	8	8872	872	871	890	17	4	2023-10-25 18:01:57.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
892	\\xd6cdc31e6df0d6103cf0a21d67d013efe14ba73b8e59c6e218c7ce29d849e546	8	8879	879	872	891	15	4	2023-10-25 18:01:58.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
893	\\x815db655b9f354a6567992321db1262cf28a4e77bc58422d9e3548ae690abe02	8	8880	880	873	892	13	4	2023-10-25 18:01:59	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
894	\\x4c89a0132f22f0f652ab6ea3d2e9350fbff22677680d17f0eecc8546a164ca99	8	8882	882	874	893	17	4	2023-10-25 18:01:59.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
895	\\xd810ac7d2c8168a2c474b4dd7ba3714818263018f8ca9089d5a3e9bc79e8418e	8	8886	886	875	894	5	4	2023-10-25 18:02:00.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
896	\\x2b7b319ebbf0cd6c8d5e7b9684245e2d4557e0ded81ddc2bd4289dcd50988723	8	8888	888	876	895	13	4	2023-10-25 18:02:00.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
897	\\xfddfd19c2bebdd6de6fe5db8775c24fba171784ba63bb98de9a55b51c5b102f0	8	8890	890	877	896	3	4	2023-10-25 18:02:01	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
898	\\xf937bfa154139b0a9c499c38dc81c6fa626574485230ff04085f7540962c270e	8	8891	891	878	897	5	4	2023-10-25 18:02:01.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
899	\\x46009d6f6c8a296ef3bfebb916d1ef1efaa1f0afe3b361798052eb673e4267dd	8	8902	902	879	898	15	4	2023-10-25 18:02:03.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
900	\\xafc2df429058f44570d3b7205fcd8ea8e30d0ce6a911a1208eaeb6481312c745	8	8903	903	880	899	5	4	2023-10-25 18:02:03.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
901	\\x4efe65aaac56b8a69cdbf3bc290e88f2b37447268a03ac9a2b7525534b831abd	8	8904	904	881	900	11	4	2023-10-25 18:02:03.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
902	\\x14b2d21c294f58a87a923605bd80ef33c544988e344ab276d56c1e8e00da0ec5	8	8915	915	882	901	11	4	2023-10-25 18:02:06	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
903	\\xc9313455c9e09d1f26e75d98c08b74e9fd88fbd493c52636d2a22664170fa26d	8	8920	920	883	902	8	4	2023-10-25 18:02:07	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
904	\\xe1c28b09bc0b9d23278d1c4f9acb841c22d624e18033b80c863a645fa60acc38	8	8943	943	884	903	6	4	2023-10-25 18:02:11.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
905	\\x1eeb5d2fc59e953f18143cfe50ae60f7d2f99038b49802313f876ff2805e9320	8	8957	957	885	904	15	4	2023-10-25 18:02:14.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
906	\\x456b1f64dde17e415fe20d64cf26cf08b3ceec346b2559cd1a8634ee48580c62	8	8965	965	886	905	6	4	2023-10-25 18:02:16	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
907	\\xd5709ec99e3e1840a73fe790d5e9a435056455047a21235e96fe1d86abdca64d	8	8968	968	887	906	17	4	2023-10-25 18:02:16.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
908	\\x659827e74eb5d17451503f717e25d0531181760de1ab8039e69f79d478cde2b2	8	8969	969	888	907	5	4	2023-10-25 18:02:16.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
909	\\xa26ae9c3d95c6a538d93f33095e6d0e94f6bea2955f8af14c74c12e80549910a	8	8981	981	889	908	13	4	2023-10-25 18:02:19.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
910	\\x7bae1ac49ea18f2be2e5528b56cdde37aa5a7270955c838f1441f192034a13a1	8	8991	991	890	909	13	4	2023-10-25 18:02:21.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
911	\\x2949ad9bfe6cd442940f1adb195584e2b3eb8650fa413b1fb166f6d5171f1981	8	8999	999	891	910	17	4	2023-10-25 18:02:22.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
912	\\x959da75f011667820c5578c13cce75893f2fd8775988243d6898651a47df10db	9	9023	23	892	911	9	4	2023-10-25 18:02:27.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
913	\\x370720c8392adb66da418cfe688560505cdda31af7cd34128b8563fa99d048c4	9	9026	26	893	912	13	436	2023-10-25 18:02:28.2	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
914	\\x72523b2d8ba7e0afb90b2bc1ae2e23e6d9d3934512071463392b201bc3d20552	9	9031	31	894	913	11	4	2023-10-25 18:02:29.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
915	\\x3d50a8e40819562d35d3e50091b3c7c5ae9d2ea54f99a3337a42544ac97e4700	9	9036	36	895	914	11	4	2023-10-25 18:02:30.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
916	\\x121d4bcca872206e8d6339e38711a630adffd0f288041fd501e9944a150bc7df	9	9050	50	896	915	6	4	2023-10-25 18:02:33	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
917	\\x0a2875327b754ffd2dde6cb2e593d0229c265154a115c0b668ee281094f48458	9	9051	51	897	916	11	4	2023-10-25 18:02:33.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
918	\\x418db3a25a8f7a8dbd092eac6d756478d3be818a0c33456fe4b47eb19bd6fa46	9	9053	53	898	917	8	4	2023-10-25 18:02:33.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
919	\\x46ed96ca4eee5d33ebc6f097ac47b41dbf15333550cec64a2a37f0e3cf5c73a1	9	9065	65	899	918	9	2182	2023-10-25 18:02:36	1	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
920	\\xe5acc55cfcd7a6dcf62ae7f35ad8a690b58020d1b51f56faef8f2633760f3ae6	9	9070	70	900	919	8	4	2023-10-25 18:02:37	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
921	\\x5f63b96940480e8c6666b5816f87559f3b153a98d45783572ef2a0fb404e2f6b	9	9089	89	901	920	3	4	2023-10-25 18:02:40.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
922	\\xc1c8a485d56acf7327a970d1dac3b4ab64739e4fcf21edab5151edab56534ec9	9	9111	111	902	921	15	4	2023-10-25 18:02:45.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
923	\\xb05520bee793efe19f7be994043ff59276e4d6e7d786740cf77d21c47d15654f	9	9113	113	903	922	8	4	2023-10-25 18:02:45.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
924	\\x44941100720aeffa92dbbfaeb97812c6ef1e9a7c0d535bc6b2d1ab478676e416	9	9116	116	904	923	3	4	2023-10-25 18:02:46.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
925	\\x6360e7fe141c391061c15272357fb642369a2b6917afdb5a404f85bf1a73413e	9	9122	122	905	924	5	4	2023-10-25 18:02:47.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
926	\\x3a7ef9c65c5bb587c1ceeafedabdb7b6490feb62c750c0278593a5bae83a846c	9	9142	142	906	925	13	4	2023-10-25 18:02:51.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
927	\\x1da1229cb7bd883d908c7692552b8e8f6d0d33ecefcb361c0c6571583e272e28	9	9144	144	907	926	9	4	2023-10-25 18:02:51.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
928	\\x653da5060faf6e38471e5163e5c5eab766f27a75c3ba474f7fa2fab632f7c1eb	9	9152	152	908	927	11	4	2023-10-25 18:02:53.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
929	\\xa9e43236641d510f78ac3e47fdaaf353841902e2de6d060eef01999d612d1a70	9	9157	157	909	928	8	4	2023-10-25 18:02:54.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
930	\\xdfc4fb59ec24ad2eb35f64600069c8a33ea3c5dfa24ce6718f304e5a11f1c953	9	9177	177	910	929	6	4	2023-10-25 18:02:58.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
931	\\x7bc4ae97571ed74add5cff1fb2513284f2334e5a1a2f883f05c5bb1ef54cfab3	9	9183	183	911	930	11	4	2023-10-25 18:02:59.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
932	\\x83b9511c56e0c4304d2d3701ef1165622ae110c50cec8de181782c8c03cd1f55	9	9184	184	912	931	6	4	2023-10-25 18:02:59.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
933	\\xf36eba37acd9ae9b45f4bd0d8fb18f55a1e2ee02c3ec3709571395f4b9e5fe56	9	9193	193	913	932	13	4	2023-10-25 18:03:01.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
934	\\x5af5bf88ea2d7372f8f4902f975f9ee93b307c026c47b8cf0d76b2d341fd0f2b	9	9204	204	914	933	9	4	2023-10-25 18:03:03.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
935	\\xa0e23f9a5c26e6a4c14f4f295211b98425ed81ccce9cd9f35a13b44015235646	9	9206	206	915	934	17	4	2023-10-25 18:03:04.2	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
936	\\x8039e56e425f86bfdcb0999337558c80c8ff01f3e321bcf20c41dc61c7db81bd	9	9212	212	916	935	17	4	2023-10-25 18:03:05.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
937	\\x70b5a7cf3f4dad97872ba55d4bbe8a98fffc80b6c2e8c6b8766374ea01a1ac21	9	9213	213	917	936	17	4	2023-10-25 18:03:05.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
938	\\xf28769814c58b356f2028979e269baaabce731d707bdb8761f9c7c20edcbee94	9	9245	245	918	937	3	4	2023-10-25 18:03:12	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
940	\\x8a9b89b22ce55393b1b2aa3457021c1bab2ee35d81d493b3c8f9a3b90633ff3f	9	9246	246	919	938	11	4	2023-10-25 18:03:12.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
941	\\x7c70214d6a3536d01e7fb3c9311ad2f05b19d4c7166aabccfdab53267ec5b107	9	9253	253	920	940	8	4	2023-10-25 18:03:13.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
942	\\x12cb9206662d30df1705ee7179f6d572cd6068271871fadde642aba059eb36ca	9	9260	260	921	941	11	4	2023-10-25 18:03:15	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
943	\\x16be640dff407f73b787c47f16b4119646caadab88c90c019a09696fa190510a	9	9272	272	922	942	17	4	2023-10-25 18:03:17.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
944	\\xf611fd3891448f3e8449c93437eec9c087c2e4b5a8cc80b97fddf502386f8216	9	9277	277	923	943	5	4	2023-10-25 18:03:18.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
945	\\x594d7174347ae24401e489c5e0dce032ede5458797eb78ed3ab59a0a4b38c7b0	9	9288	288	924	944	5	4	2023-10-25 18:03:20.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
946	\\x3356e8c6fd60900d6d56218ae4f6b746e22f7ec56f43c274e863429c7180fec3	9	9315	315	925	945	17	4	2023-10-25 18:03:26	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
947	\\xe8039c4f5cc9314285ef3a3d851decc480c39de771e53d733a1911e6e96a01e6	9	9322	322	926	946	11	4	2023-10-25 18:03:27.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
948	\\xc00b2bf32d6fa724d910f13aaccd14cc6b1031f992f5734cb950308c6c1fc1e5	9	9323	323	927	947	11	4	2023-10-25 18:03:27.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
949	\\x6f4c35eb8d84354025477a4797456c9c4008765ddd2e5293a40528f52598ee5c	9	9333	333	928	948	17	4	2023-10-25 18:03:29.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
950	\\x0ae6a108522cb331db9710a950f60c0204c8d7a432f27d1010b59fc3b8c9650f	9	9343	343	929	949	11	4	2023-10-25 18:03:31.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
951	\\x363cd6fe0834471b572d55d034554464d6b24482b26ff3b3a90f05caa72fce6f	9	9359	359	930	950	9	4	2023-10-25 18:03:34.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
952	\\x8814deba2458fbac42170cbeded123fb9e2024ae505bc21cd18fc5acbd3108f6	9	9374	374	931	951	6	4	2023-10-25 18:03:37.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
953	\\x1293c905e806a15b454075c87c502a6b1566e44f1327efe4af8bbbfe99424d89	9	9380	380	932	952	5	4	2023-10-25 18:03:39	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
954	\\x0caefe3104928559b37c11320b0d0b3c08a0566fe93dea7f184b499ef710a01f	9	9382	382	933	953	6	4	2023-10-25 18:03:39.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
955	\\x4f4e6435a431309048c57ef54a42ff54358a40974985bee662ed86c3f91a8fed	9	9384	384	934	954	15	4	2023-10-25 18:03:39.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
956	\\xde5b0b491ff8961d2f37d50e3979ba66ceebc76fe55f037f0ff2a7899787b18d	9	9388	388	935	955	3	4	2023-10-25 18:03:40.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
957	\\x1d19b10c26dc824a5d527cdb4b0dc5b5179ccbe0bba57852001c0e921e32dfa4	9	9395	395	936	956	5	4	2023-10-25 18:03:42	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
958	\\x7c042f4f7b34d337f0e3de03b6f21f119a9d1fb1aaa30fac58de47a408b1f5c1	9	9432	432	937	957	17	4	2023-10-25 18:03:49.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
959	\\x29be038f67ed33c4ef4d8a1899e5ab574aec0a4f1ec2602dfd525addaf820e65	9	9435	435	938	958	3	4	2023-10-25 18:03:50	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
960	\\x6b9c5be413f4c92caa91207b790e5f71e9eb7012841d10bd2d0c0e70e021083d	9	9461	461	939	959	5	4	2023-10-25 18:03:55.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
961	\\xd44cdfd2bdb86fb00aef56c2c28be99eb3efbe3729ae1c03d2c8f090e58aedef	9	9465	465	940	960	15	4	2023-10-25 18:03:56	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
962	\\x80868733ccca58f2e43cc19ab38e65102abe303bcff78897eb7da912b7ddb5c7	9	9476	476	941	961	6	4	2023-10-25 18:03:58.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
964	\\x9af15c69523092bd748b456554da91ebc199d181b2b4177093c296a8612dae53	9	9481	481	942	962	6	4	2023-10-25 18:03:59.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
965	\\xe4af4c327f9fa7d9cbfb6e521d7ac0a9766dfbf802183164ccd50098a2d43f6b	9	9496	496	943	964	11	4	2023-10-25 18:04:02.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
967	\\xdcf9aaf52160e5d6fc8dabfa66ad7a57363e8e853b293e782c98e26ec89c2bd0	9	9511	511	944	965	17	4	2023-10-25 18:04:05.2	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
968	\\x1709f67f10172b3a695ad9c7cd5d6be654174105d60fe3923efb1f332f4453c9	9	9533	533	945	967	9	4	2023-10-25 18:04:09.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
969	\\xa6872d171699d3d772ea04040ce59493939ca3212e1ea93c5368ae5ff1e728a1	9	9538	538	946	968	5	4	2023-10-25 18:04:10.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
970	\\x0a7a898d0aec735cb2c58f35ff1391e0b2169b3652073ab8966cfe5b7e285d18	9	9542	542	947	969	5	4	2023-10-25 18:04:11.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
971	\\x445f1af35282283d9fbb20c1a3694fb2420f06854a577a8eebfbbd3f22d3867d	9	9543	543	948	970	17	4	2023-10-25 18:04:11.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
972	\\x8a86085b13ed8e0c2b37a7dc5e81c513f32d59ec349113ef771da16d4704269e	9	9544	544	949	971	11	4	2023-10-25 18:04:11.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
973	\\x67d1a8fa8b9863e2ca48dcf9be07b7aa437e58c1444e05b810494ec99d76da1d	9	9548	548	950	972	5	4	2023-10-25 18:04:12.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
974	\\xcbf5df083f8894e8cad6a891d8adc7e5128ecc2cbbce96eaef9eaa1526a4d840	9	9568	568	951	973	15	4	2023-10-25 18:04:16.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
975	\\x379cfe9df15f0043f69be5be756afaf9692d486b393f3201ef62b0aedf142a5f	9	9570	570	952	974	8	4	2023-10-25 18:04:17	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
976	\\x3962bf8911f5c00845dc0f5b338664a7d317e4e1224d49a32699007ac9cbd8cc	9	9587	587	953	975	13	4	2023-10-25 18:04:20.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
977	\\x8d87a596dfa608a249c8685bee3942346f8741e4a0a991ff81c74f17e5ef39f0	9	9589	589	954	976	5	4	2023-10-25 18:04:20.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
978	\\x7d69dc8aaec6d0262710e74e586b804c03563eda0e2238a1c8ffc2baf4e53d60	9	9598	598	955	977	5	4	2023-10-25 18:04:22.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
979	\\x0a320b583c944383110447c8a568f3760ed128e0dd9d897ee8bfb06347d08e5e	9	9621	621	956	978	6	4	2023-10-25 18:04:27.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
980	\\xaa8e6c8a185436c263653518b8e65b52749c0cbfece6d927652e3907dc3f5597	9	9640	640	957	979	13	4	2023-10-25 18:04:31	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
981	\\x38daf07e02e81c88523c4795aa43f911eb836b27549682c3b4cc15fbc2d8a1e0	9	9649	649	958	980	6	4	2023-10-25 18:04:32.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
982	\\xc3a82b509fea74633fbc97932e52737d270992cfd6af22478f325c0fb0ad9763	9	9655	655	959	981	3	4	2023-10-25 18:04:34	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
983	\\xb20ccfa57e024cdc65d17fc275469e7e7e4c8c8902dd512727d73ba21d3be978	9	9664	664	960	982	17	4	2023-10-25 18:04:35.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
984	\\x0451a68864769070ba616c338f71d7c6564dd744e526e9051b0aea3339704027	9	9665	665	961	983	5	4	2023-10-25 18:04:36	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
985	\\x7a6db7c043098f39f71b6ec3d71eb053b2bb2a064d27ea617416ee3ee38517df	9	9672	672	962	984	15	4	2023-10-25 18:04:37.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
986	\\x80878ed39efc5502bc0a162529547bceb9d9b822a22d305c24895cfa3eaa5e28	9	9680	680	963	985	13	4	2023-10-25 18:04:39	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
987	\\xd6bc9074c0a70e846b68de58f552dc5805655f5f63b10c2453be2deb5b56c39f	9	9688	688	964	986	6	4	2023-10-25 18:04:40.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
988	\\xbe49983a267ffc1f0b7baf67a4ae6539b881b4e5ae891d1024490e5d0b0566a9	9	9705	705	965	987	11	4	2023-10-25 18:04:44	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
989	\\x4c5907e23dab2178d4141d6c6de119a75a4b2da678eccc18b179665ed4dc39aa	9	9709	709	966	988	17	4	2023-10-25 18:04:44.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
990	\\x64460d0fef313cfc9eeafce461935b7d77f34d99b9a26be804999a0909a1e2b8	9	9742	742	967	989	13	4	2023-10-25 18:04:51.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
991	\\xf51775da38716efcb0ea512f21bd284b986fce26edeac0c6c85e10e7953816dc	9	9743	743	968	990	5	4	2023-10-25 18:04:51.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
992	\\xb8e1b9eaa0263f4e93ee0cb99a4ce05d256dc7c545bb0ae5fc52c6dab6944329	9	9754	754	969	991	17	4	2023-10-25 18:04:53.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
993	\\x266b61bae7901b972ecb0f90e76d2be19ee378e85458cd013a981e32a20929c6	9	9769	769	970	992	15	4	2023-10-25 18:04:56.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
994	\\x8d45a4d28f8184cdf39046cb084ff4d1f12436a43dd58cdef3a0ec184359aeed	9	9783	783	971	993	11	4	2023-10-25 18:04:59.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
996	\\x538db023156b6edf8358bf41a6487fd28ad4b26a266356875d4147addc8e0b7e	9	9792	792	972	994	13	4	2023-10-25 18:05:01.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
997	\\x41838c33d45e86b53a74bb129634294d944922258939c008861e17262760b4e2	9	9823	823	973	996	3	4	2023-10-25 18:05:07.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
998	\\x256f16db2ef339af8f29b6a07dfc1ff07346a1c382c8dbc888a25f46c5ec4ff1	9	9838	838	974	997	11	4	2023-10-25 18:05:10.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
999	\\x16887598116c4ca04d0d80658f6eb8619df0786fae3a8325765a9f2bfafa143a	9	9846	846	975	998	6	4	2023-10-25 18:05:12.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1000	\\xc6c06c4725b73df9d61a94ab402d9068866a6614b12331ac8060d3f74c57fdc8	9	9852	852	976	999	13	4	2023-10-25 18:05:13.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1001	\\x59208e35b4649f600d21e40c104e7ae21acd2d421ff128d04ba7f4c2555b53ff	9	9867	867	977	1000	8	4	2023-10-25 18:05:16.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1002	\\x30ed27fdb5d540dd790cc40992dab7c9f9617d0cb601edd6374d5a9977e1bbc2	9	9900	900	978	1001	17	4	2023-10-25 18:05:23	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1003	\\x575c62468e3a00fe68f6504d558137c9054f115504c7c80d421cf594a74d95ca	9	9916	916	979	1002	8	4	2023-10-25 18:05:26.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1004	\\x40ae6c9cd92b7bd6fdd56d7cd38fe48e03385a4cfb80cdc857247521bbc5d1e6	9	9941	941	980	1003	8	4	2023-10-25 18:05:31.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1005	\\x24c56b6a901dd064636fcd9a6268cb79c268574faf953f746eadcdccca20bf53	9	9947	947	981	1004	5	4	2023-10-25 18:05:32.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1006	\\xbc870cc27f3734cface5ded23af436af25414ff16f41f57c5c79957e7cd3557e	9	9958	958	982	1005	6	4	2023-10-25 18:05:34.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1007	\\x0186c3934d2419f7086d704ac0514bcd0f47298d7d6a59079a6b8d7348f9ce3a	9	9979	979	983	1006	11	4	2023-10-25 18:05:38.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1008	\\xe522e6a9795146e7f9be177dc62de671d9dec974363265b6f4ce4ffd29cc54cf	9	9980	980	984	1007	17	4	2023-10-25 18:05:39	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1009	\\xe8e91152fe6d30741bffad99ee78737d9cae53f0727efeb7cdf70f3e169bd97b	9	9994	994	985	1008	9	4	2023-10-25 18:05:41.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1010	\\xb01cd2a49e2e3e0864ca865eb9cbb1dfdf8198d3a93f35739e82f75272be5821	10	10003	3	986	1009	15	4	2023-10-25 18:05:43.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1011	\\x52e05094bacb43517ee59be7afc89a89e2435b7d6412ef16e5e2c5fdcea552b0	10	10006	6	987	1010	13	4	2023-10-25 18:05:44.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1012	\\xa812a8bed0bc77acc6a8c77061b4e4ddb4bf3c1d5a0ff4ff6f163da0ec57ff76	10	10025	25	988	1011	8	4	2023-10-25 18:05:48	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1013	\\xa38aaad78be455fb1db4558d948b9fd8acefffafe00452fa4169710cc44116ea	10	10026	26	989	1012	8	4	2023-10-25 18:05:48.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1015	\\xb01c79ca23c9a4d6108ba64019b1ad66f8f7e4d0e521f071529d27ecf284ff95	10	10031	31	990	1013	8	4	2023-10-25 18:05:49.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1016	\\xa376347ed2bcfd514799f227fe0549add783a6295e1d7667934c393fe2672132	10	10033	33	991	1015	3	4	2023-10-25 18:05:49.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1017	\\xb403253f70bd13875124fba4fc4f3557c4e3cef46cb701944283781b2eeb9b74	10	10061	61	992	1016	13	4	2023-10-25 18:05:55.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1018	\\x0f888e896e9ec6da8086953e81df58c1c7044b77d3de3dcf7829c8af6365ac60	10	10070	70	993	1017	15	4	2023-10-25 18:05:57	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1019	\\x7efb5655da046b83107b2b66fe7dfc66378206dbfe7c5376ed33c7408f17fce3	10	10075	75	994	1018	15	4	2023-10-25 18:05:58	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1020	\\xeea3783ed4119347fb540d623169aeaeefe60f46f2443519a6457453ee461eea	10	10076	76	995	1019	8	4	2023-10-25 18:05:58.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1021	\\x552776305d09d1ba6e696c58696c8738cf758127677a5f978c0306d405589557	10	10081	81	996	1020	3	4	2023-10-25 18:05:59.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1022	\\x2f2a3420ecb8f75f7c9b245175aa7132adf833f73ead192240b34a0b49d58202	10	10103	103	997	1021	6	4	2023-10-25 18:06:03.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1023	\\xdb264ef6a4ffda0e16e1e5511a9afac7635cf439fd464ac2acf839905023ba82	10	10116	116	998	1022	6	4	2023-10-25 18:06:06.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1024	\\x176a9f766a14751e319b070492eb51e512c1b30700718935b503e4ae54de92b2	10	10125	125	999	1023	11	4	2023-10-25 18:06:08	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1025	\\xeb62d52a8f8a2a861bb5ca21fa2c68dd855208838a5117a772c4007ee3810bad	10	10127	127	1000	1024	17	4	2023-10-25 18:06:08.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1026	\\x6b5be45ed22642c61a5e21a58d943992a760ab2fde2f0b18d25d5831133ca34d	10	10148	148	1001	1025	11	4	2023-10-25 18:06:12.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1027	\\x077e35f8c45265b38ce8fc405f57275c6362df7e957a3077b8f7dc9543ba8d7f	10	10177	177	1002	1026	3	4	2023-10-25 18:06:18.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1028	\\x7b089b92f57bd0af9bc976a558e9bd8e5150012eca7cec3191d703a55a6a76c4	10	10184	184	1003	1027	3	4	2023-10-25 18:06:19.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1029	\\x15231200feed44dd74a00c818d07375fd965c0f5d705fadeb6b323eac3edf123	10	10186	186	1004	1028	6	4	2023-10-25 18:06:20.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1030	\\x2f6c24a9fcd23c6086c59ced11a88802158adf8a39450048a9d9b93d8949b2d1	10	10189	189	1005	1029	5	4	2023-10-25 18:06:20.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1031	\\x76a45297fb80d18a6216fafbaf4f71bb7050b05132920b536d18e8faff567abb	10	10209	209	1006	1030	5	4	2023-10-25 18:06:24.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1032	\\x6eebac8821abfb22de3aa63fa882bd6b3d19336b426d2373660ecfddbbb9b490	10	10215	215	1007	1031	5	4	2023-10-25 18:06:26	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1033	\\xda912eeb7621c23191beb01e50f81f063d83327cdf76994380ba411e600045c5	10	10217	217	1008	1032	17	4	2023-10-25 18:06:26.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1034	\\xb02eb29754e7b3867103aed746d0c812d9f18c2146d0af6d062c582578904790	10	10223	223	1009	1033	3	4	2023-10-25 18:06:27.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1035	\\x6b8a2621563faa97c1c6f2fffecb4522333dd4b53dd19ee4e0cbb8f1ff0233c8	10	10232	232	1010	1034	8	4	2023-10-25 18:06:29.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1036	\\x0ce2ba8526446cc1b9cdb22cab579ff60a74c046d173624f54b3607643b4c245	10	10233	233	1011	1035	5	4	2023-10-25 18:06:29.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1037	\\x3f9cc85cb42f49e14976baaaec6005a1af5b4e6a7d0d9ee52ea1b38a116b0591	10	10241	241	1012	1036	3	4	2023-10-25 18:06:31.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1038	\\xc24e45c842bfe8b886ed3bf4063b33ad7d1ce1943fd8be5f20da90ae6de0a239	10	10266	266	1013	1037	15	4	2023-10-25 18:06:36.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1039	\\x487c7d84bfb5bf0337aa885f62dbffce75cb8e5077d6c56a48f1a482716bb01c	10	10271	271	1014	1038	3	4	2023-10-25 18:06:37.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1040	\\x23dab2e290b01b6b7b0c8b303bf29bf7c0fc25722ca7707373d5ad6b058ee6bb	10	10272	272	1015	1039	11	4	2023-10-25 18:06:37.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1041	\\xa9b30206f5977df925749635fc3e7510f443c34ce563ee01eaba208ec453e2b8	10	10276	276	1016	1040	11	4	2023-10-25 18:06:38.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1042	\\x344514e72c9fdd00cf0bfc9aa9aafc4b7c13cf498825650dba5675c72a89ac63	10	10285	285	1017	1041	6	4	2023-10-25 18:06:40	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1043	\\xb7af501185d059012797a1b843b3348e56f51f7d73658ac42ef33dee1229535a	10	10317	317	1018	1042	3	4	2023-10-25 18:06:46.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1044	\\x2a359095e4b8a238c704a75be01b72a80a962f7eb2fdc4869391962881b485ee	10	10330	330	1019	1043	15	4	2023-10-25 18:06:49	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1045	\\x7cc7f02fea9385c67b2e5950de6a3b5e19bcaa90ba7b6ad22169fd39b7246e34	10	10331	331	1020	1044	5	4	2023-10-25 18:06:49.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1046	\\x1fd38dfe2aa678df432f039e1efcd36ce657386ad745eae8839ec419c40fac87	10	10351	351	1021	1045	15	4	2023-10-25 18:06:53.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1047	\\x93607a2fb238612437d4a1b6714edb066729747ef3444fe89514b18ebe82ad08	10	10364	364	1022	1046	5	4	2023-10-25 18:06:55.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1048	\\xd1d157d17610fa9066cf98bf5c129b77cd9454e25bb7881dc5f4236761b950c4	10	10365	365	1023	1047	13	4	2023-10-25 18:06:56	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1049	\\x073a74493e149ddc8872183e32016850738ca2f835c2d375b5c61e521a63600e	10	10377	377	1024	1048	11	4	2023-10-25 18:06:58.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1051	\\xf8ed8969b6f5b0204edde1358c5a0a89b485e5fc76b455db4a517a5f3d16c01a	10	10383	383	1025	1049	11	4	2023-10-25 18:06:59.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1052	\\xa4dee73938b8097fcffc10746cb0b24cf3f6cb32617804f36e727a47a81e8d83	10	10385	385	1026	1051	8	4	2023-10-25 18:07:00	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1053	\\x3115603ef72fbaff865aaebb9f5e7091969003d65cdd4c70f091a99b9448db79	10	10388	388	1027	1052	3	4	2023-10-25 18:07:00.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1054	\\x463c9e7e12f07572fca3f0a431e51cfafe7a9a198ff7d0a9d1a8667c0ae7bc9f	10	10401	401	1028	1053	8	4	2023-10-25 18:07:03.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1055	\\xaee79b17b9ec512fa607559d06469310742f1c922799eee0aff9208bfb68d590	10	10402	402	1029	1054	6	4	2023-10-25 18:07:03.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1056	\\x25629697d28d4be946403f7f28d4a143eada10ea7d9cf27e6ed42371206814df	10	10423	423	1030	1055	11	4	2023-10-25 18:07:07.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1057	\\x0f44f1f265768351922361cc5ed587a21eab1a76a60f22d498e9515565a6e84e	10	10433	433	1031	1056	8	4	2023-10-25 18:07:09.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1058	\\x2ab8278078541e1c13d60bd992e1d1d0d1eebd1b9f2e5c564821c6cd07f94779	10	10443	443	1032	1057	9	4	2023-10-25 18:07:11.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1059	\\xe722e755195a6abed2077d5aea5a32e3958b393382f9dd58017533910265d5a3	10	10444	444	1033	1058	3	4	2023-10-25 18:07:11.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1060	\\x01246d3ce8b304f2a5b1bcd9492e6b519435b4c72837ca108e06675425fb4540	10	10448	448	1034	1059	3	4	2023-10-25 18:07:12.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1061	\\x7ce9fac6ceb195343066bb31a2656028143d773f9359a9c277953fb8550191a6	10	10454	454	1035	1060	11	4	2023-10-25 18:07:13.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1062	\\xbef0a2a4f21ca375385b2930aef1c440eced81a203b2a03241b6fd44fc96fb20	10	10460	460	1036	1061	15	4	2023-10-25 18:07:15	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1063	\\xb94de67e95213476db3570372b19d98612a5ab0fb0cf95a0f059cb2aae3cf00f	10	10464	464	1037	1062	13	4	2023-10-25 18:07:15.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1064	\\x7c6bfcf7355dc7f1b2cea0faf38f9d1e7cc9b3940b2218883eb80a329f294a1b	10	10466	466	1038	1063	15	4	2023-10-25 18:07:16.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1065	\\x69d79db55bd02807e380a4cf6efbad637b75e00cecf7283a45f196f87ee6c016	10	10484	484	1039	1064	3	4	2023-10-25 18:07:19.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1066	\\xa212fb504d5cef60ce42ff94e074b582b56f2410ab194c6d5bfab5a44338e9fd	10	10495	495	1040	1065	5	4	2023-10-25 18:07:22	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1067	\\xbfb8f6aa05087cbddab94fa22bc5d35d53623330fd5d4d46478288698e4ae7bd	10	10505	505	1041	1066	3	4	2023-10-25 18:07:24	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1068	\\x4f786b9005f4433d3a8bbf351cfe7088192a7c41631b3756ad1c062bed8fe3d6	10	10525	525	1042	1067	13	4	2023-10-25 18:07:28	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1070	\\xe6273f53413a74282082a94e2808dd9af81e1755abf2918ef787cd366afb17ea	10	10527	527	1043	1068	8	4	2023-10-25 18:07:28.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1071	\\x7180c6aae8eee6f9a0a23359ddbea22497d088b6c8d10a0fd19b82b3b67190b9	10	10530	530	1044	1070	6	4	2023-10-25 18:07:29	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1072	\\x4cb2fef477208335fd73d9a35a1924de9e64749c445e53bb44b3e76746e824df	10	10534	534	1045	1071	13	4	2023-10-25 18:07:29.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1073	\\x1fc054aa757cdb8200dd481d329615ec6e6e2ce606d43ae17cdf5d7248d2727a	10	10540	540	1046	1072	3	4	2023-10-25 18:07:31	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1074	\\x43108746321632cec720012220384ede3ed403d3d333efb6932503da988cc466	10	10566	566	1047	1073	13	4	2023-10-25 18:07:36.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1075	\\x809dbae491e6ebb619f56a2141de44bf6a68aac56820b8d93eeb1df67b26692c	10	10574	574	1048	1074	6	4	2023-10-25 18:07:37.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1076	\\xea2f84952d2159e1ca53c410f2ede57cafd741cbcb8fe20727ca701014c35e7f	10	10579	579	1049	1075	3	4	2023-10-25 18:07:38.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1077	\\x44f53adbe80cacef32304050a74bdb9c8e2b09d4e90810d492c43e263fe08b94	10	10619	619	1050	1076	3	4	2023-10-25 18:07:46.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1078	\\x4a4f77bd30783d3bf4887664b03b400a9c0837fecb8d601df7e3bb96e1b52883	10	10621	621	1051	1077	15	4	2023-10-25 18:07:47.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1079	\\x608d935f5e06d9e1bf6df97c438e8b099cfc06d863de1c2081c4d96f1e91cbae	10	10628	628	1052	1078	13	4	2023-10-25 18:07:48.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1080	\\x34f29da0088329cdd1b287ef65ec7fce7b80bb2ffd0d74d31391773a183b6309	10	10634	634	1053	1079	6	4	2023-10-25 18:07:49.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1081	\\x2e307e165b8a5b2538f06f08f09a323f8e74e806af802d824726dfa52c07e713	10	10635	635	1054	1080	6	4	2023-10-25 18:07:50	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1082	\\x9481ab29b93c449eeaf9f58920202ea3d57de47dbf2e022479c5ff3d0d677017	10	10650	650	1055	1081	11	4	2023-10-25 18:07:53	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1083	\\x004c1e5ad3a9a967c836308345985b213aa8e15748f22ab63a3d3e5ee05ea0cc	10	10652	652	1056	1082	17	4	2023-10-25 18:07:53.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1084	\\xc59c5dd6d27b6531b1693cf1b28b77f265367d4a901c71c0842ba417be4a6d5b	10	10679	679	1057	1083	6	4	2023-10-25 18:07:58.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1085	\\x24b801df34745ff5fe23afc78533c71359e7fff9f22c5cc7bff8895bfad398ee	10	10687	687	1058	1084	15	4	2023-10-25 18:08:00.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1087	\\x5ff5eb9c73556b4244886e322c2e40306b0f15fbb9b81d4a0d7effb502cc9998	10	10731	731	1059	1085	3	4	2023-10-25 18:08:09.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1088	\\xc18819dbf40b7121573b74090fd0440c67118e66098e92145604244de1963dd4	10	10741	741	1060	1087	11	4	2023-10-25 18:08:11.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1089	\\xcffd94f36f6dd0a24e2082406423dc350ad1545c51e46afbe166f319ed64b427	10	10743	743	1061	1088	13	4	2023-10-25 18:08:11.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1090	\\x5cf676058f272c8edea0b11020b177c8ac05abe32cf2f725253e6a5de1d1c8b9	10	10745	745	1062	1089	17	4	2023-10-25 18:08:12	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1091	\\x45532b19d86788e1ce8d04c8343eaf037dcd5d255ce6bcf683a42a43c3d3d901	10	10747	747	1063	1090	17	4	2023-10-25 18:08:12.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1092	\\xfa36970e887b0f57771e8ec79db496bb4f4d9495a8a590f7940677571abda943	10	10751	751	1064	1091	9	4	2023-10-25 18:08:13.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1093	\\x6fd2c2531a2120f92d42a1e3d8e99bd552cafdc84934672d522c5400443ac687	10	10773	773	1065	1092	8	4	2023-10-25 18:08:17.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1094	\\xedc2f0ee54f0ab2f5b7070662cff6304242b82939dd1f1292bfbd399ecab5cea	10	10787	787	1066	1093	3	4	2023-10-25 18:08:20.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1095	\\xb136908662fc2d94175ce9fc9b5844c216f0bbba0413d2e662b61af1e83236be	10	10804	804	1067	1094	17	4	2023-10-25 18:08:23.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1096	\\xcd2e48298410ee22aa394e8653ca91e095717f3d68391486a541c611d6ca3dd0	10	10808	808	1068	1095	3	4	2023-10-25 18:08:24.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1097	\\x5ee830f8071d04659c7092426d0e1ae436ba7545938c70ebf4fcaff4d5e0327b	10	10835	835	1069	1096	8	4	2023-10-25 18:08:30	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1098	\\xda9ddcf059141940b1c585fe279c29d007b9fd64ce5e037740e3f216c459788d	10	10844	844	1070	1097	13	4	2023-10-25 18:08:31.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1099	\\xfc6a0b3a69d55402234fc46fdea6b49454b656c1ef75da0625f93d41ea77c07e	10	10852	852	1071	1098	6	4	2023-10-25 18:08:33.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1100	\\x0fb025e7d78437488101cd700af278e230b40f73b13d5ac1fb323ad98707fabe	10	10857	857	1072	1099	13	4	2023-10-25 18:08:34.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1101	\\x3405dbf6bc05d6eedf88af61279e55132dab7e6df2de8c515e72e50a70d27285	10	10873	873	1073	1100	11	4	2023-10-25 18:08:37.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1102	\\x5231baaa815aa8af8656e5eaeaf56cbae1be018893911271fd37b56b7c99e552	10	10876	876	1074	1101	17	4	2023-10-25 18:08:38.2	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1103	\\x77234779f0d87daba6ed051ae56254d2fe0ed79584c1a578ff6549ca8596cbfb	10	10878	878	1075	1102	15	4	2023-10-25 18:08:38.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1104	\\x2bb8a59f00a8e0ad8992862eab3a749754534bf9983e74bac09f67d5dd89e908	10	10882	882	1076	1103	13	4	2023-10-25 18:08:39.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1105	\\x530ccfda2589024d9daade609f25ad389e34c97d79771ade5bcbae3e92b9de6d	10	10892	892	1077	1104	15	4	2023-10-25 18:08:41.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1106	\\xccb68696a5ec0cea8f5d909ded9f9085e99fcd6d9c2d96d4e83533820787d8ed	10	10900	900	1078	1105	11	4	2023-10-25 18:08:43	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1107	\\xae89da2509bc7b397b47210c4a128484ec6758461a2aeef3b88670ca324756e5	10	10905	905	1079	1106	3	4	2023-10-25 18:08:44	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1108	\\x3b58017813ca6f2b9398217f249c63cd0281ba868faaa09d4010ce7dc53a5921	10	10931	931	1080	1107	6	4	2023-10-25 18:08:49.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1109	\\xcc027c5087ac155e766771935888eb975e190c62e2ef7ec3182d7d7db79eb9d0	10	10942	942	1081	1108	6	4	2023-10-25 18:08:51.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1110	\\x7aa8ec50ae56c975309dfef93185a664f93349f64a14a9899ea86d534f1f6d8c	10	10951	951	1082	1109	13	4	2023-10-25 18:08:53.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1111	\\x5d92f8ca8ca00219ce536cfc826c2abff9287d1dcd84b0d699fb0dddba5c331d	10	10959	959	1083	1110	5	4	2023-10-25 18:08:54.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1112	\\x5c93f5f3575646e02b7ef64b587e7eff488a9660b852596fafaa3db71ae807c6	10	10978	978	1084	1111	15	4	2023-10-25 18:08:58.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1113	\\x3a51c1a5c4f9cb0fb15229d542438282086656628640056b043e6641d9577b59	10	10985	985	1085	1112	3	4	2023-10-25 18:09:00	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1114	\\x98f46f79344187a233fa07ca4cbf3f6f2f2df87895d503937ffbdc6871ec9427	11	11004	4	1086	1113	8	4	2023-10-25 18:09:03.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1115	\\x842486c8bac47ed53e92ca2d878cc75acfe3b778f14abf948f40e73ea0813d77	11	11011	11	1087	1114	6	13140	2023-10-25 18:09:05.2	43	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1116	\\xe5d72e03c4a9aa4fba93a0655b3696acc52ed541dedbd393c1db7fb60e485cae	11	11012	12	1088	1115	8	1256	2023-10-25 18:09:05.4	4	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1117	\\x9f6aaec9bb7929c2188b31be0428e1693e0e7efedd0a1f70748226d03fbffa45	11	11014	14	1089	1116	3	3375	2023-10-25 18:09:05.8	11	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1118	\\x847581fdebfd9c6937615eb1a0c71e2e6c3b073dec9eb107bad59410db862613	11	11022	22	1090	1117	8	13264	2023-10-25 18:09:07.4	42	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1119	\\xa6bf5383d5ff93cc1085cde64754075d3789166db7144bcfaba7c29d2e8d6e5e	11	11024	24	1091	1118	8	4	2023-10-25 18:09:07.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1120	\\x87eba393df2d0af5b200587dd1b28900c94db17711b8d3472faf01dddf116815	11	11029	29	1092	1119	9	4	2023-10-25 18:09:08.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1121	\\xc81b96e29a6bc6c4a9af647d907fe09ec8c9ae675eae291bac8954c89bb589ce	11	11047	47	1093	1120	15	4	2023-10-25 18:09:12.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1123	\\xb066bcf69c8e44d0f4ebc0bdd310a6fa12bcec1bac77b84ca66223d8ad060183	11	11049	49	1094	1121	17	4	2023-10-25 18:09:12.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1124	\\x162243457db5a946b294380cb5d4326d20b98a010096d3e34353c2369e95cc32	11	11060	60	1095	1123	3	4	2023-10-25 18:09:15	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1125	\\xf6a363bc8c25dbeee59a811d51e4113452bcd47ecec2ed4ec7d7c619355356c2	11	11085	85	1096	1124	8	4	2023-10-25 18:09:20	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1126	\\x78b024ad655bab5e803cd7a3dfba4546aed96362e191c31ee398544f0ea9e685	11	11114	114	1097	1125	11	4	2023-10-25 18:09:25.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1127	\\xa9a6ed417b01542d6d4b9b6ad19b68bb1dfa529fa385383118601ac4fd8d44a9	11	11124	124	1098	1126	15	4	2023-10-25 18:09:27.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1128	\\x893cec43e81596ec914e199c89ad3e5d9f8feb4f213b3c625bcd11c729f24195	11	11155	155	1099	1127	3	4	2023-10-25 18:09:34	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1129	\\xf1541e2c118e8cef6ecee3c5fd2b96fadf1b05965614e425ddbbfc1d0d2389f4	11	11166	166	1100	1128	5	4	2023-10-25 18:09:36.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1130	\\x9e151ebddb9de646dddcdecc71bfb7207d28f70c9beb31a88bb513e9aa0fe11e	11	11169	169	1101	1129	9	4	2023-10-25 18:09:36.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1131	\\x9a1081e7aff53c1e189251c9125d2aa0628279b35e4b5921f2b6fa029b7836ea	11	11181	181	1102	1130	3	4	2023-10-25 18:09:39.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1132	\\x9fed8d7a8ff596a5e0e8777002f344cb3ceb48f4b618587fcd3071f6325e91e9	11	11182	182	1103	1131	8	4	2023-10-25 18:09:39.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1133	\\x971764f8467c9718376804d82cba9a8a11b45e831b4b9199a6841e8040c518f8	11	11186	186	1104	1132	5	4	2023-10-25 18:09:40.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1134	\\xaf6b86ee3ead0b7bca9f41ab192b32a1b487c0ca7480c1af038d7d6068b8f5ce	11	11189	189	1105	1133	6	4	2023-10-25 18:09:40.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1135	\\x4e9589160487231bac8086caed0bceb32f01f75eb48a0404e26c67c7de6842fc	11	11232	232	1106	1134	6	4	2023-10-25 18:09:49.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1136	\\x6f7c83a0681c9afc6c8031302ba25f24b5faab8838498aada2e2150e2df09026	11	11238	238	1107	1135	3	4	2023-10-25 18:09:50.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1137	\\x80036478601caf0ea10c697f283d10bc5a691ac9320efff45657c52be6052919	11	11255	255	1108	1136	6	4	2023-10-25 18:09:54	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1138	\\x87fd15f621dfc665933302afe3b595a67a58641c8bf4840bb41d16e4f67c4ba1	11	11266	266	1109	1137	15	4	2023-10-25 18:09:56.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1139	\\x48d3291615c926595cf371f388285df373f78d30adb9b3857abb1840e658dee8	11	11279	279	1110	1138	9	4	2023-10-25 18:09:58.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1140	\\xa885f4d0fb94aef515e0c86b6bf74c7b88dcdf01479b791ab9b1d61ff05896bb	11	11294	294	1111	1139	6	4	2023-10-25 18:10:01.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1141	\\x22dfdf9761e9298f48197eb5db8c1dac56d1e54faa2d48e8c5647d630096198b	11	11305	305	1112	1140	5	4	2023-10-25 18:10:04	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1142	\\x0b98cce7d46e1a510624121dc738293b349965de8c21f94f8ebd870f0d667c92	11	11317	317	1113	1141	11	4	2023-10-25 18:10:06.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1143	\\x33d6e5d5580d9b102418975b578dc89d2694ec699ec65843e8fdc102383b0017	11	11334	334	1114	1142	9	4	2023-10-25 18:10:09.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1144	\\x09e3ccfdd71991727103720c15fa2220dafcf9d8453df81f0436ccbd3b91adf9	11	11353	353	1115	1143	15	4	2023-10-25 18:10:13.6	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1145	\\x0855fb36fb500e8ee03d33c757a54f84535e2fe8f034fe0ed2face3a82467b8e	11	11381	381	1116	1144	11	4	2023-10-25 18:10:19.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1146	\\x5587c10b27bb28aca6ba24ad60d1a5947fd1a89a2e19b1a63cc4a446a10e7692	11	11388	388	1117	1145	8	4	2023-10-25 18:10:20.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1147	\\x075a416e30f4008a367ba11a6bdcd6429ab16b810675fd9466b2c4308da0d42b	11	11389	389	1118	1146	11	4	2023-10-25 18:10:20.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1148	\\x88bd500a0a4580c85ba87475e0d68355c34ec7d50c416a0184a00e2704dc8b5c	11	11399	399	1119	1147	5	4	2023-10-25 18:10:22.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1149	\\x856f5257062f390018e70a32e0686c38602cefcad3820751c904a73042cf7a8a	11	11411	411	1120	1148	9	4	2023-10-25 18:10:25.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1150	\\x1228fdff947caa7afa3d88c206678e1d293eaf8ac086c479dd6dcfadf9c83049	11	11413	413	1121	1149	3	4	2023-10-25 18:10:25.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1152	\\x04a140bb4cdb52c40a528efb9ed7223398d5b772617089eb354884adf02e219b	11	11440	440	1122	1150	3	4	2023-10-25 18:10:31	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1153	\\xa16134e13acda53d59f35949f4e29ba8ae15c9eab19360734ef93c5d887129e4	11	11447	447	1123	1152	17	4	2023-10-25 18:10:32.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1154	\\x36ccfca76f3a26245c658e468598f741ed701cb0f3aa85cfe53ee2c528ae1e24	11	11449	449	1124	1153	8	4	2023-10-25 18:10:32.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1155	\\x82a143da8a0a436d174614f4f6bbaefcacf6fe7b7812b32773f8dfbc33212e66	11	11456	456	1125	1154	11	4	2023-10-25 18:10:34.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1156	\\x35a1b393c229fa6c83cb0201104dd6ef11b21f3c02cff3bf0540db579ce7e413	11	11470	470	1126	1155	17	4	2023-10-25 18:10:37	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1157	\\xd6f3b8e4bf649f9ad27324f0336f524ac87a158fff6f90f9f819b9d48981d6ac	11	11473	473	1127	1156	17	4	2023-10-25 18:10:37.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1158	\\xefe8dddc98e2a72b93fa9d2e146b9d9c5af48456f6ee0365c776a3ac1daec58f	11	11499	499	1128	1157	13	4	2023-10-25 18:10:42.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1159	\\x4eb3b526bb180cebeaf8dd122795d87cc91e0577ed4dd621c8958fc7ba13f3d8	11	11504	504	1129	1158	11	4	2023-10-25 18:10:43.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1160	\\xc08e72e27ae23b5f591a42612355831af2ce42eb1fb4644bcc13d89512a7ce35	11	11523	523	1130	1159	3	4	2023-10-25 18:10:47.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1162	\\xeecb6e6d27358e535701b46c2ce750a563311c342957e1728d2d0c617201ad2f	11	11524	524	1131	1160	3	4	2023-10-25 18:10:47.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1163	\\x8c5a3808fbde4a8b15b8175c409bde540ad451bcd1f5d3f38f7dae399f27716e	11	11531	531	1132	1162	5	4	2023-10-25 18:10:49.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1164	\\x075e667a3f03b5d1c332a182b4b889cd8dfa44c70aba3b39b59ad3b34c774593	11	11535	535	1133	1163	8	4	2023-10-25 18:10:50	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1165	\\x105e84e67f8918ffd15c45ca7d7f3e7fb7ffb30880851c5f8d5981d5d8a38e72	11	11540	540	1134	1164	11	4	2023-10-25 18:10:51	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1166	\\x710de0aa469074e3f49e44ed1271ae08ca08d898e00a5576d22e3f8df345d28c	11	11541	541	1135	1165	17	4	2023-10-25 18:10:51.2	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1167	\\xf66aae70cafeb890bfab7af9d8d5413cc0b051ef19c92f8f2eee12a2fc85a969	11	11548	548	1136	1166	3	4	2023-10-25 18:10:52.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1168	\\xa605c71a246c46783211962697726606f74d70735f86987e3baf4eeccfae7062	11	11555	555	1137	1167	13	4	2023-10-25 18:10:54	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1169	\\x0911d971c4428cde72e9a045805175710bdcafdbbc2e2f45b3fc3973cefe4345	11	11560	560	1138	1168	9	4	2023-10-25 18:10:55	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1170	\\x03983e06556d88bea8e89173a2214b43380660b7aa8effca2fdd199348886a70	11	11564	564	1139	1169	5	4	2023-10-25 18:10:55.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1171	\\xd78251c996b909e2f23a1b609e6a8e861ad02460b3fa1f128f8a8e7e182754ce	11	11565	565	1140	1170	5	4	2023-10-25 18:10:56	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1173	\\x5decdad6b78c78c10656fcd67c4b845de2408f3bfcdce4c236359c55f91c23cd	11	11575	575	1141	1171	13	4	2023-10-25 18:10:58	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1174	\\x726d9e46883439a2a732c45cec9668fdbb27c3bb9e14627f5a64f7cc8d4d26fc	11	11594	594	1142	1173	17	4	2023-10-25 18:11:01.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1175	\\x1341c8a5b63179a5af66701ae2d932bed0b41ba6d4a10f723a29c6dcb4a66c5a	11	11605	605	1143	1174	13	4	2023-10-25 18:11:04	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1176	\\xe1c041dbfab6d610d73d7d59c454b7e93ad0866447665721f0ffb6ba96f8b31c	11	11616	616	1144	1175	17	4	2023-10-25 18:11:06.2	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1177	\\x0d6eedaa10f430e4424e2d5e5a25108725235e4cae944a8eb489ef20b0511733	11	11641	641	1145	1176	9	4	2023-10-25 18:11:11.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1178	\\xf6eb2843e83c30a77801a78c6265270ada186ad767fde12b9f4c87d760a13ffc	11	11649	649	1146	1177	11	4	2023-10-25 18:11:12.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1179	\\x0c3703eb8c884a245252b145ae0b786383982781472e9b5c26207cbe0d6e9b41	11	11660	660	1147	1178	11	4	2023-10-25 18:11:15	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1180	\\x0de5a6ec41b8326d3c2fb16fec9450eae24d49c5cb36a8b299190c7d32d77ed4	11	11663	663	1148	1179	13	4	2023-10-25 18:11:15.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1181	\\x673cf62cd469284416e48b987cc070b54c8add5ec58ea95d9edd3df88f96712d	11	11667	667	1149	1180	5	4	2023-10-25 18:11:16.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1182	\\x0e027d31968968115dae3ce02e7fdc6f09671fb8d24ee075961dbcabcd6b5508	11	11672	672	1150	1181	3	4	2023-10-25 18:11:17.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1183	\\x12f0e0a3a96dc9a96f81c9c53c2411bd64c73b1a215b73d2a4bc73fb887df691	11	11681	681	1151	1182	5	4	2023-10-25 18:11:19.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1184	\\x4dca4a587d5ce43598ee26b467eda1d6a750a714c2c785c5c7cd4fa6ca6d93c8	11	11693	693	1152	1183	3	4	2023-10-25 18:11:21.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1185	\\xeb64a19ba804d7dac722b0f64860995d607bde9e43be6f4a17b273dbb0175e74	11	11732	732	1153	1184	13	4	2023-10-25 18:11:29.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1186	\\x223f99100f6c2c255e8a8b7c5f9f2a77e97314e48db5d473ec3ab48272ee5eb3	11	11742	742	1154	1185	5	4	2023-10-25 18:11:31.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1187	\\xc157412a4f2420fa6ac25046ee94ed905304c51a57a7a0ed0ee67848c34bdee8	11	11744	744	1155	1186	15	4	2023-10-25 18:11:31.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1188	\\x0fba778331ef76ae589b0c746efb5c6c902691f0ebe953c07350cf46f3909d24	11	11749	749	1156	1187	3	4	2023-10-25 18:11:32.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1189	\\x2b5204323631d16a7805cd1ee0c43215a884b163864a8d89c0b8ddd01b513192	11	11750	750	1157	1188	3	4	2023-10-25 18:11:33	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1190	\\xb9628f8e9b617f2ad64846bb315364731c7003ffaa666dab50f1b033c0642d21	11	11765	765	1158	1189	17	4	2023-10-25 18:11:36	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1191	\\x4f1a9b56fae2f6f6e4a37f9381cfa232596ceae831f43d6306aa71a8e9197f53	11	11768	768	1159	1190	5	4	2023-10-25 18:11:36.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1192	\\x3e7ff34ee22ea12e9ea44767f31699a2da97348b97d83261a71d8a87fc544c9b	11	11771	771	1160	1191	15	4	2023-10-25 18:11:37.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1193	\\x2d70d2bfca2bf030675d95dfffb618c43fac74d7dcc67c30022c649faed868a5	11	11814	814	1161	1192	5	4	2023-10-25 18:11:45.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1194	\\xd6ac7c03c5b22644d03a87435c0dd4b33cc49e646d3059164413277144209ee7	11	11815	815	1162	1193	5	4	2023-10-25 18:11:46	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1195	\\xe12198cb2cfb598c971225beb6f9ef245be693092f6ecf06bf30f00fc5582a0e	11	11816	816	1163	1194	6	4	2023-10-25 18:11:46.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1196	\\x0d5ad8723f4b4844a714731d261b317a3dbb78f21882eff84a288891fa8c7205	11	11821	821	1164	1195	8	4	2023-10-25 18:11:47.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1197	\\x1680506635068bbdf60d6dca7dc0973629e5cbd31baf0521d785577defc8e48b	11	11856	856	1165	1196	13	4	2023-10-25 18:11:54.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1198	\\x03d7a64bfd8243fe4e020363e287812d8f4fe8576e172ddc71bb1e296e17ff87	11	11862	862	1166	1197	15	4	2023-10-25 18:11:55.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1199	\\xde98ae62a7f8f4e354e84a8f694589d6c22e0691900499a653d9c0cc24a8a627	11	11879	879	1167	1198	13	4	2023-10-25 18:11:58.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1200	\\xa8c918ef1e15f0a7f69e9d94da3723fd20f41e81e0e137a5da671aa450b8fb63	11	11895	895	1168	1199	8	4	2023-10-25 18:12:02	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1201	\\xbce0f4898fbe2a5afe4343238b6950451d52321c0afffc918557924b838df9c3	11	11897	897	1169	1200	15	4	2023-10-25 18:12:02.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1202	\\xaa9eea7a710df9a510eba0d7f6ffd10c087c9c50a0fb40d693728378b5663e4c	11	11902	902	1170	1201	11	4	2023-10-25 18:12:03.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1203	\\x331aabd48189dca17c28d781ffcb8e9fede41074784a459ef23e2f9f4c0209c2	11	11917	917	1171	1202	3	4	2023-10-25 18:12:06.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1205	\\xada3620bb7fb8de0fca027d5089fee3ff363ba0ad01d8a18a59237384422d690	11	11943	943	1172	1203	8	4	2023-10-25 18:12:11.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1206	\\x675f0ee30900a9ca2a6ca75f9e99874179c9e799ce55fc70411a96cebd302090	11	11949	949	1173	1205	11	4	2023-10-25 18:12:12.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1207	\\x27aad0e8632920d007c7d7e4e6b81da9d456ab9142fb9d5cf1410d0b6922ee43	11	11963	963	1174	1206	9	4	2023-10-25 18:12:15.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1208	\\xc3ca593b8689a4518c0df64a4cf6d93eb1862c732f452cf807d2442c5f890198	11	11986	986	1175	1207	13	4	2023-10-25 18:12:20.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1209	\\xb30fd3db69dd41b0a55403a12dc1436864fb218a1f49dc8e1f38db6b5e9711f1	11	11987	987	1176	1208	15	4	2023-10-25 18:12:20.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1210	\\x8d3d1811202175748c7c9f394749490e7f30b939cb3af5e827e4b5d95eeb8e98	12	12000	0	1177	1209	3	4	2023-10-25 18:12:23	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1211	\\x6be5fe530f086a94be131968cfcbf66e121beb10c04e01be50e6f40bd179a49a	12	12019	19	1178	1210	15	4	2023-10-25 18:12:26.8	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1212	\\x72eccba53d97ec02dcfa1d2d29080b6eabd2e5acf01a4b08f8ee2cd76bbdfcdf	12	12022	22	1179	1211	13	4	2023-10-25 18:12:27.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1213	\\xd2bb44d51d9f5d55e37c61bc0800df2ba70cb4e4e55b249d5ce975848b50502e	12	12023	23	1180	1212	8	4	2023-10-25 18:12:27.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1214	\\xa4d415feecef0f13c90e59c2b2c10c931f47cc74c3f3b4c6449f0dcfdd79a759	12	12024	24	1181	1213	3	4	2023-10-25 18:12:27.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1215	\\x97d85969216e094103595ff9fe0e78a61fd4bf29a29918cf72423ec19470ef82	12	12033	33	1182	1214	13	4	2023-10-25 18:12:29.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1216	\\x5fd3a702ac39189f8b453b2c0859c50171b53c56b4c2c5d2f230564f95699cdd	12	12057	57	1183	1215	11	4	2023-10-25 18:12:34.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1217	\\xb8c7158946f7c5799bb17ba51feacd141a811d14d086985e4b443002a8a5c50f	12	12059	59	1184	1216	11	4	2023-10-25 18:12:34.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1218	\\x898a91b8cbabf7b3978ae81fa753828481f304af3baacbe344cde423855d78f7	12	12077	77	1185	1217	8	4	2023-10-25 18:12:38.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1219	\\x9436a08015a068e050dbfbea3f0705a26cb6429ea4a229e4b2536b88aac9f405	12	12083	83	1186	1218	5	4	2023-10-25 18:12:39.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1220	\\xbec5892b25ceffc2601649d7c8cedb295161b40d3e29e2bb198c5f6451ef1f2c	12	12085	85	1187	1219	15	4	2023-10-25 18:12:40	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1221	\\x4c2e0dfa4662f33cdb6b2c69e0feb9dcc818e40b3d4da4d83f801bfb54e0e130	12	12096	96	1188	1220	11	4	2023-10-25 18:12:42.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1222	\\x40dc13498a802776607dbef02faf9b7e01b77b2468cac1f3eda161f009bf0b1a	12	12103	103	1189	1221	3	4	2023-10-25 18:12:43.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1223	\\xf1049bbf00892f46f2c13979e163a7215e211fe9869b6fc365852857f31ae26d	12	12120	120	1190	1222	15	4	2023-10-25 18:12:47	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1224	\\xdf21155cc5b7b08d869f694dd43ca95301a6560fad51ca2cbf75fb58a835e28f	12	12134	134	1191	1223	3	4	2023-10-25 18:12:49.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1225	\\xf9f29add551d18d70a7e4c4709c26f029bc07bb76154abaae5d97b1ab696265e	12	12149	149	1192	1224	6	4	2023-10-25 18:12:52.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1226	\\xa87f3c38fc37426115c8538327182bb58c9abf14aba8fa994f665ca08781de8c	12	12158	158	1193	1225	13	4	2023-10-25 18:12:54.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1227	\\x90ef9c9145fba0ee87c2dcfe3133053b86afd64a57064ce9bca04253d1fd2e18	12	12159	159	1194	1226	8	4	2023-10-25 18:12:54.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1229	\\xdf2c6102cd36f069318377df4b58526adddbc06ce7204e3193ecfd4a4ae4c856	12	12179	179	1195	1227	6	4	2023-10-25 18:12:58.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1230	\\xce911776764ede7166425d798f3d366a71edda119146fa642e7bc81f3bae1fec	12	12180	180	1196	1229	15	4	2023-10-25 18:12:59	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1231	\\xcdc77f93935ce12b57227a358bdfb8012f874d9e76a28dff509141b637242213	12	12194	194	1197	1230	11	4	2023-10-25 18:13:01.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1232	\\x782542a169e8e04e3586ff4e8c629a96265c704eca092379149ab4555cfe642f	12	12221	221	1198	1231	11	4	2023-10-25 18:13:07.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1233	\\x410fa3e3aa5ec3b055749d411b1415aa9a0ec3076c0cdfc7062c2b5bf7477d91	12	12231	231	1199	1232	5	4	2023-10-25 18:13:09.2	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1234	\\xa768818f24128f65ba827c34f5cd32414d01be82164e8278b68f35b02d8b1111	12	12249	249	1200	1233	11	4	2023-10-25 18:13:12.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1235	\\x629ca61e0e1fb437d0d626257a192f00fdcb8e4f6f5787ec0bc4fbef5f47f4c1	12	12250	250	1201	1234	17	4	2023-10-25 18:13:13	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1236	\\xe405f895f9b12c13d7474eb1f5d2cb19b20b0dd600d331b99ce9095ca84f8427	12	12265	265	1202	1235	9	4	2023-10-25 18:13:16	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1237	\\x896da0f64525a9c2071756c88bad953f193ade31309b541f8b953d786215df3a	12	12274	274	1203	1236	9	4	2023-10-25 18:13:17.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1238	\\xcafad6ecb015770b254126b9e16eff780f711e1f86f4dd3424974c25844b587b	12	12292	292	1204	1237	15	4	2023-10-25 18:13:21.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1239	\\xf837065551af5c2565cf989029e02236cec019df96d8d4fe3127dd88a29eba6b	12	12299	299	1205	1238	9	4	2023-10-25 18:13:22.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1240	\\x8620fe1daeed857bccc720709bea3789835ebbe4663ff1eeff3ad21142c3b0ac	12	12306	306	1206	1239	9	4	2023-10-25 18:13:24.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1241	\\x4327cbc037d30f692f586f05652dfb6b6c8e5e5bb7e5ffa54952bd7451da4235	12	12318	318	1207	1240	6	4	2023-10-25 18:13:26.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1242	\\xd69946faaebb6a6cc982b314c8d2696b624255bdcc57a5bad11259e4964c81f5	12	12324	324	1208	1241	13	4	2023-10-25 18:13:27.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1243	\\x34700208463bc18e8e2d7e32dcd83c24c1817d216011bf9ae8be46affc333b4d	12	12336	336	1209	1242	15	4	2023-10-25 18:13:30.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1244	\\x836c2ea57a4ec366342f9083494e49f0488baab5a59a0fb6822c2a1aa32bf43f	12	12372	372	1210	1243	9	4	2023-10-25 18:13:37.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1245	\\x0cc0c7a0496f6575c0d9a646638128833d39dd08ae61d83cb14ab9e4206c9333	12	12392	392	1211	1244	9	4	2023-10-25 18:13:41.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1246	\\x8a919b8b926dbee6acb9980b26fa3e665231d552220ab5b3c4ed1b19d58a1a20	12	12412	412	1212	1245	6	4	2023-10-25 18:13:45.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1247	\\xc1902004a5f035c8a749440bb195cb6eb5b9818cfcc3819883041d1b820318aa	12	12424	424	1213	1246	17	4	2023-10-25 18:13:47.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1248	\\xb37f1864f5ed65505aafbada80931651d9e95b13767501083ca694aeb33ae6f4	12	12426	426	1214	1247	15	4	2023-10-25 18:13:48.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1249	\\x159c5b0cf273eb848150075d58760e9c7871168827913a413c1220449cd978f2	12	12431	431	1215	1248	9	4	2023-10-25 18:13:49.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1250	\\x3130a20fce12ba73b3a5f37ca5fb052eb24c2c667a5b90670cfddcd0b0a1dd7f	12	12436	436	1216	1249	15	4	2023-10-25 18:13:50.2	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1251	\\xed4de13cdbf21ab40779deae8ca2cea6ca1986f7278a7caf0fbd1e929bdb3f0f	12	12439	439	1217	1250	11	4	2023-10-25 18:13:50.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1252	\\x147204ed54e53253b70d5a9d8aede39df5a0d93690c888a7ff8678ae332df22b	12	12457	457	1218	1251	9	4	2023-10-25 18:13:54.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1253	\\x3b58e01cec3ed96a1190f8db2795dd6a0564d2202c56b9b0074ecc009d63110e	12	12466	466	1219	1252	13	4	2023-10-25 18:13:56.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1254	\\xa75cdafa8af573dc7bc582fe840067fa33751b2469e51ec160aaa28913c1daa2	12	12467	467	1220	1253	9	4	2023-10-25 18:13:56.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1255	\\x9ffc21bf76942a6a04ebd6e8e3d72e60520421a26db887845cc96f76fc09a2de	12	12496	496	1221	1254	17	4	2023-10-25 18:14:02.2	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1256	\\x63f5b7d0290b7681556fdb7b393e658aa6b7a9510a3c862d6ba2e359e71afbf1	12	12508	508	1222	1255	17	4	2023-10-25 18:14:04.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1257	\\xd695d1689246f9ef1fbfa99d3ab2e31f3c5d898ee92d73acf5b7a0d3f3f8cf01	12	12530	530	1223	1256	13	4	2023-10-25 18:14:09	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1258	\\x4624849b13d5dc0786cc284fb9997e7a3cd4b7cf2297f5d04baf2f37b670d390	12	12540	540	1224	1257	8	4	2023-10-25 18:14:11	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1259	\\x97de2a1638945c2f2606adf5fe8da344623c8dc6cb819c8f80d6578a44dd8805	12	12546	546	1225	1258	13	4	2023-10-25 18:14:12.2	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1260	\\xf370afbcd872a06f0a8ed202d5629561a6f3909f3148f14c14634edcaf915411	12	12557	557	1226	1259	9	4	2023-10-25 18:14:14.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1261	\\x43ed4b1d4784d1fec00ab2c56e54145aedc1c77c2fe21b8ed697f0a5e852b097	12	12589	589	1227	1260	11	4	2023-10-25 18:14:20.8	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1262	\\x1829392d6f8a6edd929b3e126c944877d1834e36bbf52b8078bf15c0887e0342	12	12602	602	1228	1261	15	4	2023-10-25 18:14:23.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1263	\\x5fd200b390e7c611afe0f06d4d350135b78f91b3a004661f2bd8da373989f4da	12	12614	614	1229	1262	13	4	2023-10-25 18:14:25.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1264	\\x8073b583478113525dda80e29ac69f91793b21f770ec4620074574ed986fa8d2	12	12620	620	1230	1263	8	4	2023-10-25 18:14:27	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1265	\\xeba952883b3de485c570686f363fc7fcc568592ff5516e17d115f2a2bb4661e9	12	12622	622	1231	1264	5	4	2023-10-25 18:14:27.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1266	\\xe1c4627a6fa3f867c1de4e85c986424662c9f6311ebe5b36ab785b9a3af50d36	12	12637	637	1232	1265	6	4	2023-10-25 18:14:30.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1267	\\xa62c99af34820cf35bfc4419535040aa7567310ef83cd5f58d1c2b807f329f09	12	12642	642	1233	1266	5	4	2023-10-25 18:14:31.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1268	\\xa4e61b9c5ea0c10e9ee651bcca9d957d6d9d52d7910f6645fa97e51a1b9d53e6	12	12645	645	1234	1267	9	4	2023-10-25 18:14:32	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1269	\\x2c12c75a933d718b05c172f73aefe9d688043d1120cf5c3a5aa482dcca971136	12	12660	660	1235	1268	3	4	2023-10-25 18:14:35	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1270	\\xb62772749804cad19432ea1ae8e51a68274128b24f3548fdf9b811b5854ade0d	12	12665	665	1236	1269	11	4	2023-10-25 18:14:36	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1271	\\x96b22bd4f95539663f225014520c3bb91e5d662e5062623a0c487a832c35a5ec	12	12677	677	1237	1270	9	4	2023-10-25 18:14:38.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1272	\\x0b5892f5716f05a4d9e790d26e0c99d9af3c95985af983c324fe02d580aeb666	12	12686	686	1238	1271	3	4	2023-10-25 18:14:40.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1273	\\x7d3b7786630ea0b41985e13c024214a0b827017ff34299e5c778eb85c7edda7a	12	12690	690	1239	1272	13	4	2023-10-25 18:14:41	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1274	\\xae3f1d2ab45a53cc26f12fecf31c526e0012c92775b5efef7eaa9e742bc81c35	12	12700	700	1240	1273	13	4	2023-10-25 18:14:43	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1275	\\xd42df1a0b2951150971afc753bb039e9c61fd13588cd763b3e231dfa064fed87	12	12702	702	1241	1274	13	4	2023-10-25 18:14:43.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1276	\\xb5ceb2feefcaebcef273e01ed816a3c0ff4c672270b9a5b9954c05f209b6fd52	12	12707	707	1242	1275	6	4	2023-10-25 18:14:44.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1277	\\x66acf3c7faefa40345724641ad03ffe3ef3027d2a9eedf7e93d58863c24f7c5a	12	12710	710	1243	1276	8	4	2023-10-25 18:14:45	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1278	\\x13793ba3be94649859237c0a14e9fa42e10dd4eaa63dafc54e9b63fc3e5740fe	12	12712	712	1244	1277	3	4	2023-10-25 18:14:45.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1279	\\x4640c57dae38c49c1c318b86ca82d7c606ea549adc30bf518ab0bfd46029ca06	12	12715	715	1245	1278	8	4	2023-10-25 18:14:46	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1280	\\xbf61c884ffd5ed9737d8d48c0ad944b6f299a546aba6899390c30eb788b09a4a	12	12721	721	1246	1279	9	4	2023-10-25 18:14:47.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1281	\\x2e40b87785231d3ab154ebe104d5ea500722eeda3bd23f66fce79e69884beb92	12	12734	734	1247	1280	5	4	2023-10-25 18:14:49.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1282	\\x3f39de4a8515a402b7b8375815ac56d4ba4b79b1e03bf555590c9c9b5ebe59fe	12	12749	749	1248	1281	9	4	2023-10-25 18:14:52.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1283	\\x9f5baa9135c416b2f7e997410c548a34dc8331c90430163da212bc1c1b9e9e42	12	12752	752	1249	1282	17	4	2023-10-25 18:14:53.4	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1284	\\x04cb6a215a008e906ed03045f86e92c3540b1db38a24385e1f7e1f96d469c8ae	12	12762	762	1250	1283	9	4	2023-10-25 18:14:55.4	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1285	\\x8684deb2237ceb141a0e1e344c872eefd506a7ecd66ba8f29f5c3ad9758e7215	12	12775	775	1251	1284	3	4	2023-10-25 18:14:58	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1286	\\x6b3efbbcdcda89c756f1f0ee46c8505d91f4e4b8672d82f44cc13a5ecebb3e46	12	12780	780	1252	1285	5	4	2023-10-25 18:14:59	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1287	\\x6754a1fd1bbb4354e3cd8231cda48ad5ab703a76f6f12aedf68d938895f21b4d	12	12803	803	1253	1286	6	4	2023-10-25 18:15:03.6	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1288	\\x348dd9f89c724b41c65fab7ed6b96989ec2ade04342465009581454cd7c2a330	12	12813	813	1254	1287	11	4	2023-10-25 18:15:05.6	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1289	\\x4e745339a1fe8201cd817296369bbae757d749692df5708c06977b91054eb9b0	12	12823	823	1255	1288	13	4	2023-10-25 18:15:07.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1290	\\x57cf16a78d5a785f64a77a77eebb92757cc84ee5c0b942af2bfda23751cde796	12	12824	824	1256	1289	5	4	2023-10-25 18:15:07.8	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1291	\\x2a9f659d872e4279b1147ea962dc813d212f45521fe9b83162f7ac18438a3262	12	12846	846	1257	1290	6	4	2023-10-25 18:15:12.2	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1292	\\xda816ebf08dcfe11311de841dfe7cfdc13cf681916875c1dbda122b1e0833df9	12	12852	852	1258	1291	8	4	2023-10-25 18:15:13.4	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1293	\\x2db703c6920b958670df1f0a7ed013c81c2bc5563a0cf1bd733ee0bce5ef45a7	12	12853	853	1259	1292	9	4	2023-10-25 18:15:13.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1294	\\x39d609cf3666ce15888f4f4d107b5afed3a661c975a87910cab76b3f380cc956	12	12861	861	1260	1293	17	4	2023-10-25 18:15:15.2	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1295	\\xdc3208f4a134f7a86b19872e1c937d86dc32474a314562615463917b8aca0796	12	12878	878	1261	1294	5	4	2023-10-25 18:15:18.6	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1296	\\xc87671de786e12be5a4a3d9ab568f39e7869c6557d36a838ca377e3249d8e7a2	12	12894	894	1262	1295	13	4	2023-10-25 18:15:21.8	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1297	\\xb6cac36a77a13684f4d3492dcb495f5b810a3a5d563a8b5a694f2a617996f393	12	12904	904	1263	1296	17	4	2023-10-25 18:15:23.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1298	\\x0e8657ad6636e4b8a6bebec0663a46a62937119dc26e2dab53403e54ecac7d63	12	12915	915	1264	1297	8	4	2023-10-25 18:15:26	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1299	\\xdd4167a6b68a2014b360dd517a36dedb8a74d442460e42a5b0feff3c87ecef4c	12	12928	928	1265	1298	9	4	2023-10-25 18:15:28.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1300	\\xe4117ee9cd75ef20e126e47c5086c03afb36b8b3b9e451e658b170ded8a3fed1	12	12930	930	1266	1299	5	4	2023-10-25 18:15:29	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1301	\\xaa699541aff72860e1a9c6dbd03ef3cc64e8e3fd8197ccaa2c61e0c3924d84a2	12	12931	931	1267	1300	9	4	2023-10-25 18:15:29.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1302	\\x6d21cb236a38eabde5383435daa5c60f1dc9dd7c87e591aec902348bdade08f5	12	12932	932	1268	1301	6	4	2023-10-25 18:15:29.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1303	\\x66b35e3332f3a283975a6f44c972f8f89427d4fb02330b2bfd9f164cb7238ac2	12	12943	943	1269	1302	13	4	2023-10-25 18:15:31.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1304	\\x831d07dfd8323ee50a61f5c3de7efca72d6fffc378444c16c09ac29a5975817c	12	12958	958	1270	1303	3	4	2023-10-25 18:15:34.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1305	\\xc903a71260464f6d4fe975b8af7e0d55ff6188353801aef4eb12fa24cfbbb1fc	12	12962	962	1271	1304	6	4	2023-10-25 18:15:35.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1306	\\xaaef86d74b641536cc933a6dffb70c8f6890ad4aaa219b0c11794d3423446def	12	12963	963	1272	1305	17	4	2023-10-25 18:15:35.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1307	\\xf8ebf85f0492652651992364bba4a1fd797cbd551661424a35d3077134fc6c5c	12	12966	966	1273	1306	8	4	2023-10-25 18:15:36.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1308	\\x7bab1f8b5ee00a62c9e6c61111fbcff8666189a265632711cfa8338c7ecbc380	12	12971	971	1274	1307	11	4	2023-10-25 18:15:37.2	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1309	\\xfa549c6d4cfa207a69e309696119d1f943726944fc14350d1817291fb4ef67b3	12	12985	985	1275	1308	15	4	2023-10-25 18:15:40	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1310	\\xbdee4472c9b34ecd190730f7d9dca12f7ac53f2332bdd6d6d6e291573b45b91c	12	12988	988	1276	1309	8	4	2023-10-25 18:15:40.6	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1311	\\x3a7ed778d9540288a5df0220d5545c0aabcdaa741044cada8008915ba8c718f3	12	12995	995	1277	1310	3	4	2023-10-25 18:15:42	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1312	\\x9d4ba682ab3bb939bf461b2ea41478b3e4291d00536292692c707fa7fffa0da9	12	12997	997	1278	1311	5	4	2023-10-25 18:15:42.4	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1313	\\x7b106cabb0cd6bd0b63d60b7242ff5bad061e7c8922258f30101180c8b04469c	13	13010	10	1279	1312	8	4	2023-10-25 18:15:45	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1314	\\xf68494ca058a99825eb2d305774a43e7bba70912c65db2046156c5d141eba005	13	13017	17	1280	1313	15	577	2023-10-25 18:15:46.4	1	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1315	\\xb6b38264897273aafe275f25b22275b32d0c86302c9c15e78159355a00616a26	13	13021	21	1281	1314	9	4	2023-10-25 18:15:47.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1316	\\x798ee18fa327226c134c3f26105e185dd6fa3e5fe3d1eff159f0c6b06927b263	13	13023	23	1282	1315	3	4	2023-10-25 18:15:47.6	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1317	\\x2fa3b0375f06c97a547b5be42a94934b233652b0018fcb844381f601018f03d6	13	13030	30	1283	1316	17	4	2023-10-25 18:15:49	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1318	\\x57fb05aa4b1ae29014be18f2e33e55037a193f28d1c86406e1234db24c7f31c1	13	13041	41	1284	1317	9	4	2023-10-25 18:15:51.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1319	\\x6bd7a3065b7c1b12514c0f8f8e576e7ae74e7bf26983e17a66d9db5f161dda5e	13	13042	42	1285	1318	15	4	2023-10-25 18:15:51.4	0	8	0	vrf_vk16y86940hmqmqupckrlfl6kpryscgd4n9f6dr3s80gtdkdhr08j0sfpvng7	\\xd0a470ad0bec2fd26250ae37c0631bc8cb575af4b13dd85d145e75c28a2ab918	0
1320	\\x76bc5d2276caf252d76b8c81dd9075077cfec14d76f50efb04c5decc2045f549	13	13050	50	1286	1319	3	1740	2023-10-25 18:15:53	1	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1321	\\xdf3beec0315f1a6e25a79450096977236d50fdaeb0c98ee3c4a99862ab6a1cbd	13	13055	55	1287	1320	6	4	2023-10-25 18:15:54	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1322	\\x329808a9e32e5bfb275fd54247ca90cb5d64c97c86b933a4e2230e0ae17191cb	13	13064	64	1288	1321	17	4	2023-10-25 18:15:55.8	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1323	\\x2d8bf3924b1dc25c1df2a3f63e2c5cf093690a2f845009e37492479bba049363	13	13076	76	1289	1322	3	4	2023-10-25 18:15:58.2	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1324	\\x67de36c0510016dbd20dd2ba386c38d857d278929a91d416caac1d608fbff84b	13	13078	78	1290	1323	9	4	2023-10-25 18:15:58.6	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1325	\\xe77331480a850be8825242e2090f3abb7c4d88a6dd6ff56253ed689dcfc590c9	13	13080	80	1291	1324	13	4	2023-10-25 18:15:59	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1326	\\x8371dcd6ba1428496a26cb4c41f3877f6f1619f636e229ae3229ef3692d17ebf	13	13102	102	1292	1325	11	4	2023-10-25 18:16:03.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1327	\\xa432e97eb64615b449d78792488ee92b3c3015da8d9119156312c7aeb1ff0d2f	13	13111	111	1293	1326	8	4	2023-10-25 18:16:05.2	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1328	\\xf1960f2edba7bc5ad1b1f741582509bcc702e5907289444dd9c7bd9cfbeabc84	13	13122	122	1294	1327	6	554	2023-10-25 18:16:07.4	1	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1329	\\xb045ff7279bd9317069afb8d59b6268e79e6cc9ad428e27c0c4c5fb6e84e3308	13	13126	126	1295	1328	9	4	2023-10-25 18:16:08.2	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1330	\\x31b9d716586f55c91412f8d78e66f3c3eb4edf27c9325749ad96c42e881d43b3	13	13129	129	1296	1329	8	4	2023-10-25 18:16:08.8	0	8	0	vrf_vk1lgdzulll2wsz64ug5dc22sgc3sq58e0t32xnhhnpwmptz38pxuaqen0env	\\x5a7d8ccf65bb267547c782facb72bfde89c08c896d015c35fc4fe8aeeafd19f3	0
1331	\\xffe1be28438aafd0908bcc316c19d3429dad0cfa78d32570463c01357d184c8d	13	13132	132	1297	1330	11	4	2023-10-25 18:16:09.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1332	\\x5960aa0bcf03cb45082a61cf8ef05e52e6cd9c0847e1322ee814300ce28de157	13	13135	135	1298	1331	5	365	2023-10-25 18:16:10	1	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1333	\\x3a476df3e0ad049b28bc94b7523bf672b119b4374e3486df2ccff53d85aa6a0f	13	13143	143	1299	1332	13	4	2023-10-25 18:16:11.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1334	\\x781d6523e6892c4ad79ff05fc82dc8846e821b8051364b1a54476c6a85925b14	13	13151	151	1300	1333	17	4	2023-10-25 18:16:13.2	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1335	\\xcfe26a66b7c2f93085ba31c274af222e603c7485375b0d21ecd2d46836994064	13	13157	157	1301	1334	13	4	2023-10-25 18:16:14.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1336	\\xee501179812c61e898f3f5bb9652c981d6c2709ede0e644fe03abc27c7ae425c	13	13169	169	1302	1335	13	496	2023-10-25 18:16:16.8	1	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1337	\\x83f0b2164b589d216d9106cdfc2a229214502c94352a62f86eb084d287e3b623	13	13190	190	1303	1336	6	4	2023-10-25 18:16:21	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1338	\\xd3ab43acf6ce702660671415d33dcd3ab38760316dbd92c00b740e52ed730490	13	13192	192	1304	1337	3	4	2023-10-25 18:16:21.4	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1340	\\x868fbbf719a24caa27ac0ae89b9fbd0e333d62200ec795d33b9ce882c6c21cad	13	13193	193	1305	1338	13	4	2023-10-25 18:16:21.6	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1341	\\x33e027bc527bb5c2edd45ae60e25fc1b1736948d401600f4670a0521f422f902	13	13202	202	1306	1340	11	550	2023-10-25 18:16:23.4	1	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1342	\\xc3f0af83e560affcbbbf865335033873325aaaa0d31308f0279f7978f6932653	13	13209	209	1307	1341	6	4	2023-10-25 18:16:24.8	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1343	\\x324812d8c63430ee6e164048eae54e87bdb3939e9e677115b3016aa42b01751e	13	13217	217	1308	1342	6	4	2023-10-25 18:16:26.4	0	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1344	\\xd96a9127d019744264e71c39cf17af755ea35012019cc1c22034fb21ca716ba8	13	13227	227	1309	1343	13	4	2023-10-25 18:16:28.4	0	8	0	vrf_vk18ae8yagcu89lrkdzcdgre20dwm9h7tvw7davmkp6ucpf68x2jtlqwlptfh	\\xed9360f82b7edbee3ab512890283ecedeb5bb2accff5ce8547635925a8683876	0
1345	\\xbda50e5795f8026a4ad74176a9d6a557ec713c04dd713ca63923a7dfe3599522	13	13242	242	1310	1344	6	410	2023-10-25 18:16:31.4	1	8	0	vrf_vk1rd6mxfwjn0dgv676wycxm2fsywc7er7wxqtqamadjkd79lj9y99qh2c2zk	\\xc752d20d6f89a725db126a07f6ac1055bb91fff33ae2352ddfbfdd89da91ac8c	0
1346	\\xdc3f5e5c8e1560be050374d6d61983464167fa34c3392ea8b17f66885d137e91	13	13245	245	1311	1345	9	4	2023-10-25 18:16:32	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
1347	\\x9f2beac807ac50cae77c25e6653d2247dc846741872453921ec8f33699422171	13	13247	247	1312	1346	11	4	2023-10-25 18:16:32.4	0	8	0	vrf_vk1e8d0vgcktqy0pywkyc2498p2h57lh5za34he6m8ttapmyhrpugkqwqh6sl	\\x3c6a16c654bc3e5f580a5253d223f07447bb907ea4a919d5ce39262b05351641	0
1348	\\x69fddccea36dd60d5a8e74795145703bea8e1f4de997396e9fce3550ae9c8db5	13	13249	249	1313	1347	3	4	2023-10-25 18:16:32.8	0	8	0	vrf_vk1d30jv780kknfrhsyht4j3lznss3mceatxnrltkus3ussr5macyvqx0s6mj	\\x2aa4e058fdf5ffcbc1137233ec2a35f4d484e4b103d90644c5b4b095ef261df8	0
1349	\\xebc02a1558c61322a1ff47e6df5086df7ca944b89c43febac4c8281d3116e7ac	13	13264	264	1314	1348	5	528	2023-10-25 18:16:35.8	1	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1350	\\x3f429bbf988734de6fe73567f0ae728b806b620752f730a7d1b7d34e42dfb633	13	13273	273	1315	1349	17	4	2023-10-25 18:16:37.6	0	8	0	vrf_vk1jjsupwxpx6lyeqtrz7e8eeea98r77luzpyzm4c7g0wnj6tpxglxsh5ctea	\\x65e7a552f9c67328ac116755043f72ba72b90386be2270e5928e84768ef2395e	0
1351	\\xd749bba36b6cfdbe8fd41d410db80687bdaee4b47ce8110242d030aead19e6ed	13	13275	275	1316	1350	5	4	2023-10-25 18:16:38	0	8	0	vrf_vk1x40vt4wqgys2qe0xjvt6narvdm4pwag4mwu700wdcmdy5etgwjjq2k5lae	\\x4206d809b9282339584c7e360c4bf9fb777920a6b7afe52501e8ebd5022a7090	0
1352	\\x170b1a66a5650902d7ac43a87366026ceee39fcb638b87fb70f80153af15f865	13	13284	284	1317	1351	9	4	2023-10-25 18:16:39.8	0	8	0	vrf_vk1sez939h35v3txkvddm78ar09mxnl6ral2c6dxzttd2q477j2h4fq26jg8f	\\xcbaa1993b257d3d1d15a1fb901bdcbde395e808ba4f56b1572dad77abf476e2e	0
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
1	99	1	addr_test1vrszxe5yja4a60qfhkjw72rk3ea2fflam8cyfg6y9x7hqnsdgml7e	\\x60e0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	f	\\xe0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	\N	3681818081394197	\N	fromList []	\N	\N
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
5	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	113	{"fields": [{"map": [{"k": {"bytes": "6e616d65"}, "v": {"bytes": "24706861726d65727332"}}, {"k": {"bytes": "696d616765"}, "v": {"bytes": "697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974"}}, {"k": {"bytes": "6d6564696154797065"}, "v": {"bytes": "696d6167652f6a706567"}}, {"k": {"bytes": "6f67"}, "v": {"int": 0}}, {"k": {"bytes": "6f675f6e756d626572"}, "v": {"int": 0}}, {"k": {"bytes": "726172697479"}, "v": {"bytes": "6261736963"}}, {"k": {"bytes": "6c656e677468"}, "v": {"int": 9}}, {"k": {"bytes": "63686172616374657273"}, "v": {"bytes": "6c6574746572732c6e756d62657273"}}, {"k": {"bytes": "6e756d657269635f6d6f64696669657273"}, "v": {"bytes": ""}}, {"k": {"bytes": "76657273696f6e"}, "v": {"int": 1}}]}, {"int": 1}, {"map": [{"k": {"bytes": "62675f696d616765"}, "v": {"bytes": "697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f"}}, {"k": {"bytes": "7066705f696d616765"}, "v": {"bytes": "697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b524244"}}, {"k": {"bytes": "706f7274616c"}, "v": {"bytes": ""}}, {"k": {"bytes": "64657369676e6572"}, "v": {"bytes": "697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b"}}, {"k": {"bytes": "736f6369616c73"}, "v": {"bytes": ""}}, {"k": {"bytes": "76656e646f72"}, "v": {"bytes": ""}}, {"k": {"bytes": "64656661756c74"}, "v": {"int": 0}}, {"k": {"bytes": "7374616e646172645f696d616765"}, "v": {"bytes": "697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879"}}, {"k": {"bytes": "6c6173745f7570646174655f61646472657373"}, "v": {"bytes": "01e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d"}}, {"k": {"bytes": "76616c6964617465645f6279"}, "v": {"bytes": "4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1"}}, {"k": {"bytes": "696d6167655f68617368"}, "v": {"bytes": "bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de"}}, {"k": {"bytes": "7374616e646172645f696d6167655f68617368"}, "v": {"bytes": "b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c980"}}, {"k": {"bytes": "7376675f76657273696f6e"}, "v": {"bytes": "312e31352e30"}}, {"k": {"bytes": "6167726565645f7465726d73"}, "v": {"bytes": ""}}, {"k": {"bytes": "6d6967726174655f7369675f7265717569726564"}, "v": {"int": 0}}, {"k": {"bytes": "6e736677"}, "v": {"int": 0}}, {"k": {"bytes": "747269616c"}, "v": {"int": 0}}, {"k": {"bytes": "7066705f6173736574"}, "v": {"bytes": "e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e044503036383136"}}, {"k": {"bytes": "62675f6173736574"}, "v": {"bytes": "9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65"}}]}], "constructor": 0}	\\xd8799faa446e616d654a24706861726d6572733245696d6167655838697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e677468094a636861726163746572734f6c6574746572732c6e756d62657273516e756d657269635f6d6f64696669657273404776657273696f6e0101b34862675f696d6167655835697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f497066705f696d6167655835697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b52424446706f7274616c404864657369676e65725838697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b47736f6369616c73404676656e646f72404764656661756c74004e7374616e646172645f696d6167655838697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879536c6173745f7570646174655f61646472657373583901e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d4c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f686173685820bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de537374616e646172645f696d6167655f686173685820b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c9804b7376675f76657273696f6e46312e31352e304c6167726565645f7465726d7340546d6967726174655f7369675f726571756972656400446e7366770045747269616c00497066705f61737365745823e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e0445030363831364862675f6173736574582c9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65ff
\.


--
-- Data for Name: delegation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delegation (id, addr_id, cert_index, pool_hash_id, active_epoch_no, tx_id, slot_no, redeemer_id) FROM stdin;
1	9	1	9	2	34	0	\N
2	6	3	8	2	34	0	\N
3	1	5	7	2	34	0	\N
4	11	7	3	2	34	0	\N
5	4	9	10	2	34	0	\N
6	7	11	4	2	34	0	\N
7	8	13	11	2	34	0	\N
8	3	15	6	2	34	0	\N
9	2	17	1	2	34	0	\N
10	5	19	2	2	34	0	\N
11	10	21	5	2	34	0	\N
12	15	0	4	2	37	81	\N
13	7	0	4	2	38	95	\N
14	20	0	9	2	42	155	\N
15	9	0	9	2	43	183	\N
16	19	0	8	2	47	247	\N
17	6	0	8	2	48	267	\N
18	22	0	11	2	52	321	\N
19	8	0	11	2	53	346	\N
20	18	0	7	2	57	431	\N
21	1	0	7	2	58	438	\N
22	12	0	1	2	62	520	\N
23	2	0	1	2	63	530	\N
24	14	0	3	2	67	612	\N
25	11	0	3	2	68	625	\N
26	16	0	5	2	72	711	\N
27	10	0	5	2	73	719	\N
28	10	0	5	2	75	744	\N
29	17	0	6	2	79	797	\N
30	3	0	6	2	80	814	\N
31	3	0	6	2	82	844	\N
32	13	0	2	2	86	926	\N
33	5	0	2	2	87	958	\N
34	5	0	2	2	89	988	\N
35	21	0	10	3	93	1041	\N
36	4	0	10	3	94	1056	\N
37	4	0	10	3	96	1085	\N
38	46	1	3	6	111	4208	\N
39	52	1	3	7	133	5130	\N
40	53	3	7	7	133	5130	\N
41	54	5	11	7	133	5130	\N
42	55	7	4	7	133	5130	\N
43	56	9	8	7	133	5130	\N
44	52	0	3	7	135	5261	\N
45	53	1	3	7	135	5261	\N
46	54	2	3	7	135	5261	\N
47	55	3	3	7	135	5261	\N
48	56	4	3	7	135	5261	\N
49	46	1	3	7	151	5815	\N
50	64	1	7	11	253	9065	\N
51	48	0	12	15	358	13169	\N
52	45	0	13	15	361	13264	\N
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
1	202499921800536060	9890155	55	107	0	2023-10-25 17:32:26.2	2023-10-25 17:35:41.6
2	66282696216737702	3986376	21	103	1	2023-10-25 17:35:43.8	2023-10-25 17:39:01
10	5010684950730	425954	2	93	9	2023-10-25 18:02:27.6	2023-10-25 18:05:39
7	0	0	0	103	6	2023-10-25 17:52:24.2	2023-10-25 17:55:36.6
4	0	0	0	104	3	2023-10-25 17:42:26.6	2023-10-25 17:45:40.8
13	0	0	0	101	12	2023-10-25 18:12:23	2023-10-25 18:15:42
6	44060716770800	9348931	20	86	5	2023-10-25 17:49:03.6	2023-10-25 17:52:21.4
12	21958491928975	16933560	100	90	11	2023-10-25 18:09:03.8	2023-10-25 18:12:20.2
9	0	0	0	92	8	2023-10-25 17:59:05	2023-10-25 18:02:21.2
3	0	0	0	101	2	2023-10-25 17:39:03	2023-10-25 17:42:21
8	114975022287682	16960004	100	90	7	2023-10-25 17:55:45.6	2023-10-25 17:58:59.6
5	74999293926011	3708880	20	99	4	2023-10-25 17:45:44.4	2023-10-25 17:48:58.6
11	0	0	0	99	10	2023-10-25 18:05:43.6	2023-10-25 18:08:58.6
14	20369238931786	1478140	8	38	13	2023-10-25 18:15:45	2023-10-25 18:16:38
\.


--
-- Data for Name: epoch_param; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_param (id, epoch_no, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, nonce, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, block_id, extra_entropy, coins_per_utxo_size) FROM stdin;
1	1	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x612842f0bdac952de46d262bf42f1640c086d6ba8b859efc075354ad4ea24227	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	110	\N	4310
2	2	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x23b17befb6de3287fb8c7b404f7e4492a76dfa12f3649acd1950db26a2559e98	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	213	\N	4310
3	3	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xbb3c8fe1f8bccd42eaaaaa31fe5d22fbb385e2c2e39534ae9ade22498a955a6f	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	315	\N	4310
4	4	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xf96acaa27a994e5324f44738afc423c37cf15049845dcc82c17bf2303234b215	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	425	\N	4310
5	5	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xff4d98c498f9aeba564ac174e24a2842d6bd0b96bdd98a4a26c208a3f1c83576	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	528	\N	4310
6	6	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x1e22b65a9e16e6f4cc4340ac8d299b6ea07f9a0b39ed7695488f701b43f91a6f	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	615	\N	4310
7	7	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xb5e01121c27c66371424a3c26d59b45ff41e8beb079d1c454b561e60886156a7	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	722	\N	4310
8	8	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x2bc5a16a725a9660b745e95ad5f2ae2d5c3b072d6d71e4383e91f64664ad1a18	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	816	\N	4310
9	9	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xea06873fad2050a00c37761adc7d93c00e68aef1b2804976e9d8eef815356436	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	912	\N	4310
10	10	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x58610c645422c87d95da76f1d4cc7dbdb3cf7530c56a143659dacb40791043f1	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1010	\N	4310
11	11	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x970d519c4a8c5637106c3f211c02d80af8356b1d0653662d792ce68861f10fbb	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1114	\N	4310
12	12	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x1b4a8d49e052d0c4f10d26ba1eb2172d893d07cf255103a55a5a4a1652cf74ae	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1210	\N	4310
13	13	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x7245b49849310a0f60495dde1a53737f3a9c16e7e74b08b331b27c67972c183a	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	1313	\N	4310
\.


--
-- Data for Name: epoch_stake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_stake (id, addr_id, pool_id, amount, epoch_no) FROM stdin;
1	9	9	3681818181818181	1
2	6	8	3681818181818181	1
3	1	7	3681818181818181	1
4	11	3	3681818181818181	1
5	4	10	3681818181818190	1
6	7	4	3681818181818181	1
7	8	11	3681818181818181	1
8	3	6	3681818181818181	1
9	2	1	3681818181818181	1
10	5	2	3681818181818181	1
11	10	5	3681818181818181	1
12	9	9	3681818181446391	2
13	6	8	3681818181443619	2
14	22	11	500000000	2
15	18	7	500000000	2
16	1	7	3681818181443619	2
17	11	3	3681818181443619	2
18	15	4	500000000	2
19	12	1	500000000	2
20	4	10	3681818181818190	2
21	20	9	600000000	2
22	7	4	3681818181443619	2
23	8	11	3681818181443619	2
24	3	6	3681818181265842	2
25	2	1	3681818181443619	2
26	13	2	500000000	2
27	19	8	200000000	2
28	5	2	3681818181263026	2
29	10	5	3681818181265842	2
30	16	5	300000000	2
31	14	3	500000000	2
32	17	6	300000000	2
33	9	9	3681818181446391	3
34	6	8	3681818181443619	3
35	22	11	500000000	3
36	21	10	500000000	3
37	18	7	500000000	3
38	1	7	3681818181443619	3
39	11	3	3681818181443619	3
40	15	4	500000000	3
41	12	1	500000000	3
42	4	10	3681818181263035	3
43	20	9	600000000	3
44	7	4	3681818181443619	3
45	8	11	3681818181443619	3
46	3	6	3681818181265842	3
47	2	1	3681818181443619	3
48	13	2	500000000	3
49	19	8	200000000	3
50	5	2	3681818181263026	3
51	10	5	3681818181265842	3
52	16	5	300000000	3
53	14	3	500000000	3
54	17	6	300000000	3
55	9	9	3692094946760186	4
56	6	8	3686956564100516	4
57	22	11	500000000	4
58	21	10	500000000	4
59	18	7	500000000	4
60	1	7	3690382152538448	4
61	11	3	3691238549647931	4
62	15	4	500000000	4
63	12	1	500000000	4
64	4	10	3684387372591483	4
65	20	9	600000000	4
66	7	4	3687812961209999	4
67	8	11	3694664138085863	4
68	3	6	3689525755251188	4
69	2	1	3691238549647931	4
70	13	2	500000000	4
71	19	8	200000000	4
72	5	2	3691238549467338	4
73	10	5	3688669358141705	4
74	16	5	300000000	4
75	14	3	500000000	4
76	17	6	300000000	4
77	9	9	3699723199052617	5
78	6	8	3693737234278234	5
79	22	11	501381247	5
80	21	10	500000000	5
81	18	7	501151039	5
82	1	7	3698857988879349	5
83	11	3	3700561969622922	5
84	15	4	500805727	5
85	12	1	501035935	5
86	4	10	3692015627369389	5
87	20	9	601243122	5
88	7	4	3693746046648629	5
89	8	11	3704835141694944	5
90	3	6	3695458841334687	5
91	2	1	3698866802354742	5
92	13	2	501151039	5
93	19	8	200368332	5
94	5	2	3699714385808654	5
95	10	5	3697145195403847	5
96	16	5	300690623	5
97	14	3	501266143	5
98	17	6	300483436	5
99	9	9	3705210344625548	6
100	6	8	3693737234278234	6
101	22	11	969195117507	6
102	21	10	500547950	6
103	18	7	1211306696373	6
104	1	7	3705717004093102	6
105	11	3	3708792854179417	6
106	15	4	727116732909	6
107	12	1	1332362485806	6
108	4	10	3696050537201180	6
109	20	9	969312102111	6
110	7	4	3697861323176899	6
111	8	11	3710322304565953	6
112	3	6	3695458841334687	6
113	2	1	3706411743739867	6
114	13	2	1332371100974	6
115	19	8	200368332	6
116	5	2	3707259318694150	6
117	10	5	3697145195403847	6
118	16	5	300690623	6
119	14	3	1453401620553	6
120	17	6	300483436	6
121	9	9	3716534405786656	7
122	6	8	3693737234278234	7
123	22	11	1843212204221	7
124	21	10	1002134429747	7
125	18	7	2086354549155	7
126	55	3	0	7
127	1	7	3710673394115352	7
128	11	3	3717995726936745	7
129	54	3	0	7
130	15	4	1227634371429	7
131	12	1	2457076871912	7
132	52	3	0	7
133	4	10	3701724247398255	7
134	53	3	0	7
135	20	9	2968068001442	7
136	7	4	3700695377233540	7
137	8	11	3715272966924171	7
138	3	6	3695458841334687	7
139	2	1	3712782852841109	7
140	19	8	200368332	7
141	56	3	999212833	7
142	14	3	3077829456062	7
143	46	3	4998922331595	7
144	17	6	300483436	7
145	9	9	3724884964413348	8
146	6	8	3693737234278234	8
147	22	11	3069905457202	8
148	21	10	2110039246191	8
149	18	7	3806390770268	8
150	55	3	0	8
151	1	7	3720418047233098	8
152	11	3	3720082644877521	8
153	54	3	0	8
154	15	4	2089008220915	8
155	12	1	3071595665894	8
156	52	3	0	8
157	4	10	3708000159025238	8
158	53	3	0	8
159	20	9	4442087590919	8
160	7	4	3705574281304018	8
161	8	11	3722222125754794	8
162	3	6	3695458841334687	8
163	2	1	3716262856197744	8
164	19	8	200368332	8
165	56	3	999212833	8
166	14	3	3446499425242	8
167	46	3	4998922331595	8
168	17	6	300483436	8
169	9	9	3730811635003848	9
170	6	8	3693737234278234	9
171	22	11	4232797897709	9
172	21	10	2809759411866	9
173	18	7	5087538614645	9
174	55	3	0	9
175	1	7	3727659893821343	9
176	11	3	3726659796579211	9
177	54	3	0	9
178	15	4	3488713494500	9
179	12	1	4236272451889	9
180	52	3	0	9
181	4	10	3711963026386182	9
182	53	3	0	9
183	20	9	5490184711048	9
184	7	4	3713493353583730	9
185	8	11	3728798300908334	9
186	3	6	3695458841334687	9
187	2	1	3722844651378095	9
188	19	8	200368332	9
189	56	3	999212833	9
190	14	3	4610595553764	9
191	46	3	4998905371591	9
192	17	6	300483436	9
193	9	9	3735204887299585	10
194	6	8	3693737234278234	10
195	22	11	5303738669951	10
196	21	10	3785926548550	10
197	18	7	6939994854190	10
198	55	3	0	10
199	1	7	3738115743302171	10
200	11	3	3731039288096000	10
201	54	3	0	10
202	15	4	3977236993602	10
203	12	1	5601190630400	10
204	52	3	0	10
205	4	10	3717482468635161	10
206	53	3	0	10
207	20	9	6269982178356	10
208	7	4	3716253339597514	10
209	8	11	3734844869890222	10
210	3	6	3695458841334687	10
211	2	1	3730542956725039	10
212	19	8	200368332	10
213	56	3	1000389823	10
214	14	3	5389141530497	10
215	46	3	5004793688725	10
216	17	6	300483436	10
217	9	9	3738984727764372	11
218	6	8	3693737234278234	11
219	22	11	6359629050234	11
220	21	10	4748411574805	11
221	18	7	8381768568376	11
222	55	3	0	11
223	1	7	3746228251185517	11
224	11	3	3737513667294958	11
225	54	3	0	11
226	15	4	5229156165320	11
227	12	1	6370459461206	11
228	52	3	0	11
229	4	10	3722913736015447	11
230	53	3	0	11
231	20	9	6942705936164	11
232	7	4	3723318784059779	11
233	8	11	3740793444768227	11
234	3	6	3695458841334687	11
235	2	1	3734876004196407	11
236	19	8	200368332	11
237	56	3	1002128838	11
238	14	3	6540661398244	11
239	64	7	2502396757014	11
240	46	3	2511096559452	11
241	17	6	300483436	11
242	9	9	3742704047942243	12
243	6	8	3693737234278234	12
244	22	11	6927524755797	12
245	21	10	5602481203147	12
246	18	7	9045182556156	12
247	55	3	0	12
248	1	7	3749951510234222	12
249	11	3	3746006078289314	12
250	54	3	0	12
251	15	4	6558100070058	12
252	12	1	7507792009997	12
253	52	3	0	12
254	4	10	3727726964847393	12
255	53	3	0	12
256	20	9	7605885701814	12
257	7	4	3730800397870081	12
258	8	11	3743985268806405	12
259	3	6	3695458841334687	12
260	2	1	3741270115698882	12
261	19	8	200368332	12
262	56	3	1004405870	12
263	14	3	8054083731877	12
264	64	7	2502396757014	12
265	46	3	2522488197340	12
266	17	6	300483436	12
267	9	9	3743750236395847	13
268	6	8	3693737234278234	13
269	22	11	8140365315383	13
270	21	10	6818745763380	13
271	18	7	11006427638743	13
272	55	3	0	13
273	1	7	3760927176622899	13
274	11	3	3752277997739556	13
275	54	3	0	13
276	15	4	7307124718794	13
277	12	1	8722511235031	13
278	52	3	0	13
279	4	10	3734570457416110	13
280	53	3	0	13
281	20	9	7792963253362	13
282	7	4	3735012607392902	13
283	8	11	3750791499844181	13
284	3	6	3695458841334687	13
285	2	1	3748083063045023	13
286	19	8	200368332	13
287	56	3	1006087536	13
288	14	3	9173425902716	13
289	64	7	2502381591466	13
290	46	3	2530899544403	13
291	17	6	300483436	13
\.


--
-- Data for Name: epoch_sync_time; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_sync_time (id, no, seconds, state) FROM stdin;
1	0	1	lagging
2	1	1	lagging
3	2	1	following
4	3	182	following
5	4	200	following
6	5	201	following
7	6	202	following
8	7	200	following
9	8	203	following
10	9	197	following
11	10	201	following
12	11	200	following
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
9	1	113	9
10	1	113	10
11	1	113	11
12	-1	116	9
13	-1	116	10
14	-1	117	11
15	1	118	11
16	1	119	11
17	-2	120	11
18	2	121	11
19	-2	122	11
20	2	123	11
21	-1	124	11
22	-1	125	11
23	1	126	12
24	1	126	13
25	1	126	14
26	-1	127	13
27	1	128	15
28	1	129	16
29	1	130	17
30	-1	131	15
31	-1	131	16
32	-1	131	17
33	-1	131	12
34	-1	131	14
35	1	136	18
36	-1	137	18
37	10	138	19
38	-10	139	19
39	1	355	9
40	1	355	10
41	1	355	11
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
9	1	139	9
10	1	139	10
11	1	139	11
12	1	141	11
13	1	142	9
14	1	142	10
15	1	144	9
16	1	144	10
17	1	147	11
18	1	149	11
19	1	150	11
20	2	152	11
21	2	155	11
22	1	157	11
23	1	159	12
24	1	159	13
25	1	159	14
26	1	162	12
27	1	162	14
28	1	163	15
29	1	164	12
30	1	164	14
31	1	165	16
32	1	166	12
33	1	166	14
34	1	167	17
35	1	168	15
36	1	168	16
37	1	217	18
38	10	220	19
39	1	780	9
40	1	780	10
41	1	780	11
42	13500000000000000	791	1
43	13500000000000000	791	2
44	13500000000000000	791	3
45	13500000000000000	791	4
46	2	793	5
47	1	793	6
48	1	793	7
\.


--
-- Data for Name: meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meta (id, start_time, network_name, version) FROM stdin;
1	2023-10-25 17:32:23	testnet	Version {versionBranch = [13,1,0,0], versionTags = []}
\.


--
-- Data for Name: multi_asset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.multi_asset (id, policy, name, fingerprint) FROM stdin;
1	\\x94e055c4805abb1fc15d32a17e3b6c96b2296e0d68ac6a69765d9f8d	\\x	asset1tn0jcs0dp86kzagc4hddugvwxqm0spwkexht70
2	\\x94e055c4805abb1fc15d32a17e3b6c96b2296e0d68ac6a69765d9f8d	\\x74425443	asset1kjs6rz783rayqgrkr9szs7wus0xtx8yeh2twwl
3	\\x94e055c4805abb1fc15d32a17e3b6c96b2296e0d68ac6a69765d9f8d	\\x74455448	asset1lsxj9gqp7sjn8v5gn49jh47lh5qrrwwrhk2y4c
4	\\x94e055c4805abb1fc15d32a17e3b6c96b2296e0d68ac6a69765d9f8d	\\x744d494e	asset1nqv9tp9x08xrmha3j72smzty3sug8dddseup5p
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
18	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x	asset1qrmynj6uhyk2hn9pc3yh0p80rg598n4yy77ays
19	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	\\x3030303030	asset1ul4zmmx2h8rqz9wswvc230w909pq2q0hne02q0
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
1	\\x10ec3f0666d724987bd7bca0e6a3e3379dd8c72e7e53f8600b638309	pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg
2	\\x1c6dc52e66fcd8fbb4ce5049ed0788e979490e8a188f329eb6a292c9	pool1r3ku2tnxlnv0hdxw2py76puga9u5jr52rz8n984k52fvjjcy9rn
3	\\x1d15b58ed6f59d26d08b20aa635b3ca03769934b8c69d1d81aa6de6d	pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6
4	\\x35908c7afc62e0bb58e414d46fd96fdd29453b0f80cde4df08d9089b	pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr
5	\\x3aabc87a8cb1872da46f2dee842e7299cd7993577d56144840a8bb9c	pool1824us75vkxrjmfr09hhggtnjn8xhny6h04tpgjzq4zaecz33l8r
6	\\x511662857816c77b7543e4383f253816031e3d434e5a28afb9d64721	pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0
7	\\x78a4ecb9bd827c9660eedaff0013205f035e17ddc52d98042a089bb6	pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx
8	\\x921c20953083c8322befe96fc9c697ae7c333caf90bc46eb5efbc224	pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d
9	\\xa4881f848f651c3ccecf69408d7bafa07d360d71ed1db9781bd8e608	pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v
10	\\xa9023cd813d63ba851e66835205ae1a227ee782dfd2b53cc0353ae1b	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s
11	\\xece7e4747470b66c32923761eb74025fc7ddbbdb3dace294730de975	pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm
12	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
13	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_metadata_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata_ref (id, pool_id, url, hash, registered_tx_id) FROM stdin;
1	4	http://file-server/SP1.json	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	39
2	8	http://file-server/SP3.json	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	49
3	11	http://file-server/SP4.json	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	54
4	7	http://file-server/SP5.json	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	59
5	1	http://file-server/SP6.json	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	64
6	3	http://file-server/SP7.json	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	69
7	2	http://file-server/SP10.json	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	88
8	10	http://file-server/SP11.json	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	95
\.


--
-- Data for Name: pool_offline_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_offline_data (id, pool_id, ticker_name, hash, json, bytes, pmr_id) FROM stdin;
1	4	SP1	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	{"name": "stake pool - 1", "ticker": "SP1", "homepage": "https://stakepool1.com", "description": "This is the stake pool 1 description."}	\\x7b0a2020226e616d65223a20227374616b6520706f6f6c202d2031222c0a2020227469636b6572223a2022535031222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2031206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c312e636f6d220a7d0a	1
2	8	SP3	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	{"name": "Stake Pool - 3", "ticker": "SP3", "homepage": "https://stakepool3.com", "description": "This is the stake pool 3 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2033222c0a2020227469636b6572223a2022535033222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2033206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c332e636f6d220a7d0a	2
3	11	SP4	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	{"name": "Same Name", "ticker": "SP4", "homepage": "https://stakepool4.com", "description": "This is the stake pool 4 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535034222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2034206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c342e636f6d220a7d0a	3
4	7	SP5	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	{"name": "Same Name", "ticker": "SP5", "homepage": "https://stakepool5.com", "description": "This is the stake pool 5 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535035222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2035206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c352e636f6d220a7d0a	4
5	1	SP6a7	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	{"name": "Stake Pool - 6", "ticker": "SP6a7", "homepage": "https://stakepool6.com", "description": "This is the stake pool 6 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2036222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2036206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c362e636f6d220a7d0a	5
6	3	SP6a7	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	{"name": "", "ticker": "SP6a7", "homepage": "https://stakepool7.com", "description": "This is the stake pool 7 description."}	\\x7b0a2020226e616d65223a2022222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2037206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c372e636f6d220a7d0a	6
7	2	SP10	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	{"name": "Stake Pool - 10", "ticker": "SP10", "homepage": "https://stakepool10.com", "description": "This is the stake pool 10 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130222c0a2020227469636b6572223a202253503130222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203130206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31302e636f6d220a7d0a	7
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
1	15	12
2	20	13
3	19	14
4	22	15
5	18	16
6	12	17
7	14	18
8	16	19
9	17	20
10	13	21
11	21	22
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
2	6	0	83	18
3	2	0	90	5
4	10	0	97	18
\.


--
-- Data for Name: pool_update; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_update (id, hash_id, cert_index, vrf_key_hash, pledge, active_epoch_no, meta_id, margin, fixed_cost, registered_tx_id, reward_addr_id) FROM stdin;
1	1	0	\\xb32caccdc44f08b73c9b2a30ce7f8a32635540ab582bba5622c1558aa2bf60c8	0	2	\N	0	0	34	12
2	2	1	\\x04f5e85039055bccf8150f3f7e132040c8963f471ab2e0b4eb8529ecdc3113a0	0	2	\N	0	0	34	13
3	3	2	\\xbc744255ee850dc61dd3c356c5c0cd5efab0cd6e8b25c09c87ad0d094f1b08c9	0	2	\N	0	0	34	14
4	4	3	\\x3b87cc973c75b05cb100d40d0722f8c4825c6393288138714ab15afdc9b2f479	0	2	\N	0	0	34	15
5	5	4	\\xd57752fae2a147a08a7458c1449dcc3b01061f87131fa4892bffeb0834972724	0	2	\N	0	0	34	16
6	6	5	\\x6dfd4d1a6607eb7a59211e85cc0d5c1f35b565862822e2057db3319324199578	0	2	\N	0	0	34	17
7	7	6	\\x60104714e79fac1b2b479bdd24ec92b6996c2b48edf70e195eb6525e4bda8e7b	0	2	\N	0	0	34	18
8	8	7	\\x11e9d71d390e0a9191585951b0ae68cca33656eaa7771a695ccdc76a2916da34	0	2	\N	0	0	34	19
9	9	8	\\x128fcece38173d2e053f9016bd7327a18733af5c036d78ccf06c1766617a2359	0	2	\N	0	0	34	20
10	10	9	\\xafbda61a70526702f2ff8ed34c4184386a657b05b101f4c4e0239077c78aa6a0	0	2	\N	0	0	34	21
11	11	10	\\x4992b9010caab7f9b83fe06806226697ec7e3483624d201a4b891e7d3837fadc	0	2	\N	0	0	34	22
12	4	0	\\x3b87cc973c75b05cb100d40d0722f8c4825c6393288138714ab15afdc9b2f479	400000000	3	1	0.149999999999999994	390000000	39	15
13	9	0	\\x128fcece38173d2e053f9016bd7327a18733af5c036d78ccf06c1766617a2359	500000000	3	\N	0.149999999999999994	390000000	44	20
14	8	0	\\x11e9d71d390e0a9191585951b0ae68cca33656eaa7771a695ccdc76a2916da34	600000000	3	2	0.149999999999999994	390000000	49	19
15	11	0	\\x4992b9010caab7f9b83fe06806226697ec7e3483624d201a4b891e7d3837fadc	420000000	3	3	0.149999999999999994	370000000	54	22
16	7	0	\\x60104714e79fac1b2b479bdd24ec92b6996c2b48edf70e195eb6525e4bda8e7b	410000000	3	4	0.149999999999999994	390000000	59	18
17	1	0	\\xb32caccdc44f08b73c9b2a30ce7f8a32635540ab582bba5622c1558aa2bf60c8	410000000	3	5	0.149999999999999994	400000000	64	12
18	3	0	\\xbc744255ee850dc61dd3c356c5c0cd5efab0cd6e8b25c09c87ad0d094f1b08c9	410000000	3	6	0.149999999999999994	390000000	69	14
19	5	0	\\xd57752fae2a147a08a7458c1449dcc3b01061f87131fa4892bffeb0834972724	500000000	3	\N	0.149999999999999994	380000000	74	16
20	6	0	\\x6dfd4d1a6607eb7a59211e85cc0d5c1f35b565862822e2057db3319324199578	500000000	3	\N	0.149999999999999994	390000000	81	17
21	2	0	\\x04f5e85039055bccf8150f3f7e132040c8963f471ab2e0b4eb8529ecdc3113a0	400000000	3	7	0.149999999999999994	410000000	88	13
22	10	0	\\xafbda61a70526702f2ff8ed34c4184386a657b05b101f4c4e0239077c78aa6a0	400000000	4	8	0.149999999999999994	390000000	95	21
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
1	3	1:34:
2	4	2:36:
3	5	::
4	6	::
5	7	::
6	8	3:37:
7	9	4:38:
8	10	::
9	11	::
10	12	5:39:
11	13	6:40:
12	14	::
13	15	::
14	16	::
15	17	7:42:
16	18	::
17	19	8:43:
18	20	::
19	21	9:44:
20	22	10:45:
21	23	::
22	24	::
23	25	::
24	26	11:46:
25	27	::
26	28	::
27	29	::
28	30	12:48:
29	31	::
30	32	::
31	33	::
32	34	13:49:
33	35	::
34	36	::
35	37	14:50:
36	38	15:51:
37	39	16:52:
38	40	17:54:
39	41	18:55:
40	42	::
41	43	19:56:
42	44	20:57:
43	45	::
44	46	21:58:
45	47	::
46	48	22:60:
47	49	::
48	50	23:61:
49	51	::
50	52	24:62:
51	53	::
52	54	25:63:
53	55	::
54	56	26:64:
55	57	27:66:
56	58	::
57	59	::
58	60	::
59	61	28:67:
60	62	29:68:
61	63	30:69:
62	64	31:70:
63	65	32:72:
64	66	::
65	67	33:73:
66	68	34:74:
67	69	35:75:
68	70	::
69	71	36:76:
70	72	37:78:
71	73	38:79:
72	74	::
73	75	::
74	76	39:80:
75	77	40:81:
76	78	41:82:
77	79	::
78	80	42:83:
79	81	::
80	82	43:84:
81	83	44:86:
82	84	45:87:
83	85	::
84	86	::
85	87	::
86	88	::
87	89	46:88:
88	90	47:89:
89	91	48:90:
90	92	::
91	93	49:91:
92	94	::
93	95	::
94	96	50:92:
95	97	::
96	98	51:94:
97	99	::
98	100	52:95:
99	101	::
100	102	::
101	103	::
102	104	::
103	105	53:96:
104	106	::
105	107	54:97:
106	108	55:98:
107	109	::
108	110	56:99:
109	111	::
110	112	::
111	113	57:100:
112	114	58:102:
113	115	::
114	116	59:103:
115	117	::
116	118	60:104:
117	119	::
118	120	61:105:
119	121	62:106:
120	122	::
121	123	::
122	124	63:107:
123	125	::
124	126	::
125	127	::
126	128	64:108:
127	129	65:110:
128	130	::
129	131	66:111:
130	132	::
131	133	67:113:
132	134	68:115:
133	135	::
134	136	::
135	137	::
136	138	69:117:
137	139	70:119:
138	140	71:121:
139	141	::
140	142	72:123:
141	143	74:124:1
142	144	75:126:
143	145	76:132:5
144	146	77:134:8
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
393	395	::
395	397	::
396	398	::
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
445	447	78:136:
446	448	79:138:
447	449	::
448	450	80:139:9
449	451	::
450	452	::
451	453	::
452	454	81:141:12
454	456	::
455	457	::
456	458	::
457	459	83:143:15
458	460	::
459	461	::
460	462	::
461	463	84:145:
462	464	::
463	465	::
464	466	::
465	467	85:146:
466	468	::
467	469	::
468	470	::
469	471	86:147:17
470	472	::
471	473	::
472	474	::
473	475	87:149:18
474	476	::
475	477	::
476	478	::
477	479	89:151:
478	480	::
479	481	::
480	482	::
481	483	91:152:20
482	484	::
483	485	::
484	486	::
485	487	92:154:
486	488	::
487	489	::
488	490	::
489	491	93:155:21
491	493	::
492	494	::
493	495	::
494	496	95:157:22
495	497	::
496	498	::
497	499	::
498	500	96:158:
499	501	::
500	502	::
501	503	::
502	504	::
503	505	::
504	506	97:159:23
505	507	::
506	508	::
507	509	::
508	510	99:161:26
509	511	::
510	512	::
511	513	::
512	514	101:163:28
513	515	::
514	516	::
515	517	::
516	518	103:165:31
518	520	::
519	521	::
520	522	::
521	523	104:167:34
522	524	::
523	525	::
524	526	::
525	527	106:169:
526	528	::
527	529	::
528	530	::
529	531	::
530	532	::
531	533	109:170:
532	534	::
533	535	::
534	536	::
535	537	110:172:
536	538	::
537	539	::
538	540	::
539	541	111:207:
540	542	::
541	543	::
542	544	::
543	545	146:216:
544	546	::
545	547	::
546	548	::
547	549	::
548	550	147:217:37
549	551	::
550	552	::
551	553	::
552	554	::
553	555	148:219:
554	556	::
555	557	::
556	558	::
557	559	149:220:38
558	560	::
559	561	::
560	562	::
561	563	150:222:
562	564	::
563	565	::
564	566	::
565	567	::
566	568	151:223:
567	569	152::
568	570	::
569	571	153:225:
570	572	::
571	573	::
572	574	::
573	575	158:229:
574	576	159:231:
575	577	161:351:
576	578	::
577	579	::
578	580	::
579	581	221:353:
580	582	::
581	583	::
582	584	::
583	585	::
584	586	222:355:
585	587	223:357:
586	588	::
587	589	::
588	590	::
589	591	::
590	592	287:359:
591	593	::
592	594	::
593	595	::
594	596	::
595	597	::
596	598	::
597	599	288:361:
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
721	723	289:362:
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
761	763	::
762	764	::
763	765	::
764	766	::
765	767	::
766	768	::
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
870	872	::
871	873	::
872	874	::
873	875	::
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
911	913	473:562:
912	914	::
913	915	::
914	916	::
915	917	::
916	918	::
917	919	474:564:
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
962	964	::
963	965	::
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
1113	1115	493:578:
1114	1116	553:664:
1115	1117	560:672:
1116	1118	577:694:
1117	1119	::
1118	1120	::
1119	1121	::
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
1156	1158	::
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
1312	1314	653:778:
1313	1315	::
1314	1316	::
1315	1317	::
1316	1318	::
1317	1319	::
1318	1320	654:780:39
1319	1321	::
1320	1322	::
1321	1323	::
1322	1324	::
1323	1325	::
1324	1326	::
1325	1327	::
1326	1328	656:782:
1327	1329	::
1328	1330	::
1329	1331	::
1330	1332	657:784:
1331	1333	::
1332	1334	::
1333	1335	::
1334	1336	659:786:
1335	1337	::
1336	1338	::
1338	1340	::
1339	1341	661:788:
1340	1342	::
1341	1343	::
1342	1344	::
1343	1345	662:790:42
1344	1346	::
1345	1347	::
1346	1348	::
1347	1349	663:792:46
1348	1350	::
1349	1351	::
1350	1352	::
\.


--
-- Data for Name: reward; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward (id, addr_id, type, amount, earned_epoch, spendable_epoch, pool_id) FROM stdin;
1	9	member	10276765313795	1	3	9
2	6	member	5138382656897	1	3	8
3	1	member	8563971094829	1	3	7
4	11	member	9420368204312	1	3	3
5	4	member	2569191328448	1	3	10
6	7	member	5994779766380	1	3	4
7	8	member	12845956642244	1	3	11
8	3	member	7707573985346	1	3	6
9	2	member	9420368204312	1	3	1
10	5	member	9420368204312	1	3	2
11	10	member	6851176875863	1	3	5
12	22	leader	0	1	3	11
13	21	leader	0	1	3	10
14	18	leader	0	1	3	7
15	15	leader	0	1	3	4
16	12	leader	0	1	3	1
17	20	leader	0	1	3	9
18	13	leader	0	1	3	2
19	19	leader	0	1	3	8
20	16	leader	0	1	3	5
21	14	leader	0	1	3	3
22	17	leader	0	1	3	6
23	9	member	7628252292431	2	4	9
24	6	member	6780670177718	2	4	8
25	22	member	1381247	2	4	11
26	18	member	1151039	2	4	7
27	1	member	8475836340901	2	4	7
28	11	member	9323419974991	2	4	3
29	15	member	805727	2	4	4
30	12	member	1035935	2	4	1
31	4	member	7628254777906	2	4	10
32	20	member	1243122	2	4	9
33	7	member	5933085438630	2	4	4
35	8	member	10171003609081	2	4	11
36	3	member	5933086083499	2	4	6
37	2	member	7628252706811	2	4	1
38	13	member	1151039	2	4	2
39	19	member	368332	2	4	8
40	5	member	8475836341316	2	4	2
41	10	member	8475837262142	2	4	5
42	16	member	690623	2	4	5
43	14	member	1266143	2	4	3
44	17	member	483436	2	4	6
45	22	leader	0	2	4	11
46	21	leader	0	2	4	10
47	18	leader	0	2	4	7
48	15	leader	0	2	4	4
49	12	leader	0	2	4	1
50	20	leader	0	2	4	9
51	13	leader	0	2	4	2
52	19	leader	0	2	4	8
53	16	leader	0	2	4	5
54	14	leader	0	2	4	3
55	17	leader	0	2	4	6
56	9	member	5487145572931	3	5	9
57	21	member	547950	3	5	10
58	1	member	6859015213753	3	5	7
59	11	member	8230884556495	3	5	3
60	4	member	4034909831791	3	5	10
61	7	member	4115276528270	3	5	4
62	8	member	5487162871009	3	5	11
63	2	member	7544941385125	3	5	1
64	5	member	7544932885496	3	5	2
65	22	leader	968693736260	3	5	11
66	21	leader	0	3	5	10
67	18	leader	1210805545334	3	5	7
68	15	leader	726615927182	3	5	4
69	12	leader	1331861449871	3	5	1
70	20	leader	968710858989	3	5	9
71	13	leader	1331869949935	3	5	2
72	19	leader	0	3	5	8
73	16	leader	0	3	5	5
74	14	leader	1452900354410	3	5	3
75	17	leader	0	3	5	6
76	13	refund	0	5	5	2
77	16	refund	0	5	5	5
78	9	member	11324061161108	4	6	9
79	1	member	4956390022250	4	6	7
80	11	member	9202872757328	4	6	3
81	4	member	5673710197075	4	6	10
82	7	member	2834054056641	4	6	4
83	8	member	4950662358218	4	6	11
84	2	member	6371109101242	4	6	1
85	5	member	3539345445329	4	6	2
86	22	leader	874017086714	4	6	11
87	21	leader	1001633881797	4	6	10
88	18	leader	875047852782	4	6	7
89	15	leader	500517638520	4	6	4
90	12	leader	1124714386106	4	6	1
91	20	leader	1998755899331	4	6	9
92	13	leader	625000936734	4	6	2
93	19	leader	0	4	6	8
94	16	leader	0	4	6	5
95	14	leader	1624427835509	4	6	3
96	17	leader	0	4	6	6
97	9	member	8350558626692	5	7	9
98	1	member	9744653117746	5	7	7
99	11	member	2086917940776	5	7	3
100	4	member	6275911626983	5	7	10
101	7	member	4878904070478	5	7	4
102	8	member	6949158830623	5	7	11
104	2	member	3480003356635	5	7	1
105	5	member	4175106735790	5	7	2
106	22	leader	1226693252981	5	7	11
107	21	leader	1107904816444	5	7	10
108	18	leader	1720036221113	5	7	7
109	15	leader	861373849486	5	7	4
110	12	leader	614518793982	5	7	1
111	20	leader	1474019589477	5	7	9
112	13	leader	737194206958	5	7	2
113	19	leader	0	5	7	8
114	16	leader	0	5	7	5
115	14	leader	368669969180	5	7	3
116	17	leader	0	5	7	6
117	9	member	5926670590500	6	8	9
118	1	member	7241846588245	6	8	7
119	11	member	6577151701690	6	8	3
120	4	member	3962867360944	6	8	10
121	7	member	7919072279712	6	8	4
122	8	member	6576175153540	6	8	11
123	2	member	6581795180351	6	8	1
124	5	member	7896409141149	6	8	2
125	22	leader	1162892440507	6	8	11
126	21	leader	699720165675	6	8	10
127	18	leader	1281147844377	6	8	7
128	15	leader	1399705273585	6	8	4
129	12	leader	1164676785995	6	8	1
130	20	leader	1048097120129	6	8	9
131	13	leader	1397232708817	6	8	2
132	19	leader	0	6	8	8
133	16	leader	0	6	8	5
134	14	leader	1164096128522	6	8	3
135	17	leader	0	6	8	6
136	9	member	4393252295737	7	9	9
137	1	member	10455849480828	7	9	7
138	11	member	4379491516789	7	9	3
139	4	member	5519442248979	7	9	10
140	7	member	2759986013784	7	9	4
141	8	member	6046568981888	7	9	11
142	2	member	7698305346944	7	9	1
143	56	member	1176990	7	9	3
144	46	member	5888317134	7	9	3
145	22	leader	1070940772242	7	9	11
146	21	leader	976167136684	7	9	10
147	18	leader	1852456239545	7	9	7
148	15	leader	488523499102	7	9	4
149	12	leader	1364918178511	7	9	1
150	20	leader	779797467308	7	9	9
151	19	leader	0	7	9	8
152	14	leader	778545976733	7	9	3
153	17	leader	0	7	9	6
154	9	member	3779840464787	8	10	9
155	1	member	8112507883346	8	10	7
157	11	member	6474379198958	8	10	3
158	4	member	5431267380286	8	10	10
159	7	member	7065444462265	8	10	4
160	8	member	5948574878005	8	10	11
161	2	member	4333047471368	8	10	1
162	56	member	1739015	8	10	3
163	46	member	8700053695	8	10	3
164	22	leader	1055890380283	8	10	11
165	21	leader	962485026255	8	10	10
166	18	leader	1441773714186	8	10	7
167	15	leader	1251919171718	8	10	4
168	12	leader	769268830806	8	10	1
169	20	leader	672723757808	8	10	9
170	19	leader	0	8	10	8
171	14	leader	1151519867747	8	10	3
172	17	leader	0	8	10	6
173	9	member	3719320177871	9	11	9
174	1	member	3723259048705	9	11	7
175	11	member	8492410994356	9	11	3
176	4	member	4813228831946	9	11	10
177	7	member	7481613810302	9	11	4
178	8	member	3191824038178	9	11	11
179	2	member	6394111502475	9	11	1
180	56	member	2277032	9	11	3
181	46	member	11391637888	9	11	3
182	22	leader	567895705563	9	11	11
183	21	leader	854069628342	9	11	10
184	18	leader	663413987780	9	11	7
185	15	leader	1328943904738	9	11	4
186	12	leader	1137332548791	9	11	1
187	20	leader	663179765650	9	11	9
188	19	leader	0	9	11	8
189	14	leader	1513422333633	9	11	3
190	17	leader	0	9	11	6
191	9	member	1046188453604	10	12	9
192	1	member	10975666388677	10	12	7
193	11	member	6271919450242	10	12	3
194	4	member	6843492568717	10	12	10
195	7	member	4212209522821	10	12	4
196	8	member	6806231037776	10	12	11
197	2	member	6812947346141	10	12	1
198	56	member	1681666	10	12	3
200	46	member	8413115075	10	12	3
201	22	leader	1212840559586	10	12	11
202	21	leader	1216264560233	10	12	10
203	18	leader	1961245082587	10	12	7
204	15	leader	749024648736	10	12	4
205	12	leader	1214719225034	10	12	1
206	20	leader	187077551548	10	12	9
207	19	leader	0	10	12	8
208	14	leader	1119342170839	10	12	3
209	17	leader	0	10	12	6
210	9	member	4116471874120	11	13	9
211	1	member	7687648946104	11	13	7
212	11	member	5656116037885	11	13	3
213	4	member	4656467964896	11	13	10
214	7	member	6723692307057	11	13	4
215	8	member	4630298857646	11	13	11
216	2	member	3091592346718	11	13	1
217	56	member	1516558	11	13	3
218	64	member	5135177704	11	13	7
219	46	member	3800134203	11	13	3
220	22	leader	826742568853	11	13	11
221	21	leader	829106839269	11	13	10
222	18	leader	1378175737724	11	13	7
223	15	leader	1198033328651	11	13	4
224	12	leader	552178921119	11	13	1
225	20	leader	735818730882	11	13	9
226	19	leader	0	11	13	8
227	14	leader	1010843970882	11	13	3
228	17	leader	0	11	13	6
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
5	107	\\x94e055c4805abb1fc15d32a17e3b6c96b2296e0d68ac6a69765d9f8d	timelock	{"type": "sig", "keyHash": "d1ed37edcf85136dfb9f492823e71b194301370b0e19bf96848cc84e"}	\N	\N
6	109	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	timelock	{"type": "sig", "keyHash": "5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967"}	\N	\N
7	126	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}]}	\N	\N
8	138	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}, {"type": "sig", "keyHash": "3178bf14adf78294ac2d03d60b9edfb7323d3d719e98b4b0b3ca34cd"}]}	\N	\N
\.


--
-- Data for Name: slot_leader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slot_leader (id, hash, pool_hash_id, description) FROM stdin;
1	\\x269f7149b832e4c47571e820601d07bcc28222335d8c7cd1232bd793	\N	Genesis slot leader
2	\\x5368656c6c65792047656e6573697320536c6f744c65616465722048	\N	Shelley Genesis slot leader
15	\\xece7e4747470b66c32923761eb74025fc7ddbbdb3dace294730de975	11	Pool-ece7e4747470b66c
8	\\x511662857816c77b7543e4383f253816031e3d434e5a28afb9d64721	6	Pool-511662857816c77b
13	\\xa9023cd813d63ba851e66835205ae1a227ee782dfd2b53cc0353ae1b	10	Pool-a9023cd813d63ba8
6	\\x10ec3f0666d724987bd7bca0e6a3e3379dd8c72e7e53f8600b638309	1	Pool-10ec3f0666d72498
11	\\x1d15b58ed6f59d26d08b20aa635b3ca03769934b8c69d1d81aa6de6d	3	Pool-1d15b58ed6f59d26
3	\\x78a4ecb9bd827c9660eedaff0013205f035e17ddc52d98042a089bb6	7	Pool-78a4ecb9bd827c96
17	\\x921c20953083c8322befe96fc9c697ae7c333caf90bc46eb5efbc224	8	Pool-921c20953083c832
19	\\x3aabc87a8cb1872da46f2dee842e7299cd7993577d56144840a8bb9c	5	Pool-3aabc87a8cb1872d
5	\\x35908c7afc62e0bb58e414d46fd96fdd29453b0f80cde4df08d9089b	4	Pool-35908c7afc62e0bb
9	\\xa4881f848f651c3ccecf69408d7bafa07d360d71ed1db9781bd8e608	9	Pool-a4881f848f651c3c
7	\\x1c6dc52e66fcd8fbb4ce5049ed0788e979490e8a188f329eb6a292c9	2	Pool-1c6dc52e66fcd8fb
\.


--
-- Data for Name: stake_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_address (id, hash_raw, view, script_hash) FROM stdin;
9	\\xe0064f2abd18c65f030edd38a27cd0c244949c7cfc1259218a704e9e1e	stake_test1uqry724arrr97qcwm5u2ylxscfzff8rulsf9jgv2wp8fu8smtxsh9	\N
6	\\xe006582f5b9b16b6720cf131c4447eb327ad7d1fd5d729d9016c87fb09	stake_test1uqr9st6mnvttvusv7ycug3r7kvn66lgl6htjnkgpdjrlkzgjpu2zp	\N
1	\\xe020c9cf7531f39633b3e6dc973bfe91fae6bfe35d21b24f31d9b5f67c	stake_test1uqsvnnm4x8eevvanumwfwwl7j8awd0lrt5smyne3mx6lvlqql2qup	\N
11	\\xe04cfa7a0cb7927720a6d3f2c5d1aef6ebb955d23bcbcc4a172b68a36c	stake_test1upx057svk7f8wg9x60evt5dw7m4mj4wj809ucjsh9d52xmq8p776q	\N
4	\\xe07d78a65c196231f3c7e258298fe3f4706ea0546ae9a4576275c58fe9	stake_test1up7h3fjur93rru78ufvznrlr73cxagz5dt56g4mzwhzcl6gdj5u75	\N
7	\\xe0a1dbea2c91552df9795f43ccd545e93b0bad14e08d72454a37357eb7	stake_test1uzsah63vj92jm7tetapue429ayashtg5uzxhy322xu6hadcv5j28s	\N
8	\\xe0a2a35359273d090e7527e529642659cd48edfb0e6fb80a385bc2eb26	stake_test1uz32x56eyu7sjrn4yljjjepxt8x53m0mpehmsz3ct0pwkfslertke	\N
3	\\xe0b19e81f4891b4dd041576280d8d3aecec5a36af9b3498ed88ac2b1a3	stake_test1uzceaq053yd5m5zp2a3gpkxn4m8vtgm2lxe5nrkc3tptrgc5t3sxx	\N
2	\\xe0b3385bdf22320f3ffd7544391946d599aec2064280e6f80759eae624	stake_test1uzensk7lygeq70law4zrjx2x6kv6assxg2qwd7q8t84wvfqdcnmwl	\N
5	\\xe0ca563d21e64d9fa807c6cc48970e3f3e1cf822bf24f5a5405eda519a	stake_test1ur99v0fpuexel2q8cmxy39cw8ulpe7pzhuj0tf2qtmd9rxs028q28	\N
10	\\xe0d0f27410a325078984e3fcb60f3b5f93d1ff26b5b5c36c12fd70554a	stake_test1urg0yaqs5vjs0zvyu07tvremt7farlexkk6uxmqjl4c92jssnd2fp	\N
15	\\xe0622b24bee46395c47c565a470d8a9aac2649ee24fdd909dba19f1ab6	stake_test1up3zkf97u33et3ru2edywrv2n2kzvj0wyn7ajzwm5x034ds5e8u0f	\N
20	\\xe0926bfb8e5662e93d3672214295634af3036188591c6b326cf0cd0dd1	stake_test1uzfxh7uw2e3wj0fkwgs599trftesxcvgtywxkvnv7rxsm5ga9nsw9	\N
19	\\xe0bbc76b0609d7802ae2d33e3f1a1d855e44421627aee50fb9c0dd283c	stake_test1uzauw6cxp8tcq2hz6vlr7xsas40ygssky7hw2raecrwjs0qrs4k69	\N
22	\\xe008a797946f83f7f33b65e9fe67564ae80dcc195dbf447ea5b2d478cd	stake_test1uqy209u5d7pl0uemvh5lue6kft5qmnqetkl5gl49kt283ngrn5t2a	\N
18	\\xe00cd5d91fdbe930295e901a772ce1a8bfd8a24258a6802f0173bdb7b2	stake_test1uqxdtkglm05nq227jqd8wt8p4zla3gjztzngqtcpww7m0vs5zk3uj	\N
12	\\xe0711c029fc12761f7443020fe76420694b3ef9cfdf8cd2be5e2e60b53	stake_test1upc3cq5lcynkra6yxqs0uajzq62t8muulhuv62l9utnqk5cpnpw25	\N
14	\\xe0d9aa427be339577b173b185cf3c898647b1258ed9fbb7c385fbc0ec6	stake_test1urv65snmuvu4w7ch8vv9eu7gnpj8kyjcak0mklpct77qa3s094ak0	\N
16	\\xe0d93cd302a5d65efebda8ecbe17fc238d9c8d016b49d05ba579f1cdd5	stake_test1urvne5cz5ht9al4a4rktu9luywxeergpddyaqka908cum4g8rnctr	\N
17	\\xe0f6825fae490cb8d3fad59a20cb0cf2a41472e3634801200de2da2397	stake_test1urmgyhawfyxt35l66kdzpjcv72jpguhrvdyqzgqdutdz89cv7scn4	\N
13	\\xe0b9936631cfa61538dbd4e15a7274256f09faa4d4c6e4a44b4119cc17	stake_test1uzuexe33e7np2wxm6ns45un5y4hsn74y6nrwffztgyvuc9cvsh0wt	\N
21	\\xe00b9ccca448ba7506f4a64e41bb1fb74c2ba438d97d991d9228f18c60	stake_test1uq9een9yfza82ph55e8yrwclkaxzhfpcm97ej8vj9rccccqvap48q	\N
47	\\xe01bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	stake_test1uqdlrcfc7tuta27fv0y5es5wark5kst5gcql9md02zepalg9yxxuz	\N
49	\\xe09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j	\N
50	\\xe07d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	stake_test1up73dx2qeg7gv59739gpmycmxzffyqk3ha2ctmh9ghdgneqmy000q	\N
52	\\xe072263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	stake_test1upezv0agh8cq09rt33ardnh8pdstd3lwpa5s64g2pne0uqgcygw6k	\N
53	\\xe08de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	stake_test1uzx79ge8d7gkx27vu3k9xgj9zlra0fvat5d5lxcnzm9n7hc8yk6td	\N
54	\\xe04f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	stake_test1up85ec98csnkgus5dw3x8u25mlkgu8m63hvw650ukldv04q6rf54k	\N
55	\\xe00ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	stake_test1uq8lxxfr92332xgqp66eenhpw7z04q09czgjf6uvnku20fq023mfy	\N
56	\\xe0ce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	stake_test1ur89gkdpkj42jwy3smuznfxcjdas0jz64xtckt9s8kz8h3gj4h8zv	\N
62	\\xe00caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	stake_test1uqx27cxdgy03z945xdnvv4f0dgjwevas6mrk5c5a4mgydwq63nkrv	\N
46	\\xe0f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	stake_test1urc4mvzl2cp4gedl3yq2px7659krmzuzgnl2dpjjgsydmqqxgamj7	\N
64	\\xe0f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	stake_test1urcqjef42euycw37mup524mf4j5wqlwylwwm9wzjp4v42ksjgsgcy	\N
48	\\xe0e0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	\N
45	\\xe0a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	\N
\.


--
-- Data for Name: stake_deregistration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_deregistration (id, addr_id, cert_index, epoch_no, tx_id, redeemer_id) FROM stdin;
1	46	0	4	112	\N
\.


--
-- Data for Name: stake_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_registration (id, addr_id, cert_index, epoch_no, tx_id) FROM stdin;
1	9	0	0	34
2	6	2	0	34
3	1	4	0	34
4	11	6	0	34
5	4	8	0	34
6	7	10	0	34
7	8	12	0	34
8	3	14	0	34
9	2	16	0	34
10	5	18	0	34
11	10	20	0	34
12	15	0	0	36
13	20	0	0	41
14	19	0	0	46
15	22	0	0	51
16	18	0	0	56
17	12	0	0	61
18	14	0	0	66
19	16	0	0	71
20	17	0	0	78
21	13	0	0	85
22	21	0	1	92
23	46	0	4	111
24	52	0	5	133
25	53	2	5	133
26	54	4	5	133
27	55	6	5	133
28	56	8	5	133
29	46	0	5	151
30	64	0	9	253
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
1	\\x2863622efb9136168b65a42a84f9a95d34343dfa0faba7d722568663d0777dfe	1	0	910909092	0	0	0	\N	\N	t	0
2	\\xa8f5582beaea72ddb687b5b895c4bae3c4d74457d18b33c2105cc530bba53e64	1	0	910909092	0	0	0	\N	\N	t	0
3	\\xde70eae8010643804e3e269e101390e4e0923cdb688f821a794a9dc6fa18dee5	1	0	910909092	0	0	0	\N	\N	t	0
4	\\x603bf9a26ef6aa7d58962a62c8a009d3b48cc5c859504ad11775c6fe3e35195e	1	0	910909092	0	0	0	\N	\N	t	0
5	\\x55deef18e8ba0a7bf10616bf764541a22a1372ca78be14d4e463076c9f4738dc	1	0	910909092	0	0	0	\N	\N	t	0
6	\\x34624c99bf1319f11129dc26d975d5aaa413a76d9f0bc1a2666a31f824165029	1	0	910909092	0	0	0	\N	\N	t	0
7	\\xff9acba8729d1fe25a612d33f6b91ffd2e8a5172373763b3899631693629318d	1	0	910909092	0	0	0	\N	\N	t	0
8	\\x4de8618ede43ccb995c85ebe0d035be956cfb0590ea7f648c66de299a360944c	1	0	910909092	0	0	0	\N	\N	t	0
9	\\x8fd94686cba8a282f2dd3714f3e18487a38b8461093431a1b9fdaeec8b62d6cc	1	0	910909092	0	0	0	\N	\N	t	0
10	\\xddde5b827bb4d86a464d6a8e10dee7197ba52b77334c1a910ed1c643ae29b035	1	0	910909092	0	0	0	\N	\N	t	0
11	\\xe1ecae7f938100bec01594ae31fdf4b44bc9a3fedd38cd8e3418da1a8f4dbb8c	1	0	910909092	0	0	0	\N	\N	t	0
12	\\x03b83cae3a6453f23e55d62a3dbcbdd462eadf930b545b64e076f55a37662ef6	2	0	3681818181818181	0	0	0	\N	\N	t	0
13	\\x05f84bcc240b6212e27703f98621e1877b54f6412ba06dd1a82c67ee14c90b9e	2	0	3681818181818181	0	0	0	\N	\N	t	0
14	\\x1570a20620563b088640b98f7acd79a3d195019c5f0878d2c5198b042c663e5d	2	0	3681818181818181	0	0	0	\N	\N	t	0
15	\\x18361eb95aa1fd8179900f1a56338a8a9a1e0509bcf1f395e637497c4e125669	2	0	3681818181818181	0	0	0	\N	\N	t	0
16	\\x4b05ba886118ee6381351b9ca0e1b8a98b770905c04c0015deb6dd88e93c6074	2	0	3681818181818181	0	0	0	\N	\N	t	0
17	\\x5440a78a37f54d06947becea94fa85871270b3a8209c4a2942c1ce6f7252ff5d	2	0	3681818181818181	0	0	0	\N	\N	t	0
18	\\x6a9fc545d020543994424457331c3b7357f1a65e12782949ccd24640df7a21a7	2	0	3681818181818181	0	0	0	\N	\N	t	0
19	\\x74fb318d5b5a445fc979c9b60ba9a168943dabc7a714ab0e3f74e633104498a4	2	0	3681818181818190	0	0	0	\N	\N	t	0
20	\\x844f422f38986ef2dbd5224391978b4e437fb7fee52b2df37c9fd34fe547c3de	2	0	3681818181818181	0	0	0	\N	\N	t	0
21	\\x85f7158acb8ba2bded76d9cea4819b419d2f67ddf45cbfafe629b4ba5620aadf	2	0	3681818181818181	0	0	0	\N	\N	t	0
22	\\x925447be90fa7fcea208edf492a77c406e29ef8f4ffda5d6bd5764d5aeffe7ba	2	0	3681818181818190	0	0	0	\N	\N	t	0
23	\\xaa93e798d7f3fad24dc827fa29c92508753e138d5dffd6ab11f68f88420060eb	2	0	3681818181818181	0	0	0	\N	\N	t	0
24	\\xab9d295bdf161d1643a168d6d655f0b077fdc468657cfbbda366fe647f4c26b6	2	0	3681818181818181	0	0	0	\N	\N	t	0
25	\\xc4e88255c35c1f5d67588d4fda345dc03eb0e894b1fa959fbc981fa5ee90e8a9	2	0	3681818181818181	0	0	0	\N	\N	t	0
26	\\xc666934433db2c5ef963b2b66fb98ab7be6eaca763a076e3661838e4ba72e6f7	2	0	3681818181818181	0	0	0	\N	\N	t	0
27	\\xc7243c1a45252d8f3939fd6f46e9d4b56533b888cd757738dbf751be32a8d0d7	2	0	3681818181818181	0	0	0	\N	\N	t	0
28	\\xcebb77407ac0cec1266db005ea0bb2c443a65d887a69d57d26ca89c5c3a2b99d	2	0	3681818181818181	0	0	0	\N	\N	t	0
29	\\xdf9ec9732a49ad20f0c25ee26d58fe2f585b982f800de9fc987fdee033c20099	2	0	3681818181818181	0	0	0	\N	\N	t	0
30	\\xe867a0d37b0ed51245c3f7bbbc1fe801930cb06b2b2a514c4442abf617e733c4	2	0	3681818181818181	0	0	0	\N	\N	t	0
31	\\xf4a945d28950580858ba9b25901554103d431f6a1003e85cf12642226dccb6bf	2	0	3681818181818181	0	0	0	\N	\N	t	0
32	\\xfbcdbe26abcd7d68ad924a97ab6b049563589739ba660ecc670627961577193c	2	0	3681818181818181	0	0	0	\N	\N	t	0
33	\\xff2d4fe79d4d852727326c334360d20a103c08afacd3192becb58323c9067195	2	0	3681818181818181	0	0	0	\N	\N	t	0
34	\\x5368656c6c65792047656e65736973205374616b696e67205478204861736820	2	0	0	0	0	0	\N	\N	t	0
35	\\xa5cca4eaf467927682f1a284106a02b76b50b879a8237a3b9d2d3ad38fdfd990	3	0	3681818181651228	166953	0	263	\N	\N	t	0
36	\\x0df644d5ec462ecc342377558869a3df64f10bc2dd149d12afcbbceb2442196b	4	0	3681817681473231	177997	0	339	\N	5000000	t	0
37	\\xd87297df3c196019ff7d77d4ca407870d51155a551650b387a1def80449efb63	8	0	3681817681293914	179317	0	369	\N	5000000	t	0
38	\\x9036b0ee3a3f05a26e8dcf8572101ed8e92e8a0beb324692513b8d8b6293766c	9	0	3681818181637632	180549	0	397	\N	5000000	t	0
39	\\x23d1b7394a783da8b76ddecef3c1b9d4974f9b8e781d1c6c737fff9c887b52d5	12	0	3681818181443619	194013	0	653	\N	500000	t	0
40	\\x0a1236f00789fd5f55a53fe0185bc1a65ece04b5688055236081e312953d5064	13	0	3681817681126961	166953	0	263	\N	\N	t	0
41	\\x5b03f53471f352038650d87470e4c8c11fe1d5f27dca3bfe57ff1ce144f3d5ec	17	0	3681817080948964	177997	0	339	\N	5000000	t	0
42	\\xdb7254ab4e416d34533073d5004755e372ff006fc02c710a4d7667c997a3312d	19	0	3681817080769647	179317	0	369	\N	5000000	t	0
43	\\x54aa0600cc2d903fed813feff04be3b09d1b2623bbee5ebb0d486252d31117e4	21	0	3681818181637632	180549	0	397	\N	5000000	t	0
44	\\x1c2b538b77e05a7883023d14886ef3d32e21fba82a90633b4a242f4a9d431b81	22	0	3681818181446391	191241	0	590	\N	500000	t	0
45	\\x0d2dad97fd0174bd7ff147faa482d4f89235bd52615eb647bbd98532c39a4493	26	0	3681817080602694	166953	0	263	\N	\N	t	0
46	\\xe0c7d9ce62ec2010f330fe8a90a4755425ca1c518ffe6b45e7e31994850f2cb5	30	0	3681816880424697	177997	0	339	\N	5000000	t	0
47	\\x1582bf7066b0cc7c01ae2e35248f146a71d48ef73a927341671d299ffbcce12b	34	0	3681816880245380	179317	0	369	\N	5000000	t	0
48	\\x5a4507a9377aba54b409c33b170a4519549fad826475594a02f54a92fc03b9b5	37	0	3681818181637632	180549	0	397	\N	5000000	t	0
49	\\x2f8af8da63bf487459fd8b9f05a7699e96d6402e7d232f2b788e333b82db546f	38	0	3681818181443619	194013	0	653	\N	500000	t	0
50	\\x76fc40f8e8bd29dea2d375e62b10fb5585f7a79d94be3616cc8926c422d47707	39	0	3681816880078427	166953	0	263	\N	\N	t	0
51	\\xf135d4e91e0952cb8b84ec075b2faad36f8d72eb2a06ea015b72552b380e8d76	40	0	3681816379900430	177997	0	339	\N	5000000	t	0
52	\\xfa18b61707868bdac732481e7ae05ef3293041c16e770441e025f19a8a1e60ef	41	0	3681816379721113	179317	0	369	\N	5000000	t	0
53	\\x681ee7b58343aa7ba7bd56f1bee478ed9cfccf4d1aecfac2158b20f7ca23f22c	43	0	3681818181637632	180549	0	397	\N	5000000	t	0
54	\\x2da31a67769d0ab39899d06b03e4f44685a08a550fc79d10a9305e75221315b0	44	0	3681818181443619	194013	0	653	\N	500000	t	0
55	\\xab77b8dba3bf8912b5821acb71ff286690072efbd9ed5c38e3e3360f169d6f96	46	0	3681816379554160	166953	0	263	\N	\N	t	0
56	\\xb3801a8fc854ae9f864f3968e96e6089d0490ffe3c6dbc66646d9efd6a8a6941	48	0	3681815879376163	177997	0	339	\N	5000000	t	0
57	\\x6273dde14a5b31a957a41d2e85e835fc6bd8a588b43307148c0a94b234f4a1d0	50	0	3681815879196846	179317	0	369	\N	5000000	t	0
58	\\x2d7cbea7474e093b7be6474fc91473d67f4d4aed696decf18e85b70eae9930b7	52	0	3681818181637632	180549	0	397	\N	5000000	t	0
59	\\xcc8977fb93a770f17a6c134b26f20c5de76e9e6d7d98e9c251f6da221fa96ab4	54	0	3681818181443619	194013	0	653	\N	500000	t	0
60	\\x813500e3898b887db8c22b679d2fa1dd51962224d9a75a8f43db1b40673634b9	56	0	3681815879029893	166953	0	263	\N	\N	t	0
61	\\x2f166ee13b28856ff468d79b5947d79505a2e852386171aab21cb82f494b322f	57	0	3681815378851896	177997	0	339	\N	5000000	t	0
62	\\x8f57f20c8024217447703c83c5cab4e49629509fb2a7461edbae6c2448216228	61	0	3681815378672579	179317	0	369	\N	5000000	t	0
63	\\xb4e3b7f5f27a039c03c11a99401aaa8814ad4ba59031dac18fe390c337aceb91	62	0	3681818181637632	180549	0	397	\N	5000000	t	0
64	\\x4be23e0f77d479abf807ec6b17e3709d1fb00a73aaeaffc64d98072cac07de99	63	0	3681818181443619	194013	0	653	\N	500000	t	0
65	\\xd20d77120ca01b96aae2b3a43f4fc1e4d61d27fce3bba1dd9082e214ec8b56a1	64	0	3681815378505626	166953	0	263	\N	\N	t	0
66	\\x4dace78ecd0868e6ad07965adfaab8361d0fc8a311fc4f2236e227aa0f5389d2	65	0	3681814878327629	177997	0	339	\N	5000000	t	0
67	\\x2ab479f67c1f90156a329e8a50f458f5ac37b737b858abf23683b497489f3b48	67	0	3681814878148312	179317	0	369	\N	5000000	t	0
68	\\x8c10b3aa957839973d748e1dc562b54d9aca52550fe3e2f1b3c06eca4b017268	68	0	3681818181637632	180549	0	397	\N	5000000	t	0
69	\\xb54c1f77fc3a25a2ad497f63408af67c4382ddf2f68a30772899fbdff69b1046	69	0	3681818181443619	194013	0	653	\N	500000	t	0
70	\\x39c7ec59e51a517116b1ad572ad29a353a95bb9f7f0ac7445402220a819cf0d2	71	0	3681814877981359	166953	0	263	\N	\N	t	0
71	\\xa3077bb6c6529a1d199af1aaca0afb5983886f10f62dd292042b1aad66b454cf	72	0	3681814577803362	177997	0	339	\N	5000000	t	0
72	\\x5bf348cf0b85f8e6f7deabcf662ffb9a70c338f255357c57cb554725d0693425	73	0	3681814577624045	179317	0	369	\N	5000000	t	0
73	\\x123257ad272d95357ec455559f3a8bbed9d9f355658068f8c8e8b80de50ddc9b	76	0	3681818181637632	180549	0	397	\N	5000000	t	0
74	\\x2a7d6e412745282874e826defcfb0d402ea66b47f8c34b692d62d7a6632b994a	77	0	3681818181446391	191241	0	590	\N	500000	t	0
75	\\x030d488c14d3936d64a832cafd3b11c91f48f12ae6dd0a6fc0c5570003d1a7eb	78	0	3681818181265842	180549	0	397	\N	5000000	t	0
76	\\x91a757dd882097d00b5ca93a896ee0f71285dfe1719aa2db4efc1fccc9dc695f	80	0	3681814577439800	184245	0	439	\N	500000	t	0
77	\\x08e62debc04137c6bce6d8c98a8fb6d1a9cc2e479d0b32fde22ad7f503d0dff0	82	0	3681814577272847	166953	0	263	\N	\N	t	0
78	\\x45d2344e932dc6b0b8fcd8e0aff7a9c9dc26ad547f3a0656518a48978b49dce7	83	0	3681814277094850	177997	0	339	\N	5000000	t	0
79	\\xb424ae8fd6a20d204c5ad085c8aedb4f1d19b2265c6f0d05acd673d66a68e1ef	84	0	3681814276915533	179317	0	369	\N	5000000	t	0
80	\\x16acd30d5b7c5108c682e8b4e988b7e151e3a6385a40e49558f1e2341a6c0c1c	89	0	3681818181637632	180549	0	397	\N	5000000	t	0
81	\\x0ab0316e99f98d5765a910417a5cbf9ca19fba5efdf85822961eef2a9c10813e	90	0	3681818181446391	191241	0	590	\N	500000	t	0
82	\\xb6001f52f0a4ae1c44b66336a6f7e92b078f00a7f28a9ee186238231e62be8c6	91	0	3681818181265842	180549	0	397	\N	5000000	t	0
83	\\x02d9398c1d1eaf581b6f72d01b605b2924af39d35dca702d7737118b016da7ed	93	0	3681814276731288	184245	0	439	\N	500000	t	0
84	\\x97b0b3d13ca3a500e116c5f76218c660d36e63deccb18ded274c58e777f56498	96	0	3681814276564335	166953	0	263	\N	\N	t	0
85	\\x0d3f7e2d3992f10e327b4c01e495cb21ff52e33e8977c85ba7ac2cad3c9922fd	98	0	3681813776386338	177997	0	339	\N	5000000	t	0
86	\\xfdd0aac0707cc2ff4f1f0217abb4a656469ec20ec27af16452fc37879f9a4857	100	0	3681813776207021	179317	0	369	\N	5000000	t	0
87	\\x2c94cb990468e46ce4dc472f9e77b7a1cb67459af60c1740786f735854f5bb70	105	0	3681818181637632	180549	0	397	\N	5000000	t	0
88	\\x86ec0d34b3e6fde7a866c601e1ba81d746d686faa29c95561a6ecff38a1fcdfc	107	0	3681818181443575	194057	0	654	\N	500000	t	0
89	\\x078cb67e9d8a7c50b129f483a8714bb812aa5a58398f504e09adc67e9e1cf57a	108	0	3681818181263026	180549	0	397	\N	5000000	t	0
90	\\x68cfe33c54d871fbae8a1c43626d859dd22a5bceb8e63dfc57797e1568d10bbb	110	0	3681813776022776	184245	0	439	\N	500000	t	0
91	\\x604df14c19bfb9ab1482ca931d1be07d1d33eb0e37090e332bc3fb750b5904a6	113	0	3681813775855823	166953	0	263	\N	\N	t	0
92	\\x1f2daafc7e39bc2d4263a6bfd7067b4dd0af1b9f94ef253dc53d447f6dc4ecf4	114	0	3681813275677826	177997	0	339	\N	5000000	t	0
93	\\x02c93d13f9f094307d5efcf9b474f8364f6e60133b19d1ba47c9445f08a7005b	116	0	3681813275498509	179317	0	369	\N	5000000	t	0
94	\\xe4fc044048e13c9cc30321ea577791534922b900676a583df671e93b345a9e52	118	0	3681818181637641	180549	0	397	\N	5000000	t	0
95	\\x614126ae0e1f5e4a94e2c88f851dff8b04e931ce3f2f42050c19d03626169ae5	120	0	3681818181443584	194057	0	654	\N	500000	t	0
96	\\x5d60ef34239e4163ddcccfb2865aaf4ad007ba278fe1136588784f2b8238d27a	121	0	3681818181263035	180549	0	397	\N	5000000	t	0
97	\\x0c1cb6a2c8cdb551c85e92ee53c196901b2f5255198f6eb05b40dbe86906e5af	124	0	3681813275314264	184245	0	439	\N	500000	t	0
98	\\xcb05c793b1d8375f4280259bbd1e030b7df6ca3b73ae1bb6fb2fd2fa08ff7f9e	128	0	3681818181650832	167349	0	272	\N	\N	t	0
99	\\x6a09b5d02cdc5983113734327f94852942d56adb7981c5a29e5c36b44450ed5e	129	0	99828910	171090	0	350	\N	\N	t	14
100	\\x6dcdb643a311a5918d05e0fa24f7c0aca448f49b8189e87d44153df964ea9c5a	131	0	3681818081484759	166073	0	243	\N	\N	t	0
101	\\xdf5ca83263be731054e3f5d6f3dbd1808bac4fd2b1f0016d88c7c4fd39636be1	133	0	3681817981314374	170385	0	341	\N	\N	t	0
102	\\x3262f763fe025be81c0cbc23e30ac646d30580f90a561b450ccc1a3908a5303f	134	0	3681817881146585	167789	0	282	\N	\N	t	0
103	\\xd3595936579bbdf87dd4eaf06052c5c71bc845a38891e57e07a622d77b201f29	138	0	3681817780979940	166645	0	256	\N	\N	t	0
104	\\x7d04a5da01ebac8750f0d2cbd59787310737ffeb93f81b8e1228f74e938d701f	139	0	3681817680717067	262873	0	2443	\N	\N	t	0
105	\\x517a449e71145238978d431712830feceb0b37027c1f6edab016a331071ba533	140	0	3681817580550950	166117	0	244	\N	\N	t	0
106	\\x1e6d0419614ce6870095930bb1573a307a4f57348d8773f293cbee73a5fee730	142	0	3681817580223603	327347	0	2613	\N	\N	t	2197
107	\\xfe168036a49d0f05301052df8d8ca993985d074455e4f654667334eb34942586	143	0	3681818181642252	175929	0	467	\N	\N	t	0
108	\\x37fd6564fcf86e9c1a9ab41381ab5b50192853122093720fafdfe918d4134486	144	0	3681813275134639	179625	0	551	\N	\N	t	0
109	\\x06ef27040dcafbc6deff7f62d5511cf106427e5bcddf79f0ba177d551cca6c91	145	0	4999999767575	232425	0	1751	\N	\N	t	0
110	\\x9198c2ed20c0afa739eded0415162d5168507a39ab8b6547874ac6a2cd4cccb8	146	0	4999989582758	184817	0	669	\N	\N	t	0
111	\\x6e354b59b510c6dbc5ae4aa34ee2c6b5e4dcbcd8440471ac9acc2bf81c7abe81	447	0	4999979400405	182353	0	608	\N	5633	t	0
112	\\x454ddc1483d2f2f084c088b7e06c72cb1413e691373566d05f1113bccd49e081	448	0	4999978228832	171573	0	363	\N	5648	t	0
113	\\xe38556577a000f5458a25078aa5ad53ca9bd15128e054bba9ba7523d92d0b479	450	0	4999977993987	234845	0	1700	\N	5653	t	0
114	\\x68031ebd59f5f2e54cb2c3628659b401e4b0346449e5db6f994d4d0638519463	454	0	4999977819554	174433	0	428	\N	5743	t	0
115	\\xc1e18c85803c13a7a999a033023bd121c194703f6b967d6479fab34c28492935	459	0	4999957648553	171001	0	350	\N	5784	t	0
116	\\xa70af33a873f945143ca0d613fcfbf6fc637f237b59e99d4488d06d6488ff825	463	0	4999937474472	174081	0	319	\N	5807	t	0
117	\\x8a2b5d25ab0b414ed48aa78d5bb2023a4771642cef2cd3b53f97f054a0b94b5b	467	0	19826843	173157	0	399	\N	5847	t	0
118	\\xca219004ff99c71f58b33ed2aa94e2af7dc530d7e5931fbdfdec03c8fa0ffe92	471	0	4999937281647	192825	0	745	\N	5883	t	0
119	\\x86128a48eb5b2115338e4275ce721bf1245d941e1ea6355accd6392457c54f0c	475	0	4999937085390	196257	0	823	\N	5918	t	0
120	\\xff132ec30714d2c078bd9cad275fb554e9240c8cebe43c3588289633bc5343d7	479	0	4999936910473	174917	0	338	\N	5953	t	0
121	\\xdef99f636921f4be2999d41dc74fa86724eb632cad1e0e1832a1949a460360d5	483	0	4999936717648	192825	0	745	\N	6004	t	0
122	\\x7bda68c06ec1c8575f1570373bc37f5098fe3fddda5e13bb0b7f47412209b553	487	0	9826843	173157	0	298	\N	6047	t	0
123	\\xff7cf54f53be3f598b231e86a61761d02936012c5843c96a492e723edb13058d	491	0	4999936350082	194409	0	781	\N	6122	t	0
124	\\xd27994baf9773f1012fdac567ead407989cc7dee5f75215cabdde204f39125a9	496	0	9824995	175005	0	340	\N	6192	t	0
125	\\x851fff391ddc558bc0d7cdfb303bcc4efa5833b76f08a151837e3ef57ac26e37	500	0	9651838	173157	0	298	\N	6241	t	0
126	\\xd66c33d3f095901f4d99ce9683dc364c94ec87cc9c3aee00614f5140232b387d	506	0	4999935796335	205585	0	1136	\N	6273	t	0
127	\\x8a94ca347885c3845e5f077a0d5d46d99e2bac45f71991d928239949ab42a316	510	0	4999935616094	180241	0	560	\N	6312	t	0
128	\\x05488f627d88fec1b92e7e4a107fa6c54981c7584538b5e6843a11c9d86dd3dc	514	0	4999935424985	191109	0	807	\N	6365	t	0
129	\\xe091c349b295eeb7e4b2f5c4c9252741c08c424aa52fd1653a9ad4a2e20cfa4b	518	0	4999925235988	188997	0	759	\N	6381	t	0
130	\\xf972bbefa08f8a62dc33e3b343ffc199cb69543ef972705211873ba4c6ab0db1	523	0	19811047	188953	0	758	\N	6397	t	0
131	\\x393541c3c10dad2eca37ca3ef2aabe5f54efe513905246f7e83a79eedc4346ad	527	0	4999934867806	179229	0	537	\N	6418	t	0
132	\\x0bb819aca09feae5ad550f7c23b1dfd4872ea3b386b7e3b8b02bfdece4cf7b17	533	0	4999934699401	168405	0	291	\N	6458	t	0
133	\\x5a0dd5599dc763d4f1c5425987416a72df9c859c418b4ae6217269b0cfe2fb9a	537	0	999675351	324649	0	3846	\N	6554	t	0
134	\\x610d90fa0ff3132acfbe5d170d47e90413b6e2d74dba032cfe931bd059f4138e	541	0	999414590	260761	0	2394	\N	6616	t	0
135	\\xbc7a51a70bf52b5dd51e9e55173693e933a780c8ab6e9184e5370e5e165d7085	545	0	499375158	201757	0	1049	\N	6679	t	0
136	\\xb90968ebac0cb3a9839310aaacbbab8ea33829d6749e300391ebc638b0f192ce	550	0	4998934521844	177557	0	499	\N	6731	t	0
137	\\x05746349eb7a53dd7741972a34c2e106686f0ce12dd0bf3747846f5beca56f77	555	0	2827019	172981	0	395	\N	6770	t	0
138	\\x2e282b981330609e3d78c472e24f48c42a081590417ed82c059c9a6692aa84b9	559	0	4998931337995	183849	0	642	\N	6820	t	0
139	\\x4350414c8eb37def2f75daeb7c365a4c008a629735343b95b60bc0ef3a4a660f	563	0	2820947	179053	0	533	\N	6884	t	0
140	\\x132c1db1b78dab10a9bf0bbbd53fdc564b35f47f3ab6b6aae32cf113cde5619d	568	0	4998928169590	168405	0	291	\N	6914	t	0
141	\\x2e4f01b1c0f8ae46595f843cf6d769475ac25fd985d201d481193907bff517b8	569	0	0	5000000	0	2436	\N	\N	f	1893
142	\\x9b715a86813f39902d2cbebfd79f2382a42023f5bf9dec5daf74f9c67c5e893d	571	0	4998928645807	171749	0	367	\N	6942	t	0
143	\\x837a1b5f8d6016fd887b3305f5e2d9767a2908e868bd21d35b4603f2e997472b	571	1	4998928475642	170165	0	331	\N	6942	t	0
144	\\x771ff32f91b5e52f278d84df04c8f73d7bdc3ede0feae39380a3d1663e03e7f5	575	0	1999571016704	168405	0	291	\N	6998	t	0
145	\\xe4546813502e684474b990df762afc54c98a55d03112607de6315e2db1aea7fc	576	0	1999570498807	517897	0	8234	\N	7012	t	0
146	\\x0b67a225b650f82bb60853b8eba1e997ed3d9935866a44344554cf0987fdc247	577	0	179474447	525553	0	8408	\N	7067	t	0
147	\\xcbc241cba85f0f01510a64fb45dacdcc46f50917e54b0534db5e771d9ae49085	581	0	33227402127	170297	0	334	\N	7095	t	0
148	\\x83d567e99cd035d5c54913acfd12c559481bc86af9c0a5ac566730ecefaee64e	586	0	33227403975	168449	0	292	\N	7136	t	0
149	\\xc59fc08de7285c7bee028831d0f3ddeefc871c774f2fab4b0275983f191a10fe	587	0	4998925679801	270793	0	2618	\N	7142	t	0
150	\\xefddac0b78d158fbf0d2f56b3ce1124dc2b42db8a15313319f6500ad92df6feb	592	0	4998921282585	168009	0	282	\N	7193	t	0
151	\\x43729b7b84b6db818c9305acb2d9a1ca0c70f99c32f79156dee4677b9b176e4e	599	0	4049010	180197	0	559	\N	7233	t	0
152	\\xe79c5d5862aed2492b7fbcb4e5a364fb22f06c17e0de5e325ec8202a1171019e	723	0	4998922161606	169989	0	327	\N	8453	t	0
153	\\x61849f063778cb1963fa1ae2a87f8e2752ba4456f2cb230d8842c014514c902b	723	1	4998916993201	168405	0	291	\N	8453	t	0
154	\\x56069ee0e7715a59efb0e956f96e8501136069bd0d8d297ff9b1d58f4efd0499	723	2	4998916823212	169989	0	327	\N	8453	t	0
155	\\xf8058d759b066e2c0d57eadad2815944b347d63ee2106fc545b50e2994840525	723	3	9830187	169813	0	323	\N	8453	t	0
156	\\xcd3fd111f8a8e29c4563db1beaa0ada11e3adfd4f3f456f5d8dd9129ae973ea6	723	4	4998916483410	169989	0	327	\N	8453	t	0
157	\\x14b042ed95fb93efdf8e01c47f946175a366f3f05cb6bf0102f758123b095e0c	723	5	9830187	169813	0	323	\N	8453	t	0
158	\\x15fd6c192b0fde625d3e2ed48606ce8af511b07bb55f51a3f4ac9de9499a1922	723	6	4998911315005	168405	0	291	\N	8453	t	0
159	\\x1439b27e65583ba878318994d15f89a7aaa4b1005b9e7315c7de4cc0ae8c14fd	723	7	4998906146600	168405	0	291	\N	8453	t	0
160	\\x21b83c04d42bb62198fad79b8a6177d62992afc9f45caa443d178c81ecb9de61	723	8	9830187	169813	0	323	\N	8453	t	0
161	\\xd1f8ace7d88d4953b858ace27100686b84d3d93f7d46e2f940626e06887c0a73	723	9	9660374	169813	0	323	\N	8453	t	0
162	\\x895bb59d77c808c12de0d79e5e5927596f89a70c00b0925c0989cd1235e725c6	723	10	9320748	169813	0	323	\N	8453	t	0
163	\\xe18610d420e79c90a2c627f427e1d791aede04068cca5cbd25a763a7e8d026b6	723	11	9150935	169813	0	323	\N	8453	t	0
164	\\x3cc7cd74056b619f7df4d37faeb32f6429e77a23b956de989737955d2fcfb440	723	12	9830187	169813	0	323	\N	8453	t	0
165	\\xe30f839373c10365012f688a8f80de4a428db18cd19ec9b7eec20870c67575dc	723	13	4998900978195	168405	0	291	\N	8453	t	0
166	\\x8ac7924465ad0e6ef51edf8be5699504d4f149495251f4b19045251595ecd300	723	14	9830187	169813	0	323	\N	8453	t	0
167	\\xd9d0cf24f067e3408c08f7c86169f43df1acdf9960e231a7d5083914ca24f255	723	15	4998899959141	169989	0	327	\N	8453	t	0
168	\\x84dce08113e567ae04883dc349995eee31918a9d18467208d740eac0fd37e23d	723	16	9660374	169813	0	323	\N	8453	t	0
169	\\xe1a62e61aa84ad132318c9bddf013ec1d46db5d48f607d690bbcee7ce51f08d5	723	17	4998894790736	168405	0	291	\N	8453	t	0
170	\\xa1e8fa3845c273d0a8601d31a10c4613153323646c1a494cb8c7978ce1453f89	723	18	9660374	169813	0	323	\N	8453	t	0
171	\\xbcaf47bb892e89cb6f35410d6f115548167a5d28d055732684b43a73ab9d23b0	723	19	9490561	169813	0	323	\N	8453	t	0
172	\\xfbd341ae633bb721f3c595311da8d872444a01480dc971e0f08a3eec5e590d6f	723	20	9830187	169813	0	323	\N	8453	t	0
173	\\x17fa6ac2995665e3ed81999fbfbc7404c631cf48da746a12d74bd6e240a1e5c5	723	21	9830187	169813	0	323	\N	8453	t	0
174	\\x6aefae9ce5aacf5c5a876967aba75f205b480fa5f80c10ab08ad2e95931d6732	723	22	4998894450934	169989	0	327	\N	8453	t	0
175	\\xabbfc2be3d34038b09d675042fdadfe6f6871fd6d3d03173f78062c037e054da	723	23	9150935	169813	0	323	\N	8453	t	0
176	\\x2cce3b14f25b357a5c48958f3387cd8d692e3716fea0954f255a366f93648fc1	723	24	8981122	169813	0	323	\N	8453	t	0
177	\\xbbe1b99d4af2ea0b4ab38c5ead1d99c84e5361e76bcf885b8c85d16c16527735	723	25	9830187	169813	0	323	\N	8453	t	0
178	\\x3d7f13952a898fe80d51f7482b3eaef5ff549ee4802c6fbb7c94a05f081c36df	723	26	9830187	169813	0	323	\N	8453	t	0
179	\\x3013daa3880df39de75b8bded40c9ff131512da6df21e891d1cc334e491ac075	723	27	9660374	169813	0	323	\N	8453	t	0
180	\\x58dd34d7209e0cfb00315f6d4a02ac1a89217585bee423c2a453bdcdbf60e44c	723	28	4998889282529	168405	0	291	\N	8453	t	0
181	\\xaedf443a102b7bbb363ce89874fe6e316c026d847ee9dbc6a4b985dbef581d08	723	29	9830187	169813	0	323	\N	8453	t	0
182	\\x2a4d7c5dc9991e3b6746b4f2516254c72d39b2268ecbdcd2b4e5067712ad4601	723	30	8641496	169813	0	323	\N	8453	t	0
183	\\xecdf0e8040874f77accccb9e493b18b45823048938b174c185ab27f967249554	723	31	9660374	169813	0	323	\N	8453	t	0
184	\\xd28de52f312c0066e3d19d896e2fe30a190a09702b619add0af568fba3513b68	723	32	9490561	169813	0	323	\N	8453	t	0
185	\\xc90bc6393069c4436a7d7db49df7179dcb946c8ca28e2d8505ebad379d0197f9	723	33	8471683	169813	0	323	\N	8453	t	0
186	\\x20b0f8e529e24bc47b71cc4f789f5a38d33280aabff792971533dc1a623bd122	723	34	8981122	169813	0	323	\N	8453	t	0
187	\\x4641e4eb2eeb0cae4c54c553ddaaec8236b3566fef95ff03097a89b60848b933	723	35	9830187	169813	0	323	\N	8453	t	0
188	\\x611b6dd70f8219959ebf6d00929d5eb6a2db1a2a93332efc91a7671f62c91d91	723	36	9830187	169813	0	323	\N	8453	t	0
189	\\xfe7b8f694c3d3a01caeeb75165ba4310b54767637688478a5f50002c4236d95d	723	37	7962244	169813	0	323	\N	8453	t	0
190	\\x2e8bad41e92b218504aa87df695a7bcee746dc40fb4368af99a66a6cd1c3b696	723	38	9660374	169813	0	323	\N	8453	t	0
191	\\xeb7c293cba898d7272f7eec8445877ad998057fb1d664baf7ddeb488cefc6db3	723	39	4998888942727	169989	0	327	\N	8453	t	0
192	\\xf3e802e4b493b4d4b53d4f48ca45aeddf910873e60307d4c2a25526c9137d6bb	723	40	9830187	169813	0	323	\N	8453	t	0
193	\\xea76ab8280b02cf0abda8ce7e489de3b47495c9911b136ccfcb6f8cb2c8488f4	723	41	8811309	169813	0	323	\N	8453	t	0
194	\\x1e3e1437281c3975775727bd1cfe8dc0c24e9bd5fcd6cc7254316d5e7d1bcd09	723	42	7792431	169813	0	323	\N	8453	t	0
195	\\x939810ba3b40ca5832fcd34555d64ca6d634c8ee4a9b761a0e29883b3be73425	723	43	9660374	169813	0	323	\N	8453	t	0
196	\\x7a14a0763aa69fd3f15db95955e112355d95e1ba15ff3a01847bb995edfa70b9	723	44	9830187	169813	0	323	\N	8453	t	0
197	\\xcbf56055743252dba6ec4aff99f2bf15f268958fc201f34bf81f0c929349c6e1	723	45	9320748	169813	0	323	\N	8453	t	0
198	\\x8f9eb41ce6c5db4a19f9bb24b9ce97c5dca8359efafab8168fd5343a768cf075	723	46	4998883774322	168405	0	291	\N	8453	t	0
199	\\xe5bd756ad15835ea962b2204375bea53310355369f11ba53bd928e78491f4af4	723	47	4998878605917	168405	0	291	\N	8453	t	0
200	\\xd1a8359afddd21fc81c19c3ee1907c9b446c47e934ac0862eceeecffd57bd58c	723	48	8641496	169813	0	323	\N	8453	t	0
201	\\x8eb3b2b1eb4576df962ccfd32f4588a8ccc7ee01be22b2398b6bbee550b4c8d6	723	49	10583278	171397	0	359	\N	8453	t	0
202	\\x44191f6b7eb0739f9bc728502ff6d2ffde38bdbdca45756270ab88ef69337239	723	50	10413465	169813	0	323	\N	8453	t	0
203	\\xfec7eb030c244f8e65f3d658e05e046980c1753ccc2a86caa1e48c853d167f60	723	51	9830187	169813	0	323	\N	8453	t	0
204	\\x692a49c96476200e158db239070f8d68f211dd409be657cce018acef8c56994b	723	52	9830187	169813	0	323	\N	8453	t	0
205	\\xe0dfa39d5b5368619c4bd7d57b5d3f5fd8d18a1eb1dffd28298d6c1cd206364b	723	53	4998873437512	168405	0	291	\N	8453	t	0
206	\\x1d54154dad8b1da5162179187e6daec541bed814d5bbfea9c0a42f69908058ac	723	54	4998868269107	168405	0	291	\N	8453	t	0
207	\\xee756f45575879b1e8eeda9f2ba173e54a0582f5eac1ee49847f1082e80f8d7f	723	55	9660374	169813	0	323	\N	8453	t	0
208	\\x6fc7705992a891c518d2601f45a8678e7a25722a150240800b41bb9f809a9bff	723	56	10243652	169813	0	323	\N	8453	t	0
209	\\x8a31040a06b295f14f3aa27cf9e2c7e21989371a928d52947725f42c3c451a5e	723	57	4998863100702	168405	0	291	\N	8453	t	0
210	\\xfa3547d7107061dc9823626c6235e530cc6b3b195ca4232d4cc2e51590a5e4ac	723	58	10073839	169813	0	323	\N	8453	t	0
211	\\x9c3bd1da1fc683393314fd9f3f28ccbca6b43996cd867473ecadb4a93cff7e3b	723	59	9150935	169813	0	323	\N	8453	t	0
212	\\x63bfa112683d5a89d3df44663b02c8c635b9765f5938d525fbad14bfd625d7e2	723	60	9830187	169813	0	323	\N	8453	t	0
213	\\x2f4711c0b399c137df8841756312a35b3284fcc11c59885ee517174027e3a1c6	723	61	9734213	169813	0	323	\N	8453	t	0
214	\\x810b1304f7425ee99dfb5531a17e5ba98e3da6f4b1b12290196fdbcdba35a86f	723	62	8715335	169813	0	323	\N	8453	t	0
215	\\x578337238c0c99fae388f85afb05e25c3944cccd49438528a57814eb543c4c71	723	63	9660374	169813	0	323	\N	8453	t	0
216	\\x55021eb65f3266bd6a0cdc5423baf15d5dd3dab3b0e3b4044a35f801d5f729bf	723	64	8545522	169813	0	323	\N	8453	t	0
217	\\x139bbee56cf4090d4a8702a0fe73c21e8ea6921edea8fd71fe1250614966ce66	723	65	9830187	169813	0	323	\N	8453	t	0
218	\\x543d4b64aaeda1cde4f1c5be03edc04e1ac7fcabc4ad14f04a71a90948f4f81f	723	66	9490561	169813	0	323	\N	8453	t	0
219	\\xebd86451412716f5a36a2a185984f14dce6349675742766bb1b0d15482056d3e	723	67	9830187	169813	0	323	\N	8453	t	0
220	\\x816df69fb63da9d847f46c99f6cdd89f0a8a085b5f34961d015a4d6796c581e7	723	68	9320748	169813	0	323	\N	8453	t	0
221	\\x439b645e34423da19f3da9b73bcb9eee2596e10ba5b8dd8ebb65abc3a1327244	723	69	9660374	169813	0	323	\N	8453	t	0
222	\\xed8f40bb5e24deea5f0c6bf50b304cdc67c61c9cec2f2db597583319bccb0e03	723	70	9150935	169813	0	323	\N	8453	t	0
223	\\xe17491bae12c280831156ca4f2b47c1b0712e0f52340215e52e64c68b75df302	723	71	9830187	169813	0	323	\N	8453	t	0
224	\\xd40114002e6994a014221cf407ed3d6e114aba389b1cd76b62727d7f3817aad6	723	72	4998857932297	168405	0	291	\N	8453	t	0
225	\\xb3172f2b09e8162297a33ca284e69ec0c2543673f89c733733a18ab6cac9a48e	723	73	4998852763892	168405	0	291	\N	8453	t	0
226	\\xdaee5ff0602440cc6424bd74283bda7f8865f127b67316e96acf531b1e4fa26a	723	74	9830187	169813	0	323	\N	8453	t	0
227	\\x4883ce00a6f0a0697de0c122141c0eba81b410d17962d6fbfc014b69dfcf02e9	723	75	4998847595487	168405	0	291	\N	8453	t	0
228	\\xdbbbda61e247200461c51c3305b7572db5224629707b42513ad1dfd9d2b55b19	723	76	9830187	169813	0	323	\N	8453	t	0
229	\\xeaa2f1e77d3d96f7258268973a77347a7176bb3c9ae3de49a1039acf0dee8525	723	77	9830187	169813	0	323	\N	8453	t	0
230	\\xee1e8f55928e0aeda1daa609963c886ca684f7aa4c4d6c9e99b78a8565e151c5	723	78	9830187	169813	0	323	\N	8453	t	0
231	\\xfacb077004967a535a9d8846415f8f8ea15061e6507804bbe22952985690d8b7	723	79	9830187	169813	0	323	\N	8453	t	0
232	\\x8a4e3f7feeca85ee77bd55096553eb93d82e417d40d27c055623844bb0378951	723	80	9490561	169813	0	323	\N	8453	t	0
233	\\x7fc85b995c4ea4281ffcd47982f4132cb5b0fc14a13723435ad6d6fc128cfae0	723	81	9150935	169813	0	323	\N	8453	t	0
234	\\xa643667f73752e590d4fc40ef4eb962783579cc06515567900e7cad701a07ee3	723	82	4998842427082	168405	0	291	\N	8453	t	0
235	\\xbbe4c9537c51bea65dd0294d26751f24ac5a092ac394fc568f380f490b3dbfa8	723	83	8811309	169813	0	323	\N	8453	t	0
236	\\xf80a699d4519f0c03ff61272c849f40df43bfd6514605009c7b9cfc07eae3121	723	84	9660374	169813	0	323	\N	8453	t	0
237	\\xeb9a6e8b0597ed7b8ba1137cf0dedd4c559918aaac742a0d9e916b59c58a3802	723	85	8981122	169813	0	323	\N	8453	t	0
238	\\x26d0caed5b4b9a4a2e14e91c859a2d194e700aafb9efaff82cec42ab6d19cd90	723	86	9660374	169813	0	323	\N	8453	t	0
239	\\x1775e04a62a9736a2cb0470f43b6641ea68d9d218a71c8e8a96defbfeb2e4375	723	87	8641496	169813	0	323	\N	8453	t	0
240	\\xa73e51108ced5d46eb50642841c28ea6a42f09a4a97d69866f76227846f5eb55	723	88	9830187	169813	0	323	\N	8453	t	0
241	\\x4d0486992383230db4b46e5870b132758e72b59dd9d9a57e1d9997f3d05174e3	723	89	9490561	169813	0	323	\N	8453	t	0
242	\\xfc5e2613a548a74ac844cff11a3d85210c2f4dcf77bff580a7e637f1f67a63de	723	90	8471683	169813	0	323	\N	8453	t	0
243	\\x2e4d956501014a1236509242dc2e0a7d36e755764ebd6b3888f9bb87469da46e	723	91	9830187	169813	0	323	\N	8453	t	0
244	\\x984e4be347499967e00f5b4090ab9320f38d5fbd7cc380c99f1eba7e757cb10a	723	92	8471683	169813	0	323	\N	8453	t	0
245	\\x71f444c8535f4c0aebc38fb510dddaa01f7aca561c7b4c2244e6e2b14635a67c	723	93	9150935	169813	0	323	\N	8453	t	0
246	\\xfae76fe6d740f1fa53a25d11d9d9c58a45ebc6c2de606d8ec221004047c06a15	723	94	4998837258677	168405	0	291	\N	8453	t	0
247	\\x646d618875cedabd500b7e0acbf8e5ae5b1249eedccbea67aad8f185b71d158d	723	95	8301870	169813	0	323	\N	8453	t	0
248	\\x61d0de28890d149c5713a5b2328aece258773807434f1fb04552719e8dd36c5b	723	96	8301870	169813	0	323	\N	8453	t	0
249	\\xe7057197be217b5203c6c321a4ce9c8ff2a7b608fe047da0ee29bf163374c96d	723	97	9490561	169813	0	323	\N	8453	t	0
250	\\x487721f11f58006dbd1e17ff5b5c857fab028ba493633d71352bed8e29d8c51a	723	98	8981122	169813	0	323	\N	8453	t	0
251	\\xce4afddcc98afd441e6d36897adbfd94bde135475c6150e5777063dbd76e89eb	723	99	4998832090272	168405	0	291	\N	8453	t	0
252	\\x34e2cf68be59ff831cc86fa037294f3b6cdf37a9f4d129752c864eb348605dd8	913	0	5891687959	174697	0	434	\N	10463	t	0
253	\\xf92e684b7f9233601be717de2c6e8e21dadb3f820517ce1cf1aa05b12b988611	919	0	5004793262771	251257	0	2178	\N	10493	t	0
254	\\x580eedd729c5b342679c3be6239d3b7afca03aeca5e71fa03fbe5036b81d5c1e	1115	0	1271289644136	174697	0	434	\N	12444	t	0
255	\\x8f868dd6127795d9e3826bff34b52023ab7e29b15418f2989ee6594383d84fd5	1115	1	1251198210102	168405	0	291	\N	12444	t	0
256	\\xc52e8aef9235750fb57ff6d739bf4e8dbea8ecfbc572fe294f266a35a0749707	1115	2	78199730252	168405	0	291	\N	12444	t	0
257	\\x2d619453da62d13fcbc891047f99304024ac71524c4a31216f6c7b0e2f833344	1115	3	312804424638	169989	0	327	\N	12444	t	0
258	\\x0faa0c8eb748083b034faaf5ed02cf89b5ad810353511108ec73a18264256131	1115	4	9830187	169813	0	323	\N	12444	t	0
259	\\x1be81c8424a7d37b25872e018e3bca9a914dba1594eb5982767053a82c970417	1115	5	1251193041697	168405	0	291	\N	12444	t	0
260	\\x56ab4b0f1be13446217c6f453889b5579e9c6986fc3f6072c16d0363a0e80246	1115	6	1271289474147	169989	0	327	\N	12444	t	0
261	\\x1a7619ba779d16216e0fc1eb1f7b64d583f35baa85d483215cac12a9f7bc2d7d	1115	7	312799256233	168405	0	291	\N	12444	t	0
262	\\x5fbdb3151c61d7087dac46f2da184b1fac24225e8b71be1814984697c2bde11a	1115	8	156399628908	168405	0	291	\N	12444	t	0
263	\\x66c452fc2d9a185401afa608855395d4f2a3d9851f2d875f3211f6944e22a65b	1115	9	625604019265	169989	0	327	\N	12444	t	0
264	\\xf463561b411c91a52be8d8632b078469933f1a532159d4320b1e300797b44b49	1115	10	39099780923	168405	0	291	\N	12444	t	0
265	\\x71c5807c7615619f2b1a018950ccd450e086415fb7fd80a5a49195a16986c314	1115	11	156394460503	168405	0	291	\N	12444	t	0
266	\\xe917bf2358d8b7205efec256a950b2609a0c1b7a3da68c37f62dbdc3da2c1849	1115	12	78199730252	168405	0	291	\N	12444	t	0
267	\\x0826d1d85730aafaaaf10d3a6ba84fcd24c136a307c4b082a9afa0cb9ac16977	1115	13	39094612518	168405	0	291	\N	12444	t	0
268	\\x14791177636d3c01da2a6e47a9f3eb81384b61085417df5dc369c344cf57d7b5	1115	14	1271289134345	169989	0	327	\N	12444	t	0
269	\\x9ec20bee1ab02a9c971cd81610ff16501104bd77431ed251cfdebe8210d5d24e	1115	15	156389292098	168405	0	291	\N	12444	t	0
270	\\xcc6d9755b4e68da0a3983a14f2ab82fd79f098342520e3a76cdaa1d65dc902a2	1115	16	312804424638	169989	0	327	\N	12444	t	0
271	\\x488de7982e6f176cdea2a702302ce1379fb7f2462af4a2d6fcb3e9decc8595c3	1115	17	39099780923	168405	0	291	\N	12444	t	0
272	\\xeccdc25445579f6a3b1d87a6703fe405424069631107a6526ab70bd423efeb33	1115	18	9830187	169813	0	323	\N	12444	t	0
273	\\x4a157172021730a6bdd8d2ec8c9af9f138936505789cc6a3abd56ea1fc9a0907	1115	19	1271283965940	168405	0	291	\N	12444	t	0
274	\\x5ca5462781ed1c2d12422b62fcad3a7ded7f4623ba6e96f0cccdae9a2c8624a3	1115	20	78194561847	168405	0	291	\N	12444	t	0
275	\\x5156210bae5da0e00a16741f00b7a19f144d877d867185bddfea2c826048c0c4	1115	21	9830187	169813	0	323	\N	12444	t	0
276	\\xf9bdeec63aeb35e26c80e23940bbdd552c746601c1dba44dedfb9483bde22b85	1115	22	78189393442	168405	0	291	\N	12444	t	0
277	\\x8d177b2e396f8203dff3f6067d00c6be9970fe2126eb6e62ddd823d3cd56a3cf	1115	23	78184225037	168405	0	291	\N	12444	t	0
278	\\x10d203715a571f28159b02bf3e43e3e29e982b672b0e31c9a48019012924feeb	1115	24	9830187	169813	0	323	\N	12444	t	0
279	\\xfc070207191affbdbebbadd99a4d0ca477a6087167ae29f1b14129b4244f08c7	1115	25	9830187	169813	0	323	\N	12444	t	0
280	\\xb7a7bfb6bcaddffc7db33b5e912c8fe5bd843382a1b7e767a5c4510480ec3a08	1115	26	156399628908	168405	0	291	\N	12444	t	0
281	\\x41f2bdccf01d2fd91f6398431606e7416e0822a4d7f64e9243f50bfa67e4a4e1	1115	27	625598850860	168405	0	291	\N	12444	t	0
282	\\xa24e470d7de64d2640f6bc988b1ec43b950ec7beb8141e88327ae692d0a7e101	1115	28	39089444113	168405	0	291	\N	12444	t	0
283	\\xc8116a44c91e51497f558c7c00d7db208732e1292ef5d9af679937f75f2897de	1115	29	39099780923	168405	0	291	\N	12444	t	0
284	\\x424586ace66102c8b382be352ebf45c4fcb0a8253d7bf3c9bf1712d71f4ee1ac	1115	30	9660374	169813	0	323	\N	12444	t	0
285	\\x7e7653603602174e0078b7d147bc4ae1124b6897fda24410a4ef5687375d6183	1115	31	625599020849	168405	0	291	\N	12444	t	0
286	\\x722f42e1dea22d737e28de3aff444754998b1a2b24bf4ea46aa7ee2108f4f138	1115	32	625593852444	168405	0	291	\N	12444	t	0
287	\\xd6b0650dfe3ab0e24579cd8484ea3dff58d4a033646d1abe5243a0ff79c09907	1115	33	9830187	169813	0	323	\N	12444	t	0
288	\\x9ecb016584b387bfa8ee9b4201d199717a328f975261f45dc942f671b1a375df	1115	34	9830187	169813	0	323	\N	12444	t	0
289	\\xd462172ca04f7647fb7873b0addb4c07f620d8bde2011089c0e4b349b86e7d4a	1115	35	9830187	169813	0	323	\N	12444	t	0
290	\\x05df948737e72b8acef901db33dc0d40da124f35ffb3e70cf2eff54c6699b760	1115	36	156384123693	168405	0	291	\N	12444	t	0
291	\\xc4b907d5bbee20e975f0c6fa51f35ada9ff00bb4840936e05d0728c8c1f1769c	1115	37	9830187	169813	0	323	\N	12444	t	0
292	\\x3ef080ba067241b2a5b1d2aa5e8656807ae5784520f279164aaeff3a31e8623e	1115	38	312799256233	168405	0	291	\N	12444	t	0
293	\\x527caf2251007426aa78611a42dbf6dbf70cface34ed66c3340dc99aacb00f74	1115	39	312794087828	168405	0	291	\N	12444	t	0
294	\\x84dac1bc4caa4b85043eb5e9626fd4a5091d31ab854114ad71a7b138a59ceda3	1115	40	9830187	169813	0	323	\N	12444	t	0
295	\\x6f15dfb5b46ef76448d30fdf042c71a24a2d498c7b6ea099a496e837f830a3d2	1115	41	156394460503	168405	0	291	\N	12444	t	0
296	\\x3a1e185bd4e8dbe7303f09b7f3180cdf3681c15c544f9e39e9797dc70031888b	1115	42	9660374	169813	0	323	\N	12444	t	0
297	\\x5e4c49c9a0c407689e52ee1c57bfbcf45dedc06d3050d0a4d0d444c70c88dc32	1116	0	156389292098	168405	0	291	\N	12444	t	0
298	\\x4cf1c99f8ac044a74225d09bde2cf69c65e673c08a8285e3fc96a9f68407ce4b	1116	1	9660374	169813	0	323	\N	12444	t	0
299	\\x4b096ff9fedc6c64ba75f2070e14e3046c4b7f774a009315f6efa96646ef8d00	1116	2	9830187	169813	0	323	\N	12444	t	0
300	\\x22d694767ef349f5d6e434c6303b5bf1603fb75dd2a2c3237f2b446deeaf7009	1116	3	9830187	169813	0	323	\N	12444	t	0
301	\\xae8615edf5f10715797f325d193438b34eee1937d244401367f3121b2f158b8c	1117	0	9830187	169813	0	323	\N	12451	t	0
302	\\x2972b60aeec833dc9e2f7a967884aa48adc013b5bd960fbd297f7a51dc88fb32	1117	1	9490561	169813	0	323	\N	12451	t	0
303	\\x548889c72181cb6ccff80208ba52726f37425db64e3bca952b3f0448c3ec227b	1117	2	9830187	169813	0	323	\N	12452	t	0
304	\\x82aef218597fe1aa86cb658fb0c7a07aa827a73a50516a2c78373cfc9745e580	1117	3	156378955288	168405	0	291	\N	12452	t	0
305	\\x8c3deae6724ab3e6a3ecc1f6594bd94491fcf4888ee974bb07509fffd6961470	1117	4	39084275708	168405	0	291	\N	12452	t	0
306	\\xb9e54a6224faf69a79a84253c0fcc0c8f318a0cbc2d4d76bdad6bfd0e4fb7762	1117	5	39079107303	168405	0	291	\N	12452	t	0
307	\\x6f1b5ecbbcd644e03aecc27902c370d32c1b45fe80eed1446e5e623e23581188	1117	6	9490561	169813	0	323	\N	12452	t	0
308	\\xaa9474fec1e23bee64426dfdd92efe497eaa6b4e0fa3ae55cf8441b6555b8588	1117	7	39099780923	168405	0	291	\N	12452	t	0
309	\\x29fc027475b2795f7023033fabfac5e4ebd2d10c76971cb70472950e398a14c2	1117	8	9830187	169813	0	323	\N	12452	t	0
310	\\x31f4cb1123907405d4f5364e15725ef744aa6420674272da3c7a4c1d7d1800fa	1117	9	9830187	169813	0	323	\N	12452	t	0
311	\\x561fe31a57f695326c7e56571d7f8b955ff051476d7c38a3c1405d9cc9b66159	1117	10	1271278797535	168405	0	291	\N	12452	t	0
312	\\xf8266d1f59ea4b6f139f33d2c5dff4c9706b43b82be25eb9efcec2a1da286225	1118	0	9320748	169813	0	323	\N	12452	t	0
313	\\x19c0ee4540d3b5cf0bcc697dbcf99e82eef65b53b05fe8bb97c67fc5499d192c	1118	1	9660374	169813	0	323	\N	12452	t	0
314	\\x4ab739587e6c25a79b99befa6c3e91b38456d9f69a6fda89d7b71e38fc626fbe	1118	2	625593682455	168405	0	291	\N	12454	t	0
315	\\xbbf88decacddb43793b8b798f2b8129fd4f4d1e5ab5e4710bf06aa6e08ffd6bf	1118	3	156384123693	168405	0	291	\N	12454	t	0
316	\\x582444dcd7cab6dc9fba0f886b7088f418f34ff0a0b42188f81414c6ed7cef55	1118	4	156373786883	168405	0	291	\N	12454	t	0
317	\\xd3d4a668e43d59b97bd8e10de344334fe0a52b25fc6d8fca68ace075891740df	1118	5	9660374	169813	0	323	\N	12454	t	0
318	\\xa099de4850115ec54f6cee40630338e15939a781d55a66eefd9414cc236fd3a9	1118	6	9150935	169813	0	323	\N	12454	t	0
319	\\x1858f00a11d08d391aa2a9dc144e0692aa0f7699f0649f7b0cdefbc68c5454fb	1118	7	9830187	169813	0	323	\N	12454	t	0
320	\\xdbb5defc0c0519049de8b41e311fde661e8540c55a3d42c483a97ae33c7fc844	1118	8	312793578213	169989	0	327	\N	12454	t	0
321	\\x4dade8d25d0df172b20c21260aeadbdbdc184a6e60e95a167657b6f83a8b287e	1118	9	39094612518	168405	0	291	\N	12454	t	0
322	\\x16558b29afbb53e1877bfca603f78c331f587c4f3d38ce19b29efab73aa40764	1118	10	1271278457733	169989	0	327	\N	12454	t	0
323	\\x45c0134d72671d53105ddedd7f02b01fcc9c5a1bed0eb36c5348ea0b707b3bf0	1118	11	39094612518	168405	0	291	\N	12454	t	0
324	\\xd8ccbeb07f9a1de0cc35882e5f9b8324f09a048e4bb0a25a75b98cf2b244f252	1118	12	9660374	169813	0	323	\N	12454	t	0
325	\\x89ced31ad536d3042c713432f67422678045e33f8913ed65c64707c6460b3845	1118	13	9660374	169813	0	323	\N	12454	t	0
326	\\xe9ffe6e49b3777dd839b73fe96ced28c23d91b641c419b9dada7b40e0207b400	1118	14	9830187	169813	0	323	\N	12454	t	0
327	\\xa6f5a9f3b71458c7ebb0221963b2b05dc1a11b9d159c717eba07b948846bd50e	1118	15	625588684039	168405	0	291	\N	12454	t	0
328	\\x60654fed649f4e0902a8716ca0c450725216a0151e8473796083064b8baca1ee	1118	16	39094612518	168405	0	291	\N	12454	t	0
329	\\xf466d4cf348c4fbf57808c3e237694ac7daaeefe04fa5bd623e966aadd71a308	1118	17	9320748	169813	0	323	\N	12454	t	0
330	\\x81f8d11a5fb8367c58ebd3c4f7adf0b231c21423951c4f8c10312eb4c37ee0e4	1118	18	9830187	169813	0	323	\N	12454	t	0
331	\\x685844f1941416d98a315d28c094ec584a891a08e27c15a6f8d01d9759adede3	1118	19	9490561	169813	0	323	\N	12454	t	0
332	\\xf7cffb0db83c03e230d7d26ad791a1274c75f91615eb150c739a2d39d2e69287	1118	20	9830187	169813	0	323	\N	12454	t	0
333	\\xb535a703e3290294ece1ada6611c5b6fc522ed78a5d19b1a5da8b06c43417005	1118	21	9830187	169813	0	323	\N	12454	t	0
334	\\xfb65980ea6a92a40dec04d6d9b20ea2cae58117c6a21072b6ebc100aa694021b	1118	22	9490561	169813	0	323	\N	12454	t	0
335	\\x86ab6c0c5e80dfaa7107fd60676106cced29a9c97a418f61ba5a0000e8d70320	1118	23	9830187	169813	0	323	\N	12454	t	0
336	\\xcb51efca5774a1bf623dfb0d3f7cd14239237bcf50a7930b39e5037be509fb9e	1118	24	9660374	169813	0	323	\N	12454	t	0
337	\\x304a643b0f48724e2e8cf3ef2d0ae8d971b0992b25ff72050a837a8ffbe9caf6	1118	25	1251192871708	169989	0	327	\N	12454	t	0
338	\\xaa92665384c22b5557726aaa98273da0ef35f87fdbba6faa4d81c5cb1613efab	1118	26	1271278287744	169989	0	327	\N	12454	t	0
339	\\x63ea06a315cd6492474062ef84af280df2c5909792d611ab463cc78627d3ab2e	1118	27	9660374	169813	0	323	\N	12454	t	0
340	\\xf7626adc7084a4486d3a224a520af7be0f00029956f0c072476425cf0064097c	1118	28	9660374	169813	0	323	\N	12454	t	0
341	\\xf0e82ae212253717c6e7e54559ab773a758513757dd697e44e76f63f9989208f	1118	29	156373616894	169989	0	327	\N	12454	t	0
342	\\xbd0b5d6a8a7ade1fb49b8f007ffe9bcb106ebc2c2a219c113b053a8ee051daa0	1118	30	9830187	169813	0	323	\N	12454	t	0
343	\\xdc872691e674251c6e4eee481beaeb97f93fe8300f807c33ba603f13d47f1cbd	1118	31	9660374	169813	0	323	\N	12454	t	0
344	\\x86655d7c487d5ec5638c8532b496530bb4125ebc021c9ef630d55cc338534981	1118	32	9490561	169813	0	323	\N	12454	t	0
345	\\xd26eb5003d1eb83977e2425638a904208e341f08792314b3cede4fc84b3da35b	1118	33	9660374	169813	0	323	\N	12454	t	0
346	\\x50f6ebc97f2a6dd9aced6c671adcb5a537fcde394fc9f4d18ae11158219e37e4	1118	34	9490561	169813	0	323	\N	12454	t	0
347	\\x327e1ca127f8f031431ba1a6e80a05bafd6746fab354645683786c2d9995491d	1118	35	9490561	169813	0	323	\N	12454	t	0
348	\\xceef271bd7f01a4c288400fc15322e5a1e43457d1bbb6eb870098bc99d053eeb	1118	36	9490561	169813	0	323	\N	12454	t	0
349	\\xab1efcc826ab5f317fca8ee6233cd3003570c8725d5241e1ee3f7c72b4eafebb	1118	37	39078258062	169989	0	327	\N	12454	t	0
350	\\xf7a73cbb07445b8565a1b586ac48e32a61bdb4a41422d1610676a9456236dc43	1118	38	8641496	169813	0	323	\N	12454	t	0
351	\\x6784f285d3d4bb3498bdb8ab9af356c7874eeab2718008c14b39b773e98d857a	1118	39	625593003027	169989	0	327	\N	12454	t	0
352	\\x88c5f103c96acb30c9821565c71e12d212254230e25db25bf7ce65ed0e9b8d36	1118	40	312788409808	168405	0	291	\N	12454	t	0
353	\\x1f2c4a04a058f0fdf84392e34253ff3919f33134272f114c85bf557224a18115	1118	41	156373446905	169989	0	327	\N	12454	t	0
354	\\x94da4e9fabd5650cf82a7c051a8d12f1a7ab3ce8cf646d187d59ff970513be69	1314	0	330142502314	180901	0	575	\N	14450	t	0
355	\\x96414eaab3277294f4d177966085daa8ba33a5ce298f20216fa57f44294ad9dd	1320	0	39078021633	236429	0	1736	\N	14470	t	0
356	\\x6decbe3f26bcc06e9940c86af2775b7f6004aab2e5d785871e3c17778a1d7757	1328	0	4999999820111	179889	0	552	\N	14551	t	0
357	\\x6a5ad47530554f6e8f2a958f774979a32fc0f59c2186779cb8a9526830f40c08	1332	0	4999999648538	171573	0	363	\N	14572	t	0
358	\\x722446ac32ea66826f1e966bf7e861c7a42c86bb588bed511ae4ecdcde0596fd	1336	0	4999999471201	177337	0	494	\N	14597	t	0
359	\\x0f6c44b6c7d4ada73906f33df954f60c1f252a3a50360a0f31b783dba952f1b4	1341	0	4999999820287	179713	0	548	\N	14633	t	0
360	\\x1f39255e2a87dbb729aaa6fdf8bc5e582bdde480ae5da8e2a9cdf6a6fd0f8fa2	1345	0	9826447	173553	0	408	\N	14667	t	0
361	\\xd74244deff9966d6bde78b2db9946a1f9ae9d035798d1ce3b646f1b8289e1a20	1349	0	9821255	178745	0	526	\N	14689	t	0
\.


--
-- Data for Name: tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_in (id, tx_in_id, tx_out_id, tx_out_index, redeemer_id) FROM stdin;
1	35	12	0	\N
2	36	35	1	\N
3	37	36	0	\N
4	38	26	0	\N
5	39	38	0	\N
6	40	37	0	\N
7	41	40	1	\N
8	42	41	0	\N
9	43	29	0	\N
10	44	43	0	\N
11	45	42	0	\N
12	46	45	1	\N
13	47	46	0	\N
14	48	24	0	\N
15	49	48	0	\N
16	50	47	0	\N
17	51	50	1	\N
18	52	51	0	\N
19	53	27	0	\N
20	54	53	0	\N
21	55	52	0	\N
22	56	55	1	\N
23	57	56	0	\N
24	58	13	0	\N
25	59	58	0	\N
26	60	57	0	\N
27	61	60	1	\N
28	62	61	0	\N
29	63	15	0	\N
30	64	63	0	\N
31	65	62	0	\N
32	66	65	1	\N
33	67	66	0	\N
34	68	33	0	\N
35	69	68	0	\N
36	70	67	0	\N
37	71	70	1	\N
38	72	71	0	\N
39	73	32	0	\N
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
64	98	14	0	\N
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
79	112	111	1	\N
80	113	112	0	\N
81	114	113	0	\N
82	114	113	1	\N
83	115	114	1	\N
84	116	115	1	\N
85	117	114	0	\N
86	118	116	0	\N
87	119	118	0	\N
88	119	118	1	\N
89	120	119	0	\N
90	120	119	1	\N
91	121	120	0	\N
92	122	121	0	\N
93	123	122	0	\N
94	123	121	1	\N
95	124	123	0	\N
96	125	124	0	\N
97	126	125	0	\N
98	126	123	1	\N
99	127	126	0	\N
100	127	126	1	\N
101	128	127	0	\N
102	128	127	1	\N
103	129	128	1	\N
104	130	128	0	\N
105	130	129	0	\N
106	131	129	1	\N
107	131	130	0	\N
108	131	130	1	\N
109	132	131	0	\N
110	133	132	0	\N
111	134	133	0	\N
112	134	133	1	\N
113	134	133	2	\N
114	134	133	3	\N
115	134	133	4	\N
116	134	133	5	\N
117	134	133	6	\N
118	134	133	7	\N
119	134	133	8	\N
120	134	133	9	\N
121	134	133	10	\N
122	134	133	11	\N
123	134	133	12	\N
124	134	133	13	\N
125	134	133	14	\N
126	134	133	15	\N
127	134	133	16	\N
128	134	133	17	\N
129	134	133	18	\N
130	134	133	19	\N
131	134	133	20	\N
132	134	133	21	\N
133	134	133	22	\N
134	134	133	23	\N
135	134	133	24	\N
136	134	133	25	\N
137	134	133	26	\N
138	134	133	27	\N
139	134	133	28	\N
140	134	133	29	\N
141	134	133	30	\N
142	134	133	31	\N
143	134	133	32	\N
144	134	133	33	\N
145	134	133	34	\N
146	135	134	0	\N
147	136	132	1	\N
148	137	136	0	\N
149	138	136	1	\N
150	139	138	0	\N
151	140	138	1	\N
152	141	140	0	\N
153	142	137	0	\N
154	142	140	1	\N
155	142	139	0	\N
156	143	142	0	\N
157	143	142	1	\N
158	144	143	1	\N
159	145	144	0	\N
160	145	144	1	\N
161	146	145	0	\N
162	146	145	1	\N
163	146	145	2	\N
164	146	145	3	\N
165	146	145	4	\N
166	146	145	5	\N
167	146	145	6	\N
168	146	145	7	\N
169	146	145	8	\N
170	146	145	9	\N
171	146	145	10	\N
172	146	145	11	\N
173	146	145	12	\N
174	146	145	13	\N
175	146	145	14	\N
176	146	145	15	\N
177	146	145	16	\N
178	146	145	17	\N
179	146	145	18	\N
180	146	145	19	\N
181	146	145	20	\N
182	146	145	21	\N
183	146	145	22	\N
184	146	145	23	\N
185	146	145	24	\N
186	146	145	25	\N
187	146	145	26	\N
188	146	145	27	\N
189	146	145	28	\N
190	146	145	29	\N
191	146	145	30	\N
192	146	145	31	\N
193	146	145	32	\N
194	146	145	33	\N
195	146	145	34	\N
196	146	145	35	\N
197	146	145	36	\N
198	146	145	37	\N
199	146	145	38	\N
200	146	145	39	\N
201	146	145	40	\N
202	146	145	41	\N
203	146	145	42	\N
204	146	145	43	\N
205	146	145	44	\N
206	146	145	45	\N
207	146	145	46	\N
208	146	145	47	\N
209	146	145	48	\N
210	146	145	49	\N
211	146	145	50	\N
212	146	145	51	\N
213	146	145	52	\N
214	146	145	53	\N
215	146	145	54	\N
216	146	145	55	\N
217	146	145	56	\N
218	146	145	57	\N
219	146	145	58	\N
220	146	145	59	\N
221	147	145	95	\N
222	148	145	112	\N
223	149	146	0	\N
224	149	143	0	\N
225	149	148	0	\N
226	149	148	1	\N
227	149	147	0	\N
228	149	147	1	\N
229	149	145	60	\N
230	149	145	61	\N
231	149	145	62	\N
232	149	145	63	\N
233	149	145	64	\N
234	149	145	65	\N
235	149	145	66	\N
236	149	145	67	\N
237	149	145	68	\N
238	149	145	69	\N
239	149	145	70	\N
240	149	145	71	\N
241	149	145	72	\N
242	149	145	73	\N
243	149	145	74	\N
244	149	145	75	\N
245	149	145	76	\N
246	149	145	77	\N
247	149	145	78	\N
248	149	145	79	\N
249	149	145	80	\N
250	149	145	81	\N
251	149	145	82	\N
252	149	145	83	\N
253	149	145	84	\N
254	149	145	85	\N
255	149	145	86	\N
256	149	145	87	\N
257	149	145	88	\N
258	149	145	89	\N
259	149	145	90	\N
260	149	145	91	\N
261	149	145	92	\N
262	149	145	93	\N
263	149	145	94	\N
264	149	145	96	\N
265	149	145	97	\N
266	149	145	98	\N
267	149	145	99	\N
268	149	145	100	\N
269	149	145	101	\N
270	149	145	102	\N
271	149	145	103	\N
272	149	145	104	\N
273	149	145	105	\N
274	149	145	106	\N
275	149	145	107	\N
276	149	145	108	\N
277	149	145	109	\N
278	149	145	110	\N
279	149	145	111	\N
280	149	145	113	\N
281	149	145	114	\N
282	149	145	115	\N
283	149	145	116	\N
284	149	145	117	\N
285	149	145	118	\N
286	149	145	119	\N
287	150	149	0	\N
288	151	149	1	\N
289	152	151	0	\N
290	152	150	1	\N
291	153	152	1	\N
292	154	153	1	\N
293	154	152	0	\N
294	155	154	0	\N
295	155	153	0	\N
296	156	154	1	\N
297	156	155	1	\N
298	157	156	0	\N
299	157	155	0	\N
300	158	156	1	\N
301	159	158	1	\N
302	160	159	0	\N
303	160	158	0	\N
304	161	157	1	\N
305	161	160	0	\N
306	162	160	1	\N
307	162	161	1	\N
308	163	162	0	\N
309	163	162	1	\N
310	164	157	0	\N
311	164	163	0	\N
312	165	159	1	\N
313	166	164	0	\N
314	166	161	0	\N
315	167	163	1	\N
316	167	165	1	\N
317	168	166	0	\N
318	168	166	1	\N
319	169	167	1	\N
320	170	164	1	\N
321	170	169	0	\N
322	171	170	0	\N
323	171	170	1	\N
324	172	167	0	\N
325	172	165	0	\N
326	173	168	0	\N
327	173	172	0	\N
328	174	169	1	\N
329	174	172	1	\N
330	175	173	1	\N
331	175	171	1	\N
332	176	175	1	\N
333	176	171	0	\N
334	177	173	0	\N
335	177	174	0	\N
336	178	176	0	\N
337	178	175	0	\N
338	179	178	0	\N
339	179	177	1	\N
340	180	174	1	\N
341	181	179	0	\N
342	181	180	0	\N
343	182	176	1	\N
344	182	181	1	\N
345	183	178	1	\N
346	183	177	0	\N
347	184	168	1	\N
348	184	183	0	\N
349	185	182	0	\N
350	185	182	1	\N
351	186	179	1	\N
352	186	184	1	\N
353	187	186	0	\N
354	187	185	0	\N
355	188	187	0	\N
356	188	184	0	\N
357	189	185	1	\N
358	189	183	1	\N
359	190	187	1	\N
360	190	181	0	\N
361	191	180	1	\N
362	191	188	1	\N
363	192	190	0	\N
364	192	188	0	\N
365	193	186	1	\N
366	193	191	0	\N
367	194	189	0	\N
368	194	189	1	\N
369	195	194	0	\N
370	195	192	1	\N
371	196	193	0	\N
372	196	192	0	\N
373	197	196	1	\N
374	197	195	1	\N
375	198	191	1	\N
376	199	198	1	\N
377	200	198	0	\N
378	200	193	1	\N
379	201	194	1	\N
380	201	197	1	\N
381	201	200	1	\N
382	202	201	1	\N
383	202	197	0	\N
384	203	202	0	\N
385	203	201	0	\N
386	204	196	0	\N
387	204	200	0	\N
388	205	199	1	\N
389	206	205	1	\N
390	207	206	0	\N
391	207	203	1	\N
392	208	202	1	\N
393	208	199	0	\N
394	209	206	1	\N
395	210	208	1	\N
396	210	209	0	\N
397	211	190	1	\N
398	211	207	1	\N
399	212	204	0	\N
400	212	203	0	\N
401	213	204	1	\N
402	213	210	1	\N
403	214	213	1	\N
404	214	211	1	\N
405	215	212	1	\N
406	215	195	0	\N
407	216	212	0	\N
408	216	214	1	\N
409	217	208	0	\N
410	217	210	0	\N
411	218	216	0	\N
412	218	215	1	\N
413	219	217	0	\N
414	219	214	0	\N
415	220	218	1	\N
416	220	215	0	\N
417	221	211	0	\N
418	221	219	1	\N
419	222	220	1	\N
420	222	207	0	\N
421	223	218	0	\N
422	223	219	0	\N
423	224	209	1	\N
424	225	224	1	\N
425	226	224	0	\N
426	226	205	0	\N
427	227	225	1	\N
428	228	226	0	\N
429	228	222	0	\N
430	229	221	0	\N
431	229	220	0	\N
432	230	227	0	\N
433	230	225	0	\N
434	231	229	0	\N
435	231	230	0	\N
436	232	221	1	\N
437	232	231	0	\N
438	233	232	1	\N
439	233	229	1	\N
440	234	227	1	\N
441	235	222	1	\N
442	235	230	1	\N
443	236	234	0	\N
444	236	231	1	\N
445	237	233	1	\N
446	237	235	0	\N
447	238	228	1	\N
448	238	236	0	\N
449	239	223	1	\N
450	239	237	1	\N
451	240	239	0	\N
452	240	213	0	\N
453	241	238	1	\N
454	241	228	0	\N
455	242	239	1	\N
456	242	232	0	\N
457	243	237	0	\N
458	243	242	0	\N
459	244	235	1	\N
460	244	226	1	\N
461	245	243	1	\N
462	245	241	1	\N
463	246	234	1	\N
464	247	240	0	\N
465	247	242	1	\N
466	248	233	0	\N
467	248	244	1	\N
468	249	243	0	\N
469	249	236	1	\N
470	250	245	0	\N
471	250	245	1	\N
472	251	246	1	\N
473	252	216	1	\N
474	253	217	1	\N
475	253	238	0	\N
476	253	252	0	\N
477	253	252	1	\N
478	253	250	0	\N
479	253	250	1	\N
480	253	241	0	\N
481	253	248	0	\N
482	253	248	1	\N
483	253	247	0	\N
484	253	247	1	\N
485	253	244	0	\N
486	253	240	1	\N
487	253	251	0	\N
488	253	251	1	\N
489	253	223	0	\N
490	253	249	0	\N
491	253	249	1	\N
492	253	246	0	\N
493	254	253	0	\N
494	255	253	1	\N
495	256	253	9	\N
496	257	255	0	\N
497	257	253	5	\N
498	258	257	0	\N
499	258	254	0	\N
500	259	255	1	\N
501	260	259	0	\N
502	260	254	1	\N
503	261	257	1	\N
504	262	253	6	\N
505	263	256	0	\N
506	263	253	3	\N
507	264	253	10	\N
508	265	262	1	\N
509	266	253	8	\N
510	267	264	1	\N
511	268	258	1	\N
512	268	260	1	\N
513	269	265	1	\N
514	270	268	0	\N
515	270	253	4	\N
516	271	253	13	\N
517	272	267	0	\N
518	272	265	0	\N
519	273	268	1	\N
520	274	256	1	\N
521	275	258	0	\N
522	275	274	0	\N
523	276	274	1	\N
524	277	276	1	\N
525	278	261	0	\N
526	278	271	0	\N
527	279	263	0	\N
528	279	272	0	\N
529	280	253	7	\N
530	281	263	1	\N
531	282	267	1	\N
532	283	253	11	\N
533	284	262	0	\N
534	284	272	1	\N
535	285	253	2	\N
536	286	285	1	\N
537	287	278	0	\N
538	287	275	0	\N
539	288	260	0	\N
540	288	266	0	\N
541	289	273	0	\N
542	289	283	0	\N
543	290	269	1	\N
544	291	277	0	\N
545	291	264	0	\N
546	292	270	1	\N
547	293	292	1	\N
548	294	281	0	\N
549	294	286	0	\N
550	295	280	1	\N
551	296	278	1	\N
552	296	276	0	\N
553	297	295	1	\N
554	298	288	1	\N
555	298	282	0	\N
556	299	285	0	\N
557	299	280	0	\N
558	300	297	0	\N
559	300	289	0	\N
560	301	298	0	\N
561	301	287	0	\N
562	302	284	1	\N
563	302	301	0	\N
564	303	300	0	\N
565	303	292	0	\N
566	304	290	1	\N
567	305	282	1	\N
568	306	305	1	\N
569	307	296	1	\N
570	307	279	0	\N
571	308	253	12	\N
572	309	269	0	\N
573	309	306	0	\N
574	310	290	0	\N
575	310	293	0	\N
576	311	273	1	\N
577	312	302	1	\N
578	312	295	0	\N
579	313	310	1	\N
580	313	288	0	\N
581	314	281	1	\N
582	315	297	1	\N
583	316	304	1	\N
584	317	314	0	\N
585	317	287	1	\N
586	318	299	0	\N
587	318	312	1	\N
588	319	303	0	\N
589	319	311	0	\N
590	320	293	1	\N
591	320	317	1	\N
592	321	271	1	\N
593	322	319	1	\N
594	322	311	1	\N
595	323	308	1	\N
596	324	318	0	\N
597	324	301	1	\N
598	325	284	0	\N
599	325	289	1	\N
600	326	310	0	\N
601	326	304	0	\N
602	327	286	1	\N
603	328	283	1	\N
604	329	296	0	\N
605	329	307	1	\N
606	330	321	0	\N
607	330	320	0	\N
608	331	303	1	\N
609	331	330	1	\N
610	332	325	0	\N
611	332	291	0	\N
612	333	313	0	\N
613	333	308	0	\N
614	334	298	1	\N
615	334	330	0	\N
616	335	326	0	\N
617	335	334	0	\N
618	336	309	1	\N
619	336	329	0	\N
620	337	259	1	\N
621	337	335	0	\N
622	338	322	1	\N
623	338	324	0	\N
624	339	294	0	\N
625	339	332	1	\N
626	340	335	1	\N
627	340	317	0	\N
628	341	316	1	\N
629	341	336	0	\N
630	342	307	0	\N
631	342	312	0	\N
632	343	275	1	\N
633	343	342	0	\N
634	344	323	0	\N
635	344	336	1	\N
636	345	322	0	\N
637	345	342	1	\N
638	346	338	0	\N
639	346	343	1	\N
640	347	313	1	\N
641	347	270	0	\N
642	348	339	1	\N
643	348	344	0	\N
644	349	306	1	\N
645	349	329	1	\N
646	350	318	1	\N
647	350	345	1	\N
648	351	314	1	\N
649	351	334	1	\N
650	352	320	1	\N
651	353	328	0	\N
652	353	341	1	\N
653	354	261	1	\N
654	355	347	0	\N
655	355	349	1	\N
656	356	108	2	\N
657	357	356	0	\N
658	357	356	1	\N
659	358	357	0	\N
660	358	357	1	\N
661	359	108	4	\N
662	360	107	0	\N
663	361	109	0	\N
\.


--
-- Data for Name: tx_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_metadata (id, key, json, bytes, tx_id) FROM stdin;
1	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "TestHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "TestHandle", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": "ipfs://some-hash", "website": "https://cardano.org/", "mediaType": "image/jpeg", "description": "The Handle Standard", "augmentations": []}, "HelloHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "HelloHandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "DoubleHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "DoubleHandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a460a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656067776562736974657468747470733a2f2f63617264616e6f2e6f72672f6c446f75626c6548616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656c446f75626c6548616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6b48656c6c6f48616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656b48656c6c6f48616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6a5465737448616e646c65a86d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e646172646566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e7965696d61676570697066733a2f2f736f6d652d68617368696d65646961547970656a696d6167652f6a706567646e616d656a5465737448616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f	109
2	6862	{"pools": [{"id": "1d15b58ed6f59d26d08b20aa635b3ca03769934b8c69d1d81aa6de6d", "weight": 1}]}	\\xa1191acea165706f6f6c7381a2626964783831643135623538656436663539643236643038623230616136333562336361303337363939333462386336396431643831616136646536646677656967687401	111
3	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	113
4	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	118
5	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	119
6	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	121
7	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	123
8	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"NFT-001": {"name": "One", "image": ["ipfs://some_hash1"], "version": "1.0"}, "NFT-002": {"name": "Two", "image": ["ipfs://some_hash2"], "version": "1.0"}, "NFT-files": {"id": "1", "name": "NFT with files", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": ["ipfs://somehash"], "version": "1.0", "mediaType": "image/png", "description": ["NFT with different types of files"]}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a3674e46542d303031a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65634f6e656776657273696f6e63312e30674e46542d303032a365696d6167658171697066733a2f2f736f6d655f6861736832646e616d656354776f6776657273696f6e63312e30694e46542d66696c6573a76b6465736372697074696f6e8178214e4654207769746820646966666572656e74207479706573206f662066696c65736566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e79626964613165696d616765816f697066733a2f2f736f6d6568617368696d656469615479706569696d6167652f706e67646e616d656e4e465420776974682066696c65736776657273696f6e63312e30	126
9	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"4349502d303032352d76312d686578": {"name": "CIP-0025-v1-hex", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1781e343334393530326433303330333233353264373633313264363836353738a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656f4349502d303032352d76312d6865786776657273696f6e63312e30	128
10	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"CIP-0025-v1-utf8": {"name": "CIP-0025-v1-utf8", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1704349502d303032352d76312d75746638a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65704349502d303032352d76312d757466386776657273696f6e63312e30	129
11	721	{"0x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"0x4349502d303032352d7632": {"name": "CIP-0025-v2", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a1581c17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029a14b4349502d303032352d7632a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656b4349502d303032352d76326776657273696f6e63312e30	130
12	6862	{"name": "Test Portfolio", "pools": [{"id": "1d15b58ed6f59d26d08b20aa635b3ca03769934b8c69d1d81aa6de6d", "weight": 1}, {"id": "78a4ecb9bd827c9660eedaff0013205f035e17ddc52d98042a089bb6", "weight": 1}, {"id": "ece7e4747470b66c32923761eb74025fc7ddbbdb3dace294730de975", "weight": 1}, {"id": "35908c7afc62e0bb58e414d46fd96fdd29453b0f80cde4df08d9089b", "weight": 1}, {"id": "921c20953083c8322befe96fc9c697ae7c333caf90bc46eb5efbc224", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783831643135623538656436663539643236643038623230616136333562336361303337363939333462386336396431643831616136646536646677656967687401a2626964783837386134656362396264383237633936363065656461666630303133323035663033356531376464633532643938303432613038396262366677656967687401a2626964783865636537653437343734373062363663333239323337363165623734303235666337646462626462336461636532393437333064653937356677656967687401a2626964783833353930386337616663363265306262353865343134643436666439366664643239343533623066383063646534646630386439303839626677656967687401a2626964783839323163323039353330383363383332326265666539366663396336393761653763333333636166393062633436656235656662633232346677656967687401	133
13	6862	{"name": "Test Portfolio", "pools": [{"id": "1d15b58ed6f59d26d08b20aa635b3ca03769934b8c69d1d81aa6de6d", "weight": 0}, {"id": "78a4ecb9bd827c9660eedaff0013205f035e17ddc52d98042a089bb6", "weight": 0}, {"id": "ece7e4747470b66c32923761eb74025fc7ddbbdb3dace294730de975", "weight": 0}, {"id": "35908c7afc62e0bb58e414d46fd96fdd29453b0f80cde4df08d9089b", "weight": 0}, {"id": "921c20953083c8322befe96fc9c697ae7c333caf90bc46eb5efbc224", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7385a2626964783831643135623538656436663539643236643038623230616136333562336361303337363939333462386336396431643831616136646536646677656967687400a2626964783837386134656362396264383237633936363065656461666630303133323035663033356531376464633532643938303432613038396262366677656967687400a2626964783865636537653437343734373062363663333239323337363165623734303235666337646462626462336461636532393437333064653937356677656967687400a2626964783833353930386337616663363265306262353865343134643436666439366664643239343533623066383063646534646630386439303839626677656967687400a2626964783839323163323039353330383363383332326265666539366663396336393761653763333333636166393062633436656235656662633232346677656967687401	134
14	123	"1234"	\\xa1187b6431323334	147
15	6862	{"name": "Test Portfolio", "pools": [{"id": "1d15b58ed6f59d26d08b20aa635b3ca03769934b8c69d1d81aa6de6d", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7381a2626964783831643135623538656436663539643236643038623230616136333562336361303337363939333462386336396431643831616136646536646677656967687401	151
16	6862	{"name": "Test Portfolio", "pools": [{"id": "1d15b58ed6f59d26d08b20aa635b3ca03769934b8c69d1d81aa6de6d", "weight": 1}, {"id": "78a4ecb9bd827c9660eedaff0013205f035e17ddc52d98042a089bb6", "weight": 1}]}	\\xa1191acea2646e616d656e5465737420506f7274666f6c696f65706f6f6c7382a2626964783831643135623538656436663539643236643038623230616136333562336361303337363939333462386336396431643831616136646536646677656967687401a2626964783837386134656362396264383237633936363065656461666630303133323035663033356531376464633532643938303432613038396262366677656967687401	253
17	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	355
\.


--
-- Data for Name: tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_out (id, tx_id, index, address, address_raw, address_has_script, payment_cred, stake_address_id, value, data_hash, inline_datum_id, reference_script_id) FROM stdin;
1	1	0	5oP9ib6ym3XZLfh84Ku4tHJE48GfjifxmH9CacVX7Ws8XnHYULhWTX5AUoiTvrZudr	\\x82d818582683581c2387ce75b4a04060bcc7b7605ce52a4926ea7d2889dda8d42b504db4a10243190378001a7f43f3d9	f	\N	\N	910909092	\N	\N	\N
2	2	0	5oP9ib6ym3XZWwTtZm2bAzrEP9CMsETwJFGhwGJVWkfoLmiXLV4n7Rg3WLoWm9FMud	\\x82d818582683581c271845e7016a4250550b8a58ca8fdbbf05035b8470d43a761447b30ca10243190378001a7b567e2c	f	\N	\N	910909092	\N	\N	\N
3	3	0	5oP9ib6ym3XZYoGXN5sBr1UD34W9EJpyAFA6tcPugA2WisLLFdQ3oZfAJkPaYTvevv	\\x82d818582683581c27bd61ee63029c0eae4cc15587d0ce54bb6f61b8e519b5d47220a109a10243190378001a609afcf3	f	\N	\N	910909092	\N	\N	\N
4	4	0	5oP9ib6ym3Xa1fYvjZJv2wPJ3VmR3k5rx2DdccnT6NGrzwWoTN1UC2neNCaKE7hyXW	\\x82d818582683581c311000a2240db34914d5fcf053add6fdc29315351e15b5ca420b8a6ba10243190378001ae4d6c889	f	\N	\N	910909092	\N	\N	\N
5	5	0	5oP9ib6ym3XbGwhCH9Jg3kHfxcoZMmc88PuJrsBVxn1Mn7v9Aqzsr3HuAEwQSCSoX4	\\x82d818582683581c4a7d65319f7a5598f45bc72e91b43eb75b42c8fcec20dc3ae6c852dca10243190378001a108aeb3f	f	\N	\N	910909092	\N	\N	\N
6	6	0	5oP9ib6ym3XbYXC572BLgNx5TGvAWA1xwhFA6vw5LEeN3AwihfuRDmJZN3StT5w2SX	\\x82d818582683581c4fe52a7afe0ec1b0d8fd22caee71a33e1293a8809f85046408a9aa2ea10243190378001a08e6ef1c	f	\N	\N	910909092	\N	\N	\N
7	7	0	5oP9ib6ym3XcE3UNFXNEqTqqZ8jty1TjqSYG7rjkkp7SVrLiGEvza5dZCqoibgQX4N	\\x82d818582683581c5d9bf4ac9ffe57c39b5b0b4b724c3276afdaf497240f6547d12d9f9fa10243190378001a63137283	f	\N	\N	910909092	\N	\N	\N
8	8	0	5oP9ib6ym3XcNxZkKLVvGo277zfuMC8wazfyYgoDo7rP4mhs343EGFm7r1gU8QMp5p	\\x82d818582683581c60b3eb75f6a7f24a5c88bbba65dc8a2b34611023c97d0076fc6e3381a10243190378001a280c8de3	f	\N	\N	910909092	\N	\N	\N
9	9	0	5oP9ib6ym3XeVcjukiWKo9aMKtMZxvsRCbAKxPzKzXEpPHFRpED9oAG3cbEaAFfQEK	\\x82d818582683581c8b43c7ca831b060ba844172490ad3869ef7aaf1f8868f5ec7898e783a10243190378001a315e4370	f	\N	\N	910909092	\N	\N	\N
10	10	0	5oP9ib6ym3XjLQC726j8Qkfv7VysWzKTVGhsiWjHkxnxgxVPRadqZP8L6cYhEwjcE5	\\x82d818582683581cecb218e1608a923dd881d9f15e3d0afd4f7395c734bfcf41d84ed181a10243190378001a0483bc72	f	\N	\N	910909092	\N	\N	\N
11	11	0	5oP9ib6ym3XjPogWkR2LWxjQ4EYEW8RS4XiFkXhiBjL5HUNdJPdioscWHGpJ4asi2h	\\x82d818582683581cede09116c2bec22a4f07244b0e9ce8000a70bb5ad9767da0f66b03ffa10243190378001aec27f9a6	f	\N	\N	910909092	\N	\N	\N
12	12	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681818181818181	\N	\N	\N
13	13	0	addr_test1qqsq556eza3c7epg2lqx0klhj53wvrt8x25xwng8enna5meqe88h2v0njcem8ekujualay06u6l7xhfpkf8nrkd47e7qu4gqjt	\\x00200a535917638f642857c067dbf79522e60d6732a8674d07cce7da6f20c9cf7531f39633b3e6dc973bfe91fae6bfe35d21b24f31d9b5f67c	f	\\x200a535917638f642857c067dbf79522e60d6732a8674d07cce7da6f	\N	3681818181818181	\N	\N	\N
14	14	0	addr_test1vrszxe5yja4a60qfhkjw72rk3ea2fflam8cyfg6y9x7hqnsdgml7e	\\x60e0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	f	\\xe0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	\N	3681818181818181	\N	\N	\N
15	15	0	addr_test1qzv82fe0zmztsrlpz0zhugjqrp9rnaqtctyewzdky493z0dn8pda7g3jpull6a2y8yv5d4ve4mpqvs5qumuqwk02ucjqcaszef	\\x009875272f16c4b80fe113c57e2240184a39f40bc2c99709b6254b113db3385bdf22320f3ffd7544391946d599aec2064280e6f80759eae624	f	\\x9875272f16c4b80fe113c57e2240184a39f40bc2c99709b6254b113d	\N	3681818181818181	\N	\N	\N
16	16	0	addr_test1vqpvwu4qkrz4e4yzwu7jmqsg4u36rd0gaanq0sm2dsxrhzga7jveu	\\x6002c772a0b0c55cd482773d2d8208af23a1b5e8ef6607c36a6c0c3b89	f	\\x02c772a0b0c55cd482773d2d8208af23a1b5e8ef6607c36a6c0c3b89	\N	3681818181818181	\N	\N	\N
17	17	0	addr_test1qra63x2yaxehtjujr2plz09zqkrm58qasrczelpljcw04jd3n6qlfzgmfhgyz4mzsrvd8tkwck3k47dnfx8d3zkzkx3scc2d52	\\x00fba89944e9b375cb921a83f13ca20587ba1c1d80f02cfc3f961cfac9b19e81f4891b4dd041576280d8d3aecec5a36af9b3498ed88ac2b1a3	f	\\xfba89944e9b375cb921a83f13ca20587ba1c1d80f02cfc3f961cfac9	\N	3681818181818181	\N	\N	\N
18	18	0	addr_test1vrg76dlde7z3xm0mnayjsgl8rvv5xqfhpv8pn0uksjxvsns4qxdwa	\\x60d1ed37edcf85136dfb9f492823e71b194301370b0e19bf96848cc84e	f	\\xd1ed37edcf85136dfb9f492823e71b194301370b0e19bf96848cc84e	\N	3681818181818181	\N	\N	\N
19	19	0	addr_test1qzlsssp28sgjp6pql5wzxt7lzrmxr7wtfku5ktt9gukr2qra0zn9cxtzx8eu0cjc9x878arsd6s9g6hf53tkyaw93l5s4wf76s	\\x00bf08402a3c1120e820fd1c232fdf10f661f9cb4db94b2d65472c35007d78a65c196231f3c7e258298fe3f4706ea0546ae9a4576275c58fe9	f	\\xbf08402a3c1120e820fd1c232fdf10f661f9cb4db94b2d65472c3500	\N	3681818181818190	\N	\N	\N
20	20	0	addr_test1vplxvfpdddnl5y6thzjjnrqm4hf83hgrwhmp252tszkpezq9gthd9	\\x607e66242d6b67fa134bb8a5298c1badd278dd0375f615514b80ac1c88	f	\\x7e66242d6b67fa134bb8a5298c1badd278dd0375f615514b80ac1c88	\N	3681818181818181	\N	\N	\N
21	21	0	addr_test1qp9vdwcaqmua09apgrrateftg0fs7s6u5s2rv7ey5vs2af722c7jrejdn75q03kvfztsu0e7rnuz90ey7kj5qhk62xdq9kax33	\\x004ac6bb1d06f9d797a140c7d5e52b43d30f435ca414367b24a320aea7ca563d21e64d9fa807c6cc48970e3f3e1cf822bf24f5a5405eda519a	f	\\x4ac6bb1d06f9d797a140c7d5e52b43d30f435ca414367b24a320aea7	\N	3681818181818181	\N	\N	\N
22	22	0	addr_test1vq9l45s4reh98fuwrjn4qkrz9yvc27v7xdgytepmmjgu0ycz4fsrs	\\x600bfad2151e6e53a78e1ca7505862291985799e335045e43bdc91c793	f	\\x0bfad2151e6e53a78e1ca7505862291985799e335045e43bdc91c793	\N	3681818181818190	\N	\N	\N
23	23	0	addr_test1vzgxzlqylfrsf3zy7hnnnx333sdh3gnvpjpk8juhvdafh0qytyupc	\\x6090617c04fa4704c444f5e7399a318c1b78a26c0c8363cb97637a9bbc	f	\\x90617c04fa4704c444f5e7399a318c1b78a26c0c8363cb97637a9bbc	\N	3681818181818181	\N	\N	\N
24	24	0	addr_test1qq6v2pma7l9npgppg7xpkpq68z0ffkqe7d3mkz3zxduy0dgxtqh4hxckkeeqeuf3c3z8ave84473l4wh98vszmy8lvysjsjajv	\\x0034c5077df7cb30a021478c1b041a389e94d819f363bb0a22337847b506582f5b9b16b6720cf131c4447eb327ad7d1fd5d729d9016c87fb09	f	\\x34c5077df7cb30a021478c1b041a389e94d819f363bb0a22337847b5	\N	3681818181818181	\N	\N	\N
25	25	0	addr_test1vzz9wh2ygjc9zghx2gzafehsya3kd6q68u03tpzyxk5je6gh0qfn4	\\x6084575d4444b05122e65205d4e6f0276366e81a3f1f15844435a92ce9	f	\\x84575d4444b05122e65205d4e6f0276366e81a3f1f15844435a92ce9	\N	3681818181818181	\N	\N	\N
26	26	0	addr_test1qqdxgqkdkjc2pm5czx5a2nh88mulwxu5jcn2mffcdfz4cr4pm04zey249huhjh6ren25t6fmpwk3fcydwfz55de406msnksmh0	\\x001a6402cdb4b0a0ee9811a9d54ee73ef9f71b949626ada5386a455c0ea1dbea2c91552df9795f43ccd545e93b0bad14e08d72454a37357eb7	f	\\x1a6402cdb4b0a0ee9811a9d54ee73ef9f71b949626ada5386a455c0e	\N	3681818181818181	\N	\N	\N
27	27	0	addr_test1qpcg3fx5y34q5j3x5kp8exgrcf0j2h8wdz0lr5cdd375l34z5df4jfeapy882fl999jzvkwdfrklkrn0hq9rsk7zavnq8wks32	\\x007088a4d4246a0a4a26a5827c9903c25f255cee689ff1d30d6c7d4fc6a2a35359273d090e7527e529642659cd48edfb0e6fb80a385bc2eb26	f	\\x7088a4d4246a0a4a26a5827c9903c25f255cee689ff1d30d6c7d4fc6	\N	3681818181818181	\N	\N	\N
28	28	0	addr_test1vql6x4mssryl9gckfadsk28hqje7w0s5g09x92zps7zjx3s7sf4ka	\\x603fa3577080c9f2a3164f5b0b28f704b3e73e1443ca62a84187852346	f	\\x3fa3577080c9f2a3164f5b0b28f704b3e73e1443ca62a84187852346	\N	3681818181818181	\N	\N	\N
29	29	0	addr_test1qzjypn0z5pw0vydpe5ep590f0w6swqugxhl205nut2sy3ysxfu4t6xxxtupsahfc5f7dpsjyjjw8elqjtysc5uzwnc0q42fu8s	\\x00a440cde2a05cf611a1cd321a15e97bb507038835fea7d27c5aa04892064f2abd18c65f030edd38a27cd0c244949c7cfc1259218a704e9e1e	f	\\xa440cde2a05cf611a1cd321a15e97bb507038835fea7d27c5aa04892	\N	3681818181818181	\N	\N	\N
30	30	0	addr_test1vp2tmj2mksv85795y2yftfn4vrnesyfztc6l2zxakrfdlec68tp95	\\x6054bdc95bb4187a78b4228895a67560e79811225e35f508ddb0d2dfe7	f	\\x54bdc95bb4187a78b4228895a67560e79811225e35f508ddb0d2dfe7	\N	3681818181818181	\N	\N	\N
31	31	0	addr_test1vpyf35awzt6u9cezhkjlza0vrcnqa5hfv0umgnxw29aygjsyr9ngv	\\x604898d3ae12f5c2e322bda5f175ec1e260ed2e963f9b44cce517a444a	f	\\x4898d3ae12f5c2e322bda5f175ec1e260ed2e963f9b44cce517a444a	\N	3681818181818181	\N	\N	\N
32	32	0	addr_test1qryu57z4ws92v6ky3ssz5jenmc8clq0rf480m7ff9u4rd07s7f6ppge9q7ycfclukc8nkhun68ljddd4cdkp9lts249qsktuj8	\\x00c9ca7855740aa66ac48c202a4b33de0f8f81e34d4efdf9292f2a36bfd0f27410a325078984e3fcb60f3b5f93d1ff26b5b5c36c12fd70554a	f	\\xc9ca7855740aa66ac48c202a4b33de0f8f81e34d4efdf9292f2a36bf	\N	3681818181818181	\N	\N	\N
33	33	0	addr_test1qpqk24ewfzykspkx9x68sj3aaazsfte9v5uvy58jq29vetjvlfaqedujwus2d5ljchg6aahth92ayw7te39pw2mg5dkqu2xsh5	\\x004165572e48896806c629b4784a3def4504af256538c250f2028accae4cfa7a0cb7927720a6d3f2c5d1aef6ebb955d23bcbcc4a172b68a36c	f	\\x4165572e48896806c629b4784a3def4504af256538c250f2028accae	\N	3681818181818181	\N	\N	\N
34	35	0	addr_test1qq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxrz9vjtaerrjhz8c4j6guxc4x4vyey7uf8amyyahgvlr2mqxvn2nm	\\x000fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818622b24bee46395c47c565a470d8a9aac2649ee24fdd909dba19f1ab6	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	15	500000000	\N	\N	\N
35	35	1	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681817681651228	\N	\N	\N
36	36	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681817681473231	\N	\N	\N
37	37	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681817681293914	\N	\N	\N
72	66	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681814878327629	\N	\N	\N
38	38	0	addr_test1qqdxgqkdkjc2pm5czx5a2nh88mulwxu5jcn2mffcdfz4cr4pm04zey249huhjh6ren25t6fmpwk3fcydwfz55de406msnksmh0	\\x001a6402cdb4b0a0ee9811a9d54ee73ef9f71b949626ada5386a455c0ea1dbea2c91552df9795f43ccd545e93b0bad14e08d72454a37357eb7	f	\\x1a6402cdb4b0a0ee9811a9d54ee73ef9f71b949626ada5386a455c0e	7	3681818181637632	\N	\N	\N
39	39	0	addr_test1qqdxgqkdkjc2pm5czx5a2nh88mulwxu5jcn2mffcdfz4cr4pm04zey249huhjh6ren25t6fmpwk3fcydwfz55de406msnksmh0	\\x001a6402cdb4b0a0ee9811a9d54ee73ef9f71b949626ada5386a455c0ea1dbea2c91552df9795f43ccd545e93b0bad14e08d72454a37357eb7	f	\\x1a6402cdb4b0a0ee9811a9d54ee73ef9f71b949626ada5386a455c0e	7	3681818181443619	\N	\N	\N
40	40	0	addr_test1qq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxyjd0acu4nzay7nvu3pg22kxjhnqdscskgudvexeuxdphgsa0w2ca	\\x000fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818926bfb8e5662e93d3672214295634af3036188591c6b326cf0cd0dd1	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	20	600000000	\N	\N	\N
41	40	1	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681817081126961	\N	\N	\N
42	41	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681817080948964	\N	\N	\N
43	42	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681817080769647	\N	\N	\N
44	43	0	addr_test1qzjypn0z5pw0vydpe5ep590f0w6swqugxhl205nut2sy3ysxfu4t6xxxtupsahfc5f7dpsjyjjw8elqjtysc5uzwnc0q42fu8s	\\x00a440cde2a05cf611a1cd321a15e97bb507038835fea7d27c5aa04892064f2abd18c65f030edd38a27cd0c244949c7cfc1259218a704e9e1e	f	\\xa440cde2a05cf611a1cd321a15e97bb507038835fea7d27c5aa04892	9	3681818181637632	\N	\N	\N
45	44	0	addr_test1qzjypn0z5pw0vydpe5ep590f0w6swqugxhl205nut2sy3ysxfu4t6xxxtupsahfc5f7dpsjyjjw8elqjtysc5uzwnc0q42fu8s	\\x00a440cde2a05cf611a1cd321a15e97bb507038835fea7d27c5aa04892064f2abd18c65f030edd38a27cd0c244949c7cfc1259218a704e9e1e	f	\\xa440cde2a05cf611a1cd321a15e97bb507038835fea7d27c5aa04892	9	3681818181446391	\N	\N	\N
46	45	0	addr_test1qq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsx9mca4svzwhsq4w95e78udpmp27g3ppvfawu58mnsxa9q7qtuyw5w	\\x000fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818bbc76b0609d7802ae2d33e3f1a1d855e44421627aee50fb9c0dd283c	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	19	200000000	\N	\N	\N
47	45	1	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681816880602694	\N	\N	\N
48	46	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681816880424697	\N	\N	\N
49	47	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681816880245380	\N	\N	\N
50	48	0	addr_test1qq6v2pma7l9npgppg7xpkpq68z0ffkqe7d3mkz3zxduy0dgxtqh4hxckkeeqeuf3c3z8ave84473l4wh98vszmy8lvysjsjajv	\\x0034c5077df7cb30a021478c1b041a389e94d819f363bb0a22337847b506582f5b9b16b6720cf131c4447eb327ad7d1fd5d729d9016c87fb09	f	\\x34c5077df7cb30a021478c1b041a389e94d819f363bb0a22337847b5	6	3681818181637632	\N	\N	\N
51	49	0	addr_test1qq6v2pma7l9npgppg7xpkpq68z0ffkqe7d3mkz3zxduy0dgxtqh4hxckkeeqeuf3c3z8ave84473l4wh98vszmy8lvysjsjajv	\\x0034c5077df7cb30a021478c1b041a389e94d819f363bb0a22337847b506582f5b9b16b6720cf131c4447eb327ad7d1fd5d729d9016c87fb09	f	\\x34c5077df7cb30a021478c1b041a389e94d819f363bb0a22337847b5	6	3681818181443619	\N	\N	\N
52	50	0	addr_test1qq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqg57tegmur7lenke0flen4vjhgphxpjhdlg3l2tvk50rxs6mkul2	\\x000fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa281808a797946f83f7f33b65e9fe67564ae80dcc195dbf447ea5b2d478cd	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	22	500000000	\N	\N	\N
53	50	1	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681816380078427	\N	\N	\N
54	51	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681816379900430	\N	\N	\N
55	52	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681816379721113	\N	\N	\N
56	53	0	addr_test1qpcg3fx5y34q5j3x5kp8exgrcf0j2h8wdz0lr5cdd375l34z5df4jfeapy882fl999jzvkwdfrklkrn0hq9rsk7zavnq8wks32	\\x007088a4d4246a0a4a26a5827c9903c25f255cee689ff1d30d6c7d4fc6a2a35359273d090e7527e529642659cd48edfb0e6fb80a385bc2eb26	f	\\x7088a4d4246a0a4a26a5827c9903c25f255cee689ff1d30d6c7d4fc6	8	3681818181637632	\N	\N	\N
57	54	0	addr_test1qpcg3fx5y34q5j3x5kp8exgrcf0j2h8wdz0lr5cdd375l34z5df4jfeapy882fl999jzvkwdfrklkrn0hq9rsk7zavnq8wks32	\\x007088a4d4246a0a4a26a5827c9903c25f255cee689ff1d30d6c7d4fc6a2a35359273d090e7527e529642659cd48edfb0e6fb80a385bc2eb26	f	\\x7088a4d4246a0a4a26a5827c9903c25f255cee689ff1d30d6c7d4fc6	8	3681818181443619	\N	\N	\N
58	55	0	addr_test1qq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqv6hv3lklfxq54ayq6wukwr29lmz3yyk9xsqhszuaak7eqwjvkmh	\\x000fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa28180cd5d91fdbe930295e901a772ce1a8bfd8a24258a6802f0173bdb7b2	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	18	500000000	\N	\N	\N
59	55	1	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681815879554160	\N	\N	\N
60	56	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681815879376163	\N	\N	\N
61	57	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681815879196846	\N	\N	\N
62	58	0	addr_test1qqsq556eza3c7epg2lqx0klhj53wvrt8x25xwng8enna5meqe88h2v0njcem8ekujualay06u6l7xhfpkf8nrkd47e7qu4gqjt	\\x00200a535917638f642857c067dbf79522e60d6732a8674d07cce7da6f20c9cf7531f39633b3e6dc973bfe91fae6bfe35d21b24f31d9b5f67c	f	\\x200a535917638f642857c067dbf79522e60d6732a8674d07cce7da6f	1	3681818181637632	\N	\N	\N
63	59	0	addr_test1qqsq556eza3c7epg2lqx0klhj53wvrt8x25xwng8enna5meqe88h2v0njcem8ekujualay06u6l7xhfpkf8nrkd47e7qu4gqjt	\\x00200a535917638f642857c067dbf79522e60d6732a8674d07cce7da6f20c9cf7531f39633b3e6dc973bfe91fae6bfe35d21b24f31d9b5f67c	f	\\x200a535917638f642857c067dbf79522e60d6732a8674d07cce7da6f	1	3681818181443619	\N	\N	\N
64	60	0	addr_test1qq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxr3rspflsf8v8m5gvpqlemyyp55k0heel0ce547tchxpdfsppqq8c	\\x000fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818711c029fc12761f7443020fe76420694b3ef9cfdf8cd2be5e2e60b53	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	12	500000000	\N	\N	\N
65	60	1	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681815379029893	\N	\N	\N
66	61	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681815378851896	\N	\N	\N
67	62	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681815378672579	\N	\N	\N
68	63	0	addr_test1qzv82fe0zmztsrlpz0zhugjqrp9rnaqtctyewzdky493z0dn8pda7g3jpull6a2y8yv5d4ve4mpqvs5qumuqwk02ucjqcaszef	\\x009875272f16c4b80fe113c57e2240184a39f40bc2c99709b6254b113db3385bdf22320f3ffd7544391946d599aec2064280e6f80759eae624	f	\\x9875272f16c4b80fe113c57e2240184a39f40bc2c99709b6254b113d	2	3681818181637632	\N	\N	\N
69	64	0	addr_test1qzv82fe0zmztsrlpz0zhugjqrp9rnaqtctyewzdky493z0dn8pda7g3jpull6a2y8yv5d4ve4mpqvs5qumuqwk02ucjqcaszef	\\x009875272f16c4b80fe113c57e2240184a39f40bc2c99709b6254b113db3385bdf22320f3ffd7544391946d599aec2064280e6f80759eae624	f	\\x9875272f16c4b80fe113c57e2240184a39f40bc2c99709b6254b113d	2	3681818181443619	\N	\N	\N
70	65	0	addr_test1qq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxxe4fp8hcee2aa3wwcctneu3xry0vf93mvlhd7rshaupmrqz4tacl	\\x000fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818d9aa427be339577b173b185cf3c898647b1258ed9fbb7c385fbc0ec6	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	14	500000000	\N	\N	\N
71	65	1	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681814878505626	\N	\N	\N
73	67	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681814878148312	\N	\N	\N
74	68	0	addr_test1qpqk24ewfzykspkx9x68sj3aaazsfte9v5uvy58jq29vetjvlfaqedujwus2d5ljchg6aahth92ayw7te39pw2mg5dkqu2xsh5	\\x004165572e48896806c629b4784a3def4504af256538c250f2028accae4cfa7a0cb7927720a6d3f2c5d1aef6ebb955d23bcbcc4a172b68a36c	f	\\x4165572e48896806c629b4784a3def4504af256538c250f2028accae	11	3681818181637632	\N	\N	\N
75	69	0	addr_test1qpqk24ewfzykspkx9x68sj3aaazsfte9v5uvy58jq29vetjvlfaqedujwus2d5ljchg6aahth92ayw7te39pw2mg5dkqu2xsh5	\\x004165572e48896806c629b4784a3def4504af256538c250f2028accae4cfa7a0cb7927720a6d3f2c5d1aef6ebb955d23bcbcc4a172b68a36c	f	\\x4165572e48896806c629b4784a3def4504af256538c250f2028accae	11	3681818181443619	\N	\N	\N
76	70	0	addr_test1qq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxxe8nfs9fwktmltm28vhctlcgudnjxsz66f6pd62703eh2sr002f8	\\x000fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818d93cd302a5d65efebda8ecbe17fc238d9c8d016b49d05ba579f1cdd5	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	16	300000000	\N	\N	\N
77	70	1	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681814577981359	\N	\N	\N
78	71	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681814577803362	\N	\N	\N
79	72	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681814577624045	\N	\N	\N
80	73	0	addr_test1qryu57z4ws92v6ky3ssz5jenmc8clq0rf480m7ff9u4rd07s7f6ppge9q7ycfclukc8nkhun68ljddd4cdkp9lts249qsktuj8	\\x00c9ca7855740aa66ac48c202a4b33de0f8f81e34d4efdf9292f2a36bfd0f27410a325078984e3fcb60f3b5f93d1ff26b5b5c36c12fd70554a	f	\\xc9ca7855740aa66ac48c202a4b33de0f8f81e34d4efdf9292f2a36bf	10	3681818181637632	\N	\N	\N
81	74	0	addr_test1qryu57z4ws92v6ky3ssz5jenmc8clq0rf480m7ff9u4rd07s7f6ppge9q7ycfclukc8nkhun68ljddd4cdkp9lts249qsktuj8	\\x00c9ca7855740aa66ac48c202a4b33de0f8f81e34d4efdf9292f2a36bfd0f27410a325078984e3fcb60f3b5f93d1ff26b5b5c36c12fd70554a	f	\\xc9ca7855740aa66ac48c202a4b33de0f8f81e34d4efdf9292f2a36bf	10	3681818181446391	\N	\N	\N
82	75	0	addr_test1qryu57z4ws92v6ky3ssz5jenmc8clq0rf480m7ff9u4rd07s7f6ppge9q7ycfclukc8nkhun68ljddd4cdkp9lts249qsktuj8	\\x00c9ca7855740aa66ac48c202a4b33de0f8f81e34d4efdf9292f2a36bfd0f27410a325078984e3fcb60f3b5f93d1ff26b5b5c36c12fd70554a	f	\\xc9ca7855740aa66ac48c202a4b33de0f8f81e34d4efdf9292f2a36bf	10	3681818181265842	\N	\N	\N
83	76	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681814577439800	\N	\N	\N
84	77	0	addr_test1qq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsx8ksf06ujgvhrfl44v6yr9seu4yz3ewxc6gqysqmck6ywts7jz760	\\x000fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818f6825fae490cb8d3fad59a20cb0cf2a41472e3634801200de2da2397	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	17	300000000	\N	\N	\N
85	77	1	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681814277272847	\N	\N	\N
86	78	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681814277094850	\N	\N	\N
87	79	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681814276915533	\N	\N	\N
88	80	0	addr_test1qra63x2yaxehtjujr2plz09zqkrm58qasrczelpljcw04jd3n6qlfzgmfhgyz4mzsrvd8tkwck3k47dnfx8d3zkzkx3scc2d52	\\x00fba89944e9b375cb921a83f13ca20587ba1c1d80f02cfc3f961cfac9b19e81f4891b4dd041576280d8d3aecec5a36af9b3498ed88ac2b1a3	f	\\xfba89944e9b375cb921a83f13ca20587ba1c1d80f02cfc3f961cfac9	3	3681818181637632	\N	\N	\N
89	81	0	addr_test1qra63x2yaxehtjujr2plz09zqkrm58qasrczelpljcw04jd3n6qlfzgmfhgyz4mzsrvd8tkwck3k47dnfx8d3zkzkx3scc2d52	\\x00fba89944e9b375cb921a83f13ca20587ba1c1d80f02cfc3f961cfac9b19e81f4891b4dd041576280d8d3aecec5a36af9b3498ed88ac2b1a3	f	\\xfba89944e9b375cb921a83f13ca20587ba1c1d80f02cfc3f961cfac9	3	3681818181446391	\N	\N	\N
90	82	0	addr_test1qra63x2yaxehtjujr2plz09zqkrm58qasrczelpljcw04jd3n6qlfzgmfhgyz4mzsrvd8tkwck3k47dnfx8d3zkzkx3scc2d52	\\x00fba89944e9b375cb921a83f13ca20587ba1c1d80f02cfc3f961cfac9b19e81f4891b4dd041576280d8d3aecec5a36af9b3498ed88ac2b1a3	f	\\xfba89944e9b375cb921a83f13ca20587ba1c1d80f02cfc3f961cfac9	3	3681818181265842	\N	\N	\N
91	83	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681814276731288	\N	\N	\N
92	84	0	addr_test1qq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsx9ejdnrrnaxz5udh48ptfe8gft0p8a2f4xxujjyksgeestsfapsf5	\\x000fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818b9936631cfa61538dbd4e15a7274256f09faa4d4c6e4a44b4119cc17	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	13	500000000	\N	\N	\N
93	84	1	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681813776564335	\N	\N	\N
94	85	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681813776386338	\N	\N	\N
95	86	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681813776207021	\N	\N	\N
96	87	0	addr_test1qp9vdwcaqmua09apgrrateftg0fs7s6u5s2rv7ey5vs2af722c7jrejdn75q03kvfztsu0e7rnuz90ey7kj5qhk62xdq9kax33	\\x004ac6bb1d06f9d797a140c7d5e52b43d30f435ca414367b24a320aea7ca563d21e64d9fa807c6cc48970e3f3e1cf822bf24f5a5405eda519a	f	\\x4ac6bb1d06f9d797a140c7d5e52b43d30f435ca414367b24a320aea7	5	3681818181637632	\N	\N	\N
97	88	0	addr_test1qp9vdwcaqmua09apgrrateftg0fs7s6u5s2rv7ey5vs2af722c7jrejdn75q03kvfztsu0e7rnuz90ey7kj5qhk62xdq9kax33	\\x004ac6bb1d06f9d797a140c7d5e52b43d30f435ca414367b24a320aea7ca563d21e64d9fa807c6cc48970e3f3e1cf822bf24f5a5405eda519a	f	\\x4ac6bb1d06f9d797a140c7d5e52b43d30f435ca414367b24a320aea7	5	3681818181443575	\N	\N	\N
98	89	0	addr_test1qp9vdwcaqmua09apgrrateftg0fs7s6u5s2rv7ey5vs2af722c7jrejdn75q03kvfztsu0e7rnuz90ey7kj5qhk62xdq9kax33	\\x004ac6bb1d06f9d797a140c7d5e52b43d30f435ca414367b24a320aea7ca563d21e64d9fa807c6cc48970e3f3e1cf822bf24f5a5405eda519a	f	\\x4ac6bb1d06f9d797a140c7d5e52b43d30f435ca414367b24a320aea7	5	3681818181263026	\N	\N	\N
99	90	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681813776022776	\N	\N	\N
100	91	0	addr_test1qq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqtnnx2gj96w5r0ffjwgxa3ld6v9wjr3ktanywey28333sq5rpx0n	\\x000fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa28180b9ccca448ba7506f4a64e41bb1fb74c2ba438d97d991d9228f18c60	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	21	500000000	\N	\N	\N
101	91	1	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681813275855823	\N	\N	\N
102	92	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681813275677826	\N	\N	\N
103	93	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681813275498509	\N	\N	\N
104	94	0	addr_test1qzlsssp28sgjp6pql5wzxt7lzrmxr7wtfku5ktt9gukr2qra0zn9cxtzx8eu0cjc9x878arsd6s9g6hf53tkyaw93l5s4wf76s	\\x00bf08402a3c1120e820fd1c232fdf10f661f9cb4db94b2d65472c35007d78a65c196231f3c7e258298fe3f4706ea0546ae9a4576275c58fe9	f	\\xbf08402a3c1120e820fd1c232fdf10f661f9cb4db94b2d65472c3500	4	3681818181637641	\N	\N	\N
105	95	0	addr_test1qzlsssp28sgjp6pql5wzxt7lzrmxr7wtfku5ktt9gukr2qra0zn9cxtzx8eu0cjc9x878arsd6s9g6hf53tkyaw93l5s4wf76s	\\x00bf08402a3c1120e820fd1c232fdf10f661f9cb4db94b2d65472c35007d78a65c196231f3c7e258298fe3f4706ea0546ae9a4576275c58fe9	f	\\xbf08402a3c1120e820fd1c232fdf10f661f9cb4db94b2d65472c3500	4	3681818181443584	\N	\N	\N
106	96	0	addr_test1qzlsssp28sgjp6pql5wzxt7lzrmxr7wtfku5ktt9gukr2qra0zn9cxtzx8eu0cjc9x878arsd6s9g6hf53tkyaw93l5s4wf76s	\\x00bf08402a3c1120e820fd1c232fdf10f661f9cb4db94b2d65472c35007d78a65c196231f3c7e258298fe3f4706ea0546ae9a4576275c58fe9	f	\\xbf08402a3c1120e820fd1c232fdf10f661f9cb4db94b2d65472c3500	4	3681818181263035	\N	\N	\N
107	97	0	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3681813275314264	\N	\N	\N
108	98	0	addr_test1wpnlxv2xv9a9ucvnvzqakwepzl9ltx7jzgm53av2e9ncv4sysemm8	\\x7067f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	t	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	\N	100000000	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	\N	\N
109	98	1	addr_test1vrszxe5yja4a60qfhkjw72rk3ea2fflam8cyfg6y9x7hqnsdgml7e	\\x60e0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	f	\\xe0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	\N	3681818081650832	\N	\N	\N
110	99	0	addr_test1vrszxe5yja4a60qfhkjw72rk3ea2fflam8cyfg6y9x7hqnsdgml7e	\\x60e0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	f	\\xe0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	\N	99828910	\N	\N	\N
111	100	0	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	\\x702618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	100000000	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	2	\N
112	100	1	addr_test1vrszxe5yja4a60qfhkjw72rk3ea2fflam8cyfg6y9x7hqnsdgml7e	\\x60e0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	f	\\xe0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	\N	3681817981484759	\N	\N	\N
113	101	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	2
114	101	1	addr_test1vrszxe5yja4a60qfhkjw72rk3ea2fflam8cyfg6y9x7hqnsdgml7e	\\x60e0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	f	\\xe0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	\N	3681817881314374	\N	\N	\N
115	102	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	3
116	102	1	addr_test1vrszxe5yja4a60qfhkjw72rk3ea2fflam8cyfg6y9x7hqnsdgml7e	\\x60e0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	f	\\xe0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	\N	3681817781146585	\N	\N	\N
117	103	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	1
118	103	1	addr_test1vrszxe5yja4a60qfhkjw72rk3ea2fflam8cyfg6y9x7hqnsdgml7e	\\x60e0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	f	\\xe0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	\N	3681817680979940	\N	\N	\N
119	104	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	4
120	104	1	addr_test1vrszxe5yja4a60qfhkjw72rk3ea2fflam8cyfg6y9x7hqnsdgml7e	\\x60e0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	f	\\xe0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	\N	3681817580717067	\N	\N	\N
121	105	0	addr_test1wzem0yuxjqyrmzvrsr8xfqhumyy555ngyjxw7wrg2pav90q8cagu2	\\x70b3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	t	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	\N	100000000	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	3	\N
122	105	1	addr_test1vrszxe5yja4a60qfhkjw72rk3ea2fflam8cyfg6y9x7hqnsdgml7e	\\x60e0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	f	\\xe0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	\N	3681817480550950	\N	\N	\N
123	106	0	addr_test1vrszxe5yja4a60qfhkjw72rk3ea2fflam8cyfg6y9x7hqnsdgml7e	\\x60e0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	f	\\xe0236684976bdd3c09bda4ef28768e7aa4a7fdd9f044a34429bd704e	\N	3681817580223603	\N	\N	\N
124	107	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\N	\N	\N
125	107	1	addr_test1vrg76dlde7z3xm0mnayjsgl8rvv5xqfhpv8pn0uksjxvsns4qxdwa	\\x60d1ed37edcf85136dfb9f492823e71b194301370b0e19bf96848cc84e	f	\\xd1ed37edcf85136dfb9f492823e71b194301370b0e19bf96848cc84e	\N	3681818171642252	\N	\N	\N
126	108	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000000000	\N	\N	\N
127	108	1	addr_test1qrml5hwl9s7ydm2djyup95ud6s74skkl4zzf8zk657s8thgm78sn3uhch64ujc7ffnpga68dfdqhg3sp7tk6759jrm7spy03k9	\\x00f7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd1bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	f	\\xf7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd	47	5000000000000	\N	\N	\N
128	108	2	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	5000000000000	\N	\N	\N
129	108	3	addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k	\\x00594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	f	\\x594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0	49	5000000000000	\N	\N	\N
130	108	4	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	5000000000000	\N	\N	\N
131	108	5	addr_test1vq8aee3zhkq4awq7lwsfz47nk3y5aykxh6wa3fnmcj4zsxqp42jvd	\\x600fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	f	\\x0fdce622bd815eb81efba09157d3b4494e92c6be9dd8a67bc4aa2818	\N	3656813275134639	\N	\N	\N
132	109	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\N	\N	\N
133	109	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999989767575	\N	\N	\N
134	110	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\\x81cb2989cbf6c49840511d8d3451ee44f58dde2c074fc749d05deb51eeb33741	4	\N
135	110	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999979582758	\N	\N	\N
136	111	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	1000000	\N	\N	\N
137	111	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999978400405	\N	\N	\N
138	112	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999978228832	\N	\N	\N
139	113	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	5	\N
140	113	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999967993987	\N	\N	\N
141	114	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	20000000	\N	\N	\N
142	114	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999957819554	\N	\N	\N
143	115	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	20000000	\N	\N	\N
144	115	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999937648553	\N	\N	\N
145	116	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999937474472	\N	\N	\N
146	117	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	19826843	\N	\N	\N
147	118	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
148	118	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999927281647	\N	\N	\N
149	119	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
150	119	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999927085390	\N	\N	\N
151	120	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999936910473	\N	\N	\N
152	121	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
153	121	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999926717648	\N	\N	\N
154	122	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9826843	\N	\N	\N
155	123	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
156	123	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999926350082	\N	\N	\N
157	124	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9824995	\N	\N	\N
158	125	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9651838	\N	\N	\N
159	126	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
160	126	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999925796335	\N	\N	\N
161	127	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
162	127	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999925616094	\N	\N	\N
163	128	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
164	128	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999925424985	\N	\N	\N
165	129	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
166	129	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999915235988	\N	\N	\N
167	130	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
168	130	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	9811047	\N	\N	\N
169	131	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999934867806	\N	\N	\N
170	132	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	1000000000	\N	\N	\N
171	132	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998934699401	\N	\N	\N
172	133	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	99675351	\N	\N	\N
173	133	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	100000000	\N	\N	\N
174	133	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	100000000	\N	\N	\N
175	133	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	100000000	\N	\N	\N
176	133	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	100000000	\N	\N	\N
177	133	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	50000000	\N	\N	\N
178	133	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	50000000	\N	\N	\N
179	133	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	50000000	\N	\N	\N
180	133	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	50000000	\N	\N	\N
181	133	9	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	50000000	\N	\N	\N
182	133	10	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	25000000	\N	\N	\N
183	133	11	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	25000000	\N	\N	\N
184	133	12	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	25000000	\N	\N	\N
185	133	13	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	25000000	\N	\N	\N
186	133	14	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	25000000	\N	\N	\N
187	133	15	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	12500000	\N	\N	\N
188	133	16	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	12500000	\N	\N	\N
189	133	17	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	12500000	\N	\N	\N
190	133	18	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	12500000	\N	\N	\N
191	133	19	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	12500000	\N	\N	\N
192	133	20	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	6250000	\N	\N	\N
193	133	21	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	6250000	\N	\N	\N
194	133	22	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	6250000	\N	\N	\N
195	133	23	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	6250000	\N	\N	\N
196	133	24	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	6250000	\N	\N	\N
197	133	25	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	3125000	\N	\N	\N
198	133	26	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	52	3125000	\N	\N	\N
199	133	27	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	3125000	\N	\N	\N
200	133	28	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2udu23jwmu3vv4ueerv2v3y297867je6hgmf7d3x9kt8a0sppz6xj	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab8de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	53	3125000	\N	\N	\N
201	133	29	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	3125000	\N	\N	\N
202	133	30	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl260fns203p8v3epg6azv0c4fhlv3c0h4rwca4gled76cl2q0xma9p	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab4f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	54	3125000	\N	\N	\N
203	133	31	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	3125000	\N	\N	\N
204	133	32	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2c07vvjx24rz5vsqr44nn8wzauyl2q7tsy3yn4ce8dc57jqze2tya	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab0ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	55	3125000	\N	\N	\N
205	133	33	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	3125000	\N	\N	\N
206	133	34	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	3125000	\N	\N	\N
207	134	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	499576915	\N	\N	\N
208	134	1	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	249918838	\N	\N	\N
209	134	2	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	124959419	\N	\N	\N
210	134	3	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	62479709	\N	\N	\N
211	134	4	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	31239855	\N	\N	\N
212	134	5	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	15619927	\N	\N	\N
213	134	6	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	7809964	\N	\N	\N
214	134	7	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	3904982	\N	\N	\N
215	134	8	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	3904981	\N	\N	\N
216	135	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl27w23v6rd924yufrphc9xjd3ymmqly942vh3vktq0vy00zse2a6hw	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fabce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	56	499375158	\N	\N	\N
217	136	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
218	136	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998931521844	\N	\N	\N
219	137	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2827019	\N	\N	\N
220	138	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
221	138	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998928337995	\N	\N	\N
222	139	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2820947	\N	\N	\N
223	140	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
224	140	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998923169590	\N	\N	\N
225	142	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999357290533	\N	\N	\N
226	142	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999571355274	\N	\N	\N
227	143	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999357290533	\N	\N	\N
228	143	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999571185109	\N	\N	\N
229	144	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
230	144	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999561016704	\N	\N	\N
231	145	0	addr_test1qzn2qltgr0j2fcxzg0js66cluxx7xvhuh899yf34usmn20cv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqsp5vtu	\\x00a6a07d681be4a4e0c243e50d6b1fe18de332fcb9ca522635e437353f0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xa6a07d681be4a4e0c243e50d6b1fe18de332fcb9ca522635e437353f	62	3000000	\N	\N	\N
232	145	1	addr_test1qz0y5r8mehmey3gj9frqs0ksc0hl3jmmlkhxx7a37ee99vsv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqaf4lm9	\\x009e4a0cfbcdf79245122a46083ed0c3eff8cb7bfdae637bb1f67252b20caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x9e4a0cfbcdf79245122a46083ed0c3eff8cb7bfdae637bb1f67252b2	62	3000000	\N	\N	\N
233	145	2	addr_test1qqx9udrlxfz8wqjgqu9snqqahn2ldycjtayddslnpcyu2dcv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqef8wyz	\\x000c5e347f3244770248070b09801dbcd5f693125f48d6c3f30e09c5370caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x0c5e347f3244770248070b09801dbcd5f693125f48d6c3f30e09c537	62	3000000	\N	\N	\N
234	145	3	addr_test1qpyfl38ypu6pj3gcdqrvgyv2re5fvsk262qs5wdptn0typgv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqjat73t	\\x00489fc4e40f341945186806c4118a1e689642cad2810a39a15cdeb2050caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x489fc4e40f341945186806c4118a1e689642cad2810a39a15cdeb205	62	3000000	\N	\N	\N
235	145	4	addr_test1qpa5zp4nnh66r0maqaf7jjfcs49hh6vkxch8jydwa2duf7cv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq3ff95m	\\x007b4106b39df5a1bf7d0753e94938854b7be996362e7911aeea9bc4fb0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x7b4106b39df5a1bf7d0753e94938854b7be996362e7911aeea9bc4fb	62	3000000	\N	\N	\N
236	145	5	addr_test1qrhpl0n7yejdw6srhu4acat5qa5ymfeamr4ljs2qeqvrhegv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqf5tkkh	\\x00ee1fbe7e2664d76a03bf2bdc757407684da73dd8ebf94140c8183be50caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xee1fbe7e2664d76a03bf2bdc757407684da73dd8ebf94140c8183be5	62	3000000	\N	\N	\N
237	145	6	addr_test1qzhyayc3mdcnl578jk2amawat72w5cy96cvj5g7xthltxnqv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq2d5607	\\x00ae4e9311db713fd3c79595ddf5dd5f94ea6085d6192a23c65dfeb34c0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xae4e9311db713fd3c79595ddf5dd5f94ea6085d6192a23c65dfeb34c	62	3000000	\N	\N	\N
238	145	7	addr_test1qr4tfu300j0fz3ezq5qaernpudaejjc38lcgekam69ctt7qv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqy8u7jn	\\x00eab4f22f7c9e9147220501dc8e61e37b994b113ff08cdbbbd170b5f80caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xeab4f22f7c9e9147220501dc8e61e37b994b113ff08cdbbbd170b5f8	62	3000000	\N	\N	\N
239	145	8	addr_test1qppcpmhsttvegr85k0ykak3k0awzhkne39t09j0nr7xd4tcv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqw4yeuy	\\x004380eef05ad9940cf4b3c96eda367f5c2bda798956f2c9f31f8cdaaf0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x4380eef05ad9940cf4b3c96eda367f5c2bda798956f2c9f31f8cdaaf	62	3000000	\N	\N	\N
240	145	9	addr_test1qrkmqndeknja8lsfmfwhdzdu3h65c07d75xup0l693quj3qv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqm55swe	\\x00edb04db9b4e5d3fe09da5d7689bc8df54c3fcdf50dc0bffa2c41c9440caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xedb04db9b4e5d3fe09da5d7689bc8df54c3fcdf50dc0bffa2c41c944	62	3000000	\N	\N	\N
241	145	10	addr_test1qrcx0sr46j6qt5h80lesqftcvad4hjmedp68ed8kzxl7ueqv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqz84rh0	\\x00f067c075d4b405d2e77ff3002578675b5bcb7968747cb4f611bfee640caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xf067c075d4b405d2e77ff3002578675b5bcb7968747cb4f611bfee64	62	3000000	\N	\N	\N
242	145	11	addr_test1qzrwxlw3tsft56futcqjpyf29u6va6s3k6rd6x32h4xmcwqv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqkvs58d	\\x0086e37dd15c12ba693c5e0120912a2f34ceea11b686dd1a2abd4dbc380caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x86e37dd15c12ba693c5e0120912a2f34ceea11b686dd1a2abd4dbc38	62	3000000	\N	\N	\N
243	145	12	addr_test1qrv5073xe6cjvu30npk5rcjvjmt39jmmx7c37xwazr2up3sv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq5t25kq	\\x00d947fa26ceb126722f986d41e24c96d712cb7b37b11f19dd10d5c0c60caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xd947fa26ceb126722f986d41e24c96d712cb7b37b11f19dd10d5c0c6	62	3000000	\N	\N	\N
244	145	13	addr_test1qz0fssqz2k3xdaz4qa0rwjhcdtpdp9x49zf92rwkxfxy67sv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqjcysy9	\\x009e98400255a266f455075e374af86ac2d094d52892550dd6324c4d7a0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x9e98400255a266f455075e374af86ac2d094d52892550dd6324c4d7a	62	3000000	\N	\N	\N
245	145	14	addr_test1qzjwxq5l5km5ml4vncm0mruukld4dxrfgv4jayuyu2dz0pqv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqhd6uxl	\\x00a4e3029fa5b74dfeac9e36fd8f9cb7db569869432b2e9384e29a27840caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xa4e3029fa5b74dfeac9e36fd8f9cb7db569869432b2e9384e29a2784	62	3000000	\N	\N	\N
246	145	15	addr_test1qpvnc0samqs2hlfs8da8wq7tayjkv4auqperzy5kcnfgh9gv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq096s40	\\x00593c3e1dd820abfd303b7a7703cbe9256657bc0072311296c4d28b950caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x593c3e1dd820abfd303b7a7703cbe9256657bc0072311296c4d28b95	62	3000000	\N	\N	\N
247	145	16	addr_test1qrw2xljjuayaxm66sevdurm8k2u7paag844v48mfphryr7gv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqvwv28y	\\x00dca37e52e749d36f5a8658de0f67b2b9e0f7a83d6aca9f690dc641f90caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xdca37e52e749d36f5a8658de0f67b2b9e0f7a83d6aca9f690dc641f9	62	3000000	\N	\N	\N
248	145	17	addr_test1qztya82lxttjcejhfqgvu3pdhgfp4qqy4z2rhfekpdk5pggv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqftq7ul	\\x00964e9d5f32d72c66574810ce442dba121a8004a8943ba7360b6d40a10caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x964e9d5f32d72c66574810ce442dba121a8004a8943ba7360b6d40a1	62	3000000	\N	\N	\N
249	145	18	addr_test1qzkc3tw2twlunhp9yqstswarax2q52qwjmgsv96gc7tjfugv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqp9f2tf	\\x00ad88adca5bbfc9dc252020b83ba3e9940a280e96d1061748c79724f10caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xad88adca5bbfc9dc252020b83ba3e9940a280e96d1061748c79724f1	62	3000000	\N	\N	\N
250	145	19	addr_test1qqf5pszrupejmvrwylxan9e9nl8ucrqnw095vgcuyg6eewsv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqs78ntq	\\x001340c043e0732db06e27cdd997259fcfcc0c1373cb46231c22359cba0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x1340c043e0732db06e27cdd997259fcfcc0c1373cb46231c22359cba	62	3000000	\N	\N	\N
251	145	20	addr_test1qr798k4s2um65rxpnvjr4xd3u8zatw8lwrkcdh6g96lc3esv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqfp9lkv	\\x00fc53dab05737aa0cc19b243a99b1e1c5d5b8ff70ed86df482ebf88e60caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xfc53dab05737aa0cc19b243a99b1e1c5d5b8ff70ed86df482ebf88e6	62	3000000	\N	\N	\N
252	145	21	addr_test1qpezc3hrun0gcjpeftv0rffwsl8cq790umjypcnmp9ltjzsv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq0tupll	\\x00722c46e3e4de8c48394ad8f1a52e87cf8078afe6e440e27b097eb90a0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x722c46e3e4de8c48394ad8f1a52e87cf8078afe6e440e27b097eb90a	62	3000000	\N	\N	\N
253	145	22	addr_test1qpnedrgyuwx07qkdkwmlknmspezrcwsr9sgf776zwa52fdsv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqwjh93r	\\x0067968d04e38cff02cdb3b7fb4f700e443c3a032c109f7b427768a4b60caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x67968d04e38cff02cdb3b7fb4f700e443c3a032c109f7b427768a4b6	62	3000000	\N	\N	\N
254	145	23	addr_test1qpvar20gd3p73s3ad8n92l3h6dr7vzu56waah53nx3sr5wqv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq06v46f	\\x0059d1a9e86c43e8c23d69e6557e37d347e60b94d3bbdbd23334603a380caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x59d1a9e86c43e8c23d69e6557e37d347e60b94d3bbdbd23334603a38	62	3000000	\N	\N	\N
255	145	24	addr_test1qqqf7j7yufhpjs4sk74df6tytm79du6j827vcuahsmnvknsv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqzmyxwc	\\x00009f4bc4e26e1942b0b7aad4e9645efc56f3523abccc73b786e6cb4e0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x009f4bc4e26e1942b0b7aad4e9645efc56f3523abccc73b786e6cb4e	62	3000000	\N	\N	\N
256	145	25	addr_test1qpy2l9wjj2yx0dlsv6u4c82uxm2fvve0dhwqc62wc3ndztgv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq7js7up	\\x0048af95d2928867b7f066b95c1d5c36d496332f6ddc0c694ec466d12d0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x48af95d2928867b7f066b95c1d5c36d496332f6ddc0c694ec466d12d	62	3000000	\N	\N	\N
257	145	26	addr_test1qpvqu2au6qkzf3sce7al7l9zwhs8rtsq2lumk0atrg3aspqv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqlh0rrl	\\x00580e2bbcd02c24c618cfbbff7ca275e071ae0057f9bb3fab1a23d8040caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x580e2bbcd02c24c618cfbbff7ca275e071ae0057f9bb3fab1a23d804	62	3000000	\N	\N	\N
258	145	27	addr_test1qpcd52j9nahexg0cw8djl7sww38f3xfwvzg88ec3v4g0rdcv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq2f28t0	\\x0070da2a459f6f9321f871db2ffa0e744e98992e609073e7116550f1b70caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x70da2a459f6f9321f871db2ffa0e744e98992e609073e7116550f1b7	62	3000000	\N	\N	\N
259	145	28	addr_test1qrpwavewpej5zhmnpk8dtm937pg7qyrfa7zn8a6s0ty4m4qv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqe0k4uu	\\x00c2eeb32e0e65415f730d8ed5ecb1f051e01069ef8533f7507ac95dd40caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xc2eeb32e0e65415f730d8ed5ecb1f051e01069ef8533f7507ac95dd4	62	3000000	\N	\N	\N
260	145	29	addr_test1qpdmxy2kkgw3d3szsn7qnxmwzhn624xr27vrehk0u5efjjcv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq2lukf0	\\x005bb31156b21d16c60284fc099b6e15e7a554c357983cdecfe532994b0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x5bb31156b21d16c60284fc099b6e15e7a554c357983cdecfe532994b	62	3000000	\N	\N	\N
261	145	30	addr_test1qqw3d42u9y4unelsvmpn37prwdeuzzjvytcau0nusu6m6tsv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqu48cjc	\\x001d16d55c292bc9e7f066c338f8237373c10a4c22f1de3e7c8735bd2e0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x1d16d55c292bc9e7f066c338f8237373c10a4c22f1de3e7c8735bd2e	62	3000000	\N	\N	\N
262	145	31	addr_test1qq0yk27d6hu9rj4jaj0z97kk3758dhd8zs8l8kqr9v7w22cv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq04se5m	\\x001e4b2bcdd5f851cab2ec9e22fad68fa876dda7140ff3d8032b3ce52b0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x1e4b2bcdd5f851cab2ec9e22fad68fa876dda7140ff3d8032b3ce52b	62	3000000	\N	\N	\N
263	145	32	addr_test1qr6mx96gyu9vas9qt5z80facp5rkqc756a9m8wq0fhu2lygv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqf2qach	\\x00f5b31748270acec0a05d0477a7b80d076063d4d74bb3b80f4df8af910caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xf5b31748270acec0a05d0477a7b80d076063d4d74bb3b80f4df8af91	62	3000000	\N	\N	\N
264	145	33	addr_test1qqxhyg7vgep47u2f6gmzs7j9nrq74pdg5azl55l05rhvqpsv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqz4365m	\\x000d7223cc46435f7149d236287a4598c1ea85a8a745fa53efa0eec0060caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x0d7223cc46435f7149d236287a4598c1ea85a8a745fa53efa0eec006	62	3000000	\N	\N	\N
265	145	34	addr_test1qpffqcxgm7scx9ekgmcrcqjc47g75tj7ycc5xa77agmj2mcv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq5mcdex	\\x00529060c8dfa183173646f03c0258af91ea2e5e26314377deea37256f0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x529060c8dfa183173646f03c0258af91ea2e5e26314377deea37256f	62	3000000	\N	\N	\N
266	145	35	addr_test1qpc9r0qw0hhnqahgxxwy0zghjwcxlfej6x4t8qqeqy6n26sv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq4gxjcr	\\x007051bc0e7def3076e8319c47891793b06fa732d1aab380190135356a0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x7051bc0e7def3076e8319c47891793b06fa732d1aab380190135356a	62	3000000	\N	\N	\N
267	145	36	addr_test1qrk444s9hmry5y53x7x7yhfzmptxwq4g9pfphxx460z2cwqv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq3l0xqz	\\x00ed5ad605bec64a1291378de25d22d8566702a828521b98d5d3c4ac380caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xed5ad605bec64a1291378de25d22d8566702a828521b98d5d3c4ac38	62	3000000	\N	\N	\N
268	145	37	addr_test1qr694j03chrw8swfzs8c0znn3u08ufasvukvskl9qnh2mqcv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqf098dd	\\x00f45ac9f1c5c6e3c1c9140f878a738f1e7e27b0672cc85be504eead830caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xf45ac9f1c5c6e3c1c9140f878a738f1e7e27b0672cc85be504eead83	62	3000000	\N	\N	\N
269	145	38	addr_test1qrgn76vx8dgdkzzkvys5yvgjckm7ug7vev7kvpzx0phv0hqv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uql3mesr	\\x00d13f69863b50db08566121423112c5b7ee23cccb3d660446786ec7dc0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xd13f69863b50db08566121423112c5b7ee23cccb3d660446786ec7dc	62	3000000	\N	\N	\N
270	145	39	addr_test1qp58vv5uasjw2k5qx4tfa2p7xfw0sfz762lpwns5scm0lwqv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq3vn5ws	\\x006876329cec24e55a8035569ea83e325cf8245ed2be174e148636ffb80caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x6876329cec24e55a8035569ea83e325cf8245ed2be174e148636ffb8	62	3000000	\N	\N	\N
271	145	40	addr_test1qrfvgju3w7hex072etdkx7t6xt5unvf4up783hw0axedmfcv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqpxnvsj	\\x00d2c44b9177af933fcacadb63797a32e9c9b135e07c78ddcfe9b2dda70caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xd2c44b9177af933fcacadb63797a32e9c9b135e07c78ddcfe9b2dda7	62	3000000	\N	\N	\N
272	145	41	addr_test1qzszmk65luafhshwjm09h7jv5f4aqdeu382c3gx8970d0rcv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq8sdwlh	\\x00a02ddb54ff3a9bc2ee96de5bfa4ca26bd0373c89d588a0c72f9ed78f0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xa02ddb54ff3a9bc2ee96de5bfa4ca26bd0373c89d588a0c72f9ed78f	62	3000000	\N	\N	\N
273	145	42	addr_test1qpyvmemwv5vch8kvtdyhw7tw7nuvwsy7spl3yku2p25pqsqv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqj3u7vs	\\x0048cde76e65198b9ecc5b4977796ef4f8c7409e807f125b8a0aa810400caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x48cde76e65198b9ecc5b4977796ef4f8c7409e807f125b8a0aa81040	62	3000000	\N	\N	\N
274	145	43	addr_test1qz7mrkkkxeecjlpdewt0l8lg9zrls8s09qr5262x8lx7lksv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq3erk6d	\\x00bdb1dad63673897c2dcb96ff9fe82887f81e0f28074569463fcdefda0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xbdb1dad63673897c2dcb96ff9fe82887f81e0f28074569463fcdefda	62	3000000	\N	\N	\N
275	145	44	addr_test1qrdlqjkupps2vd99xpl6nmq0z9hv4y0ljt47ftgefeupvcsv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqqj230t	\\x00dbf04adc0860a634a5307fa9ec0f116eca91ff92ebe4ad194e7816620caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xdbf04adc0860a634a5307fa9ec0f116eca91ff92ebe4ad194e781662	62	3000000	\N	\N	\N
276	145	45	addr_test1qzlavlpj7py4kmfmdfw4makpvneuwqcyp30es2yvx6knq2sv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqvqydhz	\\x00bfd67c32f0495b6d3b6a5d5df6c164f3c703040c5f98288c36ad302a0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xbfd67c32f0495b6d3b6a5d5df6c164f3c703040c5f98288c36ad302a	62	3000000	\N	\N	\N
277	145	46	addr_test1qzvdm2c75gyz6zmr0ppva64vlqkpr6vpwgxx4tctzh2j9xsv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqvkkpra	\\x0098ddab1ea2082d0b637842ceeaacf82c11e981720c6aaf0b15d5229a0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x98ddab1ea2082d0b637842ceeaacf82c11e981720c6aaf0b15d5229a	62	3000000	\N	\N	\N
278	145	47	addr_test1qrmrfp54awp4tfxvweqp56f2zlm8purfudnl9vp8anqs88gv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uq8zzemh	\\x00f6348695eb8355a4cc76401a692a17f670f069e367f2b027ecc1039d0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xf6348695eb8355a4cc76401a692a17f670f069e367f2b027ecc1039d	62	3000000	\N	\N	\N
279	145	48	addr_test1qrxhv3nazu7xljz0mdyrscp85l8h80mlyv3pnvwjxcvh97gv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqxazql7	\\x00cd76467d173c6fc84fdb48386027a7cf73bf7f232219b1d2361972f90caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xcd76467d173c6fc84fdb48386027a7cf73bf7f232219b1d2361972f9	62	3000000	\N	\N	\N
280	145	49	addr_test1qpr8l2r87dlej607rvqatasv0y4y8apu9q24ey5lya4kukgv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqgv47du	\\x00467fa867f37f9969fe1b01d5f60c792a43f43c28155c929f276b6e590caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x467fa867f37f9969fe1b01d5f60c792a43f43c28155c929f276b6e59	62	3000000	\N	\N	\N
281	145	50	addr_test1qz8gqxs8lqshstsgm56yskpd96w93vlavhny4jufgrjat5cv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uquarneg	\\x008e801a07f821782e08dd3448582d2e9c58b3fd65e64acb8940e5d5d30caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x8e801a07f821782e08dd3448582d2e9c58b3fd65e64acb8940e5d5d3	62	3000000	\N	\N	\N
282	145	51	addr_test1qpqyehjx4gglxl9xgmnky9x7sy5annyfy802grmjphg2maqv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqrqtzje	\\x00404cde46aa11f37ca646e76214de8129d9cc8921dea40f720dd0adf40caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x404cde46aa11f37ca646e76214de8129d9cc8921dea40f720dd0adf4	62	3000000	\N	\N	\N
283	145	52	addr_test1qzu88evm7a3g769uhxzfswssx3mqyrctl76kfnzfyq9zrjgv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqxt0c8r	\\x00b873e59bf7628f68bcb984983a103476020f0bffb564cc49200a21c90caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xb873e59bf7628f68bcb984983a103476020f0bffb564cc49200a21c9	62	3000000	\N	\N	\N
284	145	53	addr_test1qquhkxh60wxsxtqx2zk08kxjl7n7q7hv787v0pdl5jxtlxcv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqasjn63	\\x00397b1afa7b8d032c0650acf3d8d2ffa7e07aecf1fcc785bfa48cbf9b0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x397b1afa7b8d032c0650acf3d8d2ffa7e07aecf1fcc785bfa48cbf9b	62	3000000	\N	\N	\N
285	145	54	addr_test1qp7smtgrmcd62gx5wga8rnu4q60tahxrklr7sys6d67v33sv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqkw5ekv	\\x007d0dad03de1ba520d4723a71cf95069ebedcc3b7c7e8121a6ebcc8c60caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x7d0dad03de1ba520d4723a71cf95069ebedcc3b7c7e8121a6ebcc8c6	62	3000000	\N	\N	\N
286	145	55	addr_test1qzympn3mlnufpnwllky5avdspae9vvd82n6l76f2zl774aqv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqs94vyf	\\x0089b0ce3bfcf890cddffd894eb1b00f725631a754f5ff692a17fdeaf40caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x89b0ce3bfcf890cddffd894eb1b00f725631a754f5ff692a17fdeaf4	62	3000000	\N	\N	\N
287	145	56	addr_test1qz90yp87wjlddmcsm46rn6wykegf6fhds3njc6jykvjt7asv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqklyurs	\\x008af204fe74bed6ef10dd7439e9c4b6509d26ed84672c6a44b324bf760caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x8af204fe74bed6ef10dd7439e9c4b6509d26ed84672c6a44b324bf76	62	3000000	\N	\N	\N
288	145	57	addr_test1qr7xd6l8z26nkf3tc28n4gr92n8ng6y5kk9w5yknw8eplysv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqu0jupv	\\x00fc66ebe712b53b262bc28f3aa06554cf346894b58aea12d371f21f920caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xfc66ebe712b53b262bc28f3aa06554cf346894b58aea12d371f21f92	62	3000000	\N	\N	\N
289	145	58	addr_test1qp2hedh43zx82tf5fvp9gl9l4armr9ngjmkvkvq8mg8kljqv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqqkcayu	\\x00557cb6f5888c752d344b02547cbfaf47b1966896eccb3007da0f6fc80caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x557cb6f5888c752d344b02547cbfaf47b1966896eccb3007da0f6fc8	62	3000000	\N	\N	\N
290	145	59	addr_test1qqqxrqhnuywqkn6fp4jmcxpd9c9mzvjsr79rxg4vkae3yyqv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqrlmnv4	\\x00006182f3e11c0b4f490d65bc182d2e0bb132501f8a3322acb77312100caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\x006182f3e11c0b4f490d65bc182d2e0bb132501f8a3322acb7731210	62	3000000	\N	\N	\N
291	145	60	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	38963725791	\N	\N	\N
292	145	61	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
293	145	62	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
294	145	63	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
295	145	64	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
296	145	65	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
297	145	66	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
298	145	67	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
299	145	68	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
300	145	69	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
301	145	70	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
302	145	71	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
303	145	72	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
304	145	73	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
305	145	74	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
306	145	75	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
307	145	76	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
308	145	77	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
309	145	78	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
310	145	79	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
311	145	80	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
312	145	81	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
313	145	82	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
314	145	83	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
315	145	84	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
316	145	85	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
317	145	86	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
318	145	87	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
319	145	88	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
320	145	89	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
321	145	90	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
322	145	91	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
323	145	92	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
324	145	93	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
325	145	94	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
326	145	95	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
327	145	96	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
328	145	97	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
329	145	98	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
330	145	99	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
331	145	100	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
332	145	101	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
333	145	102	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
334	145	103	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
335	145	104	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
336	145	105	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
337	145	106	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
338	145	107	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
339	145	108	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
340	145	109	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
341	145	110	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
342	145	111	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
343	145	112	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
344	145	113	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
345	145	114	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
346	145	115	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
347	145	116	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
348	145	117	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
349	145	118	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
350	145	119	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227572424	\N	\N	\N
351	146	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	178500000	\N	\N	\N
352	146	1	addr_test1qzn2qltgr0j2fcxzg0js66cluxx7xvhuh899yf34usmn20cv4asv6sglzyttgvmxce2j763yajemp4k8df3fmtksg6uqsp5vtu	\\x00a6a07d681be4a4e0c243e50d6b1fe18de332fcb9ca522635e437353f0caf60cd411f1116b43366c6552f6a24ecb3b0d6c76a629daed046b8	f	\\xa6a07d681be4a4e0c243e50d6b1fe18de332fcb9ca522635e437353f	62	974447	\N	\N	\N
353	147	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	969750	\N	\N	\N
354	147	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33226432377	\N	\N	\N
355	148	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
356	148	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222403975	\N	\N	\N
357	149	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998921450594	\N	\N	\N
358	149	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4229207	\N	\N	\N
359	150	0	5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg	\\x82d818582683581c599d72b5e3f5a40fb4c4eb809e904d101f908a419472f542bc7032b9a10243190378001a2a94baa3	f	\N	\N	3000000	\N	\N	\N
360	150	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998918282585	\N	\N	\N
361	151	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4049010	\N	\N	\N
362	152	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
363	152	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998917161606	\N	\N	\N
364	153	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
365	153	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998911993201	\N	\N	\N
366	154	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
367	154	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998911823212	\N	\N	\N
368	155	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
369	155	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
370	156	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
371	156	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998911483410	\N	\N	\N
372	157	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
373	157	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
374	158	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
375	158	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998906315005	\N	\N	\N
376	159	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
377	159	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998901146600	\N	\N	\N
378	160	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
379	160	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
380	161	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
381	161	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
382	162	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
383	162	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
384	163	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
385	163	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4150935	\N	\N	\N
386	164	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
387	164	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
388	165	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
389	165	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998895978195	\N	\N	\N
390	166	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
391	166	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
392	167	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
393	167	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998894959141	\N	\N	\N
394	168	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
395	168	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
396	169	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
397	169	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998889790736	\N	\N	\N
398	170	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
399	170	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
400	171	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
401	171	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
402	172	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
403	172	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
404	173	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
405	173	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
406	174	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
407	174	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998889450934	\N	\N	\N
408	175	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
409	175	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4150935	\N	\N	\N
410	176	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
411	176	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3981122	\N	\N	\N
412	177	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
413	177	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
414	178	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
415	178	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
416	179	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
417	179	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
418	180	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
419	180	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998884282529	\N	\N	\N
420	181	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
421	181	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
422	182	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
423	182	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3641496	\N	\N	\N
424	183	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
425	183	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
426	184	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
427	184	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
428	185	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
429	185	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3471683	\N	\N	\N
430	186	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
431	186	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3981122	\N	\N	\N
432	187	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
433	187	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
434	188	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
435	188	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
436	189	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
437	189	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2962244	\N	\N	\N
438	190	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
439	190	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
440	191	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
441	191	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998883942727	\N	\N	\N
442	192	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
443	192	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
444	193	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
445	193	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3811309	\N	\N	\N
446	194	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
447	194	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2792431	\N	\N	\N
448	195	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
449	195	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
450	196	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
451	196	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
452	197	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
453	197	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
454	198	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
455	198	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998878774322	\N	\N	\N
456	199	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
457	199	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998873605917	\N	\N	\N
458	200	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
459	200	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3641496	\N	\N	\N
460	201	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
461	201	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5583278	\N	\N	\N
462	202	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
463	202	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5413465	\N	\N	\N
464	203	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
465	203	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
466	204	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
467	204	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
468	205	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
469	205	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998868437512	\N	\N	\N
470	206	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
471	206	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998863269107	\N	\N	\N
472	207	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
473	207	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
474	208	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
475	208	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5243652	\N	\N	\N
476	209	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
477	209	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998858100702	\N	\N	\N
478	210	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
479	210	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5073839	\N	\N	\N
480	211	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
481	211	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4150935	\N	\N	\N
482	212	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
483	212	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
484	213	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
485	213	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4734213	\N	\N	\N
486	214	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
487	214	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3715335	\N	\N	\N
488	215	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
489	215	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
490	216	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
491	216	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3545522	\N	\N	\N
492	217	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
493	217	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
494	218	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
495	218	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
496	219	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
497	219	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
498	220	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
499	220	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4320748	\N	\N	\N
500	221	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
501	221	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
502	222	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
503	222	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4150935	\N	\N	\N
504	223	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
505	223	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
506	224	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
507	224	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998852932297	\N	\N	\N
508	225	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
509	225	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998847763892	\N	\N	\N
510	226	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
511	226	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
512	227	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
513	227	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998842595487	\N	\N	\N
514	228	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
515	228	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
516	229	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
517	229	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
518	230	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
519	230	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
520	231	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
521	231	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
522	232	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
523	232	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
524	233	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
525	233	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4150935	\N	\N	\N
526	234	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
527	234	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998837427082	\N	\N	\N
528	235	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
529	235	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3811309	\N	\N	\N
530	236	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
531	236	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
532	237	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
533	237	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3981122	\N	\N	\N
534	238	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
535	238	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
536	239	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
537	239	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3641496	\N	\N	\N
538	240	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
539	240	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
540	241	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
541	241	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
542	242	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
543	242	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3471683	\N	\N	\N
544	243	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
545	243	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
546	244	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
547	244	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3471683	\N	\N	\N
548	245	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
549	245	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4150935	\N	\N	\N
550	246	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
551	246	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998832258677	\N	\N	\N
552	247	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
553	247	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3301870	\N	\N	\N
554	248	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
555	248	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3301870	\N	\N	\N
556	249	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
557	249	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
558	250	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
559	250	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3981122	\N	\N	\N
560	251	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
561	251	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998827090272	\N	\N	\N
562	252	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
563	252	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5886687959	\N	\N	\N
564	253	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1251198127250	\N	\N	\N
565	253	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	1251198378507	\N	\N	\N
566	253	2	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625599189254	\N	\N	\N
567	253	3	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	625599189254	\N	\N	\N
568	253	4	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312799594627	\N	\N	\N
569	253	5	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	312799594627	\N	\N	\N
570	253	6	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156399797313	\N	\N	\N
571	253	7	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	156399797313	\N	\N	\N
572	253	8	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78199898657	\N	\N	\N
573	253	9	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	78199898657	\N	\N	\N
574	253	10	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39099949328	\N	\N	\N
575	253	11	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39099949328	\N	\N	\N
576	253	12	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39099949328	\N	\N	\N
577	253	13	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39099949328	\N	\N	\N
578	254	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
579	254	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1271284644136	\N	\N	\N
580	255	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
581	255	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	1251193210102	\N	\N	\N
582	256	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
583	256	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	78194730252	\N	\N	\N
584	257	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
585	257	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	312799424638	\N	\N	\N
586	258	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
587	258	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
588	259	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
589	259	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	1251188041697	\N	\N	\N
590	260	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
591	260	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1271284474147	\N	\N	\N
592	261	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
593	261	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	312794256233	\N	\N	\N
594	262	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
595	262	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156394628908	\N	\N	\N
596	263	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
597	263	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	625599019265	\N	\N	\N
598	264	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
599	264	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39094780923	\N	\N	\N
600	265	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
601	265	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156389460503	\N	\N	\N
602	266	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
603	266	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	78194730252	\N	\N	\N
604	267	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
605	267	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39089612518	\N	\N	\N
606	268	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
607	268	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1271284134345	\N	\N	\N
608	269	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
609	269	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156384292098	\N	\N	\N
610	270	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
611	270	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312799424638	\N	\N	\N
612	271	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
613	271	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39094780923	\N	\N	\N
614	272	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
615	272	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
616	273	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
617	273	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1271278965940	\N	\N	\N
618	274	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
619	274	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	78189561847	\N	\N	\N
620	275	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
621	275	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
622	276	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
623	276	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	78184393442	\N	\N	\N
624	277	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
625	277	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	78179225037	\N	\N	\N
626	278	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
627	278	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
628	279	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
629	279	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
630	280	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
631	280	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	156394628908	\N	\N	\N
632	281	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
633	281	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	625593850860	\N	\N	\N
634	282	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
635	282	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39084444113	\N	\N	\N
636	283	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
637	283	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39094780923	\N	\N	\N
638	284	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
639	284	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
640	285	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
641	285	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625594020849	\N	\N	\N
642	286	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
643	286	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625588852444	\N	\N	\N
644	287	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
645	287	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
646	288	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
647	288	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
648	289	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
649	289	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
650	290	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
651	290	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156379123693	\N	\N	\N
652	291	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
653	291	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
654	292	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
655	292	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312794256233	\N	\N	\N
656	293	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
657	293	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312789087828	\N	\N	\N
658	294	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
659	294	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
660	295	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
661	295	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	156389460503	\N	\N	\N
662	296	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
663	296	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
664	297	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
665	297	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	156384292098	\N	\N	\N
666	298	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
667	298	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
668	299	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
669	299	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
670	300	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
671	300	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
672	301	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
673	301	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
674	302	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
675	302	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4490561	\N	\N	\N
676	303	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
677	303	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
678	304	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
679	304	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156373955288	\N	\N	\N
680	305	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
681	305	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39079275708	\N	\N	\N
682	306	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
683	306	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39074107303	\N	\N	\N
684	307	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
685	307	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4490561	\N	\N	\N
686	308	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
687	308	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39094780923	\N	\N	\N
688	309	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
689	309	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
690	310	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
691	310	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
692	311	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
693	311	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1271273797535	\N	\N	\N
694	312	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
695	312	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4320748	\N	\N	\N
696	313	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
697	313	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
698	314	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
699	314	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	625588682455	\N	\N	\N
700	315	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
701	315	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	156379123693	\N	\N	\N
702	316	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
703	316	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156368786883	\N	\N	\N
704	317	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
705	317	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
706	318	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
707	318	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4150935	\N	\N	\N
708	319	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
709	319	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
710	320	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
711	320	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312788578213	\N	\N	\N
712	321	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
713	321	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39089612518	\N	\N	\N
714	322	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
715	322	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1271273457733	\N	\N	\N
716	323	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
717	323	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	39089612518	\N	\N	\N
718	324	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
719	324	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
720	325	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
721	325	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
722	326	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
723	326	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
724	327	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
725	327	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	625583684039	\N	\N	\N
726	328	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
727	328	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39089612518	\N	\N	\N
728	329	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
729	329	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4320748	\N	\N	\N
730	330	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
731	330	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
732	331	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
733	331	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4490561	\N	\N	\N
734	332	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
735	332	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
736	333	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
737	333	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
738	334	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
739	334	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4490561	\N	\N	\N
740	335	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
741	335	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
742	336	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
743	336	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
744	337	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
745	337	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	1251187871708	\N	\N	\N
746	338	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
747	338	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1271273287744	\N	\N	\N
748	339	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
749	339	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
750	340	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
751	340	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
752	341	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
753	341	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156368616894	\N	\N	\N
754	342	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
755	342	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4830187	\N	\N	\N
756	343	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
757	343	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
758	344	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
759	344	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4490561	\N	\N	\N
760	345	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
761	345	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4660374	\N	\N	\N
762	346	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
763	346	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4490561	\N	\N	\N
764	347	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
765	347	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4490561	\N	\N	\N
766	348	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
767	348	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	4490561	\N	\N	\N
768	349	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
769	349	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39073258062	\N	\N	\N
770	350	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
771	350	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	3641496	\N	\N	\N
772	351	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
773	351	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	625588003027	\N	\N	\N
774	352	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
775	352	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	312783409808	\N	\N	\N
776	353	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
777	353	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	156368446905	\N	\N	\N
778	354	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
779	354	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjelsp9jn24ncfsarahcrg4tknt9gup7uf7uak2u9yr2e24dqqzpqwd	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f009653556784c3a3edf03455769aca8e07dc4fb9db2b8520d59555a	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	64	330137502314	\N	\N	\N
780	355	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\\x8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288	5	\N
781	355	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	39068021633	\N	\N	\N
782	356	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
783	356	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999996820111	\N	\N	\N
784	357	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
785	357	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999996648538	\N	\N	\N
786	358	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
787	358	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999996471201	\N	\N	\N
788	359	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
789	359	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	4999996820287	\N	\N	\N
790	360	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
791	360	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	6826447	\N	\N	\N
792	361	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
793	361	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	6821255	\N	\N	\N
\.


--
-- Data for Name: withdrawal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.withdrawal (id, addr_id, amount, redeemer_id, tx_id) FROM stdin;
1	46	5888317134	\N	252
2	46	20091691583	\N	254
3	64	5135177704	\N	354
4	46	12213249278	\N	354
\.


--
-- Name: ada_pots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ada_pots_id_seq', 13, true);


--
-- Name: block_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.block_id_seq', 1352, true);


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

SELECT pg_catalog.setval('public.epoch_stake_id_seq', 291, true);


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

SELECT pg_catalog.setval('public.ma_tx_mint_id_seq', 41, true);


--
-- Name: ma_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_out_id_seq', 48, true);


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

SELECT pg_catalog.setval('public.reverse_index_id_seq', 1350, true);


--
-- Name: reward_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reward_id_seq', 228, true);


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

SELECT pg_catalog.setval('public.slot_leader_id_seq', 1352, true);


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

SELECT pg_catalog.setval('public.tx_in_id_seq', 663, true);


--
-- Name: tx_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_metadata_id_seq', 17, true);


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

