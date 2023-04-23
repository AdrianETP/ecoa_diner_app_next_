export interface UserLogin {
    correo: string,
    clave: string,
}

export interface Estudiante {
    Matricula: string,
    Correo: string,
    Nombre: string,
    ApellidoPaterno: string,
    ApellidoMaterno: string,
}

export interface Profesor {
    Nomina: string,
    Correo: string,
    Nombre: string,
    ApellidoPaterno: string,
    ApellidoMaterno: string,
    ClaveCampus: string,
    Departamento: string
    Clave: string
}

export interface Colaborador {
    IdColaborador: string,
    Nombre: string,
    ApellidoPaterno: string,
    ApellidoMaterno: string,
    Telefono: string,
    Correo: string,
}

export interface EncuestaAlumno {
    ClaveEncuesta: string,
    Matricula: string,
    Contestada: number,
}

export interface Encuesta {
    ClaveEncuesta: string,
    ClaveEA: string,
    Descripcion: string,
    FechaIni: Date,
    FechaLim: Date,
}
export interface PreguntaPendiente {
    ClavePregunta: string,
    TipoPregunta: string,
    Descripcion: string,
}
export interface Pregunta {
    ClavePregunta: string,
    TipoPregunta: string,
    Descripcion: string,
    Archivado: number | null,
    NumPregunta: string,
}

export interface Grupo {
    CRN: string,
    ClaveMateria: string,
    ClaveEA: string,
    ClaveCampus: string,
}

export interface Respuesta {
    ClaveEncuesta: string,
    CRN: string,
    Matricula: string,
    ClavePregunta: string,
    TipoPregunta: string,
    Nomina: string,
    TipoRespuesta: string,
    Evaluacion: number,
    Comentario: string,
}
