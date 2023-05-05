# Informacion de la base de datos
SHOW VARIABLES LIKE 'character_set_database'; -- Encoding de la base de datos
SHOW PROCEDURE STATUS WHERE Db = "ecoa_diner"; -- Procedures en la base de datos
SHOW TRIGGERS; -- Triggers en la base de datos
SHOW EVENTS; -- Events en la base datos

# Asignar base de datos a usar
Use ecoa_diner; -- Base de datos a usar

# Asignar variables a usar
SET @TiposPreguntaProfesor = 'DOM,RET,ASE,MET,REC,CMT,COM,DEMO';
SET @TiposPreguntaUDF = 'APD,PLV,CEP,DEMOU';

SET @TiposPreguntaProfesor = CONCAT(@TiposPreguntaProfesor,',',@NewValue);
SET @TiposPreguntaUDF = CONCAT(@TiposPreguntaUDF,',',@NewValue);
ALTER TABLE RespuestasAlumnos
DROP CONSTRAINT respuestasalumnos_chk_1;
SELECT check_TipoPregunta('DOM',NULL);
ALTER TABLE RespuestasAlumnos
ADD CONSTRAINT respuestasalumnos_chk_1 CHECK (check_TipoPregunta(TipoPregunta, Nomina));

#######				 Queries DML				#######
SELECT * FROM Campus; -- Muestra todos los campuses
SELECT * FROM Campus WHERE NombreCampus = "Campus Monterrey"; -- Muestra un campus en especifico
SELECT COUNT(*) FROM Campus; -- Cuantos Campuses hay

SELECT * FROM UDF; -- Muestra todas las UDFs
SELECT * FROM UDF WHERE ClaveMateria = "DS3002B"; -- Muestra una UDF en especifico
SELECT * FROM UDF LIMIT 10; -- Muestra las 10 primeras UDFs
SELECT COUNT(*) FROM UDF; -- Cuantos UDFs hay

SELECT * FROM Premio; -- Muestra todos los premios
SELECT * FROM Premio WHERE ClavePremio LIKE "BOOK%"; -- Muestra los premios por una categoria en especifico
SELECT * FROM Premio LIMIT 10; -- Muestra los 10 primeros premios
SELECT COUNT(*) FROM Premio; -- Cuantos Premios hay

SELECT * FROM Colaborador; -- Muestra todos los colaboradores
SELECT * FROM Colaborador WHERE IdColaborador = 'A018379'; -- Muestra un colaborador en especifico
SELECT * FROM Colaborador LIMIT 10; -- Muestra los primeros 10 colaboradores
SELECT COUNT(*) FROM Colaborador; -- Cuantos colaboradores hay

SELECT * FROM Grupo; -- Muestra todos los grupos
SELECT * FROM Grupo WHERE CRN = "39837"; -- Muestra un grupo en especifico
SELECT * FROM Grupo LIMIT 10; -- Muestra los 10 primeros grupos
SELECT COUNT(*) FROM Grupo; -- Cuantos Grupos hay

SELECT * FROM Alumno; -- Muestra todos los alumnos
SELECT * FROM Alumno WHERE Matricula = 'A00226903'; -- Muestra un alumno en especifico
SELECT * FROM Alumno LIMIT 10; -- Muestra los primeros 10 alumnos
SELECT COUNT(*) FROM Alumno; -- Cuantos Alumnos unicos hay

SELECT * FROM Profesor; -- Muestra todos los profesores
SELECT * FROM Profesor WHERE Nomina = 'L00621404'; -- Muestra un profesor en especifico
SELECT * FROM Profesor LIMIT 10; -- Muestra los primeros 10 profesores
SELECT COUNT(*) FROM Profesor; -- Cuantos Profesores unicos hay

SELECT * FROM Encuesta; -- Muestra todas las encuestas en la base de datos
SELECT * FROM Encuesta WHERE Archivado = FALSE OR Archivado IS NULL; -- Muestra todas las encuestas activas
SELECT * FROM Encuesta WHERE Archivado = FALSE OR Archivado IS NULL LIMIT 10; -- Muestra las 10 primeras encuestas activas
SELECT COUNT(*) FROM Encuesta; -- Cuantas Encuestas hay

SELECT * FROM Pregunta; -- Muestra todas las preguntas
SELECT * FROM Pregunta WHERE Archivado = FALSE OR Archivado IS NULL; -- Muestra todas las preguntas activas
SELECT * FROM Pregunta WHERE Archivado = TRUE; -- Muestra todas las preguntas archivadas
SELECT * FROM Pregunta WHERE Archivado = FALSE OR Archivado IS NULL LIMIT 10; -- Muestra las 10 primeras preguntas activas
SELECT COUNT(*) FROM Pregunta  WHERE Archivado = FALSE OR Archivado IS NULL; -- Cuantas Preguntas activas hay
SELECT * FROM Pregunta WHERE Archivado = FALSE OR Archivado IS NULL ORDER BY LEFT(ClavePregunta, 2),
CAST(SUBSTRING_INDEX(NumPregunta, 'a', 1) AS UNSIGNED), SUBSTRING(NumPregunta, LOCATE('a', NumPregunta)) DESC; -- Muestra todas las preguntas en orden

SELECT * FROM AlumnoEnGrupo; -- Muestra todos los Alumnos en todos los grupos
SELECT * FROM AlumnoEnGrupo WHERE Matricula = 'A00226903'; -- Muestra un alumno en especifico y sus grupos
SELECT * FROM AlumnoEnGrupo ORDER BY CRN,Matricula  LIMIT 10; -- Muestra los 10 primeros alumnos en grupos
SELECT aeg.CRN,aeg.Matricula,a.Nombre,aeg.ClaveEA,aeg.ClaveCampus FROM alumnoengrupo aeg 
JOIN Alumno a WHERE a.Matricula = aeg.Matricula ORDER BY aeg.Matricula; -- Muestra todos los alumnos con Nombre en grupos
SELECT COUNT(*) FROM alumnoengrupo; -- Cuantos Alumnos hay en los grupos

SELECT * FROM ProfesorEnGrupo; -- Muestra todos los Profesores en todos los grupos
SELECT * FROM ProfesorEnGrupo WHERE Matricula = 'A00226903'; -- Muestra un Profesor en especifico y sus grupos
SELECT * FROM ProfesorEnGrupo ORDER BY CRN,Matricula  LIMIT 10; -- Muestra los 10 primeros Profesores en grupos
SELECT peg.CRN,peg.Nomina,p.Nombre,peg.ClaveEA,peg.ClaveCampus FROM ProfesorEnGrupo peg 
JOIN Profesor p WHERE p.Nomina = peg.Nomina ORDER BY peg.Nomina; -- Muestra todos los Profesores con Nombre en grupos
SELECT COUNT(*) FROM ProfesorEnGrupo; -- Cuantos Profesores hay en los grupos

SELECT * FROM EncuestaGrupo; -- Muestra todas las encuestas activas por grupo y tipo de encuestas
SELECT * FROM EncuestaGrupo WHERE ClaveEncuesta = "E1"; -- Muestra una encuesta activa por grupo y tipo de encuesta
SELECT * FROM EncuestaGrupo LIMIT 10; -- Muestra las 10 primeras encuestas activas por grupo y tipo
SELECT COUNT(*) FROM EncuestaGrupo WHERE ClaveEncuesta = "E1"; -- Cuantos encuestas hay por tipo de encuesta

SELECT * FROM EncuestasAlumnos; -- Muestra todas las encuestas activas por alumno y tipo de encuestas
SELECT * FROM EncuestasAlumnos WHERE ClaveEncuesta = "E1"; -- Muestra una encuesta activa por alumnos y tipo de encuesta
SELECT * FROM EncuestasAlumnos LIMIT 10; -- Muestra las 10 primeras encuestas activas por alumnos y tipo
SELECT COUNT(*) FROM EncuestasAlumnos WHERE ClaveEncuesta = "E1"; -- Cuantos encuestas hay por alumnos y tipo de encuesta

SELECT * FROM EncuestaGrupoPregunta; -- Muestra todas las preguntas en todas las encuestas por grupo
SELECT * FROM EncuestaGrupoPregunta WHERE CRN = "39837"; -- Muestra todas las preguntas por grupo
SELECT * FROM EncuestaGrupoPregunta WHERE CRN = "39837" AND ClaveEncuesta = "E1"; -- Muestra todas las preguntas por grupo y encuesta
SELECT COUNT(*) FROM EncuestaGrupoPregunta WHERE CRN = "39837" AND ClaveEncuesta = "E1"; -- Cuantas preguntas hay por grupo y encuesta

SELECT * FROM PreguntasProfesor; -- Muestra todas las preguntas que los profesores tienen en la ECOA
SELECT * FROM PreguntasProfesor WHERE CRN = "39837"; -- Muestra todas las preguntas que los profesores tienen por grupo
SELECT COUNT(*),Nomina FROM PreguntasProfesor WHERE CRN = "39837" AND ClaveEncuesta = "E1" GROUP BY Nomina; -- Cuantas preguntas tienen los profesore por grupo y encuesta

SELECT * FROM RespuestasAlumnos; -- Muestra todas las respuestas de los alumnos
SELECT * FROM RespuestasAlumnos WHERE Matricula = "A00226903"; -- Muestra todas las respuestas de un alumno
SELECT * FROM RespuestasAlumnos WHERE Matricula = "A00226903" AND CRN = "39837"; -- Muestra todas las respuestas de un alumno para un grupo
SELECT * FROM RespuestasAlumnos WHERE Matricula = "A00226903" AND CRN = "39837" AND Nomina = "L00621404"; -- Muestra todas las respuestas de un alumno para un profesor en grupo
SELECT COUNT(*) FROM RespuestasAlumnos WHERE Matricula = "A00226903" AND CRN = "39837"; -- Cuantas Preguntas ha respondido el alumno sobre el grupo

SELECT * FROM RespuestasFolios; -- Muestra todas las respuestas de los alumnos
SELECT * FROM RespuestasFolios WHERE Folio = "1"; -- Muestra todas las respuestas de un alumno
SELECT * FROM RespuestasFolios WHERE Folio = "1" AND CRN = "39837"; -- Muestra todas las respuestas de un alumno para un grupo
SELECT * FROM RespuestasFolios WHERE Folio = "1" AND CRN = "39837" AND Nomina = "L00621404"; -- Muestra todas las respuestas de un alumno para un profesor en grupo
SELECT COUNT(*) FROM RespuestasAlumnos WHERE Folio = "A00226903" AND CRN = "39837"; -- Cuantas Preguntas ha respondido el alumno sobre el grupo

#######				TEST DE DISTRIBUCION DE PREGUNTAS EN ENCUESTAS					#######

ALTER TABLE Alumno ADD COLUMN Genero VARCHAR(10) DEFAULT "N/A";
ALTER TABLE Profesor ADD COLUMN Genero VARCHAR(10) DEFAULT "N/A";
UPDATE Profesor SET Genero = "M" WHERE Nomina = "L00621404";
UPDATE Alumno SET Genero = "M" WHERE Matricula = "A00226903"; -- Modificacion de Tablas Profesor Y Alumno, default N/A por privacidad.


DELETE FROM EncuestaGrupo WHERE CRN = "15289";
INSERT IGNORE INTO EncuestaGrupo VALUES ("E1","15289","F1008","202311");

TRUNCATE PreguntasProfesor;
TRUNCATE EncuestaGrupoPregunta;

SELECT * FROM Grupo WHERE CRN = "15289";
DELETE ea FROM EncuestasAlumnos ea JOIN AlumnoEnGrupo aeg ON ea.Matricula = aeg.Matricula 
WHERE CRN = "15289";

DELETE FROM EncuestaGrupoPregunta WHERE ClavePregunta = "EMASE";

SELECT * FROM EncuestasAlumnos;

SELECT aeg.CRN FROM EncuestasAlumnos ea 
JOIN Alumno a ON ea.Matricula = a.Matricula
JOIN AlumnoEnGrupo aeg ON a.Matricula = aeg.Matricula
JOIN EncuestaGrupo eg ON aeg.CRN = eg.CRN
GROUP BY aeg.CRN;

SELECT * FROM Pregunta;
SELECT * FROM encuestagrupopregunta;
INSERT INTO Pregunta VALUES("EMASE2","5a","ASE2","Estas preguntas se aplicaron al 50% de la población de estudiantes en cada UF impartida.  El profesor(a) promovió un ambiente de confianza y respeto:",0);
INSERT INTO encuestagrupopregunta VALUES("E1","15289","EMASE1");
CALL sp_UpdatePregunta("EBPLV2","EBPLV",NULL,"PLV",NULL,NULL);
CALL sp_PreCheckPregunta("EMASE3","5a","ASE3","Test",NULL,@mensaje);
CALL sp_PreCheckRespuesta("E1","15289","A00236589","EMASE2","ASE2","L00621886","MULTI",10,NULL,@mensaje);
SELECT @skip_check;
DELETE FROM Pregunta WHERE ClavePregunta = "EMASE2";
DELETE FROM encuestagrupopregunta WHERE ClavePregunta = "EMASE2";

SELECT p.TipoPregunta
		FROM EncuestaGrupoPregunta egp
        JOIN Pregunta p ON egp.clavePregunta = p.clavePregunta
		WHERE egp.ClaveEncuesta = "E1" AND egp.ClavePregunta = "EMASE3";

###			TEST DE RESPUESTAS Y CHECK DE PREGUNTAS			###
SELECT * FROM RespuestasAlumnos WHERE CRN = "18323";
SELECT * FROM EncuestaGrupoPregunta WHERE CRN = "15073";

INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","39837","A00226903","EBPLV","PLV",NULL,"MULTI", 10,NULL);
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","39837","A00226903","EBREC","REC","L00621404","MULTI", 10,NULL);
CALL sp_CheckRespuestaUpdate("E13","39837","A00226903","EBASE","ASE","L00621404","Multi",10,NULL);
SELECT @claveRespuesta;
SET @mensaje = NULL;
CALL sp_PreCheckRespuesta("E13","39837","A00226903", "EBAPD", "APD", NULL,"Multi",6,NULL,@skip_check, @mensaje);
SELECT p.TipoPregunta
		FROM EncuestaGrupoPregunta egp
        JOIN Pregunta p ON egp.clavePregunta = p.clavePregunta
		WHERE egp.ClaveEncuesta = "E13" AND egp.ClavePregunta = "EBAPD";
SELECT * FROM RespuestasAlumnos WHERE ClaveEncuesta = "E13" AND CRN = "15073" AND Matricula = "A00242489";
SELECT ra.ClaveRespuesta INTO @claveRespuesta
FROM RespuestasAlumnos ra
WHERE ra.ClaveEncuesta = "E1"
AND ra.CRN = "39837"
AND ra.Matricula = "A00226903"
AND ra.ClavePregunta = "EBAPD"
AND (ra.Nomina IS NULL OR ra.Nomina = "L00621404");

DELETE FROM RespuestasAlumnos WHERE ClaveRespuesta = @Ejemplo;
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","39837","A00226903","EBASE","ASE","L00621404","MULTI", 10,NULL);
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","39837","A00226903","EBCOMEN","COM","L00621404","MULTI", 10,NULL);
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","39837","A00226903","EBDOM","DOM","L00621404","MULTI", 10,NULL);
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","39837","A00226903","EBMET","MET","L00621404","MULTI", 10,NULL);
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","39837","A00226903","EBREC","REC","L00621404","MULTI", 10,NULL);
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","39837","A00226903","EBRET","RET","L00621404","MULTI", 10,NULL);

INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","15289","A00236589","EMAPD","APD",NULL,"MULTI", 10,NULL);
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","15289","A00236589","EMPLV","PLV",null,"MULTI", 10,NULL);
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","15289","A00236589","EMASE","ASE","L00621886","MULTI", 10,NULL);
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","15289","A00236589","EMDOM","DOM","L00621886","MULTI", 10,NULL);
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","15289","A00236589","EMMET","MET","L00621886","MULTI", 10,NULL);
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","15289","A00236589","EMREC","REC","L00621886","MULTI", 10,NULL);
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","15289","A00236589","EMRET","RET","L00621886","MULTI", 10,NULL);
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","15289","A00236589","EMCOMEN","COM","L00621886","Coment", NULL,"test");
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","15289","A00236589","EMDEMO","DEMO","L00621886","MULTI", 10,NULL);

INSERT IGNORE INTO RespuestasAlumnos(ClaveEncuesta,CRN,Matricula,ClavePregunta,TipoPregunta,Nomina,TipoResp,Evaluacion,Comentario) VALUES ("E1","15289","A00236589","EMAPD","APD",NULL,"MULTI", 10,NULL);

CALL sp_PreCheckRespuesta("E13","15289","A00236589","EMASE3","ASE3",NULL,"MULTI", 10,NULL,@mensaje);
SELECT @mensaje;

UPDATE RespuestasAlumnos SET ClaveEncuesta = "E1" WHERE ClaveRespuesta IN (18,19,21,22,23,24,29,31);
UPDATE RespuestasAlumnos SET ClaveEncuesta = "E1" WHERE ClaveRespuesta =18;
DELETE FROM respuestasalumnos WHERE ClaveRespuesta IN (42,43,44,45,46);
TRUNCATE RespuestasAlumnos;

CALL sp_PreguntasFaltantesAlumno("A00238862",null,FALSE); -- (Matricula, Nomina, Exlcuir)/(Matricula, NULL, Excluir) para preguntas sin NOMINA
CALL sp_PreguntasFaltantesAlumnoINT("A00238862",null,FALSE,"17928",@mensaje);
SELECT @mensaje;

SELECT egp.ClaveEncuesta, egp.CRN, egp.ClavePregunta, p.NumPregunta, pp.Nomina
FROM EncuestaGrupoPregunta egp
JOIN AlumnoEnGrupo aeg
    ON egp.CRN = aeg.CRN
    AND aeg.Matricula = "A00242489"
LEFT JOIN PreguntasProfesor pp
    ON egp.ClaveEncuesta = pp.ClaveEncuesta
    AND egp.CRN = pp.CRN
    AND egp.ClavePregunta = pp.ClavePregunta
LEFT JOIN RespuestasAlumnos ra
    ON egp.ClaveEncuesta = ra.ClaveEncuesta
    AND egp.CRN = ra.CRN
    AND egp.ClavePregunta = ra.ClavePregunta
    AND (pp.Nomina IS NULL OR pp.Nomina = ra.Nomina)
    AND ra.Matricula = "A00242489"
INNER JOIN Pregunta p ON p.ClavePregunta = egp.ClavePregunta
WHERE ra.ClaveRespuesta IS NULL
AND ( pp.Nomina IS NULL)
ORDER BY (CASE WHEN pp.Nomina IS NULL THEN 1 ELSE 0 END), pp.Nomina, 
LEFT(p.ClavePregunta, 2), 
CAST((CASE WHEN REGEXP_SUBSTR(p.NumPregunta, '[a-zA-Z]') IS NULL THEN 
	p.NumPregunta ELSE SUBSTRING_INDEX(p.NumPregunta, REGEXP_SUBSTR(p.NumPregunta, '[a-zA-Z]'), 1) END) AS UNSIGNED), 
REGEXP_SUBSTR(p.NumPregunta, '[a-zA-Z]+$');


SELECT * FROM encuestasalumnos WHERE Matricula = "A00238862";

SELECT * FROM encuestasalumnos;
 UPDATE EncuestasAlumnos ea
        SET ea.Contestada = false
        WHERE ea.Matricula = "A00238862"
        AND ea.ClaveEncuesta = "E1"
        AND ea.CRN = "17938";
        
        
Select * from UDF inner join Grupo on UDF.ClaveMateria=Grupo.ClaveMateria where Grupo.CRN="39837";

SELECT * FROM Grupo JOIN alumnoengrupo aeg ON Grupo.CRN = aeg.CRN WHERE aeg.Matricula = "A00236589";
SELECT * FROM Grupo JOIN ProfesorEnGrupo peg ON Grupo.CRN = peg.CRN WHERE peg.Nomina = "L00621886";
CALL sp_UpdateEncuesta("E14","E13",NULL,NULL,NULL,NULL,0);

select * FROM encuesta;

#######			CREACION DE TIEMPO Y LISTA DE GRUPOS DISPONIBLES PARA ENCUESTA			#######

ALTER TABLE Grupo ADD COLUMN FechaIni DATE, ADD COLUMN FechaFin DATE, ADD COLUMN Duracion INT;
SELECT * FROM Grupo WHERE CRN = "39837";
SELECT * FROM Encuesta WHERE ClaveEncuesta = "E1";
UPDATE Grupo SET FechaIni = "2023-02-12", FechaFin = "2023-05-15", Duracion = 10 WHERE CRN = "39837";
UPDATE Grupo SET FechaIni = "2023-02-10", FechaFin = "2023-03-10", Duracion = 18 WHERE CRN = "39837";

SELECT * FROM Encuesta WHERE Encuesta = "E2";
CALL sp_GruposParaEncuesta("E2",5); -- sp_GruposParaEncuesta(ClaveEncuesta,Semana de aplicacion);

CALL sp_UpdateEncuesta("E2",NULL,NULL,NULL,"2023-02-10","2023-06-19",0);

SELECT * FROM Grupo WHERE Duracion = 5;
-- Grupos con diferentes duraciones #### IMPORTANTE ESTO SOLO SE PUEDE CORRER EN MODO NO SEGURO: TENER CUIDADO!
UPDATE grupo
SET FechaIni = CASE
    WHEN Duracion = 5 THEN '2023-02-10' + INTERVAL (FLOOR(RAND() * 3) * 6) WEEK
    WHEN Duracion = 11 THEN '2023-02-10' + INTERVAL (FLOOR(RAND() * 2) * 6) WEEK
    WHEN Duracion = 17 THEN '2023-02-10'
    ELSE FechaIni
END,
FechaFin = FechaIni + INTERVAL Duracion - 1 WEEK;

CALL sp_PreCheckPregunta("EMOO","11a","OO","",0,@mensaje);
SELECT @mensaje;

######				PRUEBA DE INGRESO DE NUEVAS PREGUNTAS					#######
DELETE FROM encuestagrupopregunta WHERE ClavePregunta = "EBASE" AND CRN = "39837";
INSERT IGNORE INTO EncuestaGrupoPregunta VALUES ("E1","39837","EBASE");
SELECT * FROM encuestagrupopregunta WHERE CRN = "17938";
SELECT * FROM preguntasprofesor WHERE CRN = "17938" AND ClaveEncuesta = "E13";

######				CAMBIOS ASESORIA					######

ALTER TABLE Grupo ADD COLUMN Activo BOOL DEFAULT FALSE;
SELECT * FROM Grupo;

UPDATE Grupo SET Activo = 1 WHERE CRN = "10207";
CALL sp_GruposParaEncuesta("E1",17); -- sp_GruposParaEncuesta(ClaveEncuesta,Semana de aplicacion);
CALL sp_CrearEncuestasGrupos("E1","18322",null);
CALL sp_BorrarGruposEncuesta("E1","39837",17);
SELECT * FROM EncuestaGrupo;
SELECT * FROM Grupo WHERE CRN = "15289";

##### PRUEBAS DE FUNCIONAMIENTO #####
INSERT INTO Encuesta VALUES ("E10","EW","","22-12-12","22-12-12",1);

UPDATE Encuesta SET Descripcion = "" WHERE ClaveEncuesta = "E9";

INSERT INTO Pregunta VALUES("EM1","1","X","",1);

UPDATE Pregunta SET ClavePregunta = "ZX" WHERE ClavePregunta = "EB26";

CALL sp_PreguntasFaltantesAlumno("A00242489",null,TRUE);
INSERT INTO EncuestaGrupoPregunta VALUES ("E1","15289","EMASE");

CALL sp_PreguntasFaltantesAlumnoINT("A00236589",null,FALSE,@mensaje);
SELECT @mensaje;

SELECT @skip_check;
INSERT IGNORE INTO RespuestasAlumnos VALUES (NULL,"E1","15289","A00236589","EMASE","ASE","L00621886","MULTI", 10,NULL);

SELECT * FROM EncuestasAlumnos WHERE Matricula = "A00236589";
SELECT * FROM EncuestasAlumnos;

SELECT pf.Nomina,egp.ClavePregunta FROM PreguntasProfesor pf
RIGHT JOIN EncuestaGrupoPregunta egp ON pf.ClavePregunta = egp.ClavePregunta WHERE egp.CRN = "39837"; -- Muestra todas las preguntas de un alumno

SELECT * FROM Pregunta;
CALL sp_UpdatePregunta("EMASE3","EMASE1",NULL,"ASE1",NULL,NULL);
SELECT * FROM Encuesta;
CALL sp_UpdateEncuesta("E1",NULL,NULL,NULL,NULL,NULL,0);

SELECT p.Descripcion,pf.Nomina,egp.ClavePregunta FROM PreguntasProfesor pf
RIGHT JOIN EncuestaGrupoPregunta egp ON pf.ClavePregunta = egp.ClavePregunta 
JOIN Pregunta p ON egp.ClavePregunta = p.ClavePregunta WHERE Nomina IS NULL AND egp.CRN = "39837"; -- Muestra todas las preguntas de un alumno

SELECT u.NombreMateria FROM UDF u JOIN Grupo g ON g.ClaveMateria = u.ClaveMateria WHERE g.CRN = "15289";

SELECT COUNT(Nomina),CRN FROM ProfesorEnGrupo GROUP BY CRN;
SELECT * FROM UDF WHERE ClaveMateria = "MR3001B";
SELECT * FROM alumnoengrupo WHERE CRN = "17938";
SELECT * FROM encuestagrupo WHERE CRN = "15073";
SELECT * FROM encuestagrupopregunta WHERE CRN = "15073" AND ClaveEncuesta = "E13";
SELECT Distinct(Nomina),COUNT(ClavePregunta) FROM preguntasprofesor WHERE CRN = "15073" AND ClaveEncuesta = "E13" GROUP BY Nomina ORDER BY Nomina;
Select * FROM profesorengrupo WHERE CRN = "39837";
SELECT DISTINCT(Matricula) FROM EncuestasAlumnos WHERE CRN = "39837" AND ClaveEncuesta = "E1";

SELECT pf.Nomina,egp.ClavePregunta FROM PreguntasProfesor pf
RIGHT JOIN EncuestaGrupoPregunta egp ON pf.ClavePregunta = egp.ClavePregunta WHERE egp.CRN = "39837" AND egp.ClaveEncuesta = "E1"; -- Muestra todas las preguntas de un alumno

SELECT * FROM encuestagrupo;
SELECT * FROM Grupo WHERE CRN = "18322";
SELECT * FROM encuestagrupopregunta;
SELECT * FROM preguntasprofesor;
SELECT * FROM EncuestasAlumnos;
SELECT * FROM ProfesorEnGrupo peg JOIN Profesor p ON p.Nomina = peg.Nomina WHERE CRN = "18323";
DELETE FROM encuestagrupo WHERE CRN = "39837" AND ClaveEncuesta = "E1";
CALL sp_CrearEncuestasGrupos("E13","39837",NULL);
CALL sp_BorrarGruposEncuesta("E1","15073",5);
CALL sp_GruposParaEncuesta("E1",5);
ALTER TABLE EncuestasAlumnos DROP PRIMARY KEY, ADD PRIMARY KEY(ClaveEncuesta, Matricula, CRN);
SELECT * FROM Grupo;
SELECT * FROM encuesta;

CALL sp_UpdateEncuesta("E1",NULL,"202311",NULL,NULL,NULL,NULL);
##### Variables de usuario persistentes #####
CREATE TABLE VariablesUsuario (
    NombreVariable VARCHAR(64) NOT NULL PRIMARY KEY,
    ValorVariable VARCHAR(64) NOT NULL
);

INSERT INTO VariablesUsuario VALUES("TiposPreguntaProfesor",'DOM,RET,ASE,MET,REC,CMT,COM,DEMO'),("TiposPreguntaUDF",',APD,PLV,CEP,DEMOU');

SELECT ea.Matricula,ea.CRN,ea.Contestada FROM EncuestasAlumnos ea JOIN Encuesta e ON ea.ClaveEncuesta = e.ClaveEncuesta WHERE ea.Matricula = "A00226903" AND e.Archivado = 0 AND ea.Contestada = 0;

INSERT IGNORE INTO AlumnoEnGrupo Values("18322","A00226903","202311","M");

CALL sp_UpdateTipoPregunta("BORRAR","REC2",TRUE);

SELECT * FROM respuestasalumnos;

DELETE FROM respuestasalumnos WHERE CRN = "39837" AND ClaveEncuesta = "E2";

UPDATE variablesusuario SET ValorVariable = 'DOM,RET,ASE,MET,REC,CMT,COM,DEMO' WHERE NombreVariable = "TiposPreguntaProfesor";
UPDATE variablesusuario SET ValorVariable = 'APD,PLV,CEP,DEMOU' WHERE NombreVariable = "TiposPreguntaUDF";
SELECT COUNT(*) FROM Pregunta WHERE TipoPregunta = "REC";
SELECT * FROM VariablesUsuario;
CALL sp_UpdateTipoPregunta("INSERT","SA",NULL,TRUE);
SELECT * FROM Pregunta WHERE TipoPregunta = "SA";
SELECT 1 FROM Pregunta WHERE TipoPregunta = "SA";
INSERT INTO Pregunta VALUES("EMSA","5a","SA","test",1);
DELETE FROM Pregunta WHERE ClavePregunta = "EMSA";
CALL sp_UpdateTipoPregunta("BORRAR","SAE","SAE",TRUE);



##### MODIFICACION DE RESPUESTASALUMNOS #####


ALTER TABLE RespuestasAlumnos DROP PRIMARY KEY;
ALTER TABLE RespuestasAlumnos ADD PRIMARY KEY (ClaveEncuesta, CRN, Matricula, ClavePregunta, Nomina);


SELECT DISTINCT pp.Nomina
    FROM EncuestaGrupoPregunta egp
    JOIN AlumnoEnGrupo aeg
        ON egp.CRN = aeg.CRN
        AND aeg.Matricula = "A00226903"
    LEFT JOIN PreguntasProfesor pp
        ON egp.ClaveEncuesta = pp.ClaveEncuesta
        AND egp.CRN = pp.CRN
        AND egp.ClavePregunta = pp.ClavePregunta
    LEFT JOIN RespuestasAlumnos ra
        ON egp.ClaveEncuesta = ra.ClaveEncuesta
        AND egp.CRN = ra.CRN
        AND egp.ClavePregunta = ra.ClavePregunta
        AND pp.Nomina = ra.Nomina
        AND ra.Matricula = "A00226903"
	JOIN Pregunta p ON p.ClavePregunta = ra.ClavePregunta
    WHERE ra.ClaveRespuesta IS NULL
    AND pp.CRN = "39837";
    
SELECT * FROM AlumnoEnGrupo aeg JOIN Alumno a ON aeg.Matricula = a.Matricula WHERE  aeg.CRN = "18322";
Update Alumno SET Correo = "A00236584@tec.mx", Clave = "Alumno1234" WHERE Matricula = "A00236584";
SELECT * FROM Grupo g  JOIN Campus c ON c.ClaveCampus = g.ClaveCampus WHERE CRN = "18323";

SELECT * FROM Grupo g  JOIN Campus c ON c.ClaveCampus = g.ClaveCampus JOIN UDF ON g.ClaveMateria = UDF.ClaveMateria WHERE UDF.TipoUDF = "Materia";

CALL sp_PreguntasFaltantesAlumno("A00226903",NULL,FALSE);

SELECT pp.ClaveEncuesta,pp.Nomina, p.ClavePregunta,p.NumPregunta,p.TipoPregunta,p.Descripcion FROM pregunta p 
INNER JOIN preguntasprofesor pp ON p.`ClavePregunta` = pp.`ClavePregunta` 
WHERE CRN = "39837" AND Nomina = "L00621404" AND (Archivado = 0 OR Archivado IS NULL)
ORDER BY (CASE WHEN pp.Nomina IS NULL THEN 1 ELSE 0 END), pp.Nomina, 
LEFT(p.ClavePregunta, 2), 
CAST((CASE WHEN REGEXP_SUBSTR(p.NumPregunta, '[a-zA-Z]') IS NULL THEN 
	p.NumPregunta ELSE SUBSTRING_INDEX(p.NumPregunta, REGEXP_SUBSTR(p.NumPregunta, '[a-zA-Z]'), 1) END) AS UNSIGNED), 
REGEXP_SUBSTR(p.NumPregunta, '[a-zA-Z]+$');

SELECT egp.ClavePregunta as ClavePregunta, p.Descripcion as Descripcion, p.TipoPregunta
        FROM PreguntasProfesor pf 
        RIGHT JOIN EncuestaGrupoPregunta egp ON pf.ClavePregunta = egp.ClavePregunta 
        left Join Pregunta p ON egp.ClavePregunta = p.ClavePregunta
        WHERE Nomina IS NULL AND egp.CRN = "17938";
        
SELECT CRN,COUNT(*) FROM ProfesorEnGrupo GROUP BY CRN ORDER BY COUNT(*) DESC;