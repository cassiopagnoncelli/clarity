--CREATE DATABASE clarity;

\c clarity

/*
   Schema.
*/
CREATE TABLE meta (
  id INTEGER,

  code VARCHAR,
  quandl_code VARCHAR,
  title VARCHAR,
  description VARCHAR,
  series_type VARCHAR,
  frequency INTEGER
);

CREATE TABLE tick (
  id SERIAL PRIMARY KEY,

  meta_id INTEGER REFERENCES meta(id),
  dt DATETIME,

  value NUMERIC
);

CREATE TABLE ohlc (
  id SERIAL,

  meta_id INTEGER REFERENCES meta(id),
  dt DATETIME,

  open NUMERIC,
  high NUMERIC,
  low NUMERIC,
  close NUMERIC,
  volume NUMERIC,
  adj NUMERIC
);

/* Indexes. */
CREATE INDEX meta_code ON meta USING HASH(code);
CREATE INDEX tick_idx ON tick(meta_id, dt);
CREATE INDEX ohlc ON ohlc(meta_id, dt);

/*
   PL/pgSQL functions for handling series.
*/
CREATE EXTENSION plpgsqpl;

CREATE FUNCTION merge (
  a VARCHAR,
  b VARCHAR
) RETURNS TABLE ();

