import type { NextApiRequest, NextApiResponse } from 'next'
import { Grupo, Profesor } from '../../../../types'
import { createPool, Pool } from 'mysql2/promise'
import { config } from './../../conectionData'



interface Response {
    Msg: string,
    Profesores: Profesor[] | undefined
}
export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const CRN = req.body.CRN
        const Matricula = req.body.Matricula
        const pool: Pool = createPool(config)
        const query = `
SELECT DISTINCT pp.Nomina
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
        AND pp.Nomina = ra.Nomina
        AND ra.Matricula =?
    WHERE ra.ClaveRespuesta IS NULL
    AND pp.CRN =?;
        `
        let [rows]: any = await pool.query(query, [Matricula, CRN])
        pool.end()
        console.log(rows)
        res.status(200).send({ Msg: "Success", Profesores: rows as Profesor[] })
    }
    catch (err: any) {
        res.status(400).send({ Msg: err.message, Profesores: undefined })
    }


}
