USE master;
GO

 CREATE DATABASE ClinicaMedica; 
 Use ClinicaMedica; 
 GO

CREATE TABLE Persona (
    idPersona INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Apellido VARCHAR(255) NOT NULL,
    DNI VARCHAR(20) NOT NULL UNIQUE,
    Telefono VARCHAR(30),
    Nacionalidad VARCHAR(255),
    Mail VARCHAR(255),
    FechaNacimiento DATE
);

CREATE TABLE ObraSocial (
    idObraSocial INT IDENTITY(1,1) PRIMARY KEY,
    RazonSocial VARCHAR(255) NOT NULL,
    Activo BIT DEFAULT 1
);

CREATE TABLE Especialidad (
    idEspecialidad INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL
);

CREATE TABLE Consultorio (
    idConsultorio INT IDENTITY(1,1) PRIMARY KEY,
    NroConsultorio INT NOT NULL,
    Piso INT NOT NULL,
    Descripcion VARCHAR(255)
);

CREATE TABLE TipoTurno (
    idTipoTurno INT IDENTITY(1,1) PRIMARY KEY,
    Descripcion VARCHAR(255) NOT NULL
);

CREATE TABLE Paciente (
    idPersona INT PRIMARY KEY,
    Localidad VARCHAR(255),
    idObraSocial INT,
    NumeroOS BIGINT,
    FechaIngreso DATE,
    FechaEgreso DATE,
    Activo BIT DEFAULT 1,

    CONSTRAINT fk_paciente_persona
        FOREIGN KEY (idPersona)
        REFERENCES Persona(idPersona),

    CONSTRAINT fk_paciente_obra_social
        FOREIGN KEY (idObraSocial)
        REFERENCES ObraSocial(idObraSocial)
);

CREATE TABLE Medico (
    idMedico INT IDENTITY(1,1) PRIMARY KEY,
    idPersona INT NOT NULL UNIQUE,
    NumMatricula VARCHAR(255) NOT NULL UNIQUE,
    HorarioAtencion INT,
    Activo BIT DEFAULT 1,

    CONSTRAINT fk_medico_persona
        FOREIGN KEY (idPersona)
        REFERENCES Persona(idPersona)
);

CREATE TABLE MedicoEspecialidad (
    idMedicoEspecialidad INT IDENTITY(1,1) PRIMARY KEY,
    idMedico INT NOT NULL,
    idEspecialidad INT NOT NULL,

    CONSTRAINT fk_me_medico
        FOREIGN KEY (idMedico)
        REFERENCES Medico(idMedico),

    CONSTRAINT fk_me_especialidad
        FOREIGN KEY (idEspecialidad)
        REFERENCES Especialidad(idEspecialidad),

    CONSTRAINT uq_medico_especialidad
        UNIQUE (idMedico, idEspecialidad)
);

CREATE TABLE HorarioAtencion (
    idHoraAtencion INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE NOT NULL,
    horaInicio TIME NOT NULL,
    horaFin TIME NOT NULL,
    Cupos INT NOT NULL,
    Activo BIT DEFAULT 1
);

CREATE TABLE MedicoHorario (
    idMedicoHorario INT IDENTITY(1,1) PRIMARY KEY,
    idMedico INT NOT NULL,
    idHorario INT NOT NULL,

    CONSTRAINT fk_mh_medico
        FOREIGN KEY (idMedico)
        REFERENCES Medico(idMedico),

    CONSTRAINT fk_mh_horario
        FOREIGN KEY (idHorario)
        REFERENCES HorarioAtencion(idHoraAtencion),

    CONSTRAINT uq_medico_horario
        UNIQUE (idMedico, idHorario)
);

CREATE TABLE TurnosMedico (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idHoraAtencion INT NOT NULL,
    fechaHora DATETIME NOT NULL,

    CONSTRAINT fk_turnos_medico_horario
        FOREIGN KEY (idHoraAtencion)
        REFERENCES HorarioAtencion(idHoraAtencion)
);

CREATE TABLE Turnos (
    idTurno INT IDENTITY(1,1) PRIMARY KEY,
    idMedico INT NOT NULL,
    idEspecialidad INT NOT NULL,
    FechaHora DATETIME NOT NULL,
    idConsultorio INT NOT NULL,
    idTipoTurno INT NOT NULL,
    idPaciente INT NOT NULL,

    CONSTRAINT fk_turno_medico
        FOREIGN KEY (idMedico)
        REFERENCES Medico(idMedico),

    CONSTRAINT fk_turno_especialidad
        FOREIGN KEY (idEspecialidad)
        REFERENCES Especialidad(idEspecialidad),

    CONSTRAINT fk_turno_consultorio
        FOREIGN KEY (idConsultorio)
        REFERENCES Consultorio(idConsultorio),

    CONSTRAINT fk_turno_tipo
        FOREIGN KEY (idTipoTurno)
        REFERENCES TipoTurno(idTipoTurno),

    CONSTRAINT fk_turno_paciente
        FOREIGN KEY (idPaciente)
        REFERENCES Paciente(idPersona)
);

CREATE TABLE HistorialMedico (
    idHistorialMedico INT IDENTITY(1,1) PRIMARY KEY,
    idTurno INT NOT NULL,
    FechaAtencion DATE NOT NULL,
    MotivoConsulta VARCHAR(255),
    Diagnostico VARCHAR(255),
    Tratamiento VARCHAR(255),
    Observaciones VARCHAR(255),

    CONSTRAINT fk_historial_turno
        FOREIGN KEY (idTurno)
        REFERENCES Turnos(idTurno)
); 


ALTER TABLE HorarioAtencion
ALTER COLUMN horaInicio TIME(0) NOT NULL;

ALTER TABLE HorarioAtencion
ALTER COLUMN horaFin TIME(0) NOT NULL;  




