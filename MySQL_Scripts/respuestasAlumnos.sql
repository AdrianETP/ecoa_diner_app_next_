CREATE DATABASE IF NOT EXISTS  ecoa_diner;
USE ecoa_diner;

CREATE TABLE IF NOT EXISTS  RespuestasAlumnos
(
    ClaveRespuesta 	INT NOT NULL AUTO_INCREMENT,
    ClavePregunta	VARCHAR(5) NOT NULL,
    Matricula    	VARCHAR(9) NOT NULL,
    ClaveEncuesta   VARCHAR(5) NOT NULL,
	TipoPregunta    VARCHAR(5) NOT NULL,
    Nomina			VARCHAR(9),
    TipoResp		VARCHAR(20),
    Evaluacion		INT,
    Comentario		VARCHAR(100),
    PRIMARY KEY (ClaveRespuesta),
    FOREIGN KEY (ClavePregunta) REFERENCES Pregunta(ClavePregunta),
    FOREIGN KEY (Matricula) REFERENCES Alumno(Matricula),
    FOREIGN KEY (ClaveEncuesta) REFERENCES Encuesta(ClaveEncuesta),
    FOREIGN KEY (Nomina) REFERENCES Profesor(Nomina),
    CHECK ((TipoPregunta = 'RET' AND Nomina IS NOT NULL) OR (TipoPregunta = 'REC' AND Nomina IS NULL))
);

DESCRIBE RespuestasAlumnos;