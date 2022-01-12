--
-- PostgreSQL database dump
--

-- Dumped from database version 11.12 (Debian 11.12-0+deb10u1)
-- Dumped by pg_dump version 11.12 (Debian 11.12-0+deb10u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: basefiles; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.basefiles (
    baseid bigint NOT NULL,
    jobid integer NOT NULL,
    fileid bigint NOT NULL,
    fileindex integer DEFAULT 0,
    basejobid integer
);


ALTER TABLE public.basefiles OWNER TO bacula;

--
-- Name: basefiles_baseid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.basefiles_baseid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.basefiles_baseid_seq OWNER TO bacula;

--
-- Name: basefiles_baseid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.basefiles_baseid_seq OWNED BY public.basefiles.baseid;


--
-- Name: cdimages; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.cdimages (
    mediaid integer NOT NULL,
    lastburn timestamp without time zone NOT NULL
);


ALTER TABLE public.cdimages OWNER TO bacula;

--
-- Name: client; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.client (
    clientid integer NOT NULL,
    name text NOT NULL,
    uname text NOT NULL,
    autoprune smallint DEFAULT 0,
    fileretention bigint DEFAULT 0,
    jobretention bigint DEFAULT 0
);


ALTER TABLE public.client OWNER TO bacula;

--
-- Name: client_clientid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.client_clientid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.client_clientid_seq OWNER TO bacula;

--
-- Name: client_clientid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.client_clientid_seq OWNED BY public.client.clientid;


--
-- Name: counters; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.counters (
    counter text NOT NULL,
    minvalue integer DEFAULT 0,
    maxvalue integer DEFAULT 0,
    currentvalue integer DEFAULT 0,
    wrapcounter text NOT NULL
);


ALTER TABLE public.counters OWNER TO bacula;

--
-- Name: device; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.device (
    deviceid integer NOT NULL,
    name text NOT NULL,
    mediatypeid integer NOT NULL,
    storageid integer NOT NULL,
    devmounts integer DEFAULT 0 NOT NULL,
    devreadbytes bigint DEFAULT 0 NOT NULL,
    devwritebytes bigint DEFAULT 0 NOT NULL,
    devreadbytessincecleaning bigint DEFAULT 0 NOT NULL,
    devwritebytessincecleaning bigint DEFAULT 0 NOT NULL,
    devreadtime bigint DEFAULT 0 NOT NULL,
    devwritetime bigint DEFAULT 0 NOT NULL,
    devreadtimesincecleaning bigint DEFAULT 0 NOT NULL,
    devwritetimesincecleaning bigint DEFAULT 0 NOT NULL,
    cleaningdate timestamp without time zone,
    cleaningperiod bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.device OWNER TO bacula;

--
-- Name: device_deviceid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.device_deviceid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.device_deviceid_seq OWNER TO bacula;

--
-- Name: device_deviceid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.device_deviceid_seq OWNED BY public.device.deviceid;


--
-- Name: file; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.file (
    fileid bigint NOT NULL,
    fileindex integer DEFAULT 0 NOT NULL,
    jobid integer NOT NULL,
    pathid integer NOT NULL,
    filenameid integer NOT NULL,
    deltaseq smallint DEFAULT 0 NOT NULL,
    markid integer DEFAULT 0 NOT NULL,
    lstat text NOT NULL,
    md5 text NOT NULL
);


ALTER TABLE public.file OWNER TO bacula;

--
-- Name: file_fileid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.file_fileid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.file_fileid_seq OWNER TO bacula;

--
-- Name: file_fileid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.file_fileid_seq OWNED BY public.file.fileid;


--
-- Name: filename; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.filename (
    filenameid integer NOT NULL,
    name text NOT NULL
);
ALTER TABLE ONLY public.filename ALTER COLUMN name SET STATISTICS 1000;


ALTER TABLE public.filename OWNER TO bacula;

--
-- Name: filename_filenameid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.filename_filenameid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.filename_filenameid_seq OWNER TO bacula;

--
-- Name: filename_filenameid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.filename_filenameid_seq OWNED BY public.filename.filenameid;


--
-- Name: fileset; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.fileset (
    filesetid integer NOT NULL,
    fileset text NOT NULL,
    md5 text NOT NULL,
    createtime timestamp without time zone NOT NULL
);


ALTER TABLE public.fileset OWNER TO bacula;

--
-- Name: fileset_filesetid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.fileset_filesetid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fileset_filesetid_seq OWNER TO bacula;

--
-- Name: fileset_filesetid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.fileset_filesetid_seq OWNED BY public.fileset.filesetid;


--
-- Name: job; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.job (
    jobid integer NOT NULL,
    job text NOT NULL,
    name text NOT NULL,
    type character(1) NOT NULL,
    level character(1) NOT NULL,
    clientid integer DEFAULT 0,
    jobstatus character(1) NOT NULL,
    schedtime timestamp without time zone,
    starttime timestamp without time zone,
    endtime timestamp without time zone,
    realendtime timestamp without time zone,
    jobtdate bigint DEFAULT 0,
    volsessionid integer DEFAULT 0,
    volsessiontime integer DEFAULT 0,
    jobfiles integer DEFAULT 0,
    jobbytes bigint DEFAULT 0,
    readbytes bigint DEFAULT 0,
    joberrors integer DEFAULT 0,
    jobmissingfiles integer DEFAULT 0,
    poolid integer DEFAULT 0,
    filesetid integer DEFAULT 0,
    priorjobid integer DEFAULT 0,
    purgedfiles smallint DEFAULT 0,
    hasbase smallint DEFAULT 0,
    hascache smallint DEFAULT 0,
    reviewed smallint DEFAULT 0,
    comment text,
    filetable text DEFAULT 'File'::text
);


ALTER TABLE public.job OWNER TO bacula;

--
-- Name: job_jobid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.job_jobid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_jobid_seq OWNER TO bacula;

--
-- Name: job_jobid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.job_jobid_seq OWNED BY public.job.jobid;


--
-- Name: jobhisto; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.jobhisto (
    jobid integer NOT NULL,
    job text NOT NULL,
    name text NOT NULL,
    type character(1) NOT NULL,
    level character(1) NOT NULL,
    clientid integer,
    jobstatus character(1) NOT NULL,
    schedtime timestamp without time zone,
    starttime timestamp without time zone,
    endtime timestamp without time zone,
    realendtime timestamp without time zone,
    jobtdate bigint,
    volsessionid integer,
    volsessiontime integer,
    jobfiles integer,
    jobbytes bigint,
    readbytes bigint,
    joberrors integer,
    jobmissingfiles integer,
    poolid integer,
    filesetid integer,
    priorjobid integer,
    purgedfiles smallint,
    hasbase smallint,
    hascache smallint,
    reviewed smallint,
    comment text,
    filetable text
);


ALTER TABLE public.jobhisto OWNER TO bacula;

--
-- Name: jobmedia; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.jobmedia (
    jobmediaid integer NOT NULL,
    jobid integer NOT NULL,
    mediaid integer NOT NULL,
    firstindex integer DEFAULT 0,
    lastindex integer DEFAULT 0,
    startfile integer DEFAULT 0,
    endfile integer DEFAULT 0,
    startblock bigint DEFAULT 0,
    endblock bigint DEFAULT 0,
    volindex integer DEFAULT 0
);


ALTER TABLE public.jobmedia OWNER TO bacula;

--
-- Name: jobmedia_jobmediaid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.jobmedia_jobmediaid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jobmedia_jobmediaid_seq OWNER TO bacula;

--
-- Name: jobmedia_jobmediaid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.jobmedia_jobmediaid_seq OWNED BY public.jobmedia.jobmediaid;


--
-- Name: location; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.location (
    locationid integer NOT NULL,
    location text NOT NULL,
    cost integer DEFAULT 0,
    enabled smallint
);


ALTER TABLE public.location OWNER TO bacula;

--
-- Name: location_locationid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.location_locationid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.location_locationid_seq OWNER TO bacula;

--
-- Name: location_locationid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.location_locationid_seq OWNED BY public.location.locationid;


--
-- Name: locationlog; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.locationlog (
    loclogid integer NOT NULL,
    date timestamp without time zone,
    comment text NOT NULL,
    mediaid integer DEFAULT 0,
    locationid integer DEFAULT 0,
    newvolstatus text NOT NULL,
    newenabled smallint,
    CONSTRAINT locationlog_newvolstatus_check CHECK ((newvolstatus = ANY (ARRAY['Full'::text, 'Archive'::text, 'Append'::text, 'Recycle'::text, 'Purged'::text, 'Read-Only'::text, 'Disabled'::text, 'Error'::text, 'Busy'::text, 'Used'::text, 'Cleaning'::text, 'Scratch'::text])))
);


ALTER TABLE public.locationlog OWNER TO bacula;

--
-- Name: locationlog_loclogid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.locationlog_loclogid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.locationlog_loclogid_seq OWNER TO bacula;

--
-- Name: locationlog_loclogid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.locationlog_loclogid_seq OWNED BY public.locationlog.loclogid;


--
-- Name: log; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.log (
    logid integer NOT NULL,
    jobid integer NOT NULL,
    "time" timestamp without time zone,
    logtext text NOT NULL
);


ALTER TABLE public.log OWNER TO bacula;

--
-- Name: log_logid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.log_logid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_logid_seq OWNER TO bacula;

--
-- Name: log_logid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.log_logid_seq OWNED BY public.log.logid;


--
-- Name: media; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.media (
    mediaid integer NOT NULL,
    volumename text NOT NULL,
    slot integer DEFAULT 0,
    poolid integer DEFAULT 0,
    mediatype text NOT NULL,
    mediatypeid integer DEFAULT 0,
    labeltype integer DEFAULT 0,
    firstwritten timestamp without time zone,
    lastwritten timestamp without time zone,
    labeldate timestamp without time zone,
    voljobs integer DEFAULT 0,
    volfiles integer DEFAULT 0,
    volblocks integer DEFAULT 0,
    volparts integer DEFAULT 0,
    volcloudparts integer DEFAULT 0,
    volmounts integer DEFAULT 0,
    volbytes bigint DEFAULT 0,
    volabytes bigint DEFAULT 0,
    volapadding bigint DEFAULT 0,
    volholebytes bigint DEFAULT 0,
    volholes integer DEFAULT 0,
    voltype integer DEFAULT 0,
    volerrors integer DEFAULT 0,
    volwrites bigint DEFAULT 0,
    volcapacitybytes bigint DEFAULT 0,
    lastpartbytes bigint DEFAULT 0,
    volstatus text NOT NULL,
    enabled smallint DEFAULT 1,
    recycle smallint DEFAULT 0,
    actiononpurge smallint DEFAULT 0,
    cacheretention bigint DEFAULT 0,
    volretention bigint DEFAULT 0,
    voluseduration bigint DEFAULT 0,
    maxvoljobs integer DEFAULT 0,
    maxvolfiles integer DEFAULT 0,
    maxvolbytes bigint DEFAULT 0,
    inchanger smallint DEFAULT 0,
    storageid integer DEFAULT 0,
    deviceid integer DEFAULT 0,
    mediaaddressing smallint DEFAULT 0,
    volreadtime bigint DEFAULT 0,
    volwritetime bigint DEFAULT 0,
    endfile integer DEFAULT 0,
    endblock bigint DEFAULT 0,
    locationid integer DEFAULT 0,
    recyclecount integer DEFAULT 0,
    initialwrite timestamp without time zone,
    scratchpoolid integer DEFAULT 0,
    recyclepoolid integer DEFAULT 0,
    comment text,
    CONSTRAINT media_volstatus_check CHECK ((volstatus = ANY (ARRAY['Full'::text, 'Archive'::text, 'Append'::text, 'Recycle'::text, 'Purged'::text, 'Read-Only'::text, 'Disabled'::text, 'Error'::text, 'Busy'::text, 'Used'::text, 'Cleaning'::text, 'Scratch'::text])))
);


ALTER TABLE public.media OWNER TO bacula;

--
-- Name: media_mediaid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.media_mediaid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.media_mediaid_seq OWNER TO bacula;

--
-- Name: media_mediaid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.media_mediaid_seq OWNED BY public.media.mediaid;


--
-- Name: mediatype; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.mediatype (
    mediatypeid integer NOT NULL,
    mediatype text NOT NULL,
    readonly integer DEFAULT 0
);


ALTER TABLE public.mediatype OWNER TO bacula;

--
-- Name: mediatype_mediatypeid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.mediatype_mediatypeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mediatype_mediatypeid_seq OWNER TO bacula;

--
-- Name: mediatype_mediatypeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.mediatype_mediatypeid_seq OWNED BY public.mediatype.mediatypeid;


--
-- Name: path; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.path (
    pathid integer NOT NULL,
    path text NOT NULL
);
ALTER TABLE ONLY public.path ALTER COLUMN path SET STATISTICS 1000;


ALTER TABLE public.path OWNER TO bacula;

--
-- Name: path_pathid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.path_pathid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.path_pathid_seq OWNER TO bacula;

--
-- Name: path_pathid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.path_pathid_seq OWNED BY public.path.pathid;


--
-- Name: pathhierarchy; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.pathhierarchy (
    pathid integer NOT NULL,
    ppathid integer NOT NULL
);


ALTER TABLE public.pathhierarchy OWNER TO bacula;

--
-- Name: pathvisibility; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.pathvisibility (
    pathid integer NOT NULL,
    jobid integer NOT NULL,
    size bigint DEFAULT 0,
    files integer DEFAULT 0
);


ALTER TABLE public.pathvisibility OWNER TO bacula;

--
-- Name: pool; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.pool (
    poolid integer NOT NULL,
    name text NOT NULL,
    numvols integer DEFAULT 0,
    maxvols integer DEFAULT 0,
    useonce smallint DEFAULT 0,
    usecatalog smallint DEFAULT 0,
    acceptanyvolume smallint DEFAULT 0,
    cacheretention bigint DEFAULT 0,
    volretention bigint DEFAULT 0,
    voluseduration bigint DEFAULT 0,
    maxvoljobs integer DEFAULT 0,
    maxvolfiles integer DEFAULT 0,
    maxvolbytes bigint DEFAULT 0,
    autoprune smallint DEFAULT 0,
    recycle smallint DEFAULT 0,
    actiononpurge smallint DEFAULT 0,
    pooltype text,
    labeltype integer DEFAULT 0,
    labelformat text NOT NULL,
    enabled smallint DEFAULT 1,
    scratchpoolid integer DEFAULT 0,
    recyclepoolid integer DEFAULT 0,
    nextpoolid integer DEFAULT 0,
    migrationhighbytes bigint DEFAULT 0,
    migrationlowbytes bigint DEFAULT 0,
    migrationtime bigint DEFAULT 0,
    CONSTRAINT pool_pooltype_check CHECK ((pooltype = ANY (ARRAY['Backup'::text, 'Copy'::text, 'Cloned'::text, 'Archive'::text, 'Migration'::text, 'Scratch'::text])))
);


ALTER TABLE public.pool OWNER TO bacula;

--
-- Name: pool_poolid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.pool_poolid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_poolid_seq OWNER TO bacula;

--
-- Name: pool_poolid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.pool_poolid_seq OWNED BY public.pool.poolid;


--
-- Name: restoreobject; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.restoreobject (
    restoreobjectid integer NOT NULL,
    objectname text NOT NULL,
    restoreobject bytea NOT NULL,
    pluginname text NOT NULL,
    objectlength integer DEFAULT 0,
    objectfulllength integer DEFAULT 0,
    objectindex integer DEFAULT 0,
    objecttype integer DEFAULT 0,
    fileindex integer DEFAULT 0,
    jobid integer,
    objectcompression integer DEFAULT 0
);


ALTER TABLE public.restoreobject OWNER TO bacula;

--
-- Name: restoreobject_restoreobjectid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.restoreobject_restoreobjectid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.restoreobject_restoreobjectid_seq OWNER TO bacula;

--
-- Name: restoreobject_restoreobjectid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.restoreobject_restoreobjectid_seq OWNED BY public.restoreobject.restoreobjectid;


--
-- Name: snapshot; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.snapshot (
    snapshotid integer NOT NULL,
    name text NOT NULL,
    jobid integer DEFAULT 0,
    filesetid integer DEFAULT 0,
    createtdate bigint DEFAULT 0,
    createdate timestamp without time zone NOT NULL,
    clientid integer DEFAULT 0,
    volume text NOT NULL,
    device text NOT NULL,
    type text NOT NULL,
    retention integer DEFAULT 0,
    comment text
);


ALTER TABLE public.snapshot OWNER TO bacula;

--
-- Name: snapshot_snapshotid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.snapshot_snapshotid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.snapshot_snapshotid_seq OWNER TO bacula;

--
-- Name: snapshot_snapshotid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.snapshot_snapshotid_seq OWNED BY public.snapshot.snapshotid;


--
-- Name: status; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.status (
    jobstatus character(1) NOT NULL,
    jobstatuslong text,
    severity integer
);


ALTER TABLE public.status OWNER TO bacula;

--
-- Name: storage; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.storage (
    storageid integer NOT NULL,
    name text NOT NULL,
    autochanger integer DEFAULT 0
);


ALTER TABLE public.storage OWNER TO bacula;

--
-- Name: storage_storageid_seq; Type: SEQUENCE; Schema: public; Owner: bacula
--

CREATE SEQUENCE public.storage_storageid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.storage_storageid_seq OWNER TO bacula;

--
-- Name: storage_storageid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bacula
--

ALTER SEQUENCE public.storage_storageid_seq OWNED BY public.storage.storageid;


--
-- Name: unsavedfiles; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.unsavedfiles (
    unsavedid integer NOT NULL,
    jobid integer NOT NULL,
    pathid integer NOT NULL,
    filenameid integer NOT NULL
);


ALTER TABLE public.unsavedfiles OWNER TO bacula;

--
-- Name: version; Type: TABLE; Schema: public; Owner: bacula
--

CREATE TABLE public.version (
    versionid integer NOT NULL
);


ALTER TABLE public.version OWNER TO bacula;

--
-- Name: basefiles baseid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.basefiles ALTER COLUMN baseid SET DEFAULT nextval('public.basefiles_baseid_seq'::regclass);


--
-- Name: client clientid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.client ALTER COLUMN clientid SET DEFAULT nextval('public.client_clientid_seq'::regclass);


--
-- Name: device deviceid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.device ALTER COLUMN deviceid SET DEFAULT nextval('public.device_deviceid_seq'::regclass);


--
-- Name: file fileid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.file ALTER COLUMN fileid SET DEFAULT nextval('public.file_fileid_seq'::regclass);


--
-- Name: filename filenameid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.filename ALTER COLUMN filenameid SET DEFAULT nextval('public.filename_filenameid_seq'::regclass);


--
-- Name: fileset filesetid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.fileset ALTER COLUMN filesetid SET DEFAULT nextval('public.fileset_filesetid_seq'::regclass);


--
-- Name: job jobid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.job ALTER COLUMN jobid SET DEFAULT nextval('public.job_jobid_seq'::regclass);


--
-- Name: jobmedia jobmediaid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.jobmedia ALTER COLUMN jobmediaid SET DEFAULT nextval('public.jobmedia_jobmediaid_seq'::regclass);


--
-- Name: location locationid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.location ALTER COLUMN locationid SET DEFAULT nextval('public.location_locationid_seq'::regclass);


--
-- Name: locationlog loclogid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.locationlog ALTER COLUMN loclogid SET DEFAULT nextval('public.locationlog_loclogid_seq'::regclass);


--
-- Name: log logid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.log ALTER COLUMN logid SET DEFAULT nextval('public.log_logid_seq'::regclass);


--
-- Name: media mediaid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.media ALTER COLUMN mediaid SET DEFAULT nextval('public.media_mediaid_seq'::regclass);


--
-- Name: mediatype mediatypeid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.mediatype ALTER COLUMN mediatypeid SET DEFAULT nextval('public.mediatype_mediatypeid_seq'::regclass);


--
-- Name: path pathid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.path ALTER COLUMN pathid SET DEFAULT nextval('public.path_pathid_seq'::regclass);


--
-- Name: pool poolid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.pool ALTER COLUMN poolid SET DEFAULT nextval('public.pool_poolid_seq'::regclass);


--
-- Name: restoreobject restoreobjectid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.restoreobject ALTER COLUMN restoreobjectid SET DEFAULT nextval('public.restoreobject_restoreobjectid_seq'::regclass);


--
-- Name: snapshot snapshotid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.snapshot ALTER COLUMN snapshotid SET DEFAULT nextval('public.snapshot_snapshotid_seq'::regclass);


--
-- Name: storage storageid; Type: DEFAULT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.storage ALTER COLUMN storageid SET DEFAULT nextval('public.storage_storageid_seq'::regclass);


--
-- Data for Name: basefiles; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.basefiles (baseid, jobid, fileid, fileindex, basejobid) FROM stdin;
\.


--
-- Data for Name: cdimages; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.cdimages (mediaid, lastburn) FROM stdin;
\.


--
-- Data for Name: client; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.client (clientid, name, uname, autoprune, fileretention, jobretention) FROM stdin;
\.


--
-- Data for Name: counters; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.counters (counter, minvalue, maxvalue, currentvalue, wrapcounter) FROM stdin;
\.


--
-- Data for Name: device; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.device (deviceid, name, mediatypeid, storageid, devmounts, devreadbytes, devwritebytes, devreadbytessincecleaning, devwritebytessincecleaning, devreadtime, devwritetime, devreadtimesincecleaning, devwritetimesincecleaning, cleaningdate, cleaningperiod) FROM stdin;
\.


--
-- Data for Name: file; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.file (fileid, fileindex, jobid, pathid, filenameid, deltaseq, markid, lstat, md5) FROM stdin;
\.


--
-- Data for Name: filename; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.filename (filenameid, name) FROM stdin;
\.


--
-- Data for Name: fileset; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.fileset (filesetid, fileset, md5, createtime) FROM stdin;
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.job (jobid, job, name, type, level, clientid, jobstatus, schedtime, starttime, endtime, realendtime, jobtdate, volsessionid, volsessiontime, jobfiles, jobbytes, readbytes, joberrors, jobmissingfiles, poolid, filesetid, priorjobid, purgedfiles, hasbase, hascache, reviewed, comment, filetable) FROM stdin;
\.


--
-- Data for Name: jobhisto; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.jobhisto (jobid, job, name, type, level, clientid, jobstatus, schedtime, starttime, endtime, realendtime, jobtdate, volsessionid, volsessiontime, jobfiles, jobbytes, readbytes, joberrors, jobmissingfiles, poolid, filesetid, priorjobid, purgedfiles, hasbase, hascache, reviewed, comment, filetable) FROM stdin;
\.


--
-- Data for Name: jobmedia; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.jobmedia (jobmediaid, jobid, mediaid, firstindex, lastindex, startfile, endfile, startblock, endblock, volindex) FROM stdin;
\.


--
-- Data for Name: location; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.location (locationid, location, cost, enabled) FROM stdin;
\.


--
-- Data for Name: locationlog; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.locationlog (loclogid, date, comment, mediaid, locationid, newvolstatus, newenabled) FROM stdin;
\.


--
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.log (logid, jobid, "time", logtext) FROM stdin;
\.


--
-- Data for Name: media; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.media (mediaid, volumename, slot, poolid, mediatype, mediatypeid, labeltype, firstwritten, lastwritten, labeldate, voljobs, volfiles, volblocks, volparts, volcloudparts, volmounts, volbytes, volabytes, volapadding, volholebytes, volholes, voltype, volerrors, volwrites, volcapacitybytes, lastpartbytes, volstatus, enabled, recycle, actiononpurge, cacheretention, volretention, voluseduration, maxvoljobs, maxvolfiles, maxvolbytes, inchanger, storageid, deviceid, mediaaddressing, volreadtime, volwritetime, endfile, endblock, locationid, recyclecount, initialwrite, scratchpoolid, recyclepoolid, comment) FROM stdin;
\.


--
-- Data for Name: mediatype; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.mediatype (mediatypeid, mediatype, readonly) FROM stdin;
\.


--
-- Data for Name: path; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.path (pathid, path) FROM stdin;
\.


--
-- Data for Name: pathhierarchy; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.pathhierarchy (pathid, ppathid) FROM stdin;
\.


--
-- Data for Name: pathvisibility; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.pathvisibility (pathid, jobid, size, files) FROM stdin;
\.


--
-- Data for Name: pool; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.pool (poolid, name, numvols, maxvols, useonce, usecatalog, acceptanyvolume, cacheretention, volretention, voluseduration, maxvoljobs, maxvolfiles, maxvolbytes, autoprune, recycle, actiononpurge, pooltype, labeltype, labelformat, enabled, scratchpoolid, recyclepoolid, nextpoolid, migrationhighbytes, migrationlowbytes, migrationtime) FROM stdin;
\.


--
-- Data for Name: restoreobject; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.restoreobject (restoreobjectid, objectname, restoreobject, pluginname, objectlength, objectfulllength, objectindex, objecttype, fileindex, jobid, objectcompression) FROM stdin;
\.


--
-- Data for Name: snapshot; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.snapshot (snapshotid, name, jobid, filesetid, createtdate, createdate, clientid, volume, device, type, retention, comment) FROM stdin;
\.


--
-- Data for Name: status; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.status (jobstatus, jobstatuslong, severity) FROM stdin;
C	Created, not yet running	15
R	Running	15
B	Blocked	15
T	Completed successfully	10
E	Terminated with errors	25
e	Non-fatal error	20
f	Fatal error	100
D	Verify found differences	15
A	Canceled by user	90
F	Waiting for Client	15
S	Waiting for Storage daemon	15
m	Waiting for new media	\N
M	Waiting for media mount	15
s	Waiting for storage resource	15
j	Waiting for job resource	15
c	Waiting for client resource	15
d	Waiting on maximum jobs	15
t	Waiting on start time	15
p	Waiting on higher priority jobs	15
a	SD despooling attributes	15
i	Doing batch insert file records	15
I	Incomplete Job	25
\.


--
-- Data for Name: storage; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.storage (storageid, name, autochanger) FROM stdin;
\.


--
-- Data for Name: unsavedfiles; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.unsavedfiles (unsavedid, jobid, pathid, filenameid) FROM stdin;
\.


--
-- Data for Name: version; Type: TABLE DATA; Schema: public; Owner: bacula
--

COPY public.version (versionid) FROM stdin;
16
\.


--
-- Name: basefiles_baseid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.basefiles_baseid_seq', 1, false);


--
-- Name: client_clientid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.client_clientid_seq', 1, false);


--
-- Name: device_deviceid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.device_deviceid_seq', 1, false);


--
-- Name: file_fileid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.file_fileid_seq', 1, false);


--
-- Name: filename_filenameid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.filename_filenameid_seq', 1, false);


--
-- Name: fileset_filesetid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.fileset_filesetid_seq', 1, false);


--
-- Name: job_jobid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.job_jobid_seq', 1, false);


--
-- Name: jobmedia_jobmediaid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.jobmedia_jobmediaid_seq', 1, false);


--
-- Name: location_locationid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.location_locationid_seq', 1, false);


--
-- Name: locationlog_loclogid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.locationlog_loclogid_seq', 1, false);


--
-- Name: log_logid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.log_logid_seq', 1, false);


--
-- Name: media_mediaid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.media_mediaid_seq', 1, false);


--
-- Name: mediatype_mediatypeid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.mediatype_mediatypeid_seq', 1, false);


--
-- Name: path_pathid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.path_pathid_seq', 1, false);


--
-- Name: pool_poolid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.pool_poolid_seq', 1, false);


--
-- Name: restoreobject_restoreobjectid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.restoreobject_restoreobjectid_seq', 1, false);


--
-- Name: snapshot_snapshotid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.snapshot_snapshotid_seq', 1, false);


--
-- Name: storage_storageid_seq; Type: SEQUENCE SET; Schema: public; Owner: bacula
--

SELECT pg_catalog.setval('public.storage_storageid_seq', 1, false);


--
-- Name: basefiles basefiles_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.basefiles
    ADD CONSTRAINT basefiles_pkey PRIMARY KEY (baseid);


--
-- Name: cdimages cdimages_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.cdimages
    ADD CONSTRAINT cdimages_pkey PRIMARY KEY (mediaid);


--
-- Name: client client_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (clientid);


--
-- Name: counters counters_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.counters
    ADD CONSTRAINT counters_pkey PRIMARY KEY (counter);


--
-- Name: device device_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_pkey PRIMARY KEY (deviceid);


--
-- Name: file file_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.file
    ADD CONSTRAINT file_pkey PRIMARY KEY (fileid);


--
-- Name: filename filename_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.filename
    ADD CONSTRAINT filename_pkey PRIMARY KEY (filenameid);


--
-- Name: fileset fileset_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.fileset
    ADD CONSTRAINT fileset_pkey PRIMARY KEY (filesetid);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (jobid);


--
-- Name: jobmedia jobmedia_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.jobmedia
    ADD CONSTRAINT jobmedia_pkey PRIMARY KEY (jobmediaid);


--
-- Name: location location_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.location
    ADD CONSTRAINT location_pkey PRIMARY KEY (locationid);


--
-- Name: locationlog locationlog_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.locationlog
    ADD CONSTRAINT locationlog_pkey PRIMARY KEY (loclogid);


--
-- Name: log log_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pkey PRIMARY KEY (logid);


--
-- Name: media media_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_pkey PRIMARY KEY (mediaid);


--
-- Name: mediatype mediatype_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.mediatype
    ADD CONSTRAINT mediatype_pkey PRIMARY KEY (mediatypeid);


--
-- Name: path path_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.path
    ADD CONSTRAINT path_pkey PRIMARY KEY (pathid);


--
-- Name: pathhierarchy pathhierarchy_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.pathhierarchy
    ADD CONSTRAINT pathhierarchy_pkey PRIMARY KEY (pathid);


--
-- Name: pathvisibility pathvisibility_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.pathvisibility
    ADD CONSTRAINT pathvisibility_pkey PRIMARY KEY (jobid, pathid);


--
-- Name: pool pool_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.pool
    ADD CONSTRAINT pool_pkey PRIMARY KEY (poolid);


--
-- Name: restoreobject restoreobject_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.restoreobject
    ADD CONSTRAINT restoreobject_pkey PRIMARY KEY (restoreobjectid);


--
-- Name: snapshot snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.snapshot
    ADD CONSTRAINT snapshot_pkey PRIMARY KEY (snapshotid);


--
-- Name: status status_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (jobstatus);


--
-- Name: storage storage_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.storage
    ADD CONSTRAINT storage_pkey PRIMARY KEY (storageid);


--
-- Name: unsavedfiles unsavedfiles_pkey; Type: CONSTRAINT; Schema: public; Owner: bacula
--

ALTER TABLE ONLY public.unsavedfiles
    ADD CONSTRAINT unsavedfiles_pkey PRIMARY KEY (unsavedid);


--
-- Name: basefiles_jobid_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX basefiles_jobid_idx ON public.basefiles USING btree (jobid);


--
-- Name: client_name_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE UNIQUE INDEX client_name_idx ON public.client USING btree (name text_pattern_ops);


--
-- Name: file_jobid_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX file_jobid_idx ON public.file USING btree (jobid);


--
-- Name: file_jpfid_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX file_jpfid_idx ON public.file USING btree (jobid, pathid, filenameid);


--
-- Name: filename_name_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE UNIQUE INDEX filename_name_idx ON public.filename USING btree (name text_pattern_ops);


--
-- Name: fileset_name_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX fileset_name_idx ON public.fileset USING btree (fileset text_pattern_ops);


--
-- Name: job_jobtdate_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX job_jobtdate_idx ON public.job USING btree (jobtdate);


--
-- Name: job_media_job_id_media_id_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX job_media_job_id_media_id_idx ON public.jobmedia USING btree (jobid, mediaid);


--
-- Name: job_name_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX job_name_idx ON public.job USING btree (name text_pattern_ops);


--
-- Name: jobhisto_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX jobhisto_idx ON public.jobhisto USING btree (starttime);


--
-- Name: log_name_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX log_name_idx ON public.log USING btree (jobid);


--
-- Name: media_poolid_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX media_poolid_idx ON public.media USING btree (poolid);


--
-- Name: media_storageid_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX media_storageid_idx ON public.media USING btree (storageid);


--
-- Name: media_volumename_id; Type: INDEX; Schema: public; Owner: bacula
--

CREATE UNIQUE INDEX media_volumename_id ON public.media USING btree (volumename text_pattern_ops);


--
-- Name: path_name_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE UNIQUE INDEX path_name_idx ON public.path USING btree (path text_pattern_ops);


--
-- Name: pathhierarchy_ppathid; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX pathhierarchy_ppathid ON public.pathhierarchy USING btree (ppathid);


--
-- Name: pathvisibility_jobid; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX pathvisibility_jobid ON public.pathvisibility USING btree (jobid);


--
-- Name: pool_name_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX pool_name_idx ON public.pool USING btree (name text_pattern_ops);


--
-- Name: restore_jobid_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE INDEX restore_jobid_idx ON public.restoreobject USING btree (jobid);


--
-- Name: snapshot_idx; Type: INDEX; Schema: public; Owner: bacula
--

CREATE UNIQUE INDEX snapshot_idx ON public.snapshot USING btree (device text_pattern_ops, volume text_pattern_ops, name text_pattern_ops);


--
-- PostgreSQL database dump complete
--

