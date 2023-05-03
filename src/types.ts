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

export interface UDF {
    ClaveMateria: string,
    NombreMateria: string,
    TipoUDF: string,
}

export interface Profesor {
    Nomina: string,
    Correo: string,
    Nombre: string,
    ApellidoPaterno: string,
    ApellidoMaterno: string,
    ClaveCampus: string,
    Departamento: string
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
    ClaveEA: string,
    CRN: string,
    Contestada: number,
}

export interface Encuesta {
    ClaveEncuesta: string,
    ClaveEA: string,
    Descripcion: string,
    FechaIni: Date,
    FechaLim: Date,
    Archivado: number
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

export interface Calificaciones {
    DOM_Prom: number,
    RET_Prom: number,
    REC_Prom: number,
    ASE_Prom: number,
    MET_Prom: number,
    AlumnosCandidatos: number,
    AlumnosQueOpinaron: number,
    Campus: string,
    ClaveMateria: string,
    EjercicioAcademico: string,
    NombreMateria: string,
    Nomina: string,
    Participacion: string,
    Periodo: string,
    Region: string,
    Semanas: number,
    Term: string,
    TipodeUdF: string,
}




