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
    pledge bigint NOT NULL,
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
5c596a20-5fbb-4c93-9907-9864540b51ca	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-11-22 21:25:00.192516+00	2023-11-22 21:25:00.196638+00	__pgboss__maintenance	\N	00:15:00	2023-11-22 21:25:00.192516+00	2023-11-22 21:25:00.20755+00	2023-11-22 21:33:00.192516+00	f	\N	\N
a8d87299-b34a-4e7b-bc4e-09f0478cf898	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:38:01.253806+00	2023-11-22 21:38:04.264284+00	\N	2023-11-22 21:38:00	00:15:00	2023-11-22 21:37:04.253806+00	2023-11-22 21:38:04.271224+00	2023-11-22 21:39:01.253806+00	f	\N	\N
92475159-299f-43ae-85ec-b3ed4f565f87	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-11-22 21:39:35.932108+00	2023-11-22 21:40:35.929832+00	__pgboss__maintenance	\N	00:15:00	2023-11-22 21:37:35.932108+00	2023-11-22 21:40:35.938187+00	2023-11-22 21:47:35.932108+00	f	\N	\N
191b794f-b57a-4860-a0cd-dc7c9493711d	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:41:01.323865+00	2023-11-22 21:41:04.339449+00	\N	2023-11-22 21:41:00	00:15:00	2023-11-22 21:40:04.323865+00	2023-11-22 21:41:04.352703+00	2023-11-22 21:42:01.323865+00	f	\N	\N
7e9ccabe-cbb7-4ae0-8681-51519aada3ff	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-11-22 21:25:35.906513+00	2023-11-22 21:25:35.918456+00	__pgboss__maintenance	\N	00:15:00	2023-11-22 21:25:35.906513+00	2023-11-22 21:25:35.92938+00	2023-11-22 21:33:35.906513+00	f	\N	\N
ed961a14-1629-4a25-b902-e0a8a23c5d5a	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:25:00.202343+00	2023-11-22 21:25:35.923598+00	\N	2023-11-22 21:25:00	00:15:00	2023-11-22 21:25:00.202343+00	2023-11-22 21:25:35.93016+00	2023-11-22 21:26:00.202343+00	f	\N	\N
c6076127-02aa-4e6f-9dbc-a34673e6ca4d	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:36:01.194137+00	2023-11-22 21:36:04.216118+00	\N	2023-11-22 21:36:00	00:15:00	2023-11-22 21:35:04.194137+00	2023-11-22 21:36:04.222793+00	2023-11-22 21:37:01.194137+00	f	\N	\N
8c6a1085-1686-412c-b66c-a109132ad606	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:40:01.300351+00	2023-11-22 21:40:04.312342+00	\N	2023-11-22 21:40:00	00:15:00	2023-11-22 21:39:04.300351+00	2023-11-22 21:40:04.325631+00	2023-11-22 21:41:01.300351+00	f	\N	\N
c182ad96-3281-4bf8-8037-d95b8c069d50	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:37:01.220993+00	2023-11-22 21:37:04.241127+00	\N	2023-11-22 21:37:00	00:15:00	2023-11-22 21:36:04.220993+00	2023-11-22 21:37:04.255647+00	2023-11-22 21:38:01.220993+00	f	\N	\N
dae8141f-b7f5-425e-b13a-e6418d3f8790	pool-metadata	0	{"poolId": "pool1aud3ck37ev3uwhfcdas54xdnjpvtrtndgcjrffgsx5grvl28fvv", "metadataJson": {"url": "http://file-server/SP3.json", "hash": "6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25"}, "poolRegistrationId": "4210000000000"}	completed	1000000	0	21600	f	2023-11-22 21:25:00.446622+00	2023-11-22 21:25:35.937489+00	\N	\N	00:15:00	2023-11-22 21:25:00.446622+00	2023-11-22 21:25:35.995198+00	2023-12-06 21:25:00.446622+00	f	\N	421
d19b0a6e-98ca-43cb-b70f-0953437b8959	pool-metadata	0	{"poolId": "pool1d3ez0uq0rzv9ly8eslwa422sacktx9gs0mh5fgncmupxwgvkf77", "metadataJson": {"url": "http://file-server/SP4.json", "hash": "09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d"}, "poolRegistrationId": "4960000000000"}	completed	1000000	0	21600	f	2023-11-22 21:25:00.487491+00	2023-11-22 21:25:35.937489+00	\N	\N	00:15:00	2023-11-22 21:25:00.487491+00	2023-11-22 21:25:35.995772+00	2023-12-06 21:25:00.487491+00	f	\N	496
3386decb-92c4-4a70-b8e6-a86bfd6a1e82	pool-metadata	0	{"poolId": "pool1ek6nwzlv07edrw8qa9q88sxj0628dxxml3pa7tvhm4hm7ql4an4", "metadataJson": {"url": "http://file-server/SP1.json", "hash": "14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7"}, "poolRegistrationId": "2010000000000"}	completed	1000000	0	21600	f	2023-11-22 21:25:00.362268+00	2023-11-22 21:25:35.937489+00	\N	\N	00:15:00	2023-11-22 21:25:00.362268+00	2023-11-22 21:25:35.997929+00	2023-12-06 21:25:00.362268+00	f	\N	201
12b0addb-2c9e-442d-9049-064f7077ff3e	pool-metadata	0	{"poolId": "pool14c8nwn4a4fnpvcs9a84f25w07vsenyxgys6ejznjfdhcqn2xrku", "metadataJson": {"url": "http://file-server/SP5.json", "hash": "0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501"}, "poolRegistrationId": "6150000000000"}	completed	1000000	0	21600	f	2023-11-22 21:25:00.520034+00	2023-11-22 21:25:35.937489+00	\N	\N	00:15:00	2023-11-22 21:25:00.520034+00	2023-11-22 21:25:36.008723+00	2023-12-06 21:25:00.520034+00	f	\N	615
0c375aa0-97cc-4a4f-87c7-c0bac12cd5bd	pool-metadata	0	{"poolId": "pool1wze6trs6ncux27gc0d3cgmelwvq0c5m2j6aryd0r8vulkavsdqj", "metadataJson": {"url": "http://file-server/SP6.json", "hash": "3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba"}, "poolRegistrationId": "6660000000000"}	completed	1000000	0	21600	f	2023-11-22 21:25:00.548646+00	2023-11-22 21:25:35.937489+00	\N	\N	00:15:00	2023-11-22 21:25:00.548646+00	2023-11-22 21:25:36.009399+00	2023-12-06 21:25:00.548646+00	f	\N	666
e1fdfabf-eb23-4af5-986a-502d9de60103	pool-rewards	0	{"epochNo": 0}	completed	1000000	0	30	f	2023-11-22 21:25:00.680345+00	2023-11-22 21:25:35.944756+00	0	\N	00:15:00	2023-11-22 21:25:00.680345+00	2023-11-22 21:25:36.09135+00	2023-12-06 21:25:00.680345+00	f	\N	1018
a04f715e-ba19-430d-b617-6d4b0a480f1f	pool-metrics	0	{"slot": 1592}	completed	0	0	0	f	2023-11-22 21:25:00.830558+00	2023-11-22 21:25:35.937609+00	\N	\N	00:15:00	2023-11-22 21:25:00.830558+00	2023-11-22 21:25:36.243655+00	2023-12-06 21:25:00.830558+00	f	\N	1592
10486bac-6e6a-45de-bcf0-f241c2986132	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:26:01.930912+00	2023-11-22 21:26:03.934651+00	\N	2023-11-22 21:26:00	00:15:00	2023-11-22 21:25:35.930912+00	2023-11-22 21:26:03.950935+00	2023-11-22 21:27:01.930912+00	f	\N	\N
3455af4e-a2c7-4b40-9ef2-1474a448aa19	pool-rewards	0	{"epochNo": 7}	retry	1000000	15	30	f	2023-11-22 21:42:44.418135+00	2023-11-22 21:42:14.414656+00	7	\N	00:15:00	2023-11-22 21:34:42.41627+00	\N	2023-12-06 21:34:42.41627+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	4502
c5d6eb70-6fd3-404c-90cc-eb21f43581ae	pool-rewards	0	{"epochNo": 1}	completed	1000000	1	30	f	2023-11-22 21:26:05.973546+00	2023-11-22 21:26:07.949989+00	1	\N	00:15:00	2023-11-22 21:25:00.809594+00	2023-11-22 21:26:08.079046+00	2023-12-06 21:25:00.809594+00	f	\N	1510
9047ab28-4e4e-42a1-8d8f-4360455ed2e3	pool-rewards	0	{"epochNo": 11}	retry	1000000	2	30	f	2023-11-22 21:42:52.419787+00	2023-11-22 21:42:22.416842+00	11	\N	00:15:00	2023-11-22 21:41:22.208227+00	\N	2023-12-06 21:41:22.208227+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	6501
8af6a204-af67-4a5d-8b54-f51b2280a0b6	pool-rewards	0	{"epochNo": 2}	completed	1000000	0	30	f	2023-11-22 21:26:23.018433+00	2023-11-22 21:26:23.955473+00	2	\N	00:15:00	2023-11-22 21:26:23.018433+00	2023-11-22 21:26:24.090388+00	2023-12-06 21:26:23.018433+00	f	\N	2005
185b9a01-6a47-451f-bbab-85203cc155ad	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-11-22 21:27:35.932222+00	2023-11-22 21:28:35.921055+00	__pgboss__maintenance	\N	00:15:00	2023-11-22 21:25:35.932222+00	2023-11-22 21:28:35.928301+00	2023-11-22 21:35:35.932222+00	f	\N	\N
e32f4c9c-76d7-47e8-823c-b1989b9fbd18	pool-metadata	0	{"poolId": "pool1mynp3e6hqdjpv53r2y4nwnk4j2pkvpzlykfakkduywyuw789dfy", "metadataJson": {"url": "http://file-server/SP7.json", "hash": "c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405"}, "poolRegistrationId": "7660000000000"}	completed	1000000	0	21600	f	2023-11-22 21:25:00.597633+00	2023-11-22 21:25:35.937489+00	\N	\N	00:15:00	2023-11-22 21:25:00.597633+00	2023-11-22 21:25:36.00665+00	2023-12-06 21:25:00.597633+00	f	\N	766
d72dc527-4fe5-48a5-a3e6-b97182d5efd2	pool-metadata	0	{"poolId": "pool1ynrrvvf6l6z6tg7ff97vvjv8aea40qe9ksjay4urn0hssj95pgk", "metadataJson": {"url": "http://file-server/SP11.json", "hash": "4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9"}, "poolRegistrationId": "12980000000000"}	completed	1000000	0	21600	f	2023-11-22 21:25:00.754559+00	2023-11-22 21:25:35.937489+00	\N	\N	00:15:00	2023-11-22 21:25:00.754559+00	2023-11-22 21:25:36.010326+00	2023-12-06 21:25:00.754559+00	f	\N	1298
283b3d30-6403-4194-9d30-61306d8f15b8	pool-metadata	0	{"poolId": "pool14ps29vpdqmnfvzfru80zwq503pymfhvjcrcu259j4jpr70susa4", "metadataJson": {"url": "http://file-server/SP10.json", "hash": "c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd"}, "poolRegistrationId": "11580000000000"}	completed	1000000	0	21600	f	2023-11-22 21:25:00.711401+00	2023-11-22 21:25:35.937489+00	\N	\N	00:15:00	2023-11-22 21:25:00.711401+00	2023-11-22 21:25:36.009883+00	2023-12-06 21:25:00.711401+00	f	\N	1158
b43bce89-298e-4f09-b681-94f7ed75dcf8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-11-22 21:36:35.934895+00	2023-11-22 21:37:35.925286+00	__pgboss__maintenance	\N	00:15:00	2023-11-22 21:34:35.934895+00	2023-11-22 21:37:35.930401+00	2023-11-22 21:44:35.934895+00	f	\N	\N
ce296a48-7497-4dd4-a801-61f81f1cd2dd	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:27:01.948409+00	2023-11-22 21:27:03.957883+00	\N	2023-11-22 21:27:00	00:15:00	2023-11-22 21:26:03.948409+00	2023-11-22 21:27:03.965117+00	2023-11-22 21:28:01.948409+00	f	\N	\N
27af5fdc-f6b6-455a-8175-b04673b3ad57	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:33:01.114806+00	2023-11-22 21:33:04.133216+00	\N	2023-11-22 21:33:00	00:15:00	2023-11-22 21:32:04.114806+00	2023-11-22 21:33:04.139734+00	2023-11-22 21:34:01.114806+00	f	\N	\N
2b5f56ed-264e-4971-8c69-5aa2eb1c4a90	__pgboss__maintenance	0	\N	created	0	0	0	f	2023-11-22 21:42:35.940685+00	\N	__pgboss__maintenance	\N	00:15:00	2023-11-22 21:40:35.940685+00	\N	2023-11-22 21:50:35.940685+00	f	\N	\N
08b04a20-c433-4504-a24d-09fe1c844b18	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:28:01.962976+00	2023-11-22 21:28:03.987325+00	\N	2023-11-22 21:28:00	00:15:00	2023-11-22 21:27:03.962976+00	2023-11-22 21:28:03.994354+00	2023-11-22 21:29:01.962976+00	f	\N	\N
02726d5c-07e4-4e88-a30c-77f2af9f17c8	pool-rewards	0	{"epochNo": 3}	completed	1000000	0	30	f	2023-11-22 21:28:02.407989+00	2023-11-22 21:28:04.011846+00	3	\N	00:15:00	2023-11-22 21:28:02.407989+00	2023-11-22 21:28:04.181003+00	2023-12-06 21:28:02.407989+00	f	\N	2502
7d7e0b34-7126-48ee-b44d-3aea3e92897c	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:29:01.992521+00	2023-11-22 21:29:04.014681+00	\N	2023-11-22 21:29:00	00:15:00	2023-11-22 21:28:03.992521+00	2023-11-22 21:29:04.023097+00	2023-11-22 21:30:01.992521+00	f	\N	\N
5cc60206-0aaf-4357-ae7d-2db03acdfdf2	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:34:01.138086+00	2023-11-22 21:34:04.163156+00	\N	2023-11-22 21:34:00	00:15:00	2023-11-22 21:33:04.138086+00	2023-11-22 21:34:04.180056+00	2023-11-22 21:35:01.138086+00	f	\N	\N
fea5fed2-6a28-4fc2-b52b-04c92a612e58	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:30:01.020425+00	2023-11-22 21:30:04.044326+00	\N	2023-11-22 21:30:00	00:15:00	2023-11-22 21:29:04.020425+00	2023-11-22 21:30:04.059+00	2023-11-22 21:31:01.020425+00	f	\N	\N
45b05dee-d1f2-4ff6-bed9-1ba5a5886f6c	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:31:01.056992+00	2023-11-22 21:31:04.070315+00	\N	2023-11-22 21:31:00	00:15:00	2023-11-22 21:30:04.056992+00	2023-11-22 21:31:04.083659+00	2023-11-22 21:32:01.056992+00	f	\N	\N
185be79d-ce21-43e2-896d-d94efc3912d1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-11-22 21:33:35.93896+00	2023-11-22 21:34:35.924382+00	__pgboss__maintenance	\N	00:15:00	2023-11-22 21:31:35.93896+00	2023-11-22 21:34:35.932603+00	2023-11-22 21:41:35.93896+00	f	\N	\N
ea4e7e17-396b-4c8f-8663-2d2e68456317	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-11-22 21:30:35.931213+00	2023-11-22 21:31:35.922436+00	__pgboss__maintenance	\N	00:15:00	2023-11-22 21:28:35.931213+00	2023-11-22 21:31:35.936969+00	2023-11-22 21:38:35.931213+00	f	\N	\N
b5899971-02a6-43ac-89d3-7c686344cf54	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:35:01.177435+00	2023-11-22 21:35:04.189737+00	\N	2023-11-22 21:35:00	00:15:00	2023-11-22 21:34:04.177435+00	2023-11-22 21:35:04.195842+00	2023-11-22 21:36:01.177435+00	f	\N	\N
33851284-18cb-48da-9358-07732495f6c9	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:32:01.082015+00	2023-11-22 21:32:04.102998+00	\N	2023-11-22 21:32:00	00:15:00	2023-11-22 21:31:04.082015+00	2023-11-22 21:32:04.116511+00	2023-11-22 21:33:01.082015+00	f	\N	\N
d9154e4c-2462-4c15-b51d-a7dfd7e09a52	__pgboss__cron	0	\N	created	2	0	0	f	2023-11-22 21:43:01.371166+00	\N	\N	2023-11-22 21:43:00	00:15:00	2023-11-22 21:42:04.371166+00	\N	2023-11-22 21:44:01.371166+00	f	\N	\N
b014f662-c59f-44da-9cda-58c182789bf0	pool-rewards	0	{"epochNo": 10}	retry	1000000	5	30	f	2023-11-22 21:42:44.418484+00	2023-11-22 21:42:14.414656+00	10	\N	00:15:00	2023-11-22 21:39:43.610427+00	\N	2023-12-06 21:39:43.610427+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	6008
12348a88-3996-42eb-a076-8b324e9e7bc8	pool-rewards	0	{"epochNo": 5}	retry	1000000	22	30	f	2023-11-22 21:42:56.42101+00	2023-11-22 21:42:26.417662+00	5	\N	00:15:00	2023-11-22 21:31:25.417273+00	\N	2023-12-06 21:31:25.417273+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	3517
4899fa44-cecb-493e-bd64-43bbf108742b	pool-rewards	0	{"epochNo": 9}	retry	1000000	9	30	f	2023-11-22 21:43:04.427435+00	2023-11-22 21:42:34.421123+00	9	\N	00:15:00	2023-11-22 21:38:03.416322+00	\N	2023-12-06 21:38:03.416322+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	5507
8344f482-d833-4247-9f70-9feaf46d58e3	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:39:01.269147+00	2023-11-22 21:39:04.288343+00	\N	2023-11-22 21:39:00	00:15:00	2023-11-22 21:38:04.269147+00	2023-11-22 21:39:04.30206+00	2023-11-22 21:40:01.269147+00	f	\N	\N
0110881e-5582-49e5-bcec-6a7ed5bb6953	__pgboss__cron	0	\N	completed	2	0	0	f	2023-11-22 21:42:01.351102+00	2023-11-22 21:42:04.365257+00	\N	2023-11-22 21:42:00	00:15:00	2023-11-22 21:41:04.351102+00	2023-11-22 21:42:04.372906+00	2023-11-22 21:43:01.351102+00	f	\N	\N
427aeeb5-1b2d-4808-85b8-50d4db7326a7	pool-rewards	0	{"epochNo": 8}	retry	1000000	12	30	f	2023-11-22 21:42:56.420668+00	2023-11-22 21:42:26.417662+00	8	\N	00:15:00	2023-11-22 21:36:23.018468+00	\N	2023-12-06 21:36:23.018468+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	5005
659f0860-338a-47b4-8450-8b5f55461891	pool-rewards	0	{"epochNo": 6}	retry	1000000	19	30	f	2023-11-22 21:43:04.427759+00	2023-11-22 21:42:34.421123+00	6	\N	00:15:00	2023-11-22 21:33:03.009837+00	\N	2023-12-06 21:33:03.009837+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	4005
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
20	2023-11-22 21:40:35.936294+00	2023-11-22 21:42:04.36892+00
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (height, hash, slot) FROM stdin;
0	3910388138d2c6d36ccf02e807277120dc3bc6f47b4999d5b2684ec068836666	3
1	8931aca3013400a3f3d535ef8dc6543917985300ce00168553c97a0e696f7ff2	9
2	82b9e467b0c1d3afa9b18eb52253d337caa29fc5aa0381417ffb3407cf29b6fd	11
3	fe6884ed223951cf95a328d814b1e16789b7695b179c5fdf57a174e2c93ec7b8	14
4	53e297ce07e72e16e808a7dce7f3d78ef23745f3f42e14edfd55ac46cffc1004	18
5	f4ec6f311b8487f97742fcaf0e6b2e7f18371b66773446cfbe55e64201337cd8	29
6	0c76a57c6e8fab45fd6691cff5801c52f0a78dbf07867da14020b72f8c42f96f	33
7	e7ae552c5ada33d7c1e51b4c5070dac556ced4e859a750f54b25e6be5cb725b0	54
8	0a2116309c6f970ce73798b94306106009e37e62d292aac53491cbc35707f957	65
9	2773f862ab86052116820d8f9c418b3139a9c704b62879193b83085176a46b8b	78
10	d6eee17e24be38e038afab2d1ca34d2a291712da608cf8e707ed9fa38694bb44	101
11	9730622ba36ec37c3ffe5f4458a04c293777c067c34b02a65ac98221bd948bdc	102
12	dc6b8525f1c9e2df72db050e867a69f96c0ed6a2a4b230a067a9a483c5558932	112
13	6cb33ef1c39861fdabef1e66576af5b7c2acd0f6946d72ea7f39915c9d8fe01b	136
14	a073b033dc806e54a27d9127686f96667061751d200757c04c397e7f9998ac3f	142
15	4e2a53dc2811ce5d0871c3673467ac9feef0567c1208029cbade58ad586090a7	143
16	06a488c413a112ee5c91bf9ac68bf2350bccffd037709fd484abaf1905cd81f9	160
17	ffc1d11cc28552b7aa37bd163eaac608bb5c258261771e6ab46c38bea33fc220	170
18	b7768045b6ea65704d549ced02f496eeba5c4c900f29b0aba9f8adaa8a60b5e6	173
19	bf85ccb8fdea004624e2510b489aef35831848eb6f59554520a27f6edeab276a	189
20	517fe323b78d67277c51816a7a909a89732f9e6f72c05a5a5ae9964db2b5840a	190
21	8d09401ef66a3ca274fda5144d399620fd5abd0982cf02e34fe373470c1e8092	196
22	2e9b753b743970406341f3a473ef21e002c436c4ce416a44bb1fa7e9019e8449	201
23	bc51ed902e9c1f03cd6f95baaeac7618bf23094fa6b79883ffde04bf203adf16	209
24	e35c6c5fd5f89bc446b77ad8a0101c3d42dc45aed82507347eef157a06f9c873	215
25	176aba747c3944a68ab50184ca4d6bddf9d31e2bd1a7c98fdc301d47240956b9	285
26	5540ccc508c48535c1c8df0f6d4ec7c2583aba8c20f70ab5fceb07da7a9d3d55	297
27	adcc9951ffb005b05ca17cf97788fb0928bb948936aa260688ec96746fd39896	298
28	185d8cdcd2059b77184e043fc1a3392449079a095cd6bc659d9149b955744525	326
29	76caa95ee794d5d5d1968795d670659ed6de59a9a9290a064b771019e5b1a523	328
30	a0884993a81feadbaf5ee0a021ae7bcda21df6bea262fdf8ac939ed2e1255d1f	333
31	710060b8b14b189628165d47b6c14294243fe5cff746b0009b323b7959952e96	359
32	7b04c7eeeff716455e9b1ea11a7fe42eb74061e750e0ab76b63ee2857c327408	371
33	a92265e5626d1f3be913a13b47a07dfc70d5d07bb4d8fd7cb906e576de1de272	375
34	660bae832ee2c837de582ac97e7a49c9add2c14c1deec72c7d40e588e019392b	384
35	8b874fb42d3b8d3478734676f5334e957f4b0f69dea2af5df6d91405481b7651	387
36	7051f1e630ce2e508005a337caac7559fd060b35b0939be00ea166452d26e65c	391
37	9bcdb4f7598dfcbab53f3cd4d16b52e1b176d04db0b4325589295899b1023397	401
38	91cbd1e85440278d0ca2d17957c99124fac5e584cf5e1df9273a3f5d72079ae4	403
39	832afca3100989b26f68b058c19467f749b0ec13d65df7779d19dc987dec96e7	413
40	077c784c2e1ab5ae10861d47aa7226484a984aee558034580c90ea7e65d620f0	416
41	c66b488b8394ff164a15f9abf498544de42548ecdcde96830d43ee3e582e57de	418
42	ad85efbbc9bf93121e35da4bb4a1ad1e65d0f01fcc84065ed09ef7e6c54aeff1	421
43	a2a32dcdb86cb37f22fa9c4a31f4350134620c2e8316dda16de31e4027123771	428
44	2642b369fcf57a9f0540718467c783cf365d3ea99233aafdee6a83bf4cc6aa5d	432
45	c23e0ce693e2ec5263887fbc9e77b8a50879535ecad82bf7013b9b7d754b7b5a	440
46	e95da6a295f1ec7ef915aca0b34e8e8a6005d2db286dc2ee28036592d5a7e8fd	441
47	4e8ca14b8b04a58ea2a8adafb8f5b5e6763c31603c3bb57d8e4f0c721c694429	451
48	94ef879688b61aaa792a3f077e30390b8e5f1bf14677e62eca236024194d494d	455
49	e73e3656573fb1bdf734b059e80f881a71affe48eedfff6a76f484bb1a98e846	456
50	8055a6bcd000af4b1e049c5156efef0e81bb112176c0c4c6846c87ac9887b7bc	470
51	e77685e46afc0b23825ff49ca026dc609d84bee4cd38baaea61e0f112063c81c	474
52	abbcc6ff14cedfd907271bc4f04d637a3bc2f883aa952e216fdaf9ea09c9f947	477
53	cf81316c9ba151dbb50fc42a3837ce6d4cc7713cbce89cd80ea6590737e5cbd8	487
54	e7aa269bec91751f790487a2c9ed11c78dcb06ac9a052994c2e59a8b2d3b5d2b	489
55	1cf95a485cfa56dc7c83b6fdc3d946105154fdac513722a1240a27247bbb58d5	496
56	e9dc3aca06bdd08a9e25b09624625598c8df67ab98bcb13708a1cfc4c61959f0	498
57	6cac8a1480fa9b1968c4f528e152bab43e9509ec929f93f9698bfd3a5dcf0d4d	504
58	0a68fe1516a3396dca312fc824ee106bc1c919fcea309c8d81997054c36e9e92	525
59	613bf89647985d97797b633227f454fbb117f0a918bc3eecc7020a8b1d58bb53	542
60	8eb193d17b1f2cdd5cfdd619d4e7ec1dbf9ef9782755f74e2d1cb493ce55bf45	563
61	c5ef661605aab165eac6e6ac282e297281191f79b864ab5a16bd3d7f77580405	570
62	ea782dce79740de9a8192a0658761974b738249734504731e4028088c588340f	574
63	557f5199ffbece63345f5bf3acc83a803250d1b864e7647062e63617d0090692	615
64	8dc2a5d95b268e689cb5fdfb73c7ebcc7a959da7b9640feacd08a92a28923bdb	629
65	ef6f15448a571d35b2aa033a57b5cf97ce5d016c9efc8579701e124cfc89d30f	636
66	197c7db40da2da6d90c801988cadeb5566d0972bca15cdd8e7f8befac5216e86	643
67	1342316cb62d254353ab1b5588c87c71e64bee73588c55c96e00f81a5f77c2cf	653
68	5a36e74ccd07bc649184eb277e22ab708f222427650921d1ff4b2eda3583140b	660
69	87967d53937e1cd3cf18bfcb5fdfa29c434737cc1965f67ec42f73fd1f042454	661
70	49f4133656dad2b3a8e3692eb1ccee4e7ba96a1ae9ff59de4e2f7a48f79a7053	666
71	1d5bb8ba745966f1a1ad6947dbc7f8aa899b263af5c5303667eab951deb9d382	670
72	24fc40f100a18e2d7089cef4614c3db8edce9b5539b29c9eec63628e8903c88d	673
73	94562b05b2133f701379b12a3fca86bc9485d8ecc7a1983e9945c45f78db6808	682
74	b33d88d6a477925982b5a9eae7285a6bfaee1cf89466d187d521cdfc3c2d2ded	690
75	45d75239c340e8bb8ca6cbcdbf7c37e09066d028c89786df82956642bfd01175	691
76	08a7272d79af8c6be96128ef45d16ea2822032f37504d16beb31ad83e032a85c	693
77	3a8c79ce622180ce52e6aa9071cc86e5fe040c1e0ca0563aa37f95dbafc2dd7e	697
78	e245e8abc1b51453c3ca2a71b08b850bedbc536710597022bc8a317e275ef0c6	723
79	6bc9a307a7220b57e09ec413c9b70c7ae216664b77fa7f056334a4241839729c	727
80	1c7c3abd84a7350281fb77d2f428a20572cab7338fec10e9bb26cd0d923d130d	730
81	bae493664652d904dd0074a551b521379d8fcc38c321b59f67b9251854ab078d	752
82	0018546cc129d240ee59e9800a9aab57b76373a87fa6cc96a8907da646d46f3f	755
83	a1824cd16792df79172d067f4c5d3114d892053eefe48e8e593b04b0e7e30310	766
84	b1ba1a5b3f776292996263d73656346bb13ac612cdfe79e372d16708cc2ccadb	787
85	904497c7b7e50bbe67179562032965e0f261668f71da1de2809999809a260948	816
86	bf9621dc1a71f228b9265fa4e3dfb108ff77919bd54634b4df40f167eb9134ca	830
87	269ee1728123653509beec7433c85d9b9a2d106a6b87f794aa8ad2e93f76f213	834
88	781b22c0e95655519817eb6341a99915d95f6cb2a558183a4afc807f8435e817	837
89	8a455a8a5fa4bafc6fcbcff328c2f3ac32eff63ee6f52ef86f8dca549b9008f3	844
90	011a542e6951e1644b1e608dd372f25d0b66b01daf7db902e9314a8fadb9fad8	849
91	acca59a9fcbbb9d5c4e20f9c568664ee6c7e5cccb3871623ad78f31bab3b6731	850
92	5259a8d22179d157076c373b635ff4bed52acc31126ea304b23327c759c295c0	852
93	372c29cea5f4322cabcf322c035b982196ff67d8c569de371bbe7c139d50f41a	860
94	f5c7fdd44fe2e5cd2fe0f6f9b5e9731c0f7a87bf420fd6cf04e9646dc6f1a4b8	911
95	912822dabbeaaf976ed5d2de2f746156bf8a7283c9f7f5df41565d54cc79aa4e	912
96	f4af53522d1efbe629655133250526dbadf0909ba49325b948b70e63441266ab	926
97	26b9cee4f5c1263fd3c6e022431863b1e70206a633e93f74608b81dd3cb701cc	932
98	efa3b44c3c61b4bb2585c3a1cc2b49cf6c4f44ba02ea4ec73632fa484b844457	939
99	e05cfcd830577e05d7e852ada76607960478acb5f91e85a0fd658abcdabd3845	952
100	f625275975a3254592b280dee51b256215811929da5cacd165e163cee1734ace	956
101	9113b27000a3983b1340c423b3efdbd2d3724ec8374e81d5806dfb0feec8280f	959
102	0bd31044c546d3197480a7df8483d847b368cf77ff95ec81d5769a768366a212	969
103	08151a093f4a21123bd27e54d960402de7998f0e099e8f0d7b4cfead8c305824	988
104	400585ab935857a00ba2f0e6bc3049e7c3c64967572061eb87dfd4c4127a54cf	991
105	9ce10dc79d1d2bccf7fd31b44f28a48a435e46e0b7bb71071b6d0e964aac657c	992
106	071b6a0b9da9671130e1095fb3d1e3aeeb663bfe6c5da9e8cf1f496940bdd122	1018
107	64931c5e155d62e463c7da5e26fa0fa76741f63952f0c7bdb8fb75377e7f76c4	1031
108	a2c0367a51ca1f8f2670d5043ffccd8569e376f59220f0097cee3086315ab2d9	1035
109	4139f84340ce0e64593e4cc5b641d73589e19bd0f96ea112768f0d5cc461e14b	1038
110	83ab05b7fd660f2297d2c089c3fb6f940ae7516c40b331a37a5fe09b029451f5	1090
111	eed1c8b4a54a562f44ec37268b8e2308b57b2dab4097f5de1a46ad9fde0a3408	1104
112	3195b1009bed7616c98bb7f5893199d85a79fd5ad009609afcb4269b59c6184f	1105
113	ac26558e7b21a9ce9f78c6e56a7356fed16d67a791f95abf7dfc5671283b0bba	1121
114	d33422dc727c926d77d980eaee04aabb845c530c7ed4dcfa9126bdd22630f94b	1140
115	1b9a5458b45099b65ce7f101a78281ba2af80f1bbdf262ad38abdd7299989f03	1158
116	729f1790e05e5b5677a8c047d2548aea7533675d7015005cad286617d5209ee5	1171
117	94d23b41d1ac103e25f5f0284fcac19652f67b27c0f9e332ed63ae244ee2b516	1178
118	11c218eaeb40f39b0ceeaf09a7079bb128667f696712a6eaa4a1dba6f94fea1d	1186
119	3022e1f3181d8cee36ff7df555436a471c9e2f013919af6a688ba0042236798f	1199
120	5b6b1314d32e5314b87eaa8d5df23c5596043c29e53497cb203d638f3c524099	1200
121	f6292b2cde240317958d848f8482e0e61e393344aa41582a38adaa1bb0564fe9	1202
122	a67bd8abb9c1e7eb4e1117bbdf44c3609d516b6b9bb95634fceffa2e0aea30fe	1203
123	6cc200ab950f2261fee6d7092a71ed1ed5a0f3d9db6ab7c85e25f3914875a97c	1231
124	05bdb6afd1fc1ec5e2567537600f41e90481ed85adde169cd336016ce1ea1a78	1234
125	1469068fef9e4adb9a267cdda69260f48586f5750b44f5532cacc5b3a0b8247b	1235
126	a95481cc3c3de045f0a9d01edc6ade846d47011774fffc9bcb0c9a2899c4ff48	1249
127	f46bd98e56d5f2cf7a5d0977327e89c60c3768d170d209dd2b8d42a3a150c08e	1277
128	86a494fff1d60e6d547cf3266322887c210f8a5bf4d19e2f7f380271839ac694	1298
129	a0c28e57f82fb39d8da1da7af1bfe8e63b8c4268ec3ae43714e9dd363a71d4eb	1307
130	422fbad7992cd69ab3df7864dc9f09c8ab72b717d98d2950571c313c258d2426	1312
131	aa8201388f1deb7f704fe63a1c595216d067b0b6da127f79580abec49a259907	1318
132	431116706d8717eee8ab5d8082972567407fccef297b85eb6d5e3be6789679e2	1331
133	6aee4accf1e173a280ef0e15d78d9ac4ef4a4d6f1780d859c02a9125cd0365bf	1335
134	aa60e35f5c70e38678a4da3651b4171a5cea98885b12d156c28b837140e63ab9	1346
135	50d022fd83b658f377e6d9b5719076025f06e7ac48794e9e6a97b40851816919	1354
136	b4ec005a7c84e1fccfd96586fafc25d7a937d097e51f125b621b7be2fc62ff7a	1372
137	240c81625eaf020f6c670f8659095986158e3386d9f7b009f63833900a3b4149	1417
138	c9a37cebcd4664c632aa089c8ddf64abbc662d57cff5bdbeb1f28509a2a13a9e	1433
139	05bf3722fe3cda66275f87640101b605f65617bc97db5e0e1180fbbfb83993c4	1444
140	f8bc35a3c58e5319d7187bd5f97ab6a0f6906d72400aad57aeeed971f7a9b5a0	1446
141	d9972ccd11952bd2774b70e0b6d28831b70ff30c639ec14b4e97245bd79bcc39	1450
142	d0c8efeb74b55a7ca07b8ea2498cb05e270774f842cf095f2323f16780e30a49	1485
143	a0f892e3e1c6d1891bf7a2ff807f9b18fdaf1b9e0d358256b78841cc75e37f30	1510
144	a96a2505792f716fc352d60003af001c4a83295175068def86b521e4aa44885b	1512
145	6330141add2271f45ff15a82a3b489ea33d91985002f7f35e5b63c3d37eee917	1522
146	e8ebf0da1f8687ed6bfdd5aa9e2265f62ef6eb1f804389b390c4dfb73809be94	1526
147	d1b31126d2076b292fb7fc71c43790269a6ad8af1dd35df090f7688822218677	1540
148	6f2d6ff012066e9318f5cc93a62d5074f937955273d28f1e7b51e7d7e46f580b	1583
149	5c27f44ba6732c43fa8b7822987eb66c859c0900fdeb9740f7b336acc63529a8	1592
150	38d40fc3e8da936de328cc326362c3944aefdbb9dece79161c01530edea33c3c	1597
151	3ac7d5b61ca71c57c1b2a07da6d5721a6dd74fcbd264bbfa8c21357f055b3032	1612
152	561217a5284e5206e26a1fbe50c18973e5bc5439edca37e2aecd58dd5eb503ce	1616
153	a8c6fc6a4167443acf636359939cc85b3baa5b70bdf1cde92604b8aa2bb67b37	1618
154	205c5139756f4e40ac0809c54dc7deb4f3153e5fd19d36a210610a37d685d5f7	1626
155	2d8766bbee85e706f203c4b1e20e9e5354a4e4a4f287b9752276710a172ac3d7	1643
156	3d67853fb7b526b781e32a7434b83ffc8f25a1f1a009be80082dfc8fa21fd6fa	1648
157	8d53f5942fc228a827fe9959433f519caca6c9983b441119abf796c724613050	1667
158	1529ea68903055c3deda30d2b2c49d2cb50b909b060227a3dfce71d21306c342	1668
159	54e01a978b4e504adc1a5bb672a418cd6bc0b4282944c303d8b0a02a0cf1c81d	1678
160	88e88c5b37f044519106647479b087ff8e7a937d67b5c146b3a67c7cb00c10a4	1695
161	9630ef8e6607c4b3d677a47ceb5adba48a9915b3f5eae87ec5e4c58480960f1f	1733
162	47aa36b221b48e963a0c72714228bc8cc1b7e970f2fd1eeaaaac7db53ba9ba68	1745
163	2496d14bd4a4b33e184cb86cb9010f8b5fca2354924a453a32ec9da1f912942e	1747
164	875761cd744040898b4ef0c4caf8baa26099d434ddd6c1effb530c05e4168d07	1748
165	fab53af27ddccc870d0eff49148659659567b2f7bf8f042d353e4a7086b1365e	1752
166	8945b343bc64f16bb75ea99715317394fbabedc40bec67d33456cafe5889aae5	1783
167	227f80ae7a449a7591cdc8129a560d63492d9da6d772906ba150f3c7153397ee	1786
168	b345eeba2e59828fc6ffd6e45ae7c7feaa5fbe6f049d7e3b38f84a2883433885	1799
169	e030bec876d5cecd4b9dfd398d31ceebb5c7835ff8365cc28e7c380448cb5820	1821
170	9504d24e3d417eb934f9995abf3759f6af40c6acd707ed1c05530b2dcffe96c9	1828
171	d6c187e45b7239163dc2fe4482537ef2948ffcbd9fe9471618146ba65bd25c62	1835
172	4814ac8559c593207af6e46933ac477965b0f0c07b6c8c58d5de47f5bd6a7b23	1837
173	0101bcb7c5fb0e31c81e7a543091236db22314f1c724ab7355a1daed0ee9d4d6	1842
174	8722e7eb1d9a971e02eb50f3bb805a98ed8dc4ac2a8ec67befc3cda5d1a3d4fd	1861
175	5bbe4ae8a780ff9fe8f7ac269d878ddda27fe1e236cf540eed04c62809976ecf	1865
176	0df25bb7b34ab96195c0b39e03490ffdaa7207f3717930ef6f232127f0896a2d	1866
177	e1f7d92cd9f3e90e64ca7af089241b308025ae48d4a715e2378e64c049582a61	1869
178	7a658386ad5bc8fcf1f43325f77abfd863bc06a87150b6990cbabf8cf9565d29	1871
179	446eb0200c1137feec442dfdeb261d4017fdcb21dc0718b365c3d62e366e3113	1907
180	0646f776a55897cc2d5e3654b8500c5d34ef9fb39090db702e13f888fdc99d7a	1918
181	3aacc456b800df3bd4af55eced14cb85982931645c443d691364935a1d92d1f5	1932
182	85dfd6db43e2089ad3caedf7ed61d298d6f5b7a353630a1b95927f3e406859bd	1958
183	a172ef93c856afd8b5c919affd572fc421c50e4bf3f5734479285756f9e37816	1960
184	0dcbe90a3ed8e248a36568809fac924eb1e270e459050efc483c0bab4501674d	1965
185	fffe15dff0100ba1047be078febbfdebf3d204bfcca95cc953fb78c2c6c4dff7	1978
186	c97513b9435bf18f91dc79ee7b7456582a0ff1999fd05366b6ffd7e2f8a17b6a	1979
187	c1b5afe75808d32358d0920c84775ef4fdd52fbde74dbbd01d386a029baffc16	1985
188	81347d66d7be0463f086e25b1c117a4e135d9e40fd403455808bc8b1ae8291e5	2005
189	803cb374a32c7fd80024769778265feca6a4dcae694a127e28c5b626f50ef879	2008
190	b74906ff9fc9cb77d40f52757a9aa46578581b7fd36bfa3b8707300d6bc6b0c0	2017
191	1f7b7db6adcd5704c6a96373a6fc28a79eb6c3858040ebe8a078323bf9ab7f8c	2018
192	64dc32fcd823204fe5a9284d346347cb89c6952d401cac18f69ef7589d3fe9e5	2022
193	f20c82dfbddefc385ad55e90856f9cf6878a9630a44b6f72e10d76116fd17151	2048
194	f0037e991fe1d9398082ea1bc94ed58d0a5b48cf63c785f50a6e1a1969c779a0	2076
195	b57d6f0ddb419b36c4d08adf9febdb68cb0bd0068cee93430f931bdce81275c0	2082
196	34b69beedb2ecbd05910940e51aa71e46acb21edb76acfce33003d8999bcb2dc	2086
197	0c5c6627f9a103ce8a67acc0c9a1067f35d5d19bb72054d30361bfd462a1155a	2100
198	fbc66b50813d6f67e7c3a669ca6ade09f6a74bbff56362642faff80814d23c6f	2111
199	3f72aca48fd124f5e6e7fa4c780473d7312548e175b3acee270833918a88df9a	2112
200	deb28f6109ed323c889a9238fe94cc0e412e48d73c5ef63f3adcb23e5a4d5a7b	2130
201	35bd926fb2311657f84065b7c6186f5f7c2d0ac4a7dd1dfa5adb9f43fadafa8f	2139
202	5fd46922fb57c9b0fcfdeda9b6775430a24bf3c7c203e9e537b8e074d0735cc3	2168
203	153e74c675b3eac71b048bde51e144da002a093c709469f9a9f514532e4daaeb	2192
204	203a9511602914bbf1e169796f3634bac9d9c4f7b82b387136db859361666bbd	2200
205	12d69448d8128865ec3533db40a0d575c56189ea82246a358cafb809c28374b4	2201
206	9ffd9604322a928b824d1b3b72cfbf0959525fc105d20a1beca3d9435dc1a2a5	2202
207	39a2bfb40a851bd1e351bf3684caced2972dc99d3c8975bf4bfefed629d330c4	2204
208	1017001c88194db7a58ec944478705dc344c6dd8d2c71bc295f3e194dcdc124f	2209
209	08130e2ea87bdaf03506aa5a34f2673898139a574c9e48b58bc34b0f907b4745	2214
210	eb3f0e9d1e2a91793efff1062a735d25017ce4d708e2297820f8f06337b6e5ea	2225
211	80fe9c0b8035d3bd0ae7fe056c1770f1ecabe7a6e0cf44e24b1d791246c01d0b	2231
212	ee48dfcc8b6afa27d98c1a8ffbc0054f3b93e2a64dfc95a5da3fe6d7e2873363	2234
213	786cb7f0e81fdd2a85bb3d9dd660fe8a5a2540286ebf828b94c5fa1bbb93d324	2240
214	bd9862eed48ca7e84f40e71677deab387b6c191fbfd11bfc5906238b21cafe6b	2266
215	8b6bdf862b9a70787e391527e39187d8cc1999434b90cbf6a505863a60b903a6	2276
216	d5ede37d10ac51c8f78ff3958147953b66d3600c48ffc0d48188ff7b4f0cde6c	2277
217	4689e3c10c7ad8fe6dc5520eb34cdef2c7c89f765a8e95649681ec6ca8f13fb6	2301
218	61975b9094e7cda755b041948ee360528500ed368cff4fd84b1bb88db57b3e7f	2305
219	e21a1f6c6661d325a4a18993e15ec1b5c3c7532f4171b3d0877eaaee7f3ae3e4	2307
220	7a7d8a5f56ac35431149dde7815891bd71b04069918b1db44022723ddfb4c2bc	2313
221	2215a0b7845caf89c3d05bd32f414085cc5118c3060d1a96a4c4f4e3df79d42c	2318
222	23ceee602d116fb2550b20e40380b68f39839dda1e9d628b99c4f2b2c46c6d41	2324
223	24ab452c246707b5f96d75cc3ca0b70215ddb4bce667d6914593149b1ac0e1d6	2346
224	83b1249353de9bb15597b4fda1160e1ecbf31cc81800263825ada4b607bd95a0	2349
225	573e1becbfd10851920abb448303e444643b9ccd86e4476436e4cb291d0a8ad3	2356
226	79175e259c0fb7b426c6ba1bf1910f7ed5b9e89796fa4b2d9040af6b428f409f	2360
227	c85731e508a0a1ba37a9366d7eec9f10aec15bf203f8a3472a66f99c0c545557	2370
228	9ca6644bf8a1ff407a67eae959135286f714186d6c97f52bd53d72e9243dde73	2371
229	9e44fec1793e8b946ec6d27f1b81c40ed0022a1e2362031a7c784b33b2482572	2373
230	12ffceabb1d9d7120db58cea9c46aa27f2911cf9ac4b3dfc46db238f62b60218	2376
231	ad636b92689b13f126f44c57f72fd4be25823a60e9aaa446d9fa0259b8789fdf	2383
232	1b56f8c029c51cdbece8351e39315ca4a34427773a7e540ee768d809e69e8e4a	2386
233	1325f9c1af096d714e33c452ca08b30e166f1c48e59775b77068f375abb04f40	2415
234	ebdd33b12721b18d5c2b585f081a9c6867a38a7b6cdab845d501ccf6a407521a	2416
235	a50d40607c0378d404b0aeeb9ca99b594c766b265efe02d6868dbcc5f89991aa	2420
236	2a15bd97747c02517933e77e01aca3f0ddd54a1e5ea6144808dbf962f48307fa	2439
237	8d490ac9c79693b415486c77c52d93d1434e5011bef3e203fc3434e9754f3948	2443
238	315bd1d79c78d92a9b0199bdc6ea3d64442c3e438b162aba129731b1cee96b5e	2451
239	07ab43dad8c86ad99f74e46e2e8e8ac1c4afa41923f5c332832def2656eb41ac	2453
240	3cbc354d6b0b9987e3bf06641b0b3b42d6f3fd7768e37976eaab297d3326b693	2460
241	ed08d41cde57680f4cea0abc43aea151f1718c8a4a5f2e26f01b1b0847161520	2474
242	b3b779aec7a41dde29760fe5a0723ba12b2087a0d9944c78e7f5d825a13979cb	2491
243	d2ebc4aa5e8e3a8bdda881c19b62c9a49477d749f4115bd3bb9c2aee1494dd96	2499
244	546ac22d479eb44ae459924a953cdbdff89561c2ee541b27ec912487e8e41e98	2502
245	7cfe6e09b2e29ae2549c9a1813184e51d0e0925a73aa4cae116b07482ee87279	2508
246	5467dbb592f55a2b16604b7e38835a5751a758c1a5db16b3f1602b20a469c675	2522
247	b58950fb8a2f4626761731696529d10370a789e266ea979c937f7d322cb2e158	2524
248	464339e7c1549d13940fd29ebcb8dfdbbf2b6a5e6730fab18d3ee6a12caf617d	2533
249	8ce3956e7281286039a2a1bbda34496180e7366b9bfb4e683095c9bf95c32031	2541
250	d0bbd126d72d0a27a3654db9e472cf92d2409c34cecb581c95c43feb6b00d937	2552
251	26ca575addac4aed096030e711fb30605da62149d604823a4633b8a0e9a8ade1	2554
252	0a8cc50a4a23be8e12674865931ad42da7a844a5f1420301b9fe176645a29081	2559
253	fa6cb7737c727ee1a3827943f332a0bb028791e5b4533ab4f8aabc16923b4d50	2566
254	3a58139ffbb1603b98fc894298dae5b27a35a57e4bed238443b1ecb379dacaf0	2571
255	aec6691935ec7802790b4cb13fbadf8f60db6e4417fafe35acbc1ceaa4b5e124	2610
256	580252f017723a90b95fe0abf90ba4ebeac80ffb21ded317f8f2f046b07f4ba3	2611
257	8707933f856159916a4430b4c356b0fb11e8eb8d85f5b7f0e879789dbb8e911e	2620
258	28ce699a839dc2284f0181b3e6f384957639a52a213ce153971c2a9f7469e99a	2628
259	c3104dccf28e5dd4ad0906a54a2eb401b99447d36a2805b6cbf0b5c29dbc4d43	2632
260	fb2ef872acef3d3beaf069964532c2b73c443ff184cf73a5d8f6d187b1f3e6f0	2635
261	9a9fb637cb9829c4b222e42e3b0b130ab5c886e1fd2b4812691e0c9808cee9c9	2636
262	75b40bc6d204c05675678e225f054bb7c220190fbd150654034e165a32281fcf	2654
263	a58c979108aa6b48de286561140fccecc2a79a9f8170002fde4ab3ab17d0d5c8	2667
264	875007994d7aeae50dcf5ac58b44d62618a2619fb27de9f0acae5cc59d54b709	2673
265	2500b75014fcea8e9149526965e0696c4f8e7bdd2bba7d1e32d03523d967719a	2679
266	9920081b0afeb4be92f1fc33be85bfc2cbe817a4a5eea5aad6f9c54701a3cb62	2683
267	af4a11b3de91af2a794ef8c31cb48eb5dab224f9181d5c34b7fe41ec35994b25	2689
268	41c2b99969b0d7cb3d342ba69e786df92de52ab9ce2cc86d06b44d4507142c36	2697
269	c6da3e9c60d6e6db6894e9d8efe0ce9b30013228e07dafc8a64744169f851142	2700
270	03fc9b0c83fb05bf8b79a246c233adb8b1f3a7692607334632c831f19cb8251c	2707
271	9cdcd588876067220ab728784743ca2abddd0c112be93ddc40e19667e2766d0f	2710
272	153586c2fd7a51c00e73d22a9114dd17fedb8ad7be9c6991998ac350b1e1a1d9	2729
273	8c1ea5de1028e498eb03be16937a7f4d4a2448b8e9e250a2021f71ea45cb0789	2733
274	d85b931185eeae4f6f54fb388473d0b1c086b9f4669a50bbc4827d9b395d020d	2744
275	02876bbd571c9b818256869dc8f03316d6f1ade5a5408a33733c78c3f0d50a57	2751
276	d138a2dbd26692b8b24be04ae357ebb8edf6ca2f90fe6b1d5cfa3fea940cf1fb	2752
277	75ad03371068f353efa3f0c3c21ed65261572117012ea6455bfd46d2b01cdcab	2756
278	92f0f0638ad2b18b8dd8038ccd351f32caad58252e4b76dc5fd969fd16ddeb79	2765
279	1d4cb75e2c8790b8bf6f5e2e048d06771061412b6e9be4d32612d2c75f5d5f41	2767
280	43abe575769f102e8ef605d8cd3c0da74c064afbaee434e951cf9e8889032294	2783
281	1b5277c7ff8ca578e8d5268a0ea0e2b9ebcf7377254c7fd4e7004c46baa9c1c3	2798
282	93b4a098f04889e4c974f32feb5c252594920b232cea00de01de261eccab5838	2839
283	73026aae511118ebcf5ffaecde3b8a33bc4ec8d370af26d11b6ab8c2eb4cf81d	2840
284	454a3695e5e4225334f8f48d2ffd8cb319745c8254edf52bf6e12a782127edc4	2858
285	a04b61abee09081fa3a080878398509047d51a45109d706860ea2702be2f2a11	2859
286	de2948f76709c8d60fee709accc32837b5efa5df6fd03e93f8bdd146cedf9e9e	2868
287	e73ababbb1c52bb1d32bf8b4d1a40d0ffa4bf5092e622e91831f92a5a4a4a7d3	2873
288	2324d06ee47aaf5055ab2f8444677781e55cd1d68e54193e3a5917429cb64e8f	2887
289	1a958569f0514efc9355552b778c3d7a59c7a749acc32a4824b3be4b8ef9910b	2895
290	09a62f4630ec0c3b942aaea1f15d7feb08615d8b093f2c5d73f4f7d3c08ed5f1	2912
291	4805e0265469a92092603cc40dc225538173cc2feee9a768de42ef08cd1b8fa3	2921
292	cff7ddb4d71f843ca2cc323368d4a533a2579c6c387c5684a08c2994a33787b1	2932
293	cdb4b5e0cf234f713fd35f5a69d2f686cae7f7cb8a00969dc4b235ef49b9c864	2941
294	6057688b33059f98b6a6b56d8890fecbe1110e31a456025a2f92b47dc41f7b89	2942
295	41f40025fce9f00e4ad99918054aa7e0faf0792d0973cf9c72c3e1857a8de9c1	2944
296	4da76332852a0ccb6420778b34bfb543235b1d25fd05459188b362fbbcf0f4d3	2967
297	3951cb929fd06675c3afef0c6fe8fbdc3c49227cfb538f17175c0a32d66f4e06	2975
298	6c88c54b2fc25cc53e052bb81ee939d507c436218ba117e934a308e41bbd14d5	2989
299	caf5578766339b80733f0bcecca1db415a748720001a44b46d5c7c54f8b7ac97	3025
300	af5a11517de7470dd0f711b59a4b8f4dd617a7d1a7b60c26cee2a01f26ec880b	3027
301	7682a7101d53bb424f4ca9e4ce0428c99b5dbe3ac9f5903e1a48b7b13bb91745	3040
302	8ad1be91ff819f2799a6ff478f9339d4ee1f2dc599b716b2075534c54d49ce3a	3070
303	55825eabc00dbc198551c79d0c8be9857a54232032e3302bea4e9f74eea04881	3087
304	dfcc78b8adf0adc7a9b39e233b01b19d2dae988c7ecf6dc9a80e3ac42e25d51d	3100
305	dd976e01b8aa4ad6975617709b9cf91341141a3970d2389ced66dc42b5743a83	3117
306	7869b77da714a51e6cf81b91243ac527bb33d0fe7f50929c2904359c4b4ce75b	3118
307	bce8fa78520c790cd4984f6052a83139b1490dbf80cc63769e7e437b1bf94d01	3119
308	6a06e476281169e5379101b74017fb7f6d740c71eeb3405fa4173ca65403496b	3129
309	eb9e3ba3d5edbad6a53829fa52635cd602eb03eb92775758ef70e7881181fa34	3148
310	6287c0d75029adf1ceafb976e9fda0a4e97eebfc94436ac866f166e043c3d749	3163
311	1b2defe7d515745f1caac597fae35cc8f623bf5028320d655b050280118b9d60	3165
312	15dfac476e84ef0f3cb83a33bd3d1a33a1da21530a261606d856fdc8fc4919fd	3179
313	4bcd3b364f792a9e637a2be4516eff7993122e618adebda57129bd69e54d032e	3184
314	053a528db6576105ddfa477af19126581644ec2c1a6edf679b0b7ef896fa5710	3207
315	22838f19c6cf2ac29841840a0c3e88bd6286ea7fefaadd26989670956fb83033	3215
316	d83951ca039713e7b603813a5c4d1a905f6d43b6283a87dd634b4481fa95d906	3229
317	065e5e514d53dd51260d88f6e7c03f5d081cca0026c10e734fe0c686c99a20b6	3230
318	846f342b5ef543b34b1f2ec705a74b0ad8b3e1f0c047d386abb537a4d4c40fc8	3238
319	0ac16e205d7542e94ff2f84e64f3218d3cbf76032fb2fbaafb162d8e822c6bef	3247
320	aea834857faec86e23af659208704a4e129322417abfa5d2373443d5ac985232	3256
321	2c7b9e14d697fd8f2955460d776e53282ae21088f56dd24976dcdc6964e2e749	3276
322	fcc28b71d80b5466e61f3474bcc9746dd699832807d23bd369a6493b184e57ba	3290
323	021f9d9ae74b84c4d853e231c1c3daab6ad98e1c16af6366d82f4b2f5bbe1fe6	3292
324	754064c0c8faadfad37c46c50e5cd273ce5221e1485d4e8267256d1acf40a058	3311
325	96121b3ec0c8cb7209509174b748ddbff5d15d131d232f8aa3191c64980617f9	3325
326	c0b6b4dda089eeacc3937398cf1c455ab26a17c49928408edb26fb289ed7e245	3328
327	0e96d12cc72d653b654cd28960b14bd8e1c6823c933b20523b79b089295fd12e	3336
328	ceb59259d80dc4678b33628dc88f2cc7036785fc8d76a896fd3f1a726e19ca3e	3370
329	c2925c24f61762aed4c4aae270459c24e0bc93d060249c4bacb5506c4ac08115	3377
330	427c9c29ed6c1f5badb2495a52c3f06de9cc26f27c575be49c2ed81496eb0b71	3378
331	90672415edc0832eb45d06ab2ff83db820609893632e8dec84488a6b46ecf1b3	3379
332	c5351f3f658bfbd6e4bbaf481667c3a093db6a6a54cbef10488239dfb742814e	3389
333	031211397ddcc1e2793892362763f3fb7b572b7ed1f7d46438afcd507b704387	3392
334	e69712109d9a1f7a34732151b11e69a4d144758acd7b3bf434500abe721d0415	3397
335	5dd38ada200abe9bee06dda4aa3b8d851ece688c0cde8d2b86243b217e568fea	3419
336	5d1114972da3ab30e34aa870d6f9741103632241853c42a9551851b5dd63b411	3425
337	e45a75fa3417be36a22ff13a0b4202c0a48a0607c00cbf7929ee6a785b5b1045	3431
338	1891649385569d1b5fc5222e25ffee2dc7ed5937e31fe0c8c00145ccff737435	3442
339	cbace2aa08eae4326cbc7aca1a97954db9ab7c1873c220309efe0cc7b6f0d5ba	3446
340	a5c7d6f7f5ea62dddf29ddaeb83c8cdb49e99aafc540a8678edafc9cc637ddf4	3457
341	9e92be1f346644b0eb1bb92ff1ec5a836f47d7757c2598b70e88c00dd7b891f3	3463
342	1b9e316c3ccc65f03f744a60f5ef6a250b3c7ec665ee410fd77632e98369493e	3492
343	6244dc5e4a839b285e63dd6573b16d443463109aa90ea52946ca3035e36b381f	3495
344	337944aa92d1b42dc7f36bb2ffb378c65bb617ecb47f037c072fefbda1bf9bbc	3498
345	c8e2753dd0add6eef450c46702b4615c6385abc4f92e7e9ed60afcd0f76daa87	3517
346	8f258da1e106f0510aad526aca1b1a06e52e414d940bfdd3c0d665ddfc93bf4f	3519
347	7172da44644a8dce3fb11c456b2db9243ca5c187fb9329f3afd0cf7ef69ad029	3549
348	334b635a3819eaac33b855067631c1821fd60e2902267820b988d60ad463f475	3557
349	bf3bd9d12e90382c53f17a47fba7999968b99a7471d47a2ad715c56c00b739c9	3583
350	b6928b5ca6dcb4eac6358e3dbd1537dd7c887117d7a5bdf17932ea8e7369718a	3599
351	1e086d99e861ddcdc6a34de3f349ba9eddb3f744e62a1be8677cef6d4acc47a7	3610
352	68e87e665d236fe6b3cd275528f12203dc43e40c70e5933dcc6d16cdd85bb287	3633
353	5a81102b63731cf48a6729afc35dc7c77666fc0fe44170a12d6b6bd39a343f1c	3648
354	c681038fe48ba0f1cd6ca2e2e603c310f10c6a33d366fb89043bed5d701b87e4	3651
355	c2914bdf883122a3f0994968c9917a5e0b24e06d25c312d84d158226bfb523a9	3654
356	11c013974002d1624780a1c3136cde348dde13e36452042f3439c2a549560dcb	3659
357	288e19c1e1844cebb1c18ec4fe5c500b88282e8c71a301a64f0e0c2ddbc55e77	3663
358	ea05cf6c59a6e940d988e9c1cba602b659d65e1cff0ed38a3a823cdfe735643f	3666
359	fae71aa8184dcc006b66a974b7676e176c423223a79aadfaf2d92fa1be48835e	3672
360	0d3f793ea46b8ef439afc5f94b13e44aa1d030f56f042388bb771a2d398de018	3674
361	a06b0910ad96d0cf08ef5ce17a9abbdd8066f542200f154d281dcc660a8aa739	3675
362	ec09cf32f4d10432a151cb30a20cc385169f718ae0ee6ed3680dc1c49f223442	3692
363	af13ea5b63e65fedf64b0da4928ac49fefd933a62f4494b771918bc10d91e461	3693
364	ee6525662572c56e215a3630e6e6719e1558db596913c191f929a40494bda5f6	3694
365	77fef72096154892caa8e12be337ff50569fe274f18050518012a13fb36e16ca	3699
366	823d477a1f6a2b239cab8a1b1bc9a93beb64fc481fe2fe87a1890d418fca25e7	3728
367	0e2b792c3eda40fc90a1e60e0f9d47f9c51209fc2c9a351db67744c689ab548d	3748
368	e7fe0ee9f299e14076890e9b017fd6d67f9075d1890f30b26156375a70df0993	3757
369	29be364afffde8f59dab57060c5c8d8a0f51c7e16f43459c71db32541d47c8ef	3786
370	2f7aff67168a95ac45a307348723a2af2d41defd1bee7b58e9537b37e29fbf78	3788
371	38fdca4b4e96ee8f7326150837a84bdbdec4c0ac1e402fe60932060f37f866e3	3796
372	01672e3619b0b47dd4fc3defe873d4e8b3fee6b446d52aef991c89773552932c	3798
373	da3d7888f4f2b9db0520deec9434b955be27392fe0bbc34942e36b4233dcb8cd	3799
374	1fe74416309f900cb861a8001a72bbbbbefa54c2376041805d0369e89ba13db6	3800
375	ca479ac5302dc89d967a9ee48f0480f5f409ce1f623a72a88f3d190830bf340d	3803
376	240ddebacf6ab5fb21b8f54e3ae63989128a9485c4619bba010da24d457837ba	3844
377	3c80f324cb5d9434ebacaad8b13621e801bf5fee72167fc79e87c6a1e3e81543	3850
378	aeba649ef54af59ce1f9049d25ac9e94fa046523adedfc351b4f8d86294e8a27	3864
379	46ecb51e75cc3258c74944096d09da85e3ac91e906513fa7b343ad65d6fb7869	3897
380	069c437236ab7fcbe32e2d09d283d332b572f3d0a9d19bedc0fa84a0b5bf576a	3921
381	a09c9381b4659c988b11880f11f83f2a06f695ccea559d97b2e6208611cdd4e2	3925
382	0e6c9e4f4db0c9ebc8021a932543418a71c51580dc856b4499fb6cc29ce52d53	3933
383	eb034656c1302d13815c8bb8888ff97388f9ff4cdfbb49a6806d36e7dd181328	3952
384	fa2b963e387d22484adf05a0198d04618bde01d96fe8ede6e7e556ddbbe3fd13	3955
385	7017b9ade85a188589231709fac3a2a65851d8ac56dc9eec139f068779ccc7df	3957
386	fdec71e7979dd58d46b8c58d930a0a6df4dffa30da9bf3e3c943cfaef9679735	3968
387	c8a280424ccbf2ac17ce3b2d5fd61cc1a6cad051643c9d4cef5b5e5ea6fda130	3979
388	84dca8b0348a461dd6cfd329e88e29b79fa2fcc336d0f3993e21908718b3ea9b	3983
389	6d58d4ae06e2849d8cef36083c436379e908296c74e48adc27436c9575f53d87	3988
390	8bbe583f2ce75b0b00da66177b70ab259cebc0f3bce1d729c0d19b382c613d80	3991
391	f61e8cfaee3ef149cc3520fca0dcb02218ef447ee75b106287f13f4575c8235f	4005
392	0bb841dd80716409cecfcbbc95861ed5ff94b99dfe82c44cc1bea6576858aeac	4010
393	6c8132421f84382d70028f0d2fe2abde29673a4eb759ee208b8d198957920c4d	4026
394	1a60c846816549055b1f208f6c4886b804aac6e73897f0298e576c34cf6134b1	4046
395	0ef2e28281219cd6bac69d032375c0eb22e81f004d341d217474984f31413d42	4072
396	2db724ba33064d575f1c34c40ebfec4e9689af1defdf9e9a01bd4c308eb01fdc	4079
397	57e4505d4ad95e5aff91591e160f8314b5987781bbc52af58563ad4d705bb414	4086
398	472a1996ca7c00bd7ee3ce5c3b235d23743a221f4c50bc0294618f7b5cb805e9	4093
399	7d0388c0b84106180f2bc00ce0177bad3f754ed8a86bc17c79c1b13ef2f4f14e	4097
400	3f48c184e5fe14f12a1c0b51ad04ae376815fb9fdeebaafab3b1e582bc8f9c23	4110
401	a608e2370cae640adbfe2a4f6d645e6ac4b0fd1d92bef1fc342def610dcb31c8	4119
402	4e36f015f69aeddaffd759774d801674e729c2ed8d4f54684c2934e09afb70a4	4126
403	4579da8e44bc6732ea26947c343d0e9055fabe758c20137d570b1d27c890ba27	4135
404	a7342a003ed9ff46c82cc3bb73c1379209e2f411717da0bfa17ee35a816c3bc8	4136
405	ddcee1d3c7c013b80c60699b1a62235beafd38135ff4133e4c6b7a99e98f175e	4140
406	8cbbb769bdb510789478fb5a1425824a3f7ded7574da232def745b2f0b0ac2b9	4144
407	1aa10f3081023f4ca6dbe12e92fe476abf6689505ee74b5caf1a4918d0f617cd	4146
408	6cf2be7b60275798f1d416a69ee738f8c362413598cedd84e6e2057d3163ab4a	4147
409	9c00874a540ee5278ebfdbe7dfa87a987680d9ea2984e279a838939a60083083	4157
410	ac007d3b1f99e670e5b7a75eaffb57981c84026807baf2cf22e0c4559cb48019	4164
411	ddf9e98646912ed50edbc89d9e8931dd4cdd3316498136171b3fea8f3b878c03	4171
412	bc49e331718ba32c65f5d54382f0d2766450bd7919a8d6783f81299ee422e1ac	4182
413	6df86a8bbcf2f35ff496859f03f8b7387ec5a28b19a1a3b9891ad6f2f0b4c437	4191
414	f8eb79e76e41632b717dead18339b5c6b56186d6d5ae297e065aed5f67daee74	4212
415	634621ecfe3da4c44fe02c376d47c5ba5d59892ca0117e5ef83850410ff53b95	4219
416	e8a4db810480d6e29ccb9288a291807c41ea9faffb46532b17722c64671d9b82	4260
417	bf4cc1ab490ade64a27d31989a0df793e39fe3b2a35bb0f3795a99fa65cf90d0	4263
418	4688f9ff230301e66e80098435543b05d75fef440559345b7c767d2a48f35e91	4276
419	a8a1aba0c8b7ec597af4dfbc1af47c87f5d2fd450ce20ba4bc450da6acc86a11	4293
420	04a1f9f3c1a34e0914aac3f0494328b31c05de94354e0a7cfcc6159a871b2343	4294
421	50148e045bb04d7101d4fa485163e1ebe6ca4b2bb18ae42d6efbcad40c0c5751	4298
422	ca963ef6616f98de4fd367f8223bad445359c939a810858c8adde02d7938c17a	4334
423	2fb64bb7bdae8502bc59d9cc7a4e15ee7ccf96b4f8bf7d54f521db4f25a7c65b	4345
424	fb75839dcb6ba89795daf9a5cc18aa2f9729bee031a0285dc2b28b60c8e00b18	4351
425	6a849de6a3e534ef9b47c603afdf93c39b65800571955110344cde31a9173c23	4352
426	8ef96c643816eb6214881a144ddc1f85a030d856b54bbcf5c85c21a037edb2cf	4353
427	c559607a36cd73a4a3c418da861c83e40441d19452c29ad14c3bd69f6ef9c8de	4374
428	921610d732804b5a63b0fffb43fd4386f0d68abe53b13050755e41efa6c2bc93	4384
429	bb6985f392a798b4a3a360bdb6f7197df6bc91eeecdad740e962f0866a3a6b1f	4390
430	1266bc9aac7e95d8530eb8081ac51d01d78114bef25b30294a8e8f8c179c51f8	4400
431	28b089e5ab534e2c1dc9c3baea389a65d1580932a24a140d0a4b40ecbb144072	4410
432	df61d982e0a74c3a33cc0eed6a513a68334b5cc06be25e6718ea859e446acc8c	4415
433	df584266140b8a442c8a6d86ba01d1e7d5c8206c4ff1dff3a4271543fdd119e8	4419
434	953617b308b4b1eeddfae10723bda6997b6ee7e31dcd79fa480c530710948365	4423
435	5957baf11b582422eb57901ab08758244e4bf00c54e18d806721f7d7c82d563f	4429
436	fd1894f9c89c04ae5a9bf20488f52dfbf07a253a224722245422df372bf43152	4439
437	a346df3b01116dbcd9af9e4ab75dd815cf6189e740ae9dd4a902d288fa44bdbd	4452
438	4b9699ddd6edac9322d0661ef7df4c5d0c7c4fad0432554fd62ad6bc6cd0167d	4454
439	9d768b1136018b6ecf49dc5050f802633778bef3cc4b30fbce97e830e1015525	4456
440	5c4a3005a75d32ccdeecf79c962463213092d19317da0b56b6b1cd1ff3566069	4478
441	b5ddfecd30ee0c01459b39d2a086683e191d988878c208dd5af463273dc53ea0	4480
442	d9b45746d75f2915f419af6931f591c078e80f6befa694b08dad27dc3208b321	4494
443	33e0fb690f02ba62d2da0c55b1eea4ad2c840e424188a53f0c8d58476d94a539	4497
444	fce7c2f16d07956b8f8dfd7d47e0690464ba1055d60ec8a6f5aa002577d03005	4502
445	82006bf9b134f887ce1b9b59c132ab756b158ba4233a3b9c4e12a011b4c2845f	4503
446	6360a33dfd1812c1261c39d997837cb9490431d28cb48e608f930c6d198330b1	4506
447	22643b94a0a3fa66f37c9c7906ea4f76dce919b5b1345e6338ce8a1a9f892b94	4510
448	76f67103196b9ddd190f364bf9392a9adde88e677efa7d6e529ec866388162af	4536
449	b6625a52a2d388e7ba468bc4ee07ae57effa092567eb1d228b0145358ca57314	4554
450	2a81f51a08916d31e5b227ab0439681efef44228a4e70ae66e77e7958099ff00	4576
451	3fb27710a2d775affef0ce9bce06bc71c93541c23df5b53a3490be4d5ce02de4	4610
452	7f8139aedc9d56b07938d98a19eb20a5c00a0fcaf037e1901faaf6ffdf798946	4617
453	954dd99f82ec43fa3e03fec5e54519715310dede38cc940e33278d6bcbcaa382	4626
454	4c1e49112de0b304210f533a135408352fb5adf6f31d087b0e8154ab2c572b64	4629
455	856f33bd067d5bf24bec742e0875794500b738639089949f7be69bf73d83097e	4635
456	9e87cf1a858d675a28f213638bd4575a7f2ae5a3d413689bae4fa165b781d0bf	4649
457	02c2b3b02447027296e8d410223a1a158cd1163f98a573389a513d9686e3f761	4655
458	ba09ee4d9cc5b68999e934f929a31ea9aaf4b44e3ba1f5f5e6d94bc5e65a9dfc	4660
459	d5dc3080a179dde7d49f1faccb20d1d2361019a94078f1b060db21e022221861	4674
460	670074c2634d131e138b728c86deae4f1bf474aa7db1e660cfff5b22d632b58f	4678
461	c2dfa51968f8a8cf897e978cfb87208b6a979516fcf9e7b775e5474aae8e00b9	4695
462	c7b15d068cb31f8410d6024f77da14e05a04117e1a896362c63a1adafcb05134	4698
463	51c671d777477d50b61726294cffa11ec3ae61ad90565fde7db868f30a4898f4	4701
464	2bdea263a2029c3aed08ac22b862ad4fdc122418ec53c37ee845ac1cc9a451bb	4713
465	ba414e957ccd784ab06cd3d7e0fb564a76ab5b864b18dd346ca19f85c1fe0458	4714
466	6b377df316fa069777e6596032eee51e7edd43378c2a0958faec2bb95435f9f6	4728
467	bf8343dd24eaae94b8c5205291d25d6c8861884279db36235381308e6f724b66	4785
468	178db7f4c55c8edd3abb15119056cdeb07a9be69efabdce6d4ef1a868b4f73f2	4802
469	e1efbe7115318af442b9e4f5200f5a1b2be9349cddd8c38095a5701afbe31fc2	4806
470	4cfc977897082b86e9f2b161f0d6b7535e41ed74db00c155fe34add05a0caf3f	4813
471	ced9fce8bbf8c40079176c85e873c0c5e63965d0ff1cf54a0404045ac24117bd	4818
472	72e911bc1603a222cb8f4b6ba5fe84e0d5f371b210e6560df872760df010beae	4840
473	54f2de20befaf498156bbff507a067bbfd5f34921480acc962508a267c97da78	4847
474	8c3c6cae15e942b758793b8e01b5dc8d9c438d78337ba71fcf60d437ccac6822	4861
475	a2a1acf04ae24d55207876f4eac33553cff87755a77167bf8028a5fba6955fe9	4868
476	eceefe81ebd6bafacc4f578c17e78355557553ffb318b5fbdf10d64c5403e2ad	4896
477	93cd8818cec41b22e8062196760ec0bafd1ed4e6593434ccef49c703c18e95d5	4900
478	d123535882b50b87487ea873fc12ce9b9eef7debec47c215152ea5cbfbe6e199	4906
479	dab7fa43d2c9f829ea20aaedeb5ef5bd0ad07ba6c58102b334f779a98e70b2a5	4934
480	2f52072ede28b8aa85487f29e7794d819970c0f781b1993dd53ac93607510883	4938
481	8cf09fe731b0eb97e0194f7885800ac462445ca476c4d12795d2ecd8619b3fb2	4941
482	e88edb22075af8853621ea895fe234c046de88646f67ebf1bb6578d9ee0eff58	4967
483	136d571c54a8647190d2eea9a1ba4af2311985e486dc349afd70f15abe2e56e0	4980
484	59927d2b269ecdeff9e65a482ac534c02129ec3adfdc7f4bf43991d37b4cfb23	4989
485	77efa7c3cbf72bfc8c8ef36ab7a46cb26de54e006f219923b84c0ff9dcca6764	4999
486	628d2dd3e4f82493ef093fc0dee757df47821352ddb407a8d64e64a97ca74c41	5005
487	4f52515f70ce8e96bb3d80e1d35eb7ea6620741e6877e5de94768fe438a54915	5018
488	e2edb2edcd1df70bb7ded1fbf5ea47af01fce5e2e3fcc3259967a632bf8de71b	5024
489	0ab9f96f8f9c1b9b1ee533c444b10dfc2e4b5c38421b7b8beea913c2565f73b4	5026
490	d1bf2f797e9012ec491543e3692d8b8d17ea1c454dc34aedaa7ea704a38cd509	5043
491	3037ab7b7101262efe9441c67ff2ddd0b649aa22166badaa0148e5728cce0931	5052
492	aea03fd2002ed6a6e6690fdff30a41456ad7ca8a62edfd07e979d8a2a8a4c221	5054
493	e7e81dd20329019fa802d1f511b221a1bcde1574675e2d9836a61639af62bce0	5061
494	fb643e24d30c0c2c55768b1efa495f2b1908c131e5298b1a0148831f931c46ba	5071
495	e31c78491beb7796d6dc535f442ece751de405fb5463244448df245935395e34	5130
496	9cc1015b047dcffb2126ddbc7f538bc438e0fb4cf3b22d21dcc6bfd2b285fcb8	5137
497	8f84f035287697b876957705c100287f3a8aab847699d24d733b6cd36ae32504	5138
498	5b753f614becfb0a5c46471113c9451a8e2789f357ed7e5232edba1d43a654ee	5147
499	61e5f5549c9cb4ed2e1a9ba88795b9cf6e59be979bd111f0e6196aab5da78773	5153
500	e8d36846f4ec97d78e9dc3a521d5025b12bbd05439ea86fe7e1fd070bba48eaa	5161
501	1b533c5e0cc2e3ce100b4df4d3883db2b0ab1719daad7f124d635bf6b4ad15de	5184
502	661ee03a374739e70661cf75dbadb0b90f9efb7a790369eb64d714f5a6c110df	5222
503	5e59a6dd3e822819e56dbe916f833e09b31a4fdbbc6b5ca4e0d634d6f76645d3	5225
504	8c4dab8a4b0546d5088277c458bb577067af55c0272309424ab75a73a43f3e55	5231
505	ebbc90970d6d2634b90cab377a0d75aa351d0285b85e6d0134d11b53ab83a79d	5235
506	99adb042d6f0dcafd290c3b9b70cf889a24ed0c5d0477908faec34cd3380b4ad	5238
507	fcf48f4f5318827539869fd63cdd49592f41e7f8f28910ca30d20407613c7192	5242
508	dade1f15a856b239a0a2d50b77c64a54581dde80b5b94159ea203e2f91247bd9	5256
509	1fa18bfd045f0304ad3e6ac1da46678c5bbf59e841ada5f5cdf916de5be64d26	5265
510	5497f65f8652e1c0b3867993d099510b712fbc578328fd0b1b19171c2b3981dd	5272
511	9a27411f9d21f3ec5e9b22139e7e2d727db0022ff80c30df20e3cd746e2f7635	5277
512	5cffa4c1473c8b2f0334d689593378af7ca4f3b33a555830dbda2b23cc4fe0d3	5288
513	749bd46e3259a628d556d6a906b0076742880307736b70010c6400154af5d554	5290
514	e506693b2c09357bbeb8b3bc8536c3371c682e597a1e033eedb8db8c3ef9e4f3	5325
515	c3a7e59ec3c3bbee4ffac624cb7ab7f5b6bcf17f5a05d57f682b61e2add942ab	5345
516	2133372facdbc5e676026fb9ffc6ec10141f55fec1a9712fb6df57858e18a3eb	5361
517	c41e2695797bdfc344572175e4da9fe7d0d3727f0339169943aa3f66b6a6c5ee	5362
518	b153f614f1d71a2d03fabdbc183eb800723bad70e7715c5233ec3be9e5e235e2	5365
519	a79eba7480881575b9526ed9211b5a9cc606d07cfbdcde803508bbb3554156dd	5382
520	48566047242ec96e7df00aca21d7780e1393268d0b9100c93ebc235fd699fd3d	5391
521	d85c94b2a2a317a76cc57768a090a3adb4ad85db2ca7e078542a4e79f3024515	5449
522	652c10dd332216ff49dfbd8e6a2a16653a69cac4dd9b0681b2b2c8e4b3393038	5464
523	b26be4210d7f360c9e625e0ecdcaaac75e46daa122d9be0e48ef854cb2506762	5468
524	6869147785288233a26526af0ecac59603a0f483827d87df21b63868794a7b3d	5473
525	8daba9ef0f5e1dbfc9715bcf973ffdb3514d3373953d29760d2a922c30058c84	5483
526	88e33d4db969732057831be72f54baf3da55ba3cee5212df01a2c75e62760019	5485
527	dd03e2a2acaca0f28071b10fe31f6a7ca4cccca409b2b5ba0f0357458d430169	5491
528	cc4c975ae2cba67a60e3a32e08586d33a1073efdb3c130ff41ba1a96648bda82	5507
529	5ef1dad4dbe0ea132f9bd0dd1799446545bfcc53725ac81ce10eff4c7de3e6c1	5522
530	ea7b3b829d531ea7f56e13726cfea51d1a761ac489913243cd7ae35c4bb0067c	5525
531	0a413adf0ca5f196d8b1ecb1ca6df824348d029c58c6c60a690ea042c3628657	5531
532	1c1e6c1032db278454ab66486879eee0d5bb3f7a7791bfcb2a752e9e13984d37	5576
533	ee3ec767f6ceb1d0774199db7f288d4e7cde68d813f18bec5ab1edbf1902a88e	5578
534	e4b0bc0f70dc7b93f69fcc14987562e1286827e19164a5b5099002052ecc0c19	5585
535	52fc59a4e572ffda02d970594ed200e151ec556effe7040257e294399cd1cf21	5590
536	d4b5f9078de7896802b90d14e519612ec930a47b89c92bcb2908617e8db55b1b	5595
537	17d2198dc40f7fc8accf3e30b1359ef8c4f91429854de9e08b43e4478d826b46	5607
538	d19059c48b263c6b5d156fc31f53a3a53872c96a1dcc5157f3c9bc0690ee51db	5627
539	d08ac2b448b5cf45c082c1f40012cd566c0c9724d049b89d06fc7274418320d6	5649
540	9454edb3ed7b498202480b596b863f8394703ff46f9e08f35c590d7f688e34fb	5661
541	c4d34e4ba10a1840316dcd665e7e41b23bd01a9196a8262a7cbf6cedd4fe7268	5666
542	46dbc1851367f89581386654bf4fa91ced99ad7cad4876790b768662a2858009	5668
543	6b76563415b42b100b899f8d04359b6c8c9cc58ca97315eebb314b18e716e2dd	5671
544	38c61b08b1e4e0aebf6c6892aac34fc01d5d87f2ea2abd0eb2de6c2e06178d05	5674
545	b29114b628b627ff64a9ec54ac283acaf9ce82d76d70aae73e28941d5b2498f0	5682
546	afc39a67a56b8b98789d703853f2e345928c642cd73c1a262006a216105653bd	5691
547	53f9f6743724a32a2d1b9ed102e8d582244a436760ed3ff18bb184a92a510f9c	5693
548	e780122d12837f321a10352257249dfe50e70b8221adae9bfe0bca547905a2a4	5699
549	5c81bc351255f9e63b818b02741ececdd97d3b2ff33d964673810bf20c52cb65	5701
550	31b4da51edeab64d7c977aca15bdd232041228fbf9ae17cb666470c004a1eb3e	5716
551	0d8c43f8fdb3d853ccde4db5a4d35d42b6539e1f3f3d4d7fc4a94cc7a8ef55ea	5727
552	9565727017020689fc812fbd466f3c0141bf690cff217e70d8573a69d94e8bc9	5759
553	54d0e1c60608f78bcbf6255ba14ed084aaff58c34c0bca95218d9148b8177285	5772
554	c46d1c7c74d95309af5e7ec3dd26308f1beb10124428aef3c1a1f7524db483d9	5776
555	48632fe7bf675f57b967b36a1e85c842fee93fd9068fb7123caff16a48af1042	5784
556	2a95f0377b49cf6363fc2c4728af5fce6a5941c0d029f3eb0d326b84e5f34f44	5794
557	aff1d150f25ed56931858c6f4e6f2683158e830ee7d8d991f072993c81caf6d4	5796
558	3b13d2313cb7f622caf9e2b3512c4185862f08fd284983f7ef3b67006316b872	5797
559	e49e38ab2a1a7670f06084a0c4f7ffdf3e356ddbb7db277360546dce9d996fd0	5824
560	c9bd3e0aba3c25559ece2d2881f8a9d6e8c2306c5aa1d148529c4f203881d099	5843
561	978a84811d16980307b4d5e9c6d7598b90bf9fa96668628c2e9d3226dd419798	5844
562	2842e5ae4cd08e74d8e0432064ad4b70c7f91111f2dab94cdeeaa79ee6abdaa1	5854
563	f4c2889b7889b45a8bad4e75ce0a29a4d6a02327347415785c4999c417d478e5	5874
564	34c0954ed2c0bec43114e238a23f33460d3c3f895c3677321d50c55b8df07a68	5887
565	0410531993579e46610b2d9d4bfb8e9df43300801c9b4e7fe112959202a993fe	5895
566	aa9ea0c9626c229b3585485f223fffc30174baa0128ef83863dce7aaf8c90759	5899
567	7bc1b854fcdd0b610e991a266644d87099aa8e972450486b5dac649add49ac20	5905
568	f5dc2ceaa85799cab76fe4767f460fddd1772f0477f7c9efad0cc2df41f7483f	5913
569	117090ce92c5670817dbc5f434f09af3fa1b3661d6aa2435255cf77a4f159bca	5915
570	6a9877715ccb2ef6cd73ad7eb2c343851c9bff643956a92e6823af6e549701c6	5925
571	452340c3b40965814c649c0bc8b14feebde144ea3caa81440de425c6c9d3f2e1	5932
572	d33bdd790dba3475592f9929e820b00d7afb48f1cfdc9e1d0d6b5551fd6d74fb	5939
573	fd3e9f3b9f74e89f7284698317c1d6c0b66ebd1210b4f28531e4a25059fc4e85	5955
574	07086a763e111b30c420e04c9ffbed6226e6eb8a383c743374c7b4867fd85824	5969
575	592b113ca8010472c2265e93792c8390163e314a8e5612aa8d3e3c722125ac54	5987
576	0eaa1dc067a1f93801d71685df751584458e49f8103523a3b4a4ea2c8341d263	5989
577	1372fd343f5073e355790f76cf912335c23a57da5c017bae58b65c7aaf3f399a	6008
578	3e603366ad4c97e4a42463c4cbd25c8af6d01bf4632177941db7aca01cee0a5d	6011
579	61f2c59d3ebc106ede958d952478ac8d3f316de14a5099f124d60bf933955d9c	6016
580	3e5853550604a50066bbe681a50338ee8cb0d08843d1ba2a015e0f85d0b0580a	6021
581	cad677b6e1a6f6305b3e9ff6e825e6f0988e689a2968f82682389bca6b9be564	6065
582	48cc96beeceb4872c99fe73336b03755d8c3220367285590fbfe2105eb78fa71	6068
583	493ba03a12996393d25ccaa5c71a53eb4982dd682772de343963f557223ceafb	6121
584	d95c24f249c850e7f8263d4a02616700be4a1f489e31e23b0870adb13d31f94a	6143
585	f1bbf3887ababdd83d77b5d6c26a7cad42141dd03b653df7c2040f6f5d8aa367	6176
586	923c35ad88c878cd94ccd8aa035b00c4307bc67b1f36aa6f13d467d9e738eb8d	6188
587	8df7c0cb7b4e4838e729b5ee221fb1fd49f64bbf6547dfb3410f84dd4cfb2994	6203
588	20f3178c8c14e011c9aaaa9b24369433ea41e0ebd5142ef5ae07db5d5386e222	6214
589	9a3b07f9d5be1cd5bb0160cf6e0a8f8fa4b2343f258c9aeb9265576db8a11e9a	6217
590	1932fb8a836cbead7957f4a03cdd12d02a55833c8f0f2771678d8b9c403b61ad	6218
591	f7732c26fc39ff198d406e7cbfbc1e433313678c609b00908ad2f6140f05fbfd	6219
592	b71cf25b7e3a4d0befbb1b4049e5315df800a08f52692cf9bc8f4a26dc15c529	6237
593	9c74b2130b8005bbb7f6d34daad2111d349ce59d33b10e24848e7ea108d65e5c	6238
594	c64a8a1b2f3eb7fb9c4917a470527211c886958f6c8bd816e78c279823073a59	6240
595	87173a96f8bfdf186ab4cecc2995aa08a0862d2c7aeb47a6e78e2215b641f99c	6249
596	f968bd8af8196a0637b1b0f366100b7ca621c19f1726088a5ac460f4601ba932	6252
597	0becc49fbe32b2317a235f84eec7c2f628f92e4cd6bf4975eb6baedfacd5c15b	6257
598	818c185c8582d9d1c329ba7136df289d1354cc330f89b2e00c957531634a07b4	6266
599	6c7235dcdf48108827dcb9af0efb4a612744fd8eb87cda0a3b515566e15535a7	6278
600	5d08666d31cf349de8ccdf92cccb56f067f70096ca70608a468a44d8f7ab9af8	6279
601	1a447496f187b801daaa04c42c9c7d325095f2afd024e25cf334ea4e57afb971	6280
602	381126f2aa727e4e52ded05373ec4c5ba29aeb7f9ba7dd814f37ea88fd0983bc	6310
603	4c523096c9613ef2e528c971a90e51c8de641bf5518febcd80a94d64b71c8955	6322
604	a9a7d7494d4a8d68561dd89f358d3664c9fb0f45934be4b96980123abaa6c440	6332
605	286fd94908028cefd52b2d383dc0abcf644dbcfed1b57e2a1207454dd0ee8ee7	6337
606	4328bf2c7eaae313f33d087d68d999b3edf27f6121788f1b261daf4e758a39ce	6339
607	94aa7454c49a1b21e08c1282e038b98db58937c0172f58f64c9f112e2527c1e9	6342
608	94c4fda7107506e8871d60a50b8e5c835a5c5445a084d9d3f04119406845a400	6348
609	121c662b0fac036397857ba0d75de204bf92d7c0a55d98c301ec062722443d99	6352
610	f2ecb94710a1d3d8ede2d1542e2ac10d0e0e8463564ffc37b193fb741f8f908f	6354
611	93cd63ee9ab0728fc911a50ac2b355cda662980b356d7b395f81d8f4b3ac0e66	6363
612	81a7bee8324a8bebe0c10c308503a95f94849ccf1a35ea552087bc88d7a33f2c	6371
613	0a8034bde8286dc6799b2249cf2503f5c25db15ef6a0f09e13fcaacb9dae108c	6382
614	5ca5b68499c45beb17af5eb2e81d1173fbc10e32d2365bfff7291c6bdb876922	6450
615	ddf2b75a2c5465c7541d5e7b91cb33c2e90445780a062c185b4ee2a9b952989e	6461
616	34b3f2c48dd1dd439c6b7c9c10b5b55a018e3f608500392ca3e39267dbeedba3	6474
617	af8127415a72effbd72949fda4643eeeb2b596d61d0cd79767349a4f46090ea4	6489
618	396405868ee98ca03257a8ed9b80499df235bc3e020fdb1e27e619da1074237c	6490
619	383b6dc1dfd352c77d5d407d2138a447a6dbc8b7661e4655625bcf4b9172638a	6501
620	e16ad6a3fd5195038870231b3c6fe2aae48de8c5e12194d475fac06a7abf3a08	6507
621	40f23ccc7abcea63ee48806db120b7aa9c80442ed75394085a090d85408b359d	6531
622	0229733870ed7d91cf9a8b541562b31298b96a381d7c7c50c52196c396874599	6532
623	7aec17c46e7f188e6c0667f155ffb8c7f37463838c05951f51d9d732d0941214	6544
624	64153a21fcb6e48761521109e8754b07bb4a1a03d5b2fc41feabd646525c1e3e	6556
625	a8be7ee8dfeca22be2d41189ff80d6a7cdf4fee22218e6a9cfd50ea2e0f44841	6557
626	f4f56f51872cab155b23ede6213719053cb4c74adbf54ca537632e30a222181d	6567
627	17c3af8b2aee87e55b8b9c61770638d49aff5632a0cf01a6774d20847b9fce24	6571
628	b727fcdc62302a6629caea165c5a15754a72874950b6ebe6e95b812acc54d1a5	6572
629	e81607704b3b952ec7746d77d95392533246df26351c591548e298635c1febda	6583
630	7a5701ab39a477842a25010aa28e83caae2325dcdd8e81b6721f0ea9b31b5c29	6607
631	8664230fd4d6327e68d5bd3a307e46fc69abb9526b83bd2f51a62eb6a65d1288	6635
632	2fc6cd8d5e3d45ab920e5164052f4fec76e8c4540e66e4d9a941139d5eb15d79	6643
633	5d047eeb9667d5d258c75dfe4d1a4b1e05124bf74ee32c34ddc4c0192bf4da6e	6653
634	a16c648c775f21e962fed6fad050b81a032a70731911ce7f3dabe9213cb4956a	6667
635	eade50ec91d5c2c8270daacd9241241072de808000f3c4d6cd38e0d870bc0f83	6668
636	df6619f32a24a00086888026eefac255364dbc4593c17e152537b79c2bacf2e5	6670
637	797a95da53b988f155fb56a394af68447c0be79bcf6ebad0a7e0ba698949dd0e	6671
638	87cb60b4267809cbf99fff4f0872548d4b5652d47a92f924e4583992f3ad5f37	6673
639	11e620e6b632f75606403db9dfaebd317f469e6705c92cf5ce15b39d636c15a1	6674
640	393513fd68620cee08f21350150d09cb2c1a734f09d98add1050fbedc1295057	6695
641	43ea67a3db0a78f9d70ad31daa4fa99f2d51507e8718e4fb7b23219b9dd86d51	6696
642	43d1b5a81a552798e39652f1f6ea100ef8ca25a352b962644e2a955d93f5135a	6718
643	b73eee33240f9aa2939eda53b2c16b5f8678b6878b4b42763068f92f0c521c61	6735
644	b14aabc57f6e690aedbca42f313ee614913c0c0a1ead280e14dff1c82e2257c0	6740
645	a71625910dab0a13f025a9dddc4656f6db863b4c748745b63fbee9b269514018	6761
646	45ba3dc0933e3c714699a278164c4c528bcdea21f642b6e4b07ab36b4fd99a14	6780
647	8b15c9dbc26490970f5652b888280bea15d0eedf379b2b21ec50eb55f0545c55	6791
648	22b70de1bb37f1bda5f46c8de0fb29f31ac9faab2ba78d45ebd81c31a8b7d62d	6794
649	157cb8b111e316bb06ebee229caf5ed3d0c8b81d1556cf1fd6b59c8b6c8a930e	6803
650	8ef9623a0320a98a8a6993876630791b6e3cd00fdadb0fd8cf91d3c19ff4e763	6808
651	f5708ee42d556e6dabe7a5aa941ee73f7b5b5fe5121f0cd06218f682405cebce	6811
652	4449435862194d2f36613763504e9d85da2dc9da297000506477ab29bf346d98	6837
653	ec2b207c621b59e099d25446dc50fd569ec76e40a580b333033e5e88881e4865	6859
654	1bfcd2dbaf3e0d1d86f1675e3a04cbfc9b3e3347885a0414971247831c1fb5c6	6876
655	a6823fde938a47af5bc7295f84820171d2b8e470efd1c8fc170f8cbc5a1af45c	6892
\.


--
-- Data for Name: block_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block_data (block_height, data) FROM stdin;
614	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3631342c2268617368223a2235636135623638343939633435626562313761663565623265383164313137336662633130653332643233363562666666373239316336626462383736393232222c22736c6f74223a363435307d2c22697373756572566b223a2262383866343233313138363032393330663932343631336663663766663939356430393934396366636435653239323262653436393565666662633333663435222c2270726576696f7573426c6f636b223a2230613830333462646538323836646336373939623232343963663235303366356332356462313565663661306630396531336663616163623964616531303863222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317768713376753438376c6d386a6c6b6e6b6a78717670796c3070796d3077726b3466766e79717a656568716365386d77327a39716b3239743838227d
615	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3631352c2268617368223a2264646632623735613263353436356337353431643565376239316362333363326539303434353738306130363263313835623465653261396239353239383965222c22736c6f74223a363436317d2c22697373756572566b223a2236336531313562353235306262323562306434303933323933383233393263623636383737303335303365333732356230316565306635656665383765353938222c2270726576696f7573426c6f636b223a2235636135623638343939633435626562313761663565623265383164313137336662633130653332643233363562666666373239316336626462383736393232222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6e743238367834336a753830306430776c387a72366d3275717366386b7365387574386339356c346c75777a6334686d3779736e3039686c67227d
616	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3631362c2268617368223a2233346233663263343864643164643433396336623763396331306235623535613031386533663630383530303339326361336533393236376462656564626133222c22736c6f74223a363437347d2c22697373756572566b223a2262383866343233313138363032393330663932343631336663663766663939356430393934396366636435653239323262653436393565666662633333663435222c2270726576696f7573426c6f636b223a2264646632623735613263353436356337353431643565376239316362333363326539303434353738306130363263313835623465653261396239353239383965222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317768713376753438376c6d386a6c6b6e6b6a78717670796c3070796d3077726b3466766e79717a656568716365386d77327a39716b3239743838227d
617	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3631372c2268617368223a2261663831323734313561373265666662643732393439666461343634336565656232623539366436316430636437393736373334396134663436303930656134222c22736c6f74223a363438397d2c22697373756572566b223a2262383866343233313138363032393330663932343631336663663766663939356430393934396366636435653239323262653436393565666662633333663435222c2270726576696f7573426c6f636b223a2233346233663263343864643164643433396336623763396331306235623535613031386533663630383530303339326361336533393236376462656564626133222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317768713376753438376c6d386a6c6b6e6b6a78717670796c3070796d3077726b3466766e79717a656568716365386d77327a39716b3239743838227d
618	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3631382c2268617368223a2233393634303538363865653938636130333235376138656439623830343939646632333562633365303230666462316532376536313964613130373432333763222c22736c6f74223a363439307d2c22697373756572566b223a2235383164383732366432326662376436303739303865323030666262326233643730313761643832353438336164366131663462393133393438386361303136222c2270726576696f7573426c6f636b223a2261663831323734313561373265666662643732393439666461343634336565656232623539366436316430636437393736373334396134663436303930656134222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31776e333230753233686663747a7a6661653579766e393937776c6c7433386675367834396a6666666e7736676b786c7930366d71686a30713466227d
619	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3631392c2268617368223a2233383362366463316466643335326337376435643430376432313338613434376136646263386237363631653436353536323562636634623931373236333861222c22736c6f74223a363530317d2c22697373756572566b223a2262383866343233313138363032393330663932343631336663663766663939356430393934396366636435653239323262653436393565666662633333663435222c2270726576696f7573426c6f636b223a2233393634303538363865653938636130333235376138656439623830343939646632333562633365303230666462316532376536313964613130373432333763222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317768713376753438376c6d386a6c6b6e6b6a78717670796c3070796d3077726b3466766e79717a656568716365386d77327a39716b3239743838227d
620	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a7b225f5f74797065223a22756e646566696e6564227d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22323134323937227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2230393536663536623439633437376434343365653133336163343636666138623165663666656237363230616233396464333166346537383230653235636436227d2c7b22696e646578223a312c2274784964223a2230393536663536623439633437376434343365653133336163343636666138623165663666656237363230616233396464333166346537383230653235636436227d2c7b22696e646578223a322c2274784964223a2230393536663536623439633437376434343365653133336163343636666138623165663666656237363230616233396464333166346537383230653235636436227d2c7b22696e646578223a332c2274784964223a2230393536663536623439633437376434343365653133336163343636666138623165663666656237363230616233396464333166346537383230653235636436227d2c7b22696e646578223a342c2274784964223a2230393536663536623439633437376434343365653133336163343636666138623165663666656237363230616233396464333166346537383230653235636436227d2c7b22696e646578223a352c2274784964223a2230393536663536623439633437376434343365653133336163343636666138623165663666656237363230616233396464333166346537383230653235636436227d2c7b22696e646578223a362c2274784964223a2230393536663536623439633437376434343365653133336163343636666138623165663666656237363230616233396464333166346537383230653235636436227d2c7b22696e646578223a372c2274784964223a2230393536663536623439633437376434343365653133336163343636666138623165663666656237363230616233396464333166346537383230653235636436227d2c7b22696e646578223a382c2274784964223a2230393536663536623439633437376434343365653133336163343636666138623165663666656237363230616233396464333166346537383230653235636436227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2235303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2232353039383234393731393936227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231323534393132353933313436227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22363237343536323936353733227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22333133373238313438323837227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313536383634303734313433227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223738343332303337303732227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223339323136303138353336227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223339323136303138353335227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a373934317d2c227769746864726177616c73223a5b7b227175616e74697479223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2232303036363136383638227d2c227374616b6541646472657373223a227374616b655f7465737431757263716a65663432657579637733376d75703532346d66346a3577716c77796c77776d39777a6a70347634326b736a6773676379227d2c7b227175616e74697479223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233333437313238353537227d2c227374616b6541646472657373223a227374616b655f7465737431757263346d767a6c326370346765646c337971327078373635396b726d7a757a676e6c3264706a6a677379646d71717867616d6a37227d5d7d2c226964223a2262646263306665363738306130636136366334643435323431333134643537623439316165656166626232656166363363616562633536323164313965383762222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2233363863663661313161633765323939313735363861333636616636326135393663623963646538313734626665376636653838333933656364623164636336222c226466373866663763643538386464626339623037353666306661326130353930303865306236366661613535656439633632386233393838303762623830613934353738636161616136333933336465333863306563306332313835613163356533346565396163346332353239653235623737343335306538353563373066225d2c5b2238373563316539386262626265396337376264646364373063613464373261633964303734303837346561643161663932393036323936353533663866333433222c223232326161336664636630333561353739653036663237623239396163386431313636376264643238663162663037636439333431633031663361393131626638633331333832343639343965363832373463666435396236303464303437396164323939353565636238363364643964623934313139666462366365613065225d2c5b2238363439393462663364643637393466646635366233623264343034363130313038396436643038393164346130616132343333316566383662306162386261222c226665363161653835646462363163373466356261663133303333623131663365343537653537663833363430656633393837666533616134376661643061346431376636303536313462636661633566386361353936393164653739343364306433303461616661633631633766636336396137623731346131383761633062225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22323134323937227d2c22686561646572223a7b22626c6f636b4e6f223a3632302c2268617368223a2265313661643661336664353139353033383837303233316233633666653261616534386465386335653132313934643437356661633036613761626633613038222c22736c6f74223a363530377d2c22697373756572566b223a2230613638323464663338323766383632376633623433336433396538386232613737663536373330336435366530393065376130386665323830343439303231222c2270726576696f7573426c6f636b223a2233383362366463316466643335326337376435643430376432313338613434376136646263386237363631653436353536323562636634623931373236333861222c2273697a65223a313334302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2235303139363535313538323838227d2c227478436f756e74223a312c22767266223a227672665f766b316d6535776535396d746179667474723267616733326c6730373535667135307179633672646776367874353661667a7068376671647a78333668227d
621	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3632312c2268617368223a2234306632336363633761626365613633656534383830366462313230623761613963383034343265643735333934303835613039306438353430386233353964222c22736c6f74223a363533317d2c22697373756572566b223a2262383866343233313138363032393330663932343631336663663766663939356430393934396366636435653239323262653436393565666662633333663435222c2270726576696f7573426c6f636b223a2265313661643661336664353139353033383837303233316233633666653261616534386465386335653132313934643437356661633036613761626633613038222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317768713376753438376c6d386a6c6b6e6b6a78717670796c3070796d3077726b3466766e79717a656568716365386d77327a39716b3239743838227d
622	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3632322c2268617368223a2230323239373333383730656437643931636639613862353431353632623331323938623936613338316437633763353063353231393663333936383734353939222c22736c6f74223a363533327d2c22697373756572566b223a2233373261356338663263643232643463336535363161343536366530613737396463666235616130316161393064333037393734313230643433316663663161222c2270726576696f7573426c6f636b223a2234306632336363633761626365613633656534383830366462313230623761613963383034343265643735333934303835613039306438353430386233353964222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316b307a34637834777a71777575616e353732757a653071373063323835326e706371776c78636e743263756367396579706735713264756c7279227d
623	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3632332c2268617368223a2237616563313763343665376631383865366330363637663135356666623863376633373436333833386330353935316635316439643733326430393431323134222c22736c6f74223a363534347d2c22697373756572566b223a2261323965616634326332666239366133646635343263353535633566346463316266656630326465643137663937366633646431666462376233366461616166222c2270726576696f7573426c6f636b223a2230323239373333383730656437643931636639613862353431353632623331323938623936613338316437633763353063353231393663333936383734353939222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316b77307878636a7561647267616e6765666e71766b6a7679346e7070396a3567323436676e61376135717736387735307a38787133356a7a6339227d
624	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b22626c6f62223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22626967696e74222c2276616c7565223a22373231227d2c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2268616e646c6531222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b226175676d656e746174696f6e73222c5b5d5d2c5b22636f7265222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2268616e646c65456e636f64696e67222c227574662d38225d2c5b226f67222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b22707265666978222c2224225d2c5b227465726d736f66757365222c2268747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f225d2c5b2276657273696f6e222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d5d7d5d2c5b226465736372697074696f6e222c225468652048616e646c65205374616e64617264225d2c5b22696d616765222c22697066733a2f2f736f6d652d68617368225d2c5b226e616d65222c222468616e646c6531225d2c5b2277656273697465222c2268747470733a2f2f63617264616e6f2e6f72672f225d5d7d5d5d7d5d5d7d5d5d7d7d2c22626f6479223a7b22617578696c696172794461746148617368223a2266396137363664303138666364333236626538323936366438643130333265343830383163636536326663626135666231323430326662363666616166366233222c22636572746966696361746573223a7b225f5f74797065223a22756e646566696e6564227d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22323334383435227d2c22696e70757473223a5b7b22696e646578223a372c2274784964223a2262646263306665363738306130636136366334643435323431333134643537623439316165656166626232656166363363616562633536323164313965383762227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303036343362303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303064653134303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613638363136653634366336353331222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b2263626f72223a2264383739396661613434366536313664363534613234373036383631373236643635373237333332343536393664363136373635353833383639373036363733336132663266376136343661333735373664366635613336353637393335363433333462333637353731343235333532356135303532376135333635363235363738363234633332366533313537343135313465343135383333366634633631353736353539373434393664363536343639363135343739373036353461363936643631363736353266366137303635363734323666363730303439366636373566366537353664363236353732303034363732363137323639373437393435363236313733363936333436366336353665363737343638303934613633363836313732363136333734363537323733346636633635373437343635373237333263366537353664363236353732373335313665373536643635373236393633356636643666363436393636363936353732373334303437373636353732373336393666366530313031623334383632363735663639366436313637363535383335363937303636373333613266326635313664353933363538363937313432373233393461346536653735363737353534353237333738333336663633373636623531363536643465346133353639343335323464363936353338333537373731376133393334346136663439373036363730356636393664363136373635353833353639373036363733336132663266353136643537363736613538343337383536353535333537353037393331353736643535353633333661366635303530333137333561346437363561333733313733366633363731373933363433333235613735366235323432343434363730366637323734363136633430343836343635373336393637366536353732353833383639373036363733336132663266376136323332373236383662333237383435333135343735353735373738373434383534376136663335363737343434363934353738343133363534373237363533346236393539366536313736373034353532333334633636343436623666346234373733366636333639363136633733343034363736363536653634366637323430343736343635363636313735366337343030346537333734363136653634363137323634356636393664363136373635353833383639373036363733336132663266376136323332373236383639366234333536373435333561376134623735363933353333366237363537346333383739373435363433373436333761363734353732333934323463366134363632353834323334353435383535373836383438373935333663363137333734356637353730363436313734363535663631363436343732363537333733353833393031653830666433303330626662313766323562666565353064326537316339656365363832393239313536393866393535656136363435656132623762653031323236386139356562616566653533303531363434303564663232636534313139613461333534396262663163646133643463373636313663363936343631373436353634356636323739353831633464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531346136393664363136373635356636383631373336383538323062636435386330646365656139376237313762636265306564633430623265363566633233323961346462396365333731366234376239306562353136376465353337333734363136653634363137323634356636393664363136373635356636383631373336383538323062336430366238363034616363393137323965346431306666356634326461343133376362623662393433323931663730336562393737363136373363393830346237333736363735663736363537323733363936663665343633313265333133353265333034633631363737323635363536343566373436353732366437333430353436643639363737323631373436353566373336393637356637323635373137353639373236353634303034343665373336363737303034353734373236393631366330303439373036363730356636313733373336353734353832336537343836326130396431376139636230333137346136626435666133303562383638343437356334633336303231353931633630366530343435303330333633383331333634383632363735663631373337333635373435383263396264663433376236383331643436643932643064623830663139663162373032313435653966646363343363363236346637613034646330303162633238303534363836353230343637323635363532303466366536356666222c22636f6e7374727563746f72223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c226669656c6473223a7b2263626f72223a22396661613434366536313664363534613234373036383631373236643635373237333332343536393664363136373635353833383639373036363733336132663266376136343661333735373664366635613336353637393335363433333462333637353731343235333532356135303532376135333635363235363738363234633332366533313537343135313465343135383333366634633631353736353539373434393664363536343639363135343739373036353461363936643631363736353266366137303635363734323666363730303439366636373566366537353664363236353732303034363732363137323639373437393435363236313733363936333436366336353665363737343638303934613633363836313732363136333734363537323733346636633635373437343635373237333263366537353664363236353732373335313665373536643635373236393633356636643666363436393636363936353732373334303437373636353732373336393666366530313031623334383632363735663639366436313637363535383335363937303636373333613266326635313664353933363538363937313432373233393461346536653735363737353534353237333738333336663633373636623531363536643465346133353639343335323464363936353338333537373731376133393334346136663439373036363730356636393664363136373635353833353639373036363733336132663266353136643537363736613538343337383536353535333537353037393331353736643535353633333661366635303530333137333561346437363561333733313733366633363731373933363433333235613735366235323432343434363730366637323734363136633430343836343635373336393637366536353732353833383639373036363733336132663266376136323332373236383662333237383435333135343735353735373738373434383534376136663335363737343434363934353738343133363534373237363533346236393539366536313736373034353532333334633636343436623666346234373733366636333639363136633733343034363736363536653634366637323430343736343635363636313735366337343030346537333734363136653634363137323634356636393664363136373635353833383639373036363733336132663266376136323332373236383639366234333536373435333561376134623735363933353333366237363537346333383739373435363433373436333761363734353732333934323463366134363632353834323334353435383535373836383438373935333663363137333734356637353730363436313734363535663631363436343732363537333733353833393031653830666433303330626662313766323562666565353064326537316339656365363832393239313536393866393535656136363435656132623762653031323236386139356562616566653533303531363434303564663232636534313139613461333534396262663163646133643463373636313663363936343631373436353634356636323739353831633464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531346136393664363136373635356636383631373336383538323062636435386330646365656139376237313762636265306564633430623265363566633233323961346462396365333731366234376239306562353136376465353337333734363136653634363137323634356636393664363136373635356636383631373336383538323062336430366238363034616363393137323965346431306666356634326461343133376362623662393433323931663730336562393737363136373363393830346237333736363735663736363537323733363936663665343633313265333133353265333034633631363737323635363536343566373436353732366437333430353436643639363737323631373436353566373336393637356637323635373137353639373236353634303034343665373336363737303034353734373236393631366330303439373036363730356636313733373336353734353832336537343836326130396431376139636230333137346136626435666133303562383638343437356334633336303231353931633630366530343435303330333633383331333634383632363735663631373337333635373435383263396264663433376236383331643436643932643064623830663139663162373032313435653966646363343363363236346637613034646330303162633238303534363836353230343637323635363532303466366536356666222c226974656d73223a5b7b2263626f72223a226161343436653631366436353461323437303638363137323664363537323733333234353639366436313637363535383338363937303636373333613266326637613634366133373537366436663561333635363739333536343333346233363735373134323533353235613530353237613533363536323536373836323463333236653331353734313531346534313538333336663463363135373635353937343439366436353634363936313534373937303635346136393664363136373635326636613730363536373432366636373030343936663637356636653735366436323635373230303436373236313732363937343739343536323631373336393633343636633635366536373734363830393461363336383631373236313633373436353732373334663663363537343734363537323733326336653735366436323635373237333531366537353664363537323639363335663664366636343639363636393635373237333430343737363635373237333639366636653031222c2264617461223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22427566666572222c2276616c7565223a223665363136643635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223234373036383631373236643635373237333332227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363436613337353736643666356133363536373933353634333334623336373537313432353335323561353035323761353336353632353637383632346333323665333135373431353134653431353833333666346336313537363535393734227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366436353634363936313534373937303635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223639366436313637363532663661373036353637227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236663637227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366636373566366537353664363236353732227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373236313732363937343739227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236323631373336393633227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366336353665363737343638227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2239227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223633363836313732363136333734363537323733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22366336353734373436353732373332633665373536643632363537323733227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236653735366436353732363936333566366436663634363936363639363537323733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223736363537323733363936663665227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d7d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d2c7b2263626f72223a2262333438363236373566363936643631363736353538333536393730363637333361326632663531366435393336353836393731343237323339346134653665373536373735353435323733373833333666363337363662353136353664346534613335363934333532346436393635333833353737373137613339333434613666343937303636373035663639366436313637363535383335363937303636373333613266326635313664353736373661353834333738353635353533353735303739333135373664353535363333366136663530353033313733356134643736356133373331373336663336373137393336343333323561373536623532343234343436373036663732373436313663343034383634363537333639363736653635373235383338363937303636373333613266326637613632333237323638366233323738343533313534373535373537373837343438353437613666333536373734343436393435373834313336353437323736353334623639353936653631373637303435353233333463363634343662366634623437373336663633363936313663373334303436373636353665363436663732343034373634363536363631373536633734303034653733373436313665363436313732363435663639366436313637363535383338363937303636373333613266326637613632333237323638363936623433353637343533356137613462373536393335333336623736353734633338373937343536343337343633376136373435373233393432346336613436363235383432333435343538353537383638343837393533366336313733373435663735373036343631373436353566363136343634373236353733373335383339303165383066643330333062666231376632356266656535306432653731633965636536383239323931353639386639353565613636343565613262376265303132323638613935656261656665353330353136343430356466323263653431313961346133353439626266316364613364346337363631366336393634363137343635363435663632373935383163346461393635613034396466643135656431656531396662613665323937346130623739666334313664643137393661316639376635653134613639366436313637363535663638363137333638353832306263643538633064636565613937623731376263626530656463343062326536356663323332396134646239636533373136623437623930656235313637646535333733373436313665363436313732363435663639366436313637363535663638363137333638353832306233643036623836303461636339313732396534643130666635663432646134313337636262366239343332393166373033656239373736313637336339383034623733373636373566373636353732373336393666366534363331326533313335326533303463363136373732363536353634356637343635373236643733343035343664363936373732363137343635356637333639363735663732363537313735363937323635363430303434366537333636373730303435373437323639363136633030343937303636373035663631373337333635373435383233653734383632613039643137613963623033313734613662643566613330356238363834343735633463333630323135393163363036653034343530333033363338333133363438363236373566363137333733363537343538326339626466343337623638333164343664393264306462383066313966316237303231343565396664636334336336323634663761303464633030316263323830353436383635323034363732363536353230346636653635222c2264617461223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236323637356636393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663531366435393336353836393731343237323339346134653665373536373735353435323733373833333666363337363662353136353664346534613335363934333532346436393635333833353737373137613339333434613666227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373036363730356636393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663531366435373637366135383433373835363535353335373530373933313537366435353536333336613666353035303331373335613464373635613337333137333666333637313739333634333332356137353662353234323434227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373036663732373436313663227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236343635373336393637366536353732227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363233323732363836623332373834353331353437353537353737383734343835343761366633353637373434343639343537383431333635343732373635333462363935393665363137363730343535323333346336363434366236663462227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223733366636333639363136633733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373636353665363436663732227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223634363536363631373536633734227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237333734363136653634363137323634356636393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363233323732363836393662343335363734353335613761346237353639333533333662373635373463333837393734353634333734363337613637343537323339343234633661343636323538343233343534353835353738363834383739227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223663363137333734356637353730363436313734363535663631363436343732363537333733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22303165383066643330333062666231376632356266656535306432653731633965636536383239323931353639386639353565613636343565613262376265303132323638613935656261656665353330353136343430356466323263653431313961346133353439626266316364613364227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373636313663363936343631373436353634356636323739227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223639366436313637363535663638363137333638227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2262636435386330646365656139376237313762636265306564633430623265363566633233323961346462396365333731366234376239306562353136376465227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223733373436313665363436313732363435663639366436313637363535663638363137333638227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2262336430366238363034616363393137323965346431306666356634326461343133376362623662393433323931663730336562393737363136373363393830227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237333736363735663736363537323733363936663665227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22333132653331333532653330227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22363136373732363536353634356637343635373236643733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236643639363737323631373436353566373336393637356637323635373137353639373236353634227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223665373336363737227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237343732363936313663227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373036363730356636313733373336353734227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2265373438363261303964313761396362303331373461366264356661333035623836383434373563346333363032313539316336303665303434353033303336333833313336227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236323637356636313733373336353734227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2239626466343337623638333164343664393264306462383066313966316237303231343565396664636334336336323634663761303464633030316263323830353436383635323034363732363536353230346636653635227d5d5d7d7d5d7d7d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303036343362303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303064653134303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613638363136653634366336353331222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223130303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c7370396a6e32346e6366736172616863726734746b6e74396775703775663775616b3275397972326532346471717a70717764222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223339323035373833363931227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a373938347d7d2c226964223a2233626664303233663733313735306262613865636234656162303533613235393365623235633330363237366664393638333839376634323033356665323334222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2233363863663661313161633765323939313735363861333636616636326135393663623963646538313734626665376636653838333933656364623164636336222c226634386536663166366264313831616339613339323562646439636235326333613533303134653837623431366263663735626566613133353836613734656163346666666539336132656261633266313235303633373766376161383035643262383237653565313135353364303534393464346664396233333439663033225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22323334383435227d2c22686561646572223a7b22626c6f636b4e6f223a3632342c2268617368223a2236343135336132316663623665343837363135323131303965383735346230376262346131613033643562326663343166656162643634363532356331653365222c22736c6f74223a363535367d2c22697373756572566b223a2233373261356338663263643232643463336535363161343536366530613737396463666235616130316161393064333037393734313230643433316663663161222c2270726576696f7573426c6f636b223a2237616563313763343665376631383865366330363637663135356666623863376633373436333833386330353935316635316439643733326430393431323134222c2273697a65223a313730342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223339323135373833363931227d2c227478436f756e74223a312c22767266223a227672665f766b316b307a34637834777a71777575616e353732757a653071373063323835326e706371776c78636e743263756367396579706735713264756c7279227d
625	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3632352c2268617368223a2261386265376565386466656361323262653264343131383966663830643661376364663466656532323231386536613963666435306561326530663434383431222c22736c6f74223a363535377d2c22697373756572566b223a2238613437303766623763363739396238346232663463646265343566646339306233646566353736623132326131343439373135656432653264633964383965222c2270726576696f7573426c6f636b223a2236343135336132316663623665343837363135323131303965383735346230376262346131613033643562326663343166656162643634363532356331653365222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773038616a7a3470727338386a3665687a393566657972786a653276747661746c346a6166366a75683930737872676465656673356e6368756c227d
626	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3632362c2268617368223a2266346635366635313837326361623135356232336564653632313337313930353363623463373461646266353463613533373633326533306132323231383164222c22736c6f74223a363536377d2c22697373756572566b223a2230613638323464663338323766383632376633623433336433396538386232613737663536373330336435366530393065376130386665323830343439303231222c2270726576696f7573426c6f636b223a2261386265376565386466656361323262653264343131383966663830643661376364663466656532323231386536613963666435306561326530663434383431222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316d6535776535396d746179667474723267616733326c6730373535667135307179633672646776367874353661667a7068376671647a78333668227d
627	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3632372c2268617368223a2231376333616638623261656538376535356238623963363137373036333864343961666635363332613063663031613637373464323038343762396663653234222c22736c6f74223a363537317d2c22697373756572566b223a2236336531313562353235306262323562306434303933323933383233393263623636383737303335303365333732356230316565306635656665383765353938222c2270726576696f7573426c6f636b223a2266346635366635313837326361623135356232336564653632313337313930353363623463373461646266353463613533373633326533306132323231383164222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6e743238367834336a753830306430776c387a72366d3275717366386b7365387574386339356c346c75777a6334686d3779736e3039686c67227d
628	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3632382c2268617368223a2262373237666364633632333032613636323963616561313635633561313537353461373238373439353062366562653665393562383132616363353464316135222c22736c6f74223a363537327d2c22697373756572566b223a2263656534623662646232343166313435356562366239343866363939653561633263633133393261356165663439336563316230316435326564623738626637222c2270726576696f7573426c6f636b223a2231376333616638623261656538376535356238623963363137373036333864343961666635363332613063663031613637373464323038343762396663653234222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173383271736a326a7a383571783066386b6533616c37347a676a783577747072666576616d3765747171393776326d3830687171337065307467227d
629	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3632392c2268617368223a2265383136303737303462336239353265633737343664373764393533393235333332343664663236333531633539313534386532393836333563316665626461222c22736c6f74223a363538337d2c22697373756572566b223a2236336531313562353235306262323562306434303933323933383233393263623636383737303335303365333732356230316565306635656665383765353938222c2270726576696f7573426c6f636b223a2262373237666364633632333032613636323963616561313635633561313537353461373238373439353062366562653665393562383132616363353464316135222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6e743238367834336a753830306430776c387a72366d3275717366386b7365387574386339356c346c75777a6334686d3779736e3039686c67227d
630	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3633302c2268617368223a2237613537303161623339613437373834326132353031306161323865383363616165323332356463646438653831623637323166306561396233316235633239222c22736c6f74223a363630377d2c22697373756572566b223a2230613638323464663338323766383632376633623433336433396538386232613737663536373330336435366530393065376130386665323830343439303231222c2270726576696f7573426c6f636b223a2265383136303737303462336239353265633737343664373764393533393235333332343664663236333531633539313534386532393836333563316665626461222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316d6535776535396d746179667474723267616733326c6730373535667135307179633672646776367874353661667a7068376671647a78333668227d
631	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d2c226f776e657273223a5b227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973225d2c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22353030303030303030303030303030227d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e31222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c227265776172644163636f756e74223a227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973222c22767266223a2232656535613463343233323234626239633432313037666331386136303535366436613833636563316439646433376137316635366166373139386663373539227d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22696e70757473223a5b7b22696e646578223a322c2274784964223a2265363232623561623765313364346435306236376437666566333935356439653264323237366335656461613030666164646535333130376637626632343337227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936383230313131227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a383034377d7d2c226964223a2234663061653435643238636437636639306365313234666139646261363238383564613066323436376532656138326636386561646138646232306266333562222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223838333366643937303434343763663435646638616662663736623533376436353063356365306537386235363135346462663338333234616137396561623336396162633231633231623065626531356232346563623632376462346466343935386564373838393265653834393034343966373332356165303839383035225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c226666623365326333393930333233353431343764653330373936303831663732613537636466316634666139633838623364386635313034346431333536316336306136323737343665633361383135313835666634373065383237353564333236613933633736366238653466316538323365343731626361346638623030225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22686561646572223a7b22626c6f636b4e6f223a3633312c2268617368223a2238363634323330666434643633323765363864356264336133303765343666633639616262393532366238336264326635316136326562366136356431323838222c22736c6f74223a363633357d2c22697373756572566b223a2235383164383732366432326662376436303739303865323030666262326233643730313761643832353438336164366131663462393133393438386361303136222c2270726576696f7573426c6f636b223a2237613537303161623339613437373834326132353031306161323865383363616165323332356463646438653831623637323166306561396233316235633239222c2273697a65223a3535342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383230313131227d2c227478436f756e74223a312c22767266223a227672665f766b31776e333230753233686663747a7a6661653579766e393937776c6c7433386675367834396a6666666e7736676b786c7930366d71686a30713466227d
632	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3633322c2268617368223a2232666336636438643565336434356162393230653531363430353266346665633736653863343534306536366534643961393431313339643565623135643739222c22736c6f74223a363634337d2c22697373756572566b223a2261323965616634326332666239366133646635343263353535633566346463316266656630326465643137663937366633646431666462376233366461616166222c2270726576696f7573426c6f636b223a2238363634323330666434643633323765363864356264336133303765343666633639616262393532366238336264326635316136326562366136356431323838222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316b77307878636a7561647267616e6765666e71766b6a7679346e7070396a3567323436676e61376135717736387735307a38787133356a7a6339227d
633	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3633332c2268617368223a2235643034376565623936363764356432353863373564666534643161346231653035313234626637346565333263333464646334633031393262663464613665222c22736c6f74223a363635337d2c22697373756572566b223a2261323965616634326332666239366133646635343263353535633566346463316266656630326465643137663937366633646431666462376233366461616166222c2270726576696f7573426c6f636b223a2232666336636438643565336434356162393230653531363430353266346665633736653863343534306536366534643961393431313339643565623135643739222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316b77307878636a7561647267616e6765666e71766b6a7679346e7070396a3567323436676e61376135717736387735307a38787133356a7a6339227d
634	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3633342c2268617368223a2261313663363438633737356632316539363266656436666164303530623831613033326137303733313931316365376633646162653932313363623439353661222c22736c6f74223a363636377d2c22697373756572566b223a2262383866343233313138363032393330663932343631336663663766663939356430393934396366636435653239323262653436393565666662633333663435222c2270726576696f7573426c6f636b223a2235643034376565623936363764356432353863373564666534643161346231653035313234626637346565333263333464646334633031393262663464613665222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317768713376753438376c6d386a6c6b6e6b6a78717670796c3070796d3077726b3466766e79717a656568716365386d77327a39716b3239743838227d
635	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3633352c2268617368223a2265616465353065633931643563326338323730646161636439323431323431303732646538303830303066336334643663643338653064383730626330663833222c22736c6f74223a363636387d2c22697373756572566b223a2263656534623662646232343166313435356562366239343866363939653561633263633133393261356165663439336563316230316435326564623738626637222c2270726576696f7573426c6f636b223a2261313663363438633737356632316539363266656436666164303530623831613033326137303733313931316365376633646162653932313363623439353661222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173383271736a326a7a383571783066386b6533616c37347a676a783577747072666576616d3765747171393776326d3830687171337065307467227d
636	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b654b6579526567697374726174696f6e4365727469666963617465222c227374616b654b657948617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832227d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313639393839227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2234663061653435643238636437636639306365313234666139646261363238383564613066323436376532656138326636386561646138646232306266333562227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393933363530313232227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a383130387d7d2c226964223a2233356264653062303832303137333566626335663130646337323861333930333932343438343165636435626162333838383533643536326632373932366637222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223338313066376264643265623464363633366162326539383164636139383930323139363265613233663737376465653430353565373239393864613136376135326363336636306433386331303339353164643432333663336631353465356465316239663534633966613833376138343765653361376130323137623032225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313639393839227d2c22686561646572223a7b22626c6f636b4e6f223a3633362c2268617368223a2264663636313966333261323461303030383638383830323665656661633235353336346462633435393363313765313532353337623739633262616366326535222c22736c6f74223a363637307d2c22697373756572566b223a2236663433303435383532363138336235323734353963653130303263343538376633656339363531626535633961303265323561373137636638383338303032222c2270726576696f7573426c6f636b223a2265616465353065633931643563326338323730646161636439323431323431303732646538303830303066336334643663643338653064383730626330663833222c2273697a65223a3332392c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936363530313232227d2c227478436f756e74223a312c22767266223a227672665f766b316a6e6a6e753937773777387471683072766e356d79666776787273786d6a32746b366a33666c6770357666306577786d75686c71657766716e77227d
637	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3633372c2268617368223a2237393761393564613533623938386631353566623536613339346166363834343763306265373962636636656261643061376530626136393839343964643065222c22736c6f74223a363637317d2c22697373756572566b223a2238613437303766623763363739396238346232663463646265343566646339306233646566353736623132326131343439373135656432653264633964383965222c2270726576696f7573426c6f636b223a2264663636313966333261323461303030383638383830323665656661633235353336346462633435393363313765313532353337623739633262616366326535222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773038616a7a3470727338386a3665687a393566657972786a653276747661746c346a6166366a75683930737872676465656673356e6368756c227d
638	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3633382c2268617368223a2238376362363062343236373830396362663939666666346630383732353438643462353635326434376139326639323465343538333939326633616435663337222c22736c6f74223a363637337d2c22697373756572566b223a2235383164383732366432326662376436303739303865323030666262326233643730313761643832353438336164366131663462393133393438386361303136222c2270726576696f7573426c6f636b223a2237393761393564613533623938386631353566623536613339346166363834343763306265373962636636656261643061376530626136393839343964643065222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31776e333230753233686663747a7a6661653579766e393937776c6c7433386675367834396a6666666e7736676b786c7930366d71686a30713466227d
639	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3633392c2268617368223a2231316536323065366236333266373536303634303364623964666165626433313766343639653637303563393263663563653135623339643633366331356131222c22736c6f74223a363637347d2c22697373756572566b223a2233373261356338663263643232643463336535363161343536366530613737396463666235616130316161393064333037393734313230643433316663663161222c2270726576696f7573426c6f636b223a2238376362363062343236373830396362663939666666346630383732353438643462353635326434376139326639323465343538333939326633616435663337222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316b307a34637834777a71777575616e353732757a653071373063323835326e706371776c78636e743263756367396579706735713264756c7279227d
640	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c227374616b654b657948617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832227d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313735373533227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2233356264653062303832303137333566626335663130646337323861333930333932343438343165636435626162333838383533643536326632373932366637227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393930343734333639227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a383131347d7d2c226964223a2263636561376365306334363031326634373461383438376562666639643630366631303333626330353433336162396237623334623735323739653732633061222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223861316466323834666561623034303961363230323038356134636435346132623534396365313533326630323737346361393733353638623762633131643138356631373062343163313335373739306439323963303164386365393465343639663735616264653232363461303534343031646131636231333066373031225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c226238663830623038663561633536623838393531653162336233656334336665623134616137643534396566376163646536613733376464656237333037623836343231636335626361663164626337663538376363356330303031313761363162323438336238626432656432613631386539313232356537666433373061225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313735373533227d2c22686561646572223a7b22626c6f636b4e6f223a3634302c2268617368223a2233393335313366643638363230636565303866323133353031353064303963623263316137333466303964393861646431303530666265646331323935303537222c22736c6f74223a363639357d2c22697373756572566b223a2230613638323464663338323766383632376633623433336433396538386232613737663536373330336435366530393065376130386665323830343439303231222c2270726576696f7573426c6f636b223a2231316536323065366236333266373536303634303364623964666165626433313766343639653637303563393263663563653135623339643633366331356131222c2273697a65223a3436302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393933343734333639227d2c227478436f756e74223a312c22767266223a227672665f766b316d6535776535396d746179667474723267616733326c6730373535667135307179633672646776367874353661667a7068376671647a78333668227d
641	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3634312c2268617368223a2234336561363761336462306137386639643730616433316461613466613939663264353135303765383731386534666237623233323139623964643836643531222c22736c6f74223a363639367d2c22697373756572566b223a2262383866343233313138363032393330663932343631336663663766663939356430393934396366636435653239323262653436393565666662633333663435222c2270726576696f7573426c6f636b223a2233393335313366643638363230636565303866323133353031353064303963623263316137333466303964393861646431303530666265646331323935303537222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317768713376753438376c6d386a6c6b6e6b6a78717670796c3070796d3077726b3466766e79717a656568716365386d77327a39716b3239743838227d
642	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3634322c2268617368223a2234336431623561383161353532373938653339363532663166366561313030656638636132356133353262393632363434653261393535643933663531333561222c22736c6f74223a363731387d2c22697373756572566b223a2236663433303435383532363138336235323734353963653130303263343538376633656339363531626535633961303265323561373137636638383338303032222c2270726576696f7573426c6f636b223a2234336561363761336462306137386639643730616433316461613466613939663264353135303765383731386534666237623233323139623964643836643531222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6e6a6e753937773777387471683072766e356d79666776787273786d6a32746b366a33666c6770357666306577786d75686c71657766716e77227d
643	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3634332c2268617368223a2262373365656533333234306639616132393339656461353362326331366235663836373862363837386234623432373633303638663932663063353231633631222c22736c6f74223a363733357d2c22697373756572566b223a2230613638323464663338323766383632376633623433336433396538386232613737663536373330336435366530393065376130386665323830343439303231222c2270726576696f7573426c6f636b223a2234336431623561383161353532373938653339363532663166366561313030656638636132356133353262393632363434653261393535643933663531333561222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316d6535776535396d746179667474723267616733326c6730373535667135307179633672646776367874353661667a7068376671647a78333668227d
644	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d2c226f776e657273223a5b227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576225d2c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223530303030303030227d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e32222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c227265776172644163636f756e74223a227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576222c22767266223a2236343164303432656433396332633235386433383130363063313432346634306566386162666532356566353636663463623232343737633432623261303134227d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313831363439227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2261363332393064383864303837323130363734353838643361653233626464356564333666636634326365383962316232386433393432393039343135663864227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613238333233323332323936383631366536343663363533363338222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383138333531227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a383135387d7d2c226964223a2232323765613931393533623131343039666636383933663631666438323432383766323662316236326635613232336130666461336561643134353962366565222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c226161366463663437623334323639333433326332343531666437353632633466343039623665353337656237376138386436613931613761666539346432623138626539343930323232323738396537383363316432616166353733396262323535373235353034643438373631656164356263313437656265356130653033225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223865663161663662626439386532316263356338323136306566623631313432303830663365303966363661363464316561653434333461636165373761616366626166623438626463336532313239346335313461656236313237373661616236306230633437636464326466656463313762313439383836333664323036225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313831363439227d2c22686561646572223a7b22626c6f636b4e6f223a3634342c2268617368223a2262313461616263353766366536393061656462636134326633313365653631343931336330633061316561643238306531346466663163383265323235376330222c22736c6f74223a363734307d2c22697373756572566b223a2236336531313562353235306262323562306434303933323933383233393263623636383737303335303365333732356230316565306635656665383765353938222c2270726576696f7573426c6f636b223a2262373365656533333234306639616132393339656461353362326331366235663836373862363837386234623432373633303638663932663063353231633631222c2273697a65223a3539342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383138333531227d2c227478436f756e74223a312c22767266223a227672665f766b316a6e743238367834336a753830306430776c387a72366d3275717366386b7365387574386339356c346c75777a6334686d3779736e3039686c67227d
645	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3634352c2268617368223a2261373136323539313064616230613133663032356139646464633436353666366462383633623463373438373435623633666265653962323639353134303138222c22736c6f74223a363736317d2c22697373756572566b223a2263656534623662646232343166313435356562366239343866363939653561633263633133393261356165663439336563316230316435326564623738626637222c2270726576696f7573426c6f636b223a2262313461616263353766366536393061656462636134326633313365653631343931336330633061316561643238306531346466663163383265323235376330222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173383271736a326a7a383571783066386b6533616c37347a676a783577747072666576616d3765747171393776326d3830687171337065307467227d
646	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3634362c2268617368223a2234356261336463303933336533633731343639396132373831363463346335323862636465613231663634326236653462303761623336623466643939613134222c22736c6f74223a363738307d2c22697373756572566b223a2262383866343233313138363032393330663932343631336663663766663939356430393934396366636435653239323262653436393565666662633333663435222c2270726576696f7573426c6f636b223a2261373136323539313064616230613133663032356139646464633436353666366462383633623463373438373435623633666265653962323639353134303138222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317768713376753438376c6d386a6c6b6e6b6a78717670796c3070796d3077726b3466766e79717a656568716365386d77327a39716b3239743838227d
647	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3634372c2268617368223a2238623135633964626332363439303937306635363532623838383238306265613135643065656466333739623262323165633530656235356630353435633535222c22736c6f74223a363739317d2c22697373756572566b223a2236663433303435383532363138336235323734353963653130303263343538376633656339363531626535633961303265323561373137636638383338303032222c2270726576696f7573426c6f636b223a2234356261336463303933336533633731343639396132373831363463346335323862636465613231663634326236653462303761623336623466643939613134222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6e6a6e753937773777387471683072766e356d79666776787273786d6a32746b366a33666c6770357666306577786d75686c71657766716e77227d
648	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b654b6579526567697374726174696f6e4365727469666963617465222c227374616b654b657948617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732227d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313733353533227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2263373134623066383430353437313135323836346433653563353663323931373731373366613735336666353332393861656333383335386232656135383464227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2265643833633132313864643738386230343635373533383034316135616431353239336230633731336263376136306636323465363531613734343235343433222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b2265643833633132313864643738386230343635373533383034316135616431353239336230633731336263376136306636323465363531613734343535343438222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b226564383363313231386464373838623034363537353338303431613561643135323933623063373133626337613630663632346536353161222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b2265643833633132313864643738386230343635373533383034316135616431353239336230633731336263376136306636323465363531613734346434393465222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383236343437227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a383233317d7d2c226964223a2262326435643234346466643832343663333137346638373166613764623339346538333737306563396231313435623963363738393163336537646634623837222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223130663531626664326466303430306234636632613138343766666636306430663238333234653266316532343334306561613362303164306463326266303832343834646331353131313437316563383239663637333465373831623333306534653162363365353233373037303536383033613636383365643265323062225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313733353533227d2c22686561646572223a7b22626c6f636b4e6f223a3634382c2268617368223a2232326237306465316262333766316264613566343663386465306662323966333161633966616162326261373864343565626438316333316138623764363264222c22736c6f74223a363739347d2c22697373756572566b223a2233373261356338663263643232643463336535363161343536366530613737396463666235616130316161393064333037393734313230643433316663663161222c2270726576696f7573426c6f636b223a2238623135633964626332363439303937306635363532623838383238306265613135643065656466333739623262323165633530656235356630353435633535222c2273697a65223a3431302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383236343437227d2c227478436f756e74223a312c22767266223a227672665f766b316b307a34637834777a71777575616e353732757a653071373063323835326e706371776c78636e743263756367396579706735713264756c7279227d
649	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3634392c2268617368223a2231353763623862313131653331366262303665626565323239636166356564336430633862383164313535366366316664366235396338623663386139333065222c22736c6f74223a363830337d2c22697373756572566b223a2261323965616634326332666239366133646635343263353535633566346463316266656630326465643137663937366633646431666462376233366461616166222c2270726576696f7573426c6f636b223a2232326237306465316262333766316264613566343663386465306662323966333161633966616162326261373864343565626438316333316138623764363264222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316b77307878636a7561647267616e6765666e71766b6a7679346e7070396a3567323436676e61376135717736387735307a38787133356a7a6339227d
650	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3635302c2268617368223a2238656639363233613033323061393861386136393933383736363330373931623665336364303066646164623066643863663931643363313966663465373633222c22736c6f74223a363830387d2c22697373756572566b223a2263656534623662646232343166313435356562366239343866363939653561633263633133393261356165663439336563316230316435326564623738626637222c2270726576696f7573426c6f636b223a2231353763623862313131653331366262303665626565323239636166356564336430633862383164313535366366316664366235396338623663386139333065222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173383271736a326a7a383571783066386b6533616c37347a676a783577747072666576616d3765747171393776326d3830687171337065307467227d
651	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3635312c2268617368223a2266353730386565343264353536653664616265376135616139343165653733663762356235666535313231663063643036323138663638323430356365626365222c22736c6f74223a363831317d2c22697373756572566b223a2236336531313562353235306262323562306434303933323933383233393263623636383737303335303365333732356230316565306635656665383765353938222c2270726576696f7573426c6f636b223a2238656639363233613033323061393861386136393933383736363330373931623665336364303066646164623066643863663931643363313966663465373633222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6e743238367834336a753830306430776c387a72366d3275717366386b7365387574386339356c346c75777a6334686d3779736e3039686c67227d
652	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c227374616b654b657948617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732227d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313738373435227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2266643164653335376662303432343362353363663661333864303532323333616166653133343637386130353834636665633837666336353165333464333065227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961343436663735363236633635343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2232227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396134383635366336633666343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613534363537333734343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383231323535227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a383235317d7d2c226964223a2263333336343238626130376136656633316132346631396236303566343865373336386130646134303664623038636335366534343566326365343739373934222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c223763303563333966383035633733373838373466343434303837666563613665373336663038656235633537306662333362363964343964613737323166303331633137366165333234646332633932353961646163623462626361373461353733363933316337663562643339383465313837346633643135666135373039225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c226162643737656663303532386266366636393936343532653331646463313439643332396130386436323865643765633235366233313739613536396363383561663563373264636261343730366637613937663366363661663638613130623438323466316564353632363538313261626632616635653631666334303062225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313738373435227d2c22686561646572223a7b22626c6f636b4e6f223a3635322c2268617368223a2234343439343335383632313934643266333636313337363335303465396438356461326463396461323937303030353036343737616232396266333436643938222c22736c6f74223a363833377d2c22697373756572566b223a2261323965616634326332666239366133646635343263353535633566346463316266656630326465643137663937366633646431666462376233366461616166222c2270726576696f7573426c6f636b223a2266353730386565343264353536653664616265376135616139343165653733663762356235666535313231663063643036323138663638323430356365626365222c2273697a65223a3532382c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383231323535227d2c227478436f756e74223a312c22767266223a227672665f766b316b77307878636a7561647267616e6765666e71766b6a7679346e7070396a3567323436676e61376135717736387735307a38787133356a7a6339227d
653	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3635332c2268617368223a2265633262323037633632316235396530393964323534343664633530666435363965633736653430613538306233333330333365356538383838316534383635222c22736c6f74223a363835397d2c22697373756572566b223a2262383866343233313138363032393330663932343631336663663766663939356430393934396366636435653239323262653436393565666662633333663435222c2270726576696f7573426c6f636b223a2234343439343335383632313934643266333636313337363335303465396438356461326463396461323937303030353036343737616232396266333436643938222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317768713376753438376c6d386a6c6b6e6b6a78717670796c3070796d3077726b3466766e79717a656568716365386d77327a39716b3239743838227d
654	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3635342c2268617368223a2231626663643264626166336530643164383666313637356533613034636266633962336533333437383835613034313439373132343738333163316662356336222c22736c6f74223a363837367d2c22697373756572566b223a2236336531313562353235306262323562306434303933323933383233393263623636383737303335303365333732356230316565306635656665383765353938222c2270726576696f7573426c6f636b223a2265633262323037633632316235396530393964323534343664633530666435363965633736653430613538306233333330333365356538383838316534383635222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6e743238367834336a753830306430776c387a72366d3275717366386b7365387574386339356c346c75777a6334686d3779736e3039686c67227d
655	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3635352c2268617368223a2261363832336664653933386134376166356263373239356638343832303137316432623865343730656664316338666331373066386362633561316166343563222c22736c6f74223a363839327d2c22697373756572566b223a2236663433303435383532363138336235323734353963653130303263343538376633656339363531626535633961303265323561373137636638383338303032222c2270726576696f7573426c6f636b223a2231626663643264626166336530643164383666313637356533613034636266633962336533333437383835613034313439373132343738333163316662356336222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6e6a6e753937773777387471683072766e356d79666776787273786d6a32746b366a33666c6770357666306577786d75686c71657766716e77227d
594	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3539342c2268617368223a2263363461386131623266336562376662396334393137613437303532373231316338383639353866366338626438313665373863323739383233303733613539222c22736c6f74223a363234307d2c22697373756572566b223a2261323965616634326332666239366133646635343263353535633566346463316266656630326465643137663937366633646431666462376233366461616166222c2270726576696f7573426c6f636b223a2239633734623231333062383030356262623766366433346461616432313131643334396365353964333362313065323438343865376561313038643635653563222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316b77307878636a7561647267616e6765666e71766b6a7679346e7070396a3567323436676e61376135717736387735307a38787133356a7a6339227d
595	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3539352c2268617368223a2238373137336139366638626664663138366162346365636332393935616130386130383632643263376165623437613665373865323231356236343166393963222c22736c6f74223a363234397d2c22697373756572566b223a2236663433303435383532363138336235323734353963653130303263343538376633656339363531626535633961303265323561373137636638383338303032222c2270726576696f7573426c6f636b223a2263363461386131623266336562376662396334393137613437303532373231316338383639353866366338626438313665373863323739383233303733613539222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6e6a6e753937773777387471683072766e356d79666776787273786d6a32746b366a33666c6770357666306577786d75686c71657766716e77227d
596	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3539362c2268617368223a2266393638626438616638313936613036333762316230663336363130306237636136323163313966313732363038386135616334363066343630316261393332222c22736c6f74223a363235327d2c22697373756572566b223a2238613437303766623763363739396238346232663463646265343566646339306233646566353736623132326131343439373135656432653264633964383965222c2270726576696f7573426c6f636b223a2238373137336139366638626664663138366162346365636332393935616130386130383632643263376165623437613665373865323231356236343166393963222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773038616a7a3470727338386a3665687a393566657972786a653276747661746c346a6166366a75683930737872676465656673356e6368756c227d
597	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3539372c2268617368223a2230626563633439666265333262323331376132333566383465656337633266363238663932653463643662663439373565623662616564666163643563313562222c22736c6f74223a363235377d2c22697373756572566b223a2238613437303766623763363739396238346232663463646265343566646339306233646566353736623132326131343439373135656432653264633964383965222c2270726576696f7573426c6f636b223a2266393638626438616638313936613036333762316230663336363130306237636136323163313966313732363038386135616334363066343630316261393332222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773038616a7a3470727338386a3665687a393566657972786a653276747661746c346a6166366a75683930737872676465656673356e6368756c227d
598	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3539382c2268617368223a2238313863313835633835383264396431633332396261373133366466323839643133353463633333306638396232653030633935373533313633346130376234222c22736c6f74223a363236367d2c22697373756572566b223a2236663433303435383532363138336235323734353963653130303263343538376633656339363531626535633961303265323561373137636638383338303032222c2270726576696f7573426c6f636b223a2230626563633439666265333262323331376132333566383465656337633266363238663932653463643662663439373565623662616564666163643563313562222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6e6a6e753937773777387471683072766e356d79666776787273786d6a32746b366a33666c6770357666306577786d75686c71657766716e77227d
599	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3539392c2268617368223a2236633732333564636466343831303838323764636239616630656662346136313237343466643865623837636461306133623531353536366531353533356137222c22736c6f74223a363237387d2c22697373756572566b223a2233373261356338663263643232643463336535363161343536366530613737396463666235616130316161393064333037393734313230643433316663663161222c2270726576696f7573426c6f636b223a2238313863313835633835383264396431633332396261373133366466323839643133353463633333306638396232653030633935373533313633346130376234222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316b307a34637834777a71777575616e353732757a653071373063323835326e706371776c78636e743263756367396579706735713264756c7279227d
600	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3630302c2268617368223a2235643038363636643331636633343964653863636466393263636362353666303637663730303936636137303630386134363861343464386637616239616638222c22736c6f74223a363237397d2c22697373756572566b223a2230613638323464663338323766383632376633623433336433396538386232613737663536373330336435366530393065376130386665323830343439303231222c2270726576696f7573426c6f636b223a2236633732333564636466343831303838323764636239616630656662346136313237343466643865623837636461306133623531353536366531353533356137222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316d6535776535396d746179667474723267616733326c6730373535667135307179633672646776367874353661667a7068376671647a78333668227d
601	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3630312c2268617368223a2231613434373439366631383762383031646161613034633432633963376433323530393566326166643032346532356366333334656134653537616662393731222c22736c6f74223a363238307d2c22697373756572566b223a2236663433303435383532363138336235323734353963653130303263343538376633656339363531626535633961303265323561373137636638383338303032222c2270726576696f7573426c6f636b223a2235643038363636643331636633343964653863636466393263636362353666303637663730303936636137303630386134363861343464386637616239616638222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6e6a6e753937773777387471683072766e356d79666776787273786d6a32746b366a33666c6770357666306577786d75686c71657766716e77227d
590	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3539302c2268617368223a2231393332666238613833366362656164373935376634613033636464313264303261353538333363386630663237373136373864386239633430336236316164222c22736c6f74223a363231387d2c22697373756572566b223a2233373261356338663263643232643463336535363161343536366530613737396463666235616130316161393064333037393734313230643433316663663161222c2270726576696f7573426c6f636b223a2239613362303766396435626531636435626230313630636636653061386638666134623233343366323538633961656239323635353736646238613131653961222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316b307a34637834777a71777575616e353732757a653071373063323835326e706371776c78636e743263756367396579706735713264756c7279227d
591	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3539312c2268617368223a2266373733326332366663333966663139386434303665376362666263316534333333313336373863363039623030393038616432663631343066303566626664222c22736c6f74223a363231397d2c22697373756572566b223a2262383866343233313138363032393330663932343631336663663766663939356430393934396366636435653239323262653436393565666662633333663435222c2270726576696f7573426c6f636b223a2231393332666238613833366362656164373935376634613033636464313264303261353538333363386630663237373136373864386239633430336236316164222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317768713376753438376c6d386a6c6b6e6b6a78717670796c3070796d3077726b3466766e79717a656568716365386d77327a39716b3239743838227d
592	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3539322c2268617368223a2262373163663235623765336134643062656662623162343034396535333135646638303061303866353236393263663962633866346132366463313563353239222c22736c6f74223a363233377d2c22697373756572566b223a2238613437303766623763363739396238346232663463646265343566646339306233646566353736623132326131343439373135656432653264633964383965222c2270726576696f7573426c6f636b223a2266373733326332366663333966663139386434303665376362666263316534333333313336373863363039623030393038616432663631343066303566626664222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773038616a7a3470727338386a3665687a393566657972786a653276747661746c346a6166366a75683930737872676465656673356e6368756c227d
593	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3539332c2268617368223a2239633734623231333062383030356262623766366433346461616432313131643334396365353964333362313065323438343865376561313038643635653563222c22736c6f74223a363233387d2c22697373756572566b223a2233373261356338663263643232643463336535363161343536366530613737396463666235616130316161393064333037393734313230643433316663663161222c2270726576696f7573426c6f636b223a2262373163663235623765336134643062656662623162343034396535333135646638303061303866353236393263663962633866346132366463313563353239222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316b307a34637834777a71777575616e353732757a653071373063323835326e706371776c78636e743263756367396579706735713264756c7279227d
602	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3630322c2268617368223a2233383131323666326161373237653465353264656430353337336563346335626132396165623766396261376464383134663337656138386664303938336263222c22736c6f74223a363331307d2c22697373756572566b223a2235383164383732366432326662376436303739303865323030666262326233643730313761643832353438336164366131663462393133393438386361303136222c2270726576696f7573426c6f636b223a2231613434373439366631383762383031646161613034633432633963376433323530393566326166643032346532356366333334656134653537616662393731222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31776e333230753233686663747a7a6661653579766e393937776c6c7433386675367834396a6666666e7736676b786c7930366d71686a30713466227d
603	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3630332c2268617368223a2234633532333039366339363133656632653532386339373161393065353163386465363431626635353138666562636438306139346436346237316338393535222c22736c6f74223a363332327d2c22697373756572566b223a2233373261356338663263643232643463336535363161343536366530613737396463666235616130316161393064333037393734313230643433316663663161222c2270726576696f7573426c6f636b223a2233383131323666326161373237653465353264656430353337336563346335626132396165623766396261376464383134663337656138386664303938336263222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316b307a34637834777a71777575616e353732757a653071373063323835326e706371776c78636e743263756367396579706735713264756c7279227d
604	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3630342c2268617368223a2261396137643734393464346138643638353631646438396633353864333636346339666230663435393334626534623936393830313233616261613663343430222c22736c6f74223a363333327d2c22697373756572566b223a2236336531313562353235306262323562306434303933323933383233393263623636383737303335303365333732356230316565306635656665383765353938222c2270726576696f7573426c6f636b223a2234633532333039366339363133656632653532386339373161393065353163386465363431626635353138666562636438306139346436346237316338393535222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6e743238367834336a753830306430776c387a72366d3275717366386b7365387574386339356c346c75777a6334686d3779736e3039686c67227d
605	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3630352c2268617368223a2232383666643934393038303238636566643532623264333833646330616263663634346462636665643162353765326131323037343534646430656538656537222c22736c6f74223a363333377d2c22697373756572566b223a2261323965616634326332666239366133646635343263353535633566346463316266656630326465643137663937366633646431666462376233366461616166222c2270726576696f7573426c6f636b223a2261396137643734393464346138643638353631646438396633353864333636346339666230663435393334626534623936393830313233616261613663343430222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316b77307878636a7561647267616e6765666e71766b6a7679346e7070396a3567323436676e61376135717736387735307a38787133356a7a6339227d
606	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3630362c2268617368223a2234333238626632633765616165333133663333643038376436386439393962336564663237663631323137383866316232363164616634653735386133396365222c22736c6f74223a363333397d2c22697373756572566b223a2236336531313562353235306262323562306434303933323933383233393263623636383737303335303365333732356230316565306635656665383765353938222c2270726576696f7573426c6f636b223a2232383666643934393038303238636566643532623264333833646330616263663634346462636665643162353765326131323037343534646430656538656537222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6e743238367834336a753830306430776c387a72366d3275717366386b7365387574386339356c346c75777a6334686d3779736e3039686c67227d
607	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3630372c2268617368223a2239346161373435346334396131623231653038633132383265303338623938646235383933376330313732663538663634633966313132653235323763316539222c22736c6f74223a363334327d2c22697373756572566b223a2233373261356338663263643232643463336535363161343536366530613737396463666235616130316161393064333037393734313230643433316663663161222c2270726576696f7573426c6f636b223a2234333238626632633765616165333133663333643038376436386439393962336564663237663631323137383866316232363164616634653735386133396365222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316b307a34637834777a71777575616e353732757a653071373063323835326e706371776c78636e743263756367396579706735713264756c7279227d
608	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3630382c2268617368223a2239346334666461373130373530366538383731643630613530623865356338333561356335343435613038346439643366303431313934303638343561343030222c22736c6f74223a363334387d2c22697373756572566b223a2230613638323464663338323766383632376633623433336433396538386232613737663536373330336435366530393065376130386665323830343439303231222c2270726576696f7573426c6f636b223a2239346161373435346334396131623231653038633132383265303338623938646235383933376330313732663538663634633966313132653235323763316539222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316d6535776535396d746179667474723267616733326c6730373535667135307179633672646776367874353661667a7068376671647a78333668227d
609	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3630392c2268617368223a2231323163363632623066616330333633393738353762613064373564653230346266393264376330613535643938633330316563303632373232343433643939222c22736c6f74223a363335327d2c22697373756572566b223a2263656534623662646232343166313435356562366239343866363939653561633263633133393261356165663439336563316230316435326564623738626637222c2270726576696f7573426c6f636b223a2239346334666461373130373530366538383731643630613530623865356338333561356335343435613038346439643366303431313934303638343561343030222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173383271736a326a7a383571783066386b6533616c37347a676a783577747072666576616d3765747171393776326d3830687171337065307467227d
610	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3631302c2268617368223a2266326563623934373130613164336438656465326431353432653261633130643065306538343633353634666663333762313933666237343166386639303866222c22736c6f74223a363335347d2c22697373756572566b223a2233373261356338663263643232643463336535363161343536366530613737396463666235616130316161393064333037393734313230643433316663663161222c2270726576696f7573426c6f636b223a2231323163363632623066616330333633393738353762613064373564653230346266393264376330613535643938633330316563303632373232343433643939222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316b307a34637834777a71777575616e353732757a653071373063323835326e706371776c78636e743263756367396579706735713264756c7279227d
611	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3631312c2268617368223a2239336364363365653961623037323866633931316135306163326233353563646136363239383062333536643762333935663831643866346233616330653636222c22736c6f74223a363336337d2c22697373756572566b223a2238613437303766623763363739396238346232663463646265343566646339306233646566353736623132326131343439373135656432653264633964383965222c2270726576696f7573426c6f636b223a2266326563623934373130613164336438656465326431353432653261633130643065306538343633353634666663333762313933666237343166386639303866222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31773038616a7a3470727338386a3665687a393566657972786a653276747661746c346a6166366a75683930737872676465656673356e6368756c227d
612	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3631322c2268617368223a2238316137626565383332346138626562653063313063333038353033613935663934383439636366316133356561353532303837626338386437613333663263222c22736c6f74223a363337317d2c22697373756572566b223a2235383164383732366432326662376436303739303865323030666262326233643730313761643832353438336164366131663462393133393438386361303136222c2270726576696f7573426c6f636b223a2239336364363365653961623037323866633931316135306163326233353563646136363239383062333536643762333935663831643866346233616330653636222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31776e333230753233686663747a7a6661653579766e393937776c6c7433386675367834396a6666666e7736676b786c7930366d71686a30713466227d
613	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a3631332c2268617368223a2230613830333462646538323836646336373939623232343963663235303366356332356462313565663661306630396531336663616163623964616531303863222c22736c6f74223a363338327d2c22697373756572566b223a2236663433303435383532363138336235323734353963653130303263343538376633656339363531626535633961303265323561373137636638383338303032222c2270726576696f7573426c6f636b223a2238316137626565383332346138626562653063313063333038353033613935663934383439636366316133356561353532303837626338386437613333663263222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6e6a6e753937773777387471683072766e356d79666776787273786d6a32746b366a33666c6770357666306577786d75686c71657766716e77227d
\.


--
-- Data for Name: current_pool_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_pool_metrics (stake_pool_id, slot, minted_blocks, live_delegators, active_stake, live_stake, live_pledge, live_saturation, active_size, live_size, last_ros, ros) FROM stdin;
pool1ek6nwzlv07edrw8qa9q88sxj0628dxxml3pa7tvhm4hm7ql4an4	1592	15	3	7773227772181541	11085567736156	500000000	0.13169534911125927	701.2024965423163	-700.2024965423163	17.191815520692817	17.191815520692817
pool1v0h563vr2p42uwu0wgakem82g58kwq0ap6nya3ccllsmql07ezn	1592	13	3	7773227872184305	5793133597980	600000000	0.06882180234629034	1341.8002089395525	-1340.8002089395525	22.630270057949385	22.630270057949385
pool1aud3ck37ev3uwhfcdas54xdnjpvtrtndgcjrffgsx5grvl28fvv	1592	11	3	7773227472181533	9321089689173	200000000	0.11073354021457245	833.9397786516955	-832.9397786516955	14.034811479524947	14.034811479524947
pool1d3ez0uq0rzv9ly8eslwa422sacktx9gs0mh5fgncmupxwgvkf77	1592	20	3	7773227772181533	12849745783138	500000000	0.1526535940402896	604.9324168250786	-603.9324168250786	38.30265936460953	38.30265936460953
pool14c8nwn4a4fnpvcs9a84f25w07vsenyxgys6ejznjfdhcqn2xrku	1592	13	3	7773227772181533	4028855548226	500000000	0.04786236939511407	1929.3885519435582	-1928.3885519435582	48.60796459030748	48.60796459030748
pool1wze6trs6ncux27gc0d3cgmelwvq0c5m2j6aryd0r8vulkavsdqj	1592	14	3	7773227772181533	9321389689173	500000000	0.11073710418221702	833.9129712826306	-832.9129712826306	27.969195726615315	27.969195726615315
pool1mynp3e6hqdjpv53r2y4nwnk4j2pkvpzlykfakkduywyuw789dfy	1592	22	3	7773227772181533	7557211642191	500000000	0.08977885925318667	1028.5841048548305	-1027.5841048548305	97.63208663450393	97.63208663450393
pool1mfrmvvuwpvk68rmkjqwdtdmuq62rq52vhhc93f43qjymcwsydvp	1592	15	3	7773227572003844	5792833417519	300000000	0.06881823623478855	1341.8696882419626	-1340.8696882419626	48.71200466663794	48.71200466663794
pool14ps29vpdqmnfvzfru80zwq503pymfhvjcrcu259j4jpr70susa4	1592	13	3	7772727272727272	11085567555651	500000000	0.13169534696687932	701.1573592156797	-700.1573592156797	69.151594366279	69.151594366279
pool14k9jchrftx29te8xljw9dv0tuyyvf3pc8htexq0kqrtjk5vyyhv	1592	15	3	7773227572184305	9321189511484	300000000	0.11073472609286115	833.9308585677228	-832.9308585677228	48.712004665354854	48.712004665354854
pool1ynrrvvf6l6z6tg7ff97vvjv8aea40qe9ksjay4urn0hssj95pgk	1592	15	3	7772727272727272	5793033414703	500000000	0.0688206121797645	1341.7369996519808	-1340.7369996519808	124.47286985931196	124.47286985931196
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
1	SP3	Stake Pool - 3	This is the stake pool 3 description.	https://stakepool3.com	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	\N	pool1aud3ck37ev3uwhfcdas54xdnjpvtrtndgcjrffgsx5grvl28fvv	4210000000000
2	SP1	stake pool - 1	This is the stake pool 1 description.	https://stakepool1.com	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	\N	pool1ek6nwzlv07edrw8qa9q88sxj0628dxxml3pa7tvhm4hm7ql4an4	2010000000000
3	SP4	Same Name	This is the stake pool 4 description.	https://stakepool4.com	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	\N	pool1d3ez0uq0rzv9ly8eslwa422sacktx9gs0mh5fgncmupxwgvkf77	4960000000000
4	SP6a7		This is the stake pool 7 description.	https://stakepool7.com	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	\N	pool1mynp3e6hqdjpv53r2y4nwnk4j2pkvpzlykfakkduywyuw789dfy	7660000000000
5	SP5	Same Name	This is the stake pool 5 description.	https://stakepool5.com	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	\N	pool14c8nwn4a4fnpvcs9a84f25w07vsenyxgys6ejznjfdhcqn2xrku	6150000000000
6	SP6a7	Stake Pool - 6	This is the stake pool 6 description.	https://stakepool6.com	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	\N	pool1wze6trs6ncux27gc0d3cgmelwvq0c5m2j6aryd0r8vulkavsdqj	6660000000000
7	SP10	Stake Pool - 10	This is the stake pool 10 description.	https://stakepool10.com	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	\N	pool14ps29vpdqmnfvzfru80zwq503pymfhvjcrcu259j4jpr70susa4	11580000000000
8	SP11	Stake Pool - 10 + 1	This is the stake pool 11 description.	https://stakepool11.com	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	\N	pool1ynrrvvf6l6z6tg7ff97vvjv8aea40qe9ksjay4urn0hssj95pgk	12980000000000
\.


--
-- Data for Name: pool_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_registration (id, reward_account, pledge, cost, margin, margin_percent, relays, owners, vrf, metadata_url, metadata_hash, block_slot, stake_pool_id) FROM stdin;
2010000000000	stake_test1upy9t0huw6uu3hhlj478f3alet6w62kuuyvgzcctn6f9flg9mg76c	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3001, "__typename": "RelayByAddress"}]	["stake_test1upy9t0huw6uu3hhlj478f3alet6w62kuuyvgzcctn6f9flg9mg76c"]	9c55fa2bba0abd059da9a3e15d6b939231152be15c479cb2e467ba68cae35954	http://file-server/SP1.json	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	201	pool1ek6nwzlv07edrw8qa9q88sxj0628dxxml3pa7tvhm4hm7ql4an4
3590000000000	stake_test1uppqcz5ktqs206x7dd347km79wlqvdhu5he785yknyr94ec88thga	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3002, "__typename": "RelayByAddress"}]	["stake_test1uppqcz5ktqs206x7dd347km79wlqvdhu5he785yknyr94ec88thga"]	b77cd36464ea31a71ec3c8964231ec9f3b92d33733cba8d9328adc78e790c3fc	\N	\N	359	pool1v0h563vr2p42uwu0wgakem82g58kwq0ap6nya3ccllsmql07ezn
4210000000000	stake_test1uqqxjhsza2laxmnnmdfqg495j7s928030d5musgzj97rcvcld8u7u	600000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3003, "__typename": "RelayByAddress"}]	["stake_test1uqqxjhsza2laxmnnmdfqg495j7s928030d5musgzj97rcvcld8u7u"]	7ce6f0deb73d49544fefb0bb900e136924be06de52ddf6e79b189368d9318d26	http://file-server/SP3.json	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	421	pool1aud3ck37ev3uwhfcdas54xdnjpvtrtndgcjrffgsx5grvl28fvv
4960000000000	stake_test1uqqcaral3j53cuvwj8w7p5tvkq5jdc0hpzcphhhsnh00k8g5wpfs0	420000000	370000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3004, "__typename": "RelayByAddress"}]	["stake_test1uqqcaral3j53cuvwj8w7p5tvkq5jdc0hpzcphhhsnh00k8g5wpfs0"]	24186b236ca5558a2c6e3f0048b47e4ffcb75091e6dca6964301920a2f26587f	http://file-server/SP4.json	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	496	pool1d3ez0uq0rzv9ly8eslwa422sacktx9gs0mh5fgncmupxwgvkf77
6150000000000	stake_test1uqx3a6m4py4h3m7x0upayyfrpm7u6c39jjar75th4d6t9tg3rwx8d	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3005, "__typename": "RelayByAddress"}]	["stake_test1uqx3a6m4py4h3m7x0upayyfrpm7u6c39jjar75th4d6t9tg3rwx8d"]	9057558dcc1f2a5736c72ef1b92588573e7cff5a29513309a8424301bbf009ac	http://file-server/SP5.json	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	615	pool14c8nwn4a4fnpvcs9a84f25w07vsenyxgys6ejznjfdhcqn2xrku
6660000000000	stake_test1urzvhux9lkmtve025ut498g84x9xuhwuulv9s49f5j6t4aqmr8y54	410000000	400000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3006, "__typename": "RelayByAddress"}]	["stake_test1urzvhux9lkmtve025ut498g84x9xuhwuulv9s49f5j6t4aqmr8y54"]	72a7904ad7bd7b8526809329a51873cb931670e014889233d741ff9e74fbf0c9	http://file-server/SP6.json	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	666	pool1wze6trs6ncux27gc0d3cgmelwvq0c5m2j6aryd0r8vulkavsdqj
7660000000000	stake_test1uzdxyd4x29uyvfl39eshrlvzy4rfzck2q7le83qmn59zqygyat708	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3007, "__typename": "RelayByAddress"}]	["stake_test1uzdxyd4x29uyvfl39eshrlvzy4rfzck2q7le83qmn59zqygyat708"]	db692743c0994ab4eb78732c87e2bf6090121c1fb3cd6767c65505db39dfdd2e	http://file-server/SP7.json	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	766	pool1mynp3e6hqdjpv53r2y4nwnk4j2pkvpzlykfakkduywyuw789dfy
8490000000000	stake_test1upeu2jf2lpfprlwvyq8m5xutwupv0pegkdul7f0h5y74tug4zcz5y	500000000	380000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3008, "__typename": "RelayByAddress"}]	["stake_test1upeu2jf2lpfprlwvyq8m5xutwupv0pegkdul7f0h5y74tug4zcz5y"]	fc1548a4651e9339edfe0a673f02244603b90a309e2230bfd108d10c9a597625	\N	\N	849	pool1mfrmvvuwpvk68rmkjqwdtdmuq62rq52vhhc93f43qjymcwsydvp
9880000000000	stake_test1uqn7as2474lq6ytlc7q4m8ecugkuud9m9f9tn8wgeh87dxqd9aq6s	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3009, "__typename": "RelayByAddress"}]	["stake_test1uqn7as2474lq6ytlc7q4m8ecugkuud9m9f9tn8wgeh87dxqd9aq6s"]	8500221ec6d9ace43294765319da4b7ad0d33fb24f5750646250d08cc65b94e6	\N	\N	988	pool14k9jchrftx29te8xljw9dv0tuyyvf3pc8htexq0kqrtjk5vyyhv
11580000000000	stake_test1upk40w8khw7autla7q670lk9qgp5rl7v86qp5dq594qv3dqmzan6u	400000000	410000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30010, "__typename": "RelayByAddress"}]	["stake_test1upk40w8khw7autla7q670lk9qgp5rl7v86qp5dq594qv3dqmzan6u"]	219c3f9b1fcb24b02e06dfea38fe92ee27d6b8d67b9d172099a3ce315c9f974b	http://file-server/SP10.json	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	1158	pool14ps29vpdqmnfvzfru80zwq503pymfhvjcrcu259j4jpr70susa4
12980000000000	stake_test1urvch5xw2endwg73alnjmzyynkj32g55a8ykaecty922yzcuqmz2q	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30011, "__typename": "RelayByAddress"}]	["stake_test1urvch5xw2endwg73alnjmzyynkj32g55a8ykaecty922yzcuqmz2q"]	865791ee4e86a7940c03ac69bc3a2864b36bcf65ee5819ba9b7a47bc1272b949	http://file-server/SP11.json	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	1298	pool1ynrrvvf6l6z6tg7ff97vvjv8aea40qe9ksjay4urn0hssj95pgk
66350000000000	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	500000000000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.1", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys"]	2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	\N	\N	6635	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
67400000000000	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	50000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.2", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v"]	641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	\N	\N	6740	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_retirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retirement (id, retire_at_epoch, block_slot, stake_pool_id) FROM stdin;
9110000000000	5	911	pool1mfrmvvuwpvk68rmkjqwdtdmuq62rq52vhhc93f43qjymcwsydvp
10310000000000	18	1031	pool14k9jchrftx29te8xljw9dv0tuyyvf3pc8htexq0kqrtjk5vyyhv
11860000000000	5	1186	pool14ps29vpdqmnfvzfru80zwq503pymfhvjcrcu259j4jpr70susa4
13310000000000	18	1331	pool1ynrrvvf6l6z6tg7ff97vvjv8aea40qe9ksjay4urn0hssj95pgk
\.


--
-- Data for Name: pool_rewards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_rewards (id, stake_pool_id, epoch_length, epoch_no, delegators, pledge, active_stake, member_active_stake, leader_rewards, member_rewards, rewards, version) FROM stdin;
1	pool1ek6nwzlv07edrw8qa9q88sxj0628dxxml3pa7tvhm4hm7ql4an4	500000	1	0	400000000	0	0	0	10585068281895	10585068281895	1
2	pool1v0h563vr2p42uwu0wgakem82g58kwq0ap6nya3ccllsmql07ezn	500000	1	0	500000000	0	0	0	5292534140947	5292534140947	1
3	pool1aud3ck37ev3uwhfcdas54xdnjpvtrtndgcjrffgsx5grvl28fvv	500000	1	0	600000000	0	0	0	8820890234912	8820890234912	1
4	pool1d3ez0uq0rzv9ly8eslwa422sacktx9gs0mh5fgncmupxwgvkf77	500000	1	0	420000000	0	0	0	12349246328877	12349246328877	1
5	pool1mfrmvvuwpvk68rmkjqwdtdmuq62rq52vhhc93f43qjymcwsydvp	500000	2	1	500000000	7772727272727272	7772727272727272	0	5189440639708	5189440639708	1
6	pool14k9jchrftx29te8xljw9dv0tuyyvf3pc8htexq0kqrtjk5vyyhv	500000	2	1	500000000	7772727272727272	7772727272727272	0	5189440639708	5189440639708	1
7	pool1ek6nwzlv07edrw8qa9q88sxj0628dxxml3pa7tvhm4hm7ql4an4	500000	2	3	400000000	7773227772181541	7773227272181541	0	3459404336064	3459404336064	1
8	pool1v0h563vr2p42uwu0wgakem82g58kwq0ap6nya3ccllsmql07ezn	500000	2	3	500000000	7773227872184305	7773227272184305	0	6918808583119	6918808583119	1
9	pool1aud3ck37ev3uwhfcdas54xdnjpvtrtndgcjrffgsx5grvl28fvv	500000	2	3	600000000	7773227472181533	7773227272181533	0	5189106704365	5189106704365	1
10	pool1d3ez0uq0rzv9ly8eslwa422sacktx9gs0mh5fgncmupxwgvkf77	500000	2	3	420000000	7773227772181533	7773227272181533	0	6918808672129	6918808672129	1
11	pool14c8nwn4a4fnpvcs9a84f25w07vsenyxgys6ejznjfdhcqn2xrku	500000	2	1	410000000	7772727272727272	7772727272727272	0	3459627093139	3459627093139	1
12	pool1wze6trs6ncux27gc0d3cgmelwvq0c5m2j6aryd0r8vulkavsdqj	500000	2	1	410000000	7772727272727272	7772727272727272	0	5189440639708	5189440639708	1
13	pool1mynp3e6hqdjpv53r2y4nwnk4j2pkvpzlykfakkduywyuw789dfy	500000	2	1	410000000	7772727272727272	7772727272727272	0	13838508372556	13838508372556	1
14	pool14k9jchrftx29te8xljw9dv0tuyyvf3pc8htexq0kqrtjk5vyyhv	500000	3	3	500000000	7773227572184305	7773227272184305	0	6817121882355	6817121882355	1
15	pool1ynrrvvf6l6z6tg7ff97vvjv8aea40qe9ksjay4urn0hssj95pgk	500000	3	1	400000000	7772727272727272	7772727272727272	0	15339511514937	15339511514937	1
16	pool1ek6nwzlv07edrw8qa9q88sxj0628dxxml3pa7tvhm4hm7ql4an4	500000	3	3	400000000	7773227772181541	7773227272181541	511615814363	2896945039115	3408560853478	1
17	pool1v0h563vr2p42uwu0wgakem82g58kwq0ap6nya3ccllsmql07ezn	500000	3	3	500000000	7773227872184305	7773227272184305	255973672514	1448306732299	1704280404813	1
18	pool1aud3ck37ev3uwhfcdas54xdnjpvtrtndgcjrffgsx5grvl28fvv	500000	3	3	600000000	7773227472181533	7773227272181533	0	0	0	1
19	pool1d3ez0uq0rzv9ly8eslwa422sacktx9gs0mh5fgncmupxwgvkf77	500000	3	3	420000000	7773227772181533	7773227272181533	1278525285940	7242876847756	8521402133696	1
20	pool14c8nwn4a4fnpvcs9a84f25w07vsenyxgys6ejznjfdhcqn2xrku	500000	3	3	410000000	7773227772181533	7773227272181533	0	8521402133697	8521402133697	1
21	pool1wze6trs6ncux27gc0d3cgmelwvq0c5m2j6aryd0r8vulkavsdqj	500000	3	3	410000000	7773227772181533	7773227272181533	0	1704280426738	1704280426738	1
22	pool1mynp3e6hqdjpv53r2y4nwnk4j2pkvpzlykfakkduywyuw789dfy	500000	3	3	410000000	7773227772181533	7773227272181533	0	10225682560437	10225682560437	1
23	pool1mfrmvvuwpvk68rmkjqwdtdmuq62rq52vhhc93f43qjymcwsydvp	500000	3	3	500000000	7773227572003844	7773227272003844	0	6817121882513	6817121882513	1
24	pool14ps29vpdqmnfvzfru80zwq503pymfhvjcrcu259j4jpr70susa4	500000	3	1	400000000	7772727272727272	7772727272727272	0	8521950841631	8521950841631	1
\.


--
-- Data for Name: stake_pool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_pool (id, status, last_registration_id, last_retirement_id) FROM stdin;
pool14k9jchrftx29te8xljw9dv0tuyyvf3pc8htexq0kqrtjk5vyyhv	retiring	9880000000000	10310000000000
pool1ynrrvvf6l6z6tg7ff97vvjv8aea40qe9ksjay4urn0hssj95pgk	retiring	12980000000000	13310000000000
pool1ek6nwzlv07edrw8qa9q88sxj0628dxxml3pa7tvhm4hm7ql4an4	active	2010000000000	\N
pool1v0h563vr2p42uwu0wgakem82g58kwq0ap6nya3ccllsmql07ezn	active	3590000000000	\N
pool1aud3ck37ev3uwhfcdas54xdnjpvtrtndgcjrffgsx5grvl28fvv	active	4210000000000	\N
pool1d3ez0uq0rzv9ly8eslwa422sacktx9gs0mh5fgncmupxwgvkf77	active	4960000000000	\N
pool14c8nwn4a4fnpvcs9a84f25w07vsenyxgys6ejznjfdhcqn2xrku	active	6150000000000	\N
pool1wze6trs6ncux27gc0d3cgmelwvq0c5m2j6aryd0r8vulkavsdqj	active	6660000000000	\N
pool1mynp3e6hqdjpv53r2y4nwnk4j2pkvpzlykfakkduywyuw789dfy	active	7660000000000	\N
pool1mfrmvvuwpvk68rmkjqwdtdmuq62rq52vhhc93f43qjymcwsydvp	retired	8490000000000	9110000000000
pool14ps29vpdqmnfvzfru80zwq503pymfhvjcrcu259j4jpr70susa4	retired	11580000000000	11860000000000
pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	activating	66350000000000	\N
pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	activating	67400000000000	\N
\.


--
-- Name: pool_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_metadata_id_seq', 8, true);


--
-- Name: pool_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_rewards_id_seq', 24, true);


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

