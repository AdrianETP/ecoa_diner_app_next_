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
        const encuesta = req.body as Encuesta
        console.log(encuesta)
        const pool: Pool = createPool(config)

        const prompt = `insert into Encuesta(ClaveEncuesta, ClaveEA , Descripcion , FechaIni , FechaLim) values(? , ? , ? , ? , ? )`

        const [query]: any = await pool.query(prompt, [encuesta.ClaveEncuesta, encuesta.ClaveEA, encuesta.Descripcion, encuesta.FechaIni.toString().substring(0, 10), encuesta.FechaLim.toString().substring(0, 10)])
        pool.end()
        res.status(200).json({ status: "success", Msg: 'Pregunta agregada' })
    }
    catch (err: any) {
        res.status(500).json({ status: "error", Msg: err.message })
    }
}


