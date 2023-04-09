CREATE DATABASE IF NOT EXISTS  ecoa_diner;
Use ecoa_diner;

CREATE TABLE IF NOT EXISTS  PremiosGanados
(
    NumReg			varchar(5),
    matricula		varchar(9),
    ClavePremio		varchar(5),
    FechaGanado		date,
    PRIMARY KEY (NumReg,matricula,ClavePremio),
    FOREIGN KEY (matricula) references Alumno(matricula),
    FOREIGN KEY (ClavePremio) references Premio(ClavePremio)
);

DESCRIBE PremiosGanados;
