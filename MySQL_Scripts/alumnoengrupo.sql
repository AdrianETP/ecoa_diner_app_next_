CREATE DATABASE IF NOT EXISTS  ecoa_diner;
USE ecoa_diner;

CREATE TABLE IF NOT EXISTS  AlumnoEnGrupo
(
    CRN 				VARCHAR(5) NOT NULL,
    Matricula 			VARCHAR(9) NOT NULL,
    ClaveMateria 		VARCHAR(50) NOT NULL,
    Periodo				VARCHAR(30) NOT NULL,
    PRIMARY KEY (CRN,Matricula,ClaveMateria),
    FOREIGN KEY (CRN) REFERENCES Grupo(CRN),
    FOREIGN KEY (Matricula) REFERENCES Alumno(Matricula),
    FOREIGN KEY (ClaveMateria) REFERENCES UDF(ClaveMateria)
);

DESCRIBE AlumnoEnGrupo;