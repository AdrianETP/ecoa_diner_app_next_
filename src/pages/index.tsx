import { useEffect, useState } from "react"
import Login from "./Login"
import { User } from "./types"


export default function Home() {
    let userSession: string | null = null;
    if (typeof window != 'undefined') {
        userSession = window.sessionStorage.getItem("user")
    }
    const [user, setUser] = useState<User | undefined>(undefined)
    useEffect(() => {

        if (userSession != null) {
            let userJson = JSON.parse(userSession)
            setUser(userJson)
        }
    }, [])
    const ChangeUser = (newUser: User) => {
        setUser(newUser)
        if (typeof window != 'undefined') {
            window.sessionStorage.setItem("user", JSON.stringify(newUser))
        }
    }
    if (user == undefined) {
        return <Login ChangeUser={ChangeUser} />
    }
    else {
        return <h1 className="text-center text-3xl bg-primary text-primary-content py-3">hola {user.nombre + " " + user.apellidoPaterno + " " + user.apellidoMaterno}</h1>
    }
}
