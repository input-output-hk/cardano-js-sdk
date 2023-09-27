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
419f7c5e-7f21-4532-9a1c-1f17cc26cfcc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-27 12:58:52.261739+00	2023-09-27 12:59:52.258761+00	__pgboss__maintenance	\N	00:15:00	2023-09-27 12:56:52.261739+00	2023-09-27 12:59:52.268645+00	2023-09-27 13:06:52.261739+00	f	\N	\N
12977c29-4fe5-45f1-adaf-7e3211250dd1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-27 12:44:22.176329+00	2023-09-27 12:44:22.179401+00	__pgboss__maintenance	\N	00:15:00	2023-09-27 12:44:22.176329+00	2023-09-27 12:44:22.191021+00	2023-09-27 12:52:22.176329+00	f	\N	\N
903efb38-69e3-47f2-81ee-b5bc18293330	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:01:01.65321+00	2023-09-27 13:01:04.667904+00	\N	2023-09-27 13:01:00	00:15:00	2023-09-27 13:00:04.65321+00	2023-09-27 13:01:04.674628+00	2023-09-27 13:02:01.65321+00	f	\N	\N
aa73ac6a-e8f4-4c7a-a651-bc7069642fdd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-27 13:01:52.271265+00	2023-09-27 13:02:52.262412+00	__pgboss__maintenance	\N	00:15:00	2023-09-27 12:59:52.271265+00	2023-09-27 13:02:52.275939+00	2023-09-27 13:09:52.271265+00	f	\N	\N
cf0a1307-e460-404a-a4de-7f83a27e848f	pool-metrics	0	{"slot": 9419}	completed	0	0	0	f	2023-09-27 13:05:21.811487+00	2023-09-27 13:05:22.897337+00	\N	\N	00:15:00	2023-09-27 13:05:21.811487+00	2023-09-27 13:05:23.072255+00	2023-10-11 13:05:21.811487+00	f	\N	9419
3d8ba147-ea77-441c-b616-38ccbe289e1b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-27 12:44:52.232362+00	2023-09-27 12:44:52.244235+00	__pgboss__maintenance	\N	00:15:00	2023-09-27 12:44:52.232362+00	2023-09-27 12:44:52.253872+00	2023-09-27 12:52:52.232362+00	f	\N	\N
a4a1b755-58ea-4612-8a61-7aa6c8bf316b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-27 13:04:52.278586+00	2023-09-27 13:05:52.264449+00	__pgboss__maintenance	\N	00:15:00	2023-09-27 13:02:52.278586+00	2023-09-27 13:05:52.27734+00	2023-09-27 13:12:52.278586+00	f	\N	\N
b852e1ec-ae85-4213-abc5-d2ec343a90a6	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:44:22.184789+00	2023-09-27 12:44:52.248929+00	\N	2023-09-27 12:44:00	00:15:00	2023-09-27 12:44:22.184789+00	2023-09-27 12:44:52.25493+00	2023-09-27 12:45:22.184789+00	f	\N	\N
d3fbc7c6-bd0d-4815-abf3-b3dbe2c6b152	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:06:01.768189+00	2023-09-27 13:06:04.778521+00	\N	2023-09-27 13:06:00	00:15:00	2023-09-27 13:05:04.768189+00	2023-09-27 13:06:04.791814+00	2023-09-27 13:07:01.768189+00	f	\N	\N
91494054-9b4c-42fe-9e12-aca10dedb657	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:10:01.846215+00	2023-09-27 13:10:04.864505+00	\N	2023-09-27 13:10:00	00:15:00	2023-09-27 13:09:04.846215+00	2023-09-27 13:10:04.878125+00	2023-09-27 13:11:01.846215+00	f	\N	\N
29866877-1065-44a1-b4c4-2f4b56bff264	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-27 13:10:52.283699+00	2023-09-27 13:11:52.272869+00	__pgboss__maintenance	\N	00:15:00	2023-09-27 13:08:52.283699+00	2023-09-27 13:11:52.285169+00	2023-09-27 13:18:52.283699+00	f	\N	\N
9ee020e3-54d3-4ddb-87ed-0cccdc369ce7	pool-metadata	0	{"poolId": "pool1ttj08sty3hrvla5xeqh99g5te7zld72a3h6v7ljjsc75k90zsep", "metadataJson": {"url": "http://file-server/SP1.json", "hash": "14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7"}, "poolRegistrationId": "740000000000"}	completed	1000000	0	21600	f	2023-09-27 12:44:22.275426+00	2023-09-27 12:44:52.259888+00	\N	\N	00:15:00	2023-09-27 12:44:22.275426+00	2023-09-27 12:44:52.302832+00	2023-10-11 12:44:22.275426+00	f	\N	74
f3d1998f-e6af-4e36-ba1d-e41869db1c57	pool-metadata	0	{"poolId": "pool1vx35knryxxtndndlyd6d2zpd8pn60pculy8r5mf9n6j4k6rne5g", "metadataJson": {"url": "http://file-server/SP3.json", "hash": "6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25"}, "poolRegistrationId": "2140000000000"}	completed	1000000	0	21600	f	2023-09-27 12:44:22.383042+00	2023-09-27 12:44:52.259888+00	\N	\N	00:15:00	2023-09-27 12:44:22.383042+00	2023-09-27 12:44:52.303783+00	2023-10-11 12:44:22.383042+00	f	\N	214
ff9386c9-c23f-465a-8c5d-8295244db092	pool-metadata	0	{"poolId": "pool1zycsff54pretcc5avly6yq4yr5g5jcxwx4qa9c76m9f7s3d0qet", "metadataJson": {"url": "http://file-server/SP4.json", "hash": "09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d"}, "poolRegistrationId": "3100000000000"}	completed	1000000	0	21600	f	2023-09-27 12:44:22.427744+00	2023-09-27 12:44:52.259888+00	\N	\N	00:15:00	2023-09-27 12:44:22.427744+00	2023-09-27 12:44:52.304772+00	2023-10-11 12:44:22.427744+00	f	\N	310
d4de6751-9635-4524-a9d6-0062460de6cf	pool-metadata	0	{"poolId": "pool1879x8xzp4r0dw577u9znvd7j9lysslmqmzngh3dljfdzqrvpxgj", "metadataJson": {"url": "http://file-server/SP6.json", "hash": "3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba"}, "poolRegistrationId": "4490000000000"}	completed	1000000	0	21600	f	2023-09-27 12:44:22.513812+00	2023-09-27 12:44:52.259888+00	\N	\N	00:15:00	2023-09-27 12:44:22.513812+00	2023-09-27 12:44:52.313692+00	2023-10-11 12:44:22.513812+00	f	\N	449
25a4e9ed-d346-4d3d-8488-054f0c41f19a	pool-metadata	0	{"poolId": "pool1050c4ea4xvpq3kkzv0rfmxxsh54pz025q99fd24ejxuqv9954hz", "metadataJson": {"url": "http://file-server/SP5.json", "hash": "0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501"}, "poolRegistrationId": "3650000000000"}	completed	1000000	0	21600	f	2023-09-27 12:44:22.470418+00	2023-09-27 12:44:52.259888+00	\N	\N	00:15:00	2023-09-27 12:44:22.470418+00	2023-09-27 12:44:52.313135+00	2023-10-11 12:44:22.470418+00	f	\N	365
95144074-c812-455f-9835-84e16d136cb5	pool-metadata	0	{"poolId": "pool103n9pwvgzlve22xmghl2nw5x2gx8fz5nydm4f9z85k5zxe348sq", "metadataJson": {"url": "http://file-server/SP7.json", "hash": "c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405"}, "poolRegistrationId": "5690000000000"}	completed	1000000	0	21600	f	2023-09-27 12:44:22.562633+00	2023-09-27 12:44:52.259888+00	\N	\N	00:15:00	2023-09-27 12:44:22.562633+00	2023-09-27 12:44:52.31442+00	2023-10-11 12:44:22.562633+00	f	\N	569
4e5696fe-9262-4d22-b7d1-ea68fea6158e	pool-metrics	0	{"slot": 3127}	completed	0	0	0	f	2023-09-27 12:44:23.601796+00	2023-09-27 12:44:52.260053+00	\N	\N	00:15:00	2023-09-27 12:44:23.601796+00	2023-09-27 12:44:52.534936+00	2023-10-11 12:44:23.601796+00	f	\N	3127
d86d541d-c00a-4d55-9fd1-97152e2183ca	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:45:01.255337+00	2023-09-27 12:45:04.254069+00	\N	2023-09-27 12:45:00	00:15:00	2023-09-27 12:44:52.255337+00	2023-09-27 12:45:04.262113+00	2023-09-27 12:46:01.255337+00	f	\N	\N
67400bce-335e-43d4-a757-579d71223733	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-27 12:46:52.256865+00	2023-09-27 12:47:52.246255+00	__pgboss__maintenance	\N	00:15:00	2023-09-27 12:44:52.256865+00	2023-09-27 12:47:52.259587+00	2023-09-27 12:54:52.256865+00	f	\N	\N
6e9c5aae-bee3-4881-9df9-e804f7ce0ba2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-27 13:13:52.286983+00	2023-09-27 13:14:52.274883+00	__pgboss__maintenance	\N	00:15:00	2023-09-27 13:11:52.286983+00	2023-09-27 13:14:52.281134+00	2023-09-27 13:21:52.286983+00	f	\N	\N
2abb5ac2-0683-4b7d-9742-34403db01e6a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-27 12:55:52.256985+00	2023-09-27 12:56:52.253433+00	__pgboss__maintenance	\N	00:15:00	2023-09-27 12:53:52.256985+00	2023-09-27 12:56:52.259403+00	2023-09-27 13:03:52.256985+00	f	\N	\N
1355cf60-9955-4967-8522-46fa2c639406	pool-metadata	0	{"poolId": "pool10642kanghvyd0w8v2vlrayu46gzjrpjqc3ssvwg2y574v9407ql", "metadataJson": {"url": "http://file-server/SP11.json", "hash": "4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9"}, "poolRegistrationId": "10710000000000"}	completed	1000000	0	21600	f	2023-09-27 12:44:22.786638+00	2023-09-27 12:44:52.259888+00	\N	\N	00:15:00	2023-09-27 12:44:22.786638+00	2023-09-27 12:44:52.315565+00	2023-10-11 12:44:22.786638+00	f	\N	1071
5844f5c0-c2e6-4204-9adc-2dc58674c87c	pool-metadata	0	{"poolId": "pool1jwlssult0t7hmp7wjvs7dg9nxgtlsewuxfz0x7wy3pcewh4wkr5", "metadataJson": {"url": "http://file-server/SP10.json", "hash": "c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd"}, "poolRegistrationId": "8990000000000"}	completed	1000000	0	21600	f	2023-09-27 12:44:22.725225+00	2023-09-27 12:44:52.259888+00	\N	\N	00:15:00	2023-09-27 12:44:22.725225+00	2023-09-27 12:44:52.314991+00	2023-10-11 12:44:22.725225+00	f	\N	899
4f3dfbfb-e2c3-47b5-a696-bff2e358428c	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:57:01.559581+00	2023-09-27 12:57:04.574037+00	\N	2023-09-27 12:57:00	00:15:00	2023-09-27 12:56:04.559581+00	2023-09-27 12:57:04.587561+00	2023-09-27 12:58:01.559581+00	f	\N	\N
2196a68e-a55e-4af9-87e4-e373e4910a20	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:46:01.260384+00	2023-09-27 12:46:04.279543+00	\N	2023-09-27 12:46:00	00:15:00	2023-09-27 12:45:04.260384+00	2023-09-27 12:46:04.286907+00	2023-09-27 12:47:01.260384+00	f	\N	\N
6b0d1bda-5f15-4269-af5d-13987e2fb796	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:47:01.28504+00	2023-09-27 12:47:04.308127+00	\N	2023-09-27 12:47:00	00:15:00	2023-09-27 12:46:04.28504+00	2023-09-27 12:47:04.323257+00	2023-09-27 12:48:01.28504+00	f	\N	\N
2a601f95-63de-4855-a910-830b9672ffb9	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:58:01.585813+00	2023-09-27 12:58:04.600012+00	\N	2023-09-27 12:58:00	00:15:00	2023-09-27 12:57:04.585813+00	2023-09-27 12:58:04.608915+00	2023-09-27 12:59:01.585813+00	f	\N	\N
95a33b1c-b14e-44a9-8070-2a7c94b72d90	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:48:01.321381+00	2023-09-27 12:48:04.331162+00	\N	2023-09-27 12:48:00	00:15:00	2023-09-27 12:47:04.321381+00	2023-09-27 12:48:04.337584+00	2023-09-27 12:49:01.321381+00	f	\N	\N
ce9d87da-6c41-4891-a350-30c61255abc2	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:59:01.606107+00	2023-09-27 12:59:04.621469+00	\N	2023-09-27 12:59:00	00:15:00	2023-09-27 12:58:04.606107+00	2023-09-27 12:59:04.635674+00	2023-09-27 13:00:01.606107+00	f	\N	\N
0a9f6290-cfab-41c8-836c-736b2a70f8ec	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:49:01.335858+00	2023-09-27 12:49:04.357683+00	\N	2023-09-27 12:49:00	00:15:00	2023-09-27 12:48:04.335858+00	2023-09-27 12:49:04.373091+00	2023-09-27 12:50:01.335858+00	f	\N	\N
b7e2c91e-eb65-438f-b00e-ae309fa322ca	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:00:01.633906+00	2023-09-27 13:00:04.639656+00	\N	2023-09-27 13:00:00	00:15:00	2023-09-27 12:59:04.633906+00	2023-09-27 13:00:04.655144+00	2023-09-27 13:01:01.633906+00	f	\N	\N
a3f15dfa-176e-40c5-a1cb-3d738f21b77e	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:50:01.371218+00	2023-09-27 12:50:04.386194+00	\N	2023-09-27 12:50:00	00:15:00	2023-09-27 12:49:04.371218+00	2023-09-27 12:50:04.394606+00	2023-09-27 12:51:01.371218+00	f	\N	\N
4bd1accf-bc1b-4bca-950f-1eaebf352f3e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-27 12:49:52.262295+00	2023-09-27 12:50:52.245043+00	__pgboss__maintenance	\N	00:15:00	2023-09-27 12:47:52.262295+00	2023-09-27 12:50:52.250817+00	2023-09-27 12:57:52.262295+00	f	\N	\N
544a3a57-829d-467b-a6d3-3368afc122a0	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:02:01.672884+00	2023-09-27 13:02:04.691455+00	\N	2023-09-27 13:02:00	00:15:00	2023-09-27 13:01:04.672884+00	2023-09-27 13:02:04.705687+00	2023-09-27 13:03:01.672884+00	f	\N	\N
9828c66c-0424-4844-b62f-3e9a26ecec4b	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:51:01.392877+00	2023-09-27 12:51:04.411281+00	\N	2023-09-27 12:51:00	00:15:00	2023-09-27 12:50:04.392877+00	2023-09-27 12:51:04.419481+00	2023-09-27 12:52:01.392877+00	f	\N	\N
72348f15-6f8a-4d72-81c8-a2988f365348	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:03:01.703468+00	2023-09-27 13:03:04.714609+00	\N	2023-09-27 13:03:00	00:15:00	2023-09-27 13:02:04.703468+00	2023-09-27 13:03:04.721124+00	2023-09-27 13:04:01.703468+00	f	\N	\N
26110879-1368-41fb-bb3f-38728e9bd67b	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:52:01.417692+00	2023-09-27 12:52:04.441216+00	\N	2023-09-27 12:52:00	00:15:00	2023-09-27 12:51:04.417692+00	2023-09-27 12:52:04.456111+00	2023-09-27 12:53:01.417692+00	f	\N	\N
da4a0ba5-b8c4-4f86-8a88-cb1edce1ef6d	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:53:01.4543+00	2023-09-27 12:53:04.464789+00	\N	2023-09-27 12:53:00	00:15:00	2023-09-27 12:52:04.4543+00	2023-09-27 12:53:04.478501+00	2023-09-27 12:54:01.4543+00	f	\N	\N
358b04fd-6b36-468e-a4d7-feef66992ffe	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:04:01.719142+00	2023-09-27 13:04:04.730097+00	\N	2023-09-27 13:04:00	00:15:00	2023-09-27 13:03:04.719142+00	2023-09-27 13:04:04.743466+00	2023-09-27 13:05:01.719142+00	f	\N	\N
9f059a55-9dd2-46d0-aa2a-ff6a1ee60207	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-27 12:52:52.253487+00	2023-09-27 12:53:52.249997+00	__pgboss__maintenance	\N	00:15:00	2023-09-27 12:50:52.253487+00	2023-09-27 12:53:52.255136+00	2023-09-27 13:00:52.253487+00	f	\N	\N
1c44519a-bb92-4a81-9c8a-963181d6a396	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:05:01.741814+00	2023-09-27 13:05:04.755342+00	\N	2023-09-27 13:05:00	00:15:00	2023-09-27 13:04:04.741814+00	2023-09-27 13:05:04.770051+00	2023-09-27 13:06:01.741814+00	f	\N	\N
5834bf24-ab13-4155-9725-93d962a7a9c1	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:54:01.476629+00	2023-09-27 12:54:04.494363+00	\N	2023-09-27 12:54:00	00:15:00	2023-09-27 12:53:04.476629+00	2023-09-27 12:54:04.507886+00	2023-09-27 12:55:01.476629+00	f	\N	\N
d5f50d59-5f35-4874-b419-8e6695eaef3f	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:55:01.506204+00	2023-09-27 12:55:04.520674+00	\N	2023-09-27 12:55:00	00:15:00	2023-09-27 12:54:04.506204+00	2023-09-27 12:55:04.528722+00	2023-09-27 12:56:01.506204+00	f	\N	\N
d2e3c24c-084b-44d5-8b74-33431e851f4f	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 12:56:01.526861+00	2023-09-27 12:56:04.547697+00	\N	2023-09-27 12:56:00	00:15:00	2023-09-27 12:55:04.526861+00	2023-09-27 12:56:04.561293+00	2023-09-27 12:57:01.526861+00	f	\N	\N
d5f5f725-a891-46ff-8e8f-a1c6cb2a1a8d	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:07:01.790121+00	2023-09-27 13:07:04.798501+00	\N	2023-09-27 13:07:00	00:15:00	2023-09-27 13:06:04.790121+00	2023-09-27 13:07:04.805968+00	2023-09-27 13:08:01.790121+00	f	\N	\N
1d8ae9ea-e5fb-4481-954e-0c73440e4cae	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:08:01.804255+00	2023-09-27 13:08:04.821248+00	\N	2023-09-27 13:08:00	00:15:00	2023-09-27 13:07:04.804255+00	2023-09-27 13:08:04.828481+00	2023-09-27 13:09:01.804255+00	f	\N	\N
efccb4ce-e95b-4498-bc9d-522ef8a807e2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-27 13:07:52.279287+00	2023-09-27 13:08:52.26904+00	__pgboss__maintenance	\N	00:15:00	2023-09-27 13:05:52.279287+00	2023-09-27 13:08:52.281843+00	2023-09-27 13:15:52.279287+00	f	\N	\N
58850810-6e8b-4015-ada0-489c0186ca38	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:09:01.826747+00	2023-09-27 13:09:04.840823+00	\N	2023-09-27 13:09:00	00:15:00	2023-09-27 13:08:04.826747+00	2023-09-27 13:09:04.848224+00	2023-09-27 13:10:01.826747+00	f	\N	\N
f4024b2c-38b4-46a9-8fe8-230826b99e7f	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:11:01.876372+00	2023-09-27 13:11:04.885198+00	\N	2023-09-27 13:11:00	00:15:00	2023-09-27 13:10:04.876372+00	2023-09-27 13:11:04.898955+00	2023-09-27 13:12:01.876372+00	f	\N	\N
e006f580-c018-42a6-9b0e-699a19340d4e	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:12:01.897253+00	2023-09-27 13:12:04.903912+00	\N	2023-09-27 13:12:00	00:15:00	2023-09-27 13:11:04.897253+00	2023-09-27 13:12:04.911909+00	2023-09-27 13:13:01.897253+00	f	\N	\N
83bfec69-93bf-48a9-95c2-3550fb6a3f26	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:13:01.910237+00	2023-09-27 13:13:04.929742+00	\N	2023-09-27 13:13:00	00:15:00	2023-09-27 13:12:04.910237+00	2023-09-27 13:13:04.935492+00	2023-09-27 13:14:01.910237+00	f	\N	\N
aa096172-4c69-4322-8353-dff01684b65e	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:14:01.93385+00	2023-09-27 13:14:04.951332+00	\N	2023-09-27 13:14:00	00:15:00	2023-09-27 13:13:04.93385+00	2023-09-27 13:14:04.960306+00	2023-09-27 13:15:01.93385+00	f	\N	\N
055c99b4-6ae8-463b-baa2-7899ab0e5bad	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:15:01.956333+00	2023-09-27 13:15:04.971239+00	\N	2023-09-27 13:15:00	00:15:00	2023-09-27 13:14:04.956333+00	2023-09-27 13:15:04.984842+00	2023-09-27 13:16:01.956333+00	f	\N	\N
e409ee73-e114-448a-bf5f-20b511cb1764	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:16:01.983009+00	2023-09-27 13:16:04.996631+00	\N	2023-09-27 13:16:00	00:15:00	2023-09-27 13:15:04.983009+00	2023-09-27 13:16:05.010437+00	2023-09-27 13:17:01.983009+00	f	\N	\N
6a06b61f-3b40-47e6-8324-f4628b90d8df	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:17:01.008719+00	2023-09-27 13:17:01.021243+00	\N	2023-09-27 13:17:00	00:15:00	2023-09-27 13:16:05.008719+00	2023-09-27 13:17:01.029156+00	2023-09-27 13:18:01.008719+00	f	\N	\N
09acd9ed-3b94-45fc-8b6f-fe3908c21e93	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-09-27 13:16:52.283978+00	2023-09-27 13:17:52.278351+00	__pgboss__maintenance	\N	00:15:00	2023-09-27 13:14:52.283978+00	2023-09-27 13:17:52.291746+00	2023-09-27 13:24:52.283978+00	f	\N	\N
8232a463-39c5-438a-b839-c7673a690b3a	__pgboss__maintenance	0	\N	created	0	0	0	f	2023-09-27 13:19:52.294325+00	\N	__pgboss__maintenance	\N	00:15:00	2023-09-27 13:17:52.294325+00	\N	2023-09-27 13:27:52.294325+00	f	\N	\N
b32999c7-5956-4cb6-8a3f-1b3ff51316a5	__pgboss__cron	0	\N	created	2	0	0	f	2023-09-27 13:19:01.056336+00	\N	\N	2023-09-27 13:19:00	00:15:00	2023-09-27 13:18:01.056336+00	\N	2023-09-27 13:20:01.056336+00	f	\N	\N
e98eb011-52b6-4937-b3aa-cd58ce4173d1	__pgboss__cron	0	\N	completed	2	0	0	f	2023-09-27 13:18:01.02692+00	2023-09-27 13:18:01.044716+00	\N	2023-09-27 13:18:00	00:15:00	2023-09-27 13:17:01.02692+00	2023-09-27 13:18:01.058098+00	2023-09-27 13:19:01.02692+00	f	\N	\N
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
20	2023-09-27 13:17:52.290132+00	2023-09-27 13:18:01.054307+00
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (height, hash, slot) FROM stdin;
0	af2a5ad3c25dd6059e574a1d2616b3c56e4290d6d91facebc55c971e0bcfbb53	5
1	9c7c377f64dacc96d8bdb5dc1ed5e3657fdb43b95c4c9ffc60a65aa6bada692e	18
2	671c6399393d773ec2d9904c14d52eeaa5ac07d155eb594ead213389a8e3b098	23
3	7309a3d83a20f77c6d9dd8f73230587dfa8de66a383cb1e9df6eee0d6e37a79a	25
4	4b03ed345ee0ad668c52e6197c1b848cc272ac5c84c4552d835e638140382684	39
5	a471baf1c81807d8d29dccb29cfb7db2d20077a2b4cc6795ceb8d268d7c57487	46
6	b4f30891a5e7186b88d94d2b4eec08caf45f55d4717cf1657f8a7e712363ec50	51
7	e6d57f175023c670219ea2c4b4309669c301e6058edf28740b929e4cf7db8423	55
8	6db6a7e66e1ea3fbc3c954f94c651e8107d6700347bd07c36b2729a4959569f7	74
9	4ecf9e4243928071027d9e42a61601d4b354862a631ea19293e9f41ded6b73a7	82
10	b08c9f109a11025bc5881ff4f84b700898187c3cbfc69dd3e7ea20c2dc69449a	95
11	cfc6aa795ecd0065033de8eb5c1a7bbdae87dc59885f49fad8c7ca65acad793d	107
12	edebd2cdf3f17cdcd761a9d06d65f17418f86be101dda1851b619615bf0a26fe	110
13	9656e5fa8f2009d75b1b196dfb0450c531a1db265063d629c273b011cb479d95	113
14	c74791f8147d7f437d68f81f8aad9cba1892d32fc4a78081e82a242f0d0f0861	115
15	c023c44946f583fcac8ac71fd9e97d99baf1f0299b7b08af91f55d387214bf09	131
16	7fedb8397eba5e33651fd4e641baea6de3e203a0af7ec06622a8ef7b229088a8	139
17	b677328f12ebd83502b707b3e5fbb6789a504ff29ae970800767262a66daad17	155
18	a7428e503bf82feaeadefceaa6e695913a50ddf5733112c431ea451a703ce1f6	157
19	d0dfca64f38b8adfc818022c36f3d8a76b27ed2c76837e8d79c3e685895aa6d6	164
20	f7bcde8e2dd90e42dcebd0a2b35423bb16f3e9fd460b0c1de8e84d4caa66d45a	166
21	426baa3c7b19be3f02a35af10dac9de9e809cba5b3a34416eb8ee2b93a1811ee	167
22	4d6cbe6f42f4b031966c3c32101d74ffb575697fbb6b3fe30ee5f9bfa6ee53e7	175
23	0498a88bc8aa603cc7ff112b4758c24023a22cabd20dea83e07c4158962e59f4	176
24	138b8501079e83e33329c672715384fc9b0bdae57c30fa5c3cece21f28bafaec	183
25	f69ed878af5f399dedff827ba2fb973d9189c0b9602b93db6665880da03d5ad2	186
26	4797b5cfafd03b85d63d64d8c5927a05211370772548b15e5f1bedce1666b1bf	193
27	ec0a9827cd4541e5f59cf425b94fd6bbea32e8df7d35a80a3e657b6681092ff7	196
28	374739fe99dabb0f8a3ea109c77d77aca9011cc5e2d27378f71024cbf35b8f4f	197
29	e53073032f6ba0a63a311d4b7d94f42cddf445ac5a6fd1ebb8756ca5167990e7	206
30	fa1dfb196d0b4774e2e6e6d2834a36a2f10f06a38577259d9496a1de577de637	213
31	74c099c6dd7fd2a952991bf4db2f6ec327afc6d3c7b623bfa50492d12bcc32ee	214
32	ec4cc16d464a51d3a669c2d6e79a6fd8cd36a87da084bfdc226f88036d51ec86	219
33	c94edc7d979362a9aaefb941799ec75ba2823c23c23e974faefd5161e47cce4e	247
34	51db2a0dccd0a2ebb3848e0090b6f3f51d127f7c8f2e2449b300cfd6be1e47bc	254
35	4def76767c179c7f65a0cdee73046cac3bb76686b45f194461e6d9aa619870d2	256
36	830cdc295afebd06f3de913c01a5e50414121daa90598e05b46a57bb388fd410	257
37	f0b541dcf10d27750158fd908ec303c23ae6901fefbdb00e46bd0ed4f58fbbc5	265
38	0f00b0ce11c55a2c0d92c4566d3e6ac7b2dbdc04ec013691feeb4eeddf624f8f	284
39	b08e9dce5c918f0f41fc07ac8c99fad985700fbb727ef5fee4b1ebc527ab19e5	301
40	71ddf4cab9ad95bb5e016a82f00b0938a845580bf139962002078ad5c91bae9a	305
41	ec89cd9cb0cde4b91147dafdeaa75c90d2e005ded2d66c16875c4cab43f5f808	310
42	c9d5c46bd95cf9806d5ca8ee276782d4f1b8f832fb14ec4b93a4f565f30f51cf	320
43	ff0e50a6234a169bbfdbe0a9679eeb7731e5f3d71ccb1e47cc458094797bf13a	322
44	34ac6e450ebfab93baa70378fbaa46f04706ef759011473194cccc5ebe2fe0a6	324
45	57370f12973b9fdfab689c0d0aaa9dd424c63774b89ef6e3302d1e9ff8a95e79	334
46	3fa8cf7ea81a2600eb7b01dcdb167f002c8977e4761a996be7f2710fa32b9090	345
47	d31855f8847ddf625ae2625365fc5f4cef97b9e40eaf6b6331b1e3885ba975ef	354
48	f9b067479fa786668a575cd3783742ee9df3b652439ac5a75e5f464597912f2d	356
49	8fc5ebc884b4a539cd6d74de05a87252ed5a441f4976c49c4d839ba7a97349e1	359
50	240b28eb6882567bb4002d3ebe79c05bc0211a084ac452e231c482c9e3716553	365
51	c2449735665ad35021860c13d4463cc077e0909cd783c492a9515714bf2f46c3	385
52	5aa3fa5c6262fa037ad5ccd79f239337d3a173545c6674d3bafcb205c000b4b0	397
53	ff496f548e5308ab8e201963b82cb28b39b1559ab9616388343941e74754dbeb	402
54	a76070cd2388a683db0ec1449a603417a2d47dc3ca3087306eecf6cba2bfb310	419
55	6b03f87b254345d2dea886ab57701a08b0ae0a7a0768593a0699bbce1f6bf1ec	420
56	cef3e48c3562abb02df1785683badb439dcd19a17823dac3b3af79832488d6ba	422
57	a8991926c0d0a91e6cebda4f547d3a143f1ea2dbc631dddca17484eb5186f742	427
58	60deab4a7f520bca9eb56828423c1c47ea6b5ea99fb45a18606a110232a90fc4	440
59	0fd80f96a8f9bab014732a0658fb51901c3068f8ea295f6bd819a5e63acd3f32	449
60	0633970cf8036ae6af5055872865ccbce068ab47567d867b300d0d1569df90fb	455
61	4e4aac0744bb1d47996f4b2a5efebf0b645f838cf2f96da6fda6fceb7c833a21	459
62	55de50e43ddedcefd941aa4caf54f48eb529a6b6f07e9f52ae0757c632d5962a	461
63	0377e5ae9c1c451e92d732aa0f729189320b15445bfb2ec8026d5710473f82bd	467
64	98b853b18601ff61395c4f68fd4f8fce0235d372d7514cce2ad638b6b0360272	493
65	81ad65fa49a0fc8120c3fb06e926ff992f308f3ca0f0203d4b9810a819da0632	495
66	a2d616f15f85e828f7279800adefaac9bff1e4c42f247a517748165783163e12	501
67	e5bb5822f1169c13f9d670619ebcaf71a04ec792a55a96af32ca048a33e8efc2	528
68	9b9d28fefacd4fc3f2d58cf3e1475b321ec70b86f68a63592b0b3c3137c29b60	557
69	b229283c77eafb0391ffbc9496b37f326abd5ba22bf9de24c08b1a41eb53d84a	559
70	09d612aa200e729b51f557605909a8a60b1611a915291fac0280560e59f22776	569
71	1e9a69792c17b50f7b58881ca0ab60206e1aff8c498a15ddb5fe9d569c30eb6d	573
72	0c25d1252d64a88c73f9063715a4e57818b04a52eca33b200faf3b3eee81913f	580
73	c9f57e4824a0293f7d5c596053317bd15c6f715d40e464afaaff44d0e0940bc5	585
74	2a1276d12c6a5ad0d2970764a305847309797e94f4509bf29df0e315195f893a	591
75	254cdea440631228db7d8b2e7b2e33470d7463009f4fb4a316b1294b692e851f	613
76	f15794895f15645ec52baa38fe9ac83deb0ab7b5ec553c6ab7b746638844eb71	614
77	d2a52b4ba96a73b1584a467002de7017495331e000ca15f98d30c0fa70224ac8	628
78	44db4db284515f584eaa9abc4e2881590e4444cd0efca82072beca2337347c11	661
79	e5397ff373a9e7b50d9972f58b9fff89358f84f9c6331400cb0b4be616329cdc	667
80	b0ffbcaf7cc5613cf551a30f05da33586b2430b8f8bcb1fab402650fbe05df9e	704
81	7b5f843385bcab5ef7949f5ae2917fda266f61db7aa82fd3a7ff2d06cd0510c1	713
82	018fe71d00bdfbc4078baea551bebf84d32c8f78443ab0f70733e303a4dd5540	721
83	334da8764b4e0f111af485a0850e42f52b44d9442426bb42caae701b02e416ab	724
84	626fd36f6dec2c34c18f7d18d52131a461d8ea025f5e0204bf9ca7f961099b7d	732
85	a14fae1b1c13768d67ed339154ba947706602acc3dc55b501827c3ac8a29eb34	736
86	393d6d98643085f43e16068064e7b57e0165dc2df21473c79f664cb4db90503b	745
87	2694a187c47a1568927b4006a18d635e48f37fcfc0691a5093b496dd3f6303c9	748
88	a2ebeb344fb97bc0ba57f72b073249b432740c8ce170b4fcf129d1a019843c71	751
89	68decfa39b2a4bfc76b85b64692a97921118d2f5492529ba03918e2a861efe9c	761
90	048cc382599bdedd0051f142349f1bf889b506e8a932c297ed6b8ff432087458	782
91	f2ee6fb83c394a736f94fcad57f5b597aba8540a4180a01faf354e9df274388c	787
92	cb15a0540713ee892a06e81a63211c2a1d5b1d32513f5c2ce32e339693cbc88a	789
93	4422b9d40496bedac14687106d89f4310b152824d98f7c7db85367dc3b3c2f54	790
94	a9515a65c7636c02f518295f1fb1f500153146b7bf669f179453768b7185cf1f	796
95	73c2c3c68fa657704a5f33946fbc3463c7a3621fbbe921b7c6689411acc4fc68	799
96	27e7fae09016143af3545bbd260f798d19cb0d37d08e180980825abc833a1034	810
97	4e510d76b2fbfd830d4c4af76dda9966a08e3d885cb078663860a5f6ec3bf1ff	820
98	7692f2beea3e7fb47703db73534ae5b6e128b3ccc2ecfd0f8d10cf99784a67c1	823
99	d5000217a4dd26c59f4cf4e58f6a13a0e494becea7f4af1a3468e9018bfacd4f	826
100	b99fdda57b71dc083fd2f4f4063d5351e488db69ad48dd77f78d1b520c4e4c0a	834
101	1ae04070a993eee3001d8f1e5581ccb1b5add71675d7a742f6fb01c829fdaf7f	869
102	a576d38f4847da60fe5ab9c130d4b1c281fb85b6d0a4f43556e95d44a9c7c846	874
103	efc5ff9f433db9c1fbd5640a50f39c0472de6365a7c1324684e82ec3692c3ee1	877
104	ad7beb59a22c6c69717030c1f91c0ff9186b38438a98d0f36d837609ea15c8ce	899
105	8db2a0d3f0660e2ed2dfd2736189b525903c2ad3e259884ca930deeb87e7161f	919
106	ccd75ebf2814d005bf532a1071d7bfea4ad69f8b33e5d3406e105e6f64af0e77	920
107	10401a516ce59e42db4feb06a38642462c0108b8c597bf86d407cda96408a2be	924
108	63b92e244f5a4e94a97644e66c203188f3c3078c0cf8a1524ffbdb0c2f797fc6	938
109	a90022bc643192b24e8857c85066f8ddbbb883aaca9f5199686e8d9a3394e206	943
110	984363f3f2b991bcf3dfe556a68972b30c8a99cb012d2edb7f68833f87d4f790	1006
111	7da7cd05598b77729cc3adb936caba25d5c18bc038cf587f02897d985004d3db	1022
112	4828f15d771f1ad6d466b82ff0dbb19a3ffb7617ebe1e95b671c17c232f6801c	1024
113	e329ed7833a37df224fee42946cf6fe9a1cd06d9a8d29ae0243f45999eb56e0c	1031
114	f157b096fce50dba9669347e814fc7d96ba3ffaef8e1bd2ce0b1215ab77e4ecc	1035
115	538d48d9bcb94845223927a7930e678cd66dee296e167dd74b0fd289eda1ceed	1037
116	445c95807e8eaaa00bf768c2f9066f19d031e4590011f35bf0ce48d18fb38135	1058
117	385d810eef66ae2998d320898a6614e355e32468a7b45675504aa34f67cf8599	1071
118	bc5cb946b26f4a925fd875954751a4cc9e8d94b416657200fee3c44b2384ae21	1080
119	d3f4d6f27a3a5d4ba8d0d2de0b14a61586921673826a7ac34d5ca22bf6da9c25	1088
120	973ff3334ccff38797251866a112a931414140ecc1eadd409724ebde98ec4d18	1092
121	9284c1ca0af82c4e0c5b88dfa7d5e356ade0c8a54c79d4484e0ee9b5acb5e05d	1100
122	e66b1f9e7adc520e75a6f4dc7075f320a15756346d965cbdeb2e92ec2c7514b8	1117
123	e0446a9521d58c192ab454e3e73b564a6f3eb281710eeab94d4de33ef820594d	1195
124	d5f7919bb23372f1af6985651dc7a2e924401621735992b321f7512299a885d5	1206
125	956bcd1deee2c5bc57bfd3cc82d402d3ac0c74c2503af3f13bffd28a4c51e5f3	1209
126	f6005005a187468b6db0e7ca6b700e8a369f73acd43579eed22bbfe7362a5d26	1220
127	158bb193e872fe8b1b29c5bee8b49ed3f832090ce10b05529cf2f64315320562	1225
128	881eb587c315232a830d6282591998d6a37deb65f40787684d21edcc598bba65	1227
129	1d579733ade4d7cfe8dad3ff40cb63bda44b51e4bd15d87e736322a45983db06	1237
130	dfc699df7b08185fbc4a806967bf2937d94bd61856496cd245921c20b3c93b12	1257
131	f7828330e2ae8c1fa1319f404724a9acb7a26048089e7c44bfe8645cf2036595	1259
132	c6295195a89b90c896dc5f72048de4c076cb6d70f63d5737846a2c080aa37640	1261
133	370d3b4d60079ad1eda4d08b37f2d751d54487dabaeef49d4f2b6578190eee87	1265
134	b60b3ead4e1eea2af134bb2052b53c27192d9b19c8b87af88412410bc096e65f	1274
135	5a933e8ce5a1dc86fe034c40eec33071f271eec0b8977f5d89671e901f51ed18	1280
136	6f8a4cdd02b0c3eac36d1bd665391f24bcac58534789bc64f8ee42883b5b0f19	1283
137	947bbc860c27d04bf64b85f0cb72633cd4c0d864d02ebdc6dff17f59f428716d	1298
138	3e7441670a8db80c0144eb77924e172a125ddb37d5ece804a7a0c2c02d1b57e2	1317
139	8aad6c27c5e6b27295e89d93787e481fe1c1ebe7a64ac50dd95124ca63f4e05d	1327
140	7aff3a8734724eb43ebb43cb583c2b5b5801f818564e5900c1937e8f05fd553e	1330
141	09145eba7ec03146910fa4fd11435139205191b97e00f9e428bb89b6436e3e10	1333
142	7acd9199f55acf06240dcf142856342294166ff9f4f162616114639ea3adf5ab	1343
143	00083d970c5dd6a79fcd245de169ff9e6f032067242f15a6a47726ac9b40c377	1345
144	ace7d1c442cf5e0d67007f67f69423cae25e2b49559f7aff30d0ec9b5a3e80a3	1351
145	f429b88e99eb40618407b6ab4bdd62f424871a5960fbf911ace3f75f6f2fee12	1363
146	fbc86dfca49feb1ae736464c7acd0760811e8c4f370e26d59a6d17514cff91d5	1367
147	d579ec56afea669e7e111b58edc010f6ce9c2179d0e3be77d0d8c99a8c95fefd	1376
148	995853de83d8f2c0659083958e59e2fd78dc8ed38229602d181a0b772a6f7af3	1396
149	681229730d00c694b9a7d969a3a720beeebea56ac138267e138af1f0937f6fbf	1399
150	5e590eac379a3292fb6ac9b2d9710d0025bc17c0be8de8052082317e4d2d2aad	1407
151	204fcb9a3aeec571fbd06c64fd182de122fbe89e372ee823b558cf95d5f973aa	1409
152	02317d0aba34dbf46f13ae03f5d5aef0e8f873ca3a787ed1bfbc9adfd1e05621	1415
153	98241e0ad1f6c483f7e70cb52a4dd9a08f6b9b51fef2f645c6a6cd811f670ee4	1430
154	bf633e16a3525319b699a0889f5aff77c9e1c1cbd1476aa4740a2c807f0b594e	1435
155	c25d2effcb452ac3df49f9f9c6eb3d529f58f86979819de16b4d1e531f346675	1446
156	ddc43d85e9e69fa1a59e95647195384b84d7240ff984f0473051f95c40c70790	1449
157	10a646563bad68c18dcacc6310f5a1b7b5c4e9527b6519ac672a9b6dd0c1b08d	1450
158	c1b80a0a81e8c871728578cdd83bcf444cea3e1fd290143b18afb924a072036d	1451
159	e93d4308892bfdf2e7643ab4455e560f7b26d2f953594ae46bcb8be21f89d1fc	1460
160	8b4204a8d4807ac91d62dd8785ac2498c22f9345ae0a2ae44cd56555476299cc	1463
161	6113dcd2889d472c02714eb3e1b4c6b953c5674acb73017d85c525c3d6c181b1	1484
162	e9d1fd8bd43ab1e0439bf621066e7f9dc4742232cb35182be65848cd4ec378c7	1501
163	f886e1cb434258c1c6fe9cdbf48b41709d802ec9f0ff692d5c2ea970f104db79	1505
164	47c9d7eb3ca2d204f6f1388ef57817bf43b2704fd777450869a0d95d673d0575	1524
165	e9eab5c7d934a1e423f2f2b78e14b94bc17b16029a8d0b55322855216532b58e	1544
166	1df0c66de00460c9c75ca77870e45de3c00c5570f2ca1fb6c56313064fd7f8f9	1555
167	de6cdd982435d0e15d882e1c7d58a2069c8cfee78d2941e7a668824d00d6e413	1570
168	a104fbaf3c5e16bac66c4f22c892ebc81ee84f1b49c023f797b6efc4a6a2dcbb	1578
169	fdb48fba4199ef6d4c7b28d92a5823a03cafcfbbe19b7537af75b99a050b80da	1592
170	b60b9232ed17c0864eb193cf160fcb8a92a9c18e138c1ab19b1f1fc282e9f5f3	1607
171	2262b9c646339cece349f0340fe4d06f3f76ededc5d75f4e96a00b1c85c72d27	1608
172	f9574d99e989a9d7f00846c00c50eac55f561c9df9ef8cc742e88469f829e08b	1629
173	34087b47879bdc09e7bb1707b281559d35e0afcc289731bf5e400f9f7d32f09a	1650
174	f03e66969bde9d067d1706ab85fc3d3642cd3ded50a0696c1da258e86ef4143f	1661
175	ac786fadca7a1bce35d2b6c9ec6fcff77a12c188c2a74fb0a1da344ddff8b0c6	1663
176	30745ac6c96ab4e2aefc75bfaaf76de33e02e8be93a308059ed07ce1066f6b4a	1674
177	207bca79b16b195a79a56cfe4378e150f68977f4073d3e940b387fd9ab5da4a1	1675
178	9bb3dfca7ad5e338a934311ba9e7d9f655e51116971bbdabb551acfe8862079f	1677
179	60d0a1b48bcb301c35b1866fcbb66466d6cce147f413b0e3e58889076cc16e0b	1691
180	c6041f09fc8f70c23bbb604d6382f451bc103bcb082671e8de71a3d815a4e9a8	1695
181	f867bb33a0b44863b7c387a8d9df9c378207322bae16111c17329d6808b4c34b	1707
182	7fad4490177fecbd031ad475749002c5321f3941e2797ec29c4d54415cf31681	1711
183	70615bd21384b2fd3bb4d0bec94072def3149ab7f74e0044bcf900b1e0af2571	1713
184	335f08b716475c2d8388b86aaece757943f55e8218729eb465c1c25f3214afa6	1716
185	3c2ef7e54a95745899195a17509cd5ad2bbc0ba1fd17da4de7b18f481fc29d4a	1724
186	3f32f96a37e7844592af93b52312af6655ba6a04c403d42d7bb1564712fc3d7a	1743
187	b4b78949018e98a19a637a2985feacf1e8df6d2b38c9e5aac70f8b008a75ed7b	1746
188	03fe84b8a617bf13fb2b05941351f82686e4b5f22cf126fe509b9eddad398b02	1754
189	778ab82779dfaa05883dcb4b01182f3b6edf767b0785baab8ceac4bb0d8ae5cd	1756
190	c03d116a3d0cc8e85e4c83ca37909ff13cdce29700ab5aab698e138de9359ee5	1765
191	6421c4e0754dc181a1444a19b2b18e1b77ef5db46dc5a1b98a56998d86ec47c9	1773
192	e189ec96e9e936affbbdff91f5b78dfb3ad471f7d13d3496c1d2d6d4f0d88902	1774
193	fe188ae874a2c07cab5585f3f2c1c5c7f0358ab8749db0b6c60c6b308201269c	1807
194	0fa777059bf018141e649c52feeab4b39aea79c9435845478b58efb9024f2d24	1816
195	85b5a379d254320e1bd6c129bc35e6dc7f9dd8137b3d8a091faa1957343d71dd	1836
196	addc96248257d8ac706e55ef82f2b99e6a42414155152029e7376b98d44d97be	1854
197	dc818678e7923b442bd17a6852e495d9f85540546efb5bc4427dea124b520bd5	1864
198	9d47f7d4140d2f13cb2dedbe62bb3128775a3c0bf1f7a1c422f49ae0df689698	1875
199	d1769d1430fba7fa809a4c842dbd3c04e57ae6b35e8cbdc7a2c486e1d639b327	1888
200	43bb296657d10cd43167f7b8661e49632e2a5532207cd756b2daaf38d2c34113	1907
201	f4e52e82cceabd27bf5be34c96f1aee50e7e97f80ff34feeb3a01f08b02932d7	1926
202	6cad9f92523bab115ceb7f74ef0710f56ef66d4ba2e315cacf4a0fb8a9e662cd	1937
203	acd7e15b322b0bf1d80dce5b30f70ce3487a99402edd0547c5d2ef7b3e021d04	1958
204	a90451e5ee0d01891b8bc857c30490d40f022ea847da01bb3a516e9c24f397b1	1964
205	a8475a6bb0faf4d805f7450e1b81987a1fd2d6919bbea682552f60dc94bef4b9	1982
206	45ed71e1622c233c874470597dfb7ce3ee0cb5c9330d247e7301e47bf0fa092a	1984
207	10abdeace7cc666c6a4f35b990674e4f9dcb0d34dd62192ff67360cc2a0135bc	1997
208	3b087f304f61c9bd4df980505ce826c936c430c7d88d43556b12667ad29b3045	1999
209	3c1a55b5892640fb36f68afeca3c51a0b95a82312a5ade0ca3af80eab0595abc	2014
210	b8391ef342156ceb271cb3f21035d61a93667596527195b4a514f467d5ff2a25	2015
211	e4c27ee263a004cac8b6f169858cd8eb9d529feb66b80e4cdb335b3d9f5b5342	2018
212	8534a942158dcff116f1a11f8704ea9c313a0a425feb078a546089b1dc20484e	2028
213	6a7fa92fc3ac0ee0328b090c614aa69dfadaa682d626199a360fe0f247d40791	2037
214	e4ea22893a9c51d13487730d7986c95449d1c1f12fd82000453093213b5c9d48	2045
215	c5e788ff01b4515a5e431b41c9614af479133f77acff0fdff3372b8c9b6123cc	2048
216	26a96fef25fee2f0287886ec9b6614437c8f9d3dd3ef7b405fc5d4c19638e61d	2058
217	8f4a07e204c0dc0bd4f407209e925e0f4fb2c9da5247b57e3c5494dbae7304b7	2064
218	207a9ced079671d7a0f080fb623000f4f53f5b31e4290a0c706492bf1e78d363	2068
219	2c4a93855c780d61a1be2dfd6aad86e65eafc99eb7ccb640d1b5f510551e1ec4	2072
220	8ce344fce90f525f9bb1f23176bb30eb251ab079ce706d2d38348da33811170f	2075
221	d40ac81f24ce628e1aec39193c35d6ad7df622fc28c4444017dc899c15e3afd0	2089
222	bce6b8c43ffef50011f75d549418ae7b62b0ca775d2c484d584ea152fcb7a095	2097
223	740ffa1a26044b4ff326b17f78363344f86aff1cab20859c4441afbd00d12b77	2098
224	0d1588d4a509c45eb0225d471c82c31eca6bf7e78b71ee52acdc414750852eb8	2115
225	6dc968414c4664b65c2044b2f3a95d548124de5a8585b8c18ac916ad22583a39	2122
226	79089a2bbb21c281229444e145bf700acbdcd35ae1de920ae3a76f1ee5381e28	2134
227	93bfe0419d91983cff0ee8251920cbb53674c560475bc365df3efc13d3bf107d	2139
228	0c829905643d9f978f227d80a953036ef6b8b71a35ffb9ead78cb00c0df5f6df	2141
229	e170adfb0f6ccb9e59f5bfcb55f8ebdc994c4770a3605c39fdfff25ca2af790a	2152
230	f556cd1390ccc9323612f005a6627a00d0d856b574899a948f7a19eeaa2b10b3	2173
231	bbd5cdddadba19672bce26c09d60bb5800708c463c1676511115cfcf6e914db9	2186
232	33fabf37d86ead7776c6a40eb62ac92e66198c051006951edd62c5200b6d0691	2194
233	76b9334ea0a9485d5cbdbd623745c6f3ecaf21ec078e613b0ab61d79b1915cc4	2202
234	93c1458679d196b8cff8afb803ea3fa67fc4940752218b5ecddb1e8840935bce	2208
235	60cf0a1b9d8d8a1b10b861535bb6f6daff068cfb66cd684ad4659207ef19ee94	2227
236	24cb9deeb0340153306bb5dc3be5418924a514bdee82938c3170ea1ebddac64e	2237
237	5feffad1229116a7db7c847ed4888ce52c5be706fadc47f4eafe172f12e86fa5	2238
238	dbff9d3cdb41258fb828bf34315d9476f3161eaf505dbd21db00762a5b561297	2247
239	b387c8443cfc0092a92b0c06a4d68ce5f4ea19b85a38f2654b842267cf0d821e	2251
240	9378d1c7a90cf3e7d377e4fc5f327e6c3fed74e4c95c2b2c0213b21c7c48359b	2260
241	0a898d24d18f21e7b8ad54a40dc4100d5c7280931764b2e9c2ff2e092d705eb0	2270
242	056d0e3db837e168dc4fb3871cb971244a54390d51dca050e1c14df2e4957b79	2273
243	acfb9cea2ad1d4a62969e4a81e07bc147bc2146cb32ee1d8b45b0e7dc5dabad6	2301
244	8279cbc477c20b111274a638fca3c9f3829586f3b7e766091b4a983f698f60ea	2323
245	e0f6a7f0dc203c65341065c93b11c7835aaf6e49781a234cca920543e49b20c1	2328
246	d27ef1714553305b8a08dd96d4f5703935847ea03c1becd74e5187b1be2455a9	2329
247	c40c862cb8e75f799aedf2be2314485e522b2fd04ed44b5e11f72a1e793bd282	2342
248	4d7a23e728756b885e00824abbf185557beed355b38d6c564e82c99f3b5aa918	2347
249	6f3daf85ec223f7cc4859866ce5f5244e657a2bb1902b0281b1700ec14508c40	2366
250	97dd26b70ba8731201f6328e0a1d1a38927b7653ea11c8b34a46ab7ebd6918fe	2373
251	35023bf0298601d97f98e28f627b678e84fc3ce670753a7fa6860318c004660d	2385
252	e8f08f7d830675ce13537e7e0c4401ff02992fd56246056399c14921b36593cb	2389
253	f80ddcf2393d00af3ac1921a47d85cb9ddbcac078bfd64c458f7efa0182adb3a	2395
254	7dd257ec727288d5accd529193cc017b791ee7d0671d94fdece00a928b7aafcf	2402
255	3abd14c62b368a135430455630264521f86c76b97899bf83dd86d98d3ad56ef9	2409
256	e0dae68ce5eebee8ae6b05689faefe4963891fd08c138e7a7c082ee4847602e6	2424
257	88cffbd10988e5e2e49945ecc76c9651ae4be4ead6d6adbe1b2303bedd79eac9	2427
258	216375c83286111914bea2b3edc2bdc199af80f9805578ece50a20421b60d9a8	2432
259	ce59850d3bc4e3eaadef611c64afaee726cf8ad8b13fcc0810feb05b625a4928	2438
260	086583c186ccc00debbc58fc33c86df03a4ada3b1e82d0187911d85d98f408ad	2441
261	bd5ec10b636c9f1f962c9c3dd720a9b24c78755cd65610f61ac1368a96291dc0	2455
262	f652a1fd5b4cfc7224a56a8ee610bb09ebefbde3a1a06539cd0406683569d032	2463
263	57e4e83d189c53d02643558119697c2fc75ebf53d33e666222fcea636dd4aa9d	2464
264	3d62382973a785823990af182f6041feed57ff4a84994a995e2fc938c77f314d	2466
265	7fe146679035437f77aed00f2b046cd938d72efa9345f2bed35ddceea9363a4d	2470
266	98c773ea97f6f6ed1112d3bb7762e2a8ed187f47d7ee5cbe5a65ca2024eb430b	2481
267	30f6ba5ca14ffe497bf99782eae7e782b779eb09e66930f16bef6e049843a686	2484
268	92221ee8543bb2c4de9b17c2a5ff1445eaff401c483cf4ce1ba249237ae413fc	2486
269	222694c73d6b4383a53ee492d4fc1fd0aeb9c227ca95e84de9ab6c7738d2318f	2493
270	c8de6e127e77cb8b1ea67e037d61c5dbaf89b0a72448f36562110d1262cd8a81	2504
271	7b9ecbc9d3e6c45494754fb1be2b0f65082234607a98b4454ecb92cab88b8b8d	2511
272	cedad293dfb221d06e46613f96f32e53cc9b633e255e237c90a09c5bfc65afd1	2516
273	ec23dbc375b04701996efe9326c857c71fb26ccb8fbaddc498d48f185949ba72	2534
274	50124fab0fa4ec5ef15e8bd0d50dd96088c14c12a90715999893d483dab9f181	2546
275	7104acc0cc80fb13673fc010f7413f23bc12d7021580ded35209dedede5a0b6a	2558
276	ab80b54e88b4c2ecfce5841119fcad3ce37de8c05f5930564e37eb2f9a928914	2570
277	681952c0e043a3f1125079dfe2490538b1177c70a64130829966974f2cb92258	2584
278	a98ba67adbaeb00f5184c837e46199032ba42b0c89cb1cd158b09f8db1f3c6bd	2598
279	6927567386c92c1af08a8fc625f29f60398c691d323c466311e4271d0541d0e0	2612
280	ef97d596f5c0c1a503368233c623c67cc02d9ef791e933760494a4243cefe51d	2654
281	fecc791e73b4f78cadb44893bfe71e789df92ee58ec8c471623fe699191641e0	2658
282	dd91188e7d812563a3fbf42b4cd5ece62a57a1bf1b6060fae0833688266d4c11	2663
283	0e05f69a20f47b00ab9f50b321fdadd17e5daa9426d1a01a73aa9346a2d75aac	2674
284	e0d88940043201d991cc4193b1da88408c96dbf8256ffe5c3eb796eaa3d3fe5b	2682
285	df47b69566900f155b7a51baa572c9da987e4a8708fb15fa6a97758a5b8b104a	2685
286	764f77c4b9013e870afafecb001f04ab9fe923f30370882bee71038e7cf1fa29	2710
287	90747f61afe517431f75427eaef502326dfa0fce91bac8c3a35eded716469c26	2711
288	a6dd28985c1f66dae305d211b13cc19d350f30c1b69c2f4b8e9f654d16d39da6	2726
289	9602380fe64da2fb8fa112136320ccdc92ee875d3c6834ffccfc525baafb3361	2739
290	73fbe706b17b5a221e6d1f1c67ca6907c7b4554fbd0780fba8c78304163f309c	2747
291	bd2844351843c376fae2c044e4297a4a850ca035b91d7c8d5b39c6241c8ac724	2759
292	e61c228ec35c801235e08113092e79da4e0c51f71ca9311b80b0b4ea3b6c8c49	2776
293	65adf372f864ec231e2412d02d591c03cc8d819f502ae87443d6ef58548ec79d	2782
294	e3b240fac36d1c4c5dd6326000a97407a88f0d0a4411ed81226c92184bbc4f1b	2800
295	916015454e34030cf6a7ad30e361b6a348b440a35ce9e18a6a9c179f68fb43fe	2816
296	370982a337cc640d54974e0ac806847461d0aa3650ccd2c3137251e3a3c8e3ca	2818
297	0fd1a77679b52cc424003d6c313772eff909de8c0878bf09da3482f88942aa49	2845
298	f2017c86ce40feb13ffd9d8ed18ee9b372bd40a73c1ebd0785c46e2041562f51	2866
299	d11a80db1ac461542d243889d6a326a49bc840e6ab3b6c6e9fab14d5bfbda627	2875
300	232a9ac2fe1a3248630a179968ffddd07c0c644223893307e7d56680a4169f9e	2880
301	acfb58a6a341b8652f4a933f762355eea47bc3ff7910d249167920fe2e0ab8ad	2885
302	0022e933bff3887cb62a31df7b3c0f04f207647a2beefc155904b5497c880c71	2895
303	e694e9aa194dee2e818b455a8ac7f918dd56a52ddabefdb512c92f2b8bd2d5ab	2917
304	6f02dad20c84d2a9a82713b8e5e7aff6064eae91b8b708c0818797dfcda93deb	2937
305	9c9b3ed5eddcee9b631da474484371c8521da969de0911b8eaa29edebf061b67	2941
306	c90fecde7e0058ea2e512c6a8ba7cd153d3ab529be43cdebbbda594e19ef347e	2949
307	05c521b572faae149b1bc4e259f96b7f81cbe9748df99cbb27d0899f02c2ccd4	2957
308	e20f0d97227c2b0747a25b41926c95f44c6e022290a588c6d7ab35c37dd5fb80	2982
309	c54b7d3896fe29a286cbe8827ec3d4234120b572727cb953d3c0f90cb7d7ee05	2995
310	bb8842e11b54cc57bde05249dcd9b3f77525b17cecf6d537527b950b26ddfca3	3029
311	8ca6bdfc31cc33364e41b16f18c9459e4e6a17285708402deea8e1b48695607a	3034
312	c6d1994235f7b51070f111c2a6c219dea31c38ced53970864dd687b896d98b7b	3039
313	8e17f2ef4aae1fc2205c1c6622c97ca81d59dd697bf60bb36f1a5d48d72d91a3	3044
314	2c3ab510b1dffe1eb3b7cdc9908dc0c443a4ac682e037f7d2f7d3423bc586703	3047
315	c56f102a22bb11cc002a018b87eb15f68117f6c8d4e39f62d2f72b9a7425a027	3078
316	1ad4cdd4af2081b376016251dca3250b393f11c0d3774e6aa60a8404a66de3a8	3084
317	c17576848db0cbc43e476bab1a1dc3cf7a9ea766e5b497fc354eff9944acdd62	3089
318	cede22d8e0fa0d955614283cec463d3d100c7703192acf0f41cc75bc6ad2531e	3091
319	2a7ae42150a4a811fb104636b98176b042c764342af5f4c28305adbfe9dbfba0	3097
320	b1c89acbe746719811c1a6103e1e1bcfa6ac2c0f7af0100bcdae3bed5e9fe4a1	3103
321	b79efc51322162d750468df4c375f2585611f2aa6712b1c5b9ebfb4fee35ab3b	3127
322	46db1f56a6d36bd7ad6a10743d51a3068d9107c7b1d61237a723cf08e44b955d	3133
323	ae2cef7cd22f9613959d844dfb08f3a912ed0780e8a43a7f3316c1aa18190001	3153
324	253bce648b4cc20a67b19812bb8939bb9ee99e8500d7d54cf26704e3d7b18f19	3157
325	c7ce43a3d631ccd8b03be2d58bb22e10e11771cb6d2dc362b6219980c32aabab	3169
326	ae74462a32196bbc43299f8e1b3ec2000e67c5cdfe7f3900ccc5c13cb25b5749	3171
327	aa297458ce9de902e2d18766efb754e2a9382f814909aa22ebb6391424f002b8	3198
328	ce75c43158bafcefa7eaa3112d12f27f8938d7b38abf00134417657a44ff7657	3219
329	e2370a052fef00efad7a2f19d907c70f966a7d74b8106e44c663e4d31bb61a0f	3225
330	1606e38efc4c790ea7c087d9e6ae58bc519526d49bed1997c827aab3efd1ca6d	3226
331	4bd0a804b296646fdf9435cfb9fee9746d98bc4dc69802f3b84bded3c8403fe1	3232
332	23f244c6696fc5a83340c43b11cea1cb1888a5ecbbe6bb3fcd15ff8e0232ca97	3236
333	2c566e28067270dcb6e062b7d205c5908c1d4d47d2cbee786027fbea6929847f	3260
334	73d0f2f64200155956208684a9a7e4e81aa337d4ea12944d288fc2eb82cf5233	3284
335	fefce092b9c081d70c06da218089e029d5bbb61a8513af70f6e1649de9c84ec5	3287
336	19415b3b125412b95b6114b3465fe44891235267383fef47f1fa3d1e858aa563	3291
337	5339211faed1d6ee2b1ac71e908aabe5affe71b3aee9f3b016a56051bdc21c5f	3293
338	1140dca58a66bb5ce634ee9dae560a89c1465aba6b1c227e006f5d08324aaa69	3304
339	9a6688a5f6603842fff2093cbd0dcc55b2e0052e53b863483cfdf3b74f0fe19a	3306
340	857b9d7b359de2171502a99f57434f306280b7bee76b979045545124356628ae	3307
341	aa27315a58ba29cea850de4afe9231bbf8de05164b11490fea9ea431dbfa4454	3323
342	7153e3339266cd5bae646c359ac73ee3597ed2a77587530c12b4e7bf1c015877	3327
343	4159f880739cc8523a4ab66c7a60bb97381eefaf06865d5fc8584b61ad9ab41c	3330
344	0a37f853537634111d96eddc71369a580c0a1e55bd9e0f4ce82506ce34674553	3355
345	f71081b34f4e2b492619b27d03dd77fc74cfdf9fed9946891fe07910af74b24a	3362
346	fba3235d51eb43131c170a8715e2263521bf6640ca1e2b0c1b43afdef8c59959	3379
347	31983547d28e3238ab54f30bc3ebc06ffc9475e90d57ba8a72f2dce368b79c84	3398
348	4752633b6bf8902ae78ff4b247b4796c52c1a7a1856631c0501d43371514090c	3399
349	2245eae33f14830fbfdf40bd71ad77ea047621f175526312891bff17d6f27e75	3408
350	1935b5f4fec0025953a56cdd7b9e11c636b77eccc25d11d53ac48bdf3ea1c05c	3409
351	f7b90ab054a668e8e72d50b4bd4f2f80e310c222209bbb70513c410501a1a315	3418
352	a7fc7b69922504383d9ddf8aaa1fced924ff122e0796641159df3c9275819ed3	3421
353	f943ac1450caa4e9901c5228ccd4243ada098fb4e936db2aaf5eed01cf88ae18	3426
354	34167549511ea31a1cf130d6ae058d7015c63a46683d77487e30a1f9398ed694	3430
355	701d0d0fd9eb03f6b2179f8559ab527377ace2c896d70ed6344c2366b9302a7f	3433
356	cdf6b9ac771092bc17454c1f8de2bc3b297c574029694e810f72fc88f7e30094	3434
357	e5cbb249b19edfad7ae09e81eac3cc42d65edaa0b854617218ca8828bc2d5a1d	3447
358	4fff8ed2bd4cc99fb448559393333ca2adb6eae182b90e28048a58370625f355	3473
359	5d4efe61d1eb8f353776089d48aadfbf3679b9768d3890f4544b15d5d7707ad7	3477
360	0e87880012a6deff9fa6b2e2631b6b72d5dffab32e71863514b1e5e9a1d835d9	3516
361	fe706bd198bb393b1f49c152068a45e66fa305fce42baf02dc32279120fbf1ef	3527
362	4fe95766f8cb3b78368140162668dc680f4637968be770ff292e640df280298a	3534
363	f90919f75427c610b33cf9b29179bb1619d07943ba25e2ae4497ab4d47263b29	3543
364	7c40abff086fada635fc355daf1fa1dc90d811516c40fa70a3c1bf93d9909d77	3545
365	5b8511372b92529798dc10df2ebffebfdd656d28a3d9d920408bd89d61657502	3552
366	4c4c6f2be47f94a51f66f5ad2e7db8025e2b89d8e38f1bf9502689f9bc9ef920	3554
367	93ac09726e74f58c203466ca2817e4ebb86aa66f28320cd526593e06cb13a656	3570
368	a683c7740cc99658c0eb4804177187042e057296784869df08a6e581121ac392	3571
369	c8f51139436d2f20f446af727846fae4a3f6df9b43c66a0b4cb7ad697cd0f8a2	3585
370	4c3cfd93030ed48290fbbbe61f40aba4a512bf753213de34700532e4ccb6eb31	3588
371	51f38bea5c4f23c53266efb28403add71453f63069313713f95e2890300e9c20	3594
372	b7c07bd6485380b611a2e2ef3668eb25408471e133f3ad045d1c44384928b21b	3612
373	93056dd89887c68bb2cb1e05f21a5cde3140fa53f445c768c1cfb108a45ca52f	3613
374	023c2db01255d340f6b9ec52498e4aaafdf960b9872d3fe3597a490d7c304e66	3620
375	1048018999f5493314a2f9bea4f192b5034fb84d5d8ef500ef7e29fcafa4dda2	3626
376	a55640a26ca2f1826ad940b2c00cabab7d81422a63bdb5e736c446f6a4f32386	3629
377	2c8b43abfef9205fd349c50240d351bd53e604b2e52f720d359e445d2949e310	3653
378	a845db1cc3072704705cdfd0f3e2231b6a51ff3f94488aeca890ba9524ab2771	3654
379	8f518ce4f6b8babdf1412ece8d71efc0f95ccd3cb91e1f0bb7109e94b28a7460	3658
380	64129524d0a401a5d350d80765dc7615ef749d17025237186193b0235f2d61bb	3697
381	8d35eac242becb4e482fcb96cbacbb436eefb850b8ba43e99837bbc9872db9ab	3698
382	403e5ce3786544d292406ac70913324f18663926186dc9776fd5d6efde74cb0b	3707
383	7e49b2298c5e76440053b91aacab19db86f5df5f3c8c5a3b76129a85c6c9547c	3713
384	2c4e685058eb0bd76a571a3fea41043a8c7657d6fd238cabdf71ed9282762e51	3715
385	9cef8cc5160d76135aba759b2c8a43d6d8ab3de0c690fdc74597d1f9de171fab	3717
386	0f6e00a4a41770e4c6a36fec2b70b8bdea12d8a4bb108e5ac3ff5392e7fd1bca	3734
387	eabef9e21f3cf1f466859adcf295339c3c343037b76c1c504b1496be4d857638	3739
388	a596756b1f2205d7bd24d5683e096f2a11a0b80499dbf7cdead582d91513ef20	3742
389	7f6bf530084dfc26a285d1199eaea29fd3a86c2476461e94c98bf1494065615a	3745
390	090ff742bf8e41ee1f953d582fd6efe4ea1768f5996b45ec3013e7130fe8b887	3754
391	94886648fe343a8cef7c268ce6358d37a90aaa92bdf21d70aac4458c111848fa	3758
392	e76d10c40b891bc1fec5efac0e16004434fbfc9a55080d76b3195af2db9ebe65	3759
393	c841b714033b503bfb3e32f19e36b2799da527ce24fcebc040048cfe3b29fdfe	3760
394	b7c8864ef0126bdea26cc27b305991162c014ba9568304d29526f665bb698b4c	3769
395	1ae3a1c1445a036ca362b66494d5ab27ef777dc538001b535a996642b400937d	3772
396	c9119228c7de49fcffc61bb461d229eea9d993661ce3fd9c7b4f2dd4c7eee8c4	3776
397	dcd62496b5d7f0490692d6ede129e5d971da4a32fb2d66a58e35229f8d9128cd	3777
398	7044904f2550cfe69e3e86024f384c6f1fc336fe96bc86dd3b10a412a12effc5	3786
399	7e99aaaa2be50cd55f1407955d238fdeb32c72d59bcdaa42700708cfee4e6e61	3793
400	82ea6e0a6735259cd513c9b5a344db8a98cb07226244eb60c57c14b4bae188da	3796
401	b394272108f963f22f2c0dee048722dc9724b76eed238dc07add697c73dc5885	3803
402	8c46900b6b64f8d6a46c4a7d1a274fed016dc0e1cbfb4c3a2f46999031841cda	3812
403	0d250dd9ee867084eb4caf24a79bf9077cd64929716349f3d281dd26e6ef47cb	3840
404	c5da5500b98ce6274216fd557c410b3403dc1c45b101317395f5427d8a446f87	3841
405	1d18cb57df9f1b1c5819713aadf6608ea0ca63b5961cb79aa717d0d8e18f0978	3859
406	ef559c3ecff2794150e5a79315521cd947ebe9deea15a81a203b5144ff885451	3866
407	6689763d34ac77951087be94a42f81ae25150f8656b8f71811a95bfc7e0a3560	3869
408	35c52f15c0acd7f187b1c16ba282bd99c0fd324ad9a626aed57c3fb49e7dd5a4	3892
409	71bd99e66af877406a53ab2b476628ff25fafd9654a52e3fdc8ac01eb0e4ee1b	3897
410	c8f041c83e5c92bef1cbc9a91e5e79646fbd259bbae1d641619361cd846c13e8	3901
411	430d093ab36ea1ada3522445ac94ca098c39733e24e4aa8043b7469f966a9c33	3904
412	4f2bcbeea39e950cf2dad5869eacdd50bc8a783e0939d61bb7506ef40c4f18ab	3906
413	c1a6a8d7f09179ffaccb4250bae387b575e08ee75f2e01bc5d32094a23edd9e9	3916
414	e423120a100a48671584487bad6c694ae45a50881040d4728f3bbef6f46eb7a9	3921
415	99b6c953b897334d176c46a5bbb61364b42b10d96403b737fee5dc61af474f25	3928
416	0952daff881e88352604de5eacbe55d06af0117a107f291f07de1e7d3eb57dec	3940
417	ad9caf734a1e471445757619ef754dacfe675565d155a068cd7d13bbcca8f785	3945
418	94b54e17029aa211e938fa1a0e5459407e4c47bfc1cbe28623b7221fd87db7ad	3948
419	c2213547d86eb22ea1dbf535f6fd4feda4a211bdd647b64bc151bd1688739659	3966
420	8bb230a8bdc6b1e867d12b239ff5a0e26e9ed4cd68557f587e253c02b697d75e	3979
421	d092709b05ee0aca1c14f849f7a784424da29355f45c36e8cdda6f95e483272c	4003
422	f7665445012e6be9d686ff96155aa83572e868e1d19bd52e632bb94e87267685	4007
423	593537ad86a3973eb0b56e405cc9e3a9aa6b8a8a5701e65adb1ed8edcc78bde9	4043
424	55e82f8a4bb893eb9423813a686e63f157a9fa5fcc9c59e3f433acbd3b7f0799	4053
425	1ea885e4f868faf56e946a0cfcafa6b2fe4599041e128cf7986791a4f3665b22	4062
426	3d2ccbffbb6a20c9865d990b0fd3b63265fa5c0c7d254963218212f2ff6a86b3	4076
427	49487424bd57acdb54e0af683b29c75fd8ba6b6103e4dcaeb72036c015f296b8	4078
428	b0803a8ce63329806fd99651ed0b3d03b651c61137cf2532eccbe545e424facc	4085
429	3ae942c71959b380bd35a3adab72d57b9477ae29772f3573f9224daf826a2f68	4089
430	56de1203dad6358eaa189d083753f12548d50f0fe1753c68774278e137a79f5c	4115
431	81ebe5017bfc9a281743ed05db86d121f16fac5f36e5f949da5660149f4c17be	4124
432	8340c81e665e97d1b92d918bed70da1c13923760367ad0575e7043a26c873263	4128
433	46df48159b7c0083c0dd22d9afd34d6c23095259c22aaad47128a7817c4f3499	4155
434	daf46bc572ab808241d3cd532187487eb027d29e3cb3466e936a3bfc7cf4e350	4159
435	07c12846c8bb1ece1fab964f22e1facd2eaf0848ce8dced65ecaa25646461383	4173
436	67f6682b61a1813fb587bc5663f784a64efcfc2c31f9cb06639060e6c1009d15	4178
437	de5aa897749344de81b0d854d22272524b2681e673fa0db54c7383124d6c9b66	4188
438	770a2f700a38e779d88761426c9abb7cc47def1d31dee4651dfc9738eabe107b	4215
439	05dc76b1da74ecb509860e6e332967e81a3bf5e93a09a0dc4914062b86a7f1f4	4241
440	f3cc9450c99023cb2301003c2470ea2b7991af2a3960996a8d9a027b4350beef	4245
441	d80ce12cce34630d52ad718159efa9f369ba0cfba394f4009e8479de6aef9253	4248
442	b7942946a799d8140035e75b1bf451cffdee33426ed763192052084611248e4d	4262
443	86461028908b7fb0bee685d5b644a8282004112860407f50839ead79d0445e6e	4267
444	906138456db116f5b68c5fe93e7a1dbb461ef7d093b65c6dcd76404395b56d20	4279
445	46807ef401c3049a092a08ca4a218c9ea0e057a3dd49086100f34b9613abb6b5	4286
446	9b76f3efb52c6cbcca2a391581a81753ec113f4aec70ffd0733a0c806c6ade25	4298
447	730c1ce230ad45e610cb3faecb733e5a87be1786d3289f0936d3ec0c5a948db9	4303
448	3d7b32388ccca08d6585f3975bbd5b4609764ab7c13f8ae5dd802cfb29f39979	4305
449	f7f8dca3882a222751371b188555b1d9bb8ec010380f3583eb6ce4952de72d0e	4314
450	834054119857917443170b0fb8e9b3203c5c3e8c3871b6fe3105437ed54e3d57	4316
451	4fef34ff291bad7f77f559de843ef3dccbe5762ae5bcbf62a583dc5b3cf7df80	4322
452	963e6fb85ff7398c76992ca891441866489e368ff522518364a20838aaadead9	4325
453	cc1390a5bae99ee37781682fb9bb62b18529cff7082db12e615e49d3254fa5e3	4326
454	caaf3d3cbab2000aade9716c0b0a0d3dc8c718ba20f0f6dde4f80751aedd11e5	4327
455	5e04ab0bb562897ea6970b254a8d39413bc875ed67e3c34f8413ba7ce6ea7125	4334
456	370d151ad354f65c106e361fe4683f9b820e41367e1151ddc750aed5dcc16a6f	4335
457	53b9aa69d20621fb313070019f5a0830f0c765184a7b98d6e44ce5a5169578be	4345
458	1f8d2668d9e04f314dcd23d355607cfc84ffd54ebf59bfa1d833781ba3f18ae7	4364
459	61570ecad1a91b7d1780068691519043acc8517612e15e460d08d6f1e3e2bf35	4372
460	d563d557af506754617ff441b4bf556bd4d53b73f08d9a4ad192d8724ff293b7	4381
461	c952d20b23002ee18d7402a0ace4379454aab671ac6abdb5eb417de1bd246b34	4388
462	71087168c6e7f85351b0b483bcf91ef3178448f5d8464d027460c9dbc580b44d	4396
463	ca998e51c43c67c693090c422f961e7aad08526f443524901cdec7395a40e19e	4410
464	febc55ff175629ba1802f2c88e78512653d8da407f71941fd49da95d13681f6f	4427
465	cd7f09e514f25343fabd45110f29b1f737b5850716a0fe21bfd7774a1630e559	4428
466	4b4f5591a06765439c1c55459316ced594bed76c83bc3c843fc4d7abfd46a63e	4431
467	b17e2bab766cc6944282cae58b26b087acb7c2952ad681eed20f297a2037a3c5	4437
468	e74e12649371ed6e28ade19a1d554a97a65d0109a4bef152b2435e1399ce9945	4438
469	ab245e8e7696a916e82a7635e6c70b3ddf2f79669568e28a666fe321e0964098	4445
470	03058cc4d3fe80794334c61597199ccfb041d4626aaaeef4ae8d889432d5cb1f	4450
471	ae57c481f0dd1a93e5c18fd0b4a1e2c2c259ca188ca78f5035e7f3551326b39e	4456
472	bcae8fc388890950d2c95b3485e1b1d1d5e78e3808cb976300e4c35f8322e122	4457
473	141b4911d226ae3f292b3c50734d7428936ff0b0ac2fd82fe86b62bdbfed2e6a	4480
474	7d24390eb2bf9779b715c86b309ac66bebd07ce398697fa986ba65a7142d3270	4489
475	f13d8cf16cb241535680f44b242b9822138162d45d76579dda93a29e198a2f17	4491
476	e46f42406e1c26b20ba55d38991ad33743cc4872c22437a13f9027362253ce83	4515
477	c81245c9fdca48dec52ec0be0e5a592665e3347a06ff8f179c60c19582e3c12e	4518
478	161f1ae36bf88de0d752f5b6167a0f62c1bbc4de7f7b387628a70998872eaead	4526
479	0a8ff11f2034d88f0d5cbd8b51db326f9f581e66f0f915982964967481225829	4554
480	c49838383e696b5bd8c5bc62e8c1b0fba947a1691fbef4ff8577c85aa5c0b2c7	4581
481	16610af4b6b8b0bbe38f386fa5c8215fac8501f8f915472d6c01485eb2e3e9dc	4582
482	b9d89a1d1be31ec103617b6fa2706a7d25e1febb25ff219d1b414a4672238b14	4586
483	bc5ec157c0ae36ddb0e8b2f19a21a4399177bd53d5625c21a6f49feb9ead940f	4594
484	0f2f9bfc3b7a82643aa56989a6a8d386a413639bddf1c61864d9173da8423dec	4596
485	4fa8416c9cc92f8bc977074b7d41df5f98cf1928d3ee3018a0a0a992dab41791	4616
486	6c3e69bcd44dcf59cb435f69e810e63c651722e0c635f7315f9fb0e7f8c080b9	4617
487	760611e1e39dd3ea461042b382ce3fe07cd4f589f2fb53524b9b6f423ff953b6	4629
488	0cf46e86bb301da361fc03650f06006dd52de97fbaf7adde13bf5b18f5e7d6ed	4630
489	fdc6743f8d2f7f403cd3c3678c3b2da324894144ad576fbb234cc18722e6ca03	4631
490	3fc3da597f05d8c1247b2a74d268f5f5f108ef541ccbef6f7a568eedad4e433d	4663
491	0231f03322c5368e19f739f01966ac14df05232c66147343a13957ed8fc21e3a	4669
492	c68538eb6d468013dbfc0ede014d29d6b9c45abf7d911c96e504832d7af4d571	4707
493	776b27def7b075e8d9a32d200300919b577b96a9f8a6e3032051d1d95458e6f7	4728
494	919cecb1a1256c8103876adf2945304074e494d11aa72391ade3f98d281f0eb2	4745
495	cfe44313cb63024e09ba573997ba5a6faadcba15c4e67334c77561f896f60257	4748
496	be9332431c5d026753782f1820e4dbf0fbed803571b920cbe57c0b5bf237dd67	4754
497	220b40126c22be2abdbcd40d80049e1313e117e06fcff54a5ad28a5450128040	4777
498	7e87adfc7a9bb978c1cc7604038514005b841204aa290084b3ceef4fa2cfdfb8	4788
499	5acc0c6d668d8d5339bfd5b76e0d832fc8b6afd11cddd41b55eed827e69c08e6	4798
500	85dfdb98dbf77f0875f48094b3e13a52d87d9128ba7fdee317586ef7288fd9a8	4815
501	37b4b16ab4eb0573ad1f9dad7c8fd703156447bf9b6bbcde694aeb97e652e65d	4819
502	1904be5e6b7b7a541768976c462bae96d3eca57aa78b404345ef0b131245cb9a	4827
503	5916f1abaccad73a424841c7f2ab8b49349cc1053668936ae6ae9d5746d81ede	4833
504	ccd635c5eff23198f10e66dd703a60de5c133a4f7c5c84f15c319f60263501f5	4836
505	36dc412a805f30af9c4d4386c2a4e670adf744d0509ea69469e6478892058cf4	4844
506	e43549594ee088f769ccfda1c604d3b11de4131e1b0d68cc8863a3caccc7f793	4859
507	882d622536c04deedc7c2fe4e32c60f487ce0170fc4015e62b6027a0164c0336	4870
508	98f896c81531b1aacf7952597f428c9549d1a417e8c12e956634d5eaa46f3456	4901
509	ea4121269b50f59bb48dec30883d9ca62c0fb82db487afb0cb12c69bc65635e6	4902
510	1bf4319e638013982b33c5eeec60cfe65ac439328d4698fc831ee32fdc99787e	4924
511	7ec70aecda7d1733bdb876f7addcd68d74d5ae5afdb7c9750b9dae8d2ca7f3ad	4934
512	61e3b20296f73564b0857db360c762218e35ca7e05e4fdf3ed1f0b74d9714c43	4954
513	f2681b1c28540d998740be1850b6a425fa5d6700b9bb4d01f99297c76d9ed950	4972
514	b77ff63d5373e5eca82d038d4dd908d185c06e12aa9dfa3841ba0b763dcbbee5	4974
515	f0ebbe49c4c0ffb82d954aa0dbd36749439a6b1ee106c2d3527317594cc3e6a2	4975
516	c74576dd7f3393a3762135211bbbae061f68a794547113bdd94db402a48be51b	4980
517	f7cd2134554197273afc650ff818777d1775ee00962b5b3ed4de9b40d8349ce4	4989
518	cf49ded5ecbdde657ecabc100db2a7aae1ab98d5e8c3d3f59ca8b1ebaba8ad23	5000
519	1577c3035ffe66a3bc1e2e140f567dea75fbb4d23321ccdee05eec66967500ba	5006
520	dd1737eb6ebf2ece285bbda7b531e75e9db0c41aed03d8b58fd2b30eb4603b82	5019
521	3ba521c7768c918119457ea9eda479f3ea9b2e4c9e03904fec533eff764c1fd0	5025
522	79f6f03637456b1e77c2769972f8145da1f95f02d4de9432c5425e30e73e0788	5026
523	f3d8ff2a8f545d03770876b70a00df6c0d18a1d4bab73d6516bf10cd2046066c	5029
524	d1a6aec8f3c00e279fccc49add5a4d2d858fb66dda2ef0de1e217573c1afe574	5041
525	99794c94b9457d9d6e9b1ea75b1b8e310e4df0ed7c7915ce878743df0d7b47bc	5059
526	d065b0ab018df1ed4ec64d7faf9a1da1bd3617c8385ee6769aa4a9e91fcffe72	5077
527	41ac42b5cd99da892d9c82d3ea383a8ea78b17be1e09bbd8567307a4b4df9301	5108
528	fb5b834b3b84158f21ee3df239bd1f9fd78ea16dadf827fc86c5686a44d094a0	5130
529	2c5fcec5214f8432883c50b4131b5127488a59694dc95a7df782695fa15fe357	5134
530	a8c28b6221d05386399bc8f69897897d95201559e42a4fae17924db2119643c3	5136
531	2e852703654689e2f49222006f390c98e6ac2febecb52bbd6d033e63a2d292e0	5156
532	d54e10097c88544d8961ec4482ffa25db694120bd8294148e0bc29fade8212fb	5163
533	66821e7e3fdd56dea3f7dfbc270e682076acd0a9ed5ec5e2051a9bcf4f919b99	5171
534	5d146d411a5d873a294754761370701c88131c07232619a01bb83ebc7f32d8d4	5178
535	9c955277798b663497c2ccfd9f502a72835e016bbf60b8ef951c4b0d095cb4e2	5179
536	f7fbf83046e1d1d938d2adec1ee48462553e6341661c5b67010fbdba934f4806	5199
537	12a435131d8e1ea7538a093aee140da85dddeaf77534a2b620b170cf4907e744	5203
538	fe809a049995c70386713ce0d16d9732bd9df905b7ddc0d34dfa0bc9e0200790	5205
539	91e216a8179ffee79daf07f374f046b596b15401c9f9108bfb5e6580f679cb49	5207
540	4ca9fd6af296a0390f1335e6de77b8e3d13ac26368173064988dd2d6fd8121ec	5217
541	8a13b4abe8e6dbe62298cae5f3198a706e3543499fec55cd86a80d694fe3773b	5223
542	f3271ecffec74c7e6e51b1d702138e518159f75c35158e75969695a323e8918e	5231
543	4abc0dc7328f8bbb8f2b8ee02befdc388f0268081e084ffa9c238a58969c2207	5233
544	95343c8455d950eb0df7694873e6c860be0d1f532b3d758fd60f085fb0d06e52	5234
545	80ed0e74ad2c366648ed2ea6871e0ee8c531b2335e54793eca6c1d85cfe57688	5238
546	efb55a0c9b7dfc431bf5fe02db347fad690dc3e7b3ccbfdfd73fb39c2b5f2c55	5241
547	7b342ebbee569814e5934d9422f712f1d2c2339760cc9f442e47d4b9c9e264c1	5246
548	e71c481ca457964d2be8729a0e72f46552f7725dc2d2178a52ca321547cd0c09	5248
549	8d64a18777cda91d11ac71d78e1655b73e47b40aa38bcd30fd8258d71948096f	5253
550	62ed4d467791d2f1fa452b9d06ec12d673f3993d782f7039610f23d09e04f735	5270
551	c589bc11dc9c99d7e6701dbe218dc791f4115928ae174c322dc68d700b6895ff	5284
552	2987636171f98cfb5835db25d72922e82d541c0bb595d33227689ee8431f96f0	5289
553	f1c3b487ac8a90e1bea169e0dab38fc8306ea0c1f4a969dbe07cd1ad5042d09f	5291
554	6f43aa00f2de267662c4c0fc734d5d4dcef3c3350fd2986122137d9b70783a7c	5302
555	bb06a7336f44d3fce1a1013123f41f9481ba425d3d02e894c950e7fbae8c57b9	5307
556	6cc9f986102af995362646a0abc7c65ccdecb7836a23ed15f451feb72df5fcb1	5310
557	875915203fcd1c34fb9df231fefb9741d71f532bbbc2e57f1ec7919f682bf5a8	5323
558	a9b396f5b18c312b2e942adabf0dddfd0f4af295018aeac4f5ca1fbf47206b78	5333
559	a2753a2fe299c6d14e52afb42f0cfe0ad1670440e63f179f2ec1f95f3ace10f6	5340
560	48cc0ea9c5b8272c9cf22a63e50319da0b238b192e585bd5db20e8a8d9e3c55c	5351
561	63dfcfec75f162f3cca49f92d47a287e8b5d736cedb7cbc4a37ae709aaa42b27	5353
562	c485b945b93cf350fdc22a18db6fe2c1294fe9f19e636e174c2a5e5c02a076b9	5364
563	4fd1b8e8cb9aad4a48d3e6a62a9ae16d12f87173aae77a21d947ee02aa28fa69	5368
564	742362363ea924528a561294b27680877dd3979e0c4d73c77f395c509c336c61	5379
565	9f34f01417e0a88b0444171a1dc4cb9674c3e23cd9ecf5dac1f049ee2a2b497f	5380
566	2d3455e15b53b8ea6116ba32ca42219d3fe79e6c2115d809a162b494570e18ba	5384
567	c00fed57cbf4fa76a9b2b55a7815668d6b8a4a344e9eba9fee84bae0209e2485	5396
568	66566da3328a12e2ac198601481b8b88a34210ad8ae55ffea75d6a144749b395	5414
569	23f00f69eba3c5df1046e677759ea775f14910825790c3199edfd248a4438e4c	5424
570	fe99a77dd83682f68fa3546d1176e547caec840d4dfc90f8ddf63acf05114da1	5450
571	68c9ab39ad566a974fefafa28c2498b1f7043c02230928375223d80ce9e1f478	5456
572	a39073ff0f00b749be9e2ee64a94fb0f9c9a2ca9e4d3f4d88a323fcf965e0c73	5457
573	11a4a82f2ad4b20723e9c1c8fd2740966662d3ebbb240f7c768430cbfb45765e	5458
574	a1f77c50cd3783a9df11ad43b45acea9c12615833835b80b2704709dd4c99e13	5481
575	0bf104f0cf539f85e33b6a19ac76e0a7b336aa79ae0270a9113df789abae02b7	5483
576	6f8fbc736767fa8e42e2d39e14b44a3ad9b8a637e7ae0344b3c72bb9a0802b4d	5490
577	8944e5d3662d573630236beea19f1686238b788fb166140929bb1d1dc17c935f	5504
578	c6b6dab5810e7c942e78493f661e410f693d3eae4bb4864eecbad2ca59440338	5515
579	9a311b60b5313d8b7ec3426529dd2d7b2a301f39995f267f1ba35546a2e7b322	5519
580	7be3f45b39412fd8207fcae23255b4a6c8d983723f5df7486620fe10ca835fa2	5524
581	a1e6a61a33db15a39ddf1e20c3a0c441cff59dd3c41315fcc79ce2ebc3715ada	5530
582	a22f9065bd56113ada1826eab38953bbba2bde4439844885a267249c0b275347	5537
583	f6aaa7a0ab619840d19414ea3acc00e9a5d53b62140389416f6c99dcef6c54a8	5549
584	58151144de658c20f2b492b7b879985c0c537c90b7c107694bc141b67cb1ff40	5550
585	3049e1209b7aa8335a230480045b512ff2ba2a3846b9e61b75fb4e7e0598cc4a	5554
586	26da507a1f5f0dadfe826e79745c3413faaf1a461f5268c4dcca337668c0836c	5564
587	e5221bc5189253fbb9f7752e0fb6cb3737f5edd255cdcc801cf1c4a21883f0fd	5576
588	c75c99b1349c42afcb6fef4d5f52fb18edd43f62b45bb29c3229781596a2efb1	5596
589	bb31f12812e24362dc3f385cc3c70bf5d79cb13e133ead333c4dbeaf13bb29ce	5601
590	abb46fb40d00fd5a1090db6ea2fd95325f73fab1ffc61f4949a047ebb0b53071	5608
591	ec738e3b04235b36ed0730b044b0205690db0343a67eba1360123c86b3610fcf	5643
592	6ca2181934120d159387c7d76428f30c92c724bff333340e381fc8cf8d90ac43	5644
593	06f000ecb718a99240794ad229666b67280193fb334e385852ba7e402c126824	5646
594	81d15d8cb4e6e2b39ffd82faba8b61440edf521fa3d079e7d22e8b9be5116d62	5667
595	d2165927eda01fe4017fdfdbcaa9588371a54f9f8f515070e4e1048662e5bee5	5668
596	6607bdd9b914026febd84435ab2d28c365ff51534d5922abc888c6e1375fbe04	5691
597	049281b9b6eb0932383e3b53d4e699f7fff2f50772e1c2bcd3acdb7bfcae06ef	5706
598	fb7148de9d2c67aae8aadef5cb4abd4a3c8c23452ae93b5f19b708b27c38e1e8	5707
599	86a3a3f1f7ada44420df97fce33e45c97236df1297cd654cb5b4ce49464abcb3	5729
600	86d999d2eea95f3938a3810dcd23ce5cc09ef7a1cfe4043f9fc65c43ccec5e6b	5740
601	710ca8c04e0b0ac5f49226d32c04146698e2707914e78776c93ecee22bb1c053	5748
602	9cb834610afd07647b725bfd31b589a731fa3b4b161ea62c0fbb84d5560caaf5	5759
603	966a02b9c876797a300c52c09e150a4fb41f8a04fa370c36eb2038c975b2b3b8	5778
604	156f3b043537ac27f6ba02985cd28740d7205c0a3ee520499635b489b4aedd9d	5780
605	da1d66349b440bc8a76c4d076d902f7a97b57dd8248f3248a5083cc6f99c819c	5783
606	1c26b4fcfa457becacb70d41c1b2960aef989c1fc4d5994ac6b767eefa1d8a57	5807
607	53317cda03b0cca3b94938c4fb6e1ab614caba554064819c82e9139f2e20ef10	5810
608	7d7594136e6e888833e686c5eb493ad5a244785bd947f2a2f888c082fc6cdf57	5855
609	31e0233babb01f07205391ce9c99d452f1ad01bc196257179f2de54015e432e1	5863
610	e40a516d547085964ba388533e0b390bf157ef94ad7bb46a01e5cdd096c60258	5871
611	4783ca93513c14658d6a7e498e6c1b1821b7698ee80a520cd9fe1557aa050911	5874
612	60530dc97da6e150f5d6a0bf67aba456eef0a95cc3c05e055bc6a9e2c0f55816	5882
613	7d3d07b7125bdc6f05b7fb1b2bccbc9a6ab3330dc0eb027decaab7dec2d92a6b	5891
614	6f922363b6ef51553f4186cae871f6605742e4a90d829dd90fe54e5411b72787	5895
615	ee7947ff2805d33d65ee3cdec33979d18f56a04db0b892b97c19a5fd6581135a	5926
616	616ab8099c4862b74d012c858fbf40afdf2cd5a4c72146850695c40a773c81ef	5934
617	d40490f543221adee1f86086fb9570e3cd48c1b793e244fdecc5d50e785c737d	5936
618	7202a9eacea5112f75e0f08a48079b63847be983a78026a810bfa8276348eeda	5944
619	29e82147c73cae7f970b0117914a1f3e4f1554f5dd98385db0bcae51fa8360ff	5945
620	7f792af2bf7c30e2b91c538a11c8971719ebc60ff7e156325e45145e820ff854	5973
621	4daf02e912525adae83767eb63b1e56b30baad4bd3d4f33762ca1d172cb9160a	5977
622	0b7daf556f8a9e802cbc7bd78dacf42852dd3457375045afcfe42e5796bd23e3	5979
623	e9362c0b0dc2072d7bbcbd39e4ab2307aadbb67b9eaed00bf87e70d5056afb69	5989
624	882ab02a4790cf6d74e5f70e8e344c02b4a452899777d35effcf7f487ebd1140	5991
625	29df4ca6bef670ec991ea5620218c066b4ce87071e9d79dff77aa74e1dd76944	6022
626	25efc527334623781aaddfb3fcb8fb43b46f3346e7161c1c94228bfe73cd2e0d	6038
627	2fb4941fe37d354f844cbbda311484767d251057e200311a5b62403fba6b5f03	6054
628	5304c5e47c60ce10602ee96f33a958900a4b68c1fd5b9f770345193b8e287d7c	6059
629	e16a53252e68759938ec61fb14189894079150e57c79c7f51192c0a22695e91b	6071
630	fb6977ec51f66f324f2cb56a6cae006eb58a6d3b2ba6e274aea554a98e5d23b7	6073
631	c1ee842a7c7c68f8a15fce057bbd86472f7ec90708df9ec9c7178d60e49fcde6	6125
632	970b2e959eb2dc3cb5d909d136ba037c2739ac07e89538829046e83daff6c789	6126
633	275ac24f57209027e3b62e201d49f9c6845fd94a4f433548f59c4ed224a6ee9e	6131
634	6ad1f0d055304bc2c6ac029f6bbc04016d72b537dc9543f9a371989fe3edb91d	6134
635	9c02196eaecf00e07bd6ff143d5cb0f1075748c3113d95e515e6ffeddf1ad7a1	6140
636	f713886119b54718d0a0261234adcf58323530455b737181f93cf1efd866c0a4	6145
637	1c4aa2c32dab4d88e20c5fb36971e270341c53c17e5e55a530db62aebea28b25	6153
638	749852d967aae6112e504a849e8a2abc842a5323660b91841727e622d3c2f0ee	6167
639	e0ca073b3b655c71ff4d6f6e10bf9aa23debd6dd441c6b1d5853768fef91c9e2	6186
640	e34e6a4bb8661007158073bc9f0cbed0e822456937568da27e8038b9e2b730c9	6188
641	9104fcf9dffd1eae178b112cdf345d0590b3fb2f4782ae6a5caaacaaff7eb7c1	6212
642	bb9d28da356859384ddac4fc9c27ab8793aae6fe0cbe71b22dd45dc60b5b6d01	6240
643	2b59278e8b7a744009aaeca7ab089e2701a7605fd68e6f13444e8786e6c20bc9	6251
644	737592be21ed3209163bca3312fd1a832025363925bbe2c78bca92fc600bed7c	6258
645	72fa120da335bcb7904ad0cb5bf8d4c40cc4f8563a3656fde9b1aa6d0c97a92f	6275
646	1a1872a475cdd00d2d933a5bb5428aab8a2419d5c5cada417827c421c02b415d	6295
647	b2741e46b8d05a4c201c9f919b505bdd045a4075091663f3da7f8f7e9a0919e1	6298
648	9365eb006d16bcbb202606a5b87b692887e5a2a8115278a5d3e187f8942320dc	6300
649	405e237ba03997dbe9e684b4042a93e868fc58b2c34819d51db6af7aea3d6bc5	6308
650	f91af48f55832e6128092d7c8caf479074b23808f1bd58b7b49370df572a590e	6309
651	76c6a57b15ae9f385920b97ce4ae1da3194948f86701e6f906a85ed038607277	6318
652	344b6fcad80a5245b4bf7adb1faf3107b1f02aef2dc01faee56104728ea956f1	6326
653	842ed182776e6788382036e8bb70802b224b96be30983071136b172666726fef	6333
654	f2395d82045c5eb661f8dc0ff30f32fb9a671914eaa090893e3fbc9ca9ae37e5	6354
655	954228c41ecdb18f7875d7b8b77e30548664f699be398fbd39609ded8473d6d5	6365
656	15b1eec20c463bf8effe215fefcba133269cca1471591e5ac89a7c93341ef6b8	6373
657	228aeac60c39b606c1641a42e1ff34793a66023b54db960feb183e8ed14dd1c8	6386
658	e750ee6c4fd37bdd114f914a5e683f547ff15f31f05326902d47fd49fb7aaa7d	6399
659	27fa55d9aaee56c8317e18b085d66ab8e8c2e7815a2e529d4d926b9bfb10e947	6413
660	049a65ca3a7be83f4ab0bde8ea24bd8ed3c33b9429b929d93b5c9ee194f6f3f1	6420
661	ad87f613700bc9e0973e3d038d3a5a508813b84614ce8ab9d5bd73d8d22a9b70	6425
662	bf73249b3b072286e594284c99f33566dadf4b9786847964f0a6ba2cb19732ea	6433
663	b62ce022aaf57d48c6ab0a1adc321ec324c9ca299280604990483a5369ec76e7	6448
664	b202d28a0420909196f3a6c0d24600cc902fdc8853531448bd9507000a4826a3	6478
665	9668834e303ced064f6b1c79bf55e31c8b9143ccb57a10051c825495b21f8a2e	6491
666	85540ef4e1854bcf4611b9ea233fa5331c392a95639b8a721c7e0ce2ca4b74c6	6492
667	a765f1828c185732d7790800b00f4412f717ace88f70f0110d0752fb1e3c817d	6506
668	5df803e34d86084f07daddc59da591684d0546d8bcd8d1e57d01457ca1fd4fcb	6511
669	e0a6ef3343071b0214440098180fd60a67f5e7b4a72830a3457130135ff4c53d	6523
670	489a8994c1bfa8061ba5c9c4cfa1840ef714bfcf9db90619de7738a6072c217d	6530
671	674ea6e1acbc6c488ea3359071c637ba141aa7a5b818e005bf3924f999a20ee7	6536
672	316491338dd44515e8f3365e210cae55757af47fca8b56ecae41ed9bd60a3c5b	6537
673	a1d90349e07a012dd378f1ad1618cbd26c00788e4afa30dab4972afa042a86d6	6544
674	90a0a3e834f37cc77c7f18e75b9671a6f36c8195903a58641a60ae3390ff8243	6549
675	cb6a9f2333f31c4c137c894d44d89aba3500f9626460350aa5da3b0bd749193d	6551
676	80a700dab4f5d82101712b22131dd6d53692a5ba14abc4a5f76c78285bc8faf5	6574
677	74a20fe10011a72b57e7381082e4262cd6ba44e0c18bcd3693d8f1a29ea127ef	6578
678	3b069dca7a200fd0149f1793308785dfbcd7833383781796cf8b02c1d6cbedcf	6586
679	f26738b0e285849ae031ac59ce23526b4b10600f883159ea1dfe75c3a5ca16b1	6595
680	31957353d8b0bde13f9b5debb415bfdcbe11ac1df0407fa2a1b9177bbcecf78a	6602
681	cf7dc7ae499055c573e950cdf1e0c5a7dc273e633cd3e504ab8fc3389afaa2ea	6603
682	d40927adc22526fcfacaa9697f07e6668b505560c43fba2aa64b3cef94cbd694	6606
683	31e688d089432a9c091db2c7c0fe3114bff3199eb476a40b5cba51941534fd66	6613
684	366f7999e4448f7c3ad7d7ec80aea9e33df6bccd0de65705de0479d37c55f833	6623
685	d0735bdbe20abda9810383106accaa9a3ff2fb83963acf9f834832b1cbef7e8e	6633
686	6eb387d7aab1745bc46f6b1af683cfe7f137a4cfe83ab0d87dbcb8c3ef468536	6650
687	7cc71027e1d09da023c2cf8debe25f88b02d7b3e1fd4b2dd7f3e854103674252	6658
688	79c0e59204b7acd499d2ef722891377728aa53b756c3081d363b645da34502de	6660
689	2bbbc4833011dcdb003ad42b422f9908c5dab7a9e860252922cdf0844274b520	6681
690	eadfe9089a4cf76de452d5029f809cd472aa14484ffd0a831ef005ea18506fb9	6682
691	b1bfdbcf0c05344a4a5b5a835776ac0aa8784477008e35b50db9015f939103ad	6691
692	e9bf9d991176e5f8380d8e96ee007099fa62244deeeef050eebdce81bbb86708	6694
693	477feea78cb0042820b86be1b08c4a28be07f4b476feaa4a1e3df26f451fb036	6698
694	ee2781fd62788bfd0fbdf6574e19b2018d0b7ef3b4b41062aa600b1f243a4335	6700
695	9f4d6b0585a8cdd90446a1792242f122b5d144695e85f39c84dacd5a8f916d96	6701
696	7dadb1750c36aae9ee65e50bcc2f70614405cf43abda201c0e9ca256cb7635ec	6703
697	5315fafd81af14580a01944f2ba8a68f7424c7a79eaeb6a7c61665dae5c8a447	6715
698	a0f48263aad66897ffc475426dc26578d766254d9bbdee8da83ee59bfeeb267a	6721
699	e9074cf2edaca36f98b73dc0622332b3a60481783a79271420325c1e392be39a	6729
700	94cd2fc867a2ac8c1ccfbb95000d4e93062a42de27ed29a60b53c8c95e64adf5	6738
701	31a5a54f36652735d61faf6465e15b4da79975403c4e6ace2edb25ef5ce28c4e	6743
702	2b10f7248583ddb06948d6595157d108b92b07b2d1f4b6181efbc12a0dd67df3	6745
703	0ac5f99c578cc0eb133f7347e08d55a32d6979c761e36bd87d64027d8bb73918	6749
704	a03143e7cb1a0bcf67b1563aa8895ed93a603a6482a1d93908c4828497c971fd	6759
705	144555ad57bca707ad45d70feae52002040a17b2c677c06fcbd42779eb49a6bd	6764
706	958543559a307931de79d724868baa10c367268c5df5b1fb8cf349f94f16e624	6771
707	a91bd48c670c4375e4dccce83fece24e8a6e9140fda3866aa6c143bbbb7fe044	6785
708	aed9b02505c490f48c043e1b96b0a31b46feb72744d173e67f114fcf1ef8c0d9	6794
709	258fd51b55be9b75099bd0ed4f535ef54b340c5972009e8bfedb16467d59bc72	6801
710	535c82c2c26ac3a667b258f50b27827b5f10044d8c7658d0b23b4866eb916a5d	6808
711	fd39c8edc2d786237615f222031ae54c73d75b71ec6ce2f3a5f0f87f1552e4aa	6816
712	137ada5d2ec0f2c35f48eca8b08553902ce43bc20e6239c1d4bee33161dfd277	6818
713	510c8373c438e41fd4df90eab50bba5cb46bb1fb5c33ba188b058c2c9fa2c6e4	6824
714	bda31241537fb147abcd329910b4d2b558962274a88d3ac6ffa0d2b8351dba96	6829
715	79d0cfb168de754c4b418a7bbeb84ac50aabcbd32705713871fcc7dbccc3fc97	6833
716	8e41ad78b642abd1f4459bb41609c2fb2ac3d0adc7cd133c335c6ebf509cade4	6834
717	c74f4ec6dec538f57783ec335aed6a0b631ec4e502f1e09d0b3513418a34c1ac	6839
718	a967336fa276266f22fb9e0e1c59ea5d70564bbcb621482121963876639cd132	6840
719	3784e7fa65b5a83410c6679436f2617c102273ad1e39a2331cc1c1e86aadbc9a	6846
720	c872dcca9d32fdf4f02418d74ad8dc54171f917a4e921421f1ae0f4e7c13657f	6847
721	6053b8f774f58431f494b72edc6e072a8e1d8864738cffddc1d80f2a121a89a9	6861
722	7595f20b0353f9122cae5aa5223f32c6b05855366a1091eb90383b60639d879b	6869
723	21a5457f2fac48bf388d45b238d14f6655c888468ba685f807108706dd0979be	6871
724	d7e24f9cff56cacbd0557d3ea90c9c307d8f104c64ea76c2cb147a9eec5f4738	6898
725	9a1f90839f772afd3f0be2245db49d061b25053026da02de66b584a9a4888e55	6905
726	a52ad4616de85396c1f825d43399187cba7f0f4d0f65daf83bfc2ba46e68b44f	6909
727	ff5a3ebf9c1cb72cbfb6f1f659c95579a685654adf28cf0cd946dddb47e40afb	6912
728	ba5d94479564de19637bc66f90f8079db0dff884b8ad2b26d383fdcaf69c2e66	6913
729	e7ba7157f57c37deccd85613bb34c3f44980082f7f1609a88a290ba831d10882	6921
730	c0bc95af11b89d5ba914c395ea1b0a95d61682380cab549ca71f1ec311760966	6925
731	0946d7a996b1f14c693ec7f1a2373a0db85056a08b0687bffd7db9b4b243f6c3	6930
732	623824351160485096a961ae5de7a3045c48ef8597be2ec14403d8bc85ab6a3e	6941
733	672d670b0358a164448b6edbaaeac0e0b323a6aa324c572c12ab43426d1ed774	6945
734	10410f1ac7afc4ffbc7d6a333eaf0a55f0895e2eeeeeac350a9ef9066a02d4a5	6958
735	a67b5eb2b3cc0e9454d0bc28a5fbf6ba6fb250d745a4e9f97486e3b7ccd2e951	6963
736	b7af897d0c6f9c50e5943cbea3b3088da83cbcdb2e99f866d222c2a13e351d14	6984
737	1f0cbf041c9968b853ad23e7b66f98b0259bab840d9bf7880c1df06cdd90bb3b	6988
738	eb9a48b6295bc3033a366a24c60b7d377242ded906205b0c0d6e0295d18adabb	6997
739	ee51839fb9ee409fc8b9961813810b1b3e3b3e47aa63cf2caf54d373d29f54fd	7020
740	a63681ce676c6573b80cb04693882b83050f30c80e54c9fe35a88d5470469b3e	7022
741	0a2a4e229529d4b16e3be56b41cf14f02167db519919fbe8395eb807194a8cde	7030
742	daa8e9d015278d9f6224c1c86a0060262f6441d64c54e79b787242e2bb6917cd	7041
743	5d23eb49c322133661fa51ad52e54446c9dc8ee746c39d7875775af9031ab961	7058
744	9101f56d36022081d3f974a3d5385231c9c6be85d22881bc68c2958c2256b833	7077
745	47c047707fccc2f77e1c57aa00be530348b9d54a71eec90c6eb3862770311ff0	7084
746	47fbf0647952d22c359f80b67ffa9f82046e6548daa1edc7e40305381fea585e	7087
747	d0ac81c9a2a28a06d3279d32eb171dd3a052e8e29955abf3c6f10e2d36f577fe	7108
748	8454c42a5d4dd2114a730a4587c1db94f207498339139621bba921a331530677	7114
749	a2f53539f399bb2087a9cdceb33a1c49cc9dfb713163a3f06644dffbb0404dc8	7123
750	c5378c7b2b26c01e61a52273d416b7b2f5b2a6320395c02174072c33e17e5d1b	7126
751	9c05328dc434a72d4d3c089d837b6d019060d76d6680f5f54f1d87f75814cb71	7129
752	70db2a841adbea52925c4cbebf0244c73f542b739e837af552b1275ab5c95363	7132
753	ec39f687c3e1b46512f44e39e5c63dab93123ff3c6599e61a5c440082925e9b4	7143
754	b953f004e146724768c01b614e06c76e9b234f2fdb8f6ebf1ad6d9b311585147	7154
755	4acece030dd12f50f0a442ba83a7c5bcab6aea7aefbff91fc1c3019a84b9abcd	7180
756	8f3633bc699f5cb8465ba66926baafff2c3ae388bf27ecbf244de60c48a12726	7198
757	da61b03856ea6d301e9357348b999fb0c86859a799925623c26d6953e6ded999	7201
758	4f67516d7d760de643259d97cfcb8f3ebafc6b21831c8c52905acf2cce58acea	7220
759	71f6dbbd1dc28ab3fa86bbe0f0b9e96c28f6bacb2a6d0eb44e989b3d83d6180a	7232
760	301b2fb124fff6cc12f85a709d258c1fff37838ffd7672e6af8300b90dce9e7c	7233
761	054d1ce83ba5c7b5bc20dedab5f39fc0bef8d1415a79b7af55c3bcf04c1244de	7239
762	76503b22a166b6c64007c8fe47691dc462ed83af4bac09d6af0b8e492268e559	7253
763	fb4e68324ce4a009a9360aa58b45b664d66f318a36d895fbc20ab40114cbb668	7271
764	85632059409eaf3425bb0060aa07caa139ef7b585910b40e76e5b7390d37a2d9	7274
765	5dadd21704b25119f801237514e4cce10901fe7b8570625f9c9b847b5aeb185d	7282
766	b2e7844a19885967b56f1048905317de6c2ccb559cf9eabc285a37c51fd4f9d7	7299
767	5f9cfa77e61443441f25cc28f5272013409e18402f68b5c88fab317ece9e69fa	7300
768	8b64d21b8139afccbc3c6f2f0f5924f5652497873616ebe3173d92174710e21a	7304
769	af9f0da86b3503ccb26a297c9fb6a15493d9ce6df1e06b81a7d9c066650d64f0	7308
770	e77b070147df463c6cc9062486da40be2974d636ea1270f7065ac4dfa4442efb	7313
771	1c90247cecd12691ba194dd3236f10cb1e006fa7cd9f8d911ae03869ce798628	7317
772	1ecd2171539d05debc60168b72d49a76cbc78fc827dfb94066bbecdd909b9900	7324
773	4ed0a20a3304d92a4a75f222cfb1867a7d71bb83852b8856339d93d11f5f1d97	7333
774	8cf873d880591d40ff91201281c6bb9b3e4501eb0ec29646df98a810ed32e3d3	7349
775	fe7429870c99efb5713874f3d862e4dee9b1b9b5b728c9722347c5c2b25d4037	7359
776	1da35a3a889ebdaa3d69f093c9eefd8cfd44c82f926769e1166146209e9320d1	7368
777	cb6fe3ebb055320367b716bcb64a603d544be577ba0b0440540a0a5000f0a196	7372
778	a1ba5d29e9c292442e117ae3e701c1a6bfb2e8570a5751786d51e65fa4fb1cee	7403
779	c0ae8d886c9ffb4b7b0d292d09a8e7f90d9218535bbf81d25c4c7770503e923e	7404
780	2254b2bf7c0743e294c6010d0d59efeb4df4c4361c3e7c559778ba201972cf13	7411
781	4c420ea8b8a60fe28bb48c5d82424f55e919b53c5736a14b931093d4015d4d99	7414
782	42e4a814bd79f64e6ac95e86c957d8c2ebe6e3483c125dc198588ec4ab1bdedc	7421
783	5c299d6d311729da0a21af76307c8c70062eb9c25576a926fd94828656b57008	7422
784	77e2d92bb64957db0cb07cdab20b7b0c97a2bae9990ff6a09acf4b4b3a4a254a	7455
785	515a79ba2f43a7b79e743d972c4a26889694f16855d28472f95f1fe1222c2159	7464
786	6d1c3ce8037ae75ab1d9547a5cf8da70e89efe90c0a91fa3e068f3f09d5992c7	7469
787	f48c504057314009853fb6f5802c21d16f8ba8ff1111048141ae2a95b5911308	7486
788	cbc1e6ff024c5f4e5f68246f314010c6e55f459f7067ccb2f5387904e5294baf	7504
789	6aa49fd0a44404bef7d476ce27da88997364e559817572e5335c902e329eea99	7508
790	38f9d0741307643953c418adb983cf51b4bfb73c6315d48ec522092c913472a0	7544
791	251d8d5abf449cb6cb1e8197c47312dcfa3bdb18508a26db22f18f1e0a2dba47	7570
792	dfbb824da5b607aa4bf6ccba5778d3bfd0b33df26c063ed7ef86fdb51a21eafa	7587
793	c9172f1cb82cc959cadc51c6255cc848f7d4a650ba67af43f7220509dd73d8bf	7588
794	8540d811c1d2af1e27a0a968251865a690fa2d5ce1e8f4353e9619d8b920198e	7596
795	fb2b239d234977ff40bafb9d8e80c13ccdca3412125b999565df0f8ea86639e9	7609
796	ec877bab6815ac92909bef38dc537e14f6c4fc0b978c77a072d776af81c2b17e	7613
797	91a7a0480c5a81d8a6abc862e2f232f1ee5999efcd27fdd1d436b8d2d1400437	7620
798	e4d39d1916d1f2b5abe13051f3ae1db65026ddc209008867686a8450d415226f	7622
799	e0a85dd69113af8da7b05d4765e2d33e58ff5a65dd65f36e8752d5e4ea311bef	7633
800	6f302191d5d55fbe65cd6edb07b1798f2811f60c3c7b54a9c7c4e57a7b9c458e	7644
801	611e7aae95c462b8e300f90731b55b85f48c8bb0b1e09294c5137f0b36500ffe	7654
802	ce89713ef9fb748378ab12e785372d1f73ba605ba316dcfab0f4eb7780a7dbdf	7655
803	8ae6e8cc5c46331dad523b59de983434250f5675651372f63e9bbbca2cfdc13b	7658
804	d5b491bf0472bddd2d8ad858f92a69ba6b8fceb503492e42a0edfda85e80516d	7665
805	1723f1b3f469c6ee50fe2d376a80d1528f585097ffd2825de88530e7efc0f3c0	7684
806	066171269ad437776f506167501b20c1edab36258c9a116a1690f1884be3c6fe	7686
807	a4e9dcfb8b80d6120c66854f0feb85c750e0260e0ea9b59dadcecb4c156506a5	7693
808	61d1e46f7134be2ad21a1a6fb610ab5c08740e995849a21444d4948f6bf1ba5b	7721
809	bc0bce435a7aad2fd5ae22f7c756a9d78bcd547808beb26d222c39f700269160	7724
810	6e4a8eeb47af951444723766bb37067cf889a92b467c696d5bc6b3da350a35b5	7727
811	abab8d99c0280abb0aa46562fd05c53d377d5003b5cc6a5ecdc26d4f5287e6ac	7731
812	ead1c5e43f95d569521b16f5b38098f42f88180715728899fe6c640dc39fcbd2	7733
813	47dffe10f4ab425cd9a39f106e2b6a6137b906a813f917dfc87d462ca240b869	7741
814	47b77060d5d359453d4ef9df7d544670fd1bad31f3b0f23772e5032a23fb6d34	7743
815	ad05d16aa41edb371fd5845f46f4e44e3b014cdb9fbc144233ebb007c421c029	7747
816	5c39e1d1ed9875acf677e2354055aa4b7d8f7909043832ffe3a139bf50a72f1a	7759
817	45cee308f5ed049f17e35eb083b9621ba31cf1d5d8e55250a6b349f5713f9977	7771
818	17f8923a148baad7c6e8c602ca1a70dd6308d666e2ae686d7f012836e1b7fa75	7780
819	484dd433694a45592254cf02540b8c85af0ec2ead72df0310f824df4002ea679	7786
820	32f48727084fcf12e581fb97e11b587ebd45f61da32b6b74f95fe9345496e43d	7793
821	b0355a83a3e9f8da0a9cf320c05c60f762b4519e564279ff072e21a621c75855	7794
822	8b0bb78cd019db9384df6fa2760b95f8d6264908cea75b7363f173b07436fa98	7797
823	e5c5f19bd41af25167513575e5bb432fad21c33ad66c54cfc8508a1665c40de1	7823
824	061d9fa17bcf20cc804a11da95d519e622c66c6f033e5c68fed1be4d00d684fa	7844
825	9c091da7eb55d8e9c2dfaa999c6262747dce36941557cda97d1bc942d64154f5	7851
826	a9eccacc10eb810a157437136622f12ac4e5ff70174318b3ef8ee44138ab6bc1	7865
827	fdcfb3c4e9212230c38cb2afe700720cdc1685cb15c1609f6c5073f9aa808362	7866
828	f0856bcd5a8d31da18e0d77cb00deb47c6d58e2d862acfe420e22ab16bd15e36	7888
829	6f2cfe56f417fa3b160baa64efe5cbdf3a90ea67896bbbbedf353f44821f8717	7895
830	86ff20b1736f769ab95123a53d4ed881c1f03d54be34111223957d797656a086	7900
831	1c89dd558d656a1402f12906c7960094cc35bc390ac468657aa8edb59ad7aaa4	7911
832	4f0350447c0d0dcaf7a1517588d8fb93dd9123f041d89fc19ec35af488c232de	7915
833	0f04bdece22ca4fa350f7d965ce1dddc0b318cfa099f734908f80e1f1c4f41ad	7921
834	397d780ada3640bc56e09cdd9b4d090bc118fe0a2314ebded453d68e237b317b	7930
835	a675647e8b6658f648a35cab70c638e2f61026a50b734878455e16c56c3dbad4	7934
836	6611cd1fa7aeed44a1bd8e9c8d663e07be2f356fafd9143961dc25e093b8eac5	7961
837	f5831abda2105989a40e8ab30dc3f69bf21d4dd49e7baeea3546875d8ff04300	7974
838	04edbf5be78f52fd4b64e7a8b9c9cbcea9b9c8e9e5c0d501ad29110556b7b228	7975
839	6d40dbe9703c0c53fb8ff20bd6b96bcc3d97bf4aa022846dd000a515cb0c4662	7979
840	f95433137cde592376507e8749f35d38277962c30c198ca115f8c6404378c982	7983
841	b4dd67e01bee04915d94ec105c7ec9e74ff5ae321204645ed8d3a4c93ca11470	7992
842	e63432e2534f4cf5cf1f61ebfc6d018849916039e56be1c8db9fa5fba6517b56	8006
843	4d6b1875dc30c37a540bf304c9f293880bb585681c3f8d7deab76c7fe9d88f08	8010
844	33a9ffac57d3558e7d941ca63bababef51eedbac5da10ccdccfba3becb9555a3	8012
845	29ece97da0a7a4834d0380466ce1d6a9cf46e20f0259fdabc0bba578a3e50d22	8015
846	c1bf11a1384b9b0ea918d410af79521fd64f7640a0a4457f86bff661e35b5df6	8016
847	7aa59c2497aada54092155ea35e8c302c11e188ac3d209d36678b680c7e8835d	8019
848	a1b7a76a8e33105d1d65f1c1677fe87eba1d3f3c9d831ded94de13fad3abd605	8027
849	104b9fd1e1dcb2027d6e56b85044fed8fe628527c068611834c804dc6f2e42d7	8044
850	1ec659c3481491aedef74f295126be8a81a3cec9e2eea68c06106a1e5f3cc2b9	8060
851	f499da8b1b58a073ea7189f4facbb71beed550b6b8630ae0985fae8b231561e4	8067
852	85ec8438c92fd19622520178d40392af5fd31392a1d979e44ea001b616d8d37e	8081
853	79df786c17b655b2acc440e98f4413b11d2b2a300493e190b3f1805e99c66752	8095
854	1b56753239b737003f878f9eae3fce7d9ef53f64af82bd5516ae57fbf29cb4f6	8104
855	7efdcb26f6700438f4e71c30a723107a26978acf5a4485727bf97490877de624	8114
856	bcc4115a68e7c1cf86032a294170a4f599efd107e5917ef675003dd683f81b27	8123
857	d9fbc898b292dd315e6f038ba8aeff7ffe51ffb16563cc2cd19c17bdd052becd	8139
858	a4d11d3a18af55316148151ad9880ba435db90417144214ec825dd8eace7aca6	8146
859	0430ee7eaf07a05062e8928eb6bde5cd89b4ee398dc010ab3339b77e160c73fa	8175
860	482e3c9c6f8df90a618c1b1bd2c8bfd18e1c50588dc55d5b0a95aa80e7094565	8181
861	c973d0bc6b85958bb7be24db3373cea03bc87ab9765ff613028eccfc0d9f6f62	8183
862	85bf10b5d721c6a69b81af50197b50e2e696ce06c3ddf275cbf024ad128c016b	8185
863	49f874afdda9b16a0491237f4b1e30d728dc126a28529946382a424958d778df	8190
864	f602eb8fc3778f4def29e4048eaba510d77aff6938d9ddd05c189910e8a6062f	8196
865	c533927c6dfecc7ba60e40dbbffc96ffb95f3c7879e1844a8dcf4a5ff7225871	8197
866	f07a5330fc9149617c0871c8b3a0357b8675955d2a2851820da9f23bbd1eddeb	8204
867	20071158e246abc4d81df821421c86500ab335606494109a965fa7b0f570d1aa	8226
868	dcc31cd82c9418054ed21102b38ae872172b34c986be49909df39193c4da5e4f	8232
869	d4ea65eb55eb7defc69ed0cd4cc383d74129c03de36ed31534481df3084efc3e	8255
870	bd9c41bc93ebc6a3149f5ce0e55b7c09dfe51097c61b49975026b3c4cc9eef13	8268
871	a6f54331e5163e125b28550c7b57563fbc1860a70bb6af0e6558f33c8070575f	8269
872	dcade280197292c750f3adacf2693e3bbe9d0fc59fa606024df54dd8069cdbfa	8284
873	610f94adffd9ac8d76928f979e83934da952146feb5c188637b12dae6071821f	8285
874	827991a5158b76e9310382b604ff3111c4b61c047270fd44c44ed0af1abd293e	8294
875	54b7d6d867dd058947687a6e71a962843ef9112cb1d5503da799245a43822928	8303
876	aac5e7683d16cd9f299db468133e90003b82709232800a5538ed6b7eb6efe754	8304
877	2e225d422b54f62a3e2a4ab20fe76d5dedc161266c39d9c7bfb9187f29d594ea	8321
878	e83dd56735807f676666ef918cbd8edf8ba4eb79dbba056ff4e50a250fc85624	8322
879	4b12b76ae38567f203bec853b430e1782c083f76c9c9ccdc7efe8b483ec4bc92	8332
880	70a17b8d87253e0e5f973b859c8319dd282b48ef7358ae0024660fee048d00fd	8345
881	2dc84bc9b6828c74621a1d458242f1300fd1fdce746ea4d4e53a803b4dc133b9	8346
882	3035d11c44a11eb4790c68793795aa493f220343d2e6c18e117ccf11c682941f	8359
883	5ba07a5739fb54d73530c315bb7db4e75ad475716a99e887a2a0187985419f08	8361
884	aa53690e8dcbc1ec3ad5f58cfda0779688cf53c1310d70a8fd4aeb2f2a6c35fb	8369
885	af0402ef0b6188165634d184fc882e6c166d860bece2edbbbb4956970720b59a	8370
886	764dcf23a354047ee8c0152b1ec8f249d5f49ad6b4ed03fefbd93992bfbcb203	8371
887	3b64444cb99d0dc680314c20a4b631960a69177b70787570849322ce8115d6b2	8372
888	568deb859c692393a437e672db12f61151a86681a05f5464e012c9778e0de451	8383
889	b1fb29ffe3627fe47f53f20d4021d1a51c40af9f56f5417068db65a690810c70	8388
890	21dfd0e83fda2a3fd72ea498730e52195479718ebff31750f439d57b1bab1af4	8395
891	f9c3022152e40a2507b71e1f2556cd2b84d694349919cfeacc4dcfef9ccc9e42	8397
892	8a676948063b69d4cfd01483f3d0409cb1951affac53c863f4c199de0067ed87	8410
893	5e7fe42acd9b52ae87fb87f66af0186dd3fa2990b236ffde9daa805337e13376	8415
894	ac44cbe1d02eac1889d2180fa619e71cc9f7f70aeffbe423e49b1ee2e250af3b	8430
895	03c1df3f3a2609444869b15089e84c6b3ad9ee6ab4b43c0cb67aba712758dab1	8471
896	6da02d9d708a2b9ee20c2ccca3834057dfbe5e9636aadd8cb830bdd0aa344f97	8474
897	c2c439e5953583de58c72a55826943ff70536e22b74790b89a053f1f52811521	8489
898	d86cd6b96925d92bd0f3cc853cce2b2c0ee25a6cd3913d090d81ae2a123a7dfd	8490
899	ebe3a1e9da7304b4b38c16eeab237a98600c1decd3065e5407fb4a832b1ed232	8510
900	5029732c359740ff3f4ae2f6d57c77286d40e19f9f8f1e0185b5ffd28948192f	8513
901	4a86d4bb93d8bc502e979cf23ec03b7a31c634e959f46edd4a846f6f0b48d2d5	8516
902	08caa8b80e2dc7de53de2ece3ed3ee4e476b95e4b351a909b5e9e27c240d6fd3	8517
903	5c81a4abe9b5bb2070b422e4daa62dd96a0d888a1cad5efdb49dcbe571beb3e5	8531
904	d90b4716a47e38d7dc580a78c01d2c4a77d0a34ba1c665a7c35ec9c092a54811	8541
905	582f93990820cb00de225fbf359dd10ee7f08673edb3d4f99376b754f87f581f	8550
906	6dfdd87bcd9988de343ab6ecd3460b5f99aee0eb79e768cf0741ae503a64f512	8557
907	f57ad7b575caf4ac85dda9003f0030588949f20daf210956521ab9b1c9b9b89c	8574
908	d5510f671b16b271a062e996adcd6cc8ef821cd81f305aacc9b97574c13009f6	8575
909	14094b5ec3a11bd628c89c4e7b9d5aa4478f87dad4d3a694148ca4a7e663aa06	8576
910	5cb942d5a598f7484d3565a45c1d0edd01c1a0113e4ba0f6a83ac274eaa580bf	8592
911	b6678bf9939015f25ecaa6a3bb2ed252c621a464fb2a554a8fa1835c58ada6c0	8595
912	662ab5857170f61b0edbd5209205293a92bdba194c0d60bf1ef10d88ac76045f	8596
913	a1474cc7791c6f42abd64927cf7106ba617cb62ecd6cd320c69da78d0769cb66	8607
914	ffb5364f68ffd43d4c955c0ae9182d53297e94db5b013842569f2030df2a98fb	8610
915	024cef8e3da66e83416804e3b0f0577f7876d11ab3e7d932bf608c112162c482	8614
916	4d763244d55bb361b6af96974e87b67d21399480786a5e8cb9d7eb35b4b4e2ec	8622
917	fb75fa06b1027a32caf50624322979adfda2238c412e00502cefc966f1cdc225	8636
918	4d9e1e6fdd012010798d18ac9936e6a042e7f0337b36b5e6a4526cd9a521781d	8641
919	4509d3a6da1e5724064cdf723ca0762259fbe372177d97ab22593387b6ad1327	8669
920	f267eb33ab59c167cba77d18100789f2fb71339c642615d550cfe568ac23414a	8679
921	e3263b2c8e808e27826198c6587bf4283bbf4246996e5f71e86709d77047b19b	8706
922	f2eb4fce00cdbc65ae9db8c1b89477fb434eef1ff1025caffe68c80c03570b3f	8718
923	15484c303e289dc3ef7b7eb493b170f0d36d47384c7678649cf04b44206b2a44	8722
924	6941179dfc0a908b55f1bb486afef6c663a1fd7726ddfec57bb90a8675077763	8731
925	01e75a673aa082be8cbf3fd90eeb9c72096e96342fc9d1808cb8019a67ae728c	8733
926	6fd0509ee25cff56b929670f8ddadac35198f9a527796d208d85ce45e1490f5d	8735
927	86f7c48ee1e1b110e0ee7efceec8f45c0007de96a61527b10a876ab33cd23742	8744
928	66dab6c02eee8e3bd5209cfe97fdb207d20083b848fa3b0530502692d67f206d	8752
929	813062b4a4ea9e13cee71c93552388bfa943f3766748eaf6a878c4459b10ce89	8756
930	63136d21e3eb49a3af9cd8eb73bf0bbff72b16e1c0bba26bffa087fb63a6b528	8760
931	24d705ab092d1d230e0be6cdf83fe63f5f8377425a819c1e34f19153ac1db559	8772
932	077f0643b91e1f3f04838bee2f84c1e7ec7b030eb9f25e363a57d47ae723b35a	8773
933	cfb2b7e3cb7aa89957dc995c704c5b1f8901f63acecfaf20f4911257fcc5b46c	8780
934	453122648bd7ed20a516acc981a10a553405f46920abf95814b74dc34fb7c536	8799
935	edcf7233ab1c0ef50bf0cdc3036db0ff9bb312902cf89097c500de895d6740ae	8803
936	77ba9b78dbd1fa2553ee3f170003a8cc406196292eb4809910e4aeab8356bf6f	8809
937	4cc24bc8418c4585fa13c7f701b418158978c824b3c1768340067c7979d21d07	8812
938	a5e64251dcaa2e8b323b1e2be3c42b7e9ce7be88a3a922be854ccfbcd50083ab	8818
939	9bcac0fea98bc7e944f52bebe0acaf0f3b721ecad99201ebcf0c79ab1c563f3a	8821
940	ce26effd72f3212d5894af2592b004a3e99a6357cc4ac3e00900d0b3f8b721af	8826
941	a2d17f58619dbe73c3b79f951a4c6a24a7162529c1ffa92e75d020849b931d7a	8836
942	353c83d4cbaf2e6f42cdc0da38968730f0d99a163ebb3fa55d626a8b2e9d431d	8844
943	c840aa850321a3ff0cc042861044fb57503c5e34a9bea4f0a7602558c9d67f23	8851
944	669bc4842a5b806b70a3ae02bbc88c97e70eab6d38f2744a4db4c716e3a2d73f	8864
945	39e4c309ccf636d5993fddbfca446d18bb5d15bf8144924c19acd0542c11c63b	8876
946	d1bbf6c588eb952457cebffccf290f55224b8992263fb34798432fe05c4719c3	8894
947	70124aa08e76b69d24530c56db44af0e9759a25b72bc3ff983c5b9d35fc491a2	8904
948	2a65de6da70bec42949f10749fdcbc79f3a7be14af6ec7b3a2451fa6fbe2b197	8918
949	acb758f05776f4e81b2cf20c8e6edcba96d8ede3078069fda4136859d752e29b	8922
950	f551980a0ff40144936d650c8fc6ad0b9d42d53fc000b571526bdedfeaa0e523	8942
951	882a198140c0c94b41868cca5e2a61402fa8560030c48b214f40966ab1634674	8943
952	8302bc5b64a04803c08fcfc8e22c2ec460c21b94b38a254e4a3e9ec28d4e0e2b	8959
953	d76f12e2f19312c403e9691a1b20449f0fdded53e0937be78221f18c131fb105	8964
954	368576313d7b3e3042a1b21a3c0f00bb5d74b0a6f2305472fa7062994c8fd071	8975
955	c1e372e2a327973ff410813fde388d9ca622e3096eba913beac4967841a5e104	8976
956	7de12e5ef273184d815c76d5920a8bad875235833a9dbdbb0e03954d23054bde	9016
957	3f9571ed3036845955893fe81c479e2c6991eb13637b4e3813b4e1f3cbdcef0b	9018
958	2988162adda7a7344a261ec10eae90b948fbecde4bdf55126414baecbb3b970d	9020
959	4072ccf4ee61fad41f0f98af7e80d0a7b98f326a99f4639b5dc55cd354d14153	9021
960	6a30a82632c47bdaea40c7ecc90c45e5c451abcc571d9b06e72e233696b41d2c	9044
961	c347e3b3ac085f6aa6d565fcf29154ad7425339977f9212b8a9cf19f0e8e3fb2	9048
962	c0c6c2701358b095d6f856c0f97096f0716162574b13c14b5ebda5d2589ffeb7	9066
963	3c5fbaab3ff3c8afab74b84604c334477032b30ad8bf291f9335c42c795150e8	9080
964	cff32fc5d62505ee904951f2c86b1c5a30657385b349ad91d0b25fae181c55f6	9083
965	fa589abbcaf49cbe80b082240a9ad59019892e0b7185375cebea11b4c016e14c	9085
966	66414a2a3ec3df05034eba6f3603b476d4ff8f354faef47554bcb441ceab8694	9095
967	43157d18fcf51c5ea6eea70f166702646e5074988acb6573434eba1351382ae0	9132
968	b93678ac6d0695193735767ee12384a0f3195bd31c9059c8491ed125464a9ba6	9133
969	357f41a692c9c6e2bba6865b6552f44ef9aeb55e16568045a151a91f9f05b5f8	9139
970	a4a4eb53963a33b7eedb2c874404e777a1439a69af99010c9034455ef05f361a	9149
971	a336d10322c0b687ab37faca255fe16ec7a832bc1b8cac1aabb55b1c78f8aa99	9151
972	6e3c474ff27e4547bb7a5829c4cb7f70d820b9a2b336b7f285b97e967417925a	9153
973	e3c9dec8b31af7dedb3c3d0f9e7d9c8c07e9cad91fa309e41928026a3516a699	9156
974	6fbc5acd87ce9b76f1f8c8816b5bdb4ffcc9fe9fa0b6197f7c17147a22c8fb05	9182
975	b2ccb0a87f431217835c61c1bc755d8a8e5bebdb3a65bd88f7b2312314918e8a	9188
976	a35090718c3291efe840364af9ec99e06328a68b52d0cd7ac04d8d64a81bb2bb	9191
977	ae6efa7ca6e77d4afe2b7868fa69ee94e810b8b26cb599c4d0bae21f4c05888c	9215
978	fbf99cb3181f0b39a38d29de5e0aca53d64cf053a166fde4f5706fc2f173e8db	9219
979	517210f3f9185d03a168f34af61250fce7feb2d204d702dbd06f3d045893aa59	9233
980	767d5fe8d7c3c3c167fad313ebf2da40d791bade885709de43b80a14886aa74b	9266
981	7aea8c40b483d350f27ec7ffa5bb91374afd5abb8a7200558ce2850532897968	9273
982	b577938f49dcc46fd122694039395489018d43a3d62a8b1f842356b2669f8b63	9279
983	62c29f7119169d05070f5372167039e8d0d743d9c545f38d6d3bd8ddee829824	9301
984	fde42b5602445de1571da355c575e76c9b1f3d99e35a253e4ec4500b1a9c6119	9309
985	478b2005a38ca9c9d37d8b8b95954a574bb9ad57bbcb721435f9dcc806bd40a6	9310
986	f381db7306a8ff58c68379cd981ce155eb991f792977694e1b57146584665de2	9311
987	8d623ed6db489ecfd484528090edd8008739f55a26d3b5c61d945cb30239c34e	9319
988	a400e0b4feff98da0fbefed2e9616a4897385e3c01d5009e1615d4eb5ba0661e	9329
989	ed8e48767c4a27c0a09b09ade1c1a2819d37e247cf1a81c45810d058aa20cdb7	9342
990	9562c1df39a9bfaed8b4f5c38120396a77602b30d74f4f3d43135850d1d35b59	9346
991	ff8411f5076b655b2abd724e8509704bf0c789c43cbae4843cd107fc148c5fee	9353
992	b9faf4c4167725d3bd2becb75ccc6abbe7ec7c2b2c776dc87d92b240488102ac	9365
993	b67522b341f5db96c0139eac1636ec932d6c0a5f4b1a5042314358d36bd68f41	9366
994	146164dba2d345dd519f62f21e688f0609d4e53fee3daaedda3fe6563ecae772	9373
995	ae7e50dc66dedf05e7bdf1b6669dc72dcbfed1c9654a2f613d5360646403d11a	9376
996	37f917293e022df24d83df2ab750aa48b474a15e7a48b5d47983eafcdf87e759	9377
997	b012b6575b182b1b86ee44ad5db68579eb8e0518c5604efa180aa39d0d501b56	9399
998	affeafa7099d51d4403b84258dc5b5d69ce5884964a0c74896a99f72d87e224c	9402
999	4970dba1ce2db8c182223c72077a009fbe067c5e314575001fa806b15b45d313	9405
1000	b0a3ae91c7a8523d1a57f8f0a24664d1fa38e0b4f252edce208ec2eccb5334d9	9419
1001	aa542bd294b64967d59abcf86e19473f7a1d272d0b9a0504b4d0af0459c2704c	9438
1002	e7abf063726221e3934e3ebd2f4627e29f690e1b80894e839b0296bde5512116	9439
1003	7878f7bf3fcf4fd253ec33541083c7dcaf9f05d2ea905d925346fa868644b685	9446
1004	4ca9ac41d2b5cb9100825aa5d5a20b2f309fdb00175539a349ac4ae08c92a2f4	9448
1005	cb041f7b440d9dfb2d63c202f9950afeac58164fd008a1227bffe1cfa90b21dc	9458
1006	62cb6cb57fbba222b292390e707c66f478bea16f71b55bc504c1a3897a3b6b96	9466
1007	97195d144de22032cdbd42f60925784051304c71208a28a28027779a9d2727f7	9470
1008	4cb969ba0e3bc2255d4bad8d445024f1d1b88cfa57c42d11447fda10d2fa668f	9483
1009	63ad1ac293b29be2606eba493f1bb15df43b62d5561a5949e05cbd15a1916997	9489
1010	6162d1e03999e3cd342343d0daea3fe91a9ac5bd224e0fa905b1a1422036e09e	9490
1011	d1f8a6b18021bf93c7c4d876e296f22ed868f524de3fcbac432c1c2ba3204a6e	9508
1012	3de9680d2dcba7fab7cd0e5cfbf892c2285974fa1df0a9b8f7f597c702fe4eab	9509
1013	6b1dae2c823336adcf4a3e34c075e14a15c0f1df7802af87fa6083843cf55089	9510
1014	24e9caf96d6276676e9653b38bbf0603f5710787f0152fae33854198e76cdd32	9517
1015	d468ef417cce92374d80f29b721ecf664993bc3626619cd1a181835dc0941ee9	9523
1016	dee9c4c522c3c76e056bedc1c018e57b9c28e6ecf78933b1bca325a9b642dec9	9527
1017	0abe612a4dcb24857c9b67686f61f6b9588f2cc381389ca28fd841140635fb2f	9531
1018	3cd0e1e7d4dffe4ff630ad236480b3eaf06085a700d2e71facc6e3eb72b85fe3	9535
1019	1c5484c6f988886f9651edd5c8e81ab1844f83ac9feafbec9c2b7d3f49fd3390	9542
1020	6ac33986c298ceca4a3a539720c872b19b8d16b679a9d98023ba41e555a739cb	9544
1021	c78436d8ee90689aa8f3541968d79004cf6eae8c9918cf2bd2634cc9d65a0204	9558
1022	96c9782e3e897123f327e0a26e56a84bc3be08fdc027a691956a9b410b5c955d	9575
1023	25e34cd08a53d876a10241654c8e9c3e4a2e57534351322f27ba8be4f77d2183	9584
1024	9091138d14e16f51ec5b87d8a53391a0a1ff4c9640d6a001b1f34431c0452a8c	9601
1025	b8a45ec1abbc41a80fe6cc43978cce51b64e98c41e2b35c5c372e73256095980	9620
1026	2703b45ed7ec2d8d62b745f548457b00b101c9e8c30cf6c775cbe7eadd11e893	9643
1027	586b2ae91e94594fa8c8d47827bc2706472cf2253a3be9960fe6b9947216e190	9646
1028	d78708e374f28558dce63196d7d78ba10983ca4fac566a6abe42aa772c559dff	9653
1029	68e804f25b4c18f0d6b342092d058ffd7356c5fedc7a640911bf37cc2dd867b7	9678
1030	31598570071d4cf0eb819fc8432b807bf12717100227942c84d9579c674e1699	9688
1031	78b81f0da90e50429ece378f58268529dcce9a164d51ba837eb3b445c9b47246	9691
1032	86548cc7bb1161db698f702d30002b561f0b327ba2058bbccc604cb3e890502f	9692
1033	728dce424a38a37e1d8678cfdf4fec772a518f819a3e33cecb6638f9c8b95562	9710
1034	ac7664aaab74d2759beee0bc9a01f1cb9e18fca63fd4243978ec8a354556a143	9712
1035	6a3434827580f9a71cf56f7a7c7d1f57973624a3ba057c474f80cfd1df995e10	9713
1036	0360b0417d42a158e1198d34497a53b96d72c565bbb2f31408eb3b0e5964b17d	9720
1037	40f885fadb6ca74b7bcc04eaf5fe0cf061c5fdd79a20ff22a34391e94d69d8b6	9740
1038	e1363775a0f14387d775de9276b98fb046ac0740147a46b15981ba3cfbf3a0e8	9741
1039	b2e260fc9afadf3ad52ff3e6305b7d5439f834be7ca67a9f88aa1f94485b746c	9744
1040	e78b32a996eb867eca2e11d11c2c568cf68f4dcdb2023bca77a74e09ea1beac5	9754
1041	a4e5f42c24ac77474bfcf8681e49c82cf8b88d4327daaf48c99109c6c45747a6	9755
1042	1bb3a90c9d366e4304713b74b1b585fdabb2d45f6f8e9f971b3a4e361c0e9e41	9793
1043	1e46097a813936be1ae3a4e2b4bd75f1e4d28f303aef80dc5947e5c1ab4b83fa	9802
1044	a0884f0a81b1f64ffbc9f121bf199a69e6a73ea03661ee05868d0ccd00a6806a	9803
1045	c6c8842bf8a161d5d32e7acd99426bcab161855e4b568c7cfe5d7c57c6156af4	9813
1046	b0e4af6d2c53f1449438982cf24584f932d701552fdbf92d733a9fcfbd928f16	9815
1047	1095fc5e49c1b5ce4993b4a3e4931a9ebd3c3c9cd7b880148abfb1d0b3b13b5f	9816
1048	dde376cf47ba00b9e5acd707ec9953603c21a05c71b0313cab0e375abb6972f2	9828
1049	843fda1b821724915885e461b91ce03546ae21f9c0c1a64b1e974c11c6f44548	9836
1050	645a959770ae779c7853bcbcb1e7f2ddab478120c7b13ce7f61c39421cbb5084	9838
1051	9ec810c180d39fe02310b2393f287707336c9b4eb2b7b389da68a42b9dfa5d8c	9840
1052	1d321fa335d71457aa5764bd9c25b3d4170c53ad87c9e390b18c2c3e9f238589	9845
1053	f8678396ac1fa96d6fd5c2942cd161e1ebe95b3d9fface3f1e035b166e69d095	9848
1054	c6b771b8045436e79be49e8aad7a44cb6dcc55348b8bd5b373f9d53efd9e019b	9849
1055	f662af5aeb0e0992e125a0239764bc3c851c962617014bab624b40287f1d6474	9861
1056	96d6ae633167fc31056c0a0034aadb26f49e6f7b0da3448eec87e43f4b38cfaa	9876
1057	32d8002a924fe6dd85bce9a3a27af575932d83ed7d90c41a14643fa3006c1fd5	9878
1058	5e9495028708d9b41657743f7f30503c0ecb49e59f610fcac25a2ac5a95ee59b	9881
1059	a66269c53b646254f0ecfaf071e23ed1458fefec1858b11c1778877e527abdc4	9883
1060	852ff68b10f9d78ee67e3321cc26cf5c5f438b99773ba0e97d893d95aef62cca	9923
1061	42b6f97bd378cc1b0d5f15ffbe35e34d0679360f5365b3ca47b12f55595e88d4	9949
1062	da623f0af182d978f729c8f2298abfcd9be66eeac4ec398df252ecbf2e823ef7	9950
1063	1cf0c1ca9d1e67b187db469341dfac6ddc7cb5b17c679047187a43d698788b30	9955
1064	568082310d047597b59ba061de7c30a52738e006ee4a85bbc915bc918642051c	9958
1065	12ab2f57ee093b38c796c0a8d343c8a57ba0ec2c0f03ace0749a396a20c5fa83	9961
1066	dab166d006d082d291020ccab13a25d1e36a44fb46a50fece83b1f3a0b3fd458	9965
1067	87799c9a41aa934da2509c248f6cb5cb3127ccde59b29e0386263831327a061c	9973
1068	4f604f8def3a5c55bc7f04420984df6177b182f0bbae0b2273cc78090a5c3e8c	9977
1069	b0da35f46ae92cc7ab1f82635a34b7bcdb9ac148189e6697f5d331f3c860e41a	9979
1070	79769d6c1122b395ca6b27e6dbdb55a58afba58d3033db9d7e7f3a9b0aee8c9c	9994
1071	14207641f12440165b8c564637654eb2419ead93fe0ad031a79911b942d420c2	9995
1072	e073c2b834954c1d7825fb7ba66041924fdf5c90bc030aef6035db5e143bd0ff	10003
1073	1cc63135761f58a3bde04d82d92f2ca32dc0b4bb001d3aabecfd31fff69fa8a2	10022
1074	f153e75de7f395e83304d5243f0c6738da302039137c289b1ca3d13c502aa1be	10026
1075	bf9cf10bd32a7e47e879152f5280dce4a508febed0c80d69bac3fb278de06626	10036
1076	27d104376cde522a6277c072b943a55f4433111fe80fe6a6c67c36e20d186a07	10042
1077	40a14ed419ab10a06863921bc7569a2d27a7130ffbbdbee9ca891581122d96cb	10068
1078	5cdca768472c45b6b7230414c4ee339b6276480d39716c7f3162bb221bdbd78e	10071
1079	be677777a1ffb49332c71f0af823864e711ae9a95cab3f2ccc6714e0ccba1574	10082
1080	b9182521f6a7e30ccb223c50c47730eed7f8be3065aabe35cd807df91621eafb	10084
1081	d3506bf89eff6e04e0f16afb13a8869e2b6a6425e8530527fa08c6608c758f1f	10101
1082	a70cbea2c598a59ee208ef4df9e1ddca12644b66d12a431a3aedc1ed20a12330	10105
1083	61c98f109df554b788dfdcc6ebf2e91f7de4096d2f294c457a1f883437042f3d	10120
1084	93834f3f92291d962d9d555fb5907c682dfd620958b063f23b02654f349f7a6a	10126
1085	a7b3387b705b557b0329130abb670b6f5f483a7b23234d0159659d7f23757a9b	10144
1086	3caab229175885284cc330dee5dc27f1bd7f4c6cf86ec2cbcf0ebe8e1a1c37c0	10151
1087	43af4c67a497f627056965cb75615acbdee68a25a3d20e1533ee5da4ac978e96	10159
1088	500dfb464f9272f1202bb413face5ff7552d2ac98415eda70652421d32942a46	10165
1089	2b104fee239f01c3705e4d9f4e7d025e75b98233f76268ec0ae5ea83a0a8fa80	10192
1090	4b8b3d209b66dade1e729cdb305569631e26ac95e4579757a94b20c06e0626f2	10204
1091	2e5bfe65aeefeae62535c1334e5b1596045678610d67ce83c60b97c1c8144fb1	10208
1092	9122b83cccb9ee2284b9d17b51c855a44eae2a61cde24434d6030ffea28ff939	10210
1093	2ab10a288a96520aa0bda36210aadbb67c69f5607d9062eae7e0778864b3dee9	10213
1094	7d4c3106603ca5d5447a9273ac5d684fc1427ce78ea2c1c03ddeb4de3aaed1fa	10214
1095	2a9b925e0a326fd807f8eda112cdebd8bdb733f0eddc1d27e6a7cad4a1719e2d	10237
1096	bf5b883cb660b4d19fe40e25e28384cede868625fe377f374519c25e83181fb5	10238
1097	921d7b94ab4a38aa2926d63fec646d4338740358b7b6997d6114e701e3a93ae6	10239
1098	605a055d95489b9dc4555a366b654916ebdfe4ad2679ec26273ac9e6abc9a745	10252
1099	a24e65ee9c42115677cdbec22f0b6825e9fca4f1d2eeb94665f70478fa9c0220	10275
1100	24579f11f6cef6cf21c33d1fac18565f8829d16354f5d22ffa1dab6a01936647	10322
1101	e3c1a193c1337e521e2a63e774c86c6c531383b3381888a8869b1f062a20c062	10344
1102	7a27dbe69e7ef4de1cefeeac663485f0c60b3ea0f919f7fb8dbd16a4d6f56d0a	10389
1103	95380d7f2cee32fea88af208aed8d961f38230958623f3a9babcb5564d6dfa40	10398
1104	319bc98aad042c5aa38fdaed3909d6e27f0986dd81040324163b149ea142032e	10406
1105	4a58840532635b4c504ec3696d1ee3b4c0f5bb927e3668d3fd555472cb23b4c0	10414
1106	d64a58854f3cd191c6cffaa11461a69a601d6d4b064989a6ef6e4841eeadf4f8	10422
1107	1972adafc67566bcdeefbab70aea31ab19e0180c20c87ab1c2bcad780f1bf313	10424
1108	eeb312eb0dd2817889033f21c3b4e88ab04f24397a9968e91c98e4250f85b971	10455
1109	4c3d42af0d0c0613005ca66adb29f39f0085fac1c74b92148fbe3e8298a1ed60	10469
1110	e4318f718a78a4fb9d34cd2ce18ef57dd358d21c1941c4d0566b8d2307c2e1c4	10476
1111	0eeed89fba6bd5b3ecdcc4c4222b6beac34e127ff7424240ce8d0c69e63ef7e9	10479
1112	eff6b097836008a6cd7d9d92f6206321ac450bf6f2fe4b5da8cc95aaa4c43fbf	10480
1113	688b5e79bb57be137b2b45ec9bf9fd0bfd323071e6c3e7417b0510c0fba8d993	10485
1114	f0f3e9ad9f3a7bbf82283c702535efd2bd0f7d03d0aabc69b27cb3caf9c2dd91	10503
1115	7a26a0782c8b1d2794c5d3e1311f48bf0a6b80be465ba4b630b9253ad6c749d0	10505
1116	b11356575d735d5ac75744d67b6d3daac73b6b1493deed58300ab9c02252b075	10517
1117	20ac9fb10e0347f194ec4b1b05851afcafff06f855713e014b3ccd87881661a8	10525
1118	db9ea8ea79816ac65b5f45e1497d53bada01c518d5298d663f9e5f5b493e3cc0	10540
1119	f9e6f06c3bff8999e1cf3e52396608841fb346095f3f5565269431a58749d7c9	10543
1120	e5d1c1b9fa4fc94e0c0728e37f022539dc38af4eb7100507c93ed45e55604c76	10560
1121	8d8b496439394a6ccf3f927aaa1c9fb01bc13b62b2f6c682b295e3bfe856957c	10573
1122	a9158932ec1074af8e335adeaacb650b637361bc6c9e6086f73e1f0f6686a8f5	10575
1123	b9979065c4c700dbb5206586151e2406962add36538294cc491c3361607d5dcb	10587
1124	fb9dfd678c8013ff9ae65ece04cbc992abfb96d363ebc499fdd622a428ba7f30	10601
1125	61b5d0f6b585ff8450d4fce94822091bf6b84199ce13557b6a584ac79b934d15	10607
1126	c367bba57f5de14970b08b9a51f6c1f4dfbb2f452e3fcc216637916c39dd0570	10653
1127	8d5b02d4d49921a015af2eb09da16cb054e657c7e98ee8d5c993d5611ce87a4d	10657
1128	2f039278b4eaf112b74466c62cf73918316547c3ce96b7ca2b260c026e297432	10681
1129	57e64a2ebb6be1d7c66aaeacefc0c78051fd1fffcda4d62d24f4f88669574ddd	10703
1130	1bce8cdca5b1c33823b4036a40046760b46a84c0ead40422fae749610f634f9c	10730
1131	4047fa107c2a164c75c24373e4b0fc0d70cb3d5ad969e8e005217068498b5330	10731
1132	98110eb36c5f956e476d8e5c6e88946dab47c43d439787462c58a3c4efa3b81f	10737
1133	dc2680b11386013f985253bfd5d891f5b6d4986ec05ec8facef78aa673ccaba6	10749
1134	7693d7c0e65d98534cd55394195286151067c8452b7823b42361b0956211a958	10757
1135	86383caabbc9e288315dbcc328401e845ac585ac1d9ba4be61d5ee75c2940494	10765
1136	d79bdf13150ad8b4c27f5c08ac9e55791e9cbb5f24ba9df6b91bfe0d08c7bb99	10767
1137	657b53acc37b0faa30c71480b36df3d728ddb6783644337a9beb77a5e69a4a72	10785
1138	ed385ad61e74f08bd2e36a19a4dcdefd458a90c9edb9a50560fc97157ccfdafd	10789
1139	f0b7e6fbb26837ad25a18afb7e09e41223a8d71b5ba0d1b6ea80bdb9beb79142	10817
1140	4afe0bc0672de3ceb0d591bd8912efa5444b5d55c622a326d03280c31276a9ff	10820
1141	5626f01d95bd9ff885c5d4786ed03d331c446c219678bd86940d066153c68bc4	10821
1142	1ea257b5654521f63d29441e267b0a0b742ddc6dc7af203c85506346d1b6abbc	10836
1143	21138a892715783b73e229ffd7071280b392c94729b16cface7185d1d1eaac63	10848
1144	76d33e034fb0c7065a6aeedb482f5bdf71f572a3cbd22765b6ba212d1536e963	10864
1145	b0d54c401056c337302926f3d8497fafc53ce10bf2ae37e6a8b364a983a4d27d	10898
1146	14f845b5f0b5758bc7c5abfbaa89d3a9ec18fabb494831e2327c3c8e05aae6c5	10905
1147	41b4b497867d1086c315f13035d0cdc52000140589a9ca09d13b88bdfd9748b6	10926
1148	a482c2cee605f25c7b9d6afaed3dcd0b2aa044b20994a8bddd8fd2e1a680c301	10929
1149	e74848b8fadcdc736a9ec300f5783b74e6afc36e0ff8c8341011fb04db295a8c	10933
1150	db307a1949c99ec2f699125548a628eaf93e6f3f1ca1a0d5b8ef74229675d4e8	10944
1151	302b896dbd2f52f0b99a4fb11ad3b536091c2728174e3da1d6029221c288ccf7	10945
1152	a8a06b74a3824ac52a9b44debc80cd0501ffd829258975c471c1a0c4d58efae4	10950
1153	1c331d75608f80ed4d54aedad36546bb291e24e3ff4e969a465091281d8f3412	10962
1154	19e7277e16c2fbe4680f389d602ef70c36c1976ae4be9b500de1a7cf00771490	10964
1155	38a2e850eb5fdf58e9400f7df85b8330a1c3ea1120d85ecd1aa0704a6b054121	10973
1156	13faffa3138f451c54dc7382c5f8e0cfe9c7103797cc679b46b98aed3fa47494	10981
1157	eff4963eb7c7636712f380e79ad1c4604e830df8a989b7e0143741640486d7cf	10998
1158	2d5fd06e1a90cc8a3a428062fcf34ef2018607e1efc285352b9826454ff5c094	11011
1159	d1e7d728221847adf3ec082d2ac32aaee3b64cf44ef2388051a850b67f2c7445	11013
1160	f07c0ebd10009e4abbaa9361a9d53678c36e0c3872d5dec2e2c2085b5d878f07	11015
1161	a71506f848f2b437d93476ec6051d9de096e630b8b9111db8acf681b55b1933b	11019
1162	87669a80d6bb82db056422b93a44e9969e962cc973c06e7c7c257b777221fb74	11022
1163	31564ed57a49c4146b93da856b6e88cd7c54a8c79113e367c58d30f937a9fba4	11033
1164	eb730c0f7ada03a9ecdf3e1eebb1e63ea7e7e9efd4180a5009e4fcc5cd7c0477	11038
1165	134f7d635eecfabe703b7297e2aafe9b78bc3e60d977999349a6bf22eae5fa5d	11040
1166	fd503f28b96210c702b486350f1409964321e70beca3dde6fd8ffc77632a4cee	11048
1167	195463bc4546c9c7185701c8a059b3fb273c8fb7e54b2fd944f0ff425a78be3b	11052
1168	69460c423714cc5ee0a5790d200803f3f2e222b7a35c3d7a623575c691f3710a	11074
1169	a59e3693ab3a6334fe94d961c4a968bb6b642d810af7e68e8b68773f5e64f5e7	11075
1170	c1263fb6625607eabdc454d37981c77f049f282ad728ed4e2f1ae10c438efec2	11076
1171	612e4f2a853d94124e07482b0803fc89635d1bf6391524432516c3e1109997e6	11088
1172	c311d575deb0242ce58c6283caf61c9776cd2aabb83bc933c834e0961a0f4f1a	11110
1173	38319bbfad4e1b51e1cc1cd934a6391b210adf60d6ea66210c87ad2a01b35361	11164
1174	e0930e123af1fee8f2458930322e610529d28eb9e55d27da9e0b2fa1cf610c11	11165
1175	e570da2708184114b1e4764f7db32955c2693043a0a009234f4e74fc04b6f8de	11166
1176	e2806dd2196452c2d80b14df7b3b81c2cf163b63dd47c289b15427a06c385c66	11168
1177	dee1279ef7bdfa394a143591f2aa994ae9180e1b56e54b3784eb772e1ec173e0	11173
1178	bbad5c3c85a57eb42c54b6842dd5af09715abe483b823a5c53ef2d23c43f3e23	11182
1179	317e8390e44ac1b4964367322993bfbeae9029b7d8302c9543b0808c0c124bf0	11196
1180	0b32e6d6258942bf02a294ca38372f357e64413f3d01109cb12cd81c2e32ba0d	11198
1181	47f84ed8abdd1bcb020af9d8ea0b7f9450cd9eb632b60fff1c1511064dc7817c	11233
1182	fcc1dc8aff930a28f63185bf6f40b770f46f64fbfef650c40c6717ddacd14176	11263
1183	8968f7522f27d256599f85500d57ab079c18bd22f6ac82753057f3435ba61fe1	11274
1184	7a6f16804db10cb96fce29a18c7a57664e45398942eb3b223177c39e14f4fc3d	11291
1185	ee140597ab5083ad2fd6ec0aa9d4b2f177ca96c7086d23f937a273229c00db07	11294
1186	63a14dd14673f7211c37289970182e106b58155760dafe8937881bd1a20a76ce	11304
1187	1d43057ed2feeeae62b180f035cce4c804f8c16d8851d0ca722e2a10722f9fbd	11305
1188	910b9cab6440cf30e9f64ff65aaf38501f7784d94eb99e8e0a55339f670c617c	11323
1189	08eb6cc860172360639597e9dc5225bf5f5d0e869d2995d5756066b55bc52aff	11325
1190	a25d5f9b2045272b398f3938e0459a05a65d4d6ae83cdd3d75eeb16efc1c28b1	11340
1191	df890ab2e8f66e1f273ab8870919d693bd5de04bc4db53e5ee947790164e1d02	11344
1192	2a23f0d14ad2a6b5248571820d554f49d490c4390e9d06fb6c547e52c058d439	11358
1193	5ab987626077c6ebfa53fc9c19426cf916d59162a4529e891ee78e7c94a99727	11365
1194	c42575f44e0013bd37489fd270eb3c9dabf440a475954b867546ffeea9f58330	11366
1195	3c6325ece211441c7066f699b78d3da06c15924447ba9e9aca84b7b6503eb667	11369
1196	94f9fb1df292609c24c0882b08a9402bdb69f1fb4349b4e03214378e177daa70	11394
1197	f19f8fa2634cd3f19d2e54ed9af8301a3e2dd0346d89c03ff494503134058ea9	11403
1198	9d5364a369a1d4e7a97e48102f9fb5681e6da54e5322db577ce701b4c5da501d	11406
1199	96950f9a782615e6b4c5493a8448a29dc1e25e9e50efd6b1103ed9117b8d78a0	11408
1200	656dbd6e7a1c4befb5b61d6ded0dd9644a92360caef9aa06daa476378c2f9769	11421
1201	e537a075bd9a7c4a986cd3b647271c123dc2da08f44d3197f27a1d0f69bbd7d7	11423
1202	90eaaca446934a09daefaf89ed0d78cf401fd78f9e5a5a878fa94564db63f545	11433
1203	c31c52f66d812861d26a11f7e3cfee68fcad140f0c89e3edba517eb99016e92a	11476
1204	66ba113ec0cf848c6c43b6df50733bb40fbee31ace4504f4ec76559360f68177	11500
1205	543112d1dc6c86f64cc2dca7a63e8e14fc846aea516de5270484d637a46827c3	11504
1206	3fb36207e3873b894bf04a534f27867eb21a1c95da58aee7331557475fcd5d0b	11509
1207	97aeffe39479fc9366e9f3b24938c151a2c9c716362c5ce3315288168e2a00bb	11524
1208	8640024d3ff6230a0225672946eef1813b1705eae3ffc3ecbce2efac2f585e9c	11537
1209	3eddf6bb6c5a34412d48b0272652eea2f192119ef640b81d26c66cfb00da6f29	11549
1210	00ad1b4d1e24206f07aee41b91f4d4adeef7bae4f9bab5ff8f95d8425339d624	11552
1211	f4f46bb32f758838998418e66d4ac2b5e43a189cca3c97ac973a6ba567b1d069	11553
1212	1f8de6e4b93a4d730686c4525c3f6c498cb6c190f23ee9f8c78cb4b34d1289ff	11561
1213	958ba91ce9e245dc3f1f12c08d8619477eceed7d78161bbe49dace3eb0831220	11563
1214	0da3143d85097a10b3ca1b99f4563568a3087459b0f52796aab6dbd66d07660d	11571
1215	0017f946cf51a1eb255221dc92fe22986f54c9c333292ffe35b184544a3b79cb	11576
1216	c4b8068af57ac76c19e041a1f84862731cd016df6c6c5a538d27d4f6b943df32	11583
1217	02539babb0a37136d21344442aca1abd4a36beb3c8c55706f594bfa6b47ae7ef	11585
1218	31876561e65abb04d1b73fe216da75da8bd38e735c031a736c88a795290862ff	11591
1219	c65f449c423f185a72d29f48171e9022480d35c1c3179ea667d24b45e643a286	11593
1220	21fb775a93410ff15637a74facf32800622a23fda040a987f26c4a60448ae916	11597
1221	67c387e7380d27b26cdee6d5eededa9c810a05da19e88a6ed0ee83159fce051d	11599
1222	5b392bd72b1afc10eca5bdbc8eebc15f9181430adfd12a67bf8a0b38be28cff6	11614
1223	e0a0f82bb2b15531ee226d7f45a563414f91aa561e7c3039c641c6d9224b5bd1	11628
1224	ed1e0f753f5f864346d52bcdd91950696a9681dac51beb627ef68eae67f57ff6	11634
1225	c4e3ddfafa400454c319b93d8cd5b66eb65d35d4d555d20f3779b868d7c09509	11637
1226	a5d36ae76a00f4f0862e231b7ed6b84fa427fa67d9ef00b0b031809e9eb42825	11645
1227	66f45d039aa692c7b51f6d7fa65f7900c8f0a99575e875414289ea90a59e060d	11649
1228	428dbfebb030800dff55dad04b6532838bb067fdadbe3e8a5bdb7b6c81329c46	11651
1229	6426688b141bf087ea890d9efa2198c7b790e482470f17c9aadde6a46db6d5cc	11664
1230	4bcbff3389828b09c8eb5f3f042462e042fe1f5a643aa85ddfc81add27f64442	11666
1231	9306c9e2961119dc492abceb43b0a46c8b42f00e458943eb8207c737030f708e	11672
1232	27ca7cc91d870b6457f7e1f624f58e9cdf965d954c46e8af33be878ff4bf17c1	11673
1233	6cf3399a6bdaefa911af2c70b7183bb7f3806024a4a90d129753786e5e67857a	11682
1234	b7335714fce8b3a94096e58b048c5ac358edce72b23cf072ce944ea808152536	11692
1235	e72012fae1e840207099ab6c2ecc310457c382cb153d01a84a970c52c3bd1d76	11701
1236	a9deae29c105d3e11375e4b1290afa8229e10e59d341036e5bab36eae74b4d79	11707
1237	37e3df02b1a49eb4bc67d5dfe0e7459e46858c69f8ea27a563ecedf543064473	11710
1238	576c3149c3644a5999cd733ae609a40778d3d2dce28d0722e02288c44efe319f	11713
1239	08165aee026de44da967ae860111cac1f9877a218e8d70c97dda179d1250cf9d	11717
1240	154be2a4afd5cb9a0ca62e88c45345fc9ad95903a02f9e68052dc72804b1488f	11720
1241	ecee8a7625e767fc437af7f66f793e3c798105bcec89e4f5b6182df947aaa5bb	11727
1242	9782f73b8b9e621568b4d17b597a9128d21753dfa4c191086b90e8787144037e	11734
1243	3bc72c4d2c7e0cb044c7caf7fff7bdf08b9e28ee4b25b154e0bc153f5571454a	11743
1244	44bb107c70f1ce06f344660395773052f77291741640776276223bf2345bbc8c	11754
1245	0e25c3c2ee887f97c535acab95da397c3bc69610598dd26cd6c8a368060e517e	11756
1246	bae55c62d83d4011a2ed14f6487a78ba720fb37f1208f393ae9a26c619363ba6	11778
1247	6abdeac769d975c730557602ec79cbb03da93db777a0a7d466d8c49059aa12a1	11787
1248	a4bbf0b25b86016906987e791dc5554aedda0322ba2c849fcd694863e7edcef6	11807
1249	0c93f9e95903c026f88cc34707b924f12c225bd5acbe9333af71476b26714b21	11813
1250	9e63570d96132b8a3117f2c67c78f2067d06a9aaa9cebcc97b74948795e56099	11815
1251	669687a79a4a678618dc8840cd97b4094ff50a909bdaaa5dcba21cfa73e98819	11817
1252	3c2e6b619554109d5a384d20e10b168aa8347d13b0ba19dda3f479bb830a69f3	11822
1253	5a4ebd17714db2b9d6637f2bb18b3c3576e32f760f18c76552d14628442bf8c5	11825
1254	c0c08925d4c678c974edc5e17ef5968552c1fb7d2dc04d2add7fa77a2465ac34	11830
1255	2d64bc46b69b99b907d6aa6987f3274355e512623c18d4470f5f8541aed97b0d	11831
1256	627d0c493e7ea90af4347ead5ed0aef94243c1ca72a111ac6c0daa466c3e92cd	11840
1257	b803f35a80ae728049756a3417621f4ee6f64e83316c10bd8108c53f9d7db6bd	11873
1258	6623e8a0624a22e0806a3964c20cd1a148dd8565902180ca7790ed8823ce6ea2	11882
1259	c1e0a482b3d90e9733508dbc7b59214836badd9f4617ea1f91bbbe2a970a5e2e	11890
1260	2f3e7d450e1adce3e90c6c315e4859882dbf7505108f56aa5dc38ebfda7de2ac	11896
1261	df93495f4d64763be2d732ce29c6b7307119ba46ab4e4881c4acb2cb8822fbb5	11910
1262	c79d7a993740ae523482056484039ce1069e6d9ed0201977da47a4c581494596	11914
1263	99f81c0c8afa6b98a78343fcd6f430166f6455c5d67c0a06d78c4e2a8f2d85a7	11918
1264	870aebb703de4302b9b6dc382297678fec3636d77747c6dcfc74b9183bfe27d8	11924
1265	a57180a2f9f7dd899225a1e8adb31c7ed1724f0f8a2fef41bd457d36bff93019	11929
1266	d6aabfefa1bdc1734d7879fb234205bd40aa3d506dde08736de841e4f289815e	11936
1267	42a66ab45911e6ef111a82a24b5db0b655cc238a73448a1a93d1f0e508c14be5	11945
1268	06cb78123ad3bc216788489f691a3ab8b7a5f5c936b2f4b558f4df5b2647d35b	11946
1269	b80d1316d5bca66e48c51131a20a978445bbc57184bb43919f382275f7f56974	11971
1270	42ed05a06d44216724cfe3e98adb0f70fb76fe3b1e0acc8094151ac3c4e1b2ce	11976
1271	f042183c4a5b653775f55562294e4e561ae3d4a9a2164cc0d31cbd6ac9eabc39	11978
1272	cbb2edc4d46ffca83a531a5e56fc8c06b22494dde8e2470135b3eb3e96f0df51	11980
1273	9ff89c3f5bb9fa5f6a1be087c6ee6da5ddbd0d354a29c136359a18b01520b3c7	11991
1274	c35bc78032c38d7574fb78977107a50aa47ed348cc47f040876e7c401fd1d6cf	12000
1275	be31f8e68a5d7b004f452c13a062b133145bd8f3b0a46e178214da052e879476	12012
1276	74872edd3dc8edace5a8ffcdddc52fc811a43c1b4ec46a8f9a3271263b37ae17	12018
1277	64cffad647c568a988b10a3a4b05a5b2a24abcf0d6a62dd8fc2d0ea772321c51	12030
1278	25975dc41686e31430d8d9805d2ad844006ad6b6c32922182a4210c10ae380e3	12037
1279	a952cd1abb31496b9818718a17bb062cb1c59318add255b293e8ded81013a8b5	12042
1280	ffb3360905589b81d70b9ab48bc0d6fd3be73d6aad0d84b960e0c8bb490d55da	12045
1281	6d45a81447a60551070051add0a0bfa118ce651508c4f1986205c25f39f47a54	12064
1282	c02c11c1c09ba5fb30d0942ba8b43e96e9840953768b61ad125725f7b6d1462e	12068
1283	3344c6929ac42e3beb917a65001604a2cc99ba17c1da662df834848483dda825	12071
1284	ac2a2d58736ff3cceda31165ca46e7eb339961829a0b9c275d6a6f5926e8a949	12080
1285	1b3e463a30ab32ef4eaf7628794fded335a52303404dc709483cb46c30927485	12085
1286	d7dc28602c8613c8254914cc887284866983c3aff77900f368ebaba9ec0bee18	12093
1287	cf84e4ab89a5c04f7abb5822adf062d16256557ea94cb82ad45a5f2595708d3b	12099
1288	46268e2bdb4651d71971eb48131b9558aceafd4d9a09bec3cbd60dc77778402a	12115
1289	44857fe658611fd2ae867c82b189c66fe3609e3ab00ee57a3b707918f081d621	12137
1290	48c01a0ae6eb10f3146a8f27e24a35224beaab757c33a2df546a737e61d975c3	12142
1291	0d5701e4b3382c6f2556121b6fa28c75dcf12d0ff92fc68b31daa335aaf02347	12156
1292	5e123b3bb94c8e42ac130b752e1701c6ef1898b932b961b11f8a2ca79c88f762	12201
1293	8635758001172ef5a6b809b66e1fd9ac435c74d84636e46ddcd80e8b5ac74a95	12202
1294	6450550b0842818187858e2743bf4cbc622fe2f89698509538c051f8f830d414	12204
1295	c87aed2457509432e0001bb0f44323f6ff183536d828e41df28f78dc126a2d4e	12209
1296	525bf351bbc2eb7dd4f8d5f9b84b7a2f089deb2a05b1bc91b14a86b32238e82b	12212
1297	0cff671fd6ce937b721ad0dd4688825e62fadb20efab02bbb1a5507a2781f834	12216
1298	159da45b506521426fa93e9a2aeb30504400daa510ce6aff74dad07d692a9f27	12233
1299	ea5f7a9ccd778258dce9c060b577c43779e5b20cb50fc1cec2d05542e0342420	12242
1300	9ea6356ebcb8484cbd47eb5f404583b913b36599ff571345a0b48bb732ae2543	12251
1301	3e6998bd93eba73eb5e026a7b07ed2ea836def9904982a93ad9cc4f5b26a2fbf	12256
1302	fc3d1ee431c352de22b8e4598c05917bedfd303b1fe62bffbb6db51a478921ab	12262
1303	459e44b31a12c641fca94a46e0c3c17c244cb260eb6390ed8604f39669926744	12267
1304	687b6f50a3eb4e2d87123efd3bdf9fd1f3e10f32434b4824db34ad54c9fc91ed	12269
1305	6e779234ea56fad64ad18e334d727e94fea303851048221a4c5f79e55c85ca05	12270
1306	64ed9f6b07358cccc2c63f207aa425cac1b2356fc7ee8a3e27d28b7c88b74ff1	12283
1307	6dca41b4c481046ca1cf871b8914e0c153e8a391c0b4500ec19adb877b5949dc	12301
1308	c7a31c7e16c608a2ca8269fb62d063fb1cd17d87f493595d8894906c7022977f	12311
1309	7d72e8943eee768111e8f63ce8eed2ed1d489f40d4df409705e1d461b6bbdc23	12313
1310	b524617fb906907a9845bb3374577136017715647186fccfd93708962ca03325	12317
1311	8045da973d491eeaac57dd183fe2f11f422c1beebc26d05e1820fb484d25c715	12323
1312	478c06e961d83dcaf14e75b6061a69f6734aaca506d1f913ecac14d80514e382	12352
1313	cdf8781f1ce15f93205b696f9a26b5c3aef824d43269c9559fb59b79e77f0523	12370
1314	829bb665201bca965b31f4efb183a4affc7b58c057dd71c2b6fdd05ab81278e2	12371
1315	9b14b0af54e0a0e6b517979699c3532a47b4c0f128c1778ac50f88f38bab27e7	12376
1316	29e5b93b6e6502598d671c614e015cd6526121630266b9d88566949cc3f2ac55	12377
1317	e302213e37c6480ec3585960f57373faa4c5e8d7331c145bece4373f4ffe54d0	12382
1318	a54b1f9597eace686f3fb04d65fc273f77fbb25bca01784e758a34e3fdf84a0e	12393
1319	6592f2d7263296785627422dfb4ec9d915f4535ec36f1156ca2ef5aebd025c1a	12406
1320	ca399096cfa0ef6ebd84f72107b96edf4ed671ac99de79c4434c0d5454770fff	12412
1321	7a85418eac9afc6e16f5b70e440dae9c1b503191cea215f80987c641355389d5	12416
1322	fef441745676fd6d419208417fa020e40f0ff64191045a435aca64054aabc76f	12437
1323	3d03f412a44ad787539606289ae8e4afb98ab2b53f3af86553261b5f7ff12567	12442
1324	2573e22ca08c00333efeabd5c8a121ec946e9f864cadfae402c385e05f104e92	12444
1325	2234d72b3a4910ca08423a9403afb924805a46b2358f5bd5f6f91c07b4d9563c	12446
1326	69e10768643d4b2a5570adc6eb49191858b3de38cfa5674f76bb1a76c9ffeb3c	12454
1327	5824b16485421a6b923b58dac0d293bb0ac77465ec69cd7fe5ca6f0b2608a7b7	12462
1328	65a519e130f344569197eb707e159f67f2b439860f1698f5a5a08149db438bd3	12489
1329	8f5ce2ccc2df80cd794813b8cbd46bb08e5dec3c3815396f90b5f3a476480c40	12504
1330	58840fa18ce1286a84deff8e91add37a531ec455c0e8a994655481d4c52e9004	12506
1331	e06f5e8f6a277469a1553ead1af4fb58e5c22517e7b191b49478788ec3e56426	12508
1332	06dec000c3d3cf0e18004a11bcd44afd1c5f6e3cbf8bd61c43c9da8f87aa7fe6	12518
1333	2bb1dc2983df082e4eb8dd609ab5d36cb736e3387d848852dc63eafec4a38690	12520
1334	321e27c2b16d87ed0fe7a6cafd1ec7f23c275f52d39fc51ae9a90ed6596fe28b	12528
1335	c67be3d04f6b27d36e6386e91f6072a5032e27921a70ee23a7810a7d35b52d85	12540
1336	0008e578608cf8408d478bf3c2c762d7dbabd00b9395f8c17090a6206ae81b04	12557
1337	cfa625f1a1ae9f4c1cebc141396768530937c08f0ab7b0b705fa7bba11f59355	12562
1338	823396e89fc598be855c76e33dd433b9772db59a560166b59c6174ecd7868f0b	12568
1339	e2327c7c43686c8d34ac540da15c4d98da53d8a8854b2addc937548641f4a1bd	12569
1340	a4e8d9e3baf18c7ac8b26ca1e97ff6c301755534d66b07cde63b91da31c6c1ca	12571
1341	770f9f5a91f010e1487688cf26bb9a20eb97181e56e1e61c5b644839ef6dc32d	12582
1342	700def3b76bfcd9fccb8abbb93174aabfdb158b32e3fd7f6cc7de510747c0ff8	12591
1343	4e5f8379d3160a171c48aa360360c41552865588b573e519ef8aca463e298173	12592
1344	f1877951458bc470d04c963acd3a8151ef183c54080b6fd69906adaea076f400	12598
1345	06279c09d21f3df68fda139a6f35854287ef4262c851bbbdc36bd546840290bb	12630
1346	6ef1633e266dced2d9e718c42e9a8d155072e3ddbe98e8fce5639d8dc69c75f9	12637
1347	9baa22c0c964ec150830a83747b6b3df3f5f70099f131fce6eed1e7b271d2426	12650
1348	fd1422b30184692b0b720b875ea173dc09d1574c394ff6946402412d531e4002	12662
1349	beb16c80e1e4746e9c76b69fea1443232bbe2a4f62911fa7875a3cb354a989e2	12673
1350	f4b5f4cfe46339414d17a7ca2cbd29666cae19e98f580e10c8ba59cb792ae801	12686
1351	83f5b3a0ed498d6c816364444f0ebe2ebd4938aa5818cc196e75ff47e46727e3	12689
1352	acd54b86a7eff1d42f8cee31d708355f76b6590e7d4ad507c78fdfa82c357690	12695
1353	751be5453df9f83753b389da3509672e016c763cfadc0fdf270859829bbf9a8e	12699
1354	ba716d6ad537f0f7ad9d6f99b85137b5b62011462d631ce48afa5c91dda9ee2c	12714
1355	c2137d1275f0bfca49855c6db448f71b85b2d0d839286b6099f5216c53097b9b	12718
1356	f75b8b1bc933eea019276e5ee2b304faf3f1ea21fd91a2f00c2d5c5eb55a07d4	12720
1357	405289f8212a5e279c93a59adfe943a4b62891f8daaaea0615f3fe0ccad85208	12723
1358	15a6a534d132f784d813f5dca0fda560763ce605cb4c8f251e50fe0b6604d2e2	12724
1359	956f7c614c8cf3ec3530351ca98581e84b4bbc10dc3a544ae99d574e65a1e590	12725
1360	ba2fa67eb901292831ba1fcb61d38f90ac2409953737e53ffc56a4aaef7ff171	12727
1361	518fd128728d167fe36a4263c6b54b8ea537a6ecae404883d38d8296b6466da6	12740
1362	2a1f179cff87e61685a9b309ad116fb60d50f6f091708225094eff77bfc8c9d0	12741
1363	1ac8cdc2b95429eb559a1fcd30b54bbf778c273d0631f97ca45b4f7062713013	12747
1364	3ea95c8a417f5197cb3e2a52fe69034fd88468c634142df7c6e6e7d7ed1a211e	12749
1365	eed30d54da6fd5dbb3c3721bcfd8e1df2847926ab7c9487f6f29dfb604db9e4b	12750
1366	80153f53df33bf95f995269000107491a19ff72cfeef7e88bdffe788fb1ff6c0	12758
1367	95bd8149f7e8e481fe0d5e0e8706d8543ad98cfe74ca1b4ee507c0a778cfc96c	12776
1368	93c1852f61b6a32dc7412f373233b480cc481ec15ec2cd3f4fbeab4e71d8d666	12782
1369	200f05589e5b0d3a2ebe9403bdb88dbe80380daa690094d95a70add30cfb18d0	12783
1370	fdc92ea1f492e1bc449352e63d5d70d4925930069046648da97fd4780df6d2d7	12796
1371	c6b90100c475530c6c208bf89d882c19c7b6f32333f025b0f655f5cbf3f5ad0e	12806
1372	c3f28ddc0c81d9041692b7df1b524a795902637f6aa2db4835e42e10cce823bf	12810
1373	09fb43082e729b5dd026f38e5d39f534ffa7fbcd5404606c2502bd619d6f5a1a	12814
1374	130dcffdf5e82f9f106cdfabe1f26f05e24e0a4a42d18bab6d4e6a0df82d9024	12828
1375	8aff02e73e967ea845efb0a568e20ac2557f874ed824909f5ef35c159e8715bf	12833
1376	bc3e3874665c899df8a790e166453db46cce938e81a1ebde4ad3d9e333c0f116	12849
1377	99423b9955a422bcc3edc90fccddc6a72048884536bc43327a513af7333d1076	12859
1378	bac507bd8618918c21f034c1251b9b09cabfb2276ed1d031e97c6b2d3ef58f3f	12878
1379	4de5f815734d63bc52c0b27fa162fc36fe3fbf1aad18cadddea98185676e0bc3	12886
1380	46635bb7981ea727744101544d4b2593090dc9cb6a04a1189881783c5f591bed	12892
1381	0813889a7a0b759c8fc5530b7267d784e98c9a45fe9883b977b96d909fe9703d	12897
1382	c209a1963c14469a745ad3ff145ad266535a80299aa1ccda256f26bf42f96490	12908
1383	a47f6ecc65d72390242df51ca9223b95eebba878ba2e3d1eb984f8221ae69aec	12943
1384	4adbff8627601286eacc48ed828826606d6fe4a80f9695a6f461b05befa3cf76	12947
1385	a8eb383c098084d501150d609c027d9a574ede2715350af141d642b955e2f86e	12958
1386	8593d4bbbaeb173703688d98ff42726f428ac6043cc1fe29add4b34f60d4361f	12972
1387	cb1300369bc2340cab5d35e03c571c59e0e570ba936dfd024baa77182bb7ec32	12974
1388	c5ab943d13deff9a82fd0099bfb00abe02769e1b3594bda97f9a61b852689148	12978
1389	6517f8923e0d91d47e4ce80edbbf7f1e570d2c09b056d84c0ef257d41bcac4fe	13001
1390	c180f823c49cf0f7874def059e3d18091c3d77411a1854868ce8c72bdeb8089f	13004
1391	9f6ebf0ca3e98f30e6f697211c8f487fd26cad94c016a82e88bbd8420ecac872	13007
1392	677f5965524253b382058e61102b9e2bdef29e82a738d4881e671171b9a00336	13010
1393	801dfc41f9f4981410e46154c4ca857428b7f0d1fcfc8a15dd90cdfc60a590af	13012
1394	bd3ec79ca24f5740d7618acc37ff62fa420b1a9c5776ccdd7aa2ce548261fadf	13038
1395	31044c3be96c0f8004b00b984721b88e471175eb91b5a913c8c29117ecd2ecbe	13050
1396	897dd2201700e216b94e078f698ab5d49683f8f1233eb1f626b354c265dde962	13053
1397	3eb2194135f22e024845f0ac6b910943a88434d9540097739f6bcded32406664	13094
1398	e057ef19cd89038f46123b72590da56a0752fa4972d008a16215ace39d1ad022	13095
1399	ff2ac76c5d7a20f6c5b7cccaeac9520ea2195e7bd541b15361d8283c7f13225d	13097
1400	9c95905e595169fa701ee764c7a6046e6edb9fb62dd07c70ad758ca591aea242	13112
1401	dafe507d671ce73f35fd1186685ab4b3bc5160c46c72784d8161195073ac68e1	13116
1402	9bae91f826190011296431b2713f9748ae219ad0f90f50d83c6f646b8799b5af	13127
1403	883a7eccfe23f0a7933ca6975500d04d305d1f11f30e2204e95a57c9bb157243	13135
1404	16565095909f2c9c960abfdd4ab334590f2e3a11bd81aa34f7cfd6f94ab13229	13156
1405	b1084172a8b713a8c14e37f5e4dd4d90d433436806eb60bbd1873829aab5d759	13165
1406	de4d3dde82b7e2bfd83ee6ac1cc94a30407f134f29e26fb5295e3a6e02dc6238	13180
1407	62a7cad4d9e9c4ed4cb8530f1b457dadec618444b8154402dc542c2549abb4b5	13183
1408	bf05275e66536087496c7f1f75d1de158f7ba8518da76088b0181bea7e921bfa	13191
1409	2251b370b0315c352f2df72514946cb02490cce7184227b7ec60794b8273fb69	13203
1410	7295c9235a59e17da1c870a954b73469265ce5c4caeb886684dc64efc75ecf49	13209
1411	6e7967a4fc811402c18c5d29fc096efc57c8b6666f5127440b76cab4ba2bddf3	13211
1412	c6f8c0ae9e365f43ec8a6d09789d87d87df9d78e4102fd84cc430afe81ebacd1	13226
1413	d275da51b3538f974b586800025b821ee9ed5bc21031eb35ce13dcb5896014c7	13230
1414	bb6cc9780d0c9103f6d9029481cdad6c711375c081d451e71da49e7ce40c1f9f	13231
1415	d0b9c292eae19c267ccbec05b433df2bf6c6b909786827b2972e47161fda0ea5	13232
1416	e3baea8f202e6ced47af0ba09c307e093c8b98e89e341b68fc824aae01b5f0ad	13235
1417	172c6754463e5a8a33fc857d8d862d5b78deaef4ac512f2d6f08b28c9e7ba6d6	13247
1418	e6c8f4458a8c1f70b47660370e2977231902e18bf3fa72e0ec35995f385406ba	13281
1419	221fd4e201bb5bb353992843b2101d8ac941ec37e2918d1f0046bae301b41ce4	13287
1420	91ef83e1f7a012e1e0a8d0cc7bebf0089aa56490acc925b9b0e1225984962791	13289
1421	5011755e940ec552be996a5c5cb637d98f50c4a7230d7f85df224e381a50a738	13299
1422	4059e1b98c606831f0b7fb0c6740c1f7c1359b871e53caf448f158c812cd24e3	13327
1423	4b9499c3d654e3ba2300295f8fa469d498300ac58cfa664ef55f4eb12171e375	13341
1424	f24a67af4af7d29ad6037897c50f5ab56b53d5ec1823d1ae23cdec08c6969b79	13345
1425	b6442bda5731d25b07b1c346e064b433a8d981a456c8132a9bce794f7faebd3a	13386
1426	cb04b6dc774b5a63f2e900c2cf0227127861d1dacf154baecb0b88eb70d7a976	13396
1427	adcf8a905ceb17dacbfa3b1abaea839562c9d96346149aba796ef8788928abab	13407
\.


--
-- Data for Name: block_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block_data (block_height, data) FROM stdin;
1419	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313431392c2268617368223a2232323166643465323031626235626233353339393238343362323130316438616339343165633337653239313864316630303436626165333031623431636534222c22736c6f74223a31333238377d2c22697373756572566b223a2266336561653865623466363633663735653538666363383233343937386233653563396664396466353865356332636231383537373736326539333664373563222c2270726576696f7573426c6f636b223a2265366338663434353861386331663730623437363630333730653239373732333139303265313862663366613732653065633335393935663338353430366261222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316739643938336b7839683366683975353373386b306d326c646a736538776d6a6e647061356a7878746a6e743832737573366d71657735326b37227d
1420	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b654b6579526567697374726174696f6e4365727469666963617465222c227374616b654b657948617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732227d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313639393839227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2239316239623063626265613739343238313438396238363235366237336362636432356161643033653730623530303734373337666162633762386462613761227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393933363530323938227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31343732377d2c227769746864726177616c73223a5b5d7d2c226964223a2261303036646538636337643831613366623731653232643265336634626432323066353035373832326633663436626461343966386335643934636138366435222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223661363233643664643161396437346132336239383766643765363834623630373164366166363633383632373139653633656333343336656665383762343864303939313832653433383632373065373832666164626566346638396138383564353630613937316233396639613263363966316439306536653532393038225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313639393839227d2c22686561646572223a7b22626c6f636b4e6f223a313432302c2268617368223a2239316566383365316637613031326531653061386430636337626562663030383961613536343930616363393235623962306531323235393834393632373931222c22736c6f74223a31333238397d2c22697373756572566b223a2266336561653865623466363633663735653538666363383233343937386233653563396664396466353865356332636231383537373736326539333664373563222c2270726576696f7573426c6f636b223a2232323166643465323031626235626233353339393238343362323130316438616339343165633337653239313864316630303436626165333031623431636534222c2273697a65223a3332392c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936363530323938227d2c227478436f756e74223a312c22767266223a227672665f766b316739643938336b7839683366683975353373386b306d326c646a736538776d6a6e647061356a7878746a6e743832737573366d71657735326b37227d
1421	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313432312c2268617368223a2235303131373535653934306563353532626539393661356335636236333764393866353063346137323330643766383564663232346533383161353061373338222c22736c6f74223a31333239397d2c22697373756572566b223a2236343733633934316335663362616438313662663765646432343361373030643936306237356435356330323837373738343337336533306334636430343765222c2270726576696f7573426c6f636b223a2239316566383365316637613031326531653061386430636337626562663030383961613536343930616363393235623962306531323235393834393632373931222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313632716165643061756a3367727271747a6b6536773275326c6a6e366b78637261356e74716d7035787a78717532756c77787271397264393764227d
1422	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313432322c2268617368223a2234303539653162393863363036383331663062376662306336373430633166376331333539623837316535336361663434386631353863383132636432346533222c22736c6f74223a31333332377d2c22697373756572566b223a2233353831336532613065303332316436663735653963623030653934336632393166323866343439663763643135386133313765666664623032346532613934222c2270726576696f7573426c6f636b223a2235303131373535653934306563353532626539393661356335636236333764393866353063346137323330643766383564663232346533383161353061373338222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3175663833303978713678676d6376397064706b666a716134767476736a67356e6767797477633537763663733664706b727738716e3372737176227d
1423	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313432332c2268617368223a2234623934393963336436353465336261323330303239356638666134363964343938333030616335386366613636346566353566346562313231373165333735222c22736c6f74223a31333334317d2c22697373756572566b223a2237396666356564306564643564323435626661623963336263343535666661336438366637323732353430303464663031343438356235386263626235613036222c2270726576696f7573426c6f636b223a2234303539653162393863363036383331663062376662306336373430633166376331333539623837316535336361663434386631353863383132636432346533222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3172663638773234343467327879677975656777767a7961333033766371776a6e7a68386435353337336b7a336672677034306571337361667a38227d
1424	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c227374616b654b657948617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732227d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313738373435227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2231613034663531633063636562343231393439303537343232613839366231663035386261353661383237303032646132363436353265366533306134346139227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961343436663735363236633635343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2232227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396134383635366336633666343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613534363537333734343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383231323535227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31343738317d2c227769746864726177616c73223a5b5d7d2c226964223a2235303965326339633934666162633263623034326438613430636331366231643330313030623339366132613839376231303364356334333036306161656237222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c223662303637653238306164336531373939626633383065666364656634383035303436653431323931366263306630613931306363613765316361613832363836616566613566646362666239613531386461386235383734323439663634356237643939366438336431633066646538316434343930656639626131393061225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223633373738363961653533623138323337653238333737323662396435306662383036373461306337613935643863643734363864376432373934306565383833316535333232663835373132303033343166313135353334616266626636646230643464653739313233303333356466313762636132376232323062333036225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313738373435227d2c22686561646572223a7b22626c6f636b4e6f223a313432342c2268617368223a2266323461363761663461663764323961643630333738393763353066356162353662353364356563313832336431616532336364656330386336393639623739222c22736c6f74223a31333334357d2c22697373756572566b223a2264323538333438333264646463616364383634373232326237653231376533353263396539643239346565316638366264663138666264613534306631316630222c2270726576696f7573426c6f636b223a2234623934393963336436353465336261323330303239356638666134363964343938333030616335386366613636346566353566346562313231373165333735222c2273697a65223a3532382c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383231323535227d2c227478436f756e74223a312c22767266223a227672665f766b317632386464636b363475756c667334797877777675777430646d7278716a393479637a347367663468383737737a3833716d3573336c6b7a6c71227d
1425	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313432352c2268617368223a2262363434326264613537333164323562303762316333343665303634623433336138643938316134353663383133326139626365373934663766616562643361222c22736c6f74223a31333338367d2c22697373756572566b223a2239333666663733346533313332303632633539636538646335333662663062376235363662313163356362653863633761613036356634366436343235383834222c2270726576696f7573426c6f636b223a2266323461363761663461663764323961643630333738393763353066356162353662353364356563313832336431616532336364656330386336393639623739222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a66327838707567343670797672746563676a716a6b356b306b30636b716c33386a71346b68766d6d7375716e6c61646b6d6b73647a6b727535227d
1426	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313432362c2268617368223a2263623034623664633737346235613633663265393030633263663032323731323738363164316461636631353462616563623062383865623730643761393736222c22736c6f74223a31333339367d2c22697373756572566b223a2262313835356233613839616136663438363732343064616661663138336533366538653961313766643532643662306132346335653336613632313739616164222c2270726576696f7573426c6f636b223a2262363434326264613537333164323562303762316333343665303634623433336138643938316134353663383133326139626365373934663766616562643361222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3176387134703030756d77756a6133643037646e6d676b717777673236333963396179706b383066383770636d3374633263676371633430343676227d
1427	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313432372c2268617368223a2261646366386139303563656231376461636266613362316162616561383339353632633964393633343631343961626137393665663837383839323861626162222c22736c6f74223a31333430377d2c22697373756572566b223a2262376331373039326665303036396238323835643335386533353564343935656333643336636638316361343462613266336166336535663331653038663436222c2270726576696f7573426c6f636b223a2263623034623664633737346235613633663265393030633263663032323731323738363164316461636631353462616563623062383865623730643761393736222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31666d736e37306474366d757474716e376563646a7a6b64327638393433793965793474676c6774306d64643339646c32753233737a766a636a78227d
1416	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b226964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c22767266223a2236343164303432656433396332633235386433383130363063313432346634306566386162666532356566353636663463623232343737633432623261303134222c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223530303030303030227d2c22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c227265776172644163636f756e74223a227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576222c226f776e657273223a5b227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576225d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e32222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d7d7d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739373133227d2c22696e70757473223a5b7b22696e646578223a342c2274784964223a2232313966666438323032666362653132333762386532363934326535316531613238346562333361323238613863633934313638646235633435363534616136227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936383230323837227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31343637317d2c227769746864726177616c73223a5b5d7d2c226964223a2239316239623063626265613739343238313438396238363235366237336362636432356161643033653730623530303734373337666162633762386462613761222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c223663366661343762373739643436373938326536383136643165353465643237623434313339323466386232343565663362326334396162363033633662373139643836633862656262663834656435633538316138663965333966383537643566376632396262393339663063616435343437373765383138643237613065225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c226261356435313964626634366139306337656364653434666234333361376366636238333738393638333333366631343431643134656137646534316536633561353665393365393830653136626565623836666332393837376631663463353439623239313061656138316139626633393266393638613162303265653030225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739373133227d2c22686561646572223a7b22626c6f636b4e6f223a313431362c2268617368223a2265336261656138663230326536636564343761663062613039633330376530393363386239386538396533343162363866633832346161653031623566306164222c22736c6f74223a31333233357d2c22697373756572566b223a2264323538333438333264646463616364383634373232326237653231376533353263396539643239346565316638366264663138666264613534306631316630222c2270726576696f7573426c6f636b223a2264306239633239326561653139633236376363626563303562343333646632626636633662393039373836383237623239373265343731363166646130656135222c2273697a65223a3535302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383230323837227d2c227478436f756e74223a312c22767266223a227672665f766b317632386464636b363475756c667334797877777675777430646d7278716a393479637a347367663468383737737a3833716d3573336c6b7a6c71227d
1417	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313431372c2268617368223a2231373263363735343436336535613861333366633835376438643836326435623738646561656634616335313266326436663038623238633965376261366436222c22736c6f74223a31333234377d2c22697373756572566b223a2264323538333438333264646463616364383634373232326237653231376533353263396539643239346565316638366264663138666264613534306631316630222c2270726576696f7573426c6f636b223a2265336261656138663230326536636564343761663062613039633330376530393363386239386538396533343162363866633832346161653031623566306164222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317632386464636b363475756c667334797877777675777430646d7278716a393479637a347367663468383737737a3833716d3573336c6b7a6c71227d
1418	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313431382c2268617368223a2265366338663434353861386331663730623437363630333730653239373732333139303265313862663366613732653065633335393935663338353430366261222c22736c6f74223a31333238317d2c22697373756572566b223a2264323538333438333264646463616364383634373232326237653231376533353263396539643239346565316638366264663138666264613534306631316630222c2270726576696f7573426c6f636b223a2231373263363735343436336535613861333366633835376438643836326435623738646561656634616335313266326436663038623238633965376261366436222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317632386464636b363475756c667334797877777675777430646d7278716a393479637a347367663468383737737a3833716d3573336c6b7a6c71227d
1390	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313830373235227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2261623430306437353536646231383464646239636337316664633361303536616561363830306131646239356366666462393561333032343238633739383330227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2235303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c7370396a6e32346e6366736172616863726734746b6e74396775703775663775616b3275397972326532346471717a70717764222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223535313136333437333136227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31343434317d2c227769746864726177616c73223a5b7b227175616e74697479223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234313335393730323635227d2c227374616b6541646472657373223a227374616b655f7465737431757263716a65663432657579637733376d75703532346d66346a3577716c77796c77776d39777a6a70347634326b736a6773676379227d2c7b227175616e74697479223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223131383639343932383033227d2c227374616b6541646472657373223a227374616b655f7465737431757263346d767a6c326370346765646c337971327078373635396b726d7a757a676e6c3264706a6a677379646d71717867616d6a37227d5d7d2c226964223a2235353636353537393933356133373166656566346437656137396235316631623732616363363262343931623661636334663630376664396137363138323637222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2233363863663661313161633765323939313735363861333636616636326135393663623963646538313734626665376636653838333933656364623164636336222c223933633430636561353737616432383164666466326137396633623131623333636362333330613532643531303166336365393163636533653930386637353339333632303761636634663239623530633534333730633239383237373733653235636565353735373933663335366637643535616138323935653661623032225d2c5b2238373563316539386262626265396337376264646364373063613464373261633964303734303837346561643161663932393036323936353533663866333433222c223331343363376663366239646464656664643165383034613435323864356236356336396133323138653863353666616539323033623239643631383036313332643261616233393733303130376461353335383466643662366430393530366162313736303838666335386430333630353061363134383833366136623039225d2c5b2238363439393462663364643637393466646635366233623264343034363130313038396436643038393164346130616132343333316566383662306162386261222c226539376465343130383664333731303436356132646335643438653130636436316461643030306166633263376537353137656637373563626365633161643632636161343136366566633563393231356332343261623236376463353137323432353865333530643432663635653430376464353865393064366230343037225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313830373235227d2c22686561646572223a7b22626c6f636b4e6f223a313339302c2268617368223a2263313830663832336334396366306637383734646566303539653364313830393163336437373431316131383534383638636538633732626465623830383966222c22736c6f74223a31333030347d2c22697373756572566b223a2236343733633934316335663362616438313662663765646432343361373030643936306237356435356330323837373738343337336533306334636430343765222c2270726576696f7573426c6f636b223a2236353137663839323365306439316434376534636538306564626266376631653537306432633039623035366438346330656632353764343162636163346665222c2273697a65223a3537332c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223535313231333437333136227d2c227478436f756e74223a312c22767266223a227672665f766b313632716165643061756a3367727271747a6b6536773275326c6a6e366b78637261356e74716d7035787a78717532756c77787271397264393764227d
1391	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313339312c2268617368223a2239663665626630636133653938663330653666363937323131633866343837666432366361643934633031366138326538386262643834323065636163383732222c22736c6f74223a31333030377d2c22697373756572566b223a2237396666356564306564643564323435626661623963336263343535666661336438366637323732353430303464663031343438356235386263626235613036222c2270726576696f7573426c6f636b223a2263313830663832336334396366306637383734646566303539653364313830393163336437373431316131383534383638636538633732626465623830383966222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3172663638773234343467327879677975656777767a7961333033766371776a6e7a68386435353337336b7a336672677034306571337361667a38227d
1392	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313339322c2268617368223a2236373766353936353532343235336233383230353865363131303262396532626465663239653832613733386434383831653637313137316239613030333336222c22736c6f74223a31333031307d2c22697373756572566b223a2262376331373039326665303036396238323835643335386533353564343935656333643336636638316361343462613266336166336535663331653038663436222c2270726576696f7573426c6f636b223a2239663665626630636133653938663330653666363937323131633866343837666432366361643934633031366138326538386262643834323065636163383732222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31666d736e37306474366d757474716e376563646a7a6b64327638393433793965793474676c6774306d64643339646c32753233737a766a636a78227d
1393	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313339332c2268617368223a2238303164666334316639663439383134313065343631353463346361383537343238623766306431666366633861313564643930636466633630613539306166222c22736c6f74223a31333031327d2c22697373756572566b223a2262376331373039326665303036396238323835643335386533353564343935656333643336636638316361343462613266336166336535663331653038663436222c2270726576696f7573426c6f636b223a2236373766353936353532343235336233383230353865363131303262396532626465663239653832613733386434383831653637313137316239613030333336222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31666d736e37306474366d757474716e376563646a7a6b64327638393433793965793474676c6774306d64643339646c32753233737a766a636a78227d
1394	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b22626c6f62223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22626967696e74222c2276616c7565223a22373231227d2c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2268616e646c6531222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b226175676d656e746174696f6e73222c5b5d5d2c5b22636f7265222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2268616e646c65456e636f64696e67222c227574662d38225d2c5b226f67222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b22707265666978222c2224225d2c5b227465726d736f66757365222c2268747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f225d2c5b2276657273696f6e222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d5d7d5d2c5b226465736372697074696f6e222c225468652048616e646c65205374616e64617264225d2c5b22696d616765222c22697066733a2f2f736f6d652d68617368225d2c5b226e616d65222c222468616e646c6531225d2c5b2277656273697465222c2268747470733a2f2f63617264616e6f2e6f72672f225d5d7d5d5d7d5d5d7d5d5d7d2c2273637269707473223a5b5d7d2c22626f6479223a7b22617578696c696172794461746148617368223a2266396137363664303138666364333236626538323936366438643130333265343830383163636536326663626135666231323430326662363666616166366233222c22636572746966696361746573223a5b5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22323336343239227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2233323032303138653532356130633435613662636537616561313131343865396437323230663362306530656334313663653566336635313736356439356637227d2c7b22696e646578223a312c2274784964223a2233656139613333653964313235393266393035643064366364633666343961613130316462613461646666373130643334613366333738333134316234326531227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303036343362303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303064653134303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613638363136653634366336353331222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b2263626f72223a2264383739396661613434366536313664363534613234373036383631373236643635373237333332343536393664363136373635353833383639373036363733336132663266376136343661333735373664366635613336353637393335363433333462333637353731343235333532356135303532376135333635363235363738363234633332366533313537343135313465343135383333366634633631353736353539373434393664363536343639363135343739373036353461363936643631363736353266366137303635363734323666363730303439366636373566366537353664363236353732303034363732363137323639373437393435363236313733363936333436366336353665363737343638303934613633363836313732363136333734363537323733346636633635373437343635373237333263366537353664363236353732373335313665373536643635373236393633356636643666363436393636363936353732373334303437373636353732373336393666366530313031623334383632363735663639366436313637363535383335363937303636373333613266326635313664353933363538363937313432373233393461346536653735363737353534353237333738333336663633373636623531363536643465346133353639343335323464363936353338333537373731376133393334346136663439373036363730356636393664363136373635353833353639373036363733336132663266353136643537363736613538343337383536353535333537353037393331353736643535353633333661366635303530333137333561346437363561333733313733366633363731373933363433333235613735366235323432343434363730366637323734363136633430343836343635373336393637366536353732353833383639373036363733336132663266376136323332373236383662333237383435333135343735353735373738373434383534376136663335363737343434363934353738343133363534373237363533346236393539366536313736373034353532333334633636343436623666346234373733366636333639363136633733343034363736363536653634366637323430343736343635363636313735366337343030346537333734363136653634363137323634356636393664363136373635353833383639373036363733336132663266376136323332373236383639366234333536373435333561376134623735363933353333366237363537346333383739373435363433373436333761363734353732333934323463366134363632353834323334353435383535373836383438373935333663363137333734356637353730363436313734363535663631363436343732363537333733353833393031653830666433303330626662313766323562666565353064326537316339656365363832393239313536393866393535656136363435656132623762653031323236386139356562616566653533303531363434303564663232636534313139613461333534396262663163646133643463373636313663363936343631373436353634356636323739353831633464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531346136393664363136373635356636383631373336383538323062636435386330646365656139376237313762636265306564633430623265363566633233323961346462396365333731366234376239306562353136376465353337333734363136653634363137323634356636393664363136373635356636383631373336383538323062336430366238363034616363393137323965346431306666356634326461343133376362623662393433323931663730336562393737363136373363393830346237333736363735663736363537323733363936663665343633313265333133353265333034633631363737323635363536343566373436353732366437333430353436643639363737323631373436353566373336393637356637323635373137353639373236353634303034343665373336363737303034353734373236393631366330303439373036363730356636313733373336353734353832336537343836326130396431376139636230333137346136626435666133303562383638343437356334633336303231353931633630366530343435303330333633383331333634383632363735663631373337333635373435383263396264663433376236383331643436643932643064623830663139663162373032313435653966646363343363363236346637613034646330303162633238303534363836353230343637323635363532303466366536356666222c22636f6e7374727563746f72223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c226669656c6473223a7b2263626f72223a22396661613434366536313664363534613234373036383631373236643635373237333332343536393664363136373635353833383639373036363733336132663266376136343661333735373664366635613336353637393335363433333462333637353731343235333532356135303532376135333635363235363738363234633332366533313537343135313465343135383333366634633631353736353539373434393664363536343639363135343739373036353461363936643631363736353266366137303635363734323666363730303439366636373566366537353664363236353732303034363732363137323639373437393435363236313733363936333436366336353665363737343638303934613633363836313732363136333734363537323733346636633635373437343635373237333263366537353664363236353732373335313665373536643635373236393633356636643666363436393636363936353732373334303437373636353732373336393666366530313031623334383632363735663639366436313637363535383335363937303636373333613266326635313664353933363538363937313432373233393461346536653735363737353534353237333738333336663633373636623531363536643465346133353639343335323464363936353338333537373731376133393334346136663439373036363730356636393664363136373635353833353639373036363733336132663266353136643537363736613538343337383536353535333537353037393331353736643535353633333661366635303530333137333561346437363561333733313733366633363731373933363433333235613735366235323432343434363730366637323734363136633430343836343635373336393637366536353732353833383639373036363733336132663266376136323332373236383662333237383435333135343735353735373738373434383534376136663335363737343434363934353738343133363534373237363533346236393539366536313736373034353532333334633636343436623666346234373733366636333639363136633733343034363736363536653634366637323430343736343635363636313735366337343030346537333734363136653634363137323634356636393664363136373635353833383639373036363733336132663266376136323332373236383639366234333536373435333561376134623735363933353333366237363537346333383739373435363433373436333761363734353732333934323463366134363632353834323334353435383535373836383438373935333663363137333734356637353730363436313734363535663631363436343732363537333733353833393031653830666433303330626662313766323562666565353064326537316339656365363832393239313536393866393535656136363435656132623762653031323236386139356562616566653533303531363434303564663232636534313139613461333534396262663163646133643463373636313663363936343631373436353634356636323739353831633464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531346136393664363136373635356636383631373336383538323062636435386330646365656139376237313762636265306564633430623265363566633233323961346462396365333731366234376239306562353136376465353337333734363136653634363137323634356636393664363136373635356636383631373336383538323062336430366238363034616363393137323965346431306666356634326461343133376362623662393433323931663730336562393737363136373363393830346237333736363735663736363537323733363936663665343633313265333133353265333034633631363737323635363536343566373436353732366437333430353436643639363737323631373436353566373336393637356637323635373137353639373236353634303034343665373336363737303034353734373236393631366330303439373036363730356636313733373336353734353832336537343836326130396431376139636230333137346136626435666133303562383638343437356334633336303231353931633630366530343435303330333633383331333634383632363735663631373337333635373435383263396264663433376236383331643436643932643064623830663139663162373032313435653966646363343363363236346637613034646330303162633238303534363836353230343637323635363532303466366536356666222c226974656d73223a5b7b2263626f72223a226161343436653631366436353461323437303638363137323664363537323733333234353639366436313637363535383338363937303636373333613266326637613634366133373537366436663561333635363739333536343333346233363735373134323533353235613530353237613533363536323536373836323463333236653331353734313531346534313538333336663463363135373635353937343439366436353634363936313534373937303635346136393664363136373635326636613730363536373432366636373030343936663637356636653735366436323635373230303436373236313732363937343739343536323631373336393633343636633635366536373734363830393461363336383631373236313633373436353732373334663663363537343734363537323733326336653735366436323635373237333531366537353664363537323639363335663664366636343639363636393635373237333430343737363635373237333639366636653031222c2264617461223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22427566666572222c2276616c7565223a223665363136643635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223234373036383631373236643635373237333332227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363436613337353736643666356133363536373933353634333334623336373537313432353335323561353035323761353336353632353637383632346333323665333135373431353134653431353833333666346336313537363535393734227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366436353634363936313534373937303635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223639366436313637363532663661373036353637227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236663637227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366636373566366537353664363236353732227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373236313732363937343739227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236323631373336393633227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366336353665363737343638227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2239227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223633363836313732363136333734363537323733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22366336353734373436353732373332633665373536643632363537323733227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236653735366436353732363936333566366436663634363936363639363537323733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223736363537323733363936663665227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d7d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d2c7b2263626f72223a2262333438363236373566363936643631363736353538333536393730363637333361326632663531366435393336353836393731343237323339346134653665373536373735353435323733373833333666363337363662353136353664346534613335363934333532346436393635333833353737373137613339333434613666343937303636373035663639366436313637363535383335363937303636373333613266326635313664353736373661353834333738353635353533353735303739333135373664353535363333366136663530353033313733356134643736356133373331373336663336373137393336343333323561373536623532343234343436373036663732373436313663343034383634363537333639363736653635373235383338363937303636373333613266326637613632333237323638366233323738343533313534373535373537373837343438353437613666333536373734343436393435373834313336353437323736353334623639353936653631373637303435353233333463363634343662366634623437373336663633363936313663373334303436373636353665363436663732343034373634363536363631373536633734303034653733373436313665363436313732363435663639366436313637363535383338363937303636373333613266326637613632333237323638363936623433353637343533356137613462373536393335333336623736353734633338373937343536343337343633376136373435373233393432346336613436363235383432333435343538353537383638343837393533366336313733373435663735373036343631373436353566363136343634373236353733373335383339303165383066643330333062666231376632356266656535306432653731633965636536383239323931353639386639353565613636343565613262376265303132323638613935656261656665353330353136343430356466323263653431313961346133353439626266316364613364346337363631366336393634363137343635363435663632373935383163346461393635613034396466643135656431656531396662613665323937346130623739666334313664643137393661316639376635653134613639366436313637363535663638363137333638353832306263643538633064636565613937623731376263626530656463343062326536356663323332396134646239636533373136623437623930656235313637646535333733373436313665363436313732363435663639366436313637363535663638363137333638353832306233643036623836303461636339313732396534643130666635663432646134313337636262366239343332393166373033656239373736313637336339383034623733373636373566373636353732373336393666366534363331326533313335326533303463363136373732363536353634356637343635373236643733343035343664363936373732363137343635356637333639363735663732363537313735363937323635363430303434366537333636373730303435373437323639363136633030343937303636373035663631373337333635373435383233653734383632613039643137613963623033313734613662643566613330356238363834343735633463333630323135393163363036653034343530333033363338333133363438363236373566363137333733363537343538326339626466343337623638333164343664393264306462383066313966316237303231343565396664636334336336323634663761303464633030316263323830353436383635323034363732363536353230346636653635222c2264617461223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236323637356636393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663531366435393336353836393731343237323339346134653665373536373735353435323733373833333666363337363662353136353664346534613335363934333532346436393635333833353737373137613339333434613666227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373036363730356636393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663531366435373637366135383433373835363535353335373530373933313537366435353536333336613666353035303331373335613464373635613337333137333666333637313739333634333332356137353662353234323434227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373036663732373436313663227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236343635373336393637366536353732227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363233323732363836623332373834353331353437353537353737383734343835343761366633353637373434343639343537383431333635343732373635333462363935393665363137363730343535323333346336363434366236663462227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223733366636333639363136633733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373636353665363436663732227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223634363536363631373536633734227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237333734363136653634363137323634356636393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363233323732363836393662343335363734353335613761346237353639333533333662373635373463333837393734353634333734363337613637343537323339343234633661343636323538343233343534353835353738363834383739227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223663363137333734356637353730363436313734363535663631363436343732363537333733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22303165383066643330333062666231376632356266656535306432653731633965636536383239323931353639386639353565613636343565613262376265303132323638613935656261656665353330353136343430356466323263653431313961346133353439626266316364613364227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373636313663363936343631373436353634356636323739227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223639366436313637363535663638363137333638227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2262636435386330646365656139376237313762636265306564633430623265363566633233323961346462396365333731366234376239306562353136376465227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223733373436313665363436313732363435663639366436313637363535663638363137333638227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2262336430366238363034616363393137323965346431306666356634326461343133376362623662393433323931663730336562393737363136373363393830227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237333736363735663736363537323733363936663665227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22333132653331333532653330227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22363136373732363536353634356637343635373236643733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236643639363737323631373436353566373336393637356637323635373137353639373236353634227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223665373336363737227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237343732363936313663227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373036363730356636313733373336353734227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2265373438363261303964313761396362303331373461366264356661333035623836383434373563346333363032313539316336303665303434353033303336333833313336227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236323637356636313733373336353734227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2239626466343337623638333164343664393264306462383066313966316237303231343565396664636334336336323634663761303464633030316263323830353436383635323034363732363536353230346636653635227d5d5d7d7d5d7d7d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303036343362303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303064653134303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613638363136653634366336353331222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223130303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c7370396a6e32346e6366736172616863726734746b6e74396775703775663775616b3275397972326532346471717a70717764222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313536343633363832303738227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31343435327d2c227769746864726177616c73223a5b5d7d2c226964223a2233616663346430323063626136373437626433313064313534646632323831613462626334623036333034343863386666656330393662323938626334366665222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b7b225f5f74797065223a226e6174697665222c226b657948617368223a223563663663393132373961383539613037323630313737396662333362623037633334653164363431643435646635316666363362393637222c226b696e64223a307d5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2233363863663661313161633765323939313735363861333636616636326135393663623963646538313734626665376636653838333933656364623164636336222c226530326336306531303130613830633639313435613131626335313261373537666565616433313333333235663438396464626231363266633232353437663333393863386161623064383935346231313336303833316634326537636335366130613938373532366637363131666337616335623136616161376537653034225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22323336343239227d2c22686561646572223a7b22626c6f636b4e6f223a313339342c2268617368223a2262643365633739636132346635373430643736313861636333376666363266613432306231613963353737366363646437616132636535343832363166616466222c22736c6f74223a31333033387d2c22697373756572566b223a2233353831336532613065303332316436663735653963623030653934336632393166323866343439663763643135386133313765666664623032346532613934222c2270726576696f7573426c6f636b223a2238303164666334316639663439383134313065343631353463346361383537343238623766306431666366633861313564643930636466633630613539306166222c2273697a65223a313734302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313536343733363832303738227d2c227478436f756e74223a312c22767266223a227672665f766b3175663833303978713678676d6376397064706b666a716134767476736a67356e6767797477633537763663733664706b727738716e3372737176227d
1395	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313339352c2268617368223a2233313034346333626539366330663830303462303062393834373231623838653437313137356562393162356139313363386332393131376563643265636265222c22736c6f74223a31333035307d2c22697373756572566b223a2239333666663733346533313332303632633539636538646335333662663062376235363662313163356362653863633761613036356634366436343235383834222c2270726576696f7573426c6f636b223a2262643365633739636132346635373430643736313861636333376666363266613432306231613963353737366363646437616132636535343832363166616466222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a66327838707567343670797672746563676a716a6b356b306b30636b716c33386a71346b68766d6d7375716e6c61646b6d6b73647a6b727535227d
1396	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313339362c2268617368223a2238393764643232303137303065323136623934653037386636393861623564343936383366386631323333656231663632366233353463323635646465393632222c22736c6f74223a31333035337d2c22697373756572566b223a2262376331373039326665303036396238323835643335386533353564343935656333643336636638316361343462613266336166336535663331653038663436222c2270726576696f7573426c6f636b223a2233313034346333626539366330663830303462303062393834373231623838653437313137356562393162356139313363386332393131376563643265636265222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31666d736e37306474366d757474716e376563646a7a6b64327638393433793965793474676c6774306d64643339646c32753233737a766a636a78227d
1397	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313339372c2268617368223a2233656232313934313335663232653032343834356630616336623931303934336138383433346439353430303937373339663662636465643332343036363634222c22736c6f74223a31333039347d2c22697373756572566b223a2239336535353564346463623634653838356336353234323830356235373130356564366138613962323034363662323566386436373537643263396137643431222c2270726576696f7573426c6f636b223a2238393764643232303137303065323136623934653037386636393861623564343936383366386631323333656231663632366233353463323635646465393632222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e3838646c6c336a613530387a36676c646e35797366776e723768643268736475356b7a686a346c366c786a3071306d76766b736b3767796d61227d
1398	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313339382c2268617368223a2265303537656631396364383930333866343631323362373235393064613536613037353266613439373264303038613136323135616365333964316164303232222c22736c6f74223a31333039357d2c22697373756572566b223a2262313835356233613839616136663438363732343064616661663138336533366538653961313766643532643662306132346335653336613632313739616164222c2270726576696f7573426c6f636b223a2233656232313934313335663232653032343834356630616336623931303934336138383433346439353430303937373339663662636465643332343036363634222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3176387134703030756d77756a6133643037646e6d676b717777673236333963396179706b383066383770636d3374633263676371633430343676227d
1399	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313339392c2268617368223a2266663261633736633564376132306636633562376363636165616339353230656132313935653762643534316231353336316438323833633766313332323564222c22736c6f74223a31333039377d2c22697373756572566b223a2239336535353564346463623634653838356336353234323830356235373130356564366138613962323034363662323566386436373537643263396137643431222c2270726576696f7573426c6f636b223a2265303537656631396364383930333866343631323362373235393064613536613037353266613439373264303038613136323135616365333964316164303232222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e3838646c6c336a613530387a36676c646e35797366776e723768643268736475356b7a686a346c366c786a3071306d76766b736b3767796d61227d
1400	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313430302c2268617368223a2239633935393035653539353136396661373031656537363463376136303436653665646239666236326464303763373061643735386361353931616561323432222c22736c6f74223a31333131327d2c22697373756572566b223a2266336561653865623466363633663735653538666363383233343937386233653563396664396466353865356332636231383537373736326539333664373563222c2270726576696f7573426c6f636b223a2266663261633736633564376132306636633562376363636165616339353230656132313935653762643534316231353336316438323833633766313332323564222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316739643938336b7839683366683975353373386b306d326c646a736538776d6a6e647061356a7878746a6e743832737573366d71657735326b37227d
1401	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313430312c2268617368223a2264616665353037643637316365373366333566643131383636383561623462336263353136306334366337323738346438313631313935303733616336386531222c22736c6f74223a31333131367d2c22697373756572566b223a2236343733633934316335663362616438313662663765646432343361373030643936306237356435356330323837373738343337336533306334636430343765222c2270726576696f7573426c6f636b223a2239633935393035653539353136396661373031656537363463376136303436653665646239666236326464303763373061643735386361353931616561323432222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313632716165643061756a3367727271747a6b6536773275326c6a6e366b78637261356e74716d7035787a78717532756c77787271397264393764227d
1402	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313430322c2268617368223a2239626165393166383236313930303131323936343331623237313366393734386165323139616430663930663530643833633666363436623837393962356166222c22736c6f74223a31333132377d2c22697373756572566b223a2262376331373039326665303036396238323835643335386533353564343935656333643336636638316361343462613266336166336535663331653038663436222c2270726576696f7573426c6f636b223a2264616665353037643637316365373366333566643131383636383561623462336263353136306334366337323738346438313631313935303733616336386531222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31666d736e37306474366d757474716e376563646a7a6b64327638393433793965793474676c6774306d64643339646c32753233737a766a636a78227d
1403	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b226964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c22767266223a2232656535613463343233323234626239633432313037666331386136303535366436613833636563316439646433376137316635366166373139386663373539222c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22353030303030303030303030303030227d2c22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c227265776172644163636f756e74223a227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973222c226f776e657273223a5b227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973225d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e31222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d7d7d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22696e70757473223a5b7b22696e646578223a322c2274784964223a2232313966666438323032666362653132333762386532363934326535316531613238346562333361323238613863633934313638646235633435363534616136227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936383230313131227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31343536377d2c227769746864726177616c73223a5b5d7d2c226964223a2233346637623237383131313338336638643237323933373836353265626338316533376464616262613030306436346364363438326336663735643839373033222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c226233653832343334623464393465346230363435626261623637333333323436313135636332356430633231656366396162613862353232363062366362343939616462393737336262336530333462343235656533356634336361646635643662363032663630643964663035376339366661393464396662356634653036225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c226565346330316435326535326232643739393363666366656535396437333762623237653463623165363261643734326633396164376465383966353934343663333134346164643935393938666138353933326261616639656362666432333937386339343638306537636662653464303637653031326661323065313036225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22686561646572223a7b22626c6f636b4e6f223a313430332c2268617368223a2238383361376563636665323366306137393333636136393735353030643034643330356431663131663330653232303465393561353763396262313537323433222c22736c6f74223a31333133357d2c22697373756572566b223a2264323538333438333264646463616364383634373232326237653231376533353263396539643239346565316638366264663138666264613534306631316630222c2270726576696f7573426c6f636b223a2239626165393166383236313930303131323936343331623237313366393734386165323139616430663930663530643833633666363436623837393962356166222c2273697a65223a3535342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383230313131227d2c227478436f756e74223a312c22767266223a227672665f766b317632386464636b363475756c667334797877777675777430646d7278716a393479637a347367663468383737737a3833716d3573336c6b7a6c71227d
1404	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313430342c2268617368223a2231363536353039353930396632633963393630616266646434616233333435393066326533613131626438316161333466376366643666393461623133323239222c22736c6f74223a31333135367d2c22697373756572566b223a2239336535353564346463623634653838356336353234323830356235373130356564366138613962323034363662323566386436373537643263396137643431222c2270726576696f7573426c6f636b223a2238383361376563636665323366306137393333636136393735353030643034643330356431663131663330653232303465393561353763396262313537323433222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e3838646c6c336a613530387a36676c646e35797366776e723768643268736475356b7a686a346c366c786a3071306d76766b736b3767796d61227d
1405	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313430352c2268617368223a2262313038343137326138623731336138633134653337663565346464346439306434333334333638303665623630626264313837333832396161623564373539222c22736c6f74223a31333136357d2c22697373756572566b223a2237396666356564306564643564323435626661623963336263343535666661336438366637323732353430303464663031343438356235386263626235613036222c2270726576696f7573426c6f636b223a2231363536353039353930396632633963393630616266646434616233333435393066326533613131626438316161333466376366643666393461623133323239222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3172663638773234343467327879677975656777767a7961333033766371776a6e7a68386435353337336b7a336672677034306571337361667a38227d
1406	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313430362c2268617368223a2264653464336464653832623765326266643833656536616331636339346133303430376631333466323965323666623532393565336136653032646336323338222c22736c6f74223a31333138307d2c22697373756572566b223a2264323538333438333264646463616364383634373232326237653231376533353263396539643239346565316638366264663138666264613534306631316630222c2270726576696f7573426c6f636b223a2262313038343137326138623731336138633134653337663565346464346439306434333334333638303665623630626264313837333832396161623564373539222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317632386464636b363475756c667334797877777675777430646d7278716a393479637a347367663468383737737a3833716d3573336c6b7a6c71227d
1407	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b654b6579526567697374726174696f6e4365727469666963617465222c227374616b654b657948617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832227d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731353733227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2233346637623237383131313338336638643237323933373836353265626338316533376464616262613030306436346364363438326336663735643839373033227d2c7b22696e646578223a312c2274784964223a2233346637623237383131313338336638643237323933373836353265626338316533376464616262613030306436346364363438326336663735643839373033227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936363438353338227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31343632307d2c227769746864726177616c73223a5b5d7d2c226964223a2264376337653566363936333335653631313731636535313535623664623165316565313230636132386630313964313832663034393430623735376562656162222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223766303036366439626565616237663665633539623437373333643462383233353061383335363966653437306233323065373538396361316265626362373533366633303736343761373664616133613665643131313964313161366637303135396430323130613663313731366333376463623436643235393266343064225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731353733227d2c22686561646572223a7b22626c6f636b4e6f223a313430372c2268617368223a2236326137636164346439653963346564346362383533306631623435376461646563363138343434623831353434303264633534326332353439616262346235222c22736c6f74223a31333138337d2c22697373756572566b223a2239333666663733346533313332303632633539636538646335333662663062376235363662313163356362653863633761613036356634366436343235383834222c2270726576696f7573426c6f636b223a2264653464336464653832623765326266643833656536616331636339346133303430376631333466323965323666623532393565336136653032646336323338222c2273697a65223a3336352c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939363438353338227d2c227478436f756e74223a312c22767266223a227672665f766b316a66327838707567343670797672746563676a716a6b356b306b30636b716c33386a71346b68766d6d7375716e6c61646b6d6b73647a6b727535227d
1408	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313430382c2268617368223a2262663035323735653636353336303837343936633766316637356431646531353866376261383531386461373630383862303138316265613765393231626661222c22736c6f74223a31333139317d2c22697373756572566b223a2262376331373039326665303036396238323835643335386533353564343935656333643336636638316361343462613266336166336535663331653038663436222c2270726576696f7573426c6f636b223a2236326137636164346439653963346564346362383533306631623435376461646563363138343434623831353434303264633534326332353439616262346235222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31666d736e37306474366d757474716e376563646a7a6b64327638393433793965793474676c6774306d64643339646c32753233737a766a636a78227d
1409	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313430392c2268617368223a2232323531623337306230333135633335326632646637323531343934366362303234393063636537313834323237623765633630373934623832373366623639222c22736c6f74223a31333230337d2c22697373756572566b223a2239336535353564346463623634653838356336353234323830356235373130356564366138613962323034363662323566386436373537643263396137643431222c2270726576696f7573426c6f636b223a2262663035323735653636353336303837343936633766316637356431646531353866376261383531386461373630383862303138316265613765393231626661222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e3838646c6c336a613530387a36676c646e35797366776e723768643268736475356b7a686a346c366c786a3071306d76766b736b3767796d61227d
1410	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313431302c2268617368223a2237323935633932333561353965313764613163383730613935346237333436393236356365356334636165623838363638346463363465666337356563663439222c22736c6f74223a31333230397d2c22697373756572566b223a2239336535353564346463623634653838356336353234323830356235373130356564366138613962323034363662323566386436373537643263396137643431222c2270726576696f7573426c6f636b223a2232323531623337306230333135633335326632646637323531343934366362303234393063636537313834323237623765633630373934623832373366623639222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e3838646c6c336a613530387a36676c646e35797366776e723768643268736475356b7a686a346c366c786a3071306d76766b736b3767796d61227d
1411	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c227374616b654b657948617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832227d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313737333337227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2264376337653566363936333335653631313731636535313535623664623165316565313230636132386630313964313832663034393430623735376562656162227d2c7b22696e646578223a312c2274784964223a2264376337653566363936333335653631313731636535313535623664623165316565313230636132386630313964313832663034393430623735376562656162227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936343731323031227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31343634397d2c227769746864726177616c73223a5b5d7d2c226964223a2236393736616465643536636261386332326464363132393566653030346136643036316234613266353839643566353636333335656263303533323738613832222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223361313638393765323639656231383930373865326565636264373732326330366462376430666562303235313062303839323231636638623631646564323363346433343263333961613466383838643766316630366464303163373430383663303235623133636238303961353231366262383563366162353665643032225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c226236363930653734313435336536616533323632366234323635356639633837326263663137613735643662353261633539636531313635663534333261666565613739343731356166306532316334663566383934366463393761376461653363383439373363396662306636383336326138326463366334633161353032225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313737333337227d2c22686561646572223a7b22626c6f636b4e6f223a313431312c2268617368223a2236653739363761346663383131343032633138633564323966633039366566633537633862363636366635313237343430623736636162346261326264646633222c22736c6f74223a31333231317d2c22697373756572566b223a2237396666356564306564643564323435626661623963336263343535666661336438366637323732353430303464663031343438356235386263626235613036222c2270726576696f7573426c6f636b223a2237323935633932333561353965313764613163383730613935346237333436393236356365356334636165623838363638346463363465666337356563663439222c2273697a65223a3439362c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939343731323031227d2c227478436f756e74223a312c22767266223a227672665f766b3172663638773234343467327879677975656777767a7961333033766371776a6e7a68386435353337336b7a336672677034306571337361667a38227d
1412	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313431322c2268617368223a2263366638633061653965333635663433656338613664303937383964383764383764663964373865343130326664383463633433306166653831656261636431222c22736c6f74223a31333232367d2c22697373756572566b223a2264323538333438333264646463616364383634373232326237653231376533353263396539643239346565316638366264663138666264613534306631316630222c2270726576696f7573426c6f636b223a2236653739363761346663383131343032633138633564323966633039366566633537633862363636366635313237343430623736636162346261326264646633222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317632386464636b363475756c667334797877777675777430646d7278716a393479637a347367663468383737737a3833716d3573336c6b7a6c71227d
1413	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313431332c2268617368223a2264323735646135316233353338663937346235383638303030323562383231656539656435626332313033316562333563653133646362353839363031346337222c22736c6f74223a31333233307d2c22697373756572566b223a2266336561653865623466363633663735653538666363383233343937386233653563396664396466353865356332636231383537373736326539333664373563222c2270726576696f7573426c6f636b223a2263366638633061653965333635663433656338613664303937383964383764383764663964373865343130326664383463633433306166653831656261636431222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316739643938336b7839683366683975353373386b306d326c646a736538776d6a6e647061356a7878746a6e743832737573366d71657735326b37227d
1414	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313431342c2268617368223a2262623663633937383064306339313033663664393032393438316364616436633731313337356330383164343531653731646134396537636534306331663966222c22736c6f74223a31333233317d2c22697373756572566b223a2264323538333438333264646463616364383634373232326237653231376533353263396539643239346565316638366264663138666264613534306631316630222c2270726576696f7573426c6f636b223a2264323735646135316233353338663937346235383638303030323562383231656539656435626332313033316562333563653133646362353839363031346337222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317632386464636b363475756c667334797877777675777430646d7278716a393479637a347367663468383737737a3833716d3573336c6b7a6c71227d
1415	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313431352c2268617368223a2264306239633239326561653139633236376363626563303562343333646632626636633662393039373836383237623239373265343731363166646130656135222c22736c6f74223a31333233327d2c22697373756572566b223a2239333666663733346533313332303632633539636538646335333662663062376235363662313163356362653863633761613036356634366436343235383834222c2270726576696f7573426c6f636b223a2262623663633937383064306339313033663664393032393438316364616436633731313337356330383164343531653731646134396537636534306331663966222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a66327838707567343670797672746563676a716a6b356b306b30636b716c33386a71346b68766d6d7375716e6c61646b6d6b73647a6b727535227d
\.


--
-- Data for Name: current_pool_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_pool_metrics (stake_pool_id, slot, minted_blocks, live_delegators, active_stake, live_stake, live_pledge, live_saturation, active_size, live_size, apy) FROM stdin;
pool1ytd8qtrxualya7fnswtzhlcrujf33h2stdpdn42ampayxtc48xk	9419	91	2	3696476781009607	3696476781009607	300000000	4.500045339827777	1	0	0
pool10642kanghvyd0w8v2vlrayu46gzjrpjqc3ssvwg2y574v9407ql	9419	89	2	3715709382596433	3721371590738031	500000000	4.530351974805122	0.9984784620391872	0.00152153796081278	0
pool1ttj08sty3hrvla5xeqh99g5te7zld72a3h6v7ljjsc75k90zsep	9419	96	2	3728682222420318	3734329008988752	5541509517418	4.546126176313682	0.9984878711664554	0.0015121288335445682	0
pool1xpr9yrnkxvvlaxm3c0epda03cqqzfxp2h7ul0mtvg9zqsz4upzs	9419	96	2	3724515237546124	3731418198899690	5743166460432	4.542582591935254	0.9981500434993854	0.0018499565006145913	0
pool1vx35knryxxtndndlyd6d2zpd8pn60pculy8r5mf9n6j4k6rne5g	9419	100	2	3703559333157900	3703559333157900	200558082	4.508667551646542	1	0	0
pool1zycsff54pretcc5avly6yq4yr5g5jcxwx4qa9c76m9f7s3d0qet	9419	92	2	3730429152496573	3737950370189577	6203813242322	4.550534776870657	0.9979878765237264	0.002012123476273553	0
pool1050c4ea4xvpq3kkzv0rfmxxsh54pz025q99fd24ejxuqv9954hz	9419	109	3	3737228612346872	3746631623945091	6225203090693	4.561103228350473	0.9974902759219445	0.0025097240780554975	0
pool1879x8xzp4r0dw577u9znvd7j9lysslmqmzngh3dljfdzqrvpxgj	9419	100	2	3727606132273868	3737021964941733	6080022767551	4.549404547748025	0.9974803914035834	0.002519608596416645	0
pool103n9pwvgzlve22xmghl2nw5x2gx8fz5nydm4f9z85k5zxe348sq	9419	92	8	3727137166888526	3732161416248071	4450282799149	4.54348737558823	0.9986537963396568	0.0013462036603432148	0
pool1numk9zer8gln0jgavcrd28peg34jjwfp7wwccy2yd6vd7nsafgc	9419	53	2	0	3692299791494098	300000000	4.494960324198748	0	1	0
pool1jwlssult0t7hmp7wjvs7dg9nxgtlsewuxfz0x7wy3pcewh4wkr5	9419	83	2	0	3738290309184963	500000000	4.5509486144199345	0	1	0
\.


--
-- Data for Name: pool_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata (id, ticker, name, description, homepage, hash, ext, stake_pool_id, pool_update_id) FROM stdin;
1	SP1	stake pool - 1	This is the stake pool 1 description.	https://stakepool1.com	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	\N	pool1ttj08sty3hrvla5xeqh99g5te7zld72a3h6v7ljjsc75k90zsep	740000000000
2	SP3	Stake Pool - 3	This is the stake pool 3 description.	https://stakepool3.com	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	\N	pool1vx35knryxxtndndlyd6d2zpd8pn60pculy8r5mf9n6j4k6rne5g	2140000000000
3	SP4	Same Name	This is the stake pool 4 description.	https://stakepool4.com	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	\N	pool1zycsff54pretcc5avly6yq4yr5g5jcxwx4qa9c76m9f7s3d0qet	3100000000000
4	SP5	Same Name	This is the stake pool 5 description.	https://stakepool5.com	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	\N	pool1050c4ea4xvpq3kkzv0rfmxxsh54pz025q99fd24ejxuqv9954hz	3650000000000
5	SP6a7	Stake Pool - 6	This is the stake pool 6 description.	https://stakepool6.com	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	\N	pool1879x8xzp4r0dw577u9znvd7j9lysslmqmzngh3dljfdzqrvpxgj	4490000000000
6	SP6a7		This is the stake pool 7 description.	https://stakepool7.com	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	\N	pool103n9pwvgzlve22xmghl2nw5x2gx8fz5nydm4f9z85k5zxe348sq	5690000000000
7	SP10	Stake Pool - 10	This is the stake pool 10 description.	https://stakepool10.com	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	\N	pool1jwlssult0t7hmp7wjvs7dg9nxgtlsewuxfz0x7wy3pcewh4wkr5	8990000000000
8	SP11	Stake Pool - 10 + 1	This is the stake pool 11 description.	https://stakepool11.com	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	\N	pool10642kanghvyd0w8v2vlrayu46gzjrpjqc3ssvwg2y574v9407ql	10710000000000
\.


--
-- Data for Name: pool_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_registration (id, reward_account, pledge, cost, margin, margin_percent, relays, owners, vrf, metadata_url, metadata_hash, stake_pool_id, block_slot) FROM stdin;
740000000000	stake_test1uz5449a5mmwwdlte0rmy6eler6d4feumfgrgs7lfeah9n4ga8vp4u	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3001, "__typename": "RelayByAddress"}]	["stake_test1uz5449a5mmwwdlte0rmy6eler6d4feumfgrgs7lfeah9n4ga8vp4u"]	b47b54d3e33698b978a34b9ef844c0c137b074a11ca4314fdd6af3e16ec82c29	http://file-server/SP1.json	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	pool1ttj08sty3hrvla5xeqh99g5te7zld72a3h6v7ljjsc75k90zsep	74
1550000000000	stake_test1uz52lvhh3vl4qhhz9jj2p0vl4a6cc53jhpdp5p6p3l3d77sllu2zv	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3002, "__typename": "RelayByAddress"}]	["stake_test1uz52lvhh3vl4qhhz9jj2p0vl4a6cc53jhpdp5p6p3l3d77sllu2zv"]	9f201da836a2bb498037ea76f824c2c43ab0643b97ea3c22e7125410989f8eec	\N	\N	pool1xpr9yrnkxvvlaxm3c0epda03cqqzfxp2h7ul0mtvg9zqsz4upzs	155
2140000000000	stake_test1uzacfn4mvh3kzfx5z2tnf2jw8jxu0gudh7qh94p0gz6srgcps4rhf	600000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3003, "__typename": "RelayByAddress"}]	["stake_test1uzacfn4mvh3kzfx5z2tnf2jw8jxu0gudh7qh94p0gz6srgcps4rhf"]	f12baebfc68a52ef373942578a4543f5fbc21a5ef237980c751ff1ab26d5805d	http://file-server/SP3.json	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	pool1vx35knryxxtndndlyd6d2zpd8pn60pculy8r5mf9n6j4k6rne5g	214
3100000000000	stake_test1upv43gw0rj9l3e0j524qpj70gr400v6d20j4zqxrk3j488svdjdas	420000000	370000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3004, "__typename": "RelayByAddress"}]	["stake_test1upv43gw0rj9l3e0j524qpj70gr400v6d20j4zqxrk3j488svdjdas"]	b09acb5ac2e0d1f05f4cae8a8cd4676fc609433442ae1845372793702892f1ea	http://file-server/SP4.json	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	pool1zycsff54pretcc5avly6yq4yr5g5jcxwx4qa9c76m9f7s3d0qet	310
3650000000000	stake_test1uphhffk0mym5y33jzqmh0lkwy85u9e362zm0al7ufzwtycculfmdg	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3005, "__typename": "RelayByAddress"}]	["stake_test1uphhffk0mym5y33jzqmh0lkwy85u9e362zm0al7ufzwtycculfmdg"]	de0875b7f2134602034f5cace7a82e47dcd3521c9fcccd3bf8cc55f8ac99c040	http://file-server/SP5.json	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	pool1050c4ea4xvpq3kkzv0rfmxxsh54pz025q99fd24ejxuqv9954hz	365
4490000000000	stake_test1upnlps2guf0kt8vwhu7y8q9xtunnauru0xf9uy76ddahdsgptwx05	410000000	400000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3006, "__typename": "RelayByAddress"}]	["stake_test1upnlps2guf0kt8vwhu7y8q9xtunnauru0xf9uy76ddahdsgptwx05"]	f4d3baa6a7aa18158f6d2528e8ac4b6d057ccd1e1a273ea8d90ba7a5b634e7f3	http://file-server/SP6.json	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	pool1879x8xzp4r0dw577u9znvd7j9lysslmqmzngh3dljfdzqrvpxgj	449
5690000000000	stake_test1upgldca8uk4at3lulknl638t2antcte20yt5sgerz2j6n9g8zdgg5	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3007, "__typename": "RelayByAddress"}]	["stake_test1upgldca8uk4at3lulknl638t2antcte20yt5sgerz2j6n9g8zdgg5"]	513ab726ebc3b22eff65c58fcbcca824e09485edffb05f93b6802b50df6c512c	http://file-server/SP7.json	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	pool103n9pwvgzlve22xmghl2nw5x2gx8fz5nydm4f9z85k5zxe348sq	569
6610000000000	stake_test1upjhk7nr78ywy3mm5ar3pzcd4hfvsq3r3jgk4gnj7kncnpqu05557	500000000	380000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3008, "__typename": "RelayByAddress"}]	["stake_test1upjhk7nr78ywy3mm5ar3pzcd4hfvsq3r3jgk4gnj7kncnpqu05557"]	521ac09e9488ded6394bd4520ba62532d9b6031b415cafce6667ef4e3c0890f6	\N	\N	pool1numk9zer8gln0jgavcrd28peg34jjwfp7wwccy2yd6vd7nsafgc	661
7820000000000	stake_test1urq8zrjssn9ljl3pmydkaqasfcgvnc89jjk440p4j60gqqql5w77j	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3009, "__typename": "RelayByAddress"}]	["stake_test1urq8zrjssn9ljl3pmydkaqasfcgvnc89jjk440p4j60gqqql5w77j"]	3218ce946a17a1bd0e8e52499d80b232fe7f8d81c5bf3592faaad05bc1c901ba	\N	\N	pool1ytd8qtrxualya7fnswtzhlcrujf33h2stdpdn42ampayxtc48xk	782
8990000000000	stake_test1uz5ndq86eqc3wxn4yvzdu0e6cs0j48h5t4qd79k5h544q7q7f3vyg	400000000	410000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30010, "__typename": "RelayByAddress"}]	["stake_test1uz5ndq86eqc3wxn4yvzdu0e6cs0j48h5t4qd79k5h544q7q7f3vyg"]	db7ea24c9fd88407345dce6054e42a9c4b895bcc9f9e4cc42f532b8bbca713d9	http://file-server/SP10.json	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	pool1jwlssult0t7hmp7wjvs7dg9nxgtlsewuxfz0x7wy3pcewh4wkr5	899
10710000000000	stake_test1uz2vmhq5pvdl5nyn7w2x2764e7avzp8twllcrm78f8hegdq4d57nj	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30011, "__typename": "RelayByAddress"}]	["stake_test1uz2vmhq5pvdl5nyn7w2x2764e7avzp8twllcrm78f8hegdq4d57nj"]	7cf598bb7226be677689888549fbc464907f14772bee6979279712f69bde9902	http://file-server/SP11.json	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	pool10642kanghvyd0w8v2vlrayu46gzjrpjqc3ssvwg2y574v9407ql	1071
131350000000000	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	500000000000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.1", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys"]	2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	\N	\N	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	13135
132350000000000	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	50000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.2", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v"]	641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	\N	\N	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	13235
\.


--
-- Data for Name: pool_retirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retirement (id, retire_at_epoch, stake_pool_id, block_slot) FROM stdin;
7130000000000	5	pool1numk9zer8gln0jgavcrd28peg34jjwfp7wwccy2yd6vd7nsafgc	713
7990000000000	18	pool1ytd8qtrxualya7fnswtzhlcrujf33h2stdpdn42ampayxtc48xk	799
9380000000000	5	pool1jwlssult0t7hmp7wjvs7dg9nxgtlsewuxfz0x7wy3pcewh4wkr5	938
10920000000000	18	pool10642kanghvyd0w8v2vlrayu46gzjrpjqc3ssvwg2y574v9407ql	1092
\.


--
-- Data for Name: stake_pool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_pool (id, status, last_registration_id, last_retirement_id) FROM stdin;
pool1ytd8qtrxualya7fnswtzhlcrujf33h2stdpdn42ampayxtc48xk	retiring	7820000000000	7990000000000
pool10642kanghvyd0w8v2vlrayu46gzjrpjqc3ssvwg2y574v9407ql	retiring	10710000000000	10920000000000
pool1ttj08sty3hrvla5xeqh99g5te7zld72a3h6v7ljjsc75k90zsep	active	740000000000	\N
pool1xpr9yrnkxvvlaxm3c0epda03cqqzfxp2h7ul0mtvg9zqsz4upzs	active	1550000000000	\N
pool1vx35knryxxtndndlyd6d2zpd8pn60pculy8r5mf9n6j4k6rne5g	active	2140000000000	\N
pool1zycsff54pretcc5avly6yq4yr5g5jcxwx4qa9c76m9f7s3d0qet	active	3100000000000	\N
pool1050c4ea4xvpq3kkzv0rfmxxsh54pz025q99fd24ejxuqv9954hz	active	3650000000000	\N
pool1879x8xzp4r0dw577u9znvd7j9lysslmqmzngh3dljfdzqrvpxgj	active	4490000000000	\N
pool103n9pwvgzlve22xmghl2nw5x2gx8fz5nydm4f9z85k5zxe348sq	active	5690000000000	\N
pool1numk9zer8gln0jgavcrd28peg34jjwfp7wwccy2yd6vd7nsafgc	retired	6610000000000	7130000000000
pool1jwlssult0t7hmp7wjvs7dg9nxgtlsewuxfz0x7wy3pcewh4wkr5	retired	8990000000000	9380000000000
pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	activating	131350000000000	\N
pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	activating	132350000000000	\N
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

