CREATE DATABASE IF NOT EXISTS  ecoa_diner;
Use ecoa_diner;

CREATE TABLE IF NOT EXISTS  PremiosGanados
(
    NumReg			varchar(5),
    Matricula		varchar(9),
    ClavePremio		varchar(5),
    FechaGanado		date,
    PRIMARY KEY (NumReg,Matricula,ClavePremio),
    FOREIGN KEY (matricula) references Alumno(matricula),
    FOREIGN KEY (ClavePremio) references Premio(ClavePremio)
);

DESCRIBE PremiosGanados;
