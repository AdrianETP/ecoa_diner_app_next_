import type { NextApiRequest, NextApiResponse } from 'next'
import { Grupo } from '../../../../types'
import { createPool, Pool } from 'mysql2/promise'
import { config } from './../../conectionData'



interface Response {
    Msg: string,
    Grupos: Grupo[] | undefined
}
export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const ClaveEncuesta = req.body.ClaveEncuesta
        const Matricula = req.body.Matricula
        const pool: Pool = createPool(config)
        let [rows]: any = await pool.query("select Grupo.CRN,Grupo.ClaveMateria,Grupo.ClaveEA,Grupo.ClaveCampus from EncuestasAlumnos inner join EncuestaGrupo on EncuestasAlumnos.ClaveEncuesta = EncuestaGrupo.ClaveEncuesta inner join Grupo on EncuestaGrupo.CRN = Grupo.CRN where Matricula = ? and EncuestasAlumnos.ClaveEncuesta = ?   ", [Matricula, ClaveEncuesta])
        pool.end()
        console.log(rows)
        res.status(200).send({ Msg: "Success", Grupos: rows as Grupo[] })
    }
    catch (err: any) {
        res.status(400).send({ Msg: err.message, Grupos: undefined })
    }


}
