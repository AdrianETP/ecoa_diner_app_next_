DELIMITER $$
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