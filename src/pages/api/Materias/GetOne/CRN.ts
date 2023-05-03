import type { NextApiRequest, NextApiResponse } from 'next'
import { createPool, Pool } from 'mysql2/promise'
import { config } from './../../conectionData'
import {Profesor} from '@/types'



interface Response {
    Msg: string,
    Materias: any | undefined
}
export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const CRN = req.body.CRN
        const pool: Pool = createPool(config)
        let [rows]: any = await pool.query("Select * from UDF inner join Grupo on UDF.ClaveMateria=Grupo.ClaveMateria where Grupo.CRN=?", [CRN])
        pool.end()
        console.log(rows)
        res.status(200).send({ Msg: "Success", Materias: rows as Profesor[] })
    }
    catch (err: any) {
        res.status(400).send({ Msg: err.message, Materias: undefined })
    }


}
