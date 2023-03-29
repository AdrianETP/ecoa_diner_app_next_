import type { NextApiRequest, NextApiResponse } from 'next'
import { User } from '../types'
import { createPool, Pool, PoolOptions } from 'mysql2/promise'
import { config } from './conectionData'

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<User | unknown>
) {
    try {
        const email = req.body.email
        const clave = req.body.password
        const pool: Pool = await createPool(config)
        const [rows]: any = await pool.query("select * from Alumno where correo=?", [email])
        console.log(rows[0].clave, "", clave)
        if (clave == rows[0].clave) {
            console.log("success")
            const finalUser: User = {
                type: "student",
                email: rows[0].correo,
                matricula: rows[0].matricula,
                nombre: rows[0].nombre,
                apellidoPaterno: rows[0].apellidoPaterno,
                apellidoMaterno: rows[0].apellidoMaterno,

            }
            res.status(200).send({ msg: "se hizo el login con exito", user: finalUser })
        }
        else {
            console.log("clave incorrecta")
            throw "clave incorrecta"
        }
    }
    catch (err: unknown) {
        res.status(400).send(err)
    }


}
