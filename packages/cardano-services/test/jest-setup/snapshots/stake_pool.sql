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
-- Name: stake_pool; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE stake_pool WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE stake_pool OWNER TO postgres;

\connect stake_pool

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
-- Name: pgboss; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pgboss;


ALTER SCHEMA pgboss OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: job_state; Type: TYPE; Schema: pgboss; Owner: postgres
--

CREATE TYPE pgboss.job_state AS ENUM (
    'created',
    'retry',
    'active',
    'completed',
    'expired',
    'cancelled',
    'failed'
);


ALTER TYPE pgboss.job_state OWNER TO postgres;

--
-- Name: stake_pool_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.stake_pool_status_enum AS ENUM (
    'activating',
    'active',
    'retired',
    'retiring'
);


ALTER TYPE public.stake_pool_status_enum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: archive; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.archive (
    id uuid NOT NULL,
    name text NOT NULL,
    priority integer NOT NULL,
    data jsonb,
    state pgboss.job_state NOT NULL,
    retrylimit integer NOT NULL,
    retrycount integer NOT NULL,
    retrydelay integer NOT NULL,
    retrybackoff boolean NOT NULL,
    startafter timestamp with time zone NOT NULL,
    startedon timestamp with time zone,
    singletonkey text,
    singletonon timestamp without time zone,
    expirein interval NOT NULL,
    createdon timestamp with time zone NOT NULL,
    completedon timestamp with time zone,
    keepuntil timestamp with time zone NOT NULL,
    on_complete boolean NOT NULL,
    output jsonb,
    archivedon timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.archive OWNER TO postgres;

--
-- Name: job; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.job (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    data jsonb,
    state pgboss.job_state DEFAULT 'created'::pgboss.job_state NOT NULL,
    retrylimit integer DEFAULT 0 NOT NULL,
    retrycount integer DEFAULT 0 NOT NULL,
    retrydelay integer DEFAULT 0 NOT NULL,
    retrybackoff boolean DEFAULT false NOT NULL,
    startafter timestamp with time zone DEFAULT now() NOT NULL,
    startedon timestamp with time zone,
    singletonkey text,
    singletonon timestamp without time zone,
    expirein interval DEFAULT '00:15:00'::interval NOT NULL,
    createdon timestamp with time zone DEFAULT now() NOT NULL,
    completedon timestamp with time zone,
    keepuntil timestamp with time zone DEFAULT (now() + '14 days'::interval) NOT NULL,
    on_complete boolean DEFAULT false NOT NULL,
    output jsonb,
    block_slot integer
);


ALTER TABLE pgboss.job OWNER TO postgres;

--
-- Name: schedule; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.schedule (
    name text NOT NULL,
    cron text NOT NULL,
    timezone text,
    data jsonb,
    options jsonb,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.schedule OWNER TO postgres;

--
-- Name: subscription; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.subscription (
    event text NOT NULL,
    name text NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.subscription OWNER TO postgres;

--
-- Name: version; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.version (
    version integer NOT NULL,
    maintained_on timestamp with time zone,
    cron_on timestamp with time zone
);


ALTER TABLE pgboss.version OWNER TO postgres;

--
-- Name: block; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.block (
    height integer NOT NULL,
    hash character(64) NOT NULL,
    slot integer NOT NULL
);


ALTER TABLE public.block OWNER TO postgres;

--
-- Name: block_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.block_data (
    block_height integer NOT NULL,
    data bytea NOT NULL
);


ALTER TABLE public.block_data OWNER TO postgres;

--
-- Name: current_pool_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.current_pool_metrics (
    stake_pool_id character(56) NOT NULL,
    slot integer,
    minted_blocks integer,
    live_delegators integer,
    active_stake bigint,
    live_stake bigint,
    live_pledge bigint,
    live_saturation numeric,
    active_size numeric,
    live_size numeric,
    last_ros numeric,
    ros numeric
);


ALTER TABLE public.current_pool_metrics OWNER TO postgres;

--
-- Name: pool_delisted; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_delisted (
    stake_pool_id character(56) NOT NULL
);


ALTER TABLE public.pool_delisted OWNER TO postgres;

--
-- Name: pool_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_metadata (
    id integer NOT NULL,
    ticker character varying NOT NULL,
    name character varying NOT NULL,
    description character varying NOT NULL,
    homepage character varying NOT NULL,
    hash character varying NOT NULL,
    ext jsonb,
    stake_pool_id character(56),
    pool_update_id bigint NOT NULL
);


ALTER TABLE public.pool_metadata OWNER TO postgres;

--
-- Name: pool_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_metadata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_metadata_id_seq OWNER TO postgres;

--
-- Name: pool_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_metadata_id_seq OWNED BY public.pool_metadata.id;


--
-- Name: pool_registration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_registration (
    id bigint NOT NULL,
    reward_account character varying NOT NULL,
    pledge numeric(20,0) NOT NULL,
    cost numeric(20,0) NOT NULL,
    margin jsonb NOT NULL,
    margin_percent real NOT NULL,
    relays jsonb NOT NULL,
    owners jsonb NOT NULL,
    vrf character(64) NOT NULL,
    metadata_url character varying,
    metadata_hash character(64),
    block_slot integer NOT NULL,
    stake_pool_id character(56) NOT NULL
);


ALTER TABLE public.pool_registration OWNER TO postgres;

--
-- Name: pool_retirement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_retirement (
    id bigint NOT NULL,
    retire_at_epoch integer NOT NULL,
    block_slot integer NOT NULL,
    stake_pool_id character(56) NOT NULL
);


ALTER TABLE public.pool_retirement OWNER TO postgres;

--
-- Name: pool_rewards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_rewards (
    id integer NOT NULL,
    stake_pool_id character(56) NOT NULL,
    epoch_length integer NOT NULL,
    epoch_no integer NOT NULL,
    delegators integer NOT NULL,
    pledge numeric(20,0) NOT NULL,
    active_stake numeric(20,0) NOT NULL,
    member_active_stake numeric(20,0) NOT NULL,
    leader_rewards numeric(20,0) NOT NULL,
    member_rewards numeric(20,0) NOT NULL,
    rewards numeric(20,0) NOT NULL,
    version integer NOT NULL
);


ALTER TABLE public.pool_rewards OWNER TO postgres;

--
-- Name: pool_rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_rewards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_rewards_id_seq OWNER TO postgres;

--
-- Name: pool_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_rewards_id_seq OWNED BY public.pool_rewards.id;


--
-- Name: stake_pool; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stake_pool (
    id character(56) NOT NULL,
    status public.stake_pool_status_enum NOT NULL,
    last_registration_id bigint,
    last_retirement_id bigint
);


ALTER TABLE public.stake_pool OWNER TO postgres;

--
-- Name: pool_metadata id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata ALTER COLUMN id SET DEFAULT nextval('public.pool_metadata_id_seq'::regclass);


--
-- Name: pool_rewards id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_rewards ALTER COLUMN id SET DEFAULT nextval('public.pool_rewards_id_seq'::regclass);


--
-- Data for Name: archive; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.archive (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output, archivedon) FROM stdin;
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.job (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output, block_slot) FROM stdin;
195c40e5-ae68-4f5c-a7e0-49623ed459df	__pgboss__cron	0	\N	created	2	0	0	f	2024-07-26 09:24:01.475739+00	\N	\N	2024-07-26 09:24:00	00:15:00	2024-07-26 09:23:04.475739+00	\N	2024-07-26 09:25:01.475739+00	f	\N	\N
514281bf-d29b-4478-8947-2b41f1200778	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 08:43:23.4235+00	2024-07-26 08:43:23.427344+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 08:43:23.4235+00	2024-07-26 08:43:23.437062+00	2024-07-26 08:51:23.4235+00	f	\N	\N
c5a1050f-2826-494b-9831-35cb21f67904	pool-metrics	0	{"slot": 3711}	completed	0	0	0	f	2024-07-26 08:53:35.235196+00	2024-07-26 08:53:35.926184+00	\N	\N	00:15:00	2024-07-26 08:53:35.235196+00	2024-07-26 08:53:36.105171+00	2024-08-09 08:53:35.235196+00	f	\N	3711
068ca613-eea1-4a2b-8a67-e3a698666ff9	pool-rewards	0	{"epochNo": 2}	completed	1000000	0	30	f	2024-07-26 08:54:33.218627+00	2024-07-26 08:54:33.953559+00	2	\N	06:00:00	2024-07-26 08:54:33.218627+00	2024-07-26 08:54:34.095774+00	2025-07-26 08:54:33.218627+00	f	\N	4001
a61d9e21-6a0d-4955-a30d-1eedf924471d	pool-metrics	0	{"slot": 4203}	completed	0	0	0	f	2024-07-26 08:55:13.60913+00	2024-07-26 08:55:13.971765+00	\N	\N	00:15:00	2024-07-26 08:55:13.60913+00	2024-07-26 08:55:14.166076+00	2024-08-09 08:55:13.60913+00	f	\N	4203
5d88a727-cc2b-40f2-aeed-a446f6b8aa37	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 08:54:51.664712+00	2024-07-26 08:55:51.649436+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 08:52:51.664712+00	2024-07-26 08:55:51.660528+00	2024-07-26 09:02:51.664712+00	f	\N	\N
ccaa874a-2d70-4cde-a907-4ae45d2cc1cd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 08:43:51.635267+00	2024-07-26 08:43:51.637971+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 08:43:51.635267+00	2024-07-26 08:43:51.644336+00	2024-07-26 08:51:51.635267+00	f	\N	\N
c5591af0-ed59-4a43-8179-99ed89e5401f	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:43:23.433173+00	2024-07-26 08:43:51.642328+00	\N	2024-07-26 08:43:00	00:15:00	2024-07-26 08:43:23.433173+00	2024-07-26 08:43:51.645606+00	2024-07-26 08:44:23.433173+00	f	\N	\N
1bdfa3da-df80-4ab7-bc39-cf27e57a89fc	pool-metrics	0	{"slot": 4695}	completed	0	0	0	f	2024-07-26 08:56:52.025039+00	2024-07-26 08:56:54.014838+00	\N	\N	00:15:00	2024-07-26 08:56:52.025039+00	2024-07-26 08:56:54.291088+00	2024-08-09 08:56:52.025039+00	f	\N	4695
98e2fc4d-37d7-41e3-8be5-5bfe14dbb590	pool-rewards	0	{"epochNo": 3}	completed	1000000	0	30	f	2024-07-26 08:57:54.219129+00	2024-07-26 08:57:56.039134+00	3	\N	06:00:00	2024-07-26 08:57:54.219129+00	2024-07-26 08:57:56.145537+00	2025-07-26 08:57:54.219129+00	f	\N	5006
770fa574-bb2f-4c28-a7b2-837ca7583596	pool-metrics	0	{"slot": 5090}	completed	0	0	0	f	2024-07-26 08:58:11.018826+00	2024-07-26 08:58:12.048492+00	\N	\N	00:15:00	2024-07-26 08:58:11.018826+00	2024-07-26 08:58:12.220556+00	2024-08-09 08:58:11.018826+00	f	\N	5090
08a04269-f43e-4bb7-9f4b-35968cfb1683	pool-metadata	0	{"poolId": "pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz", "metadataJson": {"url": "http://file-server/SP1.json", "hash": "14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7"}, "poolRegistrationId": "2500000010000"}	completed	1000000	0	60	f	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.659773+00	\N	\N	00:15:00	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.696396+00	2025-07-26 08:43:23.663537+00	f	\N	250
32c06f4d-d0d7-4dd2-8afc-2d22a6642f5b	pool-metadata	0	{"poolId": "pool13kpk6jp9q09d83zfejn0wpqkxlu9xwnfyc959qqm7k8pwxyymf8", "metadataJson": {"url": "http://file-server/SP10.json", "hash": "c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd"}, "poolRegistrationId": "2500000040000"}	completed	1000000	0	60	f	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.659773+00	\N	\N	00:15:00	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.696169+00	2025-07-26 08:43:23.663537+00	f	\N	250
2fe881f2-f01d-4f6a-91d6-c48812c3edbf	pool-metadata	0	{"poolId": "pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc", "metadataJson": {"url": "http://file-server/SP6.json", "hash": "3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba"}, "poolRegistrationId": "2500000080000"}	completed	1000000	0	60	f	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.659773+00	\N	\N	00:15:00	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.698698+00	2025-07-26 08:43:23.663537+00	f	\N	250
cb99745a-deba-4a94-a022-b0ae22757bdc	pool-metadata	0	{"poolId": "pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg", "metadataJson": {"url": "http://file-server/SP4.json", "hash": "09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d"}, "poolRegistrationId": "2500000100000"}	completed	1000000	0	60	f	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.659773+00	\N	\N	00:15:00	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.703173+00	2025-07-26 08:43:23.663537+00	f	\N	250
f5245a07-da91-48d7-84bb-05e0b9d4b8e6	pool-metadata	0	{"poolId": "pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf", "metadataJson": {"url": "http://file-server/SP7.json", "hash": "c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405"}, "poolRegistrationId": "2500000020000"}	completed	1000000	0	60	f	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.659773+00	\N	\N	00:15:00	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.70348+00	2025-07-26 08:43:23.663537+00	f	\N	250
40f3670a-b23a-496a-b7d8-54171c7fe3d5	pool-metadata	0	{"poolId": "pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5", "metadataJson": {"url": "http://file-server/SP3.json", "hash": "6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25"}, "poolRegistrationId": "2500000030000"}	completed	1000000	0	60	f	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.659773+00	\N	\N	00:15:00	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.704358+00	2025-07-26 08:43:23.663537+00	f	\N	250
331a6b8b-d9a4-458f-a27e-9d9e66444b4a	pool-metrics	0	{"slot": 623}	completed	0	0	0	f	2024-07-26 08:43:23.764898+00	2024-07-26 08:43:51.659764+00	\N	\N	00:15:00	2024-07-26 08:43:23.764898+00	2024-07-26 08:43:51.905474+00	2024-08-09 08:43:23.764898+00	f	\N	623
5f758009-b6dc-4948-827e-0a7fbb948bb4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 08:57:51.663553+00	2024-07-26 08:58:51.653629+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 08:55:51.663553+00	2024-07-26 08:58:51.666347+00	2024-07-26 09:05:51.663553+00	f	\N	\N
7aca4819-1625-4797-b1fc-8d3e8764359d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:44:01.646565+00	2024-07-26 08:44:03.649254+00	\N	2024-07-26 08:44:00	00:15:00	2024-07-26 08:43:51.646565+00	2024-07-26 08:44:03.662126+00	2024-07-26 08:45:01.646565+00	f	\N	\N
6130af53-ad72-4cab-b984-0365c5538e92	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:59:01.976055+00	2024-07-26 08:59:03.982971+00	\N	2024-07-26 08:59:00	00:15:00	2024-07-26 08:58:03.976055+00	2024-07-26 08:59:04.004472+00	2024-07-26 09:00:01.976055+00	f	\N	\N
96b88d78-f6d8-4c6d-bd45-da20e5efe344	pool-metrics	0	{"slot": 1142}	completed	0	0	0	f	2024-07-26 08:45:01.408774+00	2024-07-26 08:45:01.67887+00	\N	\N	00:15:00	2024-07-26 08:45:01.408774+00	2024-07-26 08:45:01.902967+00	2024-08-09 08:45:01.408774+00	f	\N	1142
33c15d3e-a4ae-45ef-8aa1-4b7e1457c777	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:45:01.66064+00	2024-07-26 08:45:03.672834+00	\N	2024-07-26 08:45:00	00:15:00	2024-07-26 08:44:03.66064+00	2024-07-26 08:45:03.698082+00	2024-07-26 08:46:01.66064+00	f	\N	\N
16065b4f-bd38-49d1-8dde-41cd65bcd006	pool-metrics	0	{"slot": 5568}	completed	0	0	0	f	2024-07-26 08:59:46.615996+00	2024-07-26 08:59:48.091676+00	\N	\N	00:15:00	2024-07-26 08:59:46.615996+00	2024-07-26 08:59:48.301574+00	2024-08-09 08:59:46.615996+00	f	\N	5568
bc61e22a-0465-45d7-b893-92689b0971db	pool-metrics	0	{"slot": 1567}	completed	0	0	0	f	2024-07-26 08:46:26.422268+00	2024-07-26 08:46:27.723861+00	\N	\N	00:15:00	2024-07-26 08:46:26.422268+00	2024-07-26 08:46:27.922914+00	2024-08-09 08:46:26.422268+00	f	\N	1567
9a330c4f-4aa5-44dd-b4a5-939b98ae793e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 08:45:51.646252+00	2024-07-26 08:46:51.643509+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 08:43:51.646252+00	2024-07-26 08:46:51.657576+00	2024-07-26 08:53:51.646252+00	f	\N	\N
114382c6-cfd4-4484-844e-c71db3c2ae6b	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "pool-delist-schedule", "options": {}, "timezone": "UTC", "created_on": "2024-07-26T08:43:51.682Z", "updated_on": "2024-07-26T08:43:51.682Z"}	completed	0	0	0	f	2024-07-26 09:00:04.015754+00	2024-07-26 09:00:08.008815+00	pool-delist-schedule	2024-07-26 09:00:00	00:15:00	2024-07-26 09:00:04.015754+00	2024-07-26 09:00:08.017639+00	2024-08-09 09:00:04.015754+00	f	\N	\N
7c2b006f-e1b1-44bb-844d-6e60a21071c8	pool-metrics	0	{"slot": 5938}	completed	0	0	0	f	2024-07-26 09:01:00.625483+00	2024-07-26 09:01:02.129606+00	\N	\N	00:15:00	2024-07-26 09:01:00.625483+00	2024-07-26 09:01:02.311105+00	2024-08-09 09:01:00.625483+00	f	\N	5938
39c3d944-e084-4d44-b733-40eee54c52d5	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:01:01.023215+00	2024-07-26 09:01:04.028413+00	\N	2024-07-26 09:01:00	00:15:00	2024-07-26 09:00:04.023215+00	2024-07-26 09:01:04.047615+00	2024-07-26 09:02:01.023215+00	f	\N	\N
78c8115a-1402-480d-8a99-9ec792a1a17e	pool-rewards	0	{"epochNo": 4}	completed	1000000	0	30	f	2024-07-26 09:01:13.427797+00	2024-07-26 09:01:14.138907+00	4	\N	06:00:00	2024-07-26 09:01:13.427797+00	2024-07-26 09:01:14.267639+00	2025-07-26 09:01:13.427797+00	f	\N	6002
3a88f72f-862b-4289-85fb-2b24bb800ef9	pool-metrics	0	{"slot": 6448}	completed	0	0	0	f	2024-07-26 09:02:42.627528+00	2024-07-26 09:02:44.173367+00	\N	\N	00:15:00	2024-07-26 09:02:42.627528+00	2024-07-26 09:02:44.349919+00	2024-08-09 09:02:42.627528+00	f	\N	6448
c0c67b99-b814-4f6b-9fbd-c7288051b237	pool-metrics	0	{"slot": 6935}	completed	0	0	0	f	2024-07-26 09:04:20.029214+00	2024-07-26 09:04:20.215506+00	\N	\N	00:15:00	2024-07-26 09:04:20.029214+00	2024-07-26 09:04:20.444651+00	2024-08-09 09:04:20.029214+00	f	\N	6935
74737a5c-f7ed-46d9-bdb9-53bbab4bd2ca	pool-rewards	0	{"epochNo": 5}	completed	1000000	0	30	f	2024-07-26 09:04:34.038832+00	2024-07-26 09:04:34.223562+00	5	\N	06:00:00	2024-07-26 09:04:34.038832+00	2024-07-26 09:04:34.317159+00	2025-07-26 09:04:34.038832+00	f	\N	7005
9e99b224-3d04-4e03-8bdb-20660eb2ef66	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 09:03:51.668868+00	2024-07-26 09:04:51.655566+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 09:01:51.668868+00	2024-07-26 09:04:51.66031+00	2024-07-26 09:11:51.668868+00	f	\N	\N
50f1779f-8443-4f31-925f-a5943730aa8c	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:05:01.104716+00	2024-07-26 09:05:04.109395+00	\N	2024-07-26 09:05:00	00:15:00	2024-07-26 09:04:04.104716+00	2024-07-26 09:05:04.124629+00	2024-07-26 09:06:01.104716+00	f	\N	\N
df49581a-755f-456a-93f5-aa2bbac3c01e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 08:51:51.651718+00	2024-07-26 08:52:51.644868+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 08:49:51.651718+00	2024-07-26 08:52:51.661404+00	2024-07-26 08:59:51.651718+00	f	\N	\N
ff16bd8b-93a9-40eb-8ef6-c804c9d32ca7	pool-metadata	0	{"poolId": "pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5", "metadataJson": {"url": "http://file-server/SP11.json", "hash": "4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9"}, "poolRegistrationId": "2500000000000"}	completed	1000000	0	60	f	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.659773+00	\N	\N	00:15:00	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.695969+00	2025-07-26 08:43:23.663537+00	f	\N	250
fdb8635c-799d-4f2a-9847-6cf56762d0d6	pool-metadata	0	{"poolId": "pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve", "metadataJson": {"url": "http://file-server/SP5.json", "hash": "0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501"}, "poolRegistrationId": "2500000050000"}	completed	1000000	0	60	f	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.659773+00	\N	\N	00:15:00	2024-07-26 08:43:23.663537+00	2024-07-26 08:43:51.702958+00	2025-07-26 08:43:23.663537+00	f	\N	250
a3eace06-d584-415f-b594-2a008019a779	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:06:01.12227+00	2024-07-26 09:06:04.133697+00	\N	2024-07-26 09:06:00	00:15:00	2024-07-26 09:05:04.12227+00	2024-07-26 09:06:04.148076+00	2024-07-26 09:07:01.12227+00	f	\N	\N
723b4b99-ea2f-4a8f-ba6c-00f6395f4689	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:53:01.834209+00	2024-07-26 08:53:03.843384+00	\N	2024-07-26 08:53:00	00:15:00	2024-07-26 08:52:03.834209+00	2024-07-26 08:53:03.865834+00	2024-07-26 08:54:01.834209+00	f	\N	\N
731cc594-5683-424a-a7f8-79af7619ee71	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:46:01.696168+00	2024-07-26 08:46:03.693154+00	\N	2024-07-26 08:46:00	00:15:00	2024-07-26 08:45:03.696168+00	2024-07-26 08:46:03.716459+00	2024-07-26 08:47:01.696168+00	f	\N	\N
63e99c71-c048-4ad6-af58-a27f65ccfeab	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:54:01.863363+00	2024-07-26 08:54:03.866336+00	\N	2024-07-26 08:54:00	00:15:00	2024-07-26 08:53:03.863363+00	2024-07-26 08:54:03.883846+00	2024-07-26 08:55:01.863363+00	f	\N	\N
ea507c66-f624-48d1-bd92-8cb1773e2ae5	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:47:01.714468+00	2024-07-26 08:47:03.713705+00	\N	2024-07-26 08:47:00	00:15:00	2024-07-26 08:46:03.714468+00	2024-07-26 08:47:03.731834+00	2024-07-26 08:48:01.714468+00	f	\N	\N
02400b90-e43b-4008-be80-df2115bef5ab	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:07:01.145531+00	2024-07-26 09:07:04.151231+00	\N	2024-07-26 09:07:00	00:15:00	2024-07-26 09:06:04.145531+00	2024-07-26 09:07:04.167504+00	2024-07-26 09:08:01.145531+00	f	\N	\N
a2712338-cd8a-4ad4-8788-6ea173a22451	pool-rewards	0	{"epochNo": 0}	completed	1000000	0	30	f	2024-07-26 08:47:53.024281+00	2024-07-26 08:47:53.763352+00	0	\N	06:00:00	2024-07-26 08:47:53.024281+00	2024-07-26 08:47:53.883095+00	2025-07-26 08:47:53.024281+00	f	\N	2000
ae205198-86a9-415b-89fb-6b4f780dc863	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:55:01.881014+00	2024-07-26 08:55:03.889772+00	\N	2024-07-26 08:55:00	00:15:00	2024-07-26 08:54:03.881014+00	2024-07-26 08:55:03.900693+00	2024-07-26 08:56:01.881014+00	f	\N	\N
181c9961-29a9-4ce9-947a-ed0dbaab019f	pool-metrics	0	{"slot": 7894}	completed	0	0	0	f	2024-07-26 09:07:31.821358+00	2024-07-26 09:07:32.303199+00	\N	\N	00:15:00	2024-07-26 09:07:31.821358+00	2024-07-26 09:07:32.496029+00	2024-08-09 09:07:31.821358+00	f	\N	7894
8e3170ac-36fb-42f5-800a-cec8b4952fa7	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:48:01.730174+00	2024-07-26 08:48:03.733299+00	\N	2024-07-26 08:48:00	00:15:00	2024-07-26 08:47:03.730174+00	2024-07-26 08:48:03.751475+00	2024-07-26 08:49:01.730174+00	f	\N	\N
89aca893-a3b2-43cc-83cf-ec83ae6faa8c	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:56:01.899191+00	2024-07-26 08:56:03.913277+00	\N	2024-07-26 08:56:00	00:15:00	2024-07-26 08:55:03.899191+00	2024-07-26 08:56:03.928931+00	2024-07-26 08:57:01.899191+00	f	\N	\N
51d1ae88-ca54-47cb-8b8b-70b29140f0f2	pool-metrics	0	{"slot": 2052}	completed	0	0	0	f	2024-07-26 08:48:03.411752+00	2024-07-26 08:48:03.766291+00	\N	\N	00:15:00	2024-07-26 08:48:03.411752+00	2024-07-26 08:48:03.970634+00	2024-08-09 08:48:03.411752+00	f	\N	2052
01bc2fb6-7955-427e-8d2a-9675f087c2a9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 09:06:51.661954+00	2024-07-26 09:07:51.658142+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 09:04:51.661954+00	2024-07-26 09:07:51.670513+00	2024-07-26 09:14:51.661954+00	f	\N	\N
0afb330d-4f2a-4284-a283-eb0907742479	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:49:01.749226+00	2024-07-26 08:49:03.752526+00	\N	2024-07-26 08:49:00	00:15:00	2024-07-26 08:48:03.749226+00	2024-07-26 08:49:03.773997+00	2024-07-26 08:50:01.749226+00	f	\N	\N
2350e7e8-2cea-4bcd-965e-2d123fca8257	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:57:01.92719+00	2024-07-26 08:57:03.937722+00	\N	2024-07-26 08:57:00	00:15:00	2024-07-26 08:56:03.92719+00	2024-07-26 08:57:03.961102+00	2024-07-26 08:58:01.92719+00	f	\N	\N
6987a65b-75d9-47bc-8320-13192e85863c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 08:48:51.660908+00	2024-07-26 08:49:51.642121+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 08:46:51.660908+00	2024-07-26 08:49:51.64951+00	2024-07-26 08:56:51.660908+00	f	\N	\N
0dad10d0-4d8f-40e5-9798-c8d6d4890caf	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:58:01.958847+00	2024-07-26 08:58:03.959847+00	\N	2024-07-26 08:58:00	00:15:00	2024-07-26 08:57:03.958847+00	2024-07-26 08:58:03.977978+00	2024-07-26 08:59:01.958847+00	f	\N	\N
b107f5e1-ff26-43e5-a496-6bd73042bfdc	pool-metrics	0	{"slot": 2615}	completed	0	0	0	f	2024-07-26 08:49:56.030727+00	2024-07-26 08:49:57.828712+00	\N	\N	00:15:00	2024-07-26 08:49:56.030727+00	2024-07-26 08:49:58.099596+00	2024-08-09 08:49:56.030727+00	f	\N	2615
db90f7e0-75f1-44a1-9761-f84cfc153ab7	pool-rewards	0	{"epochNo": 6}	completed	1000000	0	30	f	2024-07-26 09:07:53.024654+00	2024-07-26 09:07:54.314532+00	6	\N	06:00:00	2024-07-26 09:07:53.024654+00	2024-07-26 09:07:54.441447+00	2025-07-26 09:07:53.024654+00	f	\N	8000
69be4d76-1cc9-425e-85a5-3254457e885d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:50:01.771752+00	2024-07-26 08:50:03.783155+00	\N	2024-07-26 08:50:00	00:15:00	2024-07-26 08:49:03.771752+00	2024-07-26 08:50:03.805792+00	2024-07-26 08:51:01.771752+00	f	\N	\N
befa4d1c-e968-4a86-9574-a5b180dcb46f	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:00:01.002555+00	2024-07-26 09:00:04.007448+00	\N	2024-07-26 09:00:00	00:15:00	2024-07-26 08:59:04.002555+00	2024-07-26 09:00:04.026234+00	2024-07-26 09:01:01.002555+00	f	\N	\N
9e4e3f3c-5d1c-4de2-a7f3-a271aff3ae2a	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:51:01.803033+00	2024-07-26 08:51:03.808948+00	\N	2024-07-26 08:51:00	00:15:00	2024-07-26 08:50:03.803033+00	2024-07-26 08:51:03.832428+00	2024-07-26 08:52:01.803033+00	f	\N	\N
9477ab2c-3414-453a-bd6b-027168efd04e	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:08:01.164484+00	2024-07-26 09:08:04.171598+00	\N	2024-07-26 09:08:00	00:15:00	2024-07-26 09:07:04.164484+00	2024-07-26 09:08:04.179475+00	2024-07-26 09:09:01.164484+00	f	\N	\N
6d0290fc-613b-4da2-b806-c29b278e8eb9	pool-rewards	0	{"epochNo": 1}	completed	1000000	0	30	f	2024-07-26 08:51:14.020826+00	2024-07-26 08:51:15.864975+00	1	\N	06:00:00	2024-07-26 08:51:14.020826+00	2024-07-26 08:51:15.997665+00	2025-07-26 08:51:14.020826+00	f	\N	3005
9db8dc87-7da8-4331-a8ab-1ee603a232dc	pool-delist-schedule	0	\N	completed	0	0	0	f	2024-07-26 09:00:08.014543+00	2024-07-26 09:00:08.101469+00	\N	\N	00:15:00	2024-07-26 09:00:08.014543+00	2024-07-26 09:00:08.126721+00	2024-08-09 09:00:08.014543+00	f	\N	\N
6f2d3089-da59-483d-acb1-7258a0e5510a	pool-metrics	0	{"slot": 3161}	completed	0	0	0	f	2024-07-26 08:51:45.24216+00	2024-07-26 08:51:45.878069+00	\N	\N	00:15:00	2024-07-26 08:51:45.24216+00	2024-07-26 08:51:46.079739+00	2024-08-09 08:51:45.24216+00	f	\N	3161
d3d8574f-8dd2-41b1-8784-acecaf927951	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:09:01.17778+00	2024-07-26 09:09:04.195155+00	\N	2024-07-26 09:09:00	00:15:00	2024-07-26 09:08:04.17778+00	2024-07-26 09:09:04.213043+00	2024-07-26 09:10:01.17778+00	f	\N	\N
f212bee0-b86c-45b4-84d2-fc2c4ca22df1	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 08:52:01.830125+00	2024-07-26 08:52:03.824508+00	\N	2024-07-26 08:52:00	00:15:00	2024-07-26 08:51:03.830125+00	2024-07-26 08:52:03.836355+00	2024-07-26 08:53:01.830125+00	f	\N	\N
0c7e59d8-2129-4904-9433-e127595058e5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 09:00:51.669002+00	2024-07-26 09:01:51.654031+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 08:58:51.669002+00	2024-07-26 09:01:51.665601+00	2024-07-26 09:08:51.669002+00	f	\N	\N
410991cd-38d6-49fe-9acb-70ff4b15cc9b	pool-metrics	0	{"slot": 8495}	completed	0	0	0	f	2024-07-26 09:09:32.03408+00	2024-07-26 09:09:32.365077+00	\N	\N	00:15:00	2024-07-26 09:09:32.03408+00	2024-07-26 09:09:32.578143+00	2024-08-09 09:09:32.03408+00	f	\N	8495
b72a5a6f-3b97-4cbd-a468-3f3779fe33c7	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:02:01.044542+00	2024-07-26 09:02:04.051541+00	\N	2024-07-26 09:02:00	00:15:00	2024-07-26 09:01:04.044542+00	2024-07-26 09:02:04.068342+00	2024-07-26 09:03:01.044542+00	f	\N	\N
fb80e51e-00f3-4af3-ba16-867174bad79f	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:03:01.065858+00	2024-07-26 09:03:04.070292+00	\N	2024-07-26 09:03:00	00:15:00	2024-07-26 09:02:04.065858+00	2024-07-26 09:03:04.0872+00	2024-07-26 09:04:01.065858+00	f	\N	\N
9b407f67-9627-402e-ac78-6d87c3b9d278	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:10:01.210205+00	2024-07-26 09:10:04.216099+00	\N	2024-07-26 09:10:00	00:15:00	2024-07-26 09:09:04.210205+00	2024-07-26 09:10:04.233915+00	2024-07-26 09:11:01.210205+00	f	\N	\N
f66a6927-23ef-442c-af50-44cf8224668d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:04:01.08425+00	2024-07-26 09:04:04.090845+00	\N	2024-07-26 09:04:00	00:15:00	2024-07-26 09:03:04.08425+00	2024-07-26 09:04:04.107488+00	2024-07-26 09:05:01.08425+00	f	\N	\N
c2ab6203-ff59-4295-8754-bef1d8c11ac6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 09:09:51.673421+00	2024-07-26 09:10:51.661793+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 09:07:51.673421+00	2024-07-26 09:10:51.670774+00	2024-07-26 09:17:51.673421+00	f	\N	\N
b457d490-77c1-4278-9974-f7efafce4e5e	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:11:01.230917+00	2024-07-26 09:11:04.23184+00	\N	2024-07-26 09:11:00	00:15:00	2024-07-26 09:10:04.230917+00	2024-07-26 09:11:04.246917+00	2024-07-26 09:12:01.230917+00	f	\N	\N
6a6da9a9-09f9-47f8-8d45-56b40253c1a0	pool-metrics	0	{"slot": 9006}	completed	0	0	0	f	2024-07-26 09:11:14.32149+00	2024-07-26 09:11:14.413218+00	\N	\N	00:15:00	2024-07-26 09:11:14.32149+00	2024-07-26 09:11:14.575292+00	2024-08-09 09:11:14.32149+00	f	\N	9006
aa7ab4e6-455f-4067-8603-0b7edf8ece48	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:12:01.244126+00	2024-07-26 09:12:04.252062+00	\N	2024-07-26 09:12:00	00:15:00	2024-07-26 09:11:04.244126+00	2024-07-26 09:12:04.269753+00	2024-07-26 09:13:01.244126+00	f	\N	\N
aad75057-a09f-493c-8924-457905c37874	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:14:01.282444+00	2024-07-26 09:14:04.29122+00	\N	2024-07-26 09:14:00	00:15:00	2024-07-26 09:13:04.282444+00	2024-07-26 09:14:04.310093+00	2024-07-26 09:15:01.282444+00	f	\N	\N
6e853064-463d-4bc1-b534-93d71dfc5e08	pool-rewards	0	{"epochNo": 7}	completed	1000000	0	30	f	2024-07-26 09:11:13.227122+00	2024-07-26 09:11:14.413181+00	7	\N	06:00:00	2024-07-26 09:11:13.227122+00	2024-07-26 09:11:14.526055+00	2025-07-26 09:11:13.227122+00	f	\N	9001
12e1a932-82ae-429d-a6fe-777acf07b498	pool-rewards	0	{"epochNo": 10}	completed	1000000	0	30	f	2024-07-26 09:21:20.236023+00	2024-07-26 09:21:20.685285+00	10	\N	06:00:00	2024-07-26 09:21:20.236023+00	2024-07-26 09:21:20.823941+00	2025-07-26 09:21:20.236023+00	f	\N	12036
7c851fee-ee68-49cf-a95e-0ae3600326be	__pgboss__maintenance	0	\N	created	0	0	0	f	2024-07-26 09:24:51.686418+00	\N	__pgboss__maintenance	\N	00:15:00	2024-07-26 09:22:51.686418+00	\N	2024-07-26 09:32:51.686418+00	f	\N	\N
237f5a5e-81cd-4793-bc34-85ce5e043b24	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:13:01.266706+00	2024-07-26 09:13:04.267965+00	\N	2024-07-26 09:13:00	00:15:00	2024-07-26 09:12:04.266706+00	2024-07-26 09:13:04.285+00	2024-07-26 09:14:01.266706+00	f	\N	\N
680a75e6-d688-44a6-9086-fdd3fda37cb2	pool-metrics	0	{"slot": 9560}	completed	0	0	0	f	2024-07-26 09:13:05.029918+00	2024-07-26 09:13:06.472379+00	\N	\N	00:15:00	2024-07-26 09:13:05.029918+00	2024-07-26 09:13:06.642119+00	2024-08-09 09:13:05.029918+00	f	\N	9560
bda338c9-0dbc-4793-8b57-613705b92f95	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:22:01.43639+00	2024-07-26 09:22:04.44239+00	\N	2024-07-26 09:22:00	00:15:00	2024-07-26 09:21:04.43639+00	2024-07-26 09:22:04.458935+00	2024-07-26 09:23:01.43639+00	f	\N	\N
f9f15a0c-b082-4165-a133-01d0706f63dc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 09:12:51.673121+00	2024-07-26 09:13:51.66214+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 09:10:51.673121+00	2024-07-26 09:13:51.677187+00	2024-07-26 09:20:51.673121+00	f	\N	\N
e8672249-be1c-4db0-b1a6-5643f5c1cc86	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 09:21:51.683849+00	2024-07-26 09:22:51.670847+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 09:19:51.683849+00	2024-07-26 09:22:51.683484+00	2024-07-26 09:29:51.683849+00	f	\N	\N
6c94b782-be17-4a1b-8309-2a9beb09ca84	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:23:01.457096+00	2024-07-26 09:23:04.462416+00	\N	2024-07-26 09:23:00	00:15:00	2024-07-26 09:22:04.457096+00	2024-07-26 09:23:04.477991+00	2024-07-26 09:24:01.457096+00	f	\N	\N
ff4d9a00-62e2-4a6e-97b3-95b708934315	pool-rewards	0	{"epochNo": 8}	completed	1000000	0	30	f	2024-07-26 09:14:37.242155+00	2024-07-26 09:14:38.513971+00	8	\N	06:00:00	2024-07-26 09:14:37.242155+00	2024-07-26 09:14:38.623489+00	2025-07-26 09:14:37.242155+00	f	\N	10021
8f1a72cf-c9b3-4003-8cda-3bde013d9061	pool-metrics	0	{"slot": 10072}	completed	0	0	0	f	2024-07-26 09:14:47.417885+00	2024-07-26 09:14:48.519708+00	\N	\N	00:15:00	2024-07-26 09:14:47.417885+00	2024-07-26 09:14:48.741625+00	2024-08-09 09:14:47.417885+00	f	\N	10072
18a4c44a-5ca0-49a6-9f24-6b3b4b133ffd	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:15:01.307332+00	2024-07-26 09:15:04.309944+00	\N	2024-07-26 09:15:00	00:15:00	2024-07-26 09:14:04.307332+00	2024-07-26 09:15:04.327+00	2024-07-26 09:16:01.307332+00	f	\N	\N
6772bf2c-61d1-414c-89bc-394ced4b4ebf	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:16:01.324318+00	2024-07-26 09:16:04.33238+00	\N	2024-07-26 09:16:00	00:15:00	2024-07-26 09:15:04.324318+00	2024-07-26 09:16:04.349759+00	2024-07-26 09:17:01.324318+00	f	\N	\N
78d49091-044f-4fca-bb9e-290b42325c0d	pool-metrics	0	{"slot": 10538}	completed	0	0	0	f	2024-07-26 09:16:20.616707+00	2024-07-26 09:16:22.560126+00	\N	\N	00:15:00	2024-07-26 09:16:20.616707+00	2024-07-26 09:16:22.739816+00	2024-08-09 09:16:20.616707+00	f	\N	10538
70cec2f6-504d-4ec1-b51b-cbab44d051b8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 09:15:51.680439+00	2024-07-26 09:16:51.664996+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 09:13:51.680439+00	2024-07-26 09:16:51.677116+00	2024-07-26 09:23:51.680439+00	f	\N	\N
873b81a8-d85c-4886-beb6-40cb3f2ecc0e	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:17:01.347803+00	2024-07-26 09:17:04.348199+00	\N	2024-07-26 09:17:00	00:15:00	2024-07-26 09:16:04.347803+00	2024-07-26 09:17:04.365051+00	2024-07-26 09:18:01.347803+00	f	\N	\N
dd75a1ee-332b-4dc6-8611-02a6f6680fc5	pool-rewards	0	{"epochNo": 9}	completed	1000000	0	30	f	2024-07-26 09:17:56.231889+00	2024-07-26 09:17:56.601718+00	9	\N	06:00:00	2024-07-26 09:17:56.231889+00	2024-07-26 09:17:56.695421+00	2025-07-26 09:17:56.231889+00	f	\N	11016
fedf4fc8-dffb-41e3-8c7e-e39f531e42dd	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:18:01.362474+00	2024-07-26 09:18:04.367555+00	\N	2024-07-26 09:18:00	00:15:00	2024-07-26 09:17:04.362474+00	2024-07-26 09:18:04.376896+00	2024-07-26 09:19:01.362474+00	f	\N	\N
c9321709-9acc-4108-8e5a-1296b4e59f18	pool-metrics	0	{"slot": 11132}	completed	0	0	0	f	2024-07-26 09:18:19.412072+00	2024-07-26 09:18:20.608535+00	\N	\N	00:15:00	2024-07-26 09:18:19.412072+00	2024-07-26 09:18:20.875287+00	2024-08-09 09:18:19.412072+00	f	\N	11132
5e98f1ae-45e3-49be-99cf-308f00acc707	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:19:01.375351+00	2024-07-26 09:19:04.387421+00	\N	2024-07-26 09:19:00	00:15:00	2024-07-26 09:18:04.375351+00	2024-07-26 09:19:04.411584+00	2024-07-26 09:20:01.375351+00	f	\N	\N
da3c3f45-cd44-4ed0-846e-5288cfeeec0a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-07-26 09:18:51.679905+00	2024-07-26 09:19:51.66835+00	__pgboss__maintenance	\N	00:15:00	2024-07-26 09:16:51.679905+00	2024-07-26 09:19:51.680815+00	2024-07-26 09:26:51.679905+00	f	\N	\N
0b8bf810-7df3-4059-960c-dc5f4ad8ac60	pool-metrics	0	{"slot": 11710}	completed	0	0	0	f	2024-07-26 09:20:15.019678+00	2024-07-26 09:20:16.648955+00	\N	\N	00:15:00	2024-07-26 09:20:15.019678+00	2024-07-26 09:20:16.883881+00	2024-08-09 09:20:15.019678+00	f	\N	11710
4d24f584-5f98-4944-8c99-6c524409f7f8	pool-metrics	0	{"slot": 12338}	completed	0	0	0	f	2024-07-26 09:22:20.621958+00	2024-07-26 09:22:20.722548+00	\N	\N	00:15:00	2024-07-26 09:22:20.621958+00	2024-07-26 09:22:20.943091+00	2024-08-09 09:22:20.621958+00	f	\N	12338
44d3de2d-44aa-4802-9dca-5dc2f38275d5	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:20:01.40766+00	2024-07-26 09:20:04.408153+00	\N	2024-07-26 09:20:00	00:15:00	2024-07-26 09:19:04.40766+00	2024-07-26 09:20:04.426191+00	2024-07-26 09:21:01.40766+00	f	\N	\N
f8fa145b-f45f-47ee-9a68-25e76caf4185	__pgboss__cron	0	\N	completed	2	0	0	f	2024-07-26 09:21:01.423657+00	2024-07-26 09:21:04.421973+00	\N	2024-07-26 09:21:00	00:15:00	2024-07-26 09:20:04.423657+00	2024-07-26 09:21:04.439231+00	2024-07-26 09:22:01.423657+00	f	\N	\N
\.


--
-- Data for Name: schedule; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.schedule (name, cron, timezone, data, options, created_on, updated_on) FROM stdin;
pool-delist-schedule	0 * * * *	UTC	\N	{}	2024-07-26 08:43:51.682628+00	2024-07-26 08:43:51.682628+00
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.subscription (event, name, created_on, updated_on) FROM stdin;
\.


--
-- Data for Name: version; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.version (version, maintained_on, cron_on) FROM stdin;
20	2024-07-26 09:22:51.681797+00	2024-07-26 09:23:04.473019+00
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (height, hash, slot) FROM stdin;
23	874f5302dba09412fc4760302e7e07b583ab2cfad836c8922c89d28de0e14b0a	250
25	f75471b9e8f991b55e63727bf3bf2940b0e65ebcfdb59a91829d1be673102e90	294
51	e611cfae409856ad6ca34f0dffab657d7464277c4729eadaf9eb8ba6994f3bc7	552
52	bc97ee779eee2172425281da43e9a11a7eb5987e58c80271cd0ddb65eadfe181	558
53	dcde1cd665026a559e6e5e940df2f13774dd31f64278f802eebdc15ba026760e	561
54	e5df9a68e7dc57f5f9f5ea83f9851c9beb3677bdee9686dc693a26f23341718f	566
55	291d10f359a7d88bf6a95924a1e57b7bf220b0b1f3bd95644ad4d6ad63f69db9	568
56	8e6d31818933b56a333a3320ca4a0f59848338022a1533f8202b94af8367e484	574
57	3edc34a25424df6a6a62358a9a586c5b1b045d85c11bb95100f1eb8daa88bde3	588
58	0752fcc56ad7fd6c9b8f888d7fd217b00bcfb5330439c94d3cc9188a2bd702b7	595
59	bdf4863c5736358a8f73423cd85da824fbdd06cc072324dcdd184be064c1976a	605
60	a9c087b05e8e401302b449de7bcdd79f8a71f554a77e740c9c25ec8405e5ccde	609
61	641bac5b40c58e1512df687b69606680637c9c0f1ddbf054b103e58a9332b870	623
62	ef75ab72b02aa6e451504af0cfb930238b0c1119447c28f3e36e44f611353ee3	671
63	9aad62a9bee518a12aa556457cee19f9227f05d4d36aa20f5fca60b5bea41d11	674
64	3e218020c17c878e1411f3eb4b64d2d4a375d7763f35327ec55f661f50d9178c	677
65	66431b44e8966a65e85eb5b8b17fa303c623d302973fc827842c538172876845	679
66	9459bf7bf49447f4bac77aea1e2f047309fd0734a364101eedd6d46b6c90c8f4	680
67	a5b38da9df5076fe5c1d5c926606f70fe04585daa8799b89064c0d783a46981b	684
68	87c85933459f7be01e0de19658004ad5cd14a9a7077a5c60b41fbf03b996f619	696
69	6d2cead7475d4d3656990f57d964f145ddf0196ba48ca35dc6a178972144dcd4	703
70	0c847c2401e6ad26d5beff52f0fb033e49e50a894ce474eb6c8eee44eb19e2e9	721
71	d47e07c48d8b7b1d0c4f402d2b4f2f898b7787f80efe7cef7cea888cf67e8913	728
72	cc71b3cfe1462d4da535cc616443a9cacfbdeb3e27c8fb0c5acfcfd8bd205d93	731
73	6a01430798b6dab4d0e2d8daac468fa05b90d8b5a14a72a2c7ee6904fb906584	749
74	86cb3c573bcab194de31baf3efef2bf3b8ec25f81299d2368b009aaba94ca3c0	778
75	544acef20c18b6033410cb7427bd0bb20fc2c089c1f4acd480a84d754e594fe4	788
76	f5433d835bf47e7c50d03915151aab73166cd01ceb2aa15da9ae7d079f65ce7b	793
77	56a167c5f1c07e87157abe282c5ea069b106133f774582d34715be5bb457522c	795
78	07d8ca51d536d448686c7e6f9c986a0da4739953f3a38bed5112a3742bbece52	802
79	13d8dcbc86826a9a013ba22a4566f4870927b76a3d30689fc9a7acf4e066263e	807
80	f084e0d9e1f612be14ddd92c6121718ad6e02ea41959a1a2efb1bcd5fc2c7fde	810
81	c65b7c4736e1595290cdbc7d45eceb5f79c913ed716528768fe88470a5174243	811
82	df63198d7a39a1d7a7ae861f16cc726313a9e01a99e3cf76686657e6caaf97e0	820
83	995e486593865bec452d33efcdcba29c84ba175ac592db6ea233b0a4ed71ad00	827
84	118cd57bfba6d3d091a022c245da8800cd3182a5e300cc884dbaa8dc390fd19e	882
85	b10d0c1714453255a35e99c4966da86b8c1687a6c1474d3d1a2294851a3db8b2	939
86	32596d5f0d39b2d8e22e46857bf2d3072c0608ff7bb4e43032c9cacb46e76073	940
87	ded713794e955a71a85872521dec971b4074c46b9878414a48b8f9805862ec05	951
88	b90058d3354e431ce821289cb3a7b6c77d946f163a715008c7ad1f946e07f9b9	968
89	84f09a547f842380494fb096352d7bf390b0c6664a2521c74a1c35403de66533	989
90	1d67353822ef73825176ed8fcaa783aeadbb3917aba6acf223cea13ad2299019	1003
91	42548d5e7c9a9d1001bd9f4fa3476cf86dcc0d0d3d07446c8c3918c85e7345c2	1005
92	7fd89aaf12215ed0a06fdd4ba1208a89299a0c219f54654ebd64d91d191b36d6	1006
93	0e7c84ff9c641491318ce55bd20eb87f6989e41288996e2b77b8b74e0c45ac13	1010
94	4b45137850c0537ed3361b00371c61a559a4dfb3ca279ba4b408c6657d0168d7	1015
95	6dd1f94a6b8d2331948272f011005db45e254bf6d633ef8e0f23f68ea8e90ecb	1016
96	9a8630ceac9d5fd3b38835277988460ad67858bc49843ffe6a77e0d1b7875a84	1018
97	5a30de5fbfad88f2662f11f1ce215dd06e086a7ceea1501c925cf62a7f471748	1021
98	0178c924b700afeb88bb3b9ccc65d8375513ca9d186ace3e9a402a38897d5497	1031
99	f5481f872efa73d4d06602896899edb85bf10e1b203bd46d9c387b177c1ceca7	1038
100	5cebd9b11a52dd5e1e7b2772ceb0534458efa298a17decba8847077ae89c6451	1046
101	82105c0c3cbe4318ac0dcb92896eb1c70e7837c28259dd7c87458a6b5fd79ec4	1055
102	9f33c149fe24e924ba073e3c404d5cb5dc1f24621197eb1b7019c3719db6c0a3	1057
103	9b4f739f6d4c2bf488b5da3cf154306fbe2da913e3f86043e893868763e2a1b1	1060
104	6a2cc72318cb5ef559d69936e8bc853bbb5efb96560c20ec5405b9d1c4791553	1079
105	3d9c3bc77e54c02eae30972ff756b222be50d560d8eb093320764c23dc2598fa	1084
106	ceaab98ee4dcc1b2d749c09925ddbfda87d7c27eef09250b940b2bb8fb88a41d	1090
107	b705f4eb92ced54f1a5436430eac7df2dfbc5f36b1e889d372d42eb206d88f5b	1097
108	a57d57710d9b754c35f80af741435c6ea356df03e51829427aa37101e8a5885d	1103
109	1ed161a760e645677498deb785491ad0df48ea299a86ac67485a7b6cee63b18d	1130
110	19bf2a9f6caf974b3e8c256df1f9053aa0962f8dbc05839578b444675e8d26b6	1138
111	be627498bc5422e23053c0686459d11202a8d759715364b4989584a4727045e1	1142
112	d05d2f695ab645e687d0ba9e049bf5e8965b74a643810ad5698df4200b2fb8f9	1152
113	71cf228e41a652c6415141f7bc534ea7faabcde6f2dbf5cfe68fc921b6f4f3ac	1155
114	88617b694f1201436db095680501fd36064725a55e4d4b75968030f7c7b68216	1159
115	e8bc2a08afac25f9774910533d14f644199bbdaf430393bcac04f01b7862c7d9	1172
116	7331d54fee7368df107b58f87d5b5847537ce4edda69a2870002da94c39835fc	1179
117	7fb20980153dd76602934d8a0095ef1654e8a01a544760da5b2d89f7a8702684	1191
118	8274d5cb8c44a2c64cac465cbcd1c32ff112f6d5d40fc4b1d8fe467c137d6b08	1197
119	08bff7884e1bafc3dc46257ac5a3a5ca0250671b76bfd60a799018cf909d129e	1198
120	fa6fc47120551d944cb5489767140c5bd461165d04350bd49d29b32b352ff83f	1226
121	8d5388ee3923a751eec7f690203969453cbf5840a68a1cc046474d34d35957fa	1228
122	a2c1b89cc84d3d09bc71ad5d8b5a6e3a590b59f55e0e61b515be3923a2efa4b2	1241
123	fcdf6b5375e9e46b3721a30ea661cd90478b6b094acafaa24166651282ace2bb	1244
124	dfe53541d1d57042936b16df7ce370f4571598642f8b4ab0f6f5b35a078f4d37	1245
125	98b887b0dcd2c4d11bede35fbc95cdd3b0a04eb7a2d9578a92681dd683a5b876	1250
126	a8138b2b07a630807bc5a6a26ec40daa16f0454301881822f86f9c659ae77086	1274
127	cf35550bb186881d1c1e2cc14c30ac4ff9443f3d57e537223c547a534acfd073	1282
128	adfe23c65ae0e552e0ea2a0d0ec68c0fa42b0936619c4f779db19cf865c0b8c2	1292
129	d5a71fcf17a1f029cc5911cfd66fb42d3840902b92e75f9fdec7fdf5b16c375f	1297
130	930c998d55e2d84a6603943132610eb346d0186e7951c1f002d39ebdc8a2905d	1310
131	2d58c2c2aa00e5dacf476b678821f5603d2f4251aa39caf0e72194a5416dbc5a	1324
132	c168da1d2c3970f6a0c9e4b07f8580e62d4af86524b4bbfe41d59e8c8ccc4d91	1327
133	cab0fa52f44d5778b33944882faa23efc1d94f6eb87a31b9646a8e1bbd44e9b9	1328
134	096b9eb1a7b04cc9004aba215fcd7470098497a5f66602a4b6ca3e8c3d037ead	1335
135	5cb5c13570eb298b5b4596c0f38cf603d9d958856eb83de08f2a2bf8353d82d3	1341
136	5f3f73d7552abaa6659a01135f5b84c2a62aa6ffb0978686044db96146d6f049	1350
137	9c8b4c8be7aeb235a7806d4a7b39b071401bec019eec7492c03b60ebec5bc1c6	1353
138	b3d0b64a1da92f81e992911f5c626a875f66f53b64f7560fb00087f0d8b36f74	1359
139	db86ee30901d36a43f01a8508014f7efa8b75bd9e393aa67c1d472f4957fc9f2	1361
140	a2d018ec699ca0cb23aad32cf450d66bd77e90c242fc5ddb11da72f3e248ffcc	1372
141	223799542c0697c256e37db9025e645e241fbbee44a12cff1349f479315a2eab	1390
142	03183e63115a472c0d44cb946401df7ba56085d6001020d70eaf7e041be9d024	1400
143	373037f9cac33dba101fee860b18006de263c4bc4276ce714fc9c132dde684f6	1403
144	c2baa4a8a61b5b7aba1b233ce7eab05f99a40eb490c2a9ee390361cca3ac5865	1406
145	01e358f4254aab4d5879b1a9d7d884b19b196e157e9fac0c9ebe668748770b09	1412
146	24214518e87be939b5efa59085cce4e3a5d4579a10198997f6735b42607e869c	1425
147	8940dc2936b360292a91fe08ffb6fbff0f9079b3020b4aaab6775b3e4c4edd87	1427
148	f334ffa8ab6a94732812efa30e032ef23763487589aa8a36deab6fe9e6aeed48	1430
149	798047050b0574cea3047255712d707f6e086c1ce21646dacc2c1419f06c7d51	1451
150	d9b0bcfadc29d781b0860bad3ac1aea409d3b0c2ef8f895e59d3cdca8b2d28bb	1460
151	08b419814ccd7fc763a8641d08c174f88b5d38d2b6e3a8c784d816e3a5b9cc78	1461
152	6c8fe97d2811787b00ea0a07b63c901fa46bcda050e3ec09066e0df4180c10e5	1463
153	46a92ac04cf51edcc6146c55d1baabfa0d9285acf1dbd72184c5708403822e2d	1479
154	bbc9d3a3b1388537a4faa311f59e6f7e3309270068ae74371f243a71e51cb22a	1489
155	3f30228eb0804e8a8d2e365d015f30bbf50ef0098a1bf661b99c582e7a9e1c1f	1492
156	3eb41ae5c4a8ed01236d9a28fb1f97016b5920ddf785c3c758c30333bfed42fa	1506
157	0ed0b9b33186ea78e6a760a411ff3ced08dfe5470af65a519728b714dc09262b	1515
158	e8269c2574a18ecc209adb38d1ad9646e45768362975c5f671b3bf289e0be312	1525
159	7ecaa6200467021e82b23ebce78e9b63637d9cb9356b2ac74f84eb0bfd6a2266	1536
160	8aacc08d0efe10caea35fc789ab388ed72759d1829ef1b10d77dbe6b1bfcdcaa	1560
161	37fbd0421b40183cccdcc25715862a730ba80dd82a5318297c62a20f3577c9e7	1567
162	58e377356a2a79a395c8de2830c308cc4a53750e849bbbac22dd0239e824801a	1574
163	2968617b6dcaa581ddb72589e5f663cd2e0ea620a11d76dbc48b6d6a19d05c03	1595
164	750f78a9a3d7fab67a851be56cd9d6591700556442b74aca6cd9a9693fab585b	1599
165	4f4ac4bb95e704400ca82bf55f65831140e5bca3206f717c927324f23a29a3e1	1615
166	5035138e4ef0ed7b9e0a466fb3633da4a47f4a14bc83a7518c812dcf09e189d7	1616
167	6f3c226e868b4bb21712688190018accb96dcd1ab9d3c9c961653f8d87393401	1624
168	816e0c3aace019726004edb3faaf11481bcc3eb091184f5525a51056e1e9b3e2	1627
169	187f9686dfb9b05f12e843831d9c97c34d643bd80a6f75c0cbd4b0f5208b18cc	1632
170	7dd0079197590546c658e31eb09f1b86841072b8fa379811e5beb86c94650c8e	1648
171	5a6448186eb21d7cb391b4cef7bf005012becefcd289b320d37702f6baeb0f23	1656
172	0623702b5550c697758b853910d7b9099e279363a6f3e316557752cf9cebe38a	1658
173	37f3d4271994cc7e6a7e4c63dc16d43502d3c7e98ee25cb64b1fd3f0f6d34d3d	1671
174	f22cb984b9aac9f249ebf5f8b5e46b11d9f32be3d015ef3580d6e4447c20f775	1672
175	843b38ccb8230712b7b671ec8ca8f79a494c49769c5890c5323001d270db2bb1	1681
176	cb11640403dccda7bed70e188766a12d29083fa31c4fdd51cfd8940f076b9cb0	1704
177	5fd311a35d2c6f119b6c5efb4f216b69cce41f33116eee5e6a0febb0a17c19dd	1712
178	ceb1b56c0ee949599d0d59419f70274a8c27b4f5f5437a9c040155de9c2e1def	1736
179	5bbd61265938f634bdeb7f7f30d4bdd641fdc4e10603ee7761d8af7b0d1b0646	1737
180	35ce5e97044e9dfd83bfcd9562aa21587f5677dee5f8e95baef23592ce376da3	1748
181	fa70f226f4e2aa64e9c16a7a9ec9012dc0948c8ddfd9e83d62e8c1ae4cb3fd1f	1788
182	c0999d56312481067f7c1a56c2122f60e20df37c198b0a97324bd9a72590c3ee	1795
183	e74831aeaecda85a554578a29a2cd132a2f231ce3b16db3722368bf0508970cf	1798
184	b35cf985ce317cf74134e2cc17f414f8865e685bf7de7efd680b4b47622631b8	1802
185	a077227f5f3bcf854f8fd6ca6da4ed8d2b36ca6633820bc47a21e56fc6f0aa84	1805
186	3cfe4308d5b2f3461fc20f14431d6ef4456423ba50a37cbfe26c64a45bd4c74d	1816
187	73cf1742d52567831a448cb3033fc3b1cf3d10b24a24cad4cb64f486eeba083b	1819
188	df32bec7fdcbe79659377a4a2871f5c0332413e703d4a42856c436facbb7a9b5	1830
189	31cfb1be4081793d386630e50564791fcf87ecf07e8d2ba59b151e3b7a27147c	1833
190	5dadd4e565f539574418b9a799f55a9516516ef9dd33b97574a1be3882a4cb21	1848
191	041e988504360e0ca816b0848a841cc690fda277657b26c8348d40279d962f63	1851
192	7c6e80c117fc1d6956aff2b98e93d334777e546229f6d8fea4a79aa7062bfdfa	1870
193	cf5f01caa644d3569e12d30a9004a08d4af3be0df77a8ce531a8bc74ad141790	1895
194	acfd09cce697087d19411b23cffd9b3ca0187803592294e1f83bffb895ef74d1	1908
195	7e1ef71ca141e2f8f4cf30ec69da963c330770f0d8700fc3c15afdcc2de0490b	1912
196	1524d4aa7963c612495b3418a2662c8735b6840b0e2d116c9d8a8ebafbeb75a3	1913
197	f4fdbb38f31a9fc8dbded270f48e68c5ca6f3c7bffbfc7c1a362f7dd8733fae1	1916
198	a35d1870a58904aa3796b6efa96f9a18ba2a5b1f56f51c00a8a03af9a56e4c34	1923
199	fbe86f1a88cf844600f12378ca9ad3038ead018f2af881c8660c5bb3742cd15a	1925
200	1a9dd7ed0a4fcb03e421a4f6e20f58055c962b76b0758b5600ca13fd5c29fabd	1938
201	6571c8e4406f676e76ae0b82848f21e9e1b04f36c52197cbf08689933d4e2377	1959
202	b8c2a9dd2c97442283e23632bcd4563dace4de8b1b494650839345506e5b939f	1963
203	f0f177ecb2ccfbe24f968c281a7c0bb2a210d6af53ae4b5f432321ee09c01f44	1986
204	a39624884b6a1c30fb4252b461891b29aa10faf5a5c0aeef0f31f89601f3fb74	1992
205	9ab1fc774eab41edbdb62d1c23bc5ae9720968236d4dda867717337476c6941d	1997
206	4e1e0b16863e301865c2ca5a59003a88614c42d2e504f3cab222498b7f0cde65	2000
207	324b2f678a042f4137815f387df93ce9a11fa2a715d98696bcc134ff7ef0593a	2006
208	0768f27e9cf02fc539a14b0e07becc00a3df4394967070cf785440f857c742c2	2010
209	4427e6348916c6bdbedb0d83e277a5aaaa40d68083f8e31aa074ed95c53690c5	2033
210	a2489d6d764652e561eb1b75d105415146c4e824b61baff7d7299ec09d9c217a	2047
211	432f679046df21c378dd512c683da4759b45a2c5ec4bae2901a3cfe363b85b47	2052
212	6b9d80e76900e7a5203082e800cb8ca34f6eb6d8492ec5b126ff407892e49cfc	2096
213	e794dd4028d1208b112310f6ca2e12179ac512680606975a58dac67529d11422	2113
214	fdcf04d9ad824b79313cb6a5908f84f06d946f59d5ecccfcd710376e98640f42	2125
215	224999e50dd25637e1447d3cdfaec0b788e54963dd0b19d4ae06dbe2a17ad952	2128
216	3771092290cc57bce4589dacf91bfbf97985b4bc651aae547ec4ec1edd333ebe	2133
217	fc9f6ebbfac856bbf2ef0ba528075edd583f43ffaa049d4394e6fd6dd5231c19	2150
218	8bc6088d04795f5b1706bb56f40836be7d26835fb8043bdead51a34d96a99ff0	2152
219	f787fd3fecb461feed96fa45427d6a301c78c016cf187ec5a24e4736a3d6b257	2155
220	7539d40c9c6dea1e387a141bc16b04fc5370adc021a4ef296cc6f4459d34699d	2181
221	52a26feee7347b579919fb49a03825e5ee896fd7c947928f7db8d8cc48df2303	2184
222	bb0d2df3eadf5a5f544d8727664217eefa19a0660fb71cee2b679d79c5d11f4b	2212
223	46bb4c876030c81fc614d2968cd36adc8475825b09f2d46a97ba5e1a0391bf60	2217
224	945786a17afbd293625d268bbabb4663f54670c7cc9c0c5abc9ae3ce639259aa	2247
225	e0ad4aaf51c127adb8f3d234c0e447c6d2a24d5b841752a08059d628d85f2b21	2273
226	73639763335f6a6237d5deb3cd9ec8983dd3c165a0284b664af7766b255eec40	2312
227	366dac5d03a78eced738d08bca235a85b3f0878dba22076d07ad909dfdb476dd	2314
228	ed952ffae4bca5a58897007593adadf144521cc841c2f08f84d3985ae29ad8ea	2316
229	7d9f37b883e5a63a60c0caddf863aed0ebed0d8290fd5d0e6914e562361e5a91	2322
230	1f1cadc49c4b5d8a4be7426e57352a62cdbf25df1ef7b1c99f39985cb9970cca	2323
231	6b0c69de2533466a1d42c80b06057875003e0054f86f8d4e412f3afa17c74bcd	2332
232	f8dcf1c6e0733c9e095239690a4db1c7f6297c524606e5face2136188f261e53	2343
233	43803a1d143db1d505745d4906d18239b943ff1b38b259fb026806af5faca3a1	2347
234	776e158fda081620b4afe6f09b978ac20807f01dc59edeae09b3e5c3ade0e502	2352
235	e9610ee33d5df6f5dbc44b1343ec09fc9546854643f6ec2f836a87c8264301e5	2356
236	0c23e6bc66b5c41422cc71e5f7ab5a6a3ad92f1d78f9274b19460ecb0cc3aee8	2357
237	36f9571c306e456b490d6705eee2ffd4a57afa8be6c78d1dee2ccb66957a4df8	2375
238	287a6a8dca39832382cdfa1197bcbd950db47468f918b8b525f6a50dd81f9b34	2423
239	6c5fe3ca870d1f298a1df51ab739bd5e3a6b60d50ddf4dcae22ad59c481f1c89	2437
240	431d6f7a5f018b9f83edffbe9b7543c3d989252337ff9c105c5b44c01c709718	2453
241	3243c0d049f226ebebc2cf42f95d7fed0870dc13c196ea6451f8b1b72e567bee	2461
242	edab01471f06711eda8d729fb4f0f4ce955dffc0107b651c6c80a7ff6c3465e6	2473
243	0c620ca5c07b988c7380e95997f688a44cb09128df9390f7376a5fb3f48cbcb1	2484
244	5e79e86b983476e56a458e06b40b2cb19c804b441d200fc96fc47c85273acf90	2489
245	eef421884b8c8993e4e43429c1a9ab3b18b2df8ef56d32194ed1e98f8291c381	2498
246	b0a4af05a6085c0765cb92d285711f0fd0286c93b5679fb7e1a9852d7cbf029d	2527
247	368a1a71d223f27842e2dd789f9464902654c0d90ed880f6cccbed5716883ea5	2529
248	14f3e174ce0205bdcacca9cb227386fee01e6f5011d53d7cd5641ecd0e040296	2534
249	34d397d4817e7235b3b0ae5c72d40195764b3eea000747757671972c22c2dbdb	2537
250	f74196fa2121bed80e3683d05d854a3e032ae5ebef3c09dc393823210ea99cac	2540
251	490278cff1734ec3ee0bf32bb7f486838a98d091de3e8ecefb827d6288a319bc	2553
252	e79bbceece064f99a1e5ecab395146cae30c1927b0671d8ec5c62204a9a3775b	2559
253	31ce1048588d6e11b864ae01ba6af32c70d50e2ffea3cb7c5135ff8e19daeb05	2566
254	d7d36ba296399a207979ae74afce6ee37ea146343eccc43c5f4fbaa88771872c	2573
255	c8c9990c9ea40d8ce3dc6e1e14e8fac17e16b56087844228207e7ea69e320600	2578
256	d898f4c0273f2222d639058b7adfe24c7db5755e7efd88a7d77dd3666995077e	2588
257	9a8ecc1129512171433e4246b355c34e336a4b989bcb6e7f0111e4929b31b4e0	2594
258	2a08fb96781217848e5e2ad384f06fc79ffc3570e4f03df91fce821b9f0d2568	2598
259	416e72dea359b3fce1b69ea9686c84d540fd56ed609b04edad5885565a09df46	2610
260	5a40e7579ba44dd4c8a9321fc5a70d2aca337a8c51fc787540c9a2d2af606b7e	2611
261	b614e909a379698389ee676e4e4a6b2b655a266c1e5ad15db579026b1e68a1b7	2615
262	f78393fec7dbda9c38697358ee639871776045df434352d059bddf20d22c9fbe	2622
263	ae77bb26298b09fbc77b383777fae9634ae7b9cbb996adb2db18b2e0511dac9d	2627
264	56beb13a3c43a8a89b9ad117010c7fa8ae7e9a0cb136c584e31be9b8238490ed	2641
265	57e8df1b512b209bc3bc7a135249a00c74c4eba70f0300a79f48ce24e6a5cdc3	2662
266	2286ec62e8bb156b01710475f281a6b5c5883ba257330e3a7417f5ed7b2c889e	2664
267	300fe142090985261e015694e7de909d5cc95dfd54e1ea15dddc2497063ec38d	2695
268	c854976ddeeafb2afb712373ce9e6737c786a28243f9d04281e46dff4b33739c	2699
269	46347703c83be96a947b50c071e4a9d02ac13aabda240440625e08eb2845bbd4	2736
270	b09d8de918552e9a9d28f718a7ad503e96a98132742f94d33bce0f8114033d33	2745
271	23c40f1e792854db8aa073f1e275b80db6dab947560f371657a4cca8725cd40c	2758
272	307fd76f03247946e004b9e12dedb7eeda7d27796c5fd228bf43a7ecfc65f14a	2781
273	78f546cb69a70b2a5db3e4730cc32237d815f8fc5f70e2cd6567fe8c76031906	2784
274	6e2813544ed0ef334da119955cc2d06529aabd1635e33327591586bcb707f24f	2785
275	f994e4c60f0a3a0bc82df1d39f4db27fbbb7a983643b4c32eaa9e88919f40813	2792
276	0c965722b8ca3ec48f936ff8c85faeb2589006c985f6d73154ce05a1ef61b9ec	2798
277	d3e55642083c1db3b7fc078abd595d9c7b5f781fb52a04889dd4563709f19010	2802
278	b0d0b193126198a28eac97cbcab17209efda3c8b24f54175a63781a25af737ab	2808
279	aa1aa49b196b7747ceeab65a72420b30e3d7c1fe6190910c5b1dfdfe73c81abd	2858
280	889d55f74ca43aee4e787bca708c96a3734cef7c1187733d775e9272783b1b79	2862
281	bddb22352896a7260e7d944bdb0f4284ff518e5ceda96252b58fcd05156ef4b0	2868
282	d91b974b541b4d74c7a04fee03ea283a10f4abdb465c5f4180602951f37413f9	2870
283	4940b7f279163c8a9277a1d18c7d44ea470a53ea17cb1e5d3cfe90b4f6d9438d	2874
284	35bab7075bdc598895649166654f38d25b3b3e7c47bae5823d66ed7b4435ab3c	2903
285	ef3e27c1c5794a7ca795d7c66bf7987e7e05996935fc8d13ffab15a51b6fee0f	2908
286	7cec2f53aae8dfb30326b52b6880e86b49e7c5bbd9e8ed467ba8657274ce3e4a	2927
287	b8d96159c4fdb78e3193b2667d28087b3cb19bb0b587ab4a823add0d02caa363	2946
288	e9cfff67b123fb2902d495e1d44c2424e40b1e701b6fdc764d1edf02e72c2cb7	2948
289	9e02b1bf3ec24f9db3246ad6436d28f48e89632641bb736ef71aab2b3c262589	2976
290	4007a1883997d24e56bdf9c12a3fb41349f04caea3a6248003fb42325a80c4df	2978
291	b40f9cd50485c500abdd7a4c9744ece5f518e7429e6501a94dd5f4e6b80b18ea	2985
292	2a0b46bad06ce36e0496d05585910e4707ab8c31eb8b86048c3481f08f7f03f4	2993
293	49c0087604aa44df28c7ad88e27f7bd0adbd4fe83ea5b0ea4f5a855600cd6149	3005
294	f4652ac23668602c36409d9234e2c83051a204d706ad9743083a428e0edd912c	3018
295	37e8d12ab356d72d3fc6e4861e41bad442834a69c116cd273600ff1d4d158450	3028
296	7d30cb9ea2dc0bd0c76ca9c2aa49e38d69c6f8bb30ca7e8f5556f169fed4613a	3041
297	42106c9920f8a76a06b0b9a7bee58835b68143ced810758bab5286b34248f5d1	3074
298	0475038dc82a8c8738f7d9d858d38669617aff419e8a48e1464878cb09115a71	3077
299	b470bb3ec71021950bab0514f9b19bfd5453622f42e8021a51ef689852f5271c	3090
300	f09372a558f234dcec48a722c9851cbf54405828c7256240fe5e315e2a30e7f0	3098
301	98f222e60f4c1395551ed6b6c625faa12816da8fb7373d301e23856d7d54fefb	3117
302	2d7cb87bb65eaca62add5a9d733c3b99ecc9efe56c7ca237128e93654e1bfad7	3120
303	9ef8bcd478737bfe3d8410e72f99200d22f3b8e441ee97a5cc842f2efef588db	3122
304	75149761e5d1e43191281b3ccc27f6a669782eba4f06af45da0e54ba51403467	3126
305	1eda08f00736e3f913648ba01534fe44641a58167b2953de1897e16c8c1d1f8e	3129
306	9776bb0941352cb638464a7553f29d83eeca3ee124cddf07f964b291e5923f5c	3130
307	e7753d56164d239daf784afa56cba6c7412f1a38b6940c4318284aaae7c2fd43	3133
308	a0275cbfbc5a7e57ed4a02a768d5cb3bf63e2e6b3f23650e51d95cdee71c63e6	3135
309	8b261514448e445b015cf3674710ff65fef49846028f35689c244af7ded85f89	3137
310	06ee031188f843cbc2a2d3cbb2052a7f8b1380d9049ee06c93607d9392edf85e	3146
311	f9330b5712b803fe86eb5a1c9a46c508c9d17685ba93b02b5719f07e8ac60d36	3161
312	6aee3bb42ee31188ea56b90704af956ed6dd215e2bd2a46b81a71bc629cc32c9	3163
313	655a65f3220f277154298e0083c16e69dead00d72780daba95d1dece1b4c4e4c	3184
314	9f0d5a70e978fcb0541cd1fb2c720c6a180150019bc3fa40a927754c92d7ecb4	3187
315	a67c6b4b906f81e0f4e328e6eed0f887ee7ca0c8298b16346e17001b5c332192	3211
316	573d0b8c56a9191164668fa4f9e3e971551635ac22432444d06f8d1aabcebcd6	3214
317	49c91f981667cdedaae418c49dad54622d31e88756d68173411c308b37ef5dd7	3217
318	2d2733d518320eea275082f5c9ec7436393c153080f6a8f2bbcbd3715a59f8c3	3225
319	e1f2672dbcfed388d90a41814cc5cb36d8cf0a06caed83f4b0ef3aeb23cd4063	3246
320	7ac263dba630df8ee8be95f981f5a061a8888784675bd4de58558def00422a3f	3258
321	e64ee5402aba51605a0aa4a854b63a3efa3c8a43fc227a5be6c3ebbdfdd09397	3262
322	0af5222767f30aead1fbfc86c25646d6d8c05a81d519dfad7aa772d114071bbe	3275
323	9dd99f5d84e2aa7134861440412061a88230c00bccfff16e3358ebdc34b0b6a5	3284
324	0e72d770a7d198f6abdc14f64113c6c83dc6ebf3137ef8e77de01485359902f2	3288
325	7ed840c8be276dc106bc7daa61d896cdcdbeee378f7f6e578cd9975af3a1edcd	3292
326	df4a538d1b5f5a959e4660ea6c340a041945e40d29869bf574c9cfa0f7affc9d	3317
327	7caa4701491243db360ae2b06ca882448f70bc71cc417ff9968658dbf0559f53	3344
328	1d6137947ea02b5d05ae3c433214b82a54cd56d42f72669d64a70b1f703bed8f	3346
329	0d3964820b231f4a08d416aac10a3da90767b415a76c87897fd062db7dff7b87	3349
330	4ebcf3522572bcb4b11e81590e82c5c0aaf4ce65e5fdf48158562a43ea0249f3	3357
331	7cc0929412e3adffa871bbd3ac005a3e6292a5ee3e8f4d8bc65c545504fe95dd	3368
332	4c339f18be2662011832f248484317256de3fca363bb25c62ef54c13fb1837b2	3384
333	e0adefbce363d81e6e872e1e02be442debaf497531f820743ba9b40bc061e965	3388
334	c568fbc152bafa818d86e4b04257f1d7a65506463336395c7872a1e26c09b7fd	3391
335	b13e7713354e791f66d8b5272bd204887b6171dc2f8163aa7b083690eaffe6f6	3400
336	efb7fe65e8da3a864ae8853402c2dba5493afd6c5c459daeef7c5b1b1c4f100f	3404
337	a653bece77585594431129b8ab2d9372c3ad9ff5950cc34abf70bb04fbc7b9b0	3409
338	cb26dac5a2c4e3eefaaf379cc19afc7aa2dedfc7e404b6cc6f99b92b5c6c672e	3412
339	a29e253722d9e03285d2d181434d4e1b44d66b9d53a2371170a2dbc8ce8cf5fe	3425
340	079e0e516b6ed6bc493662a7032f3274dae8d8d91b514c5b851e2c808fbaf9c6	3429
341	dd11c13bac76cd2dbafaee5686d04fd6794ce3e80dff62514acda66add24c0e5	3444
342	5f1c9ef24d46868fb1b946a777923765a99bced2326b3fc4e64524236281b302	3446
343	807c4fefc5d344e7dec5ab18af1c63eb038cb336f7f7f60cd70e923710a6eb5b	3471
344	02e95a9e9906bfed6243c6ded04f4c76cfa20ab671ccf679e453e4f2de23c7ee	3483
345	e869b611f4c8df80c8102275ffc4bcc4eea0091d80b413901508b47389c05a68	3498
346	5fa8ab79fc601c782a6024911463aa52a0cf7ef5884cdcdc5dea649c932aaa62	3509
347	8eebe3be3d09aee1ee4b5386211b4c86ef29b0be6a061e693820baa02270b169	3511
348	5f171d5231abeed9fe4637fca6e1e16e6826504144fd6170bdb6c07ef4e82037	3514
349	53cad4c755b8bfbe91dfa81c94f9ed194c22a82f5d856331648a6f3fb47f1ab5	3523
350	ce1137d466cb65f9ba7b841617d3edb6f77bdd781b6eaf9d38a09f9a188b52b4	3563
351	e88037899d6603dea21e874c70551aa5522eaa0df506cf9dec387231f0899748	3608
352	16aab4c83ec0a5b662ccc162b0731de2cf7b2afe9fff9a2102593e7e8884d2ae	3617
353	7cec9ef27a4f57221196aa36909b0b83f1318bdcadcee45649909efa442e9239	3626
354	6e738fd8dd46664c6b065b5b142e0088953b37d0c3f5022653c8db8e6a015373	3634
355	141c85391a77e1a6136797762b5c4ddff0792330283ffdd60280e2e07b576d95	3640
356	8718be1c9b1f00516f76b244f326455710102ba64afe239a153be336b7d7fe9a	3652
357	9c3345e20d925aac68b6654f37f1cc00a924abc4e6d7424e0226e0952111cb3b	3661
358	d45e8757c202ba6c3939603bff87b0f14522f04a8a56c93dc20f608daf26a981	3685
359	9bf412dfbde70f925a016b2c1f57127f0293bc5d76bd4775e9c2a32a4e28c1d9	3692
360	1d082e65defc6a21157b2c425bc4fd39b94ae8c4ca09787a610c05c1e2a4e4a9	3709
361	a1e377913564ec8511d168f02d426e153bb2346cecafbe0f52f919fb2ba84507	3711
362	ecc76a817af650df8eba63da365fcfb7c0def3c528a6e248a44ff72c8e7d042b	3720
363	63d94ababb7cc557ddb803d3cded8c8d04567a684acd2ca68daa29d09c82d4ce	3725
364	7956a317b0e3f7d97f427828e2f7bb1d08a67f8bde2aea57ae0ebe1336b9419a	3739
365	eef5695b1acfcb35a8bdac49ac864ccc6bd3bf8154cf880827aff0038f979e5e	3744
366	9763a2000098cf29e2dc2c8d258352ea24f9f2c4948b8cb5769f6a64cf11ea29	3748
367	b8ecc5693efef376c6f0a2c7fbbbc747ef900fe99e70416fccd34e5fff39cea9	3757
368	d3d66f3919ec1fa2286c0598f874e38874a18abcce4c1298622a1c2cff452f29	3761
369	b4f7d69891f451a1fcedfde76f6ab94e16930167ef07c54407a1924838530e11	3768
370	b78853480b322b47f4425d2eac97052317ca9e2b3d7eda483a1469ccbffd5466	3772
371	f5af1a146611b8308a0293590eb74fd95d72baa89f9d20a5c1d26a160dcbf73a	3813
372	3f1dc9063ff72b5a203347bd4eac369d985a7833e3bef639dd54385b718d13ea	3815
373	b4dfe99db208e8999ff01de1742da2c2beeaeb39bedf2db365b1b563c420ec08	3831
374	7b098cd848ed49a4c7b26f8e0f4e4fc5f43c85dc60beb37a90fc9c1dfde41823	3850
375	c8b185522891e0ad83d4f083ec0d4fb7cab9498e6ceab17d8d6c4a6d1261eae9	3871
376	dbf228b8b60047b4a99ee80859bd6972276a3414f21a9f373085e000745290be	3883
377	3325ffc3d17245cc7367c97a0182f503557cb6dfc435ee94751db19e79e8c7a0	3907
378	55cb5c9c0c4aae42cef7310ced38beaa1212c54a63584b6d72bc3d00d0a2e7e2	3912
379	f818ba3165bcc7cd17a53da1f96ab991f53bfb4afcc67c9947b95350f7b921d4	3919
380	1a77397a60474023ffc86198863683a51d3f4c8c60502d762f61708f8fe81ad0	3945
381	859c12524f913cd0772adb5c16e24b61c30f7cbdb0a40c26abc4dde8b9557ffc	3948
382	e9de0ee1a282a13eaa1066bbf26e5afacc973bbd2aa5e6800ee0b8a269580fc0	3951
383	4ebac829efe76831a54073a02f3db40c29e31d97fbb7bbbdcede5c1c36fbf439	3964
384	5582dd1e7c4fd18013a0fa569093fa4abaa2f1a160d31f9a3346f461976799cd	3967
385	e69bf0939cfa7ca89b895d9ded1a6ec0f7e88eeb4bf4f99586c0bf6eb100a95c	3970
386	1c721de1b09d842a75fd915f39220a1f61ce56fa4bc4491b72b993ff8b1733d7	3983
387	4a3a7865cccf618326fa0b8d8662528f4a107066e0855941576798812b18c903	3998
388	6b70efc864a2afe69327a6561abafc8e82deb124cd40f5ff8c947654453d78f4	4001
389	5e98fe32153bd0e5eeeafedc738dbb5c660463a88d33bfe17977251a338af839	4012
390	05af50496de2ec38e074fdfc642cbb366df0c2f2d191a9d1053769f8f9efd439	4017
391	b4afdbe7488c64a72a42fe8133a356cf36a84670c1383033c108069712650bb7	4022
392	cf706af130717c87b65de3c20ff14e8f625d902a8c9e97ad17069248a53df5d1	4029
393	fbb90a2d8bfd5ba37cd008e0766767a2c9b46ef9f1efdc5111f984e4ecfd0700	4048
394	fd3ad96e2894deeca07a5cf433c62c4afd3bd883a5bcd3662436ed75847cbd41	4052
395	8dd0e24e8fbabd741a823f68691b86cec1132cbef03aaf1eaad0cc2ab896f01f	4063
396	205798b2de422043b8895b804d3d985323d6fb4abe68152402d0fd92fc44852e	4065
397	f29e6777098286ce8b939594cb43fbdab9fdbad7faa8dd52780263dc490f5522	4080
398	d515080075f263c1898eeafeb521ab04ffc417fb433d7dc5a8e86e5c97979e2f	4086
399	2438893d6dfded6f62ba0d4d817974d2716a6e37e5fda9673041b1a3f5b993bf	4090
400	63cdf661bfea3310fda8c31d9ecb29e4ac6410e5ec2bb80fb6d1eda613c16312	4091
401	78c36c2ebcacb251e012e86155afff033743aac5ff925f4d01a160093e317b95	4102
402	247f5a7667c5840fa6b6b410afc181315d37e5da3c25dd643e25a168f4f6d47a	4109
403	5c0b52924e215c30d2698dd978b2a267b3f6aeb713dd83a7d40a922afd36cc96	4149
404	db4db21a78ee71c6a7a801d933640bc766a451107df287fd14315d6f16a37da6	4150
405	49ecdd5e4e3df9592e44424856a91ef9d81ed80ec50e6b5386db77e74817b9ff	4151
406	aef95883a3024023f6e4c89477f4b37f5482c37ef8ab0124607887aa15b9d451	4156
407	8b1ac63ebc77dd220a17e7543088538a89bbd7f357b9c40b1ecf3dc12e8b66c6	4161
408	7e45b3116ac1a7fda905d3b8888a302df1cdaa3f8389b4c50c8e278e1504f75b	4175
409	8ce255262c1185beea2a7544b871392816da65039bed431400c2f71e4253c7c2	4182
410	a8a2d93d7593656633ca62779ac3768a3796e4375bf5bb9cbf3681e934aecaca	4193
411	e92232fce77bcdcd7bfdeea3a90cb3e86b63929ff022696b5f533efcf932fcac	4203
412	8ef573a7b46844d919d65958df2e10e2cee2edc487d2c917421fd7eb2ce706e4	4209
413	190435d00a6e152e2e28c72fecbefa49af26ce322f45d352695ddfa5e3051d9b	4234
414	744964e9f734704c11671804e44b88a007122bf0fe0612f84137ee86f1ebbd0f	4241
415	0da040a358edd1c60c53aa6aeaab4e65933965f422c43e86f1fd7d28006840f6	4245
416	54163f79acae52dc4abbfe1e511e3cfbabdcbabdde9251fb14f554192f0b6b74	4259
417	11355361aef08a386b094d30f11184bd6c8ea7ca0dc568e6f115b8c486cf0d5d	4262
418	c3a4b4305dbcf861a6f94a235973a25d2a788f01c7d6c596b092310d01269356	4263
419	d036be10bba37780ed9a6e552465cd799e058ebbe7591afe213f8b3a068818b8	4282
420	c15e40d50ed7eee417a93ebfde93457b5654efa9463de74d071dfe1393d20484	4283
421	d2dc1f3fe21fc5487b0d4aab4a082afbd2eb2b6d75f99bd8377108e9eafca2ad	4295
422	02138088722d85d5fca7ed403e468db83be495cc9d0b002e66d17c5c421830b9	4303
423	3a956c9f5ad98e432136b17406871df5602598f023b9f34a54cf8695ceb4c653	4313
424	8ff9b7ecae79a2a6c4486e286a336882acad348bc1e0ec12fceb232407658cfa	4315
425	68375f74f9ff19db6e68de6382fdbabb0b9327f0a93c2b7d0c28007a847c18ed	4319
426	cde01d891379d194e9f6312974cb10d1de1733216fbd11ba3ac54ed7a7c460a1	4329
427	e19928b8db0f746cefbd172a19eeac0c86a6257e2653c21ca8e5bfed0cb7c19a	4333
428	ff2ef2ee897dd460257bcc846ecaf1dd934cfa91e0b6f0b9f710f0f8bab71993	4356
429	973d08267541feb9c67aae8a2165b83b031227df074410c8ba63d72decc19305	4361
430	52d2d4c0170f20eafd2951808dd14d51bab25c6258eea2426820d18b5fb5a941	4363
431	efba0ce2e3794e9d9bec3cdaca6ba21c923c80520d75a3ac023a845d5f523281	4373
432	2d77704ce8a52fb2136a6b509520b83bf40b30bc1416433b54728db78407ee91	4383
433	e3a6a473d76d32b607cc98ec3b89b2f96e1129ce1ce6a5138bc28152c4bc15d8	4402
434	aaab1d9a549069f19f1fd255febb4efa95b14d745159f1f397d73b890a794144	4417
435	cab9d7c413395f0c07a59ccafe2dd3bad44d34669fa98cfa0d5989b1667c120a	4418
436	9776d1afb3d9cbe6a341d531297246507813c314111211909c7c19908faf6ccc	4431
437	fb36f7ec3621a28e5b2672c8ef3ea323b967e36d81ff077fe0b0f543aeaf593a	4438
438	cc16b71f9e07b7b5704663365481ebeba3e889467f6fdcbd6c2bcb3ea0292a95	4474
439	0ffbda0676f40c4aa5e0363d5972cc02bc1a9bf70cf99cf20de5baa8d2838eaa	4484
440	73ddcc8a2d87587f1067160662a391de2e0b2a5cca761d867900c9f3df2bea85	4486
441	873abea73d4959f6b181be1d3c6012fe3e36eddfaf0a39ab31fac5e20e218e3a	4492
442	062bf0894b3d8509ce47ece577aa04c55ccbce4e3e0259ae5c619a8416f89e98	4504
443	5f6159969d9969940d3554670620471d4f8f63bd45125e3eebf1fcf362a40968	4509
444	f626c17fa766bf250897cfeb6e58b9f6eeb6854bc08258496bbc88968eaf0635	4520
445	abc6774b3f0cc9d951150a0a4f2242435b8c3125db6c2ae0c1c9475f6d500491	4537
446	cb837819407849954cff93fe31a69653019b99013f6c32161fd776cb6771503d	4546
447	63daf816687ad7325be7eddcd719e684e9c1f61aa9e19efae43c5af45eb5e828	4569
448	d529932d5c25b671dca4a9ed7f898325f68b789ffb2ce49491368042fcb021de	4571
449	497b387196c3bf52a6b43219417a88fcfaf8f4bbae0d908db0f1df3fd8ae5efc	4584
450	e49e271c749df3ee7fe522fdf50b7f00d3eca54025b21281e73748f811b69164	4595
451	bdc443611d18a227e6f922097a24657a82bfb379ebc9d92f2e7d7680e50d19e0	4601
452	0d4735ad68aca6c620d3016cbfb3ac857358e8d6c8e96139ed91747c365a3a20	4604
453	677e7e446cffed4745bd65f3541050800f4cfd52e3cc6517796d7636f1b83bf0	4615
454	ef1514d5ac41e69bb017eef8c610bbe42edb45ce6660a2e5262f2ce737a9be2c	4622
455	acad00ef7fc6d4dfe21c9545cdf0436e01ee4440c9750b34977e671780ccd837	4642
456	35b59c1918782fa4a566332224eff2f7388bc45e306d38472a41b63718733ef4	4648
457	a0bbe5dee9c3765c371a3f29073468b47abc387c5448ee4d3468650eb61bf19d	4660
458	6741b09d5ccd04de535a9c883ca42f203e7e9571c8d81bb7b55b43306fc8e68e	4661
459	39f579851e2607db85c047a479363417f20f935a1983fe69ab9d8736ae3b3ba4	4669
460	a25ad1fd5410ecdc46ad7e80427c2628795abddf8a3699cd69a72447222cd457	4676
461	77ecea754fd1c5247289ef1143708ee60b1585c938bf0d3f01627082075954a8	4695
462	cb0a5050fac1945a3280b2ef596ff3a7f1e8bb0541fee0de285b2d6a322bf33a	4707
463	80e809284a5d96f8a6b41859c3209fbf63b1fc5fcd1fb0bf8862867bc469d57a	4708
464	923ef9ddf9a36bb0d68ee50589707bb31991445b06a42c62436135cbfe542496	4715
465	cbafcf90a7ee025c28ed5831010b085e4729b6e91ef86584654c397520c5ddcb	4718
466	cedba3941b28392d51d871819ce549ba622f32213bcc21a691e2786f2b080a86	4722
467	10ba9bea01eabf83c9c2db7619e27e4a75dcbc73aec698e71ff826b5412bd07e	4723
468	c474c67ab811cf27fa3a6422d23c19f2417373b968e020ed540ebb7d8f633cc7	4736
469	d29b3f641e3b5efc38de30f53b16acc632c46e01884aba7ea2d1e18c6e9845a5	4743
470	fc6320de6ee06ba6378741929ea5d38dbf91b23590caf6abc216668507dc9a86	4744
471	d28b02b19f8f6bae0f609d38fb4a81a4c47285e0d84fa08c5311646bb9f4086f	4745
472	c6d39c0347fdbd96f07df27721ad5a9cd15c869f26199c1310d715355c7ffe17	4748
473	240055d236b8348cc4734faeca666c4e6d0b495c0193c1475571feb8b4116fb5	4757
474	e135a0461b54ab9943c48be067b1ea978fe519ee47152aaaf39e13ee61942dac	4764
475	0771e6a2044c5f592ad0a431858bff741822e53800501d6e4ef0fa023963ad07	4773
476	802667e398de5fddf0938a462bda2c93667c7cdfd7c80768314854cd4c9f284e	4803
477	78ed56089080d252474d76bf3b4de0c0fb18d73fd8a15076fe125ca1b59bcfbb	4804
478	decd1b0a13262acf002b26def9a563394acd535e5d925e7adac4da86ebb789a4	4808
479	0ea56acfc021360d1c65d1b795ed03a984822b10e8f8f7384c3d2b6b49d80860	4828
480	fea2c6fd17f68a252a19115d76bd5c56f8af2a9794899cf613d52381b3474bb8	4832
481	5221410006c9683eb0aaec0fd68e8cec345df2d120df2a6d8b2342e29daf3beb	4838
482	ae25ca44c8cf4fba8d4d067719e7bb4ea4de50fdce4760e57f725cde4275279b	4841
483	2ad99d4a1562273f87d7f1ff3f2d6613298f6ca708ced1d07df4bc3ee8e7b508	4847
484	ab5fd5f041308a8b369c6e8acb64fff0dfd423f111b918f58d2fb2b0d6facba2	4852
485	0ce794765b3e5ed00fdf79eef49cbc8412a22fd30ed4e7f4ba122b99d2e1dafc	4864
486	89e4906e6598aba7fae70b2c37ed4ca1625c657fe54a5c55570f68d9e9e1cbc0	4869
487	eb46f64ca9b57dc8741e45a7c71264c52bcc16c457d65dfad1ad8987250414be	4874
488	9f247ad9bc79bb1b10d8b7ef4cd1acb70ede5613a392b60985a1a0b5bc044f84	4879
489	085b377392169ad70370248ef9fc5e7751d2554989477356ccfa339cdedbf2ba	4880
490	328f9fb6ff10cd1b35cceae09a5b1c6fc4f531c6a6fcde663e5134c7296eeb48	4890
491	baaa09eb7ba084df4e7ad98aa242bbef8902cd80c3a1e94b01a0317f4687bb74	4894
492	39fe228fb9d874f9bdc8477426d9f5155bfa58f8e99ba26ffc8ce6e2b8999ad2	4902
493	dca46aaa9d0358693c12465b6ca6e38c81096a63929dd0cd584cf8e206c65e59	4921
494	8592049ac245f416d3926ed6b7780235e496a002d53cffb0402119f51d2f7943	4940
495	7c028720bd6329a8dd230e7afa4b46f2ccc2bad449e6cfa8bc38307d890c43c9	4943
496	ecc6f8f5f1cd7ce4e2c26a02285048261831115ca988e8ba659f5741afdccc95	4955
497	ffb7752edcaef1e61c8427afd1d7959a8877ae32a4167bd0ea0b40089c9086af	4962
498	0ec8604c8740a73151f114da0c9523be22b75d82a698f4b8aac1de569d264985	4972
499	63a8c7e4a84f512e4ed9d3e0404c282d3d988a3ce35228b3ba64dda070776c9c	4997
500	62a0f84a92c951322b71d3ede43986382fdb0f5ca8bea76e9aa763971b81b257	5006
501	83103f1b8b459ba98f4d74847cdf042c4a088d34c0259017ef971ea6c28dd841	5012
502	1ea4ad2939b6a0d845346c86b6ca7bb03a2ff596350bd7bcdba19bda8f65b386	5021
503	8cfa484a6a8c5ac4e10be08b9a0497dea31e7be26049a816972f42a8055b6014	5023
504	4aebb4609d0d7f87146eb20e43343564e58a6c0dc966c47c706b5a4a52caf736	5024
505	3d32027b1559f0547e50101cc0b1e0f3ebf6dba18aba8fa53f4a0ae107673040	5026
506	aeb744909c26257edda2a6032bfb5b85212529ec685a2481ab4d67c3a1363623	5049
507	8fce72d0600424d3dd3c5d5e7d10c462bdc7a029851060a3b7e3afc7e8fde581	5054
508	8cd0daabf773f66dbbe710c0da8aa4ff449c8ef6c83cb4cb6483758d71e95e93	5059
509	66b267fb9bc510ec317134d5bd87d5b784e6e158b5b3174362d078c612d99e5b	5062
510	e4414a358438c6b813488a19c7699fd5e561d5e63e33091eb7c2c31cd3440c1d	5076
511	6c6ff32220ad3f976ae23bb5839cf8e6642de00f4c61efcf3bf8cdaeecf92209	5090
512	61f6987451aa85abc75a75d36f1e2c6ff4274026f710297b18e0cb7a12726515	5095
513	4623173ea92608e74ac5e2f86c5d622ffcef8499ebf73c1fd0bd9d450ff44211	5119
514	3eef4a41a6beea0a6265d4c5ce9b706d87e02b4860def05d0722111532e8307d	5122
515	45f0584289e6bb8789ed863ca0c02eb001578956d5d992c724a01d144321ba16	5124
516	75168cd78d53f1b689e0d237f8203db404007ee4b556df825a7d9b86407b596a	5127
517	2a957c3a589e13fe4cffa55bae44deb2a537a88593fc83fd8131dd3c51b28a2e	5134
518	f7cfc683cb342cbb69d3bb7f0134cb649cd71e9325138575011c285965f07f5c	5139
519	dccdb7012a49453096b40faa66da35f4f8a575a93de8aa59c593d159f30db07f	5149
520	dc5f361e949f92864f3471ecb9d4dcd39ac77652991d3ad0052b02bf7564291b	5156
521	1313d55f9c744d70ae10fb2b333093cde0a45d84cacc8fd42314c744fd17726e	5161
522	abd488db3d7a0d80bbe79b2917770ab98fe4a74c6dc31f89d9030c6871249acd	5170
523	7cd65224e529fbb39326037e75ac4d6f37566d6f1baedb8866f600d99711bf09	5171
524	a10092761d84489bf2d76fc1afbaaea21ce909604c37befc5cbd55c5acf0bb8f	5177
525	85c3feeba2138d2b094c40622efe0bdc7604efc251ecd2e8518c9d1a555ee71e	5180
526	76cb15dc176f06a1b33625cab893b98ebaaba92f412923e9064f1b40be8c5ccc	5198
527	aaee0f0447ea9dc642a3fd5952c1ac84b438b3011a2d6c03e553a1484d70c91e	5217
528	48961046c6e9a39583c2db02045d8b203400485b8a6e01aeb8a6bd25398f9cb0	5221
529	6e93cde1241dfa9a950222dbfce527ca126bb4ee5ff32b3b8daf835d8b495f6e	5224
530	5c5283da1e69b0d2ee9d7131dd4d411ce9e07099100c825461f7bc35b2129659	5271
531	3c91aebf8ebaac8f46cdf50df945d32071d57a3560aeef00b1e94889c87ceaef	5286
532	1bede9b32faf0da41b1fffae786d949ee48996ef8fe64ed0c88d484817373259	5301
533	dd0521863ddab8d69936a2b985c9102e66bd54d991108853c9d946254b489c72	5304
534	4ade81f547cf7a717dc9986d0f1885ea0317069be47fe104520b49610792526a	5321
535	ca4cbd183b42494d8c457f23a3cf2c2095e9a27a76892d60add866d82c48a315	5383
536	74b69ce329be86b42d27d93ef565711f593f066f9bf08f659da9d68ec69a79b8	5385
537	ac0839543b800c2d9abd0cf49ddc589501db211691d3d78a48a091d9b1aadb9e	5386
538	9991b42b2ca2681513378bfbbc9730f641a53dfe74432674a242382adffd4468	5405
539	ea3de198ae00b251c29739a1101f4af9254782a2be489dafdb4cb2fb16d91e07	5416
540	5245a9650fa67d55488de72a72d3b080875886f22cf8668fbab1c248d260abe8	5417
541	8e2bde91d11742c1681d9e97a0cfc75625307920bbc68a258791bb2771e4b872	5418
542	50e9de2f6faa75a1489fc2f28ef373ff9c6c6217c3a4b30bebe1e59e515fb86d	5421
543	465d34410903c72ecf065113de1aaaa10945234de623d8517dd2ee0183e681f9	5428
544	009ec677df074a1117892fe07cc6a1c69b48198c47f70b32b6c182dc0e0c2e53	5430
545	b4c45411ea8d5c341482fa2e681b149944e63fbd14dadb9218265f584b91d6e0	5431
546	40a4461dd32a767d8e803d97ffed95c3038cda0298bbd7f8ae04f28208e491ad	5436
547	93016b0a5b1a9ebf907be1ebc6672c3954e1c71df5c35c2b9b2fb02cb3a1813c	5458
548	144a4774d548ad272ac8f48ae97faa67a8ec09741345b213bce1431f306772e7	5468
549	572eddd335e1ce0148d132befca0d74a269a80da3aa59bef4bc3adc55b7a79b6	5481
550	1b3c4e098dd08179836e72b08c42937c63e8ed7ff990c4d37ed92fc96e1de9df	5488
551	6b7a68edfb6fb150560b12cbbb3aebd36b4b92132a13bb5ad4e04155ad3a3dfb	5490
552	d2ea7ddbc71aa5ddd965f90b1e9000bdad0d3bad4e4e60c747bb12effc8937d6	5494
553	d128ab67a344acd433d4ebaa1b869ee61f66c9471c25fd5f907e98b8ce73dad8	5498
554	b83cc474c09086e13a9610f5f2c96adbcd6b212f1630a9ca8dd003064b77cf10	5505
555	0149940ba2e1e86af2b9303d1363e708cbf5b66645c7cd9a1908e41949888c52	5520
556	4f9647058637903af168fc2beb6dfb256f67c62ea2cfa7536e87ff8fecdbc8f9	5524
557	64cc0c6b1e09c09431864719ff1f3cba80efad1526453673ae0d9302ce5591cc	5525
558	75448e06889751b115bc5ef600b9f1cb52b73c5d9bc8f58ec6676f081d93310b	5531
559	bca82c392c936826ace266036a8d23205c22c45c5680ecedf0c552a5b3823626	5532
560	cf3f5e3bdcba4ea5bbed520cc2647b12ed5e7cfe3e1cee32cc8b14d75c845a83	5564
561	dcb4d06b29dc962bf137f1de8e75455d732e98047578f88d85476ccb211048a2	5568
562	eaf0c0d28fb1df583fa083fd8c89b5751431a9a68e1c76ebff84bb12faeffbd0	5569
563	aacfddcfa62944fba3f086e8044e2dadd3f3b072b49fa144a0ec30bc1e6a40a5	5570
564	8823f47213ce9c0dd7e452f67738d5c598fd23592977f13b731de8de15147ae9	5578
565	3a68c3363500a3bab51f52a18f3030c8c861ea431de96d810af7f1e40c1a9deb	5591
566	304fdb6cb6045651505d5e347b6451ce453b96b926d89b18bc3c1d6f6a3facd0	5592
567	13e3c4ce39716c101f2a721f5d71e8208804b9776a05c6580407f0128ffa10a2	5602
568	d6378309102cc4d5586e854d3a903e7ee8cfb4723db18e52a9efe4f4c3e1bb9f	5615
569	aaac2900853f4997d9092aa8a9c8e7392918ef97b3bc4c4703fa56fb9411fa02	5625
570	68ed99835895233ccaaf8119b00e698a22d46bc20aad61bc305e624f88babc5d	5629
571	f9d06d498704101e97d3ce8dc9662e1916e6b55058a52b858f3bba7061999da7	5652
572	6bfb074831993c9e63e1f67a1fc8dc28d1a815cce479e417fc11c42bd9851770	5661
573	99d3991c2f6d2e48e7edc5a14b2e52784c15a5f22eec63f611401b3223f9a2fd	5667
574	ec546bf745b403eb864365dd06031222cbc09413654d677028caec54393b48ec	5671
575	1ddb2da97cd9c7dfda9d6ab3f0999d98c6788703c03c46270f3917dd889a5b1d	5680
576	7adf70df84cd023c2fd0e6a4390921ae69ca277ac3a637ac5e61fec2852c4a59	5682
577	ca2a625faf6069c6f5e254aafd59d2feafed13a5193b5512944d885961402c1c	5694
578	6fbdbe0fc9b62739aa9c389e6a804d99946885a59163af7d76b05a1d7e709af0	5695
579	ce38d49ab31171743f028a417d241a0da3c5f54a28f6c78dc86f22c91367ea61	5696
580	3c400a63fed6fb054c419f7830a2aad8ed8d9edbaa22b24a0366b9febc64f331	5701
581	d5bd79561e1c4a29210801c11fc6d4b480cd4ca3cb85e62c57ef2094efa780c7	5709
582	897b3ef57f3857e88369c0fdc2c7efb30fa47993bba6d5617d28ffac144a5155	5725
583	521611d85fdcd202f0b081e36778cbfabda34ee4550e16b641ca50c1b2197542	5730
584	3a93c01509f3dffcaa92b35fb19627152c0f1405eee98fcf2b91945173cef3db	5739
585	323c0c491604dce8c59771bf164b874ebc3dead031d190e299ebca323cec818e	5745
586	3155d17a232dbbd98cf92aeb665f9deb05c96520303013c47a865a1f66ee3edd	5756
587	8d2b7e058c2b70e10b70d7104874c4f4ada4c3e947afa7795399b4a632120c43	5757
588	dd182198196b6861c4aaca9c67c2d0386dd67fde98cab5e5511c976affd28c83	5759
589	7d6448921d8a4209fa38863c331ec754ebf54961f5cb3f1c58aa44b3ed22ddd7	5780
590	4f631c87235bae67ce94b9306379685a6be4530c807316bdbf056b5e0e9dfc0f	5783
591	6df0d256c7da82c7affe734a4bdda06598cbdeaf1fc37fd76df14f5a55a7836e	5784
592	7625feb998eb1c28c3821147cc8407cadd5264c64198a879eeb05d6c80b9d821	5791
593	1416e45ceb6190c1a03a4fec99e345fc476f33c4e6378c67c692c99938124036	5803
594	fa6d39e0186a8ec0bfbe14922c19ba8cae60f319b466b671419cba0135a0d836	5837
595	2a740999b1b4ecff178e252de668db4a6a4cf4e1caacf40b3c5f0effc66c3f5e	5840
596	647e919e04cbf8a765b2ce6908ef74a6cd2cbc88439f6efa9fb0edbadbf4e0ca	5846
597	ddb4de4660be0480e5e9d9a07348a614a62b742b50baeba59a7e48f58799aff4	5847
598	b127f667e92210441d3856c80e450e8ddff2f7fc4c5b732674a7d56d1f385b67	5854
599	e80b39d8c02d54f916491a7f1a87cabefe72307f6dd1be55d58f2a60ab28ae04	5859
600	3b7f27f831c57c4a73773af25105f8dda800b5a816d2c5a170eeea93ad24d1b1	5863
601	0e92a5a9a37f6fd3a94ec385bd9122a2663407ac5ea56d8bd7df168dafcc2b9a	5865
602	db44e0247b4ab490e935aad9232461d83ec51286487972f7701bda77fd903333	5867
603	2e5ba22af558102c0e42c4179d22e147fd6918ec77c694e0201753be77a89b07	5869
604	f8e6bae44f1093a478726f50927c4bc6d91ef8d41b694eb32384ed10edcabc6b	5871
605	33b77f77176e2c47c796c8bc554e873833f0829c333d809f6128bfa746040ba3	5877
606	16421f79e89548de88c01ae45528e800c50451bbcfe8ca4acbc36dcffca32323	5881
607	35d2634f4f46ec4775fb7f2101e1197fc0f66f44b6d3c9b5183037d2c3d27d9d	5890
608	622b7dde8724e910469ae8ff729c61c142e7fd64d7765747af9d58236638bd45	5917
609	c4d236d9353e1b28f9991853d8c9d4d72a92eab516469d5535871abacb5a904a	5925
610	e4885437440980f91c105b1eee75187bc5765251d4b1cf5e8f90734d65bd7197	5928
611	c5c9cf1744b43755dcbb852a75b74969790088c4ba6c8f5793feccc50789dedf	5938
612	06cf68c16771b2149f53efdc67f8d2c6949261cb27c1ff147d441d9320ad49dc	5940
613	1dfdf4a5773b11f350dbfbd36859a1bc8067bbaaac37af3c7fdb4c772c6e4881	5969
614	13113816000cf44b3fcb0fdff63dccf39e690f0dfc20dabd09147c179c0395d8	5976
615	1de664599c9062f8d3e953ddb892723fb6b0dda66730afef11258b812dbb311d	5995
616	8a1ac1f79c8dbe3aae0fdc633fc80b4e0d7aad2c2deb16eb82b59dbafdab00ca	5999
617	871289dc691704153a6c0fa1fb9c42a337af4947e640e65297245a77fee08c76	6002
618	342bd0a00e462925fc5b2c7926e16d386df798bb0a0ea72d92e9e4d41562d37f	6005
619	99cc0ceced4d968b6ea1f4b081b297f157616354fe57608a10b99156537d5fbf	6040
620	fadf5e0f1e91882a430543a66c5266e10f8ac61b0abe6d46cb546ad68c31203a	6053
621	9dd8a87a54e9af8526dd11418fb78c4d4f9e06c2f2c485745a25418352c428ad	6064
622	6dc69d1c22c27fab8ac7c94d838cf06abaec9989b527e7994ab99a55ee5763b8	6067
623	713657db82f7e1c3118c58efebe6a8e7ba5360b8e0818896f92ca250f4653c80	6079
624	5f9412a14052e67794e1a6286080262ef424204892dacdb3248fbe4791db802a	6107
625	f465b5626f7b868b34dcfc12c770768157610307d8e2cb492819307aa8e5f34e	6117
626	3a0f4213d2ee9ecf31a615dfad3fe63f8ea7ee5726fc0ec0cf79d72f5b417597	6140
627	b800eca71e71b097ab2b2e850bc4556ae9f9024af1a6a78361879cc5dba77fb5	6145
628	5ea0c406e8eb4757cb5ea550b389a50b0f9c9139c72bc4cc0f4d43bf0f82fc4b	6166
629	043182d253554301291f93615bdf3ec5c174df139bf16614d0f5ca30b9f58a81	6170
630	b44453003b4eb71a644c888673bd3f105e3e4d559a82fd4ed82473a206e7d231	6191
631	ef6bf95b2d1fc6776876dd15492d6f006038b3e7ed73b3f7c0638c668b9207b9	6201
632	2a92d6d6a268085159b41d4d809eabb2c97b3feab77eaa35edb8c55eb560b36b	6215
633	9643bccc47aa97ecee341db22125667b5abe7377e4add48e10cf2b1e8c1adf6d	6223
634	1199cca76828580acd1eb06cece66eb9db6c3f3e56f5bd68c820a36d46c68a38	6238
635	9c56da4831499016646386891ed24c7c0e1cf5a9c4202b7ab3c71d905168c479	6240
636	d160ca6546e7f162c0ff8bb41bc6fd52bf92a32c16948dce7ff10746c7e8f674	6248
637	c2f3f64637409f07e6d552d6a9063ebede1b4d908eb401b49bb729dec1ab6a03	6250
638	45ff07e5165fb324138b29b8072c5ed5398bbceb2c42ee99f6910f7d1234e599	6254
639	fc7ab9e553f4be443635b7c936b805c6c8d7606fbd49c83a0fa1c92f8735821f	6260
640	180eec541e535aa91dd0099a7812d6d460707a41940aadddf6ea419fc8702a8a	6262
641	cc9a6baa83e06fcc2289b5600ade4ac1c6630ff03e119cdf45a67ba18d6ea8e9	6277
642	c4977beea79cac8181ef6351e32baba34a52101a509cf8a92bd10405a32c3423	6278
643	a1d1239743e3bc10fa7e54fca67a44f8563dfa2ac7925ac3a24a1f339a7adad8	6290
644	b702b5cd6d446f2cc2769c37a1f093554a730e8a4563e0e5e11fc9244cb9f731	6296
645	906d62eece69a8a698e13dc8b7514b39062f3724f67bcbe163d2ec6ffafea134	6298
646	9f5a62897da6df46c6766f99ea7f4c1099d4ff038cdab4d7c71863a85bb3dfff	6307
647	e8d70b68595325c88be77a6c087612c9a96e20bdbaaf037db94e2f8d17a32fc2	6313
648	6cd993244ab639eacf50c365c56e63a77ce1c542dd5bb3dcb769a2b2c41df416	6324
649	a2678f1ea5917da50aedc4bedd04719e76b1d5933bc0fd01af1b0f848be161c3	6334
650	49c0da720bec98a02d362a4a103a12a4907dc1d37041eae9ee2c643e03f049ce	6341
651	95b7690b28835137d62bae817f90b3ad1cca358ebe5a411a645b88003d697cb3	6346
652	041656cbab5285977185b647a7bba1cff287b28d05af0bb1ae8d5f49b14f5fac	6347
653	89819a3a8d767f92d83f90b8e800c19f9b425a5b62f42563a78192b310e90c36	6368
654	66a529cce4f3844a4d8e9ea972e3669df696376591d126fc1501b46bc5e1aae2	6389
655	780d6e1b081b04295f015532d734c44c4a4a3120808963d6da494aec3f45bb5e	6392
656	9566e59ff9a2e59d7255499285ab2e9f45f17af8567b9bba3415d3cc07abcd70	6394
657	802a25254f1c15c7f36cc767b8cae6b3e77e2173159d70c1bce93be5dca38575	6398
658	3b8e53dc2821ce941e774e074835b456747caa44037e3acf49326e087fd21b9c	6404
659	1d51fa9ffdd97acd0bc54f00c2558bec98142a1b61b6424bf2d6904a6cd3614a	6433
660	19c14a11fb24378bca8cf2ba07cb2badbee8cbd19cdc43adddb4604dbc8412a5	6441
661	67b94f11135bd0885c9c90a974be03b0e0afa7a47b1dbe35003ad691714ee208	6448
662	92e78f2ede7dcffcb08e37b0ac6fd572304679dd4f897e4d9cf924918ec7ec6e	6453
663	16f0a89ec0059f7fca76d260197db96627433947ffc08d02b90ad535bceee8ba	6475
664	a7c3cf438eacfc2ec7ed933f0d1cc89fe0c7b028333e9287a292f87476933df0	6495
665	ee7e37b1652829266b8dbc5409b997b5be531385d447afe49d4954c3dc96a95c	6499
666	15c43d87419ffb032ab144a00710e1fe0e2626a9177fb9806e4d02381257a6bd	6502
667	458b6cceeabd4e78cad6fed4c2962ac8a69b26c95ae911e00f680d3db5919704	6506
668	fb559a5c4a298b0678d3f0decf14a816b98989c87b9b67acef614d1ef136b083	6521
669	d728fa3812f426ca0b1075a9d71011df32899caa049906c35ffb174a96e19fdc	6538
670	d60d7bb632849cf9c6a0bb99055c2840c1eb701c3f4b810e55815b2ee1bcdcae	6542
671	f8d028781508949603064242c987e03892572c94f920763b4ca0da521ea643a1	6554
672	5ef63c5246617a6302cce429edadc3f96aab2c90a337b3bbec9d24e7a3ac418f	6564
673	93880f7f375daece4863548cbd525c1e1d740f5d44d5c474f95abea6b296d0bf	6571
674	7b43253e7fdea465e824442ad30989f6f8ea4b1762d0beda94bdb90bc9671ed7	6572
675	e16d4f649de4fe1f50e662ce87b03206d262e7976d4e30980338df3fb1374335	6577
676	0cc3850d6b7fb9ddf6034c2ef3869a0decf064377dc40529776ca9aa481f8622	6579
677	5c4eed1325df6633a37fedbfb8196e426b7799379275dbe813b6f4b6c2e969ec	6592
678	7b12939ca7fac45c19a7107b20e7eca073eda48d3f6e046fba4b526828371e66	6599
679	aea9e31ae9fafb66970acb44a3490c1a59b2ca5ab32e5a0e49c98674fd9fa43d	6603
680	40e2d0f5961ab485363594fb32351c043245d9dedcc920aba12e58e52c257228	6604
681	e515334fc5a062b93977be0930b43ce9147a8012dba3a284ee84d3572b72a0a6	6609
682	02caa447261073886a25ee23632da3ff49a8904e8e92da2186458ac7629b2d65	6617
683	e58b7c652963afc3e8a345a39ae315e20cc886c151d3508581f592b2a9b751e1	6635
684	6fa201182088a70c4cdf88c4773260d09d0cf48d5528ab8c7d5cf8959c0f2d24	6669
685	0fc41381360a807dd2d74801d78af269225eda8a3e8a0e527052ebdb1f592040	6678
686	e7a48fbbb119c19feb0f53f7aca03287c70ae699a0c6e161c03b670abbd925f5	6683
687	aef6193f36f9dfdc7cdb475fefe2d9ce41d14be416119ecfdb6c7fbf549c1822	6684
688	fbfbe2f721d8947f3a4b01ac1657702aa1c213ca899804f718004c2da8d3a7eb	6715
689	268d5825a40e68ddbb8c8c077a4919d5bf04d98830c744a14e178a50d975ae7b	6716
690	7d53a6b48d474ca59aa2b67bdde72de2c0fc2702062b54fe6a94e053a338d48e	6726
691	3f8809ed9365935d25c70f38f5d9b8650568d4e3b6dff621be582a23f0644e50	6729
692	415442b16333b45f8aa545d76a8e2b2d54eba3b61bae5e1cf86695c3ba79a91f	6736
693	63d2fef3e5434a2368916ce9160a05cd58057280e1442f7c148d6621b0d86c66	6742
694	e5438387a39175bbdbfef6c1e7e2df35eba14e01c6841768dcd80d33b81bd6d8	6744
695	7ccf7841b2d537ccd9a593e11ba12112b96c46870d5aad8c1d77f50df55d7b02	6758
696	5fefd56a83e8f5a9ed16d82e36bba9215ae5ba06f29f6e5650f1e46e97dd20c6	6783
697	0bb2d57a754146efc434bfb2f607d9cbc3de3869c6060efddbf3e7b4ef389b76	6798
698	c817168d7b03775355217a721872a6feb27d3c45a42f446e4d4c5d1c113186da	6803
699	a71dff2e8b7aeadbdb453865df04dcd0682fe0cb27b5fb5ccfad3024fb284a69	6810
700	0aacd13e0d669262313557ba8c992f63bd02ea06870ce0c90b3e64caf7a053d0	6811
701	f863c51e0606f835afbef44ac3d6c67b563f10377377d6cfa6bd40152bdee96e	6823
702	0edb51e731edcb1da46906146cecef10e5b70d855345ac7cf538aa8a279ddc39	6828
703	916979737e15f9db7646e446406e02e618de6668e83adb3c1eabe1685cd6652e	6829
704	ed92785df6cb55372d54f4a821729c9a5b77907b168f5188a97dcab8ce75627c	6832
705	d908c54a7cb16b67aba8bb63ac32db9b8f2e86a5721cba61cc458566dc568da4	6842
706	0ada54efaaac5871252d8a6d06a341f3f5c37f76c5d7acdf51b46711322cd09f	6871
707	52a6445245880cb916848df8f952bbc8faa4e16a44b80b8b2c4e04db37db2f9a	6888
708	790a572770f3926336633647eb3178998f4090f33d42c00e481f20586a329037	6921
709	dc86c7ec75b4ed0c697293ade3890233ebbed49ea9648b648e9a22e969ba1806	6923
710	b35dbf2c2417f68e2ab8675b75e234b58b5836868712cd10e8faedd23b3c67a5	6925
711	85370700474f0578b0793d083638e858081e7b39d2d2d1010341254e3133055f	6935
712	62b2627c5e184353f963a3f881ad0a81a094c1e819bd6646fc117c4e4a0a8dbc	6968
713	e78e8cc7a47914861180b4b872465c31b34a0349a195451e3ef477d166fd9e30	6973
714	6db037f9bdfc5ad8871097fe4eb9a2b73091dccb58e17e95009145d0fe1414ae	6982
715	e40af3168d084d65c42171a4d43143a2b665922f30f392a17bb54742f43626cf	7005
716	4e56061bd79641c83012c62baf3078ba5401ec784dfc6c36cf2299979b641b3e	7012
717	bcc2f1a4aa18113ac4f9682df0062670528f1c5dac42be51087cb680de3936e7	7014
718	19dfb2b03b3969987c12f3c96fcad6c3220e90532ac4324e0d0665ac9788742b	7026
719	11dd71400296f731a0d82d0cfd235de7e4b97d2d504e74cc7decbaf6030aa3b4	7029
720	7f300333e7dfd904c3d06f008b9641961fc42e5d6942d84d109fdd5f9a8bdf72	7031
721	bac1de5c36fc9750f20c2572d6496c8029cb00fef813f1916e66249ab39c492e	7033
722	0c3f510bcc541fea46d9ece17f617e977fbc24a444562ddd607e1f3b0d75a005	7037
723	648e57e53d50f10b40bd9f8951cd152f3997ef7618a46bbe8ce426ad53085d8d	7039
724	573dcb414e86fbb4b75d1fa0e586addb32b1b09d4b31d9a1e7371f951a42c83b	7044
725	6f88378c112f85bda8db5ce7872923d393dff6531449796aecca0eca6a314b93	7057
726	d4b67fa92e5248a6902f522ce54534880161ae31f2b0ae534624faa2df80558c	7060
727	8b0bfd7010752d0ff34796223357921434aa0e3abf7c7b0b5f9e00dd9d958be5	7079
728	49d163ca1622bb2932226532c84a242486d7425442e969aac3e2ae978669f637	7085
729	c8463264ffdd8226d4a8d122a20356dd6052819fe572290b7b23788048a46750	7093
730	838185eb85838649497ebc2e5078ae19f7c5a7b9f1a4c9c2d6ec25974a2008e4	7094
731	d407e8d931047e92630032a2bdced3a545119589a731cd98f5036882a30a358a	7099
732	cb3b8f426ec5cb0a5b3a28a294d09f890ef6a3a7b3c764e6eda1a9e1563b717f	7107
733	72fdce71aaa178a7681a86cc84f2b9935afc09ea4e3a4ba83f48efd3aef63f0d	7108
734	42e54b1235d135d7fa006844e787260a5c55337eb1b75ffb516ab8f64a01aa4d	7115
735	b6af7fdc91f603f2318ee4c31cd488ffc8dd8bc85bcc9238f17554e686cb8e18	7118
736	087a9d197b9da6bcc6f6050f87af9316e9e6bc47edbceb2707abe36d2ffdc851	7119
737	52bea6fef3d5fc5bc4b6953d1d0cc25805801e7d1bc6a95e2d19c8b87a4395dd	7145
738	754e63728f31a30368c8f3c72bfd2a48e88c73e602f70846d55f074625ce9e4f	7147
739	3c010588d7efde5989d624496c7edf8ccf60ef4e1d49e18bf50204e88f73f146	7158
740	ebb789c8daff35927c673dc5c85f4fbba960244c713e75db1ff77bb89f2d29c3	7161
741	b754547007867812fac210d85d5f00a4630e5b6f2917ed6638213b1812090499	7172
742	cd4be353166ac83163fe4408d4399576b7da7c7e59f76dfa375c1836483b515d	7174
743	e20371b127363d0f4655d4a218b6e2f1f08c7fb63352843735c02cad0e51882f	7182
744	e1259d4e49087a23834e5b4d68eec89263a16d81c5712fe5b52576e0dbebd111	7190
745	275b330168505c1cfd2f409dee19b295e2f98f44285389d4ccc8cbaa9228354a	7192
746	a0a1bdf0455e64ae7f4ecfd48df97a0bc8523bbcf4f94600efa013e757e65727	7209
747	475c16fcc69cb892fbf4ff4256d491ef8fd0657951899fdf5895c6412a3e9ce7	7243
748	2bb7698d143af0057170f75295981b86d83a31e6688263ad21c9e02c96fd3e24	7249
749	c0d218f8fa215037b33a445a0c11ab5b4a26ce8510da79190c1e04ef66f6c89a	7274
750	71d5e1cebc62104c54883afb283f82d61b1e33c697212c8d73de8d8b5b8a3893	7278
751	06626f0fb2ed46b3dff700ebac7f94144f9e22a9a007b5355e1082047821e3b3	7293
752	ec54fe4b7b3faf986f4fdb11b519f1afb159948cde010ad3f4d1a4789263c2f4	7298
753	e71a2e37dac9613d694c30f1616d39fd5fc48c4319dbb4f63d8058cea6e7305a	7312
754	6851ac467bd53e25ba466079a42f2cd475513f1ccfebf1b78dfd65788090d90c	7313
755	699a62f80ab7e6d725cd09e8bd14bbfc4c6c7ae8b8b671328027b0b102d32e81	7317
756	9f19e89429039d465dd3bdff8affff0279f7ac1945d3f3a173014a48335d10cd	7328
757	871b886323926a142be05e12d89953498fe81bb3a6d4dde2c4f5aeda4b324073	7345
758	7d0cc309675ef2b9db41737efd6626dfbe94760bfed6a57db8b541daf563316e	7358
759	44a0fb8c2165a208aaf93c9af227203f991fc06db00c42c69846583d6fa8842b	7376
760	4531ca7a676e6b5b3499514ca6f4d370dfe7087a5a2099a20a418c80d331a3bf	7380
761	ff8af0fb15e77b1df9543e3ecdc3508af4979e35bed0daa4d96d0c24f6c2a32e	7385
762	eaeae5986cacffaa0226e02db27790733096a3b098d5be014ceb901c1963a6d5	7387
763	53f21ee177a2019df0ea080878a9f2ec7dab63aac5d46488520c0da448c3da3e	7390
764	aaca603f7bfc226fb85d32c40465cd5117480b6d6a8e294671cbcaff237a2a10	7411
765	5721865333c8d41cbef5034075efd01d3f5d3e8dfa643a2f42d5b0dba6944066	7428
766	8a5018aecd57b3ff35c46f1cfd732551ae4a33b28d320b7076139871e71f29ff	7440
767	0f92b91eee038b3e9c0b83271cbc6bbd593222603e03229a2905ac3f75984b6f	7453
768	f99409698e018afced50aadeb9aaea143abe9d8b9e75fcc78b4308d7ff504c4a	7455
769	27ab51c3b99ba053efea6c896480d93acd600030b35569b330f895f16994696e	7468
770	929df2d6c4c47e31a670ee550dd3e492210e1654f968cac9af398c241efc4f0a	7472
771	e6d0dce6628599195f4d269ad6cb35aa227251ce5b6ef828055914bd2035cbfd	7473
772	2a516cb60537a7c261a5df349b06a444fb31ea416dd1368ea2c1548ec836bb53	7480
773	9a2b659cb5fc2412f90fab5c2de19c2f0e7bc422eb14385ada45756d3d0856db	7492
774	004085ced155829000ad65b212bed8d7bee935b56931ecb69ff40c7eb4285af7	7495
775	774e15c2e5d877fffd11bbaf6adde99b25aac19ee1f5830c7f940c30d1767a4b	7512
776	24b3d2005cc443baa4ee574e69d80fee0e1add277e10a425fb3cdf18936b35e4	7521
777	9cb68fda9e34b88875c1b79e35db67f05e4e68350f6a4e7d854cfc748b8e3f32	7523
778	9e72b6e0241304e7eb54b83b081b584010eeda7ee07fb2eeaf01a23e3fb7ac3e	7531
779	15778edbe26da8da81939e63cd003d536743cebcb1dcbbb5c3014cdf5f24edde	7534
780	c962bff6d3e006c63c87834efe4e44dee63e9d04a1875b1d2d25fd5eea1b9f3d	7553
781	0413c77a1a7359dc7c686ad8b52931a99e189de6aeee12616160c07ae5b06461	7554
782	7257b0e4931769a3d08f5a38515280c4a1a602800b45ffed2e8afe4d0a37fd29	7565
783	fce7e162576f3ce0a728233df68676f02bc9186ee47e611b7243aa0cb16532b5	7572
784	1690a6e36c4631b350274fb65ff72584a716d32aa7a3e63a6fd92787d62c51f6	7575
785	15aba6bd044271477e202dff9ef1866ba550bc2ef919a4ed46b54f8f4f44b6c6	7576
786	10a055ccb6e46ec4fa278c1be7050b60f4af3372f6433dea3f9107140e6b3b7b	7579
787	7ada2cdb42a0d0559ab6113de36b90399f8095e8e2b61100020f514aab9861d7	7587
788	229de27cdd882d3c18a9ac865823432176ce84c74e615fa2d2712810a9a7e2fd	7609
789	9f54d4280940aadd1ab819d239e46784d1b2490e2619c88fa84eadbf49a87804	7610
790	caa0d4220b5beb421cd796bd820ad0f9c01a70f1f447eefefdcf2c60dd85b711	7620
791	d97e8fea950e351dcb4c0941a557e97b0a0e536044c9f94192cd3b3561991d09	7639
792	52c3443e79e5a79d966e32a9a596c8a0d9176b504a77fc0145d52d7af5dfb158	7669
793	154109ff32a401c170b0e78635efac3341117ac1d816c22fdffebbe2a6fd9f70	7679
794	5604cd289aaf4e3a0b4aab6fcf98fdbe12e56a7561ddbcbc635fede8bfaaedea	7685
795	784bf9f2f17e5f8f2f8f7094f9f41aa01ffa7aae8dedfc026487ca69f9768ffe	7701
796	df19936a25365ed52cbb8574fa47f18e97bc4fbfdcdca15b290c7fffc49906cc	7715
797	352d431a692998845b19992c260782824aa6e260a5e2c5be3dbb606777fbbc32	7721
798	1b66a0fbb72cd0982d8dc0325708f49a942c9f5f6d60bea78e2c3bacfc45cdb0	7737
799	8115e2e117aac134cd245edb67422a489b56165d407d69d8ec70bd3ebee6b48b	7740
800	d7e2debb1fc62e360302d60ee0fbda32450c82cfb800ee712b120d904c0ad21d	7744
801	3783f7d52d9302769b4a9277c8e2fc01c8c0cd57b0d7256e00c04563883bf1f7	7752
802	afbaaf08bd3a6a39bab88f0d73c3f38532529ca1a1051f206646d0d4461d1959	7757
803	07be45797d0c69784030836a15bf024793bda0a9ea86117c70fe015817c488ec	7764
804	92c2c771fcf766bfd1434d00364127b699cd52f05a8a0f4a3cf5f2b38630885c	7767
805	42bf9365c003f4b636821da7e1ed416c6f6c88d755a0b52bb700cbe5226817b1	7804
806	71125ffb91d161282a0c67062c9cdb11d35580c94c5f8327330f81d8b94220f7	7827
807	c919ef0b0d46f091995a1307876e05b55d4741b36527f21d04d3c28a51edd55a	7843
808	2f0c872109c10bf5ebc5bd3963f26bd017a3d5a0c6747ef80e9810856fb1836a	7848
809	f37d296aec1875f7d48b8aba2638b48e379ca2acdf3681af33c11e4330b772dc	7854
810	c99e579b53fd3f3c9eff14a074597894686339b6d8fa635fc860e5c2fd6bc099	7881
811	f65993b0d0c7901ad6d443be9e1b39f5a008df9daa79add0926d20d8e35cde8b	7894
812	22fd74e18f3f228285c2a0eb427316f915f1d5ccff9bbff788f9f84c7b0bc492	7903
813	3b4fffd6039b6e1864352ca88bc7312c6b0df34336d062b02bca270b7cd58a47	7939
814	d815a81c3e4d199d3cfd76b5e7e18a3a0ee653ea3a898fee6efd59b6bf710c29	7946
815	e3c11c52c84d206e685d51c420172c0355ad74caf28a6acffe479cc04530f823	7962
816	fd79bd19d8c61af4b47d2614d106e75c5477f1d7f6c5df13faeac22cd88fce3a	7963
817	a7351a91355935833cbdc7c1c9e3fd3f48675882e30fa133a8d9a178e39b33db	7976
818	6946adcf47c017072731f108c7aa722cf5d1c65ad24e93104eadcec2ddc2598c	7977
819	dffb99c10bc7fd85e8d73046cbc284e4f07bcd4cabe73b22ef55ba199f963940	7992
820	b46532a96bb8914b6ff98f3abc5ea2c29f4be079062dc0dea3d4e84a81da8e38	7998
821	0caaeddb0a67b24aedb714e7225590d0aae8749ed841591b1511a46dedab4ac1	8000
822	29dbf5e83b3700054a11d380d5a8e1fe580f074356dace1966cf702b752f49f0	8020
823	e8ce363287501c06788aff512826db81e336189058dd883ca6702054f26bbb90	8034
824	faf7e9b8a23c3b069953adcf127e2742ef0a9511fb275adfb74e150764ba9829	8035
825	a576372695863275c3ab6c1a38157accb0b277a1cf47f42dae80af24841d4d2c	8043
826	c2df33e3ca50fa58aa76dbabe7cbbaa3692b063e480c7cd721ce914deda18e3e	8046
827	c69b674b1e74e1acbc50007424192c32d43885cfb2016a46a10605eadeb517c2	8050
828	c52427b0a6578a7274ff430bcd0b4b8a0efb4e0385cf13abe716fcaea56b3e2e	8052
829	8acab5f9fd84a1e682455f4cea79b0eefb58b9e9ce23c7d508c6bd7c64cac552	8061
830	e20e6b2bd231bf52638ed659194d06b69e21b0f0dea4fbe2e72bcc6eaa091753	8066
831	6c0c3cba93f1d42e06fc45571c469e521e76065f219b439de44be035105f7a5d	8080
832	bcb1e7825c003fd87cf214522e97a9f94b762c45bc8a2390a09520e39750db95	8086
833	b0028710086facf75b6979da3dd54dd99c27bba6da10b25feef3fa034b5b986a	8098
834	a785bb89c0460f68e9bc0893772facdbbab7a70db50165853fcf03ea8e9c7872	8112
835	0375f628ef9d1cfe99729ebcf57e5787e482c9772702576ac0588bfa2e6d205e	8136
836	1da0a773e26796c7795cb8c401294801d7e4cbcd2fc8eb652b7ece70dd36c9f7	8139
837	0eb2f209b202d944704d508269560b7dd8146d65e14d489b0a642f2c32f34274	8181
838	a4ba66e18b60f5e71620b80ffa5b10c567f901737014f81371297fe9a81db6ce	8183
839	29128b94d7f7cfcdb89e95f033259eb9b61ae869df6191cdf10f963d83a3c5eb	8210
840	345aa40ce6e296a436acaec1ace0b78ea6fb4acf36f5c82ffaa205f6c234d8ff	8221
841	977d55e97657b775f8847fcacd76dbcacfd2982c2fb45c571aa2607dc6cd95a3	8230
842	79134a8a8a5605c5226d43ca5deb64365b93889fab6ac918f4e302948453fc3b	8235
843	5d32e491a849862f3ccd2f091ac6fb62a882d131d50a1c9d398fd26ef412c6d7	8240
844	b80ebca61c1760a0d00c42e564d6cc3d4f356f342224a8255fd53510a51d91ca	8244
845	ea74c36c02f1d9814723a887d9f712ca308ea7880d6a219bfb5e860d9c62092a	8253
846	2b1053e5260d846abe4ba642b26ba6b31d2294f8460151523e3f5703d469b8fe	8262
847	932f410841c23320a2f8624c1a752542beb830e8334064bdc23b16651d9634e0	8264
848	6a6b0b061dc2d5025d4d4c8f74a5b5ee4c1afeee6af62750673134a145256ce9	8274
849	f9edc8d5bf9ac9120bb3504fef95c9aee424a15b2717ea1ca75d7759a778868b	8288
850	3f3d82a44e1c128c65c7827e845b04d6ca8c385187be80357cd00965932c15e9	8291
851	399ceb70068fe488a0ef4ac79412776edd4e7d63078cafcef8b6772e6e1f9e2d	8313
852	195bbe095959defe533467184170998de991b454d031404fdfd77a50a9dedabe	8316
853	9e83aa81c06e8e0bd8ebccd557dc293b8984a027f87f1a67e1019099eca75cf0	8327
854	3e472f706b657ee5c5d1d3903086978438772ac6785640b1ea74e46723e2ecb7	8362
855	8a1b145d0dd7b1a18fae5bf69c7de1798e0c60aa95dcb08637389f6d24a69990	8368
856	7069278268bd2613267f3cf65f8858fc3fb9c9d6b6741c25902a0d43849b89ae	8378
857	e8fc4f3e062ac737cc27f2748fcd7cda30ad56975d1c5dee5ca99656fdcf9783	8404
858	5a2124b82b71218c6fa5063521aa62136c877ac3e29916a122a4423e1c62f8a6	8453
859	1ffb35f7758d01b2dc97f9c1cdd193530cf566b468c54422c77c8d3a5e4dbead	8474
860	7c921e7d945c8356560123f524cb7c75d26981d47c789c11745ae3e61c11d620	8493
861	e2d2b9003b3da9e4d8288b1a50512fd2f6a4a92c0c4980ece4fe4c70273d3009	8495
862	de25a896e0bf488b70a0b8089ebdf8a16c131262d7f7f676d34d1934b0b8ba98	8507
863	9d8a27efc382555b16ee89dccf061b62b48a14b49ba958d70560f8f16869208c	8519
864	5d0adb65a96fd07edc5828897eb092dc49128ec1e182f9350a18b097729f2a79	8525
865	3ced95cc88a9ae25ea0117efc3ac0dfd5002251f2c37fe7cbbdc8ca948f2569f	8552
866	f596ae3de3d0a07dee2630241f621491f23178c0473b8a1c801d015f2fd3d3ba	8553
867	de02af822fbe00e4d65bd8e8f9f9910fdd8b11ffc5808dab246423d10b269302	8555
868	afd38c326ff6c6c6f0d65fa0fbe41c6f2a8f44f9e3364a20ea9b1e697bf3aba6	8568
869	fefea3aa7bee43d6afa24b298382c34a14557d9836b86fc4f7751e92fccb71d8	8581
870	978ef5e573f146a43eb2068a4cc5fdaf1558b6c30096f5dd418b8db751699d10	8583
871	e972cf25ae16dd4aeb75760779cd34212ff3af61bdf11aea044f2f5a0e72b213	8595
872	d9a3108822809cdc0151f9318193bc4c838bc16eba6660390c17d14e480dbfd9	8604
873	ca87f9f574e417236c357cef766fa5e30e681078bdd35089ea4037e2978bf141	8621
874	7df928e8a58565e06f8bac1eefd5201478a1634bd0801383b1fb2b30a751450f	8628
875	e192e822ebd4c1e10beecc8d0856bf6eeb0bfbad4013895bd5f6a086727a0262	8630
876	5516d5d7a6ac27014067b2d6c931db93dcbb3dadd86bd99e80ff4827eb01b562	8637
877	4fdfe00e98a90a94630f589be81ebdff441b254c47a52feb6f559d5728947995	8661
878	8ca93af81537aa61084faa5f9e4ef78e365174dbc0a2d2f90be09572b79dfa28	8664
879	1117075f52d0abe8afaeb6573b4d204cebb1e9c35ec23ba3d9e7915cf9d69e77	8705
880	1ee33233f1ca4bd032cb2d0ed1d08adad21d29aa6e241daa64e483be1a95409c	8711
881	fb290c64c932049c57e584cb8755ce4dcbfa91b6676d009687e26357e3411d13	8724
882	ab98f7c1a646db04befa0b7b2a15882f77c1ce60eeca50699bb5e34a0e654ac4	8727
883	325dc6fae66da1945f3210ca55535ef9fd8bb7d690e23888780f170ac3a8ea35	8743
884	c70416950f25b9c9cd4572055caac36b6e407c3ddc9c22e39d120179343e1797	8753
885	6f3f0a3cbcebe265b98b008bd3ff02b6d431f7c6d83433fb575c0264eba0ff0d	8774
886	33a508093ef1c1f620e3ce8923ee752be2007db021e8ec3e8e95beb7333695e6	8782
887	5651aa5815fa84ba67ac2cc53d94ae5834af28832bde36a0db8629f89af00caf	8803
888	da7a31b4c0e319de5d70c3b39df05b0df6e8dce281eff0cc89a6542c0752b2b1	8818
889	f49dead3ea6aa5e4b5b82e4f26599644d371af81ea782842933226dac5737010	8852
890	5532cc2e339d3bde1ac552a7fa2249fdb7017e01cca1e32f795a119e39611f57	8860
891	6fe4a6774f4ea1de4be0993c4594eee68ac75e6b05ba19e62dd3a74f5dd64f7e	8881
892	be6856dfe55b1bb44e3d4a78aadb077e3d9137aa41c743a5c02dabe9eb0a324e	8885
893	cde588e0311ea0b4851fa9a61e01c25858b70ad39c96376f159751d4e55f6021	8888
894	d1f9a4a8c36dcec245a677f4bbf637a997f80a99702a0e7823774eaf56465066	8893
895	fd748ee72250ec6f91a6e2ccd424fdf3867376879f6d600f6a67a26b6061b655	8898
896	c9cd8a7b94233620c499bfaede52cff5df6cece7bd4708a48db348a69312126e	8914
897	aca0a955ffdbd81c68a441a205b44e67a85ded631a39ae6c0dc124dd0f9a66bc	8926
898	4b5be22ae1f3e93b1f4b7950a8acb5990982a2f00a84dfeca264325525bea79b	8936
899	a4e1d42c9792a628232ac1daf551b52c563cbff7e8e4584ffa61c968671af943	8939
900	710c99346066825f8f9422305c8b1e01c4556464ab653ef983d76e113784890f	8943
901	b57064e434d0b6fbb4d8a17085c3c2bd889229ad8f707d4cc60aceb21c6e2e7a	8944
902	cf641f62b0f50233ae2b724feafc098254b17fcc1ef35255becb73ad40b5886b	8949
903	353e843a4e6cd01cdc399e9d5ebcc3a9d6bd845bdef94a97463dba4475985127	8962
904	629a7880d92f4696750943ea3c3c13b6b7204bd327e14e2199efc0a1bd481a66	8965
905	b7da1b5301805bcc597c41e1ef441abc220535918fdee9a683fd1e0a47bd2d87	8967
906	442761aaf258acfa2a061204214f652b65a17a65d04686645e86f27de3a074f6	8979
907	b70e1c4309c14e33b34ddea26f1b169129f6e1266700d65b6b4cc6f28cef9044	8993
908	09da80bef95488122496a043e411d194fe93f4f924698d8ed602b1e66295e2d7	8994
909	ca617321b7e47d5d51639f88a251b3bede246f0977cf4f206de30fb8b37c1f2e	8998
910	6b20191c8fd346aac851472da4b2d7a4b735318cbf6dbcf4bff4f43f37dd9ce8	9001
911	7e6a43c7a9b494e21f3340f6077d352a2cd1c6b8f340a77b13e07946dd749839	9006
912	2dc94a922993e397e7f0d0fe2441c2172ca8157bed9a5b21e3517b2773d77d24	9014
913	615370aca42356138bace51dabb43d8c26e6e83e66b5b6066deb86789c4db150	9029
914	da2152ac29c841f2138d984195f89c55125e61fbf6ab2483939e80c7eead81b5	9042
915	f6df7046337f611afd7d2de6581ab70bb0bc4786db35d475709bdf3f1a356721	9045
916	8bb0720285ed6949c5fc17a8ea5054b2221eafe2aff5142941e9bd3396afdc01	9052
917	e27273ec4b0bb462d041bbe9ff453baa17aa7e5b6836f1346c8dc1aca06bbdf4	9068
918	038c4ff29638425a78b772c012ce962d929ccab9dfee58cf8f112b4ce16aa95e	9091
919	08613a096fae208cb2cc5841f7085085fe97aeffec864064e9002092a928c482	9095
920	79e0e81114449941e36f301082b7b7fbe3eaaee8c4c375f352b09ff439898cd3	9116
921	fddf04f0cddf4f1b297c1aec039628a184dfb7e93f9b99fc8adba9155ec81b86	9151
922	1642b0ed7af30b4e1c1160caa23821e2224712bcd2d4ca95db3a2a04f35024c6	9157
923	29bdf1f05a9b48cfd7b6702c49821878c66a423d6a21c18894209acc8784ddf0	9170
924	bbd9ae66b54cc80b8065d2d899babcf71f5a7ca887c20d61c3abb41a62822164	9177
925	2788f9747c2f43eca681a7bdf589b1e43f37686b4670855b89a71efeb7c0a617	9191
926	b0e20c9ccef165d78a7c137b137817c95b7602731ea9a924be5172abedfee919	9193
927	556ffe17e2f69a066cc57140391718c308595255e1c880cce0cac0d1ecdd0c84	9197
928	3f4916e720952f5b95f95bbb7e06d433679f289a577be89126f277d1058cb964	9198
929	af45ff6b6562a7fce2dd71bd90d5b360b40caf58682c8f729080e99d5acd74a1	9212
930	323be09e575f9d430547ede9cee12e33566a0163eadfe34151ab34684244b716	9227
931	3b9a9337d2e18ac282e14f8b9b8f2855b129bc5e464f7f11bd5ebe885cab2818	9241
932	9f4b74950cb6b3dc87a469309bb29f1f4aae3dc11e5fe4386f20a2fcf05ff49f	9243
933	450472cee9ee7d8fcf72f6e18edb280b4f2bc5be0f29d168fb70af9cf9cab8cd	9246
934	a52c43fae390b69c034d45ce4d2b9b3967bfda5a5b2148838aed4bd3ed76807d	9248
935	03ec83800ff4c7e0735a4a15ad51b4ce886b86de63390463e07c1b54b95a82d1	9255
936	613ea354f8cd421199f9f321b8b4a8fe5bc5a872de34ef606f4ad363e24a733d	9256
937	a6173557f59398fd0ceb97f59f6ef9aa98c520bc0ee861c16652188719da6ffa	9258
938	4a7a2075799c6349f4b17316e5878890604cfedb5317e6d1c51699937f0ea241	9274
939	754ed72897c97ebe8b821622bff98996634eb6a7a311a91e80704d5c263f14ea	9280
940	7c951f496664b5ea35286f81836d639dfd5f9d0b534e56c95e912b9977c8f552	9282
941	b5a5e4c193be5b8b8a1be9dd757f57f85ef677e59a21e06f4894da98f500299f	9290
942	ea8ac1bc0ce8f4913ae9ccd7a405c65fcc16da273393985575ba5d093ef256b2	9300
943	fe3d570cfb51be58bdea1cae2fbebcaa8baa0f8da535df70f3272320acc6ddb2	9313
944	4f55c5d5f9e0436ed0a610496bf752e75ee3285ad9dcac45c72b2398752ee7b2	9323
945	e6a373da0435fd982c318d87a4d21f1e4961c6a0b238e9aa3f5c2c23a1f5e90c	9352
946	38f422912bf2f1f9be94654db5a08299680c3d25fb56537745d2c41ae8f374f3	9356
947	4d6ca3062913ede62ccbf1a4dea10592beed7ca6e92825fabf70cd1222b747f3	9367
948	8bf33f5d43095464462d5a682d63ba2aedd4ce63243260312b809fdc542acaae	9371
949	5016b429f01e472dbe22a2b3ed95555b991bea6270d6dca365b242b83fdad994	9376
950	1bebfc5b13b5051a51faf71b025e808febd7a713fe3913101c241872c5bb0920	9379
951	dfe91e7c014526e6435e768f44215f13fb0d28b4120dc8c30314652b9f61b227	9381
952	47b040a2470dac0bd1b02fdde7de412d5c079acdb443ab94ca523f414fa6acdb	9412
953	b72a73cb59e5ae837440b9a63376ba395c0fc95fd0d5468a6411f06673fd658c	9429
954	6421928917334aaa6ed469f6cc492ce0d977a245127af3776576fcd682bbc40e	9466
955	0413ca5f21d3b4e0f6f1477b70d251a78e8005767f9e42d18869db2ff406e3ec	9476
956	66d30e5f00d58bfdb0060c056c4baf6e6eae38b5e628d15bd690648164521819	9477
957	d83801b84c2de1a342ef8eebf1c104a7073bf35c08b37eaae321da7aee937768	9509
958	0a33a0b4a328859782cf8ffe35533e64406385c2644b278a3c7a10ac571ceccd	9512
959	f0ae57e46661af42ef3d0dec6aee01bcf17a300d1c45d9673d34b0ff577e2a34	9524
960	3c762e83ad053d032e3cd311c8ad13224a54b5e8ace7c4de249c83788770946f	9539
961	4bac6a823b998022e1dbbaed7d6705c324c62f2ae10b445c77254e5bad7cf0a1	9560
962	27ca20466537b632d8dd1a85198029905be662fa328f7801281634e958c399b1	9579
963	d3736ea41906d2eeb294cd55ebbb3d4d9cc23fea5325dec7d4e4a08355bb3f2c	9601
964	bd9aceaeba38030ff9450091470315d3a84dd07f6582445ff9f0f60836ec7692	9606
965	e0d327b16db8bfb0389233c157514676e997bac1b0a7c55910a30fb8f2762419	9612
966	23d0eb7036e6acfcabe43ec6e337bb86b72c014af4cc9838776452e4da8712fc	9617
967	27d373c45e4c23f90821a5bcc41bea5976f5d98fd87e0b406eccbb03ab3f5d81	9626
968	6cfc5a2b3d0c0a808412bbed8ebfa29cc91418e7195a650abcce880d04246120	9627
969	13c66c138fee3f42677bffbbd8303aa86cf73c485bc5d091ed7a2ffaf6ff5f6f	9635
970	ca8a78865814dd7f8ab7d24de051ecfcb8d421f3222ecb81003268de3e63d008	9641
971	9fb84b674725fa4aed1900fc774433d8352f70efd7070eddaa3e39049dd97f31	9644
972	aefd07f9eea0d59fb742a8e1d6fc39e14356b745ba0158da473cc0597e9b0c3b	9652
973	c3aab18de51a52673246ef40eafe3bbf780c70af7dc26c8ece6c86650ed90c42	9674
974	d7686e94a341b37f7718b78d9973387b78f07fd3e8c9972be7492029a24b9a2c	9686
975	24463dc04f6698f2885af75bdf541c83e6e3399f134379667f834073dfba7030	9707
976	e53de0f7ad3bf5cb40754df40080ba992332beaa62f99dd33b712fd77161762e	9708
977	1e6f07a4bf9e4158e6b6def710b8e5e15bbfcf144856e1caff7addc99fea7dab	9717
978	b90cfca27980c656566fec31b8666e0b970d99c3de45e80a2f9ad2762919ef76	9734
979	016c15819013b48d0ed41fab6f063ffcd9e7a6f29bf5a80fa0639bd495882fc6	9736
980	58d9a81f015619a2c3fdd11d9c4afc2ae2377fd2e6d8eb2a3cdc9b1f3845e4ef	9737
981	3030d1c0f7dd0c739d0b10a546f48940ec91233753ea40891574023a0c32e35c	9740
982	7d0c6109f12dea57fab21287ae2962794b9a2b4c584350efa814bc7a687612d3	9746
983	5ebf2de5e662a7ff53f528c2ba0d11dabeda84c95311e42fd78b70ea920a4ca4	9767
984	c462b3fd59622ff7b56d67cd87f71953b8a9ac04fef985abf241f1bce0a17682	9770
985	e94ee797cfd8c07ee3480e1af1be2ebb1b2b069b02691059dc65cde176a45908	9791
986	5c6f66ff4ac23f83a3f56f89be47f0a7d259fc2201444cb4456578edb3b8c4a9	9857
987	1ebbc5e7ce5ea6ba2c4cdf0594ff6ce79d8dc04d0a2171fca0c0666224d63e39	9858
988	708dbc84434d308e5709e1438e00650a57056e65441f7fbb22811ca85bccdd3f	9867
989	860ba839b978b774a8dd0645ffee7949833d04832d353c77d664fce0bf8a977f	9870
990	1f9eaed0fa0d132daf2537df8a98df0e94e33a2ba84d91dcca4c3b800fc2e174	9894
991	61e47ca90cb529e262e86cf39f224f7d630fc68463672ef7ec0e0095148a0d0f	9908
992	e318f1ef367045966860e57a7835827fc53d02ef25ae472a7d36d1ab279e52ab	9915
993	3efdc3ea056b339053b4239ce59d502408a24e7d4cbde1ff5516b277bc10b40f	9917
994	2490f7e050a9fc45e08916cb2050016439b027cec4f2ef130853d852ae9a0663	9924
995	ae2ce1c1dd9dca70d7365fb4c59ac007d946d46b0811b39d97e25868b63fb4ef	9932
996	fb695ffbb4b6cedef91695b7bc2a85decce305d873bd3e4d6c00a314a5cbba92	9933
997	3c9194e8ec39c91c7383a5ed6dcdd21e6d854cce2f5453fd6904106b91ded02e	9941
998	8b66e622dc712c2ff2f06300d09fa2c788ef3eb050b606983b958b09c0a1b942	9946
999	b31ba9645490c767c24ea5a614180030098098c69a09324c784dbc055168e6b1	9950
1000	8e9bd6f7486d5e02e23d724d9af01f7e159a9fc37cb0dbd495473507d9f045fe	9973
1001	41b2685c0893b69787133be62859099ef338b5e30ee337f5fdf08ca56201ce64	9974
1002	9b71c97cb4d53699b353f28e2aaaa8c81c5e8cc630bbe37ea9b25097ae9e1042	9980
1003	57ab237b1aa4148db54adeb75619a7c6285e04e4c0da4dbade46a3393297c120	9989
1004	575c58ae601b2543648ddac286f0d5260f5d57cbd8b1a40059fc847f83c240b8	9993
1005	9c824193ef70fac763cde1a02d12d49490aa846a1a3032bd6c15eafcd7b03a87	10021
1006	3ee3463c2fa0212b8d65f4edbfc3d7ba91c985f7c0abdfe2b79eb11c8981cfbc	10026
1007	42d2e1f342e0a40b4187d3f08f399b3d3e6afad7561d161da25302b42e7cd269	10034
1008	69d1179cd831525a340ecc35df9330ff99810a8520cbb9b3db37d648bf7a950e	10043
1009	f8bb5cc07aa0eef3d45df92a50098af430102af6d5d5a674a9b09063291ef28a	10044
1010	c8f46fa6ada0803f2d1f634dbb3ecf7af472f961e83cf760d65292bffe125646	10064
1011	d3ca2d0450a89c2260a396d584276241e80a0e47cd8078875552a07eb653dc3c	10072
1012	3b8f8dad1d45dcafed3ad5a741a96f382b6ae727d02b46ec406064b0ff7caa07	10106
1013	5f67b1c9ed71152db09f185ad5e42379097792bce96f7d4748285b889f227d09	10109
1014	4928923cf278835474321a2b710ee9e938de36faf897b4084431a3ec0c30aa89	10116
1015	0a0421629dac8e06835a8222a844af3567d79f9b9ce6ecd602df39d9d698ecdb	10117
1016	2c99d5ec69cc1ecfe8219a4b47ef60c0a3fbb01dc6b787074bcf2ebe78ad50d2	10131
1017	dd1dbd66d1e438b4c13de93ac6c71d1f431d3d6999ccd44d9a6374d0db871e20	10132
1018	0516052951a1c1d7e477440c9a5cbb35f17df4893e55b81cc5e1db4da1201ff8	10149
1019	fff2ffce1bda536bac2a5b1bebd93fa7edb116e39b666a561ec327d286580b5d	10157
1020	f21954e1c2ee55ec8f004f7b6143b366dab1172101d1792701a8b5dbfe7d17d8	10163
1021	616d74de0fb86df5cd9d801e4ed0aa407cb2c7c99bbbc7454f1a18e1ff8fa427	10169
1022	9c4fe294f419535aa342d09d274b81087f9528b98b7e373921cce6927c988547	10170
1023	d5a14710575d7e9d9d62c5d76782a02e15b456e185713c693f391970b55b703c	10172
1024	881a378ef71ed650da16239983eb96fc03c6fd39632f4e0f81a771f7239a4a6c	10183
1025	cfe333c2509ac0d58c099f8d927acfd059eb8b6b3327efb25e98e65fea320ee4	10188
1026	3f4033b8fed90a8e6aeda4ac1fb88c9135bf0f18cdbc1e46de926dea3232fb69	10200
1027	acc483a653175f5242806c147d327272f0c1e7fd50643f5fa5789c9c1cdb3707	10215
1028	a62b4218969bf54771933b20d420fc1f9e48a8e310cc75cbcdd3f1f0655bad0a	10217
1029	bc03a703581e3699479f180137c9a87dbd6e3c40897aa64701ca533049dd3430	10226
1030	34b516912bcdd1578d8ddd49884a73c000a7d070d626340a7e8f701b44ba6678	10230
1031	ee004a8b61fa9cc13a5abcfc4d35bfc20a9e0e7d8157c925cdd350c76137facd	10239
1032	07948172dccadb2623a5a0d241d8bc1c7bb3bd19ee5935c6559d9534324648a1	10241
1033	1efeac6c2b4932e3c9dda92155001fa75de8c1d2acc6efc5ddc6387a7732b2ba	10266
1034	b33111a952d38138628711ccffd4dc2412fa17ca95704c1aee7eb267670445bc	10274
1035	41877651630ccdcdd4ba27929d1827af5f7e7b0c21c11a51eb154153b7f72ab3	10278
1036	07e33d75f31fb2fda333b515a617facdd2fdf31cfe4df080d6fb55f844b163f0	10283
1037	247d95deadeae2cc3753508ec36c1a6cfe34ffd54119c2cf36d296d93eeb0f2e	10292
1038	28b550a7ee02fd954fd6fdfcffc8079a19f386d7e3ebbf9880a4acadf3201bce	10300
1039	18d26a1702a57e61f45225429ac0111f56847043716dcac12a849efc6717b3cb	10313
1040	6f1a97a168b9c4a04d283b5ddb20f334701da538924b219b9134f5b47916fd69	10317
1041	b5ff21f8822fda33620e3e69bc58a868457148405e22a192b2fe4d20d2395064	10335
1042	4e2bd4e4846ac820d5c866e72ee746a9a24a1991523d5c158d8c2e232bdffc66	10344
1043	f54371c3599c69a5dc73e6dee7fd866eba8a8623e6f9c10d751d842da11368c7	10346
1044	ef044c75881710fb1e107d91095208f8528653845765ca2c514ba556cf429bcd	10349
1045	7de6ad51ea869922c4af1ed499b3b36ca83431da024eb7b93e16299b37ee428a	10351
1046	f65e744ff2fa15b9abeb1f701ced7571c2eb2cb4364b92517bd163d08b95a611	10357
1047	23f1987d566926bfee3ff4ae8dc938c041a8e395ac6e02aa38cb4a10ad5d70f9	10374
1048	9155d37b819eae4183de68a6320a87e77f3a0efc51407858c2823151c157c947	10396
1049	aa4917da62f4463210a856ec283494870306d3a66edc97968072c4e56a73e484	10403
1050	9eca7d410cae5a86e7267b3f7ec432665d5dc58aecc4e9860024853e19cb371a	10411
1051	c8c529b9947cce458cc3ef8cea4ec50294ca3c6e93f2ca1ee26b9c2c03d1b48e	10419
1052	e8b3e9685949c0aa01c4945bbe2cb1a3f4dd172f3e100e1694de4d10706b16e7	10424
1053	eca5cdd5c143a07bfc0616b83e2f7af6e58f6bcca99129638212fa96db6b4b41	10435
1054	5ad5bcf52e359b002f068f318a07f697fb0b7d4136a94dcce2159ec7bdc434f7	10439
1055	df672ebfa99910b7076e220b12b9afaa2665110f2772ea78d749903bae2fbddc	10448
1056	4f307dbd83bcd382a0335908e78c43045c97af0745a590ebb632b7063ba2beab	10482
1057	ac697a44bf6dcbea7088b09364c7ea32e0c1c54a6d7b644ad1ccde7e66b31d56	10492
1058	a99550c9eb133fd2acee0b707a1f4771d60392a9ca5d3bc139581e726148bde9	10507
1059	e6113f17b87be4c1e0043dbd118eb5b3e317305f616fa7270e64890da0342cf9	10510
1060	f57c54e3873650c823cc9cdafe824abea62b6a0994393cac3d64a7ca433f8773	10526
1061	a7c2600a775893f22b7a9a3adbb08086cd354d9d2f625f33f7b86b61cbcf6e7d	10538
1062	30afeb5e0f155cf6708d3e1cf7891ece2b5b59b1a7bcb5ff6e577a71b7d5367e	10556
1063	f705339146c4128f78610278bb45ce107fb8a44efa8b23dfeb86941bdf722e64	10566
1064	fcb09f1e48db16941d1dc282bc14e5fd6f584b9d4eabde20e0766a04d87becf5	10567
1065	f429295f606aaf014a7bb460d24a9132e54bad4caeb1eaccedf4f9a304fe7c63	10604
1066	65ea1b6373bd5df47ae252e17423f512c24f4ed217e7844eb8e5a5eb3353362c	10605
1067	4a5d505081c14ae3575a6df98f3f2c6d8a924cbb8292c752405b53a709b3ad63	10643
1068	fd73b03537592b9b36b8471349fce99f8f8982bdb9dd74380ad31cdc224c31c0	10653
1069	94c79e9edf39e8febd66c3ac46236e85b6a53e376b6ea2c2615a32eb41997121	10677
1070	9103d262e0ef049aeff8c9d2d19ebd1d1dfec8dfc3a6f914cfc6ec40b09ff50b	10688
1071	79a1437f748542dd51d37a9088a33cb27e0329ae74f964b003eb3ce303698115	10692
1072	770b7347b5d62a12eec4ff8d4d484a69be800d74ee5afdc581767ab2f55a8a34	10707
1073	8d14559315c76a9e8e94527868421c9c173d143cbb8526430df1504a89fbed0b	10722
1074	b31dc782bced0d0a8129142d8ed133a06321b345cd95feba0b8f3e246aa8f77d	10725
1075	023e37bba993ffcc80558582fe813e6ceddc2df8f187d4f852f2c5c7da5bdf30	10729
1076	59250e7cd89a08ed6dddf356c5612526b48bd7b9b15824b58e3de2ac11bdfddc	10740
1077	0fff4309d1ff276542c1873bb203a9d292a0c5a8e3c7ae5fcf8dd1e53dca6376	10743
1078	c3b88ca0df1fccda665f0af36d8d9040e8ef4e5d0341236752328426bc3a68e4	10777
1079	2c0b192b91342a434f2b7464e1e2ef03a1ecd5ee30190f0f1628c62fe9f20738	10782
1080	a908d5857b0dabedbfb8112fa4416638d848d54adeb8d31cdee5492d1bf13c57	10785
1081	a5361e38df5553d9e384a30a5234e8544ab67eade538cc5d718230c84c541da7	10796
1082	4cd290b343fc0b62eaf521d728135ecdf869ed67c9486eed7e5898c58b8c494e	10816
1083	fa8e8b29f3e78a6a233a2260054ba8ffc7afd230af5f6e5423fb1cc1a5c9707c	10821
1084	bc8204e6ec87cc5e6e0f64b85fd818819e3c31dcd849f73753ce58373fd36800	10836
1085	c5d07645678fab11307a3e7c4100c9f9196b3d2c4da956977c0a9ea2acd848fb	10841
1086	9d30df8cb2b69c4b16c27a739fadb705922aa43de0ba6075663763551786bf3d	10853
1087	033ffd6f5c8c8bffedf4aa3c76b27d3f2a0eebb1a5ca3a21dd1e321f4a4acd91	10857
1088	7beea66ddf610cedfa3ade1e4138a53f2e850366e85f653c5fe4841bcb8b1ea4	10861
1089	093c1343b346a01d92644d0e83d066dbbce35445974ff07b55811db0329ad083	10881
1090	dbb1556240a50ec5dbcd16ab92668130972de9d65ae5db2a69b256daa1d130d2	10882
1091	b2abf34d3e18a6a47a9b65c42df2fb35b831d593b52d8e3f105eb42565fe52fb	10889
1092	d1a0d361a06d68df761459f48d9bf43e47f3421a9a4241113b45f707f6fc8c27	10902
1093	70ee306a23dd3aacabdfde5453e41db7dfd7928893f251b1fdac7d56338b7468	10905
1094	8759c3c48e362dffa3b7d59a2f37b3fe48cc6cebbaed9d599a47489b5304f305	10909
1095	4f2bef3bbde6e4a592cb2344b47591664c5d47ac983f0f2db847e8be22ff1713	10912
1096	44399dae6a7ca2aadb68e18c8d80395f9cadbb428a02709daa7e69e0cd6a7dfa	10927
1097	57bc0379f69e3290e85f69662b9ab7ac40567f3e1978fbb1873f6ffde2427891	10929
1098	20d8b0e0911de2812632c630db063bbfe240e3c42fbb817731c247e891667b85	10950
1099	8ff69d36569bc126f5fc1dece9e71b1be0f3a6d4c30a879fc5496ce043f76ce0	10976
1100	41a878d88ce73d8df61c2d8bfc3b363344bb75822a42e6b83d9a5cb9cc52eeb4	10977
1101	04aec80a2fb99271175526b39a6072a1624fc5efcd265b5a668f8a8ec1fed27c	11016
1102	45ca31d2c852e73665f6de42ae0eb032e370ed8f8a80bbe6f85c7e0adc493834	11019
1103	90f099344cfa629058f9c3b17f017655dc35215fe90716aea752280a97ce8a06	11026
1104	4f8fd5cb4f6bbf0bb58212838f05b1a76a423f0410cf7baae847aa178bb82f72	11029
1105	589bbd863c8d2386af5ce322c577844e6b868c71fab35668f87c30e647ae07cf	11054
1106	511a63356ce86578e08652b01fff612d05c7abb79c42301c0f98e9c836fff238	11077
1107	23419de8242b2b7ac65e4d92086a476dfce939d133081623c515830570534b6e	11081
1108	980f64c45334cff2b71dd6308c04ca24b872abdda1cecaf35d1ff4ae1523fdb3	11087
1109	cd4eaeeca0ba363a0393688fbd8ba488e4a310c13c180c5d8c80922520cc0f98	11093
1110	29e3f50c8d396f48efaf5007a6b1729b3cdc138be837b8e37782902081296bcf	11122
1111	17ae0be4c537a1af987a3cf21f7f9693f9287d65869ffefbfab033e59976995d	11132
1112	32e7d2f7ae7bb2ab987fd593eff5140a3663299b63366b1a802e8810037048f7	11134
1113	d52d675f3dd48b82ddb22e8e0d37f28f7f7551ec152b4d875f3cfc4d4e412f67	11137
1114	b4a52bea6faf3fbbeb3ec7db8d1bc0f2f8fc661da07f8853e41a1ec3f86a2056	11150
1115	c759b1e248d9d2239a4dc3d378dd0148407c0afb6e921aa941b63e627035343e	11178
1116	1b2b8fb85e901b7b85011bf6990ddf8f68360d7cc43414917143fd2bee876725	11190
1117	ab6674780f1481370577b8ab68f99fc2942a747fc96967c89fef17abf5d45066	11199
1118	6ebb90392aff0d6ddecd233c96fa65f232a0c184a5ecea509fcc227d1b2299c7	11213
1119	f6fc8b9854c2f22c53827dbb8d57f52e48fd0f44194d1d414d4d7048a2dbe611	11253
1120	ad919fca2414677b7e08258d6ebcef866c95d8dbf5c91fccb8ff6f29571a7bd8	11258
1121	c23aee522cd35d6e4d94b6190e01c2799c183cca8e7ae2a1f646adff7da3ac98	11266
1122	f1eda1aaaeec86e78325ae0091930437a20f37f91fdc0182a2cea5ee7d83d6be	11280
1123	4ca900e7beb2f0afe7684f5ec092b9cdb832639438c12c2453510efdaacd537c	11292
1124	76e493615703689524f1544faf9fb0d5561e56b13f24fbe0b5c89ab01ab2b386	11295
1125	e64c178a667d7027280f2221b10aff824784cd7892c57ee4b8300cd3985af215	11302
1126	b938da431326b7f7d4efa1f87ebffbbaa5e7947b3218c6ba08d569cce046c84b	11309
1127	7b8395550a9236db4cbb29382ee255836e7617c7c913c7def169bfa1ebacaf0c	11333
1128	5ecaa92fb9dd1ec8b81a6bf796c2f94ecdd3c4bdd187b4c45159bfafc0ada3ae	11362
1129	8f64ef57e186d54cd1c3e722739089b50726cbaf408768a2743d5094d4417b00	11372
1130	2d365316d74cedf0e87ade276d1ec278b933bad7b6e8e3edf7d98cc8142bca78	11388
1131	9eaafb8bdbece7cf40ce253b38e3db30db0748368885f9725b12149ac2a0e4b9	11399
1132	f8b4528f01afa279229aac1a5e17eb32b05301e5a05705e4072659a37e1eb051	11425
1133	b6aea341938b04120459393694505935733241bf694cd23f6262a4c8f74234f5	11429
1134	5e5c1c1ae9153a8521c25d4855d838afc91b2e05b22618ff349ddeda56f4c923	11439
1135	af233103087575a7eb49f71c21bee36a82e0122e045ae6afd25b2a22e604f1aa	11443
1136	8767f852a48994ffde54fa9143bac5ee96837f458c9e2785d47884bcc0e4c818	11456
1137	23e96b41182bb881fe5bc3cb6194b83c82722933c552a23261745fa9849b6e60	11469
1138	c6ef3e631d6da95086416e14f37110a31edf387b486901fdbea660e846c4ad92	11471
1139	a2dad3673f3e340674fe5cf5c78250dddab8e744320bee6ed8117d0c88556e3b	11484
1140	ab67abc3fdaffba64aa5ae21b1a56074f6d292f1e3ae7808e36b01ea99ea5767	11508
1141	452d7c5115307c4f4c6fd73c3d1ec10e4215ca8cc8c7eba2af21b36556244689	11532
1142	aa699a73efbac94363ae0fe6f1a850f8bba347c059cdc7e5f82a27f6c7faceb4	11535
1143	eabd7ddd7d1e7f3fcc13a48fe6996a51ed1dbf78a264ca111c0c746b96604c1c	11537
1144	eb53f043af90a82311dcf1fe8a16a582795f9c888e5ec3a8f5bb69097b600707	11548
1145	e130efddb1a82982df01db630403462202de404cc12367f6cab76723faefc998	11550
1146	28518d91ed979e209bbc3c3292db6f9c7301f10816efa6c74ec064b6bbf05cf9	11555
1147	5334396b004fb3638a11c8f15111d1f9c40aee7189b8f15318c2f2c6424c7790	11557
1148	b8490a9d6e1ce8f4d0947a72ef249d4cb9a89e1881161f6b24e1aa064c309f95	11569
1149	6a0242f546e03c60d814409bab26cd140c62e9df79717ea3a44dc6478d30e60e	11579
1150	ddf25094488020892d53d40b702d17b860a8341d255cd15e8fc88885b419ed3f	11581
1151	ae157b18a2880772cf3ce26e6dde7294643eae3a117c46abe517d40ab362ef1c	11583
1152	adaf2df1d2a44c9407ca59b5cee0ee9afec320cc31fcc0ac65ddc85589d7f7df	11612
1153	b872e7faa56bc97d46df64104f26c6ac46c947c99d58e62ec1dadc3ad4a1c596	11614
1154	8c9d691c46155bb16260b787372056740d4ae7967518b421f9a0685d51c65980	11634
1155	ebbaa9d3c843c2bb1cd77e0d23de846e5ca1e9dff7aa5daa0bc8aa4629ea399b	11640
1156	9f69e8b6136d8314e2b1ed4168d3993c8311075f5406814a9a54968a88fbe8f0	11642
1157	9a6c02b0f857688d163bf524843ad19dff05660d9892703ee610d0894b3a9c11	11648
1158	74c029238e86312b7f0526c42b7c9f564b34a70fb2dd8d7c6524316f9cb353d6	11649
1159	e8aaaed0469dc9f93994e2bba5ba339bca4e0c88c57c182898737c4e66cbe7fa	11652
1160	61733c03979730819c068e87b3d143cd8aeec8b98f47e0019be3dca9c3d9087b	11664
1161	5a54506cf1ec9b191b1630ca0656d09217ba8d99f518e8a0d7ffaf5db95a8385	11710
1162	3e2edef79c702fbe71ab3541a2947b4b92804ccdc67dde99df9fcd4a74688d39	11716
1163	91878ad72dee370122b661ba45d4a6bbe961744a0c23853ebd68d41e84fc9a12	11751
1164	e91e22f4083f4c76fd725f06581963f6355161ee74ed813a6291c2922ccb3ee9	11761
1165	e123d666f537189581426a61e71dceb0773dda9f015d208b90ed2b265b75e7d1	11763
1166	f51cc3883a78c00e225b95b7851d91b074b65c0b2526691d6459854ea07f9138	11797
1167	6aa08c6849a67410c0b458e50514d25567d0de1c4d8a69b03695f56563d26fb0	11823
1168	d5daa694f57fbf8b9a6ea78c7bdea20320ea50569b8f2559e24b97ded173ec2f	11853
1169	f9cd979623c7b3db643c1fc49fa1e69559cee891335eb8793996e4737a69b08b	11893
1170	fcf14ea9cc86ce0c483b1db4c57b54a5130d219ba20c7aefdde6e80ae11c5fd4	11894
1171	8abe6f1a1976997706745ccd5111695a823884226ef1acfa57d27d996e6c7058	11906
1172	79d414cf2d8523ab8372e31f1be4303dcdad481b7f183bba19762e9690a37e21	11936
1173	21720f0fd0c20c2a59b7e7d841809ea0316e2cdd71e5b9303706f305cd3a1539	11937
1174	f3ba8f172de9ecd268eee1f0db0c6b962864264dc9bbcce7e8cabe0677284596	11938
1175	1761427011a864f73a745b8a23eee86b07f24410cef275b0471d238366614315	11940
1176	da57a6ff6a6203fa51dc7764aaf0f7aba67069055d89340b1105b791702bc65e	11941
1177	75d0771694185fc5442decbbee42da6c291f794b57be5f414db2da11a8bd6120	11947
1178	67d043ae49a3cc93a7ce3f520ffe86a6fd161f9d7cb2bcd7ab0deba5e122a7d0	11966
1179	d7dc7b52500ea30c316df8811f11666d3c6dd48c0e5593cb4b215e4121a9034f	11973
1180	0ceb6265dcd1886540970f4a43cc6b8963730819b1e405fa47a33e4c3a99f332	11979
1181	3f522abdc016a4a3b10defb3098c95f5fd0ecfff28666eff539c546f9db367c2	11992
1182	7d326b47257683b9b38aeeb9dfb4519779916858be67b2c8c06fbc224637f2b6	12036
1183	2092e7b87fdb164fa4de0e06a61cab921df8b81bdd188e2b0d0bab0adfb87d1e	12042
1184	80ecbbf86907b395877d797a52147efab3472fb5ba1d176c6e0e0a29541e8a2b	12047
1185	db7aeb21ecf17bcb2a76153ab35cb357c7bd420001eadf9e4fee5fddc053010a	12048
1186	f0fdbad710d903b5845e1219dcee129e238f85004391a2cad3229c34ea0efffb	12060
1187	54bb858d8b3f4fa51c61fadec1301bf8f5517792cee4993fa52ed651c7e1a648	12063
1188	0514ecd78770ec1e0d93d23793f72534327901d5c6787787e253ebc472d4d718	12064
1189	ab57fa2c3eb36d93b371bb6186166200d7c23f56042b6fab60535ac48c5b4cc4	12074
1190	e09e9b511d25e0d78ed71220b157c5dad67456f3fd92c86c12ccb9de2aa59320	12087
1191	4233c9e7498cb384154087d2f1f0aaae34e2023fe454a05944a7ad4a571c52b4	12093
1192	176c4f647c6b99ffc1e7a4de7403a04fc337b394dadf94734c49548229829104	12119
1193	9de64f8a42e141f6ad8f7df4e076d379660db48b4b7a33c170d831d1684c4668	12126
1194	90b3406d368a955babb97fced542a77c35b3bf38800f7d679b5a4a5d3dbf8f1e	12142
1195	b09b21fd208038846c1ddb0b1541f47dfe9216ace852fe708a4a0886c5398e50	12152
1196	b8dfd75bdc737812744f5c92911690bb73e5ff1e5cd25931782c3119caa6e629	12156
1197	bc7abfac362dfee82a31c8ed6ad2a14f649f4d626b570a2e732c9487138f600b	12158
1198	63917c8ecf20b7dfc2712330f78893c38d951520dede0feba81b89c56021bcc2	12175
1199	82c96f00e9103d63e678ac706334e462428a043476c341790225714eb8de0eac	12182
1200	e35606ae1095dbeb6362886ee08402479e5cb22faefbde44997599820dd415d7	12192
1201	821719bbb7e581c2f41d0df73b165e76952dcac60631d4ccd2a277123b85269f	12195
1202	fa818d6196ac65f278504287b09b90323159c23e267c1947e017a95e7be0df6d	12197
1203	8b70bf0f4367d189bc72ae8199bcf3a831ddf15fee6fbb897e8eafd0b4e19d51	12208
1204	cd2e7af31193738909ebed290bce2970ae16e82a0882075d522371dc40c4b3f9	12219
1205	f60c90271991fc40b64d851d25e17d412919b98d08cf07ae68942e3c27b9a05a	12226
1206	c8f6584425f3e6b2334acb811c3f7e60a727a933c966c52a58004b24c5808a9f	12264
1207	d250aa3114fe34c40973595f09054fcce2278e52477e087b3ad163e7570eec0d	12273
1208	c3eb597366b6313f74c64e76b96e2d7682a5bb3046937ece76ab1a2d2f0bad95	12312
1209	2aa662a1d23e195a7fb456c39d5cb65749ef56021eebcde808ad15f9d3b032b0	12330
1210	4db1a94e6d1ae1dcb8f1a78c68ea787405532385149e8fa8abb1caeae2de35e3	12336
1211	67dc123dc42bfc6f11bf999fb44dce1382a8c9825b35392613f299b25a40e8b3	12338
1212	b6d99b527c2cd4d4d6ef084fc1c6f7c1229f85f790b801547bcc80153f1a5adc	12341
1213	a1f67f7d8ea13994a75b015c7cc678c2a114fe7762476c2cb68fefe64b691616	12346
1214	58f67b2cfaf1686ddb3827be913026f15ac990767762f137d4ef68e39ac114d9	12357
1215	bb7a6bd03d313851f68500b6a7d39ba52ec31641f7c558f80ec63e464922b2de	12366
1216	a379a74486d8d1aa76b6dbe915505a2b51c09de2570aecd13e4808135b5548a7	12368
1217	aaa268e012fd8bb24b926c57c670dbdc16891efc3ef344d38fcdd776432ffa07	12388
1218	d2c1cff18aaaceb1f127ce5a5c05f6d5b002c97789205a830f04e3a64ffcc104	12390
1219	829c679a2035b504779fcdb3de67fe741132a49c92b00ef9a99af9c8d360ce5e	12392
1220	5f69318cd400934d801d6941012d0fce531d024b7fe968a7dbe96c27b2e70cc1	12395
1221	923dd1cb9c43c1e3b54a5393d1a74738144d0bdad36cd99fb873191c3dadfa4d	12401
1222	f8d3fafed395a9624bacf3648f638a2f9573c0a56362b0a7317c890e412667fd	12405
1223	383a1761cb144495d1df3ffa19ba33e26acc21a7877541541b726e139b4e7321	12415
1224	a86bc01b2af5e763d5d24b67aa038621bd9983310669bc7fa8a65a65e409e055	12438
1225	ce660787a8fe1a8cd76ce6d2705cc35252a53dbe1e817203a710a9fd96cdb698	12459
1226	bcef6b0370d52ca9e7b3c958c7683783c87db3efaff96566ad4df8dc3dcc9f48	12462
1227	560ce0fed9347fc10fd5cde6f67ea9e7b73560d756dbe1336a13c464700fa7cc	12463
1228	86160bda49e4de54384eb179ede34b85765728d0d86cbe84ab28eebc0ecde91e	12472
1229	c19566ef93926d531c0b4b0af9ece0df53f13ef1eac794747124d3ab40530f1e	12475
1230	47e32b290f17edbb5c8fce1a356b7f945f1ae5a46b7d28552cb755592c92c019	12504
1231	e3973ce0397258a02c2c5fbbceb0d40314c0329aa2e300018fd24f07f6350007	12521
1232	4cf1a8aaf812651ea91f085f357669f4f840bc94fa30e98ce683c28af371a791	12526
1233	a96c513dd7795af1de33a5087960d3d684216b51473b3a8793c697796bffee22	12531
1234	f9dd0faa196de4b1653a4a3ddd85d7941763202b5fb5b6de6ee5c3410796efe5	12533
1235	daf25d9866635c062ea77d39102e5b173f8c921fecd6439d6d96569e58a4bc3b	12550
1236	11ddd3baa9ac82356f182ffbc9a36ab6fecd5b812f0a9598090488aa893b8532	12557
1237	e26b356162e52659febc3d0cce6d6b8ce29feb42674ab4473ef28470abffdbdf	12570
1238	16f121d1ee8cc94fe4561356db10d6c74b5bb8b8192ca089e00010a49890a935	12571
1239	a0e7a43875045bfb919e891c6b461459909548334d5db1658b7c0921a65504f6	12577
1240	2968fc99b2274065004cc7176a194fdc8f200e709c81ce713c693bd98accdc61	12593
1241	0d95867b01a7d39c85c4d4323c84c83f91fba34e1c19fddd4d70d8c759e76785	12608
1242	e7ba72661f19941d2207c88af6eb0d3c341da3fbac8da49cbc46416d6da01f59	12624
1243	cb5a05fa24d880b4a4e39ad4b3d8882088ee40e67036a6e86cec97cc2c4ba94b	12630
1244	4515dbfddf514bf3375393fefd76571146abbbf4bc5d35f7dfe2c138a7757fd3	12634
1245	4137004488cb85c429d0cacf24ff0b2a4af303a72e4e8f57652be75c239772db	12642
1246	c6c0d6d11b98ed07b2b4e84e18430a90f0a3328850de38d615676d2c28ac9396	12655
1247	c73ee3bce9090a36a08c931931f415b5a06ee2697fe86ecb46016d569ba84347	12667
1248	0faa7c91623f6a8bd1846c2ebd5030d586861c52cff79cc5ef431e66797c33e0	12675
1249	78018ba2008005b4a8ca529b24a865965b443762abe86a501ccfbca1fdcacad0	12691
1250	9bc28050f59110d65ff8d9dd2f0063c2ae5b8d8af011d0c7d1ba4bb075018180	12693
1251	96948ab90a240f295e4c4355c95fc2055b791a770a6bd7a73268a2121e7ffc84	12694
1252	d42c66a4e02327ef026dcb98025d0e78b462e0df9ac46dcfdba709fe6ef48e82	12706
1253	0578f1170597370c1b199ec6c95a672c8f958d7830b798d1181afc43ffe2b77e	12710
1254	2eb0926459460731b3451a3ef0647dbc269dd00dafdcb1dec8022a46abdc3161	12754
1255	26ed8d9431a47f64c406802cd42ab7caa8c501ea403ab3d2265d9216c043410a	12765
1256	f4a2ffdc7affe8bd18d1a9d9695a1dc830e9e586bb35fd2c8b131f1223e887b8	12768
1257	4b25aa7c49a5e7cadb91b33273bbb4ead6e453099bfdd9976e62c00373f3a03b	12775
1258	756ca4e4fe752264c185ff128f3212c707b1bc6275dc9812ae65c8cae5680202	12787
\.


--
-- Data for Name: block_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block_data (block_height, data) FROM stdin;
1209	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313230392c2268617368223a2232616136363261316432336531393561376662343536633339643563623635373439656635363032316565626364653830386164313566396433623033326230222c22736c6f74223a31323333307d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2263336562353937333636623633313366373463363465373662393665326437363832613562623330343639333765636537366162316132643266306261643935222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1210	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313231302c2268617368223a2234646231613934653664316165316463623866316137386336386561373837343035353332333835313439653866613861626231636165616532646533356533222c22736c6f74223a31323333367d2c22697373756572566b223a2234616261626665326534376633383232323533336132313938303739363361333538623539626239343336643464623538366333303136663064346431336632222c2270726576696f7573426c6f636b223a2232616136363261316432336531393561376662343536633339643563623635373439656635363032316565626364653830386164313566396433623033326230222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3170656534766e337a346c6b3439646d79677876337432336c647565716a71763333617564747639307534633566396d7037396b73336c39346677227d
1211	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313231312c2268617368223a2236376463313233646334326266633666313162663939396662343464636531333832613863393832356233353339323631336632393962323561343065386233222c22736c6f74223a31323333387d2c22697373756572566b223a2238396337383232323431626361633961383461663438373362376361643737363739636539613937343862383130353437303962346662393230623730313238222c2270726576696f7573426c6f636b223a2234646231613934653664316165316463623866316137386336386561373837343035353332333835313439653866613861626231636165616532646533356533222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313467766639716663373230616178797678377766686e6d376d74386678347a7a6b3078326870326e6a6d7464686c793332383873333968383936227d
1212	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313231322c2268617368223a2262366439396235323763326364346434643665663038346663316336663763313232396638356637393062383031353437626363383031353366316135616463222c22736c6f74223a31323334317d2c22697373756572566b223a2238396337383232323431626361633961383461663438373362376361643737363739636539613937343862383130353437303962346662393230623730313238222c2270726576696f7573426c6f636b223a2236376463313233646334326266633666313162663939396662343464636531333832613863393832356233353339323631336632393962323561343065386233222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313467766639716663373230616178797678377766686e6d376d74386678347a7a6b3078326870326e6a6d7464686c793332383873333968383936227d
1213	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313231332c2268617368223a2261316636376637643865613133393934613735623031356337636336373863326131313466653737363234373663326362363866656665363462363931363136222c22736c6f74223a31323334367d2c22697373756572566b223a2234616261626665326534376633383232323533336132313938303739363361333538623539626239343336643464623538366333303136663064346431336632222c2270726576696f7573426c6f636b223a2262366439396235323763326364346434643665663038346663316336663763313232396638356637393062383031353437626363383031353366316135616463222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3170656534766e337a346c6b3439646d79677876337432336c647565716a71763333617564747639307534633566396d7037396b73336c39346677227d
1214	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313231342c2268617368223a2235386636376232636661663136383664646233383237626539313330323666313561633939303736373736326631333764346566363865333961633131346439222c22736c6f74223a31323335377d2c22697373756572566b223a2234616261626665326534376633383232323533336132313938303739363361333538623539626239343336643464623538366333303136663064346431336632222c2270726576696f7573426c6f636b223a2261316636376637643865613133393934613735623031356337636336373863326131313466653737363234373663326362363866656665363462363931363136222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3170656534766e337a346c6b3439646d79677876337432336c647565716a71763333617564747639307534633566396d7037396b73336c39346677227d
1215	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313231352c2268617368223a2262623761366264303364333133383531663638353030623661376433396261353265633331363431663763353538663830656336336534363439323262326465222c22736c6f74223a31323336367d2c22697373756572566b223a2265653362386233356162383036643033316433353038383764373432303665616462316233633738666239616131663130623432633863633734326664653434222c2270726576696f7573426c6f636b223a2235386636376232636661663136383664646233383237626539313330323666313561633939303736373736326631333764346566363865333961633131346439222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173647a77666134673275367a3436616c343778743230666e306a75686b6a757966747a65793732683334307275706a656c766c7376326c34646b227d
1216	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313231362c2268617368223a2261333739613734343836643864316161373662366462653931353530356132623531633039646532353730616563643133653438303831333562353534386137222c22736c6f74223a31323336387d2c22697373756572566b223a2230636431333462386238633533376564656665303632653763303434666162663631663739646432616665653166656665303837323835323936653663616230222c2270726576696f7573426c6f636b223a2262623761366264303364333133383531663638353030623661376433396261353265633331363431663763353538663830656336336534363439323262326465222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31616874726c6c326b39746c66376a3574706c307136736d3375396c653267736e706368377634386d726b6e686835667a66636d736738716e7163227d
1217	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313231372c2268617368223a2261616132363865303132666438626232346239323663353763363730646264633136383931656663336566333434643338666364643737363433326666613037222c22736c6f74223a31323338387d2c22697373756572566b223a2233613466623162653138386363616238613566323165306432643532653266626331636239653137633139616336326332633664653064646534653037623837222c2270726576696f7573426c6f636b223a2261333739613734343836643864316161373662366462653931353530356132623531633039646532353730616563643133653438303831333562353534386137222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317435366d7234676b716c657938306e333036353235366567306877326c357a3966756a347a6a707a6e687a32347834646d6d6471707375373565227d
1218	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313231382c2268617368223a2264326331636666313861616163656231663132376365356135633035663664356230303263393737383932303561383330663034653361363466666363313034222c22736c6f74223a31323339307d2c22697373756572566b223a2265653362386233356162383036643033316433353038383764373432303665616462316233633738666239616131663130623432633863633734326664653434222c2270726576696f7573426c6f636b223a2261616132363865303132666438626232346239323663353763363730646264633136383931656663336566333434643338666364643737363433326666613037222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173647a77666134673275367a3436616c343778743230666e306a75686b6a757966747a65793732683334307275706a656c766c7376326c34646b227d
1219	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313231392c2268617368223a2238323963363739613230333562353034373739666364623364653637666537343131333261343963393262303065663961393961663963386433363063653565222c22736c6f74223a31323339327d2c22697373756572566b223a2265373130323435666236393739653638383766373932393431353665316161373936366164393638336334353664353361316165666464616331333531373262222c2270726576696f7573426c6f636b223a2264326331636666313861616163656231663132376365356135633035663664356230303263393737383932303561383330663034653361363466666363313034222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317577387736376d7939706132667a7166667a6b38646179646e3038746d763737727a656e66326771753375776e3833686d336d737379776a6533227d
1220	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313232302c2268617368223a2235663639333138636434303039333464383031643639343130313264306663653533316430323462376665393638613764626539366332376232653730636331222c22736c6f74223a31323339357d2c22697373756572566b223a2264626230313436303238373266633031396336616331613936616463306638376435313937646639643930343737393464326562643664623135326535356439222c2270726576696f7573426c6f636b223a2238323963363739613230333562353034373739666364623364653637666537343131333261343963393262303065663961393961663963386433363063653565222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31346d38786730683064636634383334666b7239636d7568643630356765396c71336572397a326e686c6136646e3374777a706b71386373303275227d
1221	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313232312c2268617368223a2239323364643163623963343363316533623534613533393364316137343733383134346430626461643336636439396662383733313931633364616466613464222c22736c6f74223a31323430317d2c22697373756572566b223a2238396337383232323431626361633961383461663438373362376361643737363739636539613937343862383130353437303962346662393230623730313238222c2270726576696f7573426c6f636b223a2235663639333138636434303039333464383031643639343130313264306663653533316430323462376665393638613764626539366332376232653730636331222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313467766639716663373230616178797678377766686e6d376d74386678347a7a6b3078326870326e6a6d7464686c793332383873333968383936227d
1222	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313232322c2268617368223a2266386433666166656433393561393632346261636633363438663633386132663935373363306135363336326230613733313763383930653431323636376664222c22736c6f74223a31323430357d2c22697373756572566b223a2238396337383232323431626361633961383461663438373362376361643737363739636539613937343862383130353437303962346662393230623730313238222c2270726576696f7573426c6f636b223a2239323364643163623963343363316533623534613533393364316137343733383134346430626461643336636439396662383733313931633364616466613464222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313467766639716663373230616178797678377766686e6d376d74386678347a7a6b3078326870326e6a6d7464686c793332383873333968383936227d
1223	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313232332c2268617368223a2233383361313736316362313434343935643164663366666131396261333365323661636332316137383737353431353431623732366531333962346537333231222c22736c6f74223a31323431357d2c22697373756572566b223a2264626230313436303238373266633031396336616331613936616463306638376435313937646639643930343737393464326562643664623135326535356439222c2270726576696f7573426c6f636b223a2266386433666166656433393561393632346261636633363438663633386132663935373363306135363336326230613733313763383930653431323636376664222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31346d38786730683064636634383334666b7239636d7568643630356765396c71336572397a326e686c6136646e3374777a706b71386373303275227d
1224	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313232342c2268617368223a2261383662633031623261663565373633643564323462363761613033383632316264393938333331303636396263376661386136356136356534303965303535222c22736c6f74223a31323433387d2c22697373756572566b223a2264626230313436303238373266633031396336616331613936616463306638376435313937646639643930343737393464326562643664623135326535356439222c2270726576696f7573426c6f636b223a2233383361313736316362313434343935643164663366666131396261333365323661636332316137383737353431353431623732366531333962346537333231222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31346d38786730683064636634383334666b7239636d7568643630356765396c71336572397a326e686c6136646e3374777a706b71386373303275227d
1225	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313232352c2268617368223a2263653636303738376138666531613863643736636536643237303563633335323532613533646265316538313732303361373130613966643936636462363938222c22736c6f74223a31323435397d2c22697373756572566b223a2238396337383232323431626361633961383461663438373362376361643737363739636539613937343862383130353437303962346662393230623730313238222c2270726576696f7573426c6f636b223a2261383662633031623261663565373633643564323462363761613033383632316264393938333331303636396263376661386136356136356534303965303535222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313467766639716663373230616178797678377766686e6d376d74386678347a7a6b3078326870326e6a6d7464686c793332383873333968383936227d
1226	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313232362c2268617368223a2262636566366230333730643532636139653762336339353863373638333738336338376462336566616666393635363661643464663864633364636339663438222c22736c6f74223a31323436327d2c22697373756572566b223a2265653362386233356162383036643033316433353038383764373432303665616462316233633738666239616131663130623432633863633734326664653434222c2270726576696f7573426c6f636b223a2263653636303738376138666531613863643736636536643237303563633335323532613533646265316538313732303361373130613966643936636462363938222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173647a77666134673275367a3436616c343778743230666e306a75686b6a757966747a65793732683334307275706a656c766c7376326c34646b227d
1227	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313232372c2268617368223a2235363063653066656439333437666331306664356364653666363765613965376237333536306437353664626531333336613133633436343730306661376363222c22736c6f74223a31323436337d2c22697373756572566b223a2265646666323535333339333464353839396333336365623934613937663631643563616664316636363362616432323033303963303063663064366538626462222c2270726576696f7573426c6f636b223a2262636566366230333730643532636139653762336339353863373638333738336338376462336566616666393635363661643464663864633364636339663438222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31613478767a306538717538337a37376d75356561793861657a7266346d6b6a746c76783473367767677a30793071383673776173396435783570227d
1228	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313232382c2268617368223a2238363136306264613439653464653534333834656231373965646533346238353736353732386430643836636265383461623238656562633065636465393165222c22736c6f74223a31323437327d2c22697373756572566b223a2234616261626665326534376633383232323533336132313938303739363361333538623539626239343336643464623538366333303136663064346431336632222c2270726576696f7573426c6f636b223a2235363063653066656439333437666331306664356364653666363765613965376237333536306437353664626531333336613133633436343730306661376363222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3170656534766e337a346c6b3439646d79677876337432336c647565716a71763333617564747639307534633566396d7037396b73336c39346677227d
1229	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313232392c2268617368223a2263313935363665663933393236643533316330623462306166396563653064663533663133656631656163373934373437313234643361623430353330663165222c22736c6f74223a31323437357d2c22697373756572566b223a2234616261626665326534376633383232323533336132313938303739363361333538623539626239343336643464623538366333303136663064346431336632222c2270726576696f7573426c6f636b223a2238363136306264613439653464653534333834656231373965646533346238353736353732386430643836636265383461623238656562633065636465393165222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3170656534766e337a346c6b3439646d79677876337432336c647565716a71763333617564747639307534633566396d7037396b73336c39346677227d
1230	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313233302c2268617368223a2234376533326232393066313765646262356338666365316133353662376639343566316165356134366237643238353532636237353535393263393263303139222c22736c6f74223a31323530347d2c22697373756572566b223a2265373130323435666236393739653638383766373932393431353665316161373936366164393638336334353664353361316165666464616331333531373262222c2270726576696f7573426c6f636b223a2263313935363665663933393236643533316330623462306166396563653064663533663133656631656163373934373437313234643361623430353330663165222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317577387736376d7939706132667a7166667a6b38646179646e3038746d763737727a656e66326771753375776e3833686d336d737379776a6533227d
1231	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313233312c2268617368223a2265333937336365303339373235386130326332633566626263656230643430333134633033323961613265333030303138666432346630376636333530303037222c22736c6f74223a31323532317d2c22697373756572566b223a2264626230313436303238373266633031396336616331613936616463306638376435313937646639643930343737393464326562643664623135326535356439222c2270726576696f7573426c6f636b223a2234376533326232393066313765646262356338666365316133353662376639343566316165356134366237643238353532636237353535393263393263303139222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31346d38786730683064636634383334666b7239636d7568643630356765396c71336572397a326e686c6136646e3374777a706b71386373303275227d
1232	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313233322c2268617368223a2234636631613861616638313236353165613931663038356633353736363966346638343062633934666133306539386365363833633238616633373161373931222c22736c6f74223a31323532367d2c22697373756572566b223a2238396337383232323431626361633961383461663438373362376361643737363739636539613937343862383130353437303962346662393230623730313238222c2270726576696f7573426c6f636b223a2265333937336365303339373235386130326332633566626263656230643430333134633033323961613265333030303138666432346630376636333530303037222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313467766639716663373230616178797678377766686e6d376d74386678347a7a6b3078326870326e6a6d7464686c793332383873333968383936227d
1233	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313233332c2268617368223a2261393663353133646437373935616631646533336135303837393630643364363834323136623531343733623361383739336336393737393662666665653232222c22736c6f74223a31323533317d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2234636631613861616638313236353165613931663038356633353736363966346638343062633934666133306539386365363833633238616633373161373931222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1234	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313233342c2268617368223a2266396464306661613139366465346231363533613461336464643835643739343137363332303262356662356236646536656535633334313037393665666535222c22736c6f74223a31323533337d2c22697373756572566b223a2233613466623162653138386363616238613566323165306432643532653266626331636239653137633139616336326332633664653064646534653037623837222c2270726576696f7573426c6f636b223a2261393663353133646437373935616631646533336135303837393630643364363834323136623531343733623361383739336336393737393662666665653232222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317435366d7234676b716c657938306e333036353235366567306877326c357a3966756a347a6a707a6e687a32347834646d6d6471707375373565227d
1235	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313233352c2268617368223a2264616632356439383636363335633036326561373764333931303265356231373366386339323166656364363433396436643936353639653538613462633362222c22736c6f74223a31323535307d2c22697373756572566b223a2230636431333462386238633533376564656665303632653763303434666162663631663739646432616665653166656665303837323835323936653663616230222c2270726576696f7573426c6f636b223a2266396464306661613139366465346231363533613461336464643835643739343137363332303262356662356236646536656535633334313037393665666535222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31616874726c6c326b39746c66376a3574706c307136736d3375396c653267736e706368377634386d726b6e686835667a66636d736738716e7163227d
1236	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313233362c2268617368223a2231316464643362616139616338323335366631383266666263396133366162366665636435623831326630613935393830393034383861613839336238353332222c22736c6f74223a31323535377d2c22697373756572566b223a2265646666323535333339333464353839396333336365623934613937663631643563616664316636363362616432323033303963303063663064366538626462222c2270726576696f7573426c6f636b223a2264616632356439383636363335633036326561373764333931303265356231373366386339323166656364363433396436643936353639653538613462633362222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31613478767a306538717538337a37376d75356561793861657a7266346d6b6a746c76783473367767677a30793071383673776173396435783570227d
1237	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313233372c2268617368223a2265323662333536313632653532363539666562633364306363653664366238636532396665623432363734616234343733656632383437306162666664626466222c22736c6f74223a31323537307d2c22697373756572566b223a2230636431333462386238633533376564656665303632653763303434666162663631663739646432616665653166656665303837323835323936653663616230222c2270726576696f7573426c6f636b223a2231316464643362616139616338323335366631383266666263396133366162366665636435623831326630613935393830393034383861613839336238353332222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31616874726c6c326b39746c66376a3574706c307136736d3375396c653267736e706368377634386d726b6e686835667a66636d736738716e7163227d
1238	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313233382c2268617368223a2231366631323164316565386363393466653435363133353664623130643663373462356262386238313932636130383965303030313061343938393061393335222c22736c6f74223a31323537317d2c22697373756572566b223a2234616261626665326534376633383232323533336132313938303739363361333538623539626239343336643464623538366333303136663064346431336632222c2270726576696f7573426c6f636b223a2265323662333536313632653532363539666562633364306363653664366238636532396665623432363734616234343733656632383437306162666664626466222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3170656534766e337a346c6b3439646d79677876337432336c647565716a71763333617564747639307534633566396d7037396b73336c39346677227d
1239	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313233392c2268617368223a2261306537613433383735303435626662393139653839316336623436313435393930393534383333346435646231363538623763303932316136353530346636222c22736c6f74223a31323537377d2c22697373756572566b223a2230636431333462386238633533376564656665303632653763303434666162663631663739646432616665653166656665303837323835323936653663616230222c2270726576696f7573426c6f636b223a2231366631323164316565386363393466653435363133353664623130643663373462356262386238313932636130383965303030313061343938393061393335222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31616874726c6c326b39746c66376a3574706c307136736d3375396c653267736e706368377634386d726b6e686835667a66636d736738716e7163227d
1240	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313234302c2268617368223a2232393638666339396232323734303635303034636337313736613139346664633866323030653730396338316365373133633639336264393861636364633631222c22736c6f74223a31323539337d2c22697373756572566b223a2265653362386233356162383036643033316433353038383764373432303665616462316233633738666239616131663130623432633863633734326664653434222c2270726576696f7573426c6f636b223a2261306537613433383735303435626662393139653839316336623436313435393930393534383333346435646231363538623763303932316136353530346636222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173647a77666134673275367a3436616c343778743230666e306a75686b6a757966747a65793732683334307275706a656c766c7376326c34646b227d
1241	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313234312c2268617368223a2230643935383637623031613764333963383563346434333233633834633833663931666261333465316331396664646434643730643863373539653736373835222c22736c6f74223a31323630387d2c22697373756572566b223a2234616261626665326534376633383232323533336132313938303739363361333538623539626239343336643464623538366333303136663064346431336632222c2270726576696f7573426c6f636b223a2232393638666339396232323734303635303034636337313736613139346664633866323030653730396338316365373133633639336264393861636364633631222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3170656534766e337a346c6b3439646d79677876337432336c647565716a71763333617564747639307534633566396d7037396b73336c39346677227d
1242	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313234322c2268617368223a2265376261373236363166313939343164323230376338386166366562306433633334316461336662616338646134396362633436343136643664613031663539222c22736c6f74223a31323632347d2c22697373756572566b223a2264626230313436303238373266633031396336616331613936616463306638376435313937646639643930343737393464326562643664623135326535356439222c2270726576696f7573426c6f636b223a2230643935383637623031613764333963383563346434333233633834633833663931666261333465316331396664646434643730643863373539653736373835222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31346d38786730683064636634383334666b7239636d7568643630356765396c71336572397a326e686c6136646e3374777a706b71386373303275227d
1243	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313234332c2268617368223a2263623561303566613234643838306234613465333961643462336438383832303838656534306536373033366136653836636563393763633263346261393462222c22736c6f74223a31323633307d2c22697373756572566b223a2238396337383232323431626361633961383461663438373362376361643737363739636539613937343862383130353437303962346662393230623730313238222c2270726576696f7573426c6f636b223a2265376261373236363166313939343164323230376338386166366562306433633334316461336662616338646134396362633436343136643664613031663539222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313467766639716663373230616178797678377766686e6d376d74386678347a7a6b3078326870326e6a6d7464686c793332383873333968383936227d
1244	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313234342c2268617368223a2234353135646266646466353134626633333735333933666566643736353731313436616262626634626335643335663764666532633133386137373537666433222c22736c6f74223a31323633347d2c22697373756572566b223a2238396337383232323431626361633961383461663438373362376361643737363739636539613937343862383130353437303962346662393230623730313238222c2270726576696f7573426c6f636b223a2263623561303566613234643838306234613465333961643462336438383832303838656534306536373033366136653836636563393763633263346261393462222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313467766639716663373230616178797678377766686e6d376d74386678347a7a6b3078326870326e6a6d7464686c793332383873333968383936227d
1245	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313234352c2268617368223a2234313337303034343838636238356334323964306361636632346666306232613461663330336137326534653866353736353262653735633233393737326462222c22736c6f74223a31323634327d2c22697373756572566b223a2264626230313436303238373266633031396336616331613936616463306638376435313937646639643930343737393464326562643664623135326535356439222c2270726576696f7573426c6f636b223a2234353135646266646466353134626633333735333933666566643736353731313436616262626634626335643335663764666532633133386137373537666433222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31346d38786730683064636634383334666b7239636d7568643630356765396c71336572397a326e686c6136646e3374777a706b71386373303275227d
1246	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313234362c2268617368223a2263366330643664313162393865643037623262346538346531383433306139306630613333323838353064653338643631353637366432633238616339333936222c22736c6f74223a31323635357d2c22697373756572566b223a2265373130323435666236393739653638383766373932393431353665316161373936366164393638336334353664353361316165666464616331333531373262222c2270726576696f7573426c6f636b223a2234313337303034343838636238356334323964306361636632346666306232613461663330336137326534653866353736353262653735633233393737326462222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317577387736376d7939706132667a7166667a6b38646179646e3038746d763737727a656e66326771753375776e3833686d336d737379776a6533227d
1247	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313234372c2268617368223a2263373365653362636539303930613336613038633933313933316634313562356130366565323639376665383665636234363031366435363962613834333437222c22736c6f74223a31323636377d2c22697373756572566b223a2230636431333462386238633533376564656665303632653763303434666162663631663739646432616665653166656665303837323835323936653663616230222c2270726576696f7573426c6f636b223a2263366330643664313162393865643037623262346538346531383433306139306630613333323838353064653338643631353637366432633238616339333936222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31616874726c6c326b39746c66376a3574706c307136736d3375396c653267736e706368377634386d726b6e686835667a66636d736738716e7163227d
1248	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313234382c2268617368223a2230666161376339313632336636613862643138343663326562643530333064353836383631633532636666373963633565663433316536363739376333336530222c22736c6f74223a31323637357d2c22697373756572566b223a2265646666323535333339333464353839396333336365623934613937663631643563616664316636363362616432323033303963303063663064366538626462222c2270726576696f7573426c6f636b223a2263373365653362636539303930613336613038633933313933316634313562356130366565323639376665383665636234363031366435363962613834333437222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31613478767a306538717538337a37376d75356561793861657a7266346d6b6a746c76783473367767677a30793071383673776173396435783570227d
1249	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313234392c2268617368223a2237383031386261323030383030356234613863613532396232346138363539363562343433373632616265383661353031636366626361316664636163616430222c22736c6f74223a31323639317d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2230666161376339313632336636613862643138343663326562643530333064353836383631633532636666373963633565663433316536363739376333336530222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1250	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313235302c2268617368223a2239626332383035306635393131306436356666386439646432663030363363326165356238643861663031316430633764316261346262303735303138313830222c22736c6f74223a31323639337d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2237383031386261323030383030356234613863613532396232346138363539363562343433373632616265383661353031636366626361316664636163616430222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1251	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313235312c2268617368223a2239363934386162393061323430663239356534633433353563393566633230353562373931613737306136626437613733323638613231323165376666633834222c22736c6f74223a31323639347d2c22697373756572566b223a2265646666323535333339333464353839396333336365623934613937663631643563616664316636363362616432323033303963303063663064366538626462222c2270726576696f7573426c6f636b223a2239626332383035306635393131306436356666386439646432663030363363326165356238643861663031316430633764316261346262303735303138313830222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31613478767a306538717538337a37376d75356561793861657a7266346d6b6a746c76783473367767677a30793071383673776173396435783570227d
1252	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313235322c2268617368223a2264343263363661346530323332376566303236646362393830323564306537386234363265306466396163343664636664626137303966653665663438653832222c22736c6f74223a31323730367d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2239363934386162393061323430663239356534633433353563393566633230353562373931613737306136626437613733323638613231323165376666633834222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1253	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313235332c2268617368223a2230353738663131373035393733373063316231393965633663393561363732633866393538643738333062373938643131383161666334336666653262373765222c22736c6f74223a31323731307d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2264343263363661346530323332376566303236646362393830323564306537386234363265306466396163343664636664626137303966653665663438653832222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1254	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313235342c2268617368223a2232656230393236343539343630373331623334353161336566303634376462633236396464303064616664636231646563383032326134366162646333313631222c22736c6f74223a31323735347d2c22697373756572566b223a2264626230313436303238373266633031396336616331613936616463306638376435313937646639643930343737393464326562643664623135326535356439222c2270726576696f7573426c6f636b223a2230353738663131373035393733373063316231393965633663393561363732633866393538643738333062373938643131383161666334336666653262373765222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31346d38786730683064636634383334666b7239636d7568643630356765396c71336572397a326e686c6136646e3374777a706b71386373303275227d
1255	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313235352c2268617368223a2232366564386439343331613437663634633430363830326364343261623763616138633530316561343033616233643232363564393231366330343334313061222c22736c6f74223a31323736357d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2232656230393236343539343630373331623334353161336566303634376462633236396464303064616664636231646563383032326134366162646333313631222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1256	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313235362c2268617368223a2266346132666664633761666665386264313864316139643936393561316463383330653965353836626233356664326338623133316631323233653838376238222c22736c6f74223a31323736387d2c22697373756572566b223a2230636431333462386238633533376564656665303632653763303434666162663631663739646432616665653166656665303837323835323936653663616230222c2270726576696f7573426c6f636b223a2232366564386439343331613437663634633430363830326364343261623763616138633530316561343033616233643232363564393231366330343334313061222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31616874726c6c326b39746c66376a3574706c307136736d3375396c653267736e706368377634386d726b6e686835667a66636d736738716e7163227d
1257	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313235372c2268617368223a2234623235616137633439613565376361646239316233333237336262623465616436653435333039396266646439393736653632633030333733663361303362222c22736c6f74223a31323737357d2c22697373756572566b223a2265373130323435666236393739653638383766373932393431353665316161373936366164393638336334353664353361316165666464616331333531373262222c2270726576696f7573426c6f636b223a2266346132666664633761666665386264313864316139643936393561316463383330653965353836626233356664326338623133316631323233653838376238222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317577387736376d7939706132667a7166667a6b38646179646e3038746d763737727a656e66326771753375776e3833686d336d737379776a6533227d
1258	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313235382c2268617368223a2237353663613465346665373532323634633138356666313238663332313263373037623162633632373564633938313261653635633863616535363830323032222c22736c6f74223a31323738377d2c22697373756572566b223a2264626230313436303238373266633031396336616331613936616463306638376435313937646639643930343737393464326562643664623135326535356439222c2270726576696f7573426c6f636b223a2234623235616137633439613565376361646239316233333237336262623465616436653435333039396266646439393736653632633030333733663361303362222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31346d38786730683064636634383334666b7239636d7568643630356765396c71336572397a326e686c6136646e3374777a706b71386373303275227d
1201	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313230312c2268617368223a2238323137313962626237653538316332663431643064663733623136356537363935326463616336303633316434636364326132373731323362383532363966222c22736c6f74223a31323139357d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2265333536303661653130393564626562363336323838366565303834303234373965356362323266616566626465343439393735393938323064643431356437222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1202	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313230322c2268617368223a2266613831386436313936616336356632373835303432383762303962393033323331353963323365323637633139343765303137613935653762653064663664222c22736c6f74223a31323139377d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2238323137313962626237653538316332663431643064663733623136356537363935326463616336303633316434636364326132373731323362383532363966222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1190	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313139302c2268617368223a2265303965396235313164323565306437386564373132323062313537633564616436373435366633666439326338366331326363623964653261613539333230222c22736c6f74223a31323038377d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2261623537666132633365623336643933623337316262363138363136363230306437633233663536303432623666616236303533356163343863356234636334222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1191	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313139312c2268617368223a2234323333633965373439386362333834313534303837643266316630616161653334653230323366653435346130353934346137616434613537316335326234222c22736c6f74223a31323039337d2c22697373756572566b223a2233613466623162653138386363616238613566323165306432643532653266626331636239653137633139616336326332633664653064646534653037623837222c2270726576696f7573426c6f636b223a2265303965396235313164323565306437386564373132323062313537633564616436373435366633666439326338366331326363623964653261613539333230222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317435366d7234676b716c657938306e333036353235366567306877326c357a3966756a347a6a707a6e687a32347834646d6d6471707375373565227d
1192	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313139322c2268617368223a2231373663346636343763366239396666633165376134646537343033613034666333333762333934646164663934373334633439353438323239383239313034222c22736c6f74223a31323131397d2c22697373756572566b223a2230636431333462386238633533376564656665303632653763303434666162663631663739646432616665653166656665303837323835323936653663616230222c2270726576696f7573426c6f636b223a2234323333633965373439386362333834313534303837643266316630616161653334653230323366653435346130353934346137616434613537316335326234222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31616874726c6c326b39746c66376a3574706c307136736d3375396c653267736e706368377634386d726b6e686835667a66636d736738716e7163227d
1193	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313139332c2268617368223a2239646536346638613432653134316636616438663764663465303736643337393636306462343862346237613333633137306438333164313638346334363638222c22736c6f74223a31323132367d2c22697373756572566b223a2265653362386233356162383036643033316433353038383764373432303665616462316233633738666239616131663130623432633863633734326664653434222c2270726576696f7573426c6f636b223a2231373663346636343763366239396666633165376134646537343033613034666333333762333934646164663934373334633439353438323239383239313034222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173647a77666134673275367a3436616c343778743230666e306a75686b6a757966747a65793732683334307275706a656c766c7376326c34646b227d
1194	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313139342c2268617368223a2239306233343036643336386139353562616262393766636564353432613737633335623362663338383030663764363739623561346135643364626638663165222c22736c6f74223a31323134327d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2239646536346638613432653134316636616438663764663465303736643337393636306462343862346237613333633137306438333164313638346334363638222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1195	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313139352c2268617368223a2262303962323166643230383033383834366331646462306231353431663437646665393231366163653835326665373038613461303838366335333938653530222c22736c6f74223a31323135327d2c22697373756572566b223a2264626230313436303238373266633031396336616331613936616463306638376435313937646639643930343737393464326562643664623135326535356439222c2270726576696f7573426c6f636b223a2239306233343036643336386139353562616262393766636564353432613737633335623362663338383030663764363739623561346135643364626638663165222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31346d38786730683064636634383334666b7239636d7568643630356765396c71336572397a326e686c6136646e3374777a706b71386373303275227d
1196	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313139362c2268617368223a2262386466643735626463373337383132373434663563393239313136393062623733653566663165356364323539333137383263333131396361613665363239222c22736c6f74223a31323135367d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2262303962323166643230383033383834366331646462306231353431663437646665393231366163653835326665373038613461303838366335333938653530222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1197	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313139372c2268617368223a2262633761626661633336326466656538326133316338656436616432613134663634396634643632366235373061326537333263393438373133386636303062222c22736c6f74223a31323135387d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2262386466643735626463373337383132373434663563393239313136393062623733653566663165356364323539333137383263333131396361613665363239222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1198	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313139382c2268617368223a2236333931376338656366323062376466633237313233333066373838393363333864393531353230646564653066656261383162383963353630323162636332222c22736c6f74223a31323137357d2c22697373756572566b223a2264626230313436303238373266633031396336616331613936616463306638376435313937646639643930343737393464326562643664623135326535356439222c2270726576696f7573426c6f636b223a2262633761626661633336326466656538326133316338656436616432613134663634396634643632366235373061326537333263393438373133386636303062222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31346d38786730683064636634383334666b7239636d7568643630356765396c71336572397a326e686c6136646e3374777a706b71386373303275227d
1199	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313139392c2268617368223a2238326339366630306539313033643633653637386163373036333334653436323432386130343334373663333431373930323235373134656238646530656163222c22736c6f74223a31323138327d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2236333931376338656366323062376466633237313233333066373838393363333864393531353230646564653066656261383162383963353630323162636332222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1200	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313230302c2268617368223a2265333536303661653130393564626562363336323838366565303834303234373965356362323266616566626465343439393735393938323064643431356437222c22736c6f74223a31323139327d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2238326339366630306539313033643633653637386163373036333334653436323432386130343334373663333431373930323235373134656238646530656163222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1203	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313230332c2268617368223a2238623730626630663433363764313839626337326165383139396263663361383331646466313566656536666262383937653865616664306234653139643531222c22736c6f74223a31323230387d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2266613831386436313936616336356632373835303432383762303962393033323331353963323365323637633139343765303137613935653762653064663664222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1204	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313230342c2268617368223a2263643265376166333131393337333839303965626564323930626365323937306165313665383261303838323037356435323233373164633430633462336639222c22736c6f74223a31323231397d2c22697373756572566b223a2265646666323535333339333464353839396333336365623934613937663631643563616664316636363362616432323033303963303063663064366538626462222c2270726576696f7573426c6f636b223a2238623730626630663433363764313839626337326165383139396263663361383331646466313566656536666262383937653865616664306234653139643531222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31613478767a306538717538337a37376d75356561793861657a7266346d6b6a746c76783473367767677a30793071383673776173396435783570227d
1205	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313230352c2268617368223a2266363063393032373139393166633430623634643835316432356531376434313239313962393864303863663037616536383934326533633237623961303561222c22736c6f74223a31323232367d2c22697373756572566b223a2234616261626665326534376633383232323533336132313938303739363361333538623539626239343336643464623538366333303136663064346431336632222c2270726576696f7573426c6f636b223a2263643265376166333131393337333839303965626564323930626365323937306165313665383261303838323037356435323233373164633430633462336639222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3170656534766e337a346c6b3439646d79677876337432336c647565716a71763333617564747639307534633566396d7037396b73336c39346677227d
1206	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313230362c2268617368223a2263386636353834343235663365366232333334616362383131633366376536306137323761393333633936366335326135383030346232346335383038613966222c22736c6f74223a31323236347d2c22697373756572566b223a2238396337383232323431626361633961383461663438373362376361643737363739636539613937343862383130353437303962346662393230623730313238222c2270726576696f7573426c6f636b223a2266363063393032373139393166633430623634643835316432356531376434313239313962393864303863663037616536383934326533633237623961303561222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313467766639716663373230616178797678377766686e6d376d74386678347a7a6b3078326870326e6a6d7464686c793332383873333968383936227d
1207	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313230372c2268617368223a2264323530616133313134666533346334303937333539356630393035346663636532323738653532343737653038376233616431363365373537306565633064222c22736c6f74223a31323237337d2c22697373756572566b223a2231373064626161643738343363313736363331613866616632613066326661383334383764326161643461323436656265303565646263313532396166633065222c2270726576696f7573426c6f636b223a2263386636353834343235663365366232333334616362383131633366376536306137323761393333633936366335326135383030346232346335383038613966222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3130347132726867327366376b3375377333686c3967677179326b6179763930346872657a326b6166776761783771747971787a71667563366174227d
1208	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313230382c2268617368223a2263336562353937333636623633313366373463363465373662393665326437363832613562623330343639333765636537366162316132643266306261643935222c22736c6f74223a31323331327d2c22697373756572566b223a2264626230313436303238373266633031396336616331613936616463306638376435313937646639643930343737393464326562643664623135326535356439222c2270726576696f7573426c6f636b223a2264323530616133313134666533346334303937333539356630393035346663636532323738653532343737653038376233616431363365373537306565633064222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31346d38786730683064636634383334666b7239636d7568643630356765396c71336572397a326e686c6136646e3374777a706b71386373303275227d
\.


--
-- Data for Name: current_pool_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_pool_metrics (stake_pool_id, slot, minted_blocks, live_delegators, active_stake, live_stake, live_pledge, live_saturation, active_size, live_size, last_ros, ros) FROM stdin;
pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g	12338	126	3	7787658517594335	14931244867063	300000000	0.04686132543634483	521.567932676077	-520.567932676077	2.4576755884500603	2.2342505349546005
pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5	12338	111	3	7837007342356908	67383166414186	500000000	0.21148032320011564	116.30512128481696	-115.30512128481696	21.75368028136363	19.776072983057844
pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz	12338	120	3	7840315182040923	76889419851723	8905648986909	0.24131545349119224	101.96871295375277	-100.96871295375277	24.22480440809876	22.022549461907964
pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf	12338	111	9	7835635149627430	70359309646947	8045729829511	0.22082087168199327	111.36600385855876	-110.36600385855876	19.80189878052733	18.001726164115755
pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5	12338	137	3	7785166410674874	12439137947602	200111331	0.03903991239176724	625.8606057323842	-624.8606057323842	1.7554825856846064	1.5958932597132787
pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve	12338	102	4	7831992736629464	63611768437927	6806120519801	0.19964388829539434	123.12175763942172	-122.12175763942172	19.436412363607083	17.669465785097348
pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc	12338	119	3	7837903344281337	72001542180896	9034742624842	0.22597497597140173	108.85743703363272	-107.85743703363272	23.12554586467304	21.023223513339126
pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw	12338	128	3	7836213421987050	70939744888085	8317171463948	0.22264255265848654	110.46294900481402	-109.46294900481402	21.129698275539543	19.208816614126857
pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg	12338	124	3	7836878379362031	72834256064676	8034973778402	0.22858842693618073	107.59879763724052	-106.59879763724052	22.938586832124113	20.853260756476466
pool13kpk6jp9q09d83zfejn0wpqkxlu9xwnfyc959qqm7k8pwxyymf8	12338	65	3	0	46444597983328	500000000	0.14576516829202937	0	1	17.65982750016262	17.65982750016262
pool16kahh6ejmg29cc3rd4eecmhnsxm56jku9d8laluamqadsplvkx5	12338	69	3	0	18737193244987	300000000	0.058806195882161	0	1	4.915351176900121	4.915351176900121
pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	12338	0	1	0	4999497471201	4999497471201	0.015690793373360365	0	1	0	0
pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	12338	0	1	0	4999527465877	4999527465877	0.01569088751087441	0	1	0	0
\.


--
-- Data for Name: pool_delisted; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_delisted (stake_pool_id) FROM stdin;
\.


--
-- Data for Name: pool_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata (id, ticker, name, description, homepage, hash, ext, stake_pool_id, pool_update_id) FROM stdin;
1	SP11	Stake Pool - 10 + 1	This is the stake pool 11 description.	https://stakepool11.com	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	\N	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5	2500000000000
2	SP10	Stake Pool - 10	This is the stake pool 10 description.	https://stakepool10.com	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	\N	pool13kpk6jp9q09d83zfejn0wpqkxlu9xwnfyc959qqm7k8pwxyymf8	2500000040000
3	SP1	stake pool - 1	This is the stake pool 1 description.	https://stakepool1.com	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	\N	pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz	2500000010000
4	SP6a7	Stake Pool - 6	This is the stake pool 6 description.	https://stakepool6.com	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	\N	pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc	2500000080000
5	SP5	Same Name	This is the stake pool 5 description.	https://stakepool5.com	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	\N	pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve	2500000050000
6	SP4	Same Name	This is the stake pool 4 description.	https://stakepool4.com	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	\N	pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg	2500000100000
7	SP6a7		This is the stake pool 7 description.	https://stakepool7.com	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	\N	pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf	2500000020000
8	SP3	Stake Pool - 3	This is the stake pool 3 description.	https://stakepool3.com	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	\N	pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5	2500000030000
\.


--
-- Data for Name: pool_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_registration (id, reward_account, pledge, cost, margin, margin_percent, relays, owners, vrf, metadata_url, metadata_hash, block_slot, stake_pool_id) FROM stdin;
2500000000000	stake_test1uzu48tmnsqvyvmurhc9sn93rmz9fsmqmgsaz0nn0s07tegs0qvdvd	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30011, "__typename": "RelayByAddress"}]	["stake_test1uzu48tmnsqvyvmurhc9sn93rmz9fsmqmgsaz0nn0s07tegs0qvdvd"]	e87c80a007d721c33bc271dac5d5c41b9fa959798b1f740248e1d98ab01cd365	http://file-server/SP11.json	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	250	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5
2500000010000	stake_test1up70fdm89yy9h4r0j0ndp0kf9ku9zukgmwshj39t8y4tlvqqs3vj7	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3001, "__typename": "RelayByAddress"}]	["stake_test1up70fdm89yy9h4r0j0ndp0kf9ku9zukgmwshj39t8y4tlvqqs3vj7"]	b76dd2f97a1857fb3367b4228a880aadd711d9b4c54cca7a88cb0c4d1a967588	http://file-server/SP1.json	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	250	pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz
2500000020000	stake_test1urq660tcrsn4dygs9waj72kukvmts82xuyutw20qpx0mhksj9p50t	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3007, "__typename": "RelayByAddress"}]	["stake_test1urq660tcrsn4dygs9waj72kukvmts82xuyutw20qpx0mhksj9p50t"]	220ba9398e3e5fae23a83d0d5927649d577a5f69d6ef1d5253c259d9393ba294	http://file-server/SP7.json	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	250	pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf
2500000030000	stake_test1ur2afj76px7gy3dmp65gd7x2hxwalemwzs2ydg7yq9pqq9sw8eqqa	600000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3003, "__typename": "RelayByAddress"}]	["stake_test1ur2afj76px7gy3dmp65gd7x2hxwalemwzs2ydg7yq9pqq9sw8eqqa"]	93e6b92de27fd14f9ceb483e655ebc2d258829966000fcadb408ba9a3db1821d	http://file-server/SP3.json	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	250	pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5
2500000040000	stake_test1urxtj66qpl3lcs3ztfexy0mxdw028lqq80pk7w5ml7w9nec20gpg8	400000000	410000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30010, "__typename": "RelayByAddress"}]	["stake_test1urxtj66qpl3lcs3ztfexy0mxdw028lqq80pk7w5ml7w9nec20gpg8"]	b12a829458e487ca0349e732f9996373b4d372d42ad289b1e1ede606fa97e02f	http://file-server/SP10.json	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	250	pool13kpk6jp9q09d83zfejn0wpqkxlu9xwnfyc959qqm7k8pwxyymf8
2500000050000	stake_test1upucnpu5we6dm0qs3ts2m2y4x8edyc6ehv7yk2dd0hlgzxgcz6k52	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3005, "__typename": "RelayByAddress"}]	["stake_test1upucnpu5we6dm0qs3ts2m2y4x8edyc6ehv7yk2dd0hlgzxgcz6k52"]	787d72c8279534c2bb2fe4d6a2db7d17766114ee6b2a029aa4d2fdfcccf56c8a	http://file-server/SP5.json	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	250	pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve
2500000060000	stake_test1upwlsslt43ued4at9uad3z6g3cqzqarge0vymvgal5lt0ng9rp8m6	500000000	380000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3008, "__typename": "RelayByAddress"}]	["stake_test1upwlsslt43ued4at9uad3z6g3cqzqarge0vymvgal5lt0ng9rp8m6"]	0292d8379ed785cef6e419eef4d0d5552478ad027903bc603f423ba270c19e71	\N	\N	250	pool16kahh6ejmg29cc3rd4eecmhnsxm56jku9d8laluamqadsplvkx5
2500000070000	stake_test1uq2wftmv6dgngtvr4u56nfn5t80lqvxpkfd7sg467dggsxq7n6y23	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3009, "__typename": "RelayByAddress"}]	["stake_test1uq2wftmv6dgngtvr4u56nfn5t80lqvxpkfd7sg467dggsxq7n6y23"]	ad94751659b91c51a5eb1df6804c329cadf37df587c4d41d54b0b7c76c6460c9	\N	\N	250	pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g
2500000080000	stake_test1uz6cd4vtra67yh9jynhyrv24mayr8l2ha93f0v5dtcw59ksu5tnft	410000000	400000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3006, "__typename": "RelayByAddress"}]	["stake_test1uz6cd4vtra67yh9jynhyrv24mayr8l2ha93f0v5dtcw59ksu5tnft"]	9a196bdc4c92d9e06351e6df1f596e564bfd343c1c57b3971a3c54007af64294	http://file-server/SP6.json	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	250	pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc
2500000090000	stake_test1ur9smq3fdcs9k3fs0thlualhfx2tu7m48cln92cvw8kychsfgetcr	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3002, "__typename": "RelayByAddress"}]	["stake_test1ur9smq3fdcs9k3fs0thlualhfx2tu7m48cln92cvw8kychsfgetcr"]	b4591f64145a52b57f5f29c7b5bd616072862034c95ff46754057bcf78ae05b5	\N	\N	250	pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw
2500000100000	stake_test1uzpudyqavsvcndp62sqn28m2nuf45nymm52v6z38nq4lzpcvy0gqy	420000000	370000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3004, "__typename": "RelayByAddress"}]	["stake_test1uzpudyqavsvcndp62sqn28m2nuf45nymm52v6z38nq4lzpcvy0gqy"]	bc2a2cd2c1a7fa821532ec8a30134c4045afffc6b9510c4c92f2c206d955ec21	http://file-server/SP4.json	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	250	pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg
110870000000000	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	500000000000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.1", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys"]	2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	\N	\N	11087	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
112580000000000	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	50000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.2", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v"]	641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	\N	\N	11258	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_retirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retirement (id, retire_at_epoch, block_slot, stake_pool_id) FROM stdin;
2940000000000	18	294	pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g
2940000010000	18	294	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5
2940000020000	5	294	pool13kpk6jp9q09d83zfejn0wpqkxlu9xwnfyc959qqm7k8pwxyymf8
2940000030000	5	294	pool16kahh6ejmg29cc3rd4eecmhnsxm56jku9d8laluamqadsplvkx5
\.


--
-- Data for Name: pool_rewards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_rewards (id, stake_pool_id, epoch_length, epoch_no, delegators, pledge, active_stake, member_active_stake, leader_rewards, member_rewards, rewards, version) FROM stdin;
1	pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g	1000000	0	0	500000000	0	0	0	0	0	1
2	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5	1000000	0	0	400000000	0	0	0	0	0	1
3	pool13kpk6jp9q09d83zfejn0wpqkxlu9xwnfyc959qqm7k8pwxyymf8	1000000	0	0	400000000	0	0	0	0	0	1
4	pool16kahh6ejmg29cc3rd4eecmhnsxm56jku9d8laluamqadsplvkx5	1000000	0	0	500000000	0	0	0	0	0	1
5	pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz	1000000	0	0	400000000	0	0	0	0	0	1
6	pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf	1000000	0	0	410000000	0	0	0	0	0	1
7	pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5	1000000	0	0	600000000	0	0	0	0	0	1
8	pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve	1000000	0	0	410000000	0	0	0	0	0	1
9	pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc	1000000	0	0	410000000	0	0	0	0	0	1
10	pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw	1000000	0	0	500000000	0	0	0	0	0	1
11	pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg	1000000	0	0	420000000	0	0	0	0	0	1
12	pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g	1000000	1	0	500000000	0	0	0	8373086431433	8373086431433	1
13	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5	1000000	1	0	400000000	0	0	0	4567138053508	4567138053508	1
14	pool13kpk6jp9q09d83zfejn0wpqkxlu9xwnfyc959qqm7k8pwxyymf8	1000000	1	0	400000000	0	0	0	8373086431433	8373086431433	1
15	pool16kahh6ejmg29cc3rd4eecmhnsxm56jku9d8laluamqadsplvkx5	1000000	1	0	500000000	0	0	0	12179034809357	12179034809357	1
16	pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz	1000000	1	0	400000000	0	0	0	7611896755848	7611896755848	1
17	pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf	1000000	1	0	410000000	0	0	0	10656655458187	10656655458187	1
18	pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5	1000000	1	0	600000000	0	0	0	7611896755848	7611896755848	1
19	pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve	1000000	1	0	410000000	0	0	0	6089517404678	6089517404678	1
20	pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc	1000000	1	0	410000000	0	0	0	5328327729093	5328327729093	1
21	pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw	1000000	1	0	500000000	0	0	0	9895465782602	9895465782602	1
22	pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg	1000000	1	0	420000000	0	0	0	7611896755848	7611896755848	1
23	pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g	1000000	2	3	500000000	7773227570018496	7773227270018496	0	6057861144406	6057861144406	1
24	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5	1000000	2	3	400000000	7773227770015680	7773227270015680	0	5192452275894	5192452275894	1
25	pool13kpk6jp9q09d83zfejn0wpqkxlu9xwnfyc959qqm7k8pwxyymf8	1000000	2	3	400000000	7773227770015680	7773227270015680	0	8654087126491	8654087126491	1
26	pool16kahh6ejmg29cc3rd4eecmhnsxm56jku9d8laluamqadsplvkx5	1000000	2	3	500000000	7773227570018496	7773227270018496	0	6057861144406	6057861144406	1
27	pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz	1000000	2	3	400000000	7773227770188889	7773227270188889	0	9519495838929	9519495838929	1
28	pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf	1000000	2	3	410000000	7773227770188881	7773227270188881	0	3461634850518	3461634850518	1
29	pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5	1000000	2	3	600000000	7773227470188881	7773227270188881	0	4327043730145	4327043730145	1
30	pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve	1000000	2	3	410000000	7773227770188881	7773227270188881	0	9519495838929	9519495838929	1
31	pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc	1000000	2	3	410000000	7773227770188881	7773227270188881	0	6057860988409	6057860988409	1
32	pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw	1000000	2	3	500000000	7773227870191653	7773227270191653	0	5192452208977	5192452208977	1
33	pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg	1000000	2	3	420000000	7773227770188881	7773227270188881	0	11250313264188	11250313264188	1
34	pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g	1000000	3	3	500000000	7773227570018496	7773227270018496	0	0	0	1
35	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5	1000000	3	3	400000000	7773227770015680	7773227270015680	1658662600648	9396874040753	11055536641401	1
36	pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz	1000000	3	3	400000000	7773227770188889	7773227270188889	1275970808158	7228288146577	8504258954735	1
37	pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf	1000000	3	3	410000000	7773227770188881	7773227270188881	1403534738976	7951150111233	9354684850209	1
38	pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5	1000000	3	3	600000000	7773227470188881	7773227270188881	0	0	0	1
39	pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve	1000000	3	3	410000000	7773227770188881	7773227270188881	255459361614	1445392429331	1700851790945	1
40	pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc	1000000	3	3	410000000	7773227770188881	7773227270188881	1531107169793	8674003575888	10205110745681	1
41	pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw	1000000	3	3	500000000	7773227870191653	7773227270191653	638151192355	3613978230308	4252129422663	1
42	pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg	1000000	3	3	420000000	7773227770188881	7773227270188881	1148389877341	6505443181919	7653833059260	1
43	pool13kpk6jp9q09d83zfejn0wpqkxlu9xwnfyc959qqm7k8pwxyymf8	1000000	3	3	400000000	7773227770015680	7773227270015680	1531115669827	8673995076083	10205110745910	1
44	pool16kahh6ejmg29cc3rd4eecmhnsxm56jku9d8laluamqadsplvkx5	1000000	3	3	500000000	7773227570018496	7773227270018496	0	0	0	1
45	pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g	1000000	4	3	500000000	7781600656449929	7781600356449929	0	0	0	1
46	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5	1000000	4	3	400000000	7777794908069188	7777794408069188	672510060606	3808678711147	4481188771753	1
47	pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz	1000000	4	3	400000000	7780839666944737	7780839166944737	1792106238679	10153054336252	11945160574931	1
48	pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf	1000000	4	3	410000000	7783884425647068	7783883925647068	671984199169	3805698832223	4477683031392	1
49	pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5	1000000	4	3	600000000	7780839366944729	7780839166944729	0	0	0	1
50	pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve	1000000	4	3	410000000	7779317287593559	7779316787593559	1232417699783	6981487307298	8213905007081	1
51	pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc	1000000	4	3	410000000	7778556097917974	7778555597917974	1344565565793	7616934942088	8961500507881	1
52	pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw	1000000	4	3	500000000	7783123335974255	7783122735974255	672049927117	3806070964266	4478120891383	1
53	pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg	1000000	4	3	420000000	7780839666944729	7780839166944729	1344145554005	7614724877193	8958870431198	1
54	pool13kpk6jp9q09d83zfejn0wpqkxlu9xwnfyc959qqm7k8pwxyymf8	1000000	4	3	400000000	7781600856447113	7781600356447113	784173267565	4441323280383	5225496547948	1
55	pool16kahh6ejmg29cc3rd4eecmhnsxm56jku9d8laluamqadsplvkx5	1000000	4	3	500000000	7785406604827853	7785406304827853	0	0	0	1
56	pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g	1000000	5	3	500000000	7787658517594335	7787658217360538	0	0	0	1
57	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5	1000000	5	3	400000000	7782987360345082	7782986860011087	1266055455115	7172101171903	8438156627018	1
58	pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz	1000000	5	3	400000000	7790359162783666	7790358662171341	1264857735197	7165314096474	8430171831671	1
59	pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf	1000000	5	9	410000000	7791744953774444	7791744453551781	421765277997	2387792220024	2809557498021	1
60	pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5	1000000	5	3	600000000	7785166410674874	7785166210563543	0	0	0	1
61	pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve	1000000	5	3	410000000	7788836783432488	7788836282820163	1054309329373	5972206974104	7026516303477	1
62	pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc	1000000	5	3	410000000	7784613958906383	7784613458516722	738524697523	4182704826891	4921229524414	1
63	pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw	1000000	5	3	500000000	7788315788183232	7788315187782437	1370594434582	7764487805539	9135082240121	1
64	pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg	1000000	5	3	420000000	7792089980208917	7792089479485260	1369913631768	7760743921956	9130657553724	1
65	pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g	1000000	6	3	500000000	7787658517594335	7787658217360538	0	0	0	1
66	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5	1000000	6	3	400000000	7794042896986483	7792383734051840	1214244442901	6868758485585	8083002928486	1
67	pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz	1000000	6	3	400000000	7798863421738401	7797586950317918	1091873812772	6178332285073	7270206097845	1
68	pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf	1000000	6	9	410000000	7801099638624653	7799695603663014	849143820584	4803840006775	5652983827359	1
69	pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5	1000000	6	3	600000000	7785166410674874	7785166210563543	0	0	0	1
70	pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve	1000000	6	3	410000000	7790537635223433	7790281675249494	485620210088	2749035702553	3234655912641	1
71	pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc	1000000	6	3	410000000	7794819069652064	7793287462092610	1092651548477	6181326705326	7273978253803	1
72	pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw	1000000	6	3	500000000	7792567917605895	7791929166012745	728277400881	4122442328009	4850719728890	1
73	pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg	1000000	6	3	420000000	7799743813268177	7798594922667179	606602218011	3431945269530	4038547487541	1
74	pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g	1000000	7	3	500000000	7787658517594335	7787658217360538	0	0	0	1
75	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5	1000000	7	3	400000000	7798524085758236	7796192412762987	1292493028931	7307347364044	8599840392975	1
76	pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz	1000000	7	3	400000000	7810808582313332	7807740004654170	553537583999	3126311676795	3679849260794	1
77	pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf	1000000	7	9	410000000	7805577304745717	7803501285584909	1383280882920	7822507832528	9205788715448	1
78	pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5	1000000	7	3	600000000	7785166410674874	7785166210563543	0	0	0	1
79	pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve	1000000	7	3	410000000	7798751540230514	7797263162556792	922712486659	5219851495016	6142563981675	1
80	pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc	1000000	7	3	410000000	7803780570159945	7800904397034698	1384410740193	7823497506787	9207908246980	1
81	pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw	1000000	7	3	500000000	7797046038497278	7795735236977011	922795533662	5221112053459	6143907587121	1
82	pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg	1000000	7	3	420000000	7808702683699375	7806209647544372	1014377147732	5733832571453	6748209719185	1
83	pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g	1000000	8	3	500000000	7787658517594335	7787658217360538	0	0	0	1
84	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5	1000000	8	3	400000000	7806962242385254	7803364513934890	1155977426005	6528263113801	7684240539806	1
85	pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz	1000000	8	3	400000000	7819238754145003	7814905318750644	481348207987	2715391783904	3196739991891	1
86	pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf	1000000	8	9	410000000	7808386862243738	7805889077804933	770007904256	4351884475823	5121892380079	1
87	pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5	1000000	8	3	600000000	7785166410674874	7785166210563543	0	0	0	1
88	pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve	1000000	8	3	410000000	7805778056533991	7803235369530896	1251515198457	7074341613161	8325856811618	1
89	pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc	1000000	8	3	410000000	7808701799684359	7805087101861589	1059458483881	5982859499318	7042317983199	1
90	pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw	1000000	8	3	500000000	7806181120737399	7803499724782550	1059077010656	5985514993912	7044592004568	1
91	pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg	1000000	8	3	420000000	7817833341253099	7813970391466328	673630456291	3802610082052	4476240538343	1
92	pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g	1000000	9	3	500000000	7787658517594335	7787658217360538	0	0	0	1
93	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5	1000000	9	3	400000000	7815045245313740	7810233272420475	855005427889	4823010682498	5678016110387	1
94	pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz	1000000	9	3	400000000	7826508960242848	7821083651035717	1043859209929	5885773335461	6929632545390	1
95	pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf	1000000	9	9	410000000	7811840227177219	7808493298917830	1423865523190	8043377259528	9467242782718	1
96	pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5	1000000	9	3	600000000	7785166410674874	7785166210563543	0	0	0	1
97	pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve	1000000	9	4	410000000	7811212328808472	7808184021595289	949211771787	5362790761438	6312002533225	1
98	pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc	1000000	9	3	410000000	7815975777938162	7811268428566915	854847223422	4822492889574	5677340112996	1
99	pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw	1000000	9	3	500000000	7811031840466289	7807622167110559	1803743584026	10189338345046	11993081929072	1
100	pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg	1000000	9	3	420000000	7821871888740640	7817402336735858	569457329293	3212583034570	3782040363863	1
101	pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g	1000000	10	3	500000000	7787658517594335	7787658217360538	0	0	0	1
102	pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5	1000000	10	3	400000000	7823645085706715	7817540619784519	467853794138	2635242990412	3103096784550	1
103	pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz	1000000	10	3	400000000	7830188809503642	7824209962712512	1401594777863	7899915760217	9301510538080	1
104	pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf	1000000	10	9	410000000	7821046015892667	7816315806750358	1121647259756	6328259934626	7449907194382	1
105	pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5	1000000	10	3	600000000	7785166410674874	7785166210563543	0	0	0	1
106	pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve	1000000	10	4	410000000	7817354892790147	7813403873090305	654373849715	3693457295040	4347831144755	1
107	pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc	1000000	10	3	410000000	7825183686185142	7819091926073702	1028676806099	5796793820732	6825470626831	1
108	pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw	1000000	10	3	500000000	7817175748053410	7812843279164018	1121881979874	6331713648433	7453595628307	1
109	pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg	1000000	10	3	420000000	7828620098459825	7823136169307311	1307956840304	7375192589613	8683149429917	1
\.


--
-- Data for Name: stake_pool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_pool (id, status, last_registration_id, last_retirement_id) FROM stdin;
pool1w9de37uckddsjwvvnc4djqtxzwx7yv7qujhyv90ayvccsudkq7g	retiring	2500000070000	2940000000000
pool1cfcgeshpeeu5ygzcg77vapt3n3ythw9vh3rdgnqkhf2573skew5	retiring	2500000000000	2940000010000
pool129yqy5ersfdk0zv0s8ea4rtf6adsc6lu5uscz2qrdsy92grpjdz	active	2500000010000	\N
pool17t30q49jpdx2e2j76rptdwpz0z4ztruy5pvdv6u7w9n7vu6a3hf	active	2500000020000	\N
pool10h4mkut7tgaplhnq38hvda9w3qgd6ep2an8jf8yfht65x944mc5	active	2500000030000	\N
pool1cekw4xn4jdrffn9q0hyjzcvq6nnsvvm94unur4na728pg2wzrve	active	2500000050000	\N
pool18zp9d6ndsszwgqk4a8ea8uzs00dhxn7lgp0xafwacd98xkammrc	active	2500000080000	\N
pool1kun4cpje5j40kd48tk92zns2e4qrydfr8e7ytf46fq8zx4687aw	active	2500000090000	\N
pool1eadpf0g7w9ytvhd7r4ce2ssszr7kqlmvkncsmzem7c32xa38sgg	active	2500000100000	\N
pool13kpk6jp9q09d83zfejn0wpqkxlu9xwnfyc959qqm7k8pwxyymf8	retired	2500000040000	2940000020000
pool16kahh6ejmg29cc3rd4eecmhnsxm56jku9d8laluamqadsplvkx5	retired	2500000060000	2940000030000
pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	activating	110870000000000	\N
pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	activating	112580000000000	\N
\.


--
-- Name: pool_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_metadata_id_seq', 8, true);


--
-- Name: pool_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_rewards_id_seq', 109, true);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- Name: schedule schedule_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (name);


--
-- Name: subscription subscription_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (event, name);


--
-- Name: version version_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.version
    ADD CONSTRAINT version_pkey PRIMARY KEY (version);


--
-- Name: block_data PK_block_data_block_height; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.block_data
    ADD CONSTRAINT "PK_block_data_block_height" PRIMARY KEY (block_height);


--
-- Name: block PK_block_slot; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.block
    ADD CONSTRAINT "PK_block_slot" PRIMARY KEY (slot);


--
-- Name: current_pool_metrics PK_current_pool_metrics_stake_pool_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_pool_metrics
    ADD CONSTRAINT "PK_current_pool_metrics_stake_pool_id" PRIMARY KEY (stake_pool_id);


--
-- Name: pool_delisted PK_pool_delisted_stake_pool_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_delisted
    ADD CONSTRAINT "PK_pool_delisted_stake_pool_id" PRIMARY KEY (stake_pool_id);


--
-- Name: pool_metadata PK_pool_metadata_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata
    ADD CONSTRAINT "PK_pool_metadata_id" PRIMARY KEY (id);


--
-- Name: pool_registration PK_pool_registration_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_registration
    ADD CONSTRAINT "PK_pool_registration_id" PRIMARY KEY (id);


--
-- Name: pool_retirement PK_pool_retirement_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_retirement
    ADD CONSTRAINT "PK_pool_retirement_id" PRIMARY KEY (id);


--
-- Name: pool_rewards PK_pool_rewards_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_rewards
    ADD CONSTRAINT "PK_pool_rewards_id" PRIMARY KEY (id);


--
-- Name: stake_pool PK_stake_pool_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "PK_stake_pool_id" PRIMARY KEY (id);


--
-- Name: pool_metadata REL_pool_metadata_pool_update_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata
    ADD CONSTRAINT "REL_pool_metadata_pool_update_id" UNIQUE (pool_update_id);


--
-- Name: stake_pool REL_stake_pool_last_registration_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "REL_stake_pool_last_registration_id" UNIQUE (last_registration_id);


--
-- Name: stake_pool REL_stake_pool_last_retirement_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "REL_stake_pool_last_retirement_id" UNIQUE (last_retirement_id);


--
-- Name: pool_rewards UQ_pool_rewards_epoch_no_stake_pool_id}; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_rewards
    ADD CONSTRAINT "UQ_pool_rewards_epoch_no_stake_pool_id}" UNIQUE (epoch_no, stake_pool_id);


--
-- Name: archive_archivedon_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX archive_archivedon_idx ON pgboss.archive USING btree (archivedon);


--
-- Name: archive_id_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX archive_id_idx ON pgboss.archive USING btree (id);


--
-- Name: job_fetch; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_fetch ON pgboss.job USING btree (name text_pattern_ops, startafter) WHERE (state < 'active'::pgboss.job_state);


--
-- Name: job_name; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_name ON pgboss.job USING btree (name text_pattern_ops);


--
-- Name: job_singleton_queue; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singleton_queue ON pgboss.job USING btree (name, singletonkey) WHERE ((state < 'active'::pgboss.job_state) AND (singletonon IS NULL) AND (singletonkey ~~ '\_\_pgboss\_\_singleton\_queue%'::text));


--
-- Name: job_singletonkey; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonkey ON pgboss.job USING btree (name, singletonkey) WHERE ((state < 'completed'::pgboss.job_state) AND (singletonon IS NULL) AND (NOT (singletonkey ~~ '\_\_pgboss\_\_singleton\_queue%'::text)));


--
-- Name: job_singletonkeyon; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonkeyon ON pgboss.job USING btree (name, singletonon, singletonkey) WHERE (state < 'expired'::pgboss.job_state);


--
-- Name: job_singletonon; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonon ON pgboss.job USING btree (name, singletonon) WHERE ((state < 'expired'::pgboss.job_state) AND (singletonkey IS NULL));


--
-- Name: IDX_block_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_block_hash" ON public.block USING btree (hash);


--
-- Name: IDX_block_height; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_block_height" ON public.block USING btree (height);


--
-- Name: IDX_pool_metadata_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_pool_metadata_name" ON public.pool_metadata USING btree (name);


--
-- Name: IDX_pool_metadata_ticker; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_pool_metadata_ticker" ON public.pool_metadata USING btree (ticker);


--
-- Name: IDX_stake_pool_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_stake_pool_status" ON public.stake_pool USING btree (status);


--
-- Name: job job_block_slot_fkey; Type: FK CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job
    ADD CONSTRAINT job_block_slot_fkey FOREIGN KEY (block_slot) REFERENCES public.block(slot) ON DELETE CASCADE;


--
-- Name: block_data FK_block_data_block_height; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.block_data
    ADD CONSTRAINT "FK_block_data_block_height" FOREIGN KEY (block_height) REFERENCES public.block(height) ON DELETE CASCADE;


--
-- Name: current_pool_metrics FK_current_pool_metrics_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_pool_metrics
    ADD CONSTRAINT "FK_current_pool_metrics_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id) ON DELETE CASCADE;


--
-- Name: pool_metadata FK_pool_metadata_pool_update_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata
    ADD CONSTRAINT "FK_pool_metadata_pool_update_id" FOREIGN KEY (pool_update_id) REFERENCES public.pool_registration(id) ON DELETE CASCADE;


--
-- Name: pool_metadata FK_pool_metadata_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata
    ADD CONSTRAINT "FK_pool_metadata_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id);


--
-- Name: pool_registration FK_pool_registration_block_slot; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_registration
    ADD CONSTRAINT "FK_pool_registration_block_slot" FOREIGN KEY (block_slot) REFERENCES public.block(slot) ON DELETE CASCADE;


--
-- Name: pool_registration FK_pool_registration_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_registration
    ADD CONSTRAINT "FK_pool_registration_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id) ON DELETE CASCADE;


--
-- Name: pool_retirement FK_pool_retirement_block_slot; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_retirement
    ADD CONSTRAINT "FK_pool_retirement_block_slot" FOREIGN KEY (block_slot) REFERENCES public.block(slot) ON DELETE CASCADE;


--
-- Name: pool_retirement FK_pool_retirement_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_retirement
    ADD CONSTRAINT "FK_pool_retirement_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id) ON DELETE CASCADE;


--
-- Name: pool_rewards FK_pool_rewards_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_rewards
    ADD CONSTRAINT "FK_pool_rewards_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id);


--
-- Name: stake_pool FK_stake_pool_last_registration_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "FK_stake_pool_last_registration_id" FOREIGN KEY (last_registration_id) REFERENCES public.pool_registration(id) ON DELETE SET NULL;


--
-- Name: stake_pool FK_stake_pool_last_retirement_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "FK_stake_pool_last_retirement_id" FOREIGN KEY (last_retirement_id) REFERENCES public.pool_retirement(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

