--
-- PostgreSQL database dump
--

-- Dumped from database version 10.3
-- Dumped by pg_dump version 10.3

-- Started on 2018-03-27 16:44:44

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 16394)
-- Name: webshop; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA webshop;


ALTER SCHEMA webshop OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 203 (class 1259 OID 16421)
-- Name: order; Type: TABLE; Schema: webshop; Owner: postgres
--

CREATE TABLE webshop."order" (
    id integer NOT NULL,
    shoppingcart_id integer NOT NULL,
    customer_name character varying(40),
    address_street character varying(40),
    address_housenumber integer,
    address_zipcode character(6),
    address_city character varying(40),
    preferred_delivery_date date,
    preferred_delivery_time time without time zone
);


ALTER TABLE webshop."order" OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 16419)
-- Name: order_id_seq; Type: SEQUENCE; Schema: webshop; Owner: postgres
--

CREATE SEQUENCE webshop.order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE webshop.order_id_seq OWNER TO postgres;

--
-- TOC entry 2827 (class 0 OID 0)
-- Dependencies: 202
-- Name: order_id_seq; Type: SEQUENCE OWNED BY; Schema: webshop; Owner: postgres
--

ALTER SEQUENCE webshop.order_id_seq OWNED BY webshop."order".id;


--
-- TOC entry 198 (class 1259 OID 16397)
-- Name: product; Type: TABLE; Schema: webshop; Owner: postgres
--

CREATE TABLE webshop.product (
    id integer NOT NULL,
    name character varying(40) NOT NULL,
    description character varying(400),
    price money
);


ALTER TABLE webshop.product OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 16395)
-- Name: product_id_seq; Type: SEQUENCE; Schema: webshop; Owner: postgres
--

CREATE SEQUENCE webshop.product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE webshop.product_id_seq OWNER TO postgres;

--
-- TOC entry 2828 (class 0 OID 0)
-- Dependencies: 197
-- Name: product_id_seq; Type: SEQUENCE OWNED BY; Schema: webshop; Owner: postgres
--

ALTER SEQUENCE webshop.product_id_seq OWNED BY webshop.product.id;


--
-- TOC entry 201 (class 1259 OID 16413)
-- Name: shoppingcart; Type: TABLE; Schema: webshop; Owner: postgres
--

CREATE TABLE webshop.shoppingcart (
    id integer NOT NULL
);


ALTER TABLE webshop.shoppingcart OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 16411)
-- Name: shoppingcart_id_seq; Type: SEQUENCE; Schema: webshop; Owner: postgres
--

CREATE SEQUENCE webshop.shoppingcart_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE webshop.shoppingcart_id_seq OWNER TO postgres;

--
-- TOC entry 2829 (class 0 OID 0)
-- Dependencies: 200
-- Name: shoppingcart_id_seq; Type: SEQUENCE OWNED BY; Schema: webshop; Owner: postgres
--

ALTER SEQUENCE webshop.shoppingcart_id_seq OWNED BY webshop.shoppingcart.id;


--
-- TOC entry 199 (class 1259 OID 16406)
-- Name: shoppingcart_product; Type: TABLE; Schema: webshop; Owner: postgres
--

CREATE TABLE webshop.shoppingcart_product (
    product_id integer NOT NULL,
    shoppingcart_id integer NOT NULL,
    quantity integer
);


ALTER TABLE webshop.shoppingcart_product OWNER TO postgres;

--
-- TOC entry 2689 (class 2604 OID 16424)
-- Name: order id; Type: DEFAULT; Schema: webshop; Owner: postgres
--

ALTER TABLE ONLY webshop."order" ALTER COLUMN id SET DEFAULT nextval('webshop.order_id_seq'::regclass);


--
-- TOC entry 2687 (class 2604 OID 16400)
-- Name: product id; Type: DEFAULT; Schema: webshop; Owner: postgres
--

ALTER TABLE ONLY webshop.product ALTER COLUMN id SET DEFAULT nextval('webshop.product_id_seq'::regclass);


--
-- TOC entry 2688 (class 2604 OID 16416)
-- Name: shoppingcart id; Type: DEFAULT; Schema: webshop; Owner: postgres
--

ALTER TABLE ONLY webshop.shoppingcart ALTER COLUMN id SET DEFAULT nextval('webshop.shoppingcart_id_seq'::regclass);


--
-- TOC entry 2697 (class 2606 OID 16429)
-- Name: order order_pkey; Type: CONSTRAINT; Schema: webshop; Owner: postgres
--

ALTER TABLE ONLY webshop."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (id);


--
-- TOC entry 2691 (class 2606 OID 16405)
-- Name: product product_pkey; Type: CONSTRAINT; Schema: webshop; Owner: postgres
--

ALTER TABLE ONLY webshop.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- TOC entry 2695 (class 2606 OID 16418)
-- Name: shoppingcart shoppingcart_pkey; Type: CONSTRAINT; Schema: webshop; Owner: postgres
--

ALTER TABLE ONLY webshop.shoppingcart
    ADD CONSTRAINT shoppingcart_pkey PRIMARY KEY (id);


--
-- TOC entry 2693 (class 2606 OID 16410)
-- Name: shoppingcart_product shoppingcart_product_pkey; Type: CONSTRAINT; Schema: webshop; Owner: postgres
--

ALTER TABLE ONLY webshop.shoppingcart_product
    ADD CONSTRAINT shoppingcart_product_pkey PRIMARY KEY (shoppingcart_id, product_id);


--
-- TOC entry 2698 (class 2606 OID 16430)
-- Name: shoppingcart_product product_id; Type: FK CONSTRAINT; Schema: webshop; Owner: postgres
--

ALTER TABLE ONLY webshop.shoppingcart_product
    ADD CONSTRAINT product_id FOREIGN KEY (product_id) REFERENCES webshop.product(id);


--
-- TOC entry 2699 (class 2606 OID 16435)
-- Name: shoppingcart_product shoppingcart_id; Type: FK CONSTRAINT; Schema: webshop; Owner: postgres
--

ALTER TABLE ONLY webshop.shoppingcart_product
    ADD CONSTRAINT shoppingcart_id FOREIGN KEY (shoppingcart_id) REFERENCES webshop.shoppingcart(id);


--
-- TOC entry 2700 (class 2606 OID 16440)
-- Name: order shoppingcart_id; Type: FK CONSTRAINT; Schema: webshop; Owner: postgres
--

ALTER TABLE ONLY webshop."order"
    ADD CONSTRAINT shoppingcart_id FOREIGN KEY (shoppingcart_id) REFERENCES webshop.shoppingcart(id);


-- Completed on 2018-03-27 16:44:44

--
-- PostgreSQL database dump complete
--

