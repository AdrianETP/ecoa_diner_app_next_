CREATE DATABASE IF NOT EXISTS  ecoa_diner;
USE ecoa_diner;

CREATE TABLE IF NOT EXISTS  EncuestasPreguntas
(
    ClaveEncuesta 		VARCHAR(5) NOT NULL,
    ClavePregunta 		VARCHAR(5) NOT NULL,
    PRIMARY KEY (ClaveEncuesta,ClavePregunta),
    FOREIGN KEY (ClaveEncuesta) REFERENCES Encuesta(ClaveEncuesta),
    FOREIGN KEY (ClavePregunta) REFERENCES Pregunta(ClavePregunta)
);

DESCRIBE EncuestasPreguntas;