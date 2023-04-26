import type { NextApiRequest, NextApiResponse } from 'next'
import { Grupo } from '../../../types'
import { createPool, Pool } from 'mysql2/promise'
import { config } from './../conectionData'



interface Response {
    Msg: string,
    Grupos: Grupo[] | undefined
}
export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const pool: Pool = createPool(config)
        let [rows]: any = await pool.query("select * from Grupo where Activo is not Null and Activo != 0")
        pool.end()
        console.log(rows)
        res.status(200).send({ Msg: "Success", Grupos: rows as Grupo[] })
    }
    catch (err: any) {
        res.status(400).send({ Msg: err.message, Grupos: undefined })
    }


}
