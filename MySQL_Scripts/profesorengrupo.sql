CREATE DATABASE IF NOT EXISTS  ecoa_diner;
USE ecoa_diner;

CREATE TABLE IF NOT EXISTS  ProfesorEnGrupo
(
    CRN 				VARCHAR(5) NOT NULL,
    Nomina 				VARCHAR(9) NOT NULL,
    ClaveMateria 		VARCHAR(50) NOT NULL,
    Periodo				VARCHAR(10) NOT NULL,
    Responsabilidad		INT NOT NULL,
    PRIMARY KEY (CRN,Nomina,ClaveMateria),
    FOREIGN KEY (CRN) REFERENCES Grupo(CRN),
    FOREIGN KEY (Nomina) REFERENCES Profesor(Nomina),
    FOREIGN KEY (ClaveMateria) REFERENCES UDF(ClaveMateria)
);

DESCRIBE ProfesorEnGrupo;