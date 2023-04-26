import type { NextApiRequest, NextApiResponse } from 'next'
import { createPool, Pool } from 'mysql2/promise'
import { config } from '../conectionData'
import { Encuesta } from '@/types'

interface Response {
    status: "success" | "error",
    Msg: string,
}

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const Encuesta: Encuesta = req.body as Encuesta
        const pool: Pool = createPool(config)
        const prompt = `call sp_UpdateEncuesta(?,null,?,?,?,?,?)`
        const [query]: any = await pool.query(prompt, [Encuesta.ClaveEncuesta, Encuesta.ClaveEA, Encuesta.Descripcion, Encuesta.FechaIni.toString().substring(0,10), Encuesta.FechaLim.toString().substring(0,10), Encuesta.Archivado])
        pool.end()
        console.log(query[0])
        res.status(200).json({ status: "success", Msg: 'Pregunta Editada' })
    }
    catch (err: any) {
        res.status(500).json({ status: "error", Msg: err.message })
    }
}


