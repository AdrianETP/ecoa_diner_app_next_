Use ecoa_diner;
DROP PROCEDURE IF EXISTS sp_UpdatePregunta;
DROP PROCEDURE IF EXISTS sp_PreCheckRespuesta;
DROP PROCEDURE IF EXISTS sp_PreCheckPregunta;
DROP PROCEDURE IF EXISTS sp_PreCheckEncuesta;
DROP PROCEDURE IF EXISTS sp_CheckRespuestaUpdate;
DROP PROCEDURE IF EXISTS sp_PreguntasFaltantesAlumno;
DROP PROCEDURE IF EXISTS sp_UpdateEncuesta;
DROP PROCEDURE IF EXISTS sp_GruposParaEncuesta;
DROP PROCEDURE IF EXISTS sp_CrearEncuestasGrupos;
DROP PROCEDURE IF EXISTS sp_BorrarGruposEncuesta;
DROP PROCEDURE IF EXISTS sp_PreguntasFaltantesAlumnoINT;
DROP PROCEDURE IF EXISTS sp_CheckEncuestaCompletada;
DROP PROCEDURE IF EXISTS sp_UpdateTipoPregunta;

DELIMITER $$
-- Procedure que modifica Preguntas
CREATE PROCEDURE sp_UpdatePregunta(
    IN oldClavePregunta VARCHAR(10), 
    IN newClavePregunta VARCHAR(10),
    IN newNumPregunta VARCHAR(5),
    IN newTipoPregunta VARCHAR(5),
    IN newDescripcion VARCHAR(500),
    IN newArchivado BOOL)
BEGIN
    DECLARE oldNumPregunta VARCHAR(5);
    DECLARE oldTipoPregunta VARCHAR(5);
    DECLARE oldArchivado BOOL;
    
    IF newClavePregunta IS NOT NULL THEN
		-- Obtener los valores existentes de los campos que no se van a actualizar
		SELECT NumPregunta, TipoPregunta, Archivado
		INTO oldNumPregunta, oldTipoPregunta, oldArchivado
		FROM Pregunta
		WHERE ClavePregunta = oldClavePregunta;

		-- Insert nueva linea en Pregunta con los valores existentes o los nuevos valores
		INSERT INTO Pregunta (ClavePregunta, NumPregunta, TipoPregunta, Descripcion, Archivado)
		SELECT newClavePregunta, COALESCE(newNumPregunta, oldNumPregunta), COALESCE(newTipoPregunta, oldTipoPregunta), 
			   COALESCE(newDescripcion, Descripcion), COALESCE(newArchivado, oldArchivado)
		FROM Pregunta
		WHERE ClavePregunta = oldClavePregunta;
        
        -- Control de Checks para asegurar transicion
		SET @skip_check = TRUE;

		-- Update foreign keys en tablas que hacen referencia a Pregunta
        
		UPDATE EncuestaGrupoPregunta
		SET ClavePregunta = newClavePregunta
		WHERE ClavePregunta = oldClavePregunta;

		UPDATE PreguntasProfesor
		SET ClavePregunta = newClavePregunta
		WHERE ClavePregunta = oldClavePregunta;

		UPDATE RespuestasAlumnos
		SET ClavePregunta = newClavePregunta,
        TipoPregunta = newTipoPregunta
		WHERE ClavePregunta = oldClavePregunta;
        
		-- Control de Checks para asegurar transicion
				SET @skip_check = FALSE;
                
		-- Delete row vieja
		DELETE FROM Pregunta
		WHERE ClavePregunta = oldClavePregunta;
        
	ELSE
        -- Update linea pregunta in Pregunta table
        UPDATE Pregunta
        SET NumPregunta = COALESCE(newNumPregunta, NumPregunta),
            TipoPregunta = COALESCE(newTipoPregunta, TipoPregunta),
            Descripcion = COALESCE(newDescripcion, Descripcion),
            Archivado = COALESCE(newArchivado, Archivado)
        WHERE ClavePregunta = oldClavePregunta;
    END IF;
END$$

-- Procedure que revisa las entradas de Respuesta
CREATE PROCEDURE sp_PreCheckRespuesta(
    IN claveEncuesta VARCHAR(5),
    IN crn	VARCHAR(10),
    IN matricula VARCHAR(9),
    IN clavePregunta VARCHAR(10),
    IN tipoPregunta VARCHAR(5),
    IN nomina	VARCHAR(9),
    IN tipoResp	VARCHAR(20),
    IN evaluacion	INT,
    IN comentario	VARCHAR(500),
    IN skip_check BOOL,
    OUT mensaje VARCHAR(100)
)
sp_PreCheckRespuesta:
BEGIN
    DECLARE numPreg INT;
    DECLARE encuestaCorrecta INT;
    DECLARE esProfesor INT;
    DECLARE enGrupo INT;
    DECLARE enGrupoValido INT;
    DECLARE tienePregunta INT;
	DECLARE tipoPreguntaEsperado VARCHAR(10);
    DECLARE esValido BOOLEAN;
    SET esValido = TRUE;
  IF NOT skip_check THEN 
    -- Verificar si la encuesta es correcta
    SELECT COUNT(*) INTO encuestaCorrecta
    FROM Encuesta e
    WHERE e.ClaveEncuesta = claveEncuesta;
    
    IF encuestaCorrecta = 0 THEN
        SET mensaje = 'La encuesta indicada no existe';
        SET esValido = FALSE;
        LEAVE sp_PreCheckRespuesta;
    END IF;
    
	-- Verificar si el CRN especificado pertenece a un grupo existente
	SELECT COUNT(*) INTO enGrupo
	FROM Grupo g
	WHERE g.CRN = crn;

	IF enGrupo = 0 THEN
        SET mensaje = 'El CRN especificado no pertenece a un grupo existente';
        SET esValido = FALSE;
        LEAVE sp_PreCheckRespuesta;
    END IF;

    -- Verificar si el alumno está en un grupo válido para la encuesta
    SELECT COUNT(*) INTO enGrupoValido
    FROM Grupo g
    JOIN AlumnoEnGrupo ag ON g.CRN = ag.CRN
    JOIN EncuestaGrupo eg ON g.CRN = eg.CRN AND eg.ClaveEncuesta = claveEncuesta
    WHERE ag.Matricula = matricula;
    
    IF enGrupoValido = 0 THEN
        SET mensaje = 'El alumno no está en un grupo válido para esta encuesta';
		SET esValido = FALSE;
        LEAVE sp_PreCheckRespuesta;
    END IF;
	
    -- Verificar si la pregunta está asignada a la encuesta
	SELECT COUNT(*) INTO numPreg
	FROM EncuestaGrupoPregunta egp
	WHERE egp.ClaveEncuesta = claveEncuesta AND egp.ClavePregunta = clavePregunta;
    
	IF numPreg = 0 AND NOT skip_check THEN
		SET mensaje = 'La pregunta no está asignada a la encuesta';
		SET esValido = FALSE;
        LEAVE sp_PreCheckRespuesta;
	ELSE
    -- Obtener el tipo de pregunta esperado para la pregunta en EncuestaGrupoPregunta
		SELECT DISTINCT p.TipoPregunta INTO tipoPreguntaEsperado
		FROM EncuestaGrupoPregunta egp
        JOIN Pregunta p ON egp.clavePregunta = p.clavePregunta
		WHERE egp.ClaveEncuesta = claveEncuesta AND egp.ClavePregunta = clavePregunta;
        
			-- Verificar si el tipo de pregunta es válido
		IF NOT (tipoPreguntaEsperado <=> tipoPregunta) THEN
			SET mensaje = 'El tipo de pregunta no es válido para la pregunta especificada';
            SET esValido = FALSE;
            LEAVE sp_PreCheckRespuesta;
		END IF;
	END IF;

    -- Verificar si el alumno tiene acceso a la pregunta
    SELECT COUNT(*) INTO tienePregunta
    FROM EncuestaGrupoPregunta egp
    JOIN Grupo g ON egp.CRN = g.CRN
    JOIN AlumnoEnGrupo ag ON g.CRN = ag.CRN
    JOIN Pregunta p ON egp.ClavePregunta = p.ClavePregunta
    WHERE ag.Matricula = matricula AND p.ClavePregunta = clavePregunta;
    
    IF tienePregunta = 0 THEN
		SET mensaje = 'El alumno no tiene acceso a la pregunta especificada';
		SET esValido = FALSE;
        LEAVE sp_PreCheckRespuesta;
	END IF;
    
    -- Verificar si el tipo de pregunta es válido
	IF (FIND_IN_SET(tipoPregunta, @TiposPreguntaProfesor) > 0 AND nomina IS NULL) THEN
		SET mensaje = "El tipo de pregunta debe llevar una Nomina";
		SET esValido = FALSE;
		LEAVE sp_PreCheckRespuesta;
	END IF;
    
	-- Verificar si la nomina es de un profesor valido
	IF nomina IS NOT NULL THEN
		SELECT COUNT(*) INTO esProfesor
		FROM ProfesorEnGrupo peg
		JOIN AlumnoEnGrupo aeg ON peg.CRN = aeg.CRN
		JOIN Grupo g ON aeg.CRN = g.CRN
		WHERE peg.Nomina = nomina and peg.CRN = crn;
		
		IF esProfesor = 0 THEN
			SET mensaje = "El profesor no es parte del grupo";
			SET esValido = FALSE;
			LEAVE sp_PreCheckRespuesta;
		END IF;
	END IF;
	
    -- Verifica si tipo de pregunta es válido
   IF (FIND_IN_SET(tipoPregunta, @TiposPreguntaUDF) > 0 AND nomina IS NOT NULL) THEN
		SET mensaje = "El tipo de pregunta no debe de llevar Nomina";
		SET esValido = FALSE;
		LEAVE sp_PreCheckRespuesta;
	END IF;
    
    -- Verificar si la evaluación es válida
	IF evaluacion < 0 OR evaluacion > 10 THEN
		SET mensaje = 'La evaluación indicada no es válida';
		SET esValido = FALSE;
        LEAVE sp_PreCheckRespuesta;
	END IF;
    
    -- Verificar si el comentario es válido
	IF LENGTH(comentario) > 500 THEN
		SET mensaje = 'El comentario excede el límite de caracteres permitidos';
		SET esValido = FALSE;
        LEAVE sp_PreCheckRespuesta;
	END IF;

   -- Establecer el mensaje de salida en base a si es válido o no
	IF esValido THEN
		SET mensaje = 'El alumno puede contestar la pregunta';
        LEAVE sp_PreCheckRespuesta;
	END IF;
	END IF;
END; $$

-- Procedure que revisa las entradas de Pregunta
CREATE PROCEDURE sp_PreCheckPregunta(
    IN clavePregunta VARCHAR(10),
    IN numPregunta VARCHAR(5),
    IN tipoPregunta VARCHAR(5),
    IN descripcion VARCHAR(500),
    IN archivado BOOL,
    OUT mensaje VARCHAR(100)
)
sp_PreCheckPregunta:
BEGIN
    DECLARE claveCorrecta INT;
    DECLARE numPreg INT;
    DECLARE tipoCorrecto INT;
    DECLARE descValida INT;

    -- Verificar si la clave es correcta
    IF clavePregunta IS NULL OR clavePregunta = '' OR clavePregunta NOT REGEXP '^(EB|EM|EC)' THEN
        SET mensaje = 'Clave incorrecta';
        LEAVE sp_PreCheckPregunta;
    END IF;

    -- Verificar si el número de pregunta es correcto
    IF numPregunta IS NULL OR numPregunta NOT REGEXP '^[0-9]+[a-z]?$' THEN
        SET mensaje = 'Número de pregunta incorrecto';
        LEAVE sp_PreCheckPregunta;
    END IF;

    -- Verificar si el tipo de pregunta es correcto
    IF ( tipoPregunta IS NULL  OR tipoPregunta != SUBSTRING(clavePregunta,3)) THEN
        SET mensaje = 'Tipo de pregunta incorrecto';
        LEAVE sp_PreCheckPregunta;
    END IF;

    -- Verificar si la descripción es válida
    IF descripcion IS NULL OR descripcion = '' THEN
        SET mensaje = 'Descripción inválida';
        LEAVE sp_PreCheckPregunta;
    END IF;

    SET mensaje = 'Pregunta es valida';
END; $$

-- Procedure que revisa las entradas de encuestas
CREATE PROCEDURE sp_PreCheckEncuesta(
	IN claveEncuesta VARCHAR(5),
    IN claveEA VARCHAR(10),
    IN descripcion VARCHAR(100),
    IN fechaIni DATE,
    IN fechaLim DATE,
    IN archivado BOOL,
    OUT mensaje VARCHAR(100)
)
sp_PreCheckEncuesta:
BEGIN
	-- Verificar si la clave es correcta
    IF claveEncuesta IS NULL OR claveEncuesta = '' OR claveEncuesta NOT REGEXP '^(E)' THEN
        SET mensaje = 'Clave incorrecta';
        LEAVE sp_PreCheckEncuesta;
    END IF;
    
    -- Verificar si la descripción es válida
    IF descripcion IS NULL OR descripcion = '' THEN
		SET mensaje = 'Descripción inválida';
		LEAVE sp_PreCheckEncuesta;
    END IF;
	
    SET mensaje = 'Encuesta es valida';
END; $$

-- Procedure que revisa si existen Respuestas y las cambia
CREATE PROCEDURE sp_CheckRespuestaUpdate(
IN claveEncuesta VARCHAR(5),
IN crn VARCHAR(10),
IN matricula VARCHAR(9),
IN clavePregunta VARCHAR(10),
IN tipoPregunta VARCHAR(5),
IN nomina VARCHAR(9),
IN tipoResp VARCHAR(20),
IN evaluacion INT,
IN comentario VARCHAR(500)
)
BEGIN
DECLARE mensaje VARCHAR(100);
SET @claveRespuesta = NULL;
SET @skip_check = FALSE;

SELECT ra.ClaveRespuesta INTO @claveRespuesta
FROM RespuestasAlumnos ra
WHERE ra.ClaveEncuesta = claveEncuesta
AND ra.CRN = crn
AND ra.Matricula = matricula
AND ra.ClavePregunta = clavePregunta
AND (ra.Nomina IS NULL OR ra.Nomina = nomina);

IF @claveRespuesta IS NOT NULL THEN
	UPDATE RespuestasAlumnos SET Evaluacion = evaluacion, Comentario = comentario WHERE ClaveRespuesta = @claveRespuesta;
ELSE 
    CALL sp_PreCheckRespuesta(claveEncuesta,crn,matricula, clavePregunta, tipoPregunta, nomina,tipoResp,evaluacion,comentario,@skip_check, mensaje);
    IF mensaje <> 'El alumno puede contestar la pregunta' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensaje;
    END IF;
	INSERT INTO RespuestasAlumnos VALUES (NULL,claveEncuesta,crn,matricula,clavePregunta,tipoPregunta,nomina,tipoResp,evaluacion,comentario);
END IF;

END; $$

-- Procedure que muestra todas las preguntas faltantes de un alumno
CREATE PROCEDURE sp_PreguntasFaltantesAlumno(
    IN matricula VARCHAR(9),
    IN nomina VARCHAR(9),
    IN excluir BOOLEAN)
BEGIN
SELECT egp.ClaveEncuesta, egp.CRN, egp.ClavePregunta, p.NumPregunta, pp.Nomina
FROM EncuestaGrupoPregunta egp
JOIN AlumnoEnGrupo aeg
    ON egp.CRN = aeg.CRN
    AND aeg.Matricula = matricula
LEFT JOIN PreguntasProfesor pp
    ON egp.ClaveEncuesta = pp.ClaveEncuesta
    AND egp.CRN = pp.CRN
    AND egp.ClavePregunta = pp.ClavePregunta
LEFT JOIN RespuestasAlumnos ra
    ON egp.ClaveEncuesta = ra.ClaveEncuesta
    AND egp.CRN = ra.CRN
    AND egp.ClavePregunta = ra.ClavePregunta
    AND (pp.Nomina IS NULL OR pp.Nomina = ra.Nomina)
    AND ra.Matricula = matricula
INNER JOIN Pregunta p ON p.ClavePregunta = egp.ClavePregunta
WHERE ra.ClaveRespuesta IS NULL
AND (nomina IS NULL OR pp.Nomina = nomina)
AND (excluir = FALSE OR pp.Nomina IS NULL)
ORDER BY (CASE WHEN pp.Nomina IS NULL THEN 1 ELSE 0 END), pp.Nomina, 
LEFT(p.ClavePregunta, 2), 
CAST((CASE WHEN REGEXP_SUBSTR(p.NumPregunta, '[a-zA-Z]') IS NULL THEN 
	p.NumPregunta ELSE SUBSTRING_INDEX(p.NumPregunta, REGEXP_SUBSTR(p.NumPregunta, '[a-zA-Z]'), 1) END) AS UNSIGNED), 
REGEXP_SUBSTR(p.NumPregunta, '[a-zA-Z]+$');
END; $$

-- Procedure que muestra el numero de las preguntas faltantes de un alumno
CREATE PROCEDURE sp_PreguntasFaltantesAlumnoINT(
    IN matricula VARCHAR(9),
    IN nomina VARCHAR(9),
    IN excluir BOOLEAN,
    IN crn VARCHAR(9),
    OUT NumPreguntasFaltantes INT)
BEGIN
    SELECT COUNT(*) INTO NumPreguntasFaltantes
    FROM EncuestaGrupoPregunta egp
    JOIN AlumnoEnGrupo aeg
        ON egp.CRN = aeg.CRN
        AND aeg.Matricula = matricula
    LEFT JOIN PreguntasProfesor pp
        ON egp.ClaveEncuesta = pp.ClaveEncuesta
        AND egp.CRN = pp.CRN
        AND egp.ClavePregunta = pp.ClavePregunta
    LEFT JOIN RespuestasAlumnos ra
        ON egp.ClaveEncuesta = ra.ClaveEncuesta
        AND egp.CRN = ra.CRN
        AND egp.ClavePregunta = ra.ClavePregunta
        AND (pp.Nomina IS NULL OR pp.Nomina = ra.Nomina)
        AND ra.Matricula = matricula
    WHERE ra.ClaveRespuesta IS NULL
    AND (nomina IS NULL OR pp.Nomina = nomina)
    AND (excluir = FALSE OR pp.Nomina IS NULL)
    AND aeg.CRN = crn;
    END; $$

-- Procedure que modifica Encuestas
CREATE PROCEDURE sp_UpdateEncuesta(
    IN oldClaveEncuesta VARCHAR(5), 
    IN newClaveEncuesta VARCHAR(5),
    IN newClaveEA VARCHAR(10),
    IN newDescripcion VARCHAR(100),
    IN newFechaIni DATE,
    IN newFechaLim DATE,
    IN newArchivado BOOL)
BEGIN
    IF newClaveEncuesta IS NOT NULL THEN
        -- Insertar nueva linea en Encuesta con valores actualizados
        INSERT INTO Encuesta (ClaveEncuesta, ClaveEA, Descripcion, FechaIni, FechaLim, Archivado)
        SELECT newClaveEncuesta, COALESCE(newClaveEA, ClaveEA), COALESCE(newDescripcion, Descripcion), 
               COALESCE(newFechaIni, FechaIni), COALESCE(newFechaLim, FechaLim), COALESCE(newArchivado, Archivado)
        FROM Encuesta
        WHERE ClaveEncuesta = oldClaveEncuesta;
	
		-- Control de Checks para asegurar transicion
		SET @skip_check = TRUE;
        
        -- Actualizar foreign keys en otras tablas que hagan referencia a Encuesta
        UPDATE EncuestaGrupo
        SET ClaveEncuesta = newClaveEncuesta
        WHERE ClaveEncuesta = oldClaveEncuesta;
        
        UPDATE EncuestaGrupoPregunta
		SET ClaveEncuesta = newClaveEncuesta
		WHERE ClaveEncuesta = oldClaveEncuesta;
        
        UPDATE PreguntasProfesor
		SET ClaveEncuesta = newClaveEncuesta
		WHERE ClaveEncuesta = oldClaveEncuesta;
        
		UPDATE EncuestasAlumnos
		SET ClaveEncuesta = newClaveEncuesta
		WHERE ClaveEncuesta = oldClaveEncuesta;

		UPDATE RespuestasAlumnos
		SET ClaveEncuesta = newClaveEncuesta
		WHERE ClaveEncuesta = oldClaveEncuesta;
        
        -- Control de Checks para asegurar transicion
		SET @skip_check = FALSE;
        
        -- Delete linea vieja
        DELETE FROM Encuesta
        WHERE ClaveEncuesta = oldClaveEncuesta;
        
    ELSE
        -- Actualizar linea existente en Encuesta
        UPDATE Encuesta e
        SET e.ClaveEA = COALESCE(newClaveEA, e.ClaveEA),
            e.Descripcion = COALESCE(newDescripcion, e.Descripcion),
            e.FechaIni = COALESCE(newFechaIni, e.FechaIni),
            e.FechaLim = COALESCE(newFechaLim, e.FechaLim),
            e.Archivado = COALESCE(newArchivado, e.Archivado)
        WHERE e.ClaveEncuesta = oldClaveEncuesta;
    END IF;
END; $$

-- Procedure que regresa todas los grupos para una encuesta
CREATE PROCEDURE sp_GruposParaEncuesta(
IN claveEncuesta VARCHAR (5),
IN semana INT)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS tempGruposParaEncuesta;
    CREATE TEMPORARY TABLE tempGruposParaEncuesta (CRN VARCHAR(10), ClaveMateria VARCHAR(50), ClaveEA VARCHAR(10), ClaveCampus VARCHAR(5));
	IF SEMANA IS NOT NULL THEN
		SET @fechaFin = DATE_ADD((SELECT FechaIni FROM Encuesta e WHERE e.ClaveEncuesta = claveEncuesta LIMIT 1), INTERVAL semana - 1 WEEK);
        INSERT IGNORE INTO tempGruposParaEncuesta(CRN,ClaveMateria,ClaveEA,ClaveCampus)
		SELECT g.CRN, g.ClaveMateria, g.ClaveEA, g.ClaveCampus
		FROM grupo g
		JOIN encuesta e
		ON g.ClaveEA = e.ClaveEA
		WHERE g.FechaFin BETWEEN e.FechaIni AND e.FechaLim 
		AND e.ClaveEncuesta = claveEncuesta
		AND (e.Archivado IS NULL OR e.Archivado = FALSE)
		AND (WEEK(g.FechaFin)= WEEK(@fechaFin)
			OR g.Activo = TRUE);
            
		SELECT e.descripcion, g.CRN, g.ClaveMateria, g.ClaveCampus, g.FechaFin
		FROM grupo g
		JOIN encuesta e
		ON g.ClaveEA = e.ClaveEA
		WHERE g.FechaFin BETWEEN e.FechaIni AND e.FechaLim 
		AND e.ClaveEncuesta = claveEncuesta
		AND (e.Archivado IS NULL OR e.Archivado = FALSE)
		AND (WEEK(g.FechaFin)= WEEK(@fechaFin)
			OR g.Activo = TRUE);
            
	ELSE 
		INSERT INTO tempGruposParaEncuesta (CRN, ClaveMateria, ClaveEA, ClaveCampus)
        SELECT g.CRN, g.ClaveMateria,g.ClaveEA, g.ClaveCampus
		FROM grupo g
		JOIN encuesta e
		ON g.ClaveEA = e.ClaveEA
		WHERE e.ClaveEncuesta = claveEncuesta
		AND (e.Archivado IS NULL OR e.Archivado = FALSE)
		AND g.Activo = TRUE;
        
        SELECT e.descripcion, g.CRN, g.ClaveMateria,g.ClaveEA, g.FechaFin
		FROM grupo g
		JOIN encuesta e
		ON g.ClaveEA = e.ClaveEA
		WHERE e.ClaveEncuesta = claveEncuesta
		AND (e.Archivado IS NULL OR e.Archivado = FALSE)
		AND g.Activo = TRUE;
	END IF;
END; $$

-- Procedure que revisa si la encuesta esta completada
CREATE PROCEDURE sp_CheckEncuestaCompletada(
    IN matricula VARCHAR(9),
    IN claveEncuesta VARCHAR(64),
    IN crn VARCHAR(64))
BEGIN
    DECLARE numPreguntasFaltantes INT;
    CALL sp_PreguntasFaltantesAlumnoINT(matricula, NULL, FALSE,crn,NumPreguntasFaltantes);
    IF numPreguntasFaltantes = 0 THEN
        UPDATE EncuestasAlumnos ea
        SET ea.Contestada = TRUE
        WHERE ea.Matricula = matricula
        AND ea.ClaveEncuesta = claveEncuesta
        AND ea.CRN = crn;
	ELSE
		UPDATE EncuestasAlumnos ea
        SET ea.Contestada = FALSE
        WHERE ea.Matricula = matricula
        AND ea.ClaveEncuesta = claveEncuesta
        AND ea.CRN = crn;
	END IF; 
END; $$

-- Procedure que crea todas los grupos encuestados por encuesta
CREATE PROCEDURE sp_CrearEncuestasGrupos(
IN claveEncuesta VARCHAR(5),
IN crn	VARCHAR(10),
IN semana INT)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS tempGrupos;
    CREATE TEMPORARY TABLE tempGrupos (CRN VARCHAR(10), ClaveMateria VARCHAR(50), ClaveEA VARCHAR(10), ClaveCampus VARCHAR(5));
    
    IF crn IS NOT NULL THEN
        INSERT INTO tempGrupos (CRN, ClaveMateria, ClaveEA, ClaveCampus)
        SELECT g.CRN, g.ClaveMateria, g.ClaveEA, g.ClaveCampus
        FROM grupo g
        WHERE g.CRN = crn;
   ELSE
    CALL sp_GruposParaEncuesta(claveEncuesta,semana);
    
    INSERT INTO tempGrupos (CRN, ClaveMateria, ClaveEA, ClaveCampus)
    SELECT tgpe.CRN, tgpe.ClaveMateria, tgpe.ClaveEA, tgpe.ClaveCampus FROM tempGruposParaEncuesta tgpe;
    
    DROP TEMPORARY TABLE IF EXISTS tempGruposParaEncuesta;
	END IF;
    
    INSERT IGNORE INTO encuestagrupo (ClaveEncuesta, CRN, ClaveMateria, ClaveEA)
    SELECT claveEncuesta, tg.CRN, tg.ClaveMateria, tg.ClaveEA FROM tempGrupos tg;
END; $$

-- Procedure que elimina todos los grupos encuestados por encuesta
CREATE PROCEDURE sp_BorrarGruposEncuesta(
IN claveEncuesta VARCHAR(5),
IN crn	VARCHAR(10),
IN semana INT)
BEGIN
    IF crn IS NOT NULL THEN
        DELETE eg
        FROM encuestagrupo eg
        JOIN Grupo g ON g.CRN = eg.CRN
        WHERE eg.ClaveEncuesta = claveEncuesta
        AND eg.CRN = crn
        AND g.ClaveMateria = eg.ClaveMateria;
    ELSE
        IF SEMANA IS NOT NULL THEN
            SET @fechaFin = DATE_ADD((SELECT FechaIni FROM Encuesta e WHERE e.ClaveEncuesta = claveEncuesta LIMIT 1), INTERVAL semana - 1 WEEK);
            DELETE eg
            FROM encuestagrupo eg
            JOIN grupo g ON eg.CRN = g.CRN
            JOIN encuesta e ON eg.ClaveEncuesta = e.ClaveEncuesta
            WHERE g.FechaFin BETWEEN e.FechaIni AND e.FechaLim 
            AND e.ClaveEncuesta = claveEncuesta
            AND (e.Archivado IS NULL OR e.Archivado = FALSE)
            AND (WEEK(g.FechaFin)= WEEK(@fechaFin)
                OR g.Activo = TRUE);
        ELSE 
            DELETE eg
            FROM encuestagrupo eg
            JOIN grupo g ON eg.CRN = g.CRN
            JOIN encuesta e ON eg.ClaveEncuesta = e.ClaveEncuesta
            WHERE e.ClaveEncuesta = claveEncuesta
            AND (e.Archivado IS NULL OR e.Archivado = FALSE)
            AND g.Activo = TRUE;
        END IF;
    END IF;
END; $$

-- Procedure que modifica los tipos de pregunta disponibles
CREATE PROCEDURE sp_UpdateTipoPregunta(
IN accion VARCHAR(10),
IN tipoPregunta VARCHAR(5),
IN NewtipoPregunta VARCHAR(5),
IN objetivo BOOL)
BEGIN
	IF objetivo = TRUE THEN
		IF accion = "BORRAR" THEN
		UPDATE VariablesUsuario SET ValorVariable = TRIM(BOTH ',' FROM REPLACE(CONCAT(',', ValorVariable, ','), CONCAT(',', tipoPregunta, ','), ',')) WHERE NombreVariable = "TiposPreguntaProfesor";
		END IF;
		IF accion = "INSERT" AND (SELECT COUNT(*) FROM Pregunta p WHERE p.TipoPregunta = tipoPregunta) <= 1 THEN
		UPDATE VariablesUsuario SET ValorVariable = CONCAT(ValorVariable,",",tipoPregunta) WHERE NombreVariable = "TiposPreguntaProfesor";
		END IF;
        IF accion = "UPDATE" THEN
            IF (SELECT COUNT(*) FROM Pregunta p WHERE p.TipoPregunta = tipoPregunta) > 1 THEN
                UPDATE VariablesUsuario SET ValorVariable = CONCAT(ValorVariable,",",NewtipoPregunta) WHERE NombreVariable = "TiposPreguntaProfesor";
            ELSE
                UPDATE VariablesUsuario SET ValorVariable = REPLACE(ValorVariable,tipoPregunta,NewtipoPregunta) WHERE NombreVariable = "TiposPreguntaProfesor";
			END IF;
		END IF;
	END IF;
	IF objetivo = FALSE THEN
		IF accion = "BORRAR" THEN
		UPDATE VariablesUsuario SET ValorVariable = TRIM(BOTH ',' FROM REPLACE(CONCAT(',', ValorVariable, ','), CONCAT(',', tipoPregunta, ','), ',')) WHERE NombreVariable = "TiposPreguntaUDF";
		END IF;
		IF accion = "INSERT" AND (SELECT COUNT(*) FROM Pregunta p WHERE p.TipoPregunta = tipoPregunta) <= 1 THEN
		UPDATE VariablesUsuario SET ValorVariable = CONCAT(ValorVariable,",",tipoPregunta) WHERE NombreVariable = "TiposPreguntaUDF";
		END IF;
        IF accion = "UPDATE" THEN
            IF (SELECT COUNT(*) FROM Pregunta p WHERE p.TipoPregunta = tipoPregunta) > 1 THEN
                UPDATE VariablesUsuario SET ValorVariable = CONCAT(ValorVariable,",",NewtipoPregunta) WHERE NombreVariable = "TiposPreguntaUDF";
            ELSE
                UPDATE VariablesUsuario SET ValorVariable = REPLACE(ValorVariable,tipoPregunta,NewtipoPregunta) WHERE NombreVariable = "TiposPreguntaUDF";
			END IF;
		END IF;
	END IF;
END; $$

