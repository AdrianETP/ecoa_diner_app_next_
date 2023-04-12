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
}

export interface EncuestaAlumno {
    ClaveEncuesta: string,
    Matricula: string,
    Contestada: number,
}
