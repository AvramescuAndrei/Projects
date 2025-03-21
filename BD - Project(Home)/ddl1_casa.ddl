-- Generated by Oracle SQL Developer Data Modeler 24.3.0.240.1210
--   at:        2025-01-04 13:16:48 EET
--   site:      Oracle Database 11g
--   type:      Oracle Database 11g



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE animale (
    id_animale      NUMBER(4) NOT NULL,
    tip_animale     VARCHAR2(5) NOT NULL,
    livrare_animale CHAR(1) NOT NULL,
    numar_animale   NUMBER(2) NOT NULL,
    pui             NUMBER(1) NOT NULL,
    pret_animale    NUMBER(4) NOT NULL
);

ALTER TABLE animale
    ADD CONSTRAINT animale_tip_animale_ck
        CHECK ( tip_animale IN ( 'porci', 'gaini', 'cai', 'oi', 'vaci' ) );

ALTER TABLE animale
    ADD CONSTRAINT animale_livrare_animale_ck CHECK ( livrare_animale IN ( 'R', 'L' ) );

ALTER TABLE animale
    ADD CONSTRAINT animale_pui_ck CHECK ( pui IN ( 1, 0 ) );

ALTER TABLE animale ADD CONSTRAINT animale_pk PRIMARY KEY ( id_animale );

CREATE TABLE autovehicule (
    id_autovehicule  NUMBER(4) NOT NULL,
    tip_auto         VARCHAR2(8) NOT NULL,
    livrare_auto     CHAR(1) NOT NULL,
    asigurare        CHAR(2) NOT NULL,
    culoare_int      VARCHAR2(8),
    culoare_ext      VARCHAR2(8),
    navigatie        CHAR(2),
    pret_autovehicul NUMBER(6) NOT NULL
);

ALTER TABLE autovehicule
    ADD CONSTRAINT autovehicule_tip_auto_ck
        CHECK ( tip_auto IN ( 'tractor', 'buldozer', 'combina' ) );

ALTER TABLE autovehicule
    ADD CONSTRAINT autovehicule_livrare_auto_ck CHECK ( livrare_auto IN ( 'L', 'R' ) );

ALTER TABLE autovehicule
    ADD CONSTRAINT autovehicule_asigurare_ck CHECK ( asigurare IN ( 'DA', 'NU' ) );

ALTER TABLE autovehicule
    ADD CONSTRAINT autovehicule_culoare_int_ck
        CHECK ( culoare_int IN ( 'rosu', 'albastru', 'verde' ) );

ALTER TABLE autovehicule
    ADD CONSTRAINT autovehicule_culoare_ext_ck
        CHECK ( culoare_ext IN ( 'albastru', 'rosu', 'verde' ) );

ALTER TABLE autovehicule
    ADD CONSTRAINT autovehicule_navigatie_ck CHECK ( navigatie IN ( 'RO', 'EN' ) );

ALTER TABLE autovehicule ADD CONSTRAINT autovehicule_pk PRIMARY KEY ( id_autovehicule );

CREATE TABLE clienti (
    id_clienti       NUMBER(3) NOT NULL,
    nume             VARCHAR2(12) NOT NULL,
    prenume          VARCHAR2(12) NOT NULL,
    oras             VARCHAR2(9) NOT NULL,
    strada           VARCHAR2(10) NOT NULL,
    numar_de_telefon CHAR(10) NOT NULL
);

ALTER TABLE clienti
    ADD CONSTRAINT clienti_numar_de_telefon_ck CHECK ( length(numar_de_telefon) = 10 );

ALTER TABLE clienti ADD CONSTRAINT clienti_pk PRIMARY KEY ( id_clienti );

ALTER TABLE clienti ADD CONSTRAINT clienti_numar_de_telefon_un UNIQUE ( numar_de_telefon );

CREATE TABLE comenzi (
    id_comenzi      NUMBER(4) NOT NULL,
    metoda_plata    CHAR(4) NOT NULL,
    nr_autovehicule NUMBER(3),
    nr_seminte      NUMBER(6),
    nr_animale      NUMBER(5),
    id_clienti      NUMBER(3) NOT NULL,
    id_autovehicule NUMBER(4),
    id_seminte      NUMBER(4),
    id_animale      NUMBER(4)
);

ALTER TABLE comenzi
    ADD CONSTRAINT comenzi_metoda_plata_ck CHECK ( metoda_plata IN ( 'CASH', 'CARD' ) );

ALTER TABLE comenzi ADD CONSTRAINT comenzi_pk PRIMARY KEY ( id_comenzi );

CREATE TABLE detalii_clienti (
    varsta     NUMBER(2) NOT NULL,
    cod_postal CHAR(6),
    id_clienti NUMBER(3) NOT NULL
);

ALTER TABLE detalii_clienti
    ADD CONSTRAINT detalii_clienti_varsta_ck CHECK ( varsta BETWEEN 18 AND 99 );


ALTER TABLE detalii_clienti
    ADD CONSTRAINT detalii_clienti_cod_postal_ck CHECK ( length(cod_postal) = 6 );

CREATE UNIQUE INDEX detalii_clienti__idx ON
    detalii_clienti (
        id_clienti
    ASC );

CREATE TABLE seminte (
    id_seminte      NUMBER(4) NOT NULL,
    tip_seminte     VARCHAR2(10) NOT NULL,
    livrare_seminte CHAR(1) NOT NULL,
    cantitatea      NUMBER(2) NOT NULL,
    anotimp         CHAR(1) NOT NULL,
    sol             VARCHAR2(9) NOT NULL,
    pret_seminte    NUMBER(4) NOT NULL
);

ALTER TABLE seminte
    ADD CONSTRAINT seminte_tip_seminte_ck
        CHECK ( tip_seminte IN ( 'rosii', 'morcovi', 'castraveti', 'ardei' ) );

ALTER TABLE seminte
    ADD CONSTRAINT seminte_livrare_seminte_ck CHECK ( livrare_seminte IN ( 'R', 'L' ) );

ALTER TABLE seminte
    ADD CONSTRAINT seminte_anotimp_ck
        CHECK ( anotimp IN ( 'V', 'T', 'I', 'P' ) );

ALTER TABLE seminte
    ADD CONSTRAINT seminte_sol_ck
        CHECK ( sol IN ( 'lutoase', 'negre', 'aluviale', 'vulcanice', 'argiloase' ) );

ALTER TABLE seminte ADD CONSTRAINT seminte_pk PRIMARY KEY ( id_seminte );

ALTER TABLE comenzi
    ADD CONSTRAINT comenzi_animale_fk FOREIGN KEY ( id_animale )
        REFERENCES animale ( id_animale );

ALTER TABLE comenzi
    ADD CONSTRAINT comenzi_autovehicule_fk FOREIGN KEY ( id_autovehicule )
        REFERENCES autovehicule ( id_autovehicule );

ALTER TABLE comenzi
    ADD CONSTRAINT comenzi_clienti_fk FOREIGN KEY ( id_clienti )
        REFERENCES clienti ( id_clienti );

ALTER TABLE comenzi
    ADD CONSTRAINT comenzi_seminte_fk FOREIGN KEY ( id_seminte )
        REFERENCES seminte ( id_seminte );

ALTER TABLE detalii_clienti
    ADD CONSTRAINT detalii_clienti_clienti_fk FOREIGN KEY ( id_clienti )
        REFERENCES clienti ( id_clienti );

CREATE SEQUENCE id_animale_inc START WITH 5000 MINVALUE 5000 MAXVALUE 6999 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER animale_id_animale_trg BEFORE
    INSERT ON animale
    FOR EACH ROW
    WHEN ( new.id_animale IS NULL )
BEGIN
    :new.id_animale := id_animale_inc.nextval;
END;
/

CREATE SEQUENCE id_autovehicule_inc START WITH 1000 MINVALUE 1000 MAXVALUE 2999 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER autovehicule_id_autovehicule BEFORE
    INSERT ON autovehicule
    FOR EACH ROW
    WHEN ( new.id_autovehicule IS NULL )
BEGIN
    :new.id_autovehicule := id_autovehicule_inc.nextval;
END;
/

CREATE SEQUENCE id_clienti_inc START WITH 111 MINVALUE 111 MAXVALUE 9999 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER clienti_id_clienti_trg BEFORE
    INSERT ON clienti
    FOR EACH ROW
    WHEN ( new.id_clienti IS NULL )
BEGIN
    :new.id_clienti := id_clienti_inc.nextval;
END;
/

CREATE SEQUENCE id_comenzi_inc START WITH 7000 MINVALUE 7000 MAXVALUE 9999 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER comenzi_id_comenzi_trg BEFORE
    INSERT ON comenzi
    FOR EACH ROW
    WHEN ( new.id_comenzi IS NULL )
BEGIN
    :new.id_comenzi := id_comenzi_inc.nextval;
END;
/

CREATE SEQUENCE id_seminte_inc START WITH 5000 MINVALUE 3000 MAXVALUE 4999 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER seminte_id_seminte_trg BEFORE
    INSERT ON seminte
    FOR EACH ROW
    WHEN ( new.id_seminte IS NULL )
BEGIN
    :new.id_seminte := id_seminte_inc.nextval;
END;
/



-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                             6
-- CREATE INDEX                             1
-- ALTER TABLE                             28
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           5
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          5
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
