import Navbar from '@/Components/Navbar'
import { Estudiante, EncuestaAlumno } from '../../types'
import React, { useEffect, useState } from 'react'


function Student() {
    const [user, setUser] = useState<Estudiante | undefined>(undefined)
    const [encuestasFaltantes, setEncuestasFaltantes] = useState<[EncuestaAlumno] | undefined >()
    const checkEncuestasFaltantes = async (matricula: string) => {

        const response = await fetch("/api/Encuestas/alumnoEncuestaFaltante", {
            method: "POST",
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ matricula: matricula })
        }).then(e => e.json())
        console.log(response)
        console.log("hello world")

        setEncuestasFaltantes(response)

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
                if (paramsUserJson) {
                    checkEncuestasFaltantes(paramsUserJson.Matricula)
                }
            } else {
                location.href = "/"
            }
        }
        else {
            location.href = "/"
        }
    }, [])
    const nombre: string = user?.Nombre + " " + user?.ApellidoPaterno + " " + user?.ApellidoMaterno
    return (

        <div className='w-screen h-screen bg-neutral-200'>
            {
                user ? (
                    <>
                        <Navbar nombre={nombre} />
                        <div className='w-screen h-2/3 flex justify-center items-center'>
                            {encuestasFaltantes ?
                                <div className='w-1/2 h-1/2 bg-error  text-error-content flex justify-center items-center rounded-md flex-col'>
                                    <h2 className='text-error-content text-2xl mb-3'>Tienes 1 ecoa sin hacer</h2>
                                    <button className='btn bg-error-content text-neutral-300' onClick={() => { location.replace("/Videogame?user=" + JSON.stringify(user)) }}>Empezar  Ecoa</button>
                                </div>
                                :
                                <div className='w-1/2 h-1/2 bg-success  text-error-content flex justify-center items-center rounded-md flex-col'>
                                    <h2 className='text-success-content text-2xl mb-3'>no te falta ninguna Ecoa</h2>
                                </div>
                            }
                        </div>
                    </>
                ) : (<div className='w-screen h-screen flex justify-center items-center text-3xl'><h1>Loading...</h1></div>)
            }

        </div >
    )

}

export default Student
