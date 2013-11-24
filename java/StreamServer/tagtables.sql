--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: mp3s_jsongs; Type: TABLE; Schema: public; Owner: hitest; Tablespace: 
--

CREATE TABLE mp3s_jsongs (
    id integer NOT NULL,
    file_hash character varying(50),
    song_filepath character varying(2000)
);


ALTER TABLE public.mp3s_jsongs OWNER TO hitest;

--
-- Name: mp3s_jsongs_id_seq; Type: SEQUENCE; Schema: public; Owner: hitest
--

CREATE SEQUENCE mp3s_jsongs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mp3s_jsongs_id_seq OWNER TO hitest;

--
-- Name: mp3s_jsongs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hitest
--

ALTER SEQUENCE mp3s_jsongs_id_seq OWNED BY mp3s_jsongs.id;


--
-- Name: mp3s_jstats; Type: TABLE; Schema: public; Owner: hitest; Tablespace: 
--

CREATE TABLE mp3s_jstats (
    category character varying(50) NOT NULL,
    item character varying(2000) NOT NULL,
    count integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.mp3s_jstats OWNER TO hitest;

--
-- Name: mp3s_jtags; Type: TABLE; Schema: public; Owner: hitest; Tablespace: 
--

CREATE TABLE mp3s_jtags (
    artist character varying(100),
    title character varying(200),
    secs integer DEFAULT (-1) NOT NULL,
    taggeddate date DEFAULT ('now'::text)::date NOT NULL,
    song_id integer
);


ALTER TABLE public.mp3s_jtags OWNER TO hitest;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: hitest
--

ALTER TABLE ONLY mp3s_jsongs ALTER COLUMN id SET DEFAULT nextval('mp3s_jsongs_id_seq'::regclass);


--
-- Name: mp3s_jsongs_pkey; Type: CONSTRAINT; Schema: public; Owner: hitest; Tablespace: 
--

ALTER TABLE ONLY mp3s_jsongs
    ADD CONSTRAINT mp3s_jsongs_pkey PRIMARY KEY (id);


--
-- Name: mp3s_jstats_pkey; Type: CONSTRAINT; Schema: public; Owner: hitest; Tablespace: 
--

ALTER TABLE ONLY mp3s_jstats
    ADD CONSTRAINT mp3s_jstats_pkey PRIMARY KEY (category, item);


--
-- Name: mp3s_jtags_song_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hitest
--

ALTER TABLE ONLY mp3s_jtags
    ADD CONSTRAINT mp3s_jtags_song_id_fkey FOREIGN KEY (song_id) REFERENCES mp3s_jsongs(id);


--
-- Name: mp3s_jsongs; Type: ACL; Schema: public; Owner: hitest
--

REVOKE ALL ON TABLE mp3s_jsongs FROM PUBLIC;
REVOKE ALL ON TABLE mp3s_jsongs FROM hitest;
GRANT ALL ON TABLE mp3s_jsongs TO hitest;
GRANT SELECT,INSERT,UPDATE ON TABLE mp3s_jsongs TO hitest;


--
-- Name: mp3s_jsongs_id_seq; Type: ACL; Schema: public; Owner: hitest
--

REVOKE ALL ON SEQUENCE mp3s_jsongs_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mp3s_jsongs_id_seq FROM hitest;
GRANT ALL ON SEQUENCE mp3s_jsongs_id_seq TO hitest;
GRANT UPDATE ON SEQUENCE mp3s_jsongs_id_seq TO hitest;


--
-- Name: mp3s_jstats; Type: ACL; Schema: public; Owner: hitest
--

REVOKE ALL ON TABLE mp3s_jstats FROM PUBLIC;
REVOKE ALL ON TABLE mp3s_jstats FROM hitest;
GRANT ALL ON TABLE mp3s_jstats TO hitest;
GRANT SELECT,INSERT,UPDATE ON TABLE mp3s_jstats TO hitest;


--
-- Name: mp3s_jtags; Type: ACL; Schema: public; Owner: hitest
--

REVOKE ALL ON TABLE mp3s_jtags FROM PUBLIC;
REVOKE ALL ON TABLE mp3s_jtags FROM hitest;
GRANT ALL ON TABLE mp3s_jtags TO hitest;
GRANT SELECT,INSERT,DELETE,TRUNCATE ON TABLE mp3s_jtags TO hitest;


--
-- PostgreSQL database dump complete
--

