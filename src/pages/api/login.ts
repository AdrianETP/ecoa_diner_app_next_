import type { NextApiRequest, NextApiResponse } from 'next'
import { Estudiante, Profesor, Colaborador } from '../../types'
import { createPool, Pool } from 'mysql2/promise'
import { config } from './conectionData'

interface Response {
    msg: string,
    user: Estudiante | Profesor | Colaborador | undefined
}
export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const email = req.body.email
        const Clave = req.body.clave
        const pool: Pool = createPool(config)
        let [rows]: any = await pool.query("select * from Alumno where correo=?", [email])
        if (rows[0]) {
            if (Clave == rows[0].Clave) {
                console.log("success")
                const finalUser: Estudiante = {
                    Correo: rows[0].Correo,
                    Matricula: rows[0].Matricula,
                    Nombre: rows[0].Nombre,
                    ApellidoPaterno: rows[0].ApellidoPaterno,
                    ApellidoMaterno: rows[0].ApellidoMaterno,

                }
                res.status(200).send({ msg: "se hizo el login con exito", user: finalUser })
            }
            else {
                console.log("clave incorrecta")
                throw "clave incorrecta"
            }
        }
        else {
            [rows] = await pool.query("select * from Profesor where Correo=?", [email])
            if (rows[0]) {
                if (Clave == rows[0].Clave) {
                    console.log(rows[0])
                    const finalUser: Profesor = {
                        Correo: rows[0].Correo as string,
                        Nomina: rows[0].Nomina as string,
                        Nombre: rows[0].Nombre as string,
                        ApellidoPaterno: rows[0].ApellidoPaterno as string,
                        ApellidoMaterno: rows[0].ApellidoMaterno as string,
                        ClaveCampus: rows[0].ClaveCampus as string,
                        Departamento: rows[0].Departamento as string
                    }
                    res.status(200).send({ msg: "se hizo el login con exito", user: finalUser })
                }
                else {
                    console.log("clave incorrecta")
                    throw "clave incorrecta"
                }

            }
            else {
                [rows] = await pool.query("select * from Colaborador where Correo=?", [email])
                if (rows[0]) {
                    if (Clave == rows[0].Clave) {
                        const finalUser: Colaborador = {
                            IdColaborador: rows[0].IdColaborador,
                            Nombre: rows[0].Nombre,
                            ApellidoPaterno: rows[0].ApellidoPaterno,
                            ApellidoMaterno: rows[0].ApellidoMaterno,
                            Telefono: rows[0].Telefono,
                            Correo: rows[0].Correo,
                        }
                        res.status(200).send({ msg: "se hizo el login con exito", user: finalUser })

                    }
                }
            }
        }
    }
    catch (err: unknown) {
        res.status(400).send({ msg: "error: no existe ese usuario", user: undefined })
    }


}
