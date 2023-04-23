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
        const ClavePregunta = req.body.ClavePregunta
        const pool: Pool = createPool(config)

        const prompt = `update Pregunta set Archivado = 0 where ClavePregunta = ?`

        const [query]: any = await pool.query(prompt, [ClavePregunta])
        pool.end()
        res.status(200).json({ status: "success", Msg: 'Pregunta Recuperada' })
    }
    catch (err: any) {
        res.status(500).json({ status: "error", Msg: err.message })
    }
}





