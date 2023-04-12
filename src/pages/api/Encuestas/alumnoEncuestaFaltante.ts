import type { NextApiRequest, NextApiResponse } from 'next'
import { EncuestaAlumno } from '@/types'
import { createPool, Pool, PoolOptions } from 'mysql2/promise'
import { config } from '../conectionData'

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<EncuestaAlumno>
) {
    try {
        const { matricula } = req.body
        const pool: Pool = createPool(config);
        let [rows] = await pool.query("select * from EncuestasAlumnos where Matricula= ?", [matricula])
        console.log("hello validacion encuestas")

    }
    catch (err: any) {
        res.status(400).send(err)
    }


}
