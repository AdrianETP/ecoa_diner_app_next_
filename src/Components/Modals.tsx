import { Pregunta } from "@/types"

export function AddModal() {
    return (
        <div className="flex flex-col w-full  items-center h-full">
            <h1 className="text-3xl">Agregar una Pregunta</h1>
            <div className="h-3/4 flex flex-col justify-evenly w-full">
                <form className=" h-full flex flex-col justify-evenly w-full">
                    <input placeholder="Tipo de Pregunta" className="input input-bordered" />
                    <input placeholder="Clave Pregunta" className="input input-bordered" />
                    <input placeholder="Periodo" className="input input-bordered" />
                    <input placeholder="Descripcion de la Pregunta" className="input input-bordered" />
                    <input placeholder="Archivado" className="input input-bordered" />
                    <button className="btn btn-primary mt-5">Agregar</button>
                </form>
            </div>
        </div>
    )
}
interface ModifyProps {
    preguntas: Pregunta[] | undefined
}
export function ModifyModal(props: ModifyProps) {
    return (
        <div className="flex flex-col w-full  items-center h-full">
            <select className="select" placeholder="hello">
                <option disabled selected>Clave de la Pregunta</option>
                {props.preguntas?.map((pregunta: Pregunta) => (
                    <option key={pregunta.ClavePregunta} value={pregunta.ClavePregunta}>{pregunta.ClavePregunta}</option>

                ))}
            </select>
        </div>
    )
}
