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
        const claveEncuesta = req.body.ClaveEncuesta
        const pool: Pool = createPool(config)

        const prompt = `update Encuesta set Archivado = 1 where ClaveEncuesta = ?`

        const [query]: any = await pool.query(prompt, [claveEncuesta])
        pool.end()
        res.status(200).json({ status: "success", Msg: 'Pregunta agregada' })
    }
    catch (err: any) {
        res.status(500).json({ status: "error", Msg: err.message })
    }
}


