DROP FUNCTION IF EXISTS f_FinEncuesta;
DELIMITER //
CREATE FUNCTION f_FinEncuesta()
RETURNS BOOLEAN
BEGIN
   -- Archiva la encuesta
    UPDATE encuesta
	SET Archivado = TRUE
	WHERE FechaLim <= CURRENT_DATE
	AND (Archivado IS NULL OR Archivado = FALSE);
    
    -- Transfiere los datos de RespuestasAlumnos a Respuestas Folios
    INSERT IGNORE INTO RespuestasFolios (ClaveEncuesta, CRN, Folio, ClavePregunta, TipoPregunta, Nomina, TipoResp, Evaluacion, Comentario)
	SELECT ra.ClaveEncuesta, 
        ra.CRN,
		DENSE_RANK() OVER (ORDER BY ra.Matricula) AS Folio, # Clasifica por fila, en este caso por matricula
		ra.ClavePregunta,
		ra.TipoPregunta, 
		ra.Nomina, 
		ra.TipoResp, 
		ra.Evaluacion, 
		ra.Comentario
	FROM RespuestasAlumnos ra;
    
RETURN true;
END//
DELIMITER ;