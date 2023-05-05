CREATE DATABASE IF NOT EXISTS  ecoa_diner;
USE ecoa_diner;

CREATE TABLE IF NOT EXISTS Alumno(
    Matricula VARCHAR(9) PRIMARY KEY NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    ApellidoPaterno VARCHAR(50) NOT NULL,
    ApellidoMaterno VARCHAR(50) NOT NULL,
    Contraseña VARCHAR(100) NOT NULL,
    Correo VARCHAR(50) NOT NULL
);
DESCRIBE Alumno;
