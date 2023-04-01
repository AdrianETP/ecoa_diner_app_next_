import Navbar from '@/Components/Navbar'
import { Estudiante } from '../../types'
import React, { useEffect, useState } from 'react'


function Student() {
    const [user, setUser] = useState<Estudiante | undefined>(undefined)
    useEffect(() => {
        const params = new URLSearchParams(location.search)
        const paramUserString: string | null = params.get("user")
        const sessionUserString: string | null = window.sessionStorage.getItem("user");
        if (paramUserString != null && sessionUserString != null) {
            console.log("no son nulos")
            const paramsUserJson = JSON.parse(paramUserString);
            const sessionUserJson = JSON.parse(sessionUserString);
            if (JSON.stringify(paramsUserJson) == JSON.stringify(sessionUserJson)) {
                console.log("son iguales")
                setUser(JSON.parse(paramUserString));
            }
        }

    }, [])
    const nombre: string = user?.nombre + " " + user?.apellidoPaterno + " " + user?.apellidoMaterno
    return (
        <div className='w-screen h-screen bg-neutral-200'>
            <Navbar nombre={nombre} />
            <div className='w-screen h-2/3 flex justify-center items-center'>
                <div className='w-1/2 h-1/2 bg-error  text-error-content flex justify-center items-center rounded-md flex-col'>
                    <h2 className='text-error-content text-2xl mb-3'>Tienes 1 ecoa sin hacer</h2>
                    <button className='btn bg-error-content text-neutral-300' onClick={() => { location.replace("/Videogame?user=" + JSON.stringify(user)) }}>Empezar  Ecoa</button>
                </div>
            </div>

        </div >
    )

}

export default Student
