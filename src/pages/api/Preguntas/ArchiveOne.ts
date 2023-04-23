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
        const ClavePregunta = req.body
        const pool: Pool = createPool(config)

        const prompt = `update Pregunta set Archivado = 1 where ClavePregunta = ?`

        const [query]: any = await pool.query(prompt, [ClavePregunta])
        pool.end()
        res.status(200).json({ Msg: 'Pregunta Archivada', status: "success" })
    }
    catch (err: any) {
        res.status(500).json({ Msg: err.message, status: "error" })
    }
}


