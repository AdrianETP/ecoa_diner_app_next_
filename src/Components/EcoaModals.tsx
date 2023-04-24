import { Encuesta } from "@/types"
import { useState } from "react"

interface Props {
    encuestas: Encuesta[] | undefined
    getAllEncuestas: () => void
}
export function EcoaAddModal(props: Props) {

    const [encuesta, setEncuesta] = useState<Encuesta>(
        {
            ClaveEncuesta: "",
            ClaveEA: "",
            Descripcion: "",
            FechaIni: new Date,
            FechaLim: new Date,

        }
    )
    const [error, setError] = useState<string>("")
    const [success, setSuccess] = useState<string>("")
    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault()
        console.log(encuesta)
        const encuestaActiva = props.encuestas?.find(encuestaA => encuestaA.ClaveEncuesta == encuesta.ClaveEncuesta)
        if (encuestaActiva) {
            setError("Error: ya hay una encuesta Activa con esa clave, puedes modificar la encuesta pero no puedes crear una encuesta con la misma clave")
        }
        if (isNaN(encuesta.FechaIni.getDate()) || isNaN(encuesta.FechaLim.getDate())) {
            setError("Error: Fecha Inicial y Fecha Limite deben fechas validas")
        }

        const response = await fetch("/api/Encuestas/AddOne", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Accept": "application/json"
            },
            body: JSON.stringify(encuesta)

        }).then(res => res.json())

        props.getAllEncuestas()
        if (response.status == "success") {

            setEncuesta({
                ClaveEncuesta: "",
                ClaveEA: "",
                Descripcion: "",
                FechaIni: new Date,
                FechaLim: new Date,
            })
            setSuccess(response.Msg)
        }
        else {
            setError(response.Msg)

        }



    }
    return (
        <div className="flex flex-col w-full  items-center h-full">
            <h1 className="text-3xl">Agregar una Encuesta</h1>
            <h3 className="text-xl text-error text-center">{error}</h3>
            <h3 className="text-xl text-success text-center">{success}</h3>
            <div className="h-3/4 flex flex-col justify-evenly w-full">
                <form className=" h-full flex flex-col justify-evenly w-full" onSubmit={e => { handleSubmit(e) }}>
                    <input placeholder="Clave Encuesta" className="input input-bordered" onChange={e => setEncuesta(encuesta => ({ ...encuesta, ClaveEncuesta: e.target.value }))} />
                    <input placeholder="Clave EA" className="input input-bordered" onChange={e => setEncuesta(encuesta => ({ ...encuesta, ClaveEA: e.target.value }))} />
                    <input placeholder="Descripcion" className="input input-bordered" onChange={e => setEncuesta(pregunta => ({ ...pregunta, Descripcion: e.target.value }))} />
                    <input placeholder="Fecha Inicial" className="input input-bordered" onChange={e => setEncuesta(pregunta => ({ ...pregunta, FechaIni: new Date(e.target.value) }))} />
                    <input placeholder="Fecha Limite" className="input input-bordered" onChange={e => setEncuesta(pregunta => ({ ...pregunta, FechaLim: new Date(e.target.value) }))} />
                    <button className="btn btn-primary mt-5">Agregar</button>
                </form>
            </div>
        </div>
    )

}

export function EcoaDeleteModal() {

}
