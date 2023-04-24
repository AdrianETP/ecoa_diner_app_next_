import handler from "@/pages/api/login"
import { Pregunta } from "@/types"
import { useState } from "react"

interface Props {
    preguntasActivas: Pregunta[] | undefined
    preguntasArchivadas: Pregunta[] | undefined
    getAllPreguntas: () => void
}
export function QuestionAddModal(props: Props) {
    const [pregunta, setPregunta] = useState<Pregunta>(
        {
            ClavePregunta: "",
            TipoPregunta: "",
            Descripcion: "",
            Archivado: null,
            NumPregunta: "",
        }
    )
    const [error, setError] = useState<string>("")
    const [success, setSuccess] = useState<string>("")
    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault()
        const preguntaActiva = props.preguntasActivas?.find(preguntaA => preguntaA.ClavePregunta == pregunta.ClavePregunta)
        const preguntaArchivada = props.preguntasArchivadas?.find(preguntaA => preguntaA.ClavePregunta == pregunta.ClavePregunta)
        if (preguntaActiva) {
            setError("Error: ya hay una pregunta Activa con esa clave, puedes modificar la pregunta pero no puedes crear una pregunta con la misma clave")
        }
        else if (preguntaArchivada) {
            setError("Error: ya hay una pregunta Archivada con esa clave, puedes recuperar la pregunta y modificarla pero no puedes crear una pregunta con la misma clave")
        }
        else if (pregunta.ClavePregunta == "" || pregunta.TipoPregunta == "" || pregunta.Descripcion == "" || pregunta.NumPregunta == "") {
            setError("Error: todos los campos son obligatorios")
        }

        else if (pregunta.ClavePregunta.substring(0, 2) != "EM" && pregunta.ClavePregunta.substring(0, 2) != "EB") {

            setError("Error: la clave debe empezar con EM o EB , tu clave empieza con" + pregunta.ClavePregunta.substring(0, 2))

        }
        else if (pregunta.ClavePregunta.length < 3) {
            setError("Error: la clave debe tener al menos 3 caracteres")

        }
        else if (pregunta.ClavePregunta.length > 10) {
            setError("Error: la clave debe tener como maximo 10 caracteres")
        }
        else if (pregunta.NumPregunta.length > 5 || pregunta.NumPregunta.length < 1) {
            setError("Error: el numero de pregunta debe tener como minimo 1 caracter y como maximo 10 caracteres")
        }
        else if (pregunta.TipoPregunta.length < 1 || pregunta.TipoPregunta.length > 5) {
            setError("Error: el tipo de pregunta es obligatorio")
        }
        else if (pregunta.Descripcion.length < 1 || pregunta.Descripcion.length > 500) {
            setError("Error: la descripcion debe tener como minimo 1 caracter y como maximo 500 caracteres y como minimo 1 caracter")
        }
        else if (pregunta.NumPregunta.length < 1 || pregunta.NumPregunta.length > 5) {
            setError("Error: el numero de pregunta debe tener como minimo 1 caracter y como maximo 5 caracteres")
        }
        else if (pregunta.ClavePregunta.substring(2) != pregunta.TipoPregunta) {
            setError("Error: la clave debe contener EM o EB + el tipo de pregunta")

        }
        else {
            setError("")
            const result = await fetch("/api/Preguntas/AddOne", {
                method: "POST",
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(pregunta)
            }).then(res => res.json())
            if (result.status == "success") {
                props.getAllPreguntas()
                setPregunta({
                    ClavePregunta: "",
                    TipoPregunta: "",
                    Descripcion: "",
                    Archivado: null,
                    NumPregunta: "",
                })
                setSuccess(result.message)

            }
            else {
                setError(result.message)
            }
        }

    }
    return (
        <div className="flex flex-col w-full  items-center h-full">
            <h1 className="text-3xl">Agregar una Pregunta</h1>
            <h3 className="text-xl text-error text-center">{error}</h3>
            <h3 className="text-xl text-success text-center">{success}</h3>
            <div className="h-3/4 flex flex-col justify-evenly w-full">
                <form className=" h-full flex flex-col justify-evenly w-full" onSubmit={e => { handleSubmit(e) }}>
                    <input placeholder="Clave Pregunta" className="input input-bordered" onChange={e => setPregunta(pregunta => ({ ...pregunta, ClavePregunta: e.target.value }))} />
                    <input placeholder="Tipo de Pregunta" className="input input-bordered" onChange={e => setPregunta(pregunta => ({ ...pregunta, TipoPregunta: e.target.value }))} />
                    <input placeholder="Descripcion de la Pregunta" className="input input-bordered" onChange={e => setPregunta(pregunta => ({ ...pregunta, Descripcion: e.target.value }))} />
                    <input placeholder="Numero de Pregunta" className="input input-bordered" onChange={e => setPregunta(pregunta => ({ ...pregunta, NumPregunta: e.target.value }))} />
                    <button className="btn btn-primary mt-5">Agregar</button>
                </form>
            </div>
        </div>
    )
}
export function QuestionModifyModal(props: Props) {
    const [pregunta, setPregunta] = useState<Pregunta>()
    const [success, setSuccess] = useState("")
    const [error, setError] = useState("")
    type Request = {
        oldClavePregunta: string,
        newClavePregunta: string | null,
        newTipoPregunta: string,
        newDescripcion: string,
        newNumPregunta: string,
        newArchivado: number | null
    }
    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        let request: Request = {
            oldClavePregunta: "",
            newClavePregunta: null,
            newTipoPregunta: "",
            newDescripcion: "",
            newNumPregunta: "",
            newArchivado: null,
        }
        e.preventDefault();
        if (!pregunta) {
            setError("Error: todos los campos son obligatorios")
            return
        }
        if (pregunta.ClavePregunta.substring(2) != pregunta.TipoPregunta) {
            request.oldClavePregunta = pregunta.ClavePregunta
            request.newClavePregunta = pregunta.ClavePregunta.substring(0, 2) + pregunta.TipoPregunta
            request.newTipoPregunta = pregunta.TipoPregunta
            request.newDescripcion = pregunta.Descripcion
            request.newNumPregunta = pregunta.NumPregunta
            request.newArchivado = pregunta.Archivado

        }
        else {
            request.oldClavePregunta = pregunta.ClavePregunta
            request.newTipoPregunta = pregunta.TipoPregunta
            request.newDescripcion = pregunta.Descripcion
            request.newNumPregunta = pregunta.NumPregunta
            request.newArchivado = pregunta.Archivado
        }
        if (request.newClavePregunta == "" || request.newTipoPregunta == "" || request.newDescripcion == "" || request.newNumPregunta == "") {
            setError("Error: todos los campos son obligatorios")

        }
        else {

            const result = await fetch("/api/Preguntas/ModifyOne", {
                method: "POST",
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(request)
            }).then(res => res.json())
            if (result.status == "success") {
                console.log(result)
                props.getAllPreguntas()
                setError("")
                setPregunta({
                    ClavePregunta: "",
                    TipoPregunta: "",
                    Descripcion: "",
                    Archivado: null,
                    NumPregunta: "",
                })
                setSuccess(result.Msg)
            }
            else {
                setError(result.Msg)
            }
        }
    }

    return (
        <div className="flex flex-col w-full  items-center h-full">
            <h1 className="text-3xl">Modificar una Pregunta</h1>
            <h3 className="text-xl text-error text-center">{error}</h3>
            <h3 className="text-xl text-success text-center">{success}</h3>
            <div className="h-3/4 flex flex-col justify-evenly w-full">
                <form className=" h-full flex flex-col justify-evenly w-full" onSubmit={(e) => handleSubmit(e)}>
                    <select className="select select-bordered" onChange={e => setPregunta(props.preguntasActivas?.find(pregunta => pregunta?.ClavePregunta == e.target.value))}>
                        <option disabled selected>Clave de la Pregunta</option>
                        {props.preguntasActivas?.map((pregunta: Pregunta) => (
                            <option key={pregunta.ClavePregunta}>{pregunta.ClavePregunta}</option>

                        ))}
                    </select>
                    <input placeholder="Tipo de Pregunta" className="input input-bordered" value={pregunta?.TipoPregunta} onChange={e => setPregunta(pregunta => (pregunta ? { ...pregunta, TipoPregunta: e.target.value } : undefined))} />
                    <input placeholder="Descripcion" className="input input-bordered" value={pregunta?.Descripcion} onChange={e => setPregunta(pregunta => (pregunta ? { ...pregunta, Descripcion: e.target.value } : undefined))} />
                    <input placeholder="Numero Pregunta" className="input input-bordered" value={pregunta?.NumPregunta} onChange={e => setPregunta(pregunta => (pregunta ? { ...pregunta, NumPregunta: e.target.value } : undefined))} />
                    <button className="btn btn-primary mt-5">Modificar</button>
                </form>
            </div>
        </div>
    )
}

export function QuestionDeleteModal(props: Props) {
    const [pregunta, setPregunta] = useState<Pregunta>()
    const [success, setSuccess] = useState("")
    const [error, setError] = useState("")
    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault()
        const result = await fetch("/api/Preguntas/ArchiveOne", {
            method: "POST",
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(pregunta?.ClavePregunta)
        }).then(res => res.json())

        if (result.status == "success") {
            props.getAllPreguntas()
            setPregunta({
                ClavePregunta: "",
                TipoPregunta: "",
                Descripcion: "",
                Archivado: null,
                NumPregunta: "",
            })
            setSuccess("Pregunta archivada correctamente")
        }
        else {
            setError("Error al archivar la pregunta")
        }
    }

    return (
        <div className="flex flex-col w-full  items-center h-full">
            <h1 className="text-3xl">Archivar Pregunta</h1>
            <h3 className="text-xl text-error text-center">{error}</h3>
            <h3 className="text-xl text-success text-center">{success}</h3>
            <div className="h-3/4 flex flex-col justify-evenly w-full">
                <form className=" h-full flex flex-col justify-evenly w-full" onSubmit={e => handleSubmit(e)}>
                    <select className="select select-bordered" onChange={e => setPregunta(props.preguntasActivas?.find(pregunta => pregunta?.ClavePregunta == e.target.value))}>
                        <option disabled selected>Clave de la Pregunta</option>
                        {props.preguntasActivas?.map((pregunta: Pregunta) => (
                            <option key={pregunta.ClavePregunta}>{pregunta.ClavePregunta}</option>

                        ))}
                    </select>
                    <input placeholder="Tipo de Pregunta" className="input input-bordered input-disabled" disabled value={pregunta?.TipoPregunta} onChange={e => setPregunta(pregunta => (pregunta ? { ...pregunta, TipoPregunta: e.target.value } : undefined))} />
                    <input placeholder="Descripcion" className="input input-bordered input-disabled" disabled value={pregunta?.Descripcion} />
                    <input placeholder="Numero Pregunta" className="input input-bordered input-disabled" disabled value={pregunta?.NumPregunta} />
                    <button className="btn btn-error mt-5">Archivar</button>
                </form>
            </div>
        </div>
    )
}


export function QuestionRetrieveModal(props: Props) {
    const [pregunta, setPregunta] = useState<Pregunta>()
    const [success, setSuccess] = useState("")
    const [error, setError] = useState("")
    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault()
        const result = await fetch("/api/Preguntas/RetrieveOne", {
            method: "POST",
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ ClavePregunta: pregunta?.ClavePregunta })
        }).then(res => res.json())
        if (result.status == "success") {
            props.getAllPreguntas()
            setPregunta({
                ClavePregunta: "",
                TipoPregunta: "",
                Descripcion: "",
                Archivado: null,
                NumPregunta: "",
            })
            console.log(result)
            setSuccess(result.Msg)
        }
        else {
            setError(result.Msg)
        }
    }
    return (
        <div className="flex flex-col w-full  items-center h-full">
            <h1 className="text-3xl">Recuperar Pregunta</h1>
            <h3 className="text-xl text-error text-center">{error}</h3>
            <h3 className="text-xl text-success text-center">{success}</h3>
            <div className="h-3/4 flex flex-col justify-evenly w-full">
                <form className=" h-full flex flex-col justify-evenly w-full" onSubmit={e => handleSubmit(e)}>
                    <select className="select select-bordered" onChange={e => setPregunta(props.preguntasArchivadas?.find(pregunta => pregunta?.ClavePregunta == e.target.value))} value={pregunta?.ClavePregunta}>
                        <option disabled selected>Clave de la Pregunta</option>
                        {props.preguntasArchivadas?.map((pregunta: Pregunta) => (
                            <option key={pregunta.ClavePregunta}>{pregunta.ClavePregunta}</option>

                        ))}
                    </select>
                    <input placeholder="Tipo de Pregunta" className="input input-bordered input-disabled" disabled value={pregunta?.TipoPregunta} onChange={e => setPregunta(pregunta => (pregunta ? { ...pregunta, TipoPregunta: e.target.value } : undefined))} />
                    <input placeholder="Descripcion" className="input input-bordered input-disabled" disabled value={pregunta?.Descripcion} />
                    <input placeholder="Numero Pregunta" className="input input-bordered input-disabled" disabled value={pregunta?.NumPregunta} />
                    <button className="btn btn-success mt-5">Recuperar</button>
                </form>
            </div>
        </div>
    )

}
