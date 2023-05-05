USE ecoa_diner;

# Datos UDF
#DROP TABLE UDF;
#TRUNCATE UDF;
SELECT * FROM UDF;

# Datos Grupo
#DROP TABLE Grupo;
#TRUNCATE Grupo;
SELECT CRN,ClaveMateria,ClaveEA AS "Clave Ejercicio Academico",Campus.NombreCampus FROM Grupo
INNER JOIN Campus ON Grupo.ClaveCampus = Campus.ClaveCampus
ORDER BY Campus.ClaveCampus;

# Datos Profesor
#DROP TABLE Profesor;
#TRUNCATE Profesor;
SELECT Nomina,Nombre,ApellidoPaterno,ApellidoMaterno,Campus.NombreCampus,Departamento,Correo FROM Profesor
INNER JOIN Campus ON Profesor.ClaveCampus = Campus.ClaveCampus
ORDER BY Campus.ClaveCampus;

# Datos Alumno
#DROP TABLE Alumno;
#TRUNCATE Alumno;
SELECT Matricula,Nombre,ApellidoPaterno,ApellidoMaterno,Campus.NombreCampus,Correo FROM Alumno
INNER JOIN Campus ON Alumno.ClaveCampus = Campus.ClaveCampus
ORDER BY Campus.ClaveCampus;

# Datos Premio
#DROP TABLE Premio;
#TRUNCATE Premio;
SELECT * FROM Premio;

# Datos pregunta
#DROP TABLE Pregunta;
#TRUNCATE Pregunta;
SELECT * FROM Pregunta;

# Datos Encuesta 
#DROP TABLE Encuesta;
#TRUNCATE Encuesta;
SELECT * FROM Encuesta;


# Datos AlumnosEnGrupo
#DROP TABLE AlumnoEnGrupo;
#TRUNCATE AlumnoEnGrupo;
SELECT * FROM AlumnoEnGrupo;

# Datos ProfesorEnGrupo
#DROP TABLE ProfesorEnGrupo;
#TRUNCATE ProfesorEnGrupo;
SELECT * FROM ProfesorEnGrupo;

# Datos EncuestasPreguntas
#DROP TABLE encuestaspreguntas;
#TRUNCATE encuestaspreguntas;

# Creacion de Encuestas con Preguntas
INSERT INTO EncuestasPreguntas (claveEncuesta, clavePregunta)
SELECT e.claveEncuesta, p.clavePregunta
FROM Encuesta e
JOIN Pregunta p;

SELECT e.claveEncuesta, p.clavePregunta
FROM Encuesta e
JOIN encuestaspreguntas ep ON e.ClaveEncuesta = ep.ClaveEncuesta
JOIN Pregunta p ON ep.ClavePregunta = p.ClavePregunta
ORDER BY e.claveEncuesta, p.clavePregunta;

# Datos EncuestasAlumnos
#DROP TABLE encuestasalumnos;
#TRUNCATE encuestasalumnos;

# Selecciona a alumnos que cursaron un curso en AlumnosEnGrupo
INSERT INTO EncuestasAlumnos(ClaveEncuesta,Matricula,Contestada)
SELECT e.claveEncuesta, aeg.Matricula, 0
FROM Encuesta e
INNER JOIN Grupo g ON e.CRN = g.CRN
INNER JOIN AlumnoEnGrupo aeg ON g.CRN = aeg.CRN AND g.ClaveMateria = aeg.ClaveMateria;

# Selecciona a alumnos que cursaron un curso en AlumnosEnGrupo en un periodo especifico
INSERT INTO EncuestasAlumnos(ClaveEncuesta,Matricula,Contestada)
SELECT e.ClaveEncuesta, aeg.Matricula, 0
FROM Encuesta e
INNER JOIN Grupo g ON e.CRN = g.CRN
INNER JOIN AlumnoEnGrupo aeg  ON g.CRN = aeg.CRN AND g.ClaveMateria = aeg.ClaveMateria AND e.Periodo = aeg.Periodo;

# Muestra la Encuesta a realizar por Alumno y Periodo
SELECT ea.ClaveEncuesta,ea.Matricula,e.ClaveEA,ea.Contestada FROM EncuestasAlumnos ea
JOIN Encuesta e WHERE ea.ClaveEncuesta = e.ClaveEncuesta;

# Datos respuestasAlumnos
#DROP TABLE RespuestasAlumnos;
#TRUNCATE TABLE RespuestasAlumnos;

# Inserta respuesta dirigida a profesor o udf
INSERT INTO RespuestasAlumnos (ClavePregunta, Matricula, ClaveEncuesta, TipoPregunta, Nomina, TipoResp, Evaluacion, Comentario)
VALUES ('3P', 'A00456789', 'E1', 'REC', NULL, 'Opción múltiple', 10, 'La Materia es util.'),
('1P', 'A00456789', 'E1', 'RET', 'A00789123', 'Opción múltiple', 10, 'El profesor es util.'),
('3P', 'A00223456', 'E1', 'REC', NULL, 'Opción múltiple', 8, 'La Materia es util.'),
('1P', 'A00223456', 'E1', 'RET', 'A00789123', 'Opción múltiple', 9, 'El profesor es util.');
SELECT * FROM RespuestasAlumnos;

# Datos respuestasFolios
#DROP TABLE RespuestasFolios;
#TRUNCATE TABLE RespuestasFolios;

# Se Selecciona datos por matricula de RespuestasAlumnos y se le asigna un folio
INSERT INTO RespuestasFolios (ClavePregunta, Folio, ClaveEncuesta, TipoPregunta, Nomina, TipoResp, Evaluacion, Comentario)
SELECT ra.ClavePregunta, 
       DENSE_RANK() OVER (ORDER BY ra.Matricula) AS Folio, # Clasifica por fila, en este caso por matricula
       ra.ClaveEncuesta, 
       ra.TipoPregunta, 
       ra.Nomina, 
       ra.TipoResp, 
       ra.Evaluacion, 
       ra.Comentario
FROM RespuestasAlumnos ra;

SELECT * FROM RespuestasFolios;