CREATE DATABASE IF NOT EXISTS  ecoa_diner;
USE ecoa_diner;

CREATE TABLE IF NOT EXISTS  Pregunta
(
    ClavePregunta	VARCHAR(5) NOT NULL,
    TipoPregunta    VARCHAR(5) NOT NULL,
    Pregunta        VARCHAR(5) NOT NULL,
    Descripcion    	VARCHAR(100),
    Archivado       BOOL,
    PRIMARY KEY (ClavePregunta)
);

DESCRIBE Pregunta;
