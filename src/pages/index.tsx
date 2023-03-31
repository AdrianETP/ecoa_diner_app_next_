import { useEffect, useState } from "react"
import Login from "../Login"
import { Estudiante, Profesor } from "./types"


export default function Home() {
    let userSession: string | null = null;
    if (typeof window != 'undefined') {
        userSession = window.sessionStorage.getItem("user")
    }
    const [user, setUser] = useState<Estudiante | Profesor | undefined>(undefined)
    useEffect(() => {
        if (userSession != null) {
            let userJson = JSON.parse(userSession)
            setUser(userJson)
        }
    }, [])
    const ChangeUser = (newUser: Estudiante | Profesor | undefined) => {
        setUser(newUser)
        if (typeof window != 'undefined') {
            if (!newUser) {
                window.sessionStorage.removeItem("user")
            }
            else {

                window.sessionStorage.setItem("user", JSON.stringify(newUser))
            }
        }
    }
    if (user == undefined) {
        return <Login ChangeUser={ChangeUser} />
    }
    else {
        if ("nomina" in user) {
            return (<div>
                <h1 className="bg-primary text-primary-content p-2 text-center text-xl"> hola {user.nombre} , pagina de profesor</h1>

                <button className="btn" onClick={() => ChangeUser(undefined)}>cerrar sesion</button>
            </div>)
        }
        else if ("matricula" in user) {

        }

    }
}
