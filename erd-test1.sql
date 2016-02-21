CREATE SCHEMA erd_test;

SET search_path TO erd_test;

-- SET CONSTRAINTS ALL DEFERRED;

DROP TABLE IF EXISTS produkt;
CREATE TABLE produkt (
    id serial not null PRIMARY KEY,
    name text not null
);

DROP TABLE IF EXISTS posten;
CREATE TABLE posten (
    id serial not null unique primary key,
    b_id int not null references bestellung (id),
    p_id int not null references produkt (id),
    menge int not null CHECK (menge > 0)
);

COMMENT ON COLUMN posten.menge IS 'Muss größer 0 sein!';

DROP TABLE IF EXISTS bestellung;
CREATE TABLE bestellung (
    id serial not null unique primary key,
    k_id int not null references kunde (id),
    lieferadr_id int not null references adresse (id)
);

DROP TABLE IF EXISTS kunde;
CREATE TABLE kunde (
    id serial not null unique primary key,
    name text not null,
    rechnungsadr_id int not null references adresse (id)
);

DROP TABLE IF EXISTS adresse;
CREATE TABLE adresse (
    id serial not null primary key,
    anschrift text not null unique CHECK (length(anschrift) > 0)
);

COMMENT ON TABLE adresse IS 'Hier wohnen Leute...';
COMMENT ON COLUMN adresse.anschrift IS 'Freitext';

ALTER TABLE adresse ADD CHECK (length(anschrift) > 0);