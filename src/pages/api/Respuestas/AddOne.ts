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

        const nomina = respuesta.Nomina === '' ? null : respuesta.Nomina;
        
        const comentario = respuesta.Comentario === '' ? null : respuesta.Comentario;

        const evaluacion = respuesta.Evaluacion < 0 ? null : respuesta.Evaluacion;

        const pool: Pool = createPool(config)
        const prompt = `CALL sp_CheckRespuestaUpdate( ClaveEncuesta, CRN, Matricula, ClavePregunta, TipoPregunta, Nomina, TipoResp, Evaluacion, Comentario) values(? , ? , ? , ? , ? , ? , ? , ? , ? )`
        const [query] = await pool.query(prompt, [respuesta.ClaveEncuesta, respuesta.CRN, respuesta.Matricula, respuesta.ClavePregunta, respuesta.TipoPregunta, nomina, respuesta.TipoRespuesta, evaluacion, comentario])
        pool.end()
        res.status(200).json({ status: "success", Msg: 'Respuesta agregada' })
        
    }
    catch (err: any) {
        const respuesta = req.body as Respuesta
        res.status(500).json({ status: "error", Msg: err.message })
        console.log(respuesta)
    }
}


