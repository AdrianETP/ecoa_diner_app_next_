import type { NextApiRequest, NextApiResponse } from 'next'
import { createPool, Pool } from 'mysql2/promise'
import { config } from '../conectionData'
import { Encuesta, Respuesta } from '@/types'

interface Response {
    status: "success" | "error",
    Msg: string,
}

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const respuesta = req.body as Respuesta
        const pool: Pool = createPool(config)
        const prompt = `insert into RespuestasAlumnos( ClaveEncuesta, CRN, Matricula, ClavePregunta, TipoPregunta, Nomina, TipoRespuesta, Evaluacion, Comentario,) values(? , ? , ? , ? , ? , ? , ? , ? , ? )`
        const [query] = await pool.query(prompt, [respuesta.ClaveEncuesta, respuesta.CRN, respuesta.Matricula, respuesta.ClavePregunta, respuesta.TipoPregunta, respuesta.Nomina, respuesta.TipoRespuesta, respuesta.Evaluacion, respuesta.Comentario])
        pool.end()
        res.status(200).json({ status: "success", Msg: 'Respuesta agregada' })
    }
    catch (err: any) {
        res.status(500).json({ status: "error", Msg: err.message })
    }
}


