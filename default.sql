SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

CREATE TABLE IF NOT EXISTS users (
    id int NOT NULL,
    mail text NOT NULL,
    accounttype integer DEFAULT 1,
    hashpass text NOT NULL,
    CONSTRAINT users_pkey PRIMARY KEY (id)
);


ALTER TABLE users OWNER TO postgres;

CREATE TABLE IF NOT EXISTS generators (
    id bigint NOT NULL,
    account integer NOT NULL,
    title text NOT NULL,
    metrics json,
    lastmodified timestamp without time zone DEFAULT (now())::timestamp without time zone NOT NULL,
    CONSTRAINT generators_pkey PRIMARY KEY (id,account),
    CONSTRAINT playlist_needs_owner FOREIGN KEY (account) REFERENCES users(id)
);

ALTER TABLE generators OWNER TO postgres;


CREATE SEQUENCE IF NOT EXISTS generators_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE generators_id_seq OWNER TO postgres;
ALTER SEQUENCE generators_id_seq OWNED BY generators.id;

CREATE TABLE IF NOT EXISTS musiccollection (
    musicid text NOT NULL,
 /*   lastmodified timestamp without time zone DEFAULT (now())::timestamp without time zone NOT NULL, */
    computedmetrics json DEFAULT '{}',
    enginever integer,
    duration float,
    step_size float,
    CONSTRAINT musicscollection_pkey PRIMARY KEY (musicid)
);


CREATE TABLE IF NOT EXISTS usermusics (
    musicid text NOT NULL,
    account integer NOT NULL,
    title text NOT NULL,
 /*   lastmodified timestamp without time zone DEFAULT (now())::timestamp without time zone NOT NULL, */
    metrics jsonb DEFAULT '{}',
    CONSTRAINT musics_pkey PRIMARY KEY (musicid,account),
    CONSTRAINT music_needs_owner FOREIGN KEY (account) REFERENCES users(id),
    CONSTRAINT music_in_collection FOREIGN KEY (musicid) REFERENCES musiccollection(musicid)
);




ALTER TABLE usermusics OWNER TO postgres;



CREATE TABLE IF NOT EXISTS playlists (
    id bigint NOT NULL,
    title text NOT NULL,
    account integer NOT NULL,
    lastmodified timestamp without time zone DEFAULT (now())::timestamp without time zone NOT NULL,
    musicids text[1000],
    CONSTRAINT playlists_pkey PRIMARY KEY (id,account),
    CONSTRAINT playlist_needs_owner FOREIGN KEY (account) REFERENCES users(id)
);


ALTER TABLE playlists OWNER TO postgres;

CREATE SEQUENCE IF NOT EXISTS playlists_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER TABLE playlists_id_seq OWNER TO postgres;
ALTER SEQUENCE playlists_id_seq OWNED BY playlists.id;
CREATE TABLE IF NOT EXISTS tokens (
    token text NOT NULL,
    account integer NOT NULL,
    lastmodified timestamp without time zone DEFAULT (now())::timestamp without time zone NOT NULL,
    CONSTRAINT tokens_pkey PRIMARY KEY (token),
    CONSTRAINT token_needs_user FOREIGN KEY (account) REFERENCES users(id)
);


ALTER TABLE tokens OWNER TO postgres;



CREATE SEQUENCE IF NOT EXISTS  users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_id_seq OWNER TO postgres;
ALTER SEQUENCE users_id_seq OWNED BY users.id;
ALTER TABLE ONLY generators ALTER COLUMN id SET DEFAULT nextval('generators_id_seq'::regclass);
ALTER TABLE ONLY playlists ALTER COLUMN id SET DEFAULT nextval('playlists_id_seq'::regclass);
ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);
