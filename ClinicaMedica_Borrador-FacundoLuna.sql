CREATE DATABASE Clinica_Medica;
GO
USE Clinica_Medica;
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

-- CONSULTA PERSONAL ADMINISTRATIVO

-- 1) Gestionar turnos medicos y estados de atencion.

-- horarios, seleccion y adjuntar al paciente --> AGENDA

-- esta opcion deberia mediante un idturno como variable:
-- 1. mostrar todos los datos de los turnos
-- 2. mostrar uno en particular por el idturno
-- 3. modificar con el idturno, el estado (agendado, cancelado, confirmado, realizado (tiposturno))

-- 2)  Administrar obras sociales y datos de cobertura medica.

-- Ya que se maneja las obras sociales en relacion a cada paciente creo que a mi parecer por relacion las que maneja la institucion
-- Quiere decir que por si lo que sea se deja de estar en convenio con una obra social deberiamos sacarla a todos los pacientes con la relacion a esta misma si
-- Entonces mediante una variable tipo @_idObraSocial:
-- 1. mostrar todas las obras sociales
-- 2. hacer listado de una en particular por id
-- 3. modificar nombre o darla de baja y por consecuente tener en cuenta que primero debemos sacarselas a todos los pacientes

--  MEDICOS

-- 3) Acceder al historial medico de los pacientes.

-- Entiendo que es por el enunciado y consulta de todas las relaciones que tenga el historial medico, se me ocurre por id tanto de paciente, turno, medico, especialidad y asi...
-- Creo que es solo un listado que puede ser mostrado de distintas maneras segun como se quiera clasificar la busqueda.

SELECT * FROM TURNOS

-- CARGA DE DATOS --

INSERT INTO ObraSocial (RazonSocial)
VALUES
('OSDE'),
('Swiss Medical');

INSERT INTO Especialidad (Nombre)
VALUES
('Cardiología'),
('Clínica Médica');

INSERT INTO Consultorio (NroConsultorio, Piso, Descripcion)
VALUES
(101,1,'Consultorio General'),
(202,2,'Consultorio Cardiología');

INSERT INTO TipoTurno (Descripcion)
VALUES
('Agendado'),
('Confirmado'),
('Cancelado'),
('Realizado');

INSERT INTO Persona
(Nombre,Apellido,DNI,Telefono,Nacionalidad,Mail,FechaNacimiento)
VALUES
('Juan','Perez','30111222','1122334455','Argentina','juan@gmail.com','1990-03-10'),

('Maria','Lopez','28999111','1166677788','Argentina','maria@gmail.com','1988-07-21'),

('Carlos','Gomez','20123123','1144455566','Argentina','cgomez@gmail.com','1975-05-02'),

('Ana','Martinez','22333444','1177788899','Argentina','amartinez@gmail.com','1980-11-15');

INSERT INTO Paciente
(idPersona,Localidad,idObraSocial,NumeroOS,FechaIngreso)
VALUES
(1,'Buenos Aires',1,123456789,'2026-02-01'),

(2,'Lanus',2,987654321,'2026-02-03');

INSERT INTO Medico
(idPersona,NumMatricula)
VALUES
(3,'MP12345'),

(4,'MP54321');

INSERT INTO MedicoEspecialidad
(idMedico,idEspecialidad)
VALUES
(1,1),

(2,2);

INSERT INTO Turnos
(idMedico,
idEspecialidad,
FechaHora,
idConsultorio,
idTipoTurno,
idPaciente)

VALUES

(1,1,'2026-02-20 09:00',1,2,1),

(2,2,'2026-02-20 10:30',2,1,2);

--- INSERTS DE HISTORIALES MEDICOS

INSERT INTO HistorialMedico
(
    idTurno,
    FechaAtencion,
    MotivoConsulta,
    Diagnostico,
    Tratamiento,
    Observaciones
)
VALUES
(
    1,
    '2026-02-20',
    'Dolor en el pecho',
    'Hipertensión arterial',
    'Losartán 50 mg cada 24 hs',
    'Control en 30 días'
),
(
    2,
    '2026-02-20',
    'Control general',
    'Paciente en buen estado de salud',
    'Sin tratamiento',
    'Próximo control anual'
);


-- TURNOS --

-- MUESTREO DE TURNOS
    SELECT * FROM Turnos;

-- MOSTRAR TODOS LOS DATOS DE TURNOS 

    SELECT
        T.idTurno AS [ID Turno],
        T.FechaHora AS [Fecha y Hora],
        PP.Nombre + ' ' + PP.Apellido AS Paciente,
        PM.Nombre + ' ' + PM.Apellido AS Medico,
        E.Nombre AS Especialidad,
        CONCAT('Consultorio ', C.NroConsultorio, ' - Piso ', C.Piso) AS Consultorio,
        TT.Descripcion AS Estado
    FROM Turnos T 
    INNER JOIN Paciente P ON T.idPaciente = P.idPersona
    INNER JOIN Persona PP ON P.idPersona = PP.idPersona
    INNER JOIN Medico M ON T.idMedico = M.idMedico
    INNER JOIN Persona PM ON M.idPersona = PM.idPersona
    INNER JOIN Especialidad E ON T.idEspecialidad = E.idEspecialidad
    INNER JOIN Consultorio C ON T.idConsultorio = C.idConsultorio
    INNER JOIN TipoTurno TT ON T.idTipoTurno = TT.idTipoTurno;
    GO

-- MOSTRAR DATOS POR ID

    DECLARE @idTurno INT = 1;

    IF EXISTS (SELECT 1 FROM Turnos WHERE idTurno = @idTurno)
    BEGIN
        SELECT
            T.idTurno AS [ID Turno],
            T.FechaHora AS [Fecha y Hora],
            PP.Nombre + ' ' + PP.Apellido AS Paciente,
            PM.Nombre + ' ' + PM.Apellido AS Medico,
            E.Nombre AS Especialidad,
            CONCAT('Consultorio ', C.NroConsultorio, ' - Piso ', C.Piso) AS Consultorio,
            TT.Descripcion AS Estado
        FROM Turnos T
        INNER JOIN Paciente P ON T.idPaciente = P.idPersona
        INNER JOIN Persona PP ON P.idPersona = PP.idPersona
        INNER JOIN Medico M ON T.idMedico = M.idMedico
        INNER JOIN Persona PM ON M.idPersona = PM.idPersona
        INNER JOIN Especialidad E ON T.idEspecialidad = E.idEspecialidad
        INNER JOIN Consultorio C ON T.idConsultorio = C.idConsultorio
        INNER JOIN TipoTurno TT ON T.idTipoTurno = TT.idTipoTurno
        WHERE T.idTurno = @idTurno;
    END
    ELSE
    BEGIN
        PRINT 'No existe un turno con ese ID.';
    END;
    GO

-- ALTA DE TURNO
    DECLARE @Alta_idMedico INT = 1;
    DECLARE @Alta_idEspecialidad INT = 1;
    DECLARE @Alta_FechaHora DATETIME = '2026-02-21 09:00';
    DECLARE @Alta_idConsultorio INT = 1;
    DECLARE @Alta_idPaciente INT = 1;
    DECLARE @Alta_idTipoTurno INT = 1;

    IF NOT EXISTS (SELECT 1 FROM Medico WHERE idMedico = @Alta_idMedico AND Activo = 1)
    BEGIN
        PRINT 'El médico no existe o no está activo.';
    END
    ELSE IF NOT EXISTS (SELECT 1 FROM MedicoEspecialidad WHERE idMedico = @Alta_idMedico AND idEspecialidad = @Alta_idEspecialidad
    )
    BEGIN
        PRINT 'El medico no atiende esa especialidad.';
    END
    ELSE IF NOT EXISTS (SELECT 1 FROM Paciente WHERE idPersona = @Alta_idPaciente AND Activo = 1)
    BEGIN
        PRINT 'El paciente no existe o no está activo.';
    END
    ELSE IF NOT EXISTS (SELECT 1 FROM Especialidad WHERE idEspecialidad = @Alta_idEspecialidad)
    BEGIN
        PRINT 'La especialidad no existe.';
    END
    ELSE IF NOT EXISTS (SELECT 1 FROM Consultorio WHERE idConsultorio = @Alta_idConsultorio)
    BEGIN
        PRINT 'El consultorio no existe.';
    END
    ELSE IF EXISTS (
        SELECT 1
        FROM Turnos
        WHERE idMedico = @Alta_idMedico
        AND FechaHora = @Alta_FechaHora
        AND idTipoTurno <> 3
    )
    BEGIN
        PRINT 'El médico ya tiene un turno en esa fecha y hora.';
    END
    ELSE IF EXISTS (
        SELECT 1
        FROM Turnos
        WHERE idConsultorio = @Alta_idConsultorio
        AND FechaHora = @Alta_FechaHora
        AND idTipoTurno <> 3
    )
    BEGIN
        PRINT 'El consultorio ya está ocupado en esa fecha y hora.';
    END
    ELSE
    BEGIN
        INSERT INTO Turnos
        (
            idMedico,
            idEspecialidad,
            FechaHora,
            idConsultorio,
            idTipoTurno,
            idPaciente
        )
        VALUES
        (
            @Alta_idMedico,
            @Alta_idEspecialidad,
            @Alta_FechaHora,
            @Alta_idConsultorio,
            @Alta_idTipoTurno,
            @Alta_idPaciente
        );

        PRINT 'Turno registrado correctamente.';
    END;
    GO

-- REPROGRAMAR TURNO
    DECLARE @Reprog_idTurno INT = 1;
    DECLARE @Reprog_NuevaFechaHora DATETIME = '2026-02-22 11:00';
    DECLARE @Reprog_NuevoConsultorio INT = 2;

    IF NOT EXISTS (SELECT 1 FROM Turnos WHERE idTurno = @Reprog_idTurno)
    BEGIN
        PRINT 'El turno no existe.';
    END
    ELSE IF EXISTS (
        SELECT 1
        FROM Turnos T
        WHERE T.idTurno = @Reprog_idTurno
        AND T.idTipoTurno = 3 
    )
    BEGIN
        PRINT 'No se puede reprogramar un turno cancelado.';
    END
    ELSE IF EXISTS (
        SELECT 1
        FROM Turnos T1
        INNER JOIN Turnos T2 ON T1.idMedico = T2.idMedico
        WHERE T1.idTurno = @Reprog_idTurno
        AND T2.FechaHora = @Reprog_NuevaFechaHora
        AND T2.idTurno <> @Reprog_idTurno
        AND T2.idTipoTurno <> 3
    )
    BEGIN
        PRINT 'El médico ya tiene otro turno en esa fecha y hora.';
    END
    ELSE IF EXISTS (
        SELECT 1
        FROM Turnos
        WHERE idConsultorio = @Reprog_NuevoConsultorio
        AND FechaHora = @Reprog_NuevaFechaHora
        AND idTurno <> @Reprog_idTurno
        AND idTipoTurno <> 3
    )
    BEGIN
        PRINT 'El consultorio ya está ocupado en esa fecha y hora.';
    END
    ELSE
    BEGIN
        UPDATE Turnos
        SET FechaHora = @Reprog_NuevaFechaHora,
            idConsultorio = @Reprog_NuevoConsultorio
        WHERE idTurno = @Reprog_idTurno; --AND @Reprog_NuevaFechaHora > GETDATE();

        PRINT 'Turno reprogramado correctamente.';
    END;
    GO

-- CANCELACION DE TURNO
    DECLARE @Cancelar_idTurno INT = 1;
    DECLARE @Cancelar_idEstadoCancelado INT = 3;

    IF NOT EXISTS (SELECT 1 FROM Turnos WHERE idTurno = @Cancelar_idTurno)
    BEGIN
        PRINT 'El turno no existe.';
    END
    ELSE
    BEGIN
        UPDATE Turnos
        SET idTipoTurno = @Cancelar_idEstadoCancelado
        WHERE idTurno = @Cancelar_idTurno;

        PRINT 'Turno cancelado correctamente.';
    END;
    GO

-- MODIFICAR EL ESTADO DE UN TURNO
    SELECT * FROM TipoTurno
    --

    DECLARE @idTurno INT = 2;
    DECLARE @idTipoTurno INT = 2;

    IF EXISTS
    (
        SELECT 1
        FROM Turnos
        WHERE idTurno = @idTurno
    )
    AND EXISTS
    (
        SELECT 1
        FROM TipoTurno
        WHERE idTipoTurno = @idTipoTurno
    )
    BEGIN
        UPDATE Turnos
        SET idTipoTurno = @idTipoTurno
        WHERE idTurno = @idTurno;
        PRINT 'Estado actualizado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'El turno o el estado indicado no existen.';
    END;
    GO

-- OBRAS SOCIALES --

-- ALTA OBRA SOCIAL
    DECLARE @RazonSocial VARCHAR(255) = 'Medifé';
    -- DECLARE @RazonSocial VARCHAR(255) = 'Galeno';
    INSERT INTO ObraSocial (RazonSocial)
    VALUES (@RazonSocial);
    PRINT 'Obra social agregada correctamente.';
    GO

-- MOSTRAR OBRAS SOCIALES (TODAS) -- 
    SELECT
        idObraSocial AS [ID Obra Social],
        RazonSocial [Razon Social],
        Activo 
    FROM ObraSocial;

    -- ACTIVAS
    SELECT
        idObraSocial AS [ID Obra Social],
        RazonSocial [Razon Social],
        Activo 
    FROM ObraSocial WHERE Activo = 1;

    -- INACTIVAS
    SELECT
        idObraSocial AS [ID Obra Social],
        RazonSocial [Razon Social],
        Activo 
    FROM ObraSocial WHERE Activo = 0;


-- MOSTRAR POR ID
    DECLARE @idObraSocial INT = 2;
    IF EXISTS (SELECT 1 FROM ObraSocial WHERE idObraSocial = @idObraSocial)
    BEGIN
        SELECT
            idObraSocial,
            RazonSocial,
            Activo
        FROM ObraSocial
        WHERE idObraSocial = @idObraSocial;
    END
    ELSE
    BEGIN
        PRINT 'No existe una obra social con ese ID.';
    END;
    GO

-- MODIFICICAR OBRA SOCIAL
    DECLARE @idObraSocial INT = 1;
    DECLARE @NuevaRazonSocial VARCHAR(255) = 'OSDE';

    UPDATE ObraSocial
    SET RazonSocial = @NuevaRazonSocial
    WHERE idObraSocial = @idObraSocial;
    GO

-- ALTA LOGICA
    DECLARE @idObraSocial INT = 1;
    UPDATE ObraSocial
    SET Activo = 1
    WHERE idObraSocial = @idObraSocial;
    GO

-- BAJA LOGICA
    DECLARE @idObraSocial INT = 2;

    IF EXISTS (
        SELECT 1
        FROM ObraSocial
        WHERE idObraSocial = @idObraSocial
    )
    BEGIN
        UPDATE ObraSocial
        SET Activo = 0
        WHERE idObraSocial = @idObraSocial;
        PRINT 'Obra social dada de baja correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'La obra social no existe.';
    END;
    GO

-- BAJA FISICA
    DECLARE @idObraSocial INT = 2;

    UPDATE Paciente
    SET idObraSocial = NULL
    WHERE idObraSocial = @idObraSocial;

    DELETE
    FROM ObraSocial
    WHERE idObraSocial = @idObraSocial;

    INSERT INTO Persona
    (Nombre,Apellido,DNI,Telefono,Nacionalidad,Mail,FechaNacimiento)
    VALUES
    ('Facundo','Luna','42836127','1134546545','Argentina','facundo@gmail.com','2000-07-09')

    SELECT * FROM Persona

    INSERT INTO Paciente
    (idPersona,Localidad,idObraSocial,NumeroOS,FechaIngreso)
    VALUES
    (5,'General Pacheco',4,123456789,GETDATE());
    GO

    SELECT * FROM Paciente

    SELECT * FROM ObraSocial

-- MUESTREO DE PACIENTES CON UNA OBRA SOCIAL

    DECLARE @idObraSocial INT = 2;

    SELECT
        Pa.idPersona AS [ID Persona],
        Per.Nombre + ' ' + Per.Apellido AS [Nombre y Apellido],
        Pa.NumeroOS AS [Numero Obra Social],
        OS.RazonSocial AS [Razon Social]
    FROM Paciente Pa
    INNER JOIN Persona Per
        ON Pa.idPersona = Per.idPersona
    INNER JOIN ObraSocial OS
        ON Pa.idObraSocial = OS.idObraSocial
    WHERE OS.idObraSocial = @idObraSocial;
    GO

-- CAMBIO DE COBERTURA DEL PACIENTE
    DECLARE @Cobertura_idPaciente INT = 1;
    DECLARE @Cobertura_idObraSocial INT = 2;
    DECLARE @Cobertura_NumeroOS BIGINT = 555777999;

    IF NOT EXISTS (SELECT 1 FROM Paciente WHERE idPersona = @Cobertura_idPaciente)
    BEGIN
        PRINT 'El paciente no existe.';
    END
    ELSE IF NOT EXISTS (
        SELECT 1
        FROM ObraSocial
        WHERE idObraSocial = @Cobertura_idObraSocial
        AND Activo = 1
    )
    BEGIN
        PRINT 'La obra social no existe o está inactiva.';
    END
    ELSE
    BEGIN
        UPDATE Paciente
        SET idObraSocial = @Cobertura_idObraSocial,
            NumeroOS = @Cobertura_NumeroOS
        WHERE idPersona = @Cobertura_idPaciente;

        PRINT 'Cobertura médica actualizada correctamente.';
    END;
    GO

-- QUITAR COBERTURA DEL PACIENTE
    DECLARE @QuitarCobertura_idPaciente INT = 1;

    IF NOT EXISTS (SELECT 1 FROM Paciente WHERE idPersona = @QuitarCobertura_idPaciente)
    BEGIN
        PRINT 'El paciente no existe.';
    END
    ELSE
    BEGIN
        UPDATE Paciente
        SET idObraSocial = NULL,
            NumeroOS = NULL
        WHERE idPersona = @QuitarCobertura_idPaciente;

        PRINT 'Cobertura médica quitada correctamente.';
    END;
    GO

-- MEDICOS -- 

-- LISTAR TODOS LOS HISTORIALES MEDICOS
    
    SELECT
    HM.idHistorialMedico,
    HM.idTurno,
    FORMAT(T.FechaHora, 'hh:mm') AS Hora,
    HM.FechaAtencion,
    Per.Nombre + ' ' + Per.Apellido AS Paciente,
    PerMed.Nombre + ' ' + PerMed.Apellido AS Medico,
    E.Nombre AS Especialidad,
    HM.MotivoConsulta,
    HM.Diagnostico,
    HM.Tratamiento,
    HM.Observaciones
    FROM HistorialMedico HM
    INNER JOIN Turnos T ON HM.idTurno = T.idTurno
    INNER JOIN Paciente Pac ON T.idPaciente = Pac.idPersona
    INNER JOIN Persona Per ON Pac.idPersona = Per.idPersona
    INNER JOIN Medico M ON T.idMedico = M.idMedico
    INNER JOIN Persona PerMed ON M.idPersona = PerMed.idPersona
    INNER JOIN Especialidad E ON T.idEspecialidad = E.idEspecialidad;

-- CONSULTAR EL HISTORIAL MEDICO DE UN PACIENTE

    DECLARE @idPaciente INT = 1;

    SELECT * FROM Persona WHERE idPersona = 1;

    SELECT
    HM.idHistorialMedico,
    HM.idTurno,
    FORMAT(T.FechaHora, 'hh:mm') AS Hora,
    HM.FechaAtencion,
    Per.Nombre + ' ' + Per.Apellido AS Paciente,
    PerMed.Nombre + ' ' + PerMed.Apellido AS Medico,
    E.Nombre AS Especialidad,
    HM.MotivoConsulta,
    HM.Diagnostico,
    HM.Tratamiento,
    HM.Observaciones
    FROM HistorialMedico HM
    INNER JOIN Turnos T ON HM.idTurno = T.idTurno
    INNER JOIN Paciente Pac ON T.idPaciente = Pac.idPersona
    INNER JOIN Persona Per ON Pac.idPersona = Per.idPersona
    INNER JOIN Medico M ON T.idMedico = M.idMedico
    INNER JOIN Persona PerMed ON M.idPersona = PerMed.idPersona
    INNER JOIN Especialidad E ON T.idEspecialidad = E.idEspecialidad
    WHERE Pac.idPersona = @idPaciente;
    GO

-- CONSULTAR EL HISTORIAL ASOCIADO A UN TURNO

    SELECT * FROM Turnos WHERE idTurno=2;

    DECLARE @idTurno INT = 2;

    SELECT
    HM.idHistorialMedico,
    HM.idTurno,
    FORMAT(T.FechaHora, 'hh:mm') AS Hora,
    HM.FechaAtencion,
    Per.Nombre + ' ' + Per.Apellido AS Paciente,
    PerMed.Nombre + ' ' + PerMed.Apellido AS Medico,
    E.Nombre AS Especialidad,
    HM.MotivoConsulta,
    HM.Diagnostico,
    HM.Tratamiento,
    HM.Observaciones
    FROM HistorialMedico HM
    INNER JOIN Turnos T ON HM.idTurno = T.idTurno
    INNER JOIN Paciente Pac ON T.idPaciente = Pac.idPersona
    INNER JOIN Persona Per ON Pac.idPersona = Per.idPersona
    INNER JOIN Medico M ON T.idMedico = M.idMedico
    INNER JOIN Persona PerMed ON M.idPersona = PerMed.idPersona
    INNER JOIN Especialidad E ON T.idEspecialidad = E.idEspecialidad
    WHERE T.idTurno = @idTurno;
    GO

-- CONSULTAR EL HISTORIAL MEDICO POR MEDICO
    DECLARE @Historial_idMedico INT = 1;

    SELECT
        HM.idHistorialMedico AS [ID Historial],
        T.idTurno AS [ID Turno],
        HM.FechaAtencion AS [Fecha Atención],
        T.FechaHora AS [Fecha y Hora Turno],
        Per.Nombre + ' ' + Per.Apellido AS Paciente,
        PerMed.Nombre + ' ' + PerMed.Apellido AS Medico,
        E.Nombre AS Especialidad,
        HM.MotivoConsulta,
        HM.Diagnostico,
        HM.Tratamiento,
        HM.Observaciones
    FROM HistorialMedico HM
    INNER JOIN Turnos T ON HM.idTurno = T.idTurno
    INNER JOIN Paciente Pac ON T.idPaciente = Pac.idPersona
    INNER JOIN Persona Per ON Pac.idPersona = Per.idPersona
    INNER JOIN Medico M ON T.idMedico = M.idMedico
    INNER JOIN Persona PerMed ON M.idPersona = PerMed.idPersona
    INNER JOIN Especialidad E ON T.idEspecialidad = E.idEspecialidad
    WHERE M.idMedico = @Historial_idMedico
    ORDER BY HM.FechaAtencion DESC;
    GO