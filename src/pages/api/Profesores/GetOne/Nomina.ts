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
        const Nomina = req.body.Nomina
        const pool: Pool = createPool(config)
        let [rows]: any = await pool.query("Select * from Profesor where Nomina = ?", [Nomina])
        pool.end()
        console.log(rows)
        res.status(200).send({ Msg: "Success", Profesores: rows as Profesor[] })
    }
    catch (err: any) {
        res.status(400).send({ Msg: err.message, Profesores: undefined })
    }


}
