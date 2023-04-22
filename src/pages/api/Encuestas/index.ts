import type { NextApiRequest, NextApiResponse } from 'next'

import { Encuesta } from '../../../types'
import { createPool } from 'mysql2/promise'
import { config } from '../conectionData'

interface Response {
    Msg: string,
    Encuestas: [Encuesta] | undefined
}

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const pool = createPool(config);
        const prompt = 'select * from Encuesta'
        pool.end()
        const [query]: any = await pool.query(prompt)
        pool.end()
        if (query.length > 0) {
            const encuestas: [Encuesta] = query as [Encuesta];
            res.status(200).json({
                Msg: 'Encuestas encontradas',
                Encuestas: encuestas,
            })

        }
    }
    catch (err: any) {
        res.status(400).send({ Msg: "Error: error al extraer las encuestas", Encuestas: undefined })
    }


}
function closePool() {
    throw new Error('Function not implemented.')
}

