USE ecoa_diner;
DROP TRIGGER IF EXISTS tg_InsertEncuestaGrupoAlumnos;
DROP TRIGGER IF EXISTS tg_RemoveEncuestaGrupoAlumnos;
DROP TRIGGER IF EXISTS tg_InsertEncuestaGrupoPreguntas;
DROP TRIGGER IF EXISTS tg_RemovePreguntaEncuesta;
DROP TRIGGER IF EXISTS tg_InsertPreguntaEncuesta;
DROP TRIGGER IF EXISTS tg_InsertPreguntasProfesor;
DROP TRIGGER IF EXISTS tg_InsertRespuestasAlumnos;
DROP TRIGGER IF EXISTS tg_UpdateRespuestasAlumnos;
DROP TRIGGER IF EXISTS tg_InsertPregunta;
DROP TRIGGER IF EXISTS tg_UpdatePregunta;
DROP TRIGGER IF EXISTS tg_DeletePregunta;
DROP TRIGGER IF EXISTS tg_InsertEncuesta;
DROP TRIGGER IF EXISTS tg_UpdateEncuesta;
DROP TRIGGER IF EXISTS tg_EncuestaCompletadaInsert;
DROP TRIGGER IF EXISTS tg_EncuestaCompletadaUpdate;
DROP TRIGGER IF EXISTS tg_EncuestaCompletadaDelete;

DELIMITER $$
-- Trigger que agrega los estudiantes de un grupo a la encuesta a realizar
CREATE TRIGGER tg_InsertEncuestaGrupoAlumnos AFTER INSERT ON EncuestaGrupo FOR EACH ROW
BEGIN
    -- Insertar filas en EncuestaAlumnos para cada alumno en AlumnoEnGrupo
    INSERT IGNORE INTO EncuestasAlumnos (ClaveEncuesta, Matricula,ClaveEA,CRN, Contestada)
    SELECT NEW.ClaveEncuesta, AlumnoEnGrupo.Matricula, NEW.ClaveEA, NEW.CRN, 0
    FROM AlumnoEnGrupo
    WHERE AlumnoEnGrupo.CRN = NEW.CRN;
END; $$

-- Trigger que elimina los estudiantes de un grupo a la encuesta a realizar
CREATE TRIGGER tg_RemoveEncuestaGrupoAlumnos AFTER DELETE ON EncuestaGrupo FOR EACH ROW
BEGIN
	-- Eliminar filas en EncuestasAlumnos para cada grupo
	DELETE ea
    FROM EncuestasAlumnos ea
    JOIN AlumnoEnGrupo aeg ON ea.Matricula = aeg.Matricula
    WHERE ea.ClaveEncuesta = OLD.ClaveEncuesta AND ea.CRN = OLD.CRN;
    
    -- Eliminar filas en EncuestaGrupoPregunta para cada encuesta
    DELETE FROM EncuestaGrupoPregunta WHERE CRN = OLD.CRN AND ClaveEncuesta = OLD.ClaveEncuesta;
END; $$

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

-- Trigger que remueva todas las preguntas sorteadas en una Encuesta
CREATE TRIGGER tg_RemovePreguntaEncuesta AFTER DELETE ON EncuestaGrupoPregunta FOR EACH ROW
BEGIN
DELETE FROM PreguntasProfesor pp WHERE OLD.ClaveEncuesta = pp.ClaveEncuesta AND OLD.ClavePregunta = pp.ClavePregunta AND OLD.CRN = pp.CRN;
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

-- Trigger que verifica que el insert de las respuestas sean validas para la encuesta
CREATE TRIGGER tg_InsertRespuestasAlumnos BEFORE INSERT ON RespuestasAlumnos FOR EACH ROW
BEGIN
    DECLARE mensaje VARCHAR(100);
    CALL sp_PreCheckRespuesta(NEW.ClaveEncuesta,NEW.CRN,NEW.Matricula, NEW.ClavePregunta, NEW.TipoPregunta, NEW.Nomina,NEW.TipoResp,NEW.Evaluacion,NEW.Comentario,@skip_check, mensaje);
    IF mensaje <> 'El alumno puede contestar la pregunta' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensaje;
    END IF;
END; $$

-- Trigger que verifica que el update de las respuestas sean validas para la encuesta
CREATE TRIGGER tg_UpdateRespuestasAlumnos BEFORE UPDATE ON RespuestasAlumnos FOR EACH ROW
BEGIN
    DECLARE mensaje VARCHAR(100);
		CALL sp_PreCheckRespuesta(
			COALESCE(NEW.ClaveEncuesta, OLD.ClaveEncuesta),
			COALESCE(NEW.CRN, OLD.CRN),
			COALESCE(NEW.Matricula, OLD.Matricula),
			COALESCE(NEW.ClavePregunta, OLD.ClavePregunta),
			COALESCE(NEW.TipoPregunta, OLD.TipoPregunta),
			COALESCE(NEW.Nomina, OLD.Nomina),
			COALESCE(NEW.TipoResp, OLD.TipoResp),
			COALESCE(NEW.Evaluacion, OLD.Evaluacion),
			COALESCE(NEW.Comentario, OLD.Comentario),
            @skip_check,
			mensaje
		);
		IF mensaje <> 'El alumno puede contestar la pregunta' THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensaje;
		END IF;
END; $$

-- Trigger que verifica que el insert de las preguntas sean validas para la encuesta
CREATE TRIGGER tg_InsertPregunta BEFORE INSERT ON Pregunta FOR EACH ROW
BEGIN
    DECLARE mensaje VARCHAR(100);
    CALL sp_PreCheckPregunta(NEW.ClavePregunta,NEW.NumPregunta,NEW.TipoPregunta, NEW.Descripcion, NEW.Archivado, mensaje);
    IF mensaje <> 'Pregunta es valida' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensaje;
    END IF;
END; $$

-- Trigger que verifica que el update de las preguntas sean validas para la encuesta
CREATE TRIGGER tg_UpdatePregunta BEFORE UPDATE ON Pregunta FOR EACH ROW
BEGIN
    DECLARE mensaje VARCHAR(100);
    CALL sp_PreCheckPregunta(
        COALESCE(NEW.ClavePregunta, OLD.ClavePregunta),
        COALESCE(NEW.NumPregunta, OLD.NumPregunta),
        COALESCE(NEW.TipoPregunta, OLD.TipoPregunta),
        COALESCE(NEW.Descripcion, OLD.Descripcion),
		COALESCE(NEW.Archivado, OLD.Archivado),
        mensaje
    );
    IF mensaje <> 'Pregunta es valida' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensaje;
    END IF;
END; $$

-- Trigger que elimina las preguntas y sus tipos de preguntas validas
CREATE TRIGGER tg_DeletePregunta AFTER DELETE ON Pregunta FOR EACH ROW
BEGIN
	-- Obtener el tipo de Preguntas a insertar
    SELECT ValorVariable INTO @TiposPreguntaProfesor
	FROM VariablesUsuario
	WHERE NombreVariable = 'TiposPreguntaProfesor';
    
    SELECT ValorVariable INTO @TiposPreguntaUDF
	FROM VariablesUsuario
	WHERE NombreVariable = 'TiposPreguntaUDF';
    
    -- Modificar los tipos de preguntas validos
    IF (FIND_IN_SET(OLD.TipoPregunta, @TiposPreguntaProfesor) > 0)  THEN
		IF NOT EXISTS (
            SELECT 1 FROM Pregunta p WHERE p.TipoPregunta = OLD.TipoPregunta
        ) THEN
		CALL sp_UpdateTipoPregunta("BORRAR",OLD.TipoPregunta,NULL,TRUE);
		END IF;
    END IF;
    IF (FIND_IN_SET(OLD.TipoPregunta, @TiposPreguntaUDF) > 0)  THEN
		IF NOT EXISTS (
            SELECT 1 FROM Pregunta p WHERE p.TipoPregunta = OLD.TipoPregunta
        ) THEN
		CALL sp_UpdateTipoPregunta("BORRAR",OLD.TipoPregunta,NULL,FALSE);
		END IF;
    END IF;
END; $$

-- Trigger que verifica que el insert de las encuestas sean validas
CREATE TRIGGER tg_InsertEncuesta BEFORE INSERT ON Encuesta FOR EACH ROW
BEGIN
    DECLARE mensaje VARCHAR(100);
    CALL sp_PreCheckEncuesta(NEW.ClaveEncuesta,NEW.ClaveEA,NEW.Descripcion, NEW.FechaIni, NEW.FechaLim, NEW.Archivado, mensaje);
    IF mensaje <> 'Encuesta es valida' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensaje;
    END IF;
END; $$

-- Trigger que verifica que el update de las preguntas sean validas para la encuesta
CREATE TRIGGER tg_UpdateEncuesta BEFORE UPDATE ON Encuesta FOR EACH ROW
BEGIN
    DECLARE mensaje VARCHAR(100);
    CALL sp_PreCheckEncuesta(
        COALESCE(NEW.ClaveEncuesta,OLD.ClaveEncuesta),
        COALESCE(NEW.ClaveEA, OLD.ClaveEA),
        COALESCE(NEW.Descripcion, OLD.Descripcion),
        COALESCE(NEW.FechaIni, OLD.FechaIni),
		COALESCE(NEW.FechaLim, OLD.FechaLim),
        COALESCE(NEW.Archivado, OLD.Archivado),
        mensaje
    );
    IF mensaje <> 'Encuesta es valida' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensaje;
    END IF;
END; $$

-- Trigger que verifica que la encuesta esta completa por alumno despues de insert
CREATE TRIGGER tg_EncuestaCompletadaInsert AFTER INSERT ON RespuestasAlumnos FOR EACH ROW
BEGIN
    CALL sp_CheckEncuestaCompletada(NEW.Matricula, NEW.ClaveEncuesta, NEW.CRN);
END $$

-- Trigger que verifica que la encuesta esta completa por alumno despues de update
CREATE TRIGGER tg_EncuestaCompletadaUpdate AFTER UPDATE ON RespuestasAlumnos FOR EACH ROW
BEGIN
    CALL sp_CheckEncuestaCompletada(NEW.Matricula, NEW.ClaveEncuesta, NEW.CRN);
END $$

-- Trigger que verifica que la encuesta esta completa por alumno despues de delete
CREATE TRIGGER tg_EncuestaCompletadaDelete AFTER DELETE ON RespuestasAlumnos FOR EACH ROW
BEGIN
    CALL sp_CheckEncuestaCompletada(OLD.Matricula, OLD.ClaveEncuesta, OLD.CRN);
END $$