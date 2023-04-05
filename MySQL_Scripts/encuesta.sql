CREATE DATABASE IF NOT EXISTS  ecoa_diner;
USE ecoa_diner;

CREATE TABLE IF NOT EXISTS  Encuesta
(
    ClaveEncuesta			VARCHAR(5) NOT NULL,
    CRN             		VARCHAR(5) NOT NULL,
	Periodo       			DATE NOT NULL,
    Descripcion       		VARCHAR(100),
    FechaIni          		DATE NOT NULL,
    FechaLim				DATE NOT NULL,
    PRIMARY KEY (ClaveEncuesta),
    FOREIGN KEY (CRN) references Grupo(CRN)
);

DESCRIBE Encuesta;