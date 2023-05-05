#CREATE DATABASE IF NOT EXISTS  ecoa_diner;
USE ecoa_diner;

# Queries DDL
CREATE TABLE IF NOT EXISTS UDF(
    ClaveMateria 	VARCHAR(50) NOT NULL PRIMARY KEY,
    NombreMateria 	VARCHAR(200),
    TipoUDF 		VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS Campus
(
	ClaveCampus		VARCHAR(5) PRIMARY KEY,
    NombreCampus	VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS  Grupo
(
    CRN 			VARCHAR(10) NOT NULL,
    ClaveMateria 	VARCHAR(50) NOT NULL,
    ClaveEA       	VARCHAR(10) NOT NULL,
    ClaveCampus		VARCHAR(5),
    PRIMARY KEY (CRN,ClaveMateria,ClaveEA,ClaveCampus),
    FOREIGN KEY (ClaveMateria) REFERENCES UDF(ClaveMateria),
    FOREIGN KEY (ClaveCampus) REFERENCES Campus(ClaveCampus)
);

CREATE TABLE IF NOT EXISTS Profesor(
    Nomina 				VARCHAR(9) PRIMARY KEY NOT NULL,
    Nombre 				VARCHAR(50) NOT NULL,
    ApellidoPaterno 	VARCHAR(50),
    ApellidoMaterno		VARCHAR(50),
    ClaveCampus			VARCHAR(5),
    Departamento		VARCHAR(200),
    Clave 				VARCHAR(100),
    Correo 				VARCHAR(50),
    FOREIGN KEY (ClaveCampus) REFERENCES Campus(ClaveCampus)
);

CREATE TABLE IF NOT EXISTS Alumno(
    Matricula 			VARCHAR(9) PRIMARY KEY NOT NULL,
    Nombre 				VARCHAR(50) NOT NULL,
    ApellidoPaterno 	VARCHAR(50),
    ApellidoMaterno 	VARCHAR(50),
    ClaveCampus			VARCHAR(5),
    Clave 				VARCHAR(100),
    Correo 				VARCHAR(50),
    FOREIGN KEY (ClaveCampus) REFERENCES Campus(ClaveCampus)
);

CREATE TABLE IF NOT EXISTS  Premio
(
    ClavePremio			VARCHAR(5),
    EstrellasMichellin	INT NOT NULL,
    TipoPremio			VARCHAR(20),
    Descripcion			VARCHAR(100),
    PRIMARY KEY (ClavePremio)
);

CREATE TABLE IF NOT EXISTS  Pregunta
(
    ClavePregunta	VARCHAR(10) NOT NULL PRIMARY KEY,
    NumPregunta     VARCHAR(5) NOT NULL,
    TipoPregunta    VARCHAR(5) NOT NULL,
    Descripcion    	VARCHAR(100),
    Archivado       BOOL
);

CREATE TABLE IF NOT EXISTS  Encuesta
(
    ClaveEncuesta	VARCHAR(5) NOT NULL PRIMARY KEY,
	ClaveEA    		VARCHAR(10) NOT NULL,
    Descripcion  	VARCHAR(100),
    FechaIni        DATE NOT NULL,
    FechaLim		DATE NOT NULL,
    Archivado		BOOL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS  PremiosGanados
(
    NumReg			VARCHAR(5),
    Matricula		VARCHAR(9),
    ClavePremio		VARCHAR(5),
    FechaGanado		DATE,
    PRIMARY KEY (NumReg,Matricula,ClavePremio),
    FOREIGN KEY (Matricula) REFERENCES Alumno(Matricula),
    FOREIGN KEY (ClavePremio) REFERENCES Premio(ClavePremio)
);

CREATE TABLE IF NOT EXISTS  AlumnoEnGrupo
(
    CRN 			VARCHAR(10) NOT NULL,
    Matricula 		VARCHAR(9) NOT NULL,
    ClaveEA			VARCHAR(30) NOT NULL,
    ClaveCampus		VARCHAR(5),
    PRIMARY KEY (CRN,Matricula),
    FOREIGN KEY (CRN) REFERENCES Grupo(CRN),
    FOREIGN KEY (Matricula) REFERENCES Alumno(Matricula),
	FOREIGN KEY (ClaveCampus) REFERENCES Campus(ClaveCampus)
);

CREATE TABLE IF NOT EXISTS  ProfesorEnGrupo
(
    CRN 				VARCHAR(10) NOT NULL,
    Nomina 				VARCHAR(9) NOT NULL,
    ClaveEA				VARCHAR(30) NOT NULL,
    ClaveCampus			VARCHAR(5),
    Responsabilidad		INT,
    PRIMARY KEY (CRN,Nomina),
    FOREIGN KEY (CRN) REFERENCES Grupo(CRN),
    FOREIGN KEY (Nomina) REFERENCES Profesor(Nomina),
    FOREIGN KEY (ClaveCampus) REFERENCES Campus(ClaveCampus)
);

CREATE TABLE IF NOT EXISTS EncuestaGrupo
(
	ClaveEncuesta 	VARCHAR(5) NOT NULL,
    CRN 			VARCHAR(10) NOT NULL,
    ClaveMateria	VARCHAR(50) NOT NULL,
    ClaveEA			VARCHAR(10) NOT NULL,
    PRIMARY KEY(ClaveEncuesta,CRN),
    FOREIGN KEY (ClaveEncuesta) REFERENCES Encuesta(ClaveEncuesta),
    FOREIGN KEY (CRN) REFERENCES Grupo(CRN),
    FOREIGN KEY (ClaveMateria) REFERENCES UDF(ClaveMateria)
);

CREATE TABLE IF NOT EXISTS  EncuestaGrupoPregunta
(
    ClaveEncuesta 	VARCHAR(5) NOT NULL,
    CRN 			VARCHAR(10) NOT NULL,
    ClavePregunta 	VARCHAR(10) NOT NULL,
    PRIMARY KEY (ClaveEncuesta,ClavePregunta),
    FOREIGN KEY (ClaveEncuesta) REFERENCES Encuesta(ClaveEncuesta),
    FOREIGN KEY (CRN) REFERENCES Grupo(CRN),
    FOREIGN KEY (ClavePregunta) REFERENCES Pregunta(ClavePregunta)
);


CREATE TABLE IF NOT EXISTS  EncuestasAlumnos
(
    ClaveEncuesta 	VARCHAR(5) NOT NULL,
    Matricula 		VARCHAR(9) NOT NULL,
    Contestada		BOOL,
    PRIMARY KEY (ClaveEncuesta,Matricula),
    FOREIGN KEY (ClaveEncuesta) REFERENCES Encuesta(ClaveEncuesta),
    FOREIGN KEY (Matricula) REFERENCES Alumno(Matricula)
);

CREATE TABLE IF NOT EXISTS PreguntasProfesor
(
	ClaveEncuesta 	VARCHAR(5) NOT NULL,
    ClavePregunta 	VARCHAR(10) NOT NULL,
    CRN 			VARCHAR(10) NOT NULL,
    Nomina 			VARCHAR(9) NOT NULL,
    PRIMARY KEY(ClaveEncuesta,ClavePregunta,Nomina,CRN),
    FOREIGN KEY (ClaveEncuesta) REFERENCES Encuesta(ClaveEncuesta),
    FOREIGN KEY (ClavePregunta) REFERENCES Pregunta(ClavePregunta),
    FOREIGN KEY (CRN) REFERENCES Grupo(CRN),
    FOREIGN KEY (Nomina) REFERENCES Profesor(Nomina)
);

CREATE TABLE IF NOT EXISTS PreguntasAlumnos (
    ClaveEncuesta VARCHAR(5),
    CRN VARCHAR(10),
    ClavePregunta VARCHAR(10),
    Matricula VARCHAR(9),
    PRIMARY KEY (ClaveEncuesta, CRN, ClavePregunta, Matricula)
);

CREATE TABLE IF NOT EXISTS  RespuestasAlumnos
(
    ClaveRespuesta 	INT NOT NULL AUTO_INCREMENT,
    ClaveEncuesta   VARCHAR(5) NOT NULL,
    CRN 			VARCHAR(10) NOT NULL,
    Matricula    	VARCHAR(9) NOT NULL,
    ClavePregunta	VARCHAR(10) NOT NULL,
	TipoPregunta    VARCHAR(5) NOT NULL,
    Nomina			VARCHAR(9),
    TipoResp		VARCHAR(20),
    Evaluacion		INT,
    Comentario		VARCHAR(500),
    PRIMARY KEY (ClaveRespuesta),
    FOREIGN KEY (ClaveEncuesta) REFERENCES Encuesta(ClaveEncuesta),
    FOREIGN KEY (CRN) REFERENCES Grupo(CRN),
    FOREIGN KEY (Matricula) REFERENCES Alumno(Matricula),
    FOREIGN KEY (ClavePregunta) REFERENCES Pregunta(ClavePregunta),
    FOREIGN KEY (Nomina) REFERENCES Profesor(Nomina),
    CHECK ((TipoPregunta IN ('DOM', 'RET', 'ASE', 'MET', 'REC', 'CMT', 'COM') AND Nomina IS NOT NULL) OR (TipoPregunta IN ('APD', 'PLV','CEP') AND Nomina IS NULL))
);

CREATE TABLE IF NOT EXISTS  RespuestasFolios
(
    ClaveRespuesta 	INT NOT NULL AUTO_INCREMENT,
    ClaveEncuesta   VARCHAR(5) NOT NULL,
    CRN 			VARCHAR(10) NOT NULL,
	Folio    		INT NOT NULL,
    ClavePregunta	VARCHAR(10) NOT NULL,
	TipoPregunta    VARCHAR(5) NOT NULL,
    Nomina			VARCHAR(9),
    TipoResp		VARCHAR(20),
    Evaluacion		INT,
    Comentario		VARCHAR(500),
    PRIMARY KEY (ClaveRespuesta),
    FOREIGN KEY (ClaveEncuesta) REFERENCES Encuesta(ClaveEncuesta),
    FOREIGN KEY (CRN) REFERENCES Grupo(CRN),
    FOREIGN KEY (ClavePregunta) REFERENCES Pregunta(ClavePregunta),
    FOREIGN KEY (Nomina) REFERENCES Profesor(Nomina),
    CHECK ((TipoPregunta IN ('DOM', 'RET', 'ASE', 'MET', 'REC', 'CMT', 'COM') AND Nomina IS NOT NULL) OR (TipoPregunta IN ('APD', 'PLV','CEP') AND Nomina IS NULL))
);