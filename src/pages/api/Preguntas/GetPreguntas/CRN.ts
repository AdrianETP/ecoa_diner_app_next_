
import type { NextApiRequest, NextApiResponse } from 'next'
import { Pregunta } from '../../../../types'
import { createPool, Pool } from 'mysql2/promise'
import { config } from './../../conectionData'



interface Response {
    Msg: string,
    Preguntas: {
        ClavePregunta: string,
        Descripcion: string
    }[] | undefined
}
export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const CRN = req.body.CRN
        const pool: Pool = createPool(config)
        const query = `SELECT egp.ClavePregunta as ClavePregunta, p.Descripcion as Descripcion
        FROM PreguntasProfesor pf 
        RIGHT JOIN EncuestaGrupoPregunta egp ON pf.ClavePregunta = egp.ClavePregunta 
        left Join Pregunta p ON egp.ClavePregunta = p.ClavePregunta
        WHERE Nomina IS NULL AND egp.CRN = ?`
        let [rows]: any = await pool.query(query, [CRN])
        pool.end()
        console.log(rows)
        res.status(200).send({ Msg: "Success", Preguntas: rows as Response['Preguntas'] })
    }
    catch (err: any) {
        res.status(400).send({ Msg: err.message, Preguntas: undefined })
    }

}
