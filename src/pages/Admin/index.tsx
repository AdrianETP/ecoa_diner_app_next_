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

    <div className='w-screen h-screen bg-neutral-200'>
      {
        user ? (
          <>
            <Navbar nombre={nombre} />
            <div className='w-screen h-2/3  flex flex-col items-center'>
              {/* modal*/}
              <input type="checkbox" id="my-modal" className="modal-toggle" />
              <div className="modal">
                <div className="modal-box">
                  {modal}
                  <div className="modal-action">
                    <label htmlFor="my-modal" className="btn">close modal</label>
                  </div>
                </div>
              </div>
              <div className="  w-full flex flex-col items-center">
                <h1 className="text-3xl text-center my-3">Preguntas Activas</h1>
                <table className="table w-5/6">
                  <thead>
                    <tr>
                      <th>Clave Pregunta</th>
                      <th>Tipo De Pregunta</th>
                      <th>Pregunta</th>
                      <th>Descripcion</th>
                    </tr>
                  </thead>
                  <tbody className="overflow-y-auto h-2/5">
                    {preguntas?.map((pregunta: Pregunta) => (
                      <tr key={pregunta.ClavePregunta}>
                        <td>{pregunta.ClavePregunta}</td>
                        <td>{pregunta.TipoPregunta}</td>
                        <td>{pregunta.Pregunta}</td>
                        <td>{pregunta.Descripcion}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                <div className="flex mt-3 w-full justify-evenly">
                  <label onClick={()=>setModal(Add))} htmlFor="my-modal" className="btn btn-success">Agregar Pregunta</label>
                  <label htmlFor="my-modal" className="btn btn-warning">Modificar Pregunta</label>
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
                  <tbody className="overflow-y-auto h-2/5">
                    {encuestas?.map((encuesta: Encuesta) => (
                      <tr key={encuesta.ClaveEncuesta}>
                        <td>{encuesta.ClaveEncuesta}</td>
                        <td>{encuesta.CRN}</td>
                        <td>{encuesta.Periodo}</td>
                        <td>{encuesta.Descripcion}</td>
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
        ) : (<div className='w-screen h-screen flex justify-center items-center text-3xl'><h1>Loading...</h1></div>)
      }

    </div >
  )


}
