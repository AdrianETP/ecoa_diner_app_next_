import type { NextApiRequest, NextApiResponse } from 'next'

import { EncuestaAlumno } from '../../../types'
import { createPool, Pool, PoolOptions } from 'mysql2/promise'
import { config } from '../conectionData'

interface Response {
    Msg: string,
    Encuestas: [EncuestaAlumno] | undefined
}

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const { matricula } = req.body
        const pool: Pool = createPool(config)
        const currentDate: Date = new Date()

        const prompt = `
         select * from EncuestasAlumnos 
         inner join Encuesta 
         on EncuestasAlumnos.ClaveEncuesta = Encuesta.ClaveEncuesta
         where 
         Matricula = ? and
         FechaIni <= ? and
         FechaLim > ?
             `

        const [query]: any = await pool.query(prompt, [matricula, currentDate, currentDate])
        if (query[0]) {
            const encuestas = query;
            const response: Response = {
                Msg: "Se encontraron respuestas pendientes",
                Encuestas: encuestas
            }
            res.send(response)
        } else {
            res.send({ Msg: "no se encontraron respuestas pendientes", Encuestas: undefined })

        }

    }
    catch (err: any) {
        res.status(400).send(err)
    }


}
