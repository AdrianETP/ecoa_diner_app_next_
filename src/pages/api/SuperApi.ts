import type { NextApiRequest, NextApiResponse } from 'next'
import { createPool, Pool } from 'mysql2/promise'
import { Encuesta, EncuestaAlumno, Grupo, Pregunta, Profesor, SuperRespuesta } from '@/types'
import { config } from './conectionData'




interface Response {
    Msg: string,
    SuperRespuesta: SuperRespuesta[] | undefined

}
export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Response>
) {
    try {
        const Matricula = req.body.Matricula
        console.log(Matricula)
        const EncuestaResponse = await fetch("http://localhost:3000/api/Encuestas/alumnoEncuestaFaltante", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Accept": "application/json"
            },
            body: JSON.stringify({ matricula: Matricula }),
        }).then(res => res.json())
        console.log(EncuestaResponse)
        const EncuestaAlumno = EncuestaResponse.Encuestas ? EncuestaResponse.Encuestas as EncuestaAlumno[] : undefined
        if (!EncuestaAlumno) {
            throw "No se Encontro la Encuesta"
        }

        let Response: SuperRespuesta[] = []
        for (let i = 0; i < EncuestaAlumno.length; i++) {
            const pool: Pool = createPool(config)
            let UDFquery = "SELECT UDF.NombreMateria  FROM Grupo g JOIN UDF ON g.ClaveMateria = UDF.ClaveMateria WHERE g.CRN = ?;"
            const [query]: any = await pool.query(UDFquery, [EncuestaAlumno[i].CRN])
            pool.end()
            console.log(query)

            Response.push({
                CRN: EncuestaAlumno[i].CRN,
                Materia: query[0].NombreMateria,
                ProfePregunta: []
            })
            let ProfesoresResponse: { Msg: string, Profesores: Profesor[] } = await fetch("http://localhost:3000/api/Profesores/GetOne/GrupoProfeSinResponder", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                },
                body: JSON.stringify({
                    CRN: EncuestaAlumno[i].CRN,
                    Matricula: Matricula
                }),
            }).then(res => res.json())
            if (ProfesoresResponse.Profesores) {
                for (let j = 0; j < ProfesoresResponse.Profesores.length; j++) {
                    const PreguntasResponse = await fetch("http://localhost:3000/api/Preguntas/GetPreguntas/Nomina", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                            "Accept": "application/json"
                        },
                        body: JSON.stringify({
                            Nomina: ProfesoresResponse.Profesores[j].Nomina,
                            CRN: EncuestaAlumno[i].CRN
                        })
                    }).then(res => res.json())

                    Response[i].ProfePregunta.push({
                        Nomina: ProfesoresResponse.Profesores[j].Nomina,
                        Pregunta: PreguntasResponse.Preguntas
                    })

                }
                const PreguntasGeneralesResponse = await fetch("http://localhost:3000/api/Preguntas/GetPreguntas/CRN", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        "Accept": "application/json"
                    },
                    body: JSON.stringify({
                        CRN: EncuestaAlumno[i].CRN
                    })
                }).then(res => res.json())
                Response[i].ProfePregunta.push({
                    Nomina: "",
                    Pregunta: PreguntasGeneralesResponse.Preguntas
                })

            }


        }
        res.status(200).send({ Msg: "Success", SuperRespuesta: Response })



    }
    catch (err: any) {
        res.status(400).send({ Msg: err.message, SuperRespuesta: undefined })
    }


}
