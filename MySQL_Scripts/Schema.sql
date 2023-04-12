CREATE DATABASE IF NOT EXISTS  ecoa_diner;
USE ecoa_diner;

CREATE TABLE IF NOT EXISTS UDF(
    ClaveMateria VARCHAR(50) NOT NULL PRIMARY KEY,
    Descripcion VARCHAR(50),
    TipoUDF VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS  Grupo
(
    CRN VARCHAR(5) NOT NULL,
    ClaveMateria VARCHAR(50) NOT NULL,
    PRIMARY KEY (CRN,ClaveMateria),
    FOREIGN KEY (ClaveMateria) REFERENCES UDF(ClaveMateria)
);

CREATE TABLE IF NOT EXISTS  Premio
(
    ClavePremio			VARCHAR(5),
    EstrellasMichellin	INT NOT NULL,
    TipoPremio			VARCHAR(20),
    Descripcion			VARCHAR(100),
    PRIMARY KEY (ClavePremio)
);

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

CREATE TABLE IF NOT EXISTS  Pregunta
(
    ClavePregunta	VARCHAR(5) NOT NULL,
    TipoPregunta    VARCHAR(5) NOT NULL,
    Pregunta        VARCHAR(5) NOT NULL,
    Descripcion    	VARCHAR(100),
    Archivado       BOOL,
    PRIMARY KEY (ClavePregunta)
);



CREATE TABLE IF NOT EXISTS Alumno(
    Matricula VARCHAR(9) PRIMARY KEY NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    ApellidoPaterno VARCHAR(50) NOT NULL,
    ApellidoMaterno VARCHAR(50) NOT NULL,
    Clave VARCHAR(100) NOT NULL,
    Correo VARCHAR(50) NOT NULL
);


CREATE TABLE IF NOT EXISTS Profesor(
    Nomina VARCHAR(9) PRIMARY KEY NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    ApellidoPaterno VARCHAR(50) NOT NULL,
    ApellidoMaterno VARCHAR(50) NOT NULL,
    Clave VARCHAR(100) NOT NULL,
    Correo VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS  ProfesorEnGrupo
(
    CRN 				VARCHAR(5) NOT NULL,
    Nomina 				VARCHAR(9) NOT NULL,
    ClaveMateria 		VARCHAR(50) NOT NULL,
    Periodo				VARCHAR(30) NOT NULL,
    Responsabilidad		INT NOT NULL,
    PRIMARY KEY (CRN,Nomina,ClaveMateria),
    FOREIGN KEY (CRN) REFERENCES Grupo(CRN),
    FOREIGN KEY (Nomina) REFERENCES Profesor(Nomina),
    FOREIGN KEY (ClaveMateria) REFERENCES UDF(ClaveMateria)
);


create table if not exists  alumnoengrupo
(
    crn 				varchar(5) not null,
    matricula 			varchar(9) not null,
    clavemateria 		varchar(50) not null,
    periodo				varchar(30) not null,
    primary key (crn,matricula,clavemateria),
    foreign key (crn) references grupo(crn),
    foreign key (matricula) references alumno(matricula),
    foreign key (clavemateria) references udf(clavemateria)
);


CREATE TABLE IF NOT EXISTS  EncuestasAlumnos
(
    ClaveEncuesta 		VARCHAR(5) NOT NULL,
    Matricula 			VARCHAR(9) NOT NULL,
    Contestada			BOOL,
    PRIMARY KEY (ClaveEncuesta,Matricula),
    FOREIGN KEY (ClaveEncuesta) REFERENCES Encuesta(ClaveEncuesta),
    FOREIGN KEY (Matricula) REFERENCES Alumno(Matricula)
);


CREATE TABLE IF NOT EXISTS  EncuestasPreguntas
(
    ClaveEncuesta 		VARCHAR(5) NOT NULL,
    ClavePregunta 		VARCHAR(5) NOT NULL,
    PRIMARY KEY (ClaveEncuesta,ClavePregunta),
    FOREIGN KEY (ClaveEncuesta) REFERENCES Encuesta(ClaveEncuesta),
    FOREIGN KEY (ClavePregunta) REFERENCES Pregunta(ClavePregunta)
);


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



CREATE TABLE IF NOT EXISTS  RespuestasFolios
(
    ClaveRespuesta 	INT NOT NULL AUTO_INCREMENT,
    ClavePregunta	VARCHAR(5) NOT NULL,
    Folio    		INT NOT NULL,
    ClaveEncuesta   VARCHAR(5) NOT NULL,
    TipoPregunta    VARCHAR(5) NOT NULL,
    Nomina			VARCHAR(9),
    TipoResp		VARCHAR(20),
    Evaluacion		INT,
    Comentario		VARCHAR(100),
    PRIMARY KEY (ClaveRespuesta),
    FOREIGN KEY (ClavePregunta) REFERENCES Pregunta(ClavePregunta),
    FOREIGN KEY (ClaveEncuesta) REFERENCES Encuesta(ClaveEncuesta),
    FOREIGN KEY (Nomina) REFERENCES Profesor(Nomina),
    CHECK ((TipoPregunta = 'RET' AND Nomina IS NOT NULL) OR (TipoPregunta = 'REC' AND Nomina IS NULL))
);

