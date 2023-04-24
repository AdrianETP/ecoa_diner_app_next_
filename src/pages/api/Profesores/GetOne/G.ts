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
        const pool: Pool = createPool(config)
        let [rows]: any = await pool.query("Select Profesor.Nomina ,Profesor.Nombre ,Profesor.ApellidoPaterno ,Profesor.ApellidoMaterno ,Profesor.ClaveCampus  ,Profesor.Departamento ,Profesor.Clave from Profesor inner join ProfesorEnGrupo on ProfesorEnGrupo.Nomina = Profesor.Nomina where CRN = ?", [CRN])
        pool.end()
        console.log(rows)
        res.status(200).send({ Msg: "Success", Profesores: rows as Profesor[] })
    }
    catch (err: any) {
        res.status(400).send({ Msg: err.message, Profesores: undefined })
    }


}
