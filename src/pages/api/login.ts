import type { NextApiRequest, NextApiResponse } from 'next'
import { Estudiante, Profesor } from '../types'
import { createPool, Pool, PoolOptions } from 'mysql2/promise'
import { config } from './conectionData'

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Estudiante | Profesor | unknown>
) {
    try {
        const email = req.body.email
        const clave = req.body.clave
        const pool: Pool = await createPool(config)
        let [rows]: any = await pool.query("select * from Alumno where correo=?", [email])
        if (rows[0]) {
            if (clave == rows[0].clave) {
                console.log("success")
                const finalUser: Estudiante = {
                    correo: rows[0].correo,
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
        else {
            [rows] = await pool.query("select * from Profesor where correo=?", [email])
            if (rows[0]) {
                if (clave == rows[0].clave) {
                    console.log("success")
                    const finalUser: Profesor = {
                        correo: rows[0].correo,
                        nomina: rows[0].nomina,
                        nombre: rows[0].nombre,
                        apellidoPaterno: rows[0].apellidoPaterno,
                        apellidoMaterno: rows[0].apellidoMaterno,
                    }
                    res.status(200).send({ msg: "se hizo el login con exito", user: finalUser })
                }

            }
        }
    }
    catch (err: unknown) {
        res.status(400).send(err)
    }


}
