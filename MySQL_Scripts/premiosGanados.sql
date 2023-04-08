CREATE DATABASE IF NOT EXISTS  ecoa_diner;
Use ecoa_diner;

CREATE TABLE IF NOT EXISTS  PremiosGanados
(
    NumReg			varchar(5),
    matricula		varchar(9),
    PremioID		varchar(5),
    FechaGanado		date,
    PRIMARY KEY (NumReg,matricula,PremioID),
    FOREIGN KEY (matricula) references Alumno(matricula),
    FOREIGN KEY (PremioID) references Premio(PremioID)
);

DESCRIBE PremiosGanados;