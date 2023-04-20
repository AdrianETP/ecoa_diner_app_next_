import type { NextApiRequest, NextApiResponse } from 'next'

import { EncuestaAlumno } from '../../../types'
import { createPool, Pool, PoolOptions } from 'mysql2/promise'
import { config } from '../conectionData'

interface Response {
    Msg: string,
    Preguntas: [any] | undefined
}

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const { Matricula, ClaveEncuesta, Nomina, ClaveMateria } = req.body
        const pool: Pool = createPool(config)

        const prompt = `
        SELECT distinct p.ClavePregunta , p.TipoPregunta, p.Descripcion  from EncuestasPreguntas ep
        inner join EncuestasAlumnos ea
        on ep.ClaveEncuesta = ea.ClaveEncuesta
        inner join Encuesta e
        on ea.ClaveEncuesta = e.ClaveEncuesta
        inner join Pregunta p
        on p.ClavePregunta = ep.ClavePregunta
        inner join ProfesorEnGrupo peg
        on e.CRN = peg.CRN
        left join RespuestasAlumnos ra
        on ra.ClavePregunta = ep.ClavePregunta and ea.Matricula = ra.Matricula
        where ea.Matricula = ?
        and 
        ea.ClaveEncuesta = ?
        and 
        peg.nomina = ?
        and
        peg.ClaveMateria = ?
        and 
        ra.ClaveRespuesta is null;
        `

        const [query]: any = await pool.query(prompt, [Matricula, ClaveEncuesta, Nomina, ClaveMateria])
        if (query[0]) {
            const preguntas = query;
            const response: Response = {
                Msg: "Se encontraron preguntas pendientes",
                Preguntas: preguntas
            }
            res.send(response)
        } else {
            res.send({ Msg: "no se encontraron respuestas pendientes", Preguntas: undefined })

        }

    }
    catch (err: any) {
        res.status(400).send(err)
    }


}
