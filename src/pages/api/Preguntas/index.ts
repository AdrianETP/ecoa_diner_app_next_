
import type { NextApiRequest, NextApiResponse } from 'next'

import { Pregunta } from '../../../types'
import { createPool, Pool } from 'mysql2/promise'
import { config } from '../conectionData'

interface Response {
    Msg: string,
    Preguntas: [Pregunta] | undefined
}

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const pool: Pool = createPool(config)

        const prompt = `
        Select * from Pregunta order by NumPregunta , ClavePregunta;
        `

        const [query]: any = await pool.query(prompt)
        pool.end()
        if (query[0]) {
            const preguntas = query as [Pregunta];
            const response: Response = {
                Msg: "se encontraron preguntas",
                Preguntas: preguntas
            }
            res.send(response)
        } else {
            res.send({ Msg: "no se encontraron preguntas", Preguntas: undefined })

        }

    }
    catch (err: any) {
        res.status(400).send(err)
    }


}
