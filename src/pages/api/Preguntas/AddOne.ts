import type { NextApiRequest, NextApiResponse } from 'next'
import { Pregunta } from '../../../types'
import { createPool, Pool } from 'mysql2/promise'
import { config } from '../conectionData'

interface Response {
    status: "success" | "error",
    Msg: string,
}

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const pregunta = req.body
        const pool: Pool = createPool(config)

        const prompt = `insert into Pregunta(ClavePregunta, TipoPregunta , Descripcion , Archivado , NumPregunta) values(? , ? , ? , ? , ? )`

        const [query]: any = await pool.query(prompt, [pregunta.ClavePregunta, pregunta.TipoPregunta, pregunta.Descripcion, pregunta.Archivado, pregunta.NumPregunta])
        pool.end()
        res.status(200).json({ status: "success", Msg: 'Pregunta agregada' })
    }
    catch (err: any) {
        res.status(500).json({ status: "error", Msg: err.message })
    }
}


