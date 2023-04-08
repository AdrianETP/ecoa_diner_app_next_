CREATE DATABASE IF NOT EXISTS  ecoa_diner;
USE ecoa_diner;

CREATE TABLE IF NOT EXISTS  EncuestasAlumnos
(
    ClaveEncuesta 		VARCHAR(5) NOT NULL,
    Matricula 			VARCHAR(9) NOT NULL,
    Contestada			BOOL,
    PRIMARY KEY (ClaveEncuesta,Matricula),
    FOREIGN KEY (ClaveEncuesta) REFERENCES Encuesta(ClaveEncuesta),
    FOREIGN KEY (Matricula) REFERENCES Alumno(Matricula)
);

DESCRIBE EncuestasAlumnos;