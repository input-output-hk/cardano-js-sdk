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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
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

SET default_with_oids = false;

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
    slot integer NOT NULL,
    minted_blocks integer NOT NULL,
    live_delegators integer NOT NULL,
    active_stake bigint NOT NULL,
    live_stake bigint NOT NULL,
    live_pledge bigint NOT NULL,
    live_saturation numeric NOT NULL,
    active_size numeric NOT NULL,
    live_size numeric NOT NULL,
    apy numeric NOT NULL
);


ALTER TABLE public.current_pool_metrics OWNER TO postgres;

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
    stake_pool_id character(56) NOT NULL,
    block_slot integer NOT NULL
);


ALTER TABLE public.pool_registration OWNER TO postgres;

--
-- Name: pool_retirement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_retirement (
    id bigint NOT NULL,
    retire_at_epoch integer NOT NULL,
    stake_pool_id character(56) NOT NULL,
    block_slot integer NOT NULL
);


ALTER TABLE public.pool_retirement OWNER TO postgres;

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
-- Data for Name: archive; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.archive (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output, archivedon) FROM stdin;
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.job (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output, block_slot) FROM stdin;
058cba17-6ffa-457a-be8c-2de0aeae35d6	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 20:59:01.230699+00	2023-09-05 20:59:05.21816+00	\N	2023-09-05 20:59:00	00:15:00	2023-09-05 20:58:01.230699+00	2023-09-05 20:59:05.231724+00	2023-09-05 21:00:01.230699+00	f	\N	\N
33654623-dc40-43a2-9ace-da9ae6a32f0b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 20:46:40.765579+00	2023-09-05 20:46:40.769073+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 20:46:40.765579+00	2023-09-05 20:46:40.780059+00	2023-09-05 20:54:40.765579+00	f	\N	\N
9a3ee0da-f697-4a36-a0c2-63da85193d22	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 20:58:08.976096+00	2023-09-05 20:59:08.966988+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 20:56:08.976096+00	2023-09-05 20:59:08.97474+00	2023-09-05 21:06:08.976096+00	f	\N	\N
25ef72c5-01dc-4002-bbc8-b4604278409f	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:00:01.227736+00	2023-09-05 21:00:01.236991+00	\N	2023-09-05 21:00:00	00:15:00	2023-09-05 20:59:05.227736+00	2023-09-05 21:00:01.246345+00	2023-09-05 21:01:01.227736+00	f	\N	\N
ef92e7b5-2acf-47c5-85bb-4138f9fcc53d	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:01:01.243847+00	2023-09-05 21:01:01.253938+00	\N	2023-09-05 21:01:00	00:15:00	2023-09-05 21:00:01.243847+00	2023-09-05 21:01:01.505569+00	2023-09-05 21:02:01.243847+00	f	\N	\N
b5ca8315-95dc-4385-8418-79bc898295f8	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:02:01.433736+00	2023-09-05 21:02:05.273497+00	\N	2023-09-05 21:02:00	00:15:00	2023-09-05 21:01:01.433736+00	2023-09-05 21:02:05.286321+00	2023-09-05 21:03:01.433736+00	f	\N	\N
87fb2839-748f-46cf-bb57-8ee765866337	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 20:46:40.775047+00	2023-09-05 20:47:08.965675+00	\N	2023-09-05 20:46:00	00:15:00	2023-09-05 20:46:40.775047+00	2023-09-05 20:47:08.970205+00	2023-09-05 20:47:40.775047+00	f	\N	\N
9191e758-09c0-4b3d-b25d-0e6ecc1e54e1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 20:47:08.957602+00	2023-09-05 20:47:08.961141+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 20:47:08.957602+00	2023-09-05 20:47:08.970725+00	2023-09-05 20:55:08.957602+00	f	\N	\N
472e2223-4327-4017-b237-3230bd029676	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 21:01:08.977564+00	2023-09-05 21:02:08.970939+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 20:59:08.977564+00	2023-09-05 21:02:08.982652+00	2023-09-05 21:09:08.977564+00	f	\N	\N
089ffbd4-3618-4faf-813f-f63e4782d38e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 21:04:08.985483+00	2023-09-05 21:05:08.974219+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 21:02:08.985483+00	2023-09-05 21:05:08.980959+00	2023-09-05 21:12:08.985483+00	f	\N	\N
f03a5588-d132-4c99-9e20-a425b5d93260	pool-metadata	0	{"poolId": "pool1k0hksc077c0jxjpgvhuvguat8jlv2r8xfxpa5vr6c4cz6m0jah4", "metadataJson": {"url": "http://file-server/SP1.json", "hash": "14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7"}, "poolRegistrationId": "880000000000"}	completed	1000000	0	21600	f	2023-09-05 20:46:40.865659+00	2023-09-05 20:47:08.973257+00	\N	\N	00:15:00	2023-09-05 20:46:40.865659+00	2023-09-05 20:47:09.014157+00	2023-09-19 20:46:40.865659+00	f	\N	88
147cf5e1-bac0-4d40-9922-ab018678c25e	pool-metadata	0	{"poolId": "pool1juahqjshmvjctnu5mz8s9rfkcxhre4mlqyn8zwl670dfsqlkdcd", "metadataJson": {"url": "http://file-server/SP3.json", "hash": "6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25"}, "poolRegistrationId": "2760000000000"}	completed	1000000	0	21600	f	2023-09-05 20:46:40.964011+00	2023-09-05 20:47:08.973257+00	\N	\N	00:15:00	2023-09-05 20:46:40.964011+00	2023-09-05 20:47:09.014939+00	2023-09-19 20:46:40.964011+00	f	\N	276
8420d24d-6d8c-4f00-ae18-3e9f71112c9b	pool-metadata	0	{"poolId": "pool1mkw72p4vv6pjvmptynat4d7w82lfhjjkq2vudu5pxwwawm5k4wp", "metadataJson": {"url": "http://file-server/SP4.json", "hash": "09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d"}, "poolRegistrationId": "3510000000000"}	completed	1000000	0	21600	f	2023-09-05 20:46:41.013247+00	2023-09-05 20:47:08.973257+00	\N	\N	00:15:00	2023-09-05 20:46:41.013247+00	2023-09-05 20:47:09.023711+00	2023-09-19 20:46:41.013247+00	f	\N	351
e5f3ab15-84f6-4651-9b02-d9b2baeb1be0	pool-metadata	0	{"poolId": "pool1l8echf2amze2xcatzn2lyyyp7zhm9s5r2hmy6gdw7pupzsz9wy9", "metadataJson": {"url": "http://file-server/SP10.json", "hash": "c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd"}, "poolRegistrationId": "9660000000000"}	completed	1000000	0	21600	f	2023-09-05 20:46:41.303503+00	2023-09-05 20:47:08.973257+00	\N	\N	00:15:00	2023-09-05 20:46:41.303503+00	2023-09-05 20:47:09.026306+00	2023-09-19 20:46:41.303503+00	f	\N	966
3b4c96b3-5d9e-4d75-b3b0-0a8edd9a1c48	pool-metadata	0	{"poolId": "pool1vj30jr7wn83dzn928qk6fx34h3d3f3cesr47j5ymeumf65wdw9x", "metadataJson": {"url": "http://file-server/SP7.json", "hash": "c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405"}, "poolRegistrationId": "5940000000000"}	completed	1000000	0	21600	f	2023-09-05 20:46:41.131695+00	2023-09-05 20:47:08.973257+00	\N	\N	00:15:00	2023-09-05 20:46:41.131695+00	2023-09-05 20:47:09.025722+00	2023-09-19 20:46:41.131695+00	f	\N	594
0c2b185a-4ad9-409d-bbae-2b47b80757a5	pool-metadata	0	{"poolId": "pool1efkpr4fnmxhe73xj47puagzqwtv23ucpt0fkuhgx249j6vpqxk4", "metadataJson": {"url": "http://file-server/SP11.json", "hash": "4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9"}, "poolRegistrationId": "11150000000000"}	completed	1000000	0	21600	f	2023-09-05 20:46:41.359306+00	2023-09-05 20:47:08.973257+00	\N	\N	00:15:00	2023-09-05 20:46:41.359306+00	2023-09-05 20:47:09.027147+00	2023-09-19 20:46:41.359306+00	f	\N	1115
8f851ad8-3dd2-42f2-aa40-e94e283ad377	pool-metadata	0	{"poolId": "pool10zg0pmcg4k2dqt2effxrff4zzqsu43dsdw3e8cvh69ct5n73d4c", "metadataJson": {"url": "http://file-server/SP5.json", "hash": "0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501"}, "poolRegistrationId": "4290000000000"}	completed	1000000	0	21600	f	2023-09-05 20:46:41.044664+00	2023-09-05 20:47:08.973257+00	\N	\N	00:15:00	2023-09-05 20:46:41.044664+00	2023-09-05 20:47:09.028303+00	2023-09-19 20:46:41.044664+00	f	\N	429
1d161613-6690-41a6-9bf7-73d227a2687c	pool-metadata	0	{"poolId": "pool1q3gwfchl2ehtumuhka45xfzf86vy6wratwunt8zqq6qaxkypra5", "metadataJson": {"url": "http://file-server/SP6.json", "hash": "3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba"}, "poolRegistrationId": "5290000000000"}	completed	1000000	0	21600	f	2023-09-05 20:46:41.091868+00	2023-09-05 20:47:08.973257+00	\N	\N	00:15:00	2023-09-05 20:46:41.091868+00	2023-09-05 20:47:09.031016+00	2023-09-19 20:46:41.091868+00	f	\N	529
6c7081a4-f182-4c28-9bf5-f2fe631aed9a	pool-metrics	0	{"slot": 3133}	completed	0	0	0	f	2023-09-05 20:46:43.58444+00	2023-09-05 20:47:08.973363+00	\N	\N	00:15:00	2023-09-05 20:46:43.58444+00	2023-09-05 20:47:09.256769+00	2023-09-19 20:46:43.58444+00	f	\N	3133
4cd476d6-dea6-49d8-ace4-f19bce252387	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 20:47:08.968903+00	2023-09-05 20:47:12.966031+00	\N	2023-09-05 20:47:00	00:15:00	2023-09-05 20:47:08.968903+00	2023-09-05 20:47:12.97246+00	2023-09-05 20:48:08.968903+00	f	\N	\N
86173c27-5e2f-4bfd-929a-59bbdea35a57	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 20:48:01.970882+00	2023-09-05 20:48:04.985083+00	\N	2023-09-05 20:48:00	00:15:00	2023-09-05 20:47:12.970882+00	2023-09-05 20:48:04.992221+00	2023-09-05 20:49:01.970882+00	f	\N	\N
2aa3c0d2-b949-414b-b212-95f863412ed6	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 20:49:01.990522+00	2023-09-05 20:49:05.007179+00	\N	2023-09-05 20:49:00	00:15:00	2023-09-05 20:48:04.990522+00	2023-09-05 20:49:05.016338+00	2023-09-05 20:50:01.990522+00	f	\N	\N
c84e2dab-ff31-4fc1-84a8-34da0892a59a	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 20:50:01.013936+00	2023-09-05 20:50:01.0269+00	\N	2023-09-05 20:50:00	00:15:00	2023-09-05 20:49:05.013936+00	2023-09-05 20:50:01.036185+00	2023-09-05 20:51:01.013936+00	f	\N	\N
f3b77935-f791-4ac1-a6f5-36a1965ad811	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 20:49:08.974292+00	2023-09-05 20:50:08.963544+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 20:47:08.974292+00	2023-09-05 20:50:08.974992+00	2023-09-05 20:57:08.974292+00	f	\N	\N
8be12ba5-9e93-451c-b681-a17a3a6791e5	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 20:51:01.033611+00	2023-09-05 20:51:01.050111+00	\N	2023-09-05 20:51:00	00:15:00	2023-09-05 20:50:01.033611+00	2023-09-05 20:51:01.061662+00	2023-09-05 20:52:01.033611+00	f	\N	\N
30c6318c-2dc6-40f3-9952-20c56150d3ed	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 20:52:01.058053+00	2023-09-05 20:52:01.078344+00	\N	2023-09-05 20:52:00	00:15:00	2023-09-05 20:51:01.058053+00	2023-09-05 20:52:01.089852+00	2023-09-05 20:53:01.058053+00	f	\N	\N
efec21c5-cb18-4efa-92b0-a63b12081225	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 20:53:01.086907+00	2023-09-05 20:53:01.099745+00	\N	2023-09-05 20:53:00	00:15:00	2023-09-05 20:52:01.086907+00	2023-09-05 20:53:01.109295+00	2023-09-05 20:54:01.086907+00	f	\N	\N
bfa6340d-724f-45c2-9ed0-429d36a82e91	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 20:52:08.979439+00	2023-09-05 20:53:08.964603+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 20:50:08.979439+00	2023-09-05 20:53:09.063434+00	2023-09-05 21:00:08.979439+00	f	\N	\N
2fc65435-d162-4fa4-9e6a-c122e92175ce	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 20:54:01.106977+00	2023-09-05 20:54:01.123037+00	\N	2023-09-05 20:54:00	00:15:00	2023-09-05 20:53:01.106977+00	2023-09-05 20:54:01.132327+00	2023-09-05 20:55:01.106977+00	f	\N	\N
a6d93f4d-2f36-475b-8e2b-dcf33fda3222	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 20:55:01.129981+00	2023-09-05 20:55:01.144385+00	\N	2023-09-05 20:55:00	00:15:00	2023-09-05 20:54:01.129981+00	2023-09-05 20:55:01.152513+00	2023-09-05 20:56:01.129981+00	f	\N	\N
2f22c7ae-3613-4476-bda4-22664e8bf4a8	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 20:56:01.15034+00	2023-09-05 20:56:01.163261+00	\N	2023-09-05 20:56:00	00:15:00	2023-09-05 20:55:01.15034+00	2023-09-05 20:56:01.171669+00	2023-09-05 20:57:01.15034+00	f	\N	\N
75da1824-8b3f-45c4-9fdb-774211b63ce3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 20:55:09.133101+00	2023-09-05 20:56:08.964896+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 20:53:09.133101+00	2023-09-05 20:56:08.973317+00	2023-09-05 21:03:09.133101+00	f	\N	\N
6a053d73-72ac-4e6d-8660-1b32ccaf200d	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 20:57:01.169355+00	2023-09-05 20:57:01.179475+00	\N	2023-09-05 20:57:00	00:15:00	2023-09-05 20:56:01.169355+00	2023-09-05 20:57:01.184667+00	2023-09-05 20:58:01.169355+00	f	\N	\N
f91632f2-f06f-4d1b-9536-9b1da61ece99	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 20:58:01.183267+00	2023-09-05 20:58:01.200199+00	\N	2023-09-05 20:58:00	00:15:00	2023-09-05 20:57:01.183267+00	2023-09-05 20:58:01.234603+00	2023-09-05 20:59:01.183267+00	f	\N	\N
fa7cebcd-fee8-4675-86d7-3db57c45eb70	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:21:01.645635+00	2023-09-05 21:21:01.66167+00	\N	2023-09-05 21:21:00	00:15:00	2023-09-05 21:20:01.645635+00	2023-09-05 21:21:01.670505+00	2023-09-05 21:22:01.645635+00	f	\N	\N
36182bdb-aa1e-47e7-90ac-d162477c719e	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:03:01.282287+00	2023-09-05 21:03:01.291204+00	\N	2023-09-05 21:03:00	00:15:00	2023-09-05 21:02:05.282287+00	2023-09-05 21:03:01.29951+00	2023-09-05 21:04:01.282287+00	f	\N	\N
bae2cd56-e486-4c10-9c2e-881e62e1775a	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:04:01.296848+00	2023-09-05 21:04:01.313176+00	\N	2023-09-05 21:04:00	00:15:00	2023-09-05 21:03:01.296848+00	2023-09-05 21:04:01.321696+00	2023-09-05 21:05:01.296848+00	f	\N	\N
cd7d6abb-7313-4916-8e03-6f402330f6bf	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:22:01.667883+00	2023-09-05 21:22:01.679547+00	\N	2023-09-05 21:22:00	00:15:00	2023-09-05 21:21:01.667883+00	2023-09-05 21:22:01.687381+00	2023-09-05 21:23:01.667883+00	f	\N	\N
2787819c-4e03-4185-b548-f002daccb328	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:05:01.319236+00	2023-09-05 21:05:01.338665+00	\N	2023-09-05 21:05:00	00:15:00	2023-09-05 21:04:01.319236+00	2023-09-05 21:05:01.348119+00	2023-09-05 21:06:01.319236+00	f	\N	\N
59c3f6c9-43d3-43ce-840d-5f316ceae4c3	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:23:01.685042+00	2023-09-05 21:23:01.696911+00	\N	2023-09-05 21:23:00	00:15:00	2023-09-05 21:22:01.685042+00	2023-09-05 21:23:01.705145+00	2023-09-05 21:24:01.685042+00	f	\N	\N
54d0450f-40ef-4e68-a8da-0ad2801812a3	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:06:01.345755+00	2023-09-05 21:06:01.356781+00	\N	2023-09-05 21:06:00	00:15:00	2023-09-05 21:05:01.345755+00	2023-09-05 21:06:01.361606+00	2023-09-05 21:07:01.345755+00	f	\N	\N
cf0f832e-29a2-44d6-874b-575ee88f6ddd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 21:22:08.997409+00	2023-09-05 21:23:08.986942+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 21:20:08.997409+00	2023-09-05 21:23:08.993842+00	2023-09-05 21:30:08.997409+00	f	\N	\N
fb778f81-fe31-4fcd-9d77-2db84f019fd5	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:07:01.360149+00	2023-09-05 21:07:01.380608+00	\N	2023-09-05 21:07:00	00:15:00	2023-09-05 21:06:01.360149+00	2023-09-05 21:07:01.571487+00	2023-09-05 21:08:01.360149+00	f	\N	\N
4f620772-2a8c-4e81-ae1d-c0ef1342dd5f	pool-metrics	0	{"slot": 9367}	completed	0	0	0	f	2023-09-05 21:07:29.417907+00	2023-09-05 21:07:29.452627+00	\N	\N	00:15:00	2023-09-05 21:07:29.417907+00	2023-09-05 21:07:29.619053+00	2023-09-19 21:07:29.417907+00	f	\N	9367
aee5c3e5-ceb0-4a48-842d-06f571adabbd	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:24:01.703362+00	2023-09-05 21:24:01.711779+00	\N	2023-09-05 21:24:00	00:15:00	2023-09-05 21:23:01.703362+00	2023-09-05 21:24:01.72006+00	2023-09-05 21:25:01.703362+00	f	\N	\N
b5a678bb-2801-4667-931d-24295845e16d	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:08:01.512819+00	2023-09-05 21:08:05.403714+00	\N	2023-09-05 21:08:00	00:15:00	2023-09-05 21:07:01.512819+00	2023-09-05 21:08:05.41362+00	2023-09-05 21:09:01.512819+00	f	\N	\N
37cdced9-dc72-483c-8958-ba90f0e62957	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 21:07:08.983585+00	2023-09-05 21:08:08.975517+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 21:05:08.983585+00	2023-09-05 21:08:08.982488+00	2023-09-05 21:15:08.983585+00	f	\N	\N
7bac96d2-2bf4-4118-bb5c-3df05f38dffc	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:25:01.717737+00	2023-09-05 21:25:01.735031+00	\N	2023-09-05 21:25:00	00:15:00	2023-09-05 21:24:01.717737+00	2023-09-05 21:25:01.744075+00	2023-09-05 21:26:01.717737+00	f	\N	\N
20cea1b3-408a-4285-9601-1c472fd51f4b	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:09:01.411318+00	2023-09-05 21:09:01.425286+00	\N	2023-09-05 21:09:00	00:15:00	2023-09-05 21:08:05.411318+00	2023-09-05 21:09:01.433475+00	2023-09-05 21:10:01.411318+00	f	\N	\N
6095d3e2-7f44-4e52-b4fe-d0e897638957	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:26:01.741522+00	2023-09-05 21:26:01.747652+00	\N	2023-09-05 21:26:00	00:15:00	2023-09-05 21:25:01.741522+00	2023-09-05 21:26:01.755056+00	2023-09-05 21:27:01.741522+00	f	\N	\N
d5143c90-0cdb-4f6e-9d31-c4693795fdd6	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:10:01.431111+00	2023-09-05 21:10:01.444427+00	\N	2023-09-05 21:10:00	00:15:00	2023-09-05 21:09:01.431111+00	2023-09-05 21:10:01.453801+00	2023-09-05 21:11:01.431111+00	f	\N	\N
89cbfeb9-f3b8-4cd7-940e-6122db1e4554	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 21:25:08.996111+00	2023-09-05 21:26:08.990549+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 21:23:08.996111+00	2023-09-05 21:26:08.996863+00	2023-09-05 21:33:08.996111+00	f	\N	\N
5b9dfe5e-a56a-45e4-b88d-871371665376	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:11:01.45101+00	2023-09-05 21:11:01.460282+00	\N	2023-09-05 21:11:00	00:15:00	2023-09-05 21:10:01.45101+00	2023-09-05 21:11:01.609448+00	2023-09-05 21:12:01.45101+00	f	\N	\N
41db6ca9-8a18-4d82-8116-bf322cc9f315	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 21:10:08.985138+00	2023-09-05 21:11:08.977937+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 21:08:08.985138+00	2023-09-05 21:11:08.987133+00	2023-09-05 21:18:08.985138+00	f	\N	\N
a50bd6c9-c4d4-4b28-b104-2e38f6cc340a	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:27:01.752905+00	2023-09-05 21:27:01.767213+00	\N	2023-09-05 21:27:00	00:15:00	2023-09-05 21:26:01.752905+00	2023-09-05 21:27:01.775611+00	2023-09-05 21:28:01.752905+00	f	\N	\N
fcc368c0-9a5e-421e-a4f3-8fd4a0575714	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:12:01.573189+00	2023-09-05 21:12:05.479903+00	\N	2023-09-05 21:12:00	00:15:00	2023-09-05 21:11:01.573189+00	2023-09-05 21:12:05.487635+00	2023-09-05 21:13:01.573189+00	f	\N	\N
e06c7e21-0c02-45db-9b2d-ad4992260b33	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:28:01.773084+00	2023-09-05 21:28:01.78305+00	\N	2023-09-05 21:28:00	00:15:00	2023-09-05 21:27:01.773084+00	2023-09-05 21:28:01.791032+00	2023-09-05 21:29:01.773084+00	f	\N	\N
43621aef-f604-4087-9d45-8578a5c1ba22	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:13:01.485467+00	2023-09-05 21:13:01.492719+00	\N	2023-09-05 21:13:00	00:15:00	2023-09-05 21:12:05.485467+00	2023-09-05 21:13:01.500136+00	2023-09-05 21:14:01.485467+00	f	\N	\N
ba136fc5-fcb2-42f1-9869-d16256121221	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:29:01.788839+00	2023-09-05 21:29:01.798707+00	\N	2023-09-05 21:29:00	00:15:00	2023-09-05 21:28:01.788839+00	2023-09-05 21:29:01.807888+00	2023-09-05 21:30:01.788839+00	f	\N	\N
1221489b-ebe5-4bb5-9b36-046f5db2ecf1	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:14:01.498287+00	2023-09-05 21:14:01.513551+00	\N	2023-09-05 21:14:00	00:15:00	2023-09-05 21:13:01.498287+00	2023-09-05 21:14:01.520975+00	2023-09-05 21:15:01.498287+00	f	\N	\N
b9d45ad7-a46d-4120-a9bd-77c0e42f2520	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 21:13:08.9905+00	2023-09-05 21:14:08.981927+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 21:11:08.9905+00	2023-09-05 21:14:08.989253+00	2023-09-05 21:21:08.9905+00	f	\N	\N
cff67474-7347-41c4-9bef-51d418ec241a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 21:28:08.999446+00	2023-09-05 21:29:08.992092+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 21:26:08.999446+00	2023-09-05 21:29:08.999751+00	2023-09-05 21:36:08.999446+00	f	\N	\N
a5d25322-1059-49da-8792-cd13f03a78d5	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:15:01.518856+00	2023-09-05 21:15:01.533756+00	\N	2023-09-05 21:15:00	00:15:00	2023-09-05 21:14:01.518856+00	2023-09-05 21:15:01.59278+00	2023-09-05 21:16:01.518856+00	f	\N	\N
87808ea0-7b58-40e3-8486-9c66f87fa355	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:30:01.805487+00	2023-09-05 21:30:01.824875+00	\N	2023-09-05 21:30:00	00:15:00	2023-09-05 21:29:01.805487+00	2023-09-05 21:30:01.830358+00	2023-09-05 21:31:01.805487+00	f	\N	\N
dcfa6740-8bae-4ff5-8087-7c8fba15c879	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:16:01.573354+00	2023-09-05 21:16:05.557791+00	\N	2023-09-05 21:16:00	00:15:00	2023-09-05 21:15:01.573354+00	2023-09-05 21:16:05.566525+00	2023-09-05 21:17:01.573354+00	f	\N	\N
3b651ce7-ea81-4ae7-ba64-134939a75905	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:17:01.564383+00	2023-09-05 21:17:01.574876+00	\N	2023-09-05 21:17:00	00:15:00	2023-09-05 21:16:05.564383+00	2023-09-05 21:17:01.582961+00	2023-09-05 21:18:01.564383+00	f	\N	\N
bb5dad78-1a6a-4652-b3cc-d0b9a96be854	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:31:01.82822+00	2023-09-05 21:31:01.844362+00	\N	2023-09-05 21:31:00	00:15:00	2023-09-05 21:30:01.82822+00	2023-09-05 21:31:01.854756+00	2023-09-05 21:32:01.82822+00	f	\N	\N
eb59ff20-95bb-4a5b-aa11-794083dd5a80	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 21:16:08.993511+00	2023-09-05 21:17:08.98294+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 21:14:08.993511+00	2023-09-05 21:17:08.989794+00	2023-09-05 21:24:08.993511+00	f	\N	\N
efc13703-d519-4636-9570-dd2b375054bc	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:32:01.852116+00	2023-09-05 21:32:01.864029+00	\N	2023-09-05 21:32:00	00:15:00	2023-09-05 21:31:01.852116+00	2023-09-05 21:32:01.868987+00	2023-09-05 21:33:01.852116+00	f	\N	\N
c7df8bc1-854a-49cc-8078-0db589307352	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:18:01.580873+00	2023-09-05 21:18:01.598642+00	\N	2023-09-05 21:18:00	00:15:00	2023-09-05 21:17:01.580873+00	2023-09-05 21:18:01.605217+00	2023-09-05 21:19:01.580873+00	f	\N	\N
9b1b3ab8-8914-459e-baf2-aa2891cd6dd0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 21:31:09.002781+00	2023-09-05 21:32:08.993694+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 21:29:09.002781+00	2023-09-05 21:32:09.002291+00	2023-09-05 21:39:09.002781+00	f	\N	\N
6240c57c-ae3b-44aa-9882-f2639c746144	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:19:01.603732+00	2023-09-05 21:19:01.619828+00	\N	2023-09-05 21:19:00	00:15:00	2023-09-05 21:18:01.603732+00	2023-09-05 21:19:01.627914+00	2023-09-05 21:20:01.603732+00	f	\N	\N
318349c1-c2de-4d7b-9824-0dc6b55784f3	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:20:01.625568+00	2023-09-05 21:20:01.639027+00	\N	2023-09-05 21:20:00	00:15:00	2023-09-05 21:19:01.625568+00	2023-09-05 21:20:01.648698+00	2023-09-05 21:21:01.625568+00	f	\N	\N
08d1714a-2654-4ec2-becf-c0d55bc4ad03	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 21:19:08.992351+00	2023-09-05 21:20:08.985687+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 21:17:08.992351+00	2023-09-05 21:20:08.994231+00	2023-09-05 21:27:08.992351+00	f	\N	\N
6eaa7960-a852-47a5-8fef-60ff869a2126	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:33:01.867605+00	2023-09-05 21:33:01.882674+00	\N	2023-09-05 21:33:00	00:15:00	2023-09-05 21:32:01.867605+00	2023-09-05 21:33:01.890886+00	2023-09-05 21:34:01.867605+00	f	\N	\N
bd177b80-5cd8-4bac-87fb-269181763c1f	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:34:01.888442+00	2023-09-05 21:34:01.901182+00	\N	2023-09-05 21:34:00	00:15:00	2023-09-05 21:33:01.888442+00	2023-09-05 21:34:01.906293+00	2023-09-05 21:35:01.888442+00	f	\N	\N
20bbeeae-a262-4c09-a899-08f55a3486d1	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:35:01.904789+00	2023-09-05 21:35:01.91773+00	\N	2023-09-05 21:35:00	00:15:00	2023-09-05 21:34:01.904789+00	2023-09-05 21:35:01.926823+00	2023-09-05 21:36:01.904789+00	f	\N	\N
ac916059-037b-4176-aebc-63098f485623	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 21:34:09.005533+00	2023-09-05 21:35:08.995699+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 21:32:09.005533+00	2023-09-05 21:35:09.00202+00	2023-09-05 21:42:09.005533+00	f	\N	\N
e527cf96-a0be-443f-bad4-a6b70d0527c4	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:37:01.942435+00	2023-09-05 21:37:01.956105+00	\N	2023-09-05 21:37:00	00:15:00	2023-09-05 21:36:01.942435+00	2023-09-05 21:37:01.964107+00	2023-09-05 21:38:01.942435+00	f	\N	\N
eafaf9e1-0993-456d-b0f5-0e540ab510f9	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:40:01.998233+00	2023-09-05 21:40:02.012239+00	\N	2023-09-05 21:40:00	00:15:00	2023-09-05 21:39:01.998233+00	2023-09-05 21:40:02.019869+00	2023-09-05 21:41:01.998233+00	f	\N	\N
54163d4d-5abc-4d08-a67a-08c45abe0218	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:36:01.924184+00	2023-09-05 21:36:01.936566+00	\N	2023-09-05 21:36:00	00:15:00	2023-09-05 21:35:01.924184+00	2023-09-05 21:36:01.945034+00	2023-09-05 21:37:01.924184+00	f	\N	\N
a5e64680-f4b4-45c9-a21e-67a1295f0ce1	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:38:01.961847+00	2023-09-05 21:38:01.974898+00	\N	2023-09-05 21:38:00	00:15:00	2023-09-05 21:37:01.961847+00	2023-09-05 21:38:01.982973+00	2023-09-05 21:39:01.961847+00	f	\N	\N
abbc2999-5fa3-415d-95f0-0c21b26c4b0c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-05 21:37:09.004685+00	2023-09-05 21:38:08.997989+00	__pgboss__maintenance	\N	00:15:00	2023-09-05 21:35:09.004685+00	2023-09-05 21:38:09.00514+00	2023-09-05 21:45:09.004685+00	f	\N	\N
029378d0-2c8a-46e0-aad9-4ed41cb219f5	__pgboss__maintenance	0	\N	created	0	0	0	f	2023-09-05 21:40:09.008243+00	\N	__pgboss__maintenance	\N	00:15:00	2023-09-05 21:38:09.008243+00	\N	2023-09-05 21:48:09.008243+00	f	\N	\N
18ff98d2-d723-4617-9327-6c5ddb31b672	__pgboss__cron	0	\N	created	2	0	0	f	2023-09-05 21:41:01.017672+00	\N	\N	2023-09-05 21:41:00	00:15:00	2023-09-05 21:40:02.017672+00	\N	2023-09-05 21:42:01.017672+00	f	\N	\N
2679cb54-f179-470e-bed0-36916c0a2831	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-05 21:39:01.980479+00	2023-09-05 21:39:01.994535+00	\N	2023-09-05 21:39:00	00:15:00	2023-09-05 21:38:01.980479+00	2023-09-05 21:39:01.99985+00	2023-09-05 21:40:01.980479+00	f	\N	\N
\.


--
-- Data for Name: schedule; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.schedule (name, cron, timezone, data, options, created_on, updated_on) FROM stdin;
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
20	2023-09-05 21:38:09.003471+00	2023-09-05 21:40:02.014995+00
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (height, hash, slot) FROM stdin;
0	5ea1de71311bca32250db52850d781e3ccc3dce16dce264412c5f417f69815c6	4
1	72bfaea3e861dc22dbbbbd648948ed8f791551097077e509ba4f0bb4d7100067	37
2	42c85682645f0b6c5971f274bcdd9f5aa89f0c8545ecbcbc28c17e0998ceebbe	42
3	c197ab9a5546723c7e8ba74005c95f3a510bcd5e2c53095df9553ad4a3eb11d4	43
4	e2eebf3be433eb9fd30e51a5bf9e3616c55275d4e0d68a6a4f19733505829f3f	44
5	e6bc01f6d60027fe11b14a1f9815ae44cebe66f680e8ed5d32e7e9acabaea3c4	53
6	d51677ced79b272336e56a1b692040506adc9fee747971970bae6d229ba8d688	61
7	366d6e140c55bbca05b9990d10486a68d725c983e06df38f8cb842e7f93bf26a	62
8	e01866460f8786b243b3a92ccd22419664c96adda4568b2d40fa2571dcf48e5b	73
9	eb0c71b95f74c5c241e3b616ab63b6f3492afa769dcdd48516858bcd80ebb58c	75
10	c2fd8f5dd5dc73e9ae39986afd5f4d6af3824df6af17d29a9c388a89966dd629	88
11	dd0d061d408dab86c49f78e0bf65d66482dc119e53bf27eec07bc4b6c0c1a065	91
12	f39fa0e04e8c591f339579a181076ca56803ec2c85599989b9f42914c02d8a82	93
13	382302ec7678e906bfa8bbda67e2b4df3d814e42f1f8cbbf37ad3b58216d8547	111
14	021f05da458c0c833c363c11fdc01b2032f79aa5c1cbc82ab1abd85d23d63797	117
15	edbd86f4adf10bbdf121b68ffde631503c3ad51d97672a9d18b0945d09527643	144
16	4b52f91646f2b35542a69907ca8c0ed2d433418cc80013dac271424eb9442627	151
17	8dba0fcce8fb406e40d6b7959f02b2959eeead877b61549e1ed475e42011e451	157
18	57b8a4d0ebf187872f5f22eb811ed6ce505c2538796d86fa18a9ba749e3f2e55	161
19	5978040e62c335ddef6548b410d3b4599f99ff77ee18c4c7f29d2180f9c70164	176
20	eda0bed5e6e1121cd40838c56187f8021aa401ffee23ff32edbde83fdcd2efd4	177
21	bb1d79694a1cafbb4030ca54363228d3914f869adf85ca1ce0fb0674646bbdf8	182
22	9a1b65383fd1af65297b0c4b1a7c90b0faca0841ae461e78bdc5c4f20109f3ba	195
23	8fd54087e08c80af23122abf16f3b443850a9d07041d6da9134085ac0212db6a	205
24	3dba6036dcbb1bea9e8b8dc6b31e8847ff84e6f2c82c4312d7c15c885e1bee18	208
25	b5ff42093e661ebfc93437364cddc8cbe67bb550e1d3fd61af273fc648cd36c4	238
26	9a264a460a2a3790024aac8237e9488c27cff2b59a8db0d592d2b9ca7b6c06c2	242
27	957674a2d513d9cbe850f96feb43336f6e0df6e09ca252452a76a3a62445c5d6	244
28	29c4886b3f4d337a49849e852549be7c41bf12001db9cd2380450ba88e843423	256
29	dd95b7044e60c360e3e790258a06a8c0ca9635eefd94d831485c2abdecff945f	276
30	9da842436d52cce696bffab36a9411a64852784b4be9e23e50339bc9b30149c4	289
31	111f37cae19a91f7aa0b0ec0e8cc1079a71c5fad2a744d9c1936eae88bc636ec	295
32	6e5d0d069943ecff6c8baf1655db34c6953bb1489ab24dad7450f4989c1dfc9c	314
33	321b452f1f0f6ce145c3ec97a1712866e2ec0cca61f7e8297f661311a02893d6	325
34	f53933b0fd0704262a04485c91f68d36ea7ef6f6dc4d51f92802a5d7ad164ca6	326
35	10cf80130ba3c7722a7c0d764ceff9ca06525c0f43bb1b9c4b3e4eafb2503bbf	335
36	7622c9e7c72ee34ee954840d37e63077b30c660254de798416ea993715fed60e	339
37	6073813f93049c7937c563f8ed9410c6d02ba980ca1b4765ae3a9ec26f697c1a	340
38	953229e4e846efed31f4192c43d560e8948c905bcb7ad59d38582e7c0f7a2b5c	341
39	9b3be3816def5c7c65e536e7f00e9114f7149b2f662aea7a086e30130b31bb33	342
40	caabd5715fb3c8859585b4706215db8b1288c61571152ee2931d92c57b9ff91b	351
41	d05233b549b63dc47c698de96f542a240ab765426eeea1ff116b2c5dcdc2570b	362
42	9891b2b6a2272d14318fd174af7d1bb6f4b2f910a94c3c9c0667c6b354441a95	367
43	eaa34666be7e12dd1129a9fde1020a45eb3565491fc2933e9334734f3ff3da69	386
44	335aacfea80e6a7f9b5521af93ffb67b392b344580f89c6ae6490854a553d677	390
45	2007369e23e482ea57dfd59f1087554cb227cfc727402a4a3d7c57b830eec081	400
46	9de0b4c8e8360f818bc88796dc263f06e219b5146aafa25880a3e317b0fafe12	407
47	d7fd94c9818eb48939793486cd903afdc8978a33acbaa299ee460bdfc23a4d51	408
48	6ebaa84320be5cceff1537427c481a52a0ebf2723b14dcc1ff042ef65ea90196	429
49	ac5d1622e26007171c837cab314d0b6cd36a32dd800c7043df85c60299aaf2a6	432
50	ee4c5d2209f133464b8608574191aa0f6f48093ad0f17af9ab828a6425f1d4d6	448
51	03044dd18ba7eda2a1d3b0162dc600c0bf3425c87cc9e1008f4c05096a8be8d7	452
52	f821b51870114d1d3364266ca99b527c04c868b998f7c31521fe74f3c37b9b32	453
53	15509d7f95ed13d465385dbd553feed2732a51b059c5c434f215aec5535b71fd	454
54	cfb40dfb421d84bda8847338dcd077fd8cfb07d6e564da7f41422e772ab45de3	466
55	e07acaeaeae0959e8c4b7ee7e32692bf069c008b8b282ebf3e5682fab35b9658	470
56	26c0c0db5656c97be0ea61a3ffd021c05efe4dc336d6de2bdca539c6704268b4	489
57	c19d7a0d596b81e26e40f6845ac01be2e634ef2eb7c9b3f5c17fb037db4180bf	491
58	d6b7f49478b2581a2412dde3c149541e9954a749c7b4525cbb152f9763a61db0	494
59	6146e68f3096d5d57c1bc34392682191e42532deea07dd835e14d566be43b6c5	521
60	97ad020f4d5e528d08cb4dbec9bf0795725cd6b875a58ba10eb0e3b2905bb455	529
61	f4b30f3b4f462aa7a9df2e4a3e19b535879833cc5d79452d8a582e2c1a14c0a2	539
62	9f9f8f0731ad1f9dce0fdcecf0514e6bf879a4cfa499f850fc75cbd594da5d26	543
63	959ac7f56b363e7fb86dfb96976d1293705bb87a7ed915d18125ad43fd9da673	551
64	c0254ef2eb7351a68322d7a011966ff757ada832035f4d1cfa0363fe699555be	554
65	d6a0c93115c513255cd2a5d743fa3c76180729215ca131bde3379d3547a85c39	568
66	7ee67ea09187075fd26bcf47d05b2500843f0a6a3e02a694bcfc1bba79ffcb47	569
67	6cf7cdcd96819cbc92b3f4243fdeda9beb3dc20eca80fe2de76d6bb19c4eaec5	573
68	9a53b07f90de21974373ca29e3bcd2ef7c96c7c2c5f7b96ee8753e7459c904fe	583
69	f6188fe56f3ee94ff049a1848dddcfe510a2e005bb345ed619477733ba8f3353	588
70	59e6085d301fe2d423ab6ba116f232a61e8f201b2d2056eb3f29a89e8a64a6b6	594
71	eb0320931693167e910538c210b3e12ee5f35065bb517ebaf18ff6e8391ac570	595
72	7aca1003537634d26677a69c1fb52a50341fa06b06185bc15e347ca76f57f0c2	607
73	c770e227fa50656eb3fcb47a45b3395bc81b0d0e35e5fc665b778835e502f6d6	608
74	e035db7cae9c6f849eb041101a6bf29b09a9abc8cb6f6d5f6e53f61073319157	619
75	31b40f8b0b6e091287967e17a49f1a2e1f0ff349e7ecac2efb56734b0a585a91	626
76	7a15dc0012f3f7293ddf63af6456750c7a10f9dc0952a4a02ba52e0fb8c88fbd	637
77	520b1339ce7126411c09a23759af7867323a1e2c2dcec4db0a32e9d4ebc5c259	647
78	046016ca06e10b77a0b86b73d6b459b9483a8c25433d95fd9a0c6174cba7a7f2	652
79	d21892b193a2b0676eaaeaf4cf42d5476cf30dfcce76f35d6be0623bd37b7ee0	672
80	f9f9def208cac966d4e60fcf926752066cd11157c636a485a3c51ee4793634d9	684
81	c11aa0b9fff72d10d1b83ace31f6c1da481ab91a956c58f9ef23e94d65f4e4ec	685
82	f9f9bec6bda2d2ec947da95655067adf83d7b0d0174915bc6006bc2166f9d347	688
83	1431cbd0ea237e4b64e925608fc0de6243c788f7a6abcac6ab03ed341db8b1e1	698
84	6549ddce46f8c480853a9cffd9a47a30aeeff72fded190c5fbaf2d55e525cb96	710
85	1fee3a6ca079492cae2ad1401338afaf186b4b3693e8b3e6c13ae02a17c0597c	725
86	02153b83bf89c11066d3078c337b71c166b2f01abd439a7b17ad4b69ded7b96c	749
87	451b98e5824a9940f5120041a982c60dabe0bda201c90a5479d030f0deb9b8e0	809
88	2dfa211d7a882a40ac0fef5ad89b3f08d840a68775cd9335890eae25e9894026	821
89	e28d47965e2a7fad9a224b1116693bf26a1e1b9cb89c943ee241ecf883dd58dd	826
90	eb3a8d346d734fdc6e2391c12b58bd1de8277334603dbd345710120ff2af611c	828
91	874571dae456c11bfe12295095f8fb0f47d754eabb910fb332a7a86aa6163188	846
92	78852da0f97b6edf0a3e2e765d7a56b3c94b510881147c136ce00bca8f78e548	872
93	e95fc4f20dd35c5743779f3d2ad66ca5cc70115776ed06804ef4b2a639e384f3	883
94	377956152834dcc89b6c0e680d65d9603a0ea65676aed70cf3c44c0a3f78339a	886
95	23e2a2a398595f8215f847f7637760dd0de1d357587a68934135560e2352d6be	894
96	fced3c20284bb33e29abbac120421a69a125349d775604de2d8c2a2790712646	895
97	e26d8b5bf88150618da15cbdba7bafc4f0b043a42af139d4af6e2ee2169141e8	900
98	bb95b84ca787f7d4cace54aa99e2b3995ea3b1276a4b5ad34834c17177184f1d	902
99	8b4032a825d2eae54aad215dbd3d7abdb63182d1612dd2e92dfe613100ecc92b	913
100	6bc3d322fa4e3f1d3ee46bc5922337652eed92fe5a54f8454ba1da248b3eca77	920
101	39aeb588f7a16dcad1ce3a595e7dfe238d38ed1cd85572534e9ccde31b4f15d2	937
102	ad620e201d4c9e19c2f147f00e80974fbc99450d3d737172beea1da2e06623fe	966
103	3c27dda6439831a238d73ed2aa2ef68996192818e000b46774feb704b710c258	973
104	78658e0b6d46edf46fbf3b85faed0b5bbe814a8f412852c7175ecefa0eed6711	993
105	d4cb896b886ecbd73b9d9c277a50584eeabd5c159d4fd9157bdacd5d2917368b	1004
106	7feaa49294b47166660cedda242bbdc184719e8f1c64de0d1e3fd68085e5a05f	1015
107	6c44cf007728aea557bce08a76da670f2fd08523e325929fa4528704d7f1e73e	1023
108	ea7fb38467bf96b087235723664c21d839335f55c89ac9cbe16d51da6093a217	1026
109	cffcef123f1a4befe775e805477dc02270f973931da175af8555a64201e93ab8	1034
110	7fc4e19cc2e247300e90eeae3b55eb02615efbf4892d2ef198feec14db8609c5	1054
111	ebed0f860e7900d6cc393a7dbfdeb849a6eac1eeb4956e028ff71bc942f83da1	1059
112	72c2bd2fb6b77ff706153902286ed40ec443edbd459e152f96ee1150f2c75450	1077
113	c95bfae18091a961936e3c314d43aeff6316917b6e17f3c7ee8bed73852639ac	1080
114	671ba836e58594b2697868e64737b7b21ff36e7a5e56d0d5ce128e53a30a0804	1115
115	2ad7bbd99068acae737e52d3856f38079e6715689e24afb6a56ed5c705b189cc	1118
116	8f8d3e7298492eb2917f23e41c1b81f2f7caa8529a03e8edb498c9907172e192	1124
117	7f54bfeb3e76708f370b63fdedf85fa011a5ddd9a8832fe83e389d75b6714366	1144
118	eb7177e49180c6e4205264a1b6f91a6e537b0b854c5e20627a7fdd4486360fe6	1145
119	37cf27ddd261cc13a45059ab15cfa13f826b01f5613b6bf76034b947b0e7b4a4	1164
120	974b2f6cd1176cf7a087344edfd472027cb9011a0a554f20ca593e777b3abe09	1165
121	6b6a39cb3cb42ae24c13031b45660b9b0c46e8ded038d512388b50448ffcf51b	1189
122	b0d9c1bc145b0c6d5836d3dfd9b9559e0090ab04d6433fbc9a23cf2c1e4188f0	1191
123	81bc4348518e779580866ea46036ea88a8a3603fde57444eefa78b7616b1ba25	1204
124	8cac45cebe1a346ac51562848aec4ece1bef261429421e270f3a6a4ee3b1a273	1209
125	2afb228be22bf56794c95d9b42d6e0fa62478d2cf0689cf49e8111dba6bfd07e	1215
126	27434d4a7e18099a2fb59a240355e6c094d56a284acc0e933154082c30a6c44d	1224
127	8c4511bf9cc5bcf2feafdc1e09629d0175f875366a9437e39e9f346bd6e374f8	1229
128	f4fb36a4fd2cd32e3278ed911fbbd24465654c7da9454e8622701b7a94a7ecee	1233
129	1d779b554dd2b98b7d87ac3b5de23c672c2d7dde06d82aeebfd5c1cfc1496b7b	1260
130	a741ed20eeec37bff7f120ed7173d19e81e0e08bfda3f6c51425ce03ef04c9b8	1263
131	c89e1be730f32d1060e83d595b563ff1575bec6c4b5043bc3832e710434591fb	1264
132	cfd3e88bd2bc3b5ea8102a482adce275ec01f3a288fb9090df5729eadca5cbf9	1276
133	1616ba033ec487ca01b8e801c59699217be5e15d59916342d9c9e8348f0a7d85	1288
134	faf449babd387b431d37580219378097fdd3639e50e4db8a08b2865de2189733	1290
135	f09382bfacbdd42a34adb33089a9c545df4f19e3605e66c82c166d6d1367a2ce	1291
136	fab1f11ac9bce0a4722d913ebc1c8778f537f2b47244cad40338357a2d37ed26	1292
137	d6501f7cc0b09c45beaa185b6297e8f8b09eff48f6623e549b58216322fd3c0a	1316
138	8ec08768eac842c81f5878c09c70aed50f740eddfe07500aabf7ddc7961f8783	1330
139	04ea2bfc6e79af881ca77598db063583dab8d1c7f3c186d25906620486f51376	1355
140	74f3db3edbce2eabbd5d5ceec9ccd2aa83b016264ca8f4e2a331f803afdc793c	1364
141	fb76ed99107ba920515e1b61885fa80f5ea86bfea84027209ef7eeba30984470	1365
142	c12bf1857be0f1da4779d670348c81b9e46c75889d4f1cf206f9c97f7eb9a5c7	1375
143	2c1db96bc0240918f80f2673530baa5b3ab9cdf4d27a8e79c27792ef797f26de	1395
144	229642df1e99f3cd8478c8d103cfeb4bbb7e0764b75cbf1543de4565c43fcc73	1398
145	1854cfa9cb8f3a11e14eb75d19fa66b31f5323e8729538ca550056e963c7abef	1419
146	d1593ee659fe8bf4456bce06bf82f6ba39199633f2b82c7a353a8a74341b9199	1433
147	7186d4a94853c0615af615e466db09cce3e2744cb371c415c1ff30cbd85e58ab	1442
148	c557ef4433d678486e14224ad58af7287b3b44162fa15b89ef7f7af1cf386f31	1443
149	214e48aaa0efcf632685a4a24866374037f5610696836dc0dcc1e53ca5775f1e	1446
150	a03d8db80a7fa6d3cf3557b140e72b4024363ca6beef77a5ebf01ddef93a05de	1467
151	3f1e8cbb0f5bb457175390492c192bd13bcf1981f9b2fc626c8f9cd41716389c	1487
152	d987f03b8308a8fe89376e184831445c991cb9892b7cf9ed44e27721e978afc5	1499
153	d3ee65e08dfd307294afb9cc47d43fbf5fa0c9606216f90e5813b24d2eee5d41	1501
154	c71b31e75d1367692ab339bf4502c460aa019a0df9712bf7e55c23950eb6d954	1510
155	3b9d22935425a5b4ff59eeeac6167a79919627f21f2ef2cc3bfd3bd343224793	1518
156	ebf24b64a835650ed31da891819605bb99dd1a29b43319ab586a0d57e0245bb8	1543
157	1c08fbc9121ca6e7611970a2fcd968a9bca5a5e35c69c832acbb37a23ac26abe	1545
158	aef865e3c1faa146549ee9f9867eb73d048565eddd49be1662764f6a7b4bac9e	1549
159	b8040d1e26d48e1f2a2d64439dd088c165aefb80781118b421d57ca18ecc1d15	1550
160	0996a31287ae5ae8cc6a55c1f99392375ecf4e98c1d51bcfcb72190bdc43ec97	1567
161	5d35256798b4ee376dd8789115edc4384d117c95592a4c8af892d0b31e09ec07	1609
162	002b5dd2c997b43109cd0210d2c1f97656533ef1a9bd52ee6e439482ceea9c81	1619
163	147a42691bbb5c4577d90ca178cbb43ea13438eadfd8146997791cd1f1914af0	1626
164	0a1f6f4198500c74a8f20a55edf9c3227b057ed3a32dcf9f007a40bdb42e3627	1627
165	bd9cf0975cefb1f16627916a4f05279301a7fe5f92101955d446f6cc1fa0926e	1630
166	5218690c6ba8710d21032cdda5a3c1462317ca94b829829d0a51e052c35c1c0e	1636
167	124f4b595284af8cd607a8c2e94b16b7a2e4d75abf26be14ba539cee1b35c662	1637
168	490ba98eb4e9766ce9f749bad0a7c53d31ee01f66c2eb9b342cb71af0937b5bb	1647
169	cf1394278a9da88e23c3819225dab55921bf8a7fb4af93ace1555a52b69cfe15	1652
170	6929d54a631d90318e9b3028c523990d984f50162563539ef62ab31254aa5e36	1669
171	6d9c79833cec1ed18bae1942970ed9c923187cec4dc7209c7ce758b6b8a7c3d1	1682
172	4ef0d1dc681a024ca7c792a5966ab65ce6bb9fda076140e96b07c49623d43009	1695
173	8a2bf8f1ccbf9b7037f4c3994be4af3a6c3a68305c22948baaa41a17f0455b60	1712
174	6e8c03baa319d46c9bf0dc367666e52eb64246a925141985a7c36df5209c5eda	1714
175	19a4404c9c3b4619b0b60bdb8704d1fe2674fac5c7cc3d2ea050ecaaa9bbc5a2	1720
176	61ffb949eac6f3425ac02995f3ce9824ddf434391696dae038a31e6b6990a951	1734
177	fa465f6496a11b623669bc07f5bc951ebff44343e95f76279b5f4f3f23ca8019	1742
178	5389dca285dae87e4c50a4d55f197c3e350443a4ee44cd73b051d20be903ed05	1745
179	aa880c211c4fcbec9fb71e0f10fdc0f85f0e45743e171a7729b40ddd680ab33d	1746
180	0cd2132a8423c12a341e7b71dba23fd71968760bd81d846347a78af35f53022a	1754
181	c345d6be142514b6fd2bd1f27283c9a73644dec411526402f38e437ae74ef234	1765
182	d9f72cd7a35d2e671cb1e49072fd6ec891d4af80793b372d0553a9510a549202	1766
183	b575d37087202c07d8bf8060a8dc9cd6823b7bbbf322efdb7314b74dc6d0a60f	1786
184	5b032aeb711afddec8298c511cc3aa9ee86e8b2aa36957dd1cf2bc6fcf72848e	1802
185	8adf3cd6f4cc145f141fa8a907e62e8f2e0d50c6e65834669eaa5553207cd67b	1809
186	f1f1bdba92d50877911b6669c1c266a5af8eaaf58bce34e5ea8b702e708de59b	1812
187	99926f2980dc5c988096da80040f26393c13494ed7a658c42f5426fefc67b5cb	1815
188	40bd42039ede99816555343b06728e13ed6937ac75260fb364dc9c1172158343	1822
189	b1170cf10b1027c34ddc7d3a0fb8573131365c67939b2a66c30dc19020d971b7	1828
190	8c75e934441ff44711c640eb7c4d84ce95c275c48baa6a88d9f47ff35522bdf1	1830
191	d9bc658fd3e384c287269893b6c5078f8b0d377ddfa2d59bce59a87adfe49687	1832
192	ffd5171a05741481cd6eafbd2ed149338f740099368fceb424e7d46da7cbfa56	1834
193	f35b6c65eef9c171718b324adf5e8a4b971ec2719c101aaad0c134d6662caab8	1838
194	37eccc21adaefc2147c6aaecd51d2b51455a3eb7feb5d7c2e2d1f9189fb83760	1842
195	6da906f9f09258914a013d220f466134685058fdd25a3011a89598cd072c5c18	1847
196	d19f29a62746124d48aee20acea234f1aa6f82b309ed7732bea0956b5cacbce3	1852
197	e6faf1b76a153d62d1732c4ff625c2824f15195c60703f2136d331f6b5c12dd1	1853
198	106de2d11adc7c02f47fffe632af0b45bbaef66e8e18e2c3f49b26e2f485b8fa	1858
199	06d2b7ff233fcca7a4bb087fcfc9f653ded73286cfb4039a0188e8952d860299	1863
200	e23a9d8be85d7909db168ab35d6f01fdba754e042f7169c96264f68a6eb45c7d	1867
201	5549e25efbdfef44db4effce6349e2e25bbfbb33ce6764f4ff85d667bef36e23	1869
202	8c2619ae41396033af4aca15eac9661cce460f62e137fb6f040b96afd431f32f	1881
203	d907e01055034045aceb79cbed8090168039e6586c1da19c734bfda0317a1226	1882
204	c0a52f1e9e9355077d3819d67971938af54c635e2995c7c69d9409e2da5f8d26	1905
205	f4846023a946e29c4503de874ca35ab8288315c780b6de93caf1f0f67e18ebd8	1909
206	01919ca7da2f62ac834d3d825f74efb7e061b522cd53a4b9d4a0be874234cf7a	1926
207	863e85e41e6463de468af048dd6460d797509adf5567e487ec12b9b5749b14da	1928
208	de11c3ae7e2e509ceda7ec0005aa0a65868be07f5e8df3841082aa82626710e0	1935
209	3e3525b0aa72b7ef513522a047602e112a8b490835c0deda29b426b6a816e04c	1939
210	e35501ca03b69a5523f8d35ab4a45571270a213d67fedba0e9f51f30bef9434c	1969
211	574b9687240c1f25cd456f33822a37db42c37091f1c47d3c33019bff130ec669	1979
212	7889b510939c4bb72ab7c8c34a038a6945a34fc33b9c6174be64f9bf4587a167	2028
213	34811163eb8f109885ac83b37499f0e19a817f4c8038bde1ae112e11178026ad	2041
214	5fc6be135da4d224e466dfdf9ae2e9561bce45335822bc46bd262a5f461ff162	2043
215	a3eed4eba4f318462acee19020390089c71b85213218c48ed23860a1b285bf04	2049
216	1ec7f91d6f2bc4882c89b29f705e18a175005db6d5794558e51078e528b35e2d	2052
217	ab8973c7c03274f2cefef68284833521b40f3114b9abd5f9f046f43f5ef8f2ca	2054
218	ba560b497077de11c92d89ce586dddb932d495b57760a396e0a08a540fbb6caa	2081
219	9132a95dfb8d88250fd72dc5ef7f0a0af5e59602b336c9e36ae2711cb7c7b420	2093
220	fd2d6fdafa04ff3578bfbf99ab35fdc3256fe71110d5d85247953134b8a7269b	2094
221	4c0b62eca8e5fc16fa6333f0077ce21b0bd9c7602d7d8ecae7f9db6f63864f94	2097
222	b2d7558c144eeed41d81874bcf178c253a03ba9cbad67fdb9c19da9255bb9806	2113
223	17285c88061363df8c1595ba17869593f7ce71e2fdc97f23cb315e596e3ac3db	2129
224	eca19c93ae80c2b705135498474ab5c81cfd8e294f1ffe20fa785fc484fe9a70	2131
225	2a2984564375d1e33a44691d298df557e2779db8f08b8b0e34d1c4bf6d494e81	2134
226	03f2eb02c30bb7c7ad2d28e4e42e00dbd6c7d5b2c54e2669cb1e63ed6396e7a8	2139
227	0d8da47e6ab76d660cb45fba76d12fb03fb88f07e202b907149bf1d5bcb92885	2140
228	498923fd523fa1b254b123bbe52c7397c4ad6b9048454581f843d0789509d72a	2144
229	28c7d01fd3c90eeae07488e44d4aad06c23b34aebdc37864c566b59a29c5a674	2161
230	711066a9367e9b4402bc4baa5ee47d451ae1b67a443c79717918630110d91c47	2162
231	4faf49043cb55e13d0490477ba93cd02acedd38675492e15f79bd4489f99a8e3	2163
232	46ff86337099807c2887ca0c7b68069b636003d3c20dfc348c30d117e91e14a3	2181
233	214325189e19feb4288c10239ccfe1977a9565a323436a076cbc552e98f3e2d2	2195
234	def566c887de18fdb4cc3628406049cee73bf6907586150a1ddbd9c1cd528a2f	2199
235	83d656fd1adc31384cf76acab6c653ed5409c59f4313e8b0ee768b06b0c71713	2235
236	68b3b7db9621bf869809f46f2e94dbf1bca25c7b68280841515df903a0bbb775	2269
237	34f100eee269a59f994d91c152b516558ce13f8031dd1af7734470422b373ed4	2275
238	893b46acdcb0abe9cad85c76b74ed605d6ad714fad1ba93cd4790ea92c7024f7	2299
239	dff603dbbdc356298d38edf4c25b68f635aabe621b7db7cd7b0cf884c0951567	2325
240	62057124c2299f9d351519c23b58cc5f6eeac5cb9fdbe6dfefb289a98099b4a7	2330
241	408c1ebfbaed7c75a58f125a7c7b914c8c9ce55d44aca943bcf8ebc0c08fab4f	2342
242	68d3b641e961d3671799b8ead00aeed796ada980d59624807fbd9c6974156b12	2348
243	daac5cfbc98d3489410def857734ca3955b4e3bb8894df027629f843b7341be2	2354
244	ac9a791bcaa5d09df7c96f613498c95103e54315e170e8d96b8c4b024bb42d39	2371
245	0078d713077fec044a113186714f51bdda3b89d8fd87b81a8be63a2a68936761	2377
246	19a5a1449743e422fc9be5154e5b8b0ce4a4c9e0145e46a266ffdb37048445c1	2402
247	f139f6291367d1e53c55496a9babb536adb1b03bb8242a2020bb00f9face7f38	2416
248	421dbd8af4b96a5b57c9b91606c6b1fe39b73aba9e024012e74105606e1ef65e	2417
249	068601ff2b32f70512685751453f16d90332701c2e3b7438a21029f3e8c79b84	2426
250	e6ad3c78c66855ed5ccf71a19bfaefd594d709e680bbc15c29605d492c8516b6	2430
251	ac593e0018659fd406498040defff200708951f33477f94e551fc1eb8965e003	2431
252	d5e534f3c908c2542d262d1f993a2f032edfb4ef434e7f6a5f0e3171c5a552ce	2449
253	ee439cd7730372b32ac6d3b7e4663a1ddfb7ad8a9dc93172c0bdf6a7beab42cd	2452
254	1734f19a96968870258af954e46920efa77fee5fbba571ae1c964f5d56cbaca5	2459
255	2e676346b18b7b3045732abb74e90674546e6907829b6862e20d66106ca372c1	2463
256	7817d33193f6975de5101fd31b65cd0d5a2f8ba1c70edfb73d5b4ada3f54837c	2470
257	08646e33d728dac54f69546b11bfbfbcc01501ee8e8501fcd1ced16845606b18	2471
258	9a3ff545f1716b37feca295c011fd3f9c13531d2f523d1885bffa2c212dec44d	2472
259	41f51ab2a951723c2c6568268ca89fe88ab7eb753d1a3a2828cbc579330e78a7	2489
260	2768d02f11c84f4f71509bfc2106915f7253d0d680e737f48c65f1d5f0c5755c	2504
261	34c112190080f2520400162dc2db89693ae1002da8a59b756c360bedc6dfaf50	2506
262	11a68b3c6a029f0214824713e5dc8787f397038c25c350285d00bc569a2b2d6a	2510
263	69ba05271f895387a5e782c5df8bddd51b998750fe51ee42119594c72374c809	2520
264	142236510390f95a22f91cc97fca6670e564c659efe3c3f179725f0a44de10c8	2528
265	8bbbf51d87bada7a79464623e992fbb6b778f28f068015705c083064d1cc0454	2532
266	1dcf250e35aac9fb3ce9560efa46a0a27e9e2d4da52ae8374b617b671a293df0	2535
267	bb08e003b627104f7c4881afb77bec56481897cf656790aa9b19ff52de7962de	2548
268	8fe51c00889d5e276d9a7bdf36ba9cc248a797b3acddf581f199dcf2c1d1727c	2558
269	a6716c65e792fcdd9f371ccdc4bfdb0cf33ea4a033d9202f0b4424986c931d26	2566
270	437cacabdde88bb8d9258206fc37660a63c3a5951dfeaf504e8dbc8b9044e322	2567
271	3bf84e57a30300c0407ca9f0444ed980b73627c1918191a2b87daa89246b854c	2593
272	7ac8ffec5337c6033bed11aa96a60465a74e0905f53d4888e458971223e37d00	2595
273	dd893c88b26b2f6b7c5373409f2ac6e50137ef9830e9af59827caa552883a349	2606
274	3a8fadc8924194c0135fbccc3cc7a2596c9be23b157c0b577506abda132e3962	2613
275	09d1e5ba99254b28641908c9eefb5f1998b0af779f5f91162c1fa8566186d394	2620
276	84492bc0dc2547691c3ca4664bf367b563e5c3488a512e689fcd2603010d389c	2638
277	972ec741fc779afd4074664c7c5a368fa82d948b27585584a1118e65901e07d9	2650
278	93cbcc33a49a0da447d8517e10cbab6b5b4e40eedf902b7f2415365312d84a02	2653
279	b4fc85a0b057c2a45b104140b73c4a96c04248decc42df96e955d332ef0e5b0b	2655
280	51d206f71fb5c59b6c186ada546ef85a6f945a64e0669dbdfe44ee7bf5d3b497	2677
281	f1dbdc90951f363bf378fbd98ce2b21e4cd72c5f2cb2bc4d09b01a48295c721f	2678
282	daa382e016ff129d174c1c3662aa9b00d06ab1e9d3acee81171df214a0344fdb	2684
283	1ff4b22de7198d97cbbf18252d11bd95b39caacda3889ee27970d0a0c7060962	2697
284	f2ec947d93e2b3981ab5c7c8b6aab6cda3d1a665e6324a4936ee680ffc6c979f	2701
285	b2ff0812b4bd02bd6eac47fb9adf8890599ec65afa46ab662d416911f265bb38	2720
286	97ea5cc6636b7df47fc14468db12fb76ef314e62b07ba8c1159cc4b452e44f13	2721
287	280272d2b7ef688d8eed5942d2af0eae4846d1bf0d0f824d1c94b65c884b0efb	2722
288	afb0b5fe804e88976f96dcdee509fc10d2f95ed1f2a84932d31cfb77c0f67d71	2732
289	d4358af1359682d8f9f52f7e863e4daefb2bea968e919b234ef26d047babb143	2734
290	bccfcb45cbda6ef797b6246107205e1b7a79638220d3bb34ac8875d371c351fb	2737
291	72a3a677c186478d1566f8c2de2faa44acf62726cf108395e8260a14d3bdc016	2739
292	703491e62bb9b3ebcfc015f01a5495c7744e7c3df027dd4442f45c94772a2ab7	2743
293	214aca011ea3a15eb96eb61d6505e369e775fa65f64ebf9a99777282a4f17f0c	2754
294	bb4cc139663fb97d7a65b082efb955e041005caf620e989ea4487b7656618122	2757
295	044c03b3fd5e67a5edc092caf3ccec7431d05b5cd085cad5b2b9c91be85b1c58	2764
296	977fb6640eb041769481733d8f9470bb5adeef0954379af8b34dd0a352baa957	2768
297	de76b7bc5062192e17790afc4fc890f46de916b44bc663518bc2ba392e588c5f	2776
298	0bfb403261ea799a647f667fd09ebbfab868cf3cd3fd66f4532323fe5e8087bf	2790
299	bac6ba11e50629f02e925abc90e5539d7625b388b850d1623557e7d0a6b70563	2793
300	1435056e15d79bab17591cc60966523a56c093c0f5f2deeab0071cd17fc576d2	2797
301	9d3a9d928c33609692fc1442a514e9fb9eabac2cd4b5e3a8597d6c907eb06912	2818
302	818655fd03a3548cc17d51b4d4b9a6ab05ecc0f973a6e8cf6213420d64582f1c	2825
303	55f12aad6e77e00423438de2edb185471c96cdf0f0f988ab6fb49730b90034a4	2836
304	a09e1dd3215c18f3171c694d48b468fab4d3b980d8b6d397a84dd1e63788d273	2843
305	bfd5e8cc1c9d5770c0a7d08651f13405808b5facba9ee78c55f77658003aa680	2858
306	1eac15aa24f101009fada4bab67566ff4eba117ff9ad960ab05d0c5e0040fbd6	2868
307	e9655792b487850e59d2f258464ea055b9369e74888525fb1aef666d31a08187	2871
308	fa86ecfc4dec81c6b716b310d0c2b92a40c855efa4a99f780a960ca91424a987	2883
309	118eb050d23d43b9bdae399dfa092836000ab7cf8b06ac0c791fcebe889d4f8a	2891
310	de06b680d9cadc6b62a216b175d2af08d5540e6f8dc18cd0b7d02d6e92907701	2903
311	9f53b62063afa478e01e95d209324565d4795ce09f241437e2ea91090f75df16	2912
312	0f93aad53b50faf02b184c0ca9825588b5fc42afcde02c06159ff60b6c29a650	2914
313	130096f6912c98018ba55dd3c14e51d03db090a6f018c85362b5cd9d70fd4b8f	2922
314	624cf6b1255da6d046252452c510fd5da4b206148f9490fa88dcf3bbe743ddf4	2936
315	62eacaff19d83ee68da257f4523671bd224934f9ee5cadcb7fc5d27384fabcb7	2937
316	0c7c4ead91edfe4e9cc17127ba2dbd5a3ba3dd7be5609f7e0d84fa6e5ab981e5	2941
317	3afd072205bb5e7515294886971af3fc1b95c3a34c151fb6237e2d8c7dac6b2b	2973
318	79eee5c37cb377a0b28a87aac3b26b4ea1d828c301746123c11b249195594503	2980
319	f8b412f4dec0e02d9a649ea24424dacceb5e6116ba45a12a2a9ddf2f22cf3acd	2999
320	87ec1484da57bf99343753e99e29c099cc8171b9e41d98069ea6d7e3d032103c	3024
321	05bb0c3b635aad3204e47d2147b9acb3a04209228861c63ef70b57f46e222655	3033
322	0aa06f1e9cfa6d9c662878b03f440d75cf58bc6772d506c94b28490df946ecee	3044
323	f5bb105f998f6fe86f17199dea5cfc5bc993417f497a50d1f7007b60498d7327	3050
324	789669254fca12b641a31af6b1ee7728a55c4ecd28084a61222303fc548c0e7f	3062
325	c1e05c7d721288fb9087b10340679c25a0cc4a46499e1984974d0773af059cc7	3075
326	1547392a426b51bfeffc603832773f3fccb36e6db922586e0f45c1a6d68e7a38	3085
327	3c846daf149976f8d4af07e5c471e72e342810b059ac157e4280e8a167bfd6cf	3090
328	122314785fc59ec42fb5b390a297c3f12543f47f2e1a457c468d7600fb206145	3095
329	44b73ba61a98e05737160f3013c52b926bf6be354f868177a339587a9c8812e3	3096
330	eb47053fa72b018f19b29c5488aeff26cd2cc2bec2907f82914dd57bf98c557b	3106
331	61d5469ce1fd5126cbf653c37cc758f6f34b5d9ed127d40ce71b7aa5a0129c79	3113
332	60e96b338822fda709faff6cb6f3cac7db2cc14fd2c12c327e01bf042ee79ab2	3120
333	12007b2b661e9377c3a3476ded52a1c01c55a6a14f7f6b901be7576eecc4c543	3129
334	7dd412d69b0ff437313fc2a78d7c1305680d7180d26aadc421a81c513cd2cf5c	3133
335	e1a5297f9791e78b73fe16c4aff882f6ba21fb86f0701a567648d017081d1b97	3141
336	747fd46d3f62cd34909a7dd20d92dabc582ad018bb81ea53b862b3126459fbdd	3169
337	e8302588b7ef1df587b4fe1505108a9fb80766a692fb4c486a689e32287a613b	3178
338	e5459db6828f72ca120004e868061e1ef2587fce0b90ad514d17a866b053792f	3198
339	94bf1fab00783724801e11636c85f072c601f71af5a536d4df5ca9686100ea10	3207
340	0c43bd056ac2d48038db756aa6aef48c37a6b7e18b5373b19425177284490756	3222
341	2aa1b1b482d31109b458e98ffcaa4ed15dadd85435a9466d0bea0a82b78db2ba	3230
342	786fa7949c93234086abe0497f135835e0d741837fc461992f2e88fdf588fa98	3238
343	f232e336e2e8ca739afb4d7f1e40906c357adda84356ca702f8454f163c9dfcf	3244
344	fbab52eebb99f719c33525166834e6499dac87530a93fe6d33b8bfaec9e42a0a	3248
345	696b99ed89a34ea1209baf7b512bb8d3c0188771d3bc6613ec4bc4d6c47464a2	3249
346	12fd2eea606de4ab9be8c1c13d0dd0ae1c84de0bc172d3384ebeb5c8b57c9724	3253
347	283581e8f7aeed8970bcfc31ab17af5fc62ae099ee18a8ad6bbb692e5daf31e0	3275
348	7353b359dd5a0c630c1df931175338293481ba1dad93bc52856b715fd1495b1c	3280
349	e4e52b590e6bd5a5cc26105825be313616bbae8dd4aa3c49dc308859fa8c67c8	3282
350	5194ee5251fc7ebe50da37b52cdc3171da577d0c109d3f88963c43443296db5b	3288
351	2fd490f97ecdca78ce56ea74f3e6cf79bf37c85ce880d90d61259fbac1440af3	3309
352	3d3a971635c0021f3ed5a551a397acf1423d1480a4446c800a2e40a91998428c	3311
353	cd764b547b3096426433f6925368b89896288ff5357375b1715fea2a81e138d0	3314
354	4697e88c45d3199f93afc0dfaa32c13c32b8b4382512529924deb260e255db84	3323
355	8a055799aa987f1a31ab547cf8862a4d3935b9398319b2ff68b4b1d9d512441e	3333
356	7f98362e884d8230975454c913583c52af7199cbe634e58ed165f10be17ddff6	3345
357	ad65695c77be6cfa1d33be2ba8c35099d7b47e5eccd137d114a25ea67ea0d908	3348
358	5b3a6ea7e533d90ed872035103efe68001a8cb8cbd1a968aa39d9e5b553ed1fc	3355
359	b58368ecceb6139b9e6bebab520fde88a5ccf23e7e7f992f8f359d7a2148bf69	3366
360	424cfa5938df657f4fe2e507bca5160e87582845b665f07e6875a49c2eaefaf4	3391
361	ae237e4d63535ed0d0515b4d178a90374853808e4bd7d676ac1ab847c4abb036	3396
362	ec0fba753d4159805b2c4ea33cbf9c937ed7507579e3a0df2c5a49499a132d6d	3408
363	e10bd86c5840f11f95ba03a5ceaaa52572143923db6797fa528898118b2dc7bd	3420
364	e8118ffb1e7efed4b55d6db6d8bb06ffd29182391ff79a98ce7393dd7e397596	3424
365	a147d0a163b16dc5e8e03c9d983e34a6f709d61faccbad9afbc4da973a15a77b	3425
366	08d2ca75a79a4d4904167edf9e72006658082e8ebc3b54f0148f4d359ce0fb32	3428
367	b902e1e6fe2f8cdb3d6834cb405dc0220c47ce21cd3b59846410e18b29e80024	3446
368	81766a6efc32b64e2c3a567c69a9a13b25e4ee8da97851393e74b7a2dbc2f288	3458
369	a9b1ef20ac63823c434a57843ae9dd320eeec0b14b92a15662e80ff492819658	3462
370	78d9a6b9d09f1808caef9824dc649cf45ba10aa87669078474c45e7f72997f8a	3468
371	06fa12185f43afdddfcb99b8ff9d95984f0461836cb4701e13b27b78bbedc3fe	3476
372	5b4c8e409774ddfa84feb232be24a721766d6f2527198932b70eea59915f2253	3484
373	b2aa9959a421784c786c9db9667199622d3fc5c34cdd47b43255d74c3f0e75cd	3486
374	c4b2f502c82f699b25f81777d8d374c36dab9bc23ec6aadede05ee91e32bd031	3504
375	2a76dda92d430e3cd32e639ddb6ea3ecf4e46e931ffa6c441430f45133a9c4d6	3511
376	da506f516051927cc59635be633a5f12ef03f3f8bdffadf938977fc2edd683e8	3512
377	83b672ed885d49301c00668bdf9ff53b4e404ed49e3304dfc972994b2b556566	3514
378	0e2f090913941037bb56c8ae8a2ebc8990e2be203a37e963682b584091fdebec	3522
379	c2a0b01f7513dc1b327df78cd022c5b16ffea1f64bce2e1e33a57815f5ee64d5	3530
380	a5917a75b6f6a69e1b63e3cf4922cb909be7ab56ed12786dae46547b13841285	3550
381	677d4b7b10985c7f2e85bfe4627e0ff8e1ed8bd1a97b5cc11830dbd59021eb47	3552
382	43b7a3aa16985b93b748c60cbe700c9e4d590129600956d585866a09e96ac637	3559
383	d0f68b0c44445126f99961b00ea636d4b92df9072751fbb9d1b1b6cac8e5067f	3577
384	d008877566552f4df9a2d33dd8556143ae3b69972b54cc354b9bbc57e836eefc	3597
385	f7f5f00d0509c67ef6c6f9b5ff2f95f73f8b43cd3f8a4f6f2cff1f7c98cba5c8	3598
386	b9c9c7d6b275ca81735330f063f03937405be4b4e37741bee063e6900f336eb9	3604
387	eb9db3ffae56a84a0b2125097394df0b80f5c6a8cb1b7ce9a0a5eeeabfbc59f8	3625
388	e74fda25532a8f147f33b930b164e2eb29d7c8967ca9c8600eda12fbdba39412	3632
389	e94a3c4cf01335dc5a7220e813327754a52b1e29b46964ce36183e76b5d6f951	3633
390	65edde8c469aa94e7d76615e0b32b9dce9882b33d38c46053de0a5821d143251	3648
391	2258a317379e8749f3e7890ca3690937f0f2f4f489160555bb3e1bdc858adf79	3661
392	dab7ef6a21d35b55a8a2cca1302064190eadc083b00aa3d90754ef7f9764d827	3669
393	697c0ea039ef43d26d6c91c34de9079fe11569ec205d8f7c587eb1d4ea756af2	3678
394	9d8ccaf0373f341478e00dcce3673b1312f06fe05f58a967cf67dcd27ed4a3fc	3694
395	dc2927c96db53cfaedbd668519bb4ed87f6eb5d1f9923243af18edb7b9fa2101	3700
396	45b7ff0827f576d2f369d9599d2867a647956948031c1a7420be1fd88e2ae7a8	3701
397	19a24548a3d2b8864ed218f48ab78ef60e44ab29ec294ee1aaa359325a387782	3704
398	05b890e06bd254e34bd4b7c07a8b6481d8a1ffe27ae5c91a0a61a83d57aff4dd	3705
399	53a89d814a3a6dc27ebfdb731c6fb2021f8347748c1d37429e25b64699a54249	3711
400	44f1f39a8d75884335b6f3b9252c9e040f709c1b8b70208434224690f2004154	3716
401	b3a1eea970bbf4adc74477f1791ede0bbde1a26e0bf402302c73c3319be9360d	3722
402	5ee8f00736ba43514ab6a8400d298365ab655cd6ddc7b5c1d2e17fb6822d44e1	3736
403	703ab58470c4f04ad446b55ce85c261020fb7ed3880048c75bf770a068f51de5	3748
404	af3c15154bb7d1100805aaa3ad00f4414ed5c8e5ab927ab9bcebeb3b5dfb19d4	3763
405	2cf99d9abdf1fac9aabff03f2de3c97a4dfd8da37f222f040fb0e21d3cccccc7	3769
406	f7c489b6b34f9234e14addb4eece7ac1045695dde7e8f6c073b48025cdfc4676	3800
407	8bcee400b02b4b01963ef6e60861f3d4c55b699eefabdca141f79ae94672917d	3804
408	13b2b1d8a353249acd716eade6a856e78d46b394832018606831ea886f39668b	3808
409	76844bf7fbf7f83648693038de084a2e7e1696fd27b71a2f7dde6c44961bf274	3810
410	ebad8fe35958ffd95b3bc85bef4a388f3734ad0030ebed4ba28bb6d812110ba4	3815
411	765d53854b31b9ebb72f9fd01aadd48a65c16e369d7cc89f45100d3fb6a609f2	3825
412	90ffe2e2864f243494bda431302b0565e41efff5495c1a98b39dd7223d649a89	3826
413	44d2186837d7a20ffc00e68c42e48511bb3ae487735afd0ebd856d466da6a6e9	3828
414	0991a1fef0f11a34196f1a4fc474565cafbe8c2fb65b0111f9e4023300a95cb5	3834
415	8ae50e64ffaf89f32ad2d840b0394ebdf4b1cdbc08a2ce698ee88d610e0ee356	3835
416	343dc5e0743cdb6bf7ff12bc5c60a8baa3134579e98092cd5f884dd37da89c22	3856
417	a2371364ace9275106494d76d54cdde450995857cd539839fe54739cd2096b2d	3858
418	690d7209f3eac23a6cad0b648ee97aaa578c88e475b1308720ed76b470b5daa2	3859
419	30eb67f02a5b34bce9757bc361cf657ab7009a134000ff4533b959641ac063c7	3894
420	7a99d83288800753e46159d1c7f1b87918eb61386294b5a7730b9807e2ab1c48	3899
421	3ae0b4f7535601c800ff93f3898f7cb6e85c5b95c0ce09539fc45a4bfbc33b7c	3901
422	b4c1f9ca7f9fbc62aef20d4b4e6264059a54baf862d9145469b4326558ca60fe	3908
423	d059739cf0c484f54aab507022ee726c4ca59db9889d5e25a324458a8f557726	3915
424	1974a22035d065d409dd93c7c103efc6f4315b7de98695c0b029700d33afa872	3924
425	877583efb24d32027a43c944db6583fd52b857b47df2151886ac13873f13b230	3933
426	7d7bc8191a1c64b61c84c7fccfc61a0c2a670b84f0039a987604839b81408409	3935
427	cc3edf4f548ba90116970a8896e9898612a2958a693150d32a4fdc47755e151a	3949
428	1d427ccd5ee5d09b9d748fb1af30c682b2d478987f3285bb3e5192b897da2384	3970
429	6b5e80e7ab27d64bd21c550b5f4d5952128278a1103f4ac312aa7bb67882e78f	3974
430	91c74580c840cf4ca1ec7375a5bb71209f77cd71a76285f439529d8fd4ed19ee	3984
431	25bfef6df56f6f23059126ee0d5c5ae87bd85893311127b93f586e9d74048c79	3985
432	5d67dbf5e019fa8c2016cce2a36cb9364b24951bb0ecd7c17e39608599a84db3	3988
433	b0271dc04df519bd4f44b6b73b680d20cb56bd1c380388827efb1a6ee5913440	3989
434	1d50761129bd0220000565aafc3c393dcae11c246093cd4afade3428174ce9a1	4004
435	5db0f68e2b10d70b50c9d01b54e0fd318631d860fded54a30db78425fa1d24e2	4005
436	c00f02569c086857a94d57236f3972c0b1c6f502ae7fea83c1ceee7dd335b25d	4035
437	3eff5bfe96c6e968ed264606403dddb1b1223f9fa563fff383255332e1fa56f4	4041
438	95316762a9a6e39c311011defade4ec2874a6f58f80b5291f25890d9f63a1c8c	4045
439	97455c632c67e30c29429bda380da80f1cd0e196f21954d7b7f77e39ecb409ca	4047
440	72c050c09d993e80c634474aded356d602d994860d39cf8a6e757e72c0409b70	4069
441	92f62ad77bc53eebafe63bcff35c3c9e4a49d3e478a76682acc7428e19dcd304	4078
442	0f4b92878d2266c4ccc35676ae4946a284257d0c805e827fbde1102a721299a9	4080
443	afb282654b72856238f8bc6f4b5b22d8c064639b7057d36ace291b671ad343a5	4102
444	e76b1ae315124e77d0074c5e088c978b99c9eff8b3289c3eaa38f93234e78ca6	4104
445	38bba7c4ed0d0b3d833b7a2e912388a343ed33b9ca33bc53c742ccb660519772	4115
446	2aa9888538ed7a28098d658f49d76947a967aa73f6b519e66c1a8af37ae92772	4119
447	c6e3616c7fb6de05696ec00dc15ea5513e828d5253fb093e910bf7370e2312a2	4128
448	e3f3e73dee405718ed40d0c95094c20cddb4e9d7ce4546e4f45b2418899c336f	4133
449	59290c488393ea186160f08d517ac4838e0922e83b775d1173d93a06b9677831	4134
450	4e733da5cebb45475b1a1242c746043125587110e7498c1d453398ca9df938f4	4145
451	61e0a281a69b7c167be2dcf764d45cc811bca925a8202d1ee3c568c67c65e351	4147
452	0f2716641176694fa05bb3e189de33c837da468869dd1bace3d7d6ef0644dfc8	4173
453	cb38b4d38e990fac3cf15da7dc37826055b23414d78918b589f876c7d35373a4	4191
454	2b9a1d64d27cf7b663a10b7fdeeffacde433c4ae70e4562cf592039729065fc8	4209
455	2a2dd3f40692e6ac072612ae5b9591f4f4998f1326d8ed7d09bf01e917ba1b9d	4237
456	99a498528760ba16aaa8aa8b2cb7d65d5f97a600065062756a48c86f3c813683	4242
457	0682481e2a85f05e41bd75df56df69a2253f492c286addfe1caf08150e4ef74b	4263
458	c0dd138da9245182a524019bb7665f488f093630ca2542aff77e7d9f8e969ecf	4280
459	2b8d3e60c225f9c064fbf2761110c568a8e2a93f2e17739c443c9b6e4d40ef4c	4281
460	81ec08ace14f7dbd67b90f029a7e7bb11280d6c2fb698b6254b203d33f9705ff	4283
461	f6c1d1e0864a8c415cb9fd00568854750f70840702004577a097a4654483ef4b	4294
462	a85de523df9ade3e325c40c617d539bd2032fe5ea02dc7ce2f15a4a6d026eac3	4297
463	2814db382c179394c4b05ce4709c21257b5441246b35ad087ac182df6e4da2fb	4303
464	35f8706e7d57a9c66f15e3e45797747b4fd92f756f9af9e6da59761016f84d24	4309
465	f2d1433aa79ea9edae58249d7597dc991aa43028167b9b9a9816d33803ee6fc7	4313
466	460c651c1c742db4c69d515c5d1b942ee309d26960e5f9e80126157f7f7f59f8	4317
467	a157f37e9aebd92c9d705f517b5f142a54d7b2b5770a675f67ae3d892407b37e	4323
468	168a302b1c3dacc31c789e457e8ae80717647186ab3e3bb11108f99fc26ab46d	4326
469	b9077b2bd49341edc59aa9576c4e6892a920191ceab4e63e4234a0d83734b247	4328
470	5efe0780761113878e9e6bd584689c61d3d5784f0f228086d98da6449d9c847e	4333
471	022ede447442f3700a3d82d4c94be73e60385317aeea3d3b7cefd12792667abd	4338
472	9545223cfbf0e0184d55d1093c8221f739035c3ce8a246300496e78820c97d63	4339
473	c3cf35d9ffc08a89f1d807ecf3807491fe9878e3a3fbee71452c1f449b3247f7	4342
474	7ec9a2e464c5a700f460b66ceb3af48f8b2e653b088395b17bdab13694b319bc	4362
475	6c3cd9179682207b19175e9e571c5cd1904dd91eb1edcfd0cd4fec5c16bfbfc2	4383
476	3e53352bbc550617a96f0b03dbd5558d7d9a74dbdbf29924cc2e3842149107b5	4402
477	8700d8d37548da79114af127c3f6372b3b4e4a08bee1cd3ae84efcf6b0d160ef	4403
478	1641d9b8c0cf7b8ff34cc10391619ab30b4a4cfca7b74ec54719a15e3f9ecadd	4415
479	8838cda673baabe3b60796752cdae9d228b7fb58337406a63de75e3f75b84d9a	4417
480	5d4413a250f43e764a326eb3b49125382df44c90256ec1fe7595eb093c76455f	4419
481	8c2fce8b719febfdf7eddc247aab7eda0f909bd583acc02c91fe99f1a1cd5c9e	4426
482	e44d2db74bdbcd926d2a971669dd367da5aa44e3235593459e4900b3e362250b	4448
483	22b98395c499664ede91f2833cfb655b433888d8f0a8ed2c4721e9a246067a23	4461
484	3ce38d11e55777e6375842643061adfb1917484892094e590b58c49ca48182fd	4480
485	5dc791425ef4b892268c63d6ed864e4b04c250b2e09487c95767eca5db9913c0	4498
486	5d9d3c3e42b30030d55e8af59105b30f22fd8b198bd1799d9a2fae3c2c1a7d85	4523
487	fa9d0f1c87da590c1a68293b10e41bf952b5a6138dc7c1cf872dc88f6ed7aef1	4533
488	b23fb719e2d848408125f7e3b36e722ed287959502af43807b192cb5040e6dd9	4545
489	dd7495b08ea5c79fd968a9fccd8bad5da38c13f4a465895d1d3c2b17309210c6	4552
490	6fba1dc5bc97734630c9585158fd53d104e727997a331af659b5c5bd626cef48	4564
491	ce993e5acaa1cc8c7c934d8cb2b1df0735d061dbb68515e7798893a8d676b619	4580
492	4e469fe5ed8c6ce47b7693cde6006be49ee88888b3278240f24ed779e0552477	4590
493	d789b1f29b7cee4acece4ac90117db3df1086f45bccbacb316b465d6d1f03b1a	4612
494	31b81bbc776e411aebc5091ad78eafbec3058a611263a30cb514cebe2f9da31d	4620
495	356cf4df10480a316f6f10c0fc18b74385a74528b9d98542ac266c355944ea40	4642
496	ad595cc5e0fa6376c3b0052fda28decb2fce5090ffa93390233aa1bdd8131765	4643
497	ff9d225835147a53c7e1163056b85d98acac559861db9a09cc5cc8ff0cc6a8f0	4646
498	ad4d811eee1720b39522e0626c94a7cc10e1041fc24a1886582b88c1c75e9c69	4651
499	6bf716a02e167793bddcc60b1ecc6ae857562884d219f926fa25f0648c9d6a4a	4663
500	1142975aa0bcba764bed01e5064d929e9566d4f51bd598dafe2da0f7f4b2a825	4664
501	32a78eb464e4561dd37a0dda2009b67e534c550dd1044660ad4f471e5d03d7b3	4666
502	86de275c93dd2a40b5f9fb5cdf953dad832b43efbe9e33074899fdb463f03673	4667
503	7bc94f4065178d49fbd04fed8f7bd33d06519ce1c19015efebc44153318c52ff	4700
504	0a402b83b24550127b5a1fdd8d8460696a7f5a3d3229e1c30e3c965e730ccd76	4703
505	56e75b4db0cb2dbb1907187e02d1df84c8b9e7a57f3de466db1f848c925f18e9	4709
506	7f405d5e798f657f4e510645bcd8aea4cf8cc3888c9b11cc8be39f3fe94198c6	4728
507	3710ecd3d0b75fe55b5ecf897594ee40bc6739b8ca5ffb708bc13a39e6b2c211	4730
508	a08fcd336cc4bbfc67a66025d5b0cd1560d943f155683b1cec80ecdc62aaaa1d	4752
509	dd716777ed1ec9bfb167e8612ce5342bda0e847a4659b8f04ebd991296faa172	4756
510	6855d68873ac0dda1cd8deade08f40be24537ed717459cf52d96da49e63463e1	4782
511	ec3ee7b1b869492d8261c2215110926265c2a942721cf2ce9cfa32ff7fa433fc	4784
512	63bdfaefff7a7ea74e06690aeb86a0745997ddcb88ef27e49a3a2dae27037a72	4790
513	a37e99bc82ef185aaa5328d483d633ba9a2de4670a1cbd8f96843ac2ca69e24a	4793
514	c6eec602b5b91c115ecaceca0f9b50656e811525833987bacf75c14a58192276	4797
515	6314786c40be3f164aa15c25f8e1dc77c620d977487ac73551f1341345456978	4807
516	08a0f131d13c0a7ace1672d6e252cc668dee8ed6c4ea1ad07c0e4fb0597a1d76	4817
517	c6b1d3ce54c46bc7b285879f4a5306b4406063e1769b7fffa47e630a72814d7a	4830
518	fd3edda75bb58e7a3f80be30745409eb1a9e96e8e77e978336b559949f103d8b	4831
519	b7c6b43b7a2b6408e26a29b7f5b974ad6c6c0c168d3371f87b49cf6b1225fc4a	4834
520	6e334660b1441fd924673ce6f65de79aca759baddb79f147d4c6e091d33d98f6	4853
521	c093db6b9f5be839c6be56c6c9798cec1d2b3bb62d73ef60f1725d8dbe385c0c	4859
522	8382ac440672c8bc1f185a328d4e100e5562c207922681aa2caf4d711ad94189	4867
523	af8f0ba590f0421f1d24ce5a40b18d2432f4438016068acf760e52bdb22888fc	4869
524	99678f4c2cd245b2fb180d90c245d2b897959c76afe236a1b61503d11fc252fa	4879
525	8ffe5859e532691a95dfad5fd0e6f4b542cc6903f56eece699180b37f337446a	4894
526	3e859579f671dc0425b027430d6e4cdf0b763a1de353ab4ade61c08ed9ad0542	4903
527	54f8c55f54198eed1d888771b6f938b837420fc44c9a7d7387f90aea9536450f	4924
528	29ea777a4a58354336cc8dd61c8b1eabc0750a21f7e5815c797157cdbc22fc96	4932
529	447eebbc93d42397b1c424fe312a068732a813eeb747ebc8666d4b893bed530d	4933
530	608e160c35127ef48dd31b693bd181df0f56a97dc3edd47a86b41279e2ec7cc9	4938
531	e3797dc0c70ce6d2c2298d6fe9615f59bde4e34e90c83e0d69f4fa028402a390	4943
532	72b898fd273805ef7b8485816e9600fe2f1dfd0286e6d8918c9f8d79ace2738a	4946
533	c51b40dbab2df9edbf20aca7af2612eefc0167925b94acd51db0b7c469abb64b	4948
534	1f5f2b3a6a4558678f6574c589e828190e0b592fca9f321bb2cfd8ce2c48e9de	4949
535	8ce22310e1b78d51b53110a401d2ed48c02038481b612c7d27f2afb371abfe53	4967
536	ee78ca2998caf19409f84ac0e3bfeaba75eeb63dda9a12192733b491c24d5e1e	4978
537	9e57b507f264c2e5b97ece4733b371fd9b7476af255485cd074e68091ce74c76	5021
538	1010d5592b936c6d48194451dd232495531910a39a542de891c5e98f081457d8	5035
539	8a11cfdc9448932b7135f97f6e1f71763048187ab9742ae238b3e381585ca9e9	5037
540	dfdb01791fa0246e4a7d2157a31dc470e9391130c952e635643131700974cec4	5049
541	d042ef8bd3bda37fdb10576b797308585ffea87f483fa6ff5f3e39d273b3b1f1	5052
542	e6b713c9a49762cf1d8cbf3d2a88dc98781a9d8c5ae6a302202105c3ea49e46d	5071
543	4e94d8d9060e23637f582b1a7facaecd0cb6f3d67d37392c9440e90c0ff15333	5113
544	b4257c6aa9d17feb23038beb78c2054aa50836bf9f611c6515ff55cc8c530f0b	5118
545	efce1a9943ea6e366088b6c6db98bb5ec674e5df8d9bde4fc08c440740300d36	5119
546	6b944e57308618587e6923d79958df4686836c8e850ff1de9e1b25940458239a	5126
547	3c69223b3a985315c264f489c634898631af43d01dfa32c8c8d8aec5a3b2c452	5142
548	d864eac0a5f74bb4bb2422c75e8c72c0b5f847160d428aa8cc8d03e7fdf5df9d	5144
549	c6e320bc8f8d7f818412767e39e1798cc2a294599f022843bf1f77ee0fcf3278	5151
550	8521a09a04cd1d54f51545fb111d657f4200a94f67a27af9c7279cf7770104cb	5170
551	afb260ad0a44974c4c23728102d17bca378ffad75d071fefdcee20270099f28c	5176
552	b9ab2f864ad7f39382f493f98bf862ce3aae9e3828bdf898fe5e242477cd60b6	5185
553	8f1de7ba842cf835b844dd90d6352551d6284aaaacb3b0d49ecac6e854af480b	5189
554	ec4a3a8356b0e915ab86fe4ea5355da9d6c84fd2c16585b9905d663ba1beabf7	5221
555	c5afbac871f08e0163bc7d474bd0d06b69e6940590cbe8458ac21ae72c767048	5223
556	ddadf2d5bca1b5532f93a1eb54b4cf030a4cc0232909aee10a2e9b424da8a3ba	5226
557	98d90966e41e2423e0165ad1d21c50ad839670efeba56b4e9516c5431101a85c	5230
558	c11e3792d4b3a600b3a51eb8e844f4641ecbd2cdc2f89ddf44dc614d2dbb4b6a	5233
559	a80ec0b6dfde6c9ec3363599f4aba1fe23230f0c6e454bd7ffd86fe17647a5bb	5247
560	cccbf200650725c71eb72beb068015bf1361fd74bc948aa0ba370cf3252a4029	5253
561	991bc18eacc5a38fde857ccd70745749107cd1a55e84f0b60fe5ded37a93e10d	5259
562	07051c5c587c49b58c994b7946428fea74141c1f089e658f8e09c024139ea0f9	5268
563	1a03a5bac501d0707abbe00b99168483ee18284678af67a47d7b4da46d025150	5272
564	8a6c4193e37e9566c90ed0d5078ec6b856a95246b292f8b23074c72d9c1ee109	5288
565	52ef178df754b993f4efc34f7a1deb81d6ca47a1d15e85208b445243d779cd4f	5300
566	50b87ae83842f720048fd6c20f1284104f734ef0e8553d0cbfd783d23acd7cfa	5322
567	6cdc8071a7dd76847e1d223870873165b93b5051e13dcdd458d54e29a5110318	5337
568	339ded4e0cf9d3cb4cfa93f8e5421269ef2f1a9b3352a478d9f9f114e818a580	5357
569	cb0f348f81520ebf6338bdd40281c787447428a546530f417a0ad0680eeadc6d	5363
570	a50a3f6396e66521f3bc8a2cc77ce1028de7ff0c804692c4096ba08dfed69c8f	5370
571	b3ef81d95d507b0b1b4e61f987b9c526be16babefe5095be0979153f21853bd4	5386
572	a6b3211d7308ff042c5b35c650877445cd5ea43a47d7db32dd24ed5a839d3325	5388
573	9ca45301cb3a8bb3d43382dd27240798b549575c9ea110486a9475898fb6535f	5394
574	9b9436fcb1e4d6ad307c17ee9126c0b2d0f1d724b92902a9d31fc61d6d83efc4	5401
575	61067f780b486efa6b1e75c893c4bf3bd9e6dd23daec6e4250e9bf95823cc36a	5411
576	c424ea3b10e08a325af050cd71f40d7d9fd620bcb8bae811d4116ed84ad1858e	5421
577	b6b82520bda6313ce44fdc61b287b25057c2d296be7044794b70da78487d6e4e	5429
578	e9d8bf6d41fe22a76024312efb0a2fd9a596303f62c2b06775d6db1abdcfd569	5436
579	34b585b6afde93cf56e081c687716898b112f92c5251fd1d53d154541a0fea9f	5441
580	ab5dae6dd03b2a3bd151ea5a4a3fd4270d828866efe38d63f588cc1ea93e26cc	5445
581	008c6173251a3350942c0a07e5cc466d3fac09ee9a45a5ab9aab802c1255f10c	5448
582	f0a28d08639a7fa2cf49f6e0081220f074e5d2e0049bfa80028961054ba798fb	5470
583	c57583301331c33ec91baa20ba13af5bf1fecba8946b5f788a65cea33f250429	5516
584	227b06ad4f8d97a16493058bf72773e17af1bef1d3489ac6b5306bc4979dc335	5523
585	cdf77d2c1de2b5c453bd04c15a12572f54130fc41dd1f3a644709822cbd8fed5	5536
586	68fab4c9fa46bd96561a26c3f18bfa96d1bf0a299b99aed6de2415fc5594b7a8	5537
587	e6e69ba6668aee35e05e6d6dfb9e8566adb648d79746135f52455d9a5bc5ac72	5538
588	83a69c0ce6a78205fc2cf145198e4ed821329f72e4ed2a845ae6e0b563e73370	5575
589	952355b556cd9837383a11695e54cc2a51ef5cea414934d85549ff15e8d0039e	5577
590	6dfcdf00d93c8e2f192842167f7fc0f9baeb5753c81bbedbfad2fe024c3a4ce4	5581
591	559a52c5004a471417aaa8d0537836c284e87604092b8f0c79809111af97d0f3	5587
592	be80bb8d645306551d46a0ab32cd552b358810d30274d409288e8773f817600e	5588
593	25c9a0723310539f9690f437b6d76ded0ad6b1581012292c495dbe600311fdea	5597
594	e50ae465de9308b2222ad6fc8531042481c868fda64867eb9e7210cfba49c091	5598
595	fb75493d7dcc802e1cb9fc70596c9f0a65004e343e6398d3f825397121fdb344	5607
596	8d4c6f1ff415db3b8f4d87272b9fc28bf24eb74e848c30ac6b5bbb5dc2eca32c	5617
597	78ddf7deef529306dfe8f5f856f10a5c07b5ad09dfe88c157e8611c0d2a6ac66	5618
598	dd1b97314c83990c05168a508cd125695991e402999c3f8b08ee87f6ac79456d	5624
599	377915fa205161eef1ae99e724a6182c6850c7250927b33877c460bb4c9009e0	5627
600	df9c38642e1a9b05d47abc85749f6cdcf5505349574bcfeea463442bb87a8caa	5640
601	933afdd1bdbb46589d4f55adf9e81474189098fe7bbe223ed6504fbece9bbf1f	5644
602	fdce98c61d41819abac66d9bdf00100cba71445e449218ab55c05ace166edf9a	5655
603	232c9fead74d3a0fc48f25d75a1cd2c38c57cf5b96a63a04d9a923b66ea32947	5656
604	58df91ec04e9f0df8ef9004169d983bcc04fb15905219c0e745256f33102b1e9	5660
605	f3324f54eba23d865597669f095211f516b6f3ff974c7f8d2e11e261a1485a93	5668
606	56ae74acff6734b17c359726d31209c0be05ab06df1798b0cea4d9b6d65ed4c2	5701
607	b62857226834f6e2a8b19db3e039f36a201855237a645b34d5aeeba05dc7db6d	5704
608	027cc84cd3b1809b4d657d000f8829fcd66fbad6d987af2eb95c47ecc9aebfd7	5709
609	356b4b35a47952cfe6cec467b9701197979818c8bd39b7b06ffdb8251f1e1adb	5718
610	1a488803caafcfbcc3945911de72a28330158dacea93b5d87127547a75bb8624	5719
611	37c4f2ced2121dcf50e4dad4cae4bffd10534c56ceeafcadaaa4fad46b34cbbf	5724
612	a6f97aadca9a7a34e331e8a55523d4762ae61c0a3922c203082fe071a86c1817	5729
613	a727a3fe972f3556eb998458b32a972e6615ef09c05600c5a9f4551c0c13e895	5764
614	40857360c47b9b5287577c1395a72b25976afbfc1b15d26352a150dd753b3964	5802
615	e12e4f874b0c07cb0dce57720087c755c555c76359fae7995dc6ae84a61a4f00	5813
616	3170e1c68d1a1f5348aea5e9df71b9b1ff9f39d3e1ba0e01336a036cedc2801a	5865
617	0cb477467010fd5483654d99705aab937118e45fdfeea3e60f7f3c73e0bceec8	5893
618	a153c5cbc52d9769decb316268afae088f9933008099dad314620abd59cf8bf7	5896
619	72b3c798f9af97bb2de909c42a990c095201986b8bc94deacf93139070fd2210	5911
620	fab4b3dee8e744dfe886be265df2366ad5d8cef2776e430a244f91fd1958d3b9	5918
621	e1a0fdbebb02efedf1cfe63b729a478f2ea2d8f25f0e3f145064b74da46216ae	5919
622	a7b9cbef59f85de6729c5bb0be5579ab8645b042c423cec4cd16784d4c135aa0	5926
623	ad806e5ab757b95ed1fc60c4b7954876db80be25ac5a5c45fd30507e7cf69055	5955
624	5c21e5198b87cf1b182d9cc7ad4f1a7d9b33c54e0c01e1b533127e7e543ebefe	5958
625	1ce8713c0020f0ee0849d3b84cf63ef36643cb343f476ff037d495e6c43a3726	5965
626	85d9f674bf8af4e0441610b9556617cadc48b4e22096c12311d4d6846f5d4878	5968
627	ec88523aa975bbb86da1bc65d6ea4eafc4123a87a521df6a6d10c0a0db81b2c7	5983
628	279922bcea7d08974b5a7e5f7a5ffd9b9749d588d9c7bf88eb821e9ef33f00bc	5992
629	b6cb9e4b282772c1105e86479a4830a3a2adbf2f8c6d58a9e125b865d22be0f1	5996
630	a534fce9b959a889d031462bd64e499fa2b9a410a14b300c4a74cb01113f707d	6010
631	26f1ba3a1957f22628b01f53f7172e45cde43dee25e5d0a1fb61a106c1e5bec3	6011
632	77e540e6592aacff48ca2157a18a0a4b8b212e64294f1f2b919743b95e049eb9	6052
633	45652d2edd01c4a9186cafa48a42cb0e973623e59d020a8bd691599f284ecf86	6058
634	ce1a2cd55563ad4e84d5bed7ab6ef305fdf989cdcc53258d07c6c08f5cef21e1	6088
635	d5f0cb4fe0d9acebb5b00b1303eb6fdf9d5140644e91c85d4fae9174dfb805bf	6113
636	56458d35a0a819d90a47827952d45274dc3f47ccef0eaef7a9cb326acaeba035	6127
637	c97bfc7d2dde1f2ecc405d7473f49953cebbf9ec03bf3dd675679d9443e1e6d6	6155
638	ae413709902a01f58cd587ba7dfadfaf5995c9573eff43135f8e04e78412d0b6	6157
639	8ee1c15215249f053119c5dd49ac2d3754be12d58b680828a1ce92f4e558823a	6162
640	cd82ed9468083c632795248f709fb25c6b78e2cf6bf1504ec67308daffaa3fe0	6199
641	bf1e19d0795f21c572efaae3b5862d27f5199bb17a30cb08bcc944151aec6b4d	6224
642	c512fd47926f55b6a9fa411ab991a37d648d3c42f6637d456bff43c645f54d3f	6226
643	1a8f4e1aedecf082f47e3d3b66d56452f0e52c966a2af2d0612ae1c7ac2764af	6250
644	1af41d32c82fa41913307b35d1dba829bd0c42c03514ba91f66ee12ae20dbb37	6251
645	3ce26ea7d9695a8b8dadd1e9fdf85260ed649dff18b0210f9abe69385cb2b088	6268
646	60a472d77781e5a0918543bc90313c8d00500ea1dbffffee27030d6c548f9032	6275
647	bd3a56a40b0d5cd30db6053d9e0fb0bf84e497f5edd5da04582860d775978b21	6284
648	cf1dca66db97e9f55d13dcf7da088dd0d8c75413920a8f00dee8ce021a426a62	6290
649	dcc33b18e8ab8e5a85d63b5c183ac5f951155d99f4b4724eed2a91c6bc4e4122	6302
650	092887a72cf04790e1fc43c1df414af276a8c49d8daa91ae3e6a5908b4d6422d	6327
651	49d5ef851a05aeb9d1add7107e97811c077e921194f30355ea79ec44aa8fe508	6335
652	7786fa8458b8d4ad2d4ce09aea865377e0c4cec3d52cb87471560b3a4a6788bf	6346
653	206a78909b71bed5895297e5f2c257c27c03ec2af645d494597bb3ee90dba4fe	6352
654	a8fbbb1f5549c6bdf9687d1c387f4c7a0c630d979cb4c2db1f4357223b883480	6356
655	64b328ead61084591dd21874821ad8f2b5be2ead19c416bf4f457be3cbb8a797	6367
656	f939dd24203de0a743a2c71b87af3a8b8266326686ea2b894a0d8f4c92e8b87d	6369
657	3dbb0b970e7acefadfb715e205c492c694a01c640b1592df7680b961c568b511	6370
658	de0d53787cbbf2face8ccc2a5856e7dde83180f2fd70b7a8709c56f7420333b5	6374
659	16c2e5d26691340995b452cd5edc0c2023e98784c34745c386a9be557f6a9391	6385
660	20c66e38e6d3e0ca2aee00d1ae5e857fe250c5e32aba198a9f30b26b40d5697a	6391
661	c78bc3bb3a6e865d1d5f2a1172597c17e128d766ca7a59a4ed24b147ba30ef6e	6394
662	a541c487fcb1a13e70885f27f896cc25f349d2ba82bea15a311b14d06341b1d1	6395
663	59c8ad496387f7ed7987c60456e3c8800b94c274c2e2c806656c536185c5cb87	6414
664	dc448bf2d527f8d942af2b9853da382258cfc1e7dfcc853628a5b993309e2a63	6436
665	451901ce1452cd57d6f3f95b44d0a04236007ce718fddec8a78d47b87d058495	6464
666	627bf79e82c1659f8dbf7a2ec4a133d85ba2f24e7cacaef5acf15b3c7d088771	6469
667	413f57c4ae3cfe1df12e12f2ab5d42242e4bc84049820439ca37529ac46a152a	6477
668	ad428afbc3ebbc1c9ddd4589a84e01ad2f25a4eb435004e51ed309fd2b6a8b8d	6488
669	67a5d6ab65961f74045bbbb3cd6d9a7836a48d7bfa8ee6d3b063ca45e10e1d01	6491
670	03fad5949ee327b7b456a4ffc990e5bbaf045e0b40bb67af18f99f3ec05127ad	6493
671	86b2f459c44d1a05cd61c811bddae9cc90b04caf70b503d0e9fe7a33b04a556b	6497
672	2dbd01f64da00bce30a46b9e2fee66c9148f7d577d3c68cb7beb99b0b1c53af5	6499
673	0c54d8190bcda176f4aa8efc98ae7dd0cf8337b08894cf6fc0a3324647c34416	6504
674	341efc6255abe78bf7ad3d7b484fc721e8e0c7b0ba1ba34f64d2095194cb06a0	6507
675	05483ef1dba1d3a378e69be23085e80826ad1152bb9f27ae8e022c6693bc1ef6	6525
676	6ad46d7e940c663e1199f0a8fc1c1a5b1a095c087a9a5bced92fae5789d8e545	6529
677	cde83fc598f781ea6d344472ef2415ea74a64b3e04e76c3eebd50234e8e1cc8c	6533
678	1f2231cab775763158baecdd49142ff0da7fc702dafe7d3d07687b4838703e7a	6543
679	d222bfc4e41a619b6058191dc1b6807bd6f97f7741fbb04847dc33defd0bd0e4	6577
680	cbb8a8b5d8ec776de4286f0b4f20fc8836d13d17e57586dec92463a87e766b45	6580
681	12a3a08b79e80d5eae492814b0ada9640c030c75aba83a405f5230b7e0333517	6584
682	eb2e4f9ae198654c231b5b3a3ed116c4f179553ab6f74ea21b29cc97a880f426	6585
683	deff337980133edc8c07fa377ed68bcd3667a5cd66f95b00aeb3239b03ba6113	6586
684	aef703987b81fcb9e259f0336a8e01438ed1968a021fd6f84d73b06e2a73322a	6594
685	33fdc64fa753463195ff0e78ad0b72127005be022e2200c60058d0772e87ba12	6613
686	4ce0e93b3fba6cf5cd26309edfbd463da251dcd18b8c406de188b1964e0e675c	6620
687	77cc254f2ca16ce9ceb17b6a0753fe3d712925ac3106f18dc38590db0d458952	6627
688	d0e129eb584967311d1322332f89e6e09180b9525fb31d9025f5c668419f1f60	6649
689	2eaa2f5f3d7a5d4307ea6c752c332c71a117bf9d7e71e9a97b608421eed4adce	6655
690	6953162ffb0fd28b62ad4c6b00d9d301cb01405676a6bf98ce7aef1bf5df87b5	6675
691	fe23f10fd96cae7f246445072ec0d89b495d0226da2c604b9f3853a17a99511b	6681
692	9d34a73419811661f022e917af4676299a9495947380bf22b6e9b4488fcdbe55	6691
693	6c9d973f8c03d92bfee89a8665ff660eb43642ac4119a5418cb42330c9d569d7	6701
694	af1a643b95375cde4957e6233eafbcf604d40d557f4d334526a86013eb750752	6713
695	f9623b3fbde57d0f30d48ea7f93131d459b83a0c0d6c9b005850a5d9e792f668	6715
696	0f6565779a8cfce7380a7034c07285a0f95e0921959355a0b5d0b8ff3dd9f1b5	6728
697	aa385d6fe79cb3904d785f52b1949a5293a67bd284e9cd323732e0b11b2dd648	6734
698	9f57eb3529fd83af887a07054c85afcbc1450a792a24a6a5ad6469a692a6da4e	6738
699	fd946c4311fb33d661a76ae31387a21efad8c90e1051065b7067cc0b29e1f2fd	6748
700	79b276e81401fa8655a8b99e3199c8dc426a15c8f90e19e142629a66fc0c734b	6751
701	1db898350562b96bab156fdf26c99c3f5227ce618af35a27c70870acd2d59f64	6752
702	4dd00f25643d2c1697d0dce4c13777148a302b18d9831fbf599a98b7f6dc4d0f	6775
703	7bb55bf4ec594e772b0cf344719b67eb5483d303f1a540cec0c6f9be36baa092	6789
704	94517ba1aff8dfbf6a5542d6c162719d71b0aa70524b79351d5d0850d07b9375	6819
705	120791f454ee1d01bc3aed52371bd1d886ee66f82ac07b0b4858dd076660edfd	6830
706	f209bf2da8282d0ebb397ab55c23eeeae2d123f5cd8f6d1319240bf7dca655d3	6848
707	305036a4264e8321a995e5fe0495fc23d7c4cab36f8552a5146f6c19a17691b5	6849
708	6fe62452d64716915000682cfa34cb3add1f72d7e00379e68767b730f0dab598	6852
709	f911f3337fe64c907a9da27a580b55c52d292f6ce4280d898cfddfff1523c069	6857
710	3b3fa255bc40a8ec7cbb3498e591e8f3dacef814cd59e51364574f1df8183aad	6870
711	a794ea218f2c40291eeedf2e7273426fc58d5109bbf731889bea1ab0222dd089	6878
712	68ccc9d660c29ef193c086c80c6994b0f6c1508de8a48b96a6d5c1413c2364ef	6880
713	cb2896d0b831122d28ee42784655c86f382b770921bd7fb9fefb3554f092c7e3	6883
714	613ebcd247e07fd5586429b7d9e5449a669c5c2b4a50480ae6a8ef1e2969c0ea	6896
715	c0b5c2dcebd81a9da5e81ba6c2dc6a9b4b718b77657e4536f8a36d28a99c9cbb	6898
716	6110570b6b5b329870bd1d79aa1672894ba60abe8616492608bc7ef1d63cbb8f	6900
717	7dcb915bb07d710790418d179c6405a7a6846809a67c302b1d36841ecb966c83	6908
718	0f76bf19989ee38ef4c50c5405614abc08a128eb8ba7d4c3d048fea1c9043caf	6920
719	33450bc649a6da7ac38a12492b4d7dfdeaef0b3c134077f88695b988368b7461	6927
720	51fbf66ef6452691acea85fd9e37234f11904ede870868ca0a7b6b39aa59deb5	6930
721	c63556bf6fbc2906879447f390452e7d8761812b728531224f067868b8364933	6940
722	122c40392a88533fb6451eaed0e96a37849e55055c931457509211ef83ec56d6	6949
723	a8ecc8b93c8d5fc7a2ba8928cd58158ed6cc99cdc295feb8c3795398126fd2b8	6951
724	3cbebbf4c14e2bc067142129532a2bfb710bbc59e793faff133ed945ce219942	6972
725	98d3d41f28bed18eedd44af4d981f3ebf9a362ae3e2b3f85e03e9a89cd98580e	6983
726	7968d3b041ef06b7d6832623ac23ed715dc6294548dfaef037f0ffb4da4b3526	7000
727	6f40ae219ebb7cbadef82567ef98f93aba7425e42e7153aaa5780fe040492308	7001
728	45f6e4225efb828a55bfb98cc5c940f14ef57e7360b7f095065b66863d4505d9	7008
729	9b644b4ccbee4b8ca395207127731889dc7cfb784b113f1a336a531ae0b20f23	7013
730	65946821650c104eaf868a64ee3e6de1625c046d0bd46d859a9fcbf4063704b2	7017
731	c540be7e0ceddae8324070d7449a68bba06ab27293c02edb073415fe99c89c29	7027
732	9671aab14873a68bf4025ff11448f74f04d27cd8e949bb5512c7c38cf33162e1	7033
733	109cebf03d8110365a4d92ebb4691bbf2c11a8a632a60315a736ee42694616c8	7035
734	c8f80fcf438853df9bc90f50e6d49531821d74aa10d1979c6accf7c5a81d97f7	7037
735	a826f2d3ed06b787e6fa14443c6ecc7b093f1356f53d1c5fb95b6473d731bf03	7049
736	3d1c17f32c2d1cf00d0e2714578f0c0a5b4b0d938271635904da1fee3ac6c7cd	7063
737	2bc9594844293de7a93e2e90aedd88248a213029c7eac3089fed52cd81231fef	7070
738	70d00f9f4187bf8d5bca94185106593161dbded836c4cffaccf62f752047f34a	7072
739	7520ab1a98c2e86661c482ee748904b85a84997457239941eb1891402642f1cf	7108
740	74ecb4bcbcd0c742f474fdc8b5f204b32c58c60dbce3af0cc15603975f0cfb61	7114
741	6b807ec3f8d0d20a92ab73d527c8178531d98484c9db035c6ed317d63c22569a	7123
742	6dd214b5b50a296685edf1180907ff704c7d56971e5249b27253ed10db1f06e4	7130
743	8deb76e848aea16cf47df0383fd881661512df0881e5895a44301c59874c7c29	7139
744	a1b64906bf007265371aff9dd6db427fb187fb3cae001521e18c94f8942b1c19	7146
745	07e8a5e3ef84122c4cdedcd96d148b366934a0e026709b59d19cdee7f5b69f84	7154
746	44659237c11c4ddc5e33a3dccfaf897730de569bd0b378432c3f484f4e8504bd	7157
747	46ae070ad512156688ebbe2a8cb734640a81de1e8d26d04ccc3de3a542c38a7d	7163
748	6cb44d424fe4bfcc3b5b9908a4f35cd704d010f8848c9938bacc1cccc8dbf41e	7177
749	a1add84cc4e8095d0b0956506fa63d54335a4a133cd268fbc23d26e1003d86ba	7193
750	e742e1ebfc4d2ce1355b5f94b83c78ba327881f216a73b7bb567ab9d2f244fa3	7194
751	bc0a9512d388144f2907b6f269f40a2ae9ae7bce070cafbb624cac3d6aafd2e0	7216
752	4283b5275df3fe60bc9d035cbb8cfe49798d1ca6aeb709bd8af3f24e557f82c3	7220
753	346c22e252cc588e0e5aa99ec14e151655ef757885c9f70168184b7cddfc5195	7246
754	56482b6758d11f55f71775826d5c8e9d6edb576aefbf5e9fd2f629f3db518618	7250
755	ddf081097cf12e1ea174f81cfef749c3e2cf8d69d342b213b9b75059fbd024be	7259
756	f585a8bffaea24f6a8cfd84420d9948f0dbf369cef2748e554d980c71d6be404	7263
757	e80d7dda4dd32d35d42144dc1c6ca95eede2e9c08159be46c896ac68b637910d	7266
758	909a06df0eecaf72ea03a96df8b570a5e5ba732a75e75dd19ee98c3381203d56	7272
759	6bbc651572e572632a1b19f24a8fd5b23055846d25ae23e79baf77d94bb7ea6e	7300
760	d96c56147f120cc92a377a36c12aa0bb0187f4fecafb7b0992884b7fd92f57cd	7316
761	2a90a03652007915592808907c7b31ac04c9561b768757887a073c7f8e9e5cf1	7339
762	8a3f48af47da8008f09f7abf2e2b4344e4dacaef0775a496929523d99c801680	7344
763	65c8666366bafe124164c5cc73e5b77bd5ab38a82c8fb67ee8d6fca29a3d1587	7348
764	467d542968e65e0a999fc47c314613c1c61a754442212aafc2eea5405704b65f	7350
765	8b66440c05cc70b832d1471c91d32b0fb63c58275b6712801bba8b0ca7263164	7368
766	4a88143c5e79a5385f2c49cf859e4c0b7a6b2a81c24745213400d5403443aa62	7379
767	874ce0e747b96bdaa5e1e86d488250815f91963661770769bc1a7d49d2c63f7e	7382
768	da199722035ba4737c30d9b5b93319055d1a69e8197d059c7822b291db85c289	7385
769	3ba7067cca779e3883177b8c7a4a0d72610005581c96d4ac2ca86a77df7cd103	7387
770	71604f42487a4ed7725ad3a31b8bb5cd4890c00cfbca59decabe0710e5aeb7e7	7393
771	c5f2650bff6dffb5b0de240d819a8f81cb79c6417e6c791bcc4b8e4d0433a530	7418
772	c0d0c75b0483d9e2c231c0aa802dcfcf252020f80ae1d05705087f09aca09a8b	7435
773	e74f5df4f96c7ef386309109299eb3cbcdd2d5817c45ce5499bf134ee41008ea	7436
774	80e43b5b4068effa1e2a341d8211998ca89fe8924b5f33de72c189211d800798	7442
775	440cd52b8a3c6478c0ab4b8753a8a17eefb55e6e89fbe365945d61a825756229	7444
776	93519f9f242a5f39d65a8b04ff48724d9e9ca33ae6f400592952429861103ecc	7460
777	7a35ca5dc568a15a6185fc62dae8d97d43abc1a2b1b8ae80b739e20bd029b057	7461
778	2a1e46b0bd0040bb11dffac2721d7067bbe50554400d805a44e1d542ae5b2577	7462
779	2659b702cb300d2b2c4ae7fd978ef33aecc04f43c8e550d19209ce81c9651312	7465
780	4a5b599898fe9829160cd82412a398649381a04179e178d56fa46ca8134ddf71	7466
781	584b59cf222a0c174144ac0e89f964cdb921a384412502c51bd0755f034efc11	7470
782	d75f7154fae003ee84ecf591d866a1d3731d243b133eb2374517276707026d0a	7474
783	1fb1b4d9283c8d194a2a98e0398145047beb2a57cf191b9971be22d0abb4a482	7483
784	e577d5fce9b2e0292e1a29dabe1b4428321f7dd6dc7eba2adce4da1540c79bfe	7484
785	286d94cddf5bbced1a331f35a810b8acfb75c0c7d1ce0e1ff17c3043b749f4be	7492
786	6417c5a7d3bf7d73ea77d43db1d3de4ad212f710ecee4e2d57dbc4252ba485ef	7495
787	e10eee117812d181401acdb96c929761dbb44dce78c19118afe7acf505438215	7508
788	bb8b870e7726662bb7251a7923cad225e16d9c41e76621c09c9df9f0354aa60d	7510
789	2ef89bc1552d6c9fe148439bbb975ad7f26ad9a673d5a2279a672fc2a07cf587	7518
790	c038e6f7503d79fbdb1f97ac6276de1451f0728b2993c4e78e3db0b77b3aea4b	7527
791	e0917cff528c039c59e7c3a0a9ee7a005d9717f934b06b180e00267353ea6539	7528
792	29c3a46195f5236b844c60c3936eb8e5bb465b8256eff226561be3294eb59ef9	7561
793	4370ef4884a03c8a5758c3c9da50e9110d0c18df67ee3154793209f83323c494	7573
794	9cad0f804b37c87760ec7c5aae4bd2333dac718ddbb8ceba3569933b92f5ffde	7579
795	2d2ce8ff57f5b1345b265ad710eada18aa1c62afef551aea8592e1b2beedb286	7585
796	c8aab5ed45115f93d305c8bbd1e3220c03e88dc0a9cbf4077aa891276bee7efa	7596
797	0c4ec40bfac89ecf43f2e84d6a88988bf819339a22358444869172017be2f2e1	7603
798	8b4028a2ee2704cfc132c636e4051fe3d75be0544fd73dbd040264058e124a48	7611
799	f7712f73211f8d76932f5d3206b940e835dc2374fcafb91f726b576839296bb5	7612
800	d59c7d07c128ac35fe1de59fd2732cc929e4d1b8c47e6147fc37c6106cc76f9b	7627
801	73653c5ded656ed9b94de999d799c26bb6567dff29a4ed3de2c7b7fb6a56064c	7629
802	49c8590283d4bc7cdd8d376f9c23dd6f91fd1013c1c66b04c24b5e70d600c12a	7632
803	d7fb5e5e37c6e3fb9ef013bf7643c3086d7ae8034aaa999331025aaecb7a1d44	7636
804	6dd78bea94fc51b5a2ee99443c5a3d6b921a8433f5da47972748dd76ad4bc193	7649
805	d31241ad3eab63a19d8dfed6173a9e0486ca679b1e99485536ac8ba0eae87a7e	7697
806	e4150851bfea4c7359222a9aee54b65b932f695c59b6d5897d25fb67c876b363	7698
807	cabf6c12a2a18bb689fb9775783477cb23f0353b2324a6b3f179779441b1ee27	7702
808	0a9b936337942a5c0cfbb59dd01ad892383d1cc160f3b43c5a04e6ac125fe190	7706
809	fc69bf50f2e73719124b8c20fc3d5c37c4b6b759dd06daee3d029f081fc32dda	7729
810	3a21836f99173199f2e13f0c1d9c9da25a2032b38317bffc8f8ba3a43b17f897	7776
811	6fad497f9d2b4983a1add36c6db7a87f8d52379423f44574a4aa735f08cc3641	7778
812	3e9b73e1622659a1692dd4f4857945c6f9170bec7281ceb4e821a21179e10307	7779
813	43bdaff7bd316ef61662b7d2fd0a969241ad2187d068fbc8f4c48ab5b2a3ba32	7789
814	41b6b4787d45a29bd30609b20e0a843aa4c1e41d6013b3ad4cc62efbd5a89f53	7790
815	d90ae1dec45ee8859d969d50b30e6e11e2c08d9cd9ed218e487ab57f8384381d	7803
816	9282e4171aa2d052ea3b306fc467f6bdf58e25ea10f7673a5151522053b4fb66	7808
817	469dfd8bf5621079102074ad684f297ecadf95756143621145f7d98bf06900b7	7809
818	d3d7ccec3b6a94c01dce03d673c6b820a1ae8e1a3cf5aaabc60793a49800f155	7813
819	eba3971b957e5bca4f168818ef241a328d55ec56d360848f9bbf4d4792097396	7819
820	0019419291071e746c3433cd350c73e36aee8af01335462aef81e67a16d8124a	7820
821	ed12738e0fe8baec8f5eb0e9ae22e85a2a6a8f940f6aa70607146778a895f8b5	7822
822	371eb6e00a94c470836c3b913d9695de968aa9e31870b370275149c64c194fd1	7835
823	0dce0ae2fef496cd72ff3315d53d0b70eea311b76ae17dc8409a8d474d1e7ce2	7839
824	2e41ab61c4e3cc12524cb851a4c660ad07e14f6ecf86e9f638f150a89220a791	7840
825	96a337c77227354dcb394428cfd87efbd62a8b77b67ac19ebc8317b7d7a0d3b4	7845
826	6ce18c72e1ac3c14548a6c3fea722a70c31a299809c1cfb2ab71137eb4323460	7858
827	a85c59fe1e59fc86117255c46fd04924ce1f225c754f5be920c3128c936e3b82	7866
828	af9274a3dfe458a5d0e8018bc2690aa47c9bbced7760093e4500c72024bf88f0	7868
829	8d618d1b760fcba46728783c9000ed5dd0a39a45ff5e4b9fbddbe3d36f17bcd7	7883
830	994a498e6d286a4f76c24720932e20b6042f557e7279109a368b3275afcafd95	7902
831	bfff685c4418166d4d3c18431acd3fe66626fb5a5aa4e0652b2136078509aeae	7906
832	e7f82d5172c651ffb9a348f19785429150ef1312e002356a34ce5a2ed5ad1564	7910
833	f5eb432f06577491f45f8c5023db1aea0848492760b94a2fcaf4fa15646d876b	7916
834	f8a98c1153746df4181dd362174e5a865910191c517b983fa59074332b318e9f	7925
835	ce37e1cb7b3b84c008e4887b33b6c8e33548ffed352db097f9e8e006ccd013d6	7926
836	487e416912096e87a30c3a9b2087190f5786b870d52b7699e309df948703cc95	7928
837	26b38260382bcebde7e9d707f14e9258f8b285db779405acc7ea80162409d1a3	7933
838	3e379381e5f30a0f5097758e98d65c240ec3326eed6956b3bca6b4ecaa59a687	7937
839	bd2a6bc369895621d503d4e0f8b40db6a94e9a001982819dcbd7d958801c5782	7949
840	83a235939f08083477250c204eb53cf72e0c23dcfaccfae26aff5e52f36cd331	7990
841	a70eed5ccf4aa3f509d41ee897751a7a81cb3da5ac5fba8c1f24f3e764f97ca6	8001
842	a4583870d2ca4d798844650c0e02f6afb4f47f4eada10bc5f5c43e70b6d36aac	8002
843	8420e4a202f4ec0a843b3cfd4ec36e00ae7b1165a861a3d9433e1379fa364c13	8014
844	f0eec918d7e279821ba8a8b288dd2d640953a193d69d2083ef4e63734d76b11c	8030
845	e2113e30546857babbe46f1ef63793a05f2969f358277534ca4c8860d784daef	8031
846	ce67b1b6e95daaff9166b41e4840ecdaf8fcb5a929642df2c00aa3cdc25be930	8042
847	f96f0b60fa45a1d226609ee69221f7e53cf12e1a2d2b6b8a66da6e6c44c87f8c	8044
848	4d7e8a5e0ac6cc154017d3b04a74d83665edc82460e9f380b464a85773eccacd	8045
849	4a69fd5b828285fcdbbb7434c6a05c2d4bd8e5c62e91249905d9a3a0548b929a	8051
850	2d7a63abeff50af24bf6197e27743e989e6b82b07001a6d31c723b35db7a8711	8055
851	02900b8703a404b8654f6f2529580e1f37c558fc1be81dce8fca4cb7f48e8d1c	8059
852	e6192faf9aaf142ce3939b5cae365e6a4cda621b79f09e87527b81f5e9ece6f2	8060
853	4fad83ce32b00ee7bbb4ca265d46ab3f7643bd298bf98b056c2bf52588cd1bc5	8078
854	11e8cf286946e7226aa97d79b79c249d7c8cc344d5b9da4156bb5ab77db3ad84	8085
855	4d7adabdad5a752c6fc12544e7665a438d4e6646b4a04d82784162654c2e0aa0	8087
856	237c226d11262d72c6d5bd6048f9d6f6c218c809342606c9b89e5334228d7207	8102
857	17b9694cf14d0acf467f461b2560e5aeb1d59ceef0ff7f0a29af7016705daa63	8103
858	ed6fb293515ac35fdc83d8adbb3261ed50b3d0dbcc507aba30936db6e3745c4d	8105
859	03960b35eb954d34df31893e5a73a57d776415743e930bdbeb9fe03658128609	8126
860	8ce22f83d57581b447973fa103174c8d04adfd4274888583697aaff430301979	8128
861	856f262391af38f3f1871be09b6de7ec4ed649a80382a0e49819f94021757149	8129
862	d71a3af291efebcae0c4c5651e24a0a15b5e3e6405cb0750b8d196a021cecd5f	8146
863	5784f7f5e78bf341fe18637b59c7d0e9e0b7cf4444e5f362279e9988116138cf	8151
864	68457dfd8f310beb84c990c264f79be34b18cb22262bb945bc5c8870f359dad0	8155
865	39626493ab4d52d36fe344cfeec52ab4761f8a0dfb28dcfcab21bfc15a481532	8164
866	233e558aac499a292f77c3e8d62039b2d7706c3ce5507a873ebc51e7928e846c	8174
867	8e2292806dbd84aaabb74204fcbba57429d452d14902d396786e0740fbe76470	8185
868	e5cf4f1249d96add1b8adc23da155adc6846d618cf76de383291e0bfe6a7c261	8198
869	0f03b445e1b54e3601e0568a88ca4975a78541a94a5ce6b9daa1ebaf440d0d11	8199
870	e22523a77b9fd9f5b6554906069e4ef673bb54c002822c58d01584e4a6535806	8212
871	acbf627af85b1ac3ccdd64acc5aafa4351a78236dbf881bf9a1b7b8d2d8b646b	8213
872	5d896e5af2e33403a4cfcc60bbe32db577c3fd233ffafc40fda8f11071ec998e	8224
873	4600fbc4de709c4f6d0db2bb75a9ad7568344164f1b9c343d5dfee045147ad87	8254
874	4c490d2c5d6324f1443981262b05a89bdc6c04cc0bd02d3bdc9aece7c9bc0557	8262
875	27312e149cec8c324711ee3eb192809a0cdd36ac45dd900fddc8ebd87fc5db07	8263
876	694273731893e103e6f1518e7efea3bf606357c0226593ab53973f27f963bd24	8265
877	fdd66dd9cb8b100f80f9b799f34136346a41c26186209dc239ecd37957a2f1d1	8281
878	111bbad90ce7f9007afe0c6287245f29926ff4e18b7acdc349d8a0aa0092c64c	8301
879	821eea41f62bdca55dd2436d963709ae6cd9eef18925728f8556c80d8580df64	8303
880	905e7a9d40fc9a8693382f4dc2fb5d0f00edd67a49584d8f2ccb4336263be702	8307
881	2b18efe6799142ea296b85c7f3e88f39d364a312601346c26b656c5a121ac37d	8325
882	699c8c0d663d6de2001fb0ed80b871e3437ab5060af497563af19f557f4646eb	8340
883	8bca8fe3046c0f2b361dce588afa75892e3c24468e3db1b85f10bd22b87ba3b7	8356
884	3e709ffc900dd3ed570b80f81260f1ed2a050e98d0a8111d22f59edc44bc0e3c	8362
885	08a8bf9bb52ee1612b5292c74c0fb7d4117195934f4300b5c3abe22001ca8172	8380
886	a20ce01005e6bc0e63f57813e2169032c21b1f18d6a94a06e2ff79fe232f72fd	8395
887	fa87b7a552f05912d8ff7a1773ecec1b7e1a2bb7c8e7dddef659ce47fcb040b3	8399
888	0f7888eed50125b019d3c91b4cbe6a6b047aae83a9205214dc099b1611149cb7	8402
889	a10c51ab799a6b580a2fc6abd132d0d98a60fa491ab0801ca73cbb28bbc613d2	8406
890	6aed33db28a51e8797edd33a052c76a10290cd355c618086f0eddba22c1811a6	8418
891	d4b48b9279c34dc6f6b8a798e437daf0b3ad22b570b98e9cda08206e2e0e0809	8427
892	2e99fc5b7708c19baf0ce4d125afb2b7e79cd59c160754280f6e50bf46f0287d	8438
893	5007685b28d93c4542cc31bf23fc3f6ba7c79d8eb219b1b2630763a5a5bde902	8478
894	af4d57399ced13845ec34737b82f307b2e3da0956ac354eea97c6466d147b0de	8481
895	425ebd5caf374b6571bc0f9b1cdbc2cf12ac777fb54b1ca59990102597177ee0	8483
896	161c6dd0dca5e41fe894e05363e3451a2f30286220506308b2de72a83ed5bde2	8492
897	f437093b32056230d79903984ae59f78762186f6889f3612487aa540ac42ba04	8506
898	a374b89304bfd51166efc406e5c811cf994544868690807c21a1f506867c2765	8517
899	dd8514b45f3cf1a2dabe376711529ba42d4a8d9210352113363ffe39b37a19bf	8524
900	6e46d2ff94c4ae7bfbe94f8cfe36e189cc93db6b5daf8b327a18f4a398d47461	8529
901	d310e94f31eaefa8d333d21327aec925d4563e394d3f380966968f78121cec4a	8538
902	99e8e4fa0f4a124f21f5d5634c36460494af148a565fb5881f92c413ead830dd	8547
903	af7075ce7cff80dc0f679c18098aae9e3f5880ba3fa90c5375f64056e70e915a	8549
904	020286631c18bbc4840bf9763ce92c12d98f7c1df8070deb068190814f683cac	8554
905	01998e9a851fcc11edf4d1e7a84a47f227f17ff221db12a5c27ed13234c91881	8591
906	e88cc1338b873d85e3c8a9c20c9f4513b024ceadfb3f2289eae013e242867e7b	8593
907	42a66a85a1404fb55049cba42d0c8f3e5116f4870a68c4e4cb1caaec65bc9c47	8602
908	6d2e758dfcc46d7c5c1aa713b9aa619f0beb72b3cb38263910d9e3447d5d1e6f	8610
909	c61be929be2313c687964dcbf3a0423650b28b396795b7b5afa3be86dda2140c	8623
910	dcda79dea64e662ced8154afc7556877299879d58b530b2ce4e1ce84270a1ffb	8633
911	61f595bc851427b227b9b15a16833cabf1191721f881fc2f102668c0a25a9da7	8634
912	f8eb2c174d5d5e59e7166bc240f766aef8b39b2e01c647e37b59369782d90cfc	8639
913	c783b7cd61eef5610a0085947b707e96f8a768c07d67b4bc8a867a741012a9ee	8644
914	67a6f7becab6b62372339dff080affbdd36ae8368b9204d18b15a571dbbb7ab4	8647
915	46953c7563f5801a726582cddc514c573d0659559ebbcacc5eb723de53c2ef8e	8667
916	5b759a94515e6c4a49119276f8675aeaa9467858278911ce24f1fd2e3d0bc3bb	8672
917	af4160bcf0414fd01d7d6c228c7e0f39ef16471f288e28bc20a458ebac4a9005	8680
918	f92be1f92144f0da9b8e9f417bb53d1bda0e9c2a58c34aeedcb78a5c9af6d370	8686
919	5463a9768f78ab24afd82b3eddaab7a5fa7c3bb4c8bed888aaccab7e0593b29f	8687
920	8b6d1f4cf7aa56809071b89c1755baab5a998346df5b640c3caedb2c639020c3	8688
921	cb2a86b1e1cf4061c21f123f2bb974a9a8c31a29d6022f14212aca7984fa8373	8705
922	efcb336454f6fca20569e5be851d0081ba86d3492175081ee363f81a478cacfb	8723
923	d9eb57439ba437285c087603c27c95bbd0ea7be2525f598edb843ef32937dc82	8728
924	a1ca329d3ca1f13ab450dd3e512aa52ab2a6aba02c9186162bdb3c4cffc4bd65	8729
925	35a3cc4af3a2a8668cbb3976cccee94a76b4d0f4c21d902ad56970f9f17a08b2	8732
926	49e66adef1849cba57508eff44d6129adbb617267a683948cb2a3ad8206dc5c0	8751
927	a2ad439c1ffcdefbdafc7ddd5791c62e6dea0e2b9cbdc1d0463fb474cec834be	8758
928	a794d152af3ab0bfaaf623d89f361225978b6e354514c055227efbf7a2b75c0f	8776
929	5efddae219f2fac13e649f9d2577ce07e129069b72095f76828689ff51641a72	8777
930	56d695ce92c515cf89d2500e2d1e924715e2ed0ab2797b3960635045678205b5	8781
931	9ad6d80e08d9ec950f3158a18899deb3e8b655630b9e1f0662ea2303b8c1f0c5	8784
932	63c9a5bd0a47216b1df85857fc36b32adad2f5b372cdfca9d1eb0f76490a3a18	8791
933	960ebe0ca2c6ebfe3aedb3df6c5345fca21587f21e09657f8bdc62154c346850	8802
934	1e757d4d815ffd1c10b570179eb09e73b4a2ce2258f796a9c669e41395242595	8806
935	f8d0edda4dc2f6dc2951f31bbf0e8188bd1283bdfbe985b75226eeb994177548	8812
936	b0b5d58aeaea4e265d42b6d8de1fa84054a83e08bfc4a26d2fe082718255928a	8813
937	c140f3f78d9014f1404ddcf017c7260835e0cfacfd83bba0a46033e48543c082	8817
938	4f047b25e3f1d910b800bfaf170b39a5135671140bd4691c12b4e297cb4e334c	8822
939	02db6928d993a617a41692aa7248aa56dc46d2ba51ad6630585328f2158c6c87	8825
940	e0a2aa07c33c12b352fe2d05003bc48659a845b38d78bd60bd3b7daabe6da2a1	8826
941	a2583aacdf9f0170e5663232de33d18dd7228f8e7ae30b18dba8f410e615d950	8830
942	38a1b1cef67c65e4a3c1e55040e6a435c415b6c394cbe9c5165abb02e72cc2a5	8831
943	52ba7573e81648fb225a88d9825f7bad50380575024aef76ff676e313eab2bb2	8841
944	d22309561085fb9dd422bad550193ace3c700f25437a4c75804810dd58359541	8849
945	fd6dd83af2a3ea84eeb898057029091eeadd7367fb694194568698384b3a98b8	8873
946	a72b9210cbcd9dd1925bf055d53695f4ff5a99f3084c9ebd12b9298533e0a1db	8892
947	700bd8f760af00f213689bf4ed92746f9936d6495e7ebfcafe0efaa6d19c0e03	8901
948	df5b5212b34de054cea4b803aaca0da7bc226730bd9d13180f1c8e0d2bdd6fc7	8902
949	85e2a8e62276c5498179871b1ecd0f802216a42c20a7327d2f46d6613c13202e	8941
950	4f8ab3a6da9b3a0d138cde3c89d4ec20e634158f530b794359ebcf2245a8a47b	8955
951	6067e9a5247cd5e4bdcead3c6798da0aa74e1239b5f89a31d5a7fcc31638ce36	8958
952	e62905f36814cedccf3922bb7c82a5af53995577b33212f64d05db07b8ae35b9	8966
953	a97f8bfd0e5810304ddae394fc730ce9226cf2685f641be62d94e213b2b28d64	8971
954	8c425fe54a36af46915f13ad76b4ac0fe115994a1f4f97405e89b32ce159512c	8973
955	578fb0cfc7ec77232d2a44d5b5bcc743954727d07dc7b5dad6842b35c02e4a31	8976
956	bd7e7356d55c052c2435f47fcb4966dd929170e643ae2d38f069be92462f81af	8981
957	571e493a43c5b2e9f995ee4f1794278e552588790783825bec12223d4b43d06d	8992
958	bbfc3bbc49487a127833201dcbec5863ce9333270a8776e855d6889b5fb27809	8996
959	9b8bd0d7ba55f62584a9c064f57ddf771e40978d27abc228869478b09baac876	8998
960	fd1972314d9e65a68b1ea445dde89a1cd34397a69701ce735505174b28ac7645	9009
961	f901c35e315f9d00e1c6587b9e17a2b52547d74e87ebd5410da8bb6f07bae202	9020
962	c42ad7109c368d07e10c0f91eace3bd76ddb314fb7b61450c393344489e8dfae	9026
963	49f32f319154251f854a24fa12840a2a402207aade78960db9460401d926ca48	9032
964	c8d3873faa9a4c6dc15efbcce6e7a3d2121c850071feefe9224e91fad81207ac	9041
965	0bf3b9f41ee3f7f65001507a2bf59ef2b3434f3115dd39b41daad8aae3af8c82	9042
966	61775cc32443cbae47dbbea9dfa4da8b80873364a313265ba72252b6a6d3f830	9045
967	d1f4d65c34e54a35f019d3f9394f0e5035f3e08ddd39ebf4fed0d564e6e073d2	9054
968	c5bd1ddc96205c5211be0bd38ea361bd4ca0623a2d53e913d855d066206c5e64	9064
969	012ea523e9663ec802fca50fec77358b1c83d0d1b022d8945e7e3e168df56fac	9068
970	63298a590080024816f714a66ce1bf1840259410f315356a3cf6d8d36f35870d	9076
971	f4aa4fe73715b9f4d4d64b1a58c3180daf482bf74815a0dad397bc32180c825c	9081
972	b6fb8a86c8f1eccfc7e62cd531372d972c2666f3d86fc2275e836a3e36f1db73	9082
973	2519e8c26e6be2d6d7083258afab5d5662709bbfdf3ce34f30e1b94736479e62	9086
974	c5dbb05a334a6ceb6e1fe0a68ad4a21bee95e2376ba4b03684834178c43ef9b8	9092
975	d8d28e88b6b1ce90cdd7cc367a194e4b1afefc4456199fdd7ec882beff6c2b8e	9105
976	3d9679a8e94b302e5d427c07bd2967d800769acc62e39f44f742fe6860ac25e8	9108
977	7814353e0f4bed1a671a8933194ab029e8c220955df33f63fbea6b86d60f9b71	9114
978	66c0d9f7606369f003c60beb842bda55df2837fcee7f430c85002c33b6101064	9122
979	76ec9bc5147873e98445a913b11b9f6055a810a2da3d49167ce2f844062eb657	9124
980	3b4173563d91a201e1f9e26dd95c83ed0d74693ee60332228aff789bb51ea07e	9128
981	a1ff4b12cfd664a09c7a6fe354b8b29e8a45096014a0ad2896ee8bedc5050a38	9135
982	80688f0bfbbed95258b624aa2d84939f3f1e15afd565a201d7d3611c7345f890	9166
983	38e789d42c88b0bfffe9a837b1333116c9d061e74c5ec1e9ee6da60f331103bf	9173
984	3fbc134e17a7538f889ba58fbacb954a5f8596febf776f19b8274ed2bff24585	9175
985	e4cf5485c26badb3ceedfa41d255320296bba97e14b7b16cb59722f65f3576b6	9178
986	ce84a9f8ec98e45bf2ed9aff124bc03d3e2dc70a6e0c2fa58378f98774ff8f22	9188
987	e03856748a9f94e1b0f0a38924222de1830a6ef008fcb190be73f59244989148	9190
988	13e20ca19873dad21e8dd0c0c43cc2ce0e534adf0742726689e6ccb46a3fa0b7	9201
989	8d330d57ee7ba589d728e2551cb5d3d0b4d5e40360cb9113dd0a3e284f727e5e	9204
990	0943038e10978d0a65759e8de8d5821d5580ad6b1f77f97c189f5d2af420fd06	9241
991	4a44d2e8df720fd86251cb970fd0e95e4a0748534dd94553efb5bd239a4a4805	9258
992	f7623ca3fc54fe3a0f9bb94b43b4d255938590f9505ffacf5146688475809210	9265
993	f6c5677a2e0527a6882b662e8536ad780d76893af65cae35a42eca0268d0b727	9268
994	f5e45b70543d1a2331b603bb5648aab9469080599b485eafb1c354794ab51661	9284
995	e46aefec8b66bee8bde95e6fdd11ff80d690d134d7b4bc172e58e59932b6704c	9285
996	c6b7abc251055b83316f3fb3f14f16a27781cb620b3f57659613e4ccc6c7db30	9303
997	affd924044ee0c352546e0bedd4f14128c3c3f04270bff5035e3aff748b4ab01	9325
998	dffd308cf11da09f089eea4fa0b42626e4a06b7a4dbc516188e837f6286efdcd	9329
999	7b8426d436b0f331e9639f94fe95cf37d7c8f7307867305a0505dd60645f24d9	9362
1000	8933d480f1debdf5f6bd7fe9aa114bc4ee592d61c11b938271a29bcb4fe3e9d4	9367
1001	ed961048fc15da3445092a8e196b551dad489304016033e69f4e3a08a1a59552	9393
1002	530b19b4118db0fd784c1e102536949269a62dc8087ef7ba9d7d2e7121088aac	9411
1003	48a32e17d14aa582feaa0825dc9c7ca3e704788c9a09c39e8f8783f57c573bdc	9421
1004	5ae273b4ff5cf6d780346ccffcbe60ee5b1ed16dae4adccd796f0b457a8a2c88	9429
1005	e787b9e0fa8eb68c444eb7cc341b33df45f01d871416cdb1b68839a8412fafb5	9452
1006	9d40e6c4ab182640057b35ecf3027058c1a8bf4bf535062235022251e6f5131e	9459
1007	0cec2e5b8047f3542c34b89697008ad1cbf1debfcfe43ddf8b41cf4221f5ef92	9460
1008	b1c0ea76d8c8d7d29045b9fe257f3464818a51359c489738448b392127d0621b	9471
1009	9916e397643991e06974b4d43d0e46202256919bd6d645532d62f2b6e21e4f68	9476
1010	0bfd57baf49f8e49f49d3c1447bfbdedbb561acfc5749a2f0350a44ebd8410a4	9479
1011	8c3fd84404c08329f6de363297b282cdd498fbe7f5228e934a2de4e49f973008	9483
1012	7d3848abe709aa097810bca7925dc13f4e3b1251cb91ba571c4202adf7ca7661	9492
1013	2624dc47b04c429d868ddb393b02c0fd0c34db9cb2e1dea69dabfb758617fbdd	9500
1014	164a6fe36f505450ddf9704ae49f94ddb8f2c687c0eef8ec78d2605e19f9fc00	9507
1015	4177f5507600da4325a78a56c3e5b6ec5c2b3130371e823fcbc5ca8e30894bfb	9513
1016	760b97af7b8961c0fef2ed018441026eeb38abbde9a90bfacac429eaa3e9e780	9534
1017	0369e4889e5973675716c4265ea5e3c8fc9677bf11e291db57a7b4ee3f118bd8	9546
1018	a7fb2de4c8dac3e9b0e0ae446ab4e369c0bb02f383537e6d124fe8d2e6ccca4f	9548
1019	95b500381dbb9613ae23e6dfc5dbccb2a07cab90325f0446570f38679fbf197f	9549
1020	a2a9a0a14365027a3fe81facf4d4572e562e4670f586784ea7860f914f207ccc	9553
1021	5fbadc691496c0968bb261e29fb76baf4ff74fe7a6cfed108262a7ada02a64b3	9563
1022	6dfc85fe1f43c6b62cdfa637a2a948ce9a8daed401c8d36a718d69eaaf1221ff	9575
1023	5ab54c37f46f67866e7d6a046ee3a5ac074a4f95a2cd0e370a9553ed0a51fb05	9581
1024	b420239c3537b8666e3121d3508afb344920fec1f4a7659fd63aa6c066c616bc	9584
1025	5f7dc34844ce4d0b70dd65fb93ee0dd55df846f510d63e925718d3cadb41212b	9585
1026	bf4a4b07a733b502d929637e878f360f6fd4074e9693a1ee0efc7b48797032e8	9596
1027	b7987202b286c96b06f8c99c4d652279c5181e168146085fc91254f48733c080	9603
1028	642c8fabff9494a01ca081597f3500a89c75e3051b9851d5a0206c2e7ebf641e	9604
1029	28506c94a97c9bb861b84089dea01b8e2bf3915f5d6c0b746b95bb7bec9df6d2	9627
1030	c0d7319c52adbf2cc1e61e070f268a194a80313852c1a45b157c6660bf5c8516	9646
1031	1f51afd4f83eaf4f007286632498ff5f84dbde787fc47ba36dca9454a1bc62d5	9653
1032	d184abce2090307d4f361c83131506d59592f54bb857b936748fd86a9ba2e9b9	9661
1033	04dfd90f887e591afac92ade0c97ecabe111f06bb312f0bf1e5c2ca984098ddf	9676
1034	530c14af8db30d859edf9279f4696db33c10080523108c17ac3f6fba25cd1c71	9677
1035	536a95b3d249f5ce179cf01351c4aaf1648ef921dceedc11fc2879744f9d9aaa	9680
1036	994cb6aeab3c2cb4cf5c6f4806b2ab1bccda8630161d43272f2c181782567f95	9685
1037	5b66d40410fc929b3f8052b6a0a836b4903ef083a483556b86d30d58a539efb4	9704
1038	8199a929ba171c7c80cfd4722d037109782133ac3dd866eacc8babc06305b80b	9722
1039	4a16017475ce8f5b0c444ddd09e7602a0dd5bd436d8065b645479fa2daee72a7	9735
1040	de8c99466de98f219284c5618ba4f30fb412b9fa9a0229db7fb0fd0f2d6882b3	9749
1041	285706f1cc724df9797c1385b599d4bf963c6c45aafaf50828306b4d1481a01c	9764
1042	a341537e65121a13b6b35613657e40c17acddfe37c1a8a4880d7ca58bac9ec27	9781
1043	8daafd4f1eb2f8d7a4792230c188d03c9eaea70f04d129f5e3028a5441e8a6c1	9791
1044	45b31f06e164481346e5cbe880f1ee073dd08996cf154df654a25dfb766b94a8	9810
1045	eefe6999cb5378e55677e3e465e5abc58c30746845493bc7942fb9e606cb23a9	9813
1046	b9880bce5b347bfc39a720787986c03ae21d7a660c68414a316980c9e4d394d4	9817
1047	62df56dc2d7b39ddabbaf7212551b4b2239e0cfa2a2fe913bea0590fea7030a5	9844
1048	1323e5f8db788535298e5cdfdaae60e9f07e2469c8e70eb996750ac35cf50cec	9845
1049	a57cc07e2e2faa5140481a791c12cb993a6e1da59835ac3d55ff755e392fc1fb	9847
1050	86770919a10f6fa8da8da89d07662334786a528b142934b5461768c505587396	9850
1051	63734b67b078930a8888d3f886a26535d128d57b1d26ffcef62a8b78ab2770e6	9853
1052	054248ccc48616114034be9db5e2a78245f2942f109ba5c7edea88d33d2cb4f7	9857
1053	1340e86e96364bd5fb2ecc7af4f72a386f93a9049728880f271cd92a24a75ee9	9860
1054	540327e5a3c7d3c2cbcc2d3ec1fb95cbedbb634ccb171323ea9f8b9b0b477b5c	9872
1055	8a93307f1f51df0caa9a095eb933c0f2342d6b37bc6a94b1adf1863aa089775c	9892
1056	770c77dcec86f971a106a98301e817753127a99f3a31cc9588ee535debccb6e0	9901
1057	6b58d5fe6f566829dcc3f1ed30226125a422d20df650951656d8c1d59b075d3a	9907
1058	1aa35a8f625f42eceb2efe834b112fd149dd5aebbd72eda4e054d44774ff59f0	9937
1059	c51371380bb766601d35e35d23800ff8ab13f6adb833099312ffeee567c5756b	9944
1060	fecd62e5369518a6fffc6aff353b9cbfb4dc6fbdf51f8442b139e9afc764b59c	9955
1061	e3ad51d5fadbbd4e8bab4f5d26a39a831f9b6e0518864a6550b597f9ff747c4c	9959
1062	fe9b180e233b7251990fd641e6427f5e113d26d8f8eb2b62f6fcef398ca463b0	9970
1063	8a144d9fde0f1a127c17bfd4ed48ed0130dd41ad3ee3330714704e414d01cb59	9978
1064	f1fc09628ebb6b7eb192c452d8be078d85b0237c5eab2bc948d6c17536b9495c	9980
1065	7c63d209cada47e7e43b589b28799a3fb8aafe2168833b23dfb762806114a354	9989
1066	761eca29f2f8a9dc3b05be6f394ca55c0a6af18ba52dcab1b86181377db6a73a	9991
1067	58348984e6613a0b35c61e09e610aabaa3abb00fb523857333f57c18a7f3e69e	9999
1068	8244c96c8370866d3b3e0251e718fe4c4df95b3842f0cacf33ea21a6e21100b9	10004
1069	2e46163194ceb2250d43d3566e0e7c3838215e37b3bca09022aebdc7e936c7ec	10007
1070	28aab151de9dce2ba9748fb1d7fbde9cfb73284d449bcbd02ff221af846f3817	10016
1071	07da22d5d45329bd30a9c1871b5ab9b61c27ecf628d83fd981b55d315d2016af	10022
1072	db3fd228e208ffa833e426f463e8c65e709c2d52a66bcfafd09ec3dcecb6b002	10041
1073	550ac43b4cc152611ba1ccd7c10d265dab864091146ebfb6a80dbd25a899b1e2	10042
1074	d16b8c7d4f321956e16b4b395305c13cc5f91cd16cac97ca99d3fea7e3e1429a	10046
1075	b416d40580b1dd21dab75b245f06d85e280474d754dfd1a5f7d997a2303242f6	10049
1076	a5d71c0f5978bcb2122ed9c2849057f6f3310063670d1f6603597a179a1e72e9	10063
1077	13a92cffd6c6d1a19378965b9a5f5484ee6af5da5c8c859845431cd0ebeedfaa	10073
1078	e508327f26307a4910a96e39fa7f27fe19de7867346a82f693e3fbfe966fef81	10081
1079	bb2b2ce2c1c14895c446c1652b384bb4f097ba5ee850a2f6fef085059e1332d6	10084
1080	3abb5c345ef09ae9ca764489b3af9a7114082b34ad538cb3ef280d592d65188d	10104
1081	957e0c9b24306e6c16eefb235b460693c39b48c4b2bf968bdf65c1f3e8591fdc	10125
1082	1f299bc450709d5bb22cec169f15848715798e8e00f0e4378247e005dc3d28d9	10130
1083	5983f6ca53ed41823fa775bb04a969a16ca5d537fd517e371c457e6c2d56d10e	10150
1084	c9c3dbf7b861dc76f62c14f197aebb6063e1d5bbb8c1e785147fab3d0db7fca3	10173
1085	56e8d8fe576350cfa17276223739378ede1d7a4419e4a656e31d795b4e5d5406	10176
1086	296acefa7a704141aa6f3a632ba7dd943d42d0873c5b9498183522ff910a613f	10181
1087	a9348e5668fddfb7f47b1821d9cf1abce5e53ff5a80df94366390d7fce59764a	10189
1088	438d4b2e579c053d95395cb53c5787a17b8205ff6fa6f90c82a746ff6123a7af	10199
1089	a570d316aa30352acb90fcee1bb8f0119f2ef661b4a8431a378e761ec0f13623	10201
1090	069e33ec47ef903e9041e12d3141f883d8d3bacf11801c157cbda90da596c449	10205
1091	86217fe2d5065bd3a32a0762cd4278bfd8eb4440675ff9361aa5ea8adb20cf31	10207
1092	7a0af1337f068b64b87a56aab48f8639b93b34a096794a8aa5f3bc7a04f5c4f7	10213
1093	4cdc723d6ecc2c0bd4e54923b8aefb26a363fb1972d19bdb2fbc658e8e6fe2d4	10225
1094	45b21a4a1b2cbd8602c5a6c03d593190455542e6ae9a7ba7c073ae41eb8f8a5e	10228
1095	93fb68c4fc096368365399591b333c448ef3b7aa1147f61a80494f2297059418	10233
1096	ee91ad8c009f991a65eede220eb41119c33b965160a8fb648aad05b289638788	10234
1097	3b245954b55dfd3627a38fdbd5be5fa8c3d5a134b063f29f0505f32aa72d6a48	10249
1098	5d145616ce7dd0ca7e988a6390f36f56cd7688bf0b764b4216982497e43fcfe4	10264
1099	1bd149a38d9af1339a35b94d581a79c9278694a85d86c7fce2b7e1b6cd9fee25	10273
1100	6847cdb961d00b8013f0fe0aba6131a82f8a3ced92a420302269663d9f9cfba9	10279
1101	ef374448ce5e32371c312c68386fcee4ee389b5f9a7ebd47d21ff3cedc77c88e	10304
1102	c789dfd0fa165801b69b42c2c74c6f460c4ca381fb89b97b2ae6f1603e0fa517	10311
1103	47ebc1c81ae293a4f159352379d135d8af5956c2da4ad1ce8de734530075f1db	10314
1104	5b66da1026e5ace07a9079118e284b99a345c3eaa9551c2777a4422d7ed5cb68	10321
1105	a5240c772185e8bb1c95b28a65b0233bc4046fa3d6366eb264d5d84d516502f0	10335
1106	8d3df95d6563847fbeb62f0b430293ad76f0ea5385884e11900d5b2df48070fa	10337
1107	c6ba84c3027dd186485078a23181363b85af5bb4cfffb6f87e1b2b1811a3d636	10361
1108	688f9c989b7253a397805bbd98cb1745f0d6f10981a5ffffab2835a23d6ae680	10366
1109	3c02ff6713030882aa4ee93f6db0ef13322af50c9f267a30913242de365ea8a0	10386
1110	bd3114fabda9a2a36346a18f2aed8d4466c18486ab4b1127e33f6173290a0743	10391
1111	3cdfbf21973ddd51efa496239a6d945bcbf84e4ca014a0dc0c25fa7f642c6c3a	10394
1112	7323a3743876d9699a1776095407c0a7894fc9c6aeaf02ccf61441938ed555ca	10402
1113	d3d3afe86f3f2eeef58a7d091e1bf4d0bb669da674ea33f738b9a2d42e13c6f0	10440
1114	8af98ca82b4d9e5b87f6a94bd312fac60042d9bb38fd0ab9eaf2572e1450f6f4	10444
1115	ef0687e5f1b9efa677f11a5c7f077008b92f149b5c33b570131ead04c6d39e65	10446
1116	47df4bcd1e0e66bc4edfda1669455a60b453a98cb66d04a81a79b263423109b1	10452
1117	9e38d0264af73f2b6c728131f2b4db41635041fd708798c09011487f20569993	10467
1118	1c283769579a42468f867be30b57bbea05126eae181275a9322d0a30f21e8add	10477
1119	a10cfbe87777c7f0a0179f675aba6e78e3f458bd4854c53c9d445c47fc5d4c81	10484
1120	862a65dbb8406192221cd4794c7bfc40c9fd516217337aaa7e2555ee177a6c1f	10507
1121	ce072d9ea68f83524acc738bebf36aeb9ae4034b360a21a933926d2ecc6eba0b	10511
1122	096717696e6b2caa40c2b1b34cd96d794f62071cc2160afcf1a816fcd6edcba0	10541
1123	2869831c6922576cec94c424931b19d56fa87c6f4f231ba1c4ee30e7753c45ed	10542
1124	3d1a3cde7ef88ea745ee00e6d63d07e8f87ebc215417f2067d6ef8899732aeb3	10553
1125	6d6e876da7225a95fb35135d7f553650d4d5d5f18cd859a1268ac5a2a938b2a4	10558
1126	ac04a883723a228e41230d58de8245545f29896abfd128effc1b9b17714c3040	10569
1127	145930a70aaae89de8b4e6be7f1213e558888a511eb170e23973b1362e7b5d46	10571
1128	2d06dcd15537bce907950c1d3daf6d903ef7a45e4db1c2fbf8d0b23c2b19b294	10580
1129	508864a04d75c9f0e38098cd08d3ffca490cc49a1172f6770197b3481e441216	10591
1130	2c89519bf976c29ff74a5b5f60ff93b9fec83315f646c9d7a6344c55d8485425	10596
1131	c82c500fc65012aeb6fd8856cfb353a92dfea03acf2883f323992a427b913c39	10681
1132	38486e2a6b04e0e7cabecd817b8cca19fdb2c587d3e7e225c89eba93f5f86e03	10683
1133	9f13ca8aeb187613660ce5db70698aa2ae6728dc36dbf10143f61fef6fc245fb	10687
1134	a5242c46b3cb61bc7d78c339e26db2067b06937594944b7d554455d83b5dc33b	10692
1135	c4edf1fbebeeece6d52fad17dd6253128bd137444b45e3ffc7197f03a8ccc8a0	10693
1136	d16a3fed99c44fc797a41860059da46b169b1151b5dd915654b364c96ed376a8	10694
1137	735a5a18ba658066c386bc62e63e1dd88f981b44193280b578a63721e2d39efa	10697
1138	dd589d52f011c6717ef8f11adea9117b73a3767a1cd4346252e4c7c0a39bfcf1	10705
1139	6b9e004ca4fe1e2903a38953b990fb9886f6816b82785eea6c245deb6587385b	10706
1140	1e0e6ed7b69ea016058dabe108bca317cb723bfbc26f282144d8c80d74951207	10708
1141	8a33ebea637041014b0430be04998c4aceb3cb41a09cb1ffb6da20ae62aeb8df	10715
1142	640e9ebde47e8827d7d3cd878c053552891e24301d8cf00456aacf3d7067e7ab	10737
1143	27cb0e085c63b6cd066d9209cdedde08d0802de671363bfce40c3931a5d3093f	10744
1144	53252cb9fc0d9be6bdf5aca84bc61746b295fbf6581cb5b7f8932aee0a428aff	10750
1145	8a869370e4554095cf2fe4c4597fee67e724722f3a79a2c49dfe726ec22f9667	10762
1146	56b814740c5df89da30746589ca53ef8dfa5fb9b0dfb25fef6cd2af394033da8	10777
1147	9bcb3bacf2238df295924eb235bdfa87caabc795e42f0cf72124e22458a90325	10789
1148	7307fe02b70d1868c6ad0584701e101ff8e973e5aa444bf3c2869d6b5f48333f	10796
1149	3fe1d496694b16c7671962c003c49b69bfbc6acbf58ad8223ed92be703a4ca51	10797
1150	285d70f1a7da240c804ca1e0c97125bec94cf328aeb4269030860191f1c10065	10806
1151	b7150cd72d4fdfd90053ba8fb17b78547737303697b6a2d9af048a2427036429	10808
1152	04d39c06b64e513a849401b962d311b1e064735ef73045550560874998a6efe7	10812
1153	480bf6554c2c958bac539314fe7ced9b14cf7dfdae5b2b458d8beb639d4854b6	10829
1154	76e884c042a62d793541241e7e4694688e879644fa7352b9e04928df0867c831	10830
1155	dc504c8fce029432cb40b7758bd779fe20e549f9c6d5322965ff1353bdeb619b	10834
1156	a09303e8feed4951860cceeff0bfeeafc0d14c3c9e8942fc2005becaed5cc402	10837
1157	7d16c44c839b963fb6abda898db101729b547e457148bec867208e46fe252406	10850
1158	a0f9a3f4240287c11ce06b699844066ab3f6c0a7135c5fdcf481913979cb458d	10858
1159	638f8fc4fd57357f21c19f78539f6c69df0e358d7a2883b084c05ed65da601e5	10871
1160	15b62c9707fcdeeee20c881b334134dad6eefabaa2fb3bab6b16edd0be6c106c	10873
1161	8ea8fa1f69034258d9202a2cd89ec9fb3787b5186d240f71c1b6e29126a199f9	10879
1162	ad23d2480ec0e3aa3e9478eeb2e310dcfd5025eb220e67825ea8ecce9c6ab90d	10910
1163	d5376dd9b53d704e513097ab90ebc0e8b5ef6a179813394341a5d8144afb7f9e	10928
1164	d8c905bd3e5e5edb4185ea49ecee2577ffa6818929f6204260ee1eca729895be	10942
1165	0dc82babef28635e4a12be442a020044cfaae970dfaca1213b229849c057c750	10951
1166	f06686b56d43006b2f276d135d49c94bebf403cee66cdeb18878e42f80db6aae	10967
1167	fae722b51ce8d213207e80d54c5646f48a06d7b76f06ba82a44c4d358abb14b6	10986
1168	d784bb7f2a7dba6de41e96808fd2156fa5c1e05639373c734b42fec157219c00	10987
1169	6e8251708fc12b839f24c585cea7b24c752cb4450806e6f12c80a339670b678d	10993
1170	4e8b4a3bfac71f7b699c8b8bcb799617258880219a7e223bf004518f8591bbb6	11000
1171	dd66518cd3ee6cf49788ec8d02a82bed3109cbd267316729a6f6b9fafcd039cd	11002
1172	73d58794b00df2e630f1455a201c016fe3cf86ab2bfdd9846dc2ff25a2374cbd	11022
1173	33a4da7da83957ad6edce894e1c77c9a9759a88720adc1194121c21c0c4960ca	11032
1174	8af492178c96e8499a413a67ec461469af37da799b53638f9f07bd4b4a0c0f5b	11033
1175	021f0181dd976d685ceb930df66052516320f6bf927fb9f8cd9b5cd51846c661	11041
1176	1e3501fda41fc4f12469a0036a94de12266b5296c4556ac5b84509e556ff5e36	11045
1177	7db2a539be87ffcf2e783310d00755ba15c27c26bacc1179a1d06cedf74aae1c	11053
1178	91415a00d2c4ebbbe32fa279dcf51f95f5862ff53f214af8998cae811837ebe1	11056
1179	47af8c7ca72403fe46b06a263c9710b22fe011ccd6316da86f2680842eefa715	11060
1180	4aebbb0a60056513045790be1dfd441531a10af282e35b204a762d05bcb7010e	11064
1181	d67e45ba213ce7d206782876b891c0f95bbc3729ed13e99eaaeb4f24b279389e	11082
1182	96a8fa149accef2e4389167246d5556fa14eb2bb99a9972c5b63634913d98e6c	11096
1183	cabdf8ff262bfa02e28b9e638a7f77a8bb80a297ce97830fc91c9d60d1325039	11102
1184	e290140dab7c95c8256ec4d8cfafa4af37b7fd14cc9e7532c6e0bdbc9ff5ade5	11119
1185	337d38bfafdad6ce456ae5c1a600dcade0121bf937c336f2c287c2680e691814	11141
1186	aab6ece7de474fbeab109207a4cf1786e347606a9ceb39e4e47c170d7b5dfcf4	11166
1187	2d37a6cac0301fbb32edc3ad18afa4f265992c69a0c083be259cb864e2432891	11171
1188	96d4986d0e0941037cc3f8e4af295558735ffaa1bc91a594ec7a43f60c0c20dc	11187
1189	435dd132bbbb5933a652fc5e7da8a8b6d5d0a5b11abdfb26f52ce145750cc4f5	11207
1190	d21752009336cc51c18ec59d7acd019d7bb6b92bbcc982684cee5e06f2492770	11214
1191	f59e7625d6020b017733eb30fd3aff0a23fa65b4db0ae1edb0f577603e3da6a9	11223
1192	103723607e3758c7f5de6263457f6c008d2b105245037a9ae69b3cac0d8fd220	11226
1193	fd14a54cb5aab8a5172d525b0ae7a1d629e5a4e3206230a5bee087bc33b8b64b	11229
1194	2a103a81d9f3387ed022798f740258b57eeea2d818dc78bc4030f3becb4d97d9	11244
1195	75be323f66b66e5fc08951c71a67311c7b7a93ada6275e7989cf3ccdf1af651c	11261
1196	5941c349fced696057a31d656ad2e53304e9665d41e0fd7f153a751a102ad66b	11280
1197	a6c37bb03b3bcc1ab9062bd901e96888c3fe2cd477a97506ba67d4971203c013	11298
1198	4b6b34834046e75dc84c42b913de10393b94973c1ffe461d2a323edb80f63c35	11310
1199	8c06e881827e9a46fd8303a23e5fa8d9ceb7997c4e1fd954a47e3fc45075f886	11314
1200	7821ee568dcddd777f6c07bd00bd11f9879a54bcc6b00482e06822deec4d8a89	11317
1201	4f93f835e3e109189a005a1919c44b621d3445eb56e71e5a478f605b10057db7	11319
1202	091354f874a672d63933f3aa4ec336c5755a557b04ccd8c0d9368ab19463ef31	11329
1203	3a457ee555732aa373569d72251db04b040bb83f16d2e2082f011487fd984506	11338
1204	83562174eaf29c8a10c9c124527983e7e7545cdc79d40c4d3d330b1e0e984220	11353
1205	80435632546f5fa374189a8d161bcfdb35b6e6b7592d8199aaa30efb667006df	11364
1206	e302d2ea78a9689c1fae3e838f1622a4f68415d9f7507c90924d4451d0f40e29	11365
1207	39e840510ef5526df64c7bf18dc2e99d30823c32d3b7d98eb163c7e7711b751e	11369
1208	bb7d631ebf5b66594d22992fe1dd871233c1eb18ec26a4f73c8c6e62dc48d8b5	11376
1209	2f5ec849f575e32a97bde22623bbf3311a46610047c5a316a2235df9320a5cc2	11387
1210	6e06a5a13c193ad684efb54e1332f69345ad32a93d9b0c218e3a787874a40065	11390
1211	8ce8310c4ed7f7f47556db11f63947b7ef7ec952b6a8165f97915db5be70ddeb	11395
1212	269dd634f8c5bc5008382ad2614af3f6798bc25dcb1016d2fa1c659a4e7bf457	11401
1213	8bd3942277790435073cc74bb0620a1e72756e1af59daa649dcf6e364f7e73ed	11411
1214	533acd376c0f2900ea61103da0b7075a6fca26075d9daf17378b5d9cde410c9f	11418
1215	d0f20bd47b8e38ff97e4d8d64c00fec08508b62f629d58e56ba4a326fb0eac59	11421
1216	9fc382fc7d51a5df7023d08011cda552edf78234bbab2f1c821014271619badf	11435
1217	973a3463ac8c7807dee8a1054d19a01263f573884763f55f7be3577e8ba077eb	11464
1218	455f4ce62535c4c7838e53c05ca97470eddd089fa6c231e26eca6ac2ac52dc79	11470
1219	8f8897964db9ebfb767b002c2bfa680aa29640eda36674e6b79032c8e3149dc8	11476
1220	103b1cea820315636d4f2bd7959ed25d0d5d84a828dba6ce572a1c1c4677357d	11486
1221	882ce46cca56613fc0a8d50cffd5390c085ef253c84297b4d1b0a40d531c9399	11487
1222	b89b0b06d5102e9fb79895f92ea966119c8af91d6a8f35d0a4d50257bec4e5bf	11490
1223	2d48122697610e4bbbc2487e9184a73a23fdbd0d2142dcbf952b303cfc2c21d0	11520
1224	6046c053cfdae732809b6385610fec9bf49a10f0531697a6c214252402f7d628	11540
1225	87fb66e89417b9ee417d349dcf990bdc1fcc97c5b939984304ff7936c1f2edc0	11553
1226	320f58ab10483445cc44836f6711d9ffabdc01a6e26a0ae467feecd7ced1921a	11562
1227	867c333aa0843ec923c60e4c238572a081fdaa7c882f3fb1de3ff3b1ea08ef13	11568
1228	10da04284d1c2edc178aff5f45905f851e257cfdee5da215dbe8f3b653bed46d	11572
1229	914f352086b1128a66756ca859403f53eb49503bd7527c763e0a9e0e6e4f3967	11614
1230	77ef4b2abedc361f75c47a13124a00d8da05e1edf5bfcf8ab526c9699e732bf5	11624
1231	0304fe61cb71f48e61d338af0ad6111478ee01865d5592d5015116e986199cf2	11641
1232	07c97570df87a9c248bb1f474ce98d0ca078e98959d33f755a938983eb2ea929	11649
1233	0ed31251273ea21c83f1469e58c36bee314cbddd2677eb95bec2a2ae3055326f	11651
1234	7e8394f9c30a7f6f74278a7b3345598adb3ed448780bc75391966a93297427d9	11661
1235	139d9eea3ae823facc54bc71552cfe27ff115476107a625ad2a54bd0eb7a77f8	11673
1236	990f803cb59d7d5a05f057cef953bc76722073ba5c16d200294cab5b0957af67	11680
1237	dca35822d0e76102a8a88e52ce6502029e98b5954b342adce86b193f8bfd2c35	11696
1238	a14c47470f677c5a0ddcecd692a4b1224bde8f627521194c452d24b46a7d805c	11700
1239	febc7f0e6c59ae7a31144043c5745b5eda8b5e09ad43307549d00b04efb7df88	11704
1240	344d9c3b0016a0d7d8e7c217c0c995d4713b820f5a4a457a857e754dc4b3ef67	11710
1241	9942fc353a1abfca6a4769e44176ccf9e1e387b6be65f93988ce6614d686f508	11719
1242	4eac8c332ff64bf4b3263a3a178639a5bfa1bdd0c6fe3a9646b387ed784ecabe	11736
1243	7fa6af47d08b7a7643d072b334496c0633500eafe1203930dc5ff343d8a43c93	11737
1244	4d3b5a1af069ab16742e9041e3f03792df058436442da91789d9df8102233952	11746
1245	823c68f3eec1055f671d0e3c0c89b07cbdd8eac347d5e26787f8002765f863b3	11747
1246	33113ce096db2ead1eb7ac5d72c024cf3a87fe4e07c3c0a1404dabee9773c677	11751
1247	dd34176e038a951af6eb9c9d171217ab5b844948fe9e56cfd8b98f5f95f24e82	11754
1248	2eb17e5fc02b943b04ba810e4f7791c5c2be1e01d20fb154c6a9de1239fa9dfb	11794
1249	88c82fcecb9a38a17cf42197f51a579a87b663f62e82572ad25852f479823b64	11810
1250	b9671c98aa2ff20bf4414d2c17ab13eda3433a5771078f22caec918b200aa88a	11811
1251	f3dc313112d2510cdc1cef380bb42fe2732ea48c9d0c61a381dd06715494c69e	11816
1252	86282c28cf812199a4a00acebb216c6c3a6c41769114a77fa5aa73b76a50d12d	11826
1253	e5de1e9a8b5243f24a15afb1472f048f209acb5a858c9bbc763d09d56aeb4c02	11863
1254	2ab6de7d4b6063d48bbe72071bcef67379e89f25fc18d5b0eed090d38e31dcbc	11886
1255	7a8e366b3870942232a003ec2995bcd20c6b3c43841d474a174b3873679fc68c	11894
1256	344d1ec56b40c442d620f6e44e53f1b9ea19f64d0b876e5438a0026fe1f2c015	11897
1257	90dcbd1f8772954cdd8c4c360bf4b72dd0a2aceab3247fb2405bc69441b07c3c	11900
1258	693b87ffec308ae6682f6668fe61803d7ea4d9d900fae0e441f8786513aadd1a	11903
1259	bdf4571e9ebe27ea22b0bc3899d8bf44d7fdf5486367bcde768b086a00a7d836	11936
1260	7127b93ff13d4f12aa03e7f81495f3b5fb49d1710d2485a3b4b9434c6671385a	11939
1261	2de870361bf7eb44960f283fe599839dbec0682bfcde41316f1ec24c1f7f04ee	11973
1262	f2ceafb81dbcdf9ee626874eda750b87f0c2bc5167ae06f04e4ca67593386af8	11975
1263	fec6233d1d0dccb98e87894c1e8d6ec156770bfaedf5cd272e884d09d58663ff	11978
1264	4fbea8bb10175d18db6d3c5fb91f7c41660bdefc5af22a0b6f6621094df43c1d	11992
1265	a2a3cb307a56941a62e434be6c627bd5f2f8c4406bf842a9cb7c5a850e029e7e	12007
1266	c70fed1bdae9282e8179af95ae12bb6d123c02970f1227c59e388310ae57ab31	12008
1267	7df836fed5274abc27314da043365b68239cb3705c6e89163986729fe18ef234	12013
1268	bf5f3f31b0862ad6f866d677d08c24936199d227610c763e86bd637bae430f10	12028
1269	0c38c28f447eee31de278e8339359debaf680cd0ccd22997b9c6adaadd9301d8	12032
1270	f16e89d73b9ceaf830168bca4cf265753bd6d901f27a2220d6e5200b99a21373	12035
1271	0a743388189d5ea70102667d8e8c4cf7eecdd46e036c924f459e34c07ae5e000	12063
1272	d2598aea4b6956393c35b4ea5dcdf925bb7837a96cc536c9c5ff92e4d4bc2578	12076
1273	03b47e4c0b59aafd146b425f4f6b5e96e1b6c7124751a541e88fa61d2bdcb58c	12103
1274	213392b64f854281655b3523a4d69015d9a851bb189fb0fc04364e03e5992529	12112
1275	04ffc16e20ad91e513e6202ad3a4e276de692be8d5d60fdff333637321af9847	12113
1276	79ea9691cf07e4d51ee7354cde1c4e326f454018cf247e1f6c7d850f335d81e2	12126
1277	0659a9237597ab71cd84260298cf7df2a6140d9f7a11c1af862b712fc2c11a04	12128
1278	3d60acb630d3dbd6037298f6047e6990da867579b89ca72503101e74fb52e6c4	12141
1279	1bfa4e59881efa341a5e8258459119fc5d1917fd89963d021f24b163d823a756	12142
1280	8b1e798022fac2869e224b716a7cc81c66114144cd39c0ef15e6618a2629605e	12146
1281	44538d58a13fa2c83fdb37d3c8478ccb41129350197c5cf3ae8aee7b54067927	12151
1282	aae4ae560e65a4932bc4b7225ea5d408fd5f033182425a0864478d467c958ddc	12186
1283	ff1c50ea754031596284718cff3e490ed2a8efaa2809ba1e983518016fd58725	12187
1284	625edbe70bea360f4e83681c63d696860a0f420f97f0ee6bc871bc7b6d20292c	12213
1285	65f16ad6430790f9ac900851e9141fd5e725721444dbe85f3966a641475e3914	12214
1286	1232a6954976fa826a6a1a5729f42d3e588f6021b98fceaf12bfb18cf25b7f3a	12247
1287	5dd75d4238be3868901d871ea6af1a305322b5d78fb956fd6c83c36db075b83b	12250
1288	18afadf7f2c3a3df8b1f31f3e986aface6627f9da8fde40d8e19bc75b44d533d	12277
1289	77a733e0f2b6a98560e8a710c92a50ea393960389d14fa27b6c5bce3ffde9935	12287
1290	b6894897fe9f0e115640333360e484027b0dc24e69c75ab8f6251a280a3ed38a	12292
1291	d2677c4cad4572b73f1e141e30686b6299c433e4c59fd77024cd8b90d49e8baf	12317
1292	ca89f040b859e0526b0e6268cd2429dc80e5e35d4d657381d59342ccd7f7cc09	12322
1293	0bdc4541eb980d9e164026994a1bf470b2cef4b9e80536e6a1482e480748c807	12338
1294	35fa124beaf4fa67885bc54647717e058638b77536fdd43815ea705fcc0d5fe4	12341
1295	09df53f3b24227f4ce8cb7117712803adaa0ebee34541218adcdcd29ae21b96d	12343
1296	8522aae33b2a25e8e15ebf4995e184a72725387e8d4cd90c59e34efbb6597b76	12353
1297	76f9bdeb57703842103f9afda5d4b6063feec0ef0dc5e637f8aabae5e34d1b5b	12381
1298	4e7598c49a4afc555c8536395d4e964dacf696a291cfe4304ffee7b2e37a7cb7	12396
1299	2f251d01535ef709b291e286f9ebb805e37f530ac41f730b7bf0594b7b390cf1	12401
1300	b60dc020aa9c3e69813096d3620a3561ccb57e13e9237a37398b6c3976818a60	12404
1301	2961508b3173b7db618227291e869a9f92a7514aba8077776e441cb8b5471fb1	12407
1302	dfc1ebdcab617d4e16c77dc5eca0046f58e8687c9e48d9da5f58ef771d6c3548	12418
1303	53816cb6a7a043cdff894b5ea8bb9e3db8123edcaff3485dc40c2669d0c6b954	12427
1304	854ad9599cb7028c586dfedfa9bc342655163b1a86f5f85858a6b834a737cf03	12434
1305	6cff50ecce8bc13d4482f3e0350892a12b68e06d232d11ee0b77bfc3f8566899	12435
1306	70832e65da84d4d4fbc8deba0e87eeb87f8ce9773dd91b1791ffec8d616830b1	12438
1307	3aab35e0072aa241a988564fe15f8e3265c62b61511598374f47550b9367b7c4	12447
1308	26684f4c24c9598388eb8df03328b97bb648c193bfe528af91b0311f528216b9	12450
1309	a4da35778f68afb78fdceb9f3e565fe8e951ac51e1a09398eebee0d1f118b6e3	12452
1310	094717cda6e650cafcc7f96de7859cf2f7356b0503dce5039ecac391488095c9	12459
1311	6df08edba2e19113122c23be399793660d36fdeb810191debf300fdf23b64e28	12461
1312	cb6409c2d4a7c972a1d81dd745e3fec952f92292c8fb641def2fa383fbd79df7	12463
1313	1bb57858e1c0f510cd4dcbecf4b1113ec9ac5aec639554dc606b75dd2056de06	12469
1314	a3ef9da3d6879e1e0ac8b8c796b4a624dd24d7f172d73e85a20fbdda04b6c1e7	12482
1315	b86d73be0cb4b1ebb001306b181644513e0112b02504507e9bf403104c0c6f87	12488
1316	a85e27a4425249b98d99d1fc93cac39969b424507a029a03a2f186871faf871f	12490
1317	586b33bc0373fe7d80bf2923126f5b2b82cc17454af6300bed422780eb97553b	12502
1318	90dc16476f4e3e5388601edf4657c1660e8eda616c7d91930fd7865446045e37	12519
1319	2b5040672d5435b383e1945762261bf50859e178ccd9ac20ff7aa0bea879c109	12548
1320	30cf1fc7fdfa029c7fd5fbc52c6bc55494d4baf65ec2d692730c4d5bd3969749	12555
1321	a6d383f9d513098d7cdf5791cf72f7ce3dc085e3737b0a85c536df13011c799e	12562
1322	eecc1c49500e61d5eee7ff927d5046bfb139920ad49f2696d8f33da263c41d0e	12583
1323	ba5f82f08d03bb11c293a8d4a5c11a9ff39d94ed3070f684ff3792d14ac38e52	12585
1324	e2442cde261db3671ad9d3194c8c01afad2cd04767c837aefd36e9a7b8afc803	12591
1325	bebc06f566f2f90b17f9b349409eb0768fce43d934d050c96194ca2968bdfd41	12595
1326	ba8ed80c6dacd667c36460cfeea4ab190e5df1a7e817f862920473740ad9e35b	12596
1327	fc430b7a1c07f1a7c0b2c1f59ed8562edc6711d7e99ffb1c58d7258bd733603a	12600
1328	64580688a6d06c0c5608c3a604510374de3aa7a49c1459302fa6e6b9a46bac15	12602
1329	12968b1e1e0eda770c688b56fecbe1d43aea005450c6363188c20e6b3be6e999	12611
1330	8ad54f2e4946d4be5a8ff46df54db503a9cdbf5fc7f4dce89a7fd411fa1749e3	12613
1331	e9ff95bb6e2431b1a107e03946598213309a5d6ac31f97dabe1a0ab2af1a9d79	12628
1332	016b670abb3d64cefccd06df155b34d424f063e901c0610fcc99fc27889c4f39	12650
1333	1b8642fa29dfee18c687bc95e1936280754143d7e83abaa04b74281c31a75436	12659
1334	09be57b2727f2e6de2cdb6159f90b20e1344e2c0daa56e5fb128fb7be0e83fd6	12661
1335	cb0602b454cb92e0116680c99ed18870f42298aeed36f445c468a6caaa191d55	12683
1336	4b40fe789b93ff4258ce849f0796ad8f7c832949ae800366c0495cc020d53d8e	12693
1337	cafaf78e9430771d5474ce938fa9da2560c55e3f926f3f3a99b8393f26c5c83d	12694
1338	4c47a745f1abb3bfb3b1df8c99666361aeecb3b51e8bf7f226be1d9d3a846c48	12696
1339	b6a41abe328bf71c1eaf47008a56939a4d500a87f88a43e6a5dd9187cbe82d1e	12702
1340	2f7b212120ecd8cbac2c2784e6239aeccc3414bfc7a82e623e7e46b274dba0b0	12718
1341	f06a4057366fd98ce36f3b9b233dc74aa2035376893546519a8b77e32a5d5068	12736
1342	f04fdf2faef3b02d57e6a9d482602f3bea66726b8b1045cb81e3c23fe7b5c575	12742
1343	817a8def1b3f89446ca032abb4406558bfb2f996b36caf0418369bcd7bb198d5	12746
1344	c06743d9ea34568aa8dc10f137d424f930af900e9733187138cb9681472911a2	12751
1345	3e216caaa819799f0b36afc744421c83b2e3518f45fe849d89b933bb316acde2	12786
1346	597a2bb807ecd7f929aa026782176537450498ab85c52b3c93f7939b8e78f8b0	12797
1347	281653fb10b8e1527f5c66d78fc69ee1781149e7cc9ea0cf99fb9cf76211cda6	12810
1348	470a66db2b0a23b69d8c145a1fbbef6d7ec0798e7578b059df05cf2e94c09fe5	12832
1349	5ea75cd44f032e2afc68d508fa6beee9f78cefc91440630e50c59cd846bf64c6	12835
1350	524638f5de6b453f9f1f7fb4f9fa0e4c67c74495896edac13f8c775acb2e41a7	12853
1351	d18b714c0304e56c9e9de8196645cfa64e504177a6a8844c12a755b78f336701	12858
1352	6fdea5d205b50650659b6543327cda504707f1a29b51d0b1f7f2ab52ddae58b9	12859
1353	c06440a43bd0b52317e3c24603851f5b551e02d85eae07107671db5cd6fc622a	12862
1354	c2fee47bd6d33e44a900bda10f5cb690a361c6478366c183c1bfca6c9e93684e	12863
1355	e0f2f30fb8b5181131bb4b726d92329ba8323fd898e08b337f395a3403feef4d	12877
1356	e10c791b85964dc28e7536e7a59880fde07c3c3756bead62a88727bf7c533174	12906
1357	2917964591faf335dba7e9a6fb59ee90705cf3e1baf64e0fbfdde4c90ceeaa2e	12914
1358	a11745405670cb7056af14f0489589949762b8ec9792fe71ffa52959e7dbe133	12977
1359	068fb6b9209fea20ebf6762b2ac4adc099bbed919931e5d2cdb785cb9aed9a23	12996
1360	6eb7b4f327b0454f1a6e9a5d6ab8c1c1bf13f1ffc0fe4d255c51243f223409c1	13021
1361	600ffcfc0a144dd26623edcad5fbb045f8c403974578e313e284e07470ede085	13038
1362	f5523e42bfc52d86f2927b9730ff2e17f670918b93c89d34f44f97c1969eeca9	13042
1363	9605a69ad1becd1e32246ae24fe39f10d3921898ade0c3e81f4e5d59ae21f5ca	13058
1364	7bf1edb2801e7e3af3775acf5d3372c2ca51f2679039547c99d6ee30f172cd3c	13067
1365	5b0b76c883a8c5ab8be613bd8a1cdb3746f3ceecc3181c5f8a46eca9c2e4ef0c	13092
1366	a679206403a74a9bac0943bd11bc81bd909d5e4a36b1c91fdeed2907b40a9028	13103
1367	b6392186892e16fa2c780c12dc6af12f99762d416cfafe4bbd5bf6522ae787a2	13108
1368	7305fcc4f6b278f59d763a750aeaa09cf7991bf293f8c0a0d09d5042ff2f8b65	13111
1369	94eb5bdd2cf15c8efc8a76d65cdf544a781bf9bc3e52504858f6ba55711a4285	13144
1370	83954cef702065fe2ddb83e2267296f94db6a7364b51d7e98e5696824c9b069d	13150
1371	b8b77dad6dcc5700be19d36438bc4096ca6797db43d6b0a33683399f078c519a	13174
1372	61e4e31b1a922509e2b5bd9eedb526eaf9191b9a9de8646debca240f48f84020	13177
1373	a666deaa27fee80ace0222723a77846ce33a4f864fa9fc6bdd77c03e98ffe22f	13181
1374	3466f8ffbccfb45ef0bba64079b63c866782e5e2fd4398dd275f980330ed936d	13195
1375	af4d1cd8a6baa091d575b0b728e84d843a5756a7cf30ce8158262e6521625828	13205
1376	cf621a49c0a9ca16e9a7863c3da4b139d93ebc7f0a8a4d4006554c9a013160ac	13210
1377	91b7207527d9be82ffe7d9577d0d9989ac29d075ea6c274f1164958779ec4855	13211
1378	a890182a551c34f1d222c5c8216a21338c9097bb25971438a11bee39e5077814	13226
1379	abee93f6ca4337de5e38a6b41b617a50d6b8a2c5ce3b1fd7f85e23fc59b0a169	13234
1380	939330da40680c3a7ea61723728d8971e81d0681c7401db2a1d8f0c428e7b674	13240
1381	1492fe05caa7eb321119801e5d8f1f938778e2d897f2a722b4c9b99b886b7dc2	13250
1382	253bcc3a12d52564097b77c1b83722f025d791574bdd84b433a0e202b52e891f	13258
1383	6aaebac5d69e8e2c633cf2da6f8d5f7e7eceff0a6b7734fdcbc3d3696b927848	13262
1384	a2092a51b36dab392c65593d273c78118c3a0a21c49e27ab71cba85a64d3acf2	13282
1385	8d86f231565b84670e4497909feb56db57ae9d75667b43441dbc761af59023f7	13289
1386	2ce7cc8218150e3fb71970a1fde1d06265f7b3195714169deea7d0639eb8d51d	13318
1387	a956fcf5b2ee38ec82d5aae93a21ced6a4a4346117ff62913f19f6aff93cb631	13320
1388	6d0699efc7fd591bca7288c94178a73da4b132615a730a972325fda6437c592b	13326
1389	ed40805fa70686aaeee799ce66fe5d5f4bb85d6203c7d9e220c42ffa3fc6355c	13333
1390	61712d58f27bc30e743e8dfb528d0f1d1a2bd096b4485040b2bc14cd731a92bf	13340
1391	16d46715cf5f9d567b57e92ba9b50b932bf5a835ce896c9f73b5ae5a8bcd9dd2	13355
1392	a21957ff50bbf12ca854e09223341f03e926aa7496f6907fc2682c7c8b384e73	13380
1393	08e143da8da7f3525e16e88246ee92be0dc7b8e3d53a580c4e829126fa6de98a	13383
1394	e0207b1bc3a59f2582274dc10f43dcf2b397016c159cd4f05bdd75678a36251e	13407
1395	057f8788209e8e0999d46c7a4c60c204fa123e2c4bf0b77e03b238642c72959d	13441
1396	4e6f79fada0ff8e360290440b580d27c7ba108b3fd362c499bcc182e0d032bf9	13443
1397	78a8d38e3814af820e27d8f0524be5af025b4e6fd02358e3b6bb07a9973b3af2	13446
1398	a1db88e75d0b0e7cce9e7b38c4ee32aa0315b601cb445c63f6e4561bb9d8d244	13464
1399	82225d66281d0204dd05b6e8d81be623b918ba757a17cffdcd16a7a3f3ad414c	13481
1400	178cdd3ac2df82e0ac8f09d85fc735aed8ff867405aba663410b9d73352651b6	13483
1401	485582e9841b91ea8239765f7e93c436b87a9f53c6c22d89d3b1e157f6c38ef0	13576
1402	ef30cb4266cf6bfafede77f8df03fdd226f94f1768d747a3de6a6560662d5f27	13578
1403	f8259e8a3e3f03e433db89318b2a83dd1fd7fdb24d120784e5c61a28c1c148ed	13597
1404	0d266e24b5135dd0c98e2cd606bae030f377bf9ab0a657c5d5414717960effa6	13605
1405	9dddd8d054385ecee4178320ca3e12a05d4aaecd148dcb8367f2ec94847fb39c	13642
1406	da1f7e4e559eb9ae138119f4f09374cd9e3679eb849613f56f1372d3e81f6abc	13643
1407	41cb6ae3491c57f45e69bfb2398fe515a9fd969b8d55c4c517916bbd81adda0a	13651
1408	2197fddd943103ffc427c876db3b59da1956ce35bfb792ede9c35c7e70d60d62	13660
1409	d8609756f5a0355a326f60e32aeb93f812e38aebda41e9bad79ccd231ab377ff	13691
1410	4a5444d40eadad57fc7202314e09ec2846ef506745e0b7b9ba232ad9ff8b6fd9	13702
1411	6f22e76d5d24c11cdbcf7bd51f3958a4b4c27f1fb5872da1d0c584be3091d2cd	13706
1412	490b5736b801a5d42d111662cea9fc95dcc434355d45810ec8396c6b52879837	13708
1413	75d279e1ee01f537c8fbb1509a6138996635052e53f895fa1c8633508628774a	13711
1414	da8dc85f6f28bafd6aa58520e3abee32a318093aed17d0487ad3de87325a8104	13715
1415	cf0fcbd69b827fc6b338496ebd77c5581c86ad89019749131fa16a34218bd3d1	13736
1416	0ca9f9b2dc4fa3f67bb31470b9c6ad1a3349d8506e3df1a6897d7cb7cb84e5ad	13746
1417	559fdc956666d85c38b82e41e5dbc21363bb4e618ac5396fb2d38beb795b78d3	13751
1418	7922e3f74a889d94d6c6a786f44f93b9797bafb89c6bc00da808d413f3758ec0	13757
1419	82589d5d468148255562b06768de0bd6969b1e4b698bf26d5ee5a9c758da55c4	13760
1420	a5233b83bca50a95d4d981996b9aabd2396d8763b32fd032b58f4c6bdcd710e6	13764
1421	24bd0393f65a099ed9e9e9d39b2a3d330263e03742972c95505544d20ccaf277	13767
1422	69fa8ccac94f1b6ee16fd573648c5781f8a9357ea3e46378f35f6913c8600c9c	13773
1423	c37939a23930b11a5973cee2c4ab10d190e07dcef74f62eaa6545a8bd9602b52	13774
1424	a23a7065de247efe45addd19708ef5497d803aa51798c7043d4a7b06ed6f7a7b	13783
1425	e3f03a26b49f325ca27681191c6c1746af88d5d8ca5520ac8f49f5f5bef73a03	13788
1426	c8a8cd3164262545f8d649dbd461313ce2261c46d3f8110efe1ab4d6e7f6e457	13802
1427	2610017e5a4bdb4a843a410a0a1df58c9b5080b7f0bee3ec3ef0176877d9c782	13809
1428	88a1b5e248546d34c22acada9d68422250d36fabb993f3c032a1ea1c6e9cacc1	13813
1429	4a7150d16ac619757076193922934a1ff5b86945e9f1e710f3c73193ae1eb0ba	13826
1430	0fb13f89f2af287947969f47b9ba46a18c194510fab23179285c7f040b897b6c	13830
1431	65acebd5ac5f0b9923d918a7c128e68df1f0c322cfc73c0a0307c9b0629c3d47	13851
1432	09b6119b582aae8685566f46e9afd835739f0dd47f18412342cecd33df067835	13874
1433	effe74ba2189fd9d77e2c50a27ecb3cf08e550befd5ea0021d0b42cb242db305	13884
1434	6a3f010fa767f948a55173b332b26bad705a631c444d0a53c2489e22a52993eb	13892
1435	149f9c92b1234193bf77f1bc2dfe5f486cb3ad04d9c961e52856d0218428a579	13898
1436	ebf2b9e0bb1f4ee78af3461f9b5ae860f742afddf31b519f84fd1863f1eb952c	13902
1437	8cd3a37deb7c642ad51acd42bcacf07f980a8b5732d730887b707c03964cf0ad	13909
1438	a2698f4010328384988acff888dbf7de0fca03b1f7c1940704c7ad0771d024b2	13914
1439	94304f3aac2f340cc09e816d1e4c3d96a34356f6d19bdc8c467246aad161d822	13916
1440	cf3db18225b4a5a3cd9d35b8b0cbf3072b9f96d46dbb1eccf53c583da2be9db9	13917
1441	7cca6992ced887699710462c31da468ff483add14e4e258abdc774d655076f9d	13918
1442	8eba6cf9edf1b8bd4d371eec07d576c1e2446cdd290735d7096054bbcb131df0	13929
1443	700cc6b62f67a2b092d02ad9af46670e341123200d7d624af1bbc9b1d0d111e1	13944
1444	95d360cd3bbcfe4e3f9c5a51dbce95b0723c733e04b1774c29d983818a1e3b65	13948
1445	7e71e679d3c0cce02195f08b85b002fb10fc249c2a1686c78921b42600a6e21e	13955
1446	01e7f4ff24a71bd991bfd3a425cfad12301b83578b06e6983bdf4c6e6f75efc8	13958
1447	3524c138a52e306f568ea2117330bf2ab223ee3e31520ebf152f1b0566bbd4f1	13959
1448	777faed3f8e039928f55a7c628cefe42a27ca4422c0da6258884be2729dd3598	13967
1449	ec0d769dab1ff4a3934b1083631950a970da5e534c72e81a20472a276ac22479	13983
1450	b2938e7d64d3cf12d60a269651ac7f715ba690f86efd168e10a923a184f8f6da	13986
1451	6cb0bf48fae01dafea55661819a30282a92cdde05fca7105cb29c0467dcfecaf	13988
1452	14cee1f7727dce5b0725a167f1cc76bcb45e4ae49fc66695eba6e0cf39ac220e	13995
1453	9b0a4e319003cd1d3cc4a3998af59f662216a579a0546b6f9dd0dc363ef821aa	14008
1454	88eb1a3fb38380266fe0aceb975f677c7e577dc015a2510fb1866afc34e15806	14018
1455	90d73a15f175c1bf5c2010134ce05c5b893ba611064d3556a946728ebdaa582d	14048
1456	c80fafafea24b1658eff605124a58b9ad08e07455572e40bb82084e2e5c2dada	14052
1457	889dfe0cd322ddcc3355ca978f82f56cd84f518c837b2f9d253db582685baa4c	14083
1458	d2d09f6db4a4494f894d73edeb9f84aa54bb0842fe54989e51140ae2287e6083	14102
1459	83a08181c7fef4faaa5cebf5e1aa74a0cc42e7bd97246c139d831035bf35004d	14103
1460	e26da6cfb939bba60ddff8fb96794fa4379a62900a8a4ec9fecd8316ded863bf	14113
1461	7a651de944b03b39093f71b8477c030da95da8c9c779f6d64709ec197ba31ed0	14117
1462	dc06b40765dd582001561c99836d0a8793c00fa578cd3bee9bd62e97654315f9	14118
1463	093511b9f296aaff073e15e7df88320c212123e2cb2799d78fb65cda216475c3	14121
1464	670916cdc96a2322140a6ed8902d35aebe4c83c309c32bc80a08e3888e712205	14127
1465	6875ea32d43dca3da48e19c30155cc452a58f43bf3099305ccfb5ce391e1a85d	14140
1466	eddcd5e7ab14cdb62c418e498765867eb0c7d0d230c717cbb76ff279c3417dcd	14146
1467	2490c9f77bb016da66a06628f8e903f2ffe8fad2bc3e6d93dd447c710df7095b	14162
1468	c13a488e73a0787569fd38f7c2231c4b907d4bf0ef964e38a10cf7922f0efb20	14169
1469	d9d7839eed470d760c991c15198091469d512324ed5fd1a6037c843fc077a2e3	14172
1470	319161ec88396ca5dd64552d921f565afd07bce9dfeb988a9245bb9c1e3bac91	14185
1471	26ebc6245130eceb60549639ba02fa8c57083c5787a9c62054aef9dc6ca00fb7	14192
1472	a95c07bc031edaca2e2739a762145ecdfaf41db3cf5eedd7130b72c3033b906c	14193
1473	acd33adbe3b1818d0f647ff19eb2316395e2bc825c5c61a002f4c8848d585eb6	14196
1474	af6fad5d3ca295e7abf0a1de9e91163210b4b8dd5cdb19ca6daa9b69992954c0	14198
1475	dbf93ec5fb64482f252c85537139ed57e1e856eb2fb9cbb269505cf346f7aa08	14227
1476	9f6ba6ad429c535db36c46d488561371b86c6ea4ac6c74c1676a2d3189a3123b	14259
1477	3800fea0a45bc316a6dd289c4dee185a17db960d733bb03f18fb03700fa93487	14272
1478	22e3dd00a8c79168f712c4e074d36c2b245dc22a509de8594929d86d5d24e885	14285
1479	4fe8b6ddba949cef69333771a0bacf1140c3887ec26eeca532a86e63b0a381dc	14292
1480	5b756197284f4c8fc06d9cd563134e3d80f44a055419851e111261461356e56b	14301
1481	e77e308863ece402a8ff99c47ad211fdd0a94430c9a20bd5b7e37ef89123cd51	14313
1482	3b04cabd466eb0059261c4db8388e6c9a06d30d6cb1f3a71f1599b848861dc05	14318
1483	28a660565cfa344efc02edef912c3fd9381c6d3bd8caa5bd4c14f78e4d578096	14342
1484	ea53e15b19565c70b5a4a52b84afd430a8a68635237b8a2b9fb7fe1836d6d36a	14350
1485	9bb2e485b807ac1630a3496fda864e2ac9a866dc720b191797b8bd5d092b4f7b	14361
1486	49410f5e7303530ad28a39382cfa36f7be6315cca00b3774c9cd1c4e9c8c9ec6	14362
1487	74eec8ff4b9d7483c41572a182947ad5e6cd21f3c59ac34ae752647c99c07b1b	14379
1488	ea4106c4ddc0bdd58299cf851329151e36da5526ff8da3f45ead6a745a39e9c4	14402
1489	047d9f559ff7dffa9466cd1d2a10ccb59abeba4065b0bdf18a68a883faf33bbf	14406
1490	0c7c2c740158ef90979d7379ce66ce781d9154b9fd62376b66f4d4cc4fa27920	14412
1491	9dddd29f0752dbba3f35effae3c54524a98735b6cc43a1e1f345f7e5e86df9c7	14445
1492	78bc0ea4097cdd778cc474409da44df03d2c03a01e05c0f083ad3493d9205547	14446
1493	9099350e024c2e1b314048e91daec6591eccdcdab8c062043ba411548cc45d0b	14486
1494	c72aa8d8ccb76131c543c3885b9567e4af5605a54b101e15b539bf97d96e1ad1	14489
1495	63f79be8188b116374aa894d90548a7e988971f95476c4c4903ba3f76df99418	14492
1496	29c7d0d92c8064bdaaf88999756765906944fe56986cdcf8c34bc7cb7a375cb0	14494
1497	232dac462fe7d3f920dc9ee204eee84765d6f52f3f7233cc413866e94d1ef967	14499
1498	5f8ace2d0c13d7676a968dab7f4e97c3c820e70d5316a011e226c119e190cfae	14502
1499	cca6becbe7a97fe662f8343f4137ba87e9036b038a77c560c12b7ce7afeba88b	14511
1500	792dcaeb270a028a09569ddb92b65716f299a2a8ca455c8915c50fa15b88d5d1	14527
1501	4c95309cc231a713439c6ab32eace48ca1fc191e374c722ea3fa613d017367f9	14529
1502	674ca6c4154dc03ec28a69dc32ef8d8eb4009e712ab32989721e0e42aa4ec3fa	14538
1503	734b236987861a001dd5703c8b063531d5af944929208219e9e77a4e244fcc76	14542
1504	e4f7e4792ee9f9397db1a50f66a8e423eb67e3a924e1c88d37160b11d4c0f7f2	14555
1505	96a0ab817b6709afa97434c0bdc5baa8acd8cfbdbca0a6c14e5694addac2741c	14573
1506	d9a8a4845b9e4d4c34198884ae29f2b879b326cb8f8e5cb78de6b5642faa8f30	14593
1507	8b4c88267b302dc526f2d3aac7d2444ea6386e89d2d03d9e7c0a1d8afde2c14a	14611
1508	4ac2309a3d81b1179924faa0b89dc1e9e8b8b08309b7e07b18aec29c3b4ef379	14618
1509	4d2a8bf7fa45dce7f7f58771b8fc2d54d5aed7da74db6efc5020e8e91675b6c5	14619
1510	155a77fcbc9680736746bd3684612f52c29343310807570b0eab639b350ea9bc	14620
1511	d843d33820a72894a498914ed8574bc62217ff55492d0d18e9a2290743a8320c	14626
1512	8607c0f302bc774b6922006af4e84063891a41b269ba2ff0145466f465f02232	14630
1513	46edf7e24ad9fe6c48aa75e5ae39c52f70829d3a95bb6bd449cb43559966bd06	14641
1514	ed765ed9a9f1f4f858324f539141a0332cdcdcf4f044947f22566af2d41aecf4	14642
1515	39e2f5ef1fb55ed0dc69bf6c54fc88beaaf6e36e80af202145f2b0662d9bed75	14645
1516	651fc01abee395b6b5962e6921b7e99c4ceb83054401573b4674bd784c590c87	14662
1517	0abdb3110e8ac1d7694040cf2f289bbe65e4dee3651984f0f05fcdd027a8d5c2	14663
1518	e6ebe97f99f69f195f42de09cd8255afd440ebc7b507573acdb016f7312f1304	14676
1519	589f36343376402fdf97670ae876ae4051dd2be9dac5a7a925c41542ced8fb86	14683
1520	7eaf5f9b5bd71010cc7f2e1f2c0809b07ebf4e0820136f9c06c16bb5db97d460	14704
1521	2a20b45cc4410b8c2576507e2797b07851ff9c1696406d60db28f0872cbebbaa	14706
1522	2a3532bfd2033c82155d7d2210ce45b44cd57ffbea3a0c6f50b997c8bc5e22d6	14719
1523	73735ca7176539847a8840a6a63160cce8a7ba0606baa6d55e9d888c0722777f	14720
1524	ea7a211a28f5eae8f63aa1e4ec7d173579b78a57d258ae96b5d334acaa2894a0	14728
1525	f5ea5be848950e77622d647de6675a374c1dbb1f6fb2cabd0c0a1630c2064f86	14729
1526	b42ae8abf74e88581052d47302cbeede73f12bcdcdf8402ddd13641aa364b61a	14734
1527	ae64ed98e10809942f8e93a6996c5788a3e1185de142c4a27efd527ac0ba46a3	14737
1528	82e650b3f737218e9223f714609ce1a8b97572b14c5b7549a3445837b29081c8	14738
1529	bc751e1b12f59fff4207b1d62d03d535279cd16e730d9be12d34bc10b4d41e0a	14745
1530	71a925047ea230d1a92e130ca415081263c1898b73db0cec3ef367ae121139c0	14762
1531	4faba3dfc9a2226649e824fd3c0304c1cb3a1bf593ff651a60c13e917b1a594d	14780
1532	d31580bbeb24916026111765d71b13d2ac4d9980102d543a25f516534acbf968	14812
1533	b2c508637d99ce5bd5a49ffff02c1597708190e407385c206cb701863edc5e4d	14853
1534	75702e7c988775218381f5e2140b1835f6b4478babbe5f35231ad84caf18a625	14864
1535	1731d686ec348205870970e077f8774525667a302534bde940a500df8f680abf	14865
1536	aebadf1bd4f21e9d1fc853aa5810b4fa28c3e44d00dff985d48c6e1c25acc703	14870
1537	12dfb1a9c80eb3b55b144dd1e136ee8e97a9eaddfd02c4a1a4f61265017d672c	14885
1538	9c2c782b565c2e38d1f7290ab9af235477c68a8d5be58c868f1ee46ad819bca3	14894
1539	ec6fc165193f4dfe58285112a709900accfff9f4c7957a65bd4850a317ce17be	14914
1540	cbf81ab56e945b13da5edea1149170433ed1cbbd42f1ab5db3c277ad057bda0e	14932
1541	232768e7501ee6c3b2ad399b3d5ee898478716cc8ec3d56dcaa9a055bbbe8516	14938
1542	6c3dfd540ba4014751ec91656aa9d5abe78a0566aa8980c495ef2fcf34231a17	14947
1543	a7f4a2d2645047f0b66750d990f2cbf066899daf3ab8c45f0686bd0a60c0eb55	14959
1544	f57926e88508394607a40955b94b51f61e15d2e274b167f9f7abfd306bf89247	14984
1545	b1ad5d1b3d48f2c8cae7a5362675536da520d65e7490d25272701a5a7ae90ac7	14989
1546	a4cc7b114ff48b0c5f96f362d325630bf120ec1509013cab706d3095a8677656	14994
1547	c90cf48e4d9b46200f53a745c9a42dcea3d9fb61267b321c5bf5bb8f79af1e92	14996
1548	d9bf8a074f815d788b86314487b44068e01070505d21a73a1bae3f55b90dc217	15002
1549	f22d86510ea1a13bc976c31e6a5f408b16abf444346509bb37a0271a6322c765	15014
1550	2082105e7d130c6bfa0c06970827fa88955e76eada4a4e45dd04e750786d20eb	15021
1551	987e5a3d1bb08afef3b2854ec87871e901f72b58c041c46e1fbe84472006ae0d	15033
1552	0bf03eb633a7bcad2f56ef9afc8a3c4e1eb4a4df5241c5e03f2a4c2340720f28	15039
1553	bca866b945b7edfb5ecb9eb8e71e959967f289c5c3e99daba3a6472a8b8aa067	15041
1554	be586830cfe42084f19402bcadd5bde4a8cc736204ea4136ace59cd799dbf382	15045
1555	76f401eb71dcdfa84d4320da8d81c75c1d2c7b5b29f23ec21b6f255667442513	15076
1556	709e4e7e4dd082ebe7a084021ab55cf6dbb3bc84a2ff048b2b446f542f310745	15077
1557	40e587ecb02eeee435e2888ce2ca4110c05c901af246cd667559533c69dcad82	15082
1558	c734b544b208e68087bce1618f514ca2720f60f8966d6d7ed315441a112d9d9c	15083
1559	da5a1e1a4ad665f7cd0370efe46b03c8148a854b9e42625b4f07c3bdbbec71b8	15095
1560	a779cea6cbb90524eba6ae30b748d6ae6cb9c4a7e85eda64a46cdd6a3b3618f6	15097
1561	20720a1b1edeb1f8460984466e58b357c6c06deb0b055e8b323b00d7ec8834f9	15106
1562	8bd03d57627cbce94079a1772785c3045d93eddb8af64079f86a48c24143d53f	15137
1563	5f52506617d5f4d8f8b05212580889238d2b0ef78ed85a8feffb0ffb39898674	15153
1564	6112b2b1cf107646b2ceb8671364bfad321283d449a7ea28fd93e779defb45bf	15162
1565	b51ff8fbd5715b9efb6eabc08bf1b3e8ffea57d8ae8742e2d6b7f55ff02bdcf8	15163
1566	0102462b1945c4797b72d85a486a24e2bfe854e9066ba17a2e53b24bf1e86ed9	15166
1567	5f9144f876cecd5a2eaefbc39f40d6a8255ff53cd8af9a233763b11ad61590fc	15199
1568	3d14dcf39f9dea97d2e0d4a1f15b91fb262162ed07061e0f0c0e95b9e2181ae0	15216
1569	83e5ed1ea309244fb79907b870061335e0db8716af5ff2c8f3711e2a4339189f	15217
1570	989a45ad340bf44566139358d5c3a386068229b22b13bd70205acdfc0a95e886	15224
1571	45787d7bfdbeb42e3e88d011d239e59a4bdc09bc5f2708b7c6fb084a072d677a	15234
1572	a475b2b2b4259c7c5f374bb2c695ea573eab1b6d0629c18a6bd2b071e35dabef	15245
1573	f878c466c04efeb8076037a8fbb3c0b08a81c65ab33b809af18c244debd77982	15252
1574	daff399687586d8f2e92fcd8fdc77caf1b2f7c45a3f47e25cd4f61c9b17c9425	15262
1575	f360756e1762ba098ca4c05da91ab91ce6acb0f2a44bd15bc74af547b257d79b	15278
1576	9b5ea560840a49dd1df6c671cf268bd1540abbc1b44cfac5d6c25ad9e6965415	15281
1577	50054f9c36d0efc7a79a1ffb2fd77e0e9930ca735352c8c260dc651ea21f6565	15285
1578	1fe5ef35364a46fdcdaf8d2e97f16eb93a6c75a89d69485a41734315f220d1bd	15296
1579	9d000fb7ea2998f91cca9b177b132dfa150ea995f669f9827b4228a13431d296	15297
1580	790bfd66bb3f6375252202d9efd570509c41999f2394961fbea5aff2564612b7	15298
1581	65d2b5bb5c81fa4c80e1c5a5d84587b42f7ec8d1712a56c8934e01ed12badeb5	15300
1582	e9eeb30ec3c78337ed9b55f05eaebbc31d2bf1d902db573d54a0b2caf5226a7b	15310
1583	e31b84739234fb052488ab944d3d3a7a2b95d7397085c4ca6fc56f5fce3320f7	15346
1584	fb405b93c60a4fc745d1b1a357848c7dba361cb2d792d69e353e52aa4e73b46e	15353
1585	6782fb9dffea85aa33785d1911264b67cf7a1c344e5e45a5e4f71ed1aea17ca8	15356
1586	cc0dd42d3c67eb31cce9381726a62f626e2a279f2cdabd9329171535eb5a7973	15369
1587	c24178f08356387cb73030afdd14d273a975b2ac741abb72041ed7e3e0a63422	15372
1588	26d5a16f4284b7c9fb7e638879084b8dfc8184623b8168aedad5260b82f08b98	15379
1589	db9fda3785e2ede32e850a267d91146391ef121ff22ea64675aa22e5ee1f975f	15392
1590	646648f8ed79a90f304a3ddadc563bc74ddddbf5ea92ce832780276004255d29	15396
1591	158c9178c520f790bdd468717c466e74b8c11817f53e2951abf1f48231e2133f	15406
1592	e37354a521aa7d10c65f5c205d408eeb93caf69ae5794945004eb35750189cf9	15423
1593	2074f82d88933b6c72d0b65e86256079552343027e856b9e5145fac697fd517f	15444
1594	7e6b42c5dc27e4e4b8c79683f4c1294a5e9c590b827681ff370868420849214d	15451
1595	4c197a894d363701637b208e71102d87bb2327c11d49c0e89cba13c2dd730a11	15453
1596	cb9b3d133b91805fdcb8fe7d010f737a96a88facf1c772600f470d23e1698de2	15456
1597	7a04b7d5d43dacd09f7c665c9539320b5d25c15369e2fd68da39c7900c72e361	15463
1598	185f414d9890bedec1edd0eb45661a28c43789875581b4f0e9745b6de024e4f6	15466
1599	02407aeee72a086b41a516e2d58fcab8dc4d1998b433708aa7a79d6a7ce93808	15483
1600	cfef759f15b16b6ed92fa939ad2984fa911d964fe1bdd0e4b19531899e034836	15494
1601	89dd726afd9496bc84856d4259b41db392bc9f84bbef3326d8b0a5c4658c34fc	15535
1602	be5e74344cf213c45caedb3335ee4ff8373b979aca55e707dfe72453850df5c9	15549
1603	de6ec6e1889772de495ad54e1a3c76d17b9ca9a1b65c5fe604f9547dd44a3597	15551
1604	0f524453929de491bc49ee1448bc580bc8705f15056b9552fade841ecc53a4f2	15552
1605	d21e0bce2e6429edbdab8bb622762c6e0888a17bca60005ea53dc30888f86d8d	15562
1606	586c112a62f851525c931d95da3ad22bbcd69c0bb2a3dcb328a898c93e1d350f	15567
1607	1f3d62e0e79fd75f8ffe71215801c4c616667f51ace3ba2b2e0360f8d0b645f1	15568
1608	ae7aec9d026190af15977c33746221ee20e8efb742ac89b439a4a6f0a7f7e39e	15576
1609	186cc4943a69b6f16c23d35398b5027f7b940aa7077ac5d9221e94ba1779f862	15578
1610	51c6f7dd8bfb87607f652559b81859cf4e72362488cfb1d543d6c178cdb8baa6	15586
1611	d0941c23d4be66f83051a6b7ac2a26f4e0918f4143910348903d7eca594fe4f9	15593
1612	de84ee1d852bc47b1ce69f27cfde428b789b4e31b1359720afd8ca2405484aff	15596
1613	849bd01672650bf2048d2c4c1dbf2605e4af976641b77c26d275cf9425d0763b	15598
1614	3042e11d027e94be9d0c690c6e6102b4db23b8a5046560d418eb93991189ca8c	15604
1615	676b88a48c4b2c44dfd57477ea76bd632466bd300eff8feb132767debcee1a70	15617
1616	7eda0a3bf78963d444c96310dbb0fc5541a09980e03b956b2eef59ba282c0878	15625
1617	ac9d362a13b23ee7f281cc7ace12d0fad77bef5a36502677356f28ddcd432741	15626
1618	6b401eabf77e31689bac2fb734adec3ea87152c033bbef3b8ee2b7dd1ab408ef	15632
1619	35ee2a4f437ad28fc63c2f1579d3b1a1e6ea4a45d2f06c69b699cbe39f6f7819	15649
1620	ff21a93273eb3f85c43e44c1186fa3934c15eebdb5a6e7758a8b4053045802d9	15675
1621	a9cfbefb44f8052d1b3d936b037cfeb03c468fdd21b9238719a31877ce7da8ea	15676
1622	e2c812a243b741f00a214321dd82eb8602c6b5500998eae7751fc9e3abdb1861	15688
1623	bb427319b4bd1ba13fa61eaf79f15f003ba9a1fc858c4c7deeacab2215a7e4ca	15698
1624	4f5613d9dcf982d844f3e33a75edc4809114023e1b73818e3e048c7122d15408	15701
1625	a2e6b23794ca0bb1161409141792be0ecf1932962f10ae3750d4b4d472b92687	15707
1626	757063cf8d6069e9d349fe2746940b9b5fa67ddeb99c1acc2884ef30f18322b9	15735
1627	c1daa2e2ffccd8ccb3622fb1b7b2e06edb6b0e422e7a91a5b85b7e4b0938258b	15736
1628	2910424f6af6ba6cabb1f8409107563e288aed27ff4d94a10df1f6a7a4daa9da	15740
1629	71a4c170b19e92aa6986e59d21f0a7689ac038bc061c9c3d1a7e396bbab28612	15745
1630	1ecc805bcb0b3f665ce50e2e8611c6d154abbd93147444a4cfbec29603421568	15785
1631	09b6222d99baeb42f5d941e4a260e12f332250df5be5e64aea4e825233fffec2	15786
1632	265dfbe6b2048ddddea086a1d737b6e519a7357de1df6ba237e25ef69d93d2db	15790
1633	380c108b297c10fb8a13e091e3caec39547d3a9bc98139e17bbd93bb4b7d3e45	15804
1634	f73d0b9797c508aa71f20bfc7d31abd3f0cf57820cf55e9708765feda05e0def	15813
1635	77f9c4d73a81616ae08ffbade2a91d1f9a60742e37ab13085d4695307b934610	15834
1636	c9657ae81c79653d955a842cc88ab134a9376f7dc1e143814e373ebb0f453f12	15856
1637	4871472cec38dbcf69dab47773a9984bf6c28445048da62f140ee33b049daad3	15884
1638	ec00ecbbb67f997c96dba58002daa28462fb87714bb03b42abd9d6f35c4e2754	15890
1639	0be924132ce3dc5c27aa87b42a40b461703f672f526527627737ceb77fcd6101	15903
1640	de6d7226a8d2c322bd2c626b9ab26d31851a07665da7b9bdc2b6850119db5812	15910
1641	3a723114db83ffb9eb23ad1ba9ad444de525c3bac47b608573d6c5c6ace65cf1	15928
1642	203fc1ced3e455fcafe975d175263677d6c0ab998771688c8587ca20fc9de417	15931
1643	4e218294c754a1ba4ce7cd5a79e5e29be678c8a3f7c677416ab38719f8a573d3	15934
1644	7c193f7b1a8cd4cd997977923f0ada741bb755737bae24bf3dcf77a1def785a0	15939
1645	67b3e5c05473317f2ded83c60f6c044dafc62c4f793f39626cd956e259c2fa10	15945
1646	6f4d243908c2716955dd41635cb902b1fe0c48bf3e648d4c43a871fd9f6a3bbf	15946
1647	24948db7802ee27283cc6bea625026c2d4b0c9f4fa070c8c4c47ab00d62fcad9	15959
1648	192405c032626a823f16cef6a087770c60ba2b49d539054e38216297fe1bb544	15963
1649	197f0f0d78a0d93143bd72450b656747e5ad50dacc4e3f6a5396b464492d644e	15966
1650	5bd7fd3ddcab7bef416624107bea1d828bfff34c518873e55c2e962944104df4	15968
1651	5492f1b728307068dbe4346273047cdaf2628b499029575aae38efe31e4b9b06	15979
1652	30472bd4d3d8b7ca4b703594b327ac5f039ba668dd05b72b615b589f013e6e45	15990
1653	de0889e0673a3b8bd0a2394e82de8c89eb75ee2e9faaf0b3f44717cec4a8d405	15994
1654	62c8d76fa63d4c2e5b942ca3d04dc47a3d0f0bc24de68ed4d01e1f51ae377bd9	16031
1655	78166ee3e297134abbda62df0d944140a0449d7616668181ba571963a5379983	16034
1656	5d67da75aae420e456a01bae287f988227f710f1a7197c60d4befdcbf1bb2387	16047
1657	65332a2079ac2724ad02da827b5172fd727699b67cb3a0ad90c9119c485b92a9	16050
1658	1168bfd16ea8b71cba34458a84a361f3b29638d6cd2d6ae57ac2d156d250d624	16052
1659	350031c94943287e78883d8b2c7421eff68bbed0b6d285dff7c43964cd2294d4	16080
1660	129f3e58f90a2a35ce8cce19ebe6ccb21bce35f11bd285a7896293e9a2e520d0	16087
1661	1835039900da251faf2f5cd1b4113b7844cdd07bc609b17bb365461de567bbe2	16094
1662	63f973b772bf808806fd3fcfb232f5841823fade86cdc5699f3cd70959668722	16098
1663	4fec0ae6a534433a585b4e9126c40555e7a7062c06da9c73eb383b4d74e82ae1	16100
1664	58f8c22a472316154921de9a9f718ff413c21b15f424478f3e26016395ae62f7	16105
1665	9dccbfde530e0beb24879e2ef905b0dde52623fca99a64ed325e83f26fb4437b	16121
1666	19a13c198303bf19ef71ddffdee9e97c07cbb2ae8f34567f8fb96abbc5b7ba5d	16137
1667	c9443c977c18b9c449600561ae868db44f87013c1c7e3c6946dc3cacda3f1df3	16173
1668	7dfe28a8630c4767204e9f1c0223afcb0ac90d4c599a2d64924b62f18aeede56	16174
1669	e456cafdffae058559596b401727d8222aacb908998053704c3f3b69c7013843	16212
1670	399d2925d5f474aa0f7abc1828d69007c3e11d81c0b7e7ca994f540ed923c71c	16221
1671	7d0caef3dd86fd4d9e5ace4458496f9df01bd0d595ef0f645a21e8e50930870f	16222
1672	e81dc8f4f35850b17436a61679688b10fb3b8dc9a68d291e00f07361a6346375	16226
1673	121b93edbdf41fa4bd4811cffbb359e3acd1db3d41798fd7a946b6dc5e5c68ed	16231
1674	2642119f0ef7f93f6cf2b9bba291ed346bb0f9243d1f35bd6164d2c7e5d0af13	16239
1675	0d2ec9b1c7f90c50f4f29162a4dca26a35a405ad6eb7b0fbdac6be6e0b12d3cd	16242
1676	f6c6e2a8b2fab8557f9558496276edceb1ad80661e135b12d1ddd468c03a59fa	16247
1677	63ea260844b74e06a7bf155b5dbeb898cf73443101cfe6100ec1cedbb8c9b5dd	16261
1678	e5ca953bc52a175423e43aeba5cc9f2258f2bc07a087879a46909f72101cc407	16280
1679	30b23eb1b51b45bb64a69d90a8cd782482abf46329560779e2eaa9aa3fa1a694	16320
1680	0d7beab692cb71b1e6126c6af5c8615285cd5ff94d611723bd1e39e6951fc6a9	16321
1681	2daffdb32314318aa1b9276d69c58a3e7a6ecb26a7bbcc3f1c8fbada9b819b4e	16322
1682	0515177e8edebaae5c3386759ad7d8c226e2581def999c1ab0574567d3e0aa98	16327
1683	d6b2cfa63a679c5a2805be3e8ccb45e16314228204ddac14af94074b2e9cc1ab	16336
1684	87450f63a0f0a015a5a5c6aa187accb894d9104a92d5cc50079eaa3fd68c0bb6	16374
1685	54b9db2903215178c7e6cfcced567301653f5b38a9af7209e5dfdd4fab843e8f	16379
1686	abfd058dc606becfe284bac884c8db11c764ef380528e3d9f5542169a1f95aa8	16386
1687	886d387ac062d7726c6a0284ff6b900b16ef12b48059d2c84ba24dfbaaa5d325	16387
1688	4b3a1c90bf4df861a672388ab1587d00cefa898da1d948ba23671488f90bed0e	16412
1689	05c4e54d85993963b909921a19e7b2cdec50b615dbcbfcb1439c9898700f66dc	16419
1690	f03af320c3a9d1be2d019fec19a18be52ef04c82e1fa83a316b4d8cab32d01cb	16422
1691	a0dcb3a65b4c48df9719601579688b938bc364dbd8f8fd45bac1b39fbdbc35a9	16423
1692	7c94cffdb3484f493d517e16bf4ab201b7173ebb8f93ac7b0501e351232e19a7	16432
1693	5a5789966844eaee8933d07e33973fb7e1245026c5b59ca609f3e604a8c74408	16459
1694	139353e3bd697df15bb4fa30d2e07cbdb41ca1f9515a7962d560485c846f9e88	16478
1695	daf506ef354c63fed4ed9349f6518ac8c481689eba8fa640e485d2ee58032c16	16481
1696	732436f346162a95d4bb20cda8eeada69fb24419172810036867ec260e5f345b	16509
1697	2e67f6820ebd50692ac73c693d765b3da3a14357efd316cc959ca3c8f4bf8083	16510
1698	8a50c937f10a80d1f47c546ae60df23669ba3a90f94790ac9659719094e3c37a	16516
1699	ac068708cc03e2ca7bf78d5524a8dec477874f3b29ceb474858247c078bb0698	16517
1700	72ba48929d937f179926ee9c7951d24a97848d139b3f530054fab1d2f5707662	16524
1701	7b9db038ad7a2d0a3ea10dc05be7672421018162a6494d93d0b5a7a5ed72bdd2	16530
1702	e71cc60833d3770b56bf112ff4f82f071a0aaf209c402c6ba5bab973149876a0	16553
1703	4fa08b692fff4cd3624ec1a612bfb2d917ec98dc73666d3d23e8d6abba72aa52	16556
1704	8453a496042e953b536f5ecc2326be632c0727b5e56fe3f6e14bdf1cf7718ffa	16562
1705	cb05a30c57737009dc78e6f7c7837a1e12aa59479731bbe03314c9e867ce9a5a	16563
1706	0bf1dcef9e5d5fda432dcfb4ea98a32a93ce3d869f99937b94c73c88c5cb188b	16577
1707	3cb57defd00635f559e8fe3f25a254caf312d301669b81fc9d75a0d8162b2025	16595
1708	77909845889e63144f151abb294f6c75f33e456af3527d4cd52716a7f295ad34	16596
1709	bf021e0e56e0c97b0814d7544e3b4c9837fa0fcd32639a93c1b48a4c04a549be	16599
1710	bcd29f7b8050f24ef1b7e7bb54066346c89302a8486dc7f040f0daf12b120284	16610
1711	78288b52688bf3ea0e1a2858a1b20b8b37a174aa7806bed83cdb1c15e6640ac2	16624
1712	e0d77e788bcc3033513816ad687c5df85b76914f17c78cdd5f9e72ff1fbb3bc2	16644
1713	f6d885a039d330340d026637de63130684595aad15b763dc56a7a896b4615767	16653
1714	d65acce058961d60395a00df14e58968fa9311974196b055acf97476b858197d	16659
1715	fffde2be10ba1e74a5a0432da3c772db324a8531653395f0cff37feb4f46084b	16665
1716	a8809d55bfe9ba9c4b678e5e5060099b460c67c4f8defc18046d42d5aa160657	16679
1717	653cdbd4adc01fe519b981031ad5cda0c9d269ccaf1a080f848e0af74d5c88ca	16690
1718	1440ea137a7c7fea995bfd83e0e1a6689db7b7a858cfd4022eade3a580277b79	16692
1719	c5c59c4fc8c55a78fb22fbaab530a25948ce8b06c7199a0f306d27286e5ac0ca	16698
1720	a2682194ddbe31180afd0a002986afddbd262f8966b750e3d8623bf3ccdc1054	16726
1721	1810fce9bad2b36449cb7fd4c411524f919b93b93734efb372192d9dea9bc1ac	16729
1722	501eabf196e0a8057c5ab586e92864c1eda06b87fb2772b06662d20bd76526c5	16735
1723	a2c50907139cef6180983ac252f63fd08b6e9214f38147e95834ff7f624fe6ad	16759
1724	447101c51e9ed002f9456540f521406a39b700a779291a822b56bc4385cf2d86	16768
1725	fbf08bae3321af683f2a7fc49192cb40477dccf377a6b555131f5dcc2cb039d7	16769
1726	673dcedc28d840cb95f6a1c12457dcd4b2cb48923938465c9aee28c04b700d2e	16773
1727	43db92f3af76548309480ab1e77af8106d2cf437764f05e1ad76acf083920909	16785
1728	29fa5eebf4cccabed5a4a901cb6f92369fa24b395a014ff06bb926bd0f92decf	16798
1729	3ab52ed34c1ea1f8275d1e31910aa1f91fc1e4d37e959a9fb103902abd74b80c	16811
1730	a02292ced27c09da5e72215216745b0996123c4a61cde673ff4abaac75095b9d	16812
1731	9242cde66ec6afee822ed6258aa50b4a354662d9cbf6a5b7ab1db4686b5adb71	16824
1732	f4d9d87da424d6fb19ba14f8cdafee34c3429b2c3d32877a3387f0e9333efd7b	16828
1733	0b83df359f0196db1d03d0a712def7772985879706a29d78d8bc72a34d32b028	16830
1734	3e48b2cae0b3ad5d338ed994cc82badf7df0954d8815eaacb0bfa244a3ef935a	16833
1735	a3f6efc7fabde6ddaa4ea60ddd56fdd7c14cb0291f5add9c3d55774196f326f9	16854
1736	601aa27a4380d3fa6f23195dbee72866422bb2acb468f720579523f1838bea9c	16865
1737	8b243f13ec6975a66beebe16080af0ab731a22fb1a1f5c2b69151be779f9c082	16892
1738	474e54ced075aa38bb288c72143a14313f9a83867710593d9cf79c50f90d5b16	16937
1739	4a0e68abb5a96730ed6e6f30a2d18f7ba18180c14c315a65d6abd5a59d61fa5a	16938
1740	edcc10793b62a0329d9cace56531252d82ef80fb2469da85480526b57cfd7d3e	16962
1741	fa705b4b6ba7a2be6947802011cb00b2675e1a45b5d0ba2664fb3107e50dc9dd	16983
1742	14e6960274ba003fd7d7fa1e3067b2ccd595becd65a9bc3e306997bd2235a5fe	16986
1743	b8ca6a3101fdb316d52327b9db5dd7e50e60a69a1ed0154ab4eacb998888c355	17007
1744	db8fe3d566acb7794a42076161a668e5f6d6fb80f61c16881d595d923e68e162	17038
1745	a72bff46c5e21055393170d8e3d2697b71ad67adfe8b6c5d0ef81358c974f6dd	17039
1746	2692c2b869881a91e3dd36a1ee719f32b0d791c40d51904f2e4966439a0d7936	17045
1747	5c8e6ccaa5a2c62671c82d8d90865d14de694d73a64e1d15ca3f2a310e715a0c	17052
1748	5281236ef49b71800c52196c005caa85ec951568193725334b4c166a2fb908fd	17060
1749	3a20ae593d1c2195031d10838651ca463098c38289ef68eec404fc705b7c6648	17094
1750	cc7a121b5c0d876f96908836eb88d3a8562edfcb32d8d0bb217dff8076c9f5a1	17100
1751	2ad056a3a92cc0607bc02ebb6c478248b893f9f5d6e58c8e675dc50ff0bf0b53	17106
1752	b6c781450beb3cbb8978abbdb3ef9f666a2b66b0512bbc275f4f5d59138b0a70	17107
1753	6cd83be76ee43fbeb22c6097f28b1583fb9a7e0609ad34650587353ea97a3fac	17126
1754	4f920ce6a17f06cc4db1ca938ef8068b6a993e7ca9c5877ed59a487923be2aac	17129
1755	5d7a9158bda3c65cb92f36a78fb401e6cd2d9927c103010b9791d5183a3374b2	17154
1756	47d5376e4d9829e1419d6c624d73e267fdd6d1501ed1e09a730bfb8486590aa9	17156
1757	20241cfd21c0a47a3a37593ee339db91dbb4580bd99c2d982f38aa39e3c7badf	17157
1758	1f1b307b5e60ef6cc02c09a74e231f791583f4428714fc1368e7a01773666fc8	17158
1759	bd29d8ab780816ebde76114b2000e771f751e8ba23379613f8991a077aa37066	17160
1760	c258603073b9e0b91ef08a956aa22fece1a50920e3e9e7cdc7c4b60db142afe3	17189
1761	a09e4f6b53f744ba46c11ff2f342523851abe737311e90b3c126ea81f5bbac49	17193
1762	4db598248068f242ee1dd96f9545bb50a603b117303ae26785d75769d67a192f	17194
1763	fd1c0d3a9188d61660da3a78ba210af2333ac715c1fd8f01edb742c8283bccbf	17201
1764	d602e48fd0d0da831115205ba42daf53953812c133d04b5d06bdea3aa056e85e	17207
1765	b2add5793dfa464ca453499a82c268ba2e374cc199b4c2f83eea7c9de3f35e13	17224
1766	98d1a542f163c880bf64b3feac84b2cb6d029ba207061634727bf24e732c2ea6	17225
1767	fef72d66c0bf3e9c65ef9db7dbd3e47f6a67231e565d259c7fde63db3cd93a9b	17231
1768	970f49949b144b4abedf7947a3c5719ec420f25814ba79ba4ebcf08f0714bf66	17239
1769	9699fa04ba17f9badb7727e88349d056845fca8c39bb0a78e4f39849575f1942	17246
1770	0eeeb55aa057d4d2f47937a5c04d7b5e56875c64e187b072e984d8f29718cae6	17250
1771	d9659a7feae14fb0139753ff1fabbd1c241d463d3abc309b4ac99f17b17c437b	17262
1772	8134a9ecc2547ac384c211542e3c9f140813046c665a6f4746d448889a196fee	17278
1773	a001d481b5670c1c553ce27f8366ef0e00cf791af5e5ae5dd51116d704efdf00	17295
1774	fa4a063e3b305646381fae5782960a7d5d3a716daaac4e05633ffcbad12ea396	17305
1775	02a01d993b305a7faeb91961bf99583d3e5ef2d988898ee6dc9d559c4fab195d	17319
1776	66ad6f2c9feb28aa429143d7e728f140a41f2fb57b77d879f9802d086a2a7a96	17339
1777	5a21f8fa5b0e51059bdadfdd5a7b9b5a81dc838cf4a7a4eb7181d8b6683a1883	17343
1778	67b0accc82654bdf77fd8efa7b4a5d36b15bcc1713d09bb91050bfb147c056c9	17345
1779	3cb95b8622f580f4e3aa87c4cd0a90de5e56e8ce682a420018011f8d786f89a9	17353
1780	64268d88956bc3dec4a02afe01ebe1a8ce77250e2849268b45fde49356afd101	17354
1781	8b507e8acd192eee8dbf3131d5f5152db0874f08af2f9aed0e5fab9e54a2cf7e	17355
1782	627a1cd9029477caf2ac2996ab035d83a751588c3cded4abf225d401b116a998	17382
1783	d83ff856a399c12a8dbeb24e500606b5ec4a919467ee8b67ae4b5f9b1b5e9db6	17386
1784	9b11c7a7bf7b747afdda19f3141e72c5b653950c54e6952ddfb72b80fafc82a8	17401
1785	ea562d5d5a59d99b1bd961e9db91a357854861c0c16c91436b8140c507202c8d	17404
1786	9782344c88519b9d54e26c9ad62af2c2a4b22dc8f3ae03ec10e1d58dff8bb0b4	17405
1787	826b9cbabf49e393984a51c18cd8335e169950af8b405a668a7ec551bef1db3e	17410
1788	c5a97d56c037ca566c448834bb246e6a06fc4b66732a8171822cad2dfe46ba65	17424
1789	a1d822b92887126d204e34ae4ce45547a9638fa5b81440d6b7084521c734e124	17426
1790	fabd18fa528156110e4064c3aaf9077a5caaff77e246af82d7f8f9b0507af530	17431
1791	c1b47ac67de8ae3569d9a767e4b05c805decbc4d61e5307b1bf282dd53897dc5	17433
1792	927b8e9a163aa8761b4b783e89e9ddf1ec04b7517df7ba6c293dec159b3506e5	17436
1793	e73f6c55d2b6978dd96ac2eba668838f230e8b2db663e8e8dfb745d8ae53c72a	17438
1794	86b4d43b592148b6856d5c9c4aac7cace9440c51130df4a2e5285f99652c0019	17457
1795	d83b9b9475f47183ca0bc50960765fd4b5c524471105a022c04cfc30de666930	17468
1796	a5dac2fa564c4c098e30539150430f0be1232d36549df6b065e61007440d66ad	17470
1797	8ecb1cf1b7200cf2858754d794a69f1a396c49ad5c5116bdd7e9dd67b6eceb54	17482
1798	507841f5a5a59613194cee13aa0063f32a76e6c9611606ed54761a69dd052a73	17492
1799	3a567851eeb7fd3868c1820e24f1f4370bb5a8acdca23949c8401b2b21d20616	17518
1800	fb00b9a66537e8d0cdf0ff19f8bfb5be55a4ff85949d12433cb1387899fd30f2	17527
1801	d19f12cba071c2e6c4056568064384fe23e3a5b4a49edec7d30bc79ada6bec7e	17551
1802	ebee35bf7871fd8c2b5c2b884e1fe0e43276bca4bab6352152544c92ad1dc962	17560
1803	a8abac9f7dc8dc5c75322596806cbe7034b2592ec91b52610da26ee10b95bc66	17563
1804	aee6ce292ff34ab2cdc4b85a6ccdc97609d396dcbcc717116080981f31c85d59	17594
1805	a8e208e386f3a991d0a9d7ce78c8dd1f230286b5faae44a45bad09f4e2b1d5c6	17622
1806	b2963f6fea047eac060f66065b4059b741fa481d90ef061ff1dd57cb2992ef74	17625
1807	d9f603fed2e64967511db674713b2b04a45adb2ed8f3bf423dc21a6fb8550b5c	17632
1808	b3d8d03c8619a587ff7e289e2a16d09c9383f2be91427e7c5e1a5a7c4c571652	17649
1809	a6d111c03befe1c06a2d23e6af66cd612a2a09f066fd152ef29466eb1aa5dc6b	17660
1810	cd4eb13639aded276666eff478cde0d36de18ca3ce269a05cfd584499bda2814	17661
1811	ff177fe5863faef8aa09a3a0697329aa3cc9fd75ae428fdb8ed61b2a9eb31e5b	17675
1812	298ab4cfc8f15dd2b96eb35726782d4575de3bcd1402dc83544022f8b6cbd5d9	17680
1813	bda4f7ab937959d6c67f630c44c4bd60be9c71d94e631a4f4a61db78041b2193	17686
1814	c2810420bbefbea91ed23b5789da94eb948a755c6250a2af1978272ed868aba4	17705
1815	bece51273b007a8329a6658fedc19d7409ce76411025b6d8b46edc9bc37de35a	17712
1816	990dee537e75854d7f264efbb6f06c2f25cdf3ebf0db6161af2112130b037355	17715
1817	981d8a047760f96b90fc897bd15d08287163b9d0f6212ece075b30fd295be598	17717
1818	d8e303f6b1e5585f379bc108535ad2ef777ece81cd2f78bf3b1f2f7fb018b6e7	17728
1819	5a5f814936d92d324baf300b3ede8ba548bc26cd72308ae1ded52ff888c58a32	17730
1820	5005eba1577106838189f2188e8c727dda355fff1a32420026cf8d5789f916d1	17734
1821	eb718c582f7225bf42da764d601805a0e4d73fa05aa12dfbac3508c9d43aa105	17737
1822	109f6f796d83abfb6d4876d3058c4a8d483fca8df6e71f5787ac03b3e94385c7	17741
1823	11a206359b1b071ed3e86b20b49a69917ab8a11f21fa3cee616c0b0756237940	17747
1824	726a981dfb2b464aae0345fcb44a4ab43816b3d417ea0de24c63486eb91f9197	17760
1825	f986251e8b58bc0d6eeeea56236e480cef2d1a56060844d551088fe5f56863e0	17773
1826	b9891eb1dea190bee460e9867373f44ecb5804aacf0c566122137548dfb8deb7	17778
1827	abc304cc2b7d16ab45af1f98a78309d4fa08de31b5fcd2a6a8bf677f6637f60e	17779
1828	2d90eba32f8a04c25dad55f36ddbc6cb077e15f040d6ceafdc426fa6597cf7a9	17782
1829	5809839fbe022663a0d99c9309d038037f7cd08678bae56b8c03988a1028aeed	17789
1830	4d6b1bff8825fff6d9da4d58e28d50c40ff7e1a0625d3d38032620c6daa851f2	17793
1831	755682a4f8758ebc067b406d18138c1e879b100ad5b080ed5c74a9d6c6b65914	17806
1832	3f2befb1ef6e8589f6ba1ab8e9c3557ee8f456393da20fb52e270750cb767997	17808
1833	604b2a3f2c083f6266bc72212daf8739ffaa2f39aeef51b4e60ab58b62889f0c	17825
1834	c831cee970600164982434c73f3829e258c7744ad835531d1ec506db217c4502	17838
1835	0071bc72f4bc65220aecf450adea8e3552c58a31e0785516602a6ecad2bbd87d	17875
1836	d9f1ba7f018d2ff2a2fbc1f4ced7534389e816526ffa3dc35aa13e50aceab257	17891
1837	c6f9668b6a5dadab80d583998017044cb22ae353fec213a8e5af1a33e45bb475	17897
1838	1d69fee0a518bea687c4ebbb0da95f6115085234a10a7ea7b311ace8413a65e2	17900
1839	80c7735417941a54039aebb90a6cb1e7608d604c63b779c2beeab1be1043b504	17912
1840	fb203292d3ff8e34958a9efca4e4a280054adb19ca8e5ff65ecf1fbea0f9015b	17923
1841	cd72f11b7ff64706a9572e7ea9f8e4cbf1778d768fd6824a700220360d6118f8	17924
1842	08ced945495d6495ec9d7a878148fa885f90389fbd007617e7950963e3cd1ea0	17928
1843	3afaeefdc2c4150019af59a044d98d152cc877a4561201622af783012311049b	17944
1844	1822eb347b4aa87b7d2c7341c6e1cc1a7210ff1b55848f4e13e105e7b04d174d	17961
1845	76867b592ffd64a82355199855f6c70bfb2cb806022111fbed22c94c9fe056fc	17991
1846	59d9665f0d2758b13a0ec07a3bf225f3c118bdbc245299b0ed9548e55149ff5e	17996
1847	807e54ef18152dc5d7f52a36247778b9ae9c4a9235ceecf20325983a2ffbbf1c	17997
1848	594bc6c134c127132ab71c374f22cc9295e0aafac3ce2a85a5b8934d41687d53	18018
1849	f1f017b8d598407ad5f74b95be97eb3dbc8e1d18ef9215e80af2514df217ab03	18020
1850	7880c6ca31cc061470568bd55516836e0fee96646a7f1eb9e156bd72f5f7a87e	18021
1851	b442ab2fab2a0819cc5f8a3211d6d2b7e0a70d5e39887e696d65d4e7250f5f0f	18023
1852	a84489e4ee46ea672b910d839f3b3382b4ee14e5d240b49bd82d25182556b4e5	18026
1853	92c55530ca286054c580bd2db29888885cb0e986e9abfa96e200dc02ea6b97b0	18048
1854	0335e7a858e33e1da07853ab0495ef8133c13177090c45fcf0c159d39f1f2e11	18050
1855	b973751fa95e4105ef64af72bb98a7927b92127286af141dde25ca26765308d8	18053
1856	43756426056a835d8924fafe4d3cb357fdf3b582368fae314fca9c43f077cefc	18062
1857	782b9e2025e7daf3922eb8de5fefbcfc7bc9affe7c930f43e9b5786e000bd4bf	18093
1858	9d0fdf939447c48cc5646645b4df7e26100bd6cd838d202924b43cd3ca49dda1	18096
1859	1baf72cd2639b7985d03636b7b597e2251d0f84021ce98db3393f7124d16aee2	18099
1860	77f2490ddf0a258bdfd3d532d42a4888aaf1524159a9b5959e12cab145b12420	18138
1861	16394d22d86bcce452a6ba7afc1bb913583ab7171b8341c94be353b5a88bb7e0	18151
1862	1748e0aa3d174ceb2d74f011c96849e8af336911ed1f5d47adf282d598a2e843	18158
1863	9c5baf769bec85dc506bdd17447e29088d69432c614cecf1d36af181e6d12d65	18178
1864	8d6c1456e71993ad98465cf835b590738f00f3ec247106ea66c723a2b623edc8	18206
1865	ec506d7afa7791d91e608b9cc08959e6d869160eda344ec709382c8b54db963f	18210
1866	950e87eb9004b40fbe97bb6f1adbd86611cfe948db0ed58fb9b3f9c8fdb2ddec	18219
1867	c5d0c35b1b104d76274c228b6dc7bc0c01720df1d724a82930736cde519d0b69	18224
1868	2e2be8f5a0b6cd766f1d71d5ecf167a9ea2e0aa2b0c6e7327801b21303a0dffc	18231
1869	1b0b011c262e52b1e271287495e54187393890aa099d2291633726c0602900d3	18242
1870	6c09ba1a81cbf6b561111ff4ae0c1bb962aa6d2cd57b22a7417dfe643c976d2b	18247
1871	afa1dd74ec12b4074b5d209601847f658fc92882490845b9b322c0e949e6de8d	18264
1872	2f3348833ace45ad4faca1e940fcdeba33706388a1da46162bb51bd499e76383	18277
1873	af60b4804ca9e601523737326c04e75e2dbaf29a008917bbdc616b101a4109f1	18283
1874	776149a1546e966a34c63b8a17e90496b4afa667e25c21e2b6c6d4057e0742e4	18297
1875	ef92864ab14fac9f53438438911949c141548e8ec3ae0585da635fbc859511f6	18300
1876	afc0607b8dab7c4f354993ffef35fc783421888ef66f30baf4900309054811cb	18303
1877	e4a17a57761b108386bc97e4ba334e94944c283a922ce2a5825ded4a3e4c2923	18330
1878	8a636f61ef8b1f0ce16b551e3b3763d6dc21c2508d518541b914fff7d5a7a02a	18331
1879	4f5cd7f91872238c5f2736e744abb06228dd613bab45760e0818ddfba4ddfaa5	18343
1880	e19a6ce13bcadcdde002561d55c122d873b70025c46ce7df74cfc6ad321001e4	18349
1881	9563aa2c7e5e16025047da0d2634b80e23661ff586fc3dfd20c395304f61cf4c	18355
1882	c3a8efc6e825bd651cd7b631c5862e9356d66e3c1757784f9bd76a450f13de55	18367
1883	b20604cd5974b67eaf5e59d9df597530d2e0261850630cc7e666a061bcf52f73	18370
1884	415fb2a6187b7b17c21c9488a5d1d28691c9c425f57230eb63d13a30eddeb9e0	18374
1885	f41a698f92f89cc6ebe0019dd37c666e67cb01e8840f115a8d5739648548ed3e	18385
1886	b6d16bd0152f922c74e6ba19f25e6319a42f12bb191938973c8d76504c22e14d	18386
1887	60e21f7257b493aa77d3c47707c8609c363432a52e3f0c13507da7a490337f15	18392
1888	1d7fb99d4b6a0d2deb8d175000cb47f1b438737eab419f4419c5c62ec1456c47	18403
1889	e4e14b77b60d7a0a80a2a4ae3509d0ed3f08b0bb7a57329e22555a832fc79c60	18417
1890	b53272054e02e875680dc4450b5e9e70eb54532127c7aac20ab6d728568ba3c2	18422
1891	832ad09cc021b23e8a7f5d439380c72327c56693908f33d8c7e07cf50d585545	18430
1892	878a2149eb5510cc2bba2f0eb941cbeb18d6b9a8f3fb635c9b11de76d7b33b40	18442
1893	bf76c8dbd002e0a72bee9db77e16c489d9264900b731a4ccf1d2660d93a92f66	18444
1894	cfd60971b7ea5123a852b6c2ffa57ce7995be47d79fd93b16e2e18dd3cc9a44c	18445
1895	47c10540fdcbaa7aab2f332cf67e6d064ca5bea651be38ee8597640993437456	18453
1896	2f4158414d0a3262b65b38196576f01a007f2419e5d0ac9dc311b5968376590a	18471
1897	3dd7bcbdc974f16ac6f11c010d4c00944cc8b67e1f5bd84ee21e46f728e31824	18476
1898	8d19f79d02169a7836069ec83d404c656e4f3641b87039aad967c3bc2e9ebe22	18481
1899	7d440fdd46f651386e474e643da2d027000bd31d28a17dc6afab81a08bdd5eba	18498
1900	5e4e2d0e279096404f076fdeaa5cde975cbd7c0bf79cb9caef743f2399b1c808	18501
1901	91a83852c38f3845c08c0159a61a83c976a0a9325fbf8e20cb201de81d51b0f4	18508
1902	58ab38fcdfd275954a39d831c6e55d6be2657d36ede89e1f050eb631121da28f	18522
1903	16024d28a7378ea5f6d084e67a2944bb7df6eeab13a8876d2c1958ef50e5f9fa	18533
1904	3f1341a738a9ec8f5a2d645f3b2fb8c61d2cbe9aaaa3b6d8e2757b093607c652	18538
1905	8542a143e2cfb5051588346710adfb164efc8c57892eedffc572aa353c74b037	18545
1906	1e26dbda90af0aef0c208fd80bfc857091e34f2d09a5df39975e01c12754113a	18552
1907	c1a491c69c7a362075d2613ddb4a5477262cf59f5b3250c08287009b307d6df7	18561
1908	933fd37f12a9611c690855f3473eec7d75d8dada018194d15a8013baf1bb0b3e	18566
1909	7e9287e635c299a82670027c8b6f0a13b5f739d1a7733890e68758befd95bc6f	18577
1910	73e6e8127eb644ddbd033dbc8f75ac271b25369e229f72285ab818792d83c73f	18586
1911	83c853a41f95cadc7bd0a56d2c222031add9176809755249233717cfc56b4feb	18588
1912	94478ab56712861cf30664fb1d932b529627605dd4d4aee58fd5c6ef242e96fa	18600
1913	fcd5ccf07f2989f9cb53e05c9b4b4abddf1d42eb617768d85a7356a61e91a02f	18647
1914	be851f6e16a34485064278275ee080a77aa86f0cffba32633eeaee39ef4babc2	18648
1915	7d11be38b388c2aa1949e24700daa3c1ee00e2d058df371e2708d5f776f9118f	18661
1916	2aa054fd096b90fc50ae3240305b5981d6426658e96d6c9093a303d8bd60504e	18681
1917	87621fdc013435f8ec65bcacb4ea58c1336fade777af88f139d86fdc84affefe	18696
1918	edd8d558a212587a9f96d50b08834ddd32eb31b4c23f639851178278561fa623	18700
1919	52a28989a2ffde83942e30e616413f573bf175cbb4c952ff6efd96c646980028	18721
1920	73d6de4db0be59e6eba5fadcfee1de75dd6071faa7f31ec447ad4411a500d91c	18732
1921	89e35a677046ed13e0779b955e28356c5274422f77350e683678579e2996895f	18738
1922	bfe6fd6d4520b7b86a510e0c42f22673b9b086d81bdefedf5e0f47859ca53787	18787
1923	9ad0f8be065acb00c136be6905037487c88864d84fa4db61ffe654175887f0b7	18789
1924	e97d360190e202f7ec6319a00f3e44822b728bcb9b0890422f9454e2dbee022e	18795
1925	5126c8789f217c20389ba8cdfae5a1e44a98bcbcac73e91e6121bc802955d274	18813
1926	220030c1c90263e58639cd2f37c29bf81cd66ddcd382db639c5c4d80084b293d	18818
1927	eca0e78b3d9be98c0f94f539f9f7932fa1289fa8d79901cf1d1399130d06739a	18819
1928	732d839fdc005568c811a08c32c04ff905cb395782a8b3987a4e309c0f76e317	18828
1929	d35ac85a6ac916e53c54385a3a56825b7c4ea43d919bafd387529465540d5c2c	18850
1930	c70a2603722af4154414d28c8c5b3b0ffb7c597bd52594b6c2f1c2945f0e8750	18864
1931	4b558e5eabcf47bd3b02741ad42a0e3e2987b56b81abffde97a3052da0c9d1fb	18869
1932	445d9118acb0ddbf626c557ec68b60843ece13725d2041cba10665a0f7e9a2b5	18875
1933	c9594cad3f63c49a13fdecd4f71ff71606053950a140dea181fd765dcde3b9a3	18876
1934	e5a23406c352c80e1143533ce75dc6d28253205e512d925c8111b3748663860f	18884
1935	430d0caf17529be84e69152499d4d288647ffb9f943b6d0f98fe1e8bb31dd599	18894
1936	ad27de5a1665127e0ca735ec755f9c5042b2d6395077e03838c8ad2aac033b26	18904
1937	635e25f8f60d5a68e6bb0a47474e06b6cc60229b2ba8863f21662d5767421a1f	18907
1938	0da6240b4033448b6a71613bc37902ced478f46808160a00bd71774ae9536415	18911
1939	0feb710a0e7a42ea645569ae187b66fdd0200eb4b56d0c21cbda015fd34a5005	18923
1940	859beba0c92b83091c10c41c0bbc9b9d36430ae2158883d1d477201fb2ccc36c	18932
1941	dfe63e21a3822bdd13451f333aacab07ae329f15a263e92c59ba6d4cdd1e08fe	18941
1942	5f5d5ec000c722ac378e15cca6be800e381ca6e0fb68d53183a5b19bc3e07b9f	18949
1943	358cccf028b1ded25fc9c270fd12be83a1c2addd7153d5c3f229b5c2b2b7ff92	18953
1944	7f3ff7c74ef535581fe23c635a6b61b167e56a5bc7b6cc646b11108ffb212ad4	18962
1945	8fa27f6cc9f7fafceb5dbd46e4585c05332b493ca51caeef4fb0cbc3f00dfc51	18963
1946	9bf4274458d15016c96b7e6c6c55ba6909b6c763bb0e879dd39bd92d2d64b872	18966
1947	c7d370b4817582ff34d0477096c8cfa1033a024f50dc4d22799da76c6781689a	18967
1948	fbbc9f6fcd96f48c92d3e8cb8e30a111955b08bdf041d4d9e80dea4de8c845cc	18970
1949	b5be978786ab10903562eeef34266c81d401f61b1e878ac66488826a8c9eaa6a	18994
1950	651741fe60a7dd800b3893173ce7d116c1b7b6ed984c52977815de51d16f1bcc	18997
1951	2b0e12ec6c107f053da8b37b03689536fe5ab6b932f7e750f72d35816b329f7a	19006
1952	c9f5ca756418b1bdaec911d5b4453d30ae462a20c8a464462ea88edcdc15f2e2	19031
1953	cb9815f6443d35ba71c5274cf3c5c3377dd15ec536ee9b53b6eb3d59e50ce526	19041
1954	daa95852c2c9531969b015877eba29ae02cfab6db29cbd837da6f49e43d46bca	19042
1955	83bb1c63ffbb30d7b5f8280b1c4872f0a6e9246abcc57d4d25cb802225d820e3	19046
1956	b42c9fa9379ddbb45e7605c690df2da12e3f3381272c0092d0142caf0582aa83	19050
1957	9a57dd522428d919d9414fcf35cdefe91d3dbb52fd2ab6e13bdf5c40e71f068c	19063
1958	809aaf3a6d3bd1503df6d2ba2cb62c902f5fa62ea17b428ac5577d34b22457b9	19072
1959	81eb5e8d3ffe23b1f0d5acb00b3fab4f825b0828e79a887e8d04d307a14363e5	19093
1960	6fcf9bd01051172e884162ec94817baa1c76a9777bdf5c38a9f76188b2c0224e	19108
1961	ea07488736d05baca356fc3c84acf567dc56e309ce2b29509364018775004030	19113
1962	d2670f6b1efe2a5ee943f1a1400109eee28e144322f40a788bdf7ff3c5be2965	19120
1963	c5daa9437ed7f4b346df7192216b25376745509a0bfb714928b9ee6eb1edf728	19145
1964	1f6eacfdb2138c9354ac29156c94ff3773798f4151b5c131a61cf2aea56ddc1a	19147
1965	1736ba40a13e800ef96b5c011ff4c262f66006e649ede9045b8d9a5e800cd8ce	19151
1966	d9487a5c892642e3e78e406f95d77e5ba7f51b261cbf79f03934697d82a46b5d	19152
1967	0a88c2bdb40865e210145e30fd1b0de249b3ec9e3bc06d0d04f1fc16c011f3bc	19153
1968	905590882b042678b4eb62d72112ca5ecf682c4986afe89927d8eb432e93885f	19154
1969	3f09f7c5980279b5ac3e8ed1708e578c1b767cec2926ab55de9d950522ff6f96	19165
1970	31bebad613bf863f20b361d2048cd095c8127a9697320ce064834cc7466e6de7	19173
1971	36dd12461e944260c7ace2c6c89d0317ec1233b7758a7bc81237ea39714725c1	19174
1972	16070db369531972eb8e686fcd724c46a6e94cf13de2516554d1fa15f8312032	19182
1973	488592b3abe47318576c7f055cb14737414718dcaddf0e3976deb87cc0a1687e	19206
1974	9c6738615adfb4bfbb990e8ca8cf58561e258abbdb5033abd54dc62258017590	19220
1975	562fda6404aea46c7c2f5aee3b89aca16e61ea865bacb50e450d2dd7921246c6	19226
1976	5c953dc0bd3f2a97150227c02df29907963723c68c37fe90c5fe5cd44ab2c9db	19236
1977	2a0d61f3ca6667906e39b576194ce6901cd6fe14239e5c86fa1cb846885f1104	19243
1978	48c2ba038cb51aa19a3347f54c1daf72b7321e25906c5dad674632a30ad0a6f9	19249
1979	c1c02695817baaca1bd577f96be59f1ddbb5526b214d9e6234c1bb9041e0a494	19253
1980	1e3f59a3d334e90410b20a53cd42c94127ef1c9bd4f8adb892556ad4c63d0554	19261
1981	357829827b75a93b94621205667906aa14dd159026cc02a417d59617fc435c03	19264
1982	3aa1f5499635dbb7818a1cd2db18e06a2d4a640f0038a7494f7f4dde3fd087d1	19266
1983	e71edc59a52b7d6f6310314d1b43b313828bb9183f104391ccbd7dabe0fd668d	19271
\.


--
-- Data for Name: block_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block_data (block_height, data) FROM stdin;
1922	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932322c2268617368223a2262666536666436643435323062376238366135313065306334326632323637336239623038366438316264656665646635653066343738353963613533373837222c22736c6f74223a31383738377d2c22697373756572566b223a2235643737363830323038343663306631343933633063326631326365363833653535613235396165306532363231373164626633383762653661333832623036222c2270726576696f7573426c6f636b223a2238396533356136373730343665643133653037373962393535653238333536633532373434323266373733353065363833363738353739653239393638393566222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31307530306636713033636372786c6761716e6870377076326679706474797568733035666e7036706d666a7979766874613335716a3966646a37227d
1923	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932332c2268617368223a2239616430663862653036356163623030633133366265363930353033373438376338383836346438346661346462363166666536353431373538383766306237222c22736c6f74223a31383738397d2c22697373756572566b223a2237646562636131623962626238633239336532643939613831366632366138366665313866336464643832306664643233616437393631633934656234333431222c2270726576696f7573426c6f636b223a2262666536666436643435323062376238366135313065306334326632323637336239623038366438316264656665646635653066343738353963613533373837222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c726e796e6d7966647577686e75786165386139307a7271706e6a347236367639766e786c39617775633734387a363638646871377777756a71227d
1924	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932342c2268617368223a2265393764333630313930653230326637656336333139613030663365343438323262373238626362396230383930343232663934353465326462656530323265222c22736c6f74223a31383739357d2c22697373756572566b223a2264653039343431393139333733623762363964643663346134333030623765306632316536313866323839323766333537386632346236613537646630373930222c2270726576696f7573426c6f636b223a2239616430663862653036356163623030633133366265363930353033373438376338383836346438346661346462363166666536353431373538383766306237222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137756d7163393836756b78663536777032343537713235396667617277677763767939657576756e376d61757970347a786a3071776a74326572227d
1925	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932352c2268617368223a2235313236633837383966323137633230333839626138636466616535613165343461393862636263616337336539316536313231626338303239353564323734222c22736c6f74223a31383831337d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2265393764333630313930653230326637656336333139613030663365343438323262373238626362396230383930343232663934353465326462656530323265222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1926	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932362c2268617368223a2232323030333063316339303236336535383633396364326633376332396266383163643636646463643338326462363339633563346438303038346232393364222c22736c6f74223a31383831387d2c22697373756572566b223a2231396339323132643936656261323832643632633436643662313231356163653763333536343535383234303230326662643563303463643133313636663639222c2270726576696f7573426c6f636b223a2235313236633837383966323137633230333839626138636466616535613165343461393862636263616337336539316536313231626338303239353564323734222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31746a7037363334666b6b36743974716e32676e346e766b6371677138716177736b793471306664616736756178363474617678713863656b7963227d
1927	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932372c2268617368223a2265636130653738623364396265393863306639346635333966396637393332666131323839666138643739393031636631643133393931333064303637333961222c22736c6f74223a31383831397d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2232323030333063316339303236336535383633396364326633376332396266383163643636646463643338326462363339633563346438303038346232393364222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1928	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932382c2268617368223a2237333264383339666463303035353638633831316130386333326330346666393035636233393537383261386233393837613465333039633066373665333137222c22736c6f74223a31383832387d2c22697373756572566b223a2239376261313264616361363732663130346332636164636363626233356639306138303762386365363766643337343765386261666362303935633336346638222c2270726576696f7573426c6f636b223a2265636130653738623364396265393863306639346635333966396637393332666131323839666138643739393031636631643133393931333064303637333961222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773877336576717163787a716b616b38667a6570393934337777616e6b7379736367366d6372666e39676865736e63777565747130736c657176227d
1929	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932392c2268617368223a2264333561633835613661633931366535336335343338356133613536383235623763346561343364393139626166643338373532393436353534306435633263222c22736c6f74223a31383835307d2c22697373756572566b223a2264653039343431393139333733623762363964643663346134333030623765306632316536313866323839323766333537386632346236613537646630373930222c2270726576696f7573426c6f636b223a2237333264383339666463303035353638633831316130386333326330346666393035636233393537383261386233393837613465333039633066373665333137222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137756d7163393836756b78663536777032343537713235396667617277677763767939657576756e376d61757970347a786a3071776a74326572227d
1930	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933302c2268617368223a2263373061323630333732326166343135343431346432386338633562336230666662376335393762643532353934623663326631633239343566306538373530222c22736c6f74223a31383836347d2c22697373756572566b223a2231396339323132643936656261323832643632633436643662313231356163653763333536343535383234303230326662643563303463643133313636663639222c2270726576696f7573426c6f636b223a2264333561633835613661633931366535336335343338356133613536383235623763346561343364393139626166643338373532393436353534306435633263222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31746a7037363334666b6b36743974716e32676e346e766b6371677138716177736b793471306664616736756178363474617678713863656b7963227d
1931	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933312c2268617368223a2234623535386535656162636634376264336230323734316164343261306533653239383762353662383161626666646539376133303532646130633964316662222c22736c6f74223a31383836397d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2263373061323630333732326166343135343431346432386338633562336230666662376335393762643532353934623663326631633239343566306538373530222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1932	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933322c2268617368223a2234343564393131386163623064646266363236633535376563363862363038343365636531333732356432303431636261313036363561306637653961326235222c22736c6f74223a31383837357d2c22697373756572566b223a2265653031306234303535616364306663626430373933343864306335616564376265623132343263383933396139613939363464376530343362356564333039222c2270726576696f7573426c6f636b223a2234623535386535656162636634376264336230323734316164343261306533653239383762353662383161626666646539376133303532646130633964316662222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3139776e6377306d7364777a336e726c6476676637676a6732386c616a30666b6b65386870636d6d73326471713778346533616571613863797866227d
1933	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933332c2268617368223a2263393539346361643366363363343961313366646563643466373166663731363036303533393530613134306465613138316664373635646364653362396133222c22736c6f74223a31383837367d2c22697373756572566b223a2231396339323132643936656261323832643632633436643662313231356163653763333536343535383234303230326662643563303463643133313636663639222c2270726576696f7573426c6f636b223a2234343564393131386163623064646266363236633535376563363862363038343365636531333732356432303431636261313036363561306637653961326235222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31746a7037363334666b6b36743974716e32676e346e766b6371677138716177736b793471306664616736756178363474617678713863656b7963227d
1934	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933342c2268617368223a2265356132333430366333353263383065313134333533336365373564633664323832353332303565353132643932356338313131623337343836363338363066222c22736c6f74223a31383838347d2c22697373756572566b223a2261383561393833373033396236623566316664626665373431303236663938316134343664613736376438653064643031643564316666663039323439363565222c2270726576696f7573426c6f636b223a2263393539346361643366363363343961313366646563643466373166663731363036303533393530613134306465613138316664373635646364653362396133222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3166666b727a79727236723973673978653472373676366c74613367366d757676706a65667a75646e307635653068343566686c713265646b6179227d
1935	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933352c2268617368223a2234333064306361663137353239626538346536393135323439396434643238383634376666623966393433623664306639386665316538626233316464353939222c22736c6f74223a31383839347d2c22697373756572566b223a2231396339323132643936656261323832643632633436643662313231356163653763333536343535383234303230326662643563303463643133313636663639222c2270726576696f7573426c6f636b223a2265356132333430366333353263383065313134333533336365373564633664323832353332303565353132643932356338313131623337343836363338363066222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31746a7037363334666b6b36743974716e32676e346e766b6371677138716177736b793471306664616736756178363474617678713863656b7963227d
1936	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933362c2268617368223a2261643237646535613136363531323765306361373335656337353566396335303432623264363339353037376530333833386338616432616163303333623236222c22736c6f74223a31383930347d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2234333064306361663137353239626538346536393135323439396434643238383634376666623966393433623664306639386665316538626233316464353939222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1937	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933372c2268617368223a2236333565323566386636306435613638653662623061343734373465303662366363363032323962326261383836336632313636326435373637343231613166222c22736c6f74223a31383930377d2c22697373756572566b223a2237646562636131623962626238633239336532643939613831366632366138366665313866336464643832306664643233616437393631633934656234333431222c2270726576696f7573426c6f636b223a2261643237646535613136363531323765306361373335656337353566396335303432623264363339353037376530333833386338616432616163303333623236222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c726e796e6d7966647577686e75786165386139307a7271706e6a347236367639766e786c39617775633734387a363638646871377777756a71227d
1938	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933382c2268617368223a2230646136323430623430333334343862366137313631336263333739303263656434373866343638303831363061303062643731373734616539353336343135222c22736c6f74223a31383931317d2c22697373756572566b223a2261383561393833373033396236623566316664626665373431303236663938316134343664613736376438653064643031643564316666663039323439363565222c2270726576696f7573426c6f636b223a2236333565323566386636306435613638653662623061343734373465303662366363363032323962326261383836336632313636326435373637343231613166222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3166666b727a79727236723973673978653472373676366c74613367366d757676706a65667a75646e307635653068343566686c713265646b6179227d
1939	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933392c2268617368223a2230666562373130613065376134326561363435353639616531383762363666646430323030656234623536643063323163626461303135666433346135303035222c22736c6f74223a31383932337d2c22697373756572566b223a2264653039343431393139333733623762363964643663346134333030623765306632316536313866323839323766333537386632346236613537646630373930222c2270726576696f7573426c6f636b223a2230646136323430623430333334343862366137313631336263333739303263656434373866343638303831363061303062643731373734616539353336343135222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137756d7163393836756b78663536777032343537713235396667617277677763767939657576756e376d61757970347a786a3071776a74326572227d
1940	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313934302c2268617368223a2238353962656261306339326238333039316331306334316330626263396239643336343330616532313538383833643164343737323031666232636363333663222c22736c6f74223a31383933327d2c22697373756572566b223a2239376261313264616361363732663130346332636164636363626233356639306138303762386365363766643337343765386261666362303935633336346638222c2270726576696f7573426c6f636b223a2230666562373130613065376134326561363435353639616531383762363666646430323030656234623536643063323163626461303135666433346135303035222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773877336576717163787a716b616b38667a6570393934337777616e6b7379736367366d6372666e39676865736e63777565747130736c657176227d
1941	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313934312c2268617368223a2264666536336532316133383232626464313334353166333333616163616230376165333239663135613236336539326335396261366434636464316530386665222c22736c6f74223a31383934317d2c22697373756572566b223a2265653031306234303535616364306663626430373933343864306335616564376265623132343263383933396139613939363464376530343362356564333039222c2270726576696f7573426c6f636b223a2238353962656261306339326238333039316331306334316330626263396239643336343330616532313538383833643164343737323031666232636363333663222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3139776e6377306d7364777a336e726c6476676637676a6732386c616a30666b6b65386870636d6d73326471713778346533616571613863797866227d
1942	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313934322c2268617368223a2235663564356563303030633732326163333738653135636361366265383030653338316361366530666236386435333138336135623139626333653037623966222c22736c6f74223a31383934397d2c22697373756572566b223a2239376261313264616361363732663130346332636164636363626233356639306138303762386365363766643337343765386261666362303935633336346638222c2270726576696f7573426c6f636b223a2264666536336532316133383232626464313334353166333333616163616230376165333239663135613236336539326335396261366434636464316530386665222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773877336576717163787a716b616b38667a6570393934337777616e6b7379736367366d6372666e39676865736e63777565747130736c657176227d
1943	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313934332c2268617368223a2233353863636366303238623164656432356663396332373066643132626538336131633261646464373135336435633366323239623563326232623766663932222c22736c6f74223a31383935337d2c22697373756572566b223a2265653031306234303535616364306663626430373933343864306335616564376265623132343263383933396139613939363464376530343362356564333039222c2270726576696f7573426c6f636b223a2235663564356563303030633732326163333738653135636361366265383030653338316361366530666236386435333138336135623139626333653037623966222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3139776e6377306d7364777a336e726c6476676637676a6732386c616a30666b6b65386870636d6d73326471713778346533616571613863797866227d
1944	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313934342c2268617368223a2237663366663763373465663533353538316665323363363335613662363162313637653536613562633762366363363436623131313038666662323132616434222c22736c6f74223a31383936327d2c22697373756572566b223a2239376261313264616361363732663130346332636164636363626233356639306138303762386365363766643337343765386261666362303935633336346638222c2270726576696f7573426c6f636b223a2233353863636366303238623164656432356663396332373066643132626538336131633261646464373135336435633366323239623563326232623766663932222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773877336576717163787a716b616b38667a6570393934337777616e6b7379736367366d6372666e39676865736e63777565747130736c657176227d
1945	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313934352c2268617368223a2238666132376636636339663766616663656235646264343665343538356330353333326234393363613531636165656634666230636263336630306466633531222c22736c6f74223a31383936337d2c22697373756572566b223a2264653039343431393139333733623762363964643663346134333030623765306632316536313866323839323766333537386632346236613537646630373930222c2270726576696f7573426c6f636b223a2237663366663763373465663533353538316665323363363335613662363162313637653536613562633762366363363436623131313038666662323132616434222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137756d7163393836756b78663536777032343537713235396667617277677763767939657576756e376d61757970347a786a3071776a74326572227d
1946	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313934362c2268617368223a2239626634323734343538643135303136633936623765366336633535626136393039623663373633626230653837396464333962643932643264363462383732222c22736c6f74223a31383936367d2c22697373756572566b223a2261383561393833373033396236623566316664626665373431303236663938316134343664613736376438653064643031643564316666663039323439363565222c2270726576696f7573426c6f636b223a2238666132376636636339663766616663656235646264343665343538356330353333326234393363613531636165656634666230636263336630306466633531222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3166666b727a79727236723973673978653472373676366c74613367366d757676706a65667a75646e307635653068343566686c713265646b6179227d
1947	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313934372c2268617368223a2263376433373062343831373538326666333464303437373039366338636661313033336130323466353064633464323237393964613736633637383136383961222c22736c6f74223a31383936377d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2239626634323734343538643135303136633936623765366336633535626136393039623663373633626230653837396464333962643932643264363462383732222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1948	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313934382c2268617368223a2266626263396636666364393666343863393264336538636238653330613131313935356230386264663034316434643965383064656134646538633834356363222c22736c6f74223a31383937307d2c22697373756572566b223a2235643737363830323038343663306631343933633063326631326365363833653535613235396165306532363231373164626633383762653661333832623036222c2270726576696f7573426c6f636b223a2263376433373062343831373538326666333464303437373039366338636661313033336130323466353064633464323237393964613736633637383136383961222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31307530306636713033636372786c6761716e6870377076326679706474797568733035666e7036706d666a7979766874613335716a3966646a37227d
1949	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313934392c2268617368223a2262356265393738373836616231303930333536326565656633343236366338316434303166363162316538373861633636343838383236613863396561613661222c22736c6f74223a31383939347d2c22697373756572566b223a2261383561393833373033396236623566316664626665373431303236663938316134343664613736376438653064643031643564316666663039323439363565222c2270726576696f7573426c6f636b223a2266626263396636666364393666343863393264336538636238653330613131313935356230386264663034316434643965383064656134646538633834356363222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3166666b727a79727236723973673978653472373676366c74613367366d757676706a65667a75646e307635653068343566686c713265646b6179227d
1950	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313935302c2268617368223a2236353137343166653630613764643830306233383933313733636537643131366331623762366564393834633532393737383135646535316431366631626363222c22736c6f74223a31383939377d2c22697373756572566b223a2261383561393833373033396236623566316664626665373431303236663938316134343664613736376438653064643031643564316666663039323439363565222c2270726576696f7573426c6f636b223a2262356265393738373836616231303930333536326565656633343236366338316434303166363162316538373861633636343838383236613863396561613661222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3166666b727a79727236723973673978653472373676366c74613367366d757676706a65667a75646e307635653068343566686c713265646b6179227d
1951	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313935312c2268617368223a2232623065313265633663313037663035336461386233376230333638393533366665356162366239333266376537353066373264333538313662333239663761222c22736c6f74223a31393030367d2c22697373756572566b223a2235643737363830323038343663306631343933633063326631326365363833653535613235396165306532363231373164626633383762653661333832623036222c2270726576696f7573426c6f636b223a2236353137343166653630613764643830306233383933313733636537643131366331623762366564393834633532393737383135646535316431366631626363222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31307530306636713033636372786c6761716e6870377076326679706474797568733035666e7036706d666a7979766874613335716a3966646a37227d
1952	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313832393235227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2262396337356664383439356265396231326464343536326339656138373437353536653832396366373134636135626438626534323733323232653630303564227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2235303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303064653134303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231323635323736383330353035227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a32303434367d2c227769746864726177616c73223a5b7b227175616e74697479223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234373033383333303436227d2c227374616b6541646472657373223a227374616b655f7465737431757263716a65663432657579637733376d75703532346d66346a3577716c77796c77776d39777a6a70347634326b736a6773676379227d2c7b227175616e74697479223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239323035333933303930227d2c227374616b6541646472657373223a227374616b655f7465737431757263346d767a6c326370346765646c337971327078373635396b726d7a757a676e6c3264706a6a677379646d71717867616d6a37227d5d7d2c226964223a2231656134343864643862303733383930326634393035343166666337386236633234623261623662306565373362643461643364306430386430366439656561222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2233363863663661313161633765323939313735363861333636616636326135393663623963646538313734626665376636653838333933656364623164636336222c223363623131366362373365653366383161373961343434623437343539373164636239313264303762356566383938383866336331333838666230383535343563643438343665386135626264343331356232323332653763373032613639623663373932306431386161646363393838663463643236626664373962363030225d2c5b2238373563316539386262626265396337376264646364373063613464373261633964303734303837346561643161663932393036323936353533663866333433222c226362623963303137626335313565326632633134326663326130313134383236646633666130633564396430373538643066333633363131623033376530363464646561393965616632323865656663396435386337333766303033333966623565383632383436666163363961353566323464366238363436303034613033225d2c5b2238363439393462663364643637393466646635366233623264343034363130313038396436643038393164346130616132343333316566383662306162386261222c223533356633353833316363316631303062313733366539396461336561646534386462636165316661333037396662383934636235396434653434613062616234346466366438303063663465333734656661653563323261626539306639646133626237336530333836356137353638656363343939383438326636363035225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313832393235227d2c22686561646572223a7b22626c6f636b4e6f223a313935322c2268617368223a2263396635636137353634313862316264616563393131643562343435336433306165343632613230633861343634343632656138386564636463313566326532222c22736c6f74223a31393033317d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2232623065313265633663313037663035336461386233376230333638393533366665356162366239333266376537353066373264333538313662333239663761222c2273697a65223a3632332c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231323635323831383330353035227d2c227478436f756e74223a312c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1953	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313935332c2268617368223a2263623938313566363434336433356261373163353237346366336335633333373764643135656335333665653962353362366562336435396535306365353236222c22736c6f74223a31393034317d2c22697373756572566b223a2265653031306234303535616364306663626430373933343864306335616564376265623132343263383933396139613939363464376530343362356564333039222c2270726576696f7573426c6f636b223a2263396635636137353634313862316264616563393131643562343435336433306165343632613230633861343634343632656138386564636463313566326532222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3139776e6377306d7364777a336e726c6476676637676a6732386c616a30666b6b65386870636d6d73326471713778346533616571613863797866227d
1954	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313935342c2268617368223a2264616139353835326332633935333139363962303135383737656261323961653032636661623664623239636264383337646136663439653433643436626361222c22736c6f74223a31393034327d2c22697373756572566b223a2237646562636131623962626238633239336532643939613831366632366138366665313866336464643832306664643233616437393631633934656234333431222c2270726576696f7573426c6f636b223a2263623938313566363434336433356261373163353237346366336335633333373764643135656335333665653962353362366562336435396535306365353236222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c726e796e6d7966647577686e75786165386139307a7271706e6a347236367639766e786c39617775633734387a363638646871377777756a71227d
1955	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313935352c2268617368223a2238336262316336336666626233306437623566383238306231633438373266306136653932343661626363353764346432356362383032323235643832306533222c22736c6f74223a31393034367d2c22697373756572566b223a2237646562636131623962626238633239336532643939613831366632366138366665313866336464643832306664643233616437393631633934656234333431222c2270726576696f7573426c6f636b223a2264616139353835326332633935333139363962303135383737656261323961653032636661623664623239636264383337646136663439653433643436626361222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c726e796e6d7966647577686e75786165386139307a7271706e6a347236367639766e786c39617775633734387a363638646871377777756a71227d
1956	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313935362c2268617368223a2262343263396661393337396464626234356537363035633639306466326461313265336633333831323732633030393264303134326361663035383261613833222c22736c6f74223a31393035307d2c22697373756572566b223a2235643737363830323038343663306631343933633063326631326365363833653535613235396165306532363231373164626633383762653661333832623036222c2270726576696f7573426c6f636b223a2238336262316336336666626233306437623566383238306231633438373266306136653932343661626363353764346432356362383032323235643832306533222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31307530306636713033636372786c6761716e6870377076326679706474797568733035666e7036706d666a7979766874613335716a3966646a37227d
1957	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313935372c2268617368223a2239613537646435323234323864393139643934313466636633356364656665393164336462623532666432616236653133626466356334306537316630363863222c22736c6f74223a31393036337d2c22697373756572566b223a2264653039343431393139333733623762363964643663346134333030623765306632316536313866323839323766333537386632346236613537646630373930222c2270726576696f7573426c6f636b223a2262343263396661393337396464626234356537363035633639306466326461313265336633333831323732633030393264303134326361663035383261613833222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137756d7163393836756b78663536777032343537713235396667617277677763767939657576756e376d61757970347a786a3071776a74326572227d
1958	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313935382c2268617368223a2238303961616633613664336264313530336466366432626132636236326339303266356661363265613137623432386163353537376433346232323435376239222c22736c6f74223a31393037327d2c22697373756572566b223a2235643737363830323038343663306631343933633063326631326365363833653535613235396165306532363231373164626633383762653661333832623036222c2270726576696f7573426c6f636b223a2239613537646435323234323864393139643934313466636633356364656665393164336462623532666432616236653133626466356334306537316630363863222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31307530306636713033636372786c6761716e6870377076326679706474797568733035666e7036706d666a7979766874613335716a3966646a37227d
1959	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b226964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c22767266223a2232656535613463343233323234626239633432313037666331386136303535366436613833636563316439646433376137316635366166373139386663373539222c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22353030303030303030303030303030227d2c22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c227265776172644163636f756e74223a227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973222c226f776e657273223a5b227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973225d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e31222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d7d7d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22696e70757473223a5b7b22696e646578223a322c2274784964223a2235356236396662366636353063656335613736336333376662646331646232313966396234323266313766623333356662633735666266656631336436333031227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936383230313131227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a32303531327d2c227769746864726177616c73223a5b5d7d2c226964223a2266656233383635356535376237643239356265656562366636303132323262626332646333333661633334346437363739623735333737353033313765316133222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223634646631333561323138303232613730646232666436343131616136646339303336316433636165313839613130376236373734366430333731366531663939346535363339636133346163323961356633346134303433336261633739346431346338656466373462343733313563616266313264623638623435613034225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c223033333464373338336661323461646165653331363131363638303466376363353664333032363434323436366530376462333665326239663136396565346463303966636364353434623364333337353465613236366535363935326665313834396536616232316661333532346233303232383063373935343964353065225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22686561646572223a7b22626c6f636b4e6f223a313935392c2268617368223a2238316562356538643366666532336231663064356163623030623366616234663832356230383238653739613838376538643034643330376131343336336535222c22736c6f74223a31393039337d2c22697373756572566b223a2265323466353662353837316433633939376661356232343938643466333766333564343931613330386236383062666664333431386234363161623831393233222c2270726576696f7573426c6f636b223a2238303961616633613664336264313530336466366432626132636236326339303266356661363265613137623432386163353537376433346232323435376239222c2273697a65223a3535342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383230313131227d2c227478436f756e74223a312c22767266223a227672665f766b316e3363727973676539657a6d6165383866726b7066346635743736686c6b6d64796b3378666568336a7877706773616a757130736c796e723930227d
1960	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313936302c2268617368223a2236666366396264303130353131373265383834313632656339343831376261613163373661393737376264663563333861396637363138386232633032323465222c22736c6f74223a31393130387d2c22697373756572566b223a2265653031306234303535616364306663626430373933343864306335616564376265623132343263383933396139613939363464376530343362356564333039222c2270726576696f7573426c6f636b223a2238316562356538643366666532336231663064356163623030623366616234663832356230383238653739613838376538643034643330376131343336336535222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3139776e6377306d7364777a336e726c6476676637676a6732386c616a30666b6b65386870636d6d73326471713778346533616571613863797866227d
1961	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313936312c2268617368223a2265613037343838373336643035626163613335366663336338346163663536376463353665333039636532623239353039333634303138373735303034303330222c22736c6f74223a31393131337d2c22697373756572566b223a2261383561393833373033396236623566316664626665373431303236663938316134343664613736376438653064643031643564316666663039323439363565222c2270726576696f7573426c6f636b223a2236666366396264303130353131373265383834313632656339343831376261613163373661393737376264663563333861396637363138386232633032323465222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3166666b727a79727236723973673978653472373676366c74613367366d757676706a65667a75646e307635653068343566686c713265646b6179227d
1962	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313936322c2268617368223a2264323637306636623165666532613565653934336631613134303031303965656532386531343433323266343061373838626466376666336335626532393635222c22736c6f74223a31393132307d2c22697373756572566b223a2265323466353662353837316433633939376661356232343938643466333766333564343931613330386236383062666664333431386234363161623831393233222c2270726576696f7573426c6f636b223a2265613037343838373336643035626163613335366663336338346163663536376463353665333039636532623239353039333634303138373735303034303330222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e3363727973676539657a6d6165383866726b7066346635743736686c6b6d64796b3378666568336a7877706773616a757130736c796e723930227d
1963	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b654b6579526567697374726174696f6e4365727469666963617465222c227374616b654b657948617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832227d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731353733227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2266656233383635356535376237643239356265656562366636303132323262626332646333333661633334346437363739623735333737353033313765316133227d2c7b22696e646578223a312c2274784964223a2266656233383635356535376237643239356265656562366636303132323262626332646333333661633334346437363739623735333737353033313765316133227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936363438353338227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a32303536307d2c227769746864726177616c73223a5b5d7d2c226964223a2239313639303738333364383932366430663666383163626666623661613532623830643437333166336336633632363536646265383563316436313730663434222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223135643332336632303566666163346138313762346662623431306631346361303732303161643730363664643566306533646465616361313963343738333731386530656233643234353135646632613732626238336338303835623864613464383633326437376630383230613062373262363936663564366465633062225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731353733227d2c22686561646572223a7b22626c6f636b4e6f223a313936332c2268617368223a2263356461613934333765643766346233343664663731393232313662323533373637343535303961306266623731343932386239656536656231656466373238222c22736c6f74223a31393134357d2c22697373756572566b223a2235643737363830323038343663306631343933633063326631326365363833653535613235396165306532363231373164626633383762653661333832623036222c2270726576696f7573426c6f636b223a2264323637306636623165666532613565653934336631613134303031303965656532386531343433323266343061373838626466376666336335626532393635222c2273697a65223a3336352c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939363438353338227d2c227478436f756e74223a312c22767266223a227672665f766b31307530306636713033636372786c6761716e6870377076326679706474797568733035666e7036706d666a7979766874613335716a3966646a37227d
1964	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313936342c2268617368223a2231663665616366646232313338633933353461633239313536633934666633373733373938663431353162356331333161363163663261656135366464633161222c22736c6f74223a31393134377d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2263356461613934333765643766346233343664663731393232313662323533373637343535303961306266623731343932386239656536656231656466373238222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1965	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313936352c2268617368223a2231373336626134306131336538303065663936623563303131666634633236326636363030366536343965646539303435623864396135653830306364386365222c22736c6f74223a31393135317d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2231663665616366646232313338633933353461633239313536633934666633373733373938663431353162356331333161363163663261656135366464633161222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1966	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313936362c2268617368223a2264393438376135633839323634326533653738653430366639356437376535626137663531623236316362663739663033393334363937643832613436623564222c22736c6f74223a31393135327d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2231373336626134306131336538303065663936623563303131666634633236326636363030366536343965646539303435623864396135653830306364386365222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1967	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313936372c2268617368223a2230613838633262646234303836356532313031343565333066643162306465323439623365633965336263303664306430346631666331366330313166336263222c22736c6f74223a31393135337d2c22697373756572566b223a2235643737363830323038343663306631343933633063326631326365363833653535613235396165306532363231373164626633383762653661333832623036222c2270726576696f7573426c6f636b223a2264393438376135633839323634326533653738653430366639356437376535626137663531623236316362663739663033393334363937643832613436623564222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31307530306636713033636372786c6761716e6870377076326679706474797568733035666e7036706d666a7979766874613335716a3966646a37227d
1968	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c227374616b654b657948617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832227d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313735373533227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2239313639303738333364383932366430663666383163626666623661613532623830643437333166336336633632363536646265383563316436313730663434227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393933343732373835227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a32303539337d2c227769746864726177616c73223a5b5d7d2c226964223a2263386132303465366362326635376435303362353731356465613933383539653738636231356332336538633535316430626261353037326137336535623663222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223461646665323633613936613235633263323337373466626232623935623933646533616534633962356665356234346565626534656337613636316239623331363332643339656166323237363262316338653237383564326436326263626537373238356361643266336561313561373263363266663363626532643035225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c223137393361616131306366613537386133633732323330313165363235663235323730623039653232343065306434626463353464393839306533363835666436343164303232333762393339346135663763333538653263383430336566643334386638346433383232313366386233313266363233333835643236303064225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313735373533227d2c22686561646572223a7b22626c6f636b4e6f223a313936382c2268617368223a2239303535393038383262303432363738623465623632643732313132636135656366363832633439383661666538393932376438656234333265393338383566222c22736c6f74223a31393135347d2c22697373756572566b223a2235643737363830323038343663306631343933633063326631326365363833653535613235396165306532363231373164626633383762653661333832623036222c2270726576696f7573426c6f636b223a2230613838633262646234303836356532313031343565333066643162306465323439623365633965336263303664306430346631666331366330313166336263222c2273697a65223a3436302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936343732373835227d2c227478436f756e74223a312c22767266223a227672665f766b31307530306636713033636372786c6761716e6870377076326679706474797568733035666e7036706d666a7979766874613335716a3966646a37227d
1969	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313936392c2268617368223a2233663039663763353938303237396235616333653865643137303865353738633162373637636563323932366162353564653964393530353232666636663936222c22736c6f74223a31393136357d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2239303535393038383262303432363738623465623632643732313132636135656366363832633439383661666538393932376438656234333265393338383566222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1970	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313937302c2268617368223a2233316265626164363133626638363366323062333631643230343863643039356338313237613936393733323063653036343833346363373436366536646537222c22736c6f74223a31393137337d2c22697373756572566b223a2265653031306234303535616364306663626430373933343864306335616564376265623132343263383933396139613939363464376530343362356564333039222c2270726576696f7573426c6f636b223a2233663039663763353938303237396235616333653865643137303865353738633162373637636563323932366162353564653964393530353232666636663936222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3139776e6377306d7364777a336e726c6476676637676a6732386c616a30666b6b65386870636d6d73326471713778346533616571613863797866227d
1971	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313937312c2268617368223a2233366464313234363165393434323630633761636532633663383964303331376563313233336237373538613762633831323337656133393731343732356331222c22736c6f74223a31393137347d2c22697373756572566b223a2265323466353662353837316433633939376661356232343938643466333766333564343931613330386236383062666664333431386234363161623831393233222c2270726576696f7573426c6f636b223a2233316265626164363133626638363366323062333631643230343863643039356338313237613936393733323063653036343833346363373436366536646537222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e3363727973676539657a6d6165383866726b7066346635743736686c6b6d64796b3378666568336a7877706773616a757130736c796e723930227d
1972	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b226964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c22767266223a2236343164303432656433396332633235386433383130363063313432346634306566386162666532356566353636663463623232343737633432623261303134222c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223530303030303030227d2c22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c227265776172644163636f756e74223a227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576222c226f776e657273223a5b227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576225d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e32222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d7d7d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313832373035227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2236323465623338313961333534336334366333323634313463313863343333393234383764663530336336333831303261376531326332656530343439333962227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961343436663735363236633635343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2232227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396134383635366336633666343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613534363537333734343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383137323935227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a32303631347d2c227769746864726177616c73223a5b5d7d2c226964223a2235323461396433366562343437326532383437306631323561343166313231333536353739353839633661393462646436336434613335383335633835323166222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c226232646435623562643238383638313164663131383034626362366663306162313833653666316661643635643930363836613033343566303061386234376232316638613432633231663235656337313361313861613064616265326462326366656437626137336137333635616661336566613564626166343565333037225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c226634633434313439376162633031363235613763343939396262613131373761373265656537393534373762633237363230653362376530643965316531396663643534626138636663343135633535336563323666363635396366623330626434383466383261313661643537616261613065633832643636303833303030225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313832373035227d2c22686561646572223a7b22626c6f636b4e6f223a313937322c2268617368223a2231363037306462333639353331393732656238653638366663643732346334366136653934636631336465323531363535346431666131356638333132303332222c22736c6f74223a31393138327d2c22697373756572566b223a2265653031306234303535616364306663626430373933343864306335616564376265623132343263383933396139613939363464376530343362356564333039222c2270726576696f7573426c6f636b223a2233366464313234363165393434323630633761636532633663383964303331376563313233336237373538613762633831323337656133393731343732356331222c2273697a65223a3631382c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383137323935227d2c227478436f756e74223a312c22767266223a227672665f766b3139776e6377306d7364777a336e726c6476676637676a6732386c616a30666b6b65386870636d6d73326471713778346533616571613863797866227d
1973	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313937332c2268617368223a2234383835393262336162653437333138353736633766303535636231343733373431343731386463616464663065333937366465623837636330613136383765222c22736c6f74223a31393230367d2c22697373756572566b223a2237646562636131623962626238633239336532643939613831366632366138366665313866336464643832306664643233616437393631633934656234333431222c2270726576696f7573426c6f636b223a2231363037306462333639353331393732656238653638366663643732346334366136653934636631336465323531363535346431666131356638333132303332222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c726e796e6d7966647577686e75786165386139307a7271706e6a347236367639766e786c39617775633734387a363638646871377777756a71227d
1974	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313937342c2268617368223a2239633637333836313561646662346266626239393065386361386366353835363165323538616262646235303333616264353464633632323538303137353930222c22736c6f74223a31393232307d2c22697373756572566b223a2239376261313264616361363732663130346332636164636363626233356639306138303762386365363766643337343765386261666362303935633336346638222c2270726576696f7573426c6f636b223a2234383835393262336162653437333138353736633766303535636231343733373431343731386463616464663065333937366465623837636330613136383765222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773877336576717163787a716b616b38667a6570393934337777616e6b7379736367366d6372666e39676865736e63777565747130736c657176227d
1975	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313937352c2268617368223a2235363266646136343034616561343663376332663561656533623839616361313665363165613836356261636235306534353064326464373932313234366336222c22736c6f74223a31393232367d2c22697373756572566b223a2235643737363830323038343663306631343933633063326631326365363833653535613235396165306532363231373164626633383762653661333832623036222c2270726576696f7573426c6f636b223a2239633637333836313561646662346266626239393065386361386366353835363165323538616262646235303333616264353464633632323538303137353930222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31307530306636713033636372786c6761716e6870377076326679706474797568733035666e7036706d666a7979766874613335716a3966646a37227d
1976	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b654b6579526567697374726174696f6e4365727469666963617465222c227374616b654b657948617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732227d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731353733227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2235323461396433366562343437326532383437306631323561343166313231333536353739353839633661393462646436336434613335383335633835323166227d2c7b22696e646578223a342c2274784964223a2235356236396662366636353063656335613736336333376662646331646232313966396234323266313766623333356662633735666266656631336436333031227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383238343237227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a32303636367d2c227769746864726177616c73223a5b5d7d2c226964223a2231333063393438353635613064653639373539323431306166633338353565303162316166313331303832636631666535633433353630363337356638323731222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223937313665636237656232396139376632663835613739323431356535373032386139386532373431666362653032646232356132346532333833653464333665623562376134656439623864303232373663633039386130643231653861626664336635653562373861396636313532323562363334323764623161363064225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731353733227d2c22686561646572223a7b22626c6f636b4e6f223a313937362c2268617368223a2235633935336463306264336632613937313530323237633032646632393930373936333732336336386333376665393063356665356364343461623263396462222c22736c6f74223a31393233367d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2235363266646136343034616561343663376332663561656533623839616361313665363165613836356261636235306534353064326464373932313234366336222c2273697a65223a3336352c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2235303030303032383238343237227d2c227478436f756e74223a312c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1977	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313937372c2268617368223a2232613064363166336361363636373930366533396235373631393463653639303163643666653134323339653563383666613163623834363838356631313034222c22736c6f74223a31393234337d2c22697373756572566b223a2264653039343431393139333733623762363964643663346134333030623765306632316536313866323839323766333537386632346236613537646630373930222c2270726576696f7573426c6f636b223a2235633935336463306264336632613937313530323237633032646632393930373936333732336336386333376665393063356665356364343461623263396462222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137756d7163393836756b78663536777032343537713235396667617277677763767939657576756e376d61757970347a786a3071776a74326572227d
1978	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313937382c2268617368223a2234386332626130333863623531616131396133333437663534633164616637326237333231653235393036633564616436373436333261333061643061366639222c22736c6f74223a31393234397d2c22697373756572566b223a2239376261313264616361363732663130346332636164636363626233356639306138303762386365363766643337343765386261666362303935633336346638222c2270726576696f7573426c6f636b223a2232613064363166336361363636373930366533396235373631393463653639303163643666653134323339653563383666613163623834363838356631313034222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773877336576717163787a716b616b38667a6570393934337777616e6b7379736367366d6372666e39676865736e63777565747130736c657176227d
1979	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313937392c2268617368223a2263316330323639353831376261616361316264353737663936626535396631646462623535323662323134643965363233346331626239303431653061343934222c22736c6f74223a31393235337d2c22697373756572566b223a2237646562636131623962626238633239336532643939613831366632366138366665313866336464643832306664643233616437393631633934656234333431222c2270726576696f7573426c6f636b223a2234386332626130333863623531616131396133333437663534633164616637326237333231653235393036633564616436373436333261333061643061366639222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c726e796e6d7966647577686e75786165386139307a7271706e6a347236367639766e786c39617775633734387a363638646871377777756a71227d
1903	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930332c2268617368223a2231363032346432386137333738656135663664303834653637613239343462623764663665656162313361383837366432633139353865663530653566396661222c22736c6f74223a31383533337d2c22697373756572566b223a2265323466353662353837316433633939376661356232343938643466333766333564343931613330386236383062666664333431386234363161623831393233222c2270726576696f7573426c6f636b223a2235386162333866636466643237353935346133396438333163366535356436626532363537643336656465383965316630353065623633313132316461323866222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e3363727973676539657a6d6165383866726b7066346635743736686c6b6d64796b3378666568336a7877706773616a757130736c796e723930227d
1904	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930342c2268617368223a2233663133343161373338613965633866356132643634356633623266623863363164326362653961616161336236643865323735376230393336303763363532222c22736c6f74223a31383533387d2c22697373756572566b223a2239376261313264616361363732663130346332636164636363626233356639306138303762386365363766643337343765386261666362303935633336346638222c2270726576696f7573426c6f636b223a2231363032346432386137333738656135663664303834653637613239343462623764663665656162313361383837366432633139353865663530653566396661222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773877336576717163787a716b616b38667a6570393934337777616e6b7379736367366d6372666e39676865736e63777565747130736c657176227d
1905	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930352c2268617368223a2238353432613134336532636662353035313538383334363731306164666231363465666338633537383932656564666663353732616133353363373462303337222c22736c6f74223a31383534357d2c22697373756572566b223a2265653031306234303535616364306663626430373933343864306335616564376265623132343263383933396139613939363464376530343362356564333039222c2270726576696f7573426c6f636b223a2233663133343161373338613965633866356132643634356633623266623863363164326362653961616161336236643865323735376230393336303763363532222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3139776e6377306d7364777a336e726c6476676637676a6732386c616a30666b6b65386870636d6d73326471713778346533616571613863797866227d
1906	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930362c2268617368223a2231653236646264613930616630616566306332303866643830626663383537303931653334663264303961356466333939373565303163313237353431313361222c22736c6f74223a31383535327d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2238353432613134336532636662353035313538383334363731306164666231363465666338633537383932656564666663353732616133353363373462303337222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1907	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930372c2268617368223a2263316134393163363963376133363230373564323631336464623461353437373236326366353966356233323530633038323837303039623330376436646637222c22736c6f74223a31383536317d2c22697373756572566b223a2264653039343431393139333733623762363964643663346134333030623765306632316536313866323839323766333537386632346236613537646630373930222c2270726576696f7573426c6f636b223a2231653236646264613930616630616566306332303866643830626663383537303931653334663264303961356466333939373565303163313237353431313361222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137756d7163393836756b78663536777032343537713235396667617277677763767939657576756e376d61757970347a786a3071776a74326572227d
1908	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930382c2268617368223a2239333366643337663132613936313163363930383535663334373365656337643735643864616461303138313934643135613830313362616631626230623365222c22736c6f74223a31383536367d2c22697373756572566b223a2265653031306234303535616364306663626430373933343864306335616564376265623132343263383933396139613939363464376530343362356564333039222c2270726576696f7573426c6f636b223a2263316134393163363963376133363230373564323631336464623461353437373236326366353966356233323530633038323837303039623330376436646637222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3139776e6377306d7364777a336e726c6476676637676a6732386c616a30666b6b65386870636d6d73326471713778346533616571613863797866227d
1909	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930392c2268617368223a2237653932383765363335633239396138323637303032376338623666306131336235663733396431613737333338393065363837353862656664393562633666222c22736c6f74223a31383537377d2c22697373756572566b223a2237646562636131623962626238633239336532643939613831366632366138366665313866336464643832306664643233616437393631633934656234333431222c2270726576696f7573426c6f636b223a2239333366643337663132613936313163363930383535663334373365656337643735643864616461303138313934643135613830313362616631626230623365222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c726e796e6d7966647577686e75786165386139307a7271706e6a347236367639766e786c39617775633734387a363638646871377777756a71227d
1910	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931302c2268617368223a2237336536653831323765623634346464626430333364626338663735616332373162323533363965323239663732323835616238313837393264383363373366222c22736c6f74223a31383538367d2c22697373756572566b223a2237646562636131623962626238633239336532643939613831366632366138366665313866336464643832306664643233616437393631633934656234333431222c2270726576696f7573426c6f636b223a2237653932383765363335633239396138323637303032376338623666306131336235663733396431613737333338393065363837353862656664393562633666222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c726e796e6d7966647577686e75786165386139307a7271706e6a347236367639766e786c39617775633734387a363638646871377777756a71227d
1911	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931312c2268617368223a2238336338353361343166393563616463376264306135366432633232323033316164643931373638303937353532343932333337313763666335366234666562222c22736c6f74223a31383538387d2c22697373756572566b223a2239376261313264616361363732663130346332636164636363626233356639306138303762386365363766643337343765386261666362303935633336346638222c2270726576696f7573426c6f636b223a2237336536653831323765623634346464626430333364626338663735616332373162323533363965323239663732323835616238313837393264383363373366222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773877336576717163787a716b616b38667a6570393934337777616e6b7379736367366d6372666e39676865736e63777565747130736c657176227d
1912	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931322c2268617368223a2239343437386162353637313238363163663330363634666231643933326235323936323736303564643464346165653538666435633665663234326539366661222c22736c6f74223a31383630307d2c22697373756572566b223a2231396339323132643936656261323832643632633436643662313231356163653763333536343535383234303230326662643563303463643133313636663639222c2270726576696f7573426c6f636b223a2238336338353361343166393563616463376264306135366432633232323033316164643931373638303937353532343932333337313763666335366234666562222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31746a7037363334666b6b36743974716e32676e346e766b6371677138716177736b793471306664616736756178363474617678713863656b7963227d
1913	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931332c2268617368223a2266636435636366303766323938396639636235336530356339623462346162646466316434326562363137373638643835613733353661363165393161303266222c22736c6f74223a31383634377d2c22697373756572566b223a2239376261313264616361363732663130346332636164636363626233356639306138303762386365363766643337343765386261666362303935633336346638222c2270726576696f7573426c6f636b223a2239343437386162353637313238363163663330363634666231643933326235323936323736303564643464346165653538666435633665663234326539366661222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773877336576717163787a716b616b38667a6570393934337777616e6b7379736367366d6372666e39676865736e63777565747130736c657176227d
1980	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c227374616b654b657948617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732227d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313735373533227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2231333063393438353635613064653639373539323431306166633338353565303162316166313331303832636631666535633433353630363337356638323731227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936363532363734227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a32303639337d2c227769746864726177616c73223a5b5d7d2c226964223a2238626565383263633363336565666561663035343163373134646165363738343765313665323261656533373731636132626331393339316435363037306534222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c223061373739333635616162396530346462643330396363646238643439313132373032336235386235626635623638373361633962636331366663383537386336616436633237656232633532643362663634313863373734396564626631646364666166393834656264333032613435643964363331663838363835313063225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c226136316265616664323763393363366635313439343432313933633532343333303464316364383765346162613739643437353936616463393837333864363733646531386532353936616439323337663562393361623663346436383334343535653763353863666135626466343839383732346564393364376137663036225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313735373533227d2c22686561646572223a7b22626c6f636b4e6f223a313938302c2268617368223a2231653366353961336433333465393034313062323061353363643432633934313237656631633962643466386164623839323535366164346336336430353534222c22736c6f74223a31393236317d2c22697373756572566b223a2265323466353662353837316433633939376661356232343938643466333766333564343931613330386236383062666664333431386234363161623831393233222c2270726576696f7573426c6f636b223a2263316330323639353831376261616361316264353737663936626535396631646462623535323662323134643965363233346331626239303431653061343934222c2273697a65223a3436302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939363532363734227d2c227478436f756e74223a312c22767266223a227672665f766b316e3363727973676539657a6d6165383866726b7066346635743736686c6b6d64796b3378666568336a7877706773616a757130736c796e723930227d
1981	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313938312c2268617368223a2233353738323938323762373561393362393436323132303536363739303661613134646431353930323663633032613431376435393631376663343335633033222c22736c6f74223a31393236347d2c22697373756572566b223a2235643737363830323038343663306631343933633063326631326365363833653535613235396165306532363231373164626633383762653661333832623036222c2270726576696f7573426c6f636b223a2231653366353961336433333465393034313062323061353363643432633934313237656631633962643466386164623839323535366164346336336430353534222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31307530306636713033636372786c6761716e6870377076326679706474797568733035666e7036706d666a7979766874613335716a3966646a37227d
1982	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313938322c2268617368223a2233616131663534393936333564626237383138613163643264623138653036613264346136343066303033386137343934663766346464653366643038376431222c22736c6f74223a31393236367d2c22697373756572566b223a2235643737363830323038343663306631343933633063326631326365363833653535613235396165306532363231373164626633383762653661333832623036222c2270726576696f7573426c6f636b223a2233353738323938323762373561393362393436323132303536363739303661613134646431353930323663633032613431376435393631376663343335633033222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31307530306636713033636372786c6761716e6870377076326679706474797568733035666e7036706d666a7979766874613335716a3966646a37227d
1983	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313938332c2268617368223a2265373165646335396135326237643666363331303331346431623433623331333832386262393138336631303433393163636264376461626530666436363864222c22736c6f74223a31393237317d2c22697373756572566b223a2237646562636131623962626238633239336532643939613831366632366138366665313866336464643832306664643233616437393631633934656234333431222c2270726576696f7573426c6f636b223a2233616131663534393936333564626237383138613163643264623138653036613264346136343066303033386137343934663766346464653366643038376431222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c726e796e6d7966647577686e75786165386139307a7271706e6a347236367639766e786c39617775633734387a363638646871377777756a71227d
1890	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839302c2268617368223a2262353332373230353465303265383735363830646334343530623565396537306562353435333231323763376161633230616236643732383536386261336332222c22736c6f74223a31383432327d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2265346531346237376236306437613061383061326134616533353039643065643366303862306262376135373332396532323535356138333266633739633630222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1891	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839312c2268617368223a2238333261643039636330323162323365386137663564343339333830633732333237633536363933393038663333643863376530376366353064353835353435222c22736c6f74223a31383433307d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2262353332373230353465303265383735363830646334343530623565396537306562353435333231323763376161633230616236643732383536386261336332222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1892	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839322c2268617368223a2238373861323134396562353531306363326262613266306562393431636265623138643662396138663366623633356339623131646537366437623333623430222c22736c6f74223a31383434327d2c22697373756572566b223a2235643737363830323038343663306631343933633063326631326365363833653535613235396165306532363231373164626633383762653661333832623036222c2270726576696f7573426c6f636b223a2238333261643039636330323162323365386137663564343339333830633732333237633536363933393038663333643863376530376366353064353835353435222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31307530306636713033636372786c6761716e6870377076326679706474797568733035666e7036706d666a7979766874613335716a3966646a37227d
1893	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839332c2268617368223a2262663736633864626430303265306137326265653964623737653136633438396439323634393030623733316134636366316432363630643933613932663636222c22736c6f74223a31383434347d2c22697373756572566b223a2237646562636131623962626238633239336532643939613831366632366138366665313866336464643832306664643233616437393631633934656234333431222c2270726576696f7573426c6f636b223a2238373861323134396562353531306363326262613266306562393431636265623138643662396138663366623633356339623131646537366437623333623430222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c726e796e6d7966647577686e75786165386139307a7271706e6a347236367639766e786c39617775633734387a363638646871377777756a71227d
1894	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839342c2268617368223a2263666436303937316237656135313233613835326236633266666135376365373939356265343764373966643933623136653265313864643363633961343463222c22736c6f74223a31383434357d2c22697373756572566b223a2265653031306234303535616364306663626430373933343864306335616564376265623132343263383933396139613939363464376530343362356564333039222c2270726576696f7573426c6f636b223a2262663736633864626430303265306137326265653964623737653136633438396439323634393030623733316134636366316432363630643933613932663636222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3139776e6377306d7364777a336e726c6476676637676a6732386c616a30666b6b65386870636d6d73326471713778346533616571613863797866227d
1895	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839352c2268617368223a2234376331303534306664636261613761616232663333326366363765366430363463613562656136353162653338656538353937363430393933343337343536222c22736c6f74223a31383435337d2c22697373756572566b223a2265653031306234303535616364306663626430373933343864306335616564376265623132343263383933396139613939363464376530343362356564333039222c2270726576696f7573426c6f636b223a2263666436303937316237656135313233613835326236633266666135376365373939356265343764373966643933623136653265313864643363633961343463222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3139776e6377306d7364777a336e726c6476676637676a6732386c616a30666b6b65386870636d6d73326471713778346533616571613863797866227d
1896	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839362c2268617368223a2232663431353834313464306133323632623635623338313936353736663031613030376632343139653564306163396463333131623539363833373635393061222c22736c6f74223a31383437317d2c22697373756572566b223a2264653039343431393139333733623762363964643663346134333030623765306632316536313866323839323766333537386632346236613537646630373930222c2270726576696f7573426c6f636b223a2234376331303534306664636261613761616232663333326366363765366430363463613562656136353162653338656538353937363430393933343337343536222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137756d7163393836756b78663536777032343537713235396667617277677763767939657576756e376d61757970347a786a3071776a74326572227d
1897	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839372c2268617368223a2233646437626362646339373466313661633666313163303130643463303039343463633862363765316635626438346565323165343666373238653331383234222c22736c6f74223a31383437367d2c22697373756572566b223a2264653039343431393139333733623762363964643663346134333030623765306632316536313866323839323766333537386632346236613537646630373930222c2270726576696f7573426c6f636b223a2232663431353834313464306133323632623635623338313936353736663031613030376632343139653564306163396463333131623539363833373635393061222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137756d7163393836756b78663536777032343537713235396667617277677763767939657576756e376d61757970347a786a3071776a74326572227d
1898	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839382c2268617368223a2238643139663739643032313639613738333630363965633833643430346336353665346633363431623837303339616164393637633362633265396562653232222c22736c6f74223a31383438317d2c22697373756572566b223a2239376261313264616361363732663130346332636164636363626233356639306138303762386365363766643337343765386261666362303935633336346638222c2270726576696f7573426c6f636b223a2233646437626362646339373466313661633666313163303130643463303039343463633862363765316635626438346565323165343666373238653331383234222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773877336576717163787a716b616b38667a6570393934337777616e6b7379736367366d6372666e39676865736e63777565747130736c657176227d
1899	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839392c2268617368223a2237643434306664643436663635313338366534373465363433646132643032373030306264333164323861313764633661666162383161303862646435656261222c22736c6f74223a31383439387d2c22697373756572566b223a2265653031306234303535616364306663626430373933343864306335616564376265623132343263383933396139613939363464376530343362356564333039222c2270726576696f7573426c6f636b223a2238643139663739643032313639613738333630363965633833643430346336353665346633363431623837303339616164393637633362633265396562653232222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3139776e6377306d7364777a336e726c6476676637676a6732386c616a30666b6b65386870636d6d73326471713778346533616571613863797866227d
1900	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930302c2268617368223a2235653465326430653237393039363430346630373666646561613563646539373563626437633062663739636239636165663734336632333939623163383038222c22736c6f74223a31383530317d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2237643434306664643436663635313338366534373465363433646132643032373030306264333164323861313764633661666162383161303862646435656261222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1901	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930312c2268617368223a2239316138333835326333386633383435633038633031353961363161383363393736613061393332356662663865323063623230316465383164353162306634222c22736c6f74223a31383530387d2c22697373756572566b223a2261383561393833373033396236623566316664626665373431303236663938316134343664613736376438653064643031643564316666663039323439363565222c2270726576696f7573426c6f636b223a2235653465326430653237393039363430346630373666646561613563646539373563626437633062663739636239636165663734336632333939623163383038222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3166666b727a79727236723973673978653472373676366c74613367366d757676706a65667a75646e307635653068343566686c713265646b6179227d
1902	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930322c2268617368223a2235386162333866636466643237353935346133396438333163366535356436626532363537643336656465383965316630353065623633313132316461323866222c22736c6f74223a31383532327d2c22697373756572566b223a2261383561393833373033396236623566316664626665373431303236663938316134343664613736376438653064643031643564316666663039323439363565222c2270726576696f7573426c6f636b223a2239316138333835326333386633383435633038633031353961363161383363393736613061393332356662663865323063623230316465383164353162306634222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3166666b727a79727236723973673978653472373676366c74613367366d757676706a65667a75646e307635653068343566686c713265646b6179227d
1914	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931342c2268617368223a2262653835316636653136613334343835303634323738323735656530383061373761613836663063666662613332363333656561656533396566346261626332222c22736c6f74223a31383634387d2c22697373756572566b223a2237646562636131623962626238633239336532643939613831366632366138366665313866336464643832306664643233616437393631633934656234333431222c2270726576696f7573426c6f636b223a2266636435636366303766323938396639636235336530356339623462346162646466316434326562363137373638643835613733353661363165393161303266222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c726e796e6d7966647577686e75786165386139307a7271706e6a347236367639766e786c39617775633734387a363638646871377777756a71227d
1915	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931352c2268617368223a2237643131626533386233383863326161313934396532343730306461613363316565303065326430353864663337316532373038643566373736663931313866222c22736c6f74223a31383636317d2c22697373756572566b223a2234346532626435643735366363356637663864303065373536366364616462633531336137336336333832643461326537376665393230626566653639656332222c2270726576696f7573426c6f636b223a2262653835316636653136613334343835303634323738323735656530383061373761613836663063666662613332363333656561656533396566346261626332222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7a7630726a3939307335796a663478723633617435776768757368636730366d326372723935726a3668707a3979797a6e6d716a6136683371227d
1916	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931362c2268617368223a2232616130353466643039366239306663353061653332343033303562353938316436343236363538653936643663393039336133303364386264363035303465222c22736c6f74223a31383638317d2c22697373756572566b223a2265323466353662353837316433633939376661356232343938643466333766333564343931613330386236383062666664333431386234363161623831393233222c2270726576696f7573426c6f636b223a2237643131626533386233383863326161313934396532343730306461613363316565303065326430353864663337316532373038643566373736663931313866222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e3363727973676539657a6d6165383866726b7066346635743736686c6b6d64796b3378666568336a7877706773616a757130736c796e723930227d
1917	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931372c2268617368223a2238373632316664633031333433356638656336356263616362346561353863313333366661646537373761663838663133396438366664633834616666656665222c22736c6f74223a31383639367d2c22697373756572566b223a2235643737363830323038343663306631343933633063326631326365363833653535613235396165306532363231373164626633383762653661333832623036222c2270726576696f7573426c6f636b223a2232616130353466643039366239306663353061653332343033303562353938316436343236363538653936643663393039336133303364386264363035303465222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31307530306636713033636372786c6761716e6870377076326679706474797568733035666e7036706d666a7979766874613335716a3966646a37227d
1918	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931382c2268617368223a2265646438643535386132313235383761396639366435306230383833346464643332656233316234633233663633393835313137383237383536316661363233222c22736c6f74223a31383730307d2c22697373756572566b223a2231396339323132643936656261323832643632633436643662313231356163653763333536343535383234303230326662643563303463643133313636663639222c2270726576696f7573426c6f636b223a2238373632316664633031333433356638656336356263616362346561353863313333366661646537373761663838663133396438366664633834616666656665222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31746a7037363334666b6b36743974716e32676e346e766b6371677138716177736b793471306664616736756178363474617678713863656b7963227d
1919	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931392c2268617368223a2235326132383938396132666664653833393432653330653631363431336635373362663137356362623463393532666636656664393663363436393830303238222c22736c6f74223a31383732317d2c22697373756572566b223a2239376261313264616361363732663130346332636164636363626233356639306138303762386365363766643337343765386261666362303935633336346638222c2270726576696f7573426c6f636b223a2265646438643535386132313235383761396639366435306230383833346464643332656233316234633233663633393835313137383237383536316661363233222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773877336576717163787a716b616b38667a6570393934337777616e6b7379736367366d6372666e39676865736e63777565747130736c657176227d
1920	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932302c2268617368223a2237336436646534646230626535396536656261356661646366656531646537356464363037316661613766333165633434376164343431316135303064393163222c22736c6f74223a31383733327d2c22697373756572566b223a2239376261313264616361363732663130346332636164636363626233356639306138303762386365363766643337343765386261666362303935633336346638222c2270726576696f7573426c6f636b223a2235326132383938396132666664653833393432653330653631363431336635373362663137356362623463393532666636656664393663363436393830303238222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773877336576717163787a716b616b38667a6570393934337777616e6b7379736367366d6372666e39676865736e63777565747130736c657176227d
1921	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932312c2268617368223a2238396533356136373730343665643133653037373962393535653238333536633532373434323266373733353065363833363738353739653239393638393566222c22736c6f74223a31383733387d2c22697373756572566b223a2237646562636131623962626238633239336532643939613831366632366138366665313866336464643832306664643233616437393631633934656234333431222c2270726576696f7573426c6f636b223a2237336436646534646230626535396536656261356661646366656531646537356464363037316661613766333165633434376164343431316135303064393163222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c726e796e6d7966647577686e75786165386139307a7271706e6a347236367639766e786c39617775633734387a363638646871377777756a71227d
\.


--
-- Data for Name: current_pool_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_pool_metrics (stake_pool_id, slot, minted_blocks, live_delegators, active_stake, live_stake, live_pledge, live_saturation, active_size, live_size, apy) FROM stdin;
pool1sjkahau820nfmgf3c703p8h70xnc2ckqhlhtgwmrjxfzs744tmh	9367	90	2	3694865278748427	3694865278748427	300000000	4.4989082427971665	1	0	0
pool1efkpr4fnmxhe73xj47puagzqwtv23ucpt0fkuhgx249j6vpqxk4	9367	100	2	3732905174637911	3737969513691456	500000000	4.551392429162507	0.998645163093226	0.0013548369067739596	0
pool1k0hksc077c0jxjpgvhuvguat8jlv2r8xfxpa5vr6c4cz6m0jah4	9367	93	2	3725752914654058	3731945022133058	5456653052886	4.544056942565302	0.9983407827708403	0.0016592172291597374	0
pool1xl0v3fejd56e9txg5xld5k49he3dujgzacf0chz7sql0yx5h7rv	9367	88	2	3722594455933886	3728800005708793	5341054338084	4.540227536281874	0.9983357783293804	0.0016642216706196367	0
pool1juahqjshmvjctnu5mz8s9rfkcxhre4mlqyn8zwl670dfsqlkdcd	9367	91	2	3700564195598559	3700564195598559	200391353	4.505847306080351	1	0	0
pool1mkw72p4vv6pjvmptynat4d7w82lfhjjkq2vudu5pxwwawm5k4wp	9367	111	2	3736858791984620	3745282891788829	6491979860726	4.560297278060302	0.9977507440565629	0.0022492559434370563	0
pool10zg0pmcg4k2dqt2effxrff4zzqsu43dsdw3e8cvh69ct5n73d4c	9367	98	2	3731273874142039	3738024687349767	5769248626638	4.551459609210339	0.9981940158847602	0.0018059841152398004	0
pool1q3gwfchl2ehtumuhka45xfzf86vy6wratwunt8zqq6qaxkypra5	9367	92	2	3718139054926080	3724909441151551	4264240072373	4.535490342464176	0.9981824024630843	0.0018175975369156827	0
pool1vj30jr7wn83dzn928qk6fx34h3d3f3cesr47j5ymeumf65wdw9x	9367	98	2	3723609452993897	3733752259457543	5115793207886	4.546257454433103	0.9972834816670135	0.002716518332986473	0
pool1tgt2slr29xkx44ec6yzgk04uvq8n58m397l9hahc2r4u5kwh3x0	9367	77	2	0	3695689661012696	300000000	4.499912019629103	0	1	0
pool1l8echf2amze2xcatzn2lyyyp7zhm9s5r2hmy6gdw7pupzsz9wy9	9367	63	2	0	3724978667678108	500000000	4.535574633437582	0	1	0
\.


--
-- Data for Name: pool_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata (id, ticker, name, description, homepage, hash, ext, stake_pool_id, pool_update_id) FROM stdin;
1	SP1	stake pool - 1	This is the stake pool 1 description.	https://stakepool1.com	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	\N	pool1k0hksc077c0jxjpgvhuvguat8jlv2r8xfxpa5vr6c4cz6m0jah4	880000000000
2	SP3	Stake Pool - 3	This is the stake pool 3 description.	https://stakepool3.com	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	\N	pool1juahqjshmvjctnu5mz8s9rfkcxhre4mlqyn8zwl670dfsqlkdcd	2760000000000
3	SP4	Same Name	This is the stake pool 4 description.	https://stakepool4.com	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	\N	pool1mkw72p4vv6pjvmptynat4d7w82lfhjjkq2vudu5pxwwawm5k4wp	3510000000000
4	SP6a7		This is the stake pool 7 description.	https://stakepool7.com	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	\N	pool1vj30jr7wn83dzn928qk6fx34h3d3f3cesr47j5ymeumf65wdw9x	5940000000000
5	SP10	Stake Pool - 10	This is the stake pool 10 description.	https://stakepool10.com	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	\N	pool1l8echf2amze2xcatzn2lyyyp7zhm9s5r2hmy6gdw7pupzsz9wy9	9660000000000
6	SP11	Stake Pool - 10 + 1	This is the stake pool 11 description.	https://stakepool11.com	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	\N	pool1efkpr4fnmxhe73xj47puagzqwtv23ucpt0fkuhgx249j6vpqxk4	11150000000000
7	SP5	Same Name	This is the stake pool 5 description.	https://stakepool5.com	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	\N	pool10zg0pmcg4k2dqt2effxrff4zzqsu43dsdw3e8cvh69ct5n73d4c	4290000000000
8	SP6a7	Stake Pool - 6	This is the stake pool 6 description.	https://stakepool6.com	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	\N	pool1q3gwfchl2ehtumuhka45xfzf86vy6wratwunt8zqq6qaxkypra5	5290000000000
\.


--
-- Data for Name: pool_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_registration (id, reward_account, pledge, cost, margin, margin_percent, relays, owners, vrf, metadata_url, metadata_hash, stake_pool_id, block_slot) FROM stdin;
880000000000	stake_test1uqlvquz7pfptplxnuj3sw8gwxqn6tee4gljgxr3s7lver2q4urmhl	400000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3001, "__typename": "RelayByAddress"}]	["stake_test1uqlvquz7pfptplxnuj3sw8gwxqn6tee4gljgxr3s7lver2q4urmhl"]	464527a63d491cdf8c30825c9a04982edc2e3091c713e0ec906dacefbfe0520b	http://file-server/SP1.json	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	pool1k0hksc077c0jxjpgvhuvguat8jlv2r8xfxpa5vr6c4cz6m0jah4	88
1760000000000	stake_test1urrvtkynht5fwsy6umky2dpvjseq2fx2da2g0ymj7a3ge8sshnxnh	500000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3002, "__typename": "RelayByAddress"}]	["stake_test1urrvtkynht5fwsy6umky2dpvjseq2fx2da2g0ymj7a3ge8sshnxnh"]	05d821a74eaf2a45dfe0eb81b93b93340e39576c0c4cfbb7d20dba05f0935b02	\N	\N	pool1xl0v3fejd56e9txg5xld5k49he3dujgzacf0chz7sql0yx5h7rv	176
2760000000000	stake_test1up8zjeguclkpr2klgy7xhzyvtffh7lcv8nvwgnl5vunepnsr2f0pg	600000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3003, "__typename": "RelayByAddress"}]	["stake_test1up8zjeguclkpr2klgy7xhzyvtffh7lcv8nvwgnl5vunepnsr2f0pg"]	918b17bd5d8771f13c7586aff0e3b0548c380f476d399eeaa6e84a7ca8e24cef	http://file-server/SP3.json	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	pool1juahqjshmvjctnu5mz8s9rfkcxhre4mlqyn8zwl670dfsqlkdcd	276
3510000000000	stake_test1up64rype3k8ql4nfn933cmdgnp3kqp5pjmpetg5uar8nuvc2wkqa9	420000000	370000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3004, "__typename": "RelayByAddress"}]	["stake_test1up64rype3k8ql4nfn933cmdgnp3kqp5pjmpetg5uar8nuvc2wkqa9"]	6e5157202801c3f97f253deaa107b8571f9873ce5a1f1537c545641c8569958e	http://file-server/SP4.json	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	pool1mkw72p4vv6pjvmptynat4d7w82lfhjjkq2vudu5pxwwawm5k4wp	351
4290000000000	stake_test1uqktluxwde8wsryyzpx5p6l4m5uewxpcryvw0mnv0lvgmsc3pagxr	410000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3005, "__typename": "RelayByAddress"}]	["stake_test1uqktluxwde8wsryyzpx5p6l4m5uewxpcryvw0mnv0lvgmsc3pagxr"]	665502583e7eb045697b73cd7162172ff45c8fb6f99fc09f8f9939a86dbb9d1a	http://file-server/SP5.json	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	pool10zg0pmcg4k2dqt2effxrff4zzqsu43dsdw3e8cvh69ct5n73d4c	429
5290000000000	stake_test1urjc8hvha24aqvluvz3gyu09wfrk7sw9qm6707p69dnycvqwu74dh	410000000	400000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3006, "__typename": "RelayByAddress"}]	["stake_test1urjc8hvha24aqvluvz3gyu09wfrk7sw9qm6707p69dnycvqwu74dh"]	60c37ef18d9dfbdbf5518629bff90d913fc46e4d5624df23656fb27d954439d2	http://file-server/SP6.json	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	pool1q3gwfchl2ehtumuhka45xfzf86vy6wratwunt8zqq6qaxkypra5	529
5940000000000	stake_test1uq8l9uev3dquw98fc8cz3k99gzydkelrdll3cpkljjvl8vg7cf2pe	410000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3007, "__typename": "RelayByAddress"}]	["stake_test1uq8l9uev3dquw98fc8cz3k99gzydkelrdll3cpkljjvl8vg7cf2pe"]	65f90687394c3a8be759873b64d3669a24a956fcde41c444a094535bd46e73f9	http://file-server/SP7.json	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	pool1vj30jr7wn83dzn928qk6fx34h3d3f3cesr47j5ymeumf65wdw9x	594
6720000000000	stake_test1uraqc9mwtyl4nrw3j7wntym9lnkeuglnaudnkhwdw9h8hkchjgmx0	500000000	380000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3008, "__typename": "RelayByAddress"}]	["stake_test1uraqc9mwtyl4nrw3j7wntym9lnkeuglnaudnkhwdw9h8hkchjgmx0"]	e333db85b10204aaa567dd94552f9efedfaacee471fc6a22897d7693dd4619e7	\N	\N	pool1tgt2slr29xkx44ec6yzgk04uvq8n58m397l9hahc2r4u5kwh3x0	672
8210000000000	stake_test1upaypzc0qazfy34sfawtjgkfq4r07m7l39mzce9je4flves2u4z7v	500000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3009, "__typename": "RelayByAddress"}]	["stake_test1upaypzc0qazfy34sfawtjgkfq4r07m7l39mzce9je4flves2u4z7v"]	d15037cb591518aacc3ab53292cebf34a5806e3ad06aa5b96f117be171c9e786	\N	\N	pool1sjkahau820nfmgf3c703p8h70xnc2ckqhlhtgwmrjxfzs744tmh	821
9660000000000	stake_test1uz3j4yjpkylu0umfvnnnwzqrtwq56x0hj8ty0r593p5kscsmnvrfn	400000000	410000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 30010, "__typename": "RelayByAddress"}]	["stake_test1uz3j4yjpkylu0umfvnnnwzqrtwq56x0hj8ty0r593p5kscsmnvrfn"]	5ae8b20dc39667501ec1f2468c3f976049f95f209f938b1076c87c3a626d5bb5	http://file-server/SP10.json	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	pool1l8echf2amze2xcatzn2lyyyp7zhm9s5r2hmy6gdw7pupzsz9wy9	966
11150000000000	stake_test1uzctg0j9l5ysxyujtnchcv70jp8qm9a3tczfn7ft47vr60gahkst0	400000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 30011, "__typename": "RelayByAddress"}]	["stake_test1uzctg0j9l5ysxyujtnchcv70jp8qm9a3tczfn7ft47vr60gahkst0"]	4f5173eb13dd178531fceb5f2626d74cc540043af7da90f569b48430fac74861	http://file-server/SP11.json	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	pool1efkpr4fnmxhe73xj47puagzqwtv23ucpt0fkuhgx249j6vpqxk4	1115
190930000000000	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	500000000000000	1000	{"numerator": 1, "denominator": 5}	0.200000003	[{"ipv4": "127.0.0.1", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys"]	2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	\N	\N	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	19093
191820000000000	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	50000000	1000	{"numerator": 1, "denominator": 5}	0.200000003	[{"ipv4": "127.0.0.2", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v"]	641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	\N	\N	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	19182
\.


--
-- Data for Name: pool_retirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retirement (id, retire_at_epoch, stake_pool_id, block_slot) FROM stdin;
6980000000000	5	pool1tgt2slr29xkx44ec6yzgk04uvq8n58m397l9hahc2r4u5kwh3x0	698
8720000000000	18	pool1sjkahau820nfmgf3c703p8h70xnc2ckqhlhtgwmrjxfzs744tmh	872
10040000000000	5	pool1l8echf2amze2xcatzn2lyyyp7zhm9s5r2hmy6gdw7pupzsz9wy9	1004
11640000000000	18	pool1efkpr4fnmxhe73xj47puagzqwtv23ucpt0fkuhgx249j6vpqxk4	1164
\.


--
-- Data for Name: stake_pool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_pool (id, status, last_registration_id, last_retirement_id) FROM stdin;
pool1k0hksc077c0jxjpgvhuvguat8jlv2r8xfxpa5vr6c4cz6m0jah4	active	880000000000	\N
pool1xl0v3fejd56e9txg5xld5k49he3dujgzacf0chz7sql0yx5h7rv	active	1760000000000	\N
pool1juahqjshmvjctnu5mz8s9rfkcxhre4mlqyn8zwl670dfsqlkdcd	active	2760000000000	\N
pool1mkw72p4vv6pjvmptynat4d7w82lfhjjkq2vudu5pxwwawm5k4wp	active	3510000000000	\N
pool10zg0pmcg4k2dqt2effxrff4zzqsu43dsdw3e8cvh69ct5n73d4c	active	4290000000000	\N
pool1q3gwfchl2ehtumuhka45xfzf86vy6wratwunt8zqq6qaxkypra5	active	5290000000000	\N
pool1vj30jr7wn83dzn928qk6fx34h3d3f3cesr47j5ymeumf65wdw9x	active	5940000000000	\N
pool1tgt2slr29xkx44ec6yzgk04uvq8n58m397l9hahc2r4u5kwh3x0	retired	6720000000000	6980000000000
pool1l8echf2amze2xcatzn2lyyyp7zhm9s5r2hmy6gdw7pupzsz9wy9	retired	9660000000000	10040000000000
pool1sjkahau820nfmgf3c703p8h70xnc2ckqhlhtgwmrjxfzs744tmh	retired	8210000000000	8720000000000
pool1efkpr4fnmxhe73xj47puagzqwtv23ucpt0fkuhgx249j6vpqxk4	retired	11150000000000	11640000000000
pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	activating	190930000000000	\N
pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	activating	191820000000000	\N
\.


--
-- Name: pool_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_metadata_id_seq', 8, true);


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

