CREATE DATABASE IF NOT EXISTS  ecoa_diner;
USE ecoa_diner;

CREATE TABLE IF NOT EXISTS  RespuestasAlumnos
(
    ClavePregunta	VARCHAR(5) NOT NULL,
    Matricula    	VARCHAR(9) NOT NULL,
    ClaveEncuesta   VARCHAR(5) NOT NULL,
    TipoResp		VARCHAR(20),
    Evaluacion		INT,
    Comentario		VARCHAR(100),
    PRIMARY KEY (ClavePregunta,Matricula),
    FOREIGN KEY (ClavePregunta) REFERENCES Pregunta(ClavePregunta),
    FOREIGN KEY (Matricula) REFERENCES Alumno(Matricula),
    FOREIGN KEY (ClaveEncuesta) REFERENCES Encuesta(ClaveEncuesta)
);

DESCRIBE RespuestasAlumnos;
