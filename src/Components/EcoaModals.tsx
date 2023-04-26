import { Encuesta } from "@/types"
import { useState } from "react"

interface Props {
    encuestas: Encuesta[] | undefined
    getAllEncuestas: () => void
}
export function EcoaAddModal(props: Props) {

    const [encuesta, setEncuesta] = useState<Encuesta>()
    const [error, setError] = useState<string>("")
    const [success, setSuccess] = useState<string>("")
    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault()
        const encuestaActiva = props.encuestas?.find(encuestaA => encuestaA.ClaveEncuesta == encuesta?.ClaveEncuesta)
        if (encuestaActiva) {
            setError("Error: ya hay una encuesta Activa con esa clave, puedes modificar la encuesta pero no puedes crear una encuesta con la misma clave")
        }
        if (encuesta?.FechaLim == undefined || encuesta.FechaIni == undefined || isNaN(encuesta.FechaIni.getDate()) || isNaN(encuesta.FechaLim.getDate())) {
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

            props.getAllEncuestas()
            setEncuesta({
                ClaveEncuesta: "",
                ClaveEA: "",
                Descripcion: "",
                FechaIni: new Date,
                FechaLim: new Date,
                Archivado: 0
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
                    <input placeholder="Clave Encuesta" className="input input-bordered" onChange={e => setEncuesta(encuesta => encuesta ? ({ ...encuesta, ClaveEncuesta: e.target.value }) : ({ ClaveEncuesta: e.target.value } as Encuesta))} />
                    <input placeholder="Clave EA" className="input input-bordered" onChange={e => setEncuesta(encuesta => encuesta ? ({ ...encuesta, ClaveEA: e.target.value }) : ({ ClaveEA: e.target.value } as Encuesta))} />
                    <input placeholder="Descripcion" className="input input-bordered" onChange={e => setEncuesta(encuesta => encuesta ? ({ ...encuesta, Descripcion: e.target.value }) : ({ Descripcion: e.target.value } as Encuesta))} />
                    <input placeholder="Fecha Inicial" type="date" className="input input-bordered" onChange={e => setEncuesta(encuesta => encuesta ? ({ ...encuesta, FechaIni: new Date(e.target.value) }) : { FechaIni: new Date(e.target.value) } as Encuesta)} />
                    <input placeholder="Fecha Limite" type="date" className="input input-bordered" onChange={e => setEncuesta(encuesta => encuesta ? ({ ...encuesta, FechaLim: new Date(e.target.value) }) : ({ FechaLim: new Date(e.target.value) } as Encuesta))} />
                    <button className="btn btn-primary mt-5">Agregar</button>
                </form>
            </div>
        </div>
    )

}

export function EcoaArchiveModal(props: Props) {
    const [encuesta, setEncuesta] = useState<Encuesta>()
    const [error, setError] = useState<string>("")
    const [success, setSuccess] = useState<string>("")
    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault()
        if (!encuesta) {
            setError("Error: Debe seleccionar una Encuesta")
        }
        else {
            const response = await fetch("/api/Encuestas/ArchiveOne", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                },
                body: JSON.stringify({ ClaveEncuesta: encuesta.ClaveEncuesta })
            }
            ).then(res => res.json())
            if (response.status == "success") {
                props.getAllEncuestas()
                setEncuesta({
                    ClaveEncuesta: "",
                    ClaveEA: "",
                    Descripcion: "",
                    FechaIni: new Date,
                    FechaLim: new Date,
                    Archivado: 1
                })
                setSuccess(response.Msg)
            }
            else {
                setError(response.Msg)
            }

        }
    }
    return (
        <div className="flex flex-col w-full  items-center h-full">
            <h1 className="text-3xl">Archivar una Encuesta</h1>
            <h3 className="text-xl text-error text-center">{error}</h3>
            <h3 className="text-xl text-success text-center">{success}</h3>
            <div className="h-3/4 flex flex-col justify-evenly w-full">
                <form className=" h-full flex flex-col justify-evenly w-full" onSubmit={e => { handleSubmit(e) }}>
                    <select className="select select-bordered" onChange={e => setEncuesta(props.encuestas?.find(encuestaAA => encuestaAA.ClaveEncuesta == e.target.value))} >
                        <option>Clave Encuesta</option>
                        {props.encuestas?.map(encuesta => (
                            <option key={encuesta.ClaveEncuesta}>
                                {encuesta.ClaveEncuesta}
                            </option>
                        ))}
                    </select>
                    <input disabled placeholder="Clave EA" className="input input-bordered" value={encuesta?.ClaveEA} />
                    <input disabled placeholder="Descripcion" className="input input-bordered" value={encuesta?.Descripcion} />
                    <input disabled placeholder="Fecha Inicial" className="input input-bordered" value={encuesta?.FechaIni.toString().substring(0, 10)} />
                    <input disabled placeholder="Fecha Limite" className="input input-bordered" value={encuesta?.FechaLim.toString().substring(0, 10)} />
                    <button className="btn btn-error mt-5">Archivar</button>
                </form>
            </div>
        </div>
    )

}
