PGDMP                         t            mdmdb    9.4.8    9.4.8 f    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            �           1262    122954    mdmdb    DATABASE     k   CREATE DATABASE mdmdb WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_IN' LC_CTYPE = 'en_IN';
    DROP DATABASE mdmdb;
             postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            �           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    6            �           0    0    public    ACL     �   REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;
                  postgres    false    6                        3079    11893    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            �           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1            �            1255    123081 V   addcompany(character varying, character varying, character varying, character varying)    FUNCTION       CREATE FUNCTION addcompany(company_name character varying, company_id character varying, login_id character varying, password character varying) RETURNS void
    LANGUAGE sql
    AS $_$ 
insert into company_table(compnay_name,compnay_id,login_id,password) values ($1,$2,$3,$4);
$_$;
 �   DROP FUNCTION public.addcompany(company_name character varying, company_id character varying, login_id character varying, password character varying);
       public       postgres    false    6            �            1255    123082 h   adddevice(character varying, character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION adddevice(company_id character varying, imei character varying, mac character varying, userid character varying, password character varying) RETURNS void
    LANGUAGE sql
    AS $_$
insert into device_master(imei,mac,company_id,provisionig_id) values ($2,$3,$1,1);
insert into user_table (userid,password,device_master_sn) values ($4,$5,(select sn from device_master where imei = $2));
$_$;
 �   DROP FUNCTION public.adddevice(company_id character varying, imei character varying, mac character varying, userid character varying, password character varying);
       public       postgres    false    6            �            1255    123085 6   adddevicetogroup(character varying, character varying)    FUNCTION     �   CREATE FUNCTION adddevicetogroup(groupid character varying, userid character varying) RETURNS void
    LANGUAGE sql
    AS $_$
insert into notification_table(groupid,userid) values ($1,$2);
$_$;
 \   DROP FUNCTION public.adddevicetogroup(groupid character varying, userid character varying);
       public       postgres    false    6            �            1255    123083 A   addgroup(character varying, character varying, character varying)    FUNCTION     �   CREATE FUNCTION addgroup(groupid character varying, group_name character varying, description character varying) RETURNS void
    LANGUAGE sql
    AS $_$
insert into group_master(groupid ,group_name,description) values($1,$2,$3);
$_$;
 w   DROP FUNCTION public.addgroup(groupid character varying, group_name character varying, description character varying);
       public       postgres    false    6            �            1255    123097 9   addmessage(character varying, character varying, integer)    FUNCTION     �   CREATE FUNCTION addmessage(message character varying, destinationid character varying, msgtype integer) RETURNS void
    LANGUAGE sql
    AS $_$
insert into message_table (message, destinationid, msgtype) values ($1,$2,$3);
$_$;
 n   DROP FUNCTION public.addmessage(message character varying, destinationid character varying, msgtype integer);
       public       postgres    false    6            �            1255    123098 !   getdestination(character varying)    FUNCTION     �   CREATE FUNCTION getdestination(loginid character varying) RETURNS SETOF character varying
    LANGUAGE sql
    AS $_$ 
select gcm_token as gcm_token from user_table where userid = $1;
$_$;
 @   DROP FUNCTION public.getdestination(loginid character varying);
       public       postgres    false    6            �            1255    123100 "   getgroupaddress(character varying)    FUNCTION     /  CREATE FUNCTION getgroupaddress(groupid character varying) RETURNS TABLE(gcm_token character varying)
    LANGUAGE sql
    AS $_$

  select gcm_token from user_table where userid in (select userid from notification_table where groupid = (select groupid from group_master where group_name = $1));
  $_$;
 A   DROP FUNCTION public.getgroupaddress(groupid character varying);
       public       postgres    false    6            �            1259    123015    application_table    TABLE     �   CREATE TABLE application_table (
    sn integer NOT NULL,
    app_name character varying(100) NOT NULL,
    package_name character varying(1000) NOT NULL,
    download_url character varying(100) NOT NULL
);
 %   DROP TABLE public.application_table;
       public         postgres    false    6            �            1259    123013    application_table_sn_seq    SEQUENCE     z   CREATE SEQUENCE application_table_sn_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.application_table_sn_seq;
       public       postgres    false    184    6            �           0    0    application_table_sn_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE application_table_sn_seq OWNED BY application_table.sn;
            public       postgres    false    183            �            1259    123063    company_table    TABLE     �   CREATE TABLE company_table (
    sn integer NOT NULL,
    compnay_name character varying(100) NOT NULL,
    compnay_id character varying(100) NOT NULL,
    login_id character varying(100) NOT NULL,
    password character varying(100) NOT NULL
);
 !   DROP TABLE public.company_table;
       public         postgres    false    6            �            1259    123061    company_table_sn_seq    SEQUENCE     v   CREATE SEQUENCE company_table_sn_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.company_table_sn_seq;
       public       postgres    false    192    6            �           0    0    company_table_sn_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE company_table_sn_seq OWNED BY company_table.sn;
            public       postgres    false    191            �            1259    123027    device_app_status    TABLE     �   CREATE TABLE device_app_status (
    sn integer NOT NULL,
    userid character varying(100) NOT NULL,
    installed_app json,
    "timestamp" timestamp without time zone DEFAULT now()
);
 %   DROP TABLE public.device_app_status;
       public         postgres    false    6            �            1259    123025    device_app_status_sn_seq    SEQUENCE     z   CREATE SEQUENCE device_app_status_sn_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.device_app_status_sn_seq;
       public       postgres    false    186    6            �           0    0    device_app_status_sn_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE device_app_status_sn_seq OWNED BY device_app_status.sn;
            public       postgres    false    185            �            1259    122957    device_master    TABLE       CREATE TABLE device_master (
    sn integer NOT NULL,
    imei character varying(100) NOT NULL,
    mac character varying(100) NOT NULL,
    provisionig_id integer NOT NULL,
    company_id character varying(100) DEFAULT 'star'::character varying NOT NULL
);
 !   DROP TABLE public.device_master;
       public         postgres    false    6            �            1259    122955    device_master_sn_seq    SEQUENCE     v   CREATE SEQUENCE device_master_sn_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.device_master_sn_seq;
       public       postgres    false    174    6            �           0    0    device_master_sn_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE device_master_sn_seq OWNED BY device_master.sn;
            public       postgres    false    173            �            1259    123002    device_status_table    TABLE     7  CREATE TABLE device_status_table (
    sn integer NOT NULL,
    userid character varying(100) NOT NULL,
    lock_status integer DEFAULT 0,
    memory_status integer DEFAULT 0,
    battery_status integer DEFAULT 0,
    proxy_status integer DEFAULT 0,
    "timestamp" timestamp without time zone DEFAULT now()
);
 '   DROP TABLE public.device_status_table;
       public         postgres    false    6            �            1259    123000    device_status_table_sn_seq    SEQUENCE     |   CREATE SEQUENCE device_status_table_sn_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.device_status_table_sn_seq;
       public       postgres    false    182    6            �           0    0    device_status_table_sn_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE device_status_table_sn_seq OWNED BY device_status_table.sn;
            public       postgres    false    181            �            1259    122979    group_master    TABLE     �   CREATE TABLE group_master (
    sn integer NOT NULL,
    groupid character varying(100) NOT NULL,
    group_name character varying(100) NOT NULL,
    description character varying(1000)
);
     DROP TABLE public.group_master;
       public         postgres    false    6            �            1259    122977    group_master_sn_seq    SEQUENCE     u   CREATE SEQUENCE group_master_sn_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.group_master_sn_seq;
       public       postgres    false    178    6            �           0    0    group_master_sn_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE group_master_sn_seq OWNED BY group_master.sn;
            public       postgres    false    177            �            1259    123088    message_table    TABLE     �   CREATE TABLE message_table (
    sn integer NOT NULL,
    message character varying(1000),
    destinationid character varying(1000),
    msgtype integer
);
 !   DROP TABLE public.message_table;
       public         postgres    false    6            �            1259    123086    message_table_sn_seq    SEQUENCE     v   CREATE SEQUENCE message_table_sn_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.message_table_sn_seq;
       public       postgres    false    194    6            �           0    0    message_table_sn_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE message_table_sn_seq OWNED BY message_table.sn;
            public       postgres    false    193            �            1259    122992    notification_table    TABLE     �   CREATE TABLE notification_table (
    sn integer NOT NULL,
    groupid character varying(100) NOT NULL,
    userid character varying(100) NOT NULL,
    "timestamp" timestamp without time zone NOT NULL
);
 &   DROP TABLE public.notification_table;
       public         postgres    false    6            �            1259    122990    notification_table_sn_seq    SEQUENCE     {   CREATE SEQUENCE notification_table_sn_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.notification_table_sn_seq;
       public       postgres    false    6    180            �           0    0    notification_table_sn_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE notification_table_sn_seq OWNED BY notification_table.sn;
            public       postgres    false    179            �            1259    123050    provisioning_table    TABLE     �   CREATE TABLE provisioning_table (
    sn integer NOT NULL,
    id character varying(100) NOT NULL,
    authentication_url character varying(100) NOT NULL,
    notification_url character varying(100)
);
 &   DROP TABLE public.provisioning_table;
       public         postgres    false    6            �            1259    123048    provisioning_table_sn_seq    SEQUENCE     {   CREATE SEQUENCE provisioning_table_sn_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.provisioning_table_sn_seq;
       public       postgres    false    190    6            �           0    0    provisioning_table_sn_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE provisioning_table_sn_seq OWNED BY provisioning_table.sn;
            public       postgres    false    189            �            1259    123039    proxy_table    TABLE     �   CREATE TABLE proxy_table (
    sn integer NOT NULL,
    userid character varying(100) NOT NULL,
    blacklist json,
    whitelist json,
    proxy_url character varying(100)
);
    DROP TABLE public.proxy_table;
       public         postgres    false    6            �            1259    123037    proxy_table_sn_seq    SEQUENCE     t   CREATE SEQUENCE proxy_table_sn_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.proxy_table_sn_seq;
       public       postgres    false    6    188            �           0    0    proxy_table_sn_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE proxy_table_sn_seq OWNED BY proxy_table.sn;
            public       postgres    false    187            �            1259    122967 
   user_table    TABLE     �   CREATE TABLE user_table (
    sn integer NOT NULL,
    userid character varying(100) NOT NULL,
    password character varying(100) NOT NULL,
    gcm_token character varying(1000),
    device_master_sn integer NOT NULL
);
    DROP TABLE public.user_table;
       public         postgres    false    6            �            1259    122965    user_table_sn_seq    SEQUENCE     s   CREATE SEQUENCE user_table_sn_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.user_table_sn_seq;
       public       postgres    false    6    176            �           0    0    user_table_sn_seq    SEQUENCE OWNED BY     9   ALTER SEQUENCE user_table_sn_seq OWNED BY user_table.sn;
            public       postgres    false    175            �           2604    123018    sn    DEFAULT     n   ALTER TABLE ONLY application_table ALTER COLUMN sn SET DEFAULT nextval('application_table_sn_seq'::regclass);
 C   ALTER TABLE public.application_table ALTER COLUMN sn DROP DEFAULT;
       public       postgres    false    183    184    184            �           2604    123066    sn    DEFAULT     f   ALTER TABLE ONLY company_table ALTER COLUMN sn SET DEFAULT nextval('company_table_sn_seq'::regclass);
 ?   ALTER TABLE public.company_table ALTER COLUMN sn DROP DEFAULT;
       public       postgres    false    192    191    192            �           2604    123030    sn    DEFAULT     n   ALTER TABLE ONLY device_app_status ALTER COLUMN sn SET DEFAULT nextval('device_app_status_sn_seq'::regclass);
 C   ALTER TABLE public.device_app_status ALTER COLUMN sn DROP DEFAULT;
       public       postgres    false    186    185    186            �           2604    122960    sn    DEFAULT     f   ALTER TABLE ONLY device_master ALTER COLUMN sn SET DEFAULT nextval('device_master_sn_seq'::regclass);
 ?   ALTER TABLE public.device_master ALTER COLUMN sn DROP DEFAULT;
       public       postgres    false    173    174    174            �           2604    123005    sn    DEFAULT     r   ALTER TABLE ONLY device_status_table ALTER COLUMN sn SET DEFAULT nextval('device_status_table_sn_seq'::regclass);
 E   ALTER TABLE public.device_status_table ALTER COLUMN sn DROP DEFAULT;
       public       postgres    false    182    181    182            �           2604    122982    sn    DEFAULT     d   ALTER TABLE ONLY group_master ALTER COLUMN sn SET DEFAULT nextval('group_master_sn_seq'::regclass);
 >   ALTER TABLE public.group_master ALTER COLUMN sn DROP DEFAULT;
       public       postgres    false    178    177    178            �           2604    123091    sn    DEFAULT     f   ALTER TABLE ONLY message_table ALTER COLUMN sn SET DEFAULT nextval('message_table_sn_seq'::regclass);
 ?   ALTER TABLE public.message_table ALTER COLUMN sn DROP DEFAULT;
       public       postgres    false    194    193    194            �           2604    122995    sn    DEFAULT     p   ALTER TABLE ONLY notification_table ALTER COLUMN sn SET DEFAULT nextval('notification_table_sn_seq'::regclass);
 D   ALTER TABLE public.notification_table ALTER COLUMN sn DROP DEFAULT;
       public       postgres    false    180    179    180            �           2604    123053    sn    DEFAULT     p   ALTER TABLE ONLY provisioning_table ALTER COLUMN sn SET DEFAULT nextval('provisioning_table_sn_seq'::regclass);
 D   ALTER TABLE public.provisioning_table ALTER COLUMN sn DROP DEFAULT;
       public       postgres    false    189    190    190            �           2604    123042    sn    DEFAULT     b   ALTER TABLE ONLY proxy_table ALTER COLUMN sn SET DEFAULT nextval('proxy_table_sn_seq'::regclass);
 =   ALTER TABLE public.proxy_table ALTER COLUMN sn DROP DEFAULT;
       public       postgres    false    188    187    188            �           2604    122970    sn    DEFAULT     `   ALTER TABLE ONLY user_table ALTER COLUMN sn SET DEFAULT nextval('user_table_sn_seq'::regclass);
 <   ALTER TABLE public.user_table ALTER COLUMN sn DROP DEFAULT;
       public       postgres    false    176    175    176            s          0    123015    application_table 
   TABLE DATA               N   COPY application_table (sn, app_name, package_name, download_url) FROM stdin;
    public       postgres    false    184   �w       �           0    0    application_table_sn_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('application_table_sn_seq', 1, false);
            public       postgres    false    183            {          0    123063    company_table 
   TABLE DATA               R   COPY company_table (sn, compnay_name, compnay_id, login_id, password) FROM stdin;
    public       postgres    false    192   �w       �           0    0    company_table_sn_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('company_table_sn_seq', 1, false);
            public       postgres    false    191            u          0    123027    device_app_status 
   TABLE DATA               L   COPY device_app_status (sn, userid, installed_app, "timestamp") FROM stdin;
    public       postgres    false    186   x       �           0    0    device_app_status_sn_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('device_app_status_sn_seq', 1, false);
            public       postgres    false    185            i          0    122957    device_master 
   TABLE DATA               K   COPY device_master (sn, imei, mac, provisionig_id, company_id) FROM stdin;
    public       postgres    false    174   +x       �           0    0    device_master_sn_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('device_master_sn_seq', 1, true);
            public       postgres    false    173            q          0    123002    device_status_table 
   TABLE DATA               y   COPY device_status_table (sn, userid, lock_status, memory_status, battery_status, proxy_status, "timestamp") FROM stdin;
    public       postgres    false    182   Zx       �           0    0    device_status_table_sn_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('device_status_table_sn_seq', 1, false);
            public       postgres    false    181            m          0    122979    group_master 
   TABLE DATA               E   COPY group_master (sn, groupid, group_name, description) FROM stdin;
    public       postgres    false    178   wx       �           0    0    group_master_sn_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('group_master_sn_seq', 1, false);
            public       postgres    false    177            }          0    123088    message_table 
   TABLE DATA               E   COPY message_table (sn, message, destinationid, msgtype) FROM stdin;
    public       postgres    false    194   �x       �           0    0    message_table_sn_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('message_table_sn_seq', 1, false);
            public       postgres    false    193            o          0    122992    notification_table 
   TABLE DATA               G   COPY notification_table (sn, groupid, userid, "timestamp") FROM stdin;
    public       postgres    false    180   �x       �           0    0    notification_table_sn_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('notification_table_sn_seq', 1, false);
            public       postgres    false    179            y          0    123050    provisioning_table 
   TABLE DATA               S   COPY provisioning_table (sn, id, authentication_url, notification_url) FROM stdin;
    public       postgres    false    190   �x       �           0    0    provisioning_table_sn_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('provisioning_table_sn_seq', 1, true);
            public       postgres    false    189            w          0    123039    proxy_table 
   TABLE DATA               K   COPY proxy_table (sn, userid, blacklist, whitelist, proxy_url) FROM stdin;
    public       postgres    false    188   -y       �           0    0    proxy_table_sn_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('proxy_table_sn_seq', 1, false);
            public       postgres    false    187            k          0    122967 
   user_table 
   TABLE DATA               P   COPY user_table (sn, userid, password, gcm_token, device_master_sn) FROM stdin;
    public       postgres    false    176   Jy       �           0    0    user_table_sn_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('user_table_sn_seq', 1, false);
            public       postgres    false    175            �           2606    123023    application_table_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY application_table
    ADD CONSTRAINT application_table_pkey PRIMARY KEY (sn);
 R   ALTER TABLE ONLY public.application_table DROP CONSTRAINT application_table_pkey;
       public         postgres    false    184    184            �           2606    123070    company_table_compnay_id_key 
   CONSTRAINT     d   ALTER TABLE ONLY company_table
    ADD CONSTRAINT company_table_compnay_id_key UNIQUE (compnay_id);
 T   ALTER TABLE ONLY public.company_table DROP CONSTRAINT company_table_compnay_id_key;
       public         postgres    false    192    192            �           2606    123072    company_table_login_id_key 
   CONSTRAINT     `   ALTER TABLE ONLY company_table
    ADD CONSTRAINT company_table_login_id_key UNIQUE (login_id);
 R   ALTER TABLE ONLY public.company_table DROP CONSTRAINT company_table_login_id_key;
       public         postgres    false    192    192            �           2606    123068    company_table_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY company_table
    ADD CONSTRAINT company_table_pkey PRIMARY KEY (sn);
 J   ALTER TABLE ONLY public.company_table DROP CONSTRAINT company_table_pkey;
       public         postgres    false    192    192            �           2606    123036    device_app_status_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY device_app_status
    ADD CONSTRAINT device_app_status_pkey PRIMARY KEY (sn);
 R   ALTER TABLE ONLY public.device_app_status DROP CONSTRAINT device_app_status_pkey;
       public         postgres    false    186    186            �           2606    122962    device_master_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY device_master
    ADD CONSTRAINT device_master_pkey PRIMARY KEY (sn);
 J   ALTER TABLE ONLY public.device_master DROP CONSTRAINT device_master_pkey;
       public         postgres    false    174    174            �           2606    123012    device_status_table_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY device_status_table
    ADD CONSTRAINT device_status_table_pkey PRIMARY KEY (sn);
 V   ALTER TABLE ONLY public.device_status_table DROP CONSTRAINT device_status_table_pkey;
       public         postgres    false    182    182            �           2606    122987    group_master_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY group_master
    ADD CONSTRAINT group_master_pkey PRIMARY KEY (sn);
 H   ALTER TABLE ONLY public.group_master DROP CONSTRAINT group_master_pkey;
       public         postgres    false    178    178            �           2606    123096    message_table_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY message_table
    ADD CONSTRAINT message_table_pkey PRIMARY KEY (sn);
 J   ALTER TABLE ONLY public.message_table DROP CONSTRAINT message_table_pkey;
       public         postgres    false    194    194            �           2606    122997    notification_table_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY notification_table
    ADD CONSTRAINT notification_table_pkey PRIMARY KEY (sn);
 T   ALTER TABLE ONLY public.notification_table DROP CONSTRAINT notification_table_pkey;
       public         postgres    false    180    180            �           2606    122999 %   notification_table_userid_groupid_key 
   CONSTRAINT     w   ALTER TABLE ONLY notification_table
    ADD CONSTRAINT notification_table_userid_groupid_key UNIQUE (userid, groupid);
 b   ALTER TABLE ONLY public.notification_table DROP CONSTRAINT notification_table_userid_groupid_key;
       public         postgres    false    180    180    180            �           2606    123055    provisioning_table_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY provisioning_table
    ADD CONSTRAINT provisioning_table_pkey PRIMARY KEY (sn);
 T   ALTER TABLE ONLY public.provisioning_table DROP CONSTRAINT provisioning_table_pkey;
       public         postgres    false    190    190            �           2606    123047    proxy_table_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY proxy_table
    ADD CONSTRAINT proxy_table_pkey PRIMARY KEY (sn);
 F   ALTER TABLE ONLY public.proxy_table DROP CONSTRAINT proxy_table_pkey;
       public         postgres    false    188    188            �           2606    122975    user_table_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY user_table
    ADD CONSTRAINT user_table_pkey PRIMARY KEY (sn);
 D   ALTER TABLE ONLY public.user_table DROP CONSTRAINT user_table_pkey;
       public         postgres    false    176    176            �           1259    123024 %   application_table_package_name_uindex    INDEX     k   CREATE UNIQUE INDEX application_table_package_name_uindex ON application_table USING btree (package_name);
 9   DROP INDEX public.application_table_package_name_uindex;
       public         postgres    false    184            �           1259    122963    device_master_IMEI_uindex    INDEX     U   CREATE UNIQUE INDEX "device_master_IMEI_uindex" ON device_master USING btree (imei);
 /   DROP INDEX public."device_master_IMEI_uindex";
       public         postgres    false    174            �           1259    122964    device_master_MAC_uindex    INDEX     S   CREATE UNIQUE INDEX "device_master_MAC_uindex" ON device_master USING btree (mac);
 .   DROP INDEX public."device_master_MAC_uindex";
       public         postgres    false    174            �           1259    122989    group_master_group_name_uindex    INDEX     ]   CREATE UNIQUE INDEX group_master_group_name_uindex ON group_master USING btree (group_name);
 2   DROP INDEX public.group_master_group_name_uindex;
       public         postgres    false    178            �           1259    122988    group_master_groupid_uindex    INDEX     W   CREATE UNIQUE INDEX group_master_groupid_uindex ON group_master USING btree (groupid);
 /   DROP INDEX public.group_master_groupid_uindex;
       public         postgres    false    178            �           1259    123056    provisioning_table_id_uindex    INDEX     Y   CREATE UNIQUE INDEX provisioning_table_id_uindex ON provisioning_table USING btree (id);
 0   DROP INDEX public.provisioning_table_id_uindex;
       public         postgres    false    190            �           1259    122976    user_table_userid_uindex    INDEX     Q   CREATE UNIQUE INDEX user_table_userid_uindex ON user_table USING btree (userid);
 ,   DROP INDEX public.user_table_userid_uindex;
       public         postgres    false    176            s      x������ � �      {      x������ � �      u      x������ � �      i      x�3�44B@ �
qr�$q��qqq �:�      q      x������ � �      m      x������ � �      }      x������ � �      o      x������ � �      y   O   x�3�4��())���OM6�55�57�522�525�K,�-�/-�HM,.�5�K��-(-I�K�M���K,/�P��+F��� ��)H      w      x������ � �      k      x������ � �     