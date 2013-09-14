
CREATE TABLE mp3s_jtags (
    song_filepath character varying(2000) NOT NULL,
    file_hash character varying(50) NOT NULL,
    artist character varying(100),
    title character varying(200),
    secs integer DEFAULT (-1) NOT NULL,
    taggeddate date DEFAULT ('now'::text)::date NOT NULL
);

ALTER TABLE ONLY mp3s_jtags
    ADD CONSTRAINT mp3s_jtags_pkey PRIMARY KEY (file_hash);
CREATE INDEX jtags_path ON mp3s_jtags USING btree (song_filepath);


GRANT SELECT,INSERT,DELETE,TRUNCATE ON TABLE mp3s_jtags TO ${dbuser};

CREATE TABLE mp3s_failedtags (
    file_hash character varying(50) NOT NULL,
    reason character varying(100)
);

ALTER TABLE ONLY mp3s_failedtags
    ADD CONSTRAINT mp3s_failedtags_pkey PRIMARY KEY (file_hash);

GRANT SELECT,INSERT ON TABLE mp3s_failedtags TO ${dbuser};--
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
-- Name: mp3s_jstats; Type: TABLE; Schema: public; Owner: colin; Tablespace: 
--

CREATE TABLE mp3s_jstats (
    category character varying(50) NOT NULL,
    item character varying(2000) NOT NULL,
    count integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.mp3s_jstats OWNER TO colin;

--
-- Name: mp3s_jstats_pkey; Type: CONSTRAINT; Schema: public; Owner: colin; Tablespace: 
--

ALTER TABLE ONLY mp3s_jstats
    ADD CONSTRAINT mp3s_jstats_pkey PRIMARY KEY (category, item);


--
-- Name: mp3s_jstats; Type: ACL; Schema: public; Owner: colin
--

REVOKE ALL ON TABLE mp3s_jstats FROM PUBLIC;
REVOKE ALL ON TABLE mp3s_jstats FROM colin;
GRANT ALL ON TABLE mp3s_jstats TO colin;
GRANT SELECT,INSERT,UPDATE ON TABLE mp3s_jstats TO hitest;


--
-- PostgreSQL database dump complete
--

