import Navbar from "@/Components/Navbar"
import { Colaborador, Encuesta, Pregunta } from "@/types"
import { useState, useEffect } from "react"
import { AddModal, ModifyModal } from '../../Components/Modals'

export default function Admin() {
    const [user, setUser] = useState<Colaborador | undefined>(undefined)
    const [preguntas, setPreguntas] = useState<[Pregunta] | undefined>()
    const [encuestas, setEncuestas] = useState<[Encuesta] | undefined>()
    const [modal, setModal] = useState(AddModal)

    const getAllPreguntas = async () => {
        const preguntasJson = await fetch("/api/Preguntas").then((res) => res.json())
        console.log(preguntasJson)
        setPreguntas(preguntasJson.Preguntas)
    }

    const getAllEncuestas = async () => {
        const encuestasJson = await fetch("/api/Encuestas").then((res) => res.json())
        console.log(encuestasJson)
        setEncuestas(encuestasJson.Encuestas)
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
                                    {modal}
                                    <div className=" absolute top-1 right-1">
                                        <label htmlFor="my-modal" className="p-4 w-4 h-4 bg-red-100 flex justify-center items-center rounded-full">X</label>
                                    </div>
                                </div>
                            </div>
                            <div className="w-full flex flex-col items-center">
                                <h1 className="text-3xl text-center my-3">Preguntas Activas</h1>
                                <div className="w-5/6 overflow-y-auto rounded-md">
                                    <div className="bg-white p-2  flex justify-between font-bold text-slate-900">
                                        <div className="w-1/4">Index</div>
                                        <div className="w-1/4">Clave Pregunta</div>
                                        <div className="w-1/4">Tipo De Pregunta</div>
                                        <div className="w-1/4">Descripcion</div>
                                    </div>
                                    <div className="overflow-scroll h-96">
                                        {preguntas?.map((pregunta: Pregunta, index) => (
                                            <div key={pregunta.ClavePregunta} className={index % 2 == 0 ? "bg-slate-300 flex justify-between" : "bg-slate-100 flex justify-between"}>
                                                <div className="w-1/4 pl-2">{index + 1}</div>
                                                <div className="w-1/4 pl-2">{pregunta.ClavePregunta}</div>
                                                <div className="w-1/4 pl-2">{pregunta.TipoPregunta}</div>
                                                <div className="w-1/4 pl-2"><div className="break-words">{pregunta.Descripcion}</div></div>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                                <div className="flex mt-3 w-full justify-evenly">
                                    <label onClick={() => setModal(AddModal)} htmlFor="my-modal" className="btn btn-success">Agregar Pregunta</label>
                                    <label onClick={() => setModal(<ModifyModal preguntas={preguntas?preguntas:undefined}></ModifyModal>)} htmlFor="my-modal" className="btn btn-warning">Modificar Pregunta</label>
                                    <label htmlFor="my-modal" className="btn btn-error">Archivar Pregunta</label>
                                    <label htmlFor="my-modal" className="btn btn-info">Recuperar Pregunta</label>
                                </div>
                            </div>

                            <div className="  w-full flex flex-col items-center">
                                <h1 className="text-3xl text-center my-3">Encuestas Activas</h1>
                                <table className="table w-5/6">
                                    <thead>
                                        <tr>
                                            <th>ClaveEncuesta</th>
                                            <th>CRN</th>
                                            <th>Periodo</th>
                                            <th>Descripcion</th>
                                            <th>Fecha Inicial</th>
                                            <th>Fecha Limite</th>
                                        </tr>
                                    </thead>
                                    <tbody className="overflow-y-auto overflow-x-auto h-2/5">
                                        {encuestas?.map((encuesta: Encuesta) => (
                                            <tr key={encuesta.ClaveEncuesta}>
                                                <td>{encuesta.ClaveEncuesta}</td>
                                                <td>{encuesta.CRN}</td>
                                                <td>{encuesta.Periodo}</td>
                                                <td className="overflow-x-hidden">{encuesta.Descripcion}</td>
                                                <td>{encuesta.FechaIni.toString().substring(0, 10)}</td>
                                                <td>{encuesta.FechaLim.toString().substring(0, 10)}</td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                                <div className="flex mt-3 w-full justify-evenly">
                                    <button className="btn btn-success">Agregar Encuesta</button>
                                    <button className="btn btn-warning">Modificar Encuesta</button>
                                    <button className="btn btn-error">Borrar Encuesta </button>
                                    <button className="btn btn-info">Activar Encuesta</button>
                                </div>
                            </div>
                        </div>
                    </>

                ) : (<div className='w-screen h-screen flex justify-center items-center text-3xl'><h1>Loading...</h1></div>)}
        </div>
    )
}

