import Navbar from "@/Components/Navbar"
import { Calificaciones, Profesor } from "@/types"
import { useState, useEffect, } from "react"

export default function Maestro() {
    const [user, setUser] = useState<Profesor | undefined>(undefined)
    const [data, setData] = useState<Calificaciones[] | undefined>(undefined)
    const getData = async () => {
        const response = await fetch("/api/Profesores/Calificaciones",
            {
                method: "POST",
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'

                },
                body: JSON.stringify({
                    Nomina: user?.Nomina
                })
            }).then(res => res.json())
        console.log(response)
        setData(response.Calificaciones)

    }

    useEffect(() => {
        const params = new URLSearchParams(location.search)
        const paramUserString: string | null = params.get("user")
        const sessionUserString: string | null = window.sessionStorage.getItem("user");

        if (paramUserString != null && sessionUserString != null) {
            const paramsUserJson = JSON.parse(paramUserString);
            const sessionUserJson = JSON.parse(sessionUserString);
            if (JSON.stringify(paramsUserJson) == JSON.stringify(sessionUserJson)) {
                setUser(paramsUserJson);

            } else {
                location.href = "/"
            }
        }
        else {
            location.href = "/"
        }
    }, [])

    useEffect(() => {
        getData()
    }, [user])

    const nombre: string = user?.Nombre + " " + user?.ApellidoPaterno + " " + user?.ApellidoMaterno
    return (
        <div className='w-screen min-h-screen bg-neutral-200 '>
            {
                user ? (
                    <>
                        <Navbar nombre={nombre} />
                        <div className='w-screen h-2/3  flex flex-col items-center pt-3'>
                            <h1 className="text-3xl">Calificaciones</h1>
                            <div className="w-screen flex space-x-10 p-4 flex-wrap">
                                {data?.map((calificacion) => (<div key={calificacion.Nomina + calificacion.ASE_Prom} className="w-1/3 min-h-96 bg-white rounded-md p-4">
                                    <h1 className="text-xl font-bold">{calificacion.NombreMateria + " " + calificacion.Periodo + " Periodo"}</h1>
                                    <li  ><b>DOM_Prom: </b> {calificacion.DOM_Prom}</li>
                                    <li  ><b>RET_Prom: </b> {calificacion.RET_Prom}</li>
                                    <li  ><b>REC_Prom: </b> {calificacion.REC_Prom}</li>
                                    <li  ><b>ASE_Prom: </b> {calificacion.ASE_Prom}</li>
                                    <li  ><b>MET_Prom: </b> {calificacion.MET_Prom}</li>
                                    <li  ><b>AlumnosCandidatos: </b> {calificacion.AlumnosCandidatos}</li>
                                    <li  ><b>AlumnosQueOpinaron: </b> {calificacion.AlumnosQueOpinaron}</li>
                                    <li  ><b>Campus: </b> {calificacion.Campus}</li>
                                    <li  ><b>ClaveMateria: </b> {calificacion.ClaveMateria}</li>
                                    <li  ><b>EjercicioAcademico: </b> {calificacion.EjercicioAcademico}</li>
                                    <li  ><b>NombreMateria: </b> {calificacion.NombreMateria}</li>
                                    <li  ><b>Nomina: </b> {calificacion.Nomina}</li>
                                    <li  ><b>Participacion: </b> {calificacion.Participacion}</li>
                                    <li  ><b>Periodo: </b> {calificacion.Periodo}</li>
                                    <li  ><b>Region: </b> {calificacion.Region}</li>
                                    <li  ><b>Semanas: </b> {calificacion.Semanas}</li>
                                    <li  ><b>Term: </b> {calificacion.Term}</li>
                                    <li  ><b>TipodeUdF: </b> {calificacion.TipodeUdF}</li>

                                </div>))}
                            </div>
                        </div>
                    </>

                ) : (<div className='w-screen h-screen flex justify-center items-center text-3xl'><h1>Loading...</h1></div>)
            }
        </div >
    )
}

