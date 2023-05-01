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
        const body = req.body
        const pool: Pool = createPool(config)

        const prompt = `call sp_UpdatePregunta(?, ?, ?, ?, ?, ?)`

        const [query] = await pool.query(prompt, [body.oldClavePregunta, body.newClavePregunta, body.newNumPregunta, body.newTipoPregunta, body.newDescripcion, body.newArchivado])
        pool.end()
        res.status(200).json({ status: "success", Msg: 'Pregunta Modificada' })
    }
    catch (err: any) {
        res.status(500).json({ status: "error", Msg: err.message })
    }
}


