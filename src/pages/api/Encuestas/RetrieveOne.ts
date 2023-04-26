
import type { NextApiRequest, NextApiResponse } from 'next'
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
        const claveEncuesta = req.body.ClaveEncuesta
        const pool: Pool = createPool(config)

        const prompt = `call sp_UpdateEncuesta(?,null,null,null,null,null ,0)`


        const [query]: any = await pool.query(prompt, [claveEncuesta])
        pool.end()
        res.status(200).json({ status: "success", Msg: 'Encuesta Recuperada' })
    }
    catch (err: any) {
        res.status(500).json({ status: "error", Msg: err.message })
    }
}


