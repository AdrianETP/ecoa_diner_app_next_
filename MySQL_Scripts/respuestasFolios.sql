CREATE DATABASE IF NOT EXISTS  ecoa_diner;
USE ecoa_diner;

CREATE TABLE IF NOT EXISTS  RespuestasFolios
(
    ClavePregunta	VARCHAR(5) NOT NULL,
    Folio    		INT NOT NULL,
    ClaveEncuesta   VARCHAR(5) NOT NULL,
    TipoResp		VARCHAR(20),
    Evaluacion		INT,
    Comentario		VARCHAR(100),
    PRIMARY KEY (ClavePregunta,FOLIO),
    FOREIGN KEY (ClavePregunta) REFERENCES Pregunta(ClavePregunta),
     FOREIGN KEY (ClaveEncuesta) REFERENCES Encuesta(ClaveEncuesta)
);

DESCRIBE RespuestasFolios;