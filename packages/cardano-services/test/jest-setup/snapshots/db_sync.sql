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
1	1011	1	0	8999989979999988	0	81000010010665012	0	9335000	103
2	2010	2	89999900715568	8909990088440103	0	81000010006133205	0	4711124	202
3	3001	3	178208803062237	8734454377481363	87326813323195	81000010006133205	0	0	302
4	4014	4	265553346837050	8560638734934371	173797912095374	81000010006133205	0	0	397
5	5010	5	345167287071939	8422547072459937	232275634334919	81000010001914155	0	4219050	501
6	6017	6	429392758194197	8274950743411003	295646496238188	81000009993076301	0	9080311	592
7	7007	7	503867315792927	8144777080720952	351345610409820	81000009993076301	0	0	684
8	8006	8	575541354103271	8022335098604532	402113554215896	81000009976183837	0	16892464	772
9	9001	9	644533437640516	7908551239188050	446905346987597	81000009976183837	0	0	858
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (id, hash, epoch_no, slot_no, epoch_slot_no, block_no, previous_id, slot_leader_id, size, "time", tx_count, proto_major, proto_minor, vrf_key, op_cert, op_cert_counter) FROM stdin;
1	\\x0d5bb306ec74342bd311ad9cfb72ed64a905987ff1b2ee1eb2569f24d40cc04f	\N	\N	\N	\N	\N	1	0	2023-08-09 11:51:20	11	0	0	\N	\N	\N
2	\\x5368656c6c65792047656e6573697320426c6f636b2048617368200000000000	\N	\N	\N	\N	1	2	0	2023-08-09 11:51:20	23	0	0	\N	\N	\N
3	\\x1dbe3dfe644a561ea2a36d6e7dad684bb8d1845155099103e0d9c946fc205e23	0	0	0	0	1	3	4	2023-08-09 11:51:20	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
4	\\x7f3657403320c1cd711443e7721bd2e4e5c42ae670c95e8152855a74e10300ed	0	13	13	1	3	4	265	2023-08-09 11:51:22.6	1	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
5	\\xeedd960d04a80072069f96cb4a2aa8dcb15cd967de4c5d4a4b8aaaae395a3bd7	0	39	39	2	4	5	341	2023-08-09 11:51:27.8	1	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
6	\\xb1c05dc3ff5cc8a77baf2bc4e983bf402c35f57e8f448b7929aa187a74825fcc	0	46	46	3	5	6	4	2023-08-09 11:51:29.2	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
7	\\x7ef56f4f1c81f9aa078459b9963ef209b3c18a6c131e007b820da08e822c481e	0	49	49	4	6	7	371	2023-08-09 11:51:29.8	1	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
8	\\x9846f0482da1f211362172587d21661ad334f8d738cccdda2a7f44d203272acb	0	60	60	5	7	8	399	2023-08-09 11:51:32	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
9	\\x5897b884d72e561b371121f83812dfe286006a71df4f1559203b3c80519a86ef	0	70	70	6	8	9	4	2023-08-09 11:51:34	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
10	\\xb7c08417764b193e080f91c310ef5664c1f7951c1e20c4410409f0df3be8fb7d	0	74	74	7	9	6	4	2023-08-09 11:51:34.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
11	\\xfd3724287b5be03d2a8a0a6d337804ba9dd3f807c89e1d7e33d66bc50fc388ed	0	76	76	8	10	11	4	2023-08-09 11:51:35.2	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
12	\\x54235a1867e00e18c0a9dcec35bd62d255275dd52b5b6d70091745e5971250bd	0	85	85	9	11	9	655	2023-08-09 11:51:37	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
13	\\xf0f667d625ea08c185c94e815c067bca9ab666b3bd8590ae5f1d889912af3132	0	101	101	10	12	3	265	2023-08-09 11:51:40.2	1	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
14	\\x49aab866690b3f694a8ed56e15bdf43c3d3e03afba51da5dccfdfd7753c964e4	0	105	105	11	13	14	4	2023-08-09 11:51:41	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
15	\\x9eb03543b1a607202684d3e8dec19fb4a74738f7fa41795217700ca2c466dd1a	0	106	106	12	14	3	4	2023-08-09 11:51:41.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
16	\\x28930feb1298367a8287f457ea8ad6b5b0ccab092dab8984b5574be4053a4a26	0	108	108	13	15	8	4	2023-08-09 11:51:41.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
17	\\x1b553fe16f93d079f9eb54192aee60538c7194e6a505001aa4f41cd66294b286	0	110	110	14	16	3	4	2023-08-09 11:51:42	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
18	\\xc4a026d9c015c0eb64cda0b9dcf0c5e75a3d548fd49d1f1ac9a9d04d5556605f	0	114	114	15	17	11	341	2023-08-09 11:51:42.8	1	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
19	\\x62f66e41e620e361b05f62e1ffae4d22e50d9c97fa883b4aab09076692130209	0	144	144	16	18	8	371	2023-08-09 11:51:48.8	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
20	\\x0c9dfa24b19995edb3da7f4a2d2744e8f0362e53a44085c5babaaecf78d4f8a9	0	149	149	17	19	6	4	2023-08-09 11:51:49.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
21	\\xaf5efd211864f333e792ca61a7948aaf55d0ef4958bd22049d22625af49b7716	0	163	163	18	20	8	399	2023-08-09 11:51:52.6	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
22	\\x8a98f5a28c2e1c0cd91df3a165f236358c616c06fbac500485dd52d6f45da2c2	0	167	167	19	21	7	4	2023-08-09 11:51:53.4	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
23	\\x24dfdb0cfe0fd5f747ceea5e89e5722edf78f5c140770cc3e43e0baa3022a161	0	168	168	20	22	5	4	2023-08-09 11:51:53.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
24	\\xb1b7e11d56902c64e1cf2aeb5c6e4d0d63a06e45902555a53e510489b8391b4c	0	181	181	21	23	5	592	2023-08-09 11:51:56.2	1	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
25	\\x3bbee0f4adc105c6fc05537d57681e6c060687d4a7ac29ae4cf15a46a53831b3	0	187	187	22	24	9	4	2023-08-09 11:51:57.4	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
26	\\x3224510490c1e66a7e35309cb4d146b175eb50467e693ac2fec05b26d607a477	0	188	188	23	25	3	4	2023-08-09 11:51:57.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
27	\\x9e6d0e2e6b80ff84707b6ae9d9882409670edadbe59f035e368a38174d0a6842	0	219	219	24	26	5	265	2023-08-09 11:52:03.8	1	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
28	\\x506273332b7682e2c3cd91d032d083e1c509bef6ddda3af869d98b9db13a2ec3	0	220	220	25	27	4	4	2023-08-09 11:52:04	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
29	\\xf4897444c5bec1e6467d23572fba7297457b6b8c9a72e3cc2c676ace41adab05	0	234	234	26	28	4	341	2023-08-09 11:52:06.8	1	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
30	\\x6b9051a397f6d9a9cd9db85e60151209aabac05a88c5df56a0150b6984b7c01b	0	240	240	27	29	9	4	2023-08-09 11:52:08	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
31	\\xfd707290e1effff20c946518427abcc519bba57b33a7d5473130aa9d0e4187cb	0	267	267	28	30	3	371	2023-08-09 11:52:13.4	1	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
32	\\xf2acb1f078e14e31852fdc792ebc15583410f7e90397d2055db0663386125794	0	269	269	29	31	5	4	2023-08-09 11:52:13.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
33	\\x4888c36549ee38a9cdd9fe7d8061aba800e2b5dc6c5a83c7cccb80a0c6e0a6ad	0	270	270	30	32	33	4	2023-08-09 11:52:14	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
34	\\xcecdd1c0e1fba5823d04a2c033178184fc203d898c468607f1477e134e76d0d6	0	293	293	31	33	33	399	2023-08-09 11:52:18.6	1	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
35	\\x09b097973734785f4621c40971052d68037749bf78f4a0dbc850d134144f6d8f	0	296	296	32	34	8	4	2023-08-09 11:52:19.2	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
36	\\xff2af6a02f6058bbc62eb62669852db4a5316f1e5d859dd8d53f7734555e004b	0	297	297	33	35	14	4	2023-08-09 11:52:19.4	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
37	\\x42bb8d26235b7e5218a5f1b5ca65990cf088560c0b0c4f8828b2d2eb4626921a	0	303	303	34	36	37	655	2023-08-09 11:52:20.6	1	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
38	\\xd8f40d2f6ba38f69bf094e20c27271ed26dfb2dbce8cf3c41902d3680b62d122	0	312	312	35	37	7	265	2023-08-09 11:52:22.4	1	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
39	\\x4a104691cba09e865f0cdaa32606b8fd2552a2160e05e0259095e24b1786a3af	0	344	344	36	38	3	341	2023-08-09 11:52:28.8	1	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
40	\\xcb3f9a070252026e7204f957d44f4a7466d1efef9b5f1e746aa7e597f7ab46ec	0	351	351	37	39	9	4	2023-08-09 11:52:30.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
41	\\xf83afa1a2f7483eeda9b5b6bb241818260f3f2961e7e7963a1137ba44f2b55e3	0	363	363	38	40	4	371	2023-08-09 11:52:32.6	1	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
42	\\xd27532662955549e50568319505e9d8885f4ed97bf8f42007babe87785657d3a	0	371	371	39	41	11	399	2023-08-09 11:52:34.2	1	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
43	\\xea825446d59228c3e3a7e61de0869371ed53f60186ec4521fb4a8db2647e562a	0	375	375	40	42	37	4	2023-08-09 11:52:35	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
44	\\x1f15ed2ad91c081d67855bd1c0a44e871c3966fe26f1179a9e2cff570462ab21	0	382	382	41	43	3	655	2023-08-09 11:52:36.4	1	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
45	\\x1ba564b0fb60140f79bb84ce2e12eba7c103539acae5abe7ceef1d23ebdc0e30	0	387	387	42	44	7	4	2023-08-09 11:52:37.4	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
46	\\x81522bf28b40e6dfbd290cf805cc1a1b08f09ea39039690586557a81e9c21f65	0	415	415	43	45	14	265	2023-08-09 11:52:43	1	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
47	\\x8f94fc659d601ea37372b36c672ae3f7376a874384b04b5293e58e2b3dbc0080	0	423	423	44	46	9	4	2023-08-09 11:52:44.6	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
48	\\x4b2a1df8f4199424cafde7a0c83e86d4dcc9a1aaa3c5ee1c4025053a5c74e584	0	435	435	45	47	9	341	2023-08-09 11:52:47	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
49	\\x53bb76999781676f9801535cbaf9423e851eeea407044be2b1a91c7f8addae87	0	446	446	46	48	5	371	2023-08-09 11:52:49.2	1	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
50	\\xbb66a7d4a24c8acd81a2aa687a14c1db542fd33f45ff308498b7721034c143b1	0	456	456	47	49	37	399	2023-08-09 11:52:51.2	1	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
51	\\x8c895e00d46bd766db2423e2c655667128e7e0f981ed3aec983ab0c70efdb995	0	467	467	48	50	9	655	2023-08-09 11:52:53.4	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
52	\\x158f165aa2157581b4a0ada50825fe0b544887c49d193c34effe405131aa7527	0	483	483	49	51	5	265	2023-08-09 11:52:56.6	1	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
53	\\x59ef80db6bd587467eed78ed4b1ef5f5995267b613e135dabdb731bf8413f654	0	490	490	50	52	37	4	2023-08-09 11:52:58	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
54	\\xec810ccc7bab2ff1c2325bfc8b8e1ba2c163cbf251150b90a1085cca00f09bfe	0	494	494	51	53	3	341	2023-08-09 11:52:58.8	1	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
55	\\x62884e57fd456fad15e41c004adeaffad12d428884e301bff85da2474cbbbda0	0	500	500	52	54	7	4	2023-08-09 11:53:00	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
56	\\x48a9848ad9e3a543e76a170ca605b12788ed695617ff6c3205388e0bf7774869	0	522	522	53	55	9	371	2023-08-09 11:53:04.4	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
57	\\x54e141f27b7c64992e07d161655d59124023210fc6203bd5e7e86286e6c42193	0	525	525	54	56	11	4	2023-08-09 11:53:05	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
58	\\xbe4f302e0d5c34ffac7069b77ba04e87e938b3d06cd2829db4d54dc63d8d74e7	0	558	558	55	57	37	399	2023-08-09 11:53:11.6	1	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
59	\\xc574ba13febd606b574361844a36fb80f5f8497cc622fb976c598a49dc6085be	0	563	563	56	58	6	4	2023-08-09 11:53:12.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
60	\\x42e3ece92dda7dfd28eb5d708e9126e7214a9a6764e469b1f962f81790cfe46f	0	577	577	57	59	37	655	2023-08-09 11:53:15.4	1	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
61	\\xc43b4cd4c385c13c1a12cfccd7f3a4f851ff4a70c40b5872a190954716735c3f	0	595	595	58	60	3	265	2023-08-09 11:53:19	1	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
62	\\xa23baeaa9c9fa4733ce369305814216c66e175bf80799f7ca574133c329aef32	0	596	596	59	61	4	4	2023-08-09 11:53:19.2	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
63	\\x935b53224d59eea57310bdf2f459db8ff50631ccd2ae9270371884bc47f3577c	0	604	604	60	62	14	341	2023-08-09 11:53:20.8	1	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
64	\\x2d9f9606381df974bdf0c114956a037b5f52443803097cf6946f4e04721f6bf5	0	605	605	61	63	6	4	2023-08-09 11:53:21	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
65	\\x5aed6e758b19efea0b4e85fd8948d74df8f07895adbc11208c0d03d87384ae6c	0	614	614	62	64	3	4	2023-08-09 11:53:22.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
66	\\xd12d2f84f022c6b5fe9374b56afbc95fb6f2bcd2edcbf846f963ad1121725758	0	626	626	63	65	9	371	2023-08-09 11:53:25.2	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
67	\\x138387bf37a32f7c3210f11c4250d06933aae8a3bffa6aa1ef50f761f7d33013	0	630	630	64	66	4	4	2023-08-09 11:53:26	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
68	\\xca9c9d95044505303e17f278a3fdeec9b4a24e9acf40dc77db8409f157d67c3b	0	647	647	65	67	3	399	2023-08-09 11:53:29.4	1	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
69	\\x178fefa2fbed96bd46c88f6bc769985c79c0808860fdb81b317f05ff4ebd2df1	0	653	653	66	68	8	4	2023-08-09 11:53:30.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
70	\\x586edb653a9266051d543fb61a1633e38f4820da2df470d5bfc3fd8ae23034e5	0	658	658	67	69	33	655	2023-08-09 11:53:31.6	1	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
71	\\x0f62f84ca9e5537185b553e851f75cef1707869df1f45bb49f3bf194bd96729e	0	677	677	68	70	5	265	2023-08-09 11:53:35.4	1	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
72	\\x0d6775dc54be8d9be4106e99c324adb419b91e0dc8c68211d052fc440376bd82	0	678	678	69	71	4	4	2023-08-09 11:53:35.6	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
73	\\x2c132b0dd87e87dc544119f65406f98b4350417dbfe59f04aa5154ced08a8160	0	700	700	70	72	37	341	2023-08-09 11:53:40	1	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
74	\\x42d1407dd3f9875c754f29f8bbd4f9b843ecd2507347cc9799e8cc27f2e4e529	0	706	706	71	73	8	4	2023-08-09 11:53:41.2	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
75	\\xdc165cc454b2264993c3161d1bb01568f613118ecb140b63c228a6e22767e664	0	708	708	72	74	4	4	2023-08-09 11:53:41.6	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
76	\\x5af2b1636461c7f3547f520a359623c09ef021b5c8600c97502c42a5632ee7a4	0	710	710	73	75	11	371	2023-08-09 11:53:42	1	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
77	\\x2e8c52c54c7a972d99767b1ddd5f478dd5109a95ef220dc150a19d7c6d94033a	0	711	711	74	76	11	4	2023-08-09 11:53:42.2	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
78	\\x3cd07a90531f44446ba89847df854d235ccc2aa350008d0f5dc5ad7b750c1b09	0	718	718	75	77	11	4	2023-08-09 11:53:43.6	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
79	\\x022375165eed4e58f20c741822c38e582dce500e7b6e16394fbf1cb07e2af33c	0	723	723	76	78	11	399	2023-08-09 11:53:44.6	1	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
80	\\x26986d029fedcccb9d124ca7fd15c2d1856b30ccc79c6570bd807a39f4448a0f	0	728	728	77	79	6	4	2023-08-09 11:53:45.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
81	\\x1fe6c86525e4f458d0a2626323921c34a7e3f15b4f191cc7713029c9b75227b7	0	729	729	78	80	33	4	2023-08-09 11:53:45.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
82	\\x9d36f17343b68c9d13873582a6c940acf5d350e820241fedf7d76a8691e1f3ac	0	730	730	79	81	3	4	2023-08-09 11:53:46	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
83	\\x3746b2b9d83be51cdeb820afebd7f13dbc571739e27c8b262d135baaaf986448	0	740	740	80	82	3	592	2023-08-09 11:53:48	1	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
84	\\xda58993d391e0b5e4f7c66200632b9e78381e26539834100e6d40621faa228dc	0	765	765	81	83	8	399	2023-08-09 11:53:53	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
85	\\x474bd36b770a4e9eb5d396d81659bc28f7f9b1d9619f1b4c00b9c7150f850055	0	768	768	82	84	6	4	2023-08-09 11:53:53.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
86	\\xdbcf77b3ba82b82a6928cc54606061e5c8702376dbda62ff2b476d323a23b9d7	0	769	769	83	85	37	4	2023-08-09 11:53:53.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
87	\\x88f7c8b240221c0a9c418504c3e4100032ae692fef51cb71bcf525dd1938211c	0	780	780	84	86	8	441	2023-08-09 11:53:56	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
88	\\x414f70a4e478e59f78928a9ded18f5f65c001be17067f9b4d33326a987e153a5	0	787	787	85	87	14	4	2023-08-09 11:53:57.4	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
89	\\x5881cfd41bf3ef656c70c49cebdd7e29146b5f72f44530a80dacb1d0241dc46f	0	808	808	86	88	37	265	2023-08-09 11:54:01.6	1	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
90	\\xdcf49110f81087fd35b8fc814646a72e53bb8e8fd3e934d20d01e304765c43d6	0	811	811	87	89	9	4	2023-08-09 11:54:02.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
91	\\xdb75926e2040369a991ae2e52255f8670a5b0dbd8fc8167bcd145f20a6690eff	0	824	824	88	90	8	341	2023-08-09 11:54:04.8	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
92	\\x6b599c8d708baa27923bcc06e5104bf5c5ae6d43774763fa8dd1032f481ab91a	0	828	828	89	91	33	4	2023-08-09 11:54:05.6	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
93	\\x0e7c551f57a29a8ac6f6f000299cf07e62a2bc0e1c113a1bae53b4577fdc3c14	0	850	850	90	92	37	371	2023-08-09 11:54:10	1	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
94	\\xafe3998e2bab668ff7630859246e99ff6f28b1ea4697a90efdbe9d361b389a0f	0	864	864	91	93	4	399	2023-08-09 11:54:12.8	1	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
95	\\x9e054489a19b8553be1d208ffeb3a98a1f9c6121b5fa0c2228c86bd623125fa3	0	928	928	92	94	33	592	2023-08-09 11:54:25.6	1	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
96	\\x3f6c161982aef8256b5dfe1d5f4e8533b4cb50198360c10a784911f0ce483cc9	0	934	934	93	95	5	4	2023-08-09 11:54:26.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
97	\\x54d853f7fdfbfd3dcd6922f1755f77cd98c7e77528dc003bbbd38435c13652f1	0	939	939	94	96	8	399	2023-08-09 11:54:27.8	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
98	\\x60c21a53dae9ae9d23731c34eaa8b486c6a1f68914406d192c9befb74bb00c60	0	945	945	95	97	6	4	2023-08-09 11:54:29	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
99	\\xe80900f4b91f7d518dada441af1c819b9e95397286da383136fb13c60cc4249e	0	948	948	96	98	33	441	2023-08-09 11:54:29.6	1	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
100	\\xf84693c2bd6ddbe2c7fdfd689ce193fa1010c4b635f86a92e9e4bcfa42599209	0	950	950	97	99	7	4	2023-08-09 11:54:30	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
101	\\x72a1ce80d04d44444f8371315a9f9c82b56a5784e09b034e16b6ac3d1553253d	0	973	973	98	100	11	265	2023-08-09 11:54:34.6	1	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
102	\\x8f3810648a7fed77ac8e9282abbbc58891bf27d3e3729e29012c2d2485095796	0	983	983	99	101	8	341	2023-08-09 11:54:36.6	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
103	\\x21d64b180224316cd43cdc7b2e8dee080dd86564a3785a835700400727e2e7a3	1	1011	11	100	102	8	371	2023-08-09 11:54:42.2	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
104	\\xd363c5c128411c9593aee802c25fa267b28d9d00bf7ecd6a2b8dc66c3ec5ddc8	1	1019	19	101	103	5	4	2023-08-09 11:54:43.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
105	\\x605d17bbb950686d6ea01c18bbd454d72889819da0c4704ec89eda9928dc9e08	1	1021	21	102	104	4	399	2023-08-09 11:54:44.2	1	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
106	\\x206e0cc6ab7fbdcdc20ba4a0c0a73a122b0031daa1d6448f2ee2cb2c3ab5a4d3	1	1030	30	103	105	8	4	2023-08-09 11:54:46	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
107	\\x182a4413f846162d475a44932448184230cd4ef020a3e310d731a101c592f8f3	1	1031	31	104	106	33	4	2023-08-09 11:54:46.2	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
108	\\xc9bbaf807483bd21be3206fe1a92374620c0be3b53a71ecde61a39185fcf1fad	1	1036	36	105	107	9	656	2023-08-09 11:54:47.2	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
109	\\xd6170cfc959592374c790fc7fc31c58ab42e7447e397486ff90d048aadaba542	1	1043	43	106	108	3	399	2023-08-09 11:54:48.6	1	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
110	\\xa65c7c40d075130532fab48c0c30a0aaf477ac6ef434716d304c6b010038824a	1	1063	63	107	109	4	441	2023-08-09 11:54:52.6	1	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
111	\\x2d8357de52604ba3d5087f92203e91f290d4f9576b641bd40a06f6cf5fe317e4	1	1068	68	108	110	37	4	2023-08-09 11:54:53.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
112	\\x936230fb4d8a6c8fab8d12633930fd6218c3530ec4d464768786b5df5e0201a8	1	1073	73	109	111	4	265	2023-08-09 11:54:54.6	1	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
113	\\x35476dee4eead15e67ad27701d4ad2ff07e86a853433d156f2b4cf50c62c94ab	1	1075	75	110	112	37	4	2023-08-09 11:54:55	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
114	\\xb4d0bb7a4619a675d34dc12712a945c7c233ebaba4988260dde5c35264ca4b57	1	1084	84	111	113	33	341	2023-08-09 11:54:56.8	1	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
115	\\x482b5e608c6aaeb1c79abe7b4480ca158f9f78f327dd6a8ede2526e09cbaea08	1	1111	111	112	114	5	371	2023-08-09 11:55:02.2	1	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
116	\\x94205144ad3b2d527c60280ca8ad334d7bc453f35d21620fef494cce638a95fc	1	1116	116	113	115	33	4	2023-08-09 11:55:03.2	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
117	\\xdebf5c96d60aaffd00829a252d812af27b25a03af9b1f6e1b2d656d8bd0d6456	1	1117	117	114	116	9	4	2023-08-09 11:55:03.4	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
118	\\xfcb4067652cd0990f8dc6b3dff0b52c642e2b8ea60901003247cb9f808cf03df	1	1129	129	115	117	11	399	2023-08-09 11:55:05.8	1	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
119	\\x0cdca467201f82c2b9e2701077649afd7eac214a3a061925ebd71884615a74d6	1	1136	136	116	118	8	4	2023-08-09 11:55:07.2	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
120	\\xbad5aa45c4e60cd0bea054b533954ced9faaa837d7dab4b7155309a068131321	1	1137	137	117	119	6	4	2023-08-09 11:55:07.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
121	\\x0cdaf205fd66bbb324818375eb1d25618431f02383666ebb03c4858ce78ef1e9	1	1161	161	118	120	4	656	2023-08-09 11:55:12.2	1	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
122	\\x249339a4f04feb8cd0ea5d1f752642d3dfe6cfca59b65e8f2a3ca2a000dc17a1	1	1172	172	119	121	14	399	2023-08-09 11:55:14.4	1	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
123	\\xe5436ba566db86e5e5a7ce845780e6d77b6b197e4cc672c94263995727251b93	1	1184	184	120	122	14	441	2023-08-09 11:55:16.8	1	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
124	\\xa94b4d2f4782a4ee52ca1ca2dac4eb97ba58b09014b036dd4d322819f4780e30	1	1198	198	121	123	37	274	2023-08-09 11:55:19.6	1	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
125	\\xd7d990ebe7bb0c2147604b4392d0b87a5a5b7017ed95257287d4b29c0924307b	1	1202	202	122	124	33	4	2023-08-09 11:55:20.4	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
126	\\x2fa7e0ebf96d72689c43cd011956d34eebc458ae22f8f108954755a0e24727bb	1	1215	215	123	125	5	352	2023-08-09 11:55:23	1	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
127	\\x81f0eb65d58ef2e498b12a3d3965011d4007b19b264acbd27e6f0b337cfc3c80	1	1222	222	124	126	37	4	2023-08-09 11:55:24.4	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
128	\\xcbc0238029c56a148abaf50ce9d96a4e64d1104117b6c51ffd1a5c9be7ce6ba5	1	1244	244	125	127	7	245	2023-08-09 11:55:28.8	1	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
129	\\xe0170b283843c8f2b6a7fee25983ff3f52fa494f17eab0f297c42ffb6544eb4f	1	1249	249	126	128	4	4	2023-08-09 11:55:29.8	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
130	\\x36f3218641a88064b44bb965595f04ea57a6020f1f42fef2a5fb048e76fa5d78	1	1258	258	127	129	8	343	2023-08-09 11:55:31.6	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
131	\\xf73fb1d903bb2df219b42ed5a3fa821041a7547c4b20896cdaeb7f1553894a63	1	1277	277	128	130	37	284	2023-08-09 11:55:35.4	1	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
132	\\xb96951e41ca471dd64a1095c4c33fc2abf3e14584bf0b94aeab8160ce7bd73b0	1	1289	289	129	131	4	258	2023-08-09 11:55:37.8	1	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
133	\\x247f015d70d905e47d403db2ff383ce7f4a1fb242cbed0ffa694876ef6db7684	1	1297	297	130	132	6	2445	2023-08-09 11:55:39.4	1	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
134	\\x6da1792ad85ff6bef0085e1ef4f351266fe8cb8d37249d6cac028d71a8c695be	1	1317	317	131	133	8	246	2023-08-09 11:55:43.4	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
135	\\x84f3b140f5112a909d38623415538d82331f6e4272ac5f1f8c71ad0e850dfa3f	1	1335	335	132	134	33	2615	2023-08-09 11:55:47	1	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
136	\\x58b5f7a5c7e218f3cda63d81f5a5bb88b9f6349886c0f2a61fbf637ff4f4880a	1	1357	357	133	135	8	469	2023-08-09 11:55:51.4	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
137	\\x8e3b201f30d001b53ca0b545a8cc6b922273da7573aebd4c677dc185f47d2438	1	1372	372	134	136	3	553	2023-08-09 11:55:54.4	1	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
138	\\x8a79cee20c118cc8e0927a8a1a3c80bd606b59e8681dbf27eea2a069841cc628	1	1377	377	135	137	37	1534	2023-08-09 11:55:55.4	1	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
139	\\xcb52c65ba8ceceb9659837c7f93ce86d5b7e43a0ef0e7c51f07e025ecf2745ad	1	1386	386	136	138	9	671	2023-08-09 11:55:57.2	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
140	\\xfe2ad453319eaab5c8a8a951d835680be85b58812f9ef2a4cd6935dcb93de8af	1	1394	394	137	139	14	4	2023-08-09 11:55:58.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
141	\\x8beaa6e5dbc617aa5b326def3d68a3f22b60dd2fa2a36e3c45e9d9faec0c70ee	1	1407	407	138	140	6	4	2023-08-09 11:56:01.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
142	\\xbc06b48bfe0b0bbd4fbe136964540623ea7323cd772da2a84d4a7bb948bb623b	1	1430	430	139	141	8	4	2023-08-09 11:56:06	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
143	\\xd44a3378a01f3c688134a4811d69361d425efa425bc722fc18be609eb8baf48d	1	1440	440	140	142	37	4	2023-08-09 11:56:08	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
144	\\xa8f8818a16ee02e2c031d1160b112959f381cc9b67c9f963fc115ad88b71e2d5	1	1442	442	141	143	6	4	2023-08-09 11:56:08.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
145	\\x3ea12934f4b6d0c6b1b14fee4040301c1377ea952ff96698483beae45370a64d	1	1449	449	142	144	14	4	2023-08-09 11:56:09.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
146	\\xeaa8d674130936f4e1fa743e2563ed2ded789352bce2fd1ca86113b3168c9466	1	1451	451	143	145	7	4	2023-08-09 11:56:10.2	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
147	\\x6a7cc239e13a37eecf43658649e9092046045106378b45d74e16982c08a902a8	1	1471	471	144	146	37	4	2023-08-09 11:56:14.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
148	\\x8b6c7343823b3813e2e8638bcad92067cd6eeb9a7486845f0019faa3810fb375	1	1474	474	145	147	8	4	2023-08-09 11:56:14.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
149	\\x88a8a94e7fa01bcdda525e5fc68b4c117c5dcfc7e3730ac18419e6cded6ae0c2	1	1490	490	146	148	6	4	2023-08-09 11:56:18	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
150	\\xef1460c45373ead5f31ba2f62520f157f85dde485480f3e4732d5ab3e9a1c4d6	1	1499	499	147	149	8	4	2023-08-09 11:56:19.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
151	\\xc7788022413c941004d98f5fcfcb671e972492c8abdd5dccfd5b3c5aec6a9071	1	1501	501	148	150	9	4	2023-08-09 11:56:20.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
152	\\x8fd6800dab0b2888943ae46437d8887c0eada05b5225db7dd818cee59a9c25bc	1	1510	510	149	151	7	4	2023-08-09 11:56:22	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
153	\\xbadcbab34e4198a88f80d4a45f54d2f110efdbe4822f4c57d6c326c9b1399d64	1	1519	519	150	152	8	4	2023-08-09 11:56:23.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
154	\\xd798edf3ace7f52ec19c972ad95fda255cfb1011484b4412c0cb7dc67d82b642	1	1541	541	151	153	33	4	2023-08-09 11:56:28.2	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
155	\\xfe86a177d2d0577834fe73d26d9e8145ac008321064cc40d02c79f10a6c01eb8	1	1556	556	152	154	5	4	2023-08-09 11:56:31.2	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
156	\\x9bfb9be3e96ec1e4a19ebdbed19e9978b2718649574633489c2ab3e54ba88b1a	1	1567	567	153	155	11	4	2023-08-09 11:56:33.4	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
157	\\x5e26d00fb5a4c143ad6607ad91be50ef02c41e2b47544813e5f946cbc357d640	1	1579	579	154	156	6	4	2023-08-09 11:56:35.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
158	\\xa14161524540e49d5dfe2a1f19501e01a9522a0b18df4b5ca1ff065ec0e4b3f8	1	1595	595	155	157	14	4	2023-08-09 11:56:39	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
159	\\x3fa9162b0e81940bcb62a93a9ec64c1c54f347e0dc59d86c4b7ec5f1fbdb9deb	1	1603	603	156	158	8	4	2023-08-09 11:56:40.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
160	\\x5e8e554cc02445fb230cd2fbbba30e3af29f85105aaa34581eedf987adada4c2	1	1608	608	157	159	5	4	2023-08-09 11:56:41.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
161	\\xb7f7f04eb8cf58800f9bddf0e3901ed186c7d1d6b9ca51172ec4a0fc96eeb4a6	1	1627	627	158	160	11	4	2023-08-09 11:56:45.4	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
162	\\xe1009768fcd7450878a789aee38fb5db1303961f0d92e655de94916023f87f55	1	1649	649	159	161	5	4	2023-08-09 11:56:49.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
163	\\xe6766ac58ed4dbefa77ece8c94e115a394edf4368f0983dd2c5c9f68a45490c7	1	1651	651	160	162	14	4	2023-08-09 11:56:50.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
164	\\x186572cd62dbebed22b9288ec8b0319ec733774d302423c72ae4ebd075538300	1	1661	661	161	163	11	4	2023-08-09 11:56:52.2	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
165	\\xcbc8e36b7fcf5e758e50ce35fc4a3cd3afe26f2c3049ad96e9c383010815f870	1	1670	670	162	164	37	4	2023-08-09 11:56:54	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
166	\\xbaba5b65be119ec0c78675d20f584da897737c776822033f7ca42cfb5a3653e0	1	1673	673	163	165	7	4	2023-08-09 11:56:54.6	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
167	\\xbdac8fdbe979ef8bfb2cfd7ff7054a8951dc57a5f970d9655bbedfd8508363cc	1	1676	676	164	166	3	4	2023-08-09 11:56:55.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
168	\\x06074af24f59d43bc8265486caf081f8a475fd18e6e98afeeb2eeca802e738f0	1	1685	685	165	167	9	4	2023-08-09 11:56:57	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
169	\\x45b6219d4d5c585e1ad315ce67fc2e58f32fdf6d660293a7df58b417a5856ab2	1	1694	694	166	168	37	4	2023-08-09 11:56:58.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
170	\\xad1816296202e340b9f0f1456477963375fb1015e1cf475803d8f95ed05d8bb9	1	1702	702	167	169	6	4	2023-08-09 11:57:00.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
171	\\x14d3b064f6d7bb25741756c9769b0970093c6068eefc9dd637d69c03a06358f1	1	1705	705	168	170	8	4	2023-08-09 11:57:01	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
172	\\x56c97f6523c77cababbb611cc54efc654f936d9300d5b4d7994b7005eb053317	1	1708	708	169	171	37	4	2023-08-09 11:57:01.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
173	\\xeeb8890a3abde417ed1cd8aee2dfe44eb0c2560e95e327f87d525ba9c82890c1	1	1709	709	170	172	14	4	2023-08-09 11:57:01.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
174	\\x2dce88e5050a8c5b9b0f43a3e2966121024ff545a89a57aabc83d25354e6fc9a	1	1751	751	171	173	7	4	2023-08-09 11:57:10.2	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
175	\\x4e874a0523dbf5d14197edf217520093695b9789cebb4ecee9b1289b53905daa	1	1755	755	172	174	5	4	2023-08-09 11:57:11	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
176	\\x70eb6de541276e3c2648e015e66252d5db9799f68fe126d3f7b2400e31a8a22f	1	1770	770	173	175	5	4	2023-08-09 11:57:14	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
177	\\x6f74d6989f264ae727e234b59028bfe883bb90b9e98767b13b18ceabd2aa91fd	1	1781	781	174	176	9	4	2023-08-09 11:57:16.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
178	\\x11b94aa1fb3e988d0abde11ecac45b5b5a167d13f3b8704a991f55dbe526ad7c	1	1808	808	175	177	8	4	2023-08-09 11:57:21.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
179	\\x06c8b9b5cf7c87b6cb6f0c2dd215970b6f1e13993e6741520e8da68b42e9af07	1	1812	812	176	178	5	4	2023-08-09 11:57:22.4	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
180	\\x3a808d07e45cfb36b2218c8b16859f81869303c1c49ac22472d32d70b0ef73bc	1	1829	829	177	179	7	4	2023-08-09 11:57:25.8	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
181	\\x89ec569f862e020699699463f80fc120656cd7ad3c29d774f2337b056db53a5f	1	1830	830	178	180	37	4	2023-08-09 11:57:26	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
182	\\x5757eec410f41a76e9cbc7ccc00268fc4c649c8ebb1da422c2d5a8e8cb26fb0c	1	1862	862	179	181	11	4	2023-08-09 11:57:32.4	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
183	\\x8b6072e796a97aa74c23c4b9423466ff955d3643687d6414491e2551be6265a0	1	1864	864	180	182	9	4	2023-08-09 11:57:32.8	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
184	\\x2ed5cd54390d85999c3f279a88500e9b2145132fc264ae0d40afdda18b3efada	1	1865	865	181	183	9	4	2023-08-09 11:57:33	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
185	\\x1c9414ebb783290fed095223404692abcc703f3cb65cc0edd723163ddafe6ef1	1	1866	866	182	184	9	4	2023-08-09 11:57:33.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
186	\\x47565750876c151c5f17d784a0303fd9864e0baa1c9d19eb9074f012a0d60e07	1	1872	872	183	185	4	4	2023-08-09 11:57:34.4	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
187	\\x6ae92c1e4369864429e92bb8eb0d83388a40ecb21f8a0e14146e948ff7056576	1	1873	873	184	186	37	4	2023-08-09 11:57:34.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
188	\\x18821e6dac9f1d0d086065a511f6020f9d03d8caa7450399feac47435716024f	1	1878	878	185	187	3	4	2023-08-09 11:57:35.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
189	\\x42286a228378d847c282027da7d99e39b3d3e72d5c9ae73d060830ac97eeef16	1	1880	880	186	188	7	4	2023-08-09 11:57:36	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
190	\\xd6f31fdc17a5cf827e42e4a5e807335c9cd58fffdb6d17e05ee241f7a759a4f0	1	1890	890	187	189	5	4	2023-08-09 11:57:38	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
191	\\xaef12819eca1ae268899dc65538e11fba12a13f14c25799fd82d47679bb86159	1	1912	912	188	190	3	4	2023-08-09 11:57:42.4	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
192	\\xb625160034dd121aa6be759f5c6d446f8ce0214bdac199a2fae55d668054ab36	1	1934	934	189	191	14	4	2023-08-09 11:57:46.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
193	\\x6dcfee737b7ebc7558cd4c4b71677417cb282e84d7b9f080493b9a17790c2571	1	1936	936	190	192	8	4	2023-08-09 11:57:47.2	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
194	\\x49fb1534a88b174cd917fc3d6e9dcdde97b7b32e810ec0e1929a2c4e8f01a3bc	1	1941	941	191	193	5	4	2023-08-09 11:57:48.2	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
195	\\x4fe347bc9f7963e875f88546e706da13770a65e7c1954b522c7c6e672a28bd87	1	1942	942	192	194	6	4	2023-08-09 11:57:48.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
196	\\x126061e6225cf2129bc45e08693b249a782a8e1efaf6195158d55e3864e2dd47	1	1947	947	193	195	14	4	2023-08-09 11:57:49.4	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
197	\\x0dfa1b1f47f484b64b4c9be85e441b79902bd4bc7a7911774ed033702fe50746	1	1958	958	194	196	14	4	2023-08-09 11:57:51.6	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
198	\\x11eea768130bbac6323df983198c42e7745b10cb43ae37e6400f0969b4e66876	1	1962	962	195	197	3	4	2023-08-09 11:57:52.4	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
199	\\x64098a3a1089e6307ab069f400dea06488f44e587f537da393d2ad16d55dfd49	1	1973	973	196	198	8	4	2023-08-09 11:57:54.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
200	\\x5500ef5ddedb6ca09f0464fb90a8ca4d60bac92a84795cb912049998aa846aaf	1	1986	986	197	199	9	4	2023-08-09 11:57:57.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
201	\\x6bac484057fee84c24b0cd39036b89ea7ea735dfbf4ad0e9603bbbf706b8c1a0	1	1989	989	198	200	6	4	2023-08-09 11:57:57.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
202	\\x506106d1dbeddce12925e9d35fe369da360fc9e0f0806e8a928892d3bdd57926	2	2010	10	199	201	7	4	2023-08-09 11:58:02	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
203	\\x9fd0f02298eff645ec209570aa2948d60400f5e34ad1e95920a56a9f6760ebe9	2	2011	11	200	202	14	4	2023-08-09 11:58:02.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
204	\\x88487f659ff48f299314e3316bedddf72ac4453626d8bb14d149813aa26bbb50	2	2017	17	201	203	11	4	2023-08-09 11:58:03.4	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
205	\\x73efd4419e58d47dc2f22bd56f50a827b2a4bf0e825ad9187fded389ea20fe94	2	2028	28	202	204	9	4	2023-08-09 11:58:05.6	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
206	\\xa9a301306a2e448b184bd0d64271591321bda532dfea7be978ea9e6e2146ade7	2	2097	97	203	205	4	4	2023-08-09 11:58:19.4	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
207	\\x92adbb94c0a2847aacdcb10359b2547a6c37cef59270bec32742c8f7c961308b	2	2106	106	204	206	6	4	2023-08-09 11:58:21.2	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
208	\\x804c53ee9b99cf17da41dd956a8cc7cfeb9eaa576881c358911352d68a72840a	2	2118	118	205	207	4	4	2023-08-09 11:58:23.6	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
209	\\xd47ab4af91c71a2546240f200b839031751e3173774cc11573d9f2c150d1a65a	2	2119	119	206	208	3	4	2023-08-09 11:58:23.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
210	\\x9b7ac0ddf4f494dcb0dd0f8594e2d4b657bc25d8f24ed6353aee59083d758719	2	2123	123	207	209	8	4	2023-08-09 11:58:24.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
211	\\x50d63fb4997306f37da956096f011ca0a3107f2b7539144cf167f9c22368a4db	2	2140	140	208	210	8	4	2023-08-09 11:58:28	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
212	\\x54a81f0b47380e8ff5cc902536221804ad0ab3f7a2f572979dfe515d47797c52	2	2142	142	209	211	4	4	2023-08-09 11:58:28.4	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
213	\\xbc03ee5d833ffc16fd03f6d45b5040654d6c9e993418cd3b622b5deaf43af2d5	2	2148	148	210	212	6	4	2023-08-09 11:58:29.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
214	\\x17c603137b33a83616de550fcc20f8c894ef81b7130c5f087db112a34e36453d	2	2149	149	211	213	33	4	2023-08-09 11:58:29.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
215	\\x0cb3505fee41bce9306533aed5f7813df28b8970f9d063eccf9ad98fdfdd5d27	2	2183	183	212	214	4	4	2023-08-09 11:58:36.6	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
216	\\x809124061e2ee33423bb7161265ba9f525baf56e48b190ae218fe1694c55ebad	2	2203	203	213	215	8	4	2023-08-09 11:58:40.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
217	\\x5e006a5e11b5e3092dead2c3940f739d09f066de82bec7baac373e1f17173a9a	2	2204	204	214	216	6	4	2023-08-09 11:58:40.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
218	\\x5f3d616e60f50a6631ba8a8a456322edb0e1f6d0269a0aa4a8d919d96e262fd2	2	2209	209	215	217	7	4	2023-08-09 11:58:41.8	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
219	\\xf6a3436204279e3cd4d894f93732422329382669a07e58f043eed9c036afe4a9	2	2212	212	216	218	4	4	2023-08-09 11:58:42.4	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
220	\\xd4c2ade6ee333ef3b0e921a842f3b1815388da79023771fe903f7925b8c7e046	2	2218	218	217	219	8	4	2023-08-09 11:58:43.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
221	\\xba66336380417fe2dad7b9bbfe1167b5bf2483683cf6e32384b0b21b10cb2ed3	2	2222	222	218	220	5	4	2023-08-09 11:58:44.4	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
222	\\x001c23c3b5069a640b59d5152e19a697632cfb2d6e000dd0d4d671bc62e175b7	2	2225	225	219	221	5	4	2023-08-09 11:58:45	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
223	\\x8c9899911013f1f8f0da0914280211ffc7581f8ff26ddf832fc75446eaa68390	2	2233	233	220	222	7	4	2023-08-09 11:58:46.6	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
224	\\xacd47df1100df8b23583d40086f4416066b3232aeb63fc0c929b41c861828d82	2	2256	256	221	223	3	4	2023-08-09 11:58:51.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
225	\\xeeb67422ae40c9b03485ca98b323f36474d890a3c1e62264a76affa140d0e38c	2	2276	276	222	224	14	4	2023-08-09 11:58:55.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
226	\\xb5577ec853ab0c8a1df2ab3ce78186c832824639a985ce603f5b7f450db7bc90	2	2277	277	223	225	37	4	2023-08-09 11:58:55.4	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
227	\\x00e3f43b58bc1d221b7df41acb9ef80266aada6839f9a48911db402b3796e2db	2	2280	280	224	226	5	4	2023-08-09 11:58:56	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
228	\\xb182f80b973477615e8f06f199cc525d49f9bb8b8eacc315f97e96512244f159	2	2286	286	225	227	37	4	2023-08-09 11:58:57.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
229	\\xbfd9ed14e1e8f32d3d1c066110c4132d45f1c38cf82eef57584e639ec8017a1a	2	2294	294	226	228	33	4	2023-08-09 11:58:58.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
230	\\x16acfcd587501b12b6385149ec83ce0d2046f6d1950a1ee60aa673784c6bb8c8	2	2304	304	227	229	14	4	2023-08-09 11:59:00.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
231	\\x30cd530c56948bbb9b431aeb22596eb5ebb00e54b3f7917b2faaba4bd51b2858	2	2306	306	228	230	37	4	2023-08-09 11:59:01.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
232	\\x65486e21d506cfbd6faf0f4399fec27a784381a9a60fb25de6a958a52102a06a	2	2310	310	229	231	37	4	2023-08-09 11:59:02	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
233	\\xa502359d619d0c4f8de55906a94ab6644c719ba840025a4ecdfca92ff19c481a	2	2325	325	230	232	8	4	2023-08-09 11:59:05	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
234	\\xd43e04c2853a0a9f633d30ebc700750e8a5cd53d33b45c745b86077a2e73112d	2	2335	335	231	233	37	4	2023-08-09 11:59:07	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
235	\\x256b624c63b93614a0d443e8c3298c837e53d1154449b06b15828ea515a2bf6f	2	2353	353	232	234	8	4	2023-08-09 11:59:10.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
236	\\xbfc1fe3df44383d78aa383f77f223003f5be52493f8883e649da0a8e98673d32	2	2362	362	233	235	37	4	2023-08-09 11:59:12.4	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
237	\\x03218101c8128892a1e26ee60a055f1970547d0aed382d8fe6f0dd48abcb034f	2	2367	367	234	236	9	4	2023-08-09 11:59:13.4	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
238	\\x309fd4baa7963d180d3ec31291c2ad1c6ac94b29c9560b0840d143326606988e	2	2370	370	235	237	14	4	2023-08-09 11:59:14	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
239	\\x4f540a8d238ff580a45b263de96a2eb8843836ea02d88c36931e389f2f5bce7b	2	2379	379	236	238	3	4	2023-08-09 11:59:15.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
240	\\x2adf6b3dfebe530b7b36284f59e197062b332d904831c99d3d611a3a348ff227	2	2383	383	237	239	14	4	2023-08-09 11:59:16.6	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
241	\\xd05ea9110bc0b4275ed0cfbeb15b58a8b7097eb4494e4a8bccc830c7648c3413	2	2397	397	238	240	14	4	2023-08-09 11:59:19.4	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
242	\\x7c564fe593e3aff768656c6c67e82ae52be70cf18821cac200d2e8e6bf6eea06	2	2409	409	239	241	4	4	2023-08-09 11:59:21.8	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
243	\\xb9d426fbc62c9e3be8e84fd2222075352462b3691c162973def1c93f94f20271	2	2413	413	240	242	5	4	2023-08-09 11:59:22.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
244	\\x2b2f359e96c03df8a2fa8de96feec2e6d5f119810e61fc32bbade81fe99d60b5	2	2422	422	241	243	4	4	2023-08-09 11:59:24.4	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
245	\\x22da2fbc243d3fa7f5c800ff2baaca0915eac932235a37bedd355cda69b5a63e	2	2429	429	242	244	9	4	2023-08-09 11:59:25.8	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
246	\\x91bd42398614b9ba34a8eb89687cb6f3f071673e39c768e862cd56ce863ef902	2	2431	431	243	245	9	4	2023-08-09 11:59:26.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
247	\\x341c4810627e557457855de1f93af6c23d42cb906bfb6ddca115304f7760b839	2	2439	439	244	246	5	4	2023-08-09 11:59:27.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
248	\\x1d9c838ab44ddca84cec70d4f76bfb0eee230999ac4d082068ef3150fdf641a4	2	2469	469	245	247	3	4	2023-08-09 11:59:33.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
249	\\x02d6e630d91120af9452a7516a2ec85ce7607d71220d3c7e2a2b2ef7e058ec56	2	2471	471	246	248	7	4	2023-08-09 11:59:34.2	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
250	\\x7ae1953fe64e9704005c5caeecc7109d6b409c51fafbe0cd78167d182e9ee0ba	2	2474	474	247	249	14	4	2023-08-09 11:59:34.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
251	\\xa52126b176d609c6d3d8b0c4bb49e87e5f021f021acf8037f748cfef4ba1ceed	2	2482	482	248	250	3	4	2023-08-09 11:59:36.4	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
252	\\xeade6b23cf0fbcb2814572daef631e0e8a36a5f8dad8d055fa25e2ca99614566	2	2491	491	249	251	11	4	2023-08-09 11:59:38.2	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
253	\\xb77f997cc2fdab647e35f0fe67e96193663f9d5c03d7fa16cbad82a473ff9142	2	2513	513	250	252	8	4	2023-08-09 11:59:42.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
254	\\x181601185b481c88b71c9ddc0b33d4ff82168bf14432dc8c3b209fd18b5cbde5	2	2514	514	251	253	14	4	2023-08-09 11:59:42.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
255	\\x9693aa2b6a0fa6f1d2fdd80d2f541b7978c97d69bc1da2b0d4a4e327df24bd33	2	2517	517	252	254	4	4	2023-08-09 11:59:43.4	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
256	\\xb83c30bb6e067dc74d9f7d1d4589d395ccb6fa3bac0ac4db4780fa0e2765e4f4	2	2532	532	253	255	33	4	2023-08-09 11:59:46.4	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
257	\\xb8b36d28a934f26d23ed39253a84bd64d095f7b013002fbc58106310446128e8	2	2535	535	254	256	3	4	2023-08-09 11:59:47	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
258	\\x8b0d59136e7702c97780196c89c33523428a96ff28224fc244b4dfcd3f52ea28	2	2556	556	255	257	9	4	2023-08-09 11:59:51.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
259	\\x8236f7c212ae9198a54257cd0e608a5c244f7a8ac0b7163a37092d9c67c908cb	2	2562	562	256	258	11	4	2023-08-09 11:59:52.4	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
260	\\x39d0fe30fbc5a425be51f73a610d9053ebbd1435415e59725a9d9bbf9d463144	2	2570	570	257	259	37	4	2023-08-09 11:59:54	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
261	\\xdc4d5f759872ef19f4ace7ca0d6fb2995e8c3707593e867ccfe1cd00bf3b1f9f	2	2614	614	258	260	7	4	2023-08-09 12:00:02.8	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
262	\\x86b0cec8808b75e04be83189739a8428286257950f365ac56e05bdd8645b0fd3	2	2627	627	259	261	4	4	2023-08-09 12:00:05.4	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
263	\\x3a6198aac0879d21327d3e7cf5b4b3187ca81715c098453e9f49abaa18b51d0c	2	2628	628	260	262	3	4	2023-08-09 12:00:05.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
264	\\x0e6326b421d7a65698e7895f7021fe5a7208de10c64a723c16ee0a9c5f233389	2	2631	631	261	263	33	4	2023-08-09 12:00:06.2	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
265	\\x0c02191d63dff577693c73dfdcec71ba8e343536aec9e37ceef92274a078721f	2	2639	639	262	264	9	4	2023-08-09 12:00:07.8	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
266	\\x5ecc28c1baee3b3f4e6098ef26211113ebbebe5d973c1aa655e303ad21253cbc	2	2656	656	263	265	9	4	2023-08-09 12:00:11.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
267	\\xc31cedf59239e406ea11bc703168b6ab55821e3dfa266e7bc996a6d8e9517b3a	2	2668	668	264	266	4	4	2023-08-09 12:00:13.6	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
268	\\x58bc4eabd43004ae7746b73463749634c82841ebc4fde8b5929c86dd157a112b	2	2687	687	265	267	4	4	2023-08-09 12:00:17.4	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
269	\\x95e575c4099d4bf9768b68adde9ec8733456df9053f1b190ce5c234fa55b752d	2	2697	697	266	268	9	4	2023-08-09 12:00:19.4	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
270	\\x44cd9740024743094071116690bf49a89f1739d2da21e42c81c6bb7a05e5603c	2	2699	699	267	269	5	4	2023-08-09 12:00:19.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
271	\\x22a8803f0abcfa571cc052a2f7988f61e1b7f02845a0bf5748be7f323a07537e	2	2706	706	268	270	11	4	2023-08-09 12:00:21.2	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
272	\\xb3b96e03e79b0b266668ac2d5cd244067bc04db61d3775670c4704159898cd3f	2	2721	721	269	271	11	4	2023-08-09 12:00:24.2	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
273	\\xa2beed9da76c10f347f56c8329e9185dd163394b117d08f371d8569189b0015b	2	2730	730	270	272	3	4	2023-08-09 12:00:26	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
274	\\x02b72ab974547e79ada4563e9e5ada7478fbc4eea34e146ad20b56f969ea93ab	2	2737	737	271	273	37	4	2023-08-09 12:00:27.4	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
275	\\xcaa2f041bc3978618c0171c6b4db62b08f152a8557d2e2e469a5592d4057bac7	2	2756	756	272	274	8	4	2023-08-09 12:00:31.2	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
276	\\x9d3663c525665099ad20771f30ae0d0a8a1421354f18f730d5aa3bf39d6698cf	2	2763	763	273	275	11	4	2023-08-09 12:00:32.6	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
277	\\xbab6596b3949d1b422c0330061e8c847905613087e366355de14723dab28a386	2	2771	771	274	276	7	4	2023-08-09 12:00:34.2	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
278	\\xe203deacec74b2f9097bd53df46d09429724bd3072c5d9288e1e7d41f6ba0827	2	2790	790	275	277	4	4	2023-08-09 12:00:38	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
279	\\xf29ffedb8b4f49f51f761b15cbe85ebe0dd92fe7ea4f88660ae132aa4cdc468c	2	2805	805	276	278	6	4	2023-08-09 12:00:41	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
280	\\xdde07ea6eef8d32e21bddfeadfe9f0e825fd8ac88e5fcca44d1f6a4d78e2411d	2	2811	811	277	279	37	4	2023-08-09 12:00:42.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
281	\\x14cab72eeeb0f3880c2c0254a9e956cfa45dd69420c4ae5f911b93e58549a92f	2	2815	815	278	280	6	4	2023-08-09 12:00:43	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
282	\\xfedbc45e8a06be2af5f49067300b255ad8fb5c3b7bbdcaacd85463ee84c06355	2	2817	817	279	281	6	4	2023-08-09 12:00:43.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
283	\\x8518514c05513fa433943f97f408608d8d2f7f97802802476160bbc41ec81911	2	2818	818	280	282	6	4	2023-08-09 12:00:43.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
284	\\xfb2f649ce393c1ee4f48f9d363b3bab57371562b3805416343f210a9c1ddece1	2	2819	819	281	283	9	4	2023-08-09 12:00:43.8	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
285	\\xc21ee0253c69dfab97477411c34a1016acb0b9fce85d8f5a6efabf9340314910	2	2822	822	282	284	7	4	2023-08-09 12:00:44.4	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
286	\\x60522d654b2b9dcfcc40c5c5bff9ec425d888a5c34461496a94028a2d2b9367c	2	2836	836	283	285	4	4	2023-08-09 12:00:47.2	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
287	\\xff2b4992c431c88c67991640eb284876841ccc19e03de9e8e24036330e6016d4	2	2846	846	284	286	7	4	2023-08-09 12:00:49.2	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
288	\\xd68ac06d2f03223ad4ffdbcc1e05cd76b069c2223e03c1b2813fcdc9cc8ebb65	2	2853	853	285	287	11	4	2023-08-09 12:00:50.6	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
289	\\x4965afc84458e86c9a1522c48ed6ac4c81e98dedf5f6f54a07826a46b11c74a5	2	2867	867	286	288	3	4	2023-08-09 12:00:53.4	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
290	\\x5ad19f10a5f6ebbc1a4604d5e928d46dd19c1787394a8660e8974ea97a7a5ad8	2	2886	886	287	289	3	4	2023-08-09 12:00:57.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
291	\\x578e7c7018a86cc23bd74dd61bc4b9ecc8d130cb79130cd83908034abb4df930	2	2902	902	288	290	9	4	2023-08-09 12:01:00.4	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
292	\\x47cdeec3016ba054299cf394c1e41bb161044b99a72ad612b096ed63208ceb4c	2	2905	905	289	291	7	4	2023-08-09 12:01:01	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
293	\\x2f1eb994cb49587fae52dc9dff21f47309329422c1a6a2161833bacd640cc20a	2	2914	914	290	292	9	4	2023-08-09 12:01:02.8	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
294	\\x3a8110334eb5714889514323c5d8d9e7f97f5ae49690a378df4e4a77d227fcf4	2	2923	923	291	293	33	4	2023-08-09 12:01:04.6	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
295	\\xd9ce25291a90bca0ffe8fb5282b29b86220cf61a88e9db4b76f27cedee3e613f	2	2926	926	292	294	14	4	2023-08-09 12:01:05.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
296	\\x8bc5928def5805ddf04ec334ab89d0cd5322a7de8bbb5befbc7f818b5f5be7e6	2	2931	931	293	295	7	4	2023-08-09 12:01:06.2	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
297	\\xdedc739ae70deca7b4b3f8982ed449c62a2518353df81bb1a5564f2b90497c04	2	2935	935	294	296	6	4	2023-08-09 12:01:07	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
298	\\xcc2e2dd5ba4319ba1abbfe0d3ab4b60290d3f386bfadac8a25ff414ab78541f4	2	2947	947	295	297	7	4	2023-08-09 12:01:09.4	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
299	\\x5bc2d4a1e7c9c96e66276261dbbfae62f4e2c53451709c8fb05996ddec1d6351	2	2989	989	296	298	8	4	2023-08-09 12:01:17.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
300	\\xa18ca95f4167f061a7fe09d132e34f17a0e00e4553c5f480a4101b9042373db3	2	2990	990	297	299	14	4	2023-08-09 12:01:18	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
301	\\x10fb3b9c89cee8a931a993bbe555da42222551e9cdb7b27bac966cb09a003ced	2	2998	998	298	300	6	4	2023-08-09 12:01:19.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
302	\\xab0e57472a65ae83e94f4c1f21d28771efe18e89a4b40a6392b9b832147a5207	3	3001	1	299	301	8	4	2023-08-09 12:01:20.2	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
303	\\xb58bf10e526f773283a91dc8ad294dc66cfe7fc002c96afbb322fc40c49c8d4a	3	3032	32	300	302	7	4	2023-08-09 12:01:26.4	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
304	\\x5f3e47716ec7e3a5a4ea567edcb54c0056087b35122dcd3c23736aa5049dd490	3	3033	33	301	303	7	4	2023-08-09 12:01:26.6	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
305	\\x5efac0e9cfe6a7c7e3dcc9412c976fd9e4924dd047e67ca8521cd319ee88d794	3	3043	43	302	304	4	4	2023-08-09 12:01:28.6	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
306	\\x5416197b3c3d3873e122a98fba6eccbf0dcc57819b0fde3097b57865676a7a25	3	3071	71	303	305	33	4	2023-08-09 12:01:34.2	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
307	\\x0d935beaf6feddf7e878aae802c0ee40680d85f7c7794baa6842cfad2519faef	3	3072	72	304	306	33	4	2023-08-09 12:01:34.4	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
308	\\x7a48b2627390647be07fab664c8aab04721564df82bf12dc5dd2469f6459c7c7	3	3114	114	305	307	33	4	2023-08-09 12:01:42.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
309	\\x73fdee7b37e08fa40986d249bf0548877f995fc09d520f84e9143d683c5f0343	3	3125	125	306	308	8	4	2023-08-09 12:01:45	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
310	\\xa87320465afe25e5fac4561e5df4f0968bba8be4a3756c14da9eca5f89c53d25	3	3147	147	307	309	8	4	2023-08-09 12:01:49.4	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
311	\\xe1ebe059d2dacf8d2174b3fa20ba6e30624246dd38e5e543de3ca88f2f250260	3	3150	150	308	310	4	4	2023-08-09 12:01:50	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
312	\\x946e688fb2f28655fcf51f8d27a50a261bea6be9d82f242bf04642e9ab8f6033	3	3164	164	309	311	5	4	2023-08-09 12:01:52.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
313	\\xe32f08849fd7b49055985c185f4a70033d7b1aacdc0dd4a9fe840f458907daf6	3	3173	173	310	312	6	4	2023-08-09 12:01:54.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
314	\\x05ac40320b0db09119009dd962084efa6116e3bcfc472a1b7453348332b23e1d	3	3183	183	311	313	8	4	2023-08-09 12:01:56.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
315	\\xfe05aecb4041c43a548dca2c84239212ac86bf67d74b12d7d97a863777f95b5c	3	3200	200	312	314	33	4	2023-08-09 12:02:00	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
316	\\x7e2cb45d00d8ae32fdc2d7f7bf43dad76b5951f669a0456ab657d54d0b6e9df8	3	3204	204	313	315	5	4	2023-08-09 12:02:00.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
317	\\xa753986d411418881892eed5c1ffa6de2f3e15208e301896e13fd6ee5c2f9635	3	3231	231	314	316	5	4	2023-08-09 12:02:06.2	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
318	\\x78eb3bf3262aadc07fa92abad723b9a9f1d1f1f23d6d47273ba5c0563e99f0fe	3	3244	244	315	317	37	4	2023-08-09 12:02:08.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
319	\\xa513004bd5bdbc2a36d22bdb1c5dbd30465f5cd78f6f20e796aeec84f8ddb30c	3	3258	258	316	318	3	4	2023-08-09 12:02:11.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
320	\\xee8781c10b620a1bcd8bab7b615daddbb39311ea77cdbdeac2bff428e50cc145	3	3260	260	317	319	33	4	2023-08-09 12:02:12	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
321	\\x0ccdca0226c6fdd053b9bbfe8d899fbb42869aa47e72939af82a2619396efc1d	3	3263	263	318	320	6	4	2023-08-09 12:02:12.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
322	\\xbe6950c23d6ee007d69c07f5ece86730bba1a4aaa45531cd326f84571156a07d	3	3278	278	319	321	11	4	2023-08-09 12:02:15.6	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
323	\\x216d48e1b36b4796ec0bfdb5978ffaa8fa2322da9a8e0b7e7a4d11b8c1c0f7a1	3	3283	283	320	322	5	4	2023-08-09 12:02:16.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
324	\\x4fca99c6664522d2a5e0ab95f19034f45067fcace727e06e34c26fd7b5d90e69	3	3305	305	321	323	3	4	2023-08-09 12:02:21	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
325	\\x84bcd04627d04174cd6aa4f6a5f732eb978adc8629ac5a755a7c8a6dc98341a9	3	3308	308	322	324	11	4	2023-08-09 12:02:21.6	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
327	\\x11f789fdbdb61a261c9202c86a764d8cf35d3da1c47dbacedf6d75e964dadcc6	3	3312	312	323	325	11	4	2023-08-09 12:02:22.4	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
328	\\xef3c280de1453c09b49ae4c36af7b04481a5ba3666ee3d89dd05ed7cd2d79a28	3	3315	315	324	327	37	4	2023-08-09 12:02:23	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
329	\\x8e7bc2b0d22df5ac361d4a616b36b53934c582f275b0729671053ca81b0118d4	3	3337	337	325	328	4	4	2023-08-09 12:02:27.4	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
330	\\x69084f605872fe9669933333fe38017222c2a0ca7cf5a9c116a8b812493faadb	3	3359	359	326	329	5	4	2023-08-09 12:02:31.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
331	\\x67a90696f404d2f25bbebce14cf8c66f3f0b6005ee06fdb08148f0c1e11b8492	3	3369	369	327	330	14	4	2023-08-09 12:02:33.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
332	\\x07bc16a99d3e442ef95c31b4aa51c0d560225c21c571687ab790abcb76a28d06	3	3379	379	328	331	4	4	2023-08-09 12:02:35.8	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
333	\\x81b3a5e23fb02ed4a3bd641cc10d5b4eb12c821acaf3eb1ee91053c8272481e4	3	3382	382	329	332	5	4	2023-08-09 12:02:36.4	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
334	\\x3089fbe7c67fa5f2d838dfd6e2b8998f984c9cc63b852bcca1e8d2908345da4f	3	3387	387	330	333	7	4	2023-08-09 12:02:37.4	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
335	\\x1e8e85c61a330bb80328d8d0c9f8421ec596acbaa30ccdc1d2555c5696e85b5e	3	3388	388	331	334	7	4	2023-08-09 12:02:37.6	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
336	\\x6c6d9b790fe78cd86a3907acccf7c0666c036ae55cad0dfe5c0e415c8c1b9670	3	3414	414	332	335	33	4	2023-08-09 12:02:42.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
337	\\x36de30611c61c7a0f3acbc7efaf940e4f6705b2362cc732c648b545f4863400e	3	3415	415	333	336	3	4	2023-08-09 12:02:43	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
338	\\x83442c21ad28c916a9701c909281babb46faca36c37ffec54c7f644593c2dc6d	3	3429	429	334	337	8	4	2023-08-09 12:02:45.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
339	\\xc58ce9bb6fbe7d4e30144c99b20e5f7588292c8d143dafaa233ef7184415b12b	3	3448	448	335	338	9	4	2023-08-09 12:02:49.6	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
340	\\x344cc95692a45b5c5954e0325af6df7bb85dc9b2eacec448a0e1575bdb0a4554	3	3451	451	336	339	11	4	2023-08-09 12:02:50.2	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
341	\\x6663687c8d5aef21fc419c0853ff2269960f209a6057f6a21be040ca6ef63721	3	3469	469	337	340	14	4	2023-08-09 12:02:53.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
342	\\xcc2ac7af43e1ad43219bb7cdb39cb41908b970180f6bf95c91ca1b597c278649	3	3479	479	338	341	33	4	2023-08-09 12:02:55.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
343	\\xf032021ebb625fb2d62d0c19342b35abd62b674c6e25746250f07fed67f3fedc	3	3483	483	339	342	7	4	2023-08-09 12:02:56.6	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
344	\\x26908d9fb93b2ee8f13e614856ee7ebe3cfe5c9ad9da9ea982e188b9c03763b0	3	3485	485	340	343	9	4	2023-08-09 12:02:57	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
345	\\xbf0e7b1d537c12380821f33d1027203da87bab21f309a434c732da2048de2876	3	3511	511	341	344	4	4	2023-08-09 12:03:02.2	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
346	\\x372c3ffae0ec16efc91262b6ef5a78d22fec7ce2d2aab008099613d57fe8ff0e	3	3527	527	342	345	3	4	2023-08-09 12:03:05.4	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
347	\\xc0dde9fa7f620e2a6209a5ccaff03bfe0e1fab98113518e9919d2a7b31aa7c1f	3	3531	531	343	346	5	4	2023-08-09 12:03:06.2	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
348	\\xc2c50dde361ff5d79f54ea759d10640025fcaa8cf5d4f5b1ce0aaa07a889f3db	3	3543	543	344	347	3	4	2023-08-09 12:03:08.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
349	\\x1a5fb92f80a38d92cf71e0e1e112bef7f353b550288f665803c7e8bed64e10e9	3	3551	551	345	348	9	4	2023-08-09 12:03:10.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
350	\\xf5b73945f49d40b64da6f4f1eebd65e04d9b22ce61b3202ac994aca2a598ee66	3	3557	557	346	349	3	4	2023-08-09 12:03:11.4	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
351	\\xe713242a195ab279c025097355eb1b725773ac3da4c5bb71fd6ccb5be6eb328b	3	3559	559	347	350	37	4	2023-08-09 12:03:11.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
352	\\xfd9298cad151e310a32c76a4a1e74c3cfeb16e189be9be6472f6bdec937c0cf7	3	3593	593	348	351	37	4	2023-08-09 12:03:18.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
353	\\x046286740ee23d2a402d52a31e4dbfaf8a40abdbde8f50d1589cf048dcc8fe18	3	3596	596	349	352	3	4	2023-08-09 12:03:19.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
354	\\xe41dce43572effc721962beaf1d8fd85f8f174438bb15fdaa9b11a733045d4a7	3	3608	608	350	353	6	4	2023-08-09 12:03:21.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
355	\\xe8b9363149a3e7bd7637564ea8a176ec3f9449c2b863fa77ce3cccc34f7b21dd	3	3619	619	351	354	11	4	2023-08-09 12:03:23.8	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
356	\\xe23bd38ad238a7cda7c338be471e33e8c13d4eae73c5cd118fc5b423452d20cd	3	3623	623	352	355	5	4	2023-08-09 12:03:24.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
357	\\xde027f13512b72778ea3675054ecfbc49505d98a286a8be022337cdb762cb37f	3	3650	650	353	356	6	4	2023-08-09 12:03:30	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
358	\\x72b3e9e3a0d311518386d35aa18aa99e89db01822413d1c2cc267dd40b4a1748	3	3670	670	354	357	14	4	2023-08-09 12:03:34	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
359	\\x45730f1d5b82f9317ed6922d07dc0e4646c4eb014acadea37f3a517da66cff7e	3	3683	683	355	358	33	4	2023-08-09 12:03:36.6	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
360	\\x76ddafe24c5a182fe9e9ade5725acbac5a7be7df167b0af9198b1c26bbe0f5b9	3	3687	687	356	359	6	4	2023-08-09 12:03:37.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
361	\\xc52df0bed59054800e881d7c0763572e970242ba1d5a69b4aa1ed45f46a30b4a	3	3703	703	357	360	33	4	2023-08-09 12:03:40.6	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
362	\\x055b3e50a0bb8ebeaaecd492a2e79ae02f7cea7d0c93343d423100e060b0b9ac	3	3705	705	358	361	7	4	2023-08-09 12:03:41	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
363	\\xc11c99d16d03c52e55e1ee0d0a40adf48a0f1e12ef866869e6174b54cdecb6e9	3	3722	722	359	362	8	4	2023-08-09 12:03:44.4	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
364	\\x2018130c97a10db0ffc3e92f73ac43645d00bef9fb2724ee9497ea724f0f9ec5	3	3727	727	360	363	14	4	2023-08-09 12:03:45.4	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
365	\\x0075b2d37416cfa2b8efd095a48818115bd02636b9840d92697005082fda9966	3	3729	729	361	364	5	4	2023-08-09 12:03:45.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
366	\\x576ef634bdd18334f7520be034326c841a15a667f03432855d94972a116db589	3	3736	736	362	365	7	4	2023-08-09 12:03:47.2	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
367	\\xa53fea08835f2b97a2989306692e892e40eb2e4e2821900f34c08a9041480da2	3	3737	737	363	366	33	4	2023-08-09 12:03:47.4	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
368	\\x6fe31118b7342bfe032f0c4f74a93112b8f9e8e7b89df1af8170d813bd3404fe	3	3748	748	364	367	6	4	2023-08-09 12:03:49.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
369	\\x19f47d2c1dd7e9abca93f3a43b4ce7d24fb87e850cfaf4b3df6bc311ecac1ef5	3	3756	756	365	368	8	4	2023-08-09 12:03:51.2	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
370	\\x2146a1eee5aa707e77b2d978e46db2da016ab77a1194ba1a55f7a36f4c9869a4	3	3764	764	366	369	37	4	2023-08-09 12:03:52.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
371	\\xbd7589ab3f3427debd7d9469c6b7212dfc12ba83889091d94d496e7fa3ce41ce	3	3769	769	367	370	5	4	2023-08-09 12:03:53.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
372	\\x1dca8e7d801019c4c9d800ae51326bde96298dd69f21ade18ba7084828644a45	3	3777	777	368	371	4	4	2023-08-09 12:03:55.4	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
373	\\x85234a340aa9d1f33d30fa8b9a107f1a4a4611e2b060788b388ed3a1b02864f0	3	3783	783	369	372	14	4	2023-08-09 12:03:56.6	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
374	\\xdc9509466e8891c0e1d6da729179798a48c57d0ea61119761d01714abceba1e2	3	3789	789	370	373	37	4	2023-08-09 12:03:57.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
375	\\x49e1026ac11daa3d137ee9dcc5861d31b2654ed44409debd15bddc8cac6e1320	3	3794	794	371	374	14	4	2023-08-09 12:03:58.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
376	\\x0a42f85ab8ffd4e219a8d72d67642d5ee8b71c6b88b2d121b3a9f21b91d1c71f	3	3806	806	372	375	4	4	2023-08-09 12:04:01.2	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
377	\\x9c4ea1677aabd20d53ded8188f9cd575f6760a6c73b38d8b52f7347fbd7180a5	3	3849	849	373	376	11	4	2023-08-09 12:04:09.8	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
378	\\xd7a7ed255be4aa7643f86447a0b12194daa8631ac0231004fc65d7aa46847599	3	3853	853	374	377	33	4	2023-08-09 12:04:10.6	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
379	\\x902d60bfe71a51f8bbb2584c5b99c6ebe452a038c6dbc9ea33eabea926f97150	3	3874	874	375	378	5	4	2023-08-09 12:04:14.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
380	\\x9776b2a5a4001602b855c9308fd22896e155ea2f74838702d3d142d68b622684	3	3882	882	376	379	9	4	2023-08-09 12:04:16.4	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
381	\\x24d1dcef5b63d841d6659637ad57315b17b5b2ef51686fff946c7b8d85b2e0a4	3	3895	895	377	380	14	4	2023-08-09 12:04:19	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
382	\\x266600e3e20cfb9a24e45fd5e58f51e9f7387a517a573a0e446422f519aa1540	3	3904	904	378	381	8	4	2023-08-09 12:04:20.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
383	\\x5ab5ccb46f70328ade888312b160020c0d95e39186c8059d93670e84ab94c0ee	3	3916	916	379	382	14	4	2023-08-09 12:04:23.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
384	\\x161620346c915bca6e79c8da827c365abe35e3554001aed7f753d09db5b86c2f	3	3924	924	380	383	3	4	2023-08-09 12:04:24.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
386	\\xb935067bf7140efcc9dfd2f3d19d162b2475c28e2c6c0f02b08618bf9d5c18ac	3	3928	928	381	384	4	4	2023-08-09 12:04:25.6	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
387	\\x4cb4cf33541a81d0244a7a34daa9de5eb6f82d80423f9d61175b1ef0319e0ae2	3	3933	933	382	386	5	4	2023-08-09 12:04:26.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
388	\\xd9dd1470a125d852b77a7b60d673e99b4baaca52dce47c897e4783e8e9c82db2	3	3934	934	383	387	7	4	2023-08-09 12:04:26.8	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
389	\\xaf763105182b925f19f1d3339bb0448f88a307c3f04452cd6cb27b20e2dfd57f	3	3940	940	384	388	37	4	2023-08-09 12:04:28	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
390	\\xb3458ec742840df2f63b9a43e10f345eae4f0c0e09af0bb780a80944c42b1b07	3	3944	944	385	389	8	4	2023-08-09 12:04:28.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
391	\\xf27d645d006fc517fcc86383ee7aa2252aa9c3827cd9aba157b3c55bdf81bf09	3	3965	965	386	390	6	4	2023-08-09 12:04:33	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
392	\\xa778038e9bb400e84b95d0372b39ecaaedc78cffd9e5f753b25b9bcfa5657063	3	3967	967	387	391	6	4	2023-08-09 12:04:33.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
393	\\xaece56d64d6b9dae40aaa72b4896080fa30dcceab9e615e119817e244ef242c9	3	3968	968	388	392	7	4	2023-08-09 12:04:33.6	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
394	\\x5895ba1fec5a30c5f22573fc89257d291ac681519c01d567698da9780de52cc5	3	3973	973	389	393	5	4	2023-08-09 12:04:34.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
395	\\x09e970928a8ee7c06859200dbd42cdeb48cb71cc568b795d50aebee8f01d04df	3	3979	979	390	394	3	4	2023-08-09 12:04:35.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
396	\\x582f42efc99a12446660a4da5577a0b2c2ee11f560add51241c8eaf8948df8cc	3	3986	986	391	395	3	4	2023-08-09 12:04:37.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
397	\\x979cf49c3451d0f9decdaf49c85b309f632e22ab078b5d68000d9e50c086b279	4	4014	14	392	396	4	4	2023-08-09 12:04:42.8	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
398	\\xc8e8d52ba716d3fa851e228a0bfde33d9be4632a62ccfa61218b7b762d786e5c	4	4021	21	393	397	7	4	2023-08-09 12:04:44.2	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
399	\\x051991fe3f44e9222c927a8a40d04bb566a0f979e706cbb24b270bee850daf6e	4	4029	29	394	398	7	4	2023-08-09 12:04:45.8	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
400	\\x811297185a06718ce0e3019bdf247635cc8a074d8a63a9bf9a3aed8657701c02	4	4035	35	395	399	14	4	2023-08-09 12:04:47	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
401	\\xe93eee755b215c3e4be93def6ab41e28d9548c829cfdc8e1d83d921cb4afbaec	4	4049	49	396	400	6	4	2023-08-09 12:04:49.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
402	\\xc3bcda03ed70ed557aa6f5784915d9fef83cd2aae376105002dc724ca34f2acf	4	4058	58	397	401	14	4	2023-08-09 12:04:51.6	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
403	\\x782f0b95192145c8bcf4e49bac147b0b9f587a77f291de87ddcd1dd06011de5c	4	4069	69	398	402	3	4	2023-08-09 12:04:53.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
404	\\xbd5fda51ac7326f71bb0a65cd448f065bcd2907f7154ea5dbaf7abb85931bac9	4	4070	70	399	403	4	4	2023-08-09 12:04:54	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
405	\\xe73681551d0f15551ead70855d58e9f6e1242e3cc2fbaeeafcd43d118909a8bd	4	4087	87	400	404	11	4	2023-08-09 12:04:57.4	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
406	\\x0945e28e7bedda46c2cce155cda9f16b3f49e6f9730f8f2595783a8ed0a0c9da	4	4089	89	401	405	5	4	2023-08-09 12:04:57.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
407	\\xb573a956a94793b542beb9e48bc3cafe2573bce3a5860964a4e729c7bd6e4bf0	4	4094	94	402	406	14	4	2023-08-09 12:04:58.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
408	\\x811ad46fff6d9110407aef1edc8e40f436bf293c99cf46ca5ee8728276345b51	4	4107	107	403	407	9	4	2023-08-09 12:05:01.4	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
409	\\x37f66079f10fb2028200a2d54c514444b406cb717f1537d9f15893c3042050b3	4	4110	110	404	408	4	4	2023-08-09 12:05:02	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
410	\\xf1f5dcf61659dfd857e5b189429a309660d849e0ba3ea26daa59acfeabf210cc	4	4113	113	405	409	3	4	2023-08-09 12:05:02.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
411	\\xf01a92a5f3d0605170ab10f19e2c3413f01f4091cc4a0c24804c39eb0d5a5d11	4	4135	135	406	410	5	1009	2023-08-09 12:05:07	1	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
413	\\xbb14644fc2927568e945d972def792473b9001ca0889ed29d171494589510c98	4	4149	149	407	411	3	4	2023-08-09 12:05:09.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
414	\\x97a8d4509c5ac9b41c5811c6ab8d82b1a55126b5d68547154f70d7326cd1f0a8	4	4157	157	408	413	6	4	2023-08-09 12:05:11.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
416	\\x8b981581e47ac4366f23ccaa27e1f5ebea3f7301e8fe05c9c3e0d3c91434519a	4	4158	158	409	414	6	4	2023-08-09 12:05:11.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
417	\\x531ebbe83ea4a8a796514db81a15d9b4f86e7e984261d43dd1df573935dfb310	4	4162	162	410	416	6	413	2023-08-09 12:05:12.4	1	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
418	\\x21c6aeb01b36362eb163c0e4f8ab5da49a039d552d69a4c35b9222bea0e4fa7f	4	4163	163	411	417	33	4	2023-08-09 12:05:12.6	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
419	\\x3ddf784ac957363e706941a06506b83ac5921c187e16ac272601701066fee6fc	4	4175	175	412	418	5	4	2023-08-09 12:05:15	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
420	\\x4b96919b56ac7b6e8a9d809915f23afde9dd946f44928e28aed693456c216ba1	4	4218	218	413	419	8	4	2023-08-09 12:05:23.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
421	\\x67b978eeb0e392b30248ed0cc8f205fbc85c176d3f21fe11ec74a365e18bc97c	4	4219	219	414	420	7	335	2023-08-09 12:05:23.8	1	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
422	\\x9f914ea89b6c4b8857a52f0de03b007ab9bfadb88935244e12289555be4f0fa3	4	4233	233	415	421	37	4	2023-08-09 12:05:26.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
423	\\xd6ac4f0e548bf57c7d8e9d7f39923a15e6c8a3dc50d0c3ca9d947610252190ed	4	4247	247	416	422	11	4	2023-08-09 12:05:29.4	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
424	\\xc101211795e424aa7eb97d02d0b078e8bf3f5f3ad1ead7c2be780d94840c662d	4	4252	252	417	423	11	4	2023-08-09 12:05:30.4	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
425	\\xa1b7945e147bfc0ce885395bdd6660e4834531ff949557f94e039f74657171fd	4	4255	255	418	424	9	308	2023-08-09 12:05:31	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
426	\\x39a585b0d80cd7c41c090c5144db0bc3bc18c75539ae6d208306ee6f51eb99b9	4	4280	280	419	425	6	4	2023-08-09 12:05:36	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
427	\\x98e2950d0f7c8aef3de46dd4406c7a4f755a4f697ffc3f0b3a731dd0d75e119c	4	4296	296	420	426	9	4	2023-08-09 12:05:39.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
428	\\xde22fe872db9a8eeec423bf4d73d47b772392a93d88613718f78a90d46961458	4	4314	314	421	427	6	4	2023-08-09 12:05:42.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
429	\\xde84cf774174addee3494789bddd380a2a836f5ee2b77ecd5f4406ef136627d9	4	4315	315	422	428	11	405	2023-08-09 12:05:43	1	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
430	\\xd742808b16c96b019d0692c5c4246962204652509e9a9c67fc906ed8efe773e6	4	4344	344	423	429	33	4	2023-08-09 12:05:48.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
431	\\x1b3db213e6ebf390b397557d38064538f549e35c21d36b20e6770949350e1804	4	4377	377	424	430	3	4	2023-08-09 12:05:55.4	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
432	\\x81de91e6a9a44af8b1963914c9d8925768884cf6fe3ccd4e95154fda863deced	4	4380	380	425	431	37	4	2023-08-09 12:05:56	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
433	\\x89cbb1d25de55c3f1b10eca1f34759382d4b6063581393761a4dec520cccc44b	4	4382	382	426	432	3	753	2023-08-09 12:05:56.4	1	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
434	\\xc9cca9f3da09a6131473f865ba786f5e406095ef585f851309f45d5a2fc6af4a	4	4385	385	427	433	8	4	2023-08-09 12:05:57	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
435	\\x86a26af55150c15c7ec76ae1bbbe3cf8ee6be23af4b7eca499ed0114ec475d40	4	4390	390	428	434	11	4	2023-08-09 12:05:58	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
436	\\x1eea1b6b64020b9973aef23ce393f0ec9a9df8e3f0570d02aad4e36f2fa709cb	4	4395	395	429	435	9	4	2023-08-09 12:05:59	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
437	\\x7359f7a88249324c8e9a358b4095bc6a1c19533f64c421a84d1b82d01d67b7ef	4	4409	409	430	436	5	753	2023-08-09 12:06:01.8	1	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
438	\\xf60b1979bd0287a986d2c94c752265de3029d89b73fadff91303252a60616d6d	4	4423	423	431	437	3	4	2023-08-09 12:06:04.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
439	\\xb99b25de885610a0ad7fc1e9afcb2333252aaa27292b2cac05e78fd1f113686a	4	4438	438	432	438	5	4	2023-08-09 12:06:07.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
440	\\xa9a8723296bd9050cb11dcbb537d608e2367ea25fc3552ec9c3bb93efb99814a	4	4454	454	433	439	4	4	2023-08-09 12:06:10.8	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
441	\\x4697ec721ab1bd21452e399276a3bc1b0ade882f20b0f064d2b07731db7257f3	4	4455	455	434	440	6	4	2023-08-09 12:06:11	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
442	\\xdfc10b8dde0f3a28245279b8508bba2e66c0ca6ab96b2cf62b25f78aa4759849	4	4476	476	435	441	6	340	2023-08-09 12:06:15.2	1	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
443	\\x072d55c8a62a1f02262df887f0f6485d50be7ec88519c1c54421037069a6c0a2	4	4478	478	436	442	9	4	2023-08-09 12:06:15.6	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
444	\\x625623740c7d4e405445fea26f01f742331e4487cd3b13a7d3d84730fc675c7e	4	4480	480	437	443	11	4	2023-08-09 12:06:16	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
445	\\x121a168baca74676d99fe6d25865cb920dde9e5b1d746d0bf2798ddf6733f7bb	4	4499	499	438	444	4	4	2023-08-09 12:06:19.8	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
446	\\x141215c685b218b8ad2c2dfc0754ef2f8484baa0a4a252a6a6dfd3d157c9bd75	4	4504	504	439	445	33	753	2023-08-09 12:06:20.8	1	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
447	\\x762c6e4f3f382937549cebfe5c487ac7ef700657b776d2e85f78c34a8d7f0ade	4	4552	552	440	446	7	4	2023-08-09 12:06:30.4	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
448	\\x70af7d0df86a8e79642bb312b02afaf9279cab222d18cea5777b1bef1fbcc11b	4	4553	553	441	447	11	4	2023-08-09 12:06:30.6	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
449	\\x67bc42860402b6f7f3c70aa20b22316de12e7815ee2a04b5dd6bf444c9d614af	4	4559	559	442	448	33	4	2023-08-09 12:06:31.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
450	\\x21b35f540361989ab9990453fd17c53f61dcce7428a1f51b0f0280af291c7091	4	4565	565	443	449	8	304	2023-08-09 12:06:33	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
451	\\xbacfbc58b2831557a115ccbeb4cb8afcd7bf7ca29d93f6f0d741b6670f0c281d	4	4566	566	444	450	37	4	2023-08-09 12:06:33.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
452	\\x493e25cb68d58f9ef436049681ebcf42213413fbd36d3595d9dbd4b982217ec1	4	4594	594	445	451	37	4	2023-08-09 12:06:38.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
453	\\x179638c34d3695518f85c21a0d3b3fdb485699d3e11abe0b37e1ffd0c5d10cef	4	4597	597	446	452	11	4	2023-08-09 12:06:39.4	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
454	\\xf32df39f286999897457841ec2fdfd665f786f1838adcda4808aba8d48acdc9e	4	4612	612	447	453	4	789	2023-08-09 12:06:42.4	1	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
455	\\x9b2226624815b715bb83c4ce24230e581901379c10514ec7d069bf2a62c1c636	4	4614	614	448	454	8	4	2023-08-09 12:06:42.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
456	\\x6c1f6adc5305a8b43970beb0add105d22fb54c25e001768b05f22f25a2b0cb5b	4	4618	618	449	455	7	4	2023-08-09 12:06:43.6	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
457	\\xadcef96c02c57ecb96fe6d730492b0aa1468b18fac307fd3f5ecd4acc503d6a3	4	4622	622	450	456	14	4	2023-08-09 12:06:44.4	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
458	\\x16d9522e925cda73a1d761e45775c3b4246ec8500f48b525c4486c8b5e1a4b91	4	4625	625	451	457	14	346	2023-08-09 12:06:45	1	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
459	\\x944c9913122a61c40258ef52233d18c9e3bac0fc0ecadcb0c7ea5680ade9caa4	4	4626	626	452	458	11	4	2023-08-09 12:06:45.2	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
460	\\xa70e0cf4f6fc3852bcb97e35d2bf92d07597c02364df2791934a8617887ec182	4	4629	629	453	459	11	4	2023-08-09 12:06:45.8	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
461	\\x3d4e0296c7d318a623cd70c02e0a9c4a6c18b3e9ccd9b4bba1a699d745862a8e	4	4636	636	454	460	3	4	2023-08-09 12:06:47.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
462	\\x82689e9a5eefa2baf9522f59d8035767fd467dac6b3612762f8b279f82340f67	4	4638	638	455	461	6	304	2023-08-09 12:06:47.6	1	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
463	\\xf70b6811f99187ab8368e59edd517bc420a6cfb0437acda1ef8722c2c4bbf87d	4	4655	655	456	462	14	4	2023-08-09 12:06:51	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
464	\\xada759b71eca284c4728e46c81b36a23968ece2a2e30526bff642e2ea1db1332	4	4668	668	457	463	37	4	2023-08-09 12:06:53.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
465	\\x3ba7d304c2ca3b393865ce387fd9a6ac867e3bbf0ec44e9159260f9374e8a132	4	4684	684	458	464	9	4	2023-08-09 12:06:56.8	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
466	\\x6ac8fdb47078c71e64f761dc947f9089538d94d8cf6c84db80ade96913569c4c	4	4704	704	459	465	8	1144	2023-08-09 12:07:00.8	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
467	\\x39bd50a095974c70d4ec11ce20ba1da1f349e6104c759a75082d84db50f9db3a	4	4721	721	460	466	6	4	2023-08-09 12:07:04.2	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
468	\\x4351226e7555a99e7b2de3b441fe1f5b40ccf7882dbd161d757e5736dacc43e6	4	4722	722	461	467	6	4	2023-08-09 12:07:04.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
470	\\xccdd673b6446d295a9784435f644b4b024bf821c96b2821aefd347790627287f	4	4732	732	462	468	14	4	2023-08-09 12:07:06.4	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
471	\\x75b90645acc45d072aa7b82dd045c4b0568af682e74b0e78e1a222522e2b6da4	4	4738	738	463	470	3	566	2023-08-09 12:07:07.6	1	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
472	\\x6ecb648a83d87259d3a34ed493d95550d2ba90dec003fdb093e0dedafc9364b6	4	4743	743	464	471	6	4	2023-08-09 12:07:08.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
473	\\x97f9b5813542e30b01f54701304832cbe23c41254c2e977d64a4b6da37a15655	4	4749	749	465	472	33	4	2023-08-09 12:07:09.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
474	\\x8b7b0c30390365c5ac35190eba44ea6fc9dcc1c07c203f29caa2b9299c835314	4	4750	750	466	473	7	4	2023-08-09 12:07:10	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
475	\\x2f4a743cafd570ec65dc9991df5ce7d270fd5b9adb32f26fa02de35e7405583c	4	4761	761	467	474	14	779	2023-08-09 12:07:12.2	1	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
476	\\x99e04f93ee3a265b68c03d01a53d69b2237c77ab763d99523e93d64b422ec5fb	4	4766	766	468	475	9	4	2023-08-09 12:07:13.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
477	\\xde916bcb0f777bb39f819913ad301da776cd7a0d267891d915f4a7c5dd227eeb	4	4780	780	469	476	5	4	2023-08-09 12:07:16	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
478	\\x2c2fd219d39eb9c4a3040648da0a8054509f13e2f7cee2d153d486b7ed88c1b4	4	4783	783	470	477	9	4	2023-08-09 12:07:16.6	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
479	\\x2024650f9076abac2c1b9fd97c18acf34bf97ccc921d600873dee6f66cefcd1d	4	4794	794	471	478	14	832	2023-08-09 12:07:18.8	1	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
480	\\x13d73e838e7fabc2529963eef83352219b29dfb779e2d2e82ad3840514d444d9	4	4799	799	472	479	7	4	2023-08-09 12:07:19.8	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
481	\\xc52c81b052ef811e699bca262e8ec7aa9dda0f6f8a85472491f07c4fc8b8e5a7	4	4818	818	473	480	33	4	2023-08-09 12:07:23.6	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
482	\\x07a7bbb5af3290113772e2849e1d98a019d2c4a06fda56a16ad42f670a26eef0	4	4842	842	474	481	37	4	2023-08-09 12:07:28.4	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
483	\\xdc165ca3a4abe1d557aeaf845e3e8f7570901a7d533ba319d9cc0ba94b626221	4	4851	851	475	482	6	766	2023-08-09 12:07:30.2	1	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
485	\\x10cad06d8fcfbaf115c18225d31b521d0f65b92b39280c4a5e302e2521414c99	4	4852	852	476	483	11	4	2023-08-09 12:07:30.4	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
486	\\x32621c15df7e61ceae66ef0ea604bb9deec44592b4661809008825da309d761b	4	4859	859	477	485	6	4	2023-08-09 12:07:31.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
487	\\x383ad54258197cf0df6c608e37bf4a01eaba70d4484864358b0181a88b102cc3	4	4879	879	478	486	5	4	2023-08-09 12:07:35.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
488	\\x6cccc63c6a7de1117677d863a0a81f510bf85f935e81faa2a931a6e03ac72fc2	4	4880	880	479	487	6	543	2023-08-09 12:07:36	1	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
489	\\xaa6ed3fcb81bb7a3e004b338ee7b192831fb02ad743f58a8b9596e73429c6ba9	4	4893	893	480	488	5	4	2023-08-09 12:07:38.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
490	\\x77f11205a690ad741cda12730b025eeef8c3ee98e0e6decc5137d59b66f1f7b6	4	4894	894	481	489	4	4	2023-08-09 12:07:38.8	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
491	\\xf0c451d357aa585e57af43845ffa824cc0a49d5863af2fd2f47de4f778e7019b	4	4903	903	482	490	5	4	2023-08-09 12:07:40.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
492	\\x50d319588c3b6bd601942c1ea208aca645b1dbd098ab42d2e1278a13cfe97f2c	4	4907	907	483	491	4	4	2023-08-09 12:07:41.4	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
493	\\x5253cf0ffe7e1f0c3f1dd8ccd4f4869551b8cb76076112809a66aac6438c38de	4	4919	919	484	492	4	293	2023-08-09 12:07:43.8	1	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
494	\\xaa9384af7f99c60633cd6e27d086fc32bf3cb8b9a4af163bca9c2264ab2976c8	4	4942	942	485	493	3	4	2023-08-09 12:07:48.4	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
495	\\x1ca90ea5f5174781e191052dff4530a29e9ea567610b6d4b8da195f5bca4e5b1	4	4945	945	486	494	37	4	2023-08-09 12:07:49	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
496	\\x4b559fcf90bd0e03b58d6414bb8794abaed9db31f7fcb0f4e771906251c56781	4	4949	949	487	495	37	4	2023-08-09 12:07:49.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
497	\\x6468a30478700ba1749a77685014dd5d0181cb4fe4f9fc40a13b2104e648073e	4	4952	952	488	496	9	3432	2023-08-09 12:07:50.4	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
498	\\x286d7586116e94a828c8f8b4c30cb2f8f880f967f0151ae564fba0305936dbe1	4	4956	956	489	497	6	4	2023-08-09 12:07:51.2	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
499	\\x6ecf9623c333be73309bb46c0ff879dd94ac5b6e001770538474b61b146d7b1c	4	4991	991	490	498	3	4	2023-08-09 12:07:58.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
500	\\xf843a3acab2c7c39501e70b8cbdcfcef09e2d490524b78bc2ccdf2aabe130e54	4	4994	994	491	499	7	4	2023-08-09 12:07:58.8	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
501	\\x92ee81540168af3e19074ee317f0b8b98ad40385de265586a40ea6e46621c3ce	5	5010	10	492	500	14	1980	2023-08-09 12:08:02	1	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
502	\\xe29c69c0850f5f71b63c348605d3a617e07d00e09622dfb786fcd9ddfe4f647d	5	5014	14	493	501	14	4	2023-08-09 12:08:02.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
503	\\x734950d1c2318978c8608b607f7fd5f9b72e73cdfaa0221b8d2926743fa3bb3c	5	5029	29	494	502	3	4	2023-08-09 12:08:05.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
504	\\x3d0ec9409b05e6f1f20616edfdb183b740a75773e610c32faf6ecb2a69c3a075	5	5037	37	495	503	4	4	2023-08-09 12:08:07.4	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
505	\\x3af5c67b583a18a3986ff74c2c517212891bcc3793a5dab9f94e564207649a05	5	5040	40	496	504	3	1051	2023-08-09 12:08:08	1	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
506	\\xd938e53f95b5a098ab01803c1cfd5c1fbb5bf124643bb5a41de0471159968f24	5	5066	66	497	505	14	4	2023-08-09 12:08:13.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
507	\\x500679c180191cfd78a9081398e2f8485ca8886cd48ab6468b6acd022487fd53	5	5069	69	498	506	11	4	2023-08-09 12:08:13.8	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
508	\\x1d65d56c9c838aa6712884179e84f00c10f88277f8b5fb35dce360a2c109d8d2	5	5070	70	499	507	11	4	2023-08-09 12:08:14	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
509	\\x4139b057b94fb177cbd74cc5c53128744a769b78e10486feee1be5c05bfb8388	5	5074	74	500	508	33	4	2023-08-09 12:08:14.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
510	\\xf50c80d5ef3f2caa23b7cb30b958ee2f52887338072570ad69391bb1c3115249	5	5081	81	501	509	11	648	2023-08-09 12:08:16.2	1	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
511	\\x50c939ad0e650b7715a4bd31ce21b217ab266a08093b3e0a4c35d0cc3aba8ac6	5	5084	84	502	510	5	4	2023-08-09 12:08:16.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
512	\\x4eb9011c2c7ad9aa7e75cd2ea2c7edc94148ba69c152674cd555e3aab2065e86	5	5099	99	503	511	4	4	2023-08-09 12:08:19.8	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
513	\\x4b5b82109293c2fe94000cd13c65a12e58dbaefc0a70449a1231d3b8259f22c4	5	5114	114	504	512	37	4	2023-08-09 12:08:22.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
514	\\x865e363f71da6d9ebb1984ae957451dcbfff89a9461905319c056d9967434b4f	5	5124	124	505	513	9	539	2023-08-09 12:08:24.8	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
515	\\x8761d1ae74e10539ec9d006a4e5045973ff4175de218529178ca8c38cd0d7894	5	5127	127	506	514	8	4	2023-08-09 12:08:25.4	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
516	\\x18d089c5b431f611a3c2e51800768f623092e85db19c4e07480d73def36e52c6	5	5138	138	507	515	5	4	2023-08-09 12:08:27.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
517	\\xdab61a4ab728a9a087e243c7d32efe971a91c0ed9473698d7404597f71cdcade	5	5151	151	508	516	3	4	2023-08-09 12:08:30.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
518	\\x6a42a0e4280ed6633640ba605fd89faade3d7eb904a382eec8f65c493c42eef1	5	5165	165	509	517	9	541	2023-08-09 12:08:33	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
519	\\x573d8af40d578c4878340e451c9d852a1e09bbced9dfca4509d6564a111bc02e	5	5168	168	510	518	5	4	2023-08-09 12:08:33.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
520	\\xc93d3208bd15c94a7b6811a5e9d3d31aac26778d078a6d1b82a2cf53c5d00557	5	5173	173	511	519	14	4	2023-08-09 12:08:34.6	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
521	\\xaae25a9663fb2faeed51ba1c590665c01f8c96fd8db59d972d1fdca5a9cd2270	5	5192	192	512	520	9	4	2023-08-09 12:08:38.4	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
522	\\x3a1c5fc18fa82a12d764801059c4d367b43b8ba8336ccd335de2c1821afd141a	5	5207	207	513	521	8	401	2023-08-09 12:08:41.4	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
523	\\x182effe4062df7761a6c0ce7e222612b167be1c7a14726cf147bb72b42181d4b	5	5210	210	514	522	6	4	2023-08-09 12:08:42	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
524	\\x5592a458b9277d46b672bc0b66414d81ca6374f4b53668ec59ec27062c812a27	5	5241	241	515	523	37	4	2023-08-09 12:08:48.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
525	\\xc644ecadc8db6105cd2b48b943601c0069e10ffb73ec2e3437ed42232efe3234	5	5244	244	516	524	14	4	2023-08-09 12:08:48.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
526	\\x70a8bab48541d3b4cb5288dc14143738b80f856e8337f005114b9c83de5e146e	5	5274	274	517	525	4	293	2023-08-09 12:08:54.8	1	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
527	\\x6852d93c7c1c4b5310b55d8a6de820840d668517bcc3b05ddcbae7701735fc57	5	5284	284	518	526	11	2407	2023-08-09 12:08:56.8	1	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
528	\\x936bc27fbfe05bd4983dd629f036224eae5d749c7282b1bc65a104a536b88654	5	5310	310	519	527	4	329	2023-08-09 12:09:02	1	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
529	\\xb14e547ef1ed5eeb5d3f00198718c13b1207f24649d453b265a602b1e2751c4e	5	5319	319	520	528	33	329	2023-08-09 12:09:03.8	1	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
530	\\x97fd852d64729cf95882698572ba6732f131cc1a2bbb374a80b012a461bd7102	5	5329	329	521	529	37	490	2023-08-09 12:09:05.8	1	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
531	\\x9e522198b5455cdc92b0c69e9c5b6fc5ac54765f76d3f9bd02248b4b38de4028	5	5340	340	522	530	7	365	2023-08-09 12:09:08	1	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
532	\\x327cbdef9ed17d3ef013d0925e8d113bf6b4579cce8ea6534ee240c2434ee3a4	5	5356	356	523	531	14	662	2023-08-09 12:09:11.2	2	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
533	\\x94c8548effc77482fdc8c2e276f0eda2422947e9c1c814efd05b229c54a9323b	5	5357	357	524	532	8	4	2023-08-09 12:09:11.4	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
534	\\xa2d9eb8488b0848fefbfa160cec00e469f1a2df1da58ca7de62133e473628d24	5	5365	365	525	533	9	4	2023-08-09 12:09:13	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
535	\\x7ef6d21bef92624b9f32993ca62af365bf7cd6c8b3ff83caab776f4e58d43772	5	5389	389	526	534	5	4	2023-08-09 12:09:17.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
536	\\x870a75f57af114cb650b189aaeb549cfd73c34386b01d7649b3fb2ace722e6b0	5	5391	391	527	535	8	4	2023-08-09 12:09:18.2	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
538	\\x0331fdb66b085ded323ee8f14edbeb18a0e8a25058813f8cb418538d1ce23c4f	5	5394	394	528	536	37	4	2023-08-09 12:09:18.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
539	\\x60c980da7fc5a4d68376a6120aa3e59aebb17ee990132157bc1a5e1af9467b6e	5	5420	420	529	538	4	337	2023-08-09 12:09:24	1	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
540	\\x33c76559856a18e98e11cab0241773a97cd4718c0f25d64145b181ad610d30d3	5	5422	422	530	539	37	4	2023-08-09 12:09:24.4	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
541	\\x3bc4ce69e93b27d45cba4ce2143987d6e84cd34f9e5cbc20ff6d2af807622e6d	5	5447	447	531	540	9	8200	2023-08-09 12:09:29.4	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
542	\\xe164fbd53b9aa635ac310e37f32676e9303fe87491f55b1c9b925c02cee872a3	5	5449	449	532	541	8	4	2023-08-09 12:09:29.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
543	\\xa115cdf500012465ad18606a5ad343f611dbbaf3b1a7e1f4a8d11fcf6eb10ac9	5	5452	452	533	542	8	4	2023-08-09 12:09:30.4	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
544	\\x22f9ce82df8fc46e440dd0aeda25f31d5a945c030f929c580feb24f0055ae05f	5	5470	470	534	543	3	8410	2023-08-09 12:09:34	1	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
545	\\x1c8092e9f7143aa27a38121105dde7d9eeebec187a8284bed855f43d3574f660	5	5500	500	535	544	37	4	2023-08-09 12:09:40	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
546	\\x5a6769da80a139f53efae100597e9a9d66c5a0969ddb31da6b025c411b2d6de2	5	5503	503	536	545	7	4	2023-08-09 12:09:40.6	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
547	\\x88a00e95bb611b0c21176486d66ad761c85770f2ae7e5a6ab1149cd69f12b9d5	5	5512	512	537	546	33	4	2023-08-09 12:09:42.4	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
548	\\x3dff9929f9a4f2e19501ed59b19fa8c2cea134b92b81ebb120fce5576e03effb	5	5514	514	538	547	5	4	2023-08-09 12:09:42.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
549	\\x461e6c9d7b4d5d634fd3fed64754d096deeb2b2e5b87e910b527187a364deebc	5	5523	523	539	548	33	294	2023-08-09 12:09:44.6	1	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
550	\\xb574f2328978fb1fdea8873a28dd36aedaf9537e1af85824f0d1643b19f4349b	5	5533	533	540	549	9	4	2023-08-09 12:09:46.6	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
551	\\x77466ac89a7da3533df84854fbbf9194319c06a561547562da7db5b4e87d2873	5	5541	541	541	550	9	4	2023-08-09 12:09:48.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
552	\\x31a17c42082d336e56d87a33eb1cb75cc92e07a4ec788e4accc7f843c7f3d1f5	5	5545	545	542	551	14	4	2023-08-09 12:09:49	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
553	\\xa81f47e78bbfc5c650594d003905ad85cb114a7f39c7723896d1f57714a9394e	5	5552	552	543	552	9	285	2023-08-09 12:09:50.4	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
554	\\x37eafef884f8e17a16f7e65a86c70c7131653fde7356078551e8aa1f7194c495	5	5604	604	544	553	11	429	2023-08-09 12:10:00.8	1	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
555	\\x1dba4cf60e1a2c7bd3455368ad1e44c0345f9d8d984cfc8979f3b19c23f5bc10	5	5618	618	545	554	3	4	2023-08-09 12:10:03.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
556	\\xeea3dd93d9c2f7b17b84f96224c907ed6eecb4eed037f85763e03b1b465b06d0	5	5646	646	546	555	4	4	2023-08-09 12:10:09.2	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
557	\\x480bf3281d51700972f918396bf1e4ab7f812559a8faaa396be3bc98d0237989	5	5648	648	547	556	6	4	2023-08-09 12:10:09.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
558	\\x0562c223b17123fef30f58c7333cd966cfac435b1cf52aaf1a50111d91ff9b9d	5	5655	655	548	557	7	4	2023-08-09 12:10:11	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
559	\\x81826e2eb8c9043bfeb536eedf299686c845928637f72a926ec52b148ff8ab25	5	5672	672	549	558	37	4	2023-08-09 12:10:14.4	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
560	\\x8870e5250bdfd42afd28ab6379126d64c8330d050980b2dfd5c4fb6ab953dd19	5	5674	674	550	559	8	4	2023-08-09 12:10:14.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
561	\\x06e3282b51e28e2e53299b4012295e4a37fe6477d27c7834c201acf182fbbb2f	5	5675	675	551	560	14	4	2023-08-09 12:10:15	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
562	\\x7ee1a4ca7eed643660662e2410a22cc96f0c6d04b58c0e96e6d66782f2cb85aa	5	5678	678	552	561	6	4	2023-08-09 12:10:15.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
563	\\xebdc9cade6ef568db8496053850c26936c042b91aff24ff78e2adceaeaac9121	5	5683	683	553	562	37	4	2023-08-09 12:10:16.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
564	\\xb3489525cf10a53ac43e7c2ef11d6562c501e8741537c75a3404e372d694f912	5	5686	686	554	563	5	4	2023-08-09 12:10:17.2	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
565	\\xf442d6e4f974871b191765041288baa3daaa38887aca8005c6c8cdeb0feb3ce4	5	5710	710	555	564	11	4	2023-08-09 12:10:22	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
566	\\x7f39e46b6d11b4b044563b522f80a2edda5289d4d8da507771a3c6a578a0ed37	5	5724	724	556	565	11	4	2023-08-09 12:10:24.8	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
567	\\x053fb8884a379abbc7c0ad727a62a7a904080448ce6e0cd97b914aa11c4b203f	5	5743	743	557	566	4	4	2023-08-09 12:10:28.6	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
568	\\x84dbb09f70d9bcac1c99b07d06e7ecd55d50b8a7475e7d5a08e82f9512cda7cc	5	5744	744	558	567	11	4	2023-08-09 12:10:28.8	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
569	\\x4abb672a89ae399c28f6c4b5814e84aedcd9b773c8ff6bdf3fc24bd2a7835595	5	5756	756	559	568	37	4	2023-08-09 12:10:31.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
570	\\x11d01a8ba86b3f5b3d04bceb6c1029915b4bc3b91c41f91b02e859a6dec740aa	5	5758	758	560	569	4	4	2023-08-09 12:10:31.6	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
571	\\x43a62d3c972d7818d069ba658060daee02765badd67d9968390dabdad056cb53	5	5759	759	561	570	8	4	2023-08-09 12:10:31.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
572	\\x6bfa8105843d5673df9cac9388435881e78b9bddfe3683a17493acf18908b961	5	5760	760	562	571	6	4	2023-08-09 12:10:32	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
573	\\x934ad5c8d7a2e128c28ccb0773ab8d49bea15d9a6aa1ef7e2ede69c475054a50	5	5761	761	563	572	7	4	2023-08-09 12:10:32.2	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
574	\\x14cb64f93ff713161c72a14a1bc88e45abf9de0de90a51bc9374a8af9565f2a3	5	5762	762	564	573	33	4	2023-08-09 12:10:32.4	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
575	\\xecc3d6323fac0f160675ff49bd42e588cb84bb952120c7ab25a29efdd87a62be	5	5773	773	565	574	9	4	2023-08-09 12:10:34.6	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
576	\\x681f573a68a86468ea116899f0b887b2f7bfa79664f9aa8ea2415bfa151136a6	5	5802	802	566	575	9	4	2023-08-09 12:10:40.4	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
577	\\xdcbd0b1101ea4ff83327edde2db88d83368157edcf6d12026d546f6f503d80ee	5	5816	816	567	576	6	4	2023-08-09 12:10:43.2	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
578	\\x2db096a4b30eb73d9b6401016a783338d31b644f27ba83730740d16fd7bb7fd9	5	5880	880	568	577	33	4	2023-08-09 12:10:56	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
579	\\x02d847281515207cfaa5e1ee47aeb74adbeff73dcbfd5d875f0a936618b5267d	5	5883	883	569	578	7	4	2023-08-09 12:10:56.6	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
580	\\xfba1a9f55fa4da6e465d92d87a29d625f447c4a7cdb5c75002bdf35b61525885	5	5886	886	570	579	37	4	2023-08-09 12:10:57.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
581	\\x5bc370fc7829996c4f0485cd7c59a036eaf9567898ae2636d6ba6b35848c6071	5	5930	930	571	580	37	4	2023-08-09 12:11:06	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
582	\\xfe5892660aa9a226a5addce180f3b1b92b73f62c043b57c4f57f54ed11fe6746	5	5933	933	572	581	9	4	2023-08-09 12:11:06.6	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
583	\\x311177c5e00672d926ef5c42a41e97750d9dbddf3044f7263fcdf377b272e6b0	5	5945	945	573	582	4	4	2023-08-09 12:11:09	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
584	\\x9de9a2ead0fdf86826e19eb04b19a2de68760b9aedddc6563184034ce414f219	5	5952	952	574	583	33	4	2023-08-09 12:11:10.4	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
585	\\x48ff8718a0dc092490dc9381a3241b818fdbc8e932d68893a802066ff75636cc	5	5954	954	575	584	9	4	2023-08-09 12:11:10.8	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
586	\\xc62951753f4b2386d37960791bb853eacd3c25fa16853b8b7571229ec7fad9fb	5	5961	961	576	585	4	4	2023-08-09 12:11:12.2	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
587	\\xb46ef10a26905bdda4e6f5e341923083fff28c6ff90c37a38469cd70ac483d32	5	5963	963	577	586	33	4	2023-08-09 12:11:12.6	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
588	\\xbb268d2c1416ceb2a423a8664e42001d04ad0f80dc43c836a2a47ed1e90244d7	5	5971	971	578	587	14	4	2023-08-09 12:11:14.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
589	\\x846fa4c5a6aecc2a5e330da63ce848628ad5cfa2fc963bf7e1cbd00dc98d8555	5	5976	976	579	588	5	4	2023-08-09 12:11:15.2	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
590	\\xc05839867d9bc88c513313fc22595305b5d9edeb0eb53b61d0ca16a5442cf8af	5	5984	984	580	589	11	4	2023-08-09 12:11:16.8	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
591	\\xa14ef3bf977432104284de39ec2e4beb5bd80029124def334400be0a649039cb	5	5986	986	581	590	4	4	2023-08-09 12:11:17.2	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
592	\\x0c5ecdcb3f389ee9bf59d09d15d32f080eedfb835b463020ccb2c03d314b5069	6	6017	17	582	591	33	4	2023-08-09 12:11:23.4	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
593	\\xdbd050363188cc83d80ba469186d68a49147ff61a0b4fc756211353b7844592c	6	6027	27	583	592	5	4	2023-08-09 12:11:25.4	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
594	\\x3997431077f508a1a83e463296f4333bcb3d1be4d002f7eb32d1c0f15a016970	6	6041	41	584	593	4	4	2023-08-09 12:11:28.2	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
595	\\x466a2cbccc682800616e0b1f4a79245065abc9b343b65fb21da4be30273f7a62	6	6057	57	585	594	11	4	2023-08-09 12:11:31.4	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
596	\\x6d66986cc38fa80c11cdd936a55d9b4ec125056709beac12e3d1e30103d3b645	6	6062	62	586	595	7	4	2023-08-09 12:11:32.4	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
598	\\xd3c8c5b32566786e7a9fc9057a4a03c8056fa7b8c9db88c8297730e7f12ae38a	6	6063	63	587	596	14	4	2023-08-09 12:11:32.6	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
599	\\x02a035ee1c9a6939e322d8c13211394b7d67a1d23948ddfe66306dda4c702026	6	6066	66	588	598	6	4	2023-08-09 12:11:33.2	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
600	\\xa722de383763749def64996774227e15ff74f5921493698841f7b0ec8f3bf1bc	6	6069	69	589	599	14	4	2023-08-09 12:11:33.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
601	\\xd0ac770a90f3b48bf78ff6257d440037b8ad5b108d035a2b84cb49b3bcd15720	6	6071	71	590	600	8	4	2023-08-09 12:11:34.2	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
602	\\x74906d1166f352da028f983e206de2a5b05a56d9248428e3b8186e47c7ebb722	6	6074	74	591	601	4	4	2023-08-09 12:11:34.8	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
603	\\xf615042a00ec38e4e2213e882700056a4a86c48e4ec3b6fc36eb1b278c5a076b	6	6086	86	592	602	6	4	2023-08-09 12:11:37.2	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
604	\\x55937df12ac29426ce221f86affc600fe7e2962a0265abe90627b6cd12c6737e	6	6087	87	593	603	11	4	2023-08-09 12:11:37.4	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
605	\\x906fca92d2cca32116ca9d19ab040b8b6d653f998d6162108309d7821182c16a	6	6114	114	594	604	37	4	2023-08-09 12:11:42.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
606	\\xb32d31c6ba7ec05dd91d23f7bbff8ff55d61e762c0cbae299b981cea7460a1dc	6	6122	122	595	605	37	4	2023-08-09 12:11:44.4	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
607	\\xa49695233f6aa9d8555aee448a89c5a2268d0bd93b57431d598ba0de6cb80ae2	6	6127	127	596	606	8	4	2023-08-09 12:11:45.4	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
608	\\x3c9e3ebf4fecebd18dceb0f07f319dde9caf8c1c5b7d32cfb73f700e1bca6672	6	6147	147	597	607	33	4	2023-08-09 12:11:49.4	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
609	\\x1554451462004cb772322da8fdda72152caa8013f29bc52ac14418821ef6f269	6	6151	151	598	608	9	4	2023-08-09 12:11:50.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
610	\\xd5f7d19984a47c584be8913eae4a683271611508f2b8d576ebb85c1afaa72dd8	6	6159	159	599	609	5	4	2023-08-09 12:11:51.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
611	\\x643a0dcd122146b63eac0618432b47e226fe1b6c21d2ba20ca6d5afa865c7b38	6	6171	171	600	610	7	4	2023-08-09 12:11:54.2	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
612	\\x4b48ddde453b16a778a500d4309271fca46adf9177df7535cade930026d66352	6	6209	209	601	611	5	4	2023-08-09 12:12:01.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
613	\\xcb269a319366283a783550f619fadeabe8486c5877060d1e39373c6ad09888a5	6	6214	214	602	612	6	4	2023-08-09 12:12:02.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
614	\\x7dd9fa3f529bf55032ed4dd5e5abef12dc3a6f28d21af9932ff67b93fa90bc22	6	6225	225	603	613	37	4	2023-08-09 12:12:05	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
615	\\x3449c801f9c788947a720f0802fe17927ec1efaf8de4480a5ceef1af0d87df08	6	6248	248	604	614	3	4	2023-08-09 12:12:09.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
616	\\xdb150002f673a38f42bf8f6dbb6d204f96df1fe16cb2b8254c522ea0021038f0	6	6266	266	605	615	37	4	2023-08-09 12:12:13.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
617	\\x087c7d055c883d71355d152f093393c0c6dab05779d7ac99af2b060be32ee462	6	6271	271	606	616	37	4	2023-08-09 12:12:14.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
618	\\xb263e8874db1ab5750156cd5b4436a908993a4ef522c7d85bf30e50267f2a7a0	6	6280	280	607	617	4	4	2023-08-09 12:12:16	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
619	\\x60f3648d922df24227e7aa0d99704aad6d46c75baa72a4aee48cbc92397e5771	6	6281	281	608	618	7	4	2023-08-09 12:12:16.2	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
620	\\x6ac33a632f7e9f4c3027f73dfa86fe1141c9a257b6387861d93ae4a0b9e9aa8f	6	6291	291	609	619	33	4	2023-08-09 12:12:18.2	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
621	\\x748a9b96b2fd1ecf87030e0e4ffe1138674ea0873c8cfd9e9530ae0ccdc08e34	6	6318	318	610	620	5	4	2023-08-09 12:12:23.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
622	\\x4148350fde7a6d255246e6d92492eb68526021d226d41feb9de1fc9f7e65ac3f	6	6326	326	611	621	37	4	2023-08-09 12:12:25.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
623	\\x09966f4cdc429a72fae896c4c3fec73205cbe0bb9c99b3ddab2fc2c48f4cce6f	6	6344	344	612	622	6	4	2023-08-09 12:12:28.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
624	\\xdd06eca103837812226ec44b172112bc02f80d0ce5251b3b4e2663f1ffe6f0f3	6	6345	345	613	623	37	4	2023-08-09 12:12:29	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
625	\\xc50c2839cda077466eee674106a1ecf604943c30e594bf6b1bc15cbf1589370d	6	6362	362	614	624	14	4	2023-08-09 12:12:32.4	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
626	\\x5034a92f0547a9d4a9d8ab15e1cfc6cbc4e4e9387a549ca648427d1d261197a2	6	6399	399	615	625	11	4	2023-08-09 12:12:39.8	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
627	\\x6e95bd7cdbe303980b9ab9a0feb68c89d4af321853b85a6fbea5a3afe3adb349	6	6402	402	616	626	9	4	2023-08-09 12:12:40.4	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
628	\\x743466df78b483947fd99fdf6ae5c2f4ee1dab72ad82bd6884d8ff20331420e5	6	6404	404	617	627	4	4	2023-08-09 12:12:40.8	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
629	\\xac23d7ba93603a8f60290f3af771aa3eb400819cbe0b1ae99baca400731bd5a1	6	6419	419	618	628	14	4	2023-08-09 12:12:43.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
630	\\x58f3bec53716c9d777e5acdc48a4bca564243464fb0e8a0616cc89bfb3b9d13a	6	6431	431	619	629	4	4	2023-08-09 12:12:46.2	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
631	\\x9661d3a7a636bafcf96973af30233f5f4acd3d521f71fb2daa2c465f98ca64ca	6	6448	448	620	630	11	4	2023-08-09 12:12:49.6	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
632	\\x70849e23d6fa76171632c1e38774a133b9ed101086a6593dd9585ad5f4be0e7a	6	6451	451	621	631	11	4	2023-08-09 12:12:50.2	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
633	\\x75c88c7c05d5fbbdb73e9873dcbae2845bd01bf60d4e2da0973e19ff121beb93	6	6484	484	622	632	37	4	2023-08-09 12:12:56.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
634	\\xea1008dc454e28fcd72abdde7429718fca53f5a8450aea70e9d920c9036f519e	6	6505	505	623	633	11	4	2023-08-09 12:13:01	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
635	\\xc7f5f3ee9c8c67f8b6eb30e881768d51a17a573d50b492c46fc6d15078ee4105	6	6511	511	624	634	9	4	2023-08-09 12:13:02.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
636	\\x1093b018052606d7144abaa437d0d4d38f1d8e66cbe9c24ea24e9746e9ee9eda	6	6519	519	625	635	37	4	2023-08-09 12:13:03.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
637	\\xac3ab32b14a4c0a587e34d7ddcdcb7cd9d2b25e12cf7657adee655c52d21c860	6	6531	531	626	636	8	4	2023-08-09 12:13:06.2	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
638	\\xc729266716d6efb9942d86e4ff846805257f59b94f40bad4f14caac409794027	6	6535	535	627	637	14	4	2023-08-09 12:13:07	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
639	\\x20756888c556f8e886aeec458aa756c9e4f70750778aadf521ca1863b08acb9e	6	6543	543	628	638	9	4	2023-08-09 12:13:08.6	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
640	\\xaf5e3f265c1e30879578acc515ee6011bd271604829c73fcae3d6fb71b2a5ecf	6	6544	544	629	639	3	4	2023-08-09 12:13:08.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
641	\\x1c5f83cde11b7839be7dcd02c276d90d92ede27fb0fa6a123f2aab5d79c6e263	6	6552	552	630	640	14	4	2023-08-09 12:13:10.4	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
643	\\xf53009f36844af2dd3dcf915a290fc3ed6e692795d1e03ec4ced64aaf226a53f	6	6555	555	631	641	11	4	2023-08-09 12:13:11	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
644	\\x75825a324c4abe66d0ce2911d7daf6973e50f2e6fdc8e9c5323fe02d752f4e99	6	6564	564	632	643	3	4	2023-08-09 12:13:12.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
645	\\x0a352a0247f0b3f380ecdd8df2f640937b4e6e059717fad19e72d988d1266c22	6	6576	576	633	644	8	4	2023-08-09 12:13:15.2	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
647	\\x1bf4769839f45078cf93a94af22f4574793e698d55618715abf2861c089706ef	6	6579	579	634	645	37	4	2023-08-09 12:13:15.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
649	\\xc9d68ccf7794df89ec71970c278b36bcf552b390f2297a74e8b8c43b6080dca2	6	6584	584	635	647	5	4	2023-08-09 12:13:16.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
650	\\x223057fdb5ce7d6fb0f855e655bcf5612c4ac44c549891b338d83651edcd7a74	6	6590	590	636	649	37	4	2023-08-09 12:13:18	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
651	\\x4fee2c48ca3259c797253c822557a06d5f066a8b36542c4d7891d2ad943a8b9c	6	6603	603	637	650	8	4	2023-08-09 12:13:20.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
652	\\x7caf2bbf8bd688016e8e0c6128e5cad12ba9faac8ca71c2e41b21d45a2de4f64	6	6614	614	638	651	7	4	2023-08-09 12:13:22.8	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
653	\\x1da7bc0e8ad2f682e84af91d21273dd29fce3196a13f50bb303d5a9b274233d9	6	6615	615	639	652	7	4	2023-08-09 12:13:23	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
654	\\x368657e091dee6437480d92358121873656ab85816e5a6078d8cfee88d5c9c6d	6	6629	629	640	653	3	4	2023-08-09 12:13:25.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
655	\\x2d2b5b8aa97fc8636ec534770d5b4a2d2d215e6022873d5f88882f4bbdf10ffe	6	6643	643	641	654	33	4	2023-08-09 12:13:28.6	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
656	\\x0c856f4923ef7c138f247565cb4b3469a79a0317c9a9777b16907546db68ac45	6	6662	662	642	655	6	4	2023-08-09 12:13:32.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
657	\\xd80efafd0e000f9f0b54756331f728d85e5145bf627b388dcbf566ea92479d75	6	6667	667	643	656	37	4	2023-08-09 12:13:33.4	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
658	\\x0b95860be5351606ad07de56905ce1a005685dbbd669481ba455218e0a5e3742	6	6676	676	644	657	4	4	2023-08-09 12:13:35.2	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
659	\\xb7e472e72ea44e98326a42f46e4c230ceef725a01ca68e00f0298ad460ece3f0	6	6679	679	645	658	3	4	2023-08-09 12:13:35.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
660	\\xf7b14e931db5f4981d102a2b389a8908c0dfc34ff40f75140d88aa8d1a438aab	6	6682	682	646	659	33	4	2023-08-09 12:13:36.4	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
661	\\x5296ebbd24f9cb824e250452019eddd85b7d28952c2a75f981bc13ac171d3e69	6	6705	705	647	660	8	4	2023-08-09 12:13:41	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
662	\\x9f00aa9ae545543d013d9f326bde47a8178fd656ae4c32949b534b4e3a61689a	6	6709	709	648	661	14	4	2023-08-09 12:13:41.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
663	\\x6e8271bf9ad9347556120a68f1092b6e479bfac4ee972151e5dac89c84858906	6	6713	713	649	662	7	4	2023-08-09 12:13:42.6	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
664	\\x0fdf529dc55777aace083b4f63fe461f5d8440d0400108f553a2e2c0dd62c3f9	6	6740	740	650	663	9	4	2023-08-09 12:13:48	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
665	\\x2981138f5efb1a0e4b06fbf46e68b805f8183f730dcd8a84694a1be8094966f2	6	6751	751	651	664	3	4	2023-08-09 12:13:50.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
666	\\x861c9b7b3d85439d96afd812659d2429961cad6f5940f901cb46d5dfeb123c36	6	6756	756	652	665	33	4	2023-08-09 12:13:51.2	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
667	\\x77ffc21eafe24847a70713e7875af19261da4a01a476f7afc730fc907cc6fa11	6	6772	772	653	666	3	4	2023-08-09 12:13:54.4	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
668	\\xc1e82da97050c8f05e34f117b0b18e72b51b5939050293457d716426134d8832	6	6779	779	654	667	8	4	2023-08-09 12:13:55.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
669	\\x56b3167ad9547071f87b21d0868be0a60902b42896b329c852a9a3fedbeacf50	6	6787	787	655	668	8	4	2023-08-09 12:13:57.4	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
670	\\x8e072c0f9d13ef068a9616dd852c9c4f4e9fd69ab7d002d2475bdb71fca2f9af	6	6807	807	656	669	9	4	2023-08-09 12:14:01.4	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
671	\\xe7df887054fd6c7c289c3b918f19600e4c632499677dcb6d9cbe16072697fbd1	6	6825	825	657	670	4	4	2023-08-09 12:14:05	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
672	\\xeba0f57988be78fb08e336fe359f3550f08bf3f9fc9b5dab6f540a79078c61d0	6	6830	830	658	671	7	4	2023-08-09 12:14:06	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
673	\\x4e9c627c48f050330d5d869a23779887a2a2f695e4558d2eed2d69a84dce7f70	6	6835	835	659	672	9	4	2023-08-09 12:14:07	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
674	\\x09e23b6fdf592472746b9a49eb9f1bb01ae9300850cbe07f2cf413bd65f4992a	6	6842	842	660	673	9	4	2023-08-09 12:14:08.4	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
675	\\x852b62789f5bf61ea0553c5e3097c94f6cc30944195816736be958f62f9bad3a	6	6853	853	661	674	4	4	2023-08-09 12:14:10.6	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
676	\\x1be25c79f8ed4daf6ae42e5baded1df03c641a3973ce043accf19946898b6039	6	6865	865	662	675	14	4	2023-08-09 12:14:13	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
677	\\xa26a02f2b7d8e365eb869382c090a77847f8321cdbb74171fec1aa1f62055010	6	6888	888	663	676	5	4	2023-08-09 12:14:17.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
678	\\x1cbdb11ec46fd7649bf55d4a67adabcd634b5d1bc75e2a4bdd9a7618aa26d398	6	6948	948	664	677	8	4	2023-08-09 12:14:29.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
679	\\x270c50a3f3e52a2671613762032ec346fcff0cd7e1b7133a0750b505b71e1f37	6	6951	951	665	678	11	4	2023-08-09 12:14:30.2	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
680	\\x1a756bd8e24fe0a83aa1327aa59ef7fbc8a24da0a39e831f27f325b206cd796c	6	6957	957	666	679	11	4	2023-08-09 12:14:31.4	0	8	0	vrf_vk15z4pz7xhauepdn49ssee5yrnrejvculacu2r3unh7dfesdanxehq2vgvw8	\\xb20af6824fdb8c2416d94917e1c5130023f8ec40db0198d67fe43bc07614a522	0
681	\\xd7e7b9fdd18102369a82d761d8b3b1434772afa293609970cae396b4c1963a8b	6	6959	959	667	680	6	4	2023-08-09 12:14:31.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
682	\\x4ff31ea7b7b5d4f6227bb739d7221b576a73f93bfa79f519506d2620eeb2c5b1	6	6972	972	668	681	14	4	2023-08-09 12:14:34.4	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
683	\\x7bff76916c65aa0f08098c04d5ab3ce9240ca1256a67ed5a4969aaa66656bdd7	6	6987	987	669	682	4	4	2023-08-09 12:14:37.4	0	8	0	vrf_vk1as3wqfzgh9wvlpmnqqrgv8mau98yc2c5p6aa3pvyf0rdd2n5fg2sgz09em	\\x0f6a89d60f56da6a21d3e0496bd94c35c96067119cc02c7853f80644edc8365f	0
684	\\xf7be58fe69b28777235ab6cfac08c25b12a7dd4f538dee432b9d91e844e3ae13	7	7007	7	670	683	33	4	2023-08-09 12:14:41.4	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
685	\\x15fdfa29c4e8190e502e9bb0b0cafcc216a4e80628a0132a70e7d64637582016	7	7015	15	671	684	8	16341	2023-08-09 12:14:43	55	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
686	\\xc38614cb0baff65d064dd5b96d66fc454da777f0746c0269540f4576b09ba074	7	7023	23	672	685	3	13752	2023-08-09 12:14:44.6	45	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
687	\\x8e6cc3a99828845bd4ee55643af8cd3c2b8e3e0cffde432811e9cb8be4935843	7	7032	32	673	686	6	4	2023-08-09 12:14:46.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
688	\\xaba5472418fb44982ea187d189372ab0e43062bc587c4b29c580da9b9ce56307	7	7041	41	674	687	9	4	2023-08-09 12:14:48.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
689	\\x31e08697e5012c1b84fc06a4f95dd742f44e48f7be55a5325456a43a17d985fd	7	7048	48	675	688	6	4	2023-08-09 12:14:49.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
690	\\x01a5e5634a4933ff8ef8b9f22d95b14fe43bc1323145620f02d95c33738c1117	7	7049	49	676	689	8	4	2023-08-09 12:14:49.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
691	\\xc738cb7c1435e99e5b81c0c26db2d8ada1c5d624065bfc076e760af3449211eb	7	7055	55	677	690	37	4	2023-08-09 12:14:51	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
693	\\x45b2b735d4eb20ebb522fb5ece98f0908aaa5e118b7da29900ca11a9a5ed2581	7	7090	90	678	691	5	4	2023-08-09 12:14:58	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
694	\\x972293fe5933c48915731fd3cd85d0f2d7172ceb0ef75a38d885b6a7ebb970ef	7	7103	103	679	693	37	4	2023-08-09 12:15:00.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
695	\\x0e9f552d6e8f0eb4daae404ded708c1fec89fa65b783ce787de3012789a9f532	7	7111	111	680	694	3	4	2023-08-09 12:15:02.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
696	\\xe0681cb0d309d914b55d6f18737331bb3c5e72db3120f01004b38ac6135b1343	7	7118	118	681	695	9	4	2023-08-09 12:15:03.6	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
697	\\x491d0f31b2b68486d4f8fc3844e60e7539f4ac15a8aa68ae4357f8c4b1eb4283	7	7119	119	682	696	7	4	2023-08-09 12:15:03.8	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
698	\\x78e17e56953b54be890e815c4e6864dc1e0194fd61e4138f6a9cbbbfeecfaabc	7	7165	165	683	697	9	4	2023-08-09 12:15:13	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
699	\\xa3a774154aca432e3d95c06ad0e8d8cccf3230e0c2d35afda3c04f9f9c09208a	7	7209	209	684	698	14	4	2023-08-09 12:15:21.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
700	\\xbe7b81e7e93ff17ebebb76fc64f2699c6bdd742460b1515d0439c73e975e3abe	7	7219	219	685	699	33	4	2023-08-09 12:15:23.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
701	\\x41d5c34367238a5166bf30844617507e4f94aa606f81b8ab078318f414632868	7	7229	229	686	700	14	4	2023-08-09 12:15:25.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
702	\\xd72d17ffa745dc99ec2c36833c1aef9e18bf26d91bf81c31a64f5dbbfad84b10	7	7230	230	687	701	5	4	2023-08-09 12:15:26	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
703	\\x6fccce3e1e22dd2182b79c9c0a88c662de1ef8289817d028ba338b2f571e4a22	7	7248	248	688	702	8	4	2023-08-09 12:15:29.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
704	\\x393cd0a3b5a794ecc96cd5adf1b2ddfd1b0f4279f8ce7e203c00e45fb9f05642	7	7250	250	689	703	9	4	2023-08-09 12:15:30	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
705	\\xf4f5b885ae631f3956c7d15a3476cfeb5ebbde9b782c039f8bf028d8a9ac413f	7	7256	256	690	704	8	4	2023-08-09 12:15:31.2	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
706	\\xb7b786e0cbd26f6f22425bb6cc361b35185377a8dcd2d5e4e17b8a1c3291e2f9	7	7260	260	691	705	9	4	2023-08-09 12:15:32	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
707	\\xdbfc57da0671307c147bc92c705f6da8be902dcae5cf552835048d73d2b300dc	7	7296	296	692	706	5	4	2023-08-09 12:15:39.2	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
708	\\xf8291436d2687ed1e5810008d954395d489e4d26bfabaf14314f7ff208509d25	7	7308	308	693	707	6	4	2023-08-09 12:15:41.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
709	\\x0f59a4dc4498d73fca1a9ec61dc3c2d7aaf5c1b313c1e3f67c15f941223afece	7	7317	317	694	708	5	4	2023-08-09 12:15:43.4	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
710	\\x53d0275c95e62d78e159193b6936e3792c9dd844e4c0a0d121602cf74ee2d31a	7	7333	333	695	709	14	4	2023-08-09 12:15:46.6	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
711	\\x6197c5575088fbef9482eefcbf0e62c0f55fa79158826da37f584ebf4223e8da	7	7344	344	696	710	8	4	2023-08-09 12:15:48.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
712	\\x6ae30840d4e0662c9bbe4ab965ff442e96069ca16344b47be0021d135ecc8e0a	7	7348	348	697	711	37	4	2023-08-09 12:15:49.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
713	\\xf8c77c233ad1cfe17cc389405a8a87db1566b3f1b048539a0b86d43eabcb43c1	7	7357	357	698	712	14	4	2023-08-09 12:15:51.4	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
715	\\xdaad77085fcae61e024e7e52a3315285e5ddb2db9c78a42177b8eba1e9c1a1f8	7	7358	358	699	713	37	4	2023-08-09 12:15:51.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
716	\\x15e677f36a5af053cacc0ab940d6db72ab9ce7a4974e891d53acdd7f8c03b0ee	7	7363	363	700	715	3	4	2023-08-09 12:15:52.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
717	\\xf7b47d96427e4f8055b1b633fafa95b195ac1a5cceb61f42d6e0e03cea3d5a07	7	7384	384	701	716	6	4	2023-08-09 12:15:56.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
718	\\xe37da72fecd8d8d4166215dd05ff9829caaf394ed6021132d4795f6d85ad4e46	7	7396	396	702	717	6	4	2023-08-09 12:15:59.2	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
719	\\x56b18fe170c05347c63dcf4f548d75e3d77a6773e9c2a2105e41135d441cfa30	7	7401	401	703	718	14	4	2023-08-09 12:16:00.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
720	\\x1f3395f5bbe049d3e16e75b1d55771c442a3706a415be80ccc2a8513c8757ce9	7	7422	422	704	719	7	4	2023-08-09 12:16:04.4	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
721	\\x1788ed98cd6fb36884f3cc3a68b00ccf8ee12e551e9e5a4c69e99e18a0b598a3	7	7431	431	705	720	14	4	2023-08-09 12:16:06.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
722	\\x2878eabcf92a6fa4d549ec77f9add0943f637d30a4a325bdad22fa03b23b4972	7	7467	467	706	721	6	4	2023-08-09 12:16:13.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
723	\\xc0f2f20c2871a19c695532768184adb8e5bb4ef9265e9d3caf5fe35ed1cd9266	7	7469	469	707	722	5	4	2023-08-09 12:16:13.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
724	\\x1a41ec4acceb0979cf1332043571665eedc94cdce34c371d03c9d31f74e1b11d	7	7480	480	708	723	14	4	2023-08-09 12:16:16	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
725	\\x8d6d0052a79e371db8341281d1e85f22a5b51470243e97986bb6d5dd24bed822	7	7486	486	709	724	6	4	2023-08-09 12:16:17.2	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
726	\\x70907bd4f0fd45935c67210b1ee427aee9b978471a8160477aa630838f646ab4	7	7510	510	710	725	14	4	2023-08-09 12:16:22	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
727	\\x412ccfa951ff001f73b53c79af0545ed4db9f04f509badcc866d5ec9c3c9ae12	7	7511	511	711	726	33	4	2023-08-09 12:16:22.2	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
728	\\xe6e5c152670ddbd8c23720cc03bb47e334f116c1b0c2d8e0f59e2c69ba81f103	7	7556	556	712	727	9	4	2023-08-09 12:16:31.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
729	\\xb66e677da9004d58f55bf8b44a040d1854de418b0799376b21e89cd8bd0af347	7	7566	566	713	728	6	4	2023-08-09 12:16:33.2	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
730	\\x57933d5d1daa2d58220fdbdf1a7c632acb0248c2e7a6beecf935111e3902fd81	7	7585	585	714	729	37	4	2023-08-09 12:16:37	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
731	\\x753b1642e3b2b209e20ae0e3050d01018ba77f0972fef6d128c1beaf5da93dd2	7	7595	595	715	730	9	4	2023-08-09 12:16:39	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
732	\\x5fa1f56e1eecf2886b71d00ee3942fcbb03bfe10b87a64abec3890f682fcb3bd	7	7606	606	716	731	3	4	2023-08-09 12:16:41.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
733	\\x1b87988d7e9611fc4b7bddc39678e7522eb5360af7442f092df23979bcb5046d	7	7640	640	717	732	9	4	2023-08-09 12:16:48	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
734	\\x41134aef02b25da86e9b5de885243308bd864f79f79ab6bc86f1ea0022ca6502	7	7650	650	718	733	8	4	2023-08-09 12:16:50	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
735	\\xd6998258c5aa1b541148f3a7b5bc4578acf18bbab9f5a7f2118b7f7cf8998fec	7	7661	661	719	734	9	4	2023-08-09 12:16:52.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
736	\\xbb812aa6cc5d49d5dd0c47d69bd658ebee795d4fc7c1d70b2a62827390537d82	7	7664	664	720	735	8	4	2023-08-09 12:16:52.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
737	\\xfe56f50cb14685bfd9fc8168fede426bcd61cc270c830f62092f3e68c2c6aad5	7	7671	671	721	736	14	4	2023-08-09 12:16:54.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
738	\\xdf9e948367b972987e7a63980beb4537440edcc057259bca4014d79785b28f87	7	7672	672	722	737	37	4	2023-08-09 12:16:54.4	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
739	\\x600e1b01c5f4eb2b0f1a97fbc684a21fe93d0adaf7f12b61677b2bdd42e032ff	7	7674	674	723	738	3	4	2023-08-09 12:16:54.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
740	\\xbaacb668ac898624c7d61190fba015aac97c724a14f81262b0b7d6c22763a5dd	7	7683	683	724	739	37	4	2023-08-09 12:16:56.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
741	\\x54fc5f03ba306bdadd831c327b854052d028c27d9157303d3564a3fec9166d76	7	7719	719	725	740	6	4	2023-08-09 12:17:03.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
742	\\x5e707814c28f1d237129d4f3b6ca69ddd0eca54ffdf783a2f5f75041673c9afb	7	7725	725	726	741	8	4	2023-08-09 12:17:05	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
743	\\x0ee64ca64044a63ddf72d0c11456edc0038ee08fda11b9f41c727580684a6c99	7	7727	727	727	742	8	4	2023-08-09 12:17:05.4	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
744	\\x59320db1e033b843cacf0b6ad138024b4446b4abbf75cc51a0fbcc5fae86cda7	7	7734	734	728	743	6	4	2023-08-09 12:17:06.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
745	\\xa9a7f4a1076f5fd3f067f79ce4b78a247218985fad5c1850a10f0aabdba4cf68	7	7736	736	729	744	14	4	2023-08-09 12:17:07.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
746	\\x3c582fe4b40fd9f44cb6f0663ea677fc6d4d4b7c41137211c0b9e658860e10ba	7	7749	749	730	745	3	4	2023-08-09 12:17:09.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
747	\\xb80a720424fb98ce5bc8b56935819fd303c0ad12a0a4b0bb44f77894c4a7cfd4	7	7751	751	731	746	14	4	2023-08-09 12:17:10.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
748	\\xefcaaf5cf7de984be0df4ee73fa8c68427ad164b55ade3b7d2a1014d315af5d4	7	7754	754	732	747	33	4	2023-08-09 12:17:10.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
749	\\x074b8f7852c8b6941992e08f45447fa4d23f97764d1bd735a2419d03fe2f146d	7	7755	755	733	748	3	4	2023-08-09 12:17:11	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
750	\\x4fae4395e4400842563501663a89cc1eac9310e0330f1b7c89d7d25e8d30d527	7	7756	756	734	749	37	4	2023-08-09 12:17:11.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
751	\\x8ba781015e2d9fbc44aec57798619ed36f096e4aed7ec1de085757a99ba1bffc	7	7761	761	735	750	5	4	2023-08-09 12:17:12.2	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
752	\\x08fef3e03113e69efe49d1b3e0253b36dbb781fabef6470c001d89eb6e51bee8	7	7763	763	736	751	6	4	2023-08-09 12:17:12.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
753	\\xa6fe1b5f4a9dd1c3c2f5a08cd27cdd05e29ffbdcb210171a074d9b79273c30cb	7	7772	772	737	752	7	4	2023-08-09 12:17:14.4	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
754	\\xb6cbf67323311163e50685acd683a5db53f3dcac379e909a564e00e1acf90c5b	7	7773	773	738	753	6	4	2023-08-09 12:17:14.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
755	\\x5c0e3c2507d5f6407029955c33ce15d4bbb83c7113c01cb633cb9105a45d8691	7	7782	782	739	754	33	4	2023-08-09 12:17:16.4	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
756	\\xf1f4cd63f63c5cf565abaf956dda32ac37a58e0bfac9bcaf8b4f698c9726ba8c	7	7812	812	740	755	8	4	2023-08-09 12:17:22.4	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
757	\\xc4e3eb6a667bfd7986038a8061e6220a10e8209285ff618c117a13d11dbfbede	7	7819	819	741	756	5	4	2023-08-09 12:17:23.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
758	\\xf1e5049ed4ac4a933a3e616f3252e9b361bb4120fc1caddc6b91cdf48bba7762	7	7833	833	742	757	37	4	2023-08-09 12:17:26.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
759	\\x0ba8172763e88ee18e6158618e6196011496f994d8f62e9f68f71808d1ef4beb	7	7834	834	743	758	8	4	2023-08-09 12:17:26.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
760	\\xf54596496341e10815044f598abc487c2408d6de0b758711296e4ab1787aaa47	7	7843	843	744	759	7	4	2023-08-09 12:17:28.6	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
761	\\x8f16e393876e5af6da15edf0d2280c0904f55b9c1b6d25325f2a2368305ae6bf	7	7847	847	745	760	33	4	2023-08-09 12:17:29.4	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
762	\\xc8d4da7a06751d828dfab5b88730541d9a50b9f26cad39ea8a4b7ed129bc9598	7	7865	865	746	761	7	4	2023-08-09 12:17:33	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
763	\\x26c006385d2a7a5cf1f06f31c1fac43d6c0e9c413f368245389818fdf0fd0576	7	7889	889	747	762	33	4	2023-08-09 12:17:37.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
764	\\x503a8dc961a83e4347952aa4ea6671fae4463c9171157c71498afe267690446a	7	7904	904	748	763	7	4	2023-08-09 12:17:40.8	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
765	\\x7ea2f83412770f7ff0928c63ae82b876d5a4716f89eaacd787f19443c464e3a7	7	7921	921	749	764	14	4	2023-08-09 12:17:44.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
766	\\x6d804ae7a211553bc5673549639005951c32ba0e3a1dd0c59c782f26ec920e73	7	7946	946	750	765	9	4	2023-08-09 12:17:49.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
767	\\x1d1d90dc00aba04abbce70cfa928744fdffbd6fb395004ff7edef233840cf15a	7	7947	947	751	766	5	4	2023-08-09 12:17:49.4	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
768	\\x84b1a47c4b125882cb2baeeb0e33fe985d5d8ca09cf2ccc473349ea4c659a6b5	7	7953	953	752	767	6	4	2023-08-09 12:17:50.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
769	\\x94cb96d91da4b67d22822763bbd89b4be057f2bd5f7b1f22294efe44f4a1bff3	7	7974	974	753	768	14	4	2023-08-09 12:17:54.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
770	\\x374a948c3449d55041da1a3af6abc06a921deb98e3fb997971e7083966fc6124	7	7993	993	754	769	6	4	2023-08-09 12:17:58.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
771	\\x74d6cf55658848c6174005ce38deb91ab1f8f94147a33803d87d26a40d535e67	7	7994	994	755	770	3	4	2023-08-09 12:17:58.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
772	\\x51afebf9c0f33521c027088ae943d8545f99da807558ad6fa10b385210e95e24	8	8006	6	756	771	3	4	2023-08-09 12:18:01.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
773	\\x981d9b485447e36066496f7cd5bed9f7064b91581dba513f3c8d8cbe52bef884	8	8014	14	757	772	6	4	2023-08-09 12:18:02.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
774	\\x58396c980ca896344cf3825cd11a36cb41c5330c5e44533f50ea671de5ee0787	8	8025	25	758	773	33	4	2023-08-09 12:18:05	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
775	\\xa7955e5984d517eb64495780866675e4e5e603303915721b7c4f9fc92de840c3	8	8037	37	759	774	14	4	2023-08-09 12:18:07.4	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
776	\\xc0ff942a95222104b62858bc781a7a09bdb1739648e9b3ff39dc6f9429bf5c50	8	8040	40	760	775	7	4	2023-08-09 12:18:08	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
777	\\x7f31acd2c18659faa2c81a4530f2203e7b5a203f2455bff28ea7f46bf74ee34f	8	8041	41	761	776	3	4	2023-08-09 12:18:08.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
778	\\xa2e44c979e02738ba8728f474996e88f5a2ef0e06cafeb2f69456fc0b7bbf586	8	8049	49	762	777	7	4	2023-08-09 12:18:09.8	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
779	\\xc7c2b0d37c3a20591514c5139afd41e5bd7b0187e702d6b3b3b9d821ff8e00ef	8	8052	52	763	778	5	4	2023-08-09 12:18:10.4	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
780	\\x3404d25a30526786dcbfa1ea943a946b2ba686e9cbf817faf2a4583c611cfbfc	8	8057	57	764	779	8	4	2023-08-09 12:18:11.4	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
781	\\xef94ed9a4bb6e162798239ae703a42353ace0ed4dd25c240b3d356b7b6366f7d	8	8068	68	765	780	33	4	2023-08-09 12:18:13.6	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
782	\\x5cbb2b0e2591eed137db784deb30898b14ebb5eab46a649b2182f72caa332576	8	8079	79	766	781	14	4	2023-08-09 12:18:15.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
783	\\xf8466e8b53ebd94d977f0a55d6f7e29d489c91fc027929fe25cfb812dbaa7383	8	8121	121	767	782	14	4	2023-08-09 12:18:24.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
784	\\x5a7ffe23d75097c6edc96f5d1f7e47e662b552e705d0b612c5d211a6957622e5	8	8139	139	768	783	37	4	2023-08-09 12:18:27.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
785	\\xa20e361d0230d1955a70725aa34af2967ded579263cb7b3a95fd4a635153fb94	8	8141	141	769	784	3	4	2023-08-09 12:18:28.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
787	\\xb44bf7c5241d1008c24ef06a57858789a4a22f106caf74a945f5042133d8da33	8	8144	144	770	785	8	4	2023-08-09 12:18:28.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
788	\\x53eca9759828b63b63669075476816b19a3662b574e3251cd61ee6381e868512	8	8145	145	771	787	3	4	2023-08-09 12:18:29	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
789	\\x34242c7e422b540da117042ba20fff2b996af0682653c53ee14faa94fa914316	8	8146	146	772	788	8	4	2023-08-09 12:18:29.2	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
790	\\x86ccf0473b34286fc1434a924b3a5dbb78918c1ea61c7cfb0ce48b7a1fa84652	8	8153	153	773	789	5	4	2023-08-09 12:18:30.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
791	\\xad6d19125fd20409455fe59133a5bf0c691b5a7574be2c89d981d6cc203e4498	8	8161	161	774	790	33	4	2023-08-09 12:18:32.2	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
792	\\xdc0b45c85fbffa12230e8b05e885552a52e14b8b24c93e199d952dcb8670bc30	8	8172	172	775	791	8	4	2023-08-09 12:18:34.4	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
793	\\x4ede0d4b22762d48e8bb0da37713418d7fcca7057b8e07f688dccb167027c381	8	8190	190	776	792	37	4	2023-08-09 12:18:38	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
794	\\x8e63e705e5ad4b3d3fdda70c3245647008e1a7c35ce8ef1c0dce4086cea469f7	8	8209	209	777	793	6	4	2023-08-09 12:18:41.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
795	\\xdc6e28a09da91522db3f4f8c0cc22957f0f1596d2701cc115b61b4c38b858612	8	8233	233	778	794	37	4	2023-08-09 12:18:46.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
796	\\x53e726b3529153caa62e28fc0e4ae576e77649e575505354ab9118055db1ccfa	8	8246	246	779	795	37	4	2023-08-09 12:18:49.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
797	\\x0c4270c39394028bb70d3d74f5489f1de10244adad6d5a98ccba41a722344ce3	8	8257	257	780	796	6	4	2023-08-09 12:18:51.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
798	\\x24796697b380aca46bf55256628dc4e3e2afcd2a980d9dca19018c135389a2db	8	8259	259	781	797	8	4	2023-08-09 12:18:51.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
799	\\xb20bacd88d00ec99d6e9b9885da1265e71f672598a431a3cb0613379313bc4bc	8	8268	268	782	798	3	4	2023-08-09 12:18:53.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
800	\\x6f8c6e3892e77d1f5c5e189e50d6625a2f1e240e7d23c88e6803f2983f15da88	8	8275	275	783	799	33	4	2023-08-09 12:18:55	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
801	\\xd3dfaaf928a6c52642cb7c31d1265cf63ce79a0120995be9faecaa4b9f4d5f33	8	8277	277	784	800	14	4	2023-08-09 12:18:55.4	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
802	\\x03462e8880e6ef5769c2ca5124e3a3328be2fe816aeac92c27393e9b20968436	8	8305	305	785	801	14	4	2023-08-09 12:19:01	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
803	\\x83aa86dace59f050c2fcf33412ab3ba71080cedfb9214b78952fdc6f73278425	8	8306	306	786	802	37	4	2023-08-09 12:19:01.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
804	\\x380b6f6fe6d88c33f8f2b882f2660b8d63eb68c79479d3690771a59db1eb8674	8	8313	313	787	803	3	4	2023-08-09 12:19:02.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
805	\\x7af9654b2549c2f3aa8b8a101a47db18ac586fdcfc5f1bef26e7856e12ee62d3	8	8314	314	788	804	33	4	2023-08-09 12:19:02.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
806	\\xab129f9c103487dd033c83ec998cdc2abb1c776b3fc91c9af210eecbdc98020a	8	8319	319	789	805	7	4	2023-08-09 12:19:03.8	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
807	\\x33c04e34d2f3cbaf5d82e6c1fe4d52a4f661bdff1f42a13c4ea83adff3d60694	8	8326	326	790	806	6	4	2023-08-09 12:19:05.2	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
808	\\xbaf9bec1b7b82ee6904eecdaa453c3914744a749dab5edbb9b7b9030740d3abe	8	8328	328	791	807	3	4	2023-08-09 12:19:05.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
809	\\x88b3511f4b1028764abb0ce06d44c9739d6a74d2c4e523749d871ab9cd1614fe	8	8346	346	792	808	7	4	2023-08-09 12:19:09.2	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
810	\\xf9c2dca3be9c1f0c9c4b1ec82d3742d1a838d430da93685a7c2c915e49fde238	8	8380	380	793	809	37	4	2023-08-09 12:19:16	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
811	\\x25af5fbeb93bbb0ce6794258f72f650e351e0231390cb7cdfe9363791078efb8	8	8384	384	794	810	3	4	2023-08-09 12:19:16.8	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
812	\\xcd3ac59c35c8ab72b02edd7a15d3188078b94495fffb38b5f33c3701daf3975d	8	8386	386	795	811	14	4	2023-08-09 12:19:17.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
813	\\xb27fd8d8137f70c09a13a134e3ba3c9e539d5db8b6db85d3c917ae4bd1b3452f	8	8396	396	796	812	14	4	2023-08-09 12:19:19.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
814	\\x55c2a4f43b2c3614eb56ccd89a3fdd1aec3bd3bd24a047064d56b0155526ee39	8	8411	411	797	813	6	4	2023-08-09 12:19:22.2	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
815	\\xff8bf01745ab32a492409029fcc29da26823c8010d4e7c77514ce3a2efbf9127	8	8423	423	798	814	5	4	2023-08-09 12:19:24.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
816	\\xa2f663ccb4ff79db7feaa509bd00f36ff83a86d4344b756ff129684aa54689c5	8	8469	469	799	815	37	4	2023-08-09 12:19:33.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
817	\\x1d8c2d75a8f9b86a5a80e48df26d1f2679c137582f9f202793991ebd607d0175	8	8479	479	800	816	37	4	2023-08-09 12:19:35.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
818	\\x6b3239ca827a436bedd2ab782f27edf2027ce31078c4f73dbf1648e1a2e2db82	8	8523	523	801	817	8	4	2023-08-09 12:19:44.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
819	\\x03fcbbef00eafb39e4087c74485da43659096cc5cdf4e17fd5635e4a4deedb4e	8	8540	540	802	818	9	4	2023-08-09 12:19:48	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
820	\\x4cc14817a8f2e99c76713e5bac77df1b15fee8054ed1a1a79d1dce3f7a149848	8	8549	549	803	819	5	4	2023-08-09 12:19:49.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
821	\\x6171ac293bb6c6863d3fed856567cd41365ea0a9696ce7d78d311a04985a5b24	8	8552	552	804	820	3	4	2023-08-09 12:19:50.4	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
822	\\x21007c1a5caaab2188832a42e6ce98795d1940f5c61e4be69bee2e2652cc1956	8	8558	558	805	821	8	4	2023-08-09 12:19:51.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
823	\\x7074540d33ad5558e09828f7a6c14f51f4cf99a1ecb27b418fc40e536f985855	8	8559	559	806	822	8	4	2023-08-09 12:19:51.8	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
824	\\x4739fe6da2421b59be643eafa681d013f3fcc7dc9a1b6f4cb4601f18e965d8e2	8	8588	588	807	823	3	4	2023-08-09 12:19:57.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
825	\\x3b870bcae0bbb657e029954d268830c17ad768732cf1d033e9b0abdae4c5c307	8	8594	594	808	824	5	4	2023-08-09 12:19:58.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
826	\\x1744cda283ba707d7640760b815b98359837eb57ebb9497f159ae237f7ed2f28	8	8612	612	809	825	33	4	2023-08-09 12:20:02.4	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
827	\\x5570608ed6ba135be5076421825ed0b084ae9671a017dd849894b001f5232029	8	8621	621	810	826	9	4	2023-08-09 12:20:04.2	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
828	\\xd064c6457a7e33250bb16e474f6eb2c8f9eaeaebc36a1606689e1722462dda00	8	8684	684	811	827	6	4	2023-08-09 12:20:16.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
829	\\x08a71f36abc76fecb16283f49ef8a53f1e244b2ef1ba9f89773ad6775a764bc4	8	8693	693	812	828	14	4	2023-08-09 12:20:18.6	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
830	\\x4d88ea50e610648a29eb15d80d70e7ac3f318e5d11512692889df828841ffed8	8	8702	702	813	829	14	4	2023-08-09 12:20:20.4	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
832	\\xd393aeece366f44daeb57dd13ce9176785f0e07489460001f94084dd9efb3908	8	8714	714	814	830	14	4	2023-08-09 12:20:22.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
833	\\xa9c8942161b21ba40840ee86948ac4ba7e7551a68debe9f243569fbb85a317d9	8	8721	721	815	832	5	4	2023-08-09 12:20:24.2	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
834	\\x4f5150ad05efccca703a53420082f38c6be23f1062246cd5596bb91f3023d129	8	8729	729	816	833	37	4	2023-08-09 12:20:25.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
835	\\xb19a1c68fd61ba873bfdc5dbaa29fc998124358f33cd4ee11fb299e6b6b9ac67	8	8752	752	817	834	5	4	2023-08-09 12:20:30.4	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
836	\\x7b76fb385a498f37a43be58af7f8d456c0bf1da811b303ab2f1d523be8ced81d	8	8761	761	818	835	7	4	2023-08-09 12:20:32.2	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
837	\\x6ff476f5425bea1dbaca4ee0fcf2a6dec6a3eecbb0e25d5c5870338075334ce2	8	8775	775	819	836	14	4	2023-08-09 12:20:35	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
838	\\x0af3abed280f15abe834b7686f86129ff7af35cf35ca3a9ab93b8c5f4fcf715d	8	8785	785	820	837	33	4	2023-08-09 12:20:37	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
839	\\xec4d43b8b4682afb62fe79db73a258d140fd8fd3bd1596b31d50b2df0834ce11	8	8788	788	821	838	7	4	2023-08-09 12:20:37.6	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
840	\\xd2a88ea698667ade6befbacb9a57eaab589948b012b5e743a11b0c7fa4437642	8	8795	795	822	839	3	4	2023-08-09 12:20:39	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
841	\\xacca30918d96b99648c5f898ebf14f0faebfc614112184439dcacdddd10c148c	8	8812	812	823	840	9	4	2023-08-09 12:20:42.4	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
842	\\xea6e9345964ec7345d70b667a77fbcf9899840ce703f6c354e8e53109664c4ed	8	8823	823	824	841	37	4	2023-08-09 12:20:44.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
843	\\x73de3e93fb15ccacf149b3db36d519e32c293aa2a819655d6123e9549b15257e	8	8829	829	825	842	5	4	2023-08-09 12:20:45.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
844	\\x405f7ecfdae3bae6810bffceb66265803bdd651dc024778bff5dca740e143e21	8	8844	844	826	843	9	4	2023-08-09 12:20:48.8	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
845	\\x8868cff8463ce10adb580fd9781820370a0aa20f387ca30ef07f13460057f0d7	8	8850	850	827	844	9	4	2023-08-09 12:20:50	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
846	\\x635de0c9912be31bca8b9106a45f794cdaccda1a93af168af33197f7b086b36e	8	8875	875	828	845	3	4	2023-08-09 12:20:55	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
847	\\x9eac7f24c6fa61b61b8942d129617fa1f4de2c3b847f19f41833fc11c4ff5f90	8	8884	884	829	846	37	4	2023-08-09 12:20:56.8	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
848	\\x36ef5077da41636d5086fe3acf59897b1d5dca6377d1994a755c22a0e043a8da	8	8923	923	830	847	3	4	2023-08-09 12:21:04.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
849	\\xbd2e2e8c96aa3ed33d5320c339080772311e1c4673af25ab5a2e6395f53358df	8	8926	926	831	848	6	4	2023-08-09 12:21:05.2	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
850	\\xf09e343e65e95fad2d646269faf5bdc66ce8369851259b760a80a36243cfcd3b	8	8930	930	832	849	8	4	2023-08-09 12:21:06	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
851	\\x7a88a2ab494a9fb026cd6621a689d95d57eb3522914b9ec6a5e6b22d0955c79c	8	8938	938	833	850	8	4	2023-08-09 12:21:07.6	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
852	\\x52c6e17d1beccfa608fc62041670f108384ecb17828ee7e8ce5024957b0a69b1	8	8949	949	834	851	33	4	2023-08-09 12:21:09.8	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
853	\\x7e4c588181f1fbd48813767a13e1de1cbc17e16ab9a7a1e03d6f9472774bbb1c	8	8962	962	835	852	5	4	2023-08-09 12:21:12.4	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
854	\\xd46c28b03d9dde8699cb4a5d86346b7a7ff6f3b96b9fa6a6d1431e270980f4fd	8	8978	978	836	853	37	4	2023-08-09 12:21:15.6	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
855	\\x3c097e65dbceeb3d9999779393c4bf6b3b7004b8263e1537df710d644395eb84	8	8986	986	837	854	3	4	2023-08-09 12:21:17.2	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
857	\\xe9fd6676eaf113b7e046b6cd97915fecd128eee0783563370a7607deca82ef57	8	8995	995	838	855	8	4	2023-08-09 12:21:19	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
858	\\x878d187e88c3c719ebad938970a3e8a7fd08e619d31a728fd9602ce83a53c606	9	9001	1	839	857	33	4	2023-08-09 12:21:20.2	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
859	\\x32d10b42d0d3b2e9c03d1c5a83b5c590d963224720e663684ed228355f565cd1	9	9002	2	840	858	7	437	2023-08-09 12:21:20.4	1	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
860	\\x8f7512deb7f0d017ff63749543948e90a59e51b9a5934598e9fea78451013783	9	9005	5	841	859	37	4	2023-08-09 12:21:21	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
861	\\xd44f8d371e8392883a06224945673f6e455fc2f1d5a5c516174fa71097785519	9	9033	33	842	860	33	4	2023-08-09 12:21:26.6	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
862	\\x22bab26bbef95af90ad05322f6c884fa0108b25705936b210dbbc1a854bf2c0e	9	9040	40	843	861	3	4	2023-08-09 12:21:28	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
863	\\x3a155733e4ff3e1e5c01c9abb11802af2e12a35f9b1529c7ac45f7863e4d9174	9	9048	48	844	862	7	4	2023-08-09 12:21:29.6	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
864	\\x3aaa386d636bd752f8fed212c4a6fa7ffddc4c9fef0fe91a9f7b9c2852e71bda	9	9056	56	845	863	8	4	2023-08-09 12:21:31.2	0	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
865	\\x279b2a467599ddc444f1c66ad0827638a0c5d0a1df9a4bc228587f749b73091a	9	9057	57	846	864	7	4	2023-08-09 12:21:31.4	0	8	0	vrf_vk14yp9dnm3rzztjy9mu0qtsazg0yv2v4x8mpjlgx7v45u8p0auvcus2uajen	\\x827f57e278acff6492c306d069bdc0395dd77c6554572a1c6b555aa8908d3965	0
866	\\xb54ad9e75ea1623813e92ed8b85a2043d4cfa42940cddb89eeb80ece445439d6	9	9058	58	847	865	9	4	2023-08-09 12:21:31.6	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
867	\\x1ceae2d83d90a4af77425b85c832b8f4666834a350b2b9469cd86bf89e601cf7	9	9073	73	848	866	3	4	2023-08-09 12:21:34.6	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
868	\\x34584c96bb966acb549ab5354e5853f4c13e329f4d68860ee3c740a9446e1a86	9	9085	85	849	867	33	4	2023-08-09 12:21:37	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
869	\\x80dcaeb6a8ff3fe36a55ffcf9b127bbc71ac8eedc1c11dc1d6b32d972ec9b406	9	9117	117	850	868	9	554	2023-08-09 12:21:43.4	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
870	\\x17de0c74ce6dd17f66b25174472ba47cecd20b8aae096caa7d6f581d6a8e2499	9	9126	126	851	869	37	4	2023-08-09 12:21:45.2	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
871	\\x139748bad29bd0527d566f6223af4c10ad336da25bde4eb8108dabc804e41e97	9	9127	127	852	870	6	4	2023-08-09 12:21:45.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
872	\\x0c3e1bfa8a626144d522bda43f5e1c052b0f14dbac16be44d7ed4ab68a305627	9	9135	135	853	871	14	4	2023-08-09 12:21:47	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
873	\\x56d36580dada3fa56bd0afbc42352733b4aec4c551c4267e5e2a5cf8a1af48e7	9	9136	136	854	872	14	4	2023-08-09 12:21:47.2	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
874	\\x9b3f180644f59af6f0fadd2f305c85cdc2e929a84bb13bff6273d35cbdb4e22a	9	9139	139	855	873	9	365	2023-08-09 12:21:47.8	1	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
875	\\x2e6088c2c5a8b77d390b7793ee281b8a58a9826bad61c2d73268273ab02d1873	9	9152	152	856	874	37	4	2023-08-09 12:21:50.4	0	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
876	\\x37b61d332ac58d031b8804662936e24a734d31b43d62a2b1d556e18320168d87	9	9165	165	857	875	14	4	2023-08-09 12:21:53	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
877	\\xb207b36a63e542fcfc6bfb52c46618ccd6c0990eb41e3626b028cae7c13d0a5c	9	9186	186	858	876	5	4	2023-08-09 12:21:57.2	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
878	\\x866d9a482b680e2a704e4462edbcb480d46cc6b29d5b26e936df21d52d4097b3	9	9188	188	859	877	6	4	2023-08-09 12:21:57.6	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
879	\\x410dd013d54989bc09e6342e074c44734af6412f916cfac77361700630a71e8e	9	9189	189	860	878	37	496	2023-08-09 12:21:57.8	1	8	0	vrf_vk1jljzd4z3pggsr9c2986yqc5fe7gx7zljlpuh0wc66jjhs8vl05rqa4jcge	\\x5e1ec766cc0426d783161ec5650a56f3e167b13aba5aa14fa001bea2c1a44773	0
880	\\x522172b56ef1791eb41530fbdac99763cafeb4bafc444a8a3dabf68d1e6e65e2	9	9199	199	861	879	5	4	2023-08-09 12:21:59.8	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
881	\\x3e44cab2e216460315f7bb7fe86654f17d7fb0d1aa5e1c7785f3e9ce398cbd9b	9	9207	207	862	880	6	4	2023-08-09 12:22:01.4	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
882	\\x32560814f4439ba01a415e31baef58dd8057878dfa4770484c9574f5c15175db	9	9210	210	863	881	14	4	2023-08-09 12:22:02	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
883	\\x0c46f6070451a48a73f52ed088154f934ab7b347257ba642d027e04d4deeda0c	9	9218	218	864	882	5	631	2023-08-09 12:22:03.6	1	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
884	\\xfb95399b99c319a8c14bb8174168e43ec091994c6fa6b9ccf4cff1b868d8b877	9	9221	221	865	883	33	4	2023-08-09 12:22:04.2	0	8	0	vrf_vk1rglq8wuwge4yadzl9nvprf0tr29jwmhw0alfqnz732tn0yvnfjlqaag3kd	\\x47a66477554f513b3f28864ce86238c86e1351575e72ae0cb042457bd7265e35	0
885	\\x18f09257bac94ca2f1bc28709f3fa48d1364ad35d87ec8a1c43e4272cd9cc17e	9	9224	224	866	884	9	4	2023-08-09 12:22:04.8	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
886	\\xd609347441ee7310db40a99f84d4df2499e13fd1e07fc5babc74aa5a0db71c2e	9	9234	234	867	885	14	4	2023-08-09 12:22:06.8	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
887	\\x6b93f50567307e9e52f9c1bba4b33333f4da350b082cdba3bf3e890b7a40922a	9	9255	255	868	886	14	410	2023-08-09 12:22:11	1	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
888	\\x0af0d5fc4e9f96d40177b3de9ed57d6a6188e9daf82f1908a3fba9e83adcc92c	9	9274	274	869	887	6	4	2023-08-09 12:22:14.8	0	8	0	vrf_vk1maj4updl76g2zkqk2twcc3l6s95qs7c044jxm2xq98sykz3ts22qcr670g	\\x64ee5a85ca56cb754660d9841c0fcdbf60c7c23d1e5bd2f174e63f0839111fb2	0
889	\\xcb767365b58847567d6f4757682d8c27ed353480fe9385835b195793dfc4dc23	9	9295	295	870	888	3	4	2023-08-09 12:22:19	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
890	\\xc5852f065520b43582e623a52a12536e0e539ad1816db79be450f21fbed421bc	9	9305	305	871	889	14	4	2023-08-09 12:22:21	0	8	0	vrf_vk1mt3j274zxjlh30rjtflc0urwkneq94tw9ennz5wa7lm5m87t5hhqxtu4ud	\\x9e68037a2b33492853196e6cde22c5e5a24b3afbc80db98991c2af26a9d36722	0
891	\\x18d0247e6fc1dda3050763d3745a47122b5ccd9fd837cd4e87977bc14d9aa555	9	9315	315	872	890	8	492	2023-08-09 12:22:23	1	8	0	vrf_vk16rr5wcqwv7g4dl0kny0486hh5shsm0yay7a6kyju6gwamu2g4anqkvg6m2	\\x8727e1999c86f1b13542721a4b77494db210983a28290f6c63726f30052d5bf9	0
892	\\x384ba28e435bd556e26992953bbc8415724479fc29478a9230c783608cbcd650	9	9339	339	873	891	9	4	2023-08-09 12:22:27.8	0	8	0	vrf_vk1fyc40a7s6kejv28jxql88ch9tqfxgtpesx706prgz0a07j3rj63sls7v8z	\\x8a58e56a9c581b0bf4f228678a90f06c9eb4cef2436f3526a2a59c3130ebde55	0
893	\\x3baebb466a1ce2e78e1ab06a21cead08f3261b416ff0620fd58451bd434db063	9	9343	343	874	892	5	4	2023-08-09 12:22:28.6	0	8	0	vrf_vk1zvhys2edc4khmepfzpc0evh9wu64n2rrgxzz0hmd53cm09vh6daqvz9sgt	\\xee7f42652a4c40bbbe829e33a18f93dd399750a911384d12370e694d6beab5ad	0
894	\\x27e1a7899952a7a16585f7754f74888eff31d4df31f2ac3ed2f13cb63fa62274	9	9355	355	875	893	3	4	2023-08-09 12:22:31	0	8	0	vrf_vk1m2kcukrkglvplknxyn4kt2m2rxvqu688ll6423kvveql6cuy52fqyq7pus	\\xb07d5ecbec25e5db81672b641077d79c543a217fcfefa6a790ed657c83be253e	0
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
1	99	1	addr_test1vz3kzhcl3j0tjz6mk7envuf0d0hgfe5guwwkt6qp342shkgfzjpjd	\\x60a3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	f	\\xa3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	\N	3681818081394197	\N	fromList []	\N	\N
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
1	9	1	1	2	34	0	\N
2	10	3	8	2	34	0	\N
3	6	5	5	2	34	0	\N
4	2	7	7	2	34	0	\N
5	11	9	4	2	34	0	\N
6	7	11	3	2	34	0	\N
7	3	13	2	2	34	0	\N
8	8	15	10	2	34	0	\N
9	4	17	9	2	34	0	\N
10	5	19	11	2	34	0	\N
11	1	21	6	2	34	0	\N
12	15	0	4	2	37	49	\N
13	11	0	4	2	38	60	\N
14	18	0	7	2	42	144	\N
15	2	0	7	2	43	163	\N
16	16	0	5	2	47	267	\N
17	6	0	5	2	48	293	\N
18	14	0	3	2	52	363	\N
19	7	0	3	2	53	371	\N
20	22	0	11	2	57	446	\N
21	5	0	11	2	58	456	\N
22	20	0	9	2	62	522	\N
23	4	0	9	2	63	558	\N
24	17	0	6	2	67	626	\N
25	1	0	6	2	68	647	\N
26	12	0	1	2	72	710	\N
27	9	0	1	2	73	723	\N
28	9	0	1	2	75	765	\N
29	13	0	2	2	79	850	\N
30	3	0	2	2	80	864	\N
31	3	0	2	2	82	939	\N
32	19	0	8	3	86	1011	\N
33	10	0	8	3	87	1021	\N
34	10	0	8	3	89	1043	\N
35	21	0	10	3	93	1111	\N
36	8	0	10	3	94	1129	\N
37	8	0	10	3	96	1172	\N
38	51	1	6	6	131	4952	\N
39	52	3	11	6	131	4952	\N
40	53	5	3	6	131	4952	\N
41	54	7	4	6	131	4952	\N
42	55	9	5	6	131	4952	\N
43	51	0	6	7	133	5040	\N
44	52	1	6	7	133	5040	\N
45	53	2	6	7	133	5040	\N
46	54	3	6	7	133	5040	\N
47	55	4	6	7	133	5040	\N
48	46	1	6	7	142	5329	\N
49	46	1	6	7	151	5604	\N
50	48	0	12	11	255	9189	\N
51	45	0	13	11	258	9315	\N
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
1	187772653479984806	9155683	51	100	0	2023-08-09 11:51:20	2023-08-09 11:54:36.6
2	81009964537308404	4711124	25	99	1	2023-08-09 11:54:42.2	2023-08-09 11:57:57.8
10	15048599303649	1237531	7	36	9	2023-08-09 12:21:20.2	2023-08-09 12:22:28.6
7	0	0	0	87	6	2023-08-09 12:11:23.4	2023-08-09 12:14:34.4
4	0	0	0	92	3	2023-08-09 12:01:20.2	2023-08-09 12:04:35.8
8	5591542256420	16892464	100	85	7	2023-08-09 12:14:41.4	2023-08-09 12:17:58.6
6	47058425280152	9080311	20	89	5	2023-08-09 12:08:02	2023-08-09 12:11:16.8
3	0	0	0	99	2	2023-08-09 11:58:02	2023-08-09 12:01:18
9	0	0	0	82	8	2023-08-09 12:18:01.2	2023-08-09 12:21:17.2
5	65000697539025	3976593	21	99	4	2023-08-09 12:04:42.8	2023-08-09 12:07:58.2
\.


--
-- Data for Name: epoch_param; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_param (id, epoch_no, min_fee_a, min_fee_b, max_block_size, max_tx_size, max_bh_size, key_deposit, pool_deposit, max_epoch, optimal_pool_count, influence, monetary_expand_rate, treasury_growth_rate, decentralisation, protocol_major, protocol_minor, min_utxo_value, min_pool_cost, nonce, cost_model_id, price_mem, price_step, max_tx_ex_mem, max_tx_ex_steps, max_block_ex_mem, max_block_ex_steps, max_val_size, collateral_percent, max_collateral_inputs, block_id, extra_entropy, coins_per_utxo_size) FROM stdin;
1	1	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x6dbe486a0a896cd183d4ee2e92c3c7c20a5462a4c9e3a9e31e000cec5be329fe	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	103	\N	4310
2	2	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x185787e9d02625ed54142e651f50a0abe771fef03935d3807ab594928625a497	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	202	\N	4310
3	3	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\xe85697f660b0942542a55ac62e163533f8431694a784f8fc8d41d077fe5546b9	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	302	\N	4310
4	4	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x41f88720917b96ba47df9de250d14e23d9fb7397f99f5be88a0b0f25ec20825d	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	397	\N	4310
5	5	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x7468b9d013a9c8a88a4162d16dce68b2089041c1ff7da230c8e623a9c11de205	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	501	\N	4310
6	6	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x442fecf929a3d7c387922f7dceed980cf028c06f4d06a365a77a61b5bff86f5c	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	592	\N	4310
7	7	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x06ed3478cf23fd4811f61ae1cab0394ef6494edd3b0a29243361780d4f6400d9	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	684	\N	4310
8	8	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x5345ed3bf230f3667fe847ee05cb7a616e37f4995d8675c831527c73f52f71ae	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	772	\N	4310
9	9	44	155381	65536	16384	1100	0	0	18	100	0	0.100000000000000006	0.100000000000000006	0	7	0	4310	0	\\x0ade78a2214664e4d8de7a856394901b090eda89d6a055d686cd0aa384d08947	1	0.0577000000000000013	7.21000000000000043e-05	16000000	10000000000	80000000	40000000000	5000	150	3	858	\N	4310
\.


--
-- Data for Name: epoch_stake; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_stake (id, addr_id, pool_id, amount, epoch_no) FROM stdin;
1	9	1	3681818181818181	1
2	10	8	3681818181818181	1
3	6	5	3681818181818181	1
4	2	7	3681818181818181	1
5	11	4	3681818181818181	1
6	7	3	3681818181818181	1
7	3	2	3681818181818181	1
8	8	10	3681818181818190	1
9	4	9	3681818181818181	1
10	5	11	3681818181818181	1
11	1	6	3681818181818181	1
12	9	1	3681818181265842	2
13	22	11	500000000	2
14	10	8	3681818181818181	2
15	6	5	3681818181443619	2
16	2	7	3681818181446391	2
17	11	4	3681818181443619	2
18	15	4	500000000	2
19	18	7	600000000	2
20	7	3	3681818181443619	2
21	14	3	500000000	2
22	3	2	3681818181265842	2
23	13	2	300000000	2
24	8	10	3681818181818190	2
25	17	6	500000000	2
26	4	9	3681818181443619	2
27	16	5	200000000	2
28	5	11	3681818181443619	2
29	20	9	500000000	2
30	1	6	3681818181443619	2
31	12	1	300000000	2
32	19	8	500000000	3
33	9	1	3681818181265842	3
34	22	11	500000000	3
35	10	8	3681818181263026	3
36	6	5	3681818181443619	3
37	2	7	3681818181446391	3
38	11	4	3681818181443619	3
39	21	10	500000000	3
40	15	4	500000000	3
41	18	7	600000000	3
42	7	3	3681818181443619	3
43	14	3	500000000	3
44	3	2	3681818181265842	3
45	13	2	300000000	3
46	8	10	3681818181263035	3
47	17	6	500000000	3
48	4	9	3681818181443619	3
49	16	5	200000000	3
50	5	11	3681818181443619	3
51	20	9	500000000	3
52	1	6	3681818181443619	3
53	12	1	300000000	3
54	19	8	500000000	4
55	9	1	3686228626383175	4
56	22	11	500000000	4
57	10	8	3687992804427292	4
58	6	5	3687992804607885	4
59	2	7	3690639071681057	4
60	11	4	3687110715584419	4
61	21	10	500000000	4
62	15	4	500000000	4
63	18	7	600000000	4
64	7	3	3691521160701752	4
65	14	3	500000000	4
66	3	2	3695049516617842	4
67	13	2	300000000	4
68	8	10	3689756982474234	4
69	17	6	500000000	4
70	4	9	3687110715584419	4
71	16	5	200000000	4
72	5	11	3693285338748685	4
73	20	9	500000000	4
74	1	6	3690639071678285	4
75	12	1	300000000	4
76	19	8	500000000	5
77	9	1	3692281602863588	5
78	22	11	501056868	5
79	10	8	3699234048292566	5
80	6	5	3697504625307624	5
81	2	7	3700150890314023	5
82	11	4	3691434269743357	5
83	21	10	500000000	5
84	15	4	500587149	5
85	18	7	601550074	5
86	7	3	3696709425692478	5
87	14	3	500704579	5
88	3	2	3702831914949802	5
89	13	2	300634121	5
90	8	10	3697539382073270	5
91	17	6	501174298	5
92	4	9	3695757823902296	5
93	16	5	200516691	5
94	5	11	3701067736234775	5
95	20	9	501174298	5
96	1	6	3699286179996162	5
97	12	1	300493205	5
98	19	8	500920744	6
99	9	1	3692281602863588	6
100	22	11	890711624923	6
101	54	4	200000000	6
102	10	8	3706014073149657	6
103	53	3	200000000	6
104	6	5	3697504625307624	6
105	2	7	3703032069221670	6
106	11	4	3699358092294739	6
107	21	10	500920744	6
108	15	4	1399213479833	6
109	51	6	199693655	6
110	18	7	509435439100	6
111	7	3	3706074020525919	6
112	52	11	200000000	6
113	14	3	1653447759580	6
114	3	2	3702831914949802	6
115	13	2	300634121	6
116	8	10	3704319406930361	6
117	17	6	1017837323510	6
118	4	9	3702961260312648	6
119	16	5	200516691	6
120	5	11	3706110048222034	6
121	55	5	200000000	6
122	20	9	1272096985824	6
123	1	6	3705048869624452	6
124	12	1	300493205	6
125	22	11	1890686558675	7
126	54	6	0	7
127	53	6	0	7
128	6	5	3697504625307624	7
129	2	7	3709409027890939	7
130	11	4	3703613356274071	7
131	21	10	2002031121745	7
132	15	4	2150533096239	7
133	51	6	499402614	7
134	18	7	1635172306293	7
135	7	3	3712449472687546	7
136	52	6	0	7
137	14	3	2778898568721	7
138	3	2	3702831914949802	7
139	13	2	300634121	7
140	8	10	3715659191158318	7
141	17	6	2143574048410	7
142	4	9	3710053579444839	7
143	16	5	200516691	7
144	5	11	3711774357734373	7
145	55	6	499846827	7
146	20	9	2524083846530	7
147	46	6	4998958485023	7
148	1	6	3711425828639309	7
149	22	11	3241472370548	8
150	54	6	0	8
151	53	6	0	8
152	6	5	3697504625307624	8
153	2	7	3717759020002895	8
154	11	4	3709193052617971	8
155	21	10	2616791246078	8
156	15	4	3135576282398	8
157	51	6	499402614	8
158	18	7	3109091923103	8
159	7	3	3717324715254200	8
160	52	6	0	8
161	14	3	3639606269109	8
162	3	2	3702831914949802	8
163	13	2	300634121	8
164	8	10	3719140618724365	8
165	17	6	3249354835298	8
166	4	9	3713536676907240	8
167	16	5	200516691	8
168	5	11	3719426593761835	8
169	55	6	499846827	8
170	20	9	3139148660290	8
171	46	6	4998958485023	8
172	1	6	3717689704107536	8
173	22	11	4693585024580	9
174	54	6	222353	9
175	53	6	221519	9
176	6	5	3697504625307624	9
177	2	7	3723240099995175	9
178	11	4	3713305882532659	9
179	21	10	3342551565808	9
180	15	4	3863589955424	9
181	51	6	499734689	9
182	18	7	4077618446406	9
183	7	3	3721429551154931	9
184	52	6	443228	9
185	14	3	4366513647771	9
186	3	2	3702831914949802	9
187	13	2	300634121	9
188	8	10	3723251046830592	9
189	17	6	4339008377494	9
190	4	9	3718330688909196	9
191	16	5	200516691	9
192	5	11	3727639862065034	9
193	55	6	499846827	9
194	20	9	3987488320821	9
195	46	6	4998941592559	9
196	1	6	3723850913283911	9
\.


--
-- Data for Name: epoch_sync_time; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_sync_time (id, no, seconds, state) FROM stdin;
1	0	1	lagging
2	1	1	lagging
3	2	1	following
4	3	184	following
5	4	200	following
6	5	202	following
7	6	198	following
8	7	200	following
9	8	199	following
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
11	-1	114	10
12	-1	115	9
13	1	116	9
14	1	117	9
15	-2	118	9
16	2	119	9
17	-2	120	9
18	2	121	9
19	-1	122	9
20	-1	123	9
21	1	124	11
22	1	124	12
23	1	124	13
24	-1	125	12
25	1	126	14
26	1	127	15
27	1	128	16
28	-1	129	14
29	-1	129	15
30	-1	129	16
31	-1	129	11
32	-1	129	13
33	10	134	17
34	-10	135	17
35	1	136	18
36	-1	137	18
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
11	1	138	9
12	1	139	10
13	1	141	10
14	1	144	9
15	1	146	9
16	2	149	9
17	2	152	9
18	1	154	9
19	1	156	11
20	1	156	12
21	1	156	13
22	1	159	11
23	1	159	13
24	1	160	14
25	1	161	11
26	1	161	13
27	1	162	15
28	1	163	14
29	1	164	16
30	1	165	14
31	1	165	15
32	10	214	17
33	1	217	18
34	13500000000000000	571	1
35	13500000000000000	571	2
36	13500000000000000	571	3
37	13500000000000000	571	4
38	13500000000000000	573	1
39	13500000000000000	573	2
40	13500000000000000	573	3
41	13500000000000000	573	4
\.


--
-- Data for Name: meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meta (id, start_time, network_name, version) FROM stdin;
1	2023-08-09 11:51:20	testnet	Version {versionBranch = [13,1,0,0], versionTags = []}
\.


--
-- Data for Name: multi_asset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.multi_asset (id, policy, name, fingerprint) FROM stdin;
1	\\x023f3343a008b850ab917215c282cb1b701245a34f699f4ae1ee1ae2	\\x	asset12wav55v9f0q3rcetltga7k4ntc52gt52qk6pxu
2	\\x023f3343a008b850ab917215c282cb1b701245a34f699f4ae1ee1ae2	\\x74425443	asset1h2lymtr628m9pez52f8gr6fm7mnxznfwy93tg5
3	\\x023f3343a008b850ab917215c282cb1b701245a34f699f4ae1ee1ae2	\\x74455448	asset1fgr2zdsctvcjyslvutqlhe58v7xyc3nn8yghjk
4	\\x023f3343a008b850ab917215c282cb1b701245a34f699f4ae1ee1ae2	\\x744d494e	asset18tc9gz8armftjjxzf8lga82ndszmg38w62t9x4
5	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x446f75626c6548616e646c65	asset1ss4nvcah07l2492qrfydamvukk4xdqme8k22vv
6	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x48656c6c6f48616e646c65	asset13xe953tueyajgxrksqww9kj42erzvqygyr3phl
7	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x5465737448616e646c65	asset1ne8rapyhga8jp95pemrefrgts9ht035zlmy6zj
8	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x283232322968616e646c653638	asset1ju4qkyl4p9xszrgfxfmu909q90luzqu0nyh4u8
9	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x68616e646c6531	asset1q0g92m9xjj3nevsw26hfl7uf74av7yce5l56jv
10	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	\\x68616e646c6532	asset1se72wfdln5vlspqe3yg8yck0rrgand3a48rjyc
11	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d303031	asset1p7xl6rzm50j2p6q2z7kd5wz3ytyjtxts8g8drz
12	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d303032	asset1ftcuk4459tu0kfkf2s6m034q8uudr20w7wcxej
13	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4e46542d66696c6573	asset1xac6dlxa7226c65wp8u5d4mrz5hmpaeljvcr29
14	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d76312d686578	asset1v2z720699zh5x5mzk23gv829akydgqz2zy9f6l
15	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d76312d75746638	asset16unjfedceaaven5ypjmxf5m2qd079td0g8hldp
16	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x4349502d303032352d7632	asset1yc673t4h5w5gfayuedepzfrzmtuj3s9hay9kes
17	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	\\x3030303030	asset1ul4zmmx2h8rqz9wswvc230w909pq2q0hne02q0
18	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	\\x	asset1qrmynj6uhyk2hn9pc3yh0p80rg598n4yy77ays
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
1	\\x1f85cef1f39a0ff5776c151d03f97db41ad9a1179146ba077de31753	pool1r7zuau0nng8l2amvz5ws87taksddngghj9rt5pmauvt4xqq2pue
2	\\x21a4eff8963ee2ad29c73a0ad3486af817e5151f69bf17b28328f521	pool1yxjwl7yk8m3262w88g9dxjr2lqt729gldxl30v5r9r6jz0hp23d
3	\\x2411b8087fb88ed526d7d883a5494c6e69de8a03ba8546da4a8a2726	pool1ysgmszrlhz8d2fkhmzp62j2vde5aazsrh2z5dkj23gnjvc7uw7p
4	\\x25ae8e4eb68aeac6eedbb6b636ea21657ae9ab34c626a873f5c5d99f	pool1ykhgun4k3t4vdmkmk6mrd63pv4awn2e5ccn2sul4chve7ed0hrq
5	\\x3a69bbfb9575c711226509c128507f260c0d143c0068872cc537a444	pool18f5mh7u4whr3zgn9p8qjs5rlycxq69puqp5gwtx9x7jygs2n45e
6	\\x85ecb98fd631e903ef702c32cb40fc1fc6d24099159ef2ff88b8661d	pool1shktnr7kx85s8mms9sevks8urlrdysyezk009lughpnp6m58j6y
7	\\x8e2c6c55238a07bd643ffbd82ab0bc52cd93b123fbc18c24642662b9	pool13ckxc4fr3grm6epll0vz4v9u2txe8vfrl0qccfryye3tjkvysdz
8	\\x9a98ac0ef967241df4390d0690d753511d38b09083fb70a92346ab56	pool1n2v2crhevujpmapep5rfp46n2ywn3vyss0ahp2frg644v95ffcl
9	\\xa3d013ec54bb60badd7a9535db921a6dae70bcfae4f6b33c9045562d	pool150gp8mz5hdst4ht6j56ahys6dkh8p086unmtx0ysg4tz6tx88hw
10	\\xaff0c09d724bca532b1d6c29be25b70c3f9bae3fa63c8de0887085da	pool14lcvp8tjf099x2cads5mufdhpsleht3l5c7gmcygwzza5gkjf5l
11	\\xde8e7c6287707f7afc20a06acf207910ef50c38cb465415dca089960	pool1m688cc58wplh4lpq5p4v7grezrh4psuvk3j5zhw2pzvkq5wmtwd
12	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
13	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_metadata_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata_ref (id, pool_id, url, hash, registered_tx_id) FROM stdin;
1	4	http://file-server/SP1.json	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	39
2	5	http://file-server/SP3.json	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	49
3	3	http://file-server/SP4.json	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	54
4	11	http://file-server/SP5.json	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	59
5	9	http://file-server/SP6.json	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	64
6	6	http://file-server/SP7.json	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	69
7	8	http://file-server/SP10.json	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	88
8	10	http://file-server/SP11.json	\\x4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	95
\.


--
-- Data for Name: pool_offline_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_offline_data (id, pool_id, ticker_name, hash, json, bytes, pmr_id) FROM stdin;
1	4	SP1	\\x14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	{"name": "stake pool - 1", "ticker": "SP1", "homepage": "https://stakepool1.com", "description": "This is the stake pool 1 description."}	\\x7b0a2020226e616d65223a20227374616b6520706f6f6c202d2031222c0a2020227469636b6572223a2022535031222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2031206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c312e636f6d220a7d0a	1
2	5	SP3	\\x6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	{"name": "Stake Pool - 3", "ticker": "SP3", "homepage": "https://stakepool3.com", "description": "This is the stake pool 3 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2033222c0a2020227469636b6572223a2022535033222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2033206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c332e636f6d220a7d0a	2
3	3	SP4	\\x09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	{"name": "Same Name", "ticker": "SP4", "homepage": "https://stakepool4.com", "description": "This is the stake pool 4 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535034222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2034206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c342e636f6d220a7d0a	3
4	11	SP5	\\x0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	{"name": "Same Name", "ticker": "SP5", "homepage": "https://stakepool5.com", "description": "This is the stake pool 5 description."}	\\x7b0a2020226e616d65223a202253616d65204e616d65222c0a2020227469636b6572223a2022535035222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2035206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c352e636f6d220a7d0a	4
5	9	SP6a7	\\x3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	{"name": "Stake Pool - 6", "ticker": "SP6a7", "homepage": "https://stakepool6.com", "description": "This is the stake pool 6 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d2036222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2036206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c362e636f6d220a7d0a	5
6	6	SP6a7	\\xc431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	{"name": "", "ticker": "SP6a7", "homepage": "https://stakepool7.com", "description": "This is the stake pool 7 description."}	\\x7b0a2020226e616d65223a2022222c0a2020227469636b6572223a20225350366137222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c2037206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c372e636f6d220a7d0a	6
7	8	SP10	\\xc054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	{"name": "Stake Pool - 10", "ticker": "SP10", "homepage": "https://stakepool10.com", "description": "This is the stake pool 10 description."}	\\x7b0a2020226e616d65223a20225374616b6520506f6f6c202d203130222c0a2020227469636b6572223a202253503130222c0a2020226465736372697074696f6e223a20225468697320697320746865207374616b6520706f6f6c203130206465736372697074696f6e2e222c0a202022686f6d6570616765223a202268747470733a2f2f7374616b65706f6f6c31302e636f6d220a7d0a	7
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
2	18	13
3	16	14
4	14	15
5	22	16
6	20	17
7	17	18
8	12	19
9	13	20
10	19	21
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
1	1	0	76	5
2	2	0	83	18
3	8	0	90	5
4	10	0	97	18
\.


--
-- Data for Name: pool_update; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_update (id, hash_id, cert_index, vrf_key_hash, pledge, active_epoch_no, meta_id, margin, fixed_cost, registered_tx_id, reward_addr_id) FROM stdin;
1	1	0	\\xffbe730c77d0c057fe51d9e63fa6e494d2a66d6fda1155cfe992f6e40cdf43b7	0	2	\N	0	0	34	12
2	2	1	\\x9aa69a568b86eff9a3ef2147d63f4e51b95532d40119c7033e9ad3e920619cc2	0	2	\N	0	0	34	13
3	3	2	\\xf058b566bbcbbe7d6352ccccdf0a9f1494c1f7365b3043332ddd4de026b7e5ec	0	2	\N	0	0	34	14
4	4	3	\\x66cef748f868fb02cc21bb9f2b5500f4ae4ac9f3d2a92861ecc02e77f8aadc0d	0	2	\N	0	0	34	15
5	5	4	\\x8fae40f79966423deefa149701c41fb4ac407a7656e67b3bae9f2225aa3134bf	0	2	\N	0	0	34	16
6	6	5	\\x821af3fbf3fcf2ee2069433ddc511089b45f117f315cb6fbfcddcdc542d23905	0	2	\N	0	0	34	17
7	7	6	\\x11f778bf5179aac4d39b7878fcae5e017de73e39ef6949d2183ce97fef0f55d5	0	2	\N	0	0	34	18
8	8	7	\\x96f1f5957a0abda66c7ec839e5abbaa1ee107cad7d03bbe0f434e3dd4fadf02d	0	2	\N	0	0	34	19
9	9	8	\\xd4c7b4434d02ada519902b9aa5e53f70902366f7ae61b83560cedf2b864165a5	0	2	\N	0	0	34	20
10	10	9	\\xd4517f93712b3447bd19e9f45890790ceb19f28ea4c2f4a114b8a691e09ce04a	0	2	\N	0	0	34	21
11	11	10	\\x3bbed4db76212c20f2667a80f0712bc4aeb93d257c9433d93bdad36f0d074715	0	2	\N	0	0	34	22
12	4	0	\\x66cef748f868fb02cc21bb9f2b5500f4ae4ac9f3d2a92861ecc02e77f8aadc0d	400000000	3	1	0.149999999999999994	390000000	39	15
13	7	0	\\x11f778bf5179aac4d39b7878fcae5e017de73e39ef6949d2183ce97fef0f55d5	500000000	3	\N	0.149999999999999994	390000000	44	18
14	5	0	\\x8fae40f79966423deefa149701c41fb4ac407a7656e67b3bae9f2225aa3134bf	600000000	3	2	0.149999999999999994	390000000	49	16
15	3	0	\\xf058b566bbcbbe7d6352ccccdf0a9f1494c1f7365b3043332ddd4de026b7e5ec	420000000	3	3	0.149999999999999994	370000000	54	14
16	11	0	\\x3bbed4db76212c20f2667a80f0712bc4aeb93d257c9433d93bdad36f0d074715	410000000	3	4	0.149999999999999994	390000000	59	22
17	9	0	\\xd4c7b4434d02ada519902b9aa5e53f70902366f7ae61b83560cedf2b864165a5	410000000	3	5	0.149999999999999994	400000000	64	20
18	6	0	\\x821af3fbf3fcf2ee2069433ddc511089b45f117f315cb6fbfcddcdc542d23905	410000000	3	6	0.149999999999999994	390000000	69	17
19	1	0	\\xffbe730c77d0c057fe51d9e63fa6e494d2a66d6fda1155cfe992f6e40cdf43b7	500000000	3	\N	0.149999999999999994	380000000	74	12
20	2	0	\\x9aa69a568b86eff9a3ef2147d63f4e51b95532d40119c7033e9ad3e920619cc2	500000000	3	\N	0.149999999999999994	390000000	81	13
21	8	0	\\x96f1f5957a0abda66c7ec839e5abbaa1ee107cad7d03bbe0f434e3dd4fadf02d	400000000	4	7	0.149999999999999994	410000000	88	19
22	10	0	\\xd4517f93712b3447bd19e9f45890790ceb19f28ea4c2f4a114b8a691e09ce04a	400000000	4	8	0.149999999999999994	390000000	95	21
23	12	0	\\x2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	500000000000000	11	\N	0.200000000000000011	1000	253	48
24	13	0	\\x641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	50000000	11	\N	0.200000000000000011	1000	256	45
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
2	4	1:34:
3	5	2:36:
4	6	::
5	7	3:37:
6	8	4:38:
7	9	::
8	10	::
9	11	::
10	12	5:39:
11	13	6:40:
12	14	::
13	15	::
14	16	::
15	17	::
16	18	7:42:
17	19	8:43:
18	20	::
19	21	9:44:
20	22	::
21	23	::
22	24	10:45:
23	25	::
24	26	::
25	27	11:46:
26	28	::
27	29	12:48:
28	30	::
29	31	13:49:
30	32	::
31	33	::
32	34	14:50:
33	35	::
34	36	::
35	37	15:51:
36	38	16:52:
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
49	51	25:63:
50	52	26:64:
51	53	::
52	54	27:66:
53	55	::
54	56	28:67:
55	57	::
56	58	29:68:
57	59	::
58	60	30:69:
59	61	31:70:
60	62	::
61	63	32:72:
62	64	::
63	65	::
64	66	33:73:
65	67	::
66	68	34:74:
67	69	::
68	70	35:75:
69	71	36:76:
70	72	::
71	73	37:78:
72	74	::
73	75	::
74	76	38:79:
75	77	::
76	78	::
77	79	39:80:
78	80	::
79	81	::
80	82	::
81	83	40:81:
82	84	41:82:
83	85	::
84	86	::
85	87	42:83:
86	88	::
87	89	43:84:
88	90	::
89	91	44:86:
90	92	::
91	93	45:87:
92	94	46:88:
93	95	47:89:
94	96	::
95	97	48:90:
96	98	::
97	99	49:91:
98	100	::
99	101	50:92:
100	102	51:94:
101	103	52:95:
102	104	::
103	105	53:96:
104	106	::
105	107	::
106	108	54:97:
107	109	55:98:
108	110	56:99:
109	111	::
110	112	57:100:
111	113	::
112	114	58:102:
113	115	59:103:
114	116	::
115	117	::
116	118	60:104:
117	119	::
118	120	::
119	121	61:105:
120	122	62:106:
121	123	63:107:
122	124	64:108:
123	125	::
124	126	65:110:
125	127	::
126	128	66:111:
127	129	::
128	130	67:113:
129	131	68:115:
130	132	69:117:
131	133	70:119:
132	134	71:121:
133	135	72:123:
134	136	74:124:1
135	137	75:126:
136	138	76:132:5
137	139	77:134:8
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
320	322	::
321	323	::
322	324	::
323	325	::
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
409	411	78:136:9
411	413	::
412	414	::
414	416	::
415	417	79:138:11
416	418	::
417	419	::
418	420	::
419	421	81:140:13
420	422	::
421	423	::
422	424	::
423	425	82:142:
424	426	::
425	427	::
426	428	::
427	429	83:143:
428	430	::
429	431	::
430	432	::
431	433	84:144:14
432	434	::
433	435	::
434	436	::
435	437	85:146:15
436	438	::
437	439	::
438	440	::
439	441	::
440	442	86:148:
441	443	::
442	444	::
443	445	::
444	446	88:149:16
445	447	::
446	448	::
447	449	::
448	450	89:151:
449	451	::
450	452	::
451	453	::
452	454	90:152:17
453	455	::
454	456	::
455	457	::
456	458	92:154:18
457	459	::
458	460	::
459	461	::
460	462	93:155:
461	463	::
462	464	::
463	465	::
464	466	94:156:19
465	467	::
466	468	::
468	470	::
469	471	96:158:22
470	472	::
471	473	::
472	474	::
473	475	98:160:24
474	476	::
475	477	::
476	478	::
477	479	99:162:27
478	480	::
479	481	::
480	482	::
481	483	102:164:29
483	485	::
484	486	::
485	487	::
486	488	104:166:
487	489	::
488	490	::
489	491	::
490	492	::
491	493	107:167:
492	494	::
493	495	::
494	496	::
495	497	108:169:
496	498	::
497	499	::
498	500	::
499	501	109:204:
500	502	::
501	503	::
502	504	::
503	505	144:213:
504	506	::
505	507	::
506	508	::
507	509	::
508	510	145:214:32
509	511	::
510	512	::
511	513	::
512	514	146:216:
513	515	::
514	516	::
515	517	::
516	518	147:217:33
517	519	::
518	520	::
519	521	::
520	522	149:219:
521	523	::
522	524	::
523	525	::
524	526	150:220:
525	527	151::
526	528	152:222:
527	529	154:224:
528	530	156:226:
529	531	157:228:
530	532	158:229:
531	533	::
532	534	::
533	535	::
534	536	::
536	538	::
537	539	162:233:
538	540	::
539	541	163:235:
540	542	::
541	543	::
542	544	164:355:
543	545	::
544	546	::
545	547	::
546	548	::
547	549	224:357:
548	550	::
549	551	::
550	552	::
551	553	225:359:
552	554	226:361:
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
641	643	::
642	644	::
643	645	::
645	647	::
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
683	685	227:362:
684	686	294:472:
685	687	::
686	688	::
687	689	::
688	690	::
689	691	::
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
855	857	::
856	858	::
857	859	361:562:
858	860	::
859	861	::
860	862	::
861	863	::
862	864	::
863	865	::
864	866	::
865	867	::
866	868	::
867	869	362:564:
868	870	::
869	871	::
870	872	::
871	873	::
872	874	363:566:
873	875	::
874	876	::
875	877	::
876	878	::
877	879	365:568:
878	880	::
879	881	::
880	882	::
881	883	367:570:34
882	884	::
883	885	::
884	886	::
885	887	368:572:38
886	888	::
887	889	::
888	890	::
889	891	369:574:
890	892	::
891	893	::
892	894	::
\.


--
-- Data for Name: reward; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reward (id, addr_id, type, amount, earned_epoch, spendable_epoch, pool_id) FROM stdin;
1	9	member	4410445117333	1	3	1
2	10	member	6174623164266	1	3	8
3	6	member	6174623164266	1	3	5
4	2	member	8820890234666	1	3	7
5	11	member	5292534140800	1	3	4
6	7	member	9702979258133	1	3	3
7	3	member	13231335352000	1	3	2
8	8	member	7938801211199	1	3	10
9	4	member	5292534140800	1	3	9
10	5	member	11467157305066	1	3	11
11	1	member	8820890234666	1	3	6
12	19	leader	0	1	3	8
13	22	leader	0	1	3	11
14	21	leader	0	1	3	10
15	15	leader	0	1	3	4
16	18	leader	0	1	3	7
17	14	leader	0	1	3	3
18	13	leader	0	1	3	2
19	17	leader	0	1	3	6
20	16	leader	0	1	3	5
21	20	leader	0	1	3	9
22	12	leader	0	1	3	1
23	9	member	6052976480413	2	4	1
24	22	member	1056868	2	4	11
25	10	member	11241243865274	2	4	8
26	6	member	9511820699739	2	4	5
27	2	member	9511818632966	2	4	7
28	11	member	4323554158938	2	4	4
29	15	member	587149	2	4	4
30	18	member	1550074	2	4	7
31	7	member	5188264990726	2	4	3
32	14	member	704579	2	4	3
33	3	member	7782398331960	2	4	2
34	13	member	634121	2	4	2
35	8	member	7782399599036	2	4	10
36	17	member	1174298	2	4	6
37	4	member	8647108317877	2	4	9
38	16	member	516691	2	4	5
39	5	member	7782397486090	2	4	11
40	20	member	1174298	2	4	9
41	1	member	8647108317877	2	4	6
42	12	member	493205	2	4	1
43	19	leader	0	2	4	8
44	22	leader	0	2	4	11
45	21	leader	0	2	4	10
46	15	leader	0	2	4	4
47	18	leader	0	2	4	7
48	14	leader	0	2	4	3
49	13	leader	0	2	4	2
50	17	leader	0	2	4	6
51	16	leader	0	2	4	5
52	20	leader	0	2	4	9
53	12	leader	0	2	4	1
54	19	member	920744	3	5	8
55	10	member	6780024857091	3	5	8
56	2	member	2881178907647	3	5	7
57	11	member	7923822551382	3	5	4
58	21	member	920744	3	5	10
59	7	member	9364594833441	3	5	3
60	8	member	6780024857091	3	5	10
61	4	member	7203436410352	3	5	9
62	5	member	5042311987259	3	5	11
63	1	member	5762689628290	3	5	6
64	19	leader	0	3	5	8
65	22	leader	890210568055	3	5	11
66	21	leader	0	3	5	10
67	15	leader	1398712892684	3	5	4
68	18	leader	508833889026	3	5	7
69	14	leader	1652947055001	3	5	3
70	13	leader	0	3	5	2
71	17	leader	1017336149212	3	5	6
72	16	leader	0	3	5	5
73	20	leader	1271595811526	3	5	9
74	12	leader	0	3	5	1
75	19	refund	0	5	5	8
76	12	refund	0	5	5	1
77	10	member	6381517948534	4	6	8
78	2	member	6376958669269	4	6	7
79	11	member	4255263979332	4	6	4
80	7	member	6375452161627	4	6	3
81	8	member	11339784227957	4	6	10
82	4	member	7092319132191	4	6	9
83	5	member	5664309512339	4	6	11
84	1	member	6376959014857	4	6	6
85	19	leader	1126561244064	4	6	8
86	22	leader	999974933752	4	6	11
87	21	leader	2001530201001	4	6	10
88	15	leader	751319616406	4	6	4
89	18	leader	1125736867193	4	6	7
90	14	leader	1125450809141	4	6	3
91	13	leader	0	4	6	2
92	17	leader	1125736724900	4	6	6
93	16	leader	0	4	6	5
94	20	leader	1251986860706	4	6	9
95	12	leader	0	4	6	1
96	10	member	7656012362248	5	7	8
97	2	member	8349992111956	5	7	7
98	11	member	5579696343900	5	7	4
99	7	member	4875242566654	5	7	3
100	8	member	3481427566047	5	7	10
102	4	member	3483097462401	5	7	9
103	5	member	7652236027462	5	7	11
105	1	member	6263875468227	5	7	6
106	19	leader	1351472222526	5	7	8
107	22	leader	1350785811873	5	7	11
108	21	leader	614760124333	5	7	10
109	15	leader	985043186159	5	7	4
110	18	leader	1473919616810	5	7	7
111	14	leader	860707700388	5	7	3
112	13	leader	0	5	7	2
113	17	leader	1105780786888	5	7	6
114	16	leader	0	5	7	5
115	20	leader	615064813760	5	7	9
116	12	leader	0	5	7	1
117	54	member	222353	6	8	4
118	10	member	6162971290957	6	8	8
119	53	member	221519	6	8	3
120	2	member	5481079992280	6	8	7
121	11	member	4112829914688	6	8	4
122	51	member	332075	6	8	6
123	7	member	4104835900731	6	8	3
124	52	member	443228	6	8	11
125	8	member	4110428106227	6	8	10
126	4	member	4794012001956	6	8	9
127	5	member	8213268303199	6	8	11
128	1	member	6161209176375	6	8	6
129	19	leader	1087994149008	6	8	8
130	22	leader	1452112654032	6	8	11
131	21	leader	725760319730	6	8	10
132	15	leader	728013673026	6	8	4
133	18	leader	968526523303	6	8	7
134	14	leader	726907378662	6	8	3
135	13	leader	0	6	8	2
136	17	leader	1089653542196	6	8	6
137	16	leader	0	6	8	5
138	20	leader	848339660531	6	8	9
139	12	leader	0	6	8	1
140	2	member	5519860483013	7	9	7
141	11	member	3868768130772	7	9	4
142	51	member	962196	7	9	6
143	7	member	4409509254313	7	9	3
144	8	member	7713426243771	7	9	10
145	4	member	4412933033038	7	9	9
146	5	member	4963994940542	7	9	11
147	55	member	963052	7	9	6
148	46	member	9631473080	7	9	6
149	1	member	7150789122325	7	9	6
150	22	leader	879363856475	7	9	11
151	21	leader	1366472354238	7	9	10
152	15	leader	685756648434	7	9	4
153	18	leader	977345674576	7	9	7
154	14	leader	782401835761	7	9	3
155	13	leader	0	7	9	2
156	17	leader	1268852815931	7	9	6
157	16	leader	0	7	9	5
158	20	leader	782684980184	7	9	9
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
5	107	\\x023f3343a008b850ab917215c282cb1b701245a34f699f4ae1ee1ae2	timelock	{"type": "sig", "keyHash": "bce9c1b7a5a3181fba20e41fa2c06b01d263a036cb6487f9540a3c36"}	\N	\N
6	109	\\x62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a	timelock	{"type": "sig", "keyHash": "5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967"}	\N	\N
7	124	\\x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}]}	\N	\N
8	134	\\x51baa83a03726f491e372a628382d269e837339081470891debdeb39	timelock	{"type": "all", "scripts": [{"type": "sig", "keyHash": "78f83b31297cfbb1f92e8e9446847b899c59d5abe8eed6b282df7d06"}, {"type": "sig", "keyHash": "3178bf14adf78294ac2d03d60b9edfb7323d3d719e98b4b0b3ca34cd"}]}	\N	\N
\.


--
-- Data for Name: slot_leader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slot_leader (id, hash, pool_hash_id, description) FROM stdin;
1	\\x0d5bb306ec74342bd311ad9cfb72ed64a905987ff1b2ee1eb2569f24	\N	Genesis slot leader
2	\\x5368656c6c65792047656e6573697320536c6f744c65616465722048	\N	Shelley Genesis slot leader
37	\\xde8e7c6287707f7afc20a06acf207910ef50c38cb465415dca089960	11	Pool-de8e7c6287707f7a
33	\\x25ae8e4eb68aeac6eedbb6b636ea21657ae9ab34c626a873f5c5d99f	4	Pool-25ae8e4eb68aeac6
6	\\xaff0c09d724bca532b1d6c29be25b70c3f9bae3fa63c8de0887085da	10	Pool-aff0c09d724bca53
14	\\x85ecb98fd631e903ef702c32cb40fc1fc6d24099159ef2ff88b8661d	6	Pool-85ecb98fd631e903
8	\\x21a4eff8963ee2ad29c73a0ad3486af817e5151f69bf17b28328f521	2	Pool-21a4eff8963ee2ad
9	\\x8e2c6c55238a07bd643ffbd82ab0bc52cd93b123fbc18c24642662b9	7	Pool-8e2c6c55238a07bd
5	\\x2411b8087fb88ed526d7d883a5494c6e69de8a03ba8546da4a8a2726	3	Pool-2411b8087fb88ed5
3	\\xa3d013ec54bb60badd7a9535db921a6dae70bcfae4f6b33c9045562d	9	Pool-a3d013ec54bb60ba
4	\\x9a98ac0ef967241df4390d0690d753511d38b09083fb70a92346ab56	8	Pool-9a98ac0ef967241d
7	\\x3a69bbfb9575c711226509c128507f260c0d143c0068872cc537a444	5	Pool-3a69bbfb9575c711
11	\\x1f85cef1f39a0ff5776c151d03f97db41ad9a1179146ba077de31753	1	Pool-1f85cef1f39a0ff5
\.


--
-- Data for Name: stake_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_address (id, hash_raw, view, script_hash) FROM stdin;
9	\\xe00c0bfd7dd11145cf4ac1db0254d5d69f18443fae68d207ca941baba5	stake_test1uqxqhlta6yg5tn62c8dsy4x46603s3pl4e5dyp72jsd6hfgrd5d6g	\N
10	\\xe01bb02bd166f17bacbf938e613477405a2f13fc8e8831c3e5b92c05bb	stake_test1uqdmq273vmchht9ljw8xzdrhgpdz7ylu36yrrsl9hykqtwcjgaqe6	\N
6	\\xe05000a4705d987891898b572570b9f8c1a0a6d76860c5fbf7617be68b	stake_test1upgqpfrstkv83yvf3dtj2u9elrq6pfkhdpsvt7lhv9a7dzcjvjdcq	\N
2	\\xe050f88377d9a7a9091778f80b781699001631aa5b8a5f4a6a8d035a89	stake_test1upg03qmhmxn6jzgh0ruqk7qknyqpvvd2tw997jn235p44zgwe6vjs	\N
11	\\xe058dbdea221038c80d001b78bc26b554e2b00f118aed88cb35e88dace	stake_test1upvdhh4zyypceqxsqxmchsnt248zkq83rzhd3r9nt6yd4ns6rnuw3	\N
7	\\xe081e62a3d998eec5916da9d0187d1f4f7e7bf4d9e0612933d08e83791	stake_test1uzq7v23anx8wckgkm2wsrp737nm7006dncrp9yeapr5r0ygqnarjz	\N
3	\\xe0a163200dabf2157b1b85d1e93d91a9e0a7c962d56971962dd6de6419	stake_test1uzskxgqd40ep27cmshg7j0v348s20jtz645hr93d6m0xgxg46m7vc	\N
8	\\xe0b02dd8073283e0da03b2889cdf77fd5a1eaae2c44270f7ab923585a8	stake_test1uzczmkq8x2p7pksrk2yfehmhl4dpa2hzc3p8paatjg6ct2quzrjvu	\N
4	\\xe0b4b2ea6a5575732bc12efcab4da52fb70c1a2df45e34afd5a266ba7f	stake_test1uz6t96n2246hx27p9m72knd997mscx3d730rft745fnt5lcnrw803	\N
5	\\xe0be4e47684a1df0bd4a1c8908958b4a51cb9fc5d305aa987ed1864584	stake_test1uzlyu3mgfgwlp022rjys39vtffguh8796vz64xr76xrytpqdllknv	\N
1	\\xe0f5f9b1992b6cb0abc50b417e25285798e6e679284e97c4f4234b0d88	stake_test1ur6lnvve9dktp279pdqhuffg27vwdene9p8f0385yd9smzq7ggrmr	\N
15	\\xe067be76c9f8f7aef29b8447cd6c988523d4d74fa6a494f0eeed4f678c	stake_test1upnmuakflrm6au5ms3ru6mycs53af46056jffu8wa48k0rqg0t20w	\N
18	\\xe073dcd33dfb561c8f83319940a35f5c8568c65fd174bec330b8822293	stake_test1upeae5ealdtperurxxv5pg6ltjzk33jl696taseshzpz9yc4nt3dk	\N
16	\\xe0bddcac27dd5b2c8fcfb22183504cbd97b31c4a64ad6adeb8f0a11226	stake_test1uz7aetp8m4djer70kgscx5zvhktmx8z2vjkk4h4c7zs3yfsqj9vst	\N
14	\\xe09c69af92b2fb7e01c513f5b5d5901298bcb4d2383a500b8cb51e676f	stake_test1uzwxntujktahuqw9z06mt4vsz2vtedxj8qa9qzuvk50xwmc29g972	\N
22	\\xe00d259387285d9bee32619e9383628eb842d73cdf5d73400050971217	stake_test1uqxjtyu89pwehm3jvx0f8qmz36uy94eumawhxsqq2zt3y9cs5h9w5	\N
20	\\xe0ef5d754fff74d92b3ba4ef2637b71b641053355841ca815a239c9ac2	stake_test1urh46a20la6dj2em5nhjvdahrdjpq5e4tpqu4q26ywwf4ss8zy77y	\N
17	\\xe0b2e4b79dce6ae7402997cbb24b3d3862e2e27cadaa43dd55dcabf6b2	stake_test1uzewfduaee4wwspfjl9myjea8p3w9cnu4k4y8h24mj4ldvsfm5uz3	\N
12	\\xe0fbe70971086288710d1f0bfd5fefa3d267da8460a268cefde768830c	stake_test1ura7wzt3pp3gsugdru9l6hl050fx0k5yvz3x3nhaua5gxrq9v4r7c	\N
13	\\xe0abe4cfbbf993d29197f889076ecaf875ba5d7dd44eb1e3821e3b5f76	stake_test1uz47fnamlxfa9yvhlzyswmk2lp6m5hta638trcuzrca47asmhtgeq	\N
19	\\xe0099309bbeef3ec9842c0bf7dee102002d01c26f0bbe4370d227741d0	stake_test1uqyexzdmame7exzzczlhmmssyqpdq8px7za7gdcdyfm5r5q8554sl	\N
21	\\xe0660d6be2820f53abdc3d7affff1454de26b3695bf8efa47bbe1a8fba	stake_test1upnq66lzsg84827u84a0llc52n0zdvmft0uwlfrmhcdglwsvnp726	\N
47	\\xe01bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	stake_test1uqdlrcfc7tuta27fv0y5es5wark5kst5gcql9md02zepalg9yxxuz	\N
49	\\xe09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j	\N
50	\\xe07d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	stake_test1up73dx2qeg7gv59739gpmycmxzffyqk3ha2ctmh9ghdgneqmy000q	\N
51	\\xe072263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	stake_test1upezv0agh8cq09rt33ardnh8pdstd3lwpa5s64g2pne0uqgcygw6k	\N
52	\\xe08de2a3276f91632bcce46c53224517c7d7a59d5d1b4f9b1316cb3f5f	stake_test1uzx79ge8d7gkx27vu3k9xgj9zlra0fvat5d5lxcnzm9n7hc8yk6td	\N
53	\\xe04f4ce0a7c4276472146ba263f154dfec8e1f7a8dd8ed51fcb7dac7d4	stake_test1up85ec98csnkgus5dw3x8u25mlkgu8m63hvw650ukldv04q6rf54k	\N
54	\\xe00ff319232aa31519000eb59ccee17784fa81e5c09124eb8c9db8a7a4	stake_test1uq8lxxfr92332xgqp66eenhpw7z04q09czgjf6uvnku20fq023mfy	\N
55	\\xe0ce5459a1b4aaa9389186f829a4d8937b07c85aa9978b2cb03d847bc5	stake_test1ur89gkdpkj42jwy3smuznfxcjdas0jz64xtckt9s8kz8h3gj4h8zv	\N
62	\\xe03f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	stake_test1uqlkq53p6t9rl6u62frka2xacqyc556nyhxnglkw6xaevnssu8wjh	\N
46	\\xe0f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	stake_test1urc4mvzl2cp4gedl3yq2px7659krmzuzgnl2dpjjgsydmqqxgamj7	\N
48	\\xe0e0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	\N
45	\\xe0a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	\N
\.


--
-- Data for Name: stake_deregistration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_deregistration (id, addr_id, cert_index, epoch_no, tx_id, redeemer_id) FROM stdin;
1	46	0	5	143	\N
\.


--
-- Data for Name: stake_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_registration (id, addr_id, cert_index, epoch_no, tx_id) FROM stdin;
1	9	0	0	34
2	10	2	0	34
3	6	4	0	34
4	2	6	0	34
5	11	8	0	34
6	7	10	0	34
7	3	12	0	34
8	8	14	0	34
9	4	16	0	34
10	5	18	0	34
11	1	20	0	34
12	15	0	0	36
13	18	0	0	41
14	16	0	0	46
15	14	0	0	51
16	22	0	0	56
17	20	0	0	61
18	17	0	0	66
19	12	0	0	71
20	13	0	0	78
21	19	0	0	85
22	21	0	1	92
23	51	0	4	131
24	52	2	4	131
25	53	4	4	131
26	54	6	4	131
27	55	8	4	131
28	46	0	5	142
29	46	0	5	151
30	48	0	9	254
31	45	0	9	257
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
1	\\xec619f6bf304692c69922cf63d316f355d3545c7962cb7480cd563e078d2ecc4	1	0	910909092	0	0	0	\N	\N	t	0
2	\\x2f79cdbfc8206888f7c422fbfe2a199535e05e820f773400eb4a1e373891bd3a	1	0	910909092	0	0	0	\N	\N	t	0
3	\\xa815a482fcab51c38dce872fa654fb05568962d05a7a2edee0bda4c88759e194	1	0	910909092	0	0	0	\N	\N	t	0
4	\\xa7b2d21f5138fd92d4c2f98aa7c47971a6322bbb1b05dd5bcff6a7ef47668a1d	1	0	910909092	0	0	0	\N	\N	t	0
5	\\x654f072f1c5c602f1f8f29b8e5c9653f37784916b904a8bd47d67360babf515f	1	0	910909092	0	0	0	\N	\N	t	0
6	\\xa1e0230885f79afc1fba8fe765a227c134e00becb05b2bb7645ffdb9f117108c	1	0	910909092	0	0	0	\N	\N	t	0
7	\\x92408e3fae7991937eeef6af1d04022a9decf18a63e69006478bcda1d3564747	1	0	910909092	0	0	0	\N	\N	t	0
8	\\xfba46c2cebf9eadd5bd700935e00fee94bfb946f3605c866922788d79b567166	1	0	910909092	0	0	0	\N	\N	t	0
9	\\x38fd915ece451308b5d275efc5c6d4e5d693c7f6a49ba2065973b7a1a9485b4f	1	0	910909092	0	0	0	\N	\N	t	0
10	\\xd34a8893cb8becc5d20eb51b0ffc27f3dead7d08ff89f2b2918a55c61cbd3181	1	0	910909092	0	0	0	\N	\N	t	0
11	\\xe4b56bec3cb43f65e7a69a50dbb28952b17f19be9ea8b7c5da6ab6298875bc9b	1	0	910909092	0	0	0	\N	\N	t	0
12	\\x063f36acb66021006ff5a45cc4aa16d43ee181dd05bf04474f9573b4bacca49b	2	0	3681818181818190	0	0	0	\N	\N	t	0
13	\\x0c1f8db1ad8bb294857ed648517fc058de30ee20d40b9b0379e7cf51475562be	2	0	3681818181818181	0	0	0	\N	\N	t	0
14	\\x12a714efc018110f0c8d29c3ae91059bb70faa204097dd8145e6b80e91eba889	2	0	3681818181818181	0	0	0	\N	\N	t	0
15	\\x33979f606f4bd80c24f8a01af98bd7a3a72471d95a18c10ad760ca2f3c38b296	2	0	3681818181818181	0	0	0	\N	\N	t	0
16	\\x3ad63d7eecb01d678e075043350eeb21ff1034640640b24b0a308d95395324be	2	0	3681818181818181	0	0	0	\N	\N	t	0
17	\\x4172b6cf04b3b97cb1d17de7908d0bda78e72416576eb36122d6e4334d031e7b	2	0	3681818181818181	0	0	0	\N	\N	t	0
18	\\x451dee53ed35c43fa8eb297cd7a88da5981036dd15d4e7402246efe91c7330b9	2	0	3681818181818181	0	0	0	\N	\N	t	0
19	\\x577711788eb0904a710ca77ab136a8502fe345ec59d1ef9c04f581a3663b1657	2	0	3681818181818181	0	0	0	\N	\N	t	0
20	\\x625104fe99dc884e1e1e3e24ca2911ec33ac89f7800745d8a356fe5aba998851	2	0	3681818181818181	0	0	0	\N	\N	t	0
21	\\x6608fc57fc6963aaad4f8fb92e3b416afb98c24b5171d92c0f5e9d641a552347	2	0	3681818181818181	0	0	0	\N	\N	t	0
22	\\x69b9764f550f2c0b459139a62c8d5bead670150b045e8b7f26f21b07a8c25b0d	2	0	3681818181818181	0	0	0	\N	\N	t	0
23	\\x789d4bbab9e56ad2f5c68fec7985fc33a10a3820c1b635c08751aef192cdf3c9	2	0	3681818181818181	0	0	0	\N	\N	t	0
24	\\x86365d7f580bf5ba85fedd26682f1fb5bd7443420a51e0d4ecc95cfe71bc4974	2	0	3681818181818181	0	0	0	\N	\N	t	0
25	\\xa0ad62bccbd0941c5b106b9cc71b55ab003222bc7b314abda09667551ff0c775	2	0	3681818181818181	0	0	0	\N	\N	t	0
26	\\xafa855d866d78e9577a6b39196021f939bc1114daa2cd664b1e73e98725def69	2	0	3681818181818190	0	0	0	\N	\N	t	0
27	\\xb4b0b133b70c50017783cc1d0edb32324b3822a6242d29ca21045fb60d8f132d	2	0	3681818181818181	0	0	0	\N	\N	t	0
28	\\xbff7530b7f1fdee712ab84870ce2ae831f783ddcaf155bc6d285fda6533f1c55	2	0	3681818181818181	0	0	0	\N	\N	t	0
29	\\xcdeec5ed89e177fbaa3351ce481b5446a50947a80e2e5e32a6c5bb206a3e452a	2	0	3681818181818181	0	0	0	\N	\N	t	0
30	\\xe1845e0ff4ed476b58844e083e985ceb1ddcd656dae2b39777c2a88077276518	2	0	3681818181818181	0	0	0	\N	\N	t	0
31	\\xe76f4390b2559abff9c66ce94e66ee3faf9fcb979e066759eb7ae95ce879e565	2	0	3681818181818181	0	0	0	\N	\N	t	0
32	\\xf90f94c83d702b084e7d09f924cbb4c979cabe485c90d3ee6546ab2457337a7f	2	0	3681818181818181	0	0	0	\N	\N	t	0
33	\\xfe853cecb6dd5dcfaffed5581901d9a306d623c6f9886f7a97a336b2b4fdb788	2	0	3681818181818181	0	0	0	\N	\N	t	0
34	\\x5368656c6c65792047656e65736973205374616b696e67205478204861736820	2	0	0	0	0	0	\N	\N	t	0
35	\\x760d5abe010aaafb77f407ac5d96cca58476353a5529a88790a30647937ce69c	4	0	3681818181651228	166953	0	263	\N	\N	t	0
36	\\x0e0a48621d8459f065ab845e4709babe790c996bf73b6c4da33c35bbbcc0963f	5	0	3681817681473231	177997	0	339	\N	5000000	t	0
37	\\x184bb6c8b84ef4134ab946cd60cc32f2f3c4c159c2549d655cbfded557fe0cd4	7	0	3681817681293914	179317	0	369	\N	5000000	t	0
38	\\x2e8b2f989e15f28d02dade8bcff3b0ac45d712d69aa6ba5fb60b14e9c0f40d28	8	0	3681818181637632	180549	0	397	\N	5000000	t	0
39	\\x4d87a421cd1bb66f7deb653f8ae6514490446cb3358909ab853e90b21dcc570e	12	0	3681818181443619	194013	0	653	\N	500000	t	0
40	\\x5826cc7ab51f493889cfa0f1e2ef45037af92a140f9005c73986a0a2dc700831	13	0	3681817681126961	166953	0	263	\N	\N	t	0
41	\\x9a1fa6957c36cb54b6971a57f98459f45b8beff050a1e8b01911d464d25eb34e	18	0	3681817080948964	177997	0	339	\N	5000000	t	0
42	\\x5ba148d846e5fec3e292061c566d6f6371dd3cdf4ef8fcc3f5b56dba138fad55	19	0	3681817080769647	179317	0	369	\N	5000000	t	0
43	\\x4f657d38b2377af10d0a5556de4791c074f6b67a1d54fc0132d1af5700420bfe	21	0	3681818181637632	180549	0	397	\N	5000000	t	0
44	\\xbb08bdc81cc840d2c96ee911eeda43f40201e82e1c971fe6f5bcd6df0e204258	24	0	3681818181446391	191241	0	590	\N	500000	t	0
45	\\xf6cb0ca82475f7c84a96918b32bc06978cecbea0044b2769dc38b5f2fc4e2ae2	27	0	3681817080602694	166953	0	263	\N	\N	t	0
46	\\xc7d046374634380db00051879a50fef22f3342aae1a69e7b1b701296c4613929	29	0	3681816880424697	177997	0	339	\N	5000000	t	0
47	\\x40832f1183036e60d69ff2b85a16f2be2d596c95e2e2505baad3a17884de0c05	31	0	3681816880245380	179317	0	369	\N	5000000	t	0
48	\\x6377c9112a27c7e26459637410a25cd2d29cc8244801fa27f8cf09d1ee9a343e	34	0	3681818181637632	180549	0	397	\N	5000000	t	0
49	\\x7d3921f593462c89799c54ca41fc40ffd212d7be45019ad87be60ed09b83b227	37	0	3681818181443619	194013	0	653	\N	500000	t	0
50	\\x167cbb2d4d6ea5babbf363e663f85b37fdbae425b27277f958a9d1102648badd	38	0	3681816880078427	166953	0	263	\N	\N	t	0
51	\\xed2995d817318d5d70feb82d689c4f3e0739c279f6e6bd255c5fe36a66b8e244	39	0	3681816379900430	177997	0	339	\N	5000000	t	0
52	\\x36dbb326a892d0c36f640a23870d7e19685ca78159b4984298870983b2689029	41	0	3681816379721113	179317	0	369	\N	5000000	t	0
53	\\x2157a11de74fc4b2265adeb5bb3b085afab40f83484e55c4aa6d0a41078eb540	42	0	3681818181637632	180549	0	397	\N	5000000	t	0
54	\\x558c647bc411c058c24da99fa9d579c13cd5184eefd2784f0eba2851787021e2	44	0	3681818181443619	194013	0	653	\N	500000	t	0
55	\\x463bd9561557e0bef0e13a58f6a6eabb3706832c39d0c625513b5911706712f4	46	0	3681816379554160	166953	0	263	\N	\N	t	0
56	\\x16acb1a82e860b87e91523f5e90f8370a7a1b4a676b037147dd02794c6dff621	48	0	3681815879376163	177997	0	339	\N	5000000	t	0
57	\\x58c9da91be139d756ab234dc5d65fce6a03475281b8a725ab9dbf1b7e12dda7c	49	0	3681815879196846	179317	0	369	\N	5000000	t	0
58	\\xd9c757a498d8baf42da0df8c57c2917ecf0cf0367582a87c1c093f20c129b609	50	0	3681818181637632	180549	0	397	\N	5000000	t	0
59	\\x026b459482d3d534642b9ddef6fd7ea0b526144bfdd118e1039bb89b7c7bd969	51	0	3681818181443619	194013	0	653	\N	500000	t	0
60	\\x7e3d0da3320927223281138b45f54813c3dec4561222a976c04b7a55ba6920f0	52	0	3681815879029893	166953	0	263	\N	\N	t	0
61	\\xf03c16bc52059d82bcfea8ce1150a66b8ca278e7cc4aa8b222d13447b5ff2483	54	0	3681815378851896	177997	0	339	\N	5000000	t	0
62	\\xca2ff1d10ea30ace8ec75e22c84bad7b99f2a8cb2f76dea20ab409f4e0a7e83d	56	0	3681815378672579	179317	0	369	\N	5000000	t	0
63	\\x3ed39b7137158eac5d02f3760cc28df32b0cb5f1f282b9d01aba767556408b70	58	0	3681818181637632	180549	0	397	\N	5000000	t	0
64	\\x4add6730c3ecdffe896ecf69375ea59b7817ca5c21bcb8fcb722e0b35f0a22da	60	0	3681818181443619	194013	0	653	\N	500000	t	0
65	\\xfa313313a93cff3c14fcee2a8569565337aef1989f4ef654a1c72334f2a6f872	61	0	3681815378505626	166953	0	263	\N	\N	t	0
66	\\x44007c8d00af91a710a6dbe253e3e8b5853b648dcd5f38d20905d224c3918abf	63	0	3681814878327629	177997	0	339	\N	5000000	t	0
67	\\x8dbe53d19c0a0cd524233130491b2c6727d9734c37054f560557bd9aad0d512c	66	0	3681814878148312	179317	0	369	\N	5000000	t	0
68	\\x0c0a28c6553660d686a6c4590a0fbda2d352487521e5a000600addaeac31469d	68	0	3681818181637632	180549	0	397	\N	5000000	t	0
69	\\xcc0ee6e41c7e20b07ec34e62d88d0c92c7eaa5997402ecc3a25e8bf4031c5332	70	0	3681818181443619	194013	0	653	\N	500000	t	0
70	\\x05eaadaae1ea3cf52cc34e5ad87183fd475554049be10a92f393e57769fb5d66	71	0	3681814877981359	166953	0	263	\N	\N	t	0
71	\\x0a91151be85547f65adffe0e70b7c41ae4c7fd5236ce0e7ee8b0645cf3930e6c	73	0	3681814577803362	177997	0	339	\N	5000000	t	0
72	\\x21c005b0744f822d3c0195980e92c1d7660935015aafc54f68ece8ff406b59c0	76	0	3681814577624045	179317	0	369	\N	5000000	t	0
73	\\xb24c9f92dc9cd37306dc49c83703e051bce31e449d92680cd3f5302f10bd839f	79	0	3681818181637632	180549	0	397	\N	5000000	t	0
74	\\x599f1eee0c0d4b520e3c34aa7e0e4b9575e475b0765936aa089146e235eb2549	83	0	3681818181446391	191241	0	590	\N	500000	t	0
75	\\x56303623c2e3053fe72a543c0f59ad511b9a5e9ac861bc88f4ed62636a7984a2	84	0	3681818181265842	180549	0	397	\N	5000000	t	0
76	\\xd76b07ed558fa67c99d372307c73efb7e5aa88ef0b71e49ced82c0d70d888c71	87	0	3681814577439800	184245	0	439	\N	500000	t	0
77	\\x3233114686ddbb9a1d8f8ddb2c92f782138bf29a3b05c12f25a9a92288e854a5	89	0	3681814577272847	166953	0	263	\N	\N	t	0
78	\\x82659feccac42a9c18db91d4f6ea1750ec61d7ab0cd0d1dc7f57344e73732e6d	91	0	3681814277094850	177997	0	339	\N	5000000	t	0
79	\\x9bb905781c2865e4fc1dd376a734f2355191185eb9d0507157cc883d8c4f3d97	93	0	3681814276915533	179317	0	369	\N	5000000	t	0
80	\\x03a070d4e72ea74cae21a6fa58b38b39eceef4a402d42df07e37938777053d27	94	0	3681818181637632	180549	0	397	\N	5000000	t	0
81	\\x1f945f18ec98e021d61bb6f6e2e2809c467b487ed16e7108627389016d7f77c6	95	0	3681818181446391	191241	0	590	\N	500000	t	0
82	\\x2e807230fbe7a7a8a27f2297f7dbedf8b81186db375231b73b18930242a8286d	97	0	3681818181265842	180549	0	397	\N	5000000	t	0
83	\\xd86887eaf8623fcf21a37dd5372ee2ae6d6144c4ea9cea3cf93b571c5b76700c	99	0	3681814276731288	184245	0	439	\N	500000	t	0
84	\\x695c35c76b5afd0ccafd45ddaec5a27030c82cd610dfd8e9c8ebbea257d210f7	101	0	3681814276564335	166953	0	263	\N	\N	t	0
85	\\xceabac41e49d8c637344a859151e63355ce38654a820f185c30275751c62d37f	102	0	3681813776386338	177997	0	339	\N	5000000	t	0
86	\\xb74a6f3e485409837bd899964ce3e50f12d0f52cd331858d1ebc49a60487287c	103	0	3681813776207021	179317	0	369	\N	5000000	t	0
87	\\x101b5cb153de2e055f7365223f086ebec12d84aba280e4f7fb145dba0c094b11	105	0	3681818181637632	180549	0	397	\N	5000000	t	0
88	\\xcaa4b38729979404ed29106e1a4baa896f43e1c9e2b7f30dd637a692054a4bcd	108	0	3681818181443575	194057	0	654	\N	500000	t	0
89	\\xa2e271df342ebfecaf925d9b09ac1a58ebd1abefae11f8bc85c08de561da237b	109	0	3681818181263026	180549	0	397	\N	5000000	t	0
90	\\xbcdd856e44c105010f379d3d2b7c955532208827141fa8f10a8d58a962c32ca5	110	0	3681813776022776	184245	0	439	\N	500000	t	0
91	\\xa7eb063b361981b6a426e09fbae90c34b7b9b6fe92f272165b8603b46197146e	112	0	3681813775855823	166953	0	263	\N	\N	t	0
92	\\x526b7a2fba4b43e671db66e1967feee95bc7b871db5e489a1ade0405f5a64112	114	0	3681813275677826	177997	0	339	\N	5000000	t	0
93	\\xfdc3e5a1940ab19b30d23b992b898425b47c96dc8187d2c88a71b91521b47390	115	0	3681813275498509	179317	0	369	\N	5000000	t	0
94	\\xd5dfb4e8fb216aec80c6a19b02800f3053c29205e3046d2791acefc1d8d2133a	118	0	3681818181637641	180549	0	397	\N	5000000	t	0
95	\\x92d8ba3b673e6668d615710f97f5975e46ac2dd999efbb53041b90a289b42eb6	121	0	3681818181443584	194057	0	654	\N	500000	t	0
96	\\xe522530e8a8e14c99c258383c72714a25708039a4c33d7ffb9ae35ea7c45f1ef	122	0	3681818181263035	180549	0	397	\N	5000000	t	0
97	\\x435fe15850898bedca2f5ee5197a94e358224b400676b9fc769656910dc95f11	123	0	3681813275314264	184245	0	439	\N	500000	t	0
98	\\x7a1a21abe5d0dfeb9e000c5452f6d81e5144ca7ab5ce03118f8532e567ed06e4	124	0	3681818181650832	167349	0	272	\N	\N	t	0
99	\\x5bba8fcdeb8dd4f25d850626baa57e4d2db2f5b2d95347c22cf1314f63e6665d	126	0	99828910	171090	0	350	\N	\N	t	14
100	\\x8ca6ad3299ff56595fec1836d531814a752c37f1e85059633c19c6b07d53f610	128	0	3681818081484759	166073	0	243	\N	\N	t	0
101	\\x283f88bd5826d14dba86437e72db8ddcb8929015492759b3106e7ba92ad54121	130	0	3681817981314374	170385	0	341	\N	\N	t	0
102	\\x6694bc9e028a3bf51481f2e369defaee35116b301b9851aa8bb6fc14ced6e5fc	131	0	3681817881146585	167789	0	282	\N	\N	t	0
103	\\x037eb20e6adce6c6bfc719ba6cc628fced479dd099904b05cd38b7e862196b8e	132	0	3681817780979940	166645	0	256	\N	\N	t	0
104	\\x2718c8d6fbbcb58b9ff61115a418c6aa17d5ea88cc0bcaad17d4369700f28194	133	0	3681817680717067	262873	0	2443	\N	\N	t	0
105	\\x348c241ec925433dfd8d242e39a15b1384b4d70c0ebf9987c6c43889bd405f1d	134	0	3681817580550950	166117	0	244	\N	\N	t	0
106	\\x905dc3d992327b3cc02370601624edf4606aee2f59ec649591ef7c197e6844cb	135	0	3681817580223603	327347	0	2613	\N	\N	t	2197
107	\\xb1acbfc1cf3d7c8c37e7d3634bcfa16bab31d9dfdce66b8609ce6aac19aa224c	136	0	3681818181642252	175929	0	467	\N	\N	t	0
108	\\x2eacfcf5dae443461078bb5792b2cf5cbd0cd4906c97508eaf8a52b81f8f2af8	137	0	3681813275134639	179625	0	551	\N	\N	t	0
109	\\x425b837b8d9aef20417c26a9e6a130850db68bbca488c6bcaa4a88f79cc21605	138	0	4999999777299	222701	0	1530	\N	\N	t	0
110	\\xcd3371989f1ae560124dd46142359620e77e0dedea3b42260f61c337c24395e2	139	0	4999989592482	184817	0	669	\N	\N	t	0
111	\\x804e2fd2e83a9af2964836eb074de6ddae30341c863207fdee358e64c7352105	411	0	4999979388217	204265	0	1005	\N	5553	t	0
112	\\xfaabdc76797cadd0cb07221a1e6a67439286e53baefcdf57ec301753b538673e	417	0	4999979214532	173685	0	411	\N	5598	t	0
113	\\x45141d4cb54ed2a70b4b303df1ed012e94b16eea8da6b6c758e05c3bf783b41f	421	0	4999977044279	170253	0	333	\N	5658	t	0
114	\\x75398df5b393880dd81cc64edbc0cc7f8a45d1601bb221fb47b81193bc280762	425	0	4999974870770	173509	0	306	\N	5692	t	0
115	\\x2708af18b5101bb178cef680fa1ceb0f6ff1b5dd9a1e9af3d1162d513278fbf4	429	0	1826667	173333	0	403	\N	5736	t	0
116	\\xece8fa720177061bfa0b9f348f2d57f61a9738412da60fe8604979f08bb8a374	433	0	4999974677769	193001	0	749	\N	5820	t	0
117	\\x91216fff959322febbbec1b1dacd485430e04940eba4a379b04a44c784985071	437	0	4999972484768	193001	0	749	\N	5835	t	0
118	\\x5bfba502d619b8e78a80141e0effa5b825c0e3440af66583f67a92be81bd883f	442	0	3825083	174917	0	338	\N	5894	t	0
119	\\x67897786a443a829a9dec28e84f326807cbb5912ecb7bf1c6f415279e39b0a95	446	0	4999970291767	193001	0	749	\N	5939	t	0
120	\\xad411377137c17a8e8322e5b543e1646b58f558939dcbe676cfb8104537f6f04	450	0	1826667	173333	0	302	\N	5999	t	0
121	\\x4bdb4a9df9d5979a6263c9429a73725e001882da6f5323d927680f173a9f3c71	454	0	4999969923849	194585	0	785	\N	6037	t	0
122	\\xaa5d404a638e36c072c382ae9393741149448c0ba36837ca1d0be4d1dbbffa1a	458	0	1824819	175181	0	344	\N	6062	t	0
123	\\x67a7d0b7cc434c6974e1ad8db2614399251f42780e4b228255972020035274de	462	0	1651486	173333	0	302	\N	6076	t	0
124	\\x06505aaeaf8ea39c9a376bb34bc31720d228007ab964e1e1042a56e803a35dec	466	0	4999969369574	205761	0	1140	\N	6124	t	0
125	\\x5550a49f533b3947c04af9cf782c5ccb826eed85a9049c375ec299f8860b7d96	471	0	4999969189157	180417	0	564	\N	6172	t	0
126	\\x7a7a4a01a9c228061e8a125bc45661b8fc9da359f0a4a8965bb8005d6b924c6f	475	0	4999958999456	189701	0	775	\N	6190	t	0
127	\\x7817cc3bb38f62a0d516a2702a3729bb0976be29e1bc27a1d1300c92295d962d	479	0	23633050	192033	0	828	\N	6223	t	0
128	\\x4becd5f067504cdf492c974ed14d3b1161941b29f47b91800fc45567e07eea03	483	0	23443921	189129	0	762	\N	6282	t	0
129	\\x603eb4787f147e5eadc1aa0eca3e71d46eda9a5dc81c2829529fcee24919b2f2	488	0	4999972263972	179405	0	541	\N	6319	t	0
130	\\x01cbb81067aecc0a38611f28efdd6c744a090729768df07316a1ac267b897493	493	0	4999972095567	168405	0	291	\N	6347	t	0
131	\\x65e5ab579c82ffc9ba98ad69ec103c61e8758e254d2c25a48b3a1ca583762b97	497	0	999693655	306345	0	3430	\N	6389	t	0
132	\\x9d40a045d15bf0a6394e2941ec4d3605e73a054e507612e2c355593f88432fdb	501	0	999451198	242457	0	1978	\N	6434	t	0
133	\\xf950d08b74149ba4141f81ecac9efd6ee1da13d263ece458e58b4e0a5cd55051	505	0	499402614	201757	0	1049	\N	6477	t	0
134	\\x5bda2cc0f126f187aa8e1d725d7eb7072c41cd5205d778c6188ec10f4da1740a	510	0	4998971911542	184025	0	646	\N	6514	t	0
135	\\x98b48cc28eb0c147da3ae8690c67f2d2468c089b4843a26ca60d1481594a2438	514	0	2820771	179229	0	537	\N	6554	t	0
136	\\x4c27758bb63f25c7e89667b2217818164a1e1b963a172f0a428b2d4627169a0b	518	0	4998971552996	179317	0	539	\N	6591	t	0
137	\\x8f1857cc5004843b52e42a641952abedeabe73954a375a53a15e3f5a0904bf17	522	0	2826843	173157	0	399	\N	6632	t	0
138	\\x39a72482afde89e669e8f40a35ee1a48d6ef6a0fec7028bf5f1681183223cdc7	526	0	4998968384591	168405	0	291	\N	6684	t	0
139	\\x1ef3a5e4ca4b31f92b860c48616a5a84cde7d39277c03520c78ce774d7d82325	527	0	0	5000000	0	2404	\N	\N	f	1893
140	\\xc8d786f9d9878fdcb988a0e50114e015b1a44288d8cc8112be12d5d93c4c18f4	528	0	4998966041445	169989	0	327	\N	6724	t	0
141	\\x4407010e88babb44f593b7afec649f6e5245e9d2516b61b0c8835560705b4eb9	529	0	4998965871456	169989	0	327	\N	6750	t	0
142	\\xc08d6f487f92ce2145cca11e07ba4df05ff50057ab416c680e53418ad251b4ae	530	0	4152938	177073	0	488	\N	6759	t	0
143	\\x7620c44fd10dc2bb7069c6029679de6272d8ba10dfda259bf4a21a31571dbee9	531	0	4998961369872	171573	0	363	\N	6769	t	0
144	\\x30b3fbf961dde9920cb47188a89dfaa1dcbf0df0cef69daf905e424e73bb6533	532	0	4998964352645	170165	0	331	\N	6780	t	0
145	\\x191fcd36be2e40ab70132badadc4e378e6e3f54362dccd638c3fa3c213370bef	532	1	4998964182480	170165	0	331	\N	6780	t	0
146	\\xeaf2a1c0836eeff38e40ec66111d259a72f45b98cb1ce55e972302ed683bcdd5	539	0	1999585298541	170253	0	333	\N	6834	t	0
147	\\x2e51883aa01c7dec24e8f8a030e9c7a293303e394f7ba9cc3a5204213656c72f	541	0	1999583812478	516313	0	8198	\N	6862	t	0
148	\\x44534d5200e183b3cc3fbe1bab373dec0044eec9a53ce011ed370d03c2bc4377	544	0	179474447	525553	0	8408	\N	6887	t	0
149	\\xe2f9134bcdc0451ec4637b4fbcf0d0f0a2d50d0b73e9712276a93076b328418d	549	0	33227916801	168449	0	292	\N	6954	t	0
150	\\xcc1446eb3193ca8580facd318599de1cf43d2e724ea954513f0fc7b44649aab3	553	0	33227917197	168053	0	283	\N	6985	t	0
151	\\x47f627171f15571d725ff443b07aa1f525189ca3aba2afed896354e05cf2b87f	554	0	2999378539297	174389	0	427	\N	6992	t	0
152	\\x32d4d10846b76f453d8ce1f88f1c1281aa75aed40b1cc99d861a871e62538451	685	0	33227916801	168449	0	292	\N	8447	t	0
153	\\x95ced451023cb5e697bc5abac13bb1cb42ff5679299a7fa2667d34e0d59b9ae3	685	1	178331771	168229	0	287	\N	8447	t	0
154	\\x3fd83096cdb9f3d1d9f6d4721096d8340a2a478d5e063e08752409f47fa64071	685	2	33227916801	168449	0	292	\N	8447	t	0
155	\\x245e0f710281a2165ee7047f06e1bf98f9a846b28996a382b1a09bbbe91db273	685	3	33227916801	168449	0	292	\N	8447	t	0
156	\\x34d9c45a202a806925412909068816f002f77448dd776e19067ab3176acfc863	685	4	33227916801	168449	0	292	\N	8447	t	0
157	\\xbafd050e3e3e799129cddd3260276a29608c6564a40a6f5af1b515aa0b90f4b9	685	5	33227916801	168449	0	292	\N	8447	t	0
158	\\x5c0548e575e8d0ac3e759859c31a4c80e135c4d81945e99d0f7a80eecd59b563	685	6	33232915217	170033	0	328	\N	8447	t	0
159	\\xc223827f7471c2f2235ad6b4dc27f610de90a5595f41576833a62fcba1ea0550	685	7	33227916801	168449	0	292	\N	8447	t	0
160	\\x60cccb9b3ab5b3cc0c91e00f8e416f4768f96cea4b76161064b8eacc67153895	685	8	33227916801	168449	0	292	\N	8447	t	0
161	\\x8f756adf64b320ffc50cf3c393e2517fdc0c6a87297542c75e48119e6555913a	685	9	33227916801	168449	0	292	\N	8447	t	0
162	\\x5ec99b4178ecdb4e911644ae7dcaeb450f774db7393111a8d7ca0eeaf0a29e9f	685	10	33227916801	168449	0	292	\N	8447	t	0
163	\\x476769f272186f5fab87064f2f1e3cda0336371ad22c567d180a013c954bcbda	685	11	33227916801	168449	0	292	\N	8447	t	0
164	\\x6a2fc8e65bbc0c7761a926a0767966e5fb35fdc2cbb721c4a1fcd262ec9afe02	685	12	33227916801	168449	0	292	\N	8447	t	0
165	\\xe534207f9576552f71d559d6d756e7c8f0406d02514a74c28bac4649be8069e9	685	13	33232915217	170033	0	328	\N	8447	t	0
166	\\xb2691e93e362c85b1eae8232979dcf8b3cb23856ebe2e598f119439274fdd1ac	685	14	33227916801	168449	0	292	\N	8447	t	0
167	\\x1ce19213b2b07ed01ec5ece6e14ee75d4459758c3cdb37585f389a7d0123fa3e	685	15	33227916801	168449	0	292	\N	8447	t	0
168	\\x40cf6ba2128b2e98c8e64cce534f744af6639b415891799e824feec0b3829142	685	16	33227916801	168449	0	292	\N	8447	t	0
169	\\xade082a001f96efccb3907cf36bd536d498a78cdaedfc0e4a41cb223a44f2d90	685	17	33222748396	168405	0	291	\N	8447	t	0
170	\\xbcf00282cacae1549585964c341387fb0faecedd8d868f2ae536a1d580aef2c7	685	18	9831771	168229	0	287	\N	8447	t	0
171	\\xf4769d8f175f03e39ced78107d23b53fd22ff09924c06be7c001ed763641364e	685	19	33222748396	168405	0	291	\N	8447	t	0
172	\\x4109b14144e4045c6c5115a2ee15237583a2d35ddc61bd3f6f86480a6ce482fe	685	20	33227916801	168449	0	292	\N	8447	t	0
173	\\x59415f848d671a7d34cd673370bba2017584b1e8182b0a5a9723edead9a3da17	685	21	33227916801	168449	0	292	\N	8447	t	0
174	\\xc9a470db32dc1fac146eab341e1ff5dcad8ca870fa373fe22d3be5bcccc485fc	685	22	33232915217	170033	0	328	\N	8447	t	0
175	\\x4a8813b205900fe892a9c75cfcdfc816ed07d93e63046627452a541666895113	685	23	2999378370892	168405	0	291	\N	8447	t	0
176	\\xc063f331621bf04b9a3144ace1199cbe7cc3d214a1f3a55e74f5ca3975dd9e67	685	24	33222748396	168405	0	291	\N	8447	t	0
177	\\x739268df0ac66cb44724705f5f97c51d98b890770925dc9ddbaea4a74c444c01	685	25	33232915217	170033	0	328	\N	8447	t	0
178	\\xe611bfea0fcd3a5500f1bea57d90ba98af2a62a34cde9ac4ce9949b7e09f52b9	685	26	33222748396	168405	0	291	\N	8447	t	0
179	\\x56ab41639a98e3e40a1f26f6613d87c7424f5653a2c130a132b7cafbc215f3d8	685	27	33227916801	168449	0	292	\N	8447	t	0
180	\\x2d8f705bacd466c1442333d26e878a7f4452478d45dafb8ae73b7ebb3c0d05db	685	28	33217579991	168405	0	291	\N	8447	t	0
181	\\x473231094e14768c89d4edaaa05de6ce413ea509607248bfdc9cb69723a7f880	685	29	33232915217	170033	0	328	\N	8447	t	0
182	\\xd3a5a2c16da7992c6bd9d2f61bc559a13a07c7914302ec6bca5084d5f0e13af0	685	30	33217579991	168405	0	291	\N	8447	t	0
183	\\x130f416c52468148890b74592ee7b9c702dba83ce3fcb9579e3a2fb5990194dd	685	31	33224748792	168405	0	291	\N	8447	t	0
184	\\x4802502af57a54daa5e7e6f42c95cf5c72648058054d7fb1e3002a66765f6ed6	685	32	33232915217	170033	0	328	\N	8447	t	0
185	\\xb0e72915dc55e4c1f7a77bd54ea51c618e49aa43c5da3a8c48976c5ffec02eea	685	33	9830187	169813	0	323	\N	8447	t	0
186	\\x63ca2c147bbcb5c8faff99d230b18c35f5d13d1d80905d6e5b07cc3b095d52f3	685	34	33227916801	168449	0	292	\N	8447	t	0
187	\\x6bfe84c41b7c9d0946677d9834a95981d98f713be61fc4d2230fbae73ac8c207	685	35	33222748396	168405	0	291	\N	8447	t	0
188	\\xe6fdf298e3ee20cbad03b08963ae3dccd039086ec15e0ae5131308fb12ba7b0c	685	36	33227916801	168449	0	292	\N	8447	t	0
189	\\x35d37e4e55438b62fb167fef4bea396f3fe98d93e8cf976f281f2cfa1f686e1f	685	37	33227916801	168449	0	292	\N	8447	t	0
190	\\x8029490fb2e857c5a32c584fc76a75270c547dd19aa1dc5a4c3ff1659bbcca4b	685	38	33232915217	170033	0	328	\N	8447	t	0
191	\\x3f9ec81a4c300e6acf99407a284065056014ad06a3d5eca356a80e23f94b6db9	685	39	33222748396	168405	0	291	\N	8447	t	0
192	\\xd4438b9cc6eae8edd546626940a14cffd103d1b20e24546f96118bb9277a6d32	685	40	33217579991	168405	0	291	\N	8447	t	0
193	\\x9e67c0aec90a919e1b3131aab1d8b253d7b888369d049b560c447abddc95a645	685	41	33227916801	168449	0	292	\N	8447	t	0
194	\\x89fa6b0f8a66e3e1bbec6ea29bd29ad8b8853c874de005019134d003378ca8c6	685	42	33227916801	168449	0	292	\N	8447	t	0
195	\\xca7c0684c62bd54d3924f216c3da8cf670fe53c78aa5b1575cf5d190ee2271f2	685	43	33222748396	168405	0	291	\N	8447	t	0
196	\\xb701d8abab88704d37d13bfa58f537302aeaaae5ea72c52e6532d3bdf2adcd8b	685	44	33217410002	169989	0	327	\N	8447	t	0
197	\\x47d78524208a27c928d3f7bdc485d6ce9de1fa344d6fd22c462e0cea6f0c3d21	685	45	9830187	169813	0	323	\N	8447	t	0
198	\\x9165bb5096af37c70759d04e3ad690d8c5ebd1e73cbada316bb42615e0dddab6	685	46	33212241597	168405	0	291	\N	8447	t	0
199	\\x33033ce68b9eec3356d4c7963e333268bae70bfd83250caf2d0061b7098987ad	685	47	33227746812	168405	0	291	\N	8447	t	0
200	\\xb93db120c9ffd640d5bac0712fff76a9a8fbcb51f1cfc9c77015e162c4fcab9e	685	48	9660374	169813	0	323	\N	8447	t	0
201	\\x4865c8336091ec25b5b2314080a33edd46e6961c15ef6434af34887de50d247c	685	49	33222748396	168405	0	291	\N	8447	t	0
202	\\x60dd85c683940b5d1139e5d0def9149c0da4182ea900e83d47246d541234a186	685	50	33212411586	168405	0	291	\N	8447	t	0
203	\\xa6f5a755da9b4402743c42039205fbcabc5a4f8d772f52ec79f7038ac3288e96	685	51	9660374	169813	0	323	\N	8447	t	0
204	\\x37329a0027064e029d88262be6420126544406f4c64cd1d48942afe631b16417	685	52	33227916801	168449	0	292	\N	8447	t	0
205	\\x596821ff9cfdf36d63600964f05456a868ed278537eab246bc8b7d8eb936b91e	685	53	33227916801	168449	0	292	\N	8447	t	0
206	\\x9eb77a6c2cd594a2418ff6c8e8aa7bce3a9e46294d90a9f9c54a65eba4e5381b	685	54	33227916801	168449	0	292	\N	8447	t	0
207	\\xc544e007754a94ed0f532d9eea607be7d755cea28dd7cea5a3263d0eb08bc30a	686	0	33232915217	170033	0	328	\N	8447	t	0
208	\\x99d50955ba625000338d95a74ab17bc164d405e47384d0e7907ce76d4179f326	686	1	9830187	169813	0	323	\N	8447	t	0
209	\\x7e3ff3d839711a0f5ed81fb351a71c67d9b4242f630c0cedbb07f1e8f5ec7071	686	2	9660374	169813	0	323	\N	8447	t	0
210	\\x82490f44730772792f4595a45fb67fec64b5fd20a89da39af96b3f50d7c1adc2	686	3	9830187	169813	0	323	\N	8447	t	0
211	\\xc54fadb06a7de6eb37a93413a10e04a3447a05194bdc2b075e7ac5f58be09737	686	4	33222748396	168405	0	291	\N	8447	t	0
212	\\x2e31f39fb95707ba175519863cc5ac932456323d57b23399d5b5c981bb9e6d29	686	5	33227916801	168449	0	292	\N	8447	t	0
213	\\x8b92cfe244fcfdbd8c0c57d6ff220b0cd0b60d24b605bd5ca0b7715e25fd2758	686	6	9490561	169813	0	323	\N	8447	t	0
214	\\x903bd812b006638e34f3c5787ca4f184b34e49208a629139e6f9fa56cf2b6efc	686	7	9830187	169813	0	323	\N	8447	t	0
215	\\xd38345fe65b31937332245be42ac5dbf4afd75720a0a3bcb383c060a5e609d4d	686	8	33227746812	168405	0	291	\N	8447	t	0
216	\\xf4a9377c1a3d9101c129aaf0400fe52ac9d0e8fb8b9eee9f2d03bd8c316fb062	686	9	33227916801	168449	0	292	\N	8447	t	0
217	\\xd8a9337ddfbf2cc27b4bd031a384f29e3bde14c60128ab4b5b249cd28dccb3ea	686	10	33227746812	169989	0	327	\N	8447	t	0
218	\\xa155b20ceb36c4824be2ba0223e456b9bb92ed1bcd72e8781d2bd841ad727dbf	686	11	9660374	169813	0	323	\N	8447	t	0
219	\\x3cf9323f8d1880655dc045a02ecde8b6c17e9085119b7e27998b7a5cf49b6e1a	686	12	33227746812	168405	0	291	\N	8447	t	0
220	\\xeafe450eeb314f2868698e32c4a1f3f9be9342b1ef58ff92e4e54a26d2371548	686	13	33222748396	168405	0	291	\N	8447	t	0
221	\\x68cfea4b4e1f602df082aac3f6d0b500e8c628a23b88e7df10012a54596a375b	686	14	9830187	169813	0	323	\N	8447	t	0
222	\\x9b2911b694586635c70cc6f3a83e59e0bbc7e21739bc73a545044ee1d5de444b	686	15	33222748396	168405	0	291	\N	8447	t	0
223	\\x4c9f4597fb3bc036957c1d2b431fcfa42f63fa0ccad50a791771661ab253027e	686	16	33227576823	169989	0	327	\N	8447	t	0
224	\\xd7a9758545b39773de33d7f02e1ddd1ba08a4ee0a7e9fda5bde6c94c9491992d	686	17	33222748396	168405	0	291	\N	8455	t	0
225	\\xd4a0d42b1b82572310b99a2e15a39fa04cdcfb2593aee026a32b5bc8dadb164c	686	18	33227916801	168449	0	292	\N	8455	t	0
226	\\xd9339b28cba628e6e1eb41fc35228b9f99e3e2b772a78faaf9aa8483b917a3fb	686	19	9830187	169813	0	323	\N	8455	t	0
227	\\xca9f67804504354048f33346ca9587c12dcb19293bc4c428fdd9659c0106ac3f	686	20	33222748396	168405	0	291	\N	8455	t	0
228	\\xc3a9e3b5d7ba723424866ba66925890f6eefde2d6aec9bab874ee222d5b3bfe9	686	21	33218548157	169989	0	327	\N	8455	t	0
229	\\xfbbbaf716bff98df41d6fc590b6708213680233ddb072f63f076b62ec74ca364	686	22	33227746812	169989	0	327	\N	8455	t	0
230	\\xff1deec274f2d700df995c19ec61860dd0b4045eb1bba9724a5eed69189fd448	686	23	33227746812	168405	0	291	\N	8455	t	0
231	\\xe4b31f401307b0427b9fd99e986f4a785052d8bb75e7cd687e524cc78d0aaa61	686	24	33217579991	168405	0	291	\N	8455	t	0
232	\\xd5ad659c9c5b142343a64a404675605771d2236b5fdb007e099dda9ae70e8388	686	25	33227916801	168449	0	292	\N	8455	t	0
233	\\x67342adab6e9fdbda28449a36694cc15da55a7d8f830d4961b32925023411051	686	26	33218378168	169989	0	327	\N	8455	t	0
234	\\xa7255dcb79d5124ddaaba8b4f941dc98e1ff4494383dedebab9795b10fa07065	686	27	9830187	169813	0	323	\N	8455	t	0
235	\\xd9bf258cfefdcc09774090d16386abb88709233ebb2a4a17c16a603806066618	686	28	33222578407	168405	0	291	\N	8455	t	0
236	\\x1640a94abd6daa8e5802b71d8aff77fcc5351a28161d969b0ab1da0812cb3179	686	29	33227916801	168449	0	292	\N	8455	t	0
237	\\x8f3fdc15c1b5dee11119bf4c07a430b72aa97c4a67f170a1dd268fa92be35a18	686	30	173163542	168229	0	287	\N	8455	t	0
238	\\x010165cc7d0e54974461ef2c41e40660c439d70998b62d66ca3541824788d482	686	31	33227916801	168449	0	292	\N	8455	t	0
239	\\x5d86ae597a2ec47febee472f7510be1ec6b6fc49e314a5c7e8c3e81d866f05a2	686	32	33222578407	168405	0	291	\N	8455	t	0
240	\\xf05b7e65b6c5252982da5cc007a36b3166df855881af9aae0dad5ec83993e6b6	686	33	33227916801	168449	0	292	\N	8455	t	0
241	\\x76f484eb7e46ad75b36635df43414a5e3c1686e46ee7b49a026b7a6f9b4f28de	686	34	9830187	169813	0	323	\N	8455	t	0
242	\\xf43fce19514b62416d24e1aee45740a3e29031d1fa52402ee4d9eb17b3634cb5	686	35	9830187	169813	0	323	\N	8455	t	0
243	\\x97ac1a28046fdda0f48b50d65a5bc0c33a7020f21e44a628869f6f5e2dce74c8	686	36	33227746812	168405	0	291	\N	8455	t	0
244	\\x954bd0bdbb4b5fa210bd6c7b9a657354fcc532e0a180136c79f70b703f2e666f	686	37	33227746812	168405	0	291	\N	8455	t	0
245	\\x5b4758e34876af9141686b7971e84fbdeb2323b2063b13ca0a2a6dde47bbe88b	686	38	33227916801	168449	0	292	\N	8455	t	0
246	\\xcd1096cfb8daecf13e2bf650b0ba0d3e725ba918313b4a18f2afdcee772ed430	686	39	33222578407	168405	0	291	\N	8455	t	0
247	\\xed8ef7b81b07848ed875a379f46690dc9364bdbfd7ecb9a1aaf9d230a314faf0	686	40	33232745228	169989	0	327	\N	8455	t	0
248	\\xf2bcfc3606f54b08d0cea2685527b267df9ba03bec3b7fffeea44efa59d80742	686	41	9660374	169813	0	323	\N	8455	t	0
249	\\xb57cd363006cd4b4bd4967b46d27efd4d794d60511cbf9fedbe4eecc06f7fa88	686	42	9830187	169813	0	323	\N	8455	t	0
250	\\x84eeb9bceaea5e50a2dcba24de2d39582e8127cf35c2bce40f535fa7985a8728	686	43	9830187	169813	0	323	\N	8455	t	0
251	\\xe4c570baf712ddc17d9a9f7f8793df6db02e5392f182cd88c089f3eb45495e8b	686	44	33222408418	169989	0	327	\N	8455	t	0
252	\\x271ba1403c4ca173ddfd3df59de5a38932639f28a546689ba07e306d77bac2c4	859	0	48578081067	174741	0	435	\N	10441	t	0
253	\\x8477e6ab586ed844bb7face25ea70e13a93832aff1fb18b70fe48004c98d1f56	869	0	4999999820111	179889	0	552	\N	10513	t	0
254	\\x1647bf63fc2da41698cb1faa4224998f00e1d600f6d7efe8220261935e57c5f6	874	0	4999999648538	171573	0	363	\N	10576	t	0
255	\\x3936b64dd654f8273115665e493677e5dbd7b2946acf3d60a282e856e0438b1e	879	0	4999999471201	177337	0	494	\N	10626	t	0
256	\\x4a8b5f38e6adb9e60c023e8e5d9e9e24d99566dc7d75191b29e4421b93609205	883	0	9816723	183277	0	629	\N	10647	t	0
257	\\x4746efd02f8f90754d6d4fd786e412b1dc95836d869523c47490419ad324cb02	887	0	6643170	173553	0	408	\N	10674	t	0
258	\\xe23e3dec469e389e2fe4d96cfbea58c302291e0463ea10b19a4a0650eef14d37	891	0	5822839	177161	0	490	\N	10745	t	0
\.


--
-- Data for Name: tx_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_in (id, tx_in_id, tx_out_id, tx_out_index, redeemer_id) FROM stdin;
1	35	13	0	\N
2	36	35	1	\N
3	37	36	0	\N
4	38	33	0	\N
5	39	38	0	\N
6	40	37	0	\N
7	41	40	1	\N
8	42	41	0	\N
9	43	17	0	\N
10	44	43	0	\N
11	45	42	0	\N
12	46	45	1	\N
13	47	46	0	\N
14	48	24	0	\N
15	49	48	0	\N
16	50	47	0	\N
17	51	50	1	\N
18	52	51	0	\N
19	53	25	0	\N
20	54	53	0	\N
21	55	52	0	\N
22	56	55	1	\N
23	57	56	0	\N
24	58	23	0	\N
25	59	58	0	\N
26	60	57	0	\N
27	61	60	1	\N
28	62	61	0	\N
29	63	22	0	\N
30	64	63	0	\N
31	65	62	0	\N
32	66	65	1	\N
33	67	66	0	\N
34	68	16	0	\N
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
46	80	19	0	\N
47	81	80	0	\N
48	82	81	0	\N
49	83	79	0	\N
50	84	83	0	\N
51	85	84	1	\N
52	86	85	0	\N
53	87	32	0	\N
54	88	87	0	\N
55	89	88	0	\N
56	90	86	0	\N
57	91	90	0	\N
58	92	91	1	\N
59	93	92	0	\N
60	94	26	0	\N
61	95	94	0	\N
62	96	95	0	\N
63	97	93	0	\N
64	98	29	0	\N
65	99	98	0	1
66	100	98	1	\N
67	101	100	1	\N
68	102	101	1	\N
69	103	102	1	\N
70	104	103	1	\N
71	105	104	1	\N
72	106	105	0	2
73	106	105	1	\N
74	107	20	0	\N
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
86	118	117	0	\N
87	118	116	0	\N
88	119	117	1	\N
89	120	119	0	\N
90	121	119	1	\N
91	121	120	0	\N
92	122	121	0	\N
93	123	122	0	\N
94	124	121	1	\N
95	124	123	0	\N
96	125	124	0	\N
97	125	124	1	\N
98	126	125	1	\N
99	127	125	0	\N
100	127	118	0	\N
101	127	126	0	\N
102	128	127	0	\N
103	128	127	1	\N
104	129	128	0	\N
105	129	128	1	\N
106	129	126	1	\N
107	130	129	0	\N
108	131	130	0	\N
109	132	131	0	\N
110	132	131	1	\N
111	132	131	2	\N
112	132	131	3	\N
113	132	131	4	\N
114	132	131	5	\N
115	132	131	6	\N
116	132	131	7	\N
117	132	131	8	\N
118	132	131	9	\N
119	132	131	10	\N
120	132	131	11	\N
121	132	131	12	\N
122	132	131	13	\N
123	132	131	14	\N
124	132	131	15	\N
125	132	131	16	\N
126	132	131	17	\N
127	132	131	18	\N
128	132	131	19	\N
129	132	131	20	\N
130	132	131	21	\N
131	132	131	22	\N
132	132	131	23	\N
133	132	131	24	\N
134	132	131	25	\N
135	132	131	26	\N
136	132	131	27	\N
137	132	131	28	\N
138	132	131	29	\N
139	132	131	30	\N
140	132	131	31	\N
141	132	131	32	\N
142	132	131	33	\N
143	132	131	34	\N
144	133	132	0	\N
145	134	130	1	\N
146	135	134	0	\N
147	136	134	1	\N
148	136	135	0	\N
149	137	136	0	\N
150	138	136	1	\N
151	139	138	0	\N
152	140	138	1	\N
153	140	137	0	\N
154	141	140	0	\N
155	141	140	1	\N
156	142	141	1	\N
157	143	141	0	\N
158	144	143	0	\N
159	144	142	1	\N
160	145	144	0	\N
161	145	144	1	\N
162	146	145	1	\N
163	147	146	1	\N
164	148	147	0	\N
165	148	147	1	\N
166	148	147	2	\N
167	148	147	3	\N
168	148	147	4	\N
169	148	147	5	\N
170	148	147	6	\N
171	148	147	7	\N
172	148	147	8	\N
173	148	147	9	\N
174	148	147	10	\N
175	148	147	11	\N
176	148	147	12	\N
177	148	147	13	\N
178	148	147	14	\N
179	148	147	15	\N
180	148	147	16	\N
181	148	147	17	\N
182	148	147	18	\N
183	148	147	19	\N
184	148	147	20	\N
185	148	147	21	\N
186	148	147	22	\N
187	148	147	23	\N
188	148	147	24	\N
189	148	147	25	\N
190	148	147	26	\N
191	148	147	27	\N
192	148	147	28	\N
193	148	147	29	\N
194	148	147	30	\N
195	148	147	31	\N
196	148	147	32	\N
197	148	147	33	\N
198	148	147	34	\N
199	148	147	35	\N
200	148	147	36	\N
201	148	147	37	\N
202	148	147	38	\N
203	148	147	39	\N
204	148	147	40	\N
205	148	147	41	\N
206	148	147	42	\N
207	148	147	43	\N
208	148	147	44	\N
209	148	147	45	\N
210	148	147	46	\N
211	148	147	47	\N
212	148	147	48	\N
213	148	147	49	\N
214	148	147	50	\N
215	148	147	51	\N
216	148	147	52	\N
217	148	147	53	\N
218	148	147	54	\N
219	148	147	55	\N
220	148	147	56	\N
221	148	147	57	\N
222	148	147	58	\N
223	148	147	59	\N
224	149	147	61	\N
225	150	147	63	\N
226	151	145	0	\N
227	152	147	101	\N
228	153	148	0	\N
229	154	147	108	\N
230	155	147	67	\N
231	156	147	90	\N
232	157	147	102	\N
233	158	147	75	\N
234	158	156	0	\N
235	159	147	112	\N
236	160	147	77	\N
237	161	147	92	\N
238	162	147	111	\N
239	163	147	78	\N
240	164	147	84	\N
241	165	147	94	\N
242	165	163	0	\N
243	166	147	104	\N
244	167	147	116	\N
245	168	147	81	\N
246	169	152	1	\N
247	170	149	0	\N
248	171	163	1	\N
249	172	147	69	\N
250	173	147	98	\N
251	174	147	62	\N
252	174	162	0	\N
253	175	151	0	\N
254	176	161	1	\N
255	177	147	65	\N
256	177	170	0	\N
257	178	168	1	\N
258	179	147	88	\N
259	180	176	1	\N
260	181	147	74	\N
261	181	174	0	\N
262	182	171	1	\N
263	183	150	1	\N
264	184	147	79	\N
265	184	179	0	\N
266	185	172	0	\N
267	185	164	0	\N
268	186	147	85	\N
269	187	186	1	\N
270	188	147	103	\N
271	189	147	76	\N
272	190	147	117	\N
273	190	177	0	\N
274	191	167	1	\N
275	192	191	1	\N
276	193	147	100	\N
277	194	147	87	\N
278	195	156	1	\N
279	196	180	1	\N
280	196	192	0	\N
281	197	186	0	\N
282	197	196	0	\N
283	198	196	1	\N
284	199	158	1	\N
285	200	185	1	\N
286	200	166	0	\N
287	201	160	1	\N
288	202	192	1	\N
289	203	197	1	\N
290	203	201	0	\N
291	204	147	115	\N
292	205	147	97	\N
293	206	147	66	\N
294	207	147	73	\N
295	207	160	0	\N
296	208	183	0	\N
297	208	159	0	\N
298	209	208	1	\N
299	209	206	0	\N
300	210	181	0	\N
301	210	178	0	\N
302	211	173	1	\N
303	212	147	109	\N
304	213	205	0	\N
305	213	200	1	\N
306	214	204	0	\N
307	214	194	0	\N
308	215	165	1	\N
309	216	147	118	\N
310	217	212	0	\N
311	217	157	1	\N
312	218	214	1	\N
313	218	216	0	\N
314	219	177	1	\N
315	220	172	1	\N
316	221	175	0	\N
317	221	161	0	\N
318	222	155	1	\N
319	223	199	1	\N
320	223	169	0	\N
321	224	194	1	\N
322	225	147	95	\N
323	226	154	0	\N
324	226	171	0	\N
325	227	189	1	\N
326	228	169	1	\N
327	228	146	0	\N
328	229	204	1	\N
329	229	220	0	\N
330	230	181	1	\N
331	231	211	1	\N
332	232	147	89	\N
333	233	228	0	\N
334	233	228	1	\N
335	234	218	0	\N
336	234	230	0	\N
337	235	229	1	\N
338	236	147	83	\N
339	237	153	1	\N
340	238	147	99	\N
341	239	217	1	\N
342	240	147	82	\N
343	241	167	0	\N
344	241	182	0	\N
345	242	219	0	\N
346	242	158	0	\N
347	243	174	1	\N
348	244	184	1	\N
349	245	147	80	\N
350	246	243	1	\N
351	247	197	0	\N
352	247	207	1	\N
353	248	176	0	\N
354	248	242	1	\N
355	249	245	0	\N
356	249	234	0	\N
357	250	173	0	\N
358	250	207	0	\N
359	251	235	1	\N
360	251	188	0	\N
361	252	147	60	\N
362	253	108	2	\N
363	254	253	0	\N
364	254	253	1	\N
365	255	254	0	\N
366	255	254	1	\N
367	256	107	0	\N
368	257	256	1	\N
369	258	257	0	\N
370	258	256	0	\N
\.


--
-- Data for Name: tx_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_metadata (id, key, json, bytes, tx_id) FROM stdin;
1	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "TestHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "TestHandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "HelloHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "HelloHandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "DoubleHandle": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "DoubleHandle", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a460a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656067776562736974657468747470733a2f2f63617264616e6f2e6f72672f6c446f75626c6548616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656c446f75626c6548616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6b48656c6c6f48616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656b48656c6c6f48616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f6a5465737448616e646c65a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d656a5465737448616e646c6567776562736974657468747470733a2f2f63617264616e6f2e6f72672f	109
2	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}, "handle2": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle2", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a26768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f6768616e646c6532a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653267776562736974657468747470733a2f2f63617264616e6f2e6f72672f	111
3	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	116
4	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	117
5	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	119
6	721	{"62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a": {"handle1": {"core": {"og": 0, "prefix": "$", "version": 0, "termsofuse": "https://cardanofoundation.org/en/terms-and-conditions/", "handleEncoding": "utf-8"}, "name": "$handle1", "image": "ipfs://some-hash", "website": "https://cardano.org/", "description": "The Handle Standard", "augmentations": []}}}	\\xa11902d1a178383632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961a16768616e646c6531a66d6175676d656e746174696f6e738064636f7265a56e68616e646c65456e636f64696e67657574662d38626f67006670726566697861246a7465726d736f66757365783668747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f6776657273696f6e006b6465736372697074696f6e735468652048616e646c65205374616e6461726465696d61676570697066733a2f2f736f6d652d68617368646e616d65682468616e646c653167776562736974657468747470733a2f2f63617264616e6f2e6f72672f	121
7	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"NFT-001": {"name": "One", "image": ["ipfs://some_hash1"], "version": "1.0"}, "NFT-002": {"name": "Two", "image": ["ipfs://some_hash2"], "version": "1.0"}, "NFT-files": {"id": "1", "name": "NFT with files", "files": [{"src": "ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5", "name": "some name", "mediaType": "video/mp4"}, {"src": ["ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2", "BU2dLjfWxuJoF2Ny"], "name": "some name", "mediaType": "audio/mpeg"}], "image": ["ipfs://somehash"], "version": "1.0", "mediaType": "image/png", "description": ["NFT with different types of files"]}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a3674e46542d303031a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65634f6e656776657273696f6e63312e30674e46542d303032a365696d6167658171697066733a2f2f736f6d655f6861736832646e616d656354776f6776657273696f6e63312e30694e46542d66696c6573a76b6465736372697074696f6e8178214e4654207769746820646966666572656e74207479706573206f662066696c65736566696c657382a3696d656469615479706569766964656f2f6d7034646e616d6569736f6d65206e616d65637372637835697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d6932425532644c6a665778754a6f46324e35a3696d65646961547970656a617564696f2f6d706567646e616d6569736f6d65206e616d6563737263827825697066733a2f2f516d6237385151345258784b51727465526e34583357614d5858666d693270425532644c6a665778754a6f46324e79626964613165696d616765816f697066733a2f2f736f6d6568617368696d656469615479706569696d6167652f706e67646e616d656e4e465420776974682066696c65736776657273696f6e63312e30	124
8	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"4349502d303032352d76312d686578": {"name": "CIP-0025-v1-hex", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1781e343334393530326433303330333233353264373633313264363836353738a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656f4349502d303032352d76312d6865786776657273696f6e63312e30	126
9	721	{"17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"CIP-0025-v1-utf8": {"name": "CIP-0025-v1-utf8", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a178383137656265333366386165656531666539613732373766653064633032323631353331613839366138623839343537383935666536303239a1704349502d303032352d76312d75746638a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d65704349502d303032352d76312d757466386776657273696f6e63312e30	127
10	721	{"0x17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029": {"0x4349502d303032352d7632": {"name": "CIP-0025-v2", "image": ["ipfs://some_hash1"], "version": "1.0"}}}	\\xa11902d1a1581c17ebe33f8aeee1fe9a7277fe0dc02261531a896a8b89457895fe6029a14b4349502d303032352d7632a365696d6167658171697066733a2f2f736f6d655f6861736831646e616d656b4349502d303032352d76326776657273696f6e63312e30	128
11	123	"1234"	\\xa1187b6431323334	146
\.


--
-- Data for Name: tx_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tx_out (id, tx_id, index, address, address_raw, address_has_script, payment_cred, stake_address_id, value, data_hash, inline_datum_id, reference_script_id) FROM stdin;
1	1	0	5oP9ib6ym3XXy22Ei7HgPkQe5GTZacew748mi4sL4SDU6GJt5vpjBPzfnQ33Hzgf56	\\x82d818582683581c07e474a7105246f3f750cfe9c7b51d00687424b949354c3e49161b2ca10243190378001a823e5d6d	f	\N	\N	910909092	\N	\N	\N
2	2	0	5oP9ib6ym3XZ8hQPWx5QdiRBdmD5e3xrhSZf88jN3XGKYt8rqucFg9q5NutL4FWUTi	\\x82d818582683581c1f607467cced69d08c416e307d22e6563143bb1cad447879b0eb5469a10243190378001a61954b61	f	\N	\N	910909092	\N	\N	\N
3	3	0	5oP9ib6ym3XbHPGFs5jJXWhenm15jqrjHE7jCPxjwdLv5szh4ZMMABR4beFwj6UyqZ	\\x82d818582683581c4aa48ebe6cd07ab97af759f06aa997010ac34159ada9fda0e06cf76ea10243190378001a45854428	f	\N	\N	910909092	\N	\N	\N
4	4	0	5oP9ib6ym3XbUMUt6rcLmbvpdPXPBNaE6tS5vLmGCaqeTK5xsh64Ldt8r26Rfh3EeD	\\x82d818582683581c4e72f843d993ee431fab71722919331f950053240aa7b2a164a7b331a10243190378001acdbb6152	f	\N	\N	910909092	\N	\N	\N
5	5	0	5oP9ib6ym3XfQsLpQK9KmZgiJ9r8BCW34cNNE8uytAdRVpDGVx4pHArQaXTWfFWsaF	\\x82d818582683581c9dbe311b5eec0c67d8e0a1d83d37a878b7b6c7a6aca7fee7258f409ea10243190378001adcc2cdf8	f	\N	\N	910909092	\N	\N	\N
6	6	0	5oP9ib6ym3Xg52HgZzDcUryLNfRsSfyGTkKJf1QocbLGD7KDxwE97sd6Fu3wzYoEHj	\\x82d818582683581caafb7977b0a2ed065fffb2ae6b0d5c18df541112b9fe9d0cb6a858fba10243190378001aaa7f81de	f	\N	\N	910909092	\N	\N	\N
7	7	0	5oP9ib6ym3XgrvuZNRDBfPt5a6Ti1ArnpWCq3PGpX4YwZgsFdugaGjtFv5Jc91hW3z	\\x82d818582683581cbae9766112b63ab99181f0bd73a75fba255c1caa37faf98d7282feaea10243190378001af9b94441	f	\N	\N	910909092	\N	\N	\N
8	8	0	5oP9ib6ym3XhJ9Cf4N9RqReRt8WCDSfuBiaL3zwSCgRNe74A8pUupvA5aaR4Z4Uhww	\\x82d818582683581cc3a911e79ee965149c43f60a93c77f100b95b11b896b37cde025beaea10243190378001a110f493a	f	\N	\N	910909092	\N	\N	\N
9	9	0	5oP9ib6ym3Xi1zNud5ckTE8qjD7iGGTnxwvvxNC4UBUgz2Zruqdx4yHK3WpYBYEtzL	\\x82d818582683581cd22e7650127f76a7373c97dd7eac7c4db727370bf6d7f4fef2f06fd2a10243190378001a296bb4a1	f	\N	\N	910909092	\N	\N	\N
10	10	0	5oP9ib6ym3XiKqcF6zQ7QQCx3Fo3jPFKsdNPTTu7Hrz81uGroq2uctecrDw2pMkyYd	\\x82d818582683581cd85ffd5ff574524db3102c9a1b3b98ad7bbb2867f718c5714dbff347a10243190378001a96fd10a2	f	\N	\N	910909092	\N	\N	\N
11	11	0	5oP9ib6ym3XjVSLCfSEYY75KP6Th6mabHW86PPTbkRDgn9EDbEeQsArdaEkqcmJpmr	\\x82d818582683581cefd4da9b72a24acb5622fab16b75604bdf486b55217165b42bf685f0a10243190378001a1e10a28d	f	\N	\N	910909092	\N	\N	\N
12	12	0	addr_test1vz9sg7xn3h64emgezs84rtfqaw737ryyjeauz2efgwsj6ecjxl3du	\\x608b0478d38df55ced19140f51ad20ebbd1f0c84967bc12b2943a12d67	f	\\x8b0478d38df55ced19140f51ad20ebbd1f0c84967bc12b2943a12d67	\N	3681818181818190	\N	\N	\N
13	13	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681818181818181	\N	\N	\N
14	14	0	addr_test1vr04993hgjh7pdz4xw4vvtdp8n92pegae5gv8yh9d0vc3hq9gafc9	\\x60df52963744afe0b45533aac62da13ccaa0e51dcd10c392e56bd988dc	f	\\xdf52963744afe0b45533aac62da13ccaa0e51dcd10c392e56bd988dc	\N	3681818181818181	\N	\N	\N
15	15	0	addr_test1vpqjwqyk3myvkwfu9y4rhrv3c5wj63xdce4dfug8u22pv4qe9fu9x	\\x60412700968ec8cb393c292a3b8d91c51d2d44cdc66ad4f107e2941654	f	\\x412700968ec8cb393c292a3b8d91c51d2d44cdc66ad4f107e2941654	\N	3681818181818181	\N	\N	\N
16	16	0	addr_test1qruk5pdlhpemlpwsd5vt97rxvtlqzwdr7tytmfnhe32a7ch4lxcej2mvkz4u2z6p0cjjs4ucumn8j2zwjlz0gg6tpkyqs6n50a	\\x00f96a05bfb873bf85d06d18b2f86662fe0139a3f2c8bda677cc55df62f5f9b1992b6cb0abc50b417e25285798e6e679284e97c4f4234b0d88	f	\\xf96a05bfb873bf85d06d18b2f86662fe0139a3f2c8bda677cc55df62	\N	3681818181818181	\N	\N	\N
17	17	0	addr_test1qqzs4tx9w4gdz8gepx4yn8q7prnmm7e5kmywsd687lzyn92slzph0kd84yy3w78cpdupdxgqzcc65ku2ta9x4rgrt2ysph750v	\\x00050aacc57550d11d1909aa499c1e08e7bdfb34b6c8e83747f7c4499550f88377d9a7a9091778f80b781699001631aa5b8a5f4a6a8d035a89	f	\\x050aacc57550d11d1909aa499c1e08e7bdfb34b6c8e83747f7c44995	\N	3681818181818181	\N	\N	\N
18	18	0	addr_test1vz7np4a8rlr2xsh4en83a65emj2v6jypd7elmn5pg8j7sfc00av6q	\\x60bd30d7a71fc6a342f5cccf1eea99dc94cd48816fb3fdce8141e5e827	f	\\xbd30d7a71fc6a342f5cccf1eea99dc94cd48816fb3fdce8141e5e827	\N	3681818181818181	\N	\N	\N
19	19	0	addr_test1qrtaup00v0khurzyegdjj7n88keav5j2fk5cjwah4luw2mapvvsqm2ljz4a3hpw3ay7er20q5lyk94tfwxtzm4k7vsvspe39r6	\\x00d7de05ef63ed7e0c44ca1b297a673db3d6524a4da9893bb7aff8e56fa163200dabf2157b1b85d1e93d91a9e0a7c962d56971962dd6de6419	f	\\xd7de05ef63ed7e0c44ca1b297a673db3d6524a4da9893bb7aff8e56f	\N	3681818181818181	\N	\N	\N
20	20	0	addr_test1vz7wnsdh5k33s8a6yrjplgkqdvqaycaqxm9kfple2s9rcds8fq0jm	\\x60bce9c1b7a5a3181fba20e41fa2c06b01d263a036cb6487f9540a3c36	f	\\xbce9c1b7a5a3181fba20e41fa2c06b01d263a036cb6487f9540a3c36	\N	3681818181818181	\N	\N	\N
21	21	0	addr_test1vzzn54a8wkvx89288ttcq7e76yha7pgdw5nf5cvwr97eevgjq9auq	\\x60853a57a775986395473ad7807b3ed12fdf050d75269a618e197d9cb1	f	\\x853a57a775986395473ad7807b3ed12fdf050d75269a618e197d9cb1	\N	3681818181818181	\N	\N	\N
22	22	0	addr_test1qq0zaa4thfw8et5g7d085zgknjre5juppq8h0lr7x52cgma5kt4x54t4wv4uzthu4dx62tahpsdzmaz7xjhatgnxhflsampq06	\\x001e2ef6abba5c7cae88f35e7a09169c879a4b81080f77fc7e3515846fb4b2ea6a5575732bc12efcab4da52fb70c1a2df45e34afd5a266ba7f	f	\\x1e2ef6abba5c7cae88f35e7a09169c879a4b81080f77fc7e3515846f	\N	3681818181818181	\N	\N	\N
23	23	0	addr_test1qz0ptdkf6rljvt4dp2y4pf7fgh2hk6qazdkqq5pllp9avv47ferksjsa7z7558yfpz2ckjj3ew0ut5c942v8a5vxgkzq8r0hkn	\\x009e15b6c9d0ff262ead0a8950a7c945d57b681d136c00503ff84bd632be4e47684a1df0bd4a1c8908958b4a51cb9fc5d305aa987ed1864584	f	\\x9e15b6c9d0ff262ead0a8950a7c945d57b681d136c00503ff84bd632	\N	3681818181818181	\N	\N	\N
24	24	0	addr_test1qqwquq4mw5z53f2x3kj6u9capux9eu6r0wu4nfgjtn5kh4jsqzj8qhvc0zgcnz6hy4ctn7xp5zndw6rqchalwctmu69s9h3ld7	\\x001c0e02bb750548a5468da5ae171d0f0c5cf3437bb959a5125ce96bd65000a4705d987891898b572570b9f8c1a0a6d76860c5fbf7617be68b	f	\\x1c0e02bb750548a5468da5ae171d0f0c5cf3437bb959a5125ce96bd6	\N	3681818181818181	\N	\N	\N
25	25	0	addr_test1qqhgzuutvttvmuvk80dqvts3vwcvd2y390aa9fhus6tywuvpuc4rmxvwa3v3dk5aqxrara8hu7l5m8sxz2fn6z8gx7gsmw2ar5	\\x002e81738b62d6cdf1963bda062e1163b0c6a8912bfbd2a6fc8696477181e62a3d998eec5916da9d0187d1f4f7e7bf4d9e0612933d08e83791	f	\\x2e81738b62d6cdf1963bda062e1163b0c6a8912bfbd2a6fc86964771	\N	3681818181818181	\N	\N	\N
26	26	0	addr_test1qr2s8q83cypdf6dqug6plp9z2djdz4eufqtc3ktna4qmh49s9hvqwv5rurdq8v5gnn0h0l26r64w93zzwrm6hy34sk5q0e2h34	\\x00d50380f1c102d4e9a0e2341f84a25364d1573c481788d973ed41bbd4b02dd8073283e0da03b2889cdf77fd5a1eaae2c44270f7ab923585a8	f	\\xd50380f1c102d4e9a0e2341f84a25364d1573c481788d973ed41bbd4	\N	3681818181818190	\N	\N	\N
27	27	0	addr_test1vpqvnpf3m6zymg76cum4l0smc7f6sf3j0j2v7s4wmktffdg345upm	\\x6040c98531de844da3dac7375fbe1bc793a826327c94cf42aedd9694b5	f	\\x40c98531de844da3dac7375fbe1bc793a826327c94cf42aedd9694b5	\N	3681818181818181	\N	\N	\N
28	28	0	addr_test1qqlvs5qd4sqjeez7zwxmwl3jzx528f449usz0929kuucvmgvp07hm5g3gh854swmqf2dt45lrpzrltng6gru49qm4wjswg4lgs	\\x003ec8500dac012ce45e138db77e3211a8a3a6b52f20279545b739866d0c0bfd7dd11145cf4ac1db0254d5d69f18443fae68d207ca941baba5	f	\\x3ec8500dac012ce45e138db77e3211a8a3a6b52f20279545b739866d	\N	3681818181818181	\N	\N	\N
29	29	0	addr_test1vz3kzhcl3j0tjz6mk7envuf0d0hgfe5guwwkt6qp342shkgfzjpjd	\\x60a3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	f	\\xa3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	\N	3681818181818181	\N	\N	\N
30	30	0	addr_test1vpklp7ka25u0snx7vh88fa5kmnyu099tgsnaesae8pkd9ccrsmvc3	\\x606df0fadd5538f84cde65ce74f696dcc9c794ab4427dcc3b9386cd2e3	f	\\x6df0fadd5538f84cde65ce74f696dcc9c794ab4427dcc3b9386cd2e3	\N	3681818181818181	\N	\N	\N
31	31	0	addr_test1vrm67nmywd7epjfrshlyr7j0kzv5j9jpdr7lhlut4u7c78gvev9a9	\\x60f7af4f64737d90c92385fe41fa4fb09949164168fdfbff8baf3d8f1d	f	\\xf7af4f64737d90c92385fe41fa4fb09949164168fdfbff8baf3d8f1d	\N	3681818181818181	\N	\N	\N
32	32	0	addr_test1qpc2qtwaupheg7j9pkuwdrh03l4gvu0jml33gn4taeed54cmkq4azeh30wktlyuwvy68wsz69ufler5gx8p7twfvqkas24n0el	\\x0070a02ddde06f947a450db8e68eef8fea8671f2dfe3144eabee72da571bb02bd166f17bacbf938e613477405a2f13fc8e8831c3e5b92c05bb	f	\\x70a02ddde06f947a450db8e68eef8fea8671f2dfe3144eabee72da57	\N	3681818181818181	\N	\N	\N
33	33	0	addr_test1qrrx6mrergd57rh9xnq7s9lgfwfwfu8wxwwrtrjn3hc9dh6cm002yggr3jqdqqdh30pxk42w9vq0zx9wmzxtxh5gmt8q3py55x	\\x00c66d6c791a1b4f0ee534c1e817e84b92e4f0ee339c358e538df056df58dbdea221038c80d001b78bc26b554e2b00f118aed88cb35e88dace	f	\\xc66d6c791a1b4f0ee534c1e817e84b92e4f0ee339c358e538df056df	\N	3681818181818181	\N	\N	\N
34	35	0	addr_test1qrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptn8hemvn78h4mefhpz8e4kf3pfr6nt5lf4yjncwam20v7xq34y25l	\\x00cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae67be76c9f8f7aef29b8447cd6c988523d4d74fa6a494f0eeed4f678c	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	15	500000000	\N	\N	\N
35	35	1	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681817681651228	\N	\N	\N
36	36	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681817681473231	\N	\N	\N
37	37	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681817681293914	\N	\N	\N
72	66	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681814878327629	\N	\N	\N
38	38	0	addr_test1qrrx6mrergd57rh9xnq7s9lgfwfwfu8wxwwrtrjn3hc9dh6cm002yggr3jqdqqdh30pxk42w9vq0zx9wmzxtxh5gmt8q3py55x	\\x00c66d6c791a1b4f0ee534c1e817e84b92e4f0ee339c358e538df056df58dbdea221038c80d001b78bc26b554e2b00f118aed88cb35e88dace	f	\\xc66d6c791a1b4f0ee534c1e817e84b92e4f0ee339c358e538df056df	11	3681818181637632	\N	\N	\N
39	39	0	addr_test1qrrx6mrergd57rh9xnq7s9lgfwfwfu8wxwwrtrjn3hc9dh6cm002yggr3jqdqqdh30pxk42w9vq0zx9wmzxtxh5gmt8q3py55x	\\x00c66d6c791a1b4f0ee534c1e817e84b92e4f0ee339c358e538df056df58dbdea221038c80d001b78bc26b554e2b00f118aed88cb35e88dace	f	\\xc66d6c791a1b4f0ee534c1e817e84b92e4f0ee339c358e538df056df	11	3681818181443619	\N	\N	\N
40	40	0	addr_test1qrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptnnmnfnm76krj8cxvvegz347hy9drr9l5t5hmpnpwyzy2fstqfvkx	\\x00cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae73dcd33dfb561c8f83319940a35f5c8568c65fd174bec330b8822293	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	18	600000000	\N	\N	\N
41	40	1	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681817081126961	\N	\N	\N
42	41	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681817080948964	\N	\N	\N
43	42	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681817080769647	\N	\N	\N
44	43	0	addr_test1qqzs4tx9w4gdz8gepx4yn8q7prnmm7e5kmywsd687lzyn92slzph0kd84yy3w78cpdupdxgqzcc65ku2ta9x4rgrt2ysph750v	\\x00050aacc57550d11d1909aa499c1e08e7bdfb34b6c8e83747f7c4499550f88377d9a7a9091778f80b781699001631aa5b8a5f4a6a8d035a89	f	\\x050aacc57550d11d1909aa499c1e08e7bdfb34b6c8e83747f7c44995	2	3681818181637632	\N	\N	\N
45	44	0	addr_test1qqzs4tx9w4gdz8gepx4yn8q7prnmm7e5kmywsd687lzyn92slzph0kd84yy3w78cpdupdxgqzcc65ku2ta9x4rgrt2ysph750v	\\x00050aacc57550d11d1909aa499c1e08e7bdfb34b6c8e83747f7c4499550f88377d9a7a9091778f80b781699001631aa5b8a5f4a6a8d035a89	f	\\x050aacc57550d11d1909aa499c1e08e7bdfb34b6c8e83747f7c44995	2	3681818181446391	\N	\N	\N
46	45	0	addr_test1qrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fpt4amjkz0h2m9j8ulv3psdgye0vhkvwy5e9ddt0t3u9pzgnqzfnfdt	\\x00cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90aebddcac27dd5b2c8fcfb22183504cbd97b31c4a64ad6adeb8f0a11226	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	16	200000000	\N	\N	\N
47	45	1	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681816880602694	\N	\N	\N
48	46	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681816880424697	\N	\N	\N
49	47	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681816880245380	\N	\N	\N
50	48	0	addr_test1qqwquq4mw5z53f2x3kj6u9capux9eu6r0wu4nfgjtn5kh4jsqzj8qhvc0zgcnz6hy4ctn7xp5zndw6rqchalwctmu69s9h3ld7	\\x001c0e02bb750548a5468da5ae171d0f0c5cf3437bb959a5125ce96bd65000a4705d987891898b572570b9f8c1a0a6d76860c5fbf7617be68b	f	\\x1c0e02bb750548a5468da5ae171d0f0c5cf3437bb959a5125ce96bd6	6	3681818181637632	\N	\N	\N
51	49	0	addr_test1qqwquq4mw5z53f2x3kj6u9capux9eu6r0wu4nfgjtn5kh4jsqzj8qhvc0zgcnz6hy4ctn7xp5zndw6rqchalwctmu69s9h3ld7	\\x001c0e02bb750548a5468da5ae171d0f0c5cf3437bb959a5125ce96bd65000a4705d987891898b572570b9f8c1a0a6d76860c5fbf7617be68b	f	\\x1c0e02bb750548a5468da5ae171d0f0c5cf3437bb959a5125ce96bd6	6	3681818181443619	\N	\N	\N
52	50	0	addr_test1qrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fpt5udxhe9vhm0cqu2yl4kh2eqy5chj6dywp62q9cedg7vahsshtj6z	\\x00cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae9c69af92b2fb7e01c513f5b5d5901298bcb4d2383a500b8cb51e676f	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	14	500000000	\N	\N	\N
53	50	1	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681816380078427	\N	\N	\N
54	51	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681816379900430	\N	\N	\N
55	52	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681816379721113	\N	\N	\N
56	53	0	addr_test1qqhgzuutvttvmuvk80dqvts3vwcvd2y390aa9fhus6tywuvpuc4rmxvwa3v3dk5aqxrara8hu7l5m8sxz2fn6z8gx7gsmw2ar5	\\x002e81738b62d6cdf1963bda062e1163b0c6a8912bfbd2a6fc8696477181e62a3d998eec5916da9d0187d1f4f7e7bf4d9e0612933d08e83791	f	\\x2e81738b62d6cdf1963bda062e1163b0c6a8912bfbd2a6fc86964771	7	3681818181637632	\N	\N	\N
57	54	0	addr_test1qqhgzuutvttvmuvk80dqvts3vwcvd2y390aa9fhus6tywuvpuc4rmxvwa3v3dk5aqxrara8hu7l5m8sxz2fn6z8gx7gsmw2ar5	\\x002e81738b62d6cdf1963bda062e1163b0c6a8912bfbd2a6fc8696477181e62a3d998eec5916da9d0187d1f4f7e7bf4d9e0612933d08e83791	f	\\x2e81738b62d6cdf1963bda062e1163b0c6a8912bfbd2a6fc86964771	7	3681818181443619	\N	\N	\N
58	55	0	addr_test1qrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsdykfcw2zan0hrycv7jwpk9r4cgttneh6awdqqq5yhzgtsw4syk6	\\x00cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae0d259387285d9bee32619e9383628eb842d73cdf5d73400050971217	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	22	500000000	\N	\N	\N
59	55	1	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681815879554160	\N	\N	\N
60	56	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681815879376163	\N	\N	\N
61	57	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681815879196846	\N	\N	\N
62	58	0	addr_test1qz0ptdkf6rljvt4dp2y4pf7fgh2hk6qazdkqq5pllp9avv47ferksjsa7z7558yfpz2ckjj3ew0ut5c942v8a5vxgkzq8r0hkn	\\x009e15b6c9d0ff262ead0a8950a7c945d57b681d136c00503ff84bd632be4e47684a1df0bd4a1c8908958b4a51cb9fc5d305aa987ed1864584	f	\\x9e15b6c9d0ff262ead0a8950a7c945d57b681d136c00503ff84bd632	5	3681818181637632	\N	\N	\N
63	59	0	addr_test1qz0ptdkf6rljvt4dp2y4pf7fgh2hk6qazdkqq5pllp9avv47ferksjsa7z7558yfpz2ckjj3ew0ut5c942v8a5vxgkzq8r0hkn	\\x009e15b6c9d0ff262ead0a8950a7c945d57b681d136c00503ff84bd632be4e47684a1df0bd4a1c8908958b4a51cb9fc5d305aa987ed1864584	f	\\x9e15b6c9d0ff262ead0a8950a7c945d57b681d136c00503ff84bd632	5	3681818181443619	\N	\N	\N
64	60	0	addr_test1qrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fpth0t465llm5my4nhf80ycmmwxmyzpfn2kzpe2q45guuntpqhdvc5x	\\x00cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90aeef5d754fff74d92b3ba4ef2637b71b641053355841ca815a239c9ac2	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	20	500000000	\N	\N	\N
65	60	1	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681815379029893	\N	\N	\N
66	61	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681815378851896	\N	\N	\N
67	62	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681815378672579	\N	\N	\N
68	63	0	addr_test1qq0zaa4thfw8et5g7d085zgknjre5juppq8h0lr7x52cgma5kt4x54t4wv4uzthu4dx62tahpsdzmaz7xjhatgnxhflsampq06	\\x001e2ef6abba5c7cae88f35e7a09169c879a4b81080f77fc7e3515846fb4b2ea6a5575732bc12efcab4da52fb70c1a2df45e34afd5a266ba7f	f	\\x1e2ef6abba5c7cae88f35e7a09169c879a4b81080f77fc7e3515846f	4	3681818181637632	\N	\N	\N
69	64	0	addr_test1qq0zaa4thfw8et5g7d085zgknjre5juppq8h0lr7x52cgma5kt4x54t4wv4uzthu4dx62tahpsdzmaz7xjhatgnxhflsampq06	\\x001e2ef6abba5c7cae88f35e7a09169c879a4b81080f77fc7e3515846fb4b2ea6a5575732bc12efcab4da52fb70c1a2df45e34afd5a266ba7f	f	\\x1e2ef6abba5c7cae88f35e7a09169c879a4b81080f77fc7e3515846f	4	3681818181443619	\N	\N	\N
70	65	0	addr_test1qrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fpt4jujmemnn2uaqzn97tkf9n6wrzut38etd2g0w4th9t76eq8c7prk	\\x00cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90aeb2e4b79dce6ae7402997cbb24b3d3862e2e27cadaa43dd55dcabf6b2	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	17	500000000	\N	\N	\N
71	65	1	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681814878505626	\N	\N	\N
73	67	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681814878148312	\N	\N	\N
74	68	0	addr_test1qruk5pdlhpemlpwsd5vt97rxvtlqzwdr7tytmfnhe32a7ch4lxcej2mvkz4u2z6p0cjjs4ucumn8j2zwjlz0gg6tpkyqs6n50a	\\x00f96a05bfb873bf85d06d18b2f86662fe0139a3f2c8bda677cc55df62f5f9b1992b6cb0abc50b417e25285798e6e679284e97c4f4234b0d88	f	\\xf96a05bfb873bf85d06d18b2f86662fe0139a3f2c8bda677cc55df62	1	3681818181637632	\N	\N	\N
75	69	0	addr_test1qruk5pdlhpemlpwsd5vt97rxvtlqzwdr7tytmfnhe32a7ch4lxcej2mvkz4u2z6p0cjjs4ucumn8j2zwjlz0gg6tpkyqs6n50a	\\x00f96a05bfb873bf85d06d18b2f86662fe0139a3f2c8bda677cc55df62f5f9b1992b6cb0abc50b417e25285798e6e679284e97c4f4234b0d88	f	\\xf96a05bfb873bf85d06d18b2f86662fe0139a3f2c8bda677cc55df62	1	3681818181443619	\N	\N	\N
76	70	0	addr_test1qrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fpthmuuyhzzrz3pcs68ctl407lg7jvldggc9zdr80memgsvxq98r38h	\\x00cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90aefbe70971086288710d1f0bfd5fefa3d267da8460a268cefde768830c	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	12	300000000	\N	\N	\N
77	70	1	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681814577981359	\N	\N	\N
78	71	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681814577803362	\N	\N	\N
79	72	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681814577624045	\N	\N	\N
80	73	0	addr_test1qqlvs5qd4sqjeez7zwxmwl3jzx528f449usz0929kuucvmgvp07hm5g3gh854swmqf2dt45lrpzrltng6gru49qm4wjswg4lgs	\\x003ec8500dac012ce45e138db77e3211a8a3a6b52f20279545b739866d0c0bfd7dd11145cf4ac1db0254d5d69f18443fae68d207ca941baba5	f	\\x3ec8500dac012ce45e138db77e3211a8a3a6b52f20279545b739866d	9	3681818181637632	\N	\N	\N
81	74	0	addr_test1qqlvs5qd4sqjeez7zwxmwl3jzx528f449usz0929kuucvmgvp07hm5g3gh854swmqf2dt45lrpzrltng6gru49qm4wjswg4lgs	\\x003ec8500dac012ce45e138db77e3211a8a3a6b52f20279545b739866d0c0bfd7dd11145cf4ac1db0254d5d69f18443fae68d207ca941baba5	f	\\x3ec8500dac012ce45e138db77e3211a8a3a6b52f20279545b739866d	9	3681818181446391	\N	\N	\N
82	75	0	addr_test1qqlvs5qd4sqjeez7zwxmwl3jzx528f449usz0929kuucvmgvp07hm5g3gh854swmqf2dt45lrpzrltng6gru49qm4wjswg4lgs	\\x003ec8500dac012ce45e138db77e3211a8a3a6b52f20279545b739866d0c0bfd7dd11145cf4ac1db0254d5d69f18443fae68d207ca941baba5	f	\\x3ec8500dac012ce45e138db77e3211a8a3a6b52f20279545b739866d	9	3681818181265842	\N	\N	\N
83	76	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681814577439800	\N	\N	\N
84	77	0	addr_test1qrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fpt4tun8mh7vn62ge07yfqahv47r4hfwhm4zwk83cy83mtamq5mxjv6	\\x00cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90aeabe4cfbbf993d29197f889076ecaf875ba5d7dd44eb1e3821e3b5f76	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	13	300000000	\N	\N	\N
85	77	1	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681814277272847	\N	\N	\N
86	78	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681814277094850	\N	\N	\N
87	79	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681814276915533	\N	\N	\N
88	80	0	addr_test1qrtaup00v0khurzyegdjj7n88keav5j2fk5cjwah4luw2mapvvsqm2ljz4a3hpw3ay7er20q5lyk94tfwxtzm4k7vsvspe39r6	\\x00d7de05ef63ed7e0c44ca1b297a673db3d6524a4da9893bb7aff8e56fa163200dabf2157b1b85d1e93d91a9e0a7c962d56971962dd6de6419	f	\\xd7de05ef63ed7e0c44ca1b297a673db3d6524a4da9893bb7aff8e56f	3	3681818181637632	\N	\N	\N
89	81	0	addr_test1qrtaup00v0khurzyegdjj7n88keav5j2fk5cjwah4luw2mapvvsqm2ljz4a3hpw3ay7er20q5lyk94tfwxtzm4k7vsvspe39r6	\\x00d7de05ef63ed7e0c44ca1b297a673db3d6524a4da9893bb7aff8e56fa163200dabf2157b1b85d1e93d91a9e0a7c962d56971962dd6de6419	f	\\xd7de05ef63ed7e0c44ca1b297a673db3d6524a4da9893bb7aff8e56f	3	3681818181446391	\N	\N	\N
90	82	0	addr_test1qrtaup00v0khurzyegdjj7n88keav5j2fk5cjwah4luw2mapvvsqm2ljz4a3hpw3ay7er20q5lyk94tfwxtzm4k7vsvspe39r6	\\x00d7de05ef63ed7e0c44ca1b297a673db3d6524a4da9893bb7aff8e56fa163200dabf2157b1b85d1e93d91a9e0a7c962d56971962dd6de6419	f	\\xd7de05ef63ed7e0c44ca1b297a673db3d6524a4da9893bb7aff8e56f	3	3681818181265842	\N	\N	\N
91	83	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681814276731288	\N	\N	\N
92	84	0	addr_test1qrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsfjvymhmhnajvy9s9l0hhpqgqz6qwzdu9musms6gnhg8gq9wgmnt	\\x00cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae099309bbeef3ec9842c0bf7dee102002d01c26f0bbe4370d227741d0	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	19	500000000	\N	\N	\N
93	84	1	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681813776564335	\N	\N	\N
94	85	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681813776386338	\N	\N	\N
95	86	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681813776207021	\N	\N	\N
96	87	0	addr_test1qpc2qtwaupheg7j9pkuwdrh03l4gvu0jml33gn4taeed54cmkq4azeh30wktlyuwvy68wsz69ufler5gx8p7twfvqkas24n0el	\\x0070a02ddde06f947a450db8e68eef8fea8671f2dfe3144eabee72da571bb02bd166f17bacbf938e613477405a2f13fc8e8831c3e5b92c05bb	f	\\x70a02ddde06f947a450db8e68eef8fea8671f2dfe3144eabee72da57	10	3681818181637632	\N	\N	\N
97	88	0	addr_test1qpc2qtwaupheg7j9pkuwdrh03l4gvu0jml33gn4taeed54cmkq4azeh30wktlyuwvy68wsz69ufler5gx8p7twfvqkas24n0el	\\x0070a02ddde06f947a450db8e68eef8fea8671f2dfe3144eabee72da571bb02bd166f17bacbf938e613477405a2f13fc8e8831c3e5b92c05bb	f	\\x70a02ddde06f947a450db8e68eef8fea8671f2dfe3144eabee72da57	10	3681818181443575	\N	\N	\N
98	89	0	addr_test1qpc2qtwaupheg7j9pkuwdrh03l4gvu0jml33gn4taeed54cmkq4azeh30wktlyuwvy68wsz69ufler5gx8p7twfvqkas24n0el	\\x0070a02ddde06f947a450db8e68eef8fea8671f2dfe3144eabee72da571bb02bd166f17bacbf938e613477405a2f13fc8e8831c3e5b92c05bb	f	\\x70a02ddde06f947a450db8e68eef8fea8671f2dfe3144eabee72da57	10	3681818181263026	\N	\N	\N
99	90	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681813776022776	\N	\N	\N
100	91	0	addr_test1qrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptnxp4479qs02w4ac0t6lll3g4x7y6ekjklca7j8h0s637aqu7xn33	\\x00cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae660d6be2820f53abdc3d7affff1454de26b3695bf8efa47bbe1a8fba	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	21	500000000	\N	\N	\N
101	91	1	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681813275855823	\N	\N	\N
102	92	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681813275677826	\N	\N	\N
103	93	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681813275498509	\N	\N	\N
104	94	0	addr_test1qr2s8q83cypdf6dqug6plp9z2djdz4eufqtc3ktna4qmh49s9hvqwv5rurdq8v5gnn0h0l26r64w93zzwrm6hy34sk5q0e2h34	\\x00d50380f1c102d4e9a0e2341f84a25364d1573c481788d973ed41bbd4b02dd8073283e0da03b2889cdf77fd5a1eaae2c44270f7ab923585a8	f	\\xd50380f1c102d4e9a0e2341f84a25364d1573c481788d973ed41bbd4	8	3681818181637641	\N	\N	\N
105	95	0	addr_test1qr2s8q83cypdf6dqug6plp9z2djdz4eufqtc3ktna4qmh49s9hvqwv5rurdq8v5gnn0h0l26r64w93zzwrm6hy34sk5q0e2h34	\\x00d50380f1c102d4e9a0e2341f84a25364d1573c481788d973ed41bbd4b02dd8073283e0da03b2889cdf77fd5a1eaae2c44270f7ab923585a8	f	\\xd50380f1c102d4e9a0e2341f84a25364d1573c481788d973ed41bbd4	8	3681818181443584	\N	\N	\N
106	96	0	addr_test1qr2s8q83cypdf6dqug6plp9z2djdz4eufqtc3ktna4qmh49s9hvqwv5rurdq8v5gnn0h0l26r64w93zzwrm6hy34sk5q0e2h34	\\x00d50380f1c102d4e9a0e2341f84a25364d1573c481788d973ed41bbd4b02dd8073283e0da03b2889cdf77fd5a1eaae2c44270f7ab923585a8	f	\\xd50380f1c102d4e9a0e2341f84a25364d1573c481788d973ed41bbd4	8	3681818181263035	\N	\N	\N
107	97	0	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3681813275314264	\N	\N	\N
108	98	0	addr_test1wpnlxv2xv9a9ucvnvzqakwepzl9ltx7jzgm53av2e9ncv4sysemm8	\\x7067f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	t	\\x67f33146617a5e61936081db3b2117cbf59bd2123748f58ac9678656	\N	100000000	\\x5e9d8bac576e8604e7c3526025bc146f5fa178173e3a5592d122687bd785b520	\N	\N
109	98	1	addr_test1vz3kzhcl3j0tjz6mk7envuf0d0hgfe5guwwkt6qp342shkgfzjpjd	\\x60a3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	f	\\xa3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	\N	3681818081650832	\N	\N	\N
110	99	0	addr_test1vz3kzhcl3j0tjz6mk7envuf0d0hgfe5guwwkt6qp342shkgfzjpjd	\\x60a3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	f	\\xa3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	\N	99828910	\N	\N	\N
111	100	0	addr_test1wqnp362vmvr8jtc946d3a3utqgclfdl5y9d3kn849e359hst7hkqk	\\x702618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	t	\\x2618e94cdb06792f05ae9b1ec78b0231f4b7f4215b1b4cf52e6342de	\N	100000000	\\x9e1199a988ba72ffd6e9c269cadb3b53b5f360ff99f112d9b2ee30c4d74ad88b	2	\N
112	100	1	addr_test1vz3kzhcl3j0tjz6mk7envuf0d0hgfe5guwwkt6qp342shkgfzjpjd	\\x60a3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	f	\\xa3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	\N	3681817981484759	\N	\N	\N
113	101	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	2
114	101	1	addr_test1vz3kzhcl3j0tjz6mk7envuf0d0hgfe5guwwkt6qp342shkgfzjpjd	\\x60a3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	f	\\xa3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	\N	3681817881314374	\N	\N	\N
115	102	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	3
116	102	1	addr_test1vz3kzhcl3j0tjz6mk7envuf0d0hgfe5guwwkt6qp342shkgfzjpjd	\\x60a3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	f	\\xa3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	\N	3681817781146585	\N	\N	\N
117	103	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	1
118	103	1	addr_test1vz3kzhcl3j0tjz6mk7envuf0d0hgfe5guwwkt6qp342shkgfzjpjd	\\x60a3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	f	\\xa3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	\N	3681817680979940	\N	\N	\N
119	104	0	addr_test1wz3937ykmlcaqxkf4z7stxpsfwfn4re7ncy48yu8vutcpxgnj28k0	\\x70a258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	t	\\xa258f896dff1d01ac9a8bd0598304b933a8f3e9e0953938767178099	\N	100000000	\N	\N	4
120	104	1	addr_test1vz3kzhcl3j0tjz6mk7envuf0d0hgfe5guwwkt6qp342shkgfzjpjd	\\x60a3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	f	\\xa3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	\N	3681817580717067	\N	\N	\N
121	105	0	addr_test1wzem0yuxjqyrmzvrsr8xfqhumyy555ngyjxw7wrg2pav90q8cagu2	\\x70b3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	t	\\xb3b7938690083d898380ce6482fcd9094a5268248cef3868507ac2bc	\N	100000000	\\x923918e403bf43c34b4ef6b48eb2ee04babed17320d8d1b9ff9ad086e86f44ec	3	\N
122	105	1	addr_test1vz3kzhcl3j0tjz6mk7envuf0d0hgfe5guwwkt6qp342shkgfzjpjd	\\x60a3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	f	\\xa3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	\N	3681817480550950	\N	\N	\N
123	106	0	addr_test1vz3kzhcl3j0tjz6mk7envuf0d0hgfe5guwwkt6qp342shkgfzjpjd	\\x60a3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	f	\\xa3615f1f8c9eb90b5bb7b336712f6bee84e688e39d65e8018d550bd9	\N	3681817580223603	\N	\N	\N
124	107	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\N	\N	\N
125	107	1	addr_test1vz7wnsdh5k33s8a6yrjplgkqdvqaycaqxm9kfple2s9rcds8fq0jm	\\x60bce9c1b7a5a3181fba20e41fa2c06b01d263a036cb6487f9540a3c36	f	\\xbce9c1b7a5a3181fba20e41fa2c06b01d263a036cb6487f9540a3c36	\N	3681818171642252	\N	\N	\N
126	108	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000000000	\N	\N	\N
127	108	1	addr_test1qrml5hwl9s7ydm2djyup95ud6s74skkl4zzf8zk657s8thgm78sn3uhch64ujc7ffnpga68dfdqhg3sp7tk6759jrm7spy03k9	\\x00f7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd1bf1e138f2f8beabc963c94cc28ee8ed4b41744601f2edaf50b21efd	f	\\xf7fa5ddf2c3c46ed4d913812d38dd43d585adfa884938adaa7a075dd	47	5000000000000	\N	\N	\N
128	108	2	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	5000000000000	\N	\N	\N
129	108	3	addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k	\\x00594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e09394c5bb6bc96115c9dc4468d020a99abff4aa2deda81b4bc6665bea	f	\\x594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0	49	5000000000000	\N	\N	\N
130	108	4	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	5000000000000	\N	\N	\N
131	108	5	addr_test1vrx2xfshgu5laez0l2jsxrz0l3alf4h2wk54sy3myl4fptsyealfp	\\x60cca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	f	\\xcca326174729fee44ffaa5030c4ffc7bf4d6ea75a958123b27ea90ae	\N	3656813275134639	\N	\N	\N
132	109	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\N	\N	\N
133	109	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999989777299	\N	\N	\N
134	110	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	10000000	\\x81cb2989cbf6c49840511d8d3451ee44f58dde2c074fc749d05deb51eeb33741	4	\N
135	110	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999979592482	\N	\N	\N
136	111	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
137	111	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999977388217	\N	\N	\N
138	112	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	2000000	\N	\N	\N
139	112	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999977214532	\N	\N	\N
140	113	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	2000000	\N	\N	\N
141	113	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999975044279	\N	\N	\N
142	114	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999974870770	\N	\N	\N
143	115	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	1826667	\N	\N	\N
144	116	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
145	116	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999972677769	\N	\N	\N
146	117	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
147	117	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999970484768	\N	\N	\N
148	118	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3825083	\N	\N	\N
149	119	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
150	119	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999968291767	\N	\N	\N
151	120	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1826667	\N	\N	\N
152	121	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2000000	\N	\N	\N
153	121	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999967923849	\N	\N	\N
154	122	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1824819	\N	\N	\N
155	123	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1651486	\N	\N	\N
156	124	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
157	124	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999959369574	\N	\N	\N
158	125	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
159	125	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999959189157	\N	\N	\N
160	126	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
161	126	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999948999456	\N	\N	\N
162	127	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
163	127	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	13633050	\N	\N	\N
164	128	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
165	128	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	13443921	\N	\N	\N
166	129	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4999972263972	\N	\N	\N
167	130	0	addr_test1qzfxfp7lj6dnhf8rxmmy6st8q6l703gsn2245vsqc85sl2mjycl63w0sq72xhrr6xm8wwzmqkmr7urmfp42s5r8jlcqskgc4x9	\\x00926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab72263fa8b9f007946b8c7a36cee70b60b6c7ee0f690d550a0cf2fe01	f	\\x926487df969b3ba4e336f64d416706bfe7c5109a955a3200c1e90fab	51	1000000000	\N	\N	\N
168	130	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998972095567	\N	\N	\N
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
215	134	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998968911542	\N	\N	\N
216	135	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2820771	\N	\N	\N
217	136	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3000000	\N	\N	\N
218	136	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998968552996	\N	\N	\N
219	137	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2826843	\N	\N	\N
220	138	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
221	138	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998963384591	\N	\N	\N
222	140	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
223	140	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998961041445	\N	\N	\N
224	141	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998961541445	\N	\N	\N
225	141	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4330011	\N	\N	\N
226	142	0	addr_test1qqk9y8lt37jk5k4672nefy2ga9l3vxg3xdqgsvpgkq78httaz6v5pj3usegtaz2srkf3kvyjjgpdr064shhw23w638jqs72jll	\\x002c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad7d169940ca3c8650be89501d931b30929202d1bf5585eee545da89e4	f	\\x2c521feb8fa56a5abaf2a7949148e97f1619113340883028b03c7bad	50	1000000	\N	\N	\N
227	142	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	3152938	\N	\N	\N
228	143	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4998961369872	\N	\N	\N
229	144	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999378713686	\N	\N	\N
230	144	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999585638959	\N	\N	\N
231	145	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999378713686	\N	\N	\N
232	145	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999585468794	\N	\N	\N
233	146	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	969750	\N	\N	\N
234	146	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	1999584328791	\N	\N	\N
235	147	0	addr_test1qp4zszt9gk52du64rtfce03739t5ypvft3pvdckjg7j54d3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qqjvqu2	\\x006a28096545a8a6f3551ad38cbe3e89574205895c42c6e2d247a54ab63f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x6a28096545a8a6f3551ad38cbe3e89574205895c42c6e2d247a54ab6	62	3000000	\N	\N	\N
236	147	1	addr_test1qp3uvtx64ty6u50ah24gyl7dxazdlecp6cqmargaz8nw6xplvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qlkpa7r	\\x0063c62cdaaac9ae51fdbaaa827fcd3744dfe701d601be8d1d11e6ed183f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x63c62cdaaac9ae51fdbaaa827fcd3744dfe701d601be8d1d11e6ed18	62	3000000	\N	\N	\N
237	147	2	addr_test1qzn5w4lrh4f07nrrtu9wr62uyaj7lqke9fhnttr79hcxkz3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qtxzszd	\\x00a74757e3bd52ff4c635f0ae1e95c2765ef82d92a6f35ac7e2df06b0a3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xa74757e3bd52ff4c635f0ae1e95c2765ef82d92a6f35ac7e2df06b0a	62	3000000	\N	\N	\N
238	147	3	addr_test1qzytpfkc4tderrgu204m88gwv966gxtsg2m5gpg3gx4lqkelvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q3wzdrj	\\x0088b0a6d8aadb918d1c53ebb39d0e6175a4197042b744051141abf05b3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x88b0a6d8aadb918d1c53ebb39d0e6175a4197042b744051141abf05b	62	3000000	\N	\N	\N
239	147	4	addr_test1qzqd2un0u3avraj73art0e6wav2pxnyaw55hzaqy0f7ufz3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q7urdgm	\\x0080d5726fe47ac1f65e8f46b7e74eeb14134c9d75297174047a7dc48a3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x80d5726fe47ac1f65e8f46b7e74eeb14134c9d75297174047a7dc48a	62	3000000	\N	\N	\N
240	147	5	addr_test1qr9agk2rrd5vvk2v5casqrcdp7rt9tv3tr59fqytfjt2yqplvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q5ufefc	\\x00cbd459431b68c6594ca63b000f0d0f86b2ad9158e854808b4c96a2003f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xcbd459431b68c6594ca63b000f0d0f86b2ad9158e854808b4c96a200	62	3000000	\N	\N	\N
241	147	6	addr_test1qpjztcpgk6f077e43jmrqel4le0vlujv02ydwjc5ur30fhelvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qflawc4	\\x006425e028b692ff7b358cb63067f5fe5ecff24c7a88d74b14e0e2f4df3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x6425e028b692ff7b358cb63067f5fe5ecff24c7a88d74b14e0e2f4df	62	3000000	\N	\N	\N
242	147	7	addr_test1qz3c5e5dydkkax7a38mpatlcv5r45vxw8g87ywhu6w09vjelvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q879fk5	\\x00a38a668d236d6e9bdd89f61eaff865075a30ce3a0fe23afcd39e564b3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xa38a668d236d6e9bdd89f61eaff865075a30ce3a0fe23afcd39e564b	62	3000000	\N	\N	\N
243	147	8	addr_test1qpmnx36w245amkdupscn062vwqldeq25wm6tn3ndhjh4v9elvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qpzrpt0	\\x007733474e5569ddd9bc0c3137e94c703edc815476f4b9c66dbcaf56173f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x7733474e5569ddd9bc0c3137e94c703edc815476f4b9c66dbcaf5617	62	3000000	\N	\N	\N
244	147	9	addr_test1qq7kdvlqcpyfcx9mjzr588eyvfuyh2d08luapuu2tkppxeelvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qrg3ywe	\\x003d66b3e0c0489c18bb9087439f2462784ba9af3ff9d0f38a5d8213673f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x3d66b3e0c0489c18bb9087439f2462784ba9af3ff9d0f38a5d821367	62	3000000	\N	\N	\N
245	147	10	addr_test1qpu0f5u5q0p25qlg6tuwhxqksu33xtz8mwk2p2zc66sp69plvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q98qmlc	\\x0078f4d39403c2aa03e8d2f8eb98168723132c47dbaca0a858d6a01d143f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x78f4d39403c2aa03e8d2f8eb98168723132c47dbaca0a858d6a01d14	62	3000000	\N	\N	\N
246	147	11	addr_test1qzdagsdz0a2mvk2k2knsrtcueuf5y427psz3xut9k0d02tflvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qc4rq6c	\\x009bd441a27f55b6595655a701af1ccf1342555e0c05137165b3daf52d3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x9bd441a27f55b6595655a701af1ccf1342555e0c05137165b3daf52d	62	3000000	\N	\N	\N
247	147	12	addr_test1qr86zz0m4usl8amkgjez2jam35yxx79kayvllx4clhfwqdelvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qe3x9qd	\\x00cfa109fbaf21f3f77644b2254bbb8d086378b6e919ff9ab8fdd2e0373f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xcfa109fbaf21f3f77644b2254bbb8d086378b6e919ff9ab8fdd2e037	62	3000000	\N	\N	\N
248	147	13	addr_test1qztfrprcfkd3m2lq5ukmvhg9u4gxn0svd8x9m2xw27qg7k3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qk5ladp	\\x00969184784d9b1dabe0a72db65d05e55069be0c69cc5da8ce57808f5a3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x969184784d9b1dabe0a72db65d05e55069be0c69cc5da8ce57808f5a	62	3000000	\N	\N	\N
249	147	14	addr_test1qq9tng2hrhwzl6zjxuz9hwwe04kwcksgmwpphyejhcahmgflvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q7ymaz3	\\x000ab9a1571ddc2fe85237045bb9d97d6cec5a08db821b9332be3b7da13f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x0ab9a1571ddc2fe85237045bb9d97d6cec5a08db821b9332be3b7da1	62	3000000	\N	\N	\N
250	147	15	addr_test1qz7nuur6f0qhf2025r5tgy77zzams6nq033cprkl9sgdrmplvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qatp2eh	\\x00bd3e707a4bc174a9eaa0e8b413de10bbb86a607c63808edf2c10d1ec3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xbd3e707a4bc174a9eaa0e8b413de10bbb86a607c63808edf2c10d1ec	62	3000000	\N	\N	\N
251	147	16	addr_test1qz0gsjz9ryfpq7jj5a90g5tpll9k5jcqgdftqvgfjjdasy3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qn0k4cq	\\x009e8848451912107a52a74af45161ffcb6a4b004352b03109949bd8123f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x9e8848451912107a52a74af45161ffcb6a4b004352b03109949bd812	62	3000000	\N	\N	\N
252	147	17	addr_test1qzm54rquz84dmfmt6qgqrfnlrd4qvtxd344mjpj79zhfdt3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q0dxart	\\x00b74a8c1c11eadda76bd01001a67f1b6a062ccd8d6bb9065e28ae96ae3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xb74a8c1c11eadda76bd01001a67f1b6a062ccd8d6bb9065e28ae96ae	62	3000000	\N	\N	\N
253	147	18	addr_test1qp5s3wu3jn8qy07lk67v3py339jc8pf3wr6re5jkjdkx53plvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q6fx6pp	\\x006908bb9194ce023fdfb6bcc88491896583853170f43cd256936c6a443f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x6908bb9194ce023fdfb6bcc88491896583853170f43cd256936c6a44	62	3000000	\N	\N	\N
254	147	19	addr_test1qpf3uy0aue7kcyvjn0flqrude80fadp3n4zysxc2uywrlqplvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qw6smmm	\\x00531e11fde67d6c11929bd3f00f8dc9de9eb4319d44481b0ae11c3f803f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x531e11fde67d6c11929bd3f00f8dc9de9eb4319d44481b0ae11c3f80	62	3000000	\N	\N	\N
255	147	20	addr_test1qp09v7r03y8cm2zzqmx8l8wkkg5t9g2cv9xpz986e8rnn63lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q9hu4h2	\\x005e56786f890f8da84206cc7f9dd6b228b2a158614c1114fac9c739ea3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x5e56786f890f8da84206cc7f9dd6b228b2a158614c1114fac9c739ea	62	3000000	\N	\N	\N
256	147	21	addr_test1qqdsuxznuevdf2ruc3djh4g0rpjwv78twlafqad04d2nmy3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q4cw3ln	\\x001b0e1853e658d4a87cc45b2bd50f1864e678eb77fa9075afab553d923f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x1b0e1853e658d4a87cc45b2bd50f1864e678eb77fa9075afab553d92	62	3000000	\N	\N	\N
257	147	22	addr_test1qquwlru3l84yl4xfvqdfppsy0gquyphea3v2tgt4jx3z2hflvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qp3eeqn	\\x0038ef8f91f9ea4fd4c9601a9086047a01c206f9ec58a5a17591a2255d3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x38ef8f91f9ea4fd4c9601a9086047a01c206f9ec58a5a17591a2255d	62	3000000	\N	\N	\N
258	147	23	addr_test1qzr7uj4znk7pcq8gqqaachkrm99v9fc276yqeuf3eftjd6plvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qxf6j33	\\x0087ee4aa29dbc1c00e8003bdc5ec3d94ac2a70af6880cf131ca5726e83f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x87ee4aa29dbc1c00e8003bdc5ec3d94ac2a70af6880cf131ca5726e8	62	3000000	\N	\N	\N
259	147	24	addr_test1qqxtzcsk94zf4ewe5le0g7anm4szsh53jnuyr09qfewpnn3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qgj7xcx	\\x000cb162162d449ae5d9a7f2f47bb3dd60285e9194f841bca04e5c19ce3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x0cb162162d449ae5d9a7f2f47bb3dd60285e9194f841bca04e5c19ce	62	3000000	\N	\N	\N
260	147	25	addr_test1qz0sdgqtgasd8m0qww7g9ekzmyal04j5jqes8mufklmsn9elvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q7l8kve	\\x009f06a00b4760d3ede073bc82e6c2d93bf7d654903303ef89b7f709973f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x9f06a00b4760d3ede073bc82e6c2d93bf7d654903303ef89b7f70997	62	3000000	\N	\N	\N
261	147	26	addr_test1qpapc6xnnxkv7dnuu029wfz9dhv32g8902vg387xsueax4plvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qk9mem2	\\x007a1c68d399accf367ce3d45724456dd91520e57a98889fc68733d3543f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x7a1c68d399accf367ce3d45724456dd91520e57a98889fc68733d354	62	3000000	\N	\N	\N
262	147	27	addr_test1qq2tuwagcta8gxtrshnrh27y0s2uhf0yq99gpt8ncfqjdhplvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qw5wxq4	\\x0014be3ba8c2fa74196385e63babc47c15cba5e4014a80acf3c24126dc3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x14be3ba8c2fa74196385e63babc47c15cba5e4014a80acf3c24126dc	62	3000000	\N	\N	\N
263	147	28	addr_test1qp7seguujlcmgtf0v3wrymtkwq50ksvtum0s02an7f4avkflvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qll0jln	\\x007d0ca39c97f1b42d2f645c326d767028fb418be6df07abb3f26bd6593f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x7d0ca39c97f1b42d2f645c326d767028fb418be6df07abb3f26bd659	62	3000000	\N	\N	\N
264	147	29	addr_test1qqt3a8mx0yfygs4xmr0kz7y04h6kpn5k6e6fhy2yr4jhqd3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qqwjchy	\\x00171e9f6679124442a6d8df61788fadf560ce96d6749b91441d6570363f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x171e9f6679124442a6d8df61788fadf560ce96d6749b91441d657036	62	3000000	\N	\N	\N
265	147	30	addr_test1qzfrrkxhy7p67y9y5p37mkmkntnff59huku4a3q5axjf25flvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qjwz79t	\\x009231d8d72783af10a4a063eddb769ae694d0b7e5b95ec414e9a495513f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x9231d8d72783af10a4a063eddb769ae694d0b7e5b95ec414e9a49551	62	3000000	\N	\N	\N
266	147	31	addr_test1qrjqcp4edksukfk7u289mumja439x2puzfq69qqcal9fgq3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q0s8myy	\\x00e40c06b96da1cb26dee28e5df372ed6253283c1241a28018efca94023f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xe40c06b96da1cb26dee28e5df372ed6253283c1241a28018efca9402	62	3000000	\N	\N	\N
267	147	32	addr_test1qrxjx6pwtxk6zz2qpr3mfnnsxcddlvaan2l96dvxqljmuqflvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qhe0wyf	\\x00cd23682e59ada1094008e3b4ce70361adfb3bd9abe5d358607e5be013f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xcd23682e59ada1094008e3b4ce70361adfb3bd9abe5d358607e5be01	62	3000000	\N	\N	\N
268	147	33	addr_test1qzke3skwppgevslt2r574785gjphzj7yasvuvc92l0qdhsplvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qn7r0ux	\\x00ad98c2ce08519643eb50e9eaf8f44483714bc4ec19c660aafbc0dbc03f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xad98c2ce08519643eb50e9eaf8f44483714bc4ec19c660aafbc0dbc0	62	3000000	\N	\N	\N
269	147	34	addr_test1qzrnv2u3hz098t4vcjgyr6as68zs2rtzcnlkzrtpe77cdl3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qfuysex	\\x0087362b91b89e53aeacc49041ebb0d1c5050d62c4ff610d61cfbd86fe3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x87362b91b89e53aeacc49041ebb0d1c5050d62c4ff610d61cfbd86fe	62	3000000	\N	\N	\N
270	147	35	addr_test1qplfunmyr7w3709rcftwdvphe8lyy98l2gcy6llfayvq06flvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qg2lzvv	\\x007e9e4f641f9d1f3ca3c256e6b037c9fe4214ff52304d7fe9e91807e93f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x7e9e4f641f9d1f3ca3c256e6b037c9fe4214ff52304d7fe9e91807e9	62	3000000	\N	\N	\N
271	147	36	addr_test1qzlv2w7nxne4a883sdv0uqukxvryle0rarrc344ym22m4y3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qdwg5wg	\\x00bec53bd334f35e9cf18358fe039633064fe5e3e8c788d6a4da95ba923f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xbec53bd334f35e9cf18358fe039633064fe5e3e8c788d6a4da95ba92	62	3000000	\N	\N	\N
272	147	37	addr_test1qprt80sh84zxae9vw2rtac65f8jx3xpq8ys0g5306k2ym5elvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q8c4mz3	\\x0046b3be173d446ee4ac7286bee35449e46898203920f4522fd5944dd33f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x46b3be173d446ee4ac7286bee35449e46898203920f4522fd5944dd3	62	3000000	\N	\N	\N
273	147	38	addr_test1qrt9hhqy7z3a8ryhge3fzjtlfnvd5md9qk3vs9lwyyl2ejelvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qw0x70k	\\x00d65bdc04f0a3d38c97466291497f4cd8da6da505a2c817ee213eaccb3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xd65bdc04f0a3d38c97466291497f4cd8da6da505a2c817ee213eaccb	62	3000000	\N	\N	\N
274	147	39	addr_test1qpfdau5p4cjju7k4plkca0w43ay4rg5udhy985y5fx6sj4plvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qxdzq60	\\x0052def281ae252e7ad50fed8ebdd58f4951a29c6dc853d09449b509543f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x52def281ae252e7ad50fed8ebdd58f4951a29c6dc853d09449b50954	62	3000000	\N	\N	\N
275	147	40	addr_test1qq9cswunvrfa7gpeehjw5hnqymvtvxmxg85wrrcvfud4stflvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qmpquw6	\\x000b883b9360d3df2039cde4ea5e6026d8b61b6641e8e18f0c4f1b582d3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x0b883b9360d3df2039cde4ea5e6026d8b61b6641e8e18f0c4f1b582d	62	3000000	\N	\N	\N
276	147	41	addr_test1qr75css8zhw45l0c4mje53de90pkx3382xxgddpj34g7sfflvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qucpuex	\\x00fd4c420715dd5a7df8aee59a45b92bc3634627518c86b4328d51e8253f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xfd4c420715dd5a7df8aee59a45b92bc3634627518c86b4328d51e825	62	3000000	\N	\N	\N
277	147	42	addr_test1qrgh7v43qm5wus24ypalnankr29wpmuawl0evmr5mnaldlelvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q3myfzs	\\x00d17f32b106e8ee4155207bf9f6761a8ae0ef9d77df966c74dcfbf6ff3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xd17f32b106e8ee4155207bf9f6761a8ae0ef9d77df966c74dcfbf6ff	62	3000000	\N	\N	\N
278	147	43	addr_test1qrjqmakf38hjed3k4m7xnr5cmk6ulvqh350qxmw99efg68elvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qsxa7yv	\\x00e40df6c989ef2cb636aefc698e98ddb5cfb0178d1e036dc52e528d1f3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xe40df6c989ef2cb636aefc698e98ddb5cfb0178d1e036dc52e528d1f	62	3000000	\N	\N	\N
279	147	44	addr_test1qp5sz0ttv9mtk9wsks8flwed8qdkrwcc0nemydkv6jvmsdflvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qlx774l	\\x0069013d6b6176bb15d0b40e9fbb2d381b61bb187cf3b236ccd499b8353f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x69013d6b6176bb15d0b40e9fbb2d381b61bb187cf3b236ccd499b835	62	3000000	\N	\N	\N
280	147	45	addr_test1qqkpcqqkaywjhk4fk63uklkqs9rnfw7vwvajgvsejwvnf9flvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qhfe9ph	\\x002c1c0016e91d2bdaa9b6a3cb7ec0814734bbcc733b243219939934953f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x2c1c0016e91d2bdaa9b6a3cb7ec0814734bbcc733b24321993993495	62	3000000	\N	\N	\N
281	147	46	addr_test1qq5f9n0u0qacy7uw6800tackprj05jghj73472mmqftlug3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qqqhvfa	\\x002892cdfc783b827b8ed1def5f71608e4fa491797a35f2b7b0257fe223f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x2892cdfc783b827b8ed1def5f71608e4fa491797a35f2b7b0257fe22	62	3000000	\N	\N	\N
282	147	47	addr_test1qqa0nafndej95u5pyxvg5829l62fzyjckne859l3qdrvslelvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qk3t08u	\\x003af9f5336e645a728121988a1d45fe94911258b4f27a17f10346c87f3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x3af9f5336e645a728121988a1d45fe94911258b4f27a17f10346c87f	62	3000000	\N	\N	\N
283	147	48	addr_test1qqn8ls2g9jg060dhentmagctm2c6n3ecwfwrv4luc3fhx5flvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q8mmg26	\\x00267fc1482c90fd3db7ccd7bea30bdab1a9c738725c3657fcc45373513f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x267fc1482c90fd3db7ccd7bea30bdab1a9c738725c3657fcc4537351	62	3000000	\N	\N	\N
284	147	49	addr_test1qqn0ymhyz9vetc2t969y9x7mz2fftqljkhcwd03ljdlhg33lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q2e46vk	\\x0026f26ee4115995e14b2e8a429bdb12929583f2b5f0e6be3f937f74463f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x26f26ee4115995e14b2e8a429bdb12929583f2b5f0e6be3f937f7446	62	3000000	\N	\N	\N
285	147	50	addr_test1qzngmcexlj4xfnejghyp879sw675vxh9hpl42kstdjj4qaelvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qxgqud9	\\x00a68de326fcaa64cf3245c813f8b076bd461ae5b87f555a0b6ca550773f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xa68de326fcaa64cf3245c813f8b076bd461ae5b87f555a0b6ca55077	62	3000000	\N	\N	\N
286	147	51	addr_test1qqc0v6dzmcnwudx6z8pspd7gz6ap40jg664u82qw609327elvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q238vez	\\x0030f669a2de26ee34da11c300b7c816ba1abe48d6abc3a80ed3cb157b3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x30f669a2de26ee34da11c300b7c816ba1abe48d6abc3a80ed3cb157b	62	3000000	\N	\N	\N
287	147	52	addr_test1qz8rzpnhkzee883xwgc9a73tyjz36m6a5lq24344axs5xl3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qsj5rng	\\x008e310677b0b3939e2672305efa2b24851d6f5da7c0aac6b5e9a1437e3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x8e310677b0b3939e2672305efa2b24851d6f5da7c0aac6b5e9a1437e	62	3000000	\N	\N	\N
288	147	53	addr_test1qzsf30524v8uht5ghjv4rfgzyhj84j4y0064ged40up404elvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8q4uj6dx	\\x00a098be8aab0fcbae88bc9951a50225e47acaa47bf55465b57f0357d73f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xa098be8aab0fcbae88bc9951a50225e47acaa47bf55465b57f0357d7	62	3000000	\N	\N	\N
289	147	54	addr_test1qre27keh2ms33yv3dh34n9vwp7fn56rn4c92z5zgttcgxcelvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qtrfwy3	\\x00f2af5b3756e11891916de359958e0f933a6873ae0aa150485af083633f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xf2af5b3756e11891916de359958e0f933a6873ae0aa150485af08363	62	3000000	\N	\N	\N
290	147	55	addr_test1qzx5dlh5f6va5en8spapzjdthr2a8hsk7n5px93aphyhqrflvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qm58r5w	\\x008d46fef44e99da6667807a1149abb8d5d3de16f4e813163d0dc9700d3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x8d46fef44e99da6667807a1149abb8d5d3de16f4e813163d0dc9700d	62	3000000	\N	\N	\N
291	147	56	addr_test1qql0m8h88yv3q0c9c408e67s7fusm438m7027088vmj0ddelvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qv8vqsq	\\x003efd9ee73919103f05c55e7cebd0f2790dd627df9eaf3ce766e4f6b73f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x3efd9ee73919103f05c55e7cebd0f2790dd627df9eaf3ce766e4f6b7	62	3000000	\N	\N	\N
292	147	57	addr_test1qp6l4k5ewll67fdlqa5t6snnpwegarjf74z9xakvsswc0n3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qf4ej2l	\\x0075fada9977ffaf25bf0768bd42730bb28e8e49f5445376cc841d87ce3f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x75fada9977ffaf25bf0768bd42730bb28e8e49f5445376cc841d87ce	62	3000000	\N	\N	\N
293	147	58	addr_test1qpsdssr6wfw67cv6094ryxkkdnkvuylfa6n8hj89ztnpl3plvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qz39a2w	\\x0060d8407a725daf619a796a321ad66cecce13e9eea67bc8e512e61fc43f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x60d8407a725daf619a796a321ad66cecce13e9eea67bc8e512e61fc4	62	3000000	\N	\N	\N
294	147	59	addr_test1qrda65uhuesngwvh3rnydkuc0uynyd5puqcetv0hwxzkxzflvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qm3pdww	\\x00dbdd5397e66134399788e646db987f09323681e03195b1f7718563093f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\xdbdd5397e66134399788e646db987f09323681e03195b1f771856309	62	3000000	\N	\N	\N
295	147	60	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	38946782728	\N	\N	\N
296	147	61	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
297	147	62	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
298	147	63	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
299	147	64	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
300	147	65	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
301	147	66	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
302	147	67	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
303	147	68	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
304	147	69	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
305	147	70	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
306	147	71	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
307	147	72	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
308	147	73	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
309	147	74	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
310	147	75	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
311	147	76	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
312	147	77	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
313	147	78	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
314	147	79	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
315	147	80	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
316	147	81	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
317	147	82	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
318	147	83	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
319	147	84	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
320	147	85	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
321	147	86	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
322	147	87	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
323	147	88	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
324	147	89	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
325	147	90	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
326	147	91	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
327	147	92	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
328	147	93	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
329	147	94	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
330	147	95	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
331	147	96	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
332	147	97	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
333	147	98	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
334	147	99	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
335	147	100	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
336	147	101	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
337	147	102	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
338	147	103	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
339	147	104	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
340	147	105	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
341	147	106	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
342	147	107	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
343	147	108	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
344	147	109	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
345	147	110	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
346	147	111	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
347	147	112	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
348	147	113	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
349	147	114	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
350	147	115	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
351	147	116	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
352	147	117	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
353	147	118	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
354	147	119	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33228085250	\N	\N	\N
355	148	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	178500000	\N	\N	\N
356	148	1	addr_test1qp4zszt9gk52du64rtfce03739t5ypvft3pvdckjg7j54d3lvpfzr5k28l4e55j8d65dmsqf3ff4xfwdx3lva5dmje8qqjvqu2	\\x006a28096545a8a6f3551ad38cbe3e89574205895c42c6e2d247a54ab63f605221d2ca3feb9a52476ea8ddc0098a535325cd347eced1bb964e	f	\\x6a28096545a8a6f3551ad38cbe3e89574205895c42c6e2d247a54ab6	62	974447	\N	\N	\N
357	149	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	10000000	\N	\N	\N
358	149	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217916801	\N	\N	\N
359	150	0	5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg	\\x82d818582683581c599d72b5e3f5a40fb4c4eb809e904d101f908a419472f542bc7032b9a10243190378001a2a94baa3	f	\N	\N	3000000	\N	\N	\N
360	150	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33224917197	\N	\N	\N
361	151	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999378539297	\N	\N	\N
362	152	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
363	152	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
364	153	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
365	153	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	173331771	\N	\N	\N
366	154	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
367	154	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
368	155	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
369	155	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
370	156	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
371	156	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
372	157	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
373	157	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
374	158	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
375	158	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227915217	\N	\N	\N
376	159	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
377	159	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
378	160	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
379	160	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
380	161	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
381	161	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
382	162	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
383	162	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
384	163	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
385	163	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
386	164	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
387	164	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
388	165	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
389	165	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227915217	\N	\N	\N
390	166	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
391	166	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
392	167	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
393	167	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
394	168	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
395	168	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
396	169	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
397	169	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217748396	\N	\N	\N
398	170	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
399	170	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4831771	\N	\N	\N
400	171	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
401	171	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217748396	\N	\N	\N
402	172	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
403	172	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
404	173	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
405	173	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
406	174	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
407	174	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227915217	\N	\N	\N
408	175	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
409	175	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	2999373370892	\N	\N	\N
410	176	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
411	176	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217748396	\N	\N	\N
412	177	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
413	177	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227915217	\N	\N	\N
414	178	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
415	178	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217748396	\N	\N	\N
416	179	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
417	179	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
418	180	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
419	180	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33212579991	\N	\N	\N
420	181	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
421	181	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227915217	\N	\N	\N
422	182	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
423	182	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33212579991	\N	\N	\N
424	183	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
425	183	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33219748792	\N	\N	\N
426	184	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
427	184	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227915217	\N	\N	\N
428	185	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
429	185	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
430	186	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
431	186	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
432	187	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
433	187	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217748396	\N	\N	\N
434	188	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
435	188	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
436	189	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
437	189	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
438	190	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
439	190	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227915217	\N	\N	\N
440	191	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
441	191	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217748396	\N	\N	\N
442	192	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
443	192	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33212579991	\N	\N	\N
444	193	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
445	193	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
446	194	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
447	194	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
448	195	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
449	195	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217748396	\N	\N	\N
450	196	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
451	196	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33212410002	\N	\N	\N
452	197	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
453	197	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
454	198	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
455	198	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33207241597	\N	\N	\N
456	199	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
457	199	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222746812	\N	\N	\N
458	200	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
459	200	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
460	201	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
461	201	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217748396	\N	\N	\N
462	202	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
463	202	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33207411586	\N	\N	\N
464	203	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
465	203	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
466	204	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
467	204	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
468	205	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
469	205	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
470	206	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
471	206	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
472	207	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
473	207	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227915217	\N	\N	\N
474	208	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
475	208	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
476	209	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
477	209	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
478	210	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
479	210	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
480	211	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
481	211	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217748396	\N	\N	\N
482	212	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
483	212	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
484	213	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
485	213	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4490561	\N	\N	\N
486	214	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
487	214	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
488	215	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
489	215	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222746812	\N	\N	\N
490	216	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
491	216	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
492	217	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
493	217	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222746812	\N	\N	\N
494	218	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
495	218	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
496	219	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
497	219	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222746812	\N	\N	\N
498	220	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
499	220	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217748396	\N	\N	\N
500	221	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
501	221	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
502	222	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
503	222	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217748396	\N	\N	\N
504	223	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
505	223	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222576823	\N	\N	\N
506	224	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
507	224	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217748396	\N	\N	\N
508	225	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
509	225	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
510	226	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
511	226	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
512	227	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
513	227	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217748396	\N	\N	\N
514	228	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
515	228	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33213548157	\N	\N	\N
516	229	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
517	229	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222746812	\N	\N	\N
518	230	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
519	230	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222746812	\N	\N	\N
520	231	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
521	231	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33212579991	\N	\N	\N
522	232	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
523	232	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
524	233	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
525	233	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33213378168	\N	\N	\N
526	234	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
527	234	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
528	235	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
529	235	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217578407	\N	\N	\N
530	236	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
531	236	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
532	237	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
533	237	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	168163542	\N	\N	\N
534	238	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
535	238	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
536	239	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
537	239	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217578407	\N	\N	\N
538	240	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
539	240	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
540	241	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
541	241	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
542	242	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
543	242	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
544	243	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
545	243	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222746812	\N	\N	\N
546	244	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
547	244	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222746812	\N	\N	\N
548	245	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
549	245	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33222916801	\N	\N	\N
550	246	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
551	246	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217578407	\N	\N	\N
552	247	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
553	247	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33227745228	\N	\N	\N
554	248	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
555	248	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4660374	\N	\N	\N
556	249	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
557	249	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
558	250	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
559	250	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	4830187	\N	\N	\N
560	251	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
561	251	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	33217408418	\N	\N	\N
562	252	0	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	5000000	\N	\N	\N
563	252	1	addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7	\\x005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80	f	\\x5cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967	46	48573081067	\N	\N	\N
564	253	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
565	253	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999996820111	\N	\N	\N
566	254	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
567	254	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999996648538	\N	\N	\N
568	255	0	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	3000000	\N	\N	\N
569	255	1	addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s	\\x00cd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cde0b30dc21735b34227c3c3d7a433865f2835916d5242155f10a08882	f	\\xcd720d49fe67daf770a070656a6f24aab587720297be661cabbae3cd	48	4999996471201	\N	\N	\N
570	256	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
571	256	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	6816723	\N	\N	\N
572	257	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
573	257	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3643170	\N	\N	\N
574	258	0	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	3000000	\N	\N	\N
575	258	1	addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7	\\x00df88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7a84bacc10de2203d30331255459b8e1736a22134cc554d1ed5789a72	f	\\xdf88a476cecb804e89f45b3600399f55eb2928065da76165cf6dd7c7	45	2822839	\N	\N	\N
\.


--
-- Data for Name: withdrawal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.withdrawal (id, addr_id, amount, redeemer_id, tx_id) FROM stdin;
1	46	9631473080	\N	252
\.


--
-- Name: ada_pots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ada_pots_id_seq', 9, true);


--
-- Name: block_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.block_id_seq', 894, true);


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

SELECT pg_catalog.setval('public.datum_id_seq', 4, true);


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

SELECT pg_catalog.setval('public.epoch_stake_id_seq', 196, true);


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

SELECT pg_catalog.setval('public.ma_tx_mint_id_seq', 36, true);


--
-- Name: ma_tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ma_tx_out_id_seq', 41, true);


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

SELECT pg_catalog.setval('public.reverse_index_id_seq', 892, true);


--
-- Name: reward_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reward_id_seq', 158, true);


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

SELECT pg_catalog.setval('public.slot_leader_id_seq', 894, true);


--
-- Name: stake_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stake_address_id_seq', 65, true);


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

SELECT pg_catalog.setval('public.tx_id_seq', 258, true);


--
-- Name: tx_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_in_id_seq', 370, true);


--
-- Name: tx_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_metadata_id_seq', 11, true);


--
-- Name: tx_out_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tx_out_id_seq', 575, true);


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
