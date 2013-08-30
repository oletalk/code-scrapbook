
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

GRANT SELECT,INSERT ON TABLE mp3s_failedtags TO ${dbuser};