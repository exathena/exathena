--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4
-- Dumped by pg_dump version 12.4

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: authentication_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authentication_logs (
    id bigint NOT NULL,
    user_id integer,
    socket_fd integer NOT NULL,
    ip bytea NOT NULL,
    encrypted_ip bytea NOT NULL,
    message text NOT NULL,
    metadata json NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: authentication_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authentication_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentication_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.authentication_logs_id_seq OWNED BY public.authentication_logs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: authentication_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentication_logs ALTER COLUMN id SET DEFAULT nextval('public.authentication_logs_id_seq'::regclass);


--
-- Name: authentication_logs authentication_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentication_logs
    ADD CONSTRAINT authentication_logs_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: authentication_logs_encrypted_ip_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authentication_logs_encrypted_ip_index ON public.authentication_logs USING btree (encrypted_ip);


--
-- Name: authentication_logs_socket_fd_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authentication_logs_socket_fd_index ON public.authentication_logs USING btree (socket_fd);


--
-- Name: authentication_logs_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authentication_logs_user_id_index ON public.authentication_logs USING btree (user_id);


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20220409185121);
