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
b4295019-9dec-4543-8122-25e3e9c0d0b7	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:51:01.158732+00	2023-10-25 17:51:01.178515+00	\N	2023-10-25 17:51:00	00:15:00	2023-10-25 17:50:01.158732+00	2023-10-25 17:51:01.1868+00	2023-10-25 17:52:01.158732+00	f	\N	\N
8e71ea39-dbb4-41cd-a307-8fa1e2f3ecbe	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-10-25 17:42:42.44402+00	2023-10-25 17:42:42.447159+00	__pgboss__maintenance	\N	00:15:00	2023-10-25 17:42:42.44402+00	2023-10-25 17:42:42.458094+00	2023-10-25 17:50:42.44402+00	f	\N	\N
61021d6f-1f86-45ea-8113-e9758f110d0e	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:52:01.185238+00	2023-10-25 17:52:01.202397+00	\N	2023-10-25 17:52:00	00:15:00	2023-10-25 17:51:01.185238+00	2023-10-25 17:52:01.216725+00	2023-10-25 17:53:01.185238+00	f	\N	\N
3fadcd1a-aac8-4082-a6b8-b36f80a45ff5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-10-25 17:51:20.87877+00	2023-10-25 17:52:20.872096+00	__pgboss__maintenance	\N	00:15:00	2023-10-25 17:49:20.87877+00	2023-10-25 17:52:20.886018+00	2023-10-25 17:59:20.87877+00	f	\N	\N
bb2cabce-590e-4118-81aa-7f97da1ce3b4	pool-rewards	0	{"epochNo": 4}	completed	1000000	0	30	f	2023-10-25 17:52:24.215734+00	2023-10-25 17:52:25.261398+00	4	\N	00:15:00	2023-10-25 17:52:24.215734+00	2023-10-25 17:52:25.396469+00	2023-11-08 17:52:24.215734+00	f	\N	6006
8ed9fcdf-12c4-4f00-8b5a-880edc5c1c45	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:53:01.215136+00	2023-10-25 17:53:01.225074+00	\N	2023-10-25 17:53:00	00:15:00	2023-10-25 17:52:01.215136+00	2023-10-25 17:53:01.238771+00	2023-10-25 17:54:01.215136+00	f	\N	\N
913d8c94-063a-4782-9719-357522be9c46	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:42:42.452228+00	2023-10-25 17:43:20.869344+00	\N	2023-10-25 17:42:00	00:15:00	2023-10-25 17:42:42.452228+00	2023-10-25 17:43:20.874018+00	2023-10-25 17:43:42.452228+00	f	\N	\N
f99ec325-8f29-4fe1-bde5-d6da4e44680b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-10-25 17:43:20.857342+00	2023-10-25 17:43:20.863338+00	__pgboss__maintenance	\N	00:15:00	2023-10-25 17:43:20.857342+00	2023-10-25 17:43:20.875144+00	2023-10-25 17:51:20.857342+00	f	\N	\N
4c95c134-173d-4d17-876a-d1938b60af09	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:55:01.263714+00	2023-10-25 17:55:01.275151+00	\N	2023-10-25 17:55:00	00:15:00	2023-10-25 17:54:01.263714+00	2023-10-25 17:55:01.288421+00	2023-10-25 17:56:01.263714+00	f	\N	\N
ad3ec83e-f262-4234-9ca8-9ca36fe52417	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-10-25 17:54:20.887638+00	2023-10-25 17:55:20.874269+00	__pgboss__maintenance	\N	00:15:00	2023-10-25 17:52:20.887638+00	2023-10-25 17:55:20.881381+00	2023-10-25 18:02:20.887638+00	f	\N	\N
4c70d922-6f67-4154-9233-7475725b229c	pool-metadata	0	{"poolId": "pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d", "metadataJson": {"url": "http://file-server/SP3.json", "hash": "6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25"}, "poolRegistrationId": "2770000000000"}	completed	1000000	0	21600	f	2023-10-25 17:42:42.677783+00	2023-10-25 17:43:20.883107+00	\N	\N	00:15:00	2023-10-25 17:42:42.677783+00	2023-10-25 17:43:20.961456+00	2023-11-08 17:42:42.677783+00	f	\N	277
330c0b90-fd20-4d90-b1ff-921b80c3d366	pool-metadata	0	{"poolId": "pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr", "metadataJson": {"url": "http://file-server/SP1.json", "hash": "14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7"}, "poolRegistrationId": "1030000000000"}	completed	1000000	0	21600	f	2023-10-25 17:42:42.566353+00	2023-10-25 17:43:20.883107+00	\N	\N	00:15:00	2023-10-25 17:42:42.566353+00	2023-10-25 17:43:20.962079+00	2023-11-08 17:42:42.566353+00	f	\N	103
a34b2844-7f38-4164-8e51-85c7ce89c555	pool-metadata	0	{"poolId": "pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm", "metadataJson": {"url": "http://file-server/SP4.json", "hash": "09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d"}, "poolRegistrationId": "3610000000000"}	completed	1000000	0	21600	f	2023-10-25 17:42:42.702431+00	2023-10-25 17:43:20.883107+00	\N	\N	00:15:00	2023-10-25 17:42:42.702431+00	2023-10-25 17:43:20.967801+00	2023-11-08 17:42:42.702431+00	f	\N	361
4c910ed4-a6d0-42d8-bcb3-717974d5c8b3	pool-metadata	0	{"poolId": "pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx", "metadataJson": {"url": "http://file-server/SP5.json", "hash": "0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501"}, "poolRegistrationId": "4500000000000"}	completed	1000000	0	21600	f	2023-10-25 17:42:42.742273+00	2023-10-25 17:43:20.883107+00	\N	\N	00:15:00	2023-10-25 17:42:42.742273+00	2023-10-25 17:43:20.974592+00	2023-11-08 17:42:42.742273+00	f	\N	450
1d395e4d-8bd2-4f11-87d8-adfc9e42c37f	pool-metadata	0	{"poolId": "pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg", "metadataJson": {"url": "http://file-server/SP6.json", "hash": "3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba"}, "poolRegistrationId": "5660000000000"}	completed	1000000	0	21600	f	2023-10-25 17:42:42.781423+00	2023-10-25 17:43:20.883107+00	\N	\N	00:15:00	2023-10-25 17:42:42.781423+00	2023-10-25 17:43:20.977105+00	2023-11-08 17:42:42.781423+00	f	\N	566
fe08adf6-3cc2-41e8-8a71-39a62d189292	pool-metadata	0	{"poolId": "pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6", "metadataJson": {"url": "http://file-server/SP7.json", "hash": "c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405"}, "poolRegistrationId": "6420000000000"}	completed	1000000	0	21600	f	2023-10-25 17:42:42.810554+00	2023-10-25 17:43:20.883107+00	\N	\N	00:15:00	2023-10-25 17:42:42.810554+00	2023-10-25 17:43:20.979518+00	2023-11-08 17:42:42.810554+00	f	\N	642
6473fa63-cc32-47df-b0d2-06814d1d9480	pool-metadata	0	{"poolId": "pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s", "metadataJson": {"url": "http://file-server/SP11.json", "hash": "4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9"}, "poolRegistrationId": "10710000000000"}	completed	1000000	0	21600	f	2023-10-25 17:42:43.046981+00	2023-10-25 17:43:20.883107+00	\N	\N	00:15:00	2023-10-25 17:42:43.046981+00	2023-10-25 17:43:20.981331+00	2023-11-08 17:42:43.046981+00	f	\N	1071
8d73dddb-1005-4ee2-b4d0-1748aea0acf6	pool-metadata	0	{"poolId": "pool1r3ku2tnxlnv0hdxw2py76puga9u5jr52rz8n984k52fvjjcy9rn", "metadataJson": {"url": "http://file-server/SP10.json", "hash": "c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd"}, "poolRegistrationId": "9710000000000"}	completed	1000000	0	21600	f	2023-10-25 17:42:42.990765+00	2023-10-25 17:43:20.883107+00	\N	\N	00:15:00	2023-10-25 17:42:42.990765+00	2023-10-25 17:43:20.980447+00	2023-11-08 17:42:42.990765+00	f	\N	971
e9ed08cf-ed35-4e3c-9090-373ff1a8ccef	pool-rewards	0	{"epochNo": 0}	completed	1000000	0	30	f	2023-10-25 17:42:43.384804+00	2023-10-25 17:43:20.903836+00	0	\N	00:15:00	2023-10-25 17:42:43.384804+00	2023-10-25 17:43:21.066971+00	2023-11-08 17:42:43.384804+00	f	\N	2000
6c3af0ee-e276-453c-adea-fe84467d58c6	pool-metrics	0	{"slot": 3071}	completed	0	0	0	f	2023-10-25 17:42:43.797176+00	2023-10-25 17:43:20.883288+00	\N	\N	00:15:00	2023-10-25 17:42:43.797176+00	2023-10-25 17:43:21.216822+00	2023-11-08 17:42:43.797176+00	f	\N	3071
198a7103-06d6-4485-9e7c-159522a4bc02	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:43:20.874461+00	2023-10-25 17:43:24.870899+00	\N	2023-10-25 17:43:00	00:15:00	2023-10-25 17:43:20.874461+00	2023-10-25 17:43:24.882473+00	2023-10-25 17:44:20.874461+00	f	\N	\N
aaff6bb4-40cc-4a58-9767-a0ef7f5ce35a	pool-rewards	0	{"epochNo": 1}	completed	1000000	1	30	f	2023-10-25 17:43:50.940518+00	2023-10-25 17:43:52.89351+00	1	\N	00:15:00	2023-10-25 17:42:43.759063+00	2023-10-25 17:43:53.048939+00	2023-11-08 17:42:43.759063+00	f	\N	3018
a36f7c58-58b6-4e49-9595-03fb6bb73566	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:44:01.880511+00	2023-10-25 17:44:04.890948+00	\N	2023-10-25 17:44:00	00:15:00	2023-10-25 17:43:24.880511+00	2023-10-25 17:44:04.908263+00	2023-10-25 17:45:01.880511+00	f	\N	\N
9c898f29-cf69-4bfe-b5c1-4cf9d92ca271	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:45:01.906011+00	2023-10-25 17:45:05.026012+00	\N	2023-10-25 17:45:00	00:15:00	2023-10-25 17:44:04.906011+00	2023-10-25 17:45:05.175153+00	2023-10-25 17:46:01.906011+00	f	\N	\N
0535c7be-7523-4a31-8edb-202166c4a4bd	pool-rewards	0	{"epochNo": 2}	completed	1000000	0	30	f	2023-10-25 17:45:44.411741+00	2023-10-25 17:45:45.127155+00	2	\N	00:15:00	2023-10-25 17:45:44.411741+00	2023-10-25 17:45:45.265078+00	2023-11-08 17:45:44.411741+00	f	\N	4007
fd43ab0a-3b19-4607-8ef4-97dfde6f5f88	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:46:01.150642+00	2023-10-25 17:46:05.064454+00	\N	2023-10-25 17:46:00	00:15:00	2023-10-25 17:45:05.150642+00	2023-10-25 17:46:05.077484+00	2023-10-25 17:47:01.150642+00	f	\N	\N
7d23bfb6-c190-49ae-a318-3935ad308a41	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-10-25 17:45:20.877592+00	2023-10-25 17:46:20.865927+00	__pgboss__maintenance	\N	00:15:00	2023-10-25 17:43:20.877592+00	2023-10-25 17:46:20.879652+00	2023-10-25 17:53:20.877592+00	f	\N	\N
ae188789-7ca1-48cd-abd0-a4eb364dc880	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:47:01.075957+00	2023-10-25 17:47:01.080448+00	\N	2023-10-25 17:47:00	00:15:00	2023-10-25 17:46:05.075957+00	2023-10-25 17:47:01.0872+00	2023-10-25 17:48:01.075957+00	f	\N	\N
1ab901f5-5536-470a-ac23-f3158651b970	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:48:01.085427+00	2023-10-25 17:48:01.105304+00	\N	2023-10-25 17:48:00	00:15:00	2023-10-25 17:47:01.085427+00	2023-10-25 17:48:01.117536+00	2023-10-25 17:49:01.085427+00	f	\N	\N
46f604b9-d61d-4140-b309-c4cfac648636	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:49:01.116034+00	2023-10-25 17:49:01.131939+00	\N	2023-10-25 17:49:00	00:15:00	2023-10-25 17:48:01.116034+00	2023-10-25 17:49:01.144703+00	2023-10-25 17:50:01.116034+00	f	\N	\N
310f4fdf-91fb-4bf2-9632-cb4f12e99e0d	pool-rewards	0	{"epochNo": 3}	completed	1000000	0	30	f	2023-10-25 17:49:03.611175+00	2023-10-25 17:49:05.178919+00	3	\N	00:15:00	2023-10-25 17:49:03.611175+00	2023-10-25 17:49:05.31393+00	2023-11-08 17:49:03.611175+00	f	\N	5003
5d7a76c6-c678-4a9f-8015-b8106b61f202	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-10-25 17:48:20.882169+00	2023-10-25 17:49:20.868844+00	__pgboss__maintenance	\N	00:15:00	2023-10-25 17:46:20.882169+00	2023-10-25 17:49:20.876817+00	2023-10-25 17:56:20.882169+00	f	\N	\N
7a4cbf67-8ec7-4fa9-8a4f-8449522d4a08	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:50:01.143175+00	2023-10-25 17:50:01.154236+00	\N	2023-10-25 17:50:00	00:15:00	2023-10-25 17:49:01.143175+00	2023-10-25 17:50:01.160832+00	2023-10-25 17:51:01.143175+00	f	\N	\N
86e3822c-a080-4bea-85f1-2dddc95a8602	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:54:01.236851+00	2023-10-25 17:54:01.251351+00	\N	2023-10-25 17:54:00	00:15:00	2023-10-25 17:53:01.236851+00	2023-10-25 17:54:01.265287+00	2023-10-25 17:55:01.236851+00	f	\N	\N
39399606-dd21-4c7e-8c2c-e76e14e50da4	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:10:01.60144+00	2023-10-25 18:10:01.620125+00	\N	2023-10-25 18:10:00	00:15:00	2023-10-25 18:09:01.60144+00	2023-10-25 18:10:01.635344+00	2023-10-25 18:11:01.60144+00	f	\N	\N
7ec87e8f-5303-4e05-ac23-8adb28217600	pool-rewards	0	{"epochNo": 5}	completed	1000000	0	30	f	2023-10-25 17:55:45.610738+00	2023-10-25 17:55:47.335071+00	5	\N	00:15:00	2023-10-25 17:55:45.610738+00	2023-10-25 17:55:47.456821+00	2023-11-08 17:55:45.610738+00	f	\N	7013
33a57f2f-57b1-40be-8c29-ed37f4046ca3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-10-25 18:09:20.896644+00	2023-10-25 18:10:20.885337+00	__pgboss__maintenance	\N	00:15:00	2023-10-25 18:07:20.896644+00	2023-10-25 18:10:20.889947+00	2023-10-25 18:17:20.896644+00	f	\N	\N
4f3a07a3-94d4-4b49-8f08-8f4a4b8afab2	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:56:01.286809+00	2023-10-25 17:56:01.299092+00	\N	2023-10-25 17:56:00	00:15:00	2023-10-25 17:55:01.286809+00	2023-10-25 17:56:01.306891+00	2023-10-25 17:57:01.286809+00	f	\N	\N
b55902bf-8c73-414b-852a-8ea7aa28a75f	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:57:01.30527+00	2023-10-25 17:57:01.322771+00	\N	2023-10-25 17:57:00	00:15:00	2023-10-25 17:56:01.30527+00	2023-10-25 17:57:01.329132+00	2023-10-25 17:58:01.30527+00	f	\N	\N
2113d576-e3c5-40f7-afa7-e7a3328b399e	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:11:01.633341+00	2023-10-25 18:11:01.641297+00	\N	2023-10-25 18:11:00	00:15:00	2023-10-25 18:10:01.633341+00	2023-10-25 18:11:01.649321+00	2023-10-25 18:12:01.633341+00	f	\N	\N
273bc9dd-a0cf-4d76-999c-7fb99c75ffef	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:58:01.327484+00	2023-10-25 17:58:01.347764+00	\N	2023-10-25 17:58:00	00:15:00	2023-10-25 17:57:01.327484+00	2023-10-25 17:58:01.354553+00	2023-10-25 17:59:01.327484+00	f	\N	\N
a5852c89-e005-44bb-bc95-0dd00f530ce2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-10-25 17:57:20.883315+00	2023-10-25 17:58:20.875063+00	__pgboss__maintenance	\N	00:15:00	2023-10-25 17:55:20.883315+00	2023-10-25 17:58:20.889293+00	2023-10-25 18:05:20.883315+00	f	\N	\N
b04574af-c7d7-4f5e-a7a5-1798f655e7d3	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:12:01.647646+00	2023-10-25 18:12:01.668721+00	\N	2023-10-25 18:12:00	00:15:00	2023-10-25 18:11:01.647646+00	2023-10-25 18:12:01.675276+00	2023-10-25 18:13:01.647646+00	f	\N	\N
b8a74100-6fa4-47d2-8c38-ef200287dc71	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 17:59:01.352987+00	2023-10-25 17:59:01.37149+00	\N	2023-10-25 17:59:00	00:15:00	2023-10-25 17:58:01.352987+00	2023-10-25 17:59:01.378891+00	2023-10-25 18:00:01.352987+00	f	\N	\N
e68d2e23-a9c4-4f01-bdf4-0e3716c2a2f6	pool-rewards	0	{"epochNo": 10}	completed	1000000	0	30	f	2023-10-25 18:12:23.014214+00	2023-10-25 18:12:23.740869+00	10	\N	00:15:00	2023-10-25 18:12:23.014214+00	2023-10-25 18:12:23.853674+00	2023-11-08 18:12:23.014214+00	f	\N	12000
57fc488b-3f2f-48c6-a478-7d4029fcfe60	pool-rewards	0	{"epochNo": 6}	completed	1000000	0	30	f	2023-10-25 17:59:05.014205+00	2023-10-25 17:59:05.414243+00	6	\N	00:15:00	2023-10-25 17:59:05.014205+00	2023-10-25 17:59:05.54057+00	2023-11-08 17:59:05.014205+00	f	\N	8010
cc68b0b2-722c-435e-9b9a-efa062e272da	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:13:01.673597+00	2023-10-25 18:13:01.688381+00	\N	2023-10-25 18:13:00	00:15:00	2023-10-25 18:12:01.673597+00	2023-10-25 18:13:01.701571+00	2023-10-25 18:14:01.673597+00	f	\N	\N
b2b0d55d-4ba9-4006-a37d-4898bbc97342	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:00:01.377299+00	2023-10-25 18:00:01.394649+00	\N	2023-10-25 18:00:00	00:15:00	2023-10-25 17:59:01.377299+00	2023-10-25 18:00:01.401691+00	2023-10-25 18:01:01.377299+00	f	\N	\N
294feab3-5683-4afd-8bd5-ee54ba3b45dc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-10-25 18:12:20.891629+00	2023-10-25 18:13:20.886178+00	__pgboss__maintenance	\N	00:15:00	2023-10-25 18:10:20.891629+00	2023-10-25 18:13:20.892992+00	2023-10-25 18:20:20.891629+00	f	\N	\N
0e418fb2-a50c-4a0a-81e9-8b35065097fa	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:01:01.399818+00	2023-10-25 18:01:01.413028+00	\N	2023-10-25 18:01:00	00:15:00	2023-10-25 18:00:01.399818+00	2023-10-25 18:01:01.427065+00	2023-10-25 18:02:01.399818+00	f	\N	\N
8d1e8a1b-b749-4c57-a546-dde4d753c10c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-10-25 18:00:20.891157+00	2023-10-25 18:01:20.877314+00	__pgboss__maintenance	\N	00:15:00	2023-10-25 17:58:20.891157+00	2023-10-25 18:01:20.88623+00	2023-10-25 18:08:20.891157+00	f	\N	\N
b245372d-de83-493c-8409-fe36f7f7ee02	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:14:01.700052+00	2023-10-25 18:14:01.712242+00	\N	2023-10-25 18:14:00	00:15:00	2023-10-25 18:13:01.700052+00	2023-10-25 18:14:01.725066+00	2023-10-25 18:15:01.700052+00	f	\N	\N
8cc31db5-50a9-4052-9f21-1860339908be	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:02:01.425429+00	2023-10-25 18:02:01.43496+00	\N	2023-10-25 18:02:00	00:15:00	2023-10-25 18:01:01.425429+00	2023-10-25 18:02:01.451681+00	2023-10-25 18:03:01.425429+00	f	\N	\N
402f3dcc-a3e0-4dea-abc0-5822cc70fc9c	pool-rewards	0	{"epochNo": 7}	completed	1000000	0	30	f	2023-10-25 18:02:27.610945+00	2023-10-25 18:02:29.492838+00	7	\N	00:15:00	2023-10-25 18:02:27.610945+00	2023-10-25 18:02:29.598751+00	2023-11-08 18:02:27.610945+00	f	\N	9023
5f086e30-ca13-483e-a83c-f09ab7c5e777	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:15:01.72354+00	2023-10-25 18:15:01.736793+00	\N	2023-10-25 18:15:00	00:15:00	2023-10-25 18:14:01.72354+00	2023-10-25 18:15:01.750977+00	2023-10-25 18:16:01.72354+00	f	\N	\N
f2175112-f2a7-4122-9495-ae62b79b741d	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:03:01.446732+00	2023-10-25 18:03:01.45725+00	\N	2023-10-25 18:03:00	00:15:00	2023-10-25 18:02:01.446732+00	2023-10-25 18:03:01.469921+00	2023-10-25 18:04:01.446732+00	f	\N	\N
19fe106d-c69c-4d20-ad88-5d64b55396ad	pool-rewards	0	{"epochNo": 11}	completed	1000000	0	30	f	2023-10-25 18:15:45.021766+00	2023-10-25 18:15:45.833875+00	11	\N	00:15:00	2023-10-25 18:15:45.021766+00	2023-10-25 18:15:45.972012+00	2023-11-08 18:15:45.021766+00	f	\N	13010
2251e101-ae6a-4166-b9bc-24cf112b88b3	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:04:01.468345+00	2023-10-25 18:04:01.476667+00	\N	2023-10-25 18:04:00	00:15:00	2023-10-25 18:03:01.468345+00	2023-10-25 18:04:01.489456+00	2023-10-25 18:05:01.468345+00	f	\N	\N
d9624d2c-9301-473a-b6aa-7f4e3557450e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-10-25 18:03:20.888173+00	2023-10-25 18:04:20.879713+00	__pgboss__maintenance	\N	00:15:00	2023-10-25 18:01:20.888173+00	2023-10-25 18:04:20.886046+00	2023-10-25 18:11:20.888173+00	f	\N	\N
4d5d4212-46b8-47b4-bad0-4986e3efd03a	__pgboss__cron	0	\N	created	2	0	0	f	2023-10-25 18:17:01.763964+00	\N	\N	2023-10-25 18:17:00	00:15:00	2023-10-25 18:16:01.763964+00	\N	2023-10-25 18:18:01.763964+00	f	\N	\N
fd53f293-5cd3-4319-89db-93d8451522a0	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:16:01.74901+00	2023-10-25 18:16:01.759054+00	\N	2023-10-25 18:16:00	00:15:00	2023-10-25 18:15:01.74901+00	2023-10-25 18:16:01.766647+00	2023-10-25 18:17:01.74901+00	f	\N	\N
7e3a27f0-84fa-4ccb-a9b0-1922481cd17f	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:05:01.487953+00	2023-10-25 18:05:01.501321+00	\N	2023-10-25 18:05:00	00:15:00	2023-10-25 18:04:01.487953+00	2023-10-25 18:05:01.507196+00	2023-10-25 18:06:01.487953+00	f	\N	\N
1541a517-b3c3-46bb-a5e4-c5765b16edc1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-10-25 18:15:20.895055+00	2023-10-25 18:16:20.889327+00	__pgboss__maintenance	\N	00:15:00	2023-10-25 18:13:20.895055+00	2023-10-25 18:16:20.897278+00	2023-10-25 18:23:20.895055+00	f	\N	\N
6a1bac10-5f99-4617-acd3-f174ebd2ac03	__pgboss__maintenance	0	\N	created	0	0	0	f	2023-10-25 18:18:20.899147+00	\N	__pgboss__maintenance	\N	00:15:00	2023-10-25 18:16:20.899147+00	\N	2023-10-25 18:26:20.899147+00	f	\N	\N
47a39e9b-1282-471a-9620-45dbcf099ab4	pool-rewards	0	{"epochNo": 8}	completed	1000000	0	30	f	2023-10-25 18:05:43.613408+00	2023-10-25 18:05:45.575223+00	8	\N	00:15:00	2023-10-25 18:05:43.613408+00	2023-10-25 18:05:45.697496+00	2023-11-08 18:05:43.613408+00	f	\N	10003
a446282c-5680-41cb-8067-e70a88c657c2	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:06:01.505677+00	2023-10-25 18:06:01.523972+00	\N	2023-10-25 18:06:00	00:15:00	2023-10-25 18:05:01.505677+00	2023-10-25 18:06:01.53776+00	2023-10-25 18:07:01.505677+00	f	\N	\N
a18e0916-6f6d-4f22-aa38-cc66b9efe3a5	pool-metrics	0	{"slot": 10127}	completed	0	0	0	f	2023-10-25 18:06:08.409703+00	2023-10-25 18:06:09.583982+00	\N	\N	00:15:00	2023-10-25 18:06:08.409703+00	2023-10-25 18:06:09.748775+00	2023-11-08 18:06:08.409703+00	f	\N	10127
2e17b2db-6787-4a81-98fd-62c1704d4c98	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:07:01.536068+00	2023-10-25 18:07:01.551224+00	\N	2023-10-25 18:07:00	00:15:00	2023-10-25 18:06:01.536068+00	2023-10-25 18:07:01.559688+00	2023-10-25 18:08:01.536068+00	f	\N	\N
bc616fa3-a22f-4262-9647-4afc7c0a66ad	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-10-25 18:06:20.888045+00	2023-10-25 18:07:20.882623+00	__pgboss__maintenance	\N	00:15:00	2023-10-25 18:04:20.888045+00	2023-10-25 18:07:20.894969+00	2023-10-25 18:14:20.888045+00	f	\N	\N
004274b8-25ed-43a0-877d-55a9761a09c7	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:08:01.55818+00	2023-10-25 18:08:01.575274+00	\N	2023-10-25 18:08:00	00:15:00	2023-10-25 18:07:01.55818+00	2023-10-25 18:08:01.58177+00	2023-10-25 18:09:01.55818+00	f	\N	\N
3623dd9e-6679-4d9d-a9a2-f389e33354d8	__pgboss__cron	0	\N	completed	2	0	0	f	2023-10-25 18:09:01.580144+00	2023-10-25 18:09:01.596635+00	\N	2023-10-25 18:09:00	00:15:00	2023-10-25 18:08:01.580144+00	2023-10-25 18:09:01.603311+00	2023-10-25 18:10:01.580144+00	f	\N	\N
1c626f46-d4ef-45f0-a6b0-a002d523fa15	pool-rewards	0	{"epochNo": 9}	completed	1000000	0	30	f	2023-10-25 18:09:03.818326+00	2023-10-25 18:09:05.653551+00	9	\N	00:15:00	2023-10-25 18:09:03.818326+00	2023-10-25 18:09:05.779987+00	2023-11-08 18:09:03.818326+00	f	\N	11004
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
20	2023-10-25 18:16:20.895796+00	2023-10-25 18:16:01.761618+00
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (height, hash, slot) FROM stdin;
0	dfecb3e3dc99283a83f561c12941ce484d1c3953ca265e1bd300443af6bc535a	16
1	509945b2110b9753987e849c3f5073af9b018d4bb8571713e46885f5cc875a1c	39
2	6e57f38e783eb29bdf1a945b9addb996b0988873d2e6d675aac9b9305a4cfc25	41
3	59005e41d6e610f04f77bce529225918eaca7c32ded96383eff00b5eebe0379f	45
4	a9a441212b5c1487da0b1101d292b5537edcac9bf86faed3e2be98d03959974e	47
5	5c82b78670a9e1757644647fbf99e325794c16b1da32a2678f28466d94309798	81
6	ba5a28ba4a81cb98ec5f3bb55e25b94dea2ecf2b010f551fba39828795643721	95
7	941e3fcf64d4ce913e9ddaf263f66571396994f93287680c9e3e8377a3ded59b	100
8	a69d93e2be318b00716c55e9d6a5b4fce64f0bd0ca8c44613b70ce98fd38af60	101
9	15cb9b142207e0c499294ad071ba2bad356327ac39f7f200be2cffae41236b57	103
10	ba807bd31a44dfa3d64b0a6229065071a2034004ae5a16de03be31e8fa3f48c8	114
11	abdc3991583cf3954a8b4a7fb5c2d5ee326893773fd2ab3e2b3cbd24d246687c	118
12	c47c2435c19a8bc73625b1531880c73770bcc95bd89401ced0f42a91c5696127	119
13	a2de026a4ccea6d50af3a2824252ad90e04bdc9254c6dc42215af7ab35e3a85a	120
14	ed06691caa0885160ac6d99806fc72c968f2581a25d4b165ccb6a654d2bd28c1	141
15	551da97edf2a6cef4ef63817b556f3c249aa9a0263bd34ae29218cfb61c0956d	146
16	63defea097fc24a462be2a68cc232848eb0d7e3c7075d4f575984c595c3b62f4	155
17	084a615adcf3bf38fe4e0dd37eb947b9cef2460aba3686a5f31d1768ee712efa	159
18	6d966c1d8da0d85f5dd187078170a14e8b244adb2d6c1119a3b238fa5fbe93da	183
19	82ed322465d7834ad47e0cbc1962d9656739102195c2ffad8aee7be05c5b440f	194
20	7dcdb94cb50267aad590684cf1cf9dba895183c98c0bc90ce6ab6fd287abe5af	196
21	8d2fd35ecc7a0edee9ca1152b1494484a1201125e22d24c12fca102aade7a1e3	198
22	d60a68a6c38ba1d5434a3a96b97bfe5cfd92fb4221386ac01a03f867637422ac	204
23	bbee5bc1c48a44cc2b4be63d85b4dbf5429ff08f9a1dcd295609a9ff29ea8c01	207
24	1f81474222b1be03b352fdf116758e22320328eed20a0ea3add51410ad04b25e	209
25	38f006f373fbd6a3ff0ca524b8c739724e4f4cf7929c605b5d912cef05948134	212
26	a346933c26b417dfad4ec038184d0b984ce4ab20f6c2237f95955128868257fa	213
27	58bb97beeb073ce892a99a544ae0640edb84b1060dec6ea81588171b071759fd	221
28	77c3aefb9f684554a4442ad803b1b82a49e5d0b0408cbfe7daececbfb37807d5	222
29	af7998e15df77808369fa9754433ed4c08976a03691416eee5c35be643901765	227
30	9cd931c6f7dd8d0420c70dd3e930afe7922277e8b227d9d05787bac54635965d	231
31	25e866f73dae6c79498adbfd023e2ba8570f96d9614d4c8860b02cee410c0323	247
32	2290dd2d66b762decefc21032f19f5d73d5fb658a30de9e69175f32f63141826	249
33	e750db2424888c07a85b6093e4f74bca4d8f3de661590935d92ff6773a40f467	251
34	a2f0e11198c79cb79df81212f1eb2ccb61d435f079da29f42be8adb94bf87de8	267
35	87b733cfac25bff89160c7f294cc9cce7d7bf8eaf9559de7ff581664efa4f959	277
36	4cf1a9d130c5878434e5da7911aad5129c495eee15323f57b00072399b707859	287
37	3af930f419b57ef9cf0aabdc925d23fbc82eb3fe0e0f701bdd25251bb36b3765	303
38	19e1ae91d662ce28ff8b7d25be0692cb9bc33817a5d4408bf065064828987b2e	321
39	611c804b89ea86f2e370412770d111e02a20cd2ebdeb2958528a2ddffad99967	327
40	428ca5acada027aef4aa85a1268d18374ab3410fcf2ec20627a37ff13d1e8586	346
41	a51b440eec8673b6d9394e572067897fe303b1c3646a8acd33968cb6fd983a59	361
42	e83fba2e9549a167ec192bb18c10c3a89eea621fc196f362de16d25c388ed575	362
43	8c154eade949a6c998c98d6192cb5581f948cf54eb09f2be822e66832d23e87c	372
44	fa147d0ec1a39c8ce2f9de533c733ed4763b338f75e290a73fa800c8c3c952ea	376
45	de5f4a25e9f94baffd7c6d06fbed87eb1fd403c682a1dbb807a30e52502fceca	409
46	bd47300d84385b861dc04942f991131a0c58d5e17c3a9b85f13fedf1868af45d	411
47	4e6f50772896b7f64edabce55b15a1e3d21550da5c07a6ea77dce42a4d863948	431
48	55cd4a8114a1afea3539b1c4173df030319205c6c348068f173b59d4917b78a7	432
49	900978bd7116eca1079570d4e246679c57fc19e8beecf3c4acd57414c0566568	438
50	9e004ccb608b1ba5da498c8803b82e019f8c3373aa4ec79d1fbe7edd3a5d8eb9	440
51	59712f0c60808054d194d1dd2ff745592b0499ef92353c812c3499f945177a1e	450
52	696412bdeda280c75e58db9fc14edbb0183fd7c616ff0c02b9f5d8f8911b1c1e	458
53	8e0235e6aba3e9938032d9bf22599d8c79117aac72d36f49bc1b084cf250d9e8	482
54	087b75b09bede36dd57ca11e0b0638432977a401bec968dc60d794f58d6f29ee	502
55	f1d2022ce1f15cc2ca06fc37ba437aa47c4e10a393ce67a138dd139a87d47b61	506
56	8da96ba8c01067874c67c5baf5f80bde617da4d2ee38812c3dc8a4e1d9e4bfe3	507
57	e1276f6ad2d7e0f5ebd69573e0263331a6aab60a728122b50355f2e9015e6cb8	508
58	9e0f54087586f5b8d4dd96501a1201d603c5226325398c3851380483b8aee745	520
59	2be2cda07723507a3e6f868765b2e2e162c04436b830ce667e0d5abae3e3558f	530
60	c9a887b28e858275e14d9481c44c062808c8d75d3e7af55f6feb893061211413	566
61	2a5862e07f543a429d4ee77ce62550bf60776fee7587c555a43c9dc91a6fd31d	587
62	711b73cc15d05b274724d4937622fdb976648b24b42964f3847b63587f76a23c	600
63	34250865948345dd9e821a71124ceba754b4421eea374bf95bfc8fe1d45efe37	607
64	9d898f884dc30b343951a360749bd140e51996d9738ec99e87edb951602c083b	612
65	7d799a41d6d424aaf78a746b073b47f6e14736679de84e04ba277ce6db048220	625
66	88124b8ed2a3a50c477a6b4b6e9a684b158da565afc7b376818def2273071d78	642
67	419731e29e30ca177a0bbd7a0d9cb28317376ed33e430314c38f3b86b76edd0b	646
68	3a9c9b02b7ce38b093b4c11ae089d3c6766d04c136f605c206c39f8922d85512	663
69	d03843f41aedc9f070ca3c9d543ca21cfcf6bc3c10d81a334755ca5c3d72ba9d	693
70	b1a36944a71f04f87d76e1aefd1f60bf7404843f94ad1803a71e45b95c6a1b13	711
71	7a1f5c4dcddb4a38481650f4ed6a1462f658a1721b4fa86ae388359bde8aca67	712
72	b23f69c0adccbd376e8ef0fbd40f4e401d2654370c07a3d32855160d0cdc9a6d	716
73	32bea0fcece58f6b50c365595d6c1b3fea243ad811661fb794fbc2640cbb49c4	719
74	1c62e287ac0a5d5ea2bf1305595d68873221898002e84af1450abbfde5e58212	731
75	16049599937516e07f25544303645e594c76035102e825cc44c139387b1f45d6	744
76	eb6c7fb302c3369d9d01ce389e272001b4e343171d8ae76051c71be706e3f8cc	751
77	20ff94606f7a46e5dd1a9952fcc96c9be74853548221e81236d7dff8877beee9	753
78	d647053d44bc70f2f10e42ac85eee265b56eef81b97300b0717333058b117a1f	762
79	31e224cef4aa6adc482797a50bf46ab17864bf51c33b2930631c0efb39d8c759	765
80	44e89177ec041ef07bd77fb44c852fbe7ab11b9a4f6654aeab10367e9572220a	775
81	2b1bcb70a371ebb566f4d44fc7db57120147f087fa9a68c78b89bf7b9f0ccbbd	797
82	11da9258bcf0f6273744fef829d728f340d60d3090db5b1906dd7c24bc5d0edf	800
83	6414882c06b41c2645ffd2dc3770911fd9f16ea08826bd1da886d48994058580	801
84	b03df6a3f0bd50a426d9d23e79630478e4842caccc575e762961f74add3fcdb8	803
85	5b4c4a2930d9aad0179f8add7351b6c5f9e88b477e349073765aaef08de9cfe8	805
86	3c95924d3133584f1a1c7a99a81f724e47b108d371a643d64461ef5a643dc8ad	814
87	90d1d4f79d32a92f04ee7cfd8da67b8b7d5285077242830b82f7457ad2e59ba9	828
88	88d60b7dc39cef43dabeafdc209fe59487efca28463c669e6a589652c2a339c1	844
89	d095573adc6f77aabba592d6d1ab211ed2139c75bbd1f8d387947d7f35232df0	846
90	05a95f7a1617beb567b8df53cbad7c2ee4818275c8da6ea0e75c5163978b6099	861
91	97044e5c8cd8d2c4f967ae0b1bd93790dc5a0675de3fc9cb2123bd9263a9c73f	862
92	09d470f9fe29ddaebd9d4cbc81bf34356cbbf3732ecad1f3e65a8630e46d431e	870
93	8b816dd781eac383390bd60d93487407b2654349fa5119e9e0b91a468696cc48	878
94	b31d411d5580817b416ce137a481893a3ffda519a16a0c9ab29100b0ba7b636d	879
95	7413d74daf79bdc73203144c7a451bf336ae0c4bdccae99f628ff35e8479c340	907
96	dec53b0427d85801f6f026addea77d18fcdea87473da440943cfaf374beceb3c	911
97	2865024c0d1bac6e6fff4f0e56b90312c84c31dfb28f85b38738fe86ca9fdd6b	926
98	5e80d0b617765425f3abad1f3259e6d9903463e2edec4db728f61053cec34b59	927
99	2f630829767839192698e14d76ee519e8678284a1b8e0f9692fdd3d37058502e	931
100	1d45d1dd02e1154b398995c3be58a68f4d0f2f6fe5700c226ccfd1091bd18e0d	933
101	ef0070b72412e6b77e99966d7922bc58f7c27bc42139f35c4815927b6aa93fd8	934
102	4de12c28bd6ca1238050473f047d3b42c7c909178c49c5a2df6ecc6a21cfb839	958
103	32596410c60cf600425dd3a41695245ff5d5cd1591b3d235ede7c8a0d6d9889a	960
104	1e333c371f79a6e03cd84d449adb7f96132ec65a2bbaef7b8d187fe5abd85a4c	971
105	f290984ca1b824677e1e3d731c693390c9f142ee8aeb39ec23d0ba63b5da4b86	988
106	7cc775ddcf93d22b852a7fcee25cad98987a4cb7fe38113e8e77c224aa4c39d7	993
107	d75e164411f389f60f2586ec3dfb581f40e7ecc23010a14efc5e784556566392	1004
108	e41f66ac51939b84e7f07b7adad11152a4381f841dc67ab198abcd4a7d2d9731	1011
109	fb0bf0344804cbee7c1f4000269d42cd2182907ba905f650308a5809da1f081b	1012
110	a10934cfd73a9e39bc5fd92db28a20beaee09ca5e78424a0782e043226d790ba	1019
111	b6fb21915a4c60a031acb6a898226dad196587c68f263363ab5246b9f7057260	1027
112	ef227bd969b822441b92152d25b9cd272e07fbd88d98c6df459f3e3c63f80886	1035
113	310fb2148fae0b028fb645aca2ae83eaf302a565e80da81a5c221d305614da19	1041
114	7da19f1e2768a059c7de3a9942fe24eef8eb7f93b40b76e5f1e29867747d17ad	1042
115	82c4fbeadd552e58a2e186f300a9850f340a1d94206af33535922e81f326ba32	1056
116	ec9516be2d9d62d58c9557166060424404b5b477deb3ae0d2619d4739a59d852	1063
117	cb151f3bb88aabf2a586c0ed034f04f8c25ea8bb625aeaea20a3e59d2b127cca	1071
118	869049fc4dce7a2eab2d3994d4c07d7e3a1cfde691b44acea9c0f5ec2957ab08	1085
119	046d979b9fa602f69496757cb2843f44a52b1c32ca29dbf2cdcd6b1d26efbb70	1088
120	f1ea3da960d50390f1f5ef21f05dc89e2ed1afa3d370b04787e30eef51af8945	1089
121	cfd276c4ee80c1b6f1275115b4217533a6d8024509a768c5ea9a6a3b9dcd3303	1093
122	bf559a585bf111413534bcc913ee5f162772e0ae31024d1d41fe61af0b16bf25	1094
123	950fbca5f8370406db5fa2dab0dce5a39508ba4ffd68bf3b3212764f3bdf25fa	1098
124	082044c855853f3e0b90dbf8a04b4d321529f961598eb2b26cb2ef78c7e0ead4	1099
125	fc481eff1a134227241e9da44cbc18b444836f07bfdf1e8155687fe7ef5ba53a	1107
126	8af443c87585f424b7b35d63b035556a4370576d3f9a45ffad278fb0074c77f0	1119
127	2b4dbe972321a76bba7b117f46c5875520da4c7c14b9bf4ecfed7c60206ddfcb	1124
128	5478a552f178155f767caf35146f9a0a2923cf3f7ad7207c80cebc21715b06a4	1127
129	9f019f1880689e1fb77db5dc854057220e208dd8df8deafde50545c450929e87	1135
130	a00d477657e6f2e082bac441fe3b3f89cd30495cafba9fffbde605e505cfcda0	1143
131	f4be64e297fb3e23bba001b7828e62eb31e7438f2fb0985a385abf4c76223be6	1170
132	f6337759cf2ccf7aa3757bbcb9099b391c5daaf952add2bed5fce1004e4a556a	1173
133	732d75cafa48a0bc5ba65315c4545c408a5c1055d739052bdd682f3c3d544188	1175
134	4ef4bf357635c0055ebae545b6fc89826ddcb2681cd609662c2fb55ae83cb5e5	1178
135	1abbb804d5fb12bb03f5dbdb14cc5b1fa238c751808ff4cc9f2a5dd30677b5b6	1183
136	395db2216b674485b571f96175692f17056894fce704cc3a79f6d541ae402ccc	1193
137	e49f5421a3cfecbca223c9a594f30b861902ce825416857b23c50b98021f092e	1204
138	812408f9ee60145697aaf8a897cb8677672e611defa95e6fdc1b0cdb4a14b5f9	1205
139	7468fa5286afc96c94d6b2c655f64651362eda6c66d4e74ebf7081cf3192bdd0	1221
140	5d76e3e31f7e83ec53d302f23227d72b48483c6d4d3166f4bcf4d4d32fdb6633	1236
141	a38134024ad0050be61dda2e8adb8793545bb6705009cec39edf023baf99fef2	1249
142	6ea09ec614c84f3cfdcb199637b69cfbadd479cd497898aad2f3e48c157aadb7	1262
143	09755cace75d555e6359be0a237f8160ee8eafb6c241f9e886ab1f22a7d79369	1282
144	5a09515c6d6f89f83d6b1dcb142dad11f0586d3d02d80e90dec1e36e37a78b32	1319
145	e795ffdfcc62e787b075543834ebd35d6b4350d17c3585c72ce99d242413222d	1341
146	8d787a7ed32d599a1a78b20a038e26c424f8b17645352bed9c2f1bf8e0b466b8	1353
147	7f121b0b7f596c48ec4973ed15d9b889b4ff5eecf238fc9e1fc481785dfde2d2	1356
148	4a9461676581df06ce7f200ed8bb411e33413ddefda3c8077e2a25115512fc69	1366
149	7955dd1bd43ff0b6bd4819647281b521bcecdaa238b1c752f8e36a3e6bc58e70	1370
150	dd23d91de0be28ff51a74be002dea4dc703412d2c17ea38a34777d8a5e38bfde	1371
151	6124fdeb4a38f7c3f0d970d45f9c1f4f243418aef78998d1188e42113556b8ba	1383
152	bcf40f1824fcf32732d1eda195b654a5648770871876c933a32f44f19c06e528	1388
153	8e80750b6d9ff8a23f7ef0d3edd1e7989beb57e42ac464eeadce5b05fd6f0fed	1390
154	b741666fbf07182f9224c88472d4af733d2c998812c9a9038e861b472af3d4bc	1394
155	4501115406dbc1f38711589e8c1b141f86340aa6bad95d515e37229b5db85148	1395
156	16ff406e7eca2b5faaaf57142db5c4086de214e0f8c97f04facd51c426d84d3b	1405
157	37bb32a6a40cc1c0ed7ae87d02b8d811c36f42df5f2afbd0109ab7bab2fdf620	1406
158	9df3cf29629e76714883f125a2383e335b55ce14c907cabce36ccce673deb604	1415
159	f79a218a6637e71b44b0fdb960a80c38b540e62bd64e656067a4f359c7e56ff1	1429
160	aa280374fe5db15a86b411db17887e7317d5eb78e887c27fc4d7ea77dddd6ff5	1435
161	835814a380a6aa4d532a021fa58860856d65bf61b1a00d3f0666abacb829c777	1438
162	7e349aa9b20e360eff9bfc42a7e8507a947d290c556fdf7c45d561a734bbf8a8	1442
163	fb64ef4050fbc727d6f65f4d5b7ad9fae455251a81f4746ba8f00c9d92298a9f	1478
164	41281b531def7bcba42b6418fd06d58a24331d178b507d9cb2efe48de87a433e	1493
165	4940401ba9cd4f69378f5fc8f5a0c07d4a9883394c16ba15e8a916f49fcdef73	1506
166	53f7e5c387771ddd940c35d8c64d7febb9d672194fbc52c69879d7662e408a4d	1512
167	5e98f8ce3522b28f68b908253890ddec35cfba597531251002071a243fd5da73	1541
168	4ed85ff92954c0ed5da255fc9cca2852d797e4263f4bdb2b07ee156c7cf6719a	1559
169	e560180c47470d5a7330649824ec6ac8ecf49a8a4f39bf6a75b024b6b57b8a81	1562
170	6e387321cf3976c4ec832195126278b6aaa6ac6abfbd4da79e7957b15d9cee35	1573
171	da236585d6f8390ffc4633fadad63088b0f4517300ccb6080c6434b12eb6b4ae	1574
172	a5df30c6bd88af7b8a79602aede7ff6f64726b7998bc02c9dcfb7499bd3ab9a7	1581
173	afca426e07da8be7cb274786d933fe622156064dbaa140c78ce6354e667a38b6	1582
174	f0e8079a66ee99bd232e6ec07661fbce0a136714d5d48457d0e7edf007dc0f4d	1590
175	a6de53bda242fdbaba3580b3e7203e744c6bb4adf6b0d9a2669e18e9bdb2e298	1593
176	f0500fae17cb714f344660d20cb043355ba5832f29c42d01d27061d1f08b1eca	1618
177	30bcc38e2b52d5801e895e7e60529ea8fe55f6c38b777b76345846a2a6e3a65a	1619
178	ba48c538388feb3abdfc8d69fd531a91edf0e2d2c8001611e7db5af480adf00a	1629
179	316e4867bebe6d5b818d106b4cf1ed4a3809414e9f38c1e42ecff0bef39d3bde	1674
180	dcf266b251301839702aa9e94adb822d2ca89bb4379b37355a5e7dca7c993311	1690
181	1735e198090508864eaf7afae604c03da1ea4eb51c98112fa53accac0b566381	1692
182	f8a3b4af08b236af264589300b1e9d6ee87abe33710d527b0c2e8f3f7d51eac2	1699
183	b4f6d0cb37ce00451bd8d68216c1a6284546d1db9a1d30392ffb40930af2d4ee	1707
184	f7884109f2282b0099dbf02e0e064a7ce480cdc054e1b9604aaeba346fe090da	1709
185	99748f8ded36954303273d8642d1f7ab6f7a828d1f04fa26449adcc8547868b2	1711
186	cb48969c64c3d5eccf0f54d78600c4f25870d396bc427bbd8062238d86dbd2cc	1713
187	1351802fe6fe2b31dbc3c0df98207deb61b8fb4535eeb16abc2518dceb8f345d	1730
188	850135ac230bf9bef2ac51ef3d0ec523b757ade3260b27e635fc43e7b71217c9	1736
189	d14b4e2e7708f1b85d6549bb8e11aca4e66e18c54de3f6208f5ba7d9b33c8fba	1739
190	35bafd7ee0fae837f6ef3f6e8fdf59d9d294ccc5dfe85a26fb5d4e2dc1987018	1741
191	3dedbf75d28fa95f6ef14708d6e46d056423fcefd95050a842eb795ca4d66649	1749
192	24b951be8ababfcfecce307b78d69fb0e3e77f149c5d416339400b0faed154c6	1780
193	91b767a65d0b833ee3beefe91ee8182f8f99708fcfc2683b6a1d1e3a011c0da4	1787
194	299aebd4c44a2069ea375347ccceb89c7c88ff7c6209b18d2e25c433bce4fabe	1794
195	71a0c95d6e4162b6b0b99ef3189e56a531081d2dcbc0b825c81801e4bbc7ae24	1799
196	3c08e53b0908bb0fe1e41ae20554c8b4c359b45d3b3a17744c6659b05e2d9afa	1814
197	694d0316613c4cdf15e6071e409c4f85ab63e0c01c3f3b62baf74cc0d27ba448	1825
198	97d882f30afa3696c042c941c773a7056f595832d3cb57c1bb16aae81e06bc20	1848
199	311e3f7d6f56637027a10f9ed5cef3f73136e16a5688d23503ada92da6f8a875	1886
200	a5c37aa43f10f6ad93e2aa5853f2366aea738cba698ee74e004c9f790fe5c513	1901
201	e70262b929ff0a3f5a0fa35d7ac4501e066af65ee8c5657a2f330400c7bb293d	1912
202	a6fe710c79a2ccec0eebd729b60902d1f64aa8bae2141d6f23c24a7622b714ff	1916
203	2825226ca5bed33c7acecb7cc9625e1aafa619cba0e08f669f44aecfc6bdf7b9	1921
204	d19d17f277a71ac01f7ca21613e34d534709a675f925c830557ff5a38bb52ad7	1922
205	d7ed99cf5375d43fc256b93efa93c75381d60a74465b9dc31481723965c58a54	1929
206	ab86da5f39c4e935efc9778e087212d44b834a32f49c04cf779c84440f0bfb15	1945
207	e10332b0b5e6255e068e18407d3daf4be8ca32d73885568c400b13573059ebf5	1972
208	27b6ec0738ba7f930fd5a546d7e138139c7e3a67ea1c301e935093659960d724	1982
209	d12c3ced8a01907602eaa084c613eec747f4fddb6d9b63c68a6d72faad2d87ef	1990
210	621be2f90bef8d2ae54b2469eb39553f626727efbfd52c5de7ee73b3724ee71d	2000
211	c975caf3bcc4e2840e684f9c458f55dfb9f0ae39266f37b905496596665808b6	2007
212	416d24efbb3e185fbc640eaecda2539f5d2f4fd431e3c191858aa19c30638e70	2010
213	93826e0764bf226465f35d44f5849742caf4fb52256e22cedb52a614235a2811	2021
214	7eebc020d8bd1daf645529e589508d22142e5034c7432f98e81b4a2e56535522	2026
215	16e596fb3c0e9850da02d0e9d618763397aaa6da1b9d662b6d9b72c64a0277fc	2064
216	04682e0fa3ddd4cc7900cf0daeb1fccc2593eaa2419ada93840b3a3fe7bd5d27	2065
217	08d2e8be7cfcaabd553337ef0c5d32e41a129ef48ad4a8d528e5cb52a1b648cc	2068
218	d79ff587e38d451d4719ea1aa47059b4f61b4924475ffe19c90df1e05fd1c7d9	2070
219	1826207da41f246b5c6ff17c69ac96bd14747e267ace685772e0d7446b1db27d	2071
220	56afd580ff40a6b156899411d6adb6d49c7755e863768417fe2bcfda7dd0b64e	2073
221	90c052beb0098d6a07779b708a51e2c587fe9d84e4d3b73dafcf23f71cba9bd3	2075
222	f588341512b0cf27e8a0e342af7c7e47b452a81a0317d7f0a8abe94059a345ec	2083
223	082970b3c5363f86dc54424660c6a576df3bba878ef98b93247effa691371976	2087
224	a7c462c26e521f55501cbdc78f4470457d15881db3faf2c87c08eab4f89058b6	2089
225	f208eda77cef7b4dc4d0ca05b6f59a3667b672b013f14a2ffb23109cc4e5dd0e	2091
226	e5cc73365b253de42257f7b7af6c362931e0ac64eeb1a39e667d631926d18709	2092
227	c8a7a407bb92c82ae3169d7ea449b4d2e1b9dceebd6816c85e947965d2daae95	2102
228	fc92eb4693f2ac1cbd99cf5bbe2164f674339c81ce5d7f958b94c36981335e45	2104
229	8ce2e596890eaa4b99181871d422689072dcc951437315e9c160378e6470a8c3	2105
230	5980ebbb5b4b613735a8830329f0c544a8bb62ddadd9746ab0c7ffad64762c3f	2135
231	10104f5f84dc310c28cedce675fc4b377e930fa4ee45a1abdd5be16acc37b42a	2141
232	79eb71fafef6fd5e7091e4107f6f995497bddd2c89f72c37c3bc815f33a22a16	2145
233	995033a000e2e95b9b4a57d034ed1e028b9bd8812f70c3031ffd2f92756be0d1	2156
234	e2c2e040d5fbfcbefe47f9352efcd9fb19b56e3e73279aa3db6b4548ec134869	2170
235	af28fed0012ad8d0b0ce09d7310a1c3d344f6a5797245e7b3a26b32261b7a51f	2171
236	f0b90a92ae6155972c4f444e994de8c722c3b7944797d0340f8c7e05124183ad	2178
237	42fb4892bce30caf19031cb17e9b77c3181326edfd7588a3c15aa7fd3fade997	2184
238	30fc38e5caa330a5dccc1019216a566bc493a2b2a91536fd885a3ef22a9e0da0	2214
239	83062549b68bca0b43bd068a05be16563f39c5d71862583f38bd593afab5b7d8	2229
240	78dfc54d8372be3c37e563a852d43535c8f4561e9fef7696d5c11e3914a12925	2259
241	a1b2d369daa6266c5942452e865fe3ac0f20765cbb4d5f9a664c51ddce5ef965	2282
242	90e3f551af097e731461f324b02b78a285d9d725d43d9c2a6d3658950e47b700	2284
243	94033bc2b386b992ae360b5c1b480ef1c8ff0da24b07820d9ca582a0893341ea	2294
244	6de96631283c2fee0ed4a4e0039c4b989618f30dc592774d5d7510e21c80119c	2319
245	76912e4de7885a782fdad3669b688a1774cde6817889dda57843600cb4384cad	2325
246	4a500ef839e79044b35265d6b05fda7e6593cd01173be8a91b7d5e197c97b68a	2335
247	eadff244f627509792a1b410b3a893868576504cc8cc3ab8092fbdfdb07a9da1	2337
248	bfd94a20d7935a505384fbc315ac27f378022a3647a85689d1561cfdfcd0cfd8	2338
249	dc2b9a418d5164e9b8354795342b7316672ab51e04a497e2fa3c4a4f23fadcd4	2388
250	ad0b69f886a1486156a7905433e4a11c634dd0a5226f5249a4e083797f2cdf0f	2389
251	e32ac0a0cb49a42d90c10fee392f55e791075e2bc87617c3d28225aad428e13b	2391
252	37eb39939375a23b5070422375697374887ac4856a985d817803327de551b532	2392
253	1f558a48d8c2ab6734ca80f7aeef9313b21299349fc52c963360116d8a91fdea	2397
254	d57239be43525eb8cf241a3b6ae4a4c446cb12e2fec8a50e84fdb2136080833d	2399
255	9757ed7a47392f4418b3edd5939589c690d95cc868107bff48ce16f554005f49	2400
256	77f74d07b64e9749790a21d097622ed0219247ea75a60fc8ef3a0144e653977c	2414
257	f94b3607fc2b78bd6bdf1c249a6c74cf791c08364778a9928f23d6529a2b9f7c	2418
258	dee23ffefa38dba7a1e31621753c6cb1fb3e702803b5c58013edad7c411e3cdb	2423
259	22e486bd38a1caf4aaba50930feab7d0e8d2fcc8265e1d8a14ad665585781eb5	2433
260	a5645d25b0f4105e3c2baa91d8357dc721285eef17421bdd7bcd79f224197f41	2451
261	8b959d17f146f2f765bc3729981aac707f78515bef9ecfcc3b617d3cb5b6d0a3	2457
262	dfdd6e37d98778f205203a6f7fc195658e6151dae0b66a8982524e7db3dd9669	2464
263	ddd917c9bfb871ad0317e937eb0c5e400a42dd44765a5cafb2ef9a854348b158	2468
264	83c94c234ef871afc343005092067d81d59ad9c6f1665261203c159723333a3e	2477
265	128d256dbc95342cc56e68cb1fa41cee3d0da00aff4c8fa499f99aacf7aeb2eb	2481
266	93033276a4bb934b1ed737dfa41cc1b74b0d1fa4562bfeb7226fc1130e96b830	2493
267	a30a5189c69392293eeba1d73a6800c329dbdd32c8081c6bd6f1173b8b00aa22	2503
268	50b217738cf0c128b7187465bbefa34f9cde7c2968bd098bdad5352c6a4cf0f7	2510
269	2a27e848e3580b34a0449181b4b9f7d96839fec16346393797a15909531f7c5b	2527
270	55f8b5008a297b8aa3974ff1d1362cd3a413234cf9d5b5158c43cc7566cae72d	2552
271	403cc10c3bebde88d7c0d2c8919378f0a5805cea21fa41fae574bc3eb5782900	2554
272	3feae63097ed1df21dadb1a22911462450f698e1a916df8e72821a35d5837051	2555
273	d9756435f05103c95bbd9b2d8a2b3daebbeab9bada9e61282e543fabbf7b672e	2559
274	f8ae37750101a271b4b39080009dfecbb56e98a1ef9a0be8ce5bd56a3eb2905c	2562
275	237860b8096c621c13e974bcbb285fdbb77f1de55ca6220be8ea06245d5b7eb3	2567
276	d8a19d8cf957f52a2561a6ff4fd0fdf1ea45df2acdcd36ca3601ab73b73b3ed6	2568
277	1b9a23ff8d81023ffc791d10f5f32a9d672985ffaf6f08e11f59f0dfbe3e7496	2571
278	16daba68003cbcff0bca777bfe578e68428ca51f69ce2a92c7c2a72a5297d671	2601
279	6cc12ae30bc40fcf4940419c56d19c74513a2ce6dbb9651551f050a24d259d8b	2605
280	f37b166032ab24249287af925afe7622cfe3cafc13842bf5867eeea6767b5d18	2609
281	a6baf7cff98682bd1846a77bfa869ceaa8e30aab1410f12ca04f114427cf254a	2617
282	cf2305773e32af8a947c4a4050aa1380711fb65fc1a6638ccc84c5d0ab323eda	2630
283	c424a6ac5314d2092d9a60800c5ee4b13e181b889f9f97353549621f53ab4ad5	2654
284	181cf2e416a26a25a4e48986c4d814f5008837189a2ad10f06cbe660922d8a24	2659
285	e63020a84cc10311ecbae8aeb8937c39a54a2a257fe33f866fd0df40165860a8	2664
286	d8b5078b32a705f42d72e26ed0816bcb7025798bd4448bc460cadcbedcf516a6	2690
287	fd1d590484776ff828435a9ce3b0e8003a798f8cf85ee81bc2625195bc7dd906	2696
288	0fd9227e6f2253812a512143acb76a77b1fb78a3ad0ce3802ea2fbb995503814	2700
289	9af02e03ee42b3f8056ca9e055e342924f3cd88554882734161c1542dd1557a6	2720
290	d64b678628fef675ed1039445e1631ac32e8e1524f736a878fb9d4467fa91592	2734
291	feb4e17c8f1bf16e94eff5834041cf0c2bce563dd6b9c337fff64b5b76f2cb85	2744
292	e63a2997f3208d47184d1372578bda2a624333ce620b37ab6d991ec195abea02	2760
293	8add5fd92be020a150f284a4e0ba5ecf3fe0eb3ced19f3618a6ef60caa721a7b	2795
294	ed1669f4e389ed2709a760b7e9a83ca3e997380a0d5aa992c4ddb35dfcd3066f	2799
295	9ac774975d67ca41190374d31c1d8f08995a35b58d3eb5bb801b42bacf108a98	2802
296	b210484276ca87782a79d23ea50462030a2b4171f885f630aad8ca62db7e1c7c	2817
297	31b81f24b49284d7f98d994c8ecf3e9da73d30d3367586dd141ec71d6314006d	2855
298	7e6697f01a1ac021149f8c9a837e07b94be92c2d5d2235c8af193867a92503e9	2880
299	fd9f62608de015b8f46598db3afc249bf984bd915812fcd228829111152cf474	2887
300	967b4eaf3fb4c88e3c3dc282137e7023180d41f6e721b2b84f16db9cc04a20dc	2892
301	85b6fa77fbbc54ab532b6b44047988e661c3f69c81739615b2afbb443ebaa4f3	2919
302	18170b718fd6a3c0c9ce426f6585e816a5d16f57ba012c085c7491b0f861d1f9	2929
303	281e33a0ff1d31f969f65f0891cb075d117ce684e6c8aed525a95ab171ab871f	2935
304	29b0b00a72b69938a6e241efd1d14035714884eab7185332aa5ccda53ed73366	2937
305	1ed00064dc99b6a6f643fa93e3ee4ac3785aab17b4b43747a81dea00337e81e9	2952
306	1d0bb24b6dc91737460768994da3275b035243c514d21ffcfa872d01bc551df4	2961
307	149da24013ebc00607779a7bafd8ebe6aaa8c5d301ca854accc5d09bdaff0789	2967
308	6479aee2989bd8f554d72c0ad279284f811c745c41749fa51b6f209309f695c5	2979
309	9685a2cd156904819e829c3ea9b214dfa130e36dad5bebc46790b599cd85d866	2984
310	9b559ac7fa281d8e4599b73f9d4963fa92602a2d13ef2091d64f61f6f68daf41	2990
311	60829361d3f9062cb7f9387d9308c5034d870a1185248c0c55c53caebfc9ad83	2995
312	3daafba23cf30c56f5b1bf6cff0334c4d427e171e75f53dc19367aace3192bf6	3018
313	2a56b8a5b9a6bb266c362fb36421566b7b8aef16607f21aefd38e8a584af4591	3024
314	3bd3533bd5dadbc1ed28b18e0833e79c64eec70dbe97024dac6333c840a0d7ff	3061
315	cb97dd475510ad9d5cd03a9884f349c09103156c715c60966ea66d0f3a5b1c2c	3066
316	cabceabbaf35c0cd114697b525127422085f8a75a4e5e3f4737b6e6b59984f65	3067
317	6716016b64f6df07c7c5f8241d3c1dd1c95b73604a03043f1e83cff34189ffe9	3070
318	ae2346a4216e7ccee1b0b9d97b39d4c0219fa457d97a2fa8260b3d5fccbf030a	3071
319	8ffd6d9885fb93b01f54d960e8db5e02ce1c95be3d9bcef2f6a14d3cf878184c	3110
320	52debd430fd840879b9f2bcedb068755d7d40c90d4a1c664a5b2358662855d7c	3121
321	c4feeed7262295b63399c5c7c5b6cc84f2d539d0d679b2ce15c805d0fccd8658	3136
322	1d8c93530b89d68af7c14a59a85649212db3debda29e5feaaecbc6b7f1e2941d	3140
323	c64e72e4c5c7f7fa801d9df66e89c9d2a5127f7c9d3835659e26837f3ba1f3e1	3145
324	0a37e445b8f3f52257fb3164e99a14191405e77c4555ffbdced616e8568747aa	3148
325	4a8b341fae865405e9286bd84fdfec7d82d34d1be7fd59cd04be921394967ca9	3160
326	b703d11b773667fc797b8a4777e9e0003ba208e287113c7332d1d6769efc7759	3179
327	e76cb11156f7725d9f308ea59f521b529ebdc142b3066576ce0a123fd6da3e91	3186
328	54b65c8bb8176a570f50012167c26ebd9ffc51c0882feaab9461642aca4a55ba	3201
329	5486aa71ed4f42e650e47acf5219d6e2763680e58dbd97c7c2fce3e91463408e	3203
330	7ff7457cf78f26a14c2ad699016c05ae8cf1be3bcfec75f63f71755c77c65597	3209
331	0fddec4b5bcbd4b4800ab4ef2d0e1e73848d30bd343026599178e5c25371327c	3213
332	dcb518613e4aab184d0e2bed1106f0e48ebe14d79cac6a8f213500c7d9ce9de8	3215
333	298818264cea268d7ced922acf4c12b8b36b84bae9ad85a86633dd8533239045	3240
334	5ef09e396ba7784a836ab039582dd43a38076b36c3a105aa4289dfb8ec299f3f	3242
335	d61af81119e17f5b40634dc136df0441948df191a2a52ffe99f413a20fea3205	3244
336	7089ce410d67e42bc22be21658b8c3aa9e523b940e5ea001141ee4438b9899aa	3247
337	08351ca10b42db24f1c7fca91cadf968de0cc7964eacc189b876a5e05c5fc2b5	3285
338	0bc7e45bed84fb27e0a7cf5ba071adf2ee23406f1572f731f8375dbf1d26c29e	3286
339	c269e30c2a41e8a0968e923a29b76fd83bf38c5bb885cf837ca15008a77b2bc5	3291
340	1f426a44b1913f1a1f94c0474c971d6c1bf4e86692b98c27193ee615df114ad2	3295
341	3575823ff80a26ab61a2cce5a11ec83faa184b71a11edef306c0c90edca769fc	3296
342	2eb2923bfb6705673eb89bba963b7c5484b0d562781c509f44ea2e79fc99840f	3303
343	bc7e2ab32a44f3989457ac3d7ca0152249db29d1f1726d0edc477aff4c2766f8	3307
344	29124ca6bfd5b719660fb2255b9de576a476018f7f6a6a026433781123e40a20	3310
345	763fecea58a22230705b457759fbcdc2837ef087e7009e2b5c4ec8d01f975982	3333
346	1486f9a0d34288c2aa7d55a806cdc3c583366d74eef82488eba056a0e86a9f0d	3341
347	0d33ac285e40fa8377d88b732dd3fb84212ac033bfbb62256c5016f3b656a8fc	3343
348	b450179f59b81335c54da78afb68977c140cce73bb1e870ad1269f61dfc85e48	3373
349	7f96107f869db392abbc74ec5e18714f9d19d97948a8de5be0a9aeee43da013c	3376
350	2ff642ef4506a777d1876699889300fb6addc602ee3bb6790efc9674d66ffad8	3402
351	53526eab4ad3ab97bc7caa58836e15d80c78136235717273824fa535ecde9ec2	3429
352	20bdcaeab3a9bd722012307a8280c6a794223b9eae1dfa23e378cb640777a42a	3439
353	0865b52a116fb11e717fec6650ceecd6fbe49b97e2e3343e2150ac34e48de498	3449
354	3937adda84771d7758fb45086cd337402df53ba046e08ae2ea5d3c705d023ef7	3450
355	7ebebedafe29e24b1a5e0858a7c5b7b85f83355cc680c39aaafa936507ddcc13	3466
356	d1b5f13b3f4a3500d6a1422737570467e4bf74408574943044a802b121ef9433	3510
357	6daff1ca8b123a726708e1b27820f2b25c8850b25f8d5efa7d6d739328242c55	3517
358	35f2c7652282271728d6a2bd20b2099922f2c0dd4996ed46ff31f6761518bdd7	3525
359	db8f031aa7e27a19098c1fe4678f6bf74bafd49d5ee42014f1d68670cb675c7c	3530
360	3deb4447afbddcfd0c803b4e90b3a7a412ff0fb789a6487530e3e4d7723a5aca	3540
361	abaa8fc8fe93c29a4280e5514b1769cb534944eedca990fca4ce1cc1a34b5a6a	3549
362	1e39743e080de5ab7315e5c381a938e5303ba27b5ab12450f95d0343f7df16ac	3563
363	73887d903d1c6bf35ef28147bd64b18cc8cf946b5153e59e9c0f333feb289a72	3574
364	0a259678754c3e73172b28726946e7083103f13e60ff87161b464dd1e46eb43e	3594
365	b2d314266b4e69ef394e46424194535ac21e7c6fef768ed0da5f230ffa835958	3607
366	09a5117b1c3afcf08b437ff9b54d426bb570a12b54db552367377ba0484df34f	3610
367	604201bbe1490386b98c655fa75c7605b74a9f40c8227ea92860af7617ebf666	3616
368	e13af51096031c943e59cbfe8e10c0fedc20a40c2e5dc27588bb505ee03db913	3617
369	697ac3c02adb2ece1b514d47b3a610056ba9436a21e5f6b0bcea21adb67e4939	3625
370	420c53afc7be1b89459880cf67223eb7b1eb271f0a566c472bbae4e78db3f9fe	3629
371	a2d259a7fc267654f2156824c76b7c1e59ae392212d3ecae920ad210b7bb269e	3638
372	91fe3ed48d13f9f39d2f645093f21a03a7e67dc5ef762943559b1c2f09cc5b3e	3639
373	f426336e0f186bc44d898f55fd8993cff9641d08d3f4d58c7660202ef9e1e805	3640
374	a4c7d50e7b2a704d1236cadc180c4ff9de76abd48473fcff61c98bf6ffbf7af5	3643
375	be95e344ad8e4efe48322b15254d4e19ffe1ba6a07d5d1cfbfc2c6110d0baf47	3652
376	2a0eeaf0eb037b678b983b4b26a3d7f3cc46ab308f1bfa6cceeb82897800dfb3	3663
377	d7710be03e3e250c0b24d496e774723540d08a775656bb930bb3dd05ed125741	3671
378	dc154fde5235a60ba3659f1ea1f2cff81c8eb30a64b7e017742afd108d52199e	3675
379	72a74c0b4a4f33afd8291af381b76ff9db6e8f6dfd7309e5a337cbb6d3a54a12	3678
380	c0042426bead277ec078dffde84a828f119ecce1e2cda7323773ed95e86bc9fc	3687
381	1632565edfbeeb708ef531c999a3e4aa470f00c30c9416ab13a39bf3b9c52894	3688
382	8f9b7c2b278321bd8d597e7e333e0eab2222d7cacfd9d71ce92faf2b074d5099	3693
383	9541ed7954ef33c5d7ba8fb5e1634f73ad0aebd07b36a5ce1cbd1071f4bae7f9	3695
384	0573bb7a60732c63c6c3822cca8bc5d94d591b4a7152cfca33324bc7fffeff91	3701
385	ba11bd0dc9ee7f5a46c3c4254bbd4f577c5052ba9316631e9efea61bdf89ddf6	3706
386	3f3b454f32775f91aebbab1ee57270978f4981e4e20e89a1daaf4b6a1dc9dbca	3722
387	6012c9f9b5eaabc2fc0a119380665e0b57d2277789409b557606d4d599efc5ba	3730
388	070fddb3ca4c5e9adee9011ebe340810bbf4d819c460364d348397c71efd63f6	3738
389	c5753a6fb5030b68490d9d1aca11bb4a6b7e7595d7be37f02e3142495904a439	3742
390	69b075a0695bcdb800621a78c89903f1843c1e43f2ef123fa6f502ba38fe661c	3749
391	21aea4a321fa58752307c45ea2fbb63e90b1c9d41e6db55e3d10d522826761a0	3752
392	24d66b88da44bcb0416cae56bd25bc4fe8ea511f6b2b8734bb24bd2a7fb446bc	3768
393	d5fae7ce69b9214d212ab59d088fbe51f527c0546e70851c49312b257e31a36f	3787
394	6f3987d318d4773562f569ac9d9518e831a5c0451816687c76acf196b9d8f154	3799
395	ebf1a97f2eff08549253f722486f1e1b692cccc4e22b21572bc7039f28fc7f82	3815
396	33a665b5af86fa2a85ff735c7bc1716eb51107c1cf85831446e2ebbe278161ff	3823
397	acb8a8252430886a38c1afd913fa05537fa976dc8425d7dee870b094546f0abf	3833
398	cd88eb6ab259c8be04427a762da8099f0ba27436db3d1f43ee99afba970c05d2	3837
399	2a46e278cc97bc13ac384401d1f3384edb5d3b6386fbf0d395e778a244ff975c	3846
400	cc532c0c4074cac16ecff5e82c3b8fe6404070662c09eb794a40c09017fbb9a4	3853
401	9ab879554587fac4cb7eeaa532f2aa9a68ce3ae8b335932d36dfb2855e1dbb4d	3858
402	fd347d4677ac685335d5896ec9bf7e5afcefaf8ceed2b17b7b256fe441c355a0	3865
403	7e3976a3254913b6a94e2140e49f81f5905b96f28eda9f0c65d38c015aeaebe1	3867
404	9c0470d3ed3e6b23a776f3b5605a601a4bc661b51f37ccf84a16cf269ade3ef5	3869
405	9aba2b003ded402f565b49e9af01fcb561e3c634ab6ffe5db52a543b7a1cc7b7	3883
406	d7400218531716e936bba4aec45b0558818817e48f75e40bc41fd7079fc36d07	3912
407	eb324889a6d228e73f4b8b65faab8247fb24b390513ffd40499277a044bf1c65	3921
408	a8fe5184e76c41306f85e24e8d40f751d76ac49ea3fd7c58bae1305816305c8d	3945
409	bbc8d07562881f46dc0795f672dc4417bf36c760defa2b3e95f386a520717635	3960
410	94728a2cae4805548aa01b11ed64fd2688cb7711005ac919e3937e55b8209fc4	3963
411	e07e9dc83f84b8a744b2ed939437447602c37528414f492ea993ba5b3898e32b	3971
412	bb6be4bab8169f8b981c0d6726d225ff21d4ce9557ee297df638d0fbecdd5928	3977
413	886a53006e2222d6170bd3ba0f594b49b90fbeef0edf70af7570ee2a8faa3339	3979
414	f25202e1b8ee2f2035d1e20c0e84a44662240933eeabc6ac3dc1a6ccff7b24d3	3988
415	a0b11447a9a992ed79d7e18df9ec98073c224d02f76a5efed3336975e1e50054	3989
416	3afdf41cbbb61b73474540234931ad70558ff87b01aa28b79f2a5962cc992b90	3996
417	57b82932a569b36906e09e9fa7af4ef12825ebbf58aabab0fafc7955649a58a2	4007
418	9fce3e9317b9469f1f44f42189d1455f61f7d551dd5eee7cd43951814cbfdded	4010
419	e252b85dd0d11a436f2467b62c711fd1e4605009e36ec9dab599e14c87bc0919	4021
420	898e9105775bf134027d755d0bf468f4eb861dcc4603fe7b3114ba5e32aa386f	4033
421	98fb709c04643fb7151a23fb3d0cf7dbdfd7c55da8192b30dd2dc43a9ef8fb3a	4042
422	1ecd987cb14341b5247c936e03bd9093ffd0fbc4a0f9b37e4a47b2e78d6e77e4	4063
423	262cf6fc6c3a5a231962f56e1dc8c51fed5f7e2be88e67aa74add43bf584772b	4070
424	3ea000cb990c05a207fb7ddcd4560f544ec0385a3b5107cd64d219baf1feced5	4078
425	1afd6ecaf4504f1b5d714c6b7b71f2b2501f18e2ad853d6705f3d5a889ca05af	4105
426	2185c46231e055023ab1add23d050d6ae17b7c65a742a3dbee9846e61567b2af	4113
427	86ba20d044ce403f38d94d2f36df2f9cb5b3c919ac3162b1eb8301fb00f16ff6	4124
428	1b930aaefd75a40a5fde869303024076cf51e9825461aa519b669c189856a172	4134
429	3e99822944f361de91c6d7ec141e485fd4006b66f297c2a142bd317769c36877	4153
430	27566e5c2fb157487f5891cbfd35839a8c0041ea8a96c01fc9c2e16bb844f0a8	4154
431	abdcbf42dfa68be5fd59cb99a5d1a6eeaac2e62440756c71fa36a0a37f8b8926	4156
432	a490ee3f823f61a52c929b9f748dc86ee0953ce984c370733b47378b8aaabcac	4165
433	e670419966562d04bcb530dfc2e98c62be4da3bc5b580d0e2fafa71e8fd2390c	4170
434	8cdd4bab8eef8364b7617bbbb7f40fa3e9580b1dda12fa28f4ef2e618dff93e2	4172
435	20e544c0974573abaed1e99c08d0b2500c1da841ed17036fb35e74438c6e1cb6	4173
436	85b320a42f3483bc3176b131e88ba9c62149ddb4ba684d426f7d58e920bed9a8	4184
437	ce24cd3343e54464371d08ee959f7e7d13fc0ba50b94266576eabe8e2e7dbf54	4187
438	a04310a35fea23c685d5f1e42d30533b3f84b4ef297d80c052553aae2aafb908	4193
439	d0c198dd2458f26ce9d452dc4e70e4f8a0c124914e3f8c97f6e79a4dba907812	4208
440	8673ed6eb67e747eddea4209330b30bfaa52a9a0faa96a82e7688703fbaca811	4209
441	7019c1c0088003219fb6441fe5605f50f715e60ade1c26307c68b897df0f242f	4213
442	4828ec88d43e2d86a19acbeb3d8df2e97a2e27f673e3eda243d8496302ee0eca	4233
443	1052413ce0b977eae956ace4fdfb2342b773a13087bb504bd7331638da629ff7	4253
444	ce8a3a1c38a597c4493d9355a477e8adab1f44d7046ddf2c72f0b5442f95feb7	4258
445	8b96a56c062639056a5b0fbc9e3a99b075dceef94ea6c37a6e33e2e5a4c0d3ec	4303
446	d6522d6e0f986aa4677a275cc4b2d16c030d67cd51bb9999b53776fb7ecb9af4	4313
447	c94ab7c8ca726d681f54d30ba21069dc0f9efb376cd6652930b64d6a44a09e0c	4321
448	1a86b46961b76148f804dcdee646218eb4997ab677d157ae7f59dfb357f2f713	4337
449	a16403ad835855444096e93b42b6368dee0e62076b38ad724737fcccf47fa1dc	4344
450	754b0a74f19763b45b6f23c34381f3ac649a58b4e955ed69c36846a4c7e2cd98	4354
451	60043508db8a8f49151cc69877355c75ee9c73b5f95fc3cc74b26e76080357e3	4365
452	33947c0d932e8ddbf498ef2ef5f1d321c3ff5fa32fdb7040a8c9cb46244ec335	4367
453	507536600c0b1e7f7598cd39e2e9a09165a49cb484a261315c00e6fc5cfa6c12	4369
454	4a4cabb8338ee0f57646e3d1b1f2bff3e6d9e37bba4bb641b5c756f81b37c202	4371
455	351bf9050f3fb51a5dcaa6ad8a95589f8f7a80d937d162007ace9fbbcb420425	4390
456	0d9492e3d97691bfe1d3b5df4b89341e02d3468c68f1fd864f4f3b4d14bd4b60	4395
457	49b196e616cd10f3ec271562f6b21bc3c2d4192aa63e03aa868c355ebcb8b6a2	4407
458	241b3f7b15892693218c7d5d2ff2ac30834da721d2175093c24c78d70b3726b6	4411
459	7562caddf4a6a87638c6b4459583201e775132543ed98a4ecf792d0d9737d05d	4418
460	924bb843c90a58d67e5900401a741b11a435bebcb7b60fc2934cf64e796de727	4429
461	819b92883a10c5acf9dc7e7d2ff68e58d4a6b75a4473c405475ec505c98e1575	4443
462	07300ab368f3fa934481bd413504b5ca33842638fe3058b96f4373f2bae2e319	4445
463	352fb727e95dd3bca7c783ca6832d0f35ec536687dc2cdde1543da79e31f5d9b	4455
464	5714d467575d06c0f61401190b38e68db9c71f010c0e7f77570e93207938e542	4460
465	3d27001acd3259767c395d97937030bee3b70205fc2565edfab08aff29cad0b4	4478
466	233a6e867d9a5d0750e17f7c8ba1923d9116c8cd7630f46300f700ecab4fbe63	4485
467	d193a86aa947045c2850d555485646a03b2f233aaa4c04903b63b9bb00dcd4fd	4509
468	16009aa31c757391e67c95a65ef7ba45bccd0d5d6d55c4e6f70dd26b47025074	4510
469	158d73b121590fbbe70c5007e279018cfb3362eb9979881432bb197c05b2a7c3	4513
470	cdb8f4b56cb40ddd8cbc7701a83525205dfe87d151ec0c4bf0467ecdd6756891	4532
471	986728209c0d3b08c812dd5922015f2f11ef2f4664900604d2d59cefb4787872	4545
472	58965fe4426485fb22c56c6b26b01838f355920bcec242dafb05e882e3485665	4560
473	2ad9c94955e44ba206ce27ed3653cb011687d64fd51815631ebf30c139ca560d	4564
474	50c46626b0c24565f4f65eb9f04b7697ff5fc02944dd613740ae2f5a36c967cd	4576
475	0d4353c197fdd627f1675b5786e49608587c52169eb195d0829744ec6f641824	4591
476	679a31ffe1dfb9df3e9e57c52b0465e90d3633fd023e0e52be18ccee29f7f2e5	4604
477	369254bd147041b24bf5b0016f0c6355cd1dc0296d9b88671f3520204062e15b	4607
478	691b2a7a5e6590ac26c30f049f343ba5731482b71af77dae773e30a636bfbaff	4629
479	7ad40c85b71fb8e6549dfebe39af4818b3f5502fce4a44e6857cd8f3ddcb29b1	4643
480	ca4ef5ed6caa45b615a2adfece57121949bb286cf091d76405e1f6c0388ad042	4667
481	b37ba54fea30029c5b81e3ba5b63314d0a6b523cb437e500b452cc5eff34dfe2	4682
482	2d43af709c7f415768850314e081ff09204e9926a94c6e514d52d632ce29e8e0	4703
483	fe8a7019edfc529920d98071e4fd8634599604c6fcef02e622b2821530972033	4718
484	425e2c09c7bae9d1cd9f46470e9b75075149621fd68de86bac17267e8f782fcf	4724
485	48e94414548921bea452e3e3667ff49a5f936f20910c23e5f0ce5fbc23542e08	4752
486	f8d277c33ce9ef8bd7564c7c5baae812ee7538c68c9e96c5b4fd12ec7ad5bf6b	4763
487	46ae9c41fa4b753d21d8a3a87cc43c4ba1bf184782401c65e13f4d91b7cef028	4772
488	6b19cc9c407d42967ef8ae5012832dc6882cd361e43939099333f62bddd6906a	4794
489	3760bdd0b7a5c74d29786ca3c0178c0857bcf608bd622d7a0c35c11623dc801d	4801
490	601c848931f6b9057e494279d22bf78a936521cb1e896873d625c3fdc3d11df8	4818
491	def9a5aa116edfee10ae548321a5526ae79a866162f1f491151895b0d45f5f41	4821
492	5ecb67b58b5cf782a0c49c19fa644848e8770caa0648395fb1ded3eb6aeb5d79	4832
493	5c11ca0ef5230b06c823193ad6d2bfb546c5a611edd9bc62a5e4ffd0bda5268b	4833
494	b59ae6c3ec8123ef425e4d75fec50422113c407525759f1611cc81e73a28381b	4841
495	2d13d95fabdca43b3c228aa01fcfe33ef24df4dbe80438fc4fe2955b36541e48	4842
496	791901dc41cef10cd3ae4ee3033e0df4aa8bccf3a5d9a5cf733bf6d0c28d9bdc	4856
497	f738d32ad30e1cea7dd8575f6e152c39ae7def80b91a3dd74e89aecf2b74e028	4857
498	f42d7ef7e54537b069942b8f897212c8c0bc4e3d7ff5d870b9406f863d722df9	4859
499	25f0755a409b17b6912c7d9a4cb6522d8d385b3ed43c01c75ca5767e65fcbe7c	4872
500	3051caa75e0de89c0160754527310defd86167025ef165ae3ef7f08caf85abb6	4899
501	06ab5c5e10b03451bfae2a4d0b63b73d104a999340ebacd5b3c0eb331c0b6b5b	4903
502	8eae29dc8d4fb03632b279f5d4fd28d16d160f3471d7fb8f3c8c4a18ad2fbabd	4913
503	3d9b01bb7831cc3e2948cbba3acee6241b3385c43147d1a161e86c7f42fdc52b	4925
504	febb66100770a5001932e8b211e7603dc813cefce39075ccee4042621846b341	4935
505	d5d22d99c765667eaec3549c178d86c605ee844f406742390528f82e51bc5777	4936
506	983b9fbd1f1376b10deb9217e8a04d4031f7d66872a7a2c66cafc223edebe43b	4940
507	dadc26df21e88c464bf679a0f4ff8c5bd9ff49178e7abef851e932a5e1cc4935	4941
508	165776ebbc1fb7ab8b78d006a7c8ddf92387aa23285aa2a3bd5df0c6170836bb	4948
509	01db7da156e44568bb994d8ea15e9cf581f51e391d91badbc2b727db3857007a	4951
510	776540fb2588f3f331401190011cbeebed8dbbc9eefe58774edf764cd4372b73	4952
511	f9a973da38d0fd3b2dccdcb0da2eed2d33547316b110cdd5958f81f59f13633f	4957
512	fc8b0c501401e201bdbc905a6a2c17a14a1a35c30ce9610d5527790669b1d533	4961
513	798667b49eb709354268cee7c2f24df187ba8300ded6df76fc54eb17197ed395	4963
514	40b2436dc533c21149ffd221686bf0df289f3c634beb829d16c40e580f8fc42d	4964
515	a687ca69dcdede3054f28115634833ef5fbfcd0a697d261e5731782095a0ea4d	4978
516	601249c71343c3c8e0a90e0766f577147b90eed7b25811a3f72e805591e3c779	4999
517	b2022b2581acf13483fa2eab39a5d85023e834f76a27c8318978436d712965ab	5003
518	7b4a1d72fbf0c04932ec8253119e1b7a1eaef2d0b2121bb37785c4e2cf78c927	5009
519	201d4cbe300c4b9b574d44e5bfa3dacb05eaad1c6a25a1113dccca8068feedea	5010
520	e064a065d8283b6ac3a1ef65ea95f43e9d3fe030598b575bf045ebae7cd34acd	5012
521	9dab8bea5e4f76afe804aeee8f99019fcb6f3150ae24d4347d0395746c7a141c	5018
522	2a74bf798aef7ccd7a1509d12ebadc50b672ea1634f2f6d918b3d6f3c58b2e2b	5023
523	7acb12f5e4dc26c40bb860d3395a2ad9733fa45ce8fb6ddb64fc3034e5aecbbe	5085
524	20091ad9486da8e85d76e35e198ca54a023e2eb3525f6373f5711e28f092c474	5086
525	9cf1d42a601cb6d6f0513b010cb13c2fada1d7b5fd63d234b410a485c7be47e2	5114
526	071dc36eb54cddb134486ef85bfac58a94831fb6483de926f4c57eb361c5e582	5130
527	f4763142f7b99b9e08e1816187bcbe77b808ec50206d65ba2e080f7f29856b52	5144
528	c1a964b9fffedbb0e8e54d2fbbb9a2a0483fbfc46d14dca1f623aa5055a8714d	5164
529	b3050ffe43879d3386568f284a2af18eeba8c8448f48ebf9fefb55cbbce4951a	5176
530	d84f00d655d855473c107d206804630db616b50d1757e98341c5cb4803bba4a3	5190
531	f4088f0464d0eea20dce0e819e9cc7d57ccf25f94217c94f72cb68b73b23e2ff	5202
532	36ce2eeeb15148ceb3a228f734672f2a2b1b37eaf39115a59199b28caedda41d	5215
533	e8c257021bc0d5ca4ad47f676d7c515429e29e2ecdff62e02f99af578fde003e	5239
534	9a394b2f777894346329eba893536521c44e8ce9f86c407ffa6f8ecf294906c7	5261
535	d7afeddd5b26ba461ab24600e256a5c57a31feea826463844964f2fe12f09b2b	5280
536	86a437b588c33281725b483bf0ad2627721fad6e016845cda833d37b1f631bde	5286
537	dbf23a14b55611d2ef53d8eab3b28b47a767e2bcc2e820f4c2d83c20a5201afd	5287
538	7210af7373eb4cef9a42a6351aacd532214faea93f6ed4655bc985efc68ea40c	5291
539	9ceb9fc13d7e96e5e28a9044f3704ae4bfa7d80eded75fdcc3efab91a5afa7e6	5304
540	180a134df63740497da7845620b22f505aacc4b2813e71afe5960650a66b521c	5305
541	b2e85e83a7927be226dd7e08b6865e7568de41fbdbb317a3c1e72ec74b9ea6d6	5319
542	d41a17a5986c908a6d358c40772018c7c1d182809c36eb8c0ca78fe4d4a37742	5330
543	c6ad7b59e1b8ae7d5560dd9ea38358ee4a659a20d62a8e6943c9ba6eb5e51680	5333
544	6bfada428d0335936828b3a7c0999427b73138a4c3581b0dcd738ec01e482ce5	5335
545	acb35d6ebdef3367e88d5450e8dbf4722b26df652c9ee6ab891d1a895fc66302	5341
546	b76da0d122311d5604137b9134639a920dd06ed418abc06556a0f2e6d2146814	5363
547	37c49e8cf46dcf2257800ef89c97d42bc15b3c1307e42b65144a17656371571b	5380
548	3d21a820156d231accfda094a37e4ce6dabd3be20f56aecb73ba59a99841c56a	5399
549	37ac4d8c235316e4994360906e46fc41da6a494c5e27697fa47e14643ecb7698	5425
550	c2fe6dbeb2b8f2d9e875f9ff26294f1a067b0580ece65bc89b40a5273befb36b	5431
551	0e4f05d14a29681d6945eb0ab9f1a906c22496c2a54806a185e89d0a2887341d	5444
552	d9ab618f87074b61466b1f6e1826cb2b8fad222f31999dc469fe9e54c420e2b2	5450
553	d6183c40af0d03b7295853721ec4b6db71d329bcdb1d619d43fadfad77789f19	5461
554	3c9e93d04ef2c51e12f97865bcfc67d420945eeac06db8947146a51af511b8d8	5464
555	1f510a34eedc11d7232813b36739fd50801e8ac179f396f6800145dee56621b3	5471
556	9e7b9dd2234f493e45cd18f221056585b55996c376907464b4aefa829ed97da9	5474
557	541b7992fc6311a9e8c3cb8f7ad70a19e13a233382788523750871b0efa6eaed	5495
558	810102820af230c31afa6ef3a64e6a77820120b97bafef87bd6533c59c36eb58	5502
559	dfc3b28ee011e2fb617d59e916a1d0d3b880ac8be26c729c416ec8fd8ba2c748	5510
560	bea216779e9ed88d536f31512addc196e99ca2789aef9c4d7e032d82168aea08	5512
561	29b65e360de050308970715c289da6e8fed7926d66d373ca49888941c7782783	5514
562	90b6a7d7bf30c1071264880d210dc1548cdb941a700373420821a09de8410d71	5548
563	bd5e95ad71f74a35b6a68a7e9dce7aae39b1072fe8118bc447ee332c34c02bbb	5558
564	90e633159e7c04a17fe90e679db80f2e96330e6d0ea73d64d11547708a7db9b4	5572
565	5921be07a2496a16401d09b477a621f6dde77e4c3cf9ba141d37e38250835566	5627
566	0dbefe69e379ecae282af4208ff6c4437cca3c08e895c1e29c606b6966eea1bd	5650
567	043ec977e557c015eba986f15c4691870a1a5e5e6086e4d26539fd1428fb3f4f	5651
568	223570e9df0112adfff5acca19d79c2aa0ddcf72360346dff3b9cd71c0ae757a	5653
569	f317c71c3a3a55137aab75e5517fdcbc76a4b2b191ba1f157d103e1e67541c96	5655
570	fac88442e78391de265dffa6345e9189f3526fbc76ed2f801c1ae5203e6c1800	5671
571	d8cd1a17ecaff29920cdb2c341b31f41a7a4a1777eac15b060baf3bd36c114b8	5673
572	afa5322139a3bf2d2d3e04392fedc47e40b9c308e15abb4823ed2fae6db8b520	5687
573	00411fe612a931aab4ff44c545b015c3feb68e757bda5a020dac9dc536582b6b	5689
574	95fa48596806dccd9c2e56678f0fa0a00879b360e85a7044f09086564ed20e01	5696
575	ed528660e3f179862b1fb860c669073062eda2f9f1a9ef7adc6355d1268eebdd	5702
576	9a6675b4acae6bcc1ec2bf98b20f5e55dcdc2d47361b3f64cf7e3b2123a60430	5706
577	6d9bfb4eaaa14253c136e891152d559d38db6ce3120c5ce859590adb1a9abc6c	5738
578	afe5e7b6a3765c57c6909246d900b33c9009a61ba5c52087cea858a2678239c0	5741
579	4f0137488f75866ba51bce2891e7e757b0d8f264e8a3239b03688c34714b0a72	5745
580	64f6218d65af6776c457d517353dfabc0a666d155779c01afa17a42066ac8fc4	5753
581	5f5d36c7fb80150768c2cebd7242a6f54bc197cdd5d20062cf5be2f105c46e5a	5759
582	59838c41d519fcba04631decc84097b7042ee533800dd5ddde7af24fab72cc57	5774
583	98ed92daaf2c172409f351b6d1024cca35a24794b9e9ab77cccfebad96752cd6	5776
584	2cbe109ee3676f5576f902145507567495a894133d05c2c292c4f2208fa91826	5780
585	b4f17f1f2f41e8add9017d235a1f52aec39ca6ab0f29c99ff2c85d88ea356ad9	5786
586	9f9a0bb462e533c83b45edd912fb9d53a9f32fe4b609bc642314090421955601	5790
587	88dfc3320d95c9c613e8d4de5de0fe31811de2801482f9724d9afdd8f902b740	5793
588	f5e788c823bf1ade8d2d6bb200df1f824bfe55f451007f2fec7963865156178d	5815
589	f96165b75520d5c7661d201eefde87e8915dc781baadf5651a2896901f5b6bf9	5824
590	968637b4baba07e608278d21ae6e52544f218733e76016248ae4ae62d8842fda	5827
591	2ac680ea75b7c94612f1b0bbabecfa775f31254e74d087e1c8e4130a2dd03ec5	5836
592	74cda4234be1399e9d722e867a95145cc8507b628df07a8d015592cf278925a2	5850
593	5202f1ea663b1266bd5364e279fecb946a8ef5e51201c9ac48588a78dabbe6d6	5861
594	198ed51d4520730f417bd1ddfc34828bce76a6bd444a2ff5dcd92d56ca0e6990	5863
595	d222a80f7d796b1d3edd61bfd62bb898cb2c17920dfc9f9ed47830cbce5d4346	5865
596	bf375df81c3227f04a2f03ff56eda439c4a20d89881522d2c465a78cbf8cbdf0	5894
597	258efafd0e4438f6fef4f5d6164298cd9804a8aa9cdf60a38ac07e17ed521972	5898
598	2fa0ff58478c3bd6346a5e70fedcacd3e5becb03d8d20fe5003514132e8b14ae	5901
599	c06c1776835b02dfc4b4f1cf9264f75549713996da91229dfb1475d0676d8856	5912
600	ce88fc884144e05a0cfac723959e7f23f77eb6ec9677f236ae376dae394a17f8	5940
601	3c9a0967426c7cb1a1835823c71631ed07ad8d905b70270c305cfc83fd97daff	5990
602	7d39fde7e5a7a85f541bd4909af01307b680cbe8e089dbcbc5dec07f240234ee	5992
603	2afb4f60dacdbed710185aaee485fd02404009c60cc6d8ae2fe2b66af865124c	5998
604	34da8ce29a2ee9afc15b35460da21d0b39b05581f786028a588668c6b2efc0d7	6006
605	9c179a3babae1cb894ee875258018b81b466219428f7a806d06bbe75576f565a	6016
606	bcd90473c13d3991798f3d35ff8ef12de8d8d6e3977fffdcaeb5bdc5c02cc45b	6032
607	140113ccf1d937b7f2f0adaa7190cde8e0a4ac6f18ff5802d53597496924c705	6040
608	de4189929258dc14df52c400cdae14c43de2d591cc8787b3266bf0ede62e4923	6041
609	d6b4dad8a28ee69f52601d532e7ae9ba29bb2568104d15cde39b88c81a5c1ce7	6043
610	29f25eb8177f5cfaf13419e427abb69860a934cea21cf5f31096e56998741f66	6060
611	8234721026076a44a9ed668fbdd27e40ffe1994209936ef4e64cb6a6f244e49f	6062
612	4c409dae42642c3fccd7c5b0d34c7de1bc341214b509b38bca57192230a2a092	6073
613	659546df393f97b9b5f3130e70df22aa053c201eee978b009048eb8553618908	6074
614	b6a6e2811cd38e48c7e54b892e006a69171157ae6fce6b2c82b1446f0246030f	6082
615	735707693e1b0277431fdcb5abc3a99ee32b2b1476d28878b8856eacaebf40e6	6086
616	6dff7f614255e1db6da34c01f61c66bc4d4d18fb9b3c0602f5dba73d4a8e4927	6090
617	1ca290f72a05374f35cbfbb591f60614c1239db9ef5e427ac2151bf3f29f3308	6095
618	5c45afa287ceebbc8c2ef2675c03c7deba47679189a4415e3ba1eb2d95062c2f	6118
619	7b2145aed3340d26c79fba73b0359af62c979809b66a1897ec3dc627dbb37ff9	6121
620	9e8d76c49bc7098e4e7c6dfdce7881a01017c8af7c37a5d6c02a960741cb4054	6146
621	b5f4a7ebfe4c8dff6dd4bf9bfccce0e602c29fd064dbd9603887551459d42570	6150
622	aea04c440b63367ea785bce2264442039e9dd7ce993d3f119cca731c024a87e0	6183
623	ec4ee3332333197009fd303fafd61681753b1126a8af79e3193790aec293889c	6194
624	ce280137610ca254c6ba267a471dc0f434b633235281e26b6f5dc26c8571bac2	6199
625	dbf7f932a8b3eaf0b1e83ee6c5aa0166bd7e01c285a3e66fbd71afa60edc95c4	6200
626	54fac287cdc9d917a3dc2a319ad3c27ee149510b89a4c498c8043b9a22a3e461	6210
627	a01680992703f3ae12cfd5477c308d6fb7506c7ffcbdcde2b7ff9c1a7e799011	6226
628	ed25e452bada59c09ed67860953e1fdcb00f4e983eed9a0b805a53483b8092a8	6228
629	ad03faa329dbf42b3becb21cd76ebf295178775102efa1b1dfd66a734289b10a	6241
630	35ee807b90e8cac180f725a7d4cc7122c0b3235d45d71bc69fca6202920635d6	6246
631	0cda4960ecee7ad69a3445a77012a4937bd5caa6361023670c153e3bb9312a12	6254
632	c57c86f6918eac62b0981ce8889d36415972b00c3ccef65b7c05df08c9a33dc8	6260
633	ec187b83d1dad391fd38b18a2aa0f2e0cc382fcc3cf966be315a42843842f666	6264
634	edcb10f1155faa20df99789d05fbf1fb4bda9f6d434162ec80af9b583c51aee8	6269
635	cd7e15ad2a125b9ca03977fe8e445c62f19c8f9874973774be4eb64c05170df6	6292
636	8c227cf608228cfbd1551aa0688596e75aa9901478ba7fb196968f2365732aae	6298
637	b97eac0dab320714dff921baa6d9ad0fbf1347de6df12ca38c5e4e6fcc533bff	6303
638	08df04e8aa6cf3df4ca2b05d2d1c92c89a44224d99204997c4473ab76f87ae2a	6332
639	bcec9267414cd32c2ba94cb9c5aee2cff394ec20b0572c59d90403e1e655c439	6341
640	676034ab6a171833e7d653383c91a9e2a781a0df61daff6633096a96fa02e14e	6349
641	74fcb51f3b5e8708f9aaacd890aa6cfca5174ac0aed3dadf985475dc520f3f61	6353
642	6966ce2379f145a212a90c860210ae904c7bd16c741adae1cc6cbc355209ba7c	6367
643	388d9b9acf93078b26bc462411c5c69a25c0a872ca09623e6a002c6afce1bcc3	6391
644	4fd1da42b30a4c56e7975261e3e624c8fd16a6272bbefe19b6977eb5df4b7ed6	6418
645	ae454873781e54946dcb50b4c879b829d93f6d9939fa0b6e70b7f74dee5e9875	6421
646	fa61b7623b7616170767e8416f48e524ec0afdf06e879c0918964e516f54d5e7	6442
647	a6e5627c27b586c9d563d99e3bdf847315d72e0387dca91738c27159c075766b	6461
648	6e676106934f705af34f1deed3f7c35d9e1e69bd7dfd301caaa8154242345f40	6468
649	a674f74205455edc6136f37b0537015ab6309777fab010b0dc4aa9355adb94f8	6474
650	46d94460207405e7601c37ef609a5d919f8e3d205fd79fe583ded1c224a8d8aa	6486
651	564b0f77f74baa33820c8348d613b284481b8bcd46b59799fe008d4698dd4678	6514
652	228c1adb79c5ac2746b2944c32583f1668e84e7a8b265868d42578ba8d58b3b0	6520
653	69b27121eff974ef18292edab4d6f55916aa074ac8a6f1528e881309d5352f7d	6525
654	8139a8f46426fa378a8ebc2be70440422f8a51b80b91308136d8f6ca3e0f3e26	6531
655	b3e79070325389f620e59f31c3cbb4843445dec3b3ba614caceab36226a201a5	6565
656	7ed2ae597f3d390b41024fbeb2fab4137ede82de16fa781ddbe7a81c41ff16a0	6567
657	76a2bd467c184b18051340f024071ac0f840500702e33ce02878f922bcc9a02a	6568
658	6f2864ce344e61606b4a25fc1628b8230b854312ecb9ab94cbf82b0160184de1	6572
659	8f2448142b6b818c3bce1d189f25eca24fde16881f8778cfd3909fef2bb6c0ca	6578
660	62e836caa97406816979ee33c7db10e165141aedec0c31a1ee9a4753f57713ee	6581
661	e0e4abd924bc00dff1ad6a030f4e316aef46383735b45dc76d356aadbc4b219e	6586
662	c3167f811d4eb73ee8541d6996ed5369ad14d2191ac162d2f52ef14a6b0e1dd5	6597
663	9a3081bedadd84b364e11a126861dac0afd04f1b5a144498af95b19d18e24c34	6604
664	59a05bf243c63597dd72ec9c59ace74ab0c91b1c6e7ec309d21a9b61cc1ae532	6629
665	ef23e191111e0f4ca136daa4b03ed88d6837462bf46e20633dc8b3653453770b	6637
666	4c50a4482f27c2ec5c790bd0965cf53a682875e3c3a38e4b3c283d4b04893132	6645
667	a5a327721ea916738ecbf3db40617bec91cf62344b090c0377c120e866f98d20	6647
668	5e15efffe4f333aabc1d8894be03dacae33ce6ac2f34fb0fd0122c36e2c5353f	6654
669	07216b3852f8a7ea29d80b4e5e83ad9f8419c9933b9e1757dbe52c5e63cb0667	6662
670	9d23a8636f55fa402918e80edc3740ecbffac5c04aa3c6eacef17a44064dcfb0	6681
671	11dd58db8db7a30cb3ed52212fe55a4b7081adaea0dfb1135c978ef8907d5863	6690
672	37441cc64593ef07987b2f544f171c6fcaaa76b0b04e839b1741d2ccb25e27e4	6707
673	f12239489692b136f0738dc9226f152acf9409acd7c5f1133a2c488437a25697	6712
674	dcc3be3baf3dec28cba7f7d128c21b7992c1be9fe8d33d1dcfd5e662464f9759	6715
675	8fe0c770313f359ebf22292625dcd5749fef1fc99c6ce334ca35c63db55531cf	6717
676	1c7cfb98df65208ca610da3e0ffad4a9de8d593f726e9a8575f189889b962a1f	6727
677	979c9daf95bd4028e7ed90d2cfe1aaf1a3670fa369c11e9af48c29c7391a6875	6746
678	09c3531f0f50ecfd1fd292069d51e5da611fe3b6fd9ba50eb61b738dba6bbbe3	6752
679	da363712ee5e0bff37dafeb46835e2240c733df102df3218e53980a863448205	6763
680	2414e40143892df652f17b30d07a8c541949e7a3f26d729c2735418e654267e3	6764
681	f135a09eac0c92b3df54cbb77f1b83274ba5d84a3a58720b6c1fc315c1279bcc	6778
682	1e0e04afcc5eefeb77c14bc380c1aba9fee1688d0691ed6f5083a82f2a2df46a	6796
683	8fe647e054b61fb245ade095b73a629496fefdc07e4bb7de897835f5b4235a4b	6799
684	96673a6b2e974d819eabbe952891f1fef417fe03982bff4cd916967d7a086028	6812
685	c209ea495285c62e881aeb3fe7b0e95d36a7cdd77d88a173e67585e267d0388b	6828
686	f9c0fd161cb362cd2356e285ab090669661f38635ab91fd7112009152d17bc43	6831
687	d21ce0d037b8c132a36e124b9abf54f9190d4b22ce44c1d8f99d04eb5057ff62	6836
688	5e22af4b7384741cade925fc69440931fec0c5967ed1d050b33cf2c563132f42	6848
689	9f7dcc69c718d1f9bd36b795d09f67b4cbac30b3b3ea068fbc6ae8cee57f3abc	6849
690	12a350c77d04fa6d8d80f8c0a82df459713470eb2a5eedf834d10c958e585517	6855
691	d0352a9b309f8e1f56fcfe0b9d12b596a77ff6b320c9c72a16d299d0e4270b33	6859
692	dbec29be304f8750fe56c859310428205fd998706a9448ee231e59a2762b9707	6861
693	2b2321c5c9ff12957cf3ae722e382a15f7bc1f5edad5d70e5494c0d2aa42c9b8	6868
694	82fc44e246e7fdb626aa8491e4372e0a779931661fb2b1340d11632215789217	6885
695	59183d5dd5ab31af801535496eaa906d645fab533aecaa74884b04e8593fe1a1	6886
696	3980ffa9ae349d484f007954b39e62abfd96bff50fe691167272a75bea3390a6	6887
697	6bfcd7c3ad83a31b16730c5e99284bba1700b7793eb5fd588491fa8b6c443e99	6905
698	39cc9b54a3f26f0e21d6f768195b9df73824be89586256ec3535d2733bb35f3f	6925
699	1e913ffa1e7e494fe6961256fcaad6c508e944cb23fd733eddbc003f034a283f	6928
700	ba5dc84270829c6a127889c65aadaab734505380d649343c1290e8526253f5c4	6929
701	5f8271671be619b06a8a01939d8826f3bf869a5332235fa19ae4ccadcd3d291d	6935
702	f88a2f7c0ebffd27897e04848b886693f479a2076e51c4ef0cd761ffaf37ab78	6944
703	e62d8f70aa5ab91fe507e05c333d2724f603da0a9233ed41852276d1cf78a780	6950
704	c57d0688b6b533d486c4454e199e335b5c8af340294b46bef26ec4f37bb88695	6951
705	b22bc372e9aa39644351330d7506321c546f77ee220760f64ee22cff04b2074a	6954
706	d2077ac9a0f4da4ab7e0ef9917a0e781dd013706ceb7ca854258679001989a00	6968
707	d3f3a9b17c7ba4a31b682eb9249e5bca7f66fc65cdb11881305048bc31d3a5df	6977
708	6ce45b534fbf4a1d95dae0526e5b42eb790f50774bd3c418459af1bacf03aa60	7013
709	6ca1e9904d497cca606ca007384fca5bb7e24e705d8bceb61e877aa9d18c10a1	7031
710	e6522dd7106f43bcc328d8aee2b1a17a75398c6a19429cd787af44b27c736519	7054
711	e96a322588ef8215f25b14109936a4db023fa691d5052dd7364c56e345722d8c	7065
712	321268250514481bccf6e64fb51c42ebe9b605496978a5fa864d5d3ed8c6d6a6	7094
713	4b1e210ba6ad0b61878cf60cedbab0cdbb6084ec7a088e28d4375b8533978644	7104
714	b2bb8240dce887def32c146b3b397569a8011b71e22a2bd1e8ceb6b43e3d4cd2	7106
715	4f2c65848622b579c3a0970fa44b812c7e60233455cd6357c86256e3e6ee5914	7120
716	1d7ae47b6985454aed55af6505ceebb17b2b5fd9528673ec2d0cdaaf18699e6d	7122
717	c4b48113b52d85d3a0f26c742a5d58828a8701d1a6ca4c2c1d3f87ac09e873c2	7143
718	3844934e526007729e05aacfff96123e3fae56a3161fb3e665cebefdef4fd6d4	7149
719	872c18036711acf4a3aa3eb51d883823a9549edba169f54fbe695b9f9735ba3b	7157
720	9417665903a9fc1eb1307b95f9ac7a5835177c87296f42cbbcf897a796ef57c1	7182
721	4f0b997ea6243c24c3e7ab7616080fd82b711acdaae99dea5543a0f1c9dc9bc4	7183
722	dc40eb8bc7469911d9b0291ab0f3ca63f7c6e0fb6f084917f766f7bf9d8513d9	7189
723	7cf593f0daaff98a8c5b35db40fd05517724f8f2f6ce64014fbf274dfc0a375d	7205
724	213f4a7135eb4223f87e20e2514fd258fdfb7580b0e622a02b6c39d05cd34309	7210
725	cd3696f2a4e05e88071705f0b0f9124258cb7474f309133b86cbd42cc1fcdb56	7221
726	1ab3040fae2fa395e51d814d1c1aef318ac6284ac8df6d0ef660b39318f285ad	7226
727	dff9ca0491421e6b43d9e9852db456500fdbfd0b9570810b6e96803b8b4d6432	7234
728	4f393fa547c5dc1b33309ed49311241cc6ec9c41f9c6860560c3a71c496f50be	7242
729	a540c1b3bb01c78068b0842c8f1bf32507ed71c1e0e82341ec57a1f7570fe5f5	7258
730	add3d8d96c8e77419b22e7cf72723009eb4b0916dd4d47ad4663876134d6c3b3	7263
731	af3c616b7beb455a163cb04a7fcc7259ec369637203e0e9f5e753ac047b56566	7265
732	aa56e273b9e951ab66a4ae003524638fb73d44dcc4f2b58020355ef78871db3e	7276
733	f40c4c4bca70d237c6fc3940d1250c3aa46c43b448680392e7453559904c7eb6	7278
734	1a54662d4e0e41219bad0429a5e6c7bf4d4789c23511bf90e4d58e8639c057b2	7287
735	856ab39a4a3000285b3aa49bc9550afc2c287593eb23b3276dab930a6ec177de	7312
736	3843635d5eac5380b01af874ad9f3f0a51cdd8341303bb9f312fa2dad9fe5de9	7316
737	72d0c11a6286b49d6a04b45d95b21c8328461b2738dee141690dd715132729fe	7319
738	63e7adec28a4feff5133267b24236c291ce496b8c380c1ea43a939b4b3e44a32	7323
739	953f48ff1f98f1d257170680b5ceb09ee5fea467936248e33083c3ca9337d33d	7329
740	2d29763881d5b0a5cd4bf5b2ca7e56ceb5d76d0d8bc315c05f9399a1d31fb05f	7340
741	9abe03db685cfce86a13ae9d99ee57cf615a3aacf901c86adaaa731ff57367ed	7342
742	c5ed8d5b21840864871b8c466598b8641f37376f8e34f015f4829e139017c56a	7378
743	d27b200917e391c97b843276874dbdd5facc8e03955fc4fc508d2e461b56036f	7389
744	09873275d132b1f357b4f7761ca8c32f03e8378519b5d6fdab8a39b1f339acbc	7391
745	ce5c8d2e347629a08d72ce60bf90e70154465a8bf885d78cc908d2ceedb830c2	7394
746	8b278c3524dca24866242f373296ffd01be593758a800e100adf0a568a770dfe	7416
747	ed1e4fa98c0a93a42589d0db11d60369ea1d2da3781ed03d668fd4b991fcc350	7418
748	83badee05afe9e69907c52b471262762105bf543f9351c25ccd424cc68fa83ef	7425
749	ee893bec5cb9f4c0818f90188e841e8760133247adb2751ab837b660527038a2	7433
750	077abf7ccd94414f146bdae9ca66b94de512d943961553414f96209ec2e754ed	7438
751	8311cae112113a6a372cd41a91cc736466557d576ff2fa72889741ed268d45e4	7443
752	b9993178475f8119ed5dbc15a292d119eed5d9354a2099fa30169c11dbe71216	7487
753	ec5234b916f74d3de7dbabc634f3e99ee544e28024ffa41d2a190f59695652ac	7490
754	a4604ba77d59517249ff5c3a733642bd045e5a91f89566044eebe8f8c213083d	7521
755	5e2eb014e1596431c203d5fb794df5599f0e6e848cbfb2b6174387a46c5b448f	7522
756	c419764bfe789dd6ecf6d82571674330c62c90bb302c6ad5592bd2424b72f589	7533
757	87dff5f95628b968d5fa02219a0dbd99d9869404bd6ea79db152997bd09f02fe	7563
758	43abeb3aa3dcc4f5e0d0280692005ac823400ea24d54c305fc47926ff3717409	7567
759	967f6aa3b086f554a9bab576890718db648ba910efeffeda1279fbcbb0f5284a	7570
760	1fc28d70172815e0821eac71643a783f379627f022d95a8b7b09949f0d2a9f64	7574
761	ac640d41e2a77db31c1daf464382c11cb4a25d6c1f4154dfbcba55585e90410b	7580
762	9721409768013539148e8523e3f96b2851a0ff26d6df81def70f0934bd6e6881	7596
763	024f06d78dc585560d2b688633897daefe68aa3fc5b88206b622dcff33432fa0	7597
764	e05023fd50e7a2c960ebb604a4cf8cd9e0504831ce33b97b1b87c48e7b0905df	7607
765	809d682e13f1c6fb0496817b20afd1ed5351f90c2727c47275f91f14a49312e2	7609
766	5799283ff9d83c31a32c5727e569b93f7e88a103f37ce3a5671eb8323343591d	7617
767	02a359f67890b132585a4407191337be21275515bc36eb4d87e86788c7a2771d	7634
768	8c0c459688f810539a34bc9ee4fba6d17ece9d959fb833ff2f4055c50f48ac2b	7673
769	6a56abddcd8e5adfd414b8bb90c7aed167e9becd98811da8e7d9aad28b8ecf37	7677
770	d8842a284d8876c53f516b327b9ef7332b26365e3ad577c66277e07a0f4a99ea	7679
771	c993e19c575c016b2369ce076e37cbe46f734a0f58c350ba5f956f2a1f5c4ae1	7685
772	955fe62283db98270508353598ff2db7f55ac9d9c8a1348ec06a25a26802e622	7712
773	fd0e9e219aa1109aba9ab62090662d86bf3ae896f963e0f12428cdac5d4c39fe	7732
774	3e6cd263e40cd1014e597cd0d0e632cce8f1dbd5e62819977796c6860e1ea9dc	7781
775	febaeba128173f9a1d5e021e0d9fd5213d39a5902644cde416ea3ae9dd06e124	7782
776	a28d05394a9f97eb46026e8218cb6ba42206b0e9c399fe20132148ac4e078440	7786
777	775fd0b801a290cab7c4670a57b431790a94c8d38a3976321513d6cb988e7ff8	7797
778	aeb7b59bdc05831859b217b4f10bb4dc52db60bbf4f99a899f7b6da025dbf00c	7831
779	62764dd2cb6c99fb318a6b54f5723fa339e2888536b0d686c3dc1d98d57262c5	7839
780	68bd8310d0545641b838ec24975405ac9ba8938a4afaa192698c4a0484e695a1	7841
781	161b42078673ab5f2f4f7880928b0b3bcc4e36a9cb9dde0e216230b202284931	7842
782	e1fcafedde6584572d5dd6524e9f1112fdb1926d9285f036182b87927c71c45d	7848
783	ab85effea5d9f837889e7b6afb0007556d18364d19c5f504e6a17eaae4a7cbb5	7853
784	4d65e314685ad2caab58df2bc6e95238c3a470f20de8b189640d98d7950286de	7868
785	74f4637675e83b38999c99653184af68cc2dc5d2bbac7c170a8921217c3213f3	7872
786	dd9b3e0e96058b79ac21778c3a87e3fdb2245c78c02226daeccc975bfd202c43	7876
787	fed13764640c2ffeebd301ef4774fe9c2a36e2970fe494e2d907219526da0200	7900
788	b749838b5895e688d2ed8a70aba26d203ca37b619627b42d7ee01f78bec94bee	7902
789	1acb2a371aa54259b32a2ed05b6103a3b7827ec759476d342c8716b11a138b01	7910
790	3c9e3827cbcba534c23858a0eebb056ace39626d4bb3dccee3fc46ef5af42f50	7914
791	f487936bb20cf5a481e5ec5df4aebdfa68146f5923c3ed3c2c7c226cd6bbb385	7926
792	d15bb92c83ecfba90df3fcaef939130d8bbc5b3b608ba9cf106de0dca98e6034	7932
793	c662a3cd0925299ce9ba64f08ce2ecf3c3be0cdccc121bd068a6a443faed783b	7936
794	f93fc71515d28707b7b5fa75ff1f4a924c4a8794c3936be82298368615333649	7964
795	815bcd373fc29d300184337c019500fd035bc019c0278ba1e72da98adcc5d021	7977
796	d7bd7b11fcca216b7dd31f205051df22e8f877a136e3ed5a68180ad0b280e52b	7981
797	9529c905749884ae3c7dca8a9d725f06f03e13e8459785c8c009a6078af05242	7983
798	7511ef882e8ec73ed4e08581749b4a7ebd4c5fd44658a531c34703edf7792cce	7990
799	44fa87f7833e20c0ccdd998a6ff51b91694159fc10bf3e8bf22b27a13281f325	8010
800	22f9a5c21f1ce1a8d77615c8e6ef6672724cb047c703d81aae06788a469cfdc3	8029
801	9239e2e39deffc87251ed4a63c00adcc0667af45de08216b7ab6e79239c2a105	8030
802	a3921e031cfb9773d1617c1254e60dc9304c11815f89e5572019699aa327bdae	8038
803	8aabff4b114dad1c7dc13a81d10f6484b74b479dc7a01554200c67ef74107fdb	8047
804	7116a398e604e60475778ec11ac38d55de1a61574470053285a2dfa29f328900	8056
805	b1b746998776bd8c7a9ec28c45331b572cf5523d1ebd809663cea33d32ed1706	8063
806	19ec400e69d6b33e9852b0f81edd6eb06d51cc2d32a02f0b95efd28a45a915ab	8120
807	f0ce1fa55721c27dc80af5689ff42a3693eff878b638cde1079f4537b05ec18a	8136
808	3f69c31617ba5adb352537b9609521030d2d532065c278c24cef3b0e5f8df436	8183
809	20770e0ec6874d7897cb89c8f386afc7575feeec9a84b762aea7c93b3fea9df2	8192
810	bb9cc9a79924b2695bc2ac3714daa74b543201d8d5a6bb813e5676ab8fc1b486	8204
811	c88afd6fb46d6673d804ca043b88f006189e59822de3ab90697e12a6fea3538a	8217
812	24b98865522ffba0e0ed068d2270da34ab56d1e71154a781d49f91d15f1090db	8226
813	c4461bea80bc171f8074bafb6a01a60fbec5afb295e5a8ca2c1a83545c2f9c55	8240
814	c056ff777a4dad88e8effbe1ab222141d15bd9d3ff5f7de15ede64d528f0b430	8241
815	908736a418563933f506ae70f1c43f9b6373ee20909bbf59f8bccad3977c45fb	8257
816	71b1b4982aecd810e7a80cd92d81d1dd02f5c86bc5a7b5df0b41b12a97eeb938	8272
817	005909b353e3610b2b3fdabddf148d80ec25a4633912bb0d3feee8b16253e0e9	8274
818	77b185a7bfe6b8c9f6bd5b446879a8ee8aa79c75968d7a837d35984119f0b5cf	8281
819	b1129cc197760b470f0320ecbcda8623fceed2860a459f723b0d50020a10aa3b	8290
820	a687573413db64eeb9ffad62429b5afc20cec72cdd32d72adfcc2a1700e7be83	8301
821	5b323b2ff9d073a0e1c602ced8b16de236adf03a4cbd75c34ca7e485a5672baf	8337
822	5ea50e791c63c4f6fc9c3b168189f1f3e19331f13dab5af4964a7483c46405da	8346
823	6de04b001d7e8200f42dc30720cdbef76e63a8e0b76a0db7a2457bfefc883a94	8365
824	37df6644054dcbbf2eae83ac6c056ba8906b24090644ddab970829e4899dc12a	8370
825	8a333b2c8e375945d3d33059418387ae05e1fab92aecea76cdff3a87da7c4365	8374
826	d6fbbb32b896784d30024ded93d8e7409f261402a401fb1549c141d9625e5b14	8408
827	9b19b958edf5d3fba840a9cf273f8bd58a94c476eecb520b03acc29be19ca05e	8413
828	8b3f7ae44d5c368307037de4cead525b8d3a8f7e3af022c5af3fe78ce51c7939	8427
829	f18b50185b03b50b9be8aaf08730116e8467d88e83f06df771b0c7d993b4b0b8	8434
830	ef0847988b408389e0ca414b69fe6f9499d28df1e95473ca31884ab3f140f9d2	8441
831	4649cc042ddae92918ecd5c85f496ad28fdfbc5af84f37c3a1a8f5e5dc42dd06	8445
832	a766a3de31e7f60e0c04c440e596c47a82b24e52b95e520acc95ea1a06db57d9	8457
833	b5b1808a86c1ed2b3732e12e51536d15a7caece9105d4b2bdc62ff97358ec933	8463
834	18297bbdf06641c1cb180b9d141542b969c37e836eaacddcef54ed5fd4b50523	8470
835	e7c55c468cee6d695bddfcf23d47df8c1f2980b5ead34980b59b31861d6e2e0a	8484
836	0d6823cd90d39de65ca53948b5dd8d9ade7777cabe38d35403df9665e5c361aa	8492
837	2acf50856705443f798d7d5c9a2c12c4ea0f5c23581dc5d88c3eafa2e7c025e3	8502
838	970c148d12d10f8c6085682e653ff1a9bc337816cad565bbbe52d912610a9aea	8503
839	f91692e22e99e18bd93fd9a1713c55635b8c815b3037f91aa1bd433b58e7b0a9	8509
840	4fd29759a46e38365d9816831ba51c13437588e5b2033b1831896553614a0d17	8510
841	d3e8a6c346917a74229dab47472c6a760c2205858c5d58a8ca198f1ef50c8c74	8512
842	1267cf3be24f9c2bdadc24ac6a7a85e3a1f473d80299fefde60acd49de15fd4a	8523
843	a86cd3f6eda20a3ce289c9eede279730935c51d11c5746f37f861129e9196f50	8540
844	0b1a7f91541751889ffd710755765b9c4f1ed1b460f4802425efc876b1dd00bd	8542
845	6fdd0145a6cf9b8dd111d4f03af3f3ede04382387f281fe18a2b4950d3456a7d	8551
846	0e00858a3fa54a26122bf4298dd79e0ca97383f2aeb31a9f5fa1abc9fba2d903	8558
847	f60a4f5f25125bf29898754f89ab7685b54392a3f9c00794ea7344b27fbd07d9	8573
848	1553c9bcb06a264a6b520a81a2019fae145a8c04ca56afae794215d2a38a1b55	8581
849	faf1e796705da9a8fb67b9a5d9a9224d054977ba856be3210b89d2218389e8f5	8639
850	1a704b621d9c19218cbeea9fa22097f9585da0600b9223253859c9f0160eeb75	8645
851	bc0d82a2e1e54c6ffd0c477d2783f7eb3558b61eeef21f2de2648c1fc4411e87	8657
852	cdd17bb3f7af90a8e66b494d9a9fc6311d9a29e3b7733533949c32d78ae3e5e8	8670
853	1158457c7a06502ac1a460d8284648d1e4534ee84e261dea1665595ea74a9ad6	8676
854	be537c63cceb8c61e2855a3741fb26ba4a897e1ffca1b4efcdcb234ba5ed25a4	8690
855	d3f64bbd1a0f0d957c312f2679747d3bfbff3966653110ab93eb592cd40a80f5	8691
856	1f65776ec96f7104583d19d974da8f1a1cb5e65fb7893e362a2f63547fe4b582	8698
857	162171321c16cca8fb9999a8949537d47a8d960030f0d553d991bf10f0b63398	8719
858	3fb52cafefc1a7e29e669d55d0b3cad5cd58b3a26e2edb2ba9d9b25bf30ea63f	8720
859	9f13f73795869f72ee29f958eb8204629a96100ea5359ea06947580edf83f111	8732
860	dde82c13d8e9a3bd2134ca19171112969a1049fbf042914a3c76f7ee8750dc7a	8751
861	7af16e6c45641b1bca63309683fcf0b1b111c2ba8358abb479a46a9f8bb0c3c4	8756
862	c0083602f0a6985bb516175795035052d14a4b3c65bb05c1ea34a010f1ff43a8	8759
863	a738f428e6fbc72e0386ec49d239e2df2b38ef184d0d75dffd2f44bbf1c25b0d	8761
864	8f8d4f2de7b2e9c0bd8442491a7569816643131b89bb9a57bba8f82852950c1e	8764
865	a9f29fac43867a4110a878152b4a23398b8e5b62873ddc13ac35ce83170035c4	8768
866	484098c9472a84cb7dee8517605b652ab25ff567ac91cb1fcd863f715c6fde66	8823
867	8cf6251d96579da6943e52d400e78f1f27c0db0eed3bbcf3a0a489b65dad1037	8827
868	3460f4a6b807c87c0d8d12d59aa478853d6d0c06f52846f5ef5964722e0f8ca5	8840
869	96521143f3219aa4d127d26d788c8e73028145a232a27bfd015b5ab6e6facb37	8852
870	7071c0e22dd5784aa286a7dd5bcf4ff52cc4ee2c565e07cca15bdded32d08c32	8858
871	4e14e48f055873651506bfd94b0c8d76dfff9758a84170baa9b58bc0abf79a5b	8872
872	d6cdc31e6df0d6103cf0a21d67d013efe14ba73b8e59c6e218c7ce29d849e546	8879
873	815db655b9f354a6567992321db1262cf28a4e77bc58422d9e3548ae690abe02	8880
874	4c89a0132f22f0f652ab6ea3d2e9350fbff22677680d17f0eecc8546a164ca99	8882
875	d810ac7d2c8168a2c474b4dd7ba3714818263018f8ca9089d5a3e9bc79e8418e	8886
876	2b7b319ebbf0cd6c8d5e7b9684245e2d4557e0ded81ddc2bd4289dcd50988723	8888
877	fddfd19c2bebdd6de6fe5db8775c24fba171784ba63bb98de9a55b51c5b102f0	8890
878	f937bfa154139b0a9c499c38dc81c6fa626574485230ff04085f7540962c270e	8891
879	46009d6f6c8a296ef3bfebb916d1ef1efaa1f0afe3b361798052eb673e4267dd	8902
880	afc2df429058f44570d3b7205fcd8ea8e30d0ce6a911a1208eaeb6481312c745	8903
881	4efe65aaac56b8a69cdbf3bc290e88f2b37447268a03ac9a2b7525534b831abd	8904
882	14b2d21c294f58a87a923605bd80ef33c544988e344ab276d56c1e8e00da0ec5	8915
883	c9313455c9e09d1f26e75d98c08b74e9fd88fbd493c52636d2a22664170fa26d	8920
884	e1c28b09bc0b9d23278d1c4f9acb841c22d624e18033b80c863a645fa60acc38	8943
885	1eeb5d2fc59e953f18143cfe50ae60f7d2f99038b49802313f876ff2805e9320	8957
886	456b1f64dde17e415fe20d64cf26cf08b3ceec346b2559cd1a8634ee48580c62	8965
887	d5709ec99e3e1840a73fe790d5e9a435056455047a21235e96fe1d86abdca64d	8968
888	659827e74eb5d17451503f717e25d0531181760de1ab8039e69f79d478cde2b2	8969
889	a26ae9c3d95c6a538d93f33095e6d0e94f6bea2955f8af14c74c12e80549910a	8981
890	7bae1ac49ea18f2be2e5528b56cdde37aa5a7270955c838f1441f192034a13a1	8991
891	2949ad9bfe6cd442940f1adb195584e2b3eb8650fa413b1fb166f6d5171f1981	8999
892	959da75f011667820c5578c13cce75893f2fd8775988243d6898651a47df10db	9023
893	370720c8392adb66da418cfe688560505cdda31af7cd34128b8563fa99d048c4	9026
894	72523b2d8ba7e0afb90b2bc1ae2e23e6d9d3934512071463392b201bc3d20552	9031
895	3d50a8e40819562d35d3e50091b3c7c5ae9d2ea54f99a3337a42544ac97e4700	9036
896	121d4bcca872206e8d6339e38711a630adffd0f288041fd501e9944a150bc7df	9050
897	0a2875327b754ffd2dde6cb2e593d0229c265154a115c0b668ee281094f48458	9051
898	418db3a25a8f7a8dbd092eac6d756478d3be818a0c33456fe4b47eb19bd6fa46	9053
899	46ed96ca4eee5d33ebc6f097ac47b41dbf15333550cec64a2a37f0e3cf5c73a1	9065
900	e5acc55cfcd7a6dcf62ae7f35ad8a690b58020d1b51f56faef8f2633760f3ae6	9070
901	5f63b96940480e8c6666b5816f87559f3b153a98d45783572ef2a0fb404e2f6b	9089
902	c1c8a485d56acf7327a970d1dac3b4ab64739e4fcf21edab5151edab56534ec9	9111
903	b05520bee793efe19f7be994043ff59276e4d6e7d786740cf77d21c47d15654f	9113
904	44941100720aeffa92dbbfaeb97812c6ef1e9a7c0d535bc6b2d1ab478676e416	9116
905	6360e7fe141c391061c15272357fb642369a2b6917afdb5a404f85bf1a73413e	9122
906	3a7ef9c65c5bb587c1ceeafedabdb7b6490feb62c750c0278593a5bae83a846c	9142
907	1da1229cb7bd883d908c7692552b8e8f6d0d33ecefcb361c0c6571583e272e28	9144
908	653da5060faf6e38471e5163e5c5eab766f27a75c3ba474f7fa2fab632f7c1eb	9152
909	a9e43236641d510f78ac3e47fdaaf353841902e2de6d060eef01999d612d1a70	9157
910	dfc4fb59ec24ad2eb35f64600069c8a33ea3c5dfa24ce6718f304e5a11f1c953	9177
911	7bc4ae97571ed74add5cff1fb2513284f2334e5a1a2f883f05c5bb1ef54cfab3	9183
912	83b9511c56e0c4304d2d3701ef1165622ae110c50cec8de181782c8c03cd1f55	9184
913	f36eba37acd9ae9b45f4bd0d8fb18f55a1e2ee02c3ec3709571395f4b9e5fe56	9193
914	5af5bf88ea2d7372f8f4902f975f9ee93b307c026c47b8cf0d76b2d341fd0f2b	9204
915	a0e23f9a5c26e6a4c14f4f295211b98425ed81ccce9cd9f35a13b44015235646	9206
916	8039e56e425f86bfdcb0999337558c80c8ff01f3e321bcf20c41dc61c7db81bd	9212
917	70b5a7cf3f4dad97872ba55d4bbe8a98fffc80b6c2e8c6b8766374ea01a1ac21	9213
918	f28769814c58b356f2028979e269baaabce731d707bdb8761f9c7c20edcbee94	9245
919	8a9b89b22ce55393b1b2aa3457021c1bab2ee35d81d493b3c8f9a3b90633ff3f	9246
920	7c70214d6a3536d01e7fb3c9311ad2f05b19d4c7166aabccfdab53267ec5b107	9253
921	12cb9206662d30df1705ee7179f6d572cd6068271871fadde642aba059eb36ca	9260
922	16be640dff407f73b787c47f16b4119646caadab88c90c019a09696fa190510a	9272
923	f611fd3891448f3e8449c93437eec9c087c2e4b5a8cc80b97fddf502386f8216	9277
924	594d7174347ae24401e489c5e0dce032ede5458797eb78ed3ab59a0a4b38c7b0	9288
925	3356e8c6fd60900d6d56218ae4f6b746e22f7ec56f43c274e863429c7180fec3	9315
926	e8039c4f5cc9314285ef3a3d851decc480c39de771e53d733a1911e6e96a01e6	9322
927	c00b2bf32d6fa724d910f13aaccd14cc6b1031f992f5734cb950308c6c1fc1e5	9323
928	6f4c35eb8d84354025477a4797456c9c4008765ddd2e5293a40528f52598ee5c	9333
929	0ae6a108522cb331db9710a950f60c0204c8d7a432f27d1010b59fc3b8c9650f	9343
930	363cd6fe0834471b572d55d034554464d6b24482b26ff3b3a90f05caa72fce6f	9359
931	8814deba2458fbac42170cbeded123fb9e2024ae505bc21cd18fc5acbd3108f6	9374
932	1293c905e806a15b454075c87c502a6b1566e44f1327efe4af8bbbfe99424d89	9380
933	0caefe3104928559b37c11320b0d0b3c08a0566fe93dea7f184b499ef710a01f	9382
934	4f4e6435a431309048c57ef54a42ff54358a40974985bee662ed86c3f91a8fed	9384
935	de5b0b491ff8961d2f37d50e3979ba66ceebc76fe55f037f0ff2a7899787b18d	9388
936	1d19b10c26dc824a5d527cdb4b0dc5b5179ccbe0bba57852001c0e921e32dfa4	9395
937	7c042f4f7b34d337f0e3de03b6f21f119a9d1fb1aaa30fac58de47a408b1f5c1	9432
938	29be038f67ed33c4ef4d8a1899e5ab574aec0a4f1ec2602dfd525addaf820e65	9435
939	6b9c5be413f4c92caa91207b790e5f71e9eb7012841d10bd2d0c0e70e021083d	9461
940	d44cdfd2bdb86fb00aef56c2c28be99eb3efbe3729ae1c03d2c8f090e58aedef	9465
941	80868733ccca58f2e43cc19ab38e65102abe303bcff78897eb7da912b7ddb5c7	9476
942	9af15c69523092bd748b456554da91ebc199d181b2b4177093c296a8612dae53	9481
943	e4af4c327f9fa7d9cbfb6e521d7ac0a9766dfbf802183164ccd50098a2d43f6b	9496
944	dcf9aaf52160e5d6fc8dabfa66ad7a57363e8e853b293e782c98e26ec89c2bd0	9511
945	1709f67f10172b3a695ad9c7cd5d6be654174105d60fe3923efb1f332f4453c9	9533
946	a6872d171699d3d772ea04040ce59493939ca3212e1ea93c5368ae5ff1e728a1	9538
947	0a7a898d0aec735cb2c58f35ff1391e0b2169b3652073ab8966cfe5b7e285d18	9542
948	445f1af35282283d9fbb20c1a3694fb2420f06854a577a8eebfbbd3f22d3867d	9543
949	8a86085b13ed8e0c2b37a7dc5e81c513f32d59ec349113ef771da16d4704269e	9544
950	67d1a8fa8b9863e2ca48dcf9be07b7aa437e58c1444e05b810494ec99d76da1d	9548
951	cbf5df083f8894e8cad6a891d8adc7e5128ecc2cbbce96eaef9eaa1526a4d840	9568
952	379cfe9df15f0043f69be5be756afaf9692d486b393f3201ef62b0aedf142a5f	9570
953	3962bf8911f5c00845dc0f5b338664a7d317e4e1224d49a32699007ac9cbd8cc	9587
954	8d87a596dfa608a249c8685bee3942346f8741e4a0a991ff81c74f17e5ef39f0	9589
955	7d69dc8aaec6d0262710e74e586b804c03563eda0e2238a1c8ffc2baf4e53d60	9598
956	0a320b583c944383110447c8a568f3760ed128e0dd9d897ee8bfb06347d08e5e	9621
957	aa8e6c8a185436c263653518b8e65b52749c0cbfece6d927652e3907dc3f5597	9640
958	38daf07e02e81c88523c4795aa43f911eb836b27549682c3b4cc15fbc2d8a1e0	9649
959	c3a82b509fea74633fbc97932e52737d270992cfd6af22478f325c0fb0ad9763	9655
960	b20ccfa57e024cdc65d17fc275469e7e7e4c8c8902dd512727d73ba21d3be978	9664
961	0451a68864769070ba616c338f71d7c6564dd744e526e9051b0aea3339704027	9665
962	7a6db7c043098f39f71b6ec3d71eb053b2bb2a064d27ea617416ee3ee38517df	9672
963	80878ed39efc5502bc0a162529547bceb9d9b822a22d305c24895cfa3eaa5e28	9680
964	d6bc9074c0a70e846b68de58f552dc5805655f5f63b10c2453be2deb5b56c39f	9688
965	be49983a267ffc1f0b7baf67a4ae6539b881b4e5ae891d1024490e5d0b0566a9	9705
966	4c5907e23dab2178d4141d6c6de119a75a4b2da678eccc18b179665ed4dc39aa	9709
967	64460d0fef313cfc9eeafce461935b7d77f34d99b9a26be804999a0909a1e2b8	9742
968	f51775da38716efcb0ea512f21bd284b986fce26edeac0c6c85e10e7953816dc	9743
969	b8e1b9eaa0263f4e93ee0cb99a4ce05d256dc7c545bb0ae5fc52c6dab6944329	9754
970	266b61bae7901b972ecb0f90e76d2be19ee378e85458cd013a981e32a20929c6	9769
971	8d45a4d28f8184cdf39046cb084ff4d1f12436a43dd58cdef3a0ec184359aeed	9783
972	538db023156b6edf8358bf41a6487fd28ad4b26a266356875d4147addc8e0b7e	9792
973	41838c33d45e86b53a74bb129634294d944922258939c008861e17262760b4e2	9823
974	256f16db2ef339af8f29b6a07dfc1ff07346a1c382c8dbc888a25f46c5ec4ff1	9838
975	16887598116c4ca04d0d80658f6eb8619df0786fae3a8325765a9f2bfafa143a	9846
976	c6c06c4725b73df9d61a94ab402d9068866a6614b12331ac8060d3f74c57fdc8	9852
977	59208e35b4649f600d21e40c104e7ae21acd2d421ff128d04ba7f4c2555b53ff	9867
978	30ed27fdb5d540dd790cc40992dab7c9f9617d0cb601edd6374d5a9977e1bbc2	9900
979	575c62468e3a00fe68f6504d558137c9054f115504c7c80d421cf594a74d95ca	9916
980	40ae6c9cd92b7bd6fdd56d7cd38fe48e03385a4cfb80cdc857247521bbc5d1e6	9941
981	24c56b6a901dd064636fcd9a6268cb79c268574faf953f746eadcdccca20bf53	9947
982	bc870cc27f3734cface5ded23af436af25414ff16f41f57c5c79957e7cd3557e	9958
983	0186c3934d2419f7086d704ac0514bcd0f47298d7d6a59079a6b8d7348f9ce3a	9979
984	e522e6a9795146e7f9be177dc62de671d9dec974363265b6f4ce4ffd29cc54cf	9980
985	e8e91152fe6d30741bffad99ee78737d9cae53f0727efeb7cdf70f3e169bd97b	9994
986	b01cd2a49e2e3e0864ca865eb9cbb1dfdf8198d3a93f35739e82f75272be5821	10003
987	52e05094bacb43517ee59be7afc89a89e2435b7d6412ef16e5e2c5fdcea552b0	10006
988	a812a8bed0bc77acc6a8c77061b4e4ddb4bf3c1d5a0ff4ff6f163da0ec57ff76	10025
989	a38aaad78be455fb1db4558d948b9fd8acefffafe00452fa4169710cc44116ea	10026
990	b01c79ca23c9a4d6108ba64019b1ad66f8f7e4d0e521f071529d27ecf284ff95	10031
991	a376347ed2bcfd514799f227fe0549add783a6295e1d7667934c393fe2672132	10033
992	b403253f70bd13875124fba4fc4f3557c4e3cef46cb701944283781b2eeb9b74	10061
993	0f888e896e9ec6da8086953e81df58c1c7044b77d3de3dcf7829c8af6365ac60	10070
994	7efb5655da046b83107b2b66fe7dfc66378206dbfe7c5376ed33c7408f17fce3	10075
995	eea3783ed4119347fb540d623169aeaeefe60f46f2443519a6457453ee461eea	10076
996	552776305d09d1ba6e696c58696c8738cf758127677a5f978c0306d405589557	10081
997	2f2a3420ecb8f75f7c9b245175aa7132adf833f73ead192240b34a0b49d58202	10103
998	db264ef6a4ffda0e16e1e5511a9afac7635cf439fd464ac2acf839905023ba82	10116
999	176a9f766a14751e319b070492eb51e512c1b30700718935b503e4ae54de92b2	10125
1000	eb62d52a8f8a2a861bb5ca21fa2c68dd855208838a5117a772c4007ee3810bad	10127
1001	6b5be45ed22642c61a5e21a58d943992a760ab2fde2f0b18d25d5831133ca34d	10148
1002	077e35f8c45265b38ce8fc405f57275c6362df7e957a3077b8f7dc9543ba8d7f	10177
1003	7b089b92f57bd0af9bc976a558e9bd8e5150012eca7cec3191d703a55a6a76c4	10184
1004	15231200feed44dd74a00c818d07375fd965c0f5d705fadeb6b323eac3edf123	10186
1005	2f6c24a9fcd23c6086c59ced11a88802158adf8a39450048a9d9b93d8949b2d1	10189
1006	76a45297fb80d18a6216fafbaf4f71bb7050b05132920b536d18e8faff567abb	10209
1007	6eebac8821abfb22de3aa63fa882bd6b3d19336b426d2373660ecfddbbb9b490	10215
1008	da912eeb7621c23191beb01e50f81f063d83327cdf76994380ba411e600045c5	10217
1009	b02eb29754e7b3867103aed746d0c812d9f18c2146d0af6d062c582578904790	10223
1010	6b8a2621563faa97c1c6f2fffecb4522333dd4b53dd19ee4e0cbb8f1ff0233c8	10232
1011	0ce2ba8526446cc1b9cdb22cab579ff60a74c046d173624f54b3607643b4c245	10233
1012	3f9cc85cb42f49e14976baaaec6005a1af5b4e6a7d0d9ee52ea1b38a116b0591	10241
1013	c24e45c842bfe8b886ed3bf4063b33ad7d1ce1943fd8be5f20da90ae6de0a239	10266
1014	487c7d84bfb5bf0337aa885f62dbffce75cb8e5077d6c56a48f1a482716bb01c	10271
1015	23dab2e290b01b6b7b0c8b303bf29bf7c0fc25722ca7707373d5ad6b058ee6bb	10272
1016	a9b30206f5977df925749635fc3e7510f443c34ce563ee01eaba208ec453e2b8	10276
1017	344514e72c9fdd00cf0bfc9aa9aafc4b7c13cf498825650dba5675c72a89ac63	10285
1018	b7af501185d059012797a1b843b3348e56f51f7d73658ac42ef33dee1229535a	10317
1019	2a359095e4b8a238c704a75be01b72a80a962f7eb2fdc4869391962881b485ee	10330
1020	7cc7f02fea9385c67b2e5950de6a3b5e19bcaa90ba7b6ad22169fd39b7246e34	10331
1021	1fd38dfe2aa678df432f039e1efcd36ce657386ad745eae8839ec419c40fac87	10351
1022	93607a2fb238612437d4a1b6714edb066729747ef3444fe89514b18ebe82ad08	10364
1023	d1d157d17610fa9066cf98bf5c129b77cd9454e25bb7881dc5f4236761b950c4	10365
1024	073a74493e149ddc8872183e32016850738ca2f835c2d375b5c61e521a63600e	10377
1025	f8ed8969b6f5b0204edde1358c5a0a89b485e5fc76b455db4a517a5f3d16c01a	10383
1026	a4dee73938b8097fcffc10746cb0b24cf3f6cb32617804f36e727a47a81e8d83	10385
1027	3115603ef72fbaff865aaebb9f5e7091969003d65cdd4c70f091a99b9448db79	10388
1028	463c9e7e12f07572fca3f0a431e51cfafe7a9a198ff7d0a9d1a8667c0ae7bc9f	10401
1029	aee79b17b9ec512fa607559d06469310742f1c922799eee0aff9208bfb68d590	10402
1030	25629697d28d4be946403f7f28d4a143eada10ea7d9cf27e6ed42371206814df	10423
1031	0f44f1f265768351922361cc5ed587a21eab1a76a60f22d498e9515565a6e84e	10433
1032	2ab8278078541e1c13d60bd992e1d1d0d1eebd1b9f2e5c564821c6cd07f94779	10443
1033	e722e755195a6abed2077d5aea5a32e3958b393382f9dd58017533910265d5a3	10444
1034	01246d3ce8b304f2a5b1bcd9492e6b519435b4c72837ca108e06675425fb4540	10448
1035	7ce9fac6ceb195343066bb31a2656028143d773f9359a9c277953fb8550191a6	10454
1036	bef0a2a4f21ca375385b2930aef1c440eced81a203b2a03241b6fd44fc96fb20	10460
1037	b94de67e95213476db3570372b19d98612a5ab0fb0cf95a0f059cb2aae3cf00f	10464
1038	7c6bfcf7355dc7f1b2cea0faf38f9d1e7cc9b3940b2218883eb80a329f294a1b	10466
1039	69d79db55bd02807e380a4cf6efbad637b75e00cecf7283a45f196f87ee6c016	10484
1040	a212fb504d5cef60ce42ff94e074b582b56f2410ab194c6d5bfab5a44338e9fd	10495
1041	bfb8f6aa05087cbddab94fa22bc5d35d53623330fd5d4d46478288698e4ae7bd	10505
1042	4f786b9005f4433d3a8bbf351cfe7088192a7c41631b3756ad1c062bed8fe3d6	10525
1043	e6273f53413a74282082a94e2808dd9af81e1755abf2918ef787cd366afb17ea	10527
1044	7180c6aae8eee6f9a0a23359ddbea22497d088b6c8d10a0fd19b82b3b67190b9	10530
1045	4cb2fef477208335fd73d9a35a1924de9e64749c445e53bb44b3e76746e824df	10534
1046	1fc054aa757cdb8200dd481d329615ec6e6e2ce606d43ae17cdf5d7248d2727a	10540
1047	43108746321632cec720012220384ede3ed403d3d333efb6932503da988cc466	10566
1048	809dbae491e6ebb619f56a2141de44bf6a68aac56820b8d93eeb1df67b26692c	10574
1049	ea2f84952d2159e1ca53c410f2ede57cafd741cbcb8fe20727ca701014c35e7f	10579
1050	44f53adbe80cacef32304050a74bdb9c8e2b09d4e90810d492c43e263fe08b94	10619
1051	4a4f77bd30783d3bf4887664b03b400a9c0837fecb8d601df7e3bb96e1b52883	10621
1052	608d935f5e06d9e1bf6df97c438e8b099cfc06d863de1c2081c4d96f1e91cbae	10628
1053	34f29da0088329cdd1b287ef65ec7fce7b80bb2ffd0d74d31391773a183b6309	10634
1054	2e307e165b8a5b2538f06f08f09a323f8e74e806af802d824726dfa52c07e713	10635
1055	9481ab29b93c449eeaf9f58920202ea3d57de47dbf2e022479c5ff3d0d677017	10650
1056	004c1e5ad3a9a967c836308345985b213aa8e15748f22ab63a3d3e5ee05ea0cc	10652
1057	c59c5dd6d27b6531b1693cf1b28b77f265367d4a901c71c0842ba417be4a6d5b	10679
1058	24b801df34745ff5fe23afc78533c71359e7fff9f22c5cc7bff8895bfad398ee	10687
1059	5ff5eb9c73556b4244886e322c2e40306b0f15fbb9b81d4a0d7effb502cc9998	10731
1060	c18819dbf40b7121573b74090fd0440c67118e66098e92145604244de1963dd4	10741
1061	cffd94f36f6dd0a24e2082406423dc350ad1545c51e46afbe166f319ed64b427	10743
1062	5cf676058f272c8edea0b11020b177c8ac05abe32cf2f725253e6a5de1d1c8b9	10745
1063	45532b19d86788e1ce8d04c8343eaf037dcd5d255ce6bcf683a42a43c3d3d901	10747
1064	fa36970e887b0f57771e8ec79db496bb4f4d9495a8a590f7940677571abda943	10751
1065	6fd2c2531a2120f92d42a1e3d8e99bd552cafdc84934672d522c5400443ac687	10773
1066	edc2f0ee54f0ab2f5b7070662cff6304242b82939dd1f1292bfbd399ecab5cea	10787
1067	b136908662fc2d94175ce9fc9b5844c216f0bbba0413d2e662b61af1e83236be	10804
1068	cd2e48298410ee22aa394e8653ca91e095717f3d68391486a541c611d6ca3dd0	10808
1069	5ee830f8071d04659c7092426d0e1ae436ba7545938c70ebf4fcaff4d5e0327b	10835
1070	da9ddcf059141940b1c585fe279c29d007b9fd64ce5e037740e3f216c459788d	10844
1071	fc6a0b3a69d55402234fc46fdea6b49454b656c1ef75da0625f93d41ea77c07e	10852
1072	0fb025e7d78437488101cd700af278e230b40f73b13d5ac1fb323ad98707fabe	10857
1073	3405dbf6bc05d6eedf88af61279e55132dab7e6df2de8c515e72e50a70d27285	10873
1074	5231baaa815aa8af8656e5eaeaf56cbae1be018893911271fd37b56b7c99e552	10876
1075	77234779f0d87daba6ed051ae56254d2fe0ed79584c1a578ff6549ca8596cbfb	10878
1076	2bb8a59f00a8e0ad8992862eab3a749754534bf9983e74bac09f67d5dd89e908	10882
1077	530ccfda2589024d9daade609f25ad389e34c97d79771ade5bcbae3e92b9de6d	10892
1078	ccb68696a5ec0cea8f5d909ded9f9085e99fcd6d9c2d96d4e83533820787d8ed	10900
1079	ae89da2509bc7b397b47210c4a128484ec6758461a2aeef3b88670ca324756e5	10905
1080	3b58017813ca6f2b9398217f249c63cd0281ba868faaa09d4010ce7dc53a5921	10931
1081	cc027c5087ac155e766771935888eb975e190c62e2ef7ec3182d7d7db79eb9d0	10942
1082	7aa8ec50ae56c975309dfef93185a664f93349f64a14a9899ea86d534f1f6d8c	10951
1083	5d92f8ca8ca00219ce536cfc826c2abff9287d1dcd84b0d699fb0dddba5c331d	10959
1084	5c93f5f3575646e02b7ef64b587e7eff488a9660b852596fafaa3db71ae807c6	10978
1085	3a51c1a5c4f9cb0fb15229d542438282086656628640056b043e6641d9577b59	10985
1086	98f46f79344187a233fa07ca4cbf3f6f2f2df87895d503937ffbdc6871ec9427	11004
1087	842486c8bac47ed53e92ca2d878cc75acfe3b778f14abf948f40e73ea0813d77	11011
1088	e5d72e03c4a9aa4fba93a0655b3696acc52ed541dedbd393c1db7fb60e485cae	11012
1089	9f6aaec9bb7929c2188b31be0428e1693e0e7efedd0a1f70748226d03fbffa45	11014
1090	847581fdebfd9c6937615eb1a0c71e2e6c3b073dec9eb107bad59410db862613	11022
1091	a6bf5383d5ff93cc1085cde64754075d3789166db7144bcfaba7c29d2e8d6e5e	11024
1092	87eba393df2d0af5b200587dd1b28900c94db17711b8d3472faf01dddf116815	11029
1093	c81b96e29a6bc6c4a9af647d907fe09ec8c9ae675eae291bac8954c89bb589ce	11047
1094	b066bcf69c8e44d0f4ebc0bdd310a6fa12bcec1bac77b84ca66223d8ad060183	11049
1095	162243457db5a946b294380cb5d4326d20b98a010096d3e34353c2369e95cc32	11060
1096	f6a363bc8c25dbeee59a811d51e4113452bcd47ecec2ed4ec7d7c619355356c2	11085
1097	78b024ad655bab5e803cd7a3dfba4546aed96362e191c31ee398544f0ea9e685	11114
1098	a9a6ed417b01542d6d4b9b6ad19b68bb1dfa529fa385383118601ac4fd8d44a9	11124
1099	893cec43e81596ec914e199c89ad3e5d9f8feb4f213b3c625bcd11c729f24195	11155
1100	f1541e2c118e8cef6ecee3c5fd2b96fadf1b05965614e425ddbbfc1d0d2389f4	11166
1101	9e151ebddb9de646dddcdecc71bfb7207d28f70c9beb31a88bb513e9aa0fe11e	11169
1102	9a1081e7aff53c1e189251c9125d2aa0628279b35e4b5921f2b6fa029b7836ea	11181
1103	9fed8d7a8ff596a5e0e8777002f344cb3ceb48f4b618587fcd3071f6325e91e9	11182
1104	971764f8467c9718376804d82cba9a8a11b45e831b4b9199a6841e8040c518f8	11186
1105	af6b86ee3ead0b7bca9f41ab192b32a1b487c0ca7480c1af038d7d6068b8f5ce	11189
1106	4e9589160487231bac8086caed0bceb32f01f75eb48a0404e26c67c7de6842fc	11232
1107	6f7c83a0681c9afc6c8031302ba25f24b5faab8838498aada2e2150e2df09026	11238
1108	80036478601caf0ea10c697f283d10bc5a691ac9320efff45657c52be6052919	11255
1109	87fd15f621dfc665933302afe3b595a67a58641c8bf4840bb41d16e4f67c4ba1	11266
1110	48d3291615c926595cf371f388285df373f78d30adb9b3857abb1840e658dee8	11279
1111	a885f4d0fb94aef515e0c86b6bf74c7b88dcdf01479b791ab9b1d61ff05896bb	11294
1112	22dfdf9761e9298f48197eb5db8c1dac56d1e54faa2d48e8c5647d630096198b	11305
1113	0b98cce7d46e1a510624121dc738293b349965de8c21f94f8ebd870f0d667c92	11317
1114	33d6e5d5580d9b102418975b578dc89d2694ec699ec65843e8fdc102383b0017	11334
1115	09e3ccfdd71991727103720c15fa2220dafcf9d8453df81f0436ccbd3b91adf9	11353
1116	0855fb36fb500e8ee03d33c757a54f84535e2fe8f034fe0ed2face3a82467b8e	11381
1117	5587c10b27bb28aca6ba24ad60d1a5947fd1a89a2e19b1a63cc4a446a10e7692	11388
1118	075a416e30f4008a367ba11a6bdcd6429ab16b810675fd9466b2c4308da0d42b	11389
1119	88bd500a0a4580c85ba87475e0d68355c34ec7d50c416a0184a00e2704dc8b5c	11399
1120	856f5257062f390018e70a32e0686c38602cefcad3820751c904a73042cf7a8a	11411
1121	1228fdff947caa7afa3d88c206678e1d293eaf8ac086c479dd6dcfadf9c83049	11413
1122	04a140bb4cdb52c40a528efb9ed7223398d5b772617089eb354884adf02e219b	11440
1123	a16134e13acda53d59f35949f4e29ba8ae15c9eab19360734ef93c5d887129e4	11447
1124	36ccfca76f3a26245c658e468598f741ed701cb0f3aa85cfe53ee2c528ae1e24	11449
1125	82a143da8a0a436d174614f4f6bbaefcacf6fe7b7812b32773f8dfbc33212e66	11456
1126	35a1b393c229fa6c83cb0201104dd6ef11b21f3c02cff3bf0540db579ce7e413	11470
1127	d6f3b8e4bf649f9ad27324f0336f524ac87a158fff6f90f9f819b9d48981d6ac	11473
1128	efe8dddc98e2a72b93fa9d2e146b9d9c5af48456f6ee0365c776a3ac1daec58f	11499
1129	4eb3b526bb180cebeaf8dd122795d87cc91e0577ed4dd621c8958fc7ba13f3d8	11504
1130	c08e72e27ae23b5f591a42612355831af2ce42eb1fb4644bcc13d89512a7ce35	11523
1131	eecb6e6d27358e535701b46c2ce750a563311c342957e1728d2d0c617201ad2f	11524
1132	8c5a3808fbde4a8b15b8175c409bde540ad451bcd1f5d3f38f7dae399f27716e	11531
1133	075e667a3f03b5d1c332a182b4b889cd8dfa44c70aba3b39b59ad3b34c774593	11535
1134	105e84e67f8918ffd15c45ca7d7f3e7fb7ffb30880851c5f8d5981d5d8a38e72	11540
1135	710de0aa469074e3f49e44ed1271ae08ca08d898e00a5576d22e3f8df345d28c	11541
1136	f66aae70cafeb890bfab7af9d8d5413cc0b051ef19c92f8f2eee12a2fc85a969	11548
1137	a605c71a246c46783211962697726606f74d70735f86987e3baf4eeccfae7062	11555
1138	0911d971c4428cde72e9a045805175710bdcafdbbc2e2f45b3fc3973cefe4345	11560
1139	03983e06556d88bea8e89173a2214b43380660b7aa8effca2fdd199348886a70	11564
1140	d78251c996b909e2f23a1b609e6a8e861ad02460b3fa1f128f8a8e7e182754ce	11565
1141	5decdad6b78c78c10656fcd67c4b845de2408f3bfcdce4c236359c55f91c23cd	11575
1142	726d9e46883439a2a732c45cec9668fdbb27c3bb9e14627f5a64f7cc8d4d26fc	11594
1143	1341c8a5b63179a5af66701ae2d932bed0b41ba6d4a10f723a29c6dcb4a66c5a	11605
1144	e1c041dbfab6d610d73d7d59c454b7e93ad0866447665721f0ffb6ba96f8b31c	11616
1145	0d6eedaa10f430e4424e2d5e5a25108725235e4cae944a8eb489ef20b0511733	11641
1146	f6eb2843e83c30a77801a78c6265270ada186ad767fde12b9f4c87d760a13ffc	11649
1147	0c3703eb8c884a245252b145ae0b786383982781472e9b5c26207cbe0d6e9b41	11660
1148	0de5a6ec41b8326d3c2fb16fec9450eae24d49c5cb36a8b299190c7d32d77ed4	11663
1149	673cf62cd469284416e48b987cc070b54c8add5ec58ea95d9edd3df88f96712d	11667
1150	0e027d31968968115dae3ce02e7fdc6f09671fb8d24ee075961dbcabcd6b5508	11672
1151	12f0e0a3a96dc9a96f81c9c53c2411bd64c73b1a215b73d2a4bc73fb887df691	11681
1152	4dca4a587d5ce43598ee26b467eda1d6a750a714c2c785c5c7cd4fa6ca6d93c8	11693
1153	eb64a19ba804d7dac722b0f64860995d607bde9e43be6f4a17b273dbb0175e74	11732
1154	223f99100f6c2c255e8a8b7c5f9f2a77e97314e48db5d473ec3ab48272ee5eb3	11742
1155	c157412a4f2420fa6ac25046ee94ed905304c51a57a7a0ed0ee67848c34bdee8	11744
1156	0fba778331ef76ae589b0c746efb5c6c902691f0ebe953c07350cf46f3909d24	11749
1157	2b5204323631d16a7805cd1ee0c43215a884b163864a8d89c0b8ddd01b513192	11750
1158	b9628f8e9b617f2ad64846bb315364731c7003ffaa666dab50f1b033c0642d21	11765
1159	4f1a9b56fae2f6f6e4a37f9381cfa232596ceae831f43d6306aa71a8e9197f53	11768
1160	3e7ff34ee22ea12e9ea44767f31699a2da97348b97d83261a71d8a87fc544c9b	11771
1161	2d70d2bfca2bf030675d95dfffb618c43fac74d7dcc67c30022c649faed868a5	11814
1162	d6ac7c03c5b22644d03a87435c0dd4b33cc49e646d3059164413277144209ee7	11815
1163	e12198cb2cfb598c971225beb6f9ef245be693092f6ecf06bf30f00fc5582a0e	11816
1164	0d5ad8723f4b4844a714731d261b317a3dbb78f21882eff84a288891fa8c7205	11821
1165	1680506635068bbdf60d6dca7dc0973629e5cbd31baf0521d785577defc8e48b	11856
1166	03d7a64bfd8243fe4e020363e287812d8f4fe8576e172ddc71bb1e296e17ff87	11862
1167	de98ae62a7f8f4e354e84a8f694589d6c22e0691900499a653d9c0cc24a8a627	11879
1168	a8c918ef1e15f0a7f69e9d94da3723fd20f41e81e0e137a5da671aa450b8fb63	11895
1169	bce0f4898fbe2a5afe4343238b6950451d52321c0afffc918557924b838df9c3	11897
1170	aa9eea7a710df9a510eba0d7f6ffd10c087c9c50a0fb40d693728378b5663e4c	11902
1171	331aabd48189dca17c28d781ffcb8e9fede41074784a459ef23e2f9f4c0209c2	11917
1172	ada3620bb7fb8de0fca027d5089fee3ff363ba0ad01d8a18a59237384422d690	11943
1173	675f0ee30900a9ca2a6ca75f9e99874179c9e799ce55fc70411a96cebd302090	11949
1174	27aad0e8632920d007c7d7e4e6b81da9d456ab9142fb9d5cf1410d0b6922ee43	11963
1175	c3ca593b8689a4518c0df64a4cf6d93eb1862c732f452cf807d2442c5f890198	11986
1176	b30fd3db69dd41b0a55403a12dc1436864fb218a1f49dc8e1f38db6b5e9711f1	11987
1177	8d3d1811202175748c7c9f394749490e7f30b939cb3af5e827e4b5d95eeb8e98	12000
1178	6be5fe530f086a94be131968cfcbf66e121beb10c04e01be50e6f40bd179a49a	12019
1179	72eccba53d97ec02dcfa1d2d29080b6eabd2e5acf01a4b08f8ee2cd76bbdfcdf	12022
1180	d2bb44d51d9f5d55e37c61bc0800df2ba70cb4e4e55b249d5ce975848b50502e	12023
1181	a4d415feecef0f13c90e59c2b2c10c931f47cc74c3f3b4c6449f0dcfdd79a759	12024
1182	97d85969216e094103595ff9fe0e78a61fd4bf29a29918cf72423ec19470ef82	12033
1183	5fd3a702ac39189f8b453b2c0859c50171b53c56b4c2c5d2f230564f95699cdd	12057
1184	b8c7158946f7c5799bb17ba51feacd141a811d14d086985e4b443002a8a5c50f	12059
1185	898a91b8cbabf7b3978ae81fa753828481f304af3baacbe344cde423855d78f7	12077
1186	9436a08015a068e050dbfbea3f0705a26cb6429ea4a229e4b2536b88aac9f405	12083
1187	bec5892b25ceffc2601649d7c8cedb295161b40d3e29e2bb198c5f6451ef1f2c	12085
1188	4c2e0dfa4662f33cdb6b2c69e0feb9dcc818e40b3d4da4d83f801bfb54e0e130	12096
1189	40dc13498a802776607dbef02faf9b7e01b77b2468cac1f3eda161f009bf0b1a	12103
1190	f1049bbf00892f46f2c13979e163a7215e211fe9869b6fc365852857f31ae26d	12120
1191	df21155cc5b7b08d869f694dd43ca95301a6560fad51ca2cbf75fb58a835e28f	12134
1192	f9f29add551d18d70a7e4c4709c26f029bc07bb76154abaae5d97b1ab696265e	12149
1193	a87f3c38fc37426115c8538327182bb58c9abf14aba8fa994f665ca08781de8c	12158
1194	90ef9c9145fba0ee87c2dcfe3133053b86afd64a57064ce9bca04253d1fd2e18	12159
1195	df2c6102cd36f069318377df4b58526adddbc06ce7204e3193ecfd4a4ae4c856	12179
1196	ce911776764ede7166425d798f3d366a71edda119146fa642e7bc81f3bae1fec	12180
1197	cdc77f93935ce12b57227a358bdfb8012f874d9e76a28dff509141b637242213	12194
1198	782542a169e8e04e3586ff4e8c629a96265c704eca092379149ab4555cfe642f	12221
1199	410fa3e3aa5ec3b055749d411b1415aa9a0ec3076c0cdfc7062c2b5bf7477d91	12231
1200	a768818f24128f65ba827c34f5cd32414d01be82164e8278b68f35b02d8b1111	12249
1201	629ca61e0e1fb437d0d626257a192f00fdcb8e4f6f5787ec0bc4fbef5f47f4c1	12250
1202	e405f895f9b12c13d7474eb1f5d2cb19b20b0dd600d331b99ce9095ca84f8427	12265
1203	896da0f64525a9c2071756c88bad953f193ade31309b541f8b953d786215df3a	12274
1204	cafad6ecb015770b254126b9e16eff780f711e1f86f4dd3424974c25844b587b	12292
1205	f837065551af5c2565cf989029e02236cec019df96d8d4fe3127dd88a29eba6b	12299
1206	8620fe1daeed857bccc720709bea3789835ebbe4663ff1eeff3ad21142c3b0ac	12306
1207	4327cbc037d30f692f586f05652dfb6b6c8e5e5bb7e5ffa54952bd7451da4235	12318
1208	d69946faaebb6a6cc982b314c8d2696b624255bdcc57a5bad11259e4964c81f5	12324
1209	34700208463bc18e8e2d7e32dcd83c24c1817d216011bf9ae8be46affc333b4d	12336
1210	836c2ea57a4ec366342f9083494e49f0488baab5a59a0fb6822c2a1aa32bf43f	12372
1211	0cc0c7a0496f6575c0d9a646638128833d39dd08ae61d83cb14ab9e4206c9333	12392
1212	8a919b8b926dbee6acb9980b26fa3e665231d552220ab5b3c4ed1b19d58a1a20	12412
1213	c1902004a5f035c8a749440bb195cb6eb5b9818cfcc3819883041d1b820318aa	12424
1214	b37f1864f5ed65505aafbada80931651d9e95b13767501083ca694aeb33ae6f4	12426
1215	159c5b0cf273eb848150075d58760e9c7871168827913a413c1220449cd978f2	12431
1216	3130a20fce12ba73b3a5f37ca5fb052eb24c2c667a5b90670cfddcd0b0a1dd7f	12436
1217	ed4de13cdbf21ab40779deae8ca2cea6ca1986f7278a7caf0fbd1e929bdb3f0f	12439
1218	147204ed54e53253b70d5a9d8aede39df5a0d93690c888a7ff8678ae332df22b	12457
1219	3b58e01cec3ed96a1190f8db2795dd6a0564d2202c56b9b0074ecc009d63110e	12466
1220	a75cdafa8af573dc7bc582fe840067fa33751b2469e51ec160aaa28913c1daa2	12467
1221	9ffc21bf76942a6a04ebd6e8e3d72e60520421a26db887845cc96f76fc09a2de	12496
1222	63f5b7d0290b7681556fdb7b393e658aa6b7a9510a3c862d6ba2e359e71afbf1	12508
1223	d695d1689246f9ef1fbfa99d3ab2e31f3c5d898ee92d73acf5b7a0d3f3f8cf01	12530
1224	4624849b13d5dc0786cc284fb9997e7a3cd4b7cf2297f5d04baf2f37b670d390	12540
1225	97de2a1638945c2f2606adf5fe8da344623c8dc6cb819c8f80d6578a44dd8805	12546
1226	f370afbcd872a06f0a8ed202d5629561a6f3909f3148f14c14634edcaf915411	12557
1227	43ed4b1d4784d1fec00ab2c56e54145aedc1c77c2fe21b8ed697f0a5e852b097	12589
1228	1829392d6f8a6edd929b3e126c944877d1834e36bbf52b8078bf15c0887e0342	12602
1229	5fd200b390e7c611afe0f06d4d350135b78f91b3a004661f2bd8da373989f4da	12614
1230	8073b583478113525dda80e29ac69f91793b21f770ec4620074574ed986fa8d2	12620
1231	eba952883b3de485c570686f363fc7fcc568592ff5516e17d115f2a2bb4661e9	12622
1232	e1c4627a6fa3f867c1de4e85c986424662c9f6311ebe5b36ab785b9a3af50d36	12637
1233	a62c99af34820cf35bfc4419535040aa7567310ef83cd5f58d1c2b807f329f09	12642
1234	a4e61b9c5ea0c10e9ee651bcca9d957d6d9d52d7910f6645fa97e51a1b9d53e6	12645
1235	2c12c75a933d718b05c172f73aefe9d688043d1120cf5c3a5aa482dcca971136	12660
1236	b62772749804cad19432ea1ae8e51a68274128b24f3548fdf9b811b5854ade0d	12665
1237	96b22bd4f95539663f225014520c3bb91e5d662e5062623a0c487a832c35a5ec	12677
1238	0b5892f5716f05a4d9e790d26e0c99d9af3c95985af983c324fe02d580aeb666	12686
1239	7d3b7786630ea0b41985e13c024214a0b827017ff34299e5c778eb85c7edda7a	12690
1240	ae3f1d2ab45a53cc26f12fecf31c526e0012c92775b5efef7eaa9e742bc81c35	12700
1241	d42df1a0b2951150971afc753bb039e9c61fd13588cd763b3e231dfa064fed87	12702
1242	b5ceb2feefcaebcef273e01ed816a3c0ff4c672270b9a5b9954c05f209b6fd52	12707
1243	66acf3c7faefa40345724641ad03ffe3ef3027d2a9eedf7e93d58863c24f7c5a	12710
1244	13793ba3be94649859237c0a14e9fa42e10dd4eaa63dafc54e9b63fc3e5740fe	12712
1245	4640c57dae38c49c1c318b86ca82d7c606ea549adc30bf518ab0bfd46029ca06	12715
1246	bf61c884ffd5ed9737d8d48c0ad944b6f299a546aba6899390c30eb788b09a4a	12721
1247	2e40b87785231d3ab154ebe104d5ea500722eeda3bd23f66fce79e69884beb92	12734
1248	3f39de4a8515a402b7b8375815ac56d4ba4b79b1e03bf555590c9c9b5ebe59fe	12749
1249	9f5baa9135c416b2f7e997410c548a34dc8331c90430163da212bc1c1b9e9e42	12752
1250	04cb6a215a008e906ed03045f86e92c3540b1db38a24385e1f7e1f96d469c8ae	12762
1251	8684deb2237ceb141a0e1e344c872eefd506a7ecd66ba8f29f5c3ad9758e7215	12775
1252	6b3efbbcdcda89c756f1f0ee46c8505d91f4e4b8672d82f44cc13a5ecebb3e46	12780
1253	6754a1fd1bbb4354e3cd8231cda48ad5ab703a76f6f12aedf68d938895f21b4d	12803
1254	348dd9f89c724b41c65fab7ed6b96989ec2ade04342465009581454cd7c2a330	12813
1255	4e745339a1fe8201cd817296369bbae757d749692df5708c06977b91054eb9b0	12823
1256	57cf16a78d5a785f64a77a77eebb92757cc84ee5c0b942af2bfda23751cde796	12824
1257	2a9f659d872e4279b1147ea962dc813d212f45521fe9b83162f7ac18438a3262	12846
1258	da816ebf08dcfe11311de841dfe7cfdc13cf681916875c1dbda122b1e0833df9	12852
1259	2db703c6920b958670df1f0a7ed013c81c2bc5563a0cf1bd733ee0bce5ef45a7	12853
1260	39d609cf3666ce15888f4f4d107b5afed3a661c975a87910cab76b3f380cc956	12861
1261	dc3208f4a134f7a86b19872e1c937d86dc32474a314562615463917b8aca0796	12878
1262	c87671de786e12be5a4a3d9ab568f39e7869c6557d36a838ca377e3249d8e7a2	12894
1263	b6cac36a77a13684f4d3492dcb495f5b810a3a5d563a8b5a694f2a617996f393	12904
1264	0e8657ad6636e4b8a6bebec0663a46a62937119dc26e2dab53403e54ecac7d63	12915
1265	dd4167a6b68a2014b360dd517a36dedb8a74d442460e42a5b0feff3c87ecef4c	12928
1266	e4117ee9cd75ef20e126e47c5086c03afb36b8b3b9e451e658b170ded8a3fed1	12930
1267	aa699541aff72860e1a9c6dbd03ef3cc64e8e3fd8197ccaa2c61e0c3924d84a2	12931
1268	6d21cb236a38eabde5383435daa5c60f1dc9dd7c87e591aec902348bdade08f5	12932
1269	66b35e3332f3a283975a6f44c972f8f89427d4fb02330b2bfd9f164cb7238ac2	12943
1270	831d07dfd8323ee50a61f5c3de7efca72d6fffc378444c16c09ac29a5975817c	12958
1271	c903a71260464f6d4fe975b8af7e0d55ff6188353801aef4eb12fa24cfbbb1fc	12962
1272	aaef86d74b641536cc933a6dffb70c8f6890ad4aaa219b0c11794d3423446def	12963
1273	f8ebf85f0492652651992364bba4a1fd797cbd551661424a35d3077134fc6c5c	12966
1274	7bab1f8b5ee00a62c9e6c61111fbcff8666189a265632711cfa8338c7ecbc380	12971
1275	fa549c6d4cfa207a69e309696119d1f943726944fc14350d1817291fb4ef67b3	12985
1276	bdee4472c9b34ecd190730f7d9dca12f7ac53f2332bdd6d6d6e291573b45b91c	12988
1277	3a7ed778d9540288a5df0220d5545c0aabcdaa741044cada8008915ba8c718f3	12995
1278	9d4ba682ab3bb939bf461b2ea41478b3e4291d00536292692c707fa7fffa0da9	12997
1279	7b106cabb0cd6bd0b63d60b7242ff5bad061e7c8922258f30101180c8b04469c	13010
1280	f68494ca058a99825eb2d305774a43e7bba70912c65db2046156c5d141eba005	13017
1281	b6b38264897273aafe275f25b22275b32d0c86302c9c15e78159355a00616a26	13021
1282	798ee18fa327226c134c3f26105e185dd6fa3e5fe3d1eff159f0c6b06927b263	13023
1283	2fa3b0375f06c97a547b5be42a94934b233652b0018fcb844381f601018f03d6	13030
1284	57fb05aa4b1ae29014be18f2e33e55037a193f28d1c86406e1234db24c7f31c1	13041
1285	6bd7a3065b7c1b12514c0f8f8e576e7ae74e7bf26983e17a66d9db5f161dda5e	13042
1286	76bc5d2276caf252d76b8c81dd9075077cfec14d76f50efb04c5decc2045f549	13050
1287	df3beec0315f1a6e25a79450096977236d50fdaeb0c98ee3c4a99862ab6a1cbd	13055
1288	329808a9e32e5bfb275fd54247ca90cb5d64c97c86b933a4e2230e0ae17191cb	13064
1289	2d8bf3924b1dc25c1df2a3f63e2c5cf093690a2f845009e37492479bba049363	13076
1290	67de36c0510016dbd20dd2ba386c38d857d278929a91d416caac1d608fbff84b	13078
1291	e77331480a850be8825242e2090f3abb7c4d88a6dd6ff56253ed689dcfc590c9	13080
1292	8371dcd6ba1428496a26cb4c41f3877f6f1619f636e229ae3229ef3692d17ebf	13102
1293	a432e97eb64615b449d78792488ee92b3c3015da8d9119156312c7aeb1ff0d2f	13111
1294	f1960f2edba7bc5ad1b1f741582509bcc702e5907289444dd9c7bd9cfbeabc84	13122
1295	b045ff7279bd9317069afb8d59b6268e79e6cc9ad428e27c0c4c5fb6e84e3308	13126
1296	31b9d716586f55c91412f8d78e66f3c3eb4edf27c9325749ad96c42e881d43b3	13129
1297	ffe1be28438aafd0908bcc316c19d3429dad0cfa78d32570463c01357d184c8d	13132
1298	5960aa0bcf03cb45082a61cf8ef05e52e6cd9c0847e1322ee814300ce28de157	13135
1299	3a476df3e0ad049b28bc94b7523bf672b119b4374e3486df2ccff53d85aa6a0f	13143
1300	781d6523e6892c4ad79ff05fc82dc8846e821b8051364b1a54476c6a85925b14	13151
1301	cfe26a66b7c2f93085ba31c274af222e603c7485375b0d21ecd2d46836994064	13157
1302	ee501179812c61e898f3f5bb9652c981d6c2709ede0e644fe03abc27c7ae425c	13169
1303	83f0b2164b589d216d9106cdfc2a229214502c94352a62f86eb084d287e3b623	13190
1304	d3ab43acf6ce702660671415d33dcd3ab38760316dbd92c00b740e52ed730490	13192
1305	868fbbf719a24caa27ac0ae89b9fbd0e333d62200ec795d33b9ce882c6c21cad	13193
1306	33e027bc527bb5c2edd45ae60e25fc1b1736948d401600f4670a0521f422f902	13202
1307	c3f0af83e560affcbbbf865335033873325aaaa0d31308f0279f7978f6932653	13209
1308	324812d8c63430ee6e164048eae54e87bdb3939e9e677115b3016aa42b01751e	13217
1309	d96a9127d019744264e71c39cf17af755ea35012019cc1c22034fb21ca716ba8	13227
1310	bda50e5795f8026a4ad74176a9d6a557ec713c04dd713ca63923a7dfe3599522	13242
1311	dc3f5e5c8e1560be050374d6d61983464167fa34c3392ea8b17f66885d137e91	13245
1312	9f2beac807ac50cae77c25e6653d2247dc846741872453921ec8f33699422171	13247
1313	69fddccea36dd60d5a8e74795145703bea8e1f4de997396e9fce3550ae9c8db5	13249
1314	ebc02a1558c61322a1ff47e6df5086df7ca944b89c43febac4c8281d3116e7ac	13264
1315	3f429bbf988734de6fe73567f0ae728b806b620752f730a7d1b7d34e42dfb633	13273
1316	d749bba36b6cfdbe8fd41d410db80687bdaee4b47ce8110242d030aead19e6ed	13275
1317	170b1a66a5650902d7ac43a87366026ceee39fcb638b87fb70f80153af15f865	13284
\.


--
-- Data for Name: block_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block_data (block_height, data) FROM stdin;
1290	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313239302c2268617368223a2236376465333663303531303031366462643230646432626133383663333864383537643237383932396139316434313663616163316436303866626666383462222c22736c6f74223a31333037387d2c22697373756572566b223a2264343865333638336135336537653239306338326662616132643232366131333238386535313932666639326265383066643430386230366438353037643765222c2270726576696f7573426c6f636b223a2232643862663339323462316463323563316466326133663633653263356366303933363930613266383435303039653337343932343739626261303439333633222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173657a393339683335763374786b7664646d3738617230396d786e6c3672616c32633664787a74746432713437376a326834667132366a673866227d
1291	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313239312c2268617368223a2265373733333134383061383530626538383235323432653230393066336162623763346438386136646436666635363235336564363839646366633539306339222c22736c6f74223a31333038307d2c22697373756572566b223a2237653438323161353861386666386536643039653839333461366231353030336362623239393439353536323266396265393439366265333636653763663035222c2270726576696f7573426c6f636b223a2236376465333663303531303031366462643230646432626133383663333864383537643237383932396139316434313663616163316436303866626666383462222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138616538796167637538396c726b647a6364677265323064776d396837747677376461766d6b703675637066363878326a746c71776c70746668227d
1312	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313331322c2268617368223a2239663262656163383037616335306361653737633235653636353364323234376463383436373431383732343533393231656338663333363939343232313731222c22736c6f74223a31333234377d2c22697373756572566b223a2234323135623733303636633436363035356166363038663934616533316365316564626537383938313035396638366263663437646338656637313030643864222c2270726576696f7573426c6f636b223a2264633366356535633865313536306265303530333734643664363139383334363431363766613334633333393265613862313766363638383564313337653931222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31653864307667636b747179307079776b79633234393870326835376c68357a6133346865366d38747461706d7968727075676b7177716836736c227d
1313	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313331332c2268617368223a2236396664646363656133366464363064356138653734373935313435373033626561386531663464653939373339366539666365333535306165396338646235222c22736c6f74223a31333234397d2c22697373756572566b223a2237303862383337303231363235613933356264613935303133636136386364336639323563653837616262366138646664646235613266313336383730393432222c2270726576696f7573426c6f636b223a2239663262656163383037616335306361653737633235653636353364323234376463383436373431383732343533393231656338663333363939343232313731222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316433306a763738306b6b6e66726873796874346a336c7a6e7373336d63656174786e726c746b75733375737372356d6163797671783073366d6a227d
1314	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c227374616b654b657948617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732227d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313738373435227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2230366566323730343064636166626336646566663766363264353531316366313036343237653562636464663739663062613137376435353163636136633931227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961343436663735363236633635343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2232227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396134383635366336633666343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613534363537333734343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383231323535227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31343638397d2c227769746864726177616c73223a5b5d7d2c226964223a2264373432343464656666393936366436626465373862326462393934366131663961653964303335373938643163653362363436663162383238396531613230222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c226638303037613865666334343732613166326665616333656637346666333066373165383330353264653338646636336431336238346663363730366232653962653539363063356135343062396634663039393761653733333638633239616639336631656438666639376234393930313833336164626137343038623065225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223630623736633361343538343030333665623436323736626661343361666333666236363763643039666339626566633539363164646562316264666564636636613232363332626432316662653636366461393936636263613939656437656262313533626561323564323738613831363261656163393633636637383061225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313738373435227d2c22686561646572223a7b22626c6f636b4e6f223a313331342c2268617368223a2265626330326131353538633631333232613166663437653664663530383664663763613934346238396334336665626163346338323831643331313665376163222c22736c6f74223a31333236347d2c22697373756572566b223a2234623833386430643934306266306431383661623430623731346136336137323131373338366432333162623438376564323434306530616134633036373333222c2270726576696f7573426c6f636b223a2236396664646363656133366464363064356138653734373935313435373033626561386531663464653939373339366539666365333535306165396338646235222c2273697a65223a3532382c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383231323535227d2c227478436f756e74223a312c22767266223a227672665f766b31783430767434777167797332716530786a7674366e617276646d3470776167346d77753730307764636d647935657467776a6a71326b356c6165227d
1315	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313331352c2268617368223a2233663432396262663938383733346465366665373335363766306165373238623830366236323037353266373330613764316237643334653432646662363333222c22736c6f74223a31333237337d2c22697373756572566b223a2266306435363739366262366133663431343964356239656332646535623638636437323265343232626133323337363966356531373134626164613235356138222c2270726576696f7573426c6f636b223a2265626330326131353538633631333232613166663437653664663530383664663763613934346238396334336665626163346338323831643331313665376163222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6a73757077787078366c79657174727a3765386565656139387237376c757a70797a6d3463376730776e6a36747078676c7873683563746561227d
1292	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313239322c2268617368223a2238333731646364366261313432383439366132366362346334316633383737663666313631396636333665323239616533323239656633363932643137656266222c22736c6f74223a31333130327d2c22697373756572566b223a2234323135623733303636633436363035356166363038663934616533316365316564626537383938313035396638366263663437646338656637313030643864222c2270726576696f7573426c6f636b223a2265373733333134383061383530626538383235323432653230393066336162623763346438386136646436666635363235336564363839646366633539306339222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31653864307667636b747179307079776b79633234393870326835376c68357a6133346865366d38747461706d7968727075676b7177716836736c227d
1293	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313239332c2268617368223a2261343332653937656236343631356234343964373837393234383865653932623363333031356461386439313139313536333132633761656231666630643266222c22736c6f74223a31333131317d2c22697373756572566b223a2232323266366661313835356139396132396533343439396132363234396439373362643130666364393964386239383835626466346332316539333662333031222c2270726576696f7573426c6f636b223a2238333731646364366261313432383439366132366362346334316633383737663666313631396636333665323239616533323239656633363932643137656266222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c67647a756c6c6c3277737a36347567356463323273676333737135386530743332786e68686e70776d70747a33387078756171656e30656e76227d
1294	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b226964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c22767266223a2232656535613463343233323234626239633432313037666331386136303535366436613833636563316439646433376137316635366166373139386663373539222c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22353030303030303030303030303030227d2c22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c227265776172644163636f756e74223a227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973222c226f776e657273223a5b227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973225d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e31222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d7d7d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22696e70757473223a5b7b22696e646578223a322c2274784964223a2233376664363536346663663836653963316139616234313338316162356235303139323835333132323039333732306661666466653931386434313334343836227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936383230313131227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31343535317d2c227769746864726177616c73223a5b5d7d2c226964223a2236646563626533663236626363303665393934306338366166323737356237663630303461616232653564373835383731653363313737373861316437373537222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223164363262316137626430643437353437383733623335623737363561343264666435373761616463333861326565316563616430613936333732383430666366313233646463376265333235336631346436343761383331616264376632613139316363613261396137313936303261633635643633366266373465353066225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c223965393162633163316463383336616266386637376134333165623962333935663331303739396230336563326538646461396664383036343564373138643934656138323765323262383130663635326136316239303164373665383131363165303861393338323563373965353139323164386238376534303664343036225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22686561646572223a7b22626c6f636b4e6f223a313239342c2268617368223a2266313936306632656462613762633561643162316637343135383235303962636337303265353930373238393434346464396337626439636662656162633834222c22736c6f74223a31333132327d2c22697373756572566b223a2234333964633262336134633935353962313932396238396366313264366263346339636338373761306262363231386336323035346135616365343861353436222c2270726576696f7573426c6f636b223a2261343332653937656236343631356234343964373837393234383865653932623363333031356461386439313139313536333132633761656231666630643266222c2273697a65223a3535342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383230313131227d2c227478436f756e74223a312c22767266223a227672665f766b317264366d7866776a6e30646776363736777963786d326673797763376572377778717471616d61646a6b6437396c6a3979393971683263327a6b227d
1295	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313239352c2268617368223a2262303435666637323739626439333137303639616662386435396236323638653739653663633961643432386532376330633463356662366538346533333038222c22736c6f74223a31333132367d2c22697373756572566b223a2264343865333638336135336537653239306338326662616132643232366131333238386535313932666639326265383066643430386230366438353037643765222c2270726576696f7573426c6f636b223a2266313936306632656462613762633561643162316637343135383235303962636337303265353930373238393434346464396337626439636662656162633834222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173657a393339683335763374786b7664646d3738617230396d786e6c3672616c32633664787a74746432713437376a326834667132366a673866227d
1296	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313239362c2268617368223a2233316239643731363538366635356339313431326638643738653636663363336562346564663237633933323537343961643936633432653838316434336233222c22736c6f74223a31333132397d2c22697373756572566b223a2232323266366661313835356139396132396533343439396132363234396439373362643130666364393964386239383835626466346332316539333662333031222c2270726576696f7573426c6f636b223a2262303435666637323739626439333137303639616662386435396236323638653739653663633961643432386532376330633463356662366538346533333038222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c67647a756c6c6c3277737a36347567356463323273676333737135386530743332786e68686e70776d70747a33387078756171656e30656e76227d
1297	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313239372c2268617368223a2266666531626532383433386161666430393038626363333136633139643334323964616430636661373864333235373034363363303133353764313834633864222c22736c6f74223a31333133327d2c22697373756572566b223a2234323135623733303636633436363035356166363038663934616533316365316564626537383938313035396638366263663437646338656637313030643864222c2270726576696f7573426c6f636b223a2233316239643731363538366635356339313431326638643738653636663363336562346564663237633933323537343961643936633432653838316434336233222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31653864307667636b747179307079776b79633234393870326835376c68357a6133346865366d38747461706d7968727075676b7177716836736c227d
1298	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b654b6579526567697374726174696f6e4365727469666963617465222c227374616b654b657948617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832227d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731353733227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2236646563626533663236626363303665393934306338366166323737356237663630303461616232653564373835383731653363313737373861316437373537227d2c7b22696e646578223a312c2274784964223a2236646563626533663236626363303665393934306338366166323737356237663630303461616232653564373835383731653363313737373861316437373537227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936363438353338227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31343537327d2c227769746864726177616c73223a5b5d7d2c226964223a2236613561643437353330353534663665386632613935386637373439373961333266633066353963323138363737396362386139353236383330663430633038222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223330633066356234616461626237396139626433343432303330613138613333356264626430306636313437633234666261623962613334663436623636316561373161653037343636326166396632393932326563396463613532313835336235313837366631303566643863396333663263656335363463643537333034225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731353733227d2c22686561646572223a7b22626c6f636b4e6f223a313239382c2268617368223a2235393630616130626366303363623435303832613631636638656630356535326536636439633038343765313332326565383134333030636532386465313537222c22736c6f74223a31333133357d2c22697373756572566b223a2234623833386430643934306266306431383661623430623731346136336137323131373338366432333162623438376564323434306530616134633036373333222c2270726576696f7573426c6f636b223a2266666531626532383433386161666430393038626363333136633139643334323964616430636661373864333235373034363363303133353764313834633864222c2273697a65223a3336352c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939363438353338227d2c227478436f756e74223a312c22767266223a227672665f766b31783430767434777167797332716530786a7674366e617276646d3470776167346d77753730307764636d647935657467776a6a71326b356c6165227d
1299	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313239392c2268617368223a2233613437366466336530616430343962323862633934623735323362663637326231313962343337346533343836646632636366663533643835616136613066222c22736c6f74223a31333134337d2c22697373756572566b223a2237653438323161353861386666386536643039653839333461366231353030336362623239393439353536323266396265393439366265333636653763663035222c2270726576696f7573426c6f636b223a2235393630616130626366303363623435303832613631636638656630356535326536636439633038343765313332326565383134333030636532386465313537222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138616538796167637538396c726b647a6364677265323064776d396837747677376461766d6b703675637066363878326a746c71776c70746668227d
1300	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313330302c2268617368223a2237383164363532336536383932633461643739666630356663383264633838343665383231623830353133363462316135343437366336613835393235623134222c22736c6f74223a31333135317d2c22697373756572566b223a2266306435363739366262366133663431343964356239656332646535623638636437323265343232626133323337363966356531373134626164613235356138222c2270726576696f7573426c6f636b223a2233613437366466336530616430343962323862633934623735323362663637326231313962343337346533343836646632636366663533643835616136613066222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316a6a73757077787078366c79657174727a3765386565656139387237376c757a70797a6d3463376730776e6a36747078676c7873683563746561227d
1301	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313330312c2268617368223a2263666532366136366237633266393330383562613331633237346166323232653630336337343835333735623064323165636432643436383336393934303634222c22736c6f74223a31333135377d2c22697373756572566b223a2237653438323161353861386666386536643039653839333461366231353030336362623239393439353536323266396265393439366265333636653763663035222c2270726576696f7573426c6f636b223a2237383164363532336536383932633461643739666630356663383264633838343665383231623830353133363462316135343437366336613835393235623134222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138616538796167637538396c726b647a6364677265323064776d396837747677376461766d6b703675637066363878326a746c71776c70746668227d
1316	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313331362c2268617368223a2264373439626261333662366366646265386664343164343130646238303638376264616565346234376365383131303234326430333061656164313965366564222c22736c6f74223a31333237357d2c22697373756572566b223a2234623833386430643934306266306431383661623430623731346136336137323131373338366432333162623438376564323434306530616134633036373333222c2270726576696f7573426c6f636b223a2233663432396262663938383733346465366665373335363766306165373238623830366236323037353266373330613764316237643334653432646662363333222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31783430767434777167797332716530786a7674366e617276646d3470776167346d77753730307764636d647935657467776a6a71326b356c6165227d
1302	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c227374616b654b657948617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832227d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313737333337227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2236613561643437353330353534663665386632613935386637373439373961333266633066353963323138363737396362386139353236383330663430633038227d2c7b22696e646578223a312c2274784964223a2236613561643437353330353534663665386632613935386637373439373961333266633066353963323138363737396362386139353236383330663430633038227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936343731323031227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31343539377d2c227769746864726177616c73223a5b5d7d2c226964223a2237323234343661633332656136363832366631653936366266376538363163376134326338366262353838626564353131616534656364636465303539366664222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c226432356530356561313234376138383437353865613462653030366661333039366366376131663234363737396537643463653430333733656563356561323333303261653961643961613962633135366261303133336539316361313264373734313839376530353964373434373363623536303030363233633039393062225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c223863393535633030356132323333643766383335663365613163373336663366353332643839636331643530343837666532613661393062386431653938353937343461373336303733313364333835643261313961386435626666613530653139663831366136333836633935653831656337653936653435373233373031225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313737333337227d2c22686561646572223a7b22626c6f636b4e6f223a313330322c2268617368223a2265653530313137393831326336316538393866336635626239363532633938316436633237303965646530653634346665303361626332376337616534323563222c22736c6f74223a31333136397d2c22697373756572566b223a2237653438323161353861386666386536643039653839333461366231353030336362623239393439353536323266396265393439366265333636653763663035222c2270726576696f7573426c6f636b223a2263666532366136366237633266393330383562613331633237346166323232653630336337343835333735623064323165636432643436383336393934303634222c2273697a65223a3439362c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939343731323031227d2c227478436f756e74223a312c22767266223a227672665f766b3138616538796167637538396c726b647a6364677265323064776d396837747677376461766d6b703675637066363878326a746c71776c70746668227d
1303	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313330332c2268617368223a2238336630623231363462353839643231366439313036636466633261323239323134353032633934333532613632663836656230383464323837653362363233222c22736c6f74223a31333139307d2c22697373756572566b223a2234333964633262336134633935353962313932396238396366313264366263346339636338373761306262363231386336323035346135616365343861353436222c2270726576696f7573426c6f636b223a2265653530313137393831326336316538393866336635626239363532633938316436633237303965646530653634346665303361626332376337616534323563222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317264366d7866776a6e30646776363736777963786d326673797763376572377778717471616d61646a6b6437396c6a3979393971683263327a6b227d
1304	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313330342c2268617368223a2264336162343361636636636537303236363036373134313564333364636433616233383736303331366462643932633030623734306535326564373330343930222c22736c6f74223a31333139327d2c22697373756572566b223a2237303862383337303231363235613933356264613935303133636136386364336639323563653837616262366138646664646235613266313336383730393432222c2270726576696f7573426c6f636b223a2238336630623231363462353839643231366439313036636466633261323239323134353032633934333532613632663836656230383464323837653362363233222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316433306a763738306b6b6e66726873796874346a336c7a6e7373336d63656174786e726c746b75733375737372356d6163797671783073366d6a227d
1305	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313330352c2268617368223a2238363866626266373139613234636161323761633061653839623966626430653333336436323230306563373935643333623963653838326336633231636164222c22736c6f74223a31333139337d2c22697373756572566b223a2237653438323161353861386666386536643039653839333461366231353030336362623239393439353536323266396265393439366265333636653763663035222c2270726576696f7573426c6f636b223a2264336162343361636636636537303236363036373134313564333364636433616233383736303331366462643932633030623734306535326564373330343930222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138616538796167637538396c726b647a6364677265323064776d396837747677376461766d6b703675637066363878326a746c71776c70746668227d
1306	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b226964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c22767266223a2236343164303432656433396332633235386433383130363063313432346634306566386162666532356566353636663463623232343737633432623261303134222c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223530303030303030227d2c22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c227265776172644163636f756e74223a227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576222c226f776e657273223a5b227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576225d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e32222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d7d7d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739373133227d2c22696e70757473223a5b7b22696e646578223a342c2274784964223a2233376664363536346663663836653963316139616234313338316162356235303139323835333132323039333732306661666466653931386434313334343836227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936383230323837227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31343633337d2c227769746864726177616c73223a5b5d7d2c226964223a2230663663343462366337643461646137333930366633336466393534663630633166323532613361353033363061306633316237383364626139353266316234222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c226432643464663766653931336339393963333534373939316537643065666437646564313137643733323435396264373263306634356365363364616363363561306566356638646466366261316162663761363332323835626536316436356663653764393237663430303433373339336665663432346335663336653062225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c226365643431653236333962313833316534333133663038306235656665656466326331646366303835386132623036656234393233386266316636366162646364633536636165393534373335386466343433623637656262333965386537356662343132626364666466303937613265636161303238663438353266383033225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739373133227d2c22686561646572223a7b22626c6f636b4e6f223a313330362c2268617368223a2233336530323762633532376262356332656464343561653630653235666331623137333639343864343031363030663436373061303532316634323266393032222c22736c6f74223a31333230327d2c22697373756572566b223a2234323135623733303636633436363035356166363038663934616533316365316564626537383938313035396638366263663437646338656637313030643864222c2270726576696f7573426c6f636b223a2238363866626266373139613234636161323761633061653839623966626430653333336436323230306563373935643333623963653838326336633231636164222c2273697a65223a3535302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383230323837227d2c227478436f756e74223a312c22767266223a227672665f766b31653864307667636b747179307079776b79633234393870326835376c68357a6133346865366d38747461706d7968727075676b7177716836736c227d
1307	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313330372c2268617368223a2263336630616638336535363061666663626262663836353333353033333837333332356161616130643331333038663032373966373937386636393332363533222c22736c6f74223a31333230397d2c22697373756572566b223a2234333964633262336134633935353962313932396238396366313264366263346339636338373761306262363231386336323035346135616365343861353436222c2270726576696f7573426c6f636b223a2233336530323762633532376262356332656464343561653630653235666331623137333639343864343031363030663436373061303532316634323266393032222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317264366d7866776a6e30646776363736777963786d326673797763376572377778717471616d61646a6b6437396c6a3979393971683263327a6b227d
1308	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313330382c2268617368223a2233323438313264386336333433306565366531363430343865616535346538376264623339333965396536373731313562333031366161343262303137353165222c22736c6f74223a31333231377d2c22697373756572566b223a2234333964633262336134633935353962313932396238396366313264366263346339636338373761306262363231386336323035346135616365343861353436222c2270726576696f7573426c6f636b223a2263336630616638336535363061666663626262663836353333353033333837333332356161616130643331333038663032373966373937386636393332363533222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317264366d7866776a6e30646776363736777963786d326673797763376572377778717471616d61646a6b6437396c6a3979393971683263327a6b227d
1309	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313330392c2268617368223a2264393661393132376430313937343432363465373163333963663137616637353565613335303132303139636331633232303334666232316361373136626138222c22736c6f74223a31333232377d2c22697373756572566b223a2237653438323161353861386666386536643039653839333461366231353030336362623239393439353536323266396265393439366265333636653763663035222c2270726576696f7573426c6f636b223a2233323438313264386336333433306565366531363430343865616535346538376264623339333965396536373731313562333031366161343262303137353165222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138616538796167637538396c726b647a6364677265323064776d396837747677376461766d6b703675637066363878326a746c71776c70746668227d
1310	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b654b6579526567697374726174696f6e4365727469666963617465222c227374616b654b657948617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732227d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313733353533227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2266653136383033366134396430663035333031303532646638643863613939333938356430373434353565346636353436363733333465623334393432353836227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223934653035356334383035616262316663313564333261313765336236633936623232393665306436386163366136393736356439663864222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b2239346530353563343830356162623166633135643332613137653362366339366232323936653064363861633661363937363564396638643734343235343433222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b2239346530353563343830356162623166633135643332613137653362366339366232323936653064363861633661363937363564396638643734343535343438222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b2239346530353563343830356162623166633135643332613137653362366339366232323936653064363861633661363937363564396638643734346434393465222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383236343437227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31343636377d2c227769746864726177616c73223a5b5d7d2c226964223a2231663339323535653261383764626237323961616136666466386263356535383262646465343830616535646138653261396364663661366664306638666132222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c226436386163613138386533303435663936666362626538656430346630376563646163313235643436393862323935333437343831303936616162646430636632653165313363396264393363636134363461376465366463336234336663653436623966323534333630383636363731323738383436623036396261623030225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313733353533227d2c22686561646572223a7b22626c6f636b4e6f223a313331302c2268617368223a2262646135306535373935663830323661346164373431373661396436613535376563373133633034646437313363613633393233613764666533353939353232222c22736c6f74223a31333234327d2c22697373756572566b223a2234333964633262336134633935353962313932396238396366313264366263346339636338373761306262363231386336323035346135616365343861353436222c2270726576696f7573426c6f636b223a2264393661393132376430313937343432363465373163333963663137616637353565613335303132303139636331633232303334666232316361373136626138222c2273697a65223a3431302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383236343437227d2c227478436f756e74223a312c22767266223a227672665f766b317264366d7866776a6e30646776363736777963786d326673797763376572377778717471616d61646a6b6437396c6a3979393971683263327a6b227d
1311	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313331312c2268617368223a2264633366356535633865313536306265303530333734643664363139383334363431363766613334633333393265613862313766363638383564313337653931222c22736c6f74223a31333234357d2c22697373756572566b223a2264343865333638336135336537653239306338326662616132643232366131333238386535313932666639326265383066643430386230366438353037643765222c2270726576696f7573426c6f636b223a2262646135306535373935663830323661346164373431373661396436613535376563373133633034646437313363613633393233613764666533353939353232222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173657a393339683335763374786b7664646d3738617230396d786e6c3672616c32633664787a74746432713437376a326834667132366a673866227d
1317	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313331372c2268617368223a2231373062316136366135363530393032643761633433613837333636303236636565653339666362363338623837666237306638303135336166313566383635222c22736c6f74223a31333238347d2c22697373756572566b223a2264343865333638336135336537653239306338326662616132643232366131333238386535313932666639326265383066643430386230366438353037643765222c2270726576696f7573426c6f636b223a2264373439626261333662366366646265386664343164343130646238303638376264616565346234376365383131303234326430333061656164313965366564222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173657a393339683335763374786b7664646d3738617230396d786e6c3672616c32633664787a74746432713437376a326834667132366a673866227d
\.


--
-- Data for Name: current_pool_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_pool_metrics (stake_pool_id, slot, minted_blocks, live_delegators, active_stake, live_stake, live_pledge, live_saturation, active_size, live_size, last_ros, ros) FROM stdin;
pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0	10127	86	2	3695459141818123	3695459141818123	300000000	4.493596923541744	1	0	5.081886414894434	4.619896740813122
pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s	10127	83	2	3721268395183711	3727662147590252	500000000	4.532755069285778	0.9982847822164693	0.0017152177835306759	46.748586469319314	42.498714972108466
pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr	10127	89	2	3720230576591116	3728547940225099	5229156165320	4.533832173620068	0.9977692753942489	0.002230724605751133	45.937129587741495	41.76102689794681
pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v	10127	101	2	3741474869477941	3745927433700536	6942705936164	4.554965254900873	0.9988113586551258	0.001188641344874175	47.4955781241479	43.17779829467991
pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d	10127	95	2	3693737434646566	3693737434646566	200368332	4.491503365541927	1	0	5.807870345634212	5.2798821323947385
pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm	10127	98	2	3740148608560173	3747153073818461	6359629050234	4.556455606289407	0.9981307234798523	0.001869276520147678	51.66428384679213	46.96753076981103
pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx	10127	117	3	3745055738156361	3757112416510907	8381768568376	4.568565947647762	0.9967909721568187	0.0032090278431813335	66.4848361038931	60.44076009444827
pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg	10127	103	2	3736144147355439	3741246463657613	6370459461206	4.549273298427578	0.9986361988305935	0.0013638011694064867	51.008616649443255	46.37146968131205
pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6	10127	109	8	3741434223705045	3746566427381492	6540661398244	4.555742257143007	0.9986301580991762	0.0013698419008237872	56.732698641727886	51.57518058338899
pool1824us75vkxrjmfr09hhggtnjn8xhny6h04tpgjzq4zaecz33l8r	10127	57	2	0	3697145496094470	300000000	4.495647493199637	0	1	18.149594338910223	18.149594338910223
pool1r3ku2tnxlnv0hdxw2py76puga9u5jr52rz8n984k52fvjjcy9rn	10127	63	2	0	3726961978969901	500000000	4.531903679664724	0	1	41.865385950365074	41.865385950365074
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
1	SP1	stake pool - 1	This is the stake pool 1 description.	https://stakepool1.com	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	\N	pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr	1030000000000
2	SP3	Stake Pool - 3	This is the stake pool 3 description.	https://stakepool3.com	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	\N	pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d	2770000000000
3	SP4	Same Name	This is the stake pool 4 description.	https://stakepool4.com	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	\N	pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm	3610000000000
4	SP5	Same Name	This is the stake pool 5 description.	https://stakepool5.com	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	\N	pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx	4500000000000
5	SP6a7	Stake Pool - 6	This is the stake pool 6 description.	https://stakepool6.com	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	\N	pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg	5660000000000
6	SP6a7		This is the stake pool 7 description.	https://stakepool7.com	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	\N	pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6	6420000000000
7	SP10	Stake Pool - 10	This is the stake pool 10 description.	https://stakepool10.com	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	\N	pool1r3ku2tnxlnv0hdxw2py76puga9u5jr52rz8n984k52fvjjcy9rn	9710000000000
8	SP11	Stake Pool - 10 + 1	This is the stake pool 11 description.	https://stakepool11.com	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	\N	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s	10710000000000
\.


--
-- Data for Name: pool_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_registration (id, reward_account, pledge, cost, margin, margin_percent, relays, owners, vrf, metadata_url, metadata_hash, block_slot, stake_pool_id) FROM stdin;
1030000000000	stake_test1up3zkf97u33et3ru2edywrv2n2kzvj0wyn7ajzwm5x034ds5e8u0f	400000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3001, "__typename": "RelayByAddress"}]	["stake_test1up3zkf97u33et3ru2edywrv2n2kzvj0wyn7ajzwm5x034ds5e8u0f"]	3b87cc973c75b05cb100d40d0722f8c4825c6393288138714ab15afdc9b2f479	http://file-server/SP1.json	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	103	pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr
1940000000000	stake_test1uzfxh7uw2e3wj0fkwgs599trftesxcvgtywxkvnv7rxsm5ga9nsw9	500000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3002, "__typename": "RelayByAddress"}]	["stake_test1uzfxh7uw2e3wj0fkwgs599trftesxcvgtywxkvnv7rxsm5ga9nsw9"]	128fcece38173d2e053f9016bd7327a18733af5c036d78ccf06c1766617a2359	\N	\N	194	pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v
2770000000000	stake_test1uzauw6cxp8tcq2hz6vlr7xsas40ygssky7hw2raecrwjs0qrs4k69	600000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3003, "__typename": "RelayByAddress"}]	["stake_test1uzauw6cxp8tcq2hz6vlr7xsas40ygssky7hw2raecrwjs0qrs4k69"]	11e9d71d390e0a9191585951b0ae68cca33656eaa7771a695ccdc76a2916da34	http://file-server/SP3.json	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	277	pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d
3610000000000	stake_test1uqy209u5d7pl0uemvh5lue6kft5qmnqetkl5gl49kt283ngrn5t2a	420000000	370000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3004, "__typename": "RelayByAddress"}]	["stake_test1uqy209u5d7pl0uemvh5lue6kft5qmnqetkl5gl49kt283ngrn5t2a"]	4992b9010caab7f9b83fe06806226697ec7e3483624d201a4b891e7d3837fadc	http://file-server/SP4.json	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	361	pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm
4500000000000	stake_test1uqxdtkglm05nq227jqd8wt8p4zla3gjztzngqtcpww7m0vs5zk3uj	410000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3005, "__typename": "RelayByAddress"}]	["stake_test1uqxdtkglm05nq227jqd8wt8p4zla3gjztzngqtcpww7m0vs5zk3uj"]	60104714e79fac1b2b479bdd24ec92b6996c2b48edf70e195eb6525e4bda8e7b	http://file-server/SP5.json	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	450	pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx
5660000000000	stake_test1upc3cq5lcynkra6yxqs0uajzq62t8muulhuv62l9utnqk5cpnpw25	410000000	400000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3006, "__typename": "RelayByAddress"}]	["stake_test1upc3cq5lcynkra6yxqs0uajzq62t8muulhuv62l9utnqk5cpnpw25"]	b32caccdc44f08b73c9b2a30ce7f8a32635540ab582bba5622c1558aa2bf60c8	http://file-server/SP6.json	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	566	pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg
6420000000000	stake_test1urv65snmuvu4w7ch8vv9eu7gnpj8kyjcak0mklpct77qa3s094ak0	410000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3007, "__typename": "RelayByAddress"}]	["stake_test1urv65snmuvu4w7ch8vv9eu7gnpj8kyjcak0mklpct77qa3s094ak0"]	bc744255ee850dc61dd3c356c5c0cd5efab0cd6e8b25c09c87ad0d094f1b08c9	http://file-server/SP7.json	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	642	pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6
7310000000000	stake_test1urvne5cz5ht9al4a4rktu9luywxeergpddyaqka908cum4g8rnctr	500000000	380000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3008, "__typename": "RelayByAddress"}]	["stake_test1urvne5cz5ht9al4a4rktu9luywxeergpddyaqka908cum4g8rnctr"]	d57752fae2a147a08a7458c1449dcc3b01061f87131fa4892bffeb0834972724	\N	\N	731	pool1824us75vkxrjmfr09hhggtnjn8xhny6h04tpgjzq4zaecz33l8r
8280000000000	stake_test1urmgyhawfyxt35l66kdzpjcv72jpguhrvdyqzgqdutdz89cv7scn4	500000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3009, "__typename": "RelayByAddress"}]	["stake_test1urmgyhawfyxt35l66kdzpjcv72jpguhrvdyqzgqdutdz89cv7scn4"]	6dfd4d1a6607eb7a59211e85cc0d5c1f35b565862822e2057db3319324199578	\N	\N	828	pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0
9710000000000	stake_test1uzuexe33e7np2wxm6ns45un5y4hsn74y6nrwffztgyvuc9cvsh0wt	400000000	410000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 30010, "__typename": "RelayByAddress"}]	["stake_test1uzuexe33e7np2wxm6ns45un5y4hsn74y6nrwffztgyvuc9cvsh0wt"]	04f5e85039055bccf8150f3f7e132040c8963f471ab2e0b4eb8529ecdc3113a0	http://file-server/SP10.json	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	971	pool1r3ku2tnxlnv0hdxw2py76puga9u5jr52rz8n984k52fvjjcy9rn
10710000000000	stake_test1uq9een9yfza82ph55e8yrwclkaxzhfpcm97ej8vj9rccccqvap48q	400000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 30011, "__typename": "RelayByAddress"}]	["stake_test1uq9een9yfza82ph55e8yrwclkaxzhfpcm97ej8vj9rccccqvap48q"]	afbda61a70526702f2ff8ed34c4184386a657b05b101f4c4e0239077c78aa6a0	http://file-server/SP11.json	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	1071	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s
131220000000000	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	500000000000000	1000	{"numerator": 1, "denominator": 5}	0.200000003	[{"ipv4": "127.0.0.1", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys"]	2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	\N	\N	13122	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
132020000000000	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	50000000	1000	{"numerator": 1, "denominator": 5}	0.200000003	[{"ipv4": "127.0.0.2", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v"]	641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	\N	\N	13202	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_retirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retirement (id, retire_at_epoch, block_slot, stake_pool_id) FROM stdin;
7530000000000	5	753	pool1824us75vkxrjmfr09hhggtnjn8xhny6h04tpgjzq4zaecz33l8r
8610000000000	18	861	pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0
10040000000000	5	1004	pool1r3ku2tnxlnv0hdxw2py76puga9u5jr52rz8n984k52fvjjcy9rn
10930000000000	18	1093	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s
\.


--
-- Data for Name: pool_rewards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_rewards (id, stake_pool_id, epoch_length, epoch_no, delegators, pledge, active_stake, member_active_stake, leader_rewards, member_rewards, rewards, version) FROM stdin;
1	pool1824us75vkxrjmfr09hhggtnjn8xhny6h04tpgjzq4zaecz33l8r	1000000	1	0	500000000	0	0	0	6851176875863	6851176875863	1
2	pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0	1000000	1	0	500000000	0	0	0	7707573985346	7707573985346	1
3	pool1r3ku2tnxlnv0hdxw2py76puga9u5jr52rz8n984k52fvjjcy9rn	1000000	1	0	400000000	0	0	0	9420368204312	9420368204312	1
4	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s	1000000	1	0	400000000	0	0	0	2569191328448	2569191328448	1
5	pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr	1000000	1	0	400000000	0	0	0	5994779766380	5994779766380	1
6	pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v	1000000	1	0	500000000	0	0	0	10276765313795	10276765313795	1
7	pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d	1000000	1	0	600000000	0	0	0	5138382656897	5138382656897	1
8	pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm	1000000	1	0	420000000	0	0	0	12845956642244	12845956642244	1
9	pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx	1000000	1	0	410000000	0	0	0	8563971094829	8563971094829	1
10	pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg	1000000	1	0	410000000	0	0	0	9420368204312	9420368204312	1
11	pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6	1000000	1	0	410000000	0	0	0	9420368204312	9420368204312	1
12	pool1824us75vkxrjmfr09hhggtnjn8xhny6h04tpgjzq4zaecz33l8r	1000000	2	2	500000000	3681818481265842	3681818181265842	0	8475837952765	8475837952765	1
13	pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0	1000000	2	2	500000000	3681818481265842	3681818181265842	0	5933086566935	5933086566935	1
14	pool1r3ku2tnxlnv0hdxw2py76puga9u5jr52rz8n984k52fvjjcy9rn	1000000	2	2	400000000	3681818681263026	3681818181263026	0	8475837492355	8475837492355	1
15	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s	1000000	2	1	400000000	3681818181818190	3681818181818190	0	7628254777906	7628254777906	1
16	pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr	1000000	2	2	400000000	3681818681443619	3681818181443619	0	5933086244357	5933086244357	1
17	pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v	1000000	2	2	500000000	3681818781446391	3681818181446391	0	7628253535553	7628253535553	1
18	pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d	1000000	2	2	600000000	3681818381443619	3681818181443619	0	6780670546050	6780670546050	1
19	pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm	1000000	2	2	420000000	3681818681443619	3681818181443619	0	10171004990328	10171004990328	1
20	pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx	1000000	2	2	410000000	3681818681443619	3681818181443619	0	8475837491940	8475837491940	1
21	pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg	1000000	2	2	410000000	3681818681443619	3681818181443619	0	7628253742746	7628253742746	1
22	pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6	1000000	2	2	410000000	3681818681443619	3681818181443619	0	9323421241134	9323421241134	1
23	pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0	1000000	3	2	500000000	3681818481265842	3681818181265842	0	0	0	1
24	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s	1000000	3	2	400000000	3681818681263035	3681818181263035	0	4034910379741	4034910379741	1
25	pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr	1000000	3	2	400000000	3681818681443619	3681818181443619	726615927182	4115276528270	4841892455452	1
26	pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v	1000000	3	2	500000000	3681818781446391	3681818181446391	968710858989	5487145572931	6455856431920	1
27	pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d	1000000	3	2	600000000	3681818381443619	3681818181443619	0	0	0	1
28	pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm	1000000	3	2	420000000	3681818681443619	3681818181443619	968693736260	5487162871009	6455856607269	1
29	pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx	1000000	3	2	410000000	3681818681443619	3681818181443619	1210805545334	6859015213753	8069820759087	1
30	pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg	1000000	3	2	410000000	3681818681443619	3681818181443619	1331861449871	7544941385125	8876802834996	1
31	pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6	1000000	3	2	410000000	3681818681443619	3681818181443619	1452900354410	8230884556495	9683784910905	1
32	pool1824us75vkxrjmfr09hhggtnjn8xhny6h04tpgjzq4zaecz33l8r	1000000	3	2	500000000	3681818481265842	3681818181265842	0	0	0	1
33	pool1r3ku2tnxlnv0hdxw2py76puga9u5jr52rz8n984k52fvjjcy9rn	1000000	3	2	400000000	3681818681263026	3681818181263026	1331869949935	7544932885496	8876802835431	1
34	pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0	1000000	4	2	500000000	3689526055251188	3689525755251188	0	0	0	1
35	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s	1000000	4	2	400000000	3684387872591483	3684387372591483	1001633881797	5673710197075	6675344078872	1
36	pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr	1000000	4	2	400000000	3687813461209999	3687812961209999	500517638520	2834054056641	3334571695161	1
37	pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v	1000000	4	2	500000000	3692095546760186	3692094946760186	1998755899331	11324061161108	13322817060439	1
38	pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d	1000000	4	2	600000000	3686956764100516	3686956564100516	0	0	0	1
39	pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm	1000000	4	2	420000000	3694664638085863	3694664138085863	874017086714	4950662358218	5824679444932	1
40	pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx	1000000	4	2	410000000	3690382652538448	3690382152538448	875047852782	4956390022250	5831437875032	1
41	pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg	1000000	4	2	410000000	3691239049647931	3691238549647931	1124714386106	6371109101242	7495823487348	1
42	pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6	1000000	4	2	410000000	3691239049647931	3691238549647931	1624427835509	9202872757328	10827300592837	1
43	pool1824us75vkxrjmfr09hhggtnjn8xhny6h04tpgjzq4zaecz33l8r	1000000	4	2	500000000	3688669658141705	3688669358141705	0	0	0	1
44	pool1r3ku2tnxlnv0hdxw2py76puga9u5jr52rz8n984k52fvjjcy9rn	1000000	4	2	400000000	3691239049467338	3691238549467338	625000936734	3539345445329	4164346382063	1
45	pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0	1000000	5	2	500000000	3695459141818123	3695458841334687	0	0	0	1
46	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s	1000000	5	2	400000000	3692016127369389	3692015627369389	1107904816444	6275911626983	7383816443427	1
47	pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr	1000000	5	2	400000000	3693746547454356	3693746046648629	861373849486	4878904070478	5740277919964	1
48	pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v	1000000	5	2	500000000	3699723800295739	3699723199052617	1474019589477	8350558626692	9824578216169	1
49	pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d	1000000	5	2	600000000	3693737434646566	3693737234278234	0	0	0	1
50	pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm	1000000	5	2	420000000	3704835643076191	3704835141694944	1226693252981	6949158830623	8175852083604	1
51	pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx	1000000	5	2	410000000	3698858490030388	3698857988879349	1720036221113	9744653117746	11464689338859	1
52	pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg	1000000	5	2	410000000	3698867303390677	3698866802354742	614518793982	3480003356635	4094522150617	1
53	pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6	1000000	5	2	410000000	3700562470889065	3700561969622922	368669969180	2086917940776	2455587909956	1
54	pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0	1000000	6	2	500000000	3695459141818123	3695458841334687	0	0	0	1
55	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s	1000000	6	2	400000000	3696051037749130	3696050537201180	699720165675	3962867360944	4662587526619	1
56	pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr	1000000	6	2	400000000	3698588439909808	3697861323176899	1399705273585	7919072279712	9318777553297	1
57	pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v	1000000	6	2	500000000	3706179656727659	3705210344625548	1048097120129	5926670590500	6974767710629	1
58	pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d	1000000	6	2	600000000	3693737434646566	3693737234278234	0	0	0	1
59	pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm	1000000	6	2	420000000	3711291499683460	3710322304565953	1162892440507	6576175153540	7739067594047	1
60	pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx	1000000	6	2	410000000	3706928310789475	3705717004093102	1281147844377	7241846588245	8522994432622	1
61	pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg	1000000	6	2	410000000	3707744106225673	3706411743739867	1164676785995	6581795180351	7746471966346	1
62	pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6	1000000	6	3	410000000	3710246255799970	3708792854179417	1164096128522	6577151701690	7741247830212	1
63	pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0	1000000	7	2	500000000	3695459141818123	3695458841334687	0	0	0	1
64	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s	1000000	7	2	400000000	3702726381828002	3701724247398255	976167136684	5519442248979	6495609385663	1
65	pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr	1000000	7	2	400000000	3701923011604969	3700695377233540	488523499102	2759986013784	3248509512886	1
66	pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v	1000000	7	2	500000000	3719502473788098	3716534405786656	779797467308	4393252295737	5173049763045	1
67	pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d	1000000	7	2	600000000	3693737434646566	3693737234278234	0	0	0	1
68	pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm	1000000	7	2	420000000	3717116179128392	3715272966924171	1070940772242	6046568981888	7117509754130	1
69	pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx	1000000	7	2	410000000	3712759748664507	3710673394115352	1852456239545	10455849480828	12308305720373	1
70	pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg	1000000	7	2	410000000	3715239929713021	3712782852841109	1364918178511	7698305346944	9063223525455	1
71	pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6	1000000	7	8	410000000	3726073477937235	3722995648481173	778545976733	4385381010913	5163926987646	1
72	pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0	1000000	8	2	500000000	3695459141818123	3695458841334687	0	0	0	1
73	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s	1000000	8	2	400000000	3710110198271429	3708000159025238	962485026255	5431267380286	6393752406541	1
74	pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr	1000000	8	2	400000000	3707663289524933	3705574281304018	1251919171718	7065444462265	8317363633983	1
75	pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v	1000000	8	2	500000000	3729327052004267	3724884964413348	672723757808	3779840464787	4452564222595	1
76	pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d	1000000	8	2	600000000	3693737434646566	3693737234278234	0	0	0	1
77	pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm	1000000	8	2	420000000	3725292031211996	3722222125754794	1055890380283	5948574878005	7004465258288	1
78	pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx	1000000	8	2	410000000	3724224438003366	3720418047233098	1441773714186	8112507883346	9554281597532	1
79	pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg	1000000	8	2	410000000	3719334451863638	3716262856197744	769268830806	4333047471368	5102316302174	1
80	pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6	1000000	8	8	410000000	3728529065847191	3725082566421949	1151519867747	6483080991668	7634600859415	1
81	pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0	1000000	9	2	500000000	3695459141818123	3695458841334687	0	0	0	1
82	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s	1000000	9	2	400000000	3714772785798048	3711963026386182	854069628342	4813228831946	5667298460288	1
83	pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr	1000000	9	2	400000000	3716982067078230	3713493353583730	1328943904738	7481613810302	8810557715040	1
84	pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v	1000000	9	2	500000000	3736301819714896	3730811635003848	663179765650	3719320177871	4382499943521	1
85	pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d	1000000	9	2	600000000	3693737434646566	3693737234278234	0	0	0	1
86	pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm	1000000	9	2	420000000	3733031098806043	3728798300908334	567895705563	3191824038178	3759719743741	1
87	pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx	1000000	9	2	410000000	3732747432435988	3727659893821343	663413987780	3723259048705	4386673036485	1
88	pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg	1000000	9	2	410000000	3727080923829984	3722844651378095	1137332548791	6394111502475	7531444051266	1
89	pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6	1000000	9	8	410000000	3736270296717399	3731659701163635	1513422333633	8503804909276	10017227242909	1
90	pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0	1000000	10	2	500000000	3695459141818123	3695458841334687	0	0	0	1
91	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s	1000000	10	2	400000000	3721268395183711	3717482468635161	1216264560233	6843492568717	8059757128950	1
92	pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr	1000000	10	2	400000000	3720230576591116	3716253339597514	749024648736	4212209522821	4961234171557	1
93	pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v	1000000	10	2	500000000	3741474869477941	3735204887299585	187077551548	1046188453604	1233266005152	1
94	pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d	1000000	10	2	600000000	3693737434646566	3693737234278234	0	0	0	1
95	pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm	1000000	10	2	420000000	3740148608560173	3734844869890222	1212840559586	6806231037776	8019071597362	1
96	pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx	1000000	10	2	410000000	3745055738156361	3738115743302171	1961245082587	10975666388677	12936911471264	1
97	pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg	1000000	10	2	410000000	3736144147355439	3730542956725039	1214719225034	6812947346141	8027666571175	1
98	pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6	1000000	10	8	410000000	3741434223705045	3736045082174548	1119342170839	6280334246983	7399676417822	1
99	pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0	1000000	11	2	500000000	3695459141818123	3695458841334687	0	0	0	1
100	pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s	1000000	11	2	400000000	3727662147590252	3722913736015447	829106839269	4656467964896	5485574804165	1
101	pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr	1000000	11	2	400000000	3728547940225099	3723318784059779	1198033328651	6723692307057	7921725635708	1
102	pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v	1000000	11	2	500000000	3745927433700536	3738984727764372	735818730882	4116471874120	4852290605002	1
103	pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d	1000000	11	2	600000000	3693737434646566	3693737234278234	0	0	0	1
104	pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm	1000000	11	2	420000000	3747153073818461	3740793444768227	826742568853	4630298857646	5457041426499	1
105	pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx	1000000	11	3	410000000	3757112416510907	3748730647942531	1378175737724	7692784123808	9070959861532	1
106	pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg	1000000	11	2	410000000	3741246463657613	3734876004196407	552178921119	3091592346718	3643771267837	1
107	pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6	1000000	11	8	410000000	3746566427381492	3740025765983248	1010843970882	5659917688646	6670761659528	1
\.


--
-- Data for Name: stake_pool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_pool (id, status, last_registration_id, last_retirement_id) FROM stdin;
pool12ytx9ptczmrhka2rusur7ffczcp3u02rfedz3tae6erjz3jqem0	retiring	8280000000000	8610000000000
pool14yprekqn6ca6s50xdq6jqkhp5gn7u7pdl5448nqr2whpk6u8v7s	retiring	10710000000000	10930000000000
pool1xkggc7huvtstkk8yzn2xlkt0m5552wc0srx7fhcgmyyfkwjtfqr	active	1030000000000	\N
pool15jyplpy0v5wrenk0d9qg67a05p7nvrt3a5wmj7qmmrnqsqwgm8v	active	1940000000000	\N
pool1jgwzp9fss0yry2l0a9hun35h4e7rx090jz7yd667l0pzg4px20d	active	2770000000000	\N
pool1ann7gar5wzmxcv5jxas7kaqztlramw7m8kkw99rnph5h2q29hpm	active	3610000000000	\N
pool10zjwewdasf7fvc8wmtlsqyeqtup4u97ac5kespp2pzdmvlzccxx	active	4500000000000	\N
pool1zrkr7pnx6ujfs77hhjswdglrx7wa33ew0eflscqtvwpsj9wfvvg	active	5660000000000	\N
pool1r52mtrkk7kwjd5ytyz4xxkeu5qmkny6t335arkq65m0x62hvsw6	active	6420000000000	\N
pool1824us75vkxrjmfr09hhggtnjn8xhny6h04tpgjzq4zaecz33l8r	retired	7310000000000	7530000000000
pool1r3ku2tnxlnv0hdxw2py76puga9u5jr52rz8n984k52fvjjcy9rn	retired	9710000000000	10040000000000
pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	activating	131220000000000	\N
pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	activating	132020000000000	\N
\.


--
-- Name: pool_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_metadata_id_seq', 8, true);


--
-- Name: pool_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_rewards_id_seq', 107, true);


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

