import Navbar from "@/Components/Navbar"
import { Colaborador, Encuesta, Grupo, Pregunta } from "@/types"
import { useState, useEffect, ReactNode } from "react"
import { QuestionAddModal, QuestionDeleteModal, QuestionModifyModal, QuestionRetrieveModal } from "@/Components/QuestionModals"
import { EcoaAddModal, EcoaArchiveModal, EcoaEditModal, EcoaRetrieveModal } from "@/Components/EcoaModals"

export default function Admin() {
    const [user, setUser] = useState<Colaborador | undefined>(undefined)
    const [preguntasActivas, setPreguntasActivas] = useState<[Pregunta] | undefined>()
    const [preguntasArchivadas, setPreguntasArchivadas] = useState<[Pregunta] | undefined>()
    const [encuestas, setEncuestas] = useState<[Encuesta] | undefined>()
    const [encuestasArchivadas, setEncuestasArchivadas] = useState<[Encuesta] | undefined>()
    const [modal, setModal] = useState<ReactNode | undefined>(undefined)
    const [grupos, setGrupos] = useState<Grupo[] | undefined>(undefined)

    const getAllGrupos = async () => {
        const gruposJson = await fetch("/api/Grupos").then((res) => res.json())
        let gruposArray: Grupo[] | undefined = undefined
        for (const grupo of gruposJson.Grupos) {
            gruposArray ? gruposArray.push(grupo as Grupo) : gruposArray = [grupo as Grupo]
        }
        setGrupos(gruposArray ? gruposArray : undefined)
        console.log(gruposArray)
    }

    const getAllPreguntas = async () => {
        const preguntasJson = await fetch("/api/Preguntas").then((res) => res.json())
        let preguntasActivasArray: [Pregunta] | undefined = undefined
        let preguntasArchivadasArray: [Pregunta] | undefined = undefined
        for (const pregunta of preguntasJson.Preguntas) {
            if (pregunta.Archivado == null || pregunta.Archivado == "0") {
                preguntasActivasArray ? preguntasActivasArray.push(pregunta as Pregunta) : preguntasActivasArray = [pregunta as Pregunta]
            }
            else {
                preguntasArchivadasArray ? preguntasArchivadasArray.push(pregunta as Pregunta) : preguntasArchivadasArray = [pregunta as Pregunta]
            }
        }
        setPreguntasActivas(preguntasActivasArray)
        setPreguntasArchivadas(preguntasArchivadasArray)
    }

    const getAllEncuestas = async () => {
        const encuestasJson = await fetch("/api/Encuestas").then((res) => res.json())
        let encuestasArray: [Encuesta] | undefined = undefined
        let encuestasArchivadasArray: [Encuesta] | undefined = undefined
        for (const encuesta of encuestasJson.Encuestas) {
            if (encuesta.Archivado == null || encuesta.Archivado == "0") {
                encuestasArray ? encuestasArray.push(encuesta as Encuesta) : encuestasArray = [encuesta as Encuesta]
            }
            else {
                encuestasArchivadasArray ? encuestasArchivadasArray.push(encuesta as Encuesta) : encuestasArchivadasArray = [encuesta as Encuesta]
            }
        }
        setEncuestas(encuestasArray)
        setEncuestasArchivadas(encuestasArchivadasArray)
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
                getAllPreguntas();
                getAllEncuestas();
                getAllGrupos();

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
        <div className='w-screen min-h-screen bg-neutral-200 '>
            {
                user ? (
                    <>
                        <Navbar nombre={nombre} />
                        <div className='w-screen h-2/3  flex flex-col items-center'>
                            {/* modal*/}
                            <input type="checkbox" id="my-modal" className="modal-toggle" />
                            <div className="modal h-screen">
                                <div className="modal-box h-screen">
                                    {modal ? modal : ""}
                                    <div className=" absolute top-1 right-1">
                                        <label htmlFor="my-modal" onClick={() => setModal(undefined)} className="p-4 w-4 h-4 bg-red-100 flex justify-center items-center rounded-full">X</label>
                                    </div>
                                </div>
                            </div>
                            <div className="w-full flex flex-col items-center">
                                <h1 className="text-3xl text-center my-3">Preguntas Activas</h1>
                                <div className="w-5/6 overflow-y-auto rounded-md">
                                    <div className="bg-white p-2  flex justify-between font-bold text-slate-900">
                                        <div className="w-1/4">Numero Pregunta</div>
                                        <div className="w-1/4">Clave Pregunta</div>
                                        <div className="w-1/4">Tipo De Pregunta</div>
                                        <div className="w-1/4">Descripcion</div>
                                    </div>
                                    <div className="overflow-scroll h-96">
                                        {preguntasActivas?.map((pregunta: Pregunta, index) => (
                                            <div key={pregunta.ClavePregunta} className={index % 2 == 0 ? "bg-slate-300 flex justify-between" : "bg-slate-100 flex justify-between"}>
                                                <div className="w-1/4 pl-2">{pregunta.NumPregunta}</div>
                                                <div className="w-1/4 pl-2">{pregunta.ClavePregunta}</div>
                                                <div className="w-1/4 pl-2">{pregunta.TipoPregunta}</div>
                                                <div className="w-1/4 pl-2"><div className="break-words">{pregunta.Descripcion}</div></div>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                                <div className="flex mt-3 w-full justify-evenly">
                                    <label onClick={() => setModal(<QuestionAddModal getAllPreguntas={getAllPreguntas} preguntasArchivadas={preguntasArchivadas} preguntasActivas={preguntasActivas} />)} htmlFor="my-modal" className="btn btn-success">Agregar Pregunta</label>
                                    <label onClick={() => setModal(<QuestionModifyModal getAllPreguntas={getAllPreguntas} preguntasActivas={preguntasActivas} preguntasArchivadas={preguntasArchivadas} />)} htmlFor="my-modal" className="btn btn-warning">Modificar Pregunta</label>
                                    <label onClick={() => setModal(<QuestionDeleteModal getAllPreguntas={getAllPreguntas} preguntasActivas={preguntasActivas} preguntasArchivadas={preguntasArchivadas} />)} htmlFor="my-modal" className="btn btn-error">Archivar Pregunta</label>
                                    <label onClick={() => setModal(<QuestionRetrieveModal getAllPreguntas={getAllPreguntas} preguntasActivas={preguntasActivas} preguntasArchivadas={preguntasArchivadas} />)} htmlFor="my-modal" className="btn btn-info">Recuperar Pregunta</label>
                                </div>
                            </div>

                            <div className="  w-full flex flex-col items-center">
                                <h1 className="text-3xl text-center my-3">Encuestas Activas</h1>

                                <div className="w-5/6 overflow-y-auto rounded-md">
                                    <div className="bg-white p-2  flex justify-between font-bold text-slate-900">
                                        <div className="w-1/5">Numero Encuesta</div>
                                        <div className="w-1/5">Clave EA</div>
                                        <div className="w-1/5">FechaIni</div>
                                        <div className="w-1/5">FechaLim</div>
                                        <div className="w-1/5">Descripcion</div>
                                    </div>
                                    <div className="overflow-scroll max-h-96">
                                        {encuestas?.map((encuesta: Encuesta, index) => (
                                            <div key={encuesta.ClaveEncuesta} className={encuesta.Archivado == 1 ? "bg-slate-700 flex justify-between text-slate-100" : index % 2 == 0 ? "bg-slate-300 flex justify-between min-h-10" : "bg-slate-100 flex justify-between min-h-10"}>
                                                <div className="w-1/5 pl-2">{encuesta.ClaveEncuesta}</div>
                                                <div className="w-1/5 pl-2">{encuesta.ClaveEA}</div>
                                                <div className="w-1/5 pl-2">{encuesta.FechaIni.toString().substring(0, 10)}</div>
                                                <div className="w-1/5 pl-2">{encuesta.FechaLim.toString().substring(0, 10)}</div>
                                                <div className="break-words w-1/5 pl-2">{encuesta.Descripcion}</div>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                                <div className="flex mt-3 w-full justify-evenly">
                                    <label htmlFor="my-modal" className="btn btn-success" onClick={() => setModal(<EcoaAddModal encuestas={encuestas} getAllEncuestas={getAllEncuestas} />)}>Agregar Encuesta</label>
                                    <label htmlFor="my-modal" className="btn btn-warning" onClick={() => setModal(<EcoaEditModal encuestas={encuestas} getAllEncuestas={getAllEncuestas} />)}>Modificar Encuesta</label>
                                    <label htmlFor="my-modal" className="btn btn-error" onClick={() => setModal(<EcoaArchiveModal encuestas={encuestas} getAllEncuestas={getAllEncuestas} />)}>Archivar Encuesta </label>
                                    <label htmlFor="my-modal" className="btn btn-info" onClick={() => setModal(<EcoaRetrieveModal encuestas={encuestasArchivadas} getAllEncuestas={getAllEncuestas} />)}>Recuperar Encuesta</label>

                                </div>
                            </div>
                        </div>
                    </>

                ) : (<div className='w-screen h-screen flex justify-center items-center text-3xl'><h1>Loading...</h1></div>)
            }
        </div >
    )
}

