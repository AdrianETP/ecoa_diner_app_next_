CREATE DATABASE IF NOT EXISTS  ecoa_diner;
USE ecoa_diner;

CREATE TABLE IF NOT EXISTS  Grupo
(
    CRN VARCHAR(5) NOT NULL,
    ClaveMateria VARCHAR(50) NOT NULL,
    PRIMARY KEY (CRN,ClaveMateria),
    FOREIGN KEY (ClaveMateria) REFERENCES UDF(ClaveMateria)
);

DESCRIBE Grupo;
