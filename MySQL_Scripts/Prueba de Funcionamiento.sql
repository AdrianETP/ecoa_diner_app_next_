USE ecoa_diner;

# Datos UDF
DROP TABLE UDF;
INSERT INTO UDF VALUES("TC1005B","Software", "Bloque");
INSERT INTO UDF VALUES("TC1001B","Fisica", "Bloque");
SELECT * FROM UDF;

# Datos Grupo
DROP TABLE Grupo;
INSERT INTO Grupo VALUES("404","TC1005B"),("404","TC1001B"),("101","TC1005B"),("101","TC1001B");
SELECT * FROM Grupo;

# Datos Profesor
DROP TABLE Profesor;
INSERT INTO Profesor VALUES("A00789123", "Profe2","Prueba2", "Prueba2", "12345", "profe2@gmail.com"),("A00123456", "Profe1","Prueba1", "Prueba1", "12345", "profe1@gmail.com");
SELECT * FROM Profesor;

# Datos Alumno
DROP TABLE alumno;
INSERT INTO Alumno VALUES("A00456789","Nombre1","Apellido1","Apellido2","Contraseña1","alumno1@gmail.com"),("A00223456","Nombre2","Apellido3","Apellido4","Contraseña2","alumno2@gmail.com");
SELECT * FROM Alumno;

# Datos Premio
DROP TABLE Premio;
INSERT INTO Premio VALUES("CPN1",1,"Coupon","Coupon de Chili's"),("GFTC1",1,"GiftCard","Giftcard de Amazon");
SELECT * FROM Premio;

# Datos pregunta
DROP TABLE Pregunta;
INSERT INTO pregunta VALUES ("1P","RET","P1","El profe enseña",0),("2P","RET","P2","El profe ayuda",0),("3P","REC","P3","La Materia es util",0);
SELECT * FROM Pregunta;

# Datos Encuesta 
DROP TABLE Encuesta;
INSERT INTO Encuesta VALUES ("E1","404",current_date(),"Ecoa 1", current_date(), current_date()),("E2","101",current_date(),"Ecoa 1", current_date(), current_date());
SELECT * FROM Encuesta;

# Datos AlumnosEnGrupo
DROP TABLE AlumnoEnGrupo;
INSERT INTO AlumnoEnGrupo VALUES ("404","A00456789","TC1005B","EJ23"),("404","A00223456","TC1001B","EJ23");
SELECT * FROM alumnoengrupo;

# Datos ProfesorEnGrupo
DROP TABLE ProfesorEnGrupo;
INSERT INTO profesorengrupo VALUES 
("404","A00789123","TC1005B","EJ23",50),
("404","A00123456","TC1005B","EJ23",50),
("101","A00789123","TC1005B","EJ23",50),
("101","A00123456","TC1005B","EJ23",50),
("404","A00789123","TC1001B","EJ23",50),
("404","A00123456","TC1001B","EJ23",50),
("101","A00789123","TC1001B","EJ23",50),
("101","A00123456","TC1001B","EJ23",50);
SELECT * FROM profesorengrupo;

# Datos EncuestasPreguntas
DROP TABLE encuestaspreguntas;

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
DROP TABLE encuestasalumnos;

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
INNER JOIN AlumnoEnGrupo aeg ON e.ClaveMateria = aeg.ClaveMateria AND e.Periodo = aeg.Periodo AND e.CRN = aeg.CRN
WHERE e.Periodo = 'EJ23';

# Muestra la Encuesta a realizar por Alumno y Periodo
SELECT ea.ClaveEncuesta,ea.Matricula,e.Periodo,ea.Contestada FROM encuestasalumnos ea
JOIN encuesta e WHERE ea.ClaveEncuesta = e.ClaveEncuesta;

# Datos respuestasAlumnos
DROP TABLE RespuestasAlumnos;
TRUNCATE TABLE RespuestasAlumnos;

# Inserta respuesta dirigida a profesor o udf
INSERT INTO RespuestasAlumnos (ClavePregunta, Matricula, ClaveEncuesta, TipoPregunta, Nomina, TipoResp, Evaluacion, Comentario)
VALUES ('3P', 'A00456789', 'E1', 'REC', NULL, 'Opción múltiple', 10, 'La Materia es util.'),
('1P', 'A00456789', 'E1', 'RET', 'A00789123', 'Opción múltiple', 10, 'El profesor es util.');
SELECT * FROM RespuestasAlumnos;

# Datos respuestasFolios
DROP TABLE RespuestasFolios;
TRUNCATE TABLE RespuestasFolios;

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
