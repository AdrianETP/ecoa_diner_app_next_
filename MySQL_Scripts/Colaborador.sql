USE ecoa_diner;
drop table `Colaborador`;
create table Colaborador(
    IdColaborador varchar(50) primary key,
    Nombre varchar(50),
    ApellidoPaterno varchar(50),
    ApellidoMaterno varchar(50),
    Telefono varchar(50),
    Correo varchar(50),
    Clave VARCHAR(50)
);

insert into Colaborador values("A018379" , "Juan" , "Perez" , "Garza" ,"1937138" , "Juan.P@tec.mx" , "Jp1234" );