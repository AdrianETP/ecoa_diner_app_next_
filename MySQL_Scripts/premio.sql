CREATE DATABASE IF NOT EXISTS  ecoa_diner;
USE ecoa_diner;

CREATE TABLE IF NOT EXISTS  Premio
(
    ClavePremio			VARCHAR(5),
    EstrellasMichellin	INT NOT NULL,
    TipoPremio			VARCHAR(20),
    Descripcion			VARCHAR(100),
    PRIMARY KEY (ClavePremio)
);

DESCRIBE Premio;