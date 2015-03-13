DROP DATABASE IF EXISTS timeseries;

CREATE DATABASE timeseries;

\c timeseries

CREATE TABLE ohlc (
  id SERIAL PRIMARY KEY,
  instrument VARCHAR(16) NOT NULL,
  epoch DATE,
  open FLOAT,
  high FLOAT,
  low FLOAT,
  close FLOAT,
  adjusted_close FLOAT,
  volume FLOAT
);

CREATE INDEX instrument_idx ON ohlc(instrument);
CREATE INDEX date_idx ON ohlc(epoch);

CREATE TABLE ohlc_info (
  id SERIAL PRIMARY KEY,
  instrument VARCHAR(16) NOT NULL,
  timeframe VARCHAR(8) NOT NULL
);
