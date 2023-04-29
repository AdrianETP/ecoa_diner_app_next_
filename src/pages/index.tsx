import { useEffect, useState } from "react"
import Login from "../Login"
import { Colaborador, Estudiante, Profesor } from "../types"


export default function Home() {
    let userSession: string | null = null;
    if (typeof window != 'undefined') {
        userSession = window.sessionStorage.getItem("user")
    }
    const [user, setUser] = useState<Estudiante | Profesor | Colaborador | undefined>(undefined)
    useEffect(() => {
        if (userSession != null) {
            let userJson = JSON.parse(userSession)
            setUser(userJson)
        }
    }, [])
    const ChangeUser = (newUser: Estudiante | Profesor | Colaborador | undefined) => {
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
        if ("Nomina" in user) {
            location.replace("/Profesor?user=" + JSON.stringify(user))
        }
        else if ("Matricula" in user) {
            location.replace("/Student?user=" + JSON.stringify(user))

        }
        else if ("IdColaborador" in user) {
            location.replace("/Admin?user=" + JSON.stringify(user))
        }
    }
}
