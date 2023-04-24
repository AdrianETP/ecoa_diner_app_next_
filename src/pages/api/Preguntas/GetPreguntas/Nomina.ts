import type { NextApiRequest, NextApiResponse } from 'next'
import { Pregunta } from '../../../../types'
import { createPool, Pool } from 'mysql2/promise'
import { config } from './../../conectionData'



interface Response {
    Msg: string,
    Preguntas: Pregunta[] | undefined
}
export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const Nomina = req.body.Nomina
        const CRN = req.body.CRN
        const pool: Pool = createPool(config)
        let [rows]: any = await pool.query("SELECT * from pregunta p INNER JOIN preguntasprofesor pp on p.`ClavePregunta` = pp.`ClavePregunta` where CRN = ? and Nomina = ? and (Archivado = 0 or Archivado is null);", [CRN, Nomina])
        pool.end()
        console.log(rows)
        res.status(200).send({ Msg: "Success", Preguntas: rows as Pregunta[] })
    }
    catch (err: any) {
        res.status(400).send({ Msg: err.message, Preguntas: undefined })
    }

}
