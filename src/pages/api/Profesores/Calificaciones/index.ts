import type { NextApiRequest, NextApiResponse } from 'next'
import { Calificaciones, Grupo, Profesor } from '../../../../types'
import { createPool, Pool } from 'mysql2/promise'
import { config } from './../../conectionData'



interface Response {
    Msg: string,
    Calificaciones: Calificaciones[] | undefined

}
export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const Nomina = req.body.Nomina
        const pool: Pool = createPool(config)
        let [rows]: any = await pool.query("Select * from informacionsesionprofesor where Nomina=?", [Nomina])
        pool.end()
        let CArray: Calificaciones[] = []
        for (let i = 0; i < rows.length; i++) {
            CArray.push({
                DOM_Prom: rows[i].DOM_Prom,
                RET_Prom: rows[i].RET_Prom,
                REC_Prom: rows[i].REC_Prom,
                ASE_Prom: rows[i].ASE_Prom,
                MET_Prom: rows[i].MET_Prom,
                AlumnosCandidatos: rows[i].AlumnosCandidatos,
                AlumnosQueOpinaron: rows[i].AlumnosQueOpinaron,
                Campus: rows[i].Campus,
                ClaveMateria: rows[i].ClaveMateria,
                EjercicioAcademico: rows[i].EjercicioAcademico,
                NombreMateria: rows[i].NombreMateria,
                Nomina: rows[i].Nomina,
                Participacion: rows[i].Participacion,
                Periodo: rows[i].Periodo,
                Region: rows[i].Region,
                Semanas: rows[i].Semanas,
                Term: rows[i].Term,
                TipodeUdF: rows[i].TipodeUdF,

            })
        }
        res.status(200).send({ Msg: "Success", Calificaciones: CArray })
    }
    catch (err: any) {
        res.status(400).send({ Msg: err.message, Calificaciones: undefined })
    }


}
