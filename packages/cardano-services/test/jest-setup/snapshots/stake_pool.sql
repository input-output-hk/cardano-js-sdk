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
45810a14-845b-4f2f-ade2-7085be880136	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:07:01.485568+00	2023-12-05 18:07:02.503323+00	\N	2023-12-05 18:07:00	00:15:00	2023-12-05 18:06:02.485568+00	2023-12-05 18:07:02.512316+00	2023-12-05 18:08:01.485568+00	f	\N	\N
b660925c-59d5-4f10-90f7-79526d1dde0d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 17:57:30.78749+00	2023-12-05 17:57:30.792427+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 17:57:30.78749+00	2023-12-05 17:57:30.803557+00	2023-12-05 18:05:30.78749+00	f	\N	\N
bef275a1-92e2-4bac-942a-250e99ebd128	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:25:01.919644+00	2023-12-05 18:25:02.93865+00	\N	2023-12-05 18:25:00	00:15:00	2023-12-05 18:24:02.919644+00	2023-12-05 18:25:02.949732+00	2023-12-05 18:26:01.919644+00	f	\N	\N
1e80ba4c-bb6d-4815-9569-ba80515f3f90	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:33:01.133897+00	2023-12-05 18:33:03.149281+00	\N	2023-12-05 18:33:00	00:15:00	2023-12-05 18:32:03.133897+00	2023-12-05 18:33:03.161063+00	2023-12-05 18:34:01.133897+00	f	\N	\N
09125aba-0e70-4818-8fbb-2a5ad1d0d5fe	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:12:01.603927+00	2023-12-05 18:12:02.623423+00	\N	2023-12-05 18:12:00	00:15:00	2023-12-05 18:11:02.603927+00	2023-12-05 18:12:02.631122+00	2023-12-05 18:13:01.603927+00	f	\N	\N
51fd8d4c-6abd-4c2c-80b7-29d6536a28f4	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:16:01.707434+00	2023-12-05 18:16:02.718988+00	\N	2023-12-05 18:16:00	00:15:00	2023-12-05 18:15:02.707434+00	2023-12-05 18:16:02.727134+00	2023-12-05 18:17:01.707434+00	f	\N	\N
610a0985-eccb-4e92-a071-7e045ca63305	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:09:01.532771+00	2023-12-05 18:09:02.549107+00	\N	2023-12-05 18:09:00	00:15:00	2023-12-05 18:08:02.532771+00	2023-12-05 18:09:02.555533+00	2023-12-05 18:10:01.532771+00	f	\N	\N
eb8b3a1b-a945-481f-8ee0-52b0aafcd7b9	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:26:01.946413+00	2023-12-05 18:26:02.965988+00	\N	2023-12-05 18:26:00	00:15:00	2023-12-05 18:25:02.946413+00	2023-12-05 18:26:03.010489+00	2023-12-05 18:27:01.946413+00	f	\N	\N
a3f6ddca-a9dd-444c-ba13-d09722d28d75	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:10:01.55385+00	2023-12-05 18:10:02.572835+00	\N	2023-12-05 18:10:00	00:15:00	2023-12-05 18:09:02.55385+00	2023-12-05 18:10:02.58023+00	2023-12-05 18:11:01.55385+00	f	\N	\N
9532f399-81a0-4003-bd50-a2ccc4d5684b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 18:15:06.268068+00	2023-12-05 18:16:06.261996+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 18:13:06.268068+00	2023-12-05 18:16:06.269815+00	2023-12-05 18:23:06.268068+00	f	\N	\N
55c6702d-1627-4d54-8892-a08c35dd9053	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 18:09:06.262898+00	2023-12-05 18:10:06.255073+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 18:07:06.262898+00	2023-12-05 18:10:06.261761+00	2023-12-05 18:17:06.262898+00	f	\N	\N
bd9982cd-0eaa-4f93-b43e-296626d85400	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:30:01.0602+00	2023-12-05 18:30:03.071285+00	\N	2023-12-05 18:30:00	00:15:00	2023-12-05 18:29:03.0602+00	2023-12-05 18:30:03.091107+00	2023-12-05 18:31:01.0602+00	f	\N	\N
16d9e9b6-3674-4de7-9a4b-c0373ac09b2d	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:23:01.876666+00	2023-12-05 18:23:02.893307+00	\N	2023-12-05 18:23:00	00:15:00	2023-12-05 18:22:02.876666+00	2023-12-05 18:23:02.906645+00	2023-12-05 18:24:01.876666+00	f	\N	\N
6285de98-69c6-48d0-a0da-99bb36fadcbc	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:36:01.20402+00	2023-12-05 18:36:03.216536+00	\N	2023-12-05 18:36:00	00:15:00	2023-12-05 18:35:03.20402+00	2023-12-05 18:36:03.234705+00	2023-12-05 18:37:01.20402+00	f	\N	\N
8a6db524-29c3-42f7-95b7-72c455434413	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:13:01.629409+00	2023-12-05 18:13:02.645089+00	\N	2023-12-05 18:13:00	00:15:00	2023-12-05 18:12:02.629409+00	2023-12-05 18:13:02.652106+00	2023-12-05 18:14:01.629409+00	f	\N	\N
8ebe7fc1-184e-4701-8d94-3a48bc234a1b	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:20:01.80257+00	2023-12-05 18:20:02.821056+00	\N	2023-12-05 18:20:00	00:15:00	2023-12-05 18:19:02.80257+00	2023-12-05 18:20:02.827629+00	2023-12-05 18:21:01.80257+00	f	\N	\N
3dc99069-8ab6-4363-aa0a-3e2623c4d321	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 17:58:06.238478+00	2023-12-05 17:58:06.251335+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 17:58:06.238478+00	2023-12-05 17:58:06.263436+00	2023-12-05 18:06:06.238478+00	f	\N	\N
ec689d41-2782-4cd3-ac07-16786ae713e1	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 17:57:30.797566+00	2023-12-05 17:58:06.256724+00	\N	2023-12-05 17:57:00	00:15:00	2023-12-05 17:57:30.797566+00	2023-12-05 17:58:06.26427+00	2023-12-05 17:58:30.797566+00	f	\N	\N
36f1538b-0b60-4747-8b78-d85b2ae63a19	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:24:01.904929+00	2023-12-05 18:24:02.915137+00	\N	2023-12-05 18:24:00	00:15:00	2023-12-05 18:23:02.904929+00	2023-12-05 18:24:02.921311+00	2023-12-05 18:25:01.904929+00	f	\N	\N
dc770af4-9576-4627-a09a-ea416a1a36d3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 18:12:06.263551+00	2023-12-05 18:13:06.258547+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 18:10:06.263551+00	2023-12-05 18:13:06.266274+00	2023-12-05 18:20:06.263551+00	f	\N	\N
fc9e9280-d084-4d32-9d70-77fdbc8305fa	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:31:01.085146+00	2023-12-05 18:31:03.098905+00	\N	2023-12-05 18:31:00	00:15:00	2023-12-05 18:30:03.085146+00	2023-12-05 18:31:03.120727+00	2023-12-05 18:32:01.085146+00	f	\N	\N
c7d30eb2-b0d9-4f5b-80c2-169032623250	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:17:01.725509+00	2023-12-05 18:17:02.746341+00	\N	2023-12-05 18:17:00	00:15:00	2023-12-05 18:16:02.725509+00	2023-12-05 18:17:02.752606+00	2023-12-05 18:18:01.725509+00	f	\N	\N
a25646d6-0ecf-4b94-a294-b5d49760559b	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:35:01.180276+00	2023-12-05 18:35:03.195799+00	\N	2023-12-05 18:35:00	00:15:00	2023-12-05 18:34:03.180276+00	2023-12-05 18:35:03.208376+00	2023-12-05 18:36:01.180276+00	f	\N	\N
27b2a56c-26b2-415e-9300-3c007f2cc871	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:37:01.231188+00	2023-12-05 18:37:03.243115+00	\N	2023-12-05 18:37:00	00:15:00	2023-12-05 18:36:03.231188+00	2023-12-05 18:37:03.256011+00	2023-12-05 18:38:01.231188+00	f	\N	\N
9ad1e124-e4ba-4fb7-a540-6d920e356743	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:21:01.82556+00	2023-12-05 18:21:02.849569+00	\N	2023-12-05 18:21:00	00:15:00	2023-12-05 18:20:02.82556+00	2023-12-05 18:21:02.85786+00	2023-12-05 18:22:01.82556+00	f	\N	\N
6c729557-da12-4f18-b4e4-91d578af14ea	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:18:01.750939+00	2023-12-05 18:18:02.768811+00	\N	2023-12-05 18:18:00	00:15:00	2023-12-05 18:17:02.750939+00	2023-12-05 18:18:02.776409+00	2023-12-05 18:19:01.750939+00	f	\N	\N
86a69f5a-2ede-4314-9ce2-3340c152ff77	pool-metadata	0	{"poolId": "pool1p2r5c3xt03t5achwd7cj7ghwzsl4ejqhhj0gq6errgm85apv3x9", "metadataJson": {"url": "http://file-server/SP3.json", "hash": "6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25"}, "poolRegistrationId": "4050000000000"}	completed	1000000	0	21600	f	2023-12-05 17:57:31.041156+00	2023-12-05 17:58:06.267748+00	\N	\N	00:15:00	2023-12-05 17:57:31.041156+00	2023-12-05 17:58:06.32978+00	2023-12-19 17:57:31.041156+00	f	\N	405
6d4f5e81-0692-4fe7-af1d-09504cbf04d4	pool-metadata	0	{"poolId": "pool1hchl83q80arjn4hcks8egft429dffnpd8405ecuvm45azjje5ae", "metadataJson": {"url": "http://file-server/SP4.json", "hash": "09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d"}, "poolRegistrationId": "4770000000000"}	completed	1000000	0	21600	f	2023-12-05 17:57:31.082984+00	2023-12-05 17:58:06.267748+00	\N	\N	00:15:00	2023-12-05 17:57:31.082984+00	2023-12-05 17:58:06.330274+00	2023-12-19 17:57:31.082984+00	f	\N	477
d4c448b0-7246-472c-b77b-41ba1afacfd9	pool-metadata	0	{"poolId": "pool124acjdvffn06wqfxc2lansvm8xyad8ga4fd2d8jp773jg28pu3g", "metadataJson": {"url": "http://file-server/SP1.json", "hash": "14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7"}, "poolRegistrationId": "2500000000000"}	completed	1000000	0	21600	f	2023-12-05 17:57:30.955751+00	2023-12-05 17:58:06.267748+00	\N	\N	00:15:00	2023-12-05 17:57:30.955751+00	2023-12-05 17:58:06.330863+00	2023-12-19 17:57:30.955751+00	f	\N	250
0baf25a5-fea6-479b-a6ce-6004e8bb1a40	pool-metadata	0	{"poolId": "pool1053yndnhk5nd7lp6eqfcwtktztwdfpd9n6xmmzckr5hzuqnq2r5", "metadataJson": {"url": "http://file-server/SP5.json", "hash": "0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501"}, "poolRegistrationId": "5650000000000"}	completed	1000000	0	21600	f	2023-12-05 17:57:31.115893+00	2023-12-05 17:58:06.267748+00	\N	\N	00:15:00	2023-12-05 17:57:31.115893+00	2023-12-05 17:58:06.337461+00	2023-12-19 17:57:31.115893+00	f	\N	565
b6de52fe-a41e-45ab-8a6d-70fc74cf51e3	pool-metadata	0	{"poolId": "pool1g8xc4xh2c7zkej9gwuh6s2nquxrrghvyyf25z62nxha0snlyz7u", "metadataJson": {"url": "http://file-server/SP7.json", "hash": "c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405"}, "poolRegistrationId": "7270000000000"}	completed	1000000	0	21600	f	2023-12-05 17:57:31.176667+00	2023-12-05 17:58:06.267748+00	\N	\N	00:15:00	2023-12-05 17:57:31.176667+00	2023-12-05 17:58:06.342618+00	2023-12-19 17:57:31.176667+00	f	\N	727
e9609617-e4bc-4ad9-b69a-dacbf09e0396	pool-metadata	0	{"poolId": "pool14fqrqspdrmz58ehsucqckyqqdu7g5q5vn6phrxga9fnvs7d9l8j", "metadataJson": {"url": "http://file-server/SP6.json", "hash": "3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba"}, "poolRegistrationId": "6460000000000"}	completed	1000000	0	21600	f	2023-12-05 17:57:31.146519+00	2023-12-05 17:58:06.267748+00	\N	\N	00:15:00	2023-12-05 17:57:31.146519+00	2023-12-05 17:58:06.34211+00	2023-12-19 17:57:31.146519+00	f	\N	646
48b13999-51c2-4630-960b-295a9678cd09	pool-rewards	0	{"epochNo": 0}	completed	1000000	0	30	f	2023-12-05 17:57:31.638238+00	2023-12-05 17:58:06.282022+00	0	\N	00:15:00	2023-12-05 17:57:31.638238+00	2023-12-05 17:58:06.423244+00	2023-12-19 17:57:31.638238+00	f	\N	2031
337f1047-4b83-4864-95e1-a580ef769bf9	pool-metrics	0	{"slot": 3090}	completed	0	0	0	f	2023-12-05 17:57:32.025719+00	2023-12-05 17:58:06.282265+00	\N	\N	00:15:00	2023-12-05 17:57:32.025719+00	2023-12-05 17:58:06.576489+00	2023-12-19 17:57:32.025719+00	f	\N	3090
bb293dbb-f111-48ab-8e0e-ca73c2476e1c	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 17:58:06.260279+00	2023-12-05 17:58:10.258953+00	\N	2023-12-05 17:58:00	00:15:00	2023-12-05 17:58:06.260279+00	2023-12-05 17:58:10.274138+00	2023-12-05 17:59:06.260279+00	f	\N	\N
4f0d4828-8fbb-4597-a633-ccbcd1d55952	pool-rewards	0	{"epochNo": 1}	completed	1000000	1	30	f	2023-12-05 17:58:36.309546+00	2023-12-05 17:58:38.276266+00	1	\N	00:15:00	2023-12-05 17:57:31.995805+00	2023-12-05 17:58:38.485947+00	2023-12-19 17:57:31.995805+00	f	\N	3007
261f3edd-6615-4dc7-8a5a-8f5e73ffc324	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 18:00:06.268623+00	2023-12-05 18:01:06.252051+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 17:58:06.268623+00	2023-12-05 18:01:06.257913+00	2023-12-05 18:08:06.268623+00	f	\N	\N
16bd6af0-155c-4e32-8223-1974bbb5c7d2	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:15:01.672795+00	2023-12-05 18:15:02.694919+00	\N	2023-12-05 18:15:00	00:15:00	2023-12-05 18:14:02.672795+00	2023-12-05 18:15:02.709207+00	2023-12-05 18:16:01.672795+00	f	\N	\N
98b6eb6e-200a-44c9-a5d8-707c5d3a139a	__pgboss__cron	0	\N	created	2	0	0	f	2023-12-05 18:43:01.387851+00	\N	\N	2023-12-05 18:43:00	00:15:00	2023-12-05 18:42:03.387851+00	\N	2023-12-05 18:44:01.387851+00	f	\N	\N
c6b62ce3-b8d9-47da-95ef-2b80e6cbb758	pool-metadata	0	{"poolId": "pool13jwk36zmyaev3chtsg3yehmcun8aa3gdzfa42aqluf59jv8jk87", "metadataJson": {"url": "http://file-server/SP11.json", "hash": "4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9"}, "poolRegistrationId": "12470000000000"}	completed	1000000	0	21600	f	2023-12-05 17:57:31.402783+00	2023-12-05 17:58:06.267748+00	\N	\N	00:15:00	2023-12-05 17:57:31.402783+00	2023-12-05 17:58:06.334957+00	2023-12-19 17:57:31.402783+00	f	\N	1247
78016635-21d2-4c14-9d63-835a4ba9e3a6	pool-metadata	0	{"poolId": "pool1qqwnsfw98ycqj5gs24829d065pgmdchfugf9n66czfux5hph4kk", "metadataJson": {"url": "http://file-server/SP10.json", "hash": "c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd"}, "poolRegistrationId": "11160000000000"}	completed	1000000	0	21600	f	2023-12-05 17:57:31.343265+00	2023-12-05 17:58:06.267748+00	\N	\N	00:15:00	2023-12-05 17:57:31.343265+00	2023-12-05 17:58:06.34376+00	2023-12-19 17:57:31.343265+00	f	\N	1116
05afc5b0-f7e2-436b-925e-9862d577af7d	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:06:01.456982+00	2023-12-05 18:06:02.478457+00	\N	2023-12-05 18:06:00	00:15:00	2023-12-05 18:05:02.456982+00	2023-12-05 18:06:02.487703+00	2023-12-05 18:07:01.456982+00	f	\N	\N
51e8f5b7-cde6-43c0-bf73-35fe7e648d5c	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:22:01.856274+00	2023-12-05 18:22:02.871265+00	\N	2023-12-05 18:22:00	00:15:00	2023-12-05 18:21:02.856274+00	2023-12-05 18:22:02.878478+00	2023-12-05 18:23:01.856274+00	f	\N	\N
1d1d2d98-f80d-4133-aa7f-e72cac69b7a0	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 17:59:01.272143+00	2023-12-05 17:59:02.283616+00	\N	2023-12-05 17:59:00	00:15:00	2023-12-05 17:58:10.272143+00	2023-12-05 17:59:02.293363+00	2023-12-05 18:00:01.272143+00	f	\N	\N
d1561ce0-d8ec-4010-b3c7-1517424c3e40	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 18:21:06.272271+00	2023-12-05 18:22:06.266375+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 18:19:06.272271+00	2023-12-05 18:22:06.279055+00	2023-12-05 18:29:06.272271+00	f	\N	\N
5eb730b5-a787-40fc-9504-4f40e0a1023d	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:00:01.29129+00	2023-12-05 18:00:02.310444+00	\N	2023-12-05 18:00:00	00:15:00	2023-12-05 17:59:02.29129+00	2023-12-05 18:00:02.318765+00	2023-12-05 18:01:01.29129+00	f	\N	\N
46c474b1-3450-49f1-ae5f-124bf3313624	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:19:01.774653+00	2023-12-05 18:19:02.795318+00	\N	2023-12-05 18:19:00	00:15:00	2023-12-05 18:18:02.774653+00	2023-12-05 18:19:02.80515+00	2023-12-05 18:20:01.774653+00	f	\N	\N
071996b6-96bd-4b95-923c-d2a3b70b68c9	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:38:01.252481+00	2023-12-05 18:38:03.268672+00	\N	2023-12-05 18:38:00	00:15:00	2023-12-05 18:37:03.252481+00	2023-12-05 18:38:03.275143+00	2023-12-05 18:39:01.252481+00	f	\N	\N
c879cab4-fcaa-4fce-8423-89c77760909e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 18:18:06.271653+00	2023-12-05 18:19:06.264819+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 18:16:06.271653+00	2023-12-05 18:19:06.270475+00	2023-12-05 18:26:06.271653+00	f	\N	\N
207b7268-7a18-4f22-9531-a8c67f53aaaf	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:01:01.316928+00	2023-12-05 18:01:02.333229+00	\N	2023-12-05 18:01:00	00:15:00	2023-12-05 18:00:02.316928+00	2023-12-05 18:01:02.340314+00	2023-12-05 18:02:01.316928+00	f	\N	\N
7eb7cb2b-846c-42fe-b44d-697f0e1d58ee	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 18:06:06.261454+00	2023-12-05 18:07:06.253678+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 18:04:06.261454+00	2023-12-05 18:07:06.261066+00	2023-12-05 18:14:06.261454+00	f	\N	\N
3db50440-5460-43d6-a4f3-4ce2054a9860	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:34:01.15749+00	2023-12-05 18:34:03.171257+00	\N	2023-12-05 18:34:00	00:15:00	2023-12-05 18:33:03.15749+00	2023-12-05 18:34:03.183897+00	2023-12-05 18:35:01.15749+00	f	\N	\N
20f65ab7-ef02-45c1-b496-23ecd5479318	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:02:01.338572+00	2023-12-05 18:02:02.361484+00	\N	2023-12-05 18:02:00	00:15:00	2023-12-05 18:01:02.338572+00	2023-12-05 18:02:02.369191+00	2023-12-05 18:03:01.338572+00	f	\N	\N
950cf346-e277-4174-a66c-25ecc6b6fa4e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 18:24:06.28122+00	2023-12-05 18:25:06.268707+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 18:22:06.28122+00	2023-12-05 18:25:06.295856+00	2023-12-05 18:32:06.28122+00	f	\N	\N
ee9d489a-ddc8-46f1-b428-160a61693f89	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:03:01.367567+00	2023-12-05 18:03:02.38969+00	\N	2023-12-05 18:03:00	00:15:00	2023-12-05 18:02:02.367567+00	2023-12-05 18:03:02.399327+00	2023-12-05 18:04:01.367567+00	f	\N	\N
332e465b-f537-4be5-976b-523606abca54	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 18:27:06.305435+00	2023-12-05 18:28:06.27171+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 18:25:06.305435+00	2023-12-05 18:28:06.314625+00	2023-12-05 18:35:06.305435+00	f	\N	\N
5bdcd4a3-629a-43a6-a771-578c05b5688d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 18:36:06.289049+00	2023-12-05 18:37:06.279297+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 18:34:06.289049+00	2023-12-05 18:37:06.290502+00	2023-12-05 18:44:06.289049+00	f	\N	\N
58f616fb-e411-418a-835a-dc3dcf78e156	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:41:01.329467+00	2023-12-05 18:41:03.351943+00	\N	2023-12-05 18:41:00	00:15:00	2023-12-05 18:40:03.329467+00	2023-12-05 18:41:03.358513+00	2023-12-05 18:42:01.329467+00	f	\N	\N
0489735b-f0d1-465c-b59d-80139f4d90f7	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:04:01.397183+00	2023-12-05 18:04:02.421158+00	\N	2023-12-05 18:04:00	00:15:00	2023-12-05 18:03:02.397183+00	2023-12-05 18:04:02.429197+00	2023-12-05 18:05:01.397183+00	f	\N	\N
77d59d3a-74d7-487d-b613-ae71e2e2f632	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 18:03:06.259895+00	2023-12-05 18:04:06.252075+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 18:01:06.259895+00	2023-12-05 18:04:06.259307+00	2023-12-05 18:11:06.259895+00	f	\N	\N
e99ab368-369e-43cf-826e-5ac9cd7d2ad1	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:08:01.510598+00	2023-12-05 18:08:02.525925+00	\N	2023-12-05 18:08:00	00:15:00	2023-12-05 18:07:02.510598+00	2023-12-05 18:08:02.534667+00	2023-12-05 18:09:01.510598+00	f	\N	\N
624394b0-47b2-4825-8b7f-eb108e9dfe0a	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:39:01.273178+00	2023-12-05 18:39:03.294312+00	\N	2023-12-05 18:39:00	00:15:00	2023-12-05 18:38:03.273178+00	2023-12-05 18:39:03.308863+00	2023-12-05 18:40:01.273178+00	f	\N	\N
e22dfd6a-0178-4461-8d59-38f7b11a0520	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:14:01.650382+00	2023-12-05 18:14:02.666773+00	\N	2023-12-05 18:14:00	00:15:00	2023-12-05 18:13:02.650382+00	2023-12-05 18:14:02.674637+00	2023-12-05 18:15:01.650382+00	f	\N	\N
f8d8a301-308d-4302-be21-ba29ff32c215	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:05:01.427412+00	2023-12-05 18:05:02.452063+00	\N	2023-12-05 18:05:00	00:15:00	2023-12-05 18:04:02.427412+00	2023-12-05 18:05:02.458915+00	2023-12-05 18:06:01.427412+00	f	\N	\N
48f24522-2a04-4f45-811a-19333c629b62	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 18:30:06.331173+00	2023-12-05 18:31:06.273557+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 18:28:06.331173+00	2023-12-05 18:31:06.290507+00	2023-12-05 18:38:06.331173+00	f	\N	\N
dfaea2dc-7f67-4646-8fae-1a0512d052da	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:11:01.578567+00	2023-12-05 18:11:02.597431+00	\N	2023-12-05 18:11:00	00:15:00	2023-12-05 18:10:02.578567+00	2023-12-05 18:11:02.605564+00	2023-12-05 18:12:01.578567+00	f	\N	\N
5895d729-0733-4ab7-abc2-9de02fad2aaa	pool-rewards	0	{"epochNo": 6}	retry	1000000	55	30	f	2023-12-05 18:42:27.383252+00	2023-12-05 18:41:57.379004+00	6	\N	00:15:00	2023-12-05 18:13:55.620658+00	\N	2023-12-19 18:13:55.620658+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	8013
0aefcd08-3d41-407a-bf56-ea95b367b063	pool-rewards	0	{"epochNo": 5}	retry	1000000	62	30	f	2023-12-05 18:42:31.387402+00	2023-12-05 18:42:01.380947+00	5	\N	00:15:00	2023-12-05 18:10:34.416329+00	\N	2023-12-19 18:10:34.416329+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	7007
cb555ee6-4664-4049-bd44-dc1e2f001f73	pool-metrics	0	{"slot": 9633}	completed	0	0	0	f	2023-12-05 18:19:19.614523+00	2023-12-05 18:19:20.804733+00	\N	\N	00:15:00	2023-12-05 18:19:19.614523+00	2023-12-05 18:19:20.972348+00	2023-12-19 18:19:19.614523+00	f	\N	9633
0b352852-0370-4de8-be35-0dad432026f2	pool-rewards	0	{"epochNo": 8}	retry	1000000	42	30	f	2023-12-05 18:42:33.387665+00	2023-12-05 18:42:03.381427+00	8	\N	00:15:00	2023-12-05 18:20:36.816787+00	\N	2023-12-19 18:20:36.816787+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	10019
e1342065-431e-4850-a765-961924848c50	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:40:01.307237+00	2023-12-05 18:40:03.32299+00	\N	2023-12-05 18:40:00	00:15:00	2023-12-05 18:39:03.307237+00	2023-12-05 18:40:03.331439+00	2023-12-05 18:41:01.307237+00	f	\N	\N
eb465055-a5a6-464e-a13a-d87976988303	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 18:39:06.294076+00	2023-12-05 18:40:06.28146+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 18:37:06.294076+00	2023-12-05 18:40:06.292876+00	2023-12-05 18:47:06.294076+00	f	\N	\N
ed5ea4b6-0214-4867-ba0c-faa6f23b3f26	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:28:01.05953+00	2023-12-05 18:28:03.018998+00	\N	2023-12-05 18:28:00	00:15:00	2023-12-05 18:27:03.05953+00	2023-12-05 18:28:03.074613+00	2023-12-05 18:29:01.05953+00	f	\N	\N
8981a779-da86-456b-bbaf-811324294ed6	__pgboss__maintenance	0	\N	created	0	0	0	f	2023-12-05 18:42:06.294744+00	\N	__pgboss__maintenance	\N	00:15:00	2023-12-05 18:40:06.294744+00	\N	2023-12-05 18:50:06.294744+00	f	\N	\N
c32b6b38-39d7-4d26-92bf-74c23c186269	pool-rewards	0	{"epochNo": 11}	retry	1000000	23	30	f	2023-12-05 18:42:41.394751+00	2023-12-05 18:42:11.385675+00	11	\N	00:15:00	2023-12-05 18:30:35.81621+00	\N	2023-12-19 18:30:35.81621+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	13014
1daa19ff-d82c-49d4-b3e4-285e8523b8bc	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:29:01.061069+00	2023-12-05 18:29:03.044577+00	\N	2023-12-05 18:29:00	00:15:00	2023-12-05 18:28:03.061069+00	2023-12-05 18:29:03.06544+00	2023-12-05 18:30:01.061069+00	f	\N	\N
98e0dd76-9706-45ea-bab4-98ac8c03216c	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:27:01.991307+00	2023-12-05 18:27:02.992759+00	\N	2023-12-05 18:27:00	00:15:00	2023-12-05 18:26:02.991307+00	2023-12-05 18:27:03.074136+00	2023-12-05 18:28:01.991307+00	f	\N	\N
9d2a9588-1041-40f9-b5b9-cebbc164b872	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:32:01.115663+00	2023-12-05 18:32:03.125477+00	\N	2023-12-05 18:32:00	00:15:00	2023-12-05 18:31:03.115663+00	2023-12-05 18:32:03.137409+00	2023-12-05 18:33:01.115663+00	f	\N	\N
2ba66eac-f16f-43a8-b543-aabcddbe6c29	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-05 18:33:06.296152+00	2023-12-05 18:34:06.275838+00	__pgboss__maintenance	\N	00:15:00	2023-12-05 18:31:06.296152+00	2023-12-05 18:34:06.285818+00	2023-12-05 18:41:06.296152+00	f	\N	\N
8d4352ac-b66c-407b-bb25-ef1821ee4496	pool-rewards	0	{"epochNo": 10}	retry	1000000	29	30	f	2023-12-05 18:42:33.387172+00	2023-12-05 18:42:03.381427+00	10	\N	00:15:00	2023-12-05 18:27:14.611046+00	\N	2023-12-19 18:27:14.611046+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	12008
a7d29bb6-2365-49b1-b588-2b82b1bd40f3	pool-rewards	0	{"epochNo": 14}	retry	1000000	3	30	f	2023-12-05 18:42:41.395105+00	2023-12-05 18:42:11.385675+00	14	\N	00:15:00	2023-12-05 18:40:38.016109+00	\N	2023-12-19 18:40:38.016109+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	16025
eb764921-ca31-4548-8019-f5e129c8521a	pool-rewards	0	{"epochNo": 9}	retry	1000000	36	30	f	2023-12-05 18:42:41.395435+00	2023-12-05 18:42:11.385675+00	9	\N	00:15:00	2023-12-05 18:23:54.415426+00	\N	2023-12-19 18:23:54.415426+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	11007
c6331216-d2ae-41a6-a247-2be4af9ac1eb	pool-rewards	0	{"epochNo": 13}	retry	1000000	10	30	f	2023-12-05 18:42:47.392233+00	2023-12-05 18:42:17.389236+00	13	\N	00:15:00	2023-12-05 18:37:17.214843+00	\N	2023-12-19 18:37:17.214843+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	15021
06c71c2e-a933-423c-902b-d5fa517c3e5c	pool-rewards	0	{"epochNo": 12}	retry	1000000	16	30	f	2023-12-05 18:42:27.384251+00	2023-12-05 18:41:57.379004+00	12	\N	00:15:00	2023-12-05 18:33:53.014311+00	\N	2023-12-19 18:33:53.014311+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	14000
69e8b4c7-95a1-4bd2-97b9-1231b04954eb	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-05 18:42:01.356862+00	2023-12-05 18:42:03.38091+00	\N	2023-12-05 18:42:00	00:15:00	2023-12-05 18:41:03.356862+00	2023-12-05 18:42:03.390737+00	2023-12-05 18:43:01.356862+00	f	\N	\N
8c638430-d394-474c-b319-36bd8639453f	pool-rewards	0	{"epochNo": 4}	retry	1000000	69	30	f	2023-12-05 18:42:43.389446+00	2023-12-05 18:42:13.38594+00	4	\N	00:15:00	2023-12-05 18:07:13.416803+00	\N	2023-12-19 18:07:13.416803+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	6002
2979832c-0b08-42ad-8665-c19b37794156	pool-rewards	0	{"epochNo": 3}	retry	1000000	75	30	f	2023-12-05 18:42:27.384638+00	2023-12-05 18:41:57.379004+00	3	\N	00:15:00	2023-12-05 18:03:53.414781+00	\N	2023-12-19 18:03:53.414781+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	5002
6f16b426-a6e5-4ac6-8d05-c63bd3dc3e08	pool-rewards	0	{"epochNo": 7}	retry	1000000	49	30	f	2023-12-05 18:42:43.389754+00	2023-12-05 18:42:13.38594+00	7	\N	00:15:00	2023-12-05 18:17:15.810236+00	\N	2023-12-19 18:17:15.810236+00	f	{"name": "Error", "stack": "Error: Previous epoch rewards job not completed yet\\n    at checkPreviousEpochCompleted (/app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:89:19)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolRewardsHandler.js:153:9\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "message": "Previous epoch rewards job not completed yet"}	9014
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
20	2023-12-05 18:40:06.290921+00	2023-12-05 18:42:03.385024+00
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (height, hash, slot) FROM stdin;
0	00ecd818a8f1e8e0475fac446d2cbcb00078571cbb191b6e016ea0a77d92bcca	18
1	40053a920724145de49ef48f25a04917d345bd7941c5e79ef0e54d05e954d466	39
2	21e9c5f3d9ecbcbf657df57a31917930cad53dfdf3c7dbacdac2eb94b64e1ce8	43
3	9a12d7a2164b4a2b389f78b7d29f00a8e77fdcf6f69571402fe23bef3cd43f21	46
4	f584493bc75d9dad658cbf8e0d41d818d7e4337459479461f8cb22adc8906ee1	47
5	aa46868ca9de97c22d296a0c01ede637a040c37887f2ccb0d8431fecb97af474	58
6	414147075a3b41a043bdaf36fb00c6e5c0d0daf10dbb33e2e5a89db29be0de59	66
7	74be2054874933d1875648b66d580b239a3b13fe097b4288e433816e5c86e46c	79
8	dade21a8ceda911de96902dab49c889afce0944cd017a1ceefe03f739fec2b39	82
9	4450a881380fac158f54b012180265e81878ddda1994e829cc86d21fdff522eb	131
10	63db4e0373236b34b64f2d000e15d39f17f57fb02b9b655dd112acbcce42ded3	132
11	805b1feab9e28c4abcb68387520974e0344e0ff30bd30aa5cb84b63481ee036b	164
12	edd2d309ad93cf4a98a0bbd241306420c46431948285cf29903a0bc505f397f4	169
13	6da56f8fb9f524fb5e998778c267d6d75f3e0d416069f1e1351bb27c8b053ce9	208
14	4c5cd314485a1a6256973f29014feca37f0316196c73bd6d37e828a5916259df	211
15	2da9b041c6e92ef20ba891f9fbee5b469b8a3791a3376d65645a72bc58112c1d	214
16	6c98cbf8547f3a592cea72b0d535dbeacdee599c18e2749e72192dbe12c753cf	224
17	dabbc36e16050252edda816462a0ae9a3b3887d9331b206994e7d53201fb5ff4	240
18	cdd51dc5f4ff103183b0f3fc8595c2db9f573108ad1eafce4876a35240da9a59	250
19	7d8da26367d12290ba4df85f22919b94f9984fe1d66c15b1ab48d7e608cc1743	257
20	e10baf454cde1491722e4770b43936187c63b8bd8d21803acf44b0ae0fcee3c0	269
21	a88b5f83313b08a038e62705258e3cb76b58e47c7ae8e4af29cb7ac330347ac0	285
22	d66463693c5026ebf995a393b39e94d0e92c9b3b1f9907fdcf928baa7acb9386	309
23	b93b5820cb999d42adc9721a3da9861fd9ff203a759ae32bae2d3c2ab1691a82	316
24	1448b5dc60a907de118850fe42c600a5e0413c62a32d5fe67388b62ddd7daac7	325
25	27401d64d7ea08ddf22aa31a1e374d5b2215a82df5fe749335731000f693cf6b	338
26	69ae4b0ebffd90ec4602b3a09930754cce5cd066f405aebcb8fa7a6af3f966ac	358
27	726817c22161b1d65d5323684f42ea0b80c0a3a308d4f11bd812836a286c2a28	360
28	48368c4fee70fc226973303f05da05aa21feb467deef3d64ca1854a31fddce08	364
29	b08d5b7cb9f81e4bac00fdddda9313abf9a1688ae4ee20743a86d067a3092e79	370
30	31095dde4fad97b96c0f5bdcb9a601ee730388d9805cf6392694ae9265907c56	371
31	172bd3f34611d14dc4ccf09e9e1ec596aee1b8323ab47828fa0b2e1db2ec1933	381
32	4beb9569a075a334f6df2d31c246a50236de099bbba42f7c72638bbb71d4e1b8	389
33	9178b732454dbaee2455e56d17d9141c314e579e118f224518956bb0a9ab2bdc	390
34	166de8e133147771de0f62e6236f0aa4ed58467eb6991da9f52061bf09540cb1	398
35	c4e82b1c2a1d1e66b43f250680b49b7c5d194cadf454e50306db7596d3e7bd72	405
36	c7317b5eaddb7d5d92198e9c99213d448a67472534c942a6bdf3195f8fd18989	407
37	36a29148d60972d4dd3cd16e1a346704dc64bb8fbeb0a1ae402bc2e3e8a1cc8f	408
38	f78293ee71b6288b6fa487f7174c11652993b8be96df6fda843c2d497f5f1640	425
39	ac40c34bf4c85b6ce4d17a158fd4db865e1e5fbf2e8838feb6fa70c50ad8b940	427
40	9813edb6bb255f00b3b008ae40a36ac98704be9bb7ffcbb1bf97507da3141bc5	431
41	e936ad43aa4cb3838bf52f4e1b34f0d41e5468d1c52a0aee44628118c5d95e69	438
42	5e126ba4c43fe1f492370b918115887f9896344df9657fc5de5419a551cc5477	448
43	ae020e67363e2ca834ae7db2bc62562b718f0363d6eac7b91c190cc859d10ba3	452
44	99194c85f47ecad2cb926880e601ad0cfbe6f9a7d79ae0aa228a649e83f988ef	464
45	a9d4449093292ee877202d764384c44a89b69f70a3cb64401dba2f6cdd13db21	472
46	8e0a281393c47afd0538504b3fba8ae6a486aa028a8b238cc6cf72dff5848375	477
47	cb36a7202cc632b65ea4bed2e20a02e76ec180ef9d969bd97b7cfb48f6fef66a	502
48	5b53912a6eaefebac137db3f374e65747a887bf70dc2144885dfda6e7868cada	522
49	a855ed626b6924a6c47bb6546dadfe6a410926ad40f744321d769192b64d62aa	536
50	f6591707ab81bcab25c7e6d2574604a2e1883fe894105c00738bf496a2d92b03	553
51	45cf601d74bed700306dc72917667320a28d45ac6b75d999b47c1a029d131089	554
52	299ea74a65fc67c74254c882972c35d441d90beb78b0cec55abd19166bb40436	558
53	c5447d725a1c0d22b61df30298df63df654c5edf9dd7b5241b18da054be99308	565
54	5407342d214cb5e905e7da0830f76022d848c5507f25a725a11f86f950d16a5f	595
55	55f75b1606e475cc192ffdc23cb30789c9220ef1e186048ee031b611994038dd	600
56	2562fb2acc09a7ed230715a93559d469f305b7f9ae454a05fee6de520a29b7a4	603
57	c7aac1a3b3dfb15187867b42d412bb22d47e597f087aabdc7aeb1dae673883f1	607
58	dd9bb6e5dd083caa6d170f078fe05096d1c3f8f97f4352979fe8b541315ab9a7	626
59	97b3eccb459fceeb5ff60bef96042d276cc53609db235b17a76f0708fe53c8b4	631
60	151902731171b6bf3308eb64c323d8c317729e307ff9a54120cd6cde7803b811	635
61	523b9bac94aae18ee62f575f80072da354820cd1796af1807ab4cda3b5c0c988	643
62	3759a3c1147b8f1c1d4421563a2b2030d93b1f582cd7ac149f24b5cc6e15424c	646
63	adea1a5a7e5d3efc1f9c567e2536b3d5e44ac2d32363e138b456affd5f2c0d85	662
64	ea4f292eb18b36f022990e55f2427ee234ed92be0a3f6b0be569644b10ee1e29	663
65	d5e65bb0d088f4d7b8c4134a5dbd62bf1662094751b67cd13412f059bcadb890	678
66	ac2e74ff5a05e8569f8d0431b6532fecfd1fd8965f21c9fb8ba8198f48e80e67	696
67	14eb7761043d1a76cb600efc88df2b9f79519dc3fb73edb96441e9179fe9c65e	702
68	fafa045ba670c4f73bf4641120978de9767e4c91767cf8e77b4482b1da29070a	707
69	18e1aac566d0d06d85364dc2fa7a4d43c9f465c85fc42139ee1fe5eeb6439deb	715
70	934b4f326412b29bb237346f7ba5cf477950eb543555f50fb112ea8e98c613c4	727
71	8626dec15f9fdcca70b556c723cbf4d9879670a0a4d918af904df95fe863cac6	774
72	0a091cb2519d6bdad30074aa2fda0859336fe4ab198f6365d788f0b07657be41	785
73	c5266b54e7240303150f7a75410f9f50de81be8c1a62c4873330e6a765ca33a1	788
74	ee25537fb5ca998a3c64c6a761204056bac112f3d288c9503dd03f8ed4c49fc5	792
75	0b8216ac404a27b7e0b6d083459d9845ba738d213f472b354676bfe6b3046504	801
76	1595cba3a03c72202bb521cbc0256c35a49d551cffd706aaa1913ef0dc5238bc	813
77	f5553f0402e210a6e82a33f5016b9208930afddf63de1a75f17c11b88dfd00ef	823
78	502742bb03135806334cf0c7c0457a59bd65ce04802022b6223a2816ad8e2c58	826
79	808baa499ce014ea26c2193f535e8f0fdbbdd8c2fe7a66cdf5a7c914b7f81998	847
80	103784ba54d0def0ba67129c6d4cedf0d81be1295134a5a55d74589e950fe737	852
81	b27d01a9db3da2b49fa260961405f3afad57e05e7180f29e9c59adbbd48f0499	871
82	65db7e5e7694fbc007ade74ba620cede3beeb41d350c564a00148cc7610eba51	873
83	e38f526a778e5d430afc8f9227380b386a9d0e96c03761f8a23bb853c0cdefb1	875
84	bdf3a30fd257e74ab6dbc7501788622c33b1e27d2ccbd0796c0d9595d2c97081	876
85	ad925f1ad75421b9ae3f1559c239eee2e99b583cf24eb09422442c19e1039e47	891
86	bf9a14ba45bb9df08ae6421629e2efe0c7744523eb42cb8ec7e601f9b8adfb75	895
87	eec815e7b6fea1f716c1c7b7a6de347004d7bb031b7e816cd34acdf2e97c02ad	900
88	093424c373974d3e8f23951d989ef1aec9373407486c2f04d07761220801b802	912
89	dbd866217fd5628b84e89de9701e501815f627619c937a6c6f577b34cae1e716	939
90	231ddb50f9f5d55ca84993f671d6e1a4e5e47d5938ea55ffbbd2e676198e772d	940
91	ee4b3b2c7ce53a199e184a1edbb69c8abbe1d578955bbc7a5171f89182fe1383	961
92	0ab60153e589c0098fb99760c96d062475feed3cd35f98ca1ddb1c71e498d04d	968
93	a87b1441c1cb02ac48fcee4d197bae0b5dad15660f1433dfe9cd1e91f8ea434d	984
94	c21fc1a249e83d331f1ac9246edf596d37e96723d959bebfd73ef356a7678298	991
95	57ecf09ddecd260c9f85aca46636764d479f313f1850d18a2e6687e4218d9c4a	994
96	2e6305f0e8867129bad0cfdb5b12bf793a94ef0c8bc72edeccf2823ca26d3597	996
97	ca74f942479b07cf82be46bac6f88f807b69db8a63f79c2eb7b2edf055d682b5	1019
98	f4d6b75437d43ed99fc2674dc3d22ae555321835374bc05826436a25670ef259	1023
99	76f7ba2af62dfbe53aa8c7b635e020020eca3979e42e1532069cab40d56163d6	1028
100	c3f3659d1c93a297852b4b83c9f0f3b1ca335eb013ffa635b23e297db9b73488	1039
101	d3bca054e2cba236820033a7459003b600b2b13780aa15c386c7dd40b1b68109	1042
102	4855d397de00ebc87737aa1c34baf483d3816b75e57b491836fb160e5bf1f335	1046
103	423c1dece37e2022cde00585cbedd6752ac557879e4091feddf22fdc3b2b59bc	1049
104	82ecd092c83bf89ec5fbc0b3c3970c779687f0e70c555bad53bebaade842b93c	1054
105	3ba206f69f7bbbcd3fe80c4cb5c87d3344ec9647ad54d7f72c23ba0b7d8c591b	1055
106	45887b7bc678205d325131836483d82cd37d36f6723ddff6444af39193323274	1056
107	4e76b42af4d5f703f6a720730558981aaf82bb323def5da93e8af64714f71bb2	1063
108	d42e7b4ace3ddf20f799abffca5147d2412e65503e9a397894ef21ea2971254a	1089
109	f3f15adff8ad72eebbea55f4aa3382a8b463f3dbe14fbfd0c12b37d11575c1f9	1116
110	fedf86f0bfd51ae503118f13bf387ce388fce4a966272c6ae8429f955154123b	1117
111	4705be689a30eb74eaedea460f3eb74ba0dd32f6e4fec1461f93e9eebe5b2571	1119
112	535f8fcf731f605fccea432e48457729f097ac75bf879780fefd87c605b54aaf	1124
113	70d4475c7f32b4ec2c4519607f84bb33345b6de8a4bc6731e1541af25b10549f	1125
114	70f49a8b95773245853cd05a4916005e53f65c494ee33c5fe230f1e3fe20513f	1134
115	c2d7ec5d784bfa05f5aad863e8456491237f850e2bbb8baa74204c2f023b7cbc	1143
116	f9da1a970adf258795242450453403c57cf1e90af9d762ca3dbb86bd8976539e	1187
117	3eee0049b96c65a5c9cbac18e79ca53f5c54c618270995d51ed3640bc679212d	1188
118	3929a1d114db00cabb95c7aff2327b7385ff7acd5fc654ac8409e0db8cfea656	1202
119	140a4eb0e53dd94db35025d6d8317219182a02fffbdca8e262f04a70d39883aa	1204
120	a8f83e32df5ecba792dc1585a2650f79e4d49f262cb45d0582fdeb0758cd1c12	1215
121	4baffcac202a28ad26b7932f87965d44cbda82785144d3583e616f83c05238e7	1219
122	2d8288bd6786e7526f669af4853830758ced23c810e8743e115b2cc852c3fa08	1233
123	6a58051f5e1607f21093cfe0b73ec5b79dfe2c401aeaca535e76c69efc46063c	1238
124	46ef0dbcb1c39e33d09cbb86803cbdec320563525610d57128e7bf9331b460e4	1239
125	c050ed4c1b90f94d7178e41a68c5d45cc5c6b01afc6cc7e1b110aa9d4ed45d67	1247
126	43d889822da6c1e5f6fea83aefd15200cedb6b5fdcdac54a7447b7108b20c163	1252
127	d22fbb9a0fc2528ef4f4003f3702b969af7c873488c16bab51341e4dd385c883	1264
128	c8547456276fe1a2b94c6a13233552db76a53e4c32d6d8b739fb92572fb1a5d9	1271
129	f3456909f412542fbc5263a4c63cc1ddf2c12f33d21f9d6940377747b7894183	1273
130	1555029aad5641047ba3b76394dd40f448caffdc7a7af0454caa991c59a57683	1293
131	f29dbda37a9b9addb5ba27d28534807255b0d629732311ae151646c1c0745696	1302
132	c7b9d25f9eabb4c1dce48abddba6c8acd1f288d8ad6473e6799fdd308454c9a0	1312
133	7ad9727b46fc6ce77bc0144906718f922a7b428d7f821af29b0e51f6a33e9e40	1313
134	25e53784791dd7045968ff43f8461b035a65de59d6a194a3fa1fe5e1620dbff6	1320
135	92e5a75a1d2b53b582f027c4426d826f5e47a5ac1fb33e96cbe06ff805e70644	1329
136	ec9a4a21415339c1985cc216b16c089b854676f13860d15db80e64d3043d09df	1376
137	6b1f647bdbce5717f706817bbc29e877052f5335b97ed5ffd629c520c874e6f8	1378
138	cffcfb0e62b1a382aafcfdb2f7ad5311c3e034817d7b2638e7a39d4bb85ec6b6	1379
139	a61b94fa32b9203a6ec645be4ca75ceddeb815cecda1e9b7c98e0c0899eb02da	1384
140	b8d4b0c421b1f25f509a50d80ca8e76fac9a8d1b20bf23c8a6d8b3df4a4b3eb5	1389
141	4c4de4cc1b001318299bec731906898f2fcd1030aa3f818669883e784edacd64	1398
142	43015ddb90f3eb0914c44c4a2db7727d50b55741c09b421db21c296fb3cfd14c	1401
143	9321a45e76514c392256d163a09afdecfb02c0e15df1eba0d0d239c1b76484ed	1402
144	10a07d0441fcc32eba3635893f5e401fb72872f98842e27f71bc59edc12b4584	1426
145	bf8fcdd850209f39c1870cf471aff40ef01e0c47b8e0b0b04b7b409dd70ec324	1440
146	bf4909a5c7398195cc7536bf5ebe002eb38d61844b9741281c63dce8c671cf7b	1459
147	e372af3019a53b4815b18eb13fba61e9ac7fed2db2dd91a8517a9c3975bc79a1	1469
148	c804ff6b4044e91c1719affb31f2cc56f43dd9ca3fab8a92f2336f0c75d7b62b	1476
149	3a1341730a2b7619ba3c2f6c5658181673114fb90caab041ae60b42d48e1499f	1482
150	d98f5229676bc29426b248bc8a639ba0db03368caeeb26f2cfe251b733e2bf72	1484
151	eecfa7001dae20577a7030f7705e46f2b7bb986a18aa066f3944a1f1391c053c	1497
152	88dbf0923eaec4c60355c587fd74f6ed7f067bb05353bc5a9825f896fce1a602	1506
153	c9622cacbc0b0bdbe6cda1059ccf9dfed6db5973bccdabad692cd827108e54d9	1513
154	9b582d5ce62c0f92479fe5720b1870b3f48492d0b7d408e9433efc6fe3ec8b8f	1521
155	a4998612cda96e30576bfd2b7d86e99386778be4d99127f271349fbf72da2488	1524
156	9f3151f353863d8b0ebbc89b3a073b18baac245e30c1fccfd0e414fa89f32e7f	1527
157	f36a977cf9d6e6387dd5d4407bb152d2f5553461d0480701c96406d7c8ac8a1f	1531
158	bb6c5e574763fd2f06220f166a980a74bb231f817bc4a851d37bbf6be4895747	1536
159	3fa92e075abe98dfe3cca1188babdbc8a401d8e6b95229e4eb00295092b02915	1567
160	e90a48e5ca7b38a7ecf553942d647fef309b50ac0adb412f37880bdd5e0820a1	1587
161	893ed1c9052141b1c48d8757163b42e39c6446637b03043559a71f35951333fc	1595
162	7bfbf41f445f2f4a046ae1509548a3ccd7ed621a098549c9cf1e429c61bcca93	1603
163	5d37a2fc12e06ed30320cbb73246c8c5fca66879e93fd10e9d3ea390485a5ede	1615
164	612c70afc122624e4e7eba1254dc10b508b0c113f73584cb61dcac83177706e4	1619
165	e4ffc803ac9fdc8da5c6cd6187d577ef5db0374fa2f778b4284d0dd8275b780a	1624
166	e87d4bda42e3367514588b013c4080f68040cc58415e8353550738335165ccba	1626
167	c10aa1bac012cd21ac26b06d1c22e7c0ff4307fa20faa9a4e89f1bc50fc1aa41	1630
168	d4289809c502d92617376916108cee9c6591f01cef3d9df97ce2e4aebad74b6e	1635
169	6275394ce4ead594e183b8c4155a76c193f1c6fe694666ca83cea82d5163a3d2	1651
170	e849fce48c82f8c72cb8e5c654008476d82149bd26354ff01237ff34542e4f93	1652
171	b0bc8d46f75417dec4eb8569ebf782c39ef21ab22e48cb2dd46512011b21f1fd	1668
172	70d373b644885a524c42902e73dbd90d4631a992e84dcba96524d125925bc862	1678
173	6fdfba31578de2bde45d275fc2f18228d8f2bf848c5d38cbabe4a59d7e8604a7	1693
174	7face73b01eb5bb26217f62de3a61e91510b8bb3512944f309b565d78d91331b	1726
175	c66208bd3803b105ae9739cf2aec7923e869722f50e3ac91af56f5fb8274a31e	1734
176	cbd191214e406af15c2bc0566e268f435c3340b5a45bba16b8c2b770a4d11363	1762
177	8b3c90f1b80e9ac935077ab4f13b7848fb2929b7694b25360111612e5bd29705	1774
178	d9149e85abd3f6aae8ce48df3d70d02ab80117ce41e09f5b9e74a5e753c9ae46	1778
179	22fa64a0bd4975d0abfccb08898133727851dc2313c8fc5ec60ffaab3bc26f35	1784
180	7a07c9c0b93d813401adb7e192ef9dce3909abfad59768d0c8437fe1068bb66e	1796
181	0805a456cbf1d581be9ac29fac9665ef65e09fdf82923876b51cb2cbf5b4eb8c	1803
182	927fd632c6b124393aacac1e73afb7100ff4d85c09b05de196bd5ed68952ada3	1804
183	d7e6083ee9e2a40c704a65fcd1320d90aa16edf167ee533930f0082f283abe0d	1837
184	774e749eec5ef65b08c77c9eb9918685c082614b873ca9ce24ab194008b833ac	1839
185	0adbf0d2bad17cbe9a74cf69a338d88b213e4c23e4a2dc8eb4db3ed855a0e53a	1844
186	ca3717b086aefa8325362a9056f0ffd03068446809901fee543bd9aa2234b43c	1860
187	84f29649183fdec0c4a4a1bb3c7c310e622973c912ac37a6b150b68ce1104caa	1865
188	7b7bcdddc9c6b367fee18c607cb208c6fd19ca495436e606b204c4208fb39d71	1866
189	377b26d288cf05b02f9f96052b0d7866adf9dd29db078b13763db4841bf53ddf	1900
190	15cccb86a573e005206e86067d52974c0842b9c886e9de455c3e2469fba2b7e5	1913
191	da7fc534e7061410538b02cc53f5c8c7ac52173a89f8f09101fda3942d71e5f1	1934
192	ef425d9805bfdd5637e982d2d318543248bbd3407a19a700a0ab6d93b88432f7	1940
193	621b7011425ad57f848618a6907a8c79929cb04741b216c101d4f4ca3d2e795d	1942
194	cee7c6b082a2ea5557d092163de4fbc6b6c231177b8aa5e1dd913e31d43046b7	1952
195	a3f7c5e58e74cf18b2e484b47b6a80d5181224480c39a34d14118f00652e4c93	1962
196	5ebc1519df982016267d6bc152ab8889e49e8ef30ff05b0ebbaae3110c3fd669	1967
197	762a4c895a78e44009b934e71ea01954cc88fbc0ee213952fa949609a2ff3854	1992
198	b9ee991feabbf27326f99563619416ec7816b5c8535cf1e1f2b0a972e8e56922	1997
199	581952aeec54c4823f6e7555b0cd4fc01064beb0fb4a2d510f0091fd7a1371b2	2031
200	9f54e4c1627ccc4571f0149866b3d177ba3efe88bf49f8ba6ab6fa8b7daedb20	2062
201	19d0edd876b474a3d13e6d0f30e56a308f3a0188673a2542247970d15e2f2773	2065
202	518da95525afbd6c2361951a5dfdde2878af6884aa36647968474a3558f28747	2072
203	fb69ca9644d7f88fdb24977cc996d296b47a0f09084f609b4aaeefa20840a0f5	2081
204	269bcbe08273c4bd0263bf76bb3c27ab3f2df3788f86ce613ae1f53da5517344	2086
205	be50ba3a1b03d85e6d5dcf2548200dec3c7da46ad51f782f78146fc7b45fe82e	2090
206	78c9173ccbdaf2f67d28f5fa64d221184c7f91c21f68960bc60ff6d670fa8d11	2091
207	aa0785e74cb88671413742ad05dfa0f8b2e102b86c35a99ffd952a648e797363	2102
208	cc44f4e1ff881a7e41f5f7e9e88c9fef610e52b265ca651ad24355c72f21e3b4	2116
209	153f901d4099df88c52c8d9f9d85147917a726a0eb8b8faf1517c4e1058d8cdf	2134
210	a3a80ac293cd4327b0d2739f7a0a5d9c9a55cb8134c49df39b4da70a1ea07b7c	2143
211	bc9fdc15688ab03850f23ffcd7f145589195e658db416ff02a7b8bc32deb0176	2146
212	9184f28bb7442814d1e4c089e4b68e3539457963e3cd3b7a6db59d7fdce65e98	2154
213	08c5a1c50ca69d3c281652dd3a79be0712b590784891e4353c3c8dbc396cf600	2158
214	a503fc3f5d14ec5a2dea8ae3d9b5705f83cd5bb9dcbd2b1ab2e7867b6675df37	2164
215	c11b6b6dc482d00ad6f03b58c9774ac7cd038c1886eb48194f6e19c32a181bf6	2175
216	a214ff73bfe7055807c137e805cd168371c4ed618cf3ef004855b7f66a0c724b	2180
217	0c1e1e754e3780dcb275035f0ea23536e7dbae2ecc41bca12e4069f7bd9bc481	2184
218	b3968b85d4219e5a5c45cb2e18d4474c5a3ba4afa008deb24b24dd9485976f33	2190
219	956d7c090e723b7f1ed95c05a520ab3ee30e3de20f8728beb24dd24056ecf364	2192
220	9958f85c481deb65c1766baec948b5feeaca15ef3346804d0618b6db73142642	2194
221	28bb7b07a80ceb89aa1ff68e49c5602dbe149a2c85824507bb47e5aeb8126192	2198
222	b37240834b54e7f78278b4132c4774f5187a92e27e1472852e4ab89481559bcb	2199
223	97ae03577354d4e48d1fbc3c351a1410cab1fab05efc2b311cf9e62b5ebf59c0	2202
224	909c871093403af82436a7c0aada1d22f1100baf63bac90309a5dff84f877e8c	2220
225	fbe490b6daf222fa728e6f89c2eb474a2302a9207f37209e8c517db41fc933a5	2223
226	ad26cf6178c461b44294835ac2401cc4e6f2b903449910c75604b8601820bd63	2225
227	b960d152d17fee0ac8c1947bf9170963c36da6fda804d769ecc6b66cee667bc3	2232
228	f30caa0622cc5a194bd527c9dbcff800bd92e42b8c5ca236834fe51e3a44642e	2233
229	c88801cf41d3cac7bb988085eee9fb04840cc8bd57f319a0a776601eed91b8a7	2236
230	2d5de165d164a44ed062293eb0fb0d14c766c303992788761e2517efb07c4345	2251
231	788dcfac2b75575febdb1387420fd134c41bb4ec529c16271d742a7875f0c3c1	2252
232	216bbfe53fe2bb50d250e18223cb141bda82ebd08f816ad4c083f50cb893d031	2256
233	9bc1b3c183c7432b68dbdb7ec3037a11430bec220cadd82fac2fea61fbfd7234	2266
234	e0db71f4356599e82054091c98c27f94075192ad6a3fd7b0d79c17a49d047fe7	2274
235	9b727513885a56a2653d0d6006756b7093bb892a1d27200a3008bb215b9915b2	2279
236	d245ec299ecd0d173d1890dca1bcaa423c247380a1174601d8ee3c806782eb0d	2294
237	6181429542daa549aef25dcb03b0650c508a74d94dd17ba0a72b46bcfe920865	2295
238	aeea054fc72672900246010bffeb3bde51ae460cbf2422895e2cf39fa7011224	2304
239	04f96ab31dd2534bc7d176743e8164fe29c2093ba175fa9e9b400321a1f0bbc1	2315
240	bfaadc1796526c82fe7e300d55439a593de29a4b30489ea592f1812ea34db45b	2319
241	f79d161d4e687d49e4ad234a610eb6a0b778b92b58ff5b6744ef8e856ba4508c	2321
242	b6b64b73b16efe08197d3724d27def676a9e11f6f2f5618f9d16594113a56af1	2324
243	bab81280d9c4d454199df48abf01877b17fcd6c5e4f9bc8fb420f23540fc9e6e	2326
244	091a171b2e486ddd456c45f0a5d284a36b369407477e98a36fb07d71c6cfd130	2358
245	eca9f5302d31b3a49fd26f3ae4726fc7fe8e726ba52810923d4785a7073479a4	2367
246	585a0222d0dd544ed18216564fef8cf554598af7473f364b86e7f5a482de091c	2375
247	a3c0303600bd140ff78ffa9d40d0d0dfe612e250750545d3b5891d3d32ce96ff	2378
248	25298a66b470b0bf348ab4001f7f17d9b0e3b2414d5c35a9170470437f3454c6	2405
249	5b44160aac89a6e0cd22712d61895fe14249f8130961eb973b28ce877001a6fe	2407
250	fdfcb3fc918d80df7ce310edbaa89872ad51cedd5b0bc37aff4a914aa2b9d134	2408
251	b336655f2ed39460326226985a38241fbed41c9c4a061a490cf9d920d7d00430	2415
252	e9d58707202fbaafca5194b3a7dbe7ee8076f47f52e299c10aec75f2800049fa	2418
253	bdfda367d208b70855b658a54246eb07cef2124ca361e29a2b9df9d68550f53c	2420
254	c66b9e83f1ce252030a018524b82eb2187b345756700eecc9b99419894938408	2425
255	093867a5da76064f211e3eb4e915d4c1b72020c24b481227c8f2bcd495d0ce05	2426
256	953cb57ed1e833e73a6c2843cde3249fb20b17cbc8d1d218a9cd7336a7bc6e6a	2442
257	a92d938fcd3dbc5871e1eca53d5d34f61237cdc43d990a570b146f1f2ec7e636	2451
258	f3e02cf2bf9b7256da7a01807038c9d8b80598977204a8b5f0d6742e0d649a81	2454
259	63e9c20930e11d153039618b7003fb87784ae67d5651ab085543efbe815f27b2	2460
260	d57b2cc4660b32f731740e17fd9ee46a373c1e1d3526607e50046676f2167774	2462
261	342a4f137d3b6ddca088171eb40618c83683e57a2429c5aee35c7fb65f4c416b	2464
262	50fa11d0fb882fedaa2bef5b7d96ba07737858e4a3f4c1cada210f553e16aee6	2473
263	01fb08263d3b3666cf79b8a6f9a2d33b7fcca4e4c1bfabd86a5af2ff335f804a	2486
264	136f456a8eb528d8b9bdff73367921fe4658c9f0b623a5b92a2ad96206f5baba	2490
265	8efe8d228607e5a44a710514ebc7b76a169ce2dad30847a449f2fe1ed3fc0dee	2496
266	f75417042c75a814faca70e395413110890d5d237d8e2a931ccd13f85cbdd92e	2504
267	fa1b4719822f0e447a580e3366a998f731f32cb14119a43059e1131c4f40f138	2506
268	3ca1ea1a2fd1ef38d099358d35e8c973de17247eb981b499143167a906408f10	2514
269	c274f6a1eb9d58ba9959ea50ddebf096df8cd2f16f711b3120814b5e845a724f	2520
270	ee11e05ea5b6376b497a144c0f593260e1b9ecd00adb1606a1d6c36163d0b5bb	2526
271	72b4b3c4e0f3d592658369d096069e78de36845cf0afbd6de47b35f5524a684c	2551
272	0c3fc2e2a596f9199b62abf41f5c9ce6086b53429dfd9c014d55c8a31d97d144	2563
273	e1158b17ec173b21ae1e92276f7c876cfbc30f63b43f1729dcc1058fdb3c4e68	2567
274	f509fe5a22fa30112167e36211e68f4335f03f8b5be4b7e4631f30d3678cb6c2	2569
275	6d30768eb84f497d7b4d240f2f2080f4d4c19c53e2df88f031b22ed008e0bf88	2577
276	7b17ce5b593a5c70a1a22433f1222eba6a6a4d7bcdb4c6b746339d5259b46a4c	2604
277	f6a2517a058809a96c9e320353f9f6342483e2e45d1eb2e1db3d65b3644b052e	2627
278	8784c67af40aac05db91122a379c2659e35f4ba37d7066434a2face3df2e007f	2645
279	172d49e8e34ae8f8f1fa0b0187712f04f256c372782052af5f46c708c44a353b	2662
280	a0ef10ad3039d42f3738a5b9f3d8cc198b73825c4027b0a00bc560b891cbc124	2669
281	61d813b30b036f3a30d3519ca89a44102b64e593fa6e79a4c2ae0e5c110138dd	2673
282	e42b0ba14d8f5d32127c152ae1ef28ed0e28df0999739e03358561218a9f8e07	2674
283	296c7b8b93318c162a90a0f4dd39d328f5bc461f2db4f078ca5969b9ea95d7cc	2675
284	feaaa1ef5611e46ec6f8213c339f0471114a1aca3ee946a02553ecb98293ad6c	2687
285	f23f8c37cbe0b4dacaec7aa44b3030d1dc490cb8eef9223b1adf42697e50cadb	2700
286	b7aadcb11ae7c192794ef5667f88688fd91c5dd30169def57387071052420f84	2706
287	866124e1afd32942b58612f3f7ed4415932a821ab778a7e1e0941bc122648f9d	2717
288	ede1419073f7f460392967358f2315508e5147fa9ac8da64153d3ae59d7678a8	2722
289	2b1830912f85927130a97cfb76d3f9dafba83a2ec17b9e68258be8a102184e16	2724
290	c40674ff2e9a94ae2e35adf3b26f3b3626863eeb1654998c14077f81f9a872b8	2727
291	b257dc5a7d1bada703ea65174c140985c09f293a156e3ad17f6dabce2da10c43	2730
292	d8c8361e7e92a75eeca852aa6e7d4b34d68e64b00d4030876c241628d8fd83d4	2732
293	8b5ff7f05e13b11b66aa9679b3abfe69303a66762a744a429873660f77cd4e52	2738
294	07e123d0c3fd82120dce462fe53c4af3721663a0e8870398b83b8d11f316ddc1	2739
295	ec3ee336354c772152afe941b53f8f9c7b9c110351cf54ea8a32e511bd32066f	2748
296	fc35df736c9525ad4b0b77a98736f7b89148eeef77f54a290a1b134643c121db	2757
297	5afb0d182adbf2a4bd96cecd4fe2428f0a7f9e2a06f27dd2366894e0a3f271aa	2761
298	e7b245dbb87998d6affb94649d1fe5eec445216f60a6f2d5ad8a79fbff3a27b0	2768
299	40454494a6138c03c1c1f75df46d1c5cbd3dda7f37914da7c922e40ff6f9029e	2770
300	67f7587eece150b501f13f1f2095c80a1a83d3678304d2a47c5ee2c7841c9e17	2780
301	7f8d62b98538256bc511e134afa0e63d51af77d999b5016eb70f374d1a25ed36	2797
302	3fa49e1c5766a09f3228ba0ca7511ba847f3dc938f16d690602c184dba171ba5	2798
303	5885b0b874766fbf3200b1bc7ea9002e7e8f342e3cab0d89b48612768a596c4f	2807
304	c8473b700d74c144e65885a28e205a598a78911c9d38ee57fcf665dc9e2e49a8	2824
305	e698b5c8febca0e6b13e512635e61aa81452a338588218d83db35ab52d6935c1	2837
306	c2cf6bc1e5d49959fcb65e7c4a4cdacc6438c76f20f35406ee85841dbcfdf779	2842
307	ef6e4737f05d1d5da1241514a833fea2b732e955b7d745571e0c356fc0aba2ec	2848
308	86ec48d25405b93915057b63fd3e717715a20a475fd700e82e566bc54ec3489b	2878
309	8c93fd8e9ec7f57f2658daff1d5b98c8a10e3662a85be95312e017622bbec1c6	2880
310	6922450669ab7b5f16ab2ca76d0f0bdb7824c331773a3406cb4eb0c693649970	2900
311	834a43ecb0edad49a4fee16be7907987e8a0f69d8a25053ff86903621e055560	2905
312	2c71183fb9bf4b0af1f9c717b93d4d23be6dd1a52434b0efdec3e8580b24b291	2912
313	dd7d1bc6f0b283c0faf0ebb32b692c3b653bd1ff6ca29ef70fd6a23ca0dd5110	2920
314	2dc3c1a57e82ed1cf392e36b3646621926f8f9bfcf8e23f012c640648188f262	2927
315	55e0470bbf784fca6fa56e7c0d5bdbfb6f3199b60bd5ac99ac2786bad6b5a945	2936
316	95d0150bf4586675a5172a7a2f6e9f9b744fab11308fff930f71e82c92c0f3af	2938
317	d047b792527dff231b9a816c85c8d8e59587915745149942320a7806872f5580	2946
318	100d213c1df9966ff6ad2e3cee8f80d906d84918f824e6abde9bacc742090c6e	2955
319	808334553a7d4afb035d6a272b4045dcd39ecd05e19cd37434a9b0b1641793bf	2979
320	08ba490384405253568c8e1ec2a9d2b76d57e4b9d0144ac1daba240e88f8575f	2992
321	ef4173d1a574241f1d7390e0bd7db266fe5b707af1d241df63985d9ded748047	2998
322	ecd00e2c6edcdbbfd6ab66c94d0a52e579c319103e295ce594a522d65807cfd7	3007
323	9bd2f32d56ac0412326d00b456c78aee66101f3921237f13dfab670642a201f9	3008
324	b7d2bd775b4dd0faeb0b66ad43f500cc89d01752be6cfed8f047c58ce249b47b	3020
325	73ebde9144f4bd3e6d37c904e081f7ee0963b6029adbae413b848e8ed6098d77	3034
326	0692466db91de2019dbfa1c0ec8e78824423f0c009643fdebab08d320a16db2a	3038
327	be3c868dbff75a48d565fe8145de386e1e4e356e5e1b2aa3ad0ddd3e178395e6	3065
328	84dc9bad392b5d7a400740ffa37bf94adc7599337e325f91abddf98467d06b48	3066
329	9de8039435132f27dd148d9954b54b453fd2428018e29be6d26508d967de37a9	3076
330	376a12f519266ea30c6014c5acf18352e4f99ff6bcc68224e758444e9adfda1d	3090
331	f373f4d7a5185515bc1c9db2d6e1a9d109b77490dece01b30defc6a8bca354ed	3119
332	a72238cd99e168642d0bb10df9a9a9c2a7cfc72f7b511f78cb062a012b9a8680	3143
333	73bc4059441abf8998f8fc11a4b91f988997d6caa2b765b18c9215ed2a41cb00	3156
334	fc574955c50d7b07fe93c9ffb230c781d6f9c375f90a2eef819de44b0df58e5a	3158
335	aea163b72a21b7668bae695ebd1b4ddb632724d1d4265b4b08e98b84aded0ab0	3159
336	c3badab537fc53e46660a4da21d24c485061445ceeb2404be9c67af2f9324d79	3164
337	b1a55947bfcc4b199f6eff3c934cdd51e3fb84a56b85ee340310c4741d2a66d2	3170
338	54899e7c50f005660832530999c476bf58ec2f390981e64338381e9f58d73ffb	3171
339	026dd24b1803dcd80cea6f394f1115a2fa7c1b78ed7a3ff62faf2efec7f4abfe	3201
340	f7996b3b08c434ecd47d96b211af7f262bc164147cecbfec06af9152f88347fb	3229
341	3fd5e7fb9ffcdd3be4b34308dd76e5a82f306d050af80ff0d5ecb25730b34598	3255
342	13dad8b3005365662a5e8720bd418be25907c3e3860bd4020985fd368bcd9778	3262
343	fe6ed82eb5c4ae80047d4a743e95fef3692d795ea92a687702b685bfcb5e3f89	3283
344	da3197114d3209ae9f00388bed8bfc15519fc7fd4078338901845a4d4b80d242	3284
345	fe53633301589a2c397895e5b6dd5cdcc8105a99f79cd9543c656118771702db	3289
346	1eb57cbc8cfa5999e16b384a9c98d00240a7dd23cd52d41688f2ace7c434b651	3292
347	2c4b64d56b76ed00a4b328bd6c9963881096f5dedc8020e8ad7c15b891c30600	3312
348	b2b46731e576df7fa97867adf592f2f47356838b84a101bdac3180e578b04ca6	3314
349	228207553f4149dd91b9d0186aa49bc89a9d77eab5eb75f72e142f5f3d763079	3327
350	752414901f3c4a28a02dc0c28e065a79eb063b165c083e26c3a7e026da6b605b	3330
351	24cff3425f1b1c78c695102564b00e2e03e3136c5b1fa6ac0f3d96db10042685	3362
352	497eb31eb220973e66e54e309d0b487c7f003cfe3aeaf4b435d0d60b4976db4c	3402
353	bebe45ae45a2e2a28242d40f6ba2570ea1f01a1b40e06ee6c77e81c038fe6628	3425
354	16d717df8cf63e98715b2b196939b40408cb9047b39ce525105fd64d4348952e	3427
355	d976aaf7aa90045a3ed5e97735f80eeddb0d6a1d970bdc438c74aed33d284da1	3431
356	a8d1e90f0c1b4008dc59adad73e09c04fc5d0fe3db94b7c0caf863e695c1b830	3439
357	cfd276daac65edccb7da12c1c182acea2f67b77efaa412cb6747f777060da9bb	3444
358	d89896bcfff67fdd9e2e8f6dbf02b0564371c9bcf0442e271138d4c298190932	3449
359	5cd7001722adf5cfe635a36760c22310ae381342e2ac43715f8f6fa7269b8aac	3466
360	edc90946eefd1f03be0ba3b35a592b9bdda4a41bcd9fa885f66d4877b97d9147	3473
361	9d397b27fbd7df07d2e5aee47f22ab5385b6754412373887725a1b3ac026cd67	3486
362	fce159f492cab53d2b311b1ae13c972d1372b15ca9caa5e1ed1831daffff5626	3504
363	8bda65b4c4c17cbdd7406ba2f906c3d83521dfdc3d7109a0cd143f28af098592	3513
364	1753efcb1b82072037096b16d62520aeb1fec828b395c37f02b2150bede74e40	3519
365	e926222b198233d7ea0c7754c01d0ceaa2a1ed3f8075de049b0e954d646c55e4	3520
366	c0782c68c0b1a66e085ac196bdf78d81d5e247801df12acd2ad9b31c4edc6475	3524
367	b1b4b924275b2e9866139eab976b8d856ecb71599371a4052be0bd793fc9d4f8	3525
368	8af36f933ab113bfb8753d436e8e0adc8148df25ed9240bdf4ff5ab83c784bbc	3533
369	6d156184575e79f4eee3f4a563f7fd348eb14762ac80da89c4be78c29fc24384	3540
370	62e08a7bbabe29ca89434cea3639614d80e4d8377cbef28cb33ea3b7c3adaf1a	3544
371	17578861843cbfe055f815022afc96347d025885aa90bec591c610dde2a2fb96	3554
372	3a8b0c3d156defd970319ab70733699b6e653d650283d92e918c2059004a9ab2	3555
373	71c1e9184c91f8c1d35c9f5eef612277b74d5c67be869e7f3d44a43e33fdcb9d	3564
374	ba05a09e88e54c00dafa78faacfcc24aae23addd50f88cdfb71fed893612a444	3568
375	f6e829aecd18f2a111800d2ae40e371caf1633079a1602b33360b92f2ac5501a	3571
376	a2a8e350669ad599123e03185381b94ef052cac789accbcdbcecc589176be30f	3578
377	df7b44f1e07b6209022fa93b3bd4d70dfed4d4c3f99692df01b4b012c8f7bd2e	3587
378	efa4ca0bed17e853bc6e317529824b91e38e57ab80b500c1239bfb091a4c1925	3606
379	4ebd921f20b3d4a3565b1f268f0769b5a858b711166579e4a308bdad920cc988	3608
380	89642dd847b424743334cb9e885654a9056ed704f21e2898536040ab1dc27e32	3618
381	182076abec0dc4b89d5ae83065f197b28966c0b13f5a18850dd05b24e223439d	3630
382	aa1c4064cc1c44eeeecc75d5cd32f118c5e656920b9afb8a18e809aabd3fd5c1	3636
383	96130ea116fe40cfa1f5920f58de08e3abae852ba92120d7b2287f6c668b7670	3637
384	84f5940780491c16d80d62af2a9e567a1a76f27df89b9771cd53c13fcb128765	3646
385	7fa22cdb9c9d6d884097f93741ccca68d5709c23deffb8b20eee851e085e849d	3653
386	8e9e49f3aff95a8ef2862032d904adcc02d7387e0ee50dffb143de23bd69b26a	3656
387	69e8038d502276644a442c259f2899b04027e17b14615c614bc57488f0ae1e99	3658
388	c7160e158acede990bd2f4511eb05844b93897b9d3bd9ada70b89afebd5401df	3711
389	06a5ef355c80d57884c65d4917002378ca6d3760b8ad6a41267bc0f5da221a70	3731
390	aa7a6101ee94fbf12da1e0ef77cb55da6e8126b815d723db2ae39f89782883a7	3738
391	f6897a1029bea5b6ad59b2ba3f0ac4a0a23c963b648bc3a3480c7d75da90e57a	3746
392	644a5537414e50d760cd50ce47710ee81b4778c1332b3b5dc8ff4e91d675f1ba	3753
393	839ec86c65b35193778416b8892fee8504ea881bd4c53297093776fd95d0def3	3760
394	9b976ae94b919d5ecf29a781afc97a00400476c2cf60b14b61ffeb77cfa1cd9e	3775
395	363ba7246317b00de36fd622d432529ddb589c68d02f2431fed8fe39713ed527	3781
396	710630c9154a4b7a57ab8524393683856ceaa2305780fe72e5007882f6593822	3797
397	3e0214cd858672c3d3779fde8703a3ec82b3d225d9b334a722cb01f45b25f966	3813
398	f72fc06fd3c3c671bdab3fbc7cfc2ebac7fd0f8d05b2c32c43e8e2086d49430b	3829
399	867d750ef307bd1da03f08cdbc79e3b90ab7c7a983962a82778c3795bdd628bc	3831
400	1054296eb001c6c9687083b3c70fd3ca3b15499436913143bc63e81f44489149	3840
401	e970f868c73683b17c25abe9270594d0b83ecfcd709dd86bd149f5f32cbb95b5	3844
402	792bacb27292c64db9760137554a9314cea0ae4ff37dc6a545b85cc38f1a1e9e	3853
403	aa4b390ba0a39006064ebbba82c8a49bd76110c37d4ab2ba0315d1ab5155f7c0	3857
404	0a3e8693a555cd7b983417fffdcdaf553df22cd77ccccd3dad5c3e29920ba0bc	3873
405	78719724401f6af76b21b1e63083daeb23e067d7184887d0c3b7796d8fb2f968	3877
406	eb4488cdf6c5369246ba419fe293064ee439339540d1e96f577da55348c6a43d	3884
407	d7124126beabe83b9d639f69e28455c3596e4a6778fcbb97972a9457e6465c9a	3889
408	92a48256fed688f83cee62d658aa50b43a7ae2990402a803efbbacffc11b6e56	3892
409	aea7e55592ae0455c7a65d99cbeddbf52de1de6c839449c2b3d9aeb9fb3c4397	3901
410	d824968064f0f30ff0fc76ccb4d4e72d6a2a891a9410399408edd21dca1b22f1	3931
411	a167b5b76f3af4c225efb0ddf5a9bf65d705a02d85e00103ebf6134b7e9ee6f2	3952
412	37d9727881ce15e4a29adbf3aac722ebfa23bd4f2a6180ceaba39344e558626a	3977
413	3614272e18adc1411904093b532a1cb99e5fc8c56f77188d06676bb8bb32862f	3990
414	4a9910180cc0591afb3a27c3e3b7ed916e7c2ab9cef2c376d248c5a6def0aff0	4010
415	862c01025805278607e1f2958792f9494e06ad5a166cd95f5359bf01a0e5e63c	4021
416	370bf927e45dc921a155ac5274641c16d84e443c97237a6e76866104513b01dd	4022
417	994c9aa7bb6558cfe9870b6e2e7617d8d3fa06a436a2d478d9668d32b13f891e	4034
418	1dbbbbf83e4eda358758aeab730bd7d6c6f5358507404ddb4a2a8584fd09e407	4048
419	5724e59e28a696987419ccf10778130990edf9a2c6659a080fb812e5a9ee742e	4060
420	f56c2cd716063070c121eb399ca60456e4cc1b883da030b23bb80d4e06e465ca	4069
421	997ba86729faaabc9d2235ba837d1df0d12cfc70ef3e5e3a2446fb3f30a8be20	4072
422	bcb5cb386f4d4a701aca95cb3641b6ac5c970a1f02fcc7f5f298a239c39bcabe	4090
423	f8052083074af278eefedfea28ebafeb9627d5f0d68648a1d0e8203c71ecb22f	4111
424	fab35e9ce00310e32b390cce2ddf867f6c9f3164c5d40a4a2e1896c9ceb42620	4118
425	7bec4e93f4951cb83f0f68b8a4cc78cdc47928df1e1df59172d07ccb85e6419d	4121
426	59c53d5f76d2c1034624c705c474b94b4694bd0117bb51cafea9882593effb70	4122
427	37a43f0ef563ed4a8935e986d6ab96f7d771ab02a91319210604b2a1673b4f1d	4147
428	ebd0c9e45f85fefe64d8f7bd6dfc99ed2a58e437609c118a391ba6d9b5787a5f	4148
429	ace3b9f93a92f2688fafa86ddba909a281c82409dade3822d36fae5ec19ea0bc	4151
430	fabf2150e774c280a72d60a1ace22493bfbacbf00fb48de09c25cacfb44548b8	4153
431	a77c8bd63385eaecd9ad04376b7ff3edd448cacbf0db8f7138545c2d5df60a29	4155
432	d09aa2e1f2765699f5cc6399b72ebe6a82587d86824206513990ea591da8753b	4167
433	d4c58335637b9c257052724a002a5aed67234ace37b15913a62fcac9ef212e5f	4190
434	9171103e9dba17162f082b7b85a495ef8ecc5cab4d74068d99c87c2ccf88c18e	4196
435	0b4e1647bd5a2e007e4108b29460c898d71ba9282d6e7fd51d0ba12d45a3195b	4213
436	b07ac6eb354149b4641e5057d67744e0854c772925bcf6dc331923f7f69c9cb8	4217
437	e7c98a7aca6a5c9212783e9fcb17c1ffd2091bcc4933ff3b54a6d304e0649594	4223
438	c66c9431afbccf2a4188f2b5eed12995511fa98d52c564a53c0d04caaa0f4c33	4226
439	876e1e551540d53b7b6bc1b49cb84a2f0ec38d64c1cc299e0e5964fe27f33963	4244
440	7d009f522a24bfea19f9316a7223ad4fe21cb13a51e7d550e9da0df0a0770544	4249
441	8dd4b64182d3309b70829f8f5bd57c710273b18c5b9e245d397a8d357ae2b033	4250
442	cc9f2845b3383b99fd89dd0166d49ac17f84cc943c318128d6ef20a5ff5840ea	4255
443	94c660219f62dfa3d39243d606fba649d78783ae3026dad836cfea18e92fabb5	4256
444	b1ed92fd243de7ccd0703e6b65cf5519dfc1f662134a749f78bd10b84306641b	4264
445	eaa81959f1d528dfadb85e0ab8ed235678db4a4254c4d7c6810c78d0dc6a55b6	4266
446	df21b032e967fb719b98d5d7be4950b80dbaa4dadbcdcd554783fa0980bceaa5	4267
447	bb53068e22791a9f1987bc8fdcf653b79905ed8050ccee9e19f0b4c61abc6a03	4283
448	61360b82f67465d152e06db300349f1fac47ccd26b5687d1384a659d92f929bd	4286
449	8eae60857991b26c8288f16fe6732d337ed80e3c11c0d252245a7b74bb2947af	4298
450	0fb4daa3a8655e3f25a5cad39ad2ae9dabf2205cfef1d919e6a579b3a1fdc521	4324
451	6076ba88efcbccd2d1f97b7a3a4e0c7d8a9e0e8162c67b328419230c00eb59a5	4351
452	b0614f6ea7dd54c07c17b62f5bd627747df357494abe5e7160edbc95948308a6	4359
453	fee1d6c1aa678203f4408f2e26b1ccf662d27e8d3c206326d67d861464b335f3	4363
454	166680f5e599dd39d04a5561a9dbe65744815fb01f8bf339add876a314ed99b4	4372
455	153cfa4b9ca3c578a8af011f67bac3a3e68597ead9fee0f3ccd63f4d58fdd434	4378
456	b4b985abd4a7c65ecd315edbd4b14e8fcbf62a43993c70d8c04685343261716f	4389
457	0737bb33de6317b9659b2df3584b9522f54dafccf61a3fa236804f630becbc54	4397
458	2573d5b02d26c48e09eb8d2c72602ccda93ce22cb0383d828ebb081716f6c3d5	4400
459	54b940a4a039e4bb928d311e9e247bef5bd5daf36095e3e928f6d8ee1dac497e	4412
460	c11e0d5496ebde2033b6c9c5a5e716e9945b7bed797890c4cc1653c76e700062	4415
461	de15db91e9395b3b5982be8c43f5d94b1adc88de4a66926358bb36b59ebfc74f	4430
462	2b2b73061ba98e0c8282591d5e189c5004804707e9ad7a20bad14bbf35e11b1b	4450
463	b2b9e88986f238ceec575ffc29dcfa6e314beb00c2e46741950fd6697a2e0cc2	4455
464	d4eb291927fc16e4c658cbbfab6b7bf922382a0b458df7eeccb5cd76ec5a2a85	4457
465	1ecd1a370a2d7dec748414c9eb1c97ecb8c81abec68fb9a56c412330925237b0	4465
466	fda0eddc30f82a404d187ca8f4798617f15ba465e1505a827058c99948c10216	4467
467	207ff426ef901332c92692aef5db2eb3087b4ad31aa7e74c113b7dc4caa62f27	4470
468	107d7eec70b54be20ca7face6bb540a2d591be91636cf9cabf9e01c6d408a43b	4473
469	5a5a87906b2611b786304f6418e05b36ba90e87592742ff65ddda8d5973a9514	4496
470	3edb06a1fb57ff40a647d4a63859ca6463447ce37ada03240ac76099af0a4a37	4498
471	6e6c9b0c96a56ec62de0217ea205ee62d3c6d6cafdb009e7b5173480ba8e248f	4505
472	000de4785244b0adf368a696fa4e34a320bbe08849ea8853d8f97be471c6f7a7	4511
473	e913cad5d44a5fb88511ab4e49645b9466efa1c6b4b9645f87b6cf10b78d1ba8	4516
474	2fcdbf30ed874f88f487bc22478eaefdc6c06bfb979aaa671c71086d9cbd4b71	4533
475	fcd9a3f764e76e37cd37e575a0dde83ebb55c7f6ef49f0b2016d6cbe91a204c8	4538
476	f1c4edca397a06ee75fcec8c0f2edc549cd4dab6bf1048058c9bb311490e04ca	4541
477	c6f7035d4846c88a0d4fa1b2bdb8d7d3120e2a8bea6b0485eb1ad89919e6e0ce	4542
478	33a78a235d9a066fdbf61e73e3e358f344cd8decaec78cc5424a8a1dee87aa82	4554
479	638b7bec7d5a812744e3428e5d49ae1337454940bddc1d2784b8b955ffbf2722	4559
480	8c173ebff8482c5bd8f69750dd8f0a6430ea24b84bea5eab80b29bcdd01a8f21	4570
481	a51a1bd9bc6db2a99a50eeded28b094d946c704c94200d37e6576306683ae52c	4571
482	bc2d0aade224a1b3267e6c9ac73bde43cdeb750edf0614738a7cca9f0dc62c59	4576
483	02edfa2a9297dc77c0613f71dbdc9e94aec0eaa56ac46750677aac4203715c0e	4596
484	2b4e527e649053b41a5e5f9a623fe99c534530ce0cd4279760794e19626987cc	4601
485	0d5aaeb1adce07ca6b60f27cf777427e721cd3a6b6599fdc1923122189c5bf96	4605
486	5d8402fbff3a588395344e12456e15d74d07ad3a6f332ad7ab7d09644c6b3038	4609
487	ac1b77be12f6faffcec30b1b8e88a077daf7a09fb0bfecb3c5711b12254dbed4	4614
488	3b67b5140a6a0e87b8334cb245d41e2494a8909364d0170fa3fbf20311481e66	4617
489	6f06f8927ed81aa967e6bb6265c05f094066b34b1d04de64774af2a7abb0829b	4619
490	42d703c797cfee4205ba6c5c0acbb426e946ce551ab0c6f7a91d943d8bef05f1	4622
491	81e9aa29ce4d2041cf3988fd198ccd16f39f1c2a08087eeca11365856892eeec	4626
492	68f2ebbac3529100b68b2fe9e93360bbe95988192e6bf5fd21f15c7aa3f715a9	4630
493	85819ace40d22b1531b15e56e78365875cfc80a55e34cebbfaf81293b9c2c862	4635
494	883422fec9070911802a9bf9d1e6b869d0788b1a825ee149926deedc5bd386e2	4649
495	ec3f38236d585898826f2ac979adb5ed7b9769c8a3e380b86a134865e7982c11	4652
496	93e11f7f3765e22851b12c49af2c2e27adecb7b25feab0bdea9da7ffc94ee655	4660
497	dc629611e293297c5e92a138b2b8bd3d26ed205bd41b98eba33568ba439984f2	4661
498	569be4a91bb5880510bec545cef159f01c7f524a6f7a561850b22de92de182f1	4696
499	efcb58f0560bbe1cd188aa9a583aa27a707775ca8f5903f55d3785da89d960e7	4716
500	c4abb882fea736961ba8639b45fb0ae8fa2fa5ec77e36c52111e867016b2570d	4720
501	8ee65f73f68107578ed7ffdc52c5eb5ee8274af1dbd4bf83299173e6cc2ed665	4721
502	90cc7b77058ec04990a01fdc9c14201fea27abc5326e39edafa591264620ef1f	4722
503	d73a7f7afcdf225eb55ef3722f095cc76715a9af3985c10591dd6b1a56db85b7	4725
504	2ea5e2f2156717d2bce795b93983341ba8f1423788fa0e89215d1b703433e67b	4749
505	e7aa599915888d07a54cc1bf3e608ecdd4f49c263862cae3e912261bdd027654	4773
506	4cd85e9cd3a0e514cddca84bab6a0f58303646901048257ffcac671cf8b01157	4783
507	ff3b801f14d28f071da0860016732997a3d10caa73d2cdeb11055a53a2f3eb57	4799
508	0d1dbeda8896c2654f6efc4990ee2bf47eaa7a0f45dbed46242f51dc06f737c4	4804
509	2a80afac8b1e3238fdba343d8b5e9be735dd3b335b17f364aa725a65fcbb8cff	4809
510	ff96951ab89baa48bfe954e719dc3d90c7900db8d9d0ba099120d7679c760976	4814
511	e74bc6d3afc46eeea96c59e9ea3b7f0c6f3bdf5d3cb4c626577f5ad40ccc5c30	4825
512	e957b9cfbd231155b29ff82bf886e8ddd176426ae37963cbdcdf0ae08ed228ca	4842
513	482c2cff9b69daf8b8030c380f6c6682c4ba2bdf2419074e96cc5e795655549b	4856
514	6592475c63d020daa3b160bcb21ea9ef63a9deb44e3bc75a55fb694d69e2adc2	4870
515	35c0b58fa459837baf693db3aca907b781e5a25ad1f2d2b2f8dab229ca1444d3	4879
516	47488d9bddb10e63baee12b6f4c0b129c418799c7ee0e4f85fad45feed9fdb95	4909
517	335822f3bba426211f16db64726733fb20acbda8dae737eac4f2558dfff93f2d	4923
518	54fff1186904cb01abad26ce869a0136aad0206130cc9154e8d767ccd335a379	4924
519	b47cf7827f7414322e0f71228c26467e7a022dd166f2f2c782256903c810a549	4930
520	9f1f00de0da05a1164f77c087399a29966335ccb36a78e152338c08f15311051	4947
521	85b54ed6c6d3ca105a645907c11f0e59f4705b31eb9a13b78dc6866ae3bd5d95	4961
522	912e29ae3362f0afe4466928376bc76ce25801e2c1414ff1cb85ef6b2da04a58	4963
523	7f43447fd2ec6abae652b9165cccbde22b0202e84a968bf2a95e768bf42a0958	4989
524	da31444b919a5606ef890b615d534b0db56e3a4d714d37c37b487c2c5fb471c6	4991
525	cd4809f45c3f1d9b6e1d3e22ae00d184bfca07595e1119c586a1bd8f4a1112dc	4996
526	836544b8f90d6bae81cdadee8b17ba160f0dfd013fc9a2ccc83f62da0a084bdb	5002
527	3e32c0b12776f7beed6abab2a6cf2dbbe09da367231514db7e4f22bee9879392	5014
528	3ee87a848c282c56eb276890cf5d250387e2425e63c75fdac6df2f3ac6beccca	5015
529	2cc73d9be9437bea96a0a6b8e72e854fec8cb85dadac5008be0b83e224a0c49e	5022
530	e04bf3c70572cd4aa1840137d15eb32896c7a546bbec9160e3c984a9055b8899	5032
531	22b800f5c2463794caf5de4ca95c53a38ddfee28a294b8d9f88e92f1c83916d7	5038
532	fd6abcb8cefba10ae524f72940e0d007c0a0b624b007afe1c63711dc267b8ee3	5042
533	1fa13080d357bd5701dcff617e975141781ee14b8ae2152b0cf796c64a30c681	5055
534	465b1f82e1e843cf973d280a67c3600c8efab902e5471c1e38294c4c00544d9c	5063
535	71ca98517ddfc0b7201dcbd14d5b4c1857250fdca9845db9e365b9284b42ccfc	5089
536	9e7d1571f3b5e38cec04489a921b91148c654b1a73b56ae92538c1f2b24c350d	5125
537	8486fae4a159a3394058d4642def56c27ad97c486126ffe374b2008f3907d2d1	5136
538	12f885029c2ef05461d38e917d1c8d392347158570b745a015459d7ff0e6d6d5	5154
539	0e7980318de4e9bb6821e6d703e5a795057b0bbfb145ffb7b266ebc25b2bbe18	5158
540	5dae102b99a62a2e739244134a9a6f687a28d077e0bcb7fab54a46b12865e33a	5166
541	0e83eb2830a84b3919d6fc0b141983f984b9dcd6cdbdac14a81eb3bb1b9e9858	5170
542	5423962c9d83c52071ec5f4047b6631bb92404fb0874dafd91c9004c4f52067e	5186
543	b56f08d5c6bcc77bac51e68d5081a40c62d2691b352a175cdbec24c6a5c1e2c3	5218
544	3d2121bbcae4e227678db68a9c74512c80556d66852a222d02a98c05e63f986a	5220
545	362d867ebe88c36a6e2abe28308f1c87e095a8768fc75dd716b87157365a7385	5246
546	3daac5aca2cfbe7f505923d08f86a8d7f36b9e7dc787e3923801367100e0f746	5254
547	87c195f07dea0518a4c1b391d585886e6466cb711feefdbce75a46c301112812	5259
548	ea5250a3045ccc4256da5b6b7b1df50b65976968fb696ba226701e001493ec1a	5273
549	d477dd52ecea1d2ba54575525a30a49c64d027bc9aaa8e91f1bc87d31c9e8057	5274
550	c92dd7078ad3f3ec69313a791af2d67b7ebc1bdca1e6c87d3f835787fd48f157	5276
551	6414a90950425dd279efc971f9036c53f20272683db875a094fd28bd0fd71a6c	5289
552	861316f172cf9088f87835c645d2acd6376b4fdcb994ef8e2691511e66ec78db	5297
553	e17453410532da3e405ff55eb95163b2220ad07a736dda95a0e8aa6aa7d3d27c	5299
554	e27ee938cb5773c35507b7058ca66d7176218607c69744e6c530def364feaea9	5301
555	628677322ba63e90264631e2a29df0a89a984d821b1b3686cd3fd43c8325a97b	5302
556	bd30fb5baacbbbab15ed5328ac5029e56bdeb053ef046d28514a7e250ef0d5bb	5315
557	cd192d049b4682e6d455c64d2e75362ec0c3699df4a78bb7d187b4674f58dcb9	5325
558	114fe97ad40a24de2fcb29677b60a6033fdbc8451f53c6833a98082e0c736ae3	5340
559	54b0675e3fd9ce39d054402383556b182d36dd67b1e0dc2c040ea4e79103f8bc	5347
560	2562900f846d595320ba41b674774376d0c147c709b3453444aabdd346551186	5354
561	f3fededbed4564be0e388d5aa4eabfb927f5b8b5518d623c3d665a6375c7a697	5363
562	4df89f34250352614c42f6ecfdcce9e9391cc42be22473a03c6051cdad648a5d	5365
563	b516f332cb23254974721b36fb13f65fe108cef8518ebd5dabba203a542fb6a5	5384
564	8d9ac5f57d04ab113a4ca3943e5c2d173190fa39e09c85f68d86455ba186daad	5404
565	0dd9c3018c22ea0cb182491ae8427542f84de3a8a2c5453dd406491ec4c756c3	5439
566	97963cf5479408729ab903887d533b7473803a1d2d8dc9102614bf0938d801b6	5466
567	7b3e999b371a9dea5f2395b0794f61dc67e9c91f66214087a13f713224a38207	5474
568	5d7b1d688ab9f64c7eecef31035baa4c91b04d1bd85b2aca1fd14f644b288101	5480
569	668a78bbc9cae15bd4c899ee2242da3bac25d44976d7e004e504ab4bfdd981ed	5487
570	f1edff3fd9d9e9b08e2d7931f981dc249a7576abae6da03af879fae2d8e78838	5489
571	6f316d528c599e38d168de38e97d3a7c4e4a8f120d535120a1ac12cc7fb1c568	5493
572	1ad0d20bf25e7fb15d633ddab009a692065f5e18152d59a5571ed0182d135406	5499
573	022fb155909b4eff3e80f4dfd44e5ccad87ec0118aaa54b0e4491d0322607607	5545
574	ee07b35971c63fb1e94fcf8f8e38c50bb8279ce9d7d6202dd1ab034bcc0a121b	5546
575	2a6c9eb9f3b4dc134a56526bec20fb0e28680a3456d02c47c6a25c666fd7b175	5548
576	f3d5db04b698b8dc4abc4875fcd6d7a9532eea24f8085392a5cf856f9a075e04	5579
577	9a0a6e9e81fd4403d7caba2fc8e7b599b3c2b5584c2e7d54cec3651aebffd4cb	5582
578	4c3b0976880da8523ff440a4d838bfd0b717011e98d01e414caf8cea7a0421b9	5583
579	9236a3cce5a5abb815985aa8fcc8c0f429f732a41885cd592a414c5d45c7e816	5590
580	cab1d97c571f2ac49155e46501758e22eda18c3ed0d6ba351e3566e68a9e5e30	5600
581	47cbd8cf7f78afde41250fcc9396dee0a932014cdfd11dc567df12f747c8e623	5606
582	f2f80819d7e1f17a07ace04582fd847ceb2b337f3f57cbf18961e0f6e3d6c2d6	5610
583	9aa370fcb280185b475e166ca9738902779c01ba4acf23c6fdae623411103eae	5612
584	faa0f832ec70cb9858bfdc6ef1fcc50651d7fbb4144252e91291ef4672a1b17c	5662
585	3a2e9b4e688d69c95c3e86d6cd51a6cf272736be1610e648c7119c9228adcb42	5667
586	069224fd0be166ff78b0d82bd88d104c790b78ef5e5b7bf09c5c399e554de1fd	5670
587	849ee67d70defab23d66b67d3b83c4acfee9e34a6dc53103a56fea14947f47a0	5679
588	bd612aee5aaa6ec645fe1f447c79957bf6959eae81b5b2f023f09eafb9605f8e	5689
589	5b4cffe40f33adcbdd335e3dead4427b1b20a51a1fc633d6fe03a7484d47c391	5693
590	e26d33de94deea5b4e91db1fb17ad110573ff9228f717e765384457f67af18d7	5702
591	69a4e03d93ad7bc79d43f49123ca21509a43ac6b782dfae7071baf35510779b9	5719
592	877c42e1b5eefdf131b3273fc57a38dbe405ef5c127a753bf71b2c1e2ac8b488	5720
593	19eacbbe956dbf19016d536dfc720d6a1f32991f8fac22155efafa9352dd9451	5740
594	9bc3c9b921b0425a4245da66092ac0b44eacb39aef954777268a2eafccee1714	5741
595	75afec80004449b0cea9191d535d061034ebf0ffa4c93499d424aa9ed5decfd5	5748
596	ade3ad9191b6f6a13d923baa90b6481fc46a22374018b7eebd748e7eefe1b32e	5749
597	355c77f6b5f2026635148d7569d9b840e5c760c9e2e0fe8cc76bd2ee7ba482d6	5754
598	408daa1f5650ce6c12d7adcdf91462d4ee1ecb0b388da88f8b84f7f2ad544de0	5780
599	9054b3cdac05640fbdc34c7e33c6d87bd7575d850eb476353667efcc3f68f14a	5804
600	ff7fddfcb0c1a8e91e57285f4992c7f8abb4ba04db7a8ef34a4d273880123219	5809
601	c9e090d17af98fa57cd8d776ff8901fea569b1b70a5de9a322d07c1d6a72974a	5817
602	877c41ea7e188702f28ec2a2e8c9384db7d3ebbd78ef9814a0a7172c746c7fbf	5836
603	bcfb5c0112a6b5dec28c2596d3e20541ea755989632f1197a30177a0c9f60b17	5850
604	4aa44db76f182b6cca4f0dc78127ce9866ef2ecf643fdd3db6bae96eb84ab253	5862
605	9033daf8ace2c7d598c0cf5f4e65bd1d2670974acb0239e2e52a184def903ce4	5874
606	ba5726250aaa09f2cb98fe6311d9c31000b40f06e4d63de1decfd43f11621e4f	5878
607	0b2aa6057058abce46f0044896744f5ba9ac12974b915dcb8625422e6f20a931	5891
608	21a48e0d936a70a019b4d8ea7b8d6a83f279d1caa75673fd4519123e43e6e4bc	5892
609	4dad970b3000144b4378ee9b8af5f3322b30b4a7cfdbce6d004b3fafad8d8fd8	5908
610	f835d0e489cbc6f0c623f03ffa457b9daed80e42ef3c2f221e8ee310a3a6b290	5916
611	f1014bc6ddcebd845ba9fa4abaeb6e875d7527deeb7ecb6e6904e9615992ebc2	5952
612	96788960eff9f625423e8160da26d2ca547c1177862b957e39b2d6288685e026	5956
613	4642e031c5d879c469a1645182b75c2747d6c7580eef98e4e75ab49494d6961e	5979
614	eca05e3a333c3bd65665454661e3c6f283f4d3d95d27b8dee11a11545b6f4bd1	5987
615	6b07f12dc1dea70d2804de23d141b75eb7d9464a38950a4319ef30fea5c39411	6002
616	b9756938e7e6084d8aff747ae2ab0bccd6db61f389d0d727c057ad467f98d366	6007
617	5682a184f99a519174a53d92a69ceee9aec09ac3baa5b53296aecf73ece6b179	6011
618	839f39cb0498ecc136cf4240adfae8b9773e18e3d3e625618363eb01dd0beee5	6025
619	14179f0c1373b98199a6fa1f9384bb4d400a5f7fd68ce92a7dcf1d3e6e0d0d7c	6065
620	bd446949c80e86d33aa1aa38306cb2a17d65853f311c46c85fd1112e71d5faf1	6073
621	a4b0461513df1d40f8c2354cb352f954c1eb2fe098c1e0879da214e636fe1347	6090
622	9f8c5f5e9d20a1ee3063160c801213a5f69a15bbf8e9cd20f978977a2f6eaa15	6103
623	42fe7ba0ddd5ddba46ba727e0efe7c8d550ca805d9319118190519b2452928ec	6113
624	c39fa9ea0a913e3735994d7c6a37eaf62ce81e944f366fd3dd9c49ab3f848c49	6122
625	6c9e0ff444721aa44458271fd00b3259bba5c9d7c56641ab399e9469207b9cb6	6145
626	c24675649764d601c8fc5fd0958c971abfeeaae15b8dbbf499d3dee7cd835b02	6148
627	91f817ba3ff6616f9bdd7dae6de202c1add20edf99de27b59b5a890a423132c2	6163
628	2077ee7de5672a87884c634cc32e7390e7bc9422509d43ce2f303c20fce87617	6173
629	9f7a1ddfe35479d2507627aa9bcd50791751a89ee12ba1c0b76ce2004ef7e2b1	6177
630	4d73658cebb5eacc3489a1a47878e13ff7a1326fb9d8882c4cc1e865fe0ee260	6185
631	86b18b1772034d955bdfcda9dc787cc21d4758cb9796c5f4c42440459edadffe	6189
632	cbcc10a4b1968f776ee06a61b5e63cf65edebf9eabd52efa38f40b142c014269	6201
633	c9b44b262d35f4d305a90c4a7218c6543076cfa3773d79834e1c52311209233f	6211
634	8ccd6acc56c60e568065af8d867d3af8ec205c5c6a268d728482802598e7314d	6246
635	2a90301094a94d80efb3a50e1fa1e95042f6394d95ca26127c9eab261e4b0699	6277
636	f4ba52c511908e460bbdeadfa197663e0dcf2de50d0f7c7652a15a0d6da93ad1	6307
637	31f80fa8963e577426817bdedf5445815bec4de3c0df971f3e7fa3978122cc91	6316
638	33a3fcb3bbf7302bdbe555dce81247ff90838a48b8c2d7c387a0e6973e934c53	6319
639	a11d6fd10637fb3bd908e8492fd200b1e44437a126057988458931437e1931ae	6329
640	3c15f053b140fa5850b1d069825dde5c901ee219704358135579ddd5264b734a	6359
641	035d667e34138e7e41163b798f49231931e8a7bac6a235d1399078c1cb727e88	6372
642	fd8251fec3e95e0e518fa3719c1cfa889b28ecdc73eed3001517f9f156a4f5c7	6388
643	c6416d774e69394dd022b3fd63d957c4b6219982c56f37feb9ce4ff14d452237	6390
644	762e493fc4028a8cf9ff284f38285d8be763015ff1991ab1ca4072dd40a58a98	6406
645	22f8c41129d1e45d8112c0748d73a9c72a9a00958ee7854a90629217f13f0924	6409
646	70ae0b9eaf8fa97f568477c9c1a546dfe24dd8d07d9c5b31a44ac4cc3f109349	6412
647	d295ae64d8a8287a43321984b4e0ce371479c60ea62be020e1fa7fde04ed881f	6427
648	3c0c23e9ba0621112d49b4a64d1e8b46ae1d74033d9d2ce480e3f7da06a0cc63	6428
649	82ccc7de605a9fe723140c399334c56df56d3415992ba112bb4e9694979ed974	6436
650	c3efda28ba63c2dddd3f363e5ee71b661434d217e6f7dab2f341cb9170b2b733	6443
651	13f2a453d2284440ef6122285dfa42bbb2689e53e9facfd5afeac3e844fe2b34	6447
652	b6d0b67b8880ab6614c7b215624f6da934fc5fcaefc49a9517332ccfae4840d0	6476
653	dee55249ecb1a45e9a1bbd0e2582360512aed958a16a2ea19e8b91b123c2b67d	6483
654	669222a72343b11def6b4dc010bcdd08ad6cd0d08e7e3253c2fed53031d49291	6485
655	6bb5dd6e16b687f190cbb0045d87c2c0c9eb53a56fa44288c1b5cd4216121c49	6509
656	d0b3b498b12dd9c416e08ed49c15b5e78972ace071baa94ea574528a8c5667e0	6514
657	5fc44a639ddd3219a6735061b4d77c7da00a30bc0547df36565f7b043d90bb7c	6528
658	f965e9bcb3920f5dbb1f011d42d53cbcdae8f26541e917be3928d6555e61e182	6535
659	b27803028f0c8b79d78ab8c4a486ec13498739aed3dfd1b5a94aa41fbe2579e5	6540
660	ef174b44af4267e8b54547f26152cee381e301e5b51c4eeb9eddced71cf25bc1	6547
661	34b81519b537db6bb89d88dc73cc1d24c7ee526715d223da7be1ad669bf23429	6549
662	9213947c0ea52ac44afb7b6ed50e19f46f27a6bdbf69e053786e2c8e106dc388	6555
663	74716f5e797ef61e29e6c2ea3cb67bc0bc0c392439fd92667fe554b9a708ae2f	6562
664	9278093b09db8c902eabfd6059d3a7c07c724d8a743220ca6459c8159f879484	6565
665	9355c2ac4c60b484447d358565b089866c58484202724d5a0c6e1f9d92f55c2f	6567
666	904651683245163eb99fca12284d3a5e4671efa872563c104856992fa01a6f42	6578
667	ca264e544410c78ba1cb6bd3526e41eb1d9a64c4026c8e6bb09fc2ff7a743c42	6595
668	9e20fb5ec6fa0b706054a15e4054ed20fc7e92d22cab8bdc15045ec09a71b3f5	6605
669	8beb91213ea0d4aa36d17b34adc89ff919591b540b4fbe4e13ccdeec3f7587df	6610
670	e4da8e52783d860de30f23ab38fe9f91cf12b45894d532cd3999951a8ea74a8c	6617
671	c5979c01c94adccc8df71a8d23a0ce9e1c6c6d2009a698aaa5ba10d2ee171e8f	6630
672	9d4553396207e1e3dc289513ba7026c369352af6c39583d657c98785f934a453	6636
673	cf96567e39e4a9b4bedd7d8da3afd44f85c53d749ca9e173cb0892182a0e2f87	6642
674	3b6c9e4663669eb644bc9d13afe0bd6d66c74c5f4e6d4ae6696868173b97da4c	6650
675	ff95cf375a9d17382138b0c449890afc414832dec9368613a3701ebe2eb53063	6667
676	8c257998d0c216dcee14f1e96d3031f8d7cbb75479765993de8efcba63d0ab0a	6686
677	5edb5ab645d6117fc10c274ddb8b76baee14fa799b8da6d75b8a720785ad032f	6688
678	ae69c4d13917c049cdcc19fbd5e101e1f832fcdfa0e0f39372259c5795986ca8	6699
679	09c275a4887b4059eb26745d22830e061ddda2155e85d76e2e724e037b7c296c	6722
680	06374b2871ccccafb58131849e4cd290b3ac8caeb024fd4747ec21d1a7fa266e	6727
681	5f83d93f4fe717214a0b9887dd7c43f1a2b3a79fce1f98fc865e65f501a19d22	6733
682	ab99aabc687e1dc50e459462f1f2ba1ca19399bac4b71ddb390b1bf038fe6d33	6739
683	43fa07a1ec7d03f6a2428c58638bc20d12852a3855153440a9bc49d4d024c5a0	6743
684	6b4a4817680ca9cb4f64c4fc1c4f0935eb48466f181741ef74269a1e60cc6655	6744
685	b850bb54d5cfe3c9e272c530f144ac3876a9cb8ac74b7bb27224e746ea318552	6745
686	0d084565e89c06ed6e45614f745d596a9f1592d7328c70a19789418b272dba14	6757
687	dcd1136d0f64d3cb8b1d2dc8cf1f5866189605486cfe5899a08d318907106f12	6761
688	c6e6bf0fc9a4c25a5527d1877b63e4d4e9ea682a3e32e833b1c4ee9e3f16690d	6763
689	c2fe792464eda4cf33f1fd949402742b65041727d4921bf2769172157dc9ba11	6768
690	bfd2dd5f5a83b7d82fe91843fd0f2188a482e00c78db6d4d451483542ea2a816	6795
691	233aa05e0149bf028d1b9f15e67736be3b9f1079d51ff26c03e0e57dabbc4576	6807
692	af376eeb4ccc8c22d49d79e707ef2dbdb86c7f8fbd13f779db5de5e2eba64d89	6821
693	0b18f99e36bc5eae500c384fe92be5442090c0b7b2f5c5bfda2e16665eecfacd	6826
694	ef9b02908d0d62a0189533a1bb7065076f2551b6e14efd399594123b6ac96e6c	6834
695	f59d6e896cc74acca6a7120a485ef4013a576adbbf4525e33d8a6225ad73dad8	6838
696	44a0e3299ee7104b687384ca8ceb75f766622cd954c3650df294a26a81f2f523	6842
697	ae459805c86c882aeb753b071e2f1b6278edcb48bc1becc56bdd45837fdfd730	6855
698	ca81653154f8ec1af7a6b74bd750b93bf1736d58f467d3005e7c8cb472c5332c	6860
699	6dd3c4baaa9d433c7e6d788ecdab046e7f7945318323a0dccf02f0c10d29d0b1	6868
700	6fb7e623153dad2a945199f3784326bfdd26ecdd6bf3ede863d6852b49990708	6903
701	3b7752f605c6f5b1c3e0fdff417dab43ffb19d90774681162ceb7ec3a7b1274c	6912
702	56a362949e6c806fa50a98c0d5c799f1785226de651f6070ad63ff8d1a7860ec	6914
703	af6a79c6264a846869944128743759a539a908493cb8761c055be59e389f6028	6923
704	e940c963581cc293f2d598fff0ac6495968a482b233218349cbd0e4fded5cd61	6938
705	2b80c347d54eab12e43791cb35fc3e1549f0ba8d761595f97e0a2d028b225a92	6966
706	a8ca0676dda95c74e3a8d3a69dfeac93ee6328297ec60f818087c067b8b84f11	6973
707	f4c5be6d3a19becf8fe2254053f74a1de70c6b028984167f70baeb9c93b54a15	6983
708	24a2672aa6f58128e0c3698bf501a9251ac30a9e7d701ef8a6a43298f1258ab4	6988
709	5bf6ff99b5182bfb22cc3c96a1e4a518e9a909a9b03c6daebd6d3ac8ecf95a1c	6996
710	9cc090e2adfbd46c99a133cbb7109785bf82a22baa3720ab2caf72398e0df456	7007
711	8715ec2a5d992ac36fae817a28860260884962f6170985651eb6dbdc0dc7355d	7011
712	3e3f9b17d63615061eafafc5641ae8e9761aee4a208c557c4ca1781cf621a635	7023
713	4431d4a6a194893f4fa443c8dad1715645e179f2ab0be832ef0fe450ebafb486	7032
714	5a8030cebcd502d27c5f84510a75625e8ae0fb8b8b515570d3bbf9f4c58f2dde	7041
715	1521e1673d953dddeca254cdf20d639db0bedcdef9fdaa5059e0e58b9fe4bf62	7050
716	7db908f194790b23eef7bd2dfeaa98277f6c5cf888b6818bd06fdd0fc5f387c1	7063
717	26f19f62ae15dc00599d449d0967459b6bb3f8e8d1e8a56ab3e89fcd2411f9cb	7069
718	1e50322780143cc43c5096ee9d37e135dd23825d6e1993fae6ea3cb595759a90	7077
719	2e178d4a249d5b4fabdda434b8b0df00b679c0e681953b7955585e0df397b248	7093
720	f6ae95c58c99e3a60d61b7fa47648c02aa6fb7bfeeaa72bec8b10f9b9a4f093d	7104
721	8c91232c23805ada0993e9f0e23093959fe0f099f2ced38b835132d306f80533	7127
722	144c12694af96fe05d6492d9a0465a2b34ec9b082d474297c3443b054c4587d7	7130
723	7f6fd93ebd8fc58513a94c18a140d819e8cdfab5bda944df50ffed45bd215c19	7134
724	f43becfffeb55df5dbb1600b534b5ba402baa9dc1fc51b1d3e758494b9899f7a	7137
725	da84aa55ade00b7f9cce15103b5d2d5b9c633c279743ee4cce35438f8a4957be	7146
726	cf262ad3fa31908c085e0edef900107871100b4836ce0f7ccdb6bfce39508b8d	7156
727	18dfde14b3276a2f408962736aae2cbcb2226bbe5d9a54ba9fa33803ac777e09	7168
728	35339cf1352e4306f19efa4e963888219c6ecd484a5a09075b844b461dd1818e	7185
729	7cacf677a08e5b47a1f9afe59ab92501d6661cf4b15129d326b45ea94b05336b	7192
730	2e7358dec2bfd13f2d1ba5628ad3c17eee02f623ecdeb36c441457f880488b5c	7218
731	5d25ac56a4c617f244bc6953b5a16ba6fe1ee0848d5c9194bb84a4206d09b1cf	7239
732	78ff5eba604b2bc5d4785a05ceac5a449058d9aff5a01e901eb9f8b72ad8960d	7241
733	466b4a43df490580696b4783247d1f32a32eb10722e9c731892c53ecdf605fa0	7250
734	aa10d78c3028d9c2508ce710d62a67400943887b4105087a6786ba7c37ce6ae7	7254
735	d10e8dcd61f65adcc34dc52fa0024caa871318878907bcd920cf8bfd7c52029c	7278
736	5b494b298a3182539227f8bda54f47fe212ede9e05e33de3b2fe2ce9a97824af	7290
737	fbb61f23e6047b4690b2bf985ee9a013cff0e992791fd78e72f5891434b5487d	7309
738	87619d1fede87cdd929482fbacdb48e075d58d506628b55677edf312f26c9589	7311
739	c85e719de8876e4ab7b9f3cca9592348d52933af5345b56da3f5cccc489020c8	7313
740	8cd98187ded67f6396ff30c0211d6b189970a1de1b8a7536d6ba623d2aadd5a4	7320
741	2fc53c20075d8ef22af060957307f8dfde9f3c4d7fd16e076f6d4edc91e821f7	7337
742	771e98bea81ef556d63fd49476c3b3b31cf9e5db2c5b322ab49560e5b1442594	7338
743	aaa3cfe29a016860c47ecb5a950c3d96b5bd8cffd5c4e752e219612d7d46992e	7342
744	77325c3aeff3e863e04ac7906f4c38f2d4b23f69592fd27cd1794a2ebecaa562	7347
745	be68134fc6c66df7ecf833ec3a2675c139e575f9400b5172e68393d55e046974	7358
746	24618462a9c11a19c6a58c9cab5c4e94047b368375bcc065c85018f5c6100de8	7364
747	3c5c684e8ffe9381cd5e9eb5c05af2d469b8fa9c144e917e70a04b7030e99ab1	7367
748	a4d2b0fa49b764626a5ab923fd2b4c6b1a38806efc527b452dd6788a82b7feb0	7368
749	dad4499067d480f2b68f7e0e57d23af37f391956b073d05a2a72dd799e1d2bf1	7373
750	bd174fef0b30c511b08fdaef543907637fa438aae0086048e1465b8db1fdbb5e	7391
751	5d4d661aecccc18bee96b027507300fd79196bc94af6e670d0ecab57e15f1b17	7393
752	8074b9298a666545788c421a9f53137b97bc81773a31cf7c9d9827dce3732175	7394
753	5ad366df474cab43336b6a73ba9c7a2ffac454e8eee55704bb1ae6a8c2d03114	7396
754	00cbe7523de6c4d5b0a86a3b6b21740681e16679f2b39b0a673b6ce745806c2f	7398
755	bb7b0fdacb0a284007c5ee08231146a3c88cbd1b118856b0c8dc3b98c52003ee	7399
756	55352c8b3985b23b10adecab6fc1f2d1db94631fe75ed80ff31935b9cf832baa	7437
757	8ffa36fb2a9373d5cc8b3b9ec906cacaae623eaf8390d0eabfe92da2cbc20aa4	7443
758	62ec78abda4e46b64a7cc4036aad88bc45f8f51aa2db8a433592321c34fe26ea	7447
759	fdd17acc16687ed0e981f0baacd6c852de064c983936bccf7b94c65a51ae7990	7452
760	1ed8f3608a3f9fc0293a948dcb1d5012ca8a5920f5f602058768ecc167bbfee2	7459
761	4c1fac8ed4ae94ba23fd8f961537c34257d67977d6dc39ba13153b7bc7fe3ae7	7461
762	983cb6a6771af2e03731884ed421e12d5e3c1e67eaf911bdfca33e98d9dce091	7466
763	50e400460da4cb34d4c033e475ac428964195abbf7e95764355ed2efb43749da	7468
764	7716e43b6ba4623535f8d36aae4bd128b124798815735c6547f5f14e17af5022	7475
765	722e8938783cb62750b24e688ff4804d28dd07f11f3e1528b652f1880fe0fff1	7477
766	749c6b271ca4ab4aca27be7d022cddff5fd5e149c55364246a166f5b797600a5	7478
767	3b1820ddc1642c39ae417a79fdc785bfda6739dd303ae35db3e02ab5fbe74bd6	7500
768	76f37f9e5f1f0a241872adc3671b4a824d65cbdce389cb66354c0a52816ec3b0	7529
769	5b416c9f3f09c1278ca61a59f1a4196b707a5bbda68a87cde2dc3d129d2f8f5b	7530
770	4ecd80d828857be8af15e5febb7a20fc183fe5e8b5c9c42589c4dcd75b25d857	7533
771	b7aa89848aa6ec2e4bf5e6dc350a4c74349fe0e3269d596113b067e17bfa71cd	7539
772	81a433d69a3f845dc768c0b94bc9ec3b0f883dfb62d4e0ef0d22f5e35e18d7a8	7561
773	339c426b2cb8ac78d409dabeaf4d63fb8d156e1c43306a2acfd4a6c0e2227c75	7570
774	8bc3a3968dcf158d2cb778d271028392f521cc4f0c3acbdd06e9f9123ae90d47	7579
775	39ae01c729622c53eebf91b4400234afc6909d851bbef92855416a857720ab28	7589
776	00565eaea378aebf441cbf52eb4e3126522a34f7ad1993b8ab854e74cb4b847b	7596
777	e4351d8ca6dba3128f5067a0148be9a687d8be455df6f8851da4dac50dd45cf4	7600
778	617b9b02a089853296e33780bd1e55d3a3a823eb203e8250082623b8479046ae	7605
779	13afc6b26544cfb5336cc895956ab6b350f21a3fd4d80d79ed75b4fc04049b3e	7612
780	c485cd1ceae5f8365848304bdfc6e404bd66740af2b8c2887d9d0cea726d6d28	7618
781	5a4fd0c5c5b162fee4888ae008721c7e88abcb4d15f28c2f8cf10b0902afd3dc	7623
782	b3a0da6599d9fa91517f34d7a6c070e4f3037d279f47638dc5f1f1887bb73836	7640
783	f50a2f424e813df8f10b28d2a885712672cfa4143e1ba0aed8a2c8e47e59e953	7650
784	fb7067ae37e48d79cd55ec98715ea79d45279487bd70b353c6d88a5a4f2c8e44	7669
785	3baaf291a5f24a703cb32e57ee202e8218013df298473af130392f8b0563879d	7684
786	fc873b600f93294d136bae48c77a503cb67c55b1cdffb3f87cb2e480202453f6	7693
787	e3f7c4a3f6ed7e969e96a7a1961170d74dc9b3a1ed0e8271f87ad2a618d02ad1	7696
788	a6913e1e3a565138d554d6306b76b1466c34cf766798bff48bbfc6dddd3761de	7701
789	6a88373d1309158498feae5a6426a7e02773803c6f87c088a099ddc7ccc267c6	7708
790	010a0310745159d3bed2e64102ee33cb6619e1fd32e04913c51eb5198101eb48	7735
791	aa4be9a1b93a1ed0aa4034f7c38797aa40fe3223377fb28b2c4e9dafa541897f	7745
792	afd8e4726b4b9c4544f69e0871c8577adfa6ce9d4240bd80f31520ed500d8fa7	7747
793	32483b95ccc5ea64ca24e5dc0ac9532689cf11e519c3be2d470058e5b24b9760	7749
794	5b1b93aabc0ea152adaf243e0ac0c3a480a853a6b1cb458081460c227a54cdc6	7764
795	579b64dabaf33003bfe672ba6fc55f5ed655b12828bbe6dc3e773a81e4da07f1	7769
796	6963005a8c262070c3c6ea43211eded6b456320b7c794eebada0a86fcd391069	7790
797	d2a45db7ada73861bb13509b0f287bc5991c6e13a6e0d866ed5e76d3ee490e49	7800
798	d44614e5b66445f69792e19b9132169dacc6ec2d5de360490df8b7ca56f887b8	7809
799	8ce6bb6fb78ce6fdb780f18d58f72accc9a4094904cfe45b4e23e4f96af60883	7815
800	c8ca2f6e1cc605c5b6348c7be31d1480efde08295e0b8c7de7b8c166669330ce	7818
801	72d89d9c1508a77b0d5557d9a890d35b02628fdd3f210cc9df9652e0c400cb02	7840
802	c4da0a9f75c5060fd4f68003e87d7031a3aeca33c442332046497621801bd4e4	7843
803	79bb6a0b4995b46f13c3588d2e8ea35db2350aae8b84908d3bccf4080a1ff655	7859
804	e91fe2e3314a9ab8bda08ea6b94ae9c3c818124e5358f30c09c1b96aafdf535a	7866
805	298327f46362bf7b6e62d6c811a23d34d4cd498001327025ee0a92e0e68578de	7867
806	391841b1aeafba2fee772c30774049429101ea6d7ca9809ac0c699f721ca49e4	7874
807	95fb8bbf4db3fe98840ade836030d72cb592f899fc24e442749f31484a4d829f	7886
808	3733f6d2b81075c258123747cf060f49c629d364794d0814eb6826e8e03bf400	7892
809	5e34bf44e5a7368451c55c428632f76570766e2b8c7d0216856f7e0a882096bd	7895
810	c88b6526c865979ff449495314f91e38264b03131a7030f0714abbdc31b1c50a	7897
811	06dbbd0eccb8fd712df47b2b85ab1fe0c50e74839579012d89ce3d982af288b5	7900
812	990fc2b412682f00c362c5fff27a5811f72c3ab026103ad46365778fbe1880ab	7906
813	918e686d46819f7a0505ba7d70fdd07a6a6c988ac02057395753b833399d4198	7922
814	c09b586b79b6fffb912fce9c899b41692ec1d64a80239ff4157d339b6a92171f	7926
815	fb299ef597bbb08f6d3c782ad268fc6505c6b2ed5771e2693a4308b894f90971	7928
816	653e08d894d39b9b792da2851da4a874e0437398b2307a314237311826a178ab	7931
817	35b499a695f7736b93f5ffb6ac89b8664009a65514255c0bfd84329bfe2934c7	7937
818	f5e684155a4d5f5bed0a6fa5ba56c161dacf4ff17688ae6769a6da80ce3ba7d0	7947
819	7956ff9ffa22dda9f690586e13a591ea6dcf80fb59a354c3bb5703381a24f0c0	7949
820	1790ee472d3557764e1c8cce55de7b52128f1a444fc71f51fbf835f5ba5136e4	8013
821	c57bfb36f393d9af7df8d6eb9634d347c41ae8f8d484de0d38cfa90a090a11b8	8025
822	0ba6926b217d0dc6f46cfc18792050ded0437a8ff4c96e7cd96acfeaed187ef3	8027
823	b499a1d992977cb2c47d30076fdcc2c182a648e67f43acd31e6f8c56398a1760	8030
824	a792bed55c98140bb7b105d43f8be4b9557ec33932a6daab874cd84285a42fa0	8053
825	765e2eefa5fd3ced0f59b313abc31b8e12b01089d619ae67446fc5f27cb90cc0	8055
826	188c7e9abd3261740c42e8b52281119ce1f9f154b21844e49a5caf762840d5a6	8058
827	e3b7408d287fd44a848fb575f283a3576741ed8349cec451dbceff770734273b	8060
828	8009dcc9df6206697385e8c379f2161f2f9e3f0340c0003756c6189b6c9e0225	8071
829	962ed2efa88c83cd86c4d52bbccdb6cfac12b1d612e700d73ddb09eb42bf3857	8077
830	083964be385c8d75c051382d5e0367f3657dfb74f635d407e89445249d2ee035	8086
831	729120ec973d25a344d43ff527649686f9e7740983a94b00a517087d810a0d10	8108
832	e03fb227fe8313637144219c0740b7fc588d5e7877f7a28760a4d8ce4800c657	8118
833	4f1620001886778545935144b2c45f184b38f6e452c21737265d4be3f74f1d1a	8139
834	1ffb27bb2d934d059f49ffe7f111c09a3ae93a22d924b32376755e0bae7ad358	8162
835	e392ba8782f877466de1c30fdc4c7c9773b5a4b9dabbd7cc1e2151d037376659	8182
836	3c28f81b755364a2b7d513bee68831d0fc4e9065adc32cbdbe0f8b2eb4953135	8196
837	1204e9f8dc9c73e6f807f1a5d97387875a6516e6f118ee497f19bc86a30c31fd	8200
838	1c13532f8e2e2ca24baa727b67422f7bb3ac79c27030ff8928e258412d5908b6	8223
839	d32006596c282bb3c9a05ef3c28ce519ac73fb228cda369645ab9b720daa1980	8240
840	9cb93d9282d94869639ec5683c4700b2ae8c6c0cc444934715d45284012a10a7	8253
841	8179118c9ee0be763d29eb80e88d66afdb2c867b327cdf335c0d4229b9ce265f	8279
842	ba14e8495bcf7de673e71ef053820e018470f42f286686d7c47d7325b308ab94	8292
843	3f51f975c41a2ee8f9b26f28b7ff75d65ccda77f773f88c29e3087304d1bb746	8294
844	2175bc2fc394ebbc51a241213b96f9d456d9443204a13fc38a3c6cd2ad0b8486	8315
845	4290014883a7a1b6a92ad5ca9ec1f0eef361b7ebec8b2d5858feed5bedebe263	8333
846	a2ca497d7e68c23eba93fef04a6d2fa962cf65c89f129665cfa1829ab3f9da00	8354
847	9a5782a18996c427c65f3818fc7c5607af3dca9735a2519962a9dcd79f3c6550	8357
848	98efc6df23e3bdef35faa6d9ca14f731fe6b3742b3dab1e9b834f4bd08890490	8383
849	12a3b23353f1879487ed7eebc560f7b3cda9f32c75cf902b25f12196cb0418bd	8388
850	022542596139765d225d894aa761f9c4c6da857f808023fd4514406efa53ed05	8412
851	efd51ce4011c62df269d40a2a19ad1e6affa4504e608f23a0b32c94a7c6b76b9	8416
852	f4f44d68e3d0711fd0d90f04b30048c82d4114ce4d7044b4f28a9a7fd10a6280	8428
853	42320ce29525d75259b53cc9e6d88a4ed9cfe26d694ce484d8a9e8b194a8d0e6	8429
854	f05bb99b308b440cf27a6244f417edee2be4d0bcd297f430408fb9d260a86756	8435
855	eea03c8ce638bc79af550860ee35967be508998940c60f425f77a12c9fe00653	8447
856	c440ad76bc62b25e2feed510d8f2bc638f551191776f07d28f4898dc04686239	8454
857	c520a50e2f165f2bd9c940a64619fef273e5d80383b5702ffea3032ea604b2d0	8460
858	4aaac8fcea0c250d804612f662840e3f86dc88510ea0ec0473536ddeec684aeb	8463
859	9a3a7de825b3ecca9dffd5cd71785946217603197fd283b17b07aa5da94c8252	8493
860	8f8a3a962b609454b5a89981cf2d78e8f21f345306d4bf9846bb7ed201206032	8495
861	34ac8336a463be04753a33ab6b7c96cf142fa5f846dfea17282925c1ffcb08f6	8497
862	2d00e19bd4c497bf27ec0253d657106d149efff2781429c7d819fac0cc7d5e5f	8498
863	5badcf00e362875b27fc161aed477b8c4aa4396a3d23c694d6f34ea20404f0f8	8502
864	ca5060a54b3d28fa78eb4b9bf719bf90ea01e1c63e521d46a72de8285e0fbb9f	8503
865	e4a0835842436c103792bc06209c89c9b4eff0fbbff35a4eb2f3db8ebfc04437	8505
866	71aad68480f1cb3a2e4455f3708419c4cd0c032a7d08638b4576ecbbb88a4e61	8515
867	8d54cb97c930a69e1ee639699b00628642921ff320a72a4798b1ed37a9f34b61	8518
868	d00c8e57abeb4993c4265108c06c9baad103429bb999151feb54eea8ac827586	8533
869	08a87ab7ba40e2de94c2a658bf559ebfcd589f7c452d3064c453918d8fe03bc1	8534
870	918468a1e711ea37bc5bf03aca061f2b04ae75ee93faf61dc9a9a426e8421f98	8536
871	b665dc77485936a31d6d0ef2a50884f07b5f62f9a6dbda9a7e97dce7ab0195cc	8545
872	06dc3a4dd32101344e0887d6372cee23c5e0524de97815ad9e0837d23326238d	8549
873	6f05a5a5d45af338305e1bcc6b14b225e6bb848eea0525a6f3440465286812b8	8556
874	b9ee104f34205a45d3e72bc2413ec188b1b7b451180125172eb04d105d4df5f7	8559
875	a8982a263469dac341b40ce0dcdc3caccda0d01203ef8f132c8ff71134b3e149	8561
876	5b10558dc20a99b0c2757af69295e054d350e4e59c14f556343f62fd07f2bb88	8567
877	e9fe403cb4ac79e3a7cf34a8adca1692786c5417dc1d51086236f7e0901063f5	8577
878	b96efb65bfffae95fe5394c95fcfd3a454ae8b171e87c4442ba1823241d64efe	8580
879	ab564edf23074738d44042536485a21023233476e4827da7a769a3b86fc68930	8595
880	ab959ebd66b0342e378c1b361ad33db3c0a944ac15cf02c839a8ad261a0ad078	8601
881	c803050f9af8ea02e1241cd58a59dc8603ea40cb0f3dfca927b1f1e29c7be952	8624
882	ab2debc67ecc1d38f8fbad492f69f8800269e138134d140d7b061e20ed82a9a0	8636
883	2f9697fd91eb1602094afbe036a7cb59fd5fc24c818e6c0efdda299def8ea5df	8639
884	5e67d3e3d8af31ad328dbd3c1d0a3e80b8a53bf83d7d4613d4e72272f9c7f1f9	8669
885	1456a0d9ab0ac85e050a500d9d8fa8d71a25f8ca18b455cdfb30562be9abbfb2	8675
886	2bb5012b47cb105b412bfee006707c22fce9469205d3dcdca6c99eeb252c714b	8681
887	cac7f3eb664ba041b5646cc10891bd6cb3b7d1d707fdcb1ceb976e893ed4248e	8686
888	eb2e65ba6f1eec96e2ef82696356b2fea1bca3802c5de89b94f0a8a551668226	8692
889	f0caa45895fe780bd01e7625dd156cacf5f3af2b3af9c6a057126d29126c2c60	8729
890	21d0f01d43a7474d12141ffe407f30e6e18dcf944de5ceec37bf884d598a2a52	8741
891	99bb7ede2856d4d5d9f58440f53bbedc8fa50e9e1f0e1cf597d6ba2759a8e4bc	8744
892	75901c8544b3421a3e9a53e359495d2d2b6d0449070daa069f8d528a4d5d10cf	8745
893	df9b321aa708f0422f690c76baaa1dec6bf72449da7661173bb1643377c0ba0c	8751
894	ae98eb9fb5b422dc159d039c8dcac99e96ca00baa34cbc6aff7affbec4c6cac1	8755
895	73cfc96d485771fda33ee021aadae836b93ade1f7dadc8e48d4467ff24ac811f	8757
896	75f9c1f13ca142a81e91b713168fb100ba79c174e1fdf57a56f4ee1d19addb97	8779
897	5b07eeb86c956100d01aaa17d1bc8912fb120738dd945443e33280edf4a264e9	8783
898	576a8f74056a51851b20b6fba956ddbb4e9fa1d5c3a3c756db8b2987ba0f42dc	8797
899	e03191dc64cfdd69b962db5d6e5800248c6a3b3aa6dba35936ea9005cadf6da9	8800
900	a78c120ae9a4d20f72480868d68508b281f4a5c9064ce97112ae590b45e4c7c6	8801
901	fb3ccbd460baae00b9590e9b8817ad4cf7b4d4d619dc60bd947c877ac52bacbd	8820
902	11c40887c49325348eccbfa187e4d2af9a7aad1c24b7641a65b97579cb437bfd	8840
903	7fac36631a2a3dab8ef1927cacf0d8b465ec68d474f2b7ede37dc36592d9b8b3	8851
904	b4bc0469ec6b3a949ec7dbf6325876f540e27482832f99115cb24d1b6fbbf7d0	8861
905	8d77b12f5d4633d324a6cad86bdea0e61200ee762ddf8ab0a122287fd686ed18	8892
906	aec76b9de83e3e12d2627ff8a30a4319e6cbb9ecbbd0e2ba86d64240e002c117	8899
907	d0b08bcee2ad962ef402f3949f18a67d89b63d5579971a97273626cf16f8827d	8902
908	044dce73b2c758b13503af9bf8988f3b4c68960965c349764ed13655436d869e	8910
909	bbc2d74d0b8f55579051d8ce16978a3c53f6ba87fc5e4ab774c384543b7a34d5	8912
910	158043ff65a5843685a36b4e3e9c7e8e4e471be4ce3c0357692c11568e8d4fc7	8913
911	cc9822c3cc56f91a7633f09d12d7e764c9eb3aaebb3fa3b4ef39cf2f36829bee	8934
912	61076b6947b042052261b51b8c364a75c29df2ed139d5cc787c53459aa37fb83	8937
913	7716ec413d5959cfaeb89777359496f864ae0ca088460606e6b7f24984ed8dad	8946
914	ca89941161e0e25c0b3a811faa1648ad4ab77b30e78afd3ea62f3fe9cb653fd4	8950
915	b18915e38a57f4ec8c29d4da05e8b4c539d604fbbe65cc5696ba3a776b092cb0	8954
916	6f391c24a5077266abfd9cff2a5d943f256d3cbdb2c222126aab1fc989920e64	8961
917	809618f351dba8d2d0a58d314a34073305e51b4f1ccd25e474f05cc1bf4df80a	8979
918	0755ebb7a59bd35272ca3a18fcf52b22118ec75c4712392aa0ca70892c25f3dd	8984
919	5a118af485194ec9bd7fd53ce5303d287848df1c1520a384ebe54beb958a8ad3	8988
920	bae76d0802447c741745d1154f4333a82b4d4d5fe0dbbbd0e3c5e7252007b565	8991
921	0608abd2f059a4c2d506d903fd33de557dc7f968b6f5c4f651731ba21efa4d29	9014
922	62d666fa27c928c71a7b253a05652f903393f14230854dbe782c9fb9eb30a89f	9029
923	9caac2252b54be0ee5eddefbd22f54f5b22f584f111c906daf07cf3a84dd3926	9049
924	7d292fda3adc17a519116f0ba92f6e14afe54ca968f8459089e37783f10560ce	9054
925	3c496c5d1568cd78787f4d7c5ffa9651f5504bd352f7f4b6f8b0e715cb710fb5	9066
926	089010a27fd41069f963de5b4b3e9d1efb8af956f643bc759072ee6f009fcd26	9072
927	51417d671b5187a5a9caf6f9a3ba309a330fb18ebd504d9e9aed6abe251ba3ca	9088
928	24a70c7ac3357b1d6c0f9290e2e4141a4c3f32f69c176436e58629213497ceec	9101
929	dd2128fba8213691428c874e968b95e4328b1ace36d1b216da3490e8cb50f431	9126
930	ea2446c60ce5b00b1d47f4a11d80d856d2724ebbbe2046eb13be91341442b1b3	9128
931	31674f61220dffecaf04b39fd2acb15d9c20d16f7a7cc9bf99cab597f3127a14	9144
932	002eea725fee95e651e278527b1e46b9308b768cce3a29d36624acfc40021aa1	9153
933	eaffcc68ac6bd51f5f8ce16b01e764b8ade58d9c9fb311b303bac68085e1e993	9157
934	1c14b47f88929841f7c672b05b7b3cbe6440d8f9b9ab49ee5850e64c2c49b4e4	9173
935	2753332f6cc471ba396469cc9b3980bcec92391b7bba84470bf8d324fe01ec7a	9177
936	6d8a42f6841cdf15ca202fd032cf4f46143740965d38b2117a7eb89fc6127cd1	9183
937	ad869db92a1e4fb8cb80df672ac96a970d050a639790547f34c9111b8037304c	9192
938	7fa59a7d9f7a7eac027f7a8e2b83f896ef7093ce8aff61f9455c58d5d35842d6	9197
939	11ae60e5e75526f7f9c3e47d90e90e4d525f48513d4f7d42328d8b65044be57c	9201
940	5a3bf094211c12e0298b9a61f2287c4b3bff6fb5643bc7521e31a6d154b153dd	9203
941	929a551c293eb2f1721dc1b164825250ce596bcaf161fbc49514947013248feb	9241
942	4da1519d4584bec3fd9d61a1df43e511fc2dd1f2a341c2e7fbdaee1f2c4b0b43	9244
943	2ead3865d1199df8c20c81c8dcb9313390de31e940fd375fb4dc06c821eee843	9246
944	1c811f550a062b7a4c535f3d180c3f6361eb26f04aac0a085eedd92cc0dd3d93	9250
945	775a77e689630dc15f9a2adb1e40213761bc629462e5cd73559e1631aa346793	9252
946	75fde981251400efd30f19ccdb74dfa28b6a0b0b5f06bf557bcb7682f385ed94	9253
947	b5630d8d2f796fa817b30e6ab20486baa9f83b1f14c49416ab298f847f7baa72	9270
948	d82520f09ef8ffcb1b83543a6568250df3f74fcf8f0747a1fcb22ec70b74d7ce	9273
949	fec93a2a2b004002a8e168b0308af97e9926770422eae9d76ab27f8ccc485574	9278
950	fcc601b6cff873ee011240191d8df6a3fba348c97a5868126a260ed57350df53	9285
951	e6eb8cfbfcae2adc56a9bf909d8b7cc3b0b7fb277b8d35038991d62870382529	9286
952	3a7ff8fedfdb708f37a4d53e306f065f75dd2a245271c34ed270888737589e66	9289
953	8175d498d2e1570f8baf497db4b8574495f98965e72bb4000f8ecc45fe423a50	9290
954	5ca75bb6b966ccde70d47e51521e0db69d0978477619db113defeae335c1012e	9300
955	2e1d997426496c1fca68b1e377c75b2f0aac6300bd494319be5a03465f028b15	9304
956	4ce518e2b85a5eda316992771b904bb8aab8318759eae5c68459086aaacfbb20	9322
957	6a4f7ef9f87c6ede1fa808801a31f482739bcd9a038a73f9ed4a3e9df9624fa1	9336
958	9f79287738f44867bad39d42170dae51b4068994b1f1acef7ea3f3411d7a7a75	9340
959	876a818588d895471e95ce59efdd6982a2c0079d0b03a3cd10fa9ecd91bb36c2	9345
960	4311689a43064b265ebb17448e154f4065ef103982873310bf5362571b38f22e	9347
961	319b6beb42f2860df6d74b34d2165f447669eaa8c56ffb9ca945bae029208f28	9348
962	432f6c618d9be2c15208c52e0e732676704ad56101362fee16d8e8abcbd99853	9353
963	8b47dad4a0952611c1a8762fbc9f0b82e4ff6e0da9f50d46b6ad0b37a9f87373	9355
964	b759711c9befd392183f14a5d81de677a6c42871be6c6208d519f121ed2b4b02	9362
965	b0884195816f0881285f06e5fd9200cb0586fed4e1b3efb9bf9f1ec9db752431	9372
966	4ccd3cc5b74efb03ae7b7aace695b5d7b3181fd34aad82c4a2b26b8ab4f8ef20	9375
967	07689685c0440add6daa0a4eeb3508df462b72d6181adfa03a730b57dcee51eb	9378
968	ea52646f501ff494dd14dd1a61033052d4c543389f0609ca8b2fe92d0a36c8b2	9383
969	56c8a5517155db5ba863e48dcbd8527fb324b853ee6f247495e2d5947476ce37	9386
970	b3f7488e72262110404a54619e04c6254dcca33824fe5b5707ac5c87ea915e72	9387
971	4cbdb9f5f2331b4c9432a07fd8159963b8428dac548cf58f67efe0c4a2b32deb	9398
972	f0383369bb9d785ef4cccaac065b5c01fd05f6991c98b43391347511af8e94b5	9406
973	f10e97ad91df676fdb49a4f107ac6d376c824cffdaa3db834bc7676e519587f5	9408
974	c2c48f3962cc9ac2e9c7fb39f47c462c2935d46bf610a621028693921adb2ab2	9436
975	5d12f4a23ede042590a880da8264b1d0a1438129086c693b8ff7e748d780b907	9437
976	3e5d74f9f14f67eed5e81f344adc0e4ac3563978ef9c153ffad2c802c98a9d06	9444
977	6bb4da6a3fc50ce284f4c04377fd4c611005052bb9641bb1035efcbcf3e71cfe	9448
978	858357df497e160eb4839264938c02f6ba09af36bf5d8b5027baaef5dbade65e	9449
979	66a14d156e50dc3703c7699077670621ee370ba45af5d9eaee3600ca6f7e1f3b	9466
980	fe0ccb5abd5b9260a44013017ba120f97349733bc41b72c85015bf9169e86003	9474
981	33b6f2a27da027eeae338cd8f84796f32ee0244e34758632b8c3b99bfead971a	9485
982	de9b77417ef1559c58d35a2bf5d680e5edbf8e94548aedb1c271e87cfea12e74	9490
983	7fdcdf165b2abb6357baa2ecd175fda2726a89491707bad333dd01a0842f9720	9499
984	60887be0d808db82fd8daf531d5c07c90ea94e90cc0fede22c8be14be424a731	9501
985	1f2f585aa3ca62712cf6fe1c35482a7bba26a24576445a01e7c9db95c89df17a	9506
986	6df92f032cd30bff7cb2ecb9f49ac78cb344da4e11862dd5075e45f1d0f625a2	9510
987	82511fe92b8917c8217931fbb30922e04d3d300b74b280b0d5b29847f14a090c	9511
988	4ff3c4c627813642c7105c20bc41fc9ab89c7e369431727adf603dc6b680bea8	9525
989	f0ff405c24afc0f455ed40d13de71ac9b3ff2e42d2eae155d5bb13a0e40d8d1a	9534
990	32be063608c7fe33a683a28febf1a59a8981763d552c3e06e0cb7358f7f46716	9536
991	ff573994826bf6e222ada6f1e039703aabfe910dbaac4f28a57642bdfaab5fca	9547
992	b7a9af0f2986177e5f7e9c8e2f62c608b8cdb31a1b7737caa583df52f80544dd	9551
993	274aa21e53697fba233eae70483dda2b66c8d144fed42f633e4e4a8e86a81e82	9552
994	9b535b70e7981863b27cbccb610586c734a299006a97def0662a570d141d357d	9579
995	268e9a83bf017e386e506c1096f08428535a485a924225cf52222d6e3aa4c6fd	9590
996	bdb7daad463fc3a9db6b6c3b7f4c951befa8b31ca33518cdac35be46e20c46d0	9599
997	4daf5b887594b2c3fcfac005b23ad87b1aa27f1f843c204452ce2249d13cd198	9609
998	3f7547c19fa309594ef11fb572766192371b2e74806f00e2ae5bbfac062018b3	9621
999	2039daafb7d5541ed8b9fbe1f04f7bcbc1ac2837a2042ad3137ec492f462eab4	9631
1000	59cdfb614383817886d4d757a4ea38acd7579e2eae03ea32abc1894cf72e5fa9	9633
1001	32107dffd7c569b088361026c789a5b8020a62a390b23eefe38a6f89df537e73	9636
1002	c8a4fb8ac936868f8a6785d8026d339bd9fedc885d1ba91714d2950eae72c038	9661
1003	dcf9ada0d4602626a0c3dba7398b5a8bbf6f4a8547a32695966fd6ca2b252a4f	9680
1004	12cb493eb380182a891400c72f7d4b4471952a2a586b98c0d1c2c7c3b934e8e9	9681
1005	0d796ba49e9ba85346fc4a4a692d97ab1aa553c3398cd34457c2cb5a0b3c1aaf	9715
1006	584b4c6993836088fa9f2dd567f09dabf6cf4946deba32a2e4f93ae376856bc6	9732
1007	2e8b2f1f18eac01f87893645ecb723e37b1213f35f7d3a9f05ab6330a6ba1355	9745
1008	a2ccc6523558ec56ad64c4697b05e7812bcb79ebf8bf72b2f67e3b40e6ac0933	9754
1009	ceb585aad1abd734ccc79bed04ea6e831da96ecb1859377e78f8b6c51980ad43	9755
1010	14ad70e665f1405c99186f21dc35d82515d751f0fcaa19667dab23f63ee55cd2	9793
1011	e42c923aab668b2acf6b0364f2228684efd49bc2bdaa909a7855bc27bd3be655	9797
1012	13bfcd875b8517efb9bc92f8bb4716d5f6d339a2b29edeb8194e2e4b951b4a5c	9799
1013	fe4a2de013b46172fadaa120cc144e6e82350075a727f5497141a104d8940899	9802
1014	90cd09e4e70fae979deef435881fd2a028f11f92cb8e71d6749e4dc84aa1c3fe	9803
1015	68d027b71daef58ce379810871bfe13ed874ef239a6ebee84454f0d81c0eb9e4	9816
1016	1f9a2691b033ceca860f7ad90244498cd21677c3fc1eb964164e333571429880	9874
1017	7ff6578986310aee6237de7f5f7690f32e15e99bcb7f62da412ccafb39811a9e	9876
1018	ea15f13a170851d1c4900fc622993072969f7c94b7357b6d0256cc217554b265	9880
1019	ec59e01ca14a33b70038cbf2931a7e5cac304ecb68b3972615f4fbc18a95033e	9881
1020	e3bef91a79ebbec2dfff027cb7b94583248bcee84dac063f010adb35246eef47	9886
1021	48e94b1fde6c0be664167e1d0ad9308d02552d5a83b8eab958832abdeb1bf9b7	9901
1022	01b105025eebdc4309dc8f1b2346ab2449813a64d2b1eb79c9756798e4bcbad5	9902
1023	80e8ff5cc588b00937aaf1a936721be720519798b5983d214936350453f9e47f	9911
1024	d44737b0597aaee25417644ea4c97d482993bf6f40259f9372d5d41a097a5466	9912
1025	85d7b6732945ed15fc623db1e688e3cbe76252dc3d677c43cf707ca8d36c5667	9914
1026	0b8caf89932c41df4fc8f951334ef8321ce38fb9a48de5e729e3d2f07156685e	9922
1027	b1e2ed2b8453433f73db9852ac186bebc5284a795a4591dd2335173d1ad4d8de	9936
1028	79e089b24574d47b1aae9fba04a9e8538eedd0aaa028fcb41bc6d631974fe819	9944
1029	28f837ffeb95c43cd4bd41b3b472d826328a0ef7a7270761e1c29e95f9191542	9945
1030	0b28d38d4275035f46f30ea4833a0845bbc19df454d93cec0c2c4c9c4c5c9001	9964
1031	814fab2bf3ea1616f59f205485ae738fec659b534b3f14cd19c8b7d2ca7ee022	9965
1032	db2788fc14ddef164de5a0e40d0da0dbc4a9e092878830a15bcb23bf29799760	10019
1033	def584f9f9101481938b1253aeb7083aaae8e7b2696c4a571cc21028dbcae37e	10021
1034	8ac3dedaf37ca3e94fdd0efd5fa8bf1326022731a6000aef1e391e9fb5d7cb5d	10023
1035	90cce861e50306bc57b26fff467df8fb9ea315535b702e50e1a01914e22bb655	10025
1036	17fc9220a41853ec3ae019e2c3bbf1c4dbccbb35854f3e436c1bf7ebdbd225ce	10027
1037	5ea9f63fb661c51c89a6fe3b67377b3530195cb123a2531c344720e082285b32	10037
1038	c3d75761183079fc83365d25b7398771f85cb9c4bfd4bbda67c6f79bf030e522	10039
1039	a86e38570158eef5dba3f14e8f1cc40c99c2aa6491c4ced9de27ed81b353c5ae	10043
1040	9926a10599adbd66e7e0ca01ce7e0d4322e21a1aea071d6f98eb370aa92976cb	10044
1041	653880e23de9fd1cd9c8ac2cfa505eba7f3a10ab01bf4ee10398eb900b5cc969	10047
1042	66585bddeac3ffaff257ffafd1107a85a6e3c651c83f2ff40784b52f6a15073f	10058
1043	c94720574c314ce085ffec3c284199d46dbe5d031b035b2ad4d0a78ee30c2ce1	10064
1044	4fae1e036deca6d718c9173198cad8d6bf56a4a52a656566a0a0131a2dfed9c1	10073
1045	88362d0fac532a8ce0b901936fddd5a1846288ef7338f675a02782dc093b075e	10076
1046	b045f8a7c88ea94635e6d603fcd8c011ebf048f101fe3a459c2946fed1f1684f	10109
1047	2c4b6ad385c36e3c2bd28201330fd0be4873c5f41811f14cc3dcff469ffef194	10135
1048	21580e26ba903b07991610f469167888d2bf75186bec261f7723fe17374763e4	10145
1049	be4ce9dac9668fc471a56dad986a585296577607704440228cbbdd8bfa71e809	10150
1050	51b005f97e4448440c06f6cd42e6dfc2ae9f2616ac3c123464543641b9be8805	10162
1051	ceec3684604712d37d810c4437a0870fc8cb1524184eb5b207ec4722d4b6ec8a	10163
1052	28eb93355d40aa2a9d7baddbacbe22eeb53f988a25a14c1d0d35a4fbd9cab57d	10183
1053	d47da2d0e53dc24671da116e93bbe7e211e832a51b19da75d96f617c8fec479f	10189
1054	a0c4a991c132cce154641c066c9edd1fc08c7cde06dbff246d2cbd86adaaf656	10190
1055	92a87d78afe3fdd7066144804de96b3217f3c77342a09b37e3487bab81139d60	10191
1056	8edd954d69147be2872f5c05e5e3e379a2e3cc14be100e41faa581c447f172cc	10218
1057	d7ba630051765bb569a0b25af9821317e4c0dd23d601d298d3d1f953756f1b6b	10222
1058	dce6e5b0fa0862c4f21bbcd8d053cc7f3bba846c86f7c715ef05be45eff21f2b	10225
1059	a548cc59c48a0b6884eaa7486f25ae92ec13d073296f734fee2d10f894f1a07d	10246
1060	e58c9a1d53673213e4e83ea3ef411023b46362a1436f70d27f27f68bb5719484	10249
1061	cf8df6b3f73cfc3995c20fa1e2868c84405f0ee96df7ffb7cc72516b7c531d21	10256
1062	055015b31c5331782d2d6ad3547e78a64c1f69250c39332933922c2b2ba0fc0e	10265
1063	3510d81f5f3dca54c58ac58eddcefea05138d94416f8af081ad62feec0d8f976	10306
1064	eecaa3beeab31fbd16cfca9f92ebf1286e5c29a71bdfcf906ee9f2cdc3c0473b	10316
1065	5cb9ee4c927d5a5e0caaaeae3f2b3066dfda612e38eb37a0c6bfa88fba4df2b4	10318
1066	5e2a9a6b25a7c0a0e1c78103b8f38921819b570a8a9b9a7594252e89f654c260	10319
1067	d73414bd0e5870d06186df82ed219bfc83e8d66073cd4fdb0615f7eefe29a9a4	10322
1068	edc4c038aef60b2b9fc06097e5a079692a7c3133eaa5a58cddecfcd977de1f55	10335
1069	cd8851954c8a540f8adc91e6dad4ff88ac1691e43758eb3ac1a690da67813c4b	10376
1070	8a72192b6deeba0f4c114b7dd1c23d48bec42b3b8a7825ead0040efd5ed6a023	10386
1071	6517becf50349dfcc2460301d6203352b78fc6592fea73aecd546ba9b8da34af	10400
1072	9c5c2d10f9d41f197459cd8eb1d028e4f8df0208270d6385047e39f3a529fee6	10411
1073	fa44f8580b3df614f2aa9fbd5e4ee9ec98aa2857c435ff2339352f7ac46af4c6	10417
1074	0ee3b48f5d5af90c5a9ce4b876c3cf389a59aa5ff8b2bd2f6d9228b15e86b9b5	10422
1075	967111fa12f163983370a14dfe80651793be5252b4e504171d5fae942f8153fd	10467
1076	3140a4e61133d2b6adfe1615ea38a9ef22d802ea0bb847436a723b875574fa7a	10468
1077	25dd268898c4c14491eda11c351e52f0dcfc2d04522a136474297d06da8a9f36	10473
1078	eba5ec21d9880e321173d9d6fc596c8e1562e56c66aa9ef2547191cda88d3521	10482
1079	3f0d1cd2e6c3bd3aed5160a242473d0361fc2cead1d7fc8a2a4eeba022ae5bda	10499
1080	2d7b80c6b3de41fea40e51bff45902b4068d7478e7520d371f79cb5880b65bc9	10519
1081	002a93c8c7ec3a70dad9349317d6ab025e94de1338dfefc2831c8c36b27ecdd0	10526
1082	165f1f0ef2efed0493de04a093247d270d1ca3fe1a95fb6948d918f1f8186258	10532
1083	1206e405a022cb2f3ca5960496a0c06e9a15c5eec58a1c728967634f4e72d7b0	10556
1084	41d9bf4b05057707f478764de48c31866727bf3c58dc6fddaf5ab089a9a46cd1	10563
1085	320834f52c193fb5eaaa74d39cd5fe50dce01162faaf3e1b79ca40d0069a5ebb	10569
1086	ac7f917cc4a16301e6c07efac78400c8ba95ce820e135829e3006c3a96c685a8	10570
1087	4dc030a060ee92e8260f117b160975f6d1dce9369dab4aec313a0526fb8a7e9a	10574
1088	1c8ea084cf8b4632bf6f244d1622d5fe0d37773b56fc7c829a4be54cc3464f0a	10575
1089	d7525200410f57e0a10a1597afae0d401079ea772540681050b73e3e576869d4	10597
1090	a965fec6169fad215f6978dde8f106780fe9132b68832734b962daea62a44660	10605
1091	41b8fc25e8c6485aa9a0e1f13649cf11aa4dfffc3fd66c2c5f5396c8848d6516	10612
1092	918da7a7ad7ca3ddb152eeb2fbab9dc9bf5181d72e8b48eba2bf4fa1f01cc779	10613
1093	62726f3691132b97085b67204b8d089091695536a12527f1d22e503946ee1103	10625
1094	d790f8d843e68eba77974a46dae9d27c812647dcef4a1ac54b8fa633d02236ae	10644
1095	fe3ff5d57cd5a59c14b0a29d65e149444da077490ff5bd9892e22be83412a2cc	10658
1096	125c4f5539f5ac18b557f109dbb41008f82d20bb904e58733ca11a0f8ccf6340	10666
1097	0448efd4d64bfc026421eb45b2579e721820677b1b278e14e4c36c3f101e6640	10670
1098	189bdc32d8f7964697c13271db596c94eb02cc949ec790845776f9e80ce5b44f	10698
1099	09e215e7f8e84a839b4c08920d6861e1b828e953db078dab0c9ae2678f6e8691	10705
1100	2cf145b6adfe7265b8779aef4546194dc38a2aac544c8dc98c389b7f4c1df8c3	10706
1101	62856d410f2cd7c8273d4c6c233353f5fb809394413869d926c33e2ba87fd458	10754
1102	49d5415dd1a391e23db8d882c75cdd284107774e1964a666fa8dac4c92791c94	10765
1103	226b8f549cc7d67939a60096905ae7c33a7fec24263cb9a48fd8e1652f82d403	10808
1104	390ab7c5dd5a5aeeed0ae9079aaf6e794d416520c6ce79ff445989bf0035af95	10813
1105	8e598ee7b889435f2083266ceee14812311c335caca85d078bf9bee50538b455	10818
1106	fdacd7dfb02f03e9e06cb21e0ceb737ce1fe182a52e9d98e6d419475eb73acba	10828
1107	19c3cb8198ab37e1a18f0abdd13a513ccea64965cc29c223dd1566cf0bd871bf	10834
1108	6104041cf50bf217e57b4489e483c21d7182b2d5f984053e98c2002e867ea76d	10841
1109	f2f6917ec5c276f9a33dc5a0bfd85acb23093d3e2845113257497329b892f86b	10846
1110	375956e8e394689b313bf2c2441cc3d935919977d9e6f51ea8efb6e5a1cc59a9	10853
1111	67bdb2e8cbedb8ab3aefab32aa7c41cb383577001d8d425b3659cf504d624470	10864
1112	19a5e37c9cb9de96b0a8d231aad6ad5d683b21e50a01e51dae447aa73f22a937	10873
1113	907480acd2730ce23ff925a7ae605212c2108ba8f72952b2bba711b307f53b1f	10889
1114	0e0a865abe099c18f03438cac035a23fbed91f1f76785f3585920f16a4354f46	10892
1115	cc283e2c316c273b9e72cdfc75dfeaa4d8fe23ec6ba119f0eacf37a9eee713b0	10901
1116	21ec1945c93f18d3f2ce3912531556631c27aa2e1a88bb0c783cc7dff2a17a25	10914
1117	96c66fe595733e97d21d1ed5b82d64faccd9de7f916b7599e3f26be25e6367bf	10923
1118	c1fccb8f0eeb47317800a089967b7388c889902b9b7dad6902adaa4b46aa777b	10936
1119	678c996cfe5d2830c624d84d171966aad6aca2553eaca8b574b24d73f3ad5c52	10952
1120	c5e29d8ecdcf92d1b7cfe1e9a8cd7bc620180ac96f8d99bcb253092b10c4ebaf	10960
1121	37f2c8f875d8f257fb3d44eb6b02464f8c0900aaeeb389b68cfafe36a25e6b82	10974
1122	2f7daecdf260eacbea8205f2f4bc56ea28f1ad687e1d0bd9fb2b9d2b094327b8	10975
1123	d3d55b167a830f101074d43b386d8b945f08546469db6ec654033e8ddcb724d1	10977
1124	cc2045112d7bfc68d8f2f889ab3ae78bfb4239170dd262c04f85d8565d8d0ad7	10999
1125	3851a13f8cbbe63a79f5b888d63a2b7c2ae1f92cc9e6c073e543715ded7407ac	11007
1126	bc07d32f98cfc725b394cf50712ca857aa3b2d629b3cb18430b5114c77f91c03	11009
1127	cda95537bd0f0f6c3a0247fc64a0ac60793d8abc33016bf71780b4f3ad91ff7b	11013
1128	388cb08c666181232df1f6bdca6a7292a34fe799718d79cc4d8be43d05a8e6d9	11020
1129	a4eb13111465d87bb4c4e4b36b481bcc8925829ff0318cd55f18f5c4b78d8949	11065
1130	6ecb9055e89583355f620cb7950c67ab72848efb9fde529eee1e4523eb3ac1fa	11069
1131	a016b0a748c84b6cf8fbe95e366e8cc8d1f901785d34140257b9bc251adf482c	11073
1132	72125b1b78efab4f924328b2d15bf204c2f632366c4998d3160469f5b22cda25	11076
1133	5f1db0fc1da546b350047c4ed24768f98b59cd63e7228dc729c3440ee8a58add	11078
1134	b63142ade9677e2f3153235c36a8adeb83a35a9d9b97ca8b7ed665da4758cef2	11083
1135	05341873c9177c3ad5993f002d90ed85bad5642285b18d7aa8401f98a6e83aac	11094
1136	c2883a754f4328fda42ae6b1488b3ded58de59d7eeb05ee9af24df0a8136e9dc	11095
1137	e18a21ce31e1ad07792073517d27af19d9d29883e3d8db4d424911b5152fdbf8	11101
1138	a88cc9a3759ae052131084c408e4a2d361e3e3a355a8dffdcb9cbf37cef7e2bd	11119
1139	d9c8dc2c71bb1f5410b9f828ece745609e7cd79d565a1776e81643042d5dafaf	11132
1140	83ed2009812f7d8f35e037dd0131ce33a40a25cda4646036dc9a8dc0da47d0bd	11142
1141	241a439741895c502c1322474a4f1d2608f27737a555de0e6aaa28c27ca68c36	11143
1142	6e240e90d2f735c4c1bfed22f459713977e5fc960aef24e4ea2cdbcf295c709b	11147
1143	c1aba674a96c17390902b4e08df3b6b2ec2dc510658f6a1fad5628cf4423dd0c	11148
1144	7022d6f6b51d3b93601d5735d62599dc69449d386c882e0646fdd195188582bb	11150
1145	3009e4debe9a8633ecb001ab220f833519ef044e06026b8d703827dd6884e1d4	11152
1146	3aba1001d406f8b2c784e575fd91bb5b232809ba6ade069030445a3bd57dd1a0	11160
1147	9d870d47926f13c959a8de426e50436575acb7d8a6d2c6feab8a838fa794b4d5	11174
1148	3c7b5ee72679a0dbaf328f06cf83299fdcd200371a955bb8ffe5ed6e8ee88bc6	11194
1149	f4537b2a9569f999e7d089a721e665455d90311bc6e8eb1c1e0fd7e194b6a45e	11195
1150	728057169e2fce55499957c33c5db828bd2c1d3d463b8a8bbbeb6c94047c2b20	11199
1151	0e9688a4de7680487a6dc8f5f2cb391ad23751ff52e1384cc5b420243dd1c651	11211
1152	20929fbc738c500bc8b8a5589792749462af00c4396c80f179d199b26867a5fc	11213
1153	f935b36a409a7e40260d8f802dc0841ab33ed43db48a28e27b3cc9b91b928898	11215
1154	f96a4c2d69c982e5afddb4dcc158311f0c649a189b5484d6a4d4b88f1ac639cf	11229
1155	75991b3ef7f96ae605216673e060c25d934f7da1d0cc254a21e1a1f8fcb0cb70	11273
1156	1edbeba875a28f09c0beba3287dff4e86d615b5f648949e269f5fae35827c1c4	11284
1157	443a60f90b3f63d302425e308c1e6752f8d987f55d213f0b48732589aa92a6f9	11292
1158	8c4b875c5bee4812e7f966b2fc86b504302bb52ed002b7e539fbc734f6edf346	11306
1159	e431acaacee476ddc8a1975d25009f4d860ace5dff9015ffc10ec6e291d6b958	11309
1160	9a9ec7fad80e3578f013f02bc16083d6079b97e85191fde8792a61af2821e71d	11310
1161	f13ba130059f4288f7ed72c022b00e1feafc017dabb2e7f4aca7a2cd8e2d6503	11328
1162	29df84fccfcd45ce8b84008f490941ef4cf49e5db2c01bdcd4b25124574acbc1	11358
1163	b0ade9813bf48d5fd750a59324196691b04e36c0794e37f909374ab6bbf1dea3	11388
1164	f6207d24b81009b99bda4ae1f5fc2167ba5710b7f25f1f8e73f368983b664cab	11414
1165	b97c841350860ed3faad7097c50aff33e866ace5514dfdcbae9c7b3f562c3243	11424
1166	d47cc7c4bfa262b7f8fd3bf96eb571117bf7d822d625c537d25fa2d5c9fdbda8	11454
1167	bd24bd76556059d911b87d0f20376039864df855de6c22bb38422b024ff98bc4	11480
1168	587493034c581f434ab8d9394834f4989aa71c5b5ab344d98c2d7246e9c94ee8	11505
1169	0411164ea05e5918932ea49a6798ea1b29403606f9c4104e0a37f39d0d86ca61	11516
1170	1c327967ab9f2c15805012f506f775259c4550a614759fad6c2057896e12bbe0	11522
1171	eee761336f1f9d6383d024bc6e63d411be2fe7f4ba7354972d59071af938d2cd	11533
1172	f6cd3f5f18fb7409deecb54e4cd6470a83a354c2353fbdbe44b32ecec149fc7b	11548
1173	d25a978c223921960e78220e869908920523b2a8ada59a957ed3a2879c7d302a	11553
1174	80335c84dc4349ed7955fdcbfa0cac4e3e5120ca4ed2821a98282b36e24146a2	11562
1175	18297978effebfad5be2efc3c71217d6c1cb59f1dd790f86b62b7aa1aade53f7	11563
1176	8b6c5c33b9c43e5bde5285cce98194a3ecc482ac353f1de26d6de81f1f36b8d4	11574
1177	efc1a78d5e78a563881075e77c5d50fb993a0cf10e453ee4cceb12ddf18f6d7c	11587
1178	4c899cf26252502278dad0235cbe5a510079d25b2be59b0bee27cf26592c3386	11589
1179	9cfa02360c39db5195bc49b97b305b380fac89b6663062a5c5ae3f860bea36f4	11591
1180	b95669db54e528c3372baaf9561bb82e71c4abb95eca5eb8e7003891521ce6df	11614
1181	1b0e2f0ec28d2ef2c7cb791e0186990b9506f1f8d0bded085e06ecebab845ff7	11625
1182	8532b69723483aa14d725b5eefe1e8194c24643eefa6829d03e6b3588823edf4	11647
1183	39f2c0ab16161e645aa288c1c0f5283f06663eceda8fa467c9c6d29845bb0458	11657
1184	5d134ac6a705df5f0f6fa47af235b8284bf91a8cd991910e2e87a9aab40bff35	11664
1185	22bc4e1b1d872619f1088067cfbad788419c9e7721be952b25f1fbdfe57d3933	11676
1186	ca26d04714a6d8ea882cf3e435250751e2a938d3f6be66b3de9e7a67dc904c84	11685
1187	5c227e68e9abb728911ed191348eac08cae68f8766f9b382298b373d380fb281	11688
1188	18d3a2152c671d8d7e6ec0ed7b74f3251773d3a38e73206246e127f56951cb72	11698
1189	a83b0c386335ee33d9dc1087362526896ddb247ca5c8a5fe18700e436d58f750	11699
1190	65dabc48e2c0055e7a55c70a0ac6dfb1033723357f7cab4a31cdd8bb855b97d1	11708
1191	c729fe4fd2b18727f8ec1f6eeb78b16997c867f3b0ab82d43745da36ea495f44	11712
1192	a2ededa240d2bddabe79837def74be7bf08b65347f616255d7395c456c0a3150	11718
1193	c5b2dfd4b85ed38e89a109366577b11b92a34d156cedc5755fd04b60bf8ec2eb	11724
1194	8f33821b5f42186914b7383dc149e0e37ca0c3d7c99f84356243775a7e746015	11725
1195	dbb725a0b28de1a82b37526882b416c3394b66739841dbf512e3023c0982e01e	11740
1196	02729552c3f064105bd1039dd6bc2e205799d2a217015158207ae0e8009ade2f	11742
1197	54eac73107f14c945b9a54a0efe4d4811418810f194f1d42a94742381a06d9f6	11748
1198	db2af2825e0b9807ec3769623ca0327cedadfefe793c3ba0515762a49d64a0fa	11749
1199	272674971e43377a59d08bb66a602e48e6ba23d3107e6874cb2e372dca0f9422	11784
1200	cfe47b7daf5702a5cf2c536719cdc7618ed5538ea332269ff890569bfc2385bf	11800
1201	8969c0c91b86f4b1d72e8a4ade25ec96de673a8015e568f74c833fcb4106d2b5	11807
1202	6c2a12cc16b884b9e4c4fd4ede21ac4dd1ca08ccfc87f960fbd03cdce228d651	11808
1203	a426ce40f0287edc29aa492b4ae7326c38cfecc19f63dcb632b33c33edd9dfeb	11824
1204	c38b50955c973220361ad8798727ec02af4c7ae5dba01620f8be92ce9b44f68b	11825
1205	a2811abf334a0ff03f9ccab6f5f94bd332e5f7ce0def7500580295faa2f50a38	11829
1206	5f05039d25c42294ae60c83bc615498cccf72fb69cd3fbed26b8c2544ea87deb	11853
1207	262de5a628b857f0ff8c8f7ccf714c5a3c568479ef5a5723a68973c74c9ceb87	11867
1208	d98b2e4f87f8b8114abc148158129ca78b7ff32c87bd4181141be3568e22c8b7	11881
1209	0417c4a6d313fb5a2d300e56ffc17e73f880eb1c02821526cfb7b53c75cf73c4	11900
1210	0829cf5cc8bf8583eda61f9d14a77c45e83859f24f9ffdf7a5baa661df4ceab3	11901
1211	394fff7f64ca361cbcb8e0f896624e7402b37476f6dae255f26f47f87b5b3685	11914
1212	cef1d4ab548a9fd4491d1257b19ce8b11725df3ac8b03695dded4cfe7064550b	11946
1213	073b33630b10564891fa32d29c02194c02604d0ce57a8b21f8967b639a40cd15	11950
1214	42e059b84e93563828c0f43bdba0bf24bffe175acf5f0e6d15c31d93dca012f5	11957
1215	efb939972d591c0b74ce37e13f609947c6faabca9c6817f74f3d4c08b0cc1a6d	11969
1216	8b11faa4b4bb3fe57480604c5ce35205783c50bc989aa4ce23e8a46e65fd057d	11982
1217	6f274f72af2e49c9241969ee18d83c2fd68265149012c775a6abda2359d6783b	11988
1218	4975d83161175b8ab425f6479c8cfcd60ba41996b702bae5c97045817a6382f5	11994
1219	11fdf34ad82ea695c03c159fb0d276db9dac296259cee8a21d0abad5d2bee174	11999
1220	7c1d62813ca6a7b6f8dd64d6e600a624b43d5462d9d748a7a45891aa47b0da58	12008
1221	7a2d8e59ef5e4014a28c62f1da9bc39a84f635acb51b06dbe83a65764d22ed92	12011
1222	285bbee8e4083d6ab002583843c9f6b5559ab9bb9229b1e7795423a311cfb99c	12016
1223	0a28a3f7cd1ae9bd5004d06accebf2b3bedf5326b56a00e95fe347c6ec78d2c7	12017
1224	264d0734b56ac362a2cde3c5e4513f0bbf4d1c2e00c25915f74f64ce47848c2c	12031
1225	0615f911fbedb8d453d300c621a6b3e33713af5eb3a0e2a94aafab3c6b020ed2	12042
1226	f0393245525c687e67fd8927e1b4c6ac40a4e30bf2d3d5e5ea373570fc215d52	12053
1227	62242e2b2744a47d22a0b3931138c076aea67f38c9af876d89057d7602530406	12065
1228	0d388146a9dca1295060b32d6a20f2f076dc5bd21c1eb9225e3b2d0a5e6db36a	12066
1229	112e8a7705b17465fd949331a4cbb3c74141f9110b0b02a218badab1cf5d60cb	12072
1230	62963e4420c01cbfeb115f44c834591f85a8c0df5c37db4353c562984ccc3413	12108
1231	a26d560c5d9a4bdf3696c77efdbf4b39d32f26bae1411cf5456c048c86ca1aaa	12110
1232	861684914c79977e85ffe8179e0bde2df9846fee30b7ff97a6133bb47fce0a47	12128
1233	14faca3569f54e349069e34b0d0a8de13c03f6513e00b99b426c15934d590d2c	12130
1234	4aa2d03bfdc13f20f1a4349634f9638256f34653f9ad20bf093d0e185daf95fa	12131
1235	9d2cf4161a96561f489f57836e014084a7f5d80ff57831d9913028c95400146e	12133
1236	f181edf6c78cee88d2e2e2ad274e088680ead863bfdf46b333de12dac2c021ab	12148
1237	d9c89f99d20cbcb7113e57f26db54ecaeb5b994d2a7cd11803158596297a2b28	12151
1238	767c89287b995979d0c214051019bf53c90d3c872af7cefa7034b2ebbf76d791	12154
1239	34ecba4b5da34b5a8f2f0f8158e88e7f760f7498fd9246a042e10f2cab0bdc7b	12204
1240	6272771c1e3395c193b46f2bf0b1fe3074bb4a1ee937c51328abff7b6b4d6a2c	12206
1241	5447b9d58c88c91cf5373e5c37a94abbe730c9a5ff6bb47e47a16ecde59578b3	12207
1242	415844c1d1fda22f6bf6523d971c720486eefc3b76e91745219e2ec6bd7abd82	12218
1243	29937336ba8a0af20154c807977c634fae5292f2984e6e7127ee3de4b3bdeebc	12240
1244	fb75974f68d02aa74fcafb7cfdc2194cfae2aa561da3b93392addd9d56dbb0d0	12254
1245	dfa00367c0a88a2cdba76ab69bef3ae2b8c21c9688ee6153d02c05c51424278f	12255
1246	0341d18347ad7d65aa08ad7f971df0cc606c7620d2fbd061865453e32452737a	12276
1247	b49c4bfd0d4580794176afa546936414749e52a1d29006f266f0f59c1177abe2	12289
1248	0e66ad966e3b97f3f11fccf6e9bb37057b48892915728f688fbc3b3b196cbf28	12327
1249	433d3925641d79b3d3abab19bf00a8c8512540df6177181e4116610a975f1dc6	12330
1250	9ea3cf59808079b3442242f8c9820156622c7c3857b3c076a529d7f5be29a6a6	12338
1251	091400e6c6ddf78c69c0b068f6c162916e2321206ab31039a134d579ebca994d	12342
1252	24ca6d6b66aecc2582af5f549346e0099ab4d93af17a5846b73ac7197e5b4d68	12348
1253	13b74dcf264d73fb51bcfede26fb2e15fe8b14692f3fa8f81ce2e7a854926dbc	12355
1254	6f499641a3e5cae07b7ab2de13ea1fbc80358c23c1af63e2d20bd37a2740cc57	12369
1255	55b142753fa27a9821be4e4d45af6b5596b4be8dd9937df9380cb8b9b3911d51	12370
1256	7fa3a3984d427ba1942a7a2ac10690898b43aa9a6fe55e1b770b8a488a91fdf7	12377
1257	e5b311e698eb400b2c0b67f335d2e8c53e11340f453c2fbe730194f4b36383fd	12385
1258	8f33b6253e14e301193486ef8bbcbad0ee8fb0b72ed0f1bc83189f50c86052eb	12396
1259	0cf0aab109c6bc476dba1adab331b869a12e4aeb4a674df05ff93d62b6f0eb1e	12425
1260	0afca5c228501ab66e85f0f64d8c76fc1a76b00b7cd522bf2071dbc9e6fca3c7	12453
1261	5bbba76dd66cdc1e6cdf5ef4e30b3685e182e173526f568545bcd2ff52e8264b	12458
1262	b8f8590ad0b636760cdba1913e8a8c1974bc3177a5f8f96d07aa7d7722823177	12460
1263	a691d72fdec46da82d4e8b71c3f7296fefe7392f3e083b6efd28205d13b5b679	12469
1264	9ae7e1842b101247766a38690d48e36d567496fd5a7c1d37796925a657100b43	12470
1265	9308546077f4374786dbaf5ab6c9ce2d2c42cef7d3f05bb287356d4a46f6a208	12492
1266	fe273dea76c7d82f8ed3e458de2985b9c7c07e37dc1b10959db95b03ca77e598	12495
1267	94e90ab7f1aecb9cc015c0bc68726969a764119bc977e1950d11af6434e3aee5	12501
1268	fa650526372c024f5c935b17fda9c8954745cc86eba25ce1ec677ded91270af5	12502
1269	22aa3514a13be42639f40b401c932173e43cedee50213c2e512fea244f253e0d	12504
1270	4d46a4406ace1094080bd62069a8da10086523d6c1adfa3bff92a76f259ea8df	12513
1271	5d9d3f1f5b955fa89dab6be594d509ef51ab57e298181f5cf6dbf8eff28b72f7	12519
1272	f35b4d805b7cb99d0fae6a5542ccf03db83afdf86699325ea836d47e1da9a6aa	12527
1273	4a73f40b58d0cf383c4b9a6d273f04ab8be10248762e8cc89601c2aedfdce7ed	12542
1274	6dccb8556962ee4b546971afbb0d66875a559c5e20eea3f3d62db016257ad8a4	12543
1275	47051c9ea94c2ef8c04bd386360cadc6f03539d860057c901a3199f5d91f12d2	12546
1276	be3cbfaec378b063f2ebac23af87fb5910b6202850c3328ac91026acf5f84db7	12559
1277	da5f53307222562a713bc99b738299f5dba375e988287eec75716910c83b8a82	12562
1278	33008091ee11e4f5cac1b13a6dda42eaee42180f4dd5c5c1492eef70c6f1bf6b	12580
1279	da5d46e33ceb3ecd0da2b7307890e3f7266f702e73c1a95c96237e273317c87a	12598
1280	61bd2d5bd2b35413555a6c30d2d2eb073b8bf3a06977dd55ac5e696e0380bbad	12624
1281	e0af27b1dcc18d1916c294a59a2424e2f6fe854eaa0bb108602509dcb86416c4	12625
1282	d4ad2b48ae3ac28bb66bf2687474c7f52db8e4d9e6093732726c998db80601de	12637
1283	0eaa1c1e82ffc54d0ca88958fc3d133f3aee4683e6b2a31dc9169556edf687d5	12639
1284	19f20e5fdf433cbef0ee8af6988f26fd01b6976ab2a9acd508cf72232511ce5f	12640
1285	f70394523ec08692fb6a1547c90839e17a726f7d7708fe5b5f639fdc57ed2a7c	12659
1286	73a05121b7fe3be8d02ee83ffdf022882444f228d0fb6ec10543f1ff0ee17915	12662
1287	6dbdb205a3bdd40ff0aaee8d37f3ac2c50389746e8192346518713f7ae8535fe	12664
1288	c54c89cf0a18a6a87bfa73a6901c29471328971987cef604884753ef6efdd9ed	12666
1289	cb3071581a02233eb9663ed5362338fd416b5f91c46153a82c423d701edfbf11	12667
1290	f0afde2206eafc1183601fa752e9aa9ffdee1639464a71d45f3df7923691fdbe	12670
1291	9c49e9a382595ca2cee9d1f2a48ec7d4659a50e89ac6d14ab614fe31ab6ebd3b	12698
1292	c5551b11c6c27ef88ad488cfa469939dadbbb16438ac1bc6b7509f35cd3c5d61	12705
1293	32b097d79cc8459bf8cba22a3643a82f14ba3f55eba15a7351752016a3ca1177	12716
1294	2302a2101bda95e21b681a600f7e873d33c1a8ce9b44aaa55afe63ece886c354	12729
1295	010da2fd5c2ec0abd1e249cb70b1c4aa6abfbddfaddcab80638108c07d4b2339	12740
1296	a901000a0e3c63cd7b6da274da652bc0a4b857adb4ea2f54b7793430813dc0b8	12749
1297	ddb6e0bd2a18a1d0c0d4213744722dbc174ea9c6cafe265be3e67e3ef2379eec	12768
1298	65ef93682e3ac509e762d201ff468b1f724d442f7db5bff7328d1ec37b38b0cc	12773
1299	7e1dccb08bd70ffa8616ce90241887f1982eadf2e02e7dcbf2f206eecf282758	12774
1300	b5d6e107ca705ea6359b435a80e83ae5e0d21779c045113263006f216af57f64	12789
1301	35a3cc1232795859be0061846db4eb49e49ae8a6f9fbbefa353bbe8168c1d700	12790
1302	aa16aabf5a4bfdc35c1ef053a3aae212d433ad9b8512209ee75eaefb2198eaa9	12802
1303	17e9651270b17906849e6a2ba3149cbb708ea2fa379647eb69b460cff87cff79	12804
1304	789a81d75b0603052c6325c94a6683488123151c876645268fd076298c733122	12805
1305	815baa2340ebba175187f8bdc14ae863491f06fd81b9b645c242d9598037220c	12806
1306	dd6b958211c5e7387f8afd8cccbe1c62c6f70dca495025fcbbfd6502210c2f1d	12818
1307	a40179fc06c612a0b67e7bb50cbc038534547f93ac60f59a630332e2bdba4abb	12828
1308	4ef7da8aea8eb8ce3d9e054634a34bc68d2d37f5a6c4a5af255c7c2c52a15e48	12839
1309	0829e4e13fb7cf22afece94c8cf20033e7c0f925985588bf3df057dcca7e985f	12840
1310	ee675458227a88d18229d0577e891197ded76881229abb562d36dff13ab5a467	12842
1311	331730880cdaa040d00c99b610ea01d54dea9fb88ed8a5bd254c2bcfaff4127a	12843
1312	be82c5d42abcc23bb56c51e73b423ad47464f119119ece8c885daf8344c02f15	12845
1313	85a8ca3cec168067b701e5f5f154b4a3438fd979afa031ec9f9ac294aa525bb6	12879
1314	e83843ebd2eabb47705746f08b50d01d6155780c466ed55c35ce26888f2e8e60	12885
1315	d6fb21ee7697b270aee8f92c1295eb94ad036bcfcb5b8eed4fc0db02000b5af9	12886
1316	e369d43a23e3ef48cf7ac93de3fe88ad9cc1d51a408fdf19dd4be837c50d40b8	12907
1317	89efc4263a24dc06da4e94bd51136ea528534fb279834428be4266b44bd0bc46	12921
1318	7b7d331f8b68610784f071d5984d3733e1d1d94532bd231fc8cea44b41aa6e2f	12930
1319	ca84ae5e6fabc47972e885e8371f2483272399c1781d2ac0cb3fd3e7566f2e39	12949
1320	333389ed3b957ca2965aa5f56452e3b8cd1821f878e0a2d5c32d73004473d0ea	12950
1321	a6badae553b9cfcaf19635f24a870f70a2b148b17f783832e4b4363e49e8a4d4	12951
1322	9f207d07fb08307bfe46db2a47470da318d1232491e258d7821451a38e021d06	12959
1323	b99f6d175be7c4186197cc4bc5991e7380166ea7469fcb68c1b0474f6a74a3d1	12964
1324	abe73d0241a6b0d7590c96afd6649a236a620ad326d84b6d585bee01226e5ffe	12977
1325	0a9085e5f6d62e629ead5dbc64e40f83622b1ae820507150ef863c85e6c423fb	12980
1326	9ac96bbd739e5a921ca629354d7d57c8a674447820856006d4ac1ae232dbcddb	12988
1327	48db849db7312d629ddf55cb5a4680ba050374bef4818a6ad20e29ed1da6297c	12989
1328	529633a6f9d2236326a85541ab24d07f3ba66c5d291ba707e540f93d3955d0a1	13014
1329	70a7f6ff388e74599b39c2adc8d0fc7cdd0de4fc6d327770e21d7f240c6a96cf	13020
1330	c1fbd1ed11265e3aa02c0d3151acbf989fbae7aa2de79ea638ef25f7f9642d66	13034
1331	06c808a4a00b5e987c750cc62e7c6410f8365a5edb86a7f738401cd083c97e2e	13049
1332	39499afdfa80d69b4d35c580f8f749aaec19fbc11345512e18c98101718c3324	13061
1333	52f05c0988c82a8287cd10c6ed092045a55c7454e5afb5fa9af4139cd8ecb5b0	13066
1334	7f9191709007b065fddfe29072c8741649165646be3a30981fe048fe86fc1651	13075
1335	8008f2c8204cd9e102c08bae7f89807ebd60ce090cabf4d5acd7ee411e273714	13086
1336	6e025781b97f31726e85b33f6d5bb09a7a4d0608e4ac946ee60dcef8a98a4b39	13087
1337	361bdef218870953d235781d77adaeb10ee6f149776e0b0915c1d74b6b68d376	13090
1338	0c22218fe5e21d106e056be4d8240122bdba6d40e4b9113fa2c2c8fc19630646	13098
1339	47cabea8d2e76e6203548544d9ff0df6214cf0a76e2e23ec176a354009b040c4	13119
1340	96d8585c81c54a91e56bf46d16de9629be7f212555fd3c59e446d3b4ee5ed664	13121
1341	5012034bd0acf6a6b5fdf8ee89fcc5c8c02b8edd3806bd272acbb0590809cc35	13130
1342	9533c30462106996e00add322cf4877498603b6f1fde150bc37f1ba51ee14eb0	13139
1343	e6a05c551f5b908fa07faa2e547af5ade8c7d60483ed745911f74cc6e9f76cd5	13158
1344	02985d697ca31727c7864af94fd5af0adeebc63526613c36916b07f7879417f0	13167
1345	fb3f70a54cdd3f74b69faf3d00bc5a6ec81e92e31463f1f501ac97340f33fd7c	13169
1346	eb852d798f62b252da01b9694e2100aecd5c80512358bc54d6f2167b1e21b190	13170
1347	738c126b68ac9ae8584d81b0dfed7615dc4313843a67fa96aad33e8dc98b54ca	13189
1348	e3b44edc57b070cbe6da75eff8866a4a2d58ea105df75c5815faf39be082755f	13199
1349	341eec8b91156645976e0552792f87a4c710d887fcdea92da4157e33e4f4db72	13208
1350	80d62fe057ee9b82513830a0bd2e0b088c2ed73829421f0f3736e60471b2a68d	13247
1351	a9ae68738c333468be22e2cedb5af49e73338ed0453c758698ba2d2cdbb91f02	13260
1352	6ce5757f8eddfea0327037c84a026498eca66daf957c0c0019bb7bb094736007	13264
1353	00e9a888b62cce7d711ab13e7d4d72ac30633701e559d570d1c54e529545719d	13275
1354	e78b3194ca2f17f5526db1a879c2a078cd3f42703f503e10e9d0878a485d8c91	13276
1355	bf28a0e0a75cb4bafe25e1e6fd75a39e85dcc101a7abd0a0607c058d0afd0439	13294
1356	26c7b6e8b04a6173872347f99d4493bcbd085c92bb95271260e466558e3c169e	13317
1357	afb96d349c4cd20d5855606759bb640475fc0de08d1b66c39f3efeb48e772e94	13319
1358	d8d090d78a381c55b4d8f4cab9ae9baf5307b832ad3de9050e3ea0fa09b3b83e	13325
1359	f9f4c44a80fa01ee45ea567ba564734f20977dbf6e1069c1c003d812b37e8595	13326
1360	9a92dbec8d5265e9ebce6b169e3037e6efc2c56f7638870e063651ebdc483ba1	13328
1361	1994b40ca726a786a971b5aef05e0b4b187970ba040fe96036ec4d5f6ffed184	13339
1362	5dd66e8696d5c6ffdc13fae99cd0b4cf5627db6dde4523c1db513d44eddccd6b	13353
1363	ae0ccee7d2aba285b97cd413355dae96e6872b9d393ac3c377a4154015d44ebd	13364
1364	e8cf3037825ed881cd71eb10bec76566ab0efd6e9eb95bdb779c4a5641eed3eb	13372
1365	c25e66516d37bd452ee235a00bdb09031e7017d46d1d8bee8b9fe5f730e03007	13379
1366	d2e1be6cf2bfafefad71c5eedde6980cba30db73c1f38ce611b05a72a4fc1782	13382
1367	e89061329f7e027601e829b27b97b00152dc9616724f399d8f04458a29db6d44	13396
1368	a00a58830674b805f8e7288f4f2f562cf7d2910cb1ae1b5d45d35510b7a7c113	13397
1369	fa6f058d76abe0d12e7636dc3ebf20188501e6dad7e7dfd49da10a82e635af8c	13415
1370	d4da1af24b50b819c06616b68c35471ca2565d029091315e50dbbe892aa18ea1	13472
1371	13673397dbdce595e2d30d43385213800b1b109ae64995817eb9599b4cc287fa	13486
1372	a13f675e1de79550079343987e58834a054e925872ae8d2a1994453c47b4a1be	13510
1373	a4029d5887f97d29af55c174ca5a7347778f13868d21776c5bc80335ba79c341	13522
1374	b4366421142f921e0ac139f142dbaed8f9818f3a222ff0efa9f9f2cb9b1db762	13524
1375	171084c7d52e016a4bcec95a8c763a9d0834f8ee4ca51d5330dbc5a160afc17e	13525
1376	86cf9799dbd36a8ba7b93b601a2c26010db0b41dc2a1b18cb8a773e424b2d1a0	13539
1377	72bf9b9d0c13b3caa8650b98896dfabdc1d4b3e4ca84087b2e324880f9640563	13558
1378	b33b8d1687d0460d4324f6444315bdc842cdf38b23fd8a9752f2916df7cd77df	13609
1379	534890a612f7e4179f14ef398063744bd11c5e5ade93890538c603dc6dbdf050	13611
1380	3a221d24c00e126213e7ea0eac07ceb77203b27087689de04d27e0b0635d61ce	13629
1381	828901646b38a5a939137cb9d5bc2825ef177a34dfef33d660204c50f3fe760b	13644
1382	c5dd28e24aa967e1f7ef8e48407e60773c31eee281b823b4dfc23655c588636e	13653
1383	fc700c4c57881c97272d795b6d917ba48f13b7183ec835f95b14c7ba4eb368c2	13660
1384	55af32c8b20a93397712de9537521fb544f5d5d82dbab50ad8240d3491bee77c	13701
1385	5e6cdce4e9dbda1c4c3a8ecc9c407fe74dd6442f1963aef2e794a0a6cf896aba	13724
1386	a1a97dcf9a588ab4ca83ef0934e2ad38b88bbc51fb7175a5c7a0ded73b3a560a	13773
1387	2f0b35369e8e57fd92c37a3c9c6c756ea8e47558511023d893031ae73583c861	13776
1388	9342dc90ead6d8c4d664b2eb30d132775159478af166162b6627deb4ccead2d3	13789
1389	677ff334110e51e2a5a436889450b2197fbcb960e0a06713d71582213a83372e	13798
1390	a536040663fd42af5106e8682c65a4121c3a4ebe4f083da71f062cc8a7424e38	13817
1391	b35096ec605b34407af6a354505e57824383dbb17d2b38dee3cad81547e1099d	13822
1392	26ad59c6a312ff81f0e0bd034e4d3d6ffbb9481c119780dab5be8ab52c533efb	13826
1393	7a8ffe707f45afb36069054a545904780bf3f23fa7e17361997210324f604094	13843
1394	69e1c7d83c5d3123042708a329b51ec68716104b544ab06d1b96daf91834636c	13851
1395	e55db951d981245a9ccd089de552228395ad01593ab901420d617bb1a2671bdc	13860
1396	f1b32b830486b55ba488e20c42646beb07f60a41f98ad0328d76fd4d6f0508f9	13862
1397	6b7541b64b276bea58f5b977076ff7429314d19aeb5b60f5ce18941857dce27c	13868
1398	7bc0be30102e3da7a5393a91e2c1338931710c02b1b69cfd99c02bea27678b26	13883
1399	5cf4f63e74fd08c09df7d21391df4a237e248758f95922cf5de2413877e33fec	13904
1400	f5f309ee9f1148b1507f6db6d9651442c628f687943aea508089dc8c0a4104be	13905
1401	febe32fdda8fe93fbd6541bfc129a729aa8570f653ea2e7a10b3a1185a9d1490	13911
1402	4a75b29785a4cf9a22230e01569391efeae5b959dcffaf0255b7ebbef8db1664	13912
1403	156c006ca1effbc7522dd7c0690ca55ccc3142593db417f6754788278e6bbf6e	13916
1404	f5963238403a1fe13694616e1a106b4a589f2e95d30047d7b3cb6858659b4bca	13931
1405	ae6d1e7694676fafac7f95f4ea79cf809321a4765515602801721698daa3d9c3	13934
1406	ad193d36b9e7eb059b567e54886f3bd64f5b67f3ee09fa3d9e4adb0fea3858fa	13938
1407	569cd66658f70550e01631854aa0bde21fe75e35ced86ee39a0dd496254c60a5	13943
1408	ee5985b2757fbd9a7d57343dd744054220946bd81d1cc125d96c39a00846099f	13950
1409	1e845f68ae8b0b982a9a46a1151ed60df6d3230ba1f6164d85f424befcee7147	13954
1410	decc47ef163313edd20d2ddb5e8098ffa4647316b918586618f83772dfc27ff7	13955
1411	e103843abc81f3fde64469a04b5e9b72cf595d9f53816c46172fc55ca7729271	13962
1412	164472b788291a5c6d9f20586982e6042bcc09344d9d2e591eb206cabf620599	13975
1413	b4ebc5b6cfe0ba5669e7e64853fb94891655ac2ab936da990bff7f4d09a76b0c	13981
1414	b4f3d01587a45b99a900a5de1dcd4c4983859035441b914ba5e605feec597ab4	13985
1415	6ecb293395ccca737dab45983152480154154f0e7c79a16cf0e1f502f2c620c0	14000
1416	ccd6ff8fda402284d58a0b2d6e4d788118ea8cffc9bffd95352b88454d7e0c31	14002
1417	14f36b4a2aac910b1da57eee65acbc89cde133076ef9d614945b6336b54bb7de	14003
1418	846d8f9fc19e52853e920d4ce1dddfc75bc998fa232ee5902297b41bab9ed2da	14042
1419	ad7a254644407e0cbddf47ca188ecab97c7504ae3f11d00c06a9ed6a1f7d6b8e	14045
1420	13079da2fa5383eec9a418b50977f6ac4e8f6fcc3eec55527679d70de6a38fb9	14055
1421	70ac62b88338d18820d088abf8678efd796ddb86ddce8e37c619255987278ac0	14069
1422	4a8400b2c7c7da7f1a9d1b7ce37e8169d04d7da59ea1b885d24f9e85732414cd	14072
1423	a5c0bd79f0481ba083b6805b25d48cbc6d14927ee040147a2656726e96147126	14094
1424	bd5bc18dde6e6d13a2e52d133d61d19771e394bda0a819ae8fec78fb2da56159	14098
1425	ade4414b93d3c2fe37daecf82a0d532d5e10826303205f9cdf977362da54f770	14100
1426	986e1cb65c1e79575a96483ef70d33883368fdff224bd3fa8e5866aa36fb45a4	14106
1427	ec1a0c5da15735d8bfa28c83d7add35bea533e74327b3ae9ecc51a97c922a3ec	14111
1428	4cba677c110dc8e1ea58738934bcf4d7ee3bbb3a13beed4d7be51c01999e072c	14126
1429	71aedfc847115e92d94f5edafeb7687844b2dc619893ca5ba8814538e6452b80	14135
1430	b043decb6483106fb9a462da52f075c91941fa2272f609491753017a1cdbc1e2	14138
1431	4d6229962b3dbd62f7182918f90f2b72d124712eb9720a39d66dd53560a145b0	14145
1432	4530f0022bbda7c98ce7a36c01d8b5c94171a8a9484de99510b852344e025a04	14147
1433	935a3fdbbcbfdf56ade3d3d1c48ee1f2012e98d99f244c7bc372c9685ebb460d	14164
1434	ffbc65ba2a7f8aff480bb8b7c3f85a2997ad72f4059b5fe27c2c9c0099a5cc56	14170
1435	c62a68b46edfa6a8f10adbc22053beb716b9cf92ada24c2f17a5d300c9a707e6	14193
1436	8aecab8f616b05e301a666c21fad1162f4466c72f0a451e6da0f397490316271	14196
1437	4697f19e93ffac9d8277811374a68ff19fe6217c92786a2721ab095b0abdcaaa	14197
1438	32a2f0b4e206726df800579110fb8b80fc76320bbeb4c4e86f063a4a6537b7cf	14224
1439	c9b7abbc2ed7221054b19f15739105a9301c86d784f91844de10a9a546f65012	14233
1440	b7f0e0683677c8a8c588a9a0d00a62603b4014e4988d512224cfedb099f4893e	14293
1441	678e950eb33c37b2d19bdc79a34099dafa09524836b2a0df2bdc63b9a2237a99	14303
1442	3f0e5db96e35d78fe178bfe0104594601bdddbd532ef1c35d401b5cbce43ec69	14307
1443	6caf6830de8cb1b5e5085db113b9927e1437a03f9c736998a5eef99c2a50982e	14317
1444	1b12c9333a6beca37c1ad1724b1b12d667d7751fb91a0967318a061a92a1a4eb	14325
1445	b0238b1e08eb236e37965f0d41feba01bd7754d229450eee87976414532a2394	14335
1446	a320f8c5367a154d21a9186b9f2d6dc5459cd46a77020403de6d2f38e499d87c	14350
1447	f24b1690a3a53253de0c776e6a49c3b7b7b2b2de24b8ad881452c67a45a240da	14374
1448	5f8156e2d9d11ae816f1e726f28025b084077512d8374f42e9c3da0e429e0ed1	14378
1449	4ec0b006d08b34c2d51d44299fd5bd27fbba85e23ba0c362e01df70be2295c3e	14387
1450	8d0716e0c3a37c3ba119a1efa5476df4df0a2a8db00b1f5a7c5e2826c13c118c	14443
1451	d530855749168156fd74755b25ad0b7917eb11a604956cd21049e9fcad79320a	14446
1452	737c872dc14becb37e5231095459262b313fb6ede3b3306ead1f3bd0a9d8fd98	14475
1453	04301f33279a26014a3723f9e2a25edf58f1b3d630d384b04e3e06ce9a6568e5	14477
1454	6ab5ef3317f437c86d8047067a62fe08b116dee4d8b92c6ad400b2b8164c38df	14480
1455	f839c2d0bcfa9fdd9c0b100b4a918666e4ffa7c5ef1d3afde5f3e823f98fb5de	14485
1456	7eda8fb08abd593a8c8f5fcac330ad73d9e2806978461dfedaf2e044a0367041	14502
1457	8b19cebba2eb6b7c51abe22b0b223544dab6d52ea1feb7b12e79014e0d848d1d	14506
1458	40ad583d7dcfcf9c8048ad385b28f59e45b59b6bb96510ad5349044732dabd32	14516
1459	3356a5705ed9d7ae8ae4bc4a7574f75540ba26a80ba2bf1eacc5bdd31abff975	14521
1460	003982f2050ca9c049fcaee3e4d89afd6a0b77ba1ad64815d239540f43a07dd4	14535
1461	75d5e9729bc332ee8457cf45a9ab458291ed78a0cb19324c972ee24307ddaf91	14562
1462	e13795923ee830637e75a683c3fc4bfbfd5419707c7bc6223649108b80e2d124	14566
1463	90f47276ffbb2859d48345d8c6f32513e843351ce0cd070e1a4b4a58ed00f034	14571
1464	dc784352361a9ca069313e5d73a2abf1e2d7f833c8a99570d7fe730596cfd71f	14601
1465	b8d3d3fb956d81f7133aa356fe082ee7c350f18367bee441da24bc25c6036d58	14621
1466	5cdfeb0854732814c934fcead9e945388dc3f65a1b0739825be24a89077e1874	14641
1467	4fb57769cfc941dcd7bafd7c406cbbcdbc777f900688e02b0f751d5748c0efaa	14657
1468	ca6539cdef2ff415595c0e877a2a7bc6d3ae35b9d68c98b26acda05df63d33f0	14659
1469	767034f72c2dc69d1233288b7308830b2198e077f96692dbbf716a57a9cda141	14668
1470	0314693fbb6c0ff56da38ac1db582e72179bc868a604c7863ddd6bd583defe6d	14681
1471	e41f630edd1fcd40254c2916d4fd8ad9e45a0521ca76b0fd8319b303694bb8f4	14692
1472	2f8a408f4561d630dcd4440c2fa32319721a10ec7b0a9e5c86c9fcae33b0e61b	14718
1473	f1030a331dd0757e482972a3bd722e007858347c3a67523e7e3180ee5470e06f	14720
1474	4a903063a7108780fcc4a485534c5c390bd382f65ab0a84db01dc2d3a7db8f63	14727
1475	99691c1b8c074b2041a180600d5b1163c215a3c0c4df8901422b9be60eba6644	14731
1476	e5f4944b179e92e153f7018c1c16d2153eb112a644c4a65e84e29b0789a704fa	14733
1477	d9faf0dc44447175a75f037668c03c19331d54bb55034e23ecb4124ab86ddb77	14741
1478	10f0ae7838bc91a5a9ec9b259918c57a4c4d0e053da914b8e6a2868a0acff0fd	14748
1479	8b9ab2ef496711629f6fb1df93af0f636a0c3f839a26364cec071427f73bb0cd	14754
1480	24fc2e1ecfe37202a438b778db1746db371e83c9ea4d215c3e2cc0dfd1f064a5	14765
1481	30f4de337525995343f417576e4cc707b784b84c4d2e607441a3127b90508b52	14766
1482	466bbdd74d4be4b2e9f3854fef281c42d334406c660738e21e51b4cc849454da	14768
1483	40398db1658208161ad9309f32c1100d9a8f29bba02e9a934a134658cebaec57	14773
1484	fdd0aab4601cae85bcdff9d3a3147dc5587e6be5a16d7a446230627d722b018d	14782
1485	3e05534ee7e38f28ad93f6e9a412b7a9e41088f2af069655cc2db58b209223a6	14785
1486	5d6c28cc8eefe2d68b346bdad00007095ebc63839780ae41f1be56ab988abddf	14786
1487	508e4d6efc61e6746c28feb54113cafcbb654aa52a90574980163606fac45d6c	14793
1488	dee124fbb9e033d368d84cfcbf1909d65e12f541a05147c030d46b0f34ac488d	14811
1489	630d1e440aad95acf87ebc68aea25ede09b71111a13f5999b9ab9c5332034b0e	14817
1490	248ced397eae664a7740d4e9c6ee5f03be469a2eee42b2ce6d9743a3b795edf9	14824
1491	bcb2a99f5fb6403d6f78e1ce415442e354365ea0c821c2d1376b24e4a62471ef	14827
1492	eac29bd1f1d828da48273b1505d6f73d0f9e9cc6514ce030661381f86792d1c4	14831
1493	32824c4294ef8e782f8dabe9582faf38a5dc78882363d0911ab3d4b7ab490ed2	14834
1494	0a97377cd51833bd6255ddb9c6d6bec09636f51aa7624d9f06daa4c3454ccbe8	14845
1495	9f91f9294bb39f9d384acedfd1405301c5bbf76879ec8af695ee04a21ceff458	14867
1496	2864d348ed2e01289ccc7bd4d9a2ab9404f5f48a86ea7a8655ebea50eec013b7	14877
1497	abe60457b148f22f35180339b315ceda6eeebefe3341d7cb42865996bfad13eb	14894
1498	31ab00cf6d88c2d5dba0144d340fcbccd131e2d3a6273e095aaf25bdb6ef14a3	14908
1499	382dba6c86631a821c7e1482027f1fde7717d480cd410e7d38a638ef495f2036	14931
1500	56ae8734b9b83c587c6f3fa99c15858c11ab07ec9e68f556e09db1d41c51cf64	14932
1501	eea8cf95ac0face2fd02fe4409d9c208661f90e042d727676b243c5dbadcf485	14950
1502	cb8b1951bf97da840ecc610157406bbe672ceabc21ba28583917a6b9031d81ab	14956
1503	06b50b6dd4c708e9912914e01aace1ef1a6f53632857f35414493ce2e609c971	14957
1504	3b0893c77511c917c2081e1b3af35e4edac33fd9e66ec506a8b63f92966cc449	14972
1505	1e20163b2e64b981f0566408a1995be7170f74038c109abde0b61ecaef010bd0	14977
1506	008f010fe0035c9fddaf3ae88b7038279467151bda5a1fb60adcb6c0e2408a26	14980
1507	d4e781960c40c4327cc79bb5ab87a870157f22ff2fe8040dfea09e9a2f5c98c4	14986
1508	194b3c79fb4a0255a1642847f9826e48fbd371e500211dd7d9b6d65d86566cd4	14989
1509	4f44fb70b44f3c8cf7057e92b433d7c12bd53dd90bb67b1ed128be2295e0808c	15021
1510	191f4e3265ed6afb102b12ea2652ec61c26b9a021287c7c4b540ddfb6a340b25	15031
1511	c9fd0e337d4182958c4951a699408ad5b1c973403c2b7a858d12c5179baf7791	15042
1512	05a6f7260e8f354db21b509f45c388ec078c35e040e547395c07bef4794f79d9	15066
1513	6d4d31e8a80939ac28aecf727aed12e3d7609fc1ea7c27f2b57dd1892f13985d	15095
1514	8c22330699ae19654f2ad7214c3851c4a2da953bbc070c1edffff8f98ff26efa	15100
1515	3ab48f9caa7c187a816c9056a47800b2a869168c08e83d5f420096b32217dd96	15101
1516	46222909238d9499c91655855e6bf78820be84ecad6fc41a93cc358f78005f12	15107
1517	9ec1dd55128cf4dfecb1c5e55f1ec9baa31f1d57c036f357fc9fba4299deb061	15111
1518	50ba92f69d4378be6b35442f5d405daebb6c902efbb3249ca5ac858ee290c804	15113
1519	d7b38474153705db4011ff887b41bfe6790af8911afd4277041ee5ee1b245aa4	15115
1520	1d60dde05cf275fe207af9e8864d96b283d4189621dc9abab274a32a3af0e9e3	15116
1521	7fb780dec0b154fbb18372fe966b15bfbeb3e45f6d230e20507907045932fa2e	15123
1522	548537b1c1b8d7fbf9b0dac46ef7779270a7e399694999e566d628c91e4583f8	15133
1523	4ed2fb72ce5d53a8049320f0f24e719d80f5204dbbd84fcc7dda1509c965ffa7	15144
1524	c560e5c5fb36718c88303893582383278b6092556e41345879f23f485bd0a404	15147
1525	aad558e543447f7298ad43df4ae43782a8acda66346588fb090d0a5cd4cf9a41	15148
1526	989d8fd1ad7bf5fcdec627cd0226e2964ab9312d7e9625d4d593375fc980c293	15156
1527	7de94a09d819a621db9a6cb169c2369d282f9b8585c4e1ffb49b3e66530a4ea1	15157
1528	bba12eaa1502cc4646099c4c230384012cd7660d1c8fdf7fb2cd4724d4fbea02	15164
1529	2a7bb62c944924f742bebac3d3f836d89b6aead91f837341d62c5fe373d47868	15166
1530	0bb1444ee89830e80846ceab12212c7700af9f6d19d1266e6271f8e82b0fef54	15171
1531	1900cc1da83e6da8c657e67d18f732104c09bc91b49fd2739fa6c241069ba421	15173
1532	707d8a2dd19eb5a1fffa36a799795f57dbd6224feb182da04e9b89b01198ab4b	15184
1533	0b67b7b4458c15c86b7ab0b21140c65946cf96ad75ef76b04d14de91bb84364d	15192
1534	d4844c6bd764b4783deab357f3df5d3f7ae2576547bca3d1e9a64bc7f303e8c7	15226
1535	e25800bef3f212e6c2b7dbb04857dd0635e20d4d60da258084044f3795df8708	15230
1536	ba7e13b982f4635650e2a11e9df69d30dfa76e229ab2d758f2f51b1165c4948a	15239
1537	a142cda319203e3c31ca3ae7e2d9a8ae75d984d6497174a33999f11be525e96b	15242
1538	386282cc139c3682c7f30cd0e6687dc259858f16b55fa8e9a79cc9cdd7a2725c	15251
1539	4a4029dd28b1c01f7da7ea4019f50745b0e5b295178208a660245c2fde071c34	15252
1540	7733550b6c0c36140a3124f51744450bf8512cd88cea46bf617301d5dbaea670	15254
1541	c05dd2adaf9272559dd4162e5163e8c1c93fdf277528d7b44d16556b228a0325	15287
1542	75413d79cb5ea0cd87bcd0ad2d1ff4b2828185826e416cff7eaa761b4be5af09	15299
1543	f08ccaa02980386a650628ba5ea975b5a1572b6a0419a9adfe2fcba7b72fd676	15324
1544	f8c7cfcabf20564a587796fd916dcc00fd234667528fa4778e499ee5a56605cd	15328
1545	2103b01538e747f164e5593f3025dabd56316c718811de200b561a1c9b7ebd34	15334
1546	13e58b7043724685380d94ab167aac2c7bbc6e09cdf00d266ba69951befe4f7f	15354
1547	a09f5ad338def684274a723a1021a56295c55d8332f3d0b83696bef0a36a52a5	15357
1548	ccce413d6e8e7d8106cf29744d16a0945ae2927987df741893c2c61dc19d240d	15370
1549	483aeabe5f99ac713ffd8b3f7954b05002f29bcd7a8d1688afcd9ec5cd79d02c	15395
1550	e0a266c1162d42c8622aadf821c8014f0a2956858072103639f3f6225d9ccacb	15402
1551	cdc4d01a612e9166d8f50b5e4d19f16bb7b640de0e4f240f8bb8a9213fe3c154	15404
1552	0b2d21383341993ce02c04ccbfd87569bb665f60831137fc7e7962a6cc144d60	15413
1553	5e3b3c881bf80adcb38ebfda7ab9652148811ee8118dadb829d9856991c0798c	15422
1554	f3e63c5342bb83df883061f6867335759ac1ac9ac76df8dcc4d7ecd4cf408f75	15433
1555	6cead7ad218df26d648d2a954b5eb2c95adec3ec4c0eed05349346941ea7392c	15434
1556	03d8b1574fdbfab7421aadab6b99e4b1bd707304044f56bb62013828f7e383f3	15435
1557	a208e6f3a4b48cf93ffed64b87cc2dab878a467ac737a879f252a755e02c4573	15437
1558	948a8ad8049b0911450bb33d628cd33ae626acce68294c83d1456c2e1a16b28c	15445
1559	eefd6865bf868163f83b97a4d74a9fe565b6703aba992d656e0e73ff57c44a8f	15462
1560	54b35ca441d2e57cf1dcd22beb6da4ac3c8ad91b6b1387b157ffc004eda7ef68	15470
1561	199bb93a87765ed2eae50f1e6a56957b7ccfa2f60d8b79bc3135eaa2daf4045b	15483
1562	42727c99054f0623f4222a0020383c5358e0d9b222d9775bf3b314dbbf9ab734	15488
1563	1c925248b7e53a4771e24191a2471665f880a782e7ac3adbab687ea6ac80c0a1	15501
1564	e380e6cf2b5fc7c0cd41a36c85e4f2b5f23605bdd83ae413962cd9b0ac8090cc	15517
1565	4d477956f24665b0516de956e1dab27f3af4d5ba13a799ffc1d17d1a15cf4c78	15518
1566	f1036b2ab14465703eb9d4f3c4051b5bdeb1a83afa793d276fafc2368a6b8cb5	15575
1567	37ae8b362d2e8f762a02cac35349b1a9bf4c50fe38e9b15e9dc7409ae36c8c77	15588
1568	c0e41de3164ccbafc4dd71ce837323da9fbe817661cd7decd638b26e7373794e	15603
1569	f7904e3909256a9c7a417dfc73d197beda9ff59a5aeb3c2358d26e1e74d4c84b	15605
1570	a3860a59b87af4befab36ad94a145375f88654a20b73ece886207f3f58977253	15607
1571	602ad0abda2d48a89f12238f758ddee042dc28813b0f6cbe3ad4bfa74fcd7b30	15621
1572	9093b25f3b1c80ce5696b356568d2a275ce5beb1b3748631bef5cd876e7f2a2d	15622
1573	3014848ea5f82cf007b1fab827fc3c3033f822f817f568ecae976d3928639550	15624
1574	ff7181fc701035316c07f136944874e6c0f4481317fcf003441f9bbdaa0ade76	15640
1575	39fa01a05419872f04bfee6adf63be37e018d0391fd5157e37c8ce18c3da8739	15646
1576	bfe1015f5bc794b136d1ffec1024f757a2f2eddd8f6c371bd01725bef07238d3	15651
1577	ed74b7a812f57d683f220a0585f48b44dbd5a90dd8661268e1c634dc631a0072	15693
1578	fe4d1cabba1f6c903a78171934298c1314f27d42fa149447c9ab6271430c356d	15698
1579	45db3fcdf7748cb989896f43a42a0b2e32f71ad6947cf6102f02881999a16512	15711
1580	d2763aad39c64c27f1b0eec7f9e68cb55c3e46f09703ec5bb657158143cee72f	15718
1581	d7ec9ae3991f2123e64f735868129d51587e475cf5948b4e2f30198991752307	15723
1582	e2ba8e674b529dfe01595473e6cc88475c69c8d2924f4238f08cb034953908da	15734
1583	9dc527e366709db556e8deef239bb28e0f9375cd8030243da723927dfe0cf9ad	15736
1584	9751aea1abca2f62008d5657e65b688eb384ec1ca9c1413a12b99e3e129c249d	15743
1585	9e0a7514dbe2a603055581d511db23ac469c41093e8c0ef75dbab038f8cf5f25	15760
1586	5a38cec9743e28d0c130d42ff55741d7a406e14c2aae0e1659f609a95e4a30c5	15772
1587	bd3922140ecbabb5541517c2e6e884cd1255554da8a7f9bb7e445e0a02c39d5a	15778
1588	390757e9139e45dc0b524d5d04d0628a05e989b793051aca49ec094b707c930a	15794
1589	daaf91403b6345f5f1a2456d47336d4ff1d0472a276f17004b630532b697e28c	15798
1590	a8d9856b3b3aa0755d8b4ea7c4f87bc233a4fa11e3d1184f1c14813c8af98a96	15807
1591	244eebfb703ccba257a06a454680d5ddb981d249e8b25f15a3da1b97410af842	15809
1592	8c4dd557b5ddb103d811de639366c4ecc8561c6c34cedfdc04a135cc736a991f	15832
1593	3eb98df199bcdca0f9cef66124c2fbbf71c672d118d20ac019dafee691fc9997	15836
1594	d31d2f606a497a56d3d78bdc605c9ab2c523ea1e067d1b552636a0c2f3493f3c	15837
1595	6eb0c08a2dbed7a6f6ba9e2d0473d5a59a49268ddec1b7fef3b030ed05c87b86	15850
1596	154c89346a6f32425c9beaabf1a53df57701155d7226026de7af8f013a834e88	15856
1597	f13c10150f0e8c2faec98ce272cf10ecb210844e64d6f9c256276b101b8ef951	15860
1598	8df79c295f736b0f3d7b818a8c9aaaa76e4f342ca306de3a87b6b9d7fdb17f6f	15872
1599	fcd8af2c15fc3e3191165242c463a2e35e33827a1c59d7090d964d052e6f0857	15876
1600	b0fd3df8729df23d1b226eff233f341cc0055426ce84324b28c0fb44a46bd089	15892
1601	6b85b44ec1f01f2f0241980fa30747b71880915c6bc35ac30fcc2728b788f586	15915
1602	859f06a21c2f6e9f675abd62a6a5ad660e3f073d35f2da3c592f3aa1cc50b47c	15923
1603	da8be65ef5b515cc18ba33b2e70836de9f1958f9146d3914724709e74420a56b	15942
1604	4f1e6cfabbfd32ce3051920e268ec2c4bb117d41872db814a3dc013e7561696e	15947
1605	ba51c7b6ac79b37ba84e2c605e5344a9f78b7532130f4d8d37863f4e35db5085	15964
1606	cf48d5ebc23d1a80183c7c4c04bbbb5e53ef018233538bcc6a857c1dfd465b3e	15969
1607	f036fb68fd3ee22ad22833c0ff180dd3a377e35b9c73fd60d5a60f55546a9944	15976
1608	4d1fb1af2b0886a9a39f8136f5a8bba12d7d146568ede35aa9721e6690827d2b	15978
1609	0e4414b4d12c42626e4bc7ee82ddc0f7e474267409f36e996389e203342e935a	15987
1610	e757a316e5974582366e9c9d5bc3fc977b70afe22b2b01613a1e9bc23a5c8da6	15991
1611	829f83f1f016a31f731114b0504f5ff6d8567610d0c13fbdb5e720211a5ecf44	15992
1612	df5a4738e90d76e83e59f2db4d15e429e17d75a85c002ae4a8f9e79e1a866254	16025
1613	26f6dbf9bf87040455554b1f98a1199b60e39394755807aa8a8139a6a85443bc	16027
1614	6466694dee168ec07348d986b0ff02e9e15f0e9cef6c9c63e6c1a4f8bf24c41b	16030
1615	ad42bf26bfe7fa84d6960dbdcbc1bf1fc367b453a5eb1afb1b33d9973d29993c	16035
1616	c00f10f08ae4b7a228f264a87b04cfaab24811eb8b74fe59d83ef981676993c1	16039
1617	435c016dcefb9ae9447ba48a46b977a6238f776d7f246219451c3bbef945addd	16040
1618	f126ed144aed25cd85c292aed3299328cba5ce7fa9dee6efc7a621dafa8e3d2b	16041
1619	b608eecb177eafbbf9eb192e387eae424ec3b68e48dc673ade008fa10bdd40e8	16069
1620	40bc0ac0afb29535efec3e1941111f5a18ec37799cd0598b62b0102a65099706	16074
1621	bfe56ce153cc753dad94653b6381f6bd1c2d55ef20429f575bb403fd7da442b7	16078
1622	c6719c043105dd82fe265d4c925475c37e3f1d0fa4763ce0ca303f98961bcebb	16094
1623	1d76e6a1ec9ebece6f6ab549dab26136868a822c423d4482adcb3af1c0ce7808	16100
1624	0bb37837498a90f80e970cd8226629434cfb93213f4dfa2926c86b8cb497b4f6	16124
1625	054216f4509e0e8df56494ff76190898012a68ea736c842b6ee9b561e668b8fc	16126
1626	59d971f53047db2779bc306aea521797c1d2e2c99da6382b59ce968a51fb2b2a	16131
1627	096f841b66087674971a6bc0da52732212483ccae5c7b862096acb18f55d3698	16138
1628	978cb741cf6b44254526a18d5e74856e4907275087058c5230fb215368cf1345	16146
1629	77c2011d5bf814faf7635ea5e88b65e0305a252bdc8627f9ce057459e2abb65e	16165
1630	b7f2008cdf9de7e0e8098ab04975b92e4113dab814e6e7627455971247dc007e	16176
1631	5cbaf8dfd2cc99f28a09de710df8ceff687f5805314ef63abcf7fbb6af42db08	16213
1632	8249a443d5edba271c5f35f660d4ef6f2151fe274456f9bdeb57e9f606e9adfa	16239
1633	33d864f436434cf33c95b8fd1d537bd4595e49527552659680948a02379623d1	16243
1634	d04be6c28594add7254c777d18fe190f62d919de1f86eba5f4774c30fcd46c33	16249
1635	d61fb718e10c64e0f1b602b74d0f9faa87c2eef86a5689d637d04058fbc15cfb	16253
1636	0e01b52d31d3a54c34958802a7b19ff19852aa6cd6213773bb671a2b6b3d87f3	16255
1637	7289feaa280d0037c588d8942a5b8ce433ba5151d7ef942e1060eefa14d06b43	16299
1638	cc2becd55e8358f15d6aed0e6f4187ddcfe2928fb443149ef16322a2da3aba74	16302
1639	060d11a77cfb5d471673991bb377492af033c4ff1b18ddd5ad7f66b696003176	16317
1640	94bb7e97c27bc78a4e95bd5674d35acadd0eb6dd3fc6a4b9d508f240a0c7c39b	16328
1641	a5f86aa7bd31e54d731dddf34472139dd3584ce4ae37dce5065639ed2f69f352	16332
1642	352875681b816c1af528f45ef0efbe2faf574d5c6a981dac3bafb5bb089b0759	16342
1643	4bdc599ace43da577399aa98266036594fb20b16e91a535a7ef84856dde6a941	16344
1644	924257e01246c3cd55fe52a4edccad96fb4e7d6d7e199d23fa51872989b6ebc7	16371
1645	19d33b83c64fb6af991b5f20bbf227ac609fa4c7d0dcd7c82a6a63487919d57e	16385
1646	1514da08bee6093a66c0022dcc82a56f6a6d99b502bf05aa7f80d422a37e4d60	16398
1647	f63a708250fba3b52e5d138f5fa768ab05d7dbcd2c3624b55006efe2718e7fdc	16404
1648	ee1ee9dd6b9b4d55495ac9770facd372a5c0c5e2126e81ad5b0994225c0ccf31	16410
1649	a5a33777ec278c421e418f5174a157cecea8607a6ca9e3d55e2922a4c78ae7b8	16423
1650	f1cc26bc00373acfb481a8b965fdf867cb16b689743c38f720da5745c19cd4a0	16443
1651	52f5d87cec708ecf1e243996b51831ebd69997cab64b34f8f1ed5d788abcd523	16456
1652	e9597355e4a00b296432f8f54411c18d65646d8825ee957e7b82c8b92a546843	16480
\.


--
-- Data for Name: block_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block_data (block_height, data) FROM stdin;
1614	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a7b225f5f74797065223a22756e646566696e6564227d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313933343431227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2233366462346533303464343638326162306331353538373032306166303439643734643835323334623330363234303030383630653736353430616339613739227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2232303030303030227d7d7d2c7b2261646472657373223a22616464725f74657374317872387a3772776d35796b3468746e377938386176646e3630376a766c686a323738356d3574766539687a33636b37773975786168676664747768387567773036636d38356c6179656c30793475306668676b656a74773972336473346578676661222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231363136393638227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b7d2c227769746864726177616c73223a5b7b227175616e74697479223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236363636227d2c227374616b6541646472657373223a227374616b655f74657374313772387a3772776d35796b3468746e377938386176646e3630376a766c686a323738356d3574766539687a33636b63763463737779227d5d7d2c226964223a2238313465653639336366303436383234326234383632613937323738356539323834643237306162653566326236333062373239316236333361313661363763222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2264643565633963643432623134316531343661626139323136306265626536623866663339363634623033393064343731343332343935303533326333336166222c223733626565326138306535383637323463623332386137333932326137353130316461383233396237383661613336313433376233623938306536633431626532366432306164643735653232663161393163623530666437386663316634356338316438633166326432316438376234303863613261663664663930303033225d2c5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c226635373337356662343161343331616439306130393061626634336333663966616434653265353039613236643638656234393435633432303235366130326137623365646634653939333533323963343336383237373031333239326561626234393963643966626435396563363263303635333965376639393234613061225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c226662356630363963393263346439643139643965336336383762373038323637396137353036323034613766373830323235323937373832633235316531616139353161326236626538356231653934333866313265643131623533336435303538303739333030663636346364366164303935376363633739656531653039225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313933343431227d2c22686561646572223a7b22626c6f636b4e6f223a313631342c2268617368223a2236343636363934646565313638656330373334386439383662306666303265396531356630653963656636633963363365366331613466386266323463343162222c22736c6f74223a31363033307d2c22697373756572566b223a2234306530383361373137353133646162333263333761396162376337336665396430353039336437643036383462306435636534643134356566326136613833222c2270726576696f7573426c6f636b223a2232366636646266396266383730343034353535353462316639386131313939623630653339333934373535383037616138613831333961366138353434336263222c2273697a65223a3632342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233363136393638227d2c227478436f756e74223a312c22767266223a227672665f766b317139716e377376733970386b39707a68656861306e723536346a7337663374767361386d6a77667471706a30366d3233756c6a7374757a307278227d
1615	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631352c2268617368223a2261643432626632366266653766613834643639363064626463626331626631666333363762343533613565623161666231623333643939373364323939393363222c22736c6f74223a31363033357d2c22697373756572566b223a2234306530383361373137353133646162333263333761396162376337336665396430353039336437643036383462306435636534643134356566326136613833222c2270726576696f7573426c6f636b223a2236343636363934646565313638656330373334386439383662306666303265396531356630653963656636633963363365366331613466386266323463343162222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317139716e377376733970386b39707a68656861306e723536346a7337663374767361386d6a77667471706a30366d3233756c6a7374757a307278227d
1616	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631362c2268617368223a2263303066313066303861653462376132323866323634613837623034636661616232343831316562386237346665353964383365663938313637363939336331222c22736c6f74223a31363033397d2c22697373756572566b223a2239656137393939666566643831636536383932616632336363366434646466316139613933356562356331313539376366383535316633336232306535376133222c2270726576696f7573426c6f636b223a2261643432626632366266653766613834643639363064626463626331626631666333363762343533613565623161666231623333643939373364323939393363222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316878686b74707236753963727575376434726b726c3463733764396835706d7035663565346465766c706d336e6e6367357a7a736e766b303661227d
1617	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631372c2268617368223a2234333563303136646365666239616539343437626134386134366239373761363233386637373664376632343632313934353163336262656639343561646464222c22736c6f74223a31363034307d2c22697373756572566b223a2233393461633535323838373266623261643364393830336539336237343235613639323835306362333736313539333130333637643734323463326566633835222c2270726576696f7573426c6f636b223a2263303066313066303861653462376132323866323634613837623034636661616232343831316562386237346665353964383365663938313637363939336331222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3168753066753534746a647535666d6a76396c3537796739337076397667666a7a72387238737a7035676b686b7578777064376a71637475347373227d
1618	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631382c2268617368223a2266313236656431343461656432356364383563323932616564333239393332386362613563653766613964656536656663376136323164616661386533643262222c22736c6f74223a31363034317d2c22697373756572566b223a2263613965326431616135643936313037346130653665346635373565306535616235613432323466366262393964363266313437636131343132396538356139222c2270726576696f7573426c6f636b223a2234333563303136646365666239616539343437626134386134366239373761363233386637373664376632343632313934353163336262656639343561646464222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31787836306866766c6a7367386d75346c7468397266666a71686b79673078726d6a7868663534786e786d306d7461326e74347871337870386b39227d
1619	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b22626c6f62223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22626967696e74222c2276616c7565223a22373231227d2c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2268616e646c6531222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b226175676d656e746174696f6e73222c5b5d5d2c5b22636f7265222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2268616e646c65456e636f64696e67222c227574662d38225d2c5b226f67222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b22707265666978222c2224225d2c5b227465726d736f66757365222c2268747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f225d2c5b2276657273696f6e222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d5d7d5d2c5b226465736372697074696f6e222c225468652048616e646c65205374616e64617264225d2c5b22696d616765222c22697066733a2f2f736f6d652d68617368225d2c5b226e616d65222c222468616e646c6531225d2c5b2277656273697465222c2268747470733a2f2f63617264616e6f2e6f72672f225d5d7d5d5d7d5d5d7d5d5d7d7d2c22626f6479223a7b22617578696c696172794461746148617368223a2266396137363664303138666364333236626538323936366438643130333265343830383163636536326663626135666231323430326662363666616166366233222c22636572746966696361746573223a7b225f5f74797065223a22756e646566696e6564227d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22323437313635227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2230383738633732646661386238316264333361623564663138383066643739343366303662326666636334656165326361616139396263656135323364356632227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303036343362303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303064653134303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613638363136653634366336353331222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b2263626f72223a2264383739396661613434366536313664363534613234373036383631373236643635373237333332343536393664363136373635353833383639373036363733336132663266376136343661333735373664366635613336353637393335363433333462333637353731343235333532356135303532376135333635363235363738363234633332366533313537343135313465343135383333366634633631353736353539373434393664363536343639363135343739373036353461363936643631363736353266366137303635363734323666363730303439366636373566366537353664363236353732303034363732363137323639373437393435363236313733363936333436366336353665363737343638303934613633363836313732363136333734363537323733346636633635373437343635373237333263366537353664363236353732373335313665373536643635373236393633356636643666363436393636363936353732373334303437373636353732373336393666366530313031623334383632363735663639366436313637363535383335363937303636373333613266326635313664353933363538363937313432373233393461346536653735363737353534353237333738333336663633373636623531363536643465346133353639343335323464363936353338333537373731376133393334346136663439373036363730356636393664363136373635353833353639373036363733336132663266353136643537363736613538343337383536353535333537353037393331353736643535353633333661366635303530333137333561346437363561333733313733366633363731373933363433333235613735366235323432343434363730366637323734363136633430343836343635373336393637366536353732353833383639373036363733336132663266376136323332373236383662333237383435333135343735353735373738373434383534376136663335363737343434363934353738343133363534373237363533346236393539366536313736373034353532333334633636343436623666346234373733366636333639363136633733343034363736363536653634366637323430343736343635363636313735366337343030346537333734363136653634363137323634356636393664363136373635353833383639373036363733336132663266376136323332373236383639366234333536373435333561376134623735363933353333366237363537346333383739373435363433373436333761363734353732333934323463366134363632353834323334353435383535373836383438373935333663363137333734356637353730363436313734363535663631363436343732363537333733353833393031653830666433303330626662313766323562666565353064326537316339656365363832393239313536393866393535656136363435656132623762653031323236386139356562616566653533303531363434303564663232636534313139613461333534396262663163646133643463373636313663363936343631373436353634356636323739353831633464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531346136393664363136373635356636383631373336383538323062636435386330646365656139376237313762636265306564633430623265363566633233323961346462396365333731366234376239306562353136376465353337333734363136653634363137323634356636393664363136373635356636383631373336383538323062336430366238363034616363393137323965346431306666356634326461343133376362623662393433323931663730336562393737363136373363393830346237333736363735663736363537323733363936663665343633313265333133353265333034633631363737323635363536343566373436353732366437333430353436643639363737323631373436353566373336393637356637323635373137353639373236353634303034343665373336363737303034353734373236393631366330303439373036363730356636313733373336353734353832336537343836326130396431376139636230333137346136626435666133303562383638343437356334633336303231353931633630366530343435303330333633383331333634383632363735663631373337333635373435383263396264663433376236383331643436643932643064623830663139663162373032313435653966646363343363363236346637613034646330303162633238303534363836353230343637323635363532303466366536356666222c22636f6e7374727563746f72223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c226669656c6473223a7b2263626f72223a22396661613434366536313664363534613234373036383631373236643635373237333332343536393664363136373635353833383639373036363733336132663266376136343661333735373664366635613336353637393335363433333462333637353731343235333532356135303532376135333635363235363738363234633332366533313537343135313465343135383333366634633631353736353539373434393664363536343639363135343739373036353461363936643631363736353266366137303635363734323666363730303439366636373566366537353664363236353732303034363732363137323639373437393435363236313733363936333436366336353665363737343638303934613633363836313732363136333734363537323733346636633635373437343635373237333263366537353664363236353732373335313665373536643635373236393633356636643666363436393636363936353732373334303437373636353732373336393666366530313031623334383632363735663639366436313637363535383335363937303636373333613266326635313664353933363538363937313432373233393461346536653735363737353534353237333738333336663633373636623531363536643465346133353639343335323464363936353338333537373731376133393334346136663439373036363730356636393664363136373635353833353639373036363733336132663266353136643537363736613538343337383536353535333537353037393331353736643535353633333661366635303530333137333561346437363561333733313733366633363731373933363433333235613735366235323432343434363730366637323734363136633430343836343635373336393637366536353732353833383639373036363733336132663266376136323332373236383662333237383435333135343735353735373738373434383534376136663335363737343434363934353738343133363534373237363533346236393539366536313736373034353532333334633636343436623666346234373733366636333639363136633733343034363736363536653634366637323430343736343635363636313735366337343030346537333734363136653634363137323634356636393664363136373635353833383639373036363733336132663266376136323332373236383639366234333536373435333561376134623735363933353333366237363537346333383739373435363433373436333761363734353732333934323463366134363632353834323334353435383535373836383438373935333663363137333734356637353730363436313734363535663631363436343732363537333733353833393031653830666433303330626662313766323562666565353064326537316339656365363832393239313536393866393535656136363435656132623762653031323236386139356562616566653533303531363434303564663232636534313139613461333534396262663163646133643463373636313663363936343631373436353634356636323739353831633464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531346136393664363136373635356636383631373336383538323062636435386330646365656139376237313762636265306564633430623265363566633233323961346462396365333731366234376239306562353136376465353337333734363136653634363137323634356636393664363136373635356636383631373336383538323062336430366238363034616363393137323965346431306666356634326461343133376362623662393433323931663730336562393737363136373363393830346237333736363735663736363537323733363936663665343633313265333133353265333034633631363737323635363536343566373436353732366437333430353436643639363737323631373436353566373336393637356637323635373137353639373236353634303034343665373336363737303034353734373236393631366330303439373036363730356636313733373336353734353832336537343836326130396431376139636230333137346136626435666133303562383638343437356334633336303231353931633630366530343435303330333633383331333634383632363735663631373337333635373435383263396264663433376236383331643436643932643064623830663139663162373032313435653966646363343363363236346637613034646330303162633238303534363836353230343637323635363532303466366536356666222c226974656d73223a5b7b2263626f72223a226161343436653631366436353461323437303638363137323664363537323733333234353639366436313637363535383338363937303636373333613266326637613634366133373537366436663561333635363739333536343333346233363735373134323533353235613530353237613533363536323536373836323463333236653331353734313531346534313538333336663463363135373635353937343439366436353634363936313534373937303635346136393664363136373635326636613730363536373432366636373030343936663637356636653735366436323635373230303436373236313732363937343739343536323631373336393633343636633635366536373734363830393461363336383631373236313633373436353732373334663663363537343734363537323733326336653735366436323635373237333531366537353664363537323639363335663664366636343639363636393635373237333430343737363635373237333639366636653031222c2264617461223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22427566666572222c2276616c7565223a223665363136643635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223234373036383631373236643635373237333332227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363436613337353736643666356133363536373933353634333334623336373537313432353335323561353035323761353336353632353637383632346333323665333135373431353134653431353833333666346336313537363535393734227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366436353634363936313534373937303635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223639366436313637363532663661373036353637227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236663637227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366636373566366537353664363236353732227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373236313732363937343739227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236323631373336393633227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366336353665363737343638227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2239227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223633363836313732363136333734363537323733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22366336353734373436353732373332633665373536643632363537323733227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236653735366436353732363936333566366436663634363936363639363537323733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223736363537323733363936663665227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d7d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d2c7b2263626f72223a2262333438363236373566363936643631363736353538333536393730363637333361326632663531366435393336353836393731343237323339346134653665373536373735353435323733373833333666363337363662353136353664346534613335363934333532346436393635333833353737373137613339333434613666343937303636373035663639366436313637363535383335363937303636373333613266326635313664353736373661353834333738353635353533353735303739333135373664353535363333366136663530353033313733356134643736356133373331373336663336373137393336343333323561373536623532343234343436373036663732373436313663343034383634363537333639363736653635373235383338363937303636373333613266326637613632333237323638366233323738343533313534373535373537373837343438353437613666333536373734343436393435373834313336353437323736353334623639353936653631373637303435353233333463363634343662366634623437373336663633363936313663373334303436373636353665363436663732343034373634363536363631373536633734303034653733373436313665363436313732363435663639366436313637363535383338363937303636373333613266326637613632333237323638363936623433353637343533356137613462373536393335333336623736353734633338373937343536343337343633376136373435373233393432346336613436363235383432333435343538353537383638343837393533366336313733373435663735373036343631373436353566363136343634373236353733373335383339303165383066643330333062666231376632356266656535306432653731633965636536383239323931353639386639353565613636343565613262376265303132323638613935656261656665353330353136343430356466323263653431313961346133353439626266316364613364346337363631366336393634363137343635363435663632373935383163346461393635613034396466643135656431656531396662613665323937346130623739666334313664643137393661316639376635653134613639366436313637363535663638363137333638353832306263643538633064636565613937623731376263626530656463343062326536356663323332396134646239636533373136623437623930656235313637646535333733373436313665363436313732363435663639366436313637363535663638363137333638353832306233643036623836303461636339313732396534643130666635663432646134313337636262366239343332393166373033656239373736313637336339383034623733373636373566373636353732373336393666366534363331326533313335326533303463363136373732363536353634356637343635373236643733343035343664363936373732363137343635356637333639363735663732363537313735363937323635363430303434366537333636373730303435373437323639363136633030343937303636373035663631373337333635373435383233653734383632613039643137613963623033313734613662643566613330356238363834343735633463333630323135393163363036653034343530333033363338333133363438363236373566363137333733363537343538326339626466343337623638333164343664393264306462383066313966316237303231343565396664636334336336323634663761303464633030316263323830353436383635323034363732363536353230346636653635222c2264617461223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236323637356636393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663531366435393336353836393731343237323339346134653665373536373735353435323733373833333666363337363662353136353664346534613335363934333532346436393635333833353737373137613339333434613666227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373036363730356636393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663531366435373637366135383433373835363535353335373530373933313537366435353536333336613666353035303331373335613464373635613337333137333666333637313739333634333332356137353662353234323434227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373036663732373436313663227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236343635373336393637366536353732227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363233323732363836623332373834353331353437353537353737383734343835343761366633353637373434343639343537383431333635343732373635333462363935393665363137363730343535323333346336363434366236663462227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223733366636333639363136633733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373636353665363436663732227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223634363536363631373536633734227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237333734363136653634363137323634356636393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363233323732363836393662343335363734353335613761346237353639333533333662373635373463333837393734353634333734363337613637343537323339343234633661343636323538343233343534353835353738363834383739227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223663363137333734356637353730363436313734363535663631363436343732363537333733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22303165383066643330333062666231376632356266656535306432653731633965636536383239323931353639386639353565613636343565613262376265303132323638613935656261656665353330353136343430356466323263653431313961346133353439626266316364613364227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373636313663363936343631373436353634356636323739227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223639366436313637363535663638363137333638227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2262636435386330646365656139376237313762636265306564633430623265363566633233323961346462396365333731366234376239306562353136376465227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223733373436313665363436313732363435663639366436313637363535663638363137333638227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2262336430366238363034616363393137323965346431306666356634326461343133376362623662393433323931663730336562393737363136373363393830227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237333736363735663736363537323733363936663665227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22333132653331333532653330227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22363136373732363536353634356637343635373236643733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236643639363737323631373436353566373336393637356637323635373137353639373236353634227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223665373336363737227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237343732363936313663227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373036363730356636313733373336353734227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2265373438363261303964313761396362303331373461366264356661333035623836383434373563346333363032313539316336303665303434353033303336333833313336227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236323637356636313733373336353734227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2239626466343337623638333164343664393264306462383066313966316237303231343565396664636334336336323634663761303464633030316263323830353436383635323034363732363536353230346636653635227d5d5d7d7d5d7d7d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303036343362303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303064653134303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613638363136653634366336353331222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223130303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c7370396a6e32346e6366736172616863726734746b6e74396775703775663775616b3275397972326532346471717a70717764222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2237353930303439373137227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a31373437397d2c227769746864726177616c73223a5b7b227175616e74697479223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231373136313337227d2c227374616b6541646472657373223a227374616b655f7465737431757263716a65663432657579637733376d75703532346d66346a3577716c77796c77776d39777a6a70347634326b736a6773676379227d2c7b227175616e74697479223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2237353933353830373435227d2c227374616b6541646472657373223a227374616b655f7465737431757263346d767a6c326370346765646c337971327078373635396b726d7a757a676e6c3264706a6a677379646d71717867616d6a37227d5d7d2c226964223a2262316631303561376533343863616566633235336539613339323538393634643433613462393161323639616233303664306461343434316436363032366339222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2233363863663661313161633765323939313735363861333636616636326135393663623963646538313734626665376636653838333933656364623164636336222c226665633161363364353764363137623264393239613234616239643263343762626163653363303961633463373430653339663032666361393136643364383665316434323664663335666365363062666339373661343761666235316434636333363732656432393439663531666331363961386330626465623937623065225d2c5b2238373563316539386262626265396337376264646364373063613464373261633964303734303837346561643161663932393036323936353533663866333433222c223662653535633562656630353066623136663730393934643163323461303939336437326564366566373437643265346236393239376436313966346164373538306661663132666162356139643363386562353839643936333964613736643330373433396163613031356432396637343538336230666232383563613032225d2c5b2238363439393462663364643637393466646635366233623264343034363130313038396436643038393164346130616132343333316566383662306162386261222c223733626461656335663563316166336235326337353466313062656439363130346638653837383562626236383839353833663332306261326134373063653736643662386165316562653165396662323531366634386261623038613166663635626664313436396538333537663433393766613431323135646437313064225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22323437313635227d2c22686561646572223a7b22626c6f636b4e6f223a313631392c2268617368223a2262363038656563623137376561666262663965623139326533383765616534323465633362363865343864633637336164653030386661313062646434306538222c22736c6f74223a31363036397d2c22697373756572566b223a2230663631396661656663323734653939316233316166666564363830353666333737316264666162623165653132303032366431366233313939633639623738222c2270726576696f7573426c6f636b223a2266313236656431343461656432356364383563323932616564333239393332386362613563653766613964656536656663376136323164616661386533643262222c2273697a65223a313938342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2237363030303439373137227d2c227478436f756e74223a312c22767266223a227672665f766b31726b72666c6e6b726a387879386a32777171706b6e7361666734677a7570723268723464757a34636672747878376b633367377367703973656e227d
1620	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313632302c2268617368223a2234306263306163306166623239353335656665633365313934313131316635613138656333373739396364303539386236326230313032613635303939373036222c22736c6f74223a31363037347d2c22697373756572566b223a2263613965326431616135643936313037346130653665346635373565306535616235613432323466366262393964363266313437636131343132396538356139222c2270726576696f7573426c6f636b223a2262363038656563623137376561666262663965623139326533383765616534323465633362363865343864633637336164653030386661313062646434306538222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31787836306866766c6a7367386d75346c7468397266666a71686b79673078726d6a7868663534786e786d306d7461326e74347871337870386b39227d
1621	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313632312c2268617368223a2262666535366365313533636337353364616439343635336236333831663662643163326435356566323034323966353735626234303366643764613434326237222c22736c6f74223a31363037387d2c22697373756572566b223a2266623935643035363033336561343763613535356238363962623633333562393434623134303734396337613166373933376239656263346238356234356564222c2270726576696f7573426c6f636b223a2234306263306163306166623239353335656665633365313934313131316635613138656333373739396364303539386236326230313032613635303939373036222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c386a786a6b65367a30336d686b6333737533636d353339746a3635756b676b346a727679766a33703968396675673936676b71356c32333763227d
1622	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313632322c2268617368223a2263363731396330343331303564643832666532363564346339323534373563333765336631643066613437363363653063613330336639383936316263656262222c22736c6f74223a31363039347d2c22697373756572566b223a2263613965326431616135643936313037346130653665346635373565306535616235613432323466366262393964363266313437636131343132396538356139222c2270726576696f7573426c6f636b223a2262666535366365313533636337353364616439343635336236333831663662643163326435356566323034323966353735626234303366643764613434326237222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31787836306866766c6a7367386d75346c7468397266666a71686b79673078726d6a7868663534786e786d306d7461326e74347871337870386b39227d
1623	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313632332c2268617368223a2231643736653661316563396562656365366636616235343964616232363133363836386138323263343233643434383261646362336166316330636537383038222c22736c6f74223a31363130307d2c22697373756572566b223a2263313737386237366165393532613764346133633731633030313239316264353731616662666263343530613235666433396133303065643537313530633237222c2270726576696f7573426c6f636b223a2263363731396330343331303564643832666532363564346339323534373563333765336631643066613437363363653063613330336639383936316263656262222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3176766173677065386d6463376a63673378336a7a7464787a6565796b376573636176737678667364726a6b38716e6a327365797365726770776e227d
1624	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313632342c2268617368223a2230626233373833373439386139306638306539373063643832323636323934333463666239333231336634646661323932366338366238636234393762346636222c22736c6f74223a31363132347d2c22697373756572566b223a2239656137393939666566643831636536383932616632336363366434646466316139613933356562356331313539376366383535316633336232306535376133222c2270726576696f7573426c6f636b223a2231643736653661316563396562656365366636616235343964616232363133363836386138323263343233643434383261646362336166316330636537383038222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316878686b74707236753963727575376434726b726c3463733764396835706d7035663565346465766c706d336e6e6367357a7a736e766b303661227d
1625	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313632352c2268617368223a2230353432313666343530396530653864663536343934666637363139303839383031326136386561373336633834326236656539623536316536363862386663222c22736c6f74223a31363132367d2c22697373756572566b223a2230663631396661656663323734653939316233316166666564363830353666333737316264666162623165653132303032366431366233313939633639623738222c2270726576696f7573426c6f636b223a2230626233373833373439386139306638306539373063643832323636323934333463666239333231336634646661323932366338366238636234393762346636222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31726b72666c6e6b726a387879386a32777171706b6e7361666734677a7570723268723464757a34636672747878376b633367377367703973656e227d
1626	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313632362c2268617368223a2235396439373166353330343764623237373962633330366165613532313739376331643265326339396461363338326235396365393638613531666232623261222c22736c6f74223a31363133317d2c22697373756572566b223a2233393461633535323838373266623261643364393830336539336237343235613639323835306362333736313539333130333637643734323463326566633835222c2270726576696f7573426c6f636b223a2230353432313666343530396530653864663536343934666637363139303839383031326136386561373336633834326236656539623536316536363862386663222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3168753066753534746a647535666d6a76396c3537796739337076397667666a7a72387238737a7035676b686b7578777064376a71637475347373227d
1627	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313632372c2268617368223a2230393666383431623636303837363734393731613662633064613532373332323132343833636361653563376238363230393661636231386635356433363938222c22736c6f74223a31363133387d2c22697373756572566b223a2263613965326431616135643936313037346130653665346635373565306535616235613432323466366262393964363266313437636131343132396538356139222c2270726576696f7573426c6f636b223a2235396439373166353330343764623237373962633330366165613532313739376331643265326339396461363338326235396365393638613531666232623261222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31787836306866766c6a7367386d75346c7468397266666a71686b79673078726d6a7868663534786e786d306d7461326e74347871337870386b39227d
1628	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313632382c2268617368223a2239373863623734316366366234343235343532366131386435653734383536653439303732373530383730353863353233306662323135333638636631333435222c22736c6f74223a31363134367d2c22697373756572566b223a2233393461633535323838373266623261643364393830336539336237343235613639323835306362333736313539333130333637643734323463326566633835222c2270726576696f7573426c6f636b223a2230393666383431623636303837363734393731613662633064613532373332323132343833636361653563376238363230393661636231386635356433363938222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3168753066753534746a647535666d6a76396c3537796739337076397667666a7a72387238737a7035676b686b7578777064376a71637475347373227d
1629	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d2c226f776e657273223a5b227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973225d2c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22353030303030303030303030303030227d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e31222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c227265776172644163636f756e74223a227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973222c22767266223a2232656535613463343233323234626239633432313037666331386136303535366436613833636563316439646433376137316635366166373139386663373539227d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22696e70757473223a5b7b22696e646578223a322c2274784964223a2238363930383633323036643538356530383738316335303532393534333233346464363663333336636436643732383831393763383334666463343538306165227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936383230313131227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a31373537387d7d2c226964223a2263623433306430366465393938363662343132666264313764383433333065646662356139336633636231613766333163623233356261366162656231306366222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c226466373133363066613535633162646637643365656638643761353636333436383865383837323661396264623635336431633834633064303061373232646234383365323262366565666339346432383062623032343438373265396566383332396262666430643539306162353235303637646132383236656637383031225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c223435366234363134353763636163393166636430643934626535626636396638353365643630313161343437623764613435346430336139303564636664383264653066346537303030643363373636616461396139376165356337373737386232623264326265623532633031646564666161383736333061333134353035225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22686561646572223a7b22626c6f636b4e6f223a313632392c2268617368223a2237376332303131643562663831346661663736333565613565383862363565303330356132353262646338363237663963653035373435396532616262363565222c22736c6f74223a31363136357d2c22697373756572566b223a2233393461633535323838373266623261643364393830336539336237343235613639323835306362333736313539333130333637643734323463326566633835222c2270726576696f7573426c6f636b223a2239373863623734316366366234343235343532366131386435653734383536653439303732373530383730353863353233306662323135333638636631333435222c2273697a65223a3535342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383230313131227d2c227478436f756e74223a312c22767266223a227672665f766b3168753066753534746a647535666d6a76396c3537796739337076397667666a7a72387238737a7035676b686b7578777064376a71637475347373227d
1630	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313633302c2268617368223a2262376632303038636466396465376530653830393861623034393735623932653431313364616238313465366537363237343535393731323437646330303765222c22736c6f74223a31363137367d2c22697373756572566b223a2239656137393939666566643831636536383932616632336363366434646466316139613933356562356331313539376366383535316633336232306535376133222c2270726576696f7573426c6f636b223a2237376332303131643562663831346661663736333565613565383862363565303330356132353262646338363237663963653035373435396532616262363565222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316878686b74707236753963727575376434726b726c3463733764396835706d7035663565346465766c706d336e6e6367357a7a736e766b303661227d
1631	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313633312c2268617368223a2235636261663864666432636339396632386130396465373130646638636566663638376635383035333134656636336162636637666262366166343264623038222c22736c6f74223a31363231337d2c22697373756572566b223a2236383530633134633362333933326365313433393861326137376339386630623532653039616534666266343763393835653334366133376531363736636665222c2270726576696f7573426c6f636b223a2262376632303038636466396465376530653830393861623034393735623932653431313364616238313465366537363237343535393731323437646330303765222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3134376d773874796732796a643267766d676d677a65617130347175386a74636168763273333535393376637936366a656d753673666668346b6b227d
1632	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313633322c2268617368223a2238323439613434336435656462613237316335663335663636306434656636663231353166653237343435366639626465623537653966363036653961646661222c22736c6f74223a31363233397d2c22697373756572566b223a2236383530633134633362333933326365313433393861326137376339386630623532653039616534666266343763393835653334366133376531363736636665222c2270726576696f7573426c6f636b223a2235636261663864666432636339396632386130396465373130646638636566663638376635383035333134656636336162636637666262366166343264623038222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3134376d773874796732796a643267766d676d677a65617130347175386a74636168763273333535393376637936366a656d753673666668346b6b227d
1633	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b65526567697374726174696f6e4365727469666963617465222c227374616b6543726564656e7469616c223a7b2268617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313639393839227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2263623433306430366465393938363662343132666264313764383433333065646662356139336633636231613766333163623233356261366162656231306366227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393933363530313232227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a31373637397d7d2c226964223a2238363836633232323237373364646532316663373037333639643733636337363839323637393933396137636362613530653664646130623865313537646236222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c226466386239303364646633306666353265353837613837383333336139613934616265326238643135623939346536373837666233333534336333373437393637383431643838656164356637643963633862316631383834663737336538373561393935333039333863653661383965393561373961666564643733303063225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313639393839227d2c22686561646572223a7b22626c6f636b4e6f223a313633332c2268617368223a2233336438363466343336343334636633336339356238666431643533376264343539356534393532373535323635393638303934386130323337393632336431222c22736c6f74223a31363234337d2c22697373756572566b223a2234306530383361373137353133646162333263333761396162376337336665396430353039336437643036383462306435636534643134356566326136613833222c2270726576696f7573426c6f636b223a2238323439613434336435656462613237316335663335663636306434656636663231353166653237343435366639626465623537653966363036653961646661222c2273697a65223a3332392c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936363530313232227d2c227478436f756e74223a312c22767266223a227672665f766b317139716e377376733970386b39707a68656861306e723536346a7337663374767361386d6a77667471706a30366d3233756c6a7374757a307278227d
1634	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313633342c2268617368223a2264303462653663323835393461646437323534633737376431386665313930663632643931396465316638366562613566343737346333306663643436633333222c22736c6f74223a31363234397d2c22697373756572566b223a2234306530383361373137353133646162333263333761396162376337336665396430353039336437643036383462306435636534643134356566326136613833222c2270726576696f7573426c6f636b223a2233336438363466343336343334636633336339356238666431643533376264343539356534393532373535323635393638303934386130323337393632336431222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317139716e377376733970386b39707a68656861306e723536346a7337663374767361386d6a77667471706a30366d3233756c6a7374757a307278227d
1635	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313633352c2268617368223a2264363166623731386531306336346530663162363032623734643066396661613837633265656638366135363839643633376430343035386662633135636662222c22736c6f74223a31363235337d2c22697373756572566b223a2239366238333838376535623961303738303661363333656264643236356335643433616566363462373730356137313330333134333733646266646563613563222c2270726576696f7573426c6f636b223a2264303462653663323835393461646437323534633737376431386665313930663632643931396465316638366562613566343737346333306663643436633333222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313670657a6c677773367079356e76616c336668776c677a7a61756e3761636e6870387367677063756b74767066716c3261343371346c6b37336b227d
1636	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313633362c2268617368223a2230653031623532643331643361353463333439353838303261376231396666313938353261613663643632313337373362623637316132623662336438376633222c22736c6f74223a31363235357d2c22697373756572566b223a2236383530633134633362333933326365313433393861326137376339386630623532653039616534666266343763393835653334366133376531363736636665222c2270726576696f7573426c6f636b223a2264363166623731386531306336346530663162363032623734643066396661613837633265656638366135363839643633376430343035386662633135636662222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3134376d773874796732796a643267766d676d677a65617130347175386a74636168763273333535393376637936366a656d753673666668346b6b227d
1637	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c227374616b6543726564656e7469616c223a7b2268617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313737333337227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2238363836633232323237373364646532316663373037333639643733636337363839323637393933396137636362613530653664646130623865313537646236227d2c7b22696e646578223a312c2274784964223a2238363836633232323237373364646532316663373037333639643733636337363839323637393933396137636362613530653664646130623865313537646236227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393933343732373835227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a31373639357d7d2c226964223a2266626230623766316362666466613137643334303964376466333032646136326234623930383036633935616235306431333733343936333234633539663831222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c226538666332616634353664386166353165353335333631373433373338333165356537623363643430666438303733656438363833313166626338353839353233366432383464316436633861346137393537386465383939373262636633346530363235643038646533306266386661393630363762636535613233323066225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c226361353636633861373861373933383662336162643732363431303933373730343137346539326631303362373062363436626537373162646462343739383537383932633737663538643734353336393630393839373061383439653362373932386136636563353736373130336533393932366566393662396366383063225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313737333337227d2c22686561646572223a7b22626c6f636b4e6f223a313633372c2268617368223a2237323839666561613238306430303337633538386438393432613562386365343333626135313531643765663934326531303630656566613134643036623433222c22736c6f74223a31363239397d2c22697373756572566b223a2236383530633134633362333933326365313433393861326137376339386630623532653039616534666266343763393835653334366133376531363736636665222c2270726576696f7573426c6f636b223a2230653031623532643331643361353463333439353838303261376231396666313938353261613663643632313337373362623637316132623662336438376633222c2273697a65223a3439362c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936343732373835227d2c227478436f756e74223a312c22767266223a227672665f766b3134376d773874796732796a643267766d676d677a65617130347175386a74636168763273333535393376637936366a656d753673666668346b6b227d
1638	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313633382c2268617368223a2263633262656364353565383335386631356436616564306536663431383764646366653239323866623434333134396566313633323261326461336162613734222c22736c6f74223a31363330327d2c22697373756572566b223a2234306530383361373137353133646162333263333761396162376337336665396430353039336437643036383462306435636534643134356566326136613833222c2270726576696f7573426c6f636b223a2237323839666561613238306430303337633538386438393432613562386365343333626135313531643765663934326531303630656566613134643036623433222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317139716e377376733970386b39707a68656861306e723536346a7337663374767361386d6a77667471706a30366d3233756c6a7374757a307278227d
1639	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313633392c2268617368223a2230363064313161373763666235643437313637333939316262333737343932616630333363346666316231386464643561643766363662363936303033313736222c22736c6f74223a31363331377d2c22697373756572566b223a2234306530383361373137353133646162333263333761396162376337336665396430353039336437643036383462306435636534643134356566326136613833222c2270726576696f7573426c6f636b223a2263633262656364353565383335386631356436616564306536663431383764646366653239323866623434333134396566313633323261326461336162613734222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317139716e377376733970386b39707a68656861306e723536346a7337663374767361386d6a77667471706a30366d3233756c6a7374757a307278227d
1640	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313634302c2268617368223a2239346262376539376332376263373861346539356264353637346433356163616464306562366464336663366134623964353038663234306130633763333962222c22736c6f74223a31363332387d2c22697373756572566b223a2263313737386237366165393532613764346133633731633030313239316264353731616662666263343530613235666433396133303065643537313530633237222c2270726576696f7573426c6f636b223a2230363064313161373763666235643437313637333939316262333737343932616630333363346666316231386464643561643766363662363936303033313736222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3176766173677065386d6463376a63673378336a7a7464787a6565796b376573636176737678667364726a6b38716e6a327365797365726770776e227d
1641	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d2c226f776e657273223a5b227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576225d2c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223530303030303030227d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e32222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c227265776172644163636f756e74223a227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576222c22767266223a2236343164303432656433396332633235386433383130363063313432346634306566386162666532356566353636663463623232343737633432623261303134227d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313832373035227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2263393662623030373537636561626262303739633361363935616266363131306165353030356637666637633862393161393361383335663231613435303636227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961343436663735363236633635343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2232227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396134383635366336633666343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613534363537333734343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383137323935227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a31373736387d7d2c226964223a2262653731336136386163306564363730323834616137303336333135316236613962653434336532386334636138666439316439373266306439653830396566222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c226238383937643262326236336431363636303332386538333339643161316632373661316435376465323262383938306330326533663163353134303532383836343932373066623430333638323632373433333832303039353033353432633964303539363036363031636239333466653934643262643163656331393036225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223435346466313537393431393033303934653431373435396661616237616334666364343065663162373433393434343766616634316231366232636335373432336132623133306166373432336665623361333938393334333664336632643461376533326539343566343630643962616363393330303237313335363038225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313832373035227d2c22686561646572223a7b22626c6f636b4e6f223a313634312c2268617368223a2261356638366161376264333165353464373331646464663334343732313339646433353834636534616533376463653530363536333965643266363966333532222c22736c6f74223a31363333327d2c22697373756572566b223a2239366238333838376535623961303738303661363333656264643236356335643433616566363462373730356137313330333134333733646266646563613563222c2270726576696f7573426c6f636b223a2239346262376539376332376263373861346539356264353637346433356163616464306562366464336663366134623964353038663234306130633763333962222c2273697a65223a3631382c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383137323935227d2c227478436f756e74223a312c22767266223a227672665f766b313670657a6c677773367079356e76616c336668776c677a7a61756e3761636e6870387367677063756b74767066716c3261343371346c6b37336b227d
1642	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313634322c2268617368223a2233353238373536383162383136633161663532386634356566306566626532666166353734643563366139383164616333626166623562623038396230373539222c22736c6f74223a31363334327d2c22697373756572566b223a2234306530383361373137353133646162333263333761396162376337336665396430353039336437643036383462306435636534643134356566326136613833222c2270726576696f7573426c6f636b223a2261356638366161376264333165353464373331646464663334343732313339646433353834636534616533376463653530363536333965643266363966333532222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317139716e377376733970386b39707a68656861306e723536346a7337663374767361386d6a77667471706a30366d3233756c6a7374757a307278227d
1643	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313634332c2268617368223a2234626463353939616365343364613537373339396161393832363630333635393466623230623136653931613533356137656638343835366464653661393431222c22736c6f74223a31363334347d2c22697373756572566b223a2239656137393939666566643831636536383932616632336363366434646466316139613933356562356331313539376366383535316633336232306535376133222c2270726576696f7573426c6f636b223a2233353238373536383162383136633161663532386634356566306566626532666166353734643563366139383164616333626166623562623038396230373539222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316878686b74707236753963727575376434726b726c3463733764396835706d7035663565346465766c706d336e6e6367357a7a736e766b303661227d
1644	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313634342c2268617368223a2239323432353765303132343663336364353566653532613465646363616439366662346537643664376531393964323366613531383732393839623665626337222c22736c6f74223a31363337317d2c22697373756572566b223a2263313737386237366165393532613764346133633731633030313239316264353731616662666263343530613235666433396133303065643537313530633237222c2270726576696f7573426c6f636b223a2234626463353939616365343364613537373339396161393832363630333635393466623230623136653931613533356137656638343835366464653661393431222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3176766173677065386d6463376a63673378336a7a7464787a6565796b376573636176737678667364726a6b38716e6a327365797365726770776e227d
1645	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b65526567697374726174696f6e4365727469666963617465222c227374616b6543726564656e7469616c223a7b2268617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731393235227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2238663164613834393936383466303665333062306362313136366337303864656539326166393339656262626166306566366161623065383966656237366636227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613238333233323332323936383631366536343663363533363338222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383238303735227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a31373831317d7d2c226964223a2266653238396364623839356164396139653938333934336366386539653866373734303364323831326436366433316164343463373763333662623162366339222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223036356639333735313136316662323830613731323730336239646633633937356563313734613735346461636331383136323633663965356636643135363431303763376635663232623465376232646532363130666133323234613261306531643162333339653964313761633262646133316537353435326465633037225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731393235227d2c22686561646572223a7b22626c6f636b4e6f223a313634352c2268617368223a2231396433336238336336346662366166393931623566323062626632323761633630396661346337643064636437633832613661363334383739313964353765222c22736c6f74223a31363338357d2c22697373756572566b223a2239366238333838376535623961303738303661363333656264643236356335643433616566363462373730356137313330333134333733646266646563613563222c2270726576696f7573426c6f636b223a2239323432353765303132343663336364353566653532613465646363616439366662346537643664376531393964323366613531383732393839623665626337222c2273697a65223a3337332c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383238303735227d2c227478436f756e74223a312c22767266223a227672665f766b313670657a6c677773367079356e76616c336668776c677a7a61756e3761636e6870387367677063756b74767066716c3261343371346c6b37336b227d
1646	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313634362c2268617368223a2231353134646130386265653630393361363663303032326463633832613536663661366439396235303262663035616137663830643432326133376534643630222c22736c6f74223a31363339387d2c22697373756572566b223a2239656137393939666566643831636536383932616632336363366434646466316139613933356562356331313539376366383535316633336232306535376133222c2270726576696f7573426c6f636b223a2231396433336238336336346662366166393931623566323062626632323761633630396661346337643064636437633832613661363334383739313964353765222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316878686b74707236753963727575376434726b726c3463733764396835706d7035663565346465766c706d336e6e6367357a7a736e766b303661227d
1647	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313634372c2268617368223a2266363361373038323530666261336235326535643133386635666137363861623035643764626364326333363234623535303036656665323731386537666463222c22736c6f74223a31363430347d2c22697373756572566b223a2234306530383361373137353133646162333263333761396162376337336665396430353039336437643036383462306435636534643134356566326136613833222c2270726576696f7573426c6f636b223a2231353134646130386265653630393361363663303032326463633832613536663661366439396235303262663035616137663830643432326133376534643630222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317139716e377376733970386b39707a68656861306e723536346a7337663374767361386d6a77667471706a30366d3233756c6a7374757a307278227d
1648	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313634382c2268617368223a2265653165653964643662396234643535343935616339373730666163643337326135633063356532313236653831616435623039393432323563306363663331222c22736c6f74223a31363431307d2c22697373756572566b223a2233393461633535323838373266623261643364393830336539336237343235613639323835306362333736313539333130333637643734323463326566633835222c2270726576696f7573426c6f636b223a2266363361373038323530666261336235326535643133386635666137363861623035643764626364326333363234623535303036656665323731386537666463222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3168753066753534746a647535666d6a76396c3537796739337076397667666a7a72387238737a7035676b686b7578777064376a71637475347373227d
1649	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c227374616b6543726564656e7469616c223a7b2268617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313735373533227d2c22696e70757473223a5b7b22696e646578223a342c2274784964223a2238363930383633323036643538356530383738316335303532393534333233346464363663333336636436643732383831393763383334666463343538306165227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936383234323437227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a31373835307d7d2c226964223a2263643938366135386465643430336662323736393832643261633631323964343733613933623634616636616461633032303430393133333930316434616661222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c226636373365666265313534376362386565623562613530333038313063653062343730393837336262373434303161373531616638306264366233613834363133633937323037303738643539326330353930373236616436636636353533336336396562396138666136656532656536653331303630643134633338663063225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c226634373637663239663939303134633637326432663732633137363135396561356336383638616366356532383865336433366335323264333464313762306166636334373833303339373662326664393663363239643531353161363135636233356531383635323439653961363537636630383436656464396238363062225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313735373533227d2c22686561646572223a7b22626c6f636b4e6f223a313634392c2268617368223a2261356133333737376563323738633432316534313866353137346131353763656365613836303761366361396533643535653239323261346337386165376238222c22736c6f74223a31363432337d2c22697373756572566b223a2230663631396661656663323734653939316233316166666564363830353666333737316264666162623165653132303032366431366233313939633639623738222c2270726576696f7573426c6f636b223a2265653165653964643662396234643535343935616339373730666163643337326135633063356532313236653831616435623039393432323563306363663331222c2273697a65223a3436302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383234323437227d2c227478436f756e74223a312c22767266223a227672665f766b31726b72666c6e6b726a387879386a32777171706b6e7361666734677a7570723268723464757a34636672747878376b633367377367703973656e227d
1650	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313635302c2268617368223a2266316363323662633030333733616366623438316138623936356664663836376362313662363839373433633338663732306461353734356331396364346130222c22736c6f74223a31363434337d2c22697373756572566b223a2230663631396661656663323734653939316233316166666564363830353666333737316264666162623165653132303032366431366233313939633639623738222c2270726576696f7573426c6f636b223a2261356133333737376563323738633432316534313866353137346131353763656365613836303761366361396533643535653239323261346337386165376238222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31726b72666c6e6b726a387879386a32777171706b6e7361666734677a7570723268723464757a34636672747878376b633367377367703973656e227d
1651	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313635312c2268617368223a2235326635643837636563373038656366316532343339393662353138333165626436393939376361623634623334663866316564356437383861626364353233222c22736c6f74223a31363435367d2c22697373756572566b223a2236383530633134633362333933326365313433393861326137376339386630623532653039616534666266343763393835653334366133376531363736636665222c2270726576696f7573426c6f636b223a2266316363323662633030333733616366623438316138623936356664663836376362313662363839373433633338663732306461353734356331396364346130222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3134376d773874796732796a643267766d676d677a65617130347175386a74636168763273333535393376637936366a656d753673666668346b6b227d
1652	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313635322c2268617368223a2265393539373335356534613030623239363433326638663534343131633138643635363436643838323565653935376537623832633862393261353436383433222c22736c6f74223a31363438307d2c22697373756572566b223a2230663631396661656663323734653939316233316166666564363830353666333737316264666162623165653132303032366431366233313939633639623738222c2270726576696f7573426c6f636b223a2235326635643837636563373038656366316532343339393662353138333165626436393939376361623634623334663866316564356437383861626364353233222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31726b72666c6e6b726a387879386a32777171706b6e7361666734677a7570723268723464757a34636672747878376b633367377367703973656e227d
1590	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539302c2268617368223a2261386439383536623362336161303735356438623465613763346638376263323333613466613131653364313138346631633134383133633861663938613936222c22736c6f74223a31353830377d2c22697373756572566b223a2236383530633134633362333933326365313433393861326137376339386630623532653039616534666266343763393835653334366133376531363736636665222c2270726576696f7573426c6f636b223a2264616166393134303362363334356635663161323435366434373333366434666631643034373261323736663137303034623633303533326236393765323863222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3134376d773874796732796a643267766d676d677a65617130347175386a74636168763273333535393376637936366a656d753673666668346b6b227d
1591	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539312c2268617368223a2232343465656266623730336363626132353761303661343534363830643564646239383164323439653862323566313561336461316239373431306166383432222c22736c6f74223a31353830397d2c22697373756572566b223a2263613965326431616135643936313037346130653665346635373565306535616235613432323466366262393964363266313437636131343132396538356139222c2270726576696f7573426c6f636b223a2261386439383536623362336161303735356438623465613763346638376263323333613466613131653364313138346631633134383133633861663938613936222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31787836306866766c6a7367386d75346c7468397266666a71686b79673078726d6a7868663534786e786d306d7461326e74347871337870386b39227d
1592	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539322c2268617368223a2238633464643535376235646462313033643831316465363339333636633465636338353631633663333463656466646330346131333563633733366139393166222c22736c6f74223a31353833327d2c22697373756572566b223a2266623935643035363033336561343763613535356238363962623633333562393434623134303734396337613166373933376239656263346238356234356564222c2270726576696f7573426c6f636b223a2232343465656266623730336363626132353761303661343534363830643564646239383164323439653862323566313561336461316239373431306166383432222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c386a786a6b65367a30336d686b6333737533636d353339746a3635756b676b346a727679766a33703968396675673936676b71356c32333763227d
1593	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539332c2268617368223a2233656239386466313939626364636130663963656636363132346332666262663731633637326431313864323061633031396461666565363931666339393937222c22736c6f74223a31353833367d2c22697373756572566b223a2233393461633535323838373266623261643364393830336539336237343235613639323835306362333736313539333130333637643734323463326566633835222c2270726576696f7573426c6f636b223a2238633464643535376235646462313033643831316465363339333636633465636338353631633663333463656466646330346131333563633733366139393166222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3168753066753534746a647535666d6a76396c3537796739337076397667666a7a72387238737a7035676b686b7578777064376a71637475347373227d
1594	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539342c2268617368223a2264333164326636303661343937613536643364373862646336303563396162326335323365613165303637643162353532363336613063326633343933663363222c22736c6f74223a31353833377d2c22697373756572566b223a2233393461633535323838373266623261643364393830336539336237343235613639323835306362333736313539333130333637643734323463326566633835222c2270726576696f7573426c6f636b223a2233656239386466313939626364636130663963656636363132346332666262663731633637326431313864323061633031396461666565363931666339393937222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3168753066753534746a647535666d6a76396c3537796739337076397667666a7a72387238737a7035676b686b7578777064376a71637475347373227d
1595	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539352c2268617368223a2236656230633038613264626564376136663662613965326430343733643561353961343932363864646563316237666566336230333065643035633837623836222c22736c6f74223a31353835307d2c22697373756572566b223a2233393461633535323838373266623261643364393830336539336237343235613639323835306362333736313539333130333637643734323463326566633835222c2270726576696f7573426c6f636b223a2264333164326636303661343937613536643364373862646336303563396162326335323365613165303637643162353532363336613063326633343933663363222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3168753066753534746a647535666d6a76396c3537796739337076397667666a7a72387238737a7035676b686b7578777064376a71637475347373227d
1596	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539362c2268617368223a2231353463383933343661366633323432356339626561616266316135336466353737303131353564373232363032366465376166386630313361383334653838222c22736c6f74223a31353835367d2c22697373756572566b223a2266623935643035363033336561343763613535356238363962623633333562393434623134303734396337613166373933376239656263346238356234356564222c2270726576696f7573426c6f636b223a2236656230633038613264626564376136663662613965326430343733643561353961343932363864646563316237666566336230333065643035633837623836222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c386a786a6b65367a30336d686b6333737533636d353339746a3635756b676b346a727679766a33703968396675673936676b71356c32333763227d
1597	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539372c2268617368223a2266313363313031353066306538633266616563393863653237326366313065636232313038343465363464366639633235363237366231303162386566393531222c22736c6f74223a31353836307d2c22697373756572566b223a2234306530383361373137353133646162333263333761396162376337336665396430353039336437643036383462306435636534643134356566326136613833222c2270726576696f7573426c6f636b223a2231353463383933343661366633323432356339626561616266316135336466353737303131353564373232363032366465376166386630313361383334653838222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317139716e377376733970386b39707a68656861306e723536346a7337663374767361386d6a77667471706a30366d3233756c6a7374757a307278227d
1598	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539382c2268617368223a2238646637396332393566373336623066336437623831386138633961616161373665346633343263613330366465336138376236623964376664623137663666222c22736c6f74223a31353837327d2c22697373756572566b223a2239656137393939666566643831636536383932616632336363366434646466316139613933356562356331313539376366383535316633336232306535376133222c2270726576696f7573426c6f636b223a2266313363313031353066306538633266616563393863653237326366313065636232313038343465363464366639633235363237366231303162386566393531222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316878686b74707236753963727575376434726b726c3463733764396835706d7035663565346465766c706d336e6e6367357a7a736e766b303661227d
1599	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539392c2268617368223a2266636438616632633135666333653331393131363532343263343633613265333565333338323761316335396437303930643936346430353265366630383537222c22736c6f74223a31353837367d2c22697373756572566b223a2239656137393939666566643831636536383932616632336363366434646466316139613933356562356331313539376366383535316633336232306535376133222c2270726576696f7573426c6f636b223a2238646637396332393566373336623066336437623831386138633961616161373665346633343263613330366465336138376236623964376664623137663666222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316878686b74707236753963727575376434726b726c3463733764396835706d7035663565346465766c706d336e6e6367357a7a736e766b303661227d
1600	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630302c2268617368223a2262306664336466383732396466323364316232323665666632333366333431636330303535343236636538343332346232386330666234346134366264303839222c22736c6f74223a31353839327d2c22697373756572566b223a2233393461633535323838373266623261643364393830336539336237343235613639323835306362333736313539333130333637643734323463326566633835222c2270726576696f7573426c6f636b223a2266636438616632633135666333653331393131363532343263343633613265333565333338323761316335396437303930643936346430353265366630383537222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3168753066753534746a647535666d6a76396c3537796739337076397667666a7a72387238737a7035676b686b7578777064376a71637475347373227d
1601	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630312c2268617368223a2236623835623434656331663031663266303234313938306661333037343762373138383039313563366263333561633330666363323732386237383866353836222c22736c6f74223a31353931357d2c22697373756572566b223a2263313737386237366165393532613764346133633731633030313239316264353731616662666263343530613235666433396133303065643537313530633237222c2270726576696f7573426c6f636b223a2262306664336466383732396466323364316232323665666632333366333431636330303535343236636538343332346232386330666234346134366264303839222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3176766173677065386d6463376a63673378336a7a7464787a6565796b376573636176737678667364726a6b38716e6a327365797365726770776e227d
1602	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630322c2268617368223a2238353966303661323163326636653966363735616264363261366135616436363065336630373364333566326461336335393266336161316363353062343763222c22736c6f74223a31353932337d2c22697373756572566b223a2239366238333838376535623961303738303661363333656264643236356335643433616566363462373730356137313330333134333733646266646563613563222c2270726576696f7573426c6f636b223a2236623835623434656331663031663266303234313938306661333037343762373138383039313563366263333561633330666363323732386237383866353836222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313670657a6c677773367079356e76616c336668776c677a7a61756e3761636e6870387367677063756b74767066716c3261343371346c6b37336b227d
1603	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630332c2268617368223a2264613862653635656635623531356363313862613333623265373038333664653966313935386639313436643339313437323437303965373434323061353662222c22736c6f74223a31353934327d2c22697373756572566b223a2263613965326431616135643936313037346130653665346635373565306535616235613432323466366262393964363266313437636131343132396538356139222c2270726576696f7573426c6f636b223a2238353966303661323163326636653966363735616264363261366135616436363065336630373364333566326461336335393266336161316363353062343763222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31787836306866766c6a7367386d75346c7468397266666a71686b79673078726d6a7868663534786e786d306d7461326e74347871337870386b39227d
1604	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630342c2268617368223a2234663165366366616262666433326365333035313932306532363865633263346262313137643431383732646238313461336463303133653735363136393665222c22736c6f74223a31353934377d2c22697373756572566b223a2233393461633535323838373266623261643364393830336539336237343235613639323835306362333736313539333130333637643734323463326566633835222c2270726576696f7573426c6f636b223a2264613862653635656635623531356363313862613333623265373038333664653966313935386639313436643339313437323437303965373434323061353662222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3168753066753534746a647535666d6a76396c3537796739337076397667666a7a72387238737a7035676b686b7578777064376a71637475347373227d
1605	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630352c2268617368223a2262613531633762366163373962333762613834653263363035653533343461396637386237353332313330663464386433373836336634653335646235303835222c22736c6f74223a31353936347d2c22697373756572566b223a2239656137393939666566643831636536383932616632336363366434646466316139613933356562356331313539376366383535316633336232306535376133222c2270726576696f7573426c6f636b223a2234663165366366616262666433326365333035313932306532363865633263346262313137643431383732646238313461336463303133653735363136393665222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316878686b74707236753963727575376434726b726c3463733764396835706d7035663565346465766c706d336e6e6367357a7a736e766b303661227d
1606	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630362c2268617368223a2263663438643565626332336431613830313833633763346330346262626235653533656630313832333335333862636336613835376331646664343635623365222c22736c6f74223a31353936397d2c22697373756572566b223a2263613965326431616135643936313037346130653665346635373565306535616235613432323466366262393964363266313437636131343132396538356139222c2270726576696f7573426c6f636b223a2262613531633762366163373962333762613834653263363035653533343461396637386237353332313330663464386433373836336634653335646235303835222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31787836306866766c6a7367386d75346c7468397266666a71686b79673078726d6a7868663534786e786d306d7461326e74347871337870386b39227d
1607	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630372c2268617368223a2266303336666236386664336565323261643232383333633066663138306464336133373765333562396337336664363064356136306635353534366139393434222c22736c6f74223a31353937367d2c22697373756572566b223a2234306530383361373137353133646162333263333761396162376337336665396430353039336437643036383462306435636534643134356566326136613833222c2270726576696f7573426c6f636b223a2263663438643565626332336431613830313833633763346330346262626235653533656630313832333335333862636336613835376331646664343635623365222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317139716e377376733970386b39707a68656861306e723536346a7337663374767361386d6a77667471706a30366d3233756c6a7374757a307278227d
1608	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630382c2268617368223a2234643166623161663262303838366139613339663831333666356138626261313264376431343635363865646533356161393732316536363930383237643262222c22736c6f74223a31353937387d2c22697373756572566b223a2239656137393939666566643831636536383932616632336363366434646466316139613933356562356331313539376366383535316633336232306535376133222c2270726576696f7573426c6f636b223a2266303336666236386664336565323261643232383333633066663138306464336133373765333562396337336664363064356136306635353534366139393434222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316878686b74707236753963727575376434726b726c3463733764396835706d7035663565346465766c706d336e6e6367357a7a736e766b303661227d
1609	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630392c2268617368223a2230653434313462346431326334323632366534626337656538326464633066376534373432363734303966333665393936333839653230333334326539333561222c22736c6f74223a31353938377d2c22697373756572566b223a2236383530633134633362333933326365313433393861326137376339386630623532653039616534666266343763393835653334366133376531363736636665222c2270726576696f7573426c6f636b223a2234643166623161663262303838366139613339663831333666356138626261313264376431343635363865646533356161393732316536363930383237643262222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3134376d773874796732796a643267766d676d677a65617130347175386a74636168763273333535393376637936366a656d753673666668346b6b227d
1610	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631302c2268617368223a2265373537613331366535393734353832333636653963396435626333666339373762373061666532326232623031363133613165396263323361356338646136222c22736c6f74223a31353939317d2c22697373756572566b223a2234306530383361373137353133646162333263333761396162376337336665396430353039336437643036383462306435636534643134356566326136613833222c2270726576696f7573426c6f636b223a2230653434313462346431326334323632366534626337656538326464633066376534373432363734303966333665393936333839653230333334326539333561222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317139716e377376733970386b39707a68656861306e723536346a7337663374767361386d6a77667471706a30366d3233756c6a7374757a307278227d
1611	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631312c2268617368223a2238323966383366316630313661333166373331313134623035303466356666366438353637363130643063313366626462356537323032313161356563663434222c22736c6f74223a31353939327d2c22697373756572566b223a2230663631396661656663323734653939316233316166666564363830353666333737316264666162623165653132303032366431366233313939633639623738222c2270726576696f7573426c6f636b223a2265373537613331366535393734353832333636653963396435626333666339373762373061666532326232623031363133613165396263323361356338646136222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31726b72666c6e6b726a387879386a32777171706b6e7361666734677a7570723268723464757a34636672747878376b633367377367703973656e227d
1612	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631322c2268617368223a2264663561343733386539306437366538336535396632646234643135653432396531376437356138356330303261653461386639653739653161383636323534222c22736c6f74223a31363032357d2c22697373756572566b223a2230663631396661656663323734653939316233316166666564363830353666333737316264666162623165653132303032366431366233313939633639623738222c2270726576696f7573426c6f636b223a2238323966383366316630313661333166373331313134623035303466356666366438353637363130643063313366626462356537323032313161356563663434222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31726b72666c6e6b726a387879386a32777171706b6e7361666734677a7570723268723464757a34636672747878376b633367377367703973656e227d
1613	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631332c2268617368223a2232366636646266396266383730343034353535353462316639386131313939623630653339333934373535383037616138613831333961366138353434336263222c22736c6f74223a31363032377d2c22697373756572566b223a2230663631396661656663323734653939316233316166666564363830353666333737316264666162623165653132303032366431366233313939633639623738222c2270726576696f7573426c6f636b223a2264663561343733386539306437366538336535396632646234643135653432396531376437356138356330303261653461386639653739653161383636323534222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31726b72666c6e6b726a387879386a32777171706b6e7361666734677a7570723268723464757a34636672747878376b633367377367703973656e227d
\.


--
-- Data for Name: current_pool_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_pool_metrics (stake_pool_id, slot, minted_blocks, live_delegators, active_stake, live_stake, live_pledge, live_saturation, active_size, live_size, last_ros, ros) FROM stdin;
pool1gk5vxx0qlc4txk7nc7lh2k3my3vmhhndfqzlkll0j7dfczenwf9	9633	89	3	7793937270628370	21209997901098	300000000	0.016686150699286466	367.4652542150838	-366.4652542150838	0	0
pool13jwk36zmyaev3chtsg3yehmcun8aa3gdzfa42aqluf59jv8jk87	9633	98	3	7815728433468628	52445911380164	500000000	0.041259805160354886	149.02455172939713	-148.02455172939713	0	0
pool124acjdvffn06wqfxc2lansvm8xyad8ga4fd2d8jp773jg28pu3g	9633	82	3	7799524396296676	36251618691822	4562539519785	0.02851956777202215	215.14968648989375	-214.14968648989375	0	0
pool14j403ncw3lc7kp5k2adzmskvp6xucaftk9frjsjs4an5ygg2tf4	9633	109	3	7829446343611114	64384999860609	8624920312491	0.05065242417548959	121.60357786070604	-120.60357786070604	0	0
pool1p2r5c3xt03t5achwd7cj7ghwzsl4ejqhhj0gq6errgm85apv3x9	9633	92	3	7786151673941820	13424401214548	200198987	0.010561131724677637	579.9999232370961	-578.9999232370961	0	0
pool1hchl83q80arjn4hcks8egft429dffnpd8405ecuvm45azjje5ae	9633	95	3	7822798734794836	53611114174584	6350893189071	0.04217648367741948	145.91748101559648	-144.91748101559648	0	0
pool1053yndnhk5nd7lp6eqfcwtktztwdfpd9n6xmmzckr5hzuqnq2r5	9633	93	4	7813736395825283	49412443290793	5603470909227	0.038873340724255113	158.13296966193965	-157.13296966193965	0	0
pool14fqrqspdrmz58ehsucqckyqqdu7g5q5vn6phrxga9fnvs7d9l8j	9633	93	3	7817259732545319	50433611408973	6568372344975	0.039676705495374505	155.0009906915866	-154.0009906915866	0	0
pool1g8xc4xh2c7zkej9gwuh6s2nquxrrghvyyf25z62nxha0snlyz7u	9633	105	4	7820632892402169	51892143188662	7297637606351	0.040824149318286394	150.70938319061202	-149.70938319061202	0	0
pool1waqwmsn0srycnlxcz3m3u32lyta5s35zgyqlyu940ece5mt6ylg	9633	67	3	0	15857690499045	300000000	0.012475428552305988	0	1	0	0
pool1qqwnsfw98ycqj5gs24829d065pgmdchfugf9n66czfux5hph4kk	9633	79	3	0	54867479701755	500000000	0.04316488097088072	0	1	0	0
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
1	SP1	stake pool - 1	This is the stake pool 1 description.	https://stakepool1.com	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	\N	pool124acjdvffn06wqfxc2lansvm8xyad8ga4fd2d8jp773jg28pu3g	2500000000000
2	SP4	Same Name	This is the stake pool 4 description.	https://stakepool4.com	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	\N	pool1hchl83q80arjn4hcks8egft429dffnpd8405ecuvm45azjje5ae	4770000000000
3	SP3	Stake Pool - 3	This is the stake pool 3 description.	https://stakepool3.com	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	\N	pool1p2r5c3xt03t5achwd7cj7ghwzsl4ejqhhj0gq6errgm85apv3x9	4050000000000
4	SP11	Stake Pool - 10 + 1	This is the stake pool 11 description.	https://stakepool11.com	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	\N	pool13jwk36zmyaev3chtsg3yehmcun8aa3gdzfa42aqluf59jv8jk87	12470000000000
5	SP5	Same Name	This is the stake pool 5 description.	https://stakepool5.com	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	\N	pool1053yndnhk5nd7lp6eqfcwtktztwdfpd9n6xmmzckr5hzuqnq2r5	5650000000000
6	SP6a7	Stake Pool - 6	This is the stake pool 6 description.	https://stakepool6.com	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	\N	pool14fqrqspdrmz58ehsucqckyqqdu7g5q5vn6phrxga9fnvs7d9l8j	6460000000000
7	SP6a7		This is the stake pool 7 description.	https://stakepool7.com	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	\N	pool1g8xc4xh2c7zkej9gwuh6s2nquxrrghvyyf25z62nxha0snlyz7u	7270000000000
8	SP10	Stake Pool - 10	This is the stake pool 10 description.	https://stakepool10.com	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	\N	pool1qqwnsfw98ycqj5gs24829d065pgmdchfugf9n66czfux5hph4kk	11160000000000
\.


--
-- Data for Name: pool_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_registration (id, reward_account, pledge, cost, margin, margin_percent, relays, owners, vrf, metadata_url, metadata_hash, block_slot, stake_pool_id) FROM stdin;
2500000000000	stake_test1upd37wqk5adaefy4azmp7rckr2mvgv6tt8mhjctn2nxyt6qs8dm9u	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3001, "__typename": "RelayByAddress"}]	["stake_test1upd37wqk5adaefy4azmp7rckr2mvgv6tt8mhjctn2nxyt6qs8dm9u"]	5e4004b6508765060d3052f34a67da48249a4d18b2b927de09b332e059b10e1f	http://file-server/SP1.json	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	250	pool124acjdvffn06wqfxc2lansvm8xyad8ga4fd2d8jp773jg28pu3g
3380000000000	stake_test1uzljg7zmy8aj3dzn6827uwh0hexkjvwz5sesjjsaaf8ehdc9kzcfl	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3002, "__typename": "RelayByAddress"}]	["stake_test1uzljg7zmy8aj3dzn6827uwh0hexkjvwz5sesjjsaaf8ehdc9kzcfl"]	ce514a2236ce3aa9533a967d1daf0aca3be0118dd19f2c334666d693c3cecfda	\N	\N	338	pool14j403ncw3lc7kp5k2adzmskvp6xucaftk9frjsjs4an5ygg2tf4
4050000000000	stake_test1uqe8udeus2eqkth3xaw2raplszr35jysheceap47x62qgeqfn2fef	600000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3003, "__typename": "RelayByAddress"}]	["stake_test1uqe8udeus2eqkth3xaw2raplszr35jysheceap47x62qgeqfn2fef"]	9ee15de02dcde348b171c8bcbd71baed879403d3982e1fd7db550def12295cd4	http://file-server/SP3.json	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	405	pool1p2r5c3xt03t5achwd7cj7ghwzsl4ejqhhj0gq6errgm85apv3x9
4770000000000	stake_test1urq6lrkeszrawlfng5rht6cdsjv5ukktgw6sj8atutynk7gt5jhj5	420000000	370000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3004, "__typename": "RelayByAddress"}]	["stake_test1urq6lrkeszrawlfng5rht6cdsjv5ukktgw6sj8atutynk7gt5jhj5"]	11e8c081f7a9b695121847234d2e36067fcf87091386d7f847689e49056d85ba	http://file-server/SP4.json	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	477	pool1hchl83q80arjn4hcks8egft429dffnpd8405ecuvm45azjje5ae
5650000000000	stake_test1uz46nkw9mafmdhvl3k6h265rraz6qf4srrwxd4yt3ycdz7quxyntz	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3005, "__typename": "RelayByAddress"}]	["stake_test1uz46nkw9mafmdhvl3k6h265rraz6qf4srrwxd4yt3ycdz7quxyntz"]	d0f5d41e2bdd115aa5a94c8a5404ccd5ba69d5d64ed5a5ba29c460624ec333a2	http://file-server/SP5.json	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	565	pool1053yndnhk5nd7lp6eqfcwtktztwdfpd9n6xmmzckr5hzuqnq2r5
6460000000000	stake_test1uqa4prgug4vcqtn3lvhg5mtj2798cunajyx6laz6nherclgatef9f	410000000	400000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3006, "__typename": "RelayByAddress"}]	["stake_test1uqa4prgug4vcqtn3lvhg5mtj2798cunajyx6laz6nherclgatef9f"]	65bee93332c5e758fe3c1626a52885ffe9792678a3ca586e579c4405a1d6f95c	http://file-server/SP6.json	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	646	pool14fqrqspdrmz58ehsucqckyqqdu7g5q5vn6phrxga9fnvs7d9l8j
7270000000000	stake_test1upwhfwtml7zatl0rkq39n7p9gwzam5cjzs5j373alz2cduqqravgp	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3007, "__typename": "RelayByAddress"}]	["stake_test1upwhfwtml7zatl0rkq39n7p9gwzam5cjzs5j373alz2cduqqravgp"]	60c879e0aeeefe07ba095e008dc1d001446fbd0a7b285625eacb30eef110c091	http://file-server/SP7.json	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	727	pool1g8xc4xh2c7zkej9gwuh6s2nquxrrghvyyf25z62nxha0snlyz7u
8230000000000	stake_test1uranep63q9yjcchmd5y76yzaeq466dqyurpyzh7us3f87qg82sct0	500000000	380000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3008, "__typename": "RelayByAddress"}]	["stake_test1uranep63q9yjcchmd5y76yzaeq466dqyurpyzh7us3f87qg82sct0"]	c5904a2bbc02aefbddb829c21a9bae7e1c74e123f30dda955a63e3e22aa4569e	\N	\N	823	pool1waqwmsn0srycnlxcz3m3u32lyta5s35zgyqlyu940ece5mt6ylg
9840000000000	stake_test1uptexktg30nem3u24vz6s2ue0h52a0xghllxrs4fupp0uagezu49d	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3009, "__typename": "RelayByAddress"}]	["stake_test1uptexktg30nem3u24vz6s2ue0h52a0xghllxrs4fupp0uagezu49d"]	8cc62175f7c8f1a972ff99e2e85a10a74b11bf64a354267b039796ced06ea05e	\N	\N	984	pool1gk5vxx0qlc4txk7nc7lh2k3my3vmhhndfqzlkll0j7dfczenwf9
11160000000000	stake_test1uzpvm4rf9m2j7t6kj052a6cfj6m2a4fxvu3v4sdlsxdhy4s0c45s5	400000000	410000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30010, "__typename": "RelayByAddress"}]	["stake_test1uzpvm4rf9m2j7t6kj052a6cfj6m2a4fxvu3v4sdlsxdhy4s0c45s5"]	83632ae821f7b9a6f4885cb2c3ea559957d4b513b1d11789c90e0b96714e4b84	http://file-server/SP10.json	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	1116	pool1qqwnsfw98ycqj5gs24829d065pgmdchfugf9n66czfux5hph4kk
12470000000000	stake_test1upywssqc5pwtnhvr6x9un8h7xwyqke6zsfjazjqv8p7485g8qfq2j	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30011, "__typename": "RelayByAddress"}]	["stake_test1upywssqc5pwtnhvr6x9un8h7xwyqke6zsfjazjqv8p7485g8qfq2j"]	c983d0e4ac81774659d6742bfcc2e20eabca85c18da6daa946cf302ec70bf466	http://file-server/SP11.json	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	1247	pool13jwk36zmyaev3chtsg3yehmcun8aa3gdzfa42aqluf59jv8jk87
161650000000000	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	500000000000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.1", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys"]	2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	\N	\N	16165	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
163320000000000	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	50000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.2", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v"]	641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	\N	\N	16332	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_retirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retirement (id, retire_at_epoch, block_slot, stake_pool_id) FROM stdin;
8710000000000	5	871	pool1waqwmsn0srycnlxcz3m3u32lyta5s35zgyqlyu940ece5mt6ylg
10190000000000	18	1019	pool1gk5vxx0qlc4txk7nc7lh2k3my3vmhhndfqzlkll0j7dfczenwf9
11430000000000	5	1143	pool1qqwnsfw98ycqj5gs24829d065pgmdchfugf9n66czfux5hph4kk
12930000000000	18	1293	pool13jwk36zmyaev3chtsg3yehmcun8aa3gdzfa42aqluf59jv8jk87
\.


--
-- Data for Name: pool_rewards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_rewards (id, stake_pool_id, epoch_length, epoch_no, delegators, pledge, active_stake, member_active_stake, leader_rewards, member_rewards, rewards, version) FROM stdin;
1	pool1waqwmsn0srycnlxcz3m3u32lyta5s35zgyqlyu940ece5mt6ylg	1000000	1	0	500000000	0	0	0	6920441742100	6920441742100	1
2	pool1gk5vxx0qlc4txk7nc7lh2k3my3vmhhndfqzlkll0j7dfczenwf9	1000000	1	0	500000000	0	0	0	12975828266438	12975828266438	1
3	pool124acjdvffn06wqfxc2lansvm8xyad8ga4fd2d8jp773jg28pu3g	1000000	1	0	400000000	0	0	0	6920441742100	6920441742100	1
4	pool14j403ncw3lc7kp5k2adzmskvp6xucaftk9frjsjs4an5ygg2tf4	1000000	1	0	500000000	0	0	0	10380662613150	10380662613150	1
5	pool1p2r5c3xt03t5achwd7cj7ghwzsl4ejqhhj0gq6errgm85apv3x9	1000000	1	0	600000000	0	0	0	5190331306575	5190331306575	1
6	pool1hchl83q80arjn4hcks8egft429dffnpd8405ecuvm45azjje5ae	1000000	1	0	420000000	0	0	0	7785496959863	7785496959863	1
7	pool1053yndnhk5nd7lp6eqfcwtktztwdfpd9n6xmmzckr5hzuqnq2r5	1000000	1	0	410000000	0	0	0	9515607395388	9515607395388	1
8	pool14fqrqspdrmz58ehsucqckyqqdu7g5q5vn6phrxga9fnvs7d9l8j	1000000	1	0	410000000	0	0	0	6055386524337	6055386524337	1
9	pool1g8xc4xh2c7zkej9gwuh6s2nquxrrghvyyf25z62nxha0snlyz7u	1000000	1	0	410000000	0	0	0	6055386524337	6055386524337	1
\.


--
-- Data for Name: stake_pool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_pool (id, status, last_registration_id, last_retirement_id) FROM stdin;
pool1gk5vxx0qlc4txk7nc7lh2k3my3vmhhndfqzlkll0j7dfczenwf9	retiring	9840000000000	10190000000000
pool13jwk36zmyaev3chtsg3yehmcun8aa3gdzfa42aqluf59jv8jk87	retiring	12470000000000	12930000000000
pool124acjdvffn06wqfxc2lansvm8xyad8ga4fd2d8jp773jg28pu3g	active	2500000000000	\N
pool14j403ncw3lc7kp5k2adzmskvp6xucaftk9frjsjs4an5ygg2tf4	active	3380000000000	\N
pool1p2r5c3xt03t5achwd7cj7ghwzsl4ejqhhj0gq6errgm85apv3x9	active	4050000000000	\N
pool1hchl83q80arjn4hcks8egft429dffnpd8405ecuvm45azjje5ae	active	4770000000000	\N
pool1053yndnhk5nd7lp6eqfcwtktztwdfpd9n6xmmzckr5hzuqnq2r5	active	5650000000000	\N
pool14fqrqspdrmz58ehsucqckyqqdu7g5q5vn6phrxga9fnvs7d9l8j	active	6460000000000	\N
pool1g8xc4xh2c7zkej9gwuh6s2nquxrrghvyyf25z62nxha0snlyz7u	active	7270000000000	\N
pool1waqwmsn0srycnlxcz3m3u32lyta5s35zgyqlyu940ece5mt6ylg	retired	8230000000000	8710000000000
pool1qqwnsfw98ycqj5gs24829d065pgmdchfugf9n66czfux5hph4kk	retired	11160000000000	11430000000000
pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	activating	161650000000000	\N
pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	activating	163320000000000	\N
\.


--
-- Name: pool_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_metadata_id_seq', 8, true);


--
-- Name: pool_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_rewards_id_seq', 9, true);


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

