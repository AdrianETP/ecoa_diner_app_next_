import type { NextApiRequest, NextApiResponse } from 'next'

import { UDF } from '@/types'
import { createPool, Pool } from 'mysql2/promise'
import { config } from './../../conectionData'



interface Response {
    Msg: string,
    Materias: UDF | undefined
}
export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const Materia = req.body
        const pool: Pool = createPool(config)
        let [rows]: any = await pool.query("Select UDF.ClaveMateria, UDF.NombreMateria, UDF.TipoUDF from UDF inner join Grupo on UDF.ClaveMateria=Grupo.ClaveMateria where Grupo.CRN=?", [Materia.CRN])
        pool.end()
        console.log(rows)
        res.status(200).send({ Msg: "Success", Materias: rows as UDF })
    }
    catch (err: any) {
        console.log(err)
        res.status(400).send({ Msg: err.message, Materias: undefined })
    }


}