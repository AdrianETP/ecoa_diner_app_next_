DELIMITER $$

-- Trigger que agrega todas las preguntas de una encuesta para cada tipo de materia
CREATE TRIGGER tg_InsertEncuestaGrupoPreguntas AFTER INSERT ON EncuestaGrupo FOR EACH ROW 
BEGIN
    DECLARE tipoUDF varchar(20);
    
    -- Obtener el tipo de UDF asociado a la materia del grupo
    SELECT UDF.TipoUDF INTO tipoUDF
    FROM UDF
    JOIN Grupo ON UDF.ClaveMateria = Grupo.ClaveMateria
    WHERE Grupo.CRN = NEW.CRN;
    
    -- Obtener el tipo de Preguntas a insertar
    SELECT ValorVariable INTO @TiposPreguntaProfesor
	FROM VariablesUsuario
	WHERE NombreVariable = 'TiposPreguntaProfesor';
    
    SELECT ValorVariable INTO @TiposPreguntaUDF
	FROM VariablesUsuario
	WHERE NombreVariable = 'TiposPreguntaUDF';
    
    -- Insertar preguntas en EncuestaGrupoPregunta dependiendo del tipo de UDF
    IF tipoUDF = 'Bloque' THEN 
        INSERT IGNORE INTO EncuestaGrupoPregunta (ClaveEncuesta, CRN, ClavePregunta)
        SELECT NEW.ClaveEncuesta, NEW.CRN, ClavePregunta
        FROM Pregunta
        WHERE ClavePregunta LIKE 'EB%'
        AND (FIND_IN_SET(Pregunta.TipoPregunta, @TiposPreguntaProfesor) > 0
        OR 	 FIND_IN_SET(Pregunta.TipoPregunta, @TiposPreguntaUDF) > 0)
        AND (Archivado = FALSE OR Archivado IS NULL);
        
       /* -- Distribuir preguntas "ASE" a la mitad de los alumnos del grupo
        CALL sp_DistribuirPreguntas(NEW.ClaveEncuesta, NEW.CRN, 'ASE', 0.5);
        
        -- Distribuir preguntas "MET" a la mitad de los alumnos del grupo
        CALL sp_DistribuirPreguntas(NEW.ClaveEncuesta, NEW.CRN, 'MET', 0.5);*/
    END IF;
    
    IF tipoUDF = 'Materia' THEN
        INSERT IGNORE INTO EncuestaGrupoPregunta (ClaveEncuesta, CRN, ClavePregunta)
        SELECT NEW.ClaveEncuesta, NEW.CRN, ClavePregunta
        FROM Pregunta
        WHERE ClavePregunta LIKE 'EM%' 
        AND (FIND_IN_SET(Pregunta.TipoPregunta, @TiposPreguntaProfesor) > 0
        OR 	 FIND_IN_SET(Pregunta.TipoPregunta, @TiposPreguntaUDF) > 0)
        AND (Archivado = FALSE OR Archivado IS NULL);
        /* -- Distribuir preguntas "ASE" a la mitad de los alumnos del grupo
        CALL sp_DistribuirPreguntas(NEW.ClaveEncuesta, NEW.CRN, 'ASE', 0.5);
        
        -- Distribuir preguntas "MET" a la mitad de los alumnos del grupo
        CALL sp_DistribuirPreguntas(NEW.ClaveEncuesta, NEW.CRN, 'MET', 0.5);*/
    END IF;
    
    IF tipoUDF = 'Concentracion' THEN
        INSERT IGNORE INTO EncuestaGrupoPregunta (ClaveEncuesta, CRN, ClavePregunta)
        SELECT NEW.ClaveEncuesta, NEW.CRN, ClavePregunta
        FROM Pregunta
        WHERE ClavePregunta LIKE 'EC%'
        AND (FIND_IN_SET(Pregunta.TipoPregunta, @TiposPreguntaProfesor) > 0
        OR 	 FIND_IN_SET(Pregunta.TipoPregunta, @TiposPreguntaUDF) > 0)
        AND (Archivado = FALSE OR Archivado IS NULL);
        /* -- Distribuir preguntas "ASE" a la mitad de los alumnos del grupo
        CALL sp_DistribuirPreguntas(NEW.ClaveEncuesta, NEW.CRN, 'ASE', 0.5);
        
        -- Distribuir preguntas "MET" a la mitad de los alumnos del grupo
        CALL sp_DistribuirPreguntas(NEW.ClaveEncuesta, NEW.CRN, 'MET', 0.5);*/
    END IF;
    
    IF tipoUDF NOT IN ('Bloque', 'Materia', 'Concentracion') THEN
        -- Mostrar un mensaje de registro
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de UDF no válido';
    END IF;
END; $$

-- Trigger que agrega todas las preguntas de una encuesta para cada tipo de profesor
CREATE TRIGGER tg_InsertPreguntasProfesor AFTER INSERT ON EncuestaGrupo FOR EACH ROW
BEGIN
    DECLARE tipoUDF varchar(20);
    
    -- Obtener el tipo de UDF asociado a la materia del grupo
    SELECT UDF.TipoUDF INTO tipoUDF
    FROM UDF
    JOIN Grupo ON UDF.ClaveMateria = Grupo.ClaveMateria
    WHERE Grupo.CRN = NEW.CRN;
    
    -- Insertar preguntas en PreguntasProfesor dependiendo del tipo de UDF y tipo de pregunta
     IF tipoUDF = 'Bloque' THEN
        INSERT IGNORE INTO PreguntasProfesor (ClaveEncuesta,ClavePregunta, CRN, Nomina)
		SELECT NEW.ClaveEncuesta, Pregunta.ClavePregunta, NEW.CRN, ProfesorEnGrupo.Nomina
        FROM Pregunta
        JOIN EncuestaGrupoPregunta ON EncuestaGrupoPregunta.ClavePregunta = pregunta.ClavePregunta
        JOIN ProfesorEnGrupo ON ProfesorEnGrupo.CRN = EncuestaGrupoPregunta.CRN
        WHERE (Pregunta.ClavePregunta LIKE 'EB%') AND FIND_IN_SET(Pregunta.TipoPregunta, @TiposPreguntaProfesor) > 0
        AND (Pregunta.Archivado = FALSE OR Pregunta.Archivado IS NULL)
        AND Profesorengrupo.CRN = NEW.CRN;
    END IF;
    
    IF tipoUDF = 'Materia' THEN
        INSERT IGNORE INTO PreguntasProfesor (ClaveEncuesta,ClavePregunta, CRN, Nomina)
		SELECT NEW.ClaveEncuesta, Pregunta.ClavePregunta, NEW.CRN, ProfesorEnGrupo.Nomina
        FROM Pregunta
        JOIN EncuestaGrupoPregunta ON EncuestaGrupoPregunta.ClavePregunta = pregunta.ClavePregunta
        JOIN ProfesorEnGrupo ON ProfesorEnGrupo.CRN = EncuestaGrupoPregunta.CRN
        WHERE (Pregunta.ClavePregunta LIKE 'EB%') AND FIND_IN_SET(Pregunta.TipoPregunta, @TiposPreguntaProfesor) > 0
        AND (Pregunta.Archivado = FALSE OR Pregunta.Archivado IS NULL)
        AND Profesorengrupo.CRN = NEW.CRN;
    END IF;
    
    IF tipoUDF = 'Concentracion' THEN
       INSERT IGNORE INTO PreguntasProfesor (ClaveEncuesta,ClavePregunta, CRN, Nomina)
		SELECT NEW.ClaveEncuesta, Pregunta.ClavePregunta, NEW.CRN, ProfesorEnGrupo.Nomina
        FROM Pregunta
        JOIN EncuestaGrupoPregunta ON EncuestaGrupoPregunta.ClavePregunta = pregunta.ClavePregunta
        JOIN ProfesorEnGrupo ON ProfesorEnGrupo.CRN = EncuestaGrupoPregunta.CRN
        WHERE (Pregunta.ClavePregunta LIKE 'EB%') AND FIND_IN_SET(Pregunta.TipoPregunta, @TiposPreguntaProfesor) > 0
        AND (Pregunta.Archivado = FALSE OR Pregunta.Archivado IS NULL)
        AND Profesorengrupo.CRN = NEW.CRN;
	END IF;
    
    IF tipoUDF NOT IN ('Bloque', 'Materia', 'Concentracion') THEN
        -- Mostrar un mensaje de registro
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de UDF no válido';
    END IF;
END; $$

-- Trigger que inserte las nuevas pregutnas a los profesores
CREATE TRIGGER tg_InsertPreguntaEncuesta AFTER INSERT ON EncuestaGrupoPregunta FOR EACH ROW
BEGIN
	INSERT IGNORE INTO PreguntasProfesor (ClaveEncuesta, ClavePregunta, CRN, Nomina)
	SELECT NEW.ClaveEncuesta, NEW.ClavePregunta, NEW.CRN, ProfesorEnGrupo.Nomina
	FROM ProfesorEnGrupo
	JOIN Pregunta ON Pregunta.ClavePregunta = NEW.ClavePregunta
	WHERE ProfesorEnGrupo.CRN = NEW.CRN
	AND FIND_IN_SET(Pregunta.TipoPregunta, @TiposPreguntaProfesor) > 0
	AND (Pregunta.Archivado = FALSE OR Pregunta.Archivado IS NULL);
END; $$
