USE ClinicaMedica;


go
CREATE PROCEDURE sp_ConsultarTurnosDisponibles
    @EspecialidadNombre VARCHAR(255)
AS
BEGIN
       

    SELECT 
        P.Nombre + ' '+ P.Apellido AS Medico,
        E.Nombre AS Especialidad,
        TM.fechaHora AS HorarioTurno
    FROM HorarioAtencion HA
    INNER JOIN MedicoHorario MH ON HA.idHoraAtencion = MH.idHorario
    INNER JOIN Medico M ON MH.idMedico = M.idMedico
    INNER JOIN Persona P ON M.idPersona = P.idPersona
    INNER JOIN MedicoEspecialidad ME ON M.idMedico = ME.idMedico
    INNER JOIN Especialidad E ON ME.idEspecialidad = E.idEspecialidad
    INNER JOIN TurnosMedico TM ON HA.idHoraAtencion = TM.idHoraAtencion
    WHERE E.Nombre = @EspecialidadNombre
      AND HA.Activo = 1
      AND HA.Cupos > 0
      AND NOT EXISTS (
          SELECT 1
          FROM Turnos T 
          WHERE T.idMedico = M.idMedico 
            AND T.FechaHora = TM.fechaHora
      )
    ORDER BY TM.fechaHora;
END;

select * from Especialidad

EXEC sp_ConsultarTurnosDisponibles @EspecialidadNombre = 'Pediatría'; 

DROP PROCEDURE sp_ConsultarTurnosDisponibles;
select * from HorarioAtencion 
select * from TurnosMedico 





--Reserva turno

go
Create PROCEDURE sp_ReservarTurno
(
    @NumMatricula VARCHAR(50),      
    @DNIPaciente VARCHAR(20),      
    @NroConsultorio INT,           
    @idTipoTurno INT,               
    @NombreEspecialidad VARCHAR(100), 
    @FechaHoraTurno DATETIME        
)
AS
BEGIN
    

    DECLARE @idMedico INT;
    DECLARE @idPaciente INT; 
    DECLARE @idConsultorio INT;
    DECLARE @idEspecialidadEncontrada INT;

   


    SELECT @idMedico = idMedico
    FROM Medico
    WHERE NumMatricula = @NumMatricula;

  
    SELECT @idPaciente = Pac.idPersona
    FROM Paciente Pac
    INNER JOIN Persona Per ON Pac.idPersona = Per.idPersona
    WHERE Per.DNI = @DNIPaciente;

   
    SELECT @idConsultorio = idConsultorio
    FROM Consultorio
    WHERE NroConsultorio = @NroConsultorio;

    SELECT @idEspecialidadEncontrada = idEspecialidad
    FROM Especialidad
    WHERE Nombre = @NombreEspecialidad; 

  

    IF @idMedico IS NULL
    BEGIN
        RAISERROR('Error: No se encontró ningún médico con la matrícula ingresada.', 16, 1);
        RETURN;
    END;

    IF @idPaciente IS NULL
    BEGIN
        RAISERROR('Error: No se encontró ningún paciente con el DNI ingresado.', 16, 1);
        RETURN;
    END;

    IF @idConsultorio IS NULL
    BEGIN
        RAISERROR('Error: El número de consultorio especificado no existe.', 16, 1);
        RETURN;
    END;

  
    IF @idEspecialidadEncontrada IS NULL
    BEGIN
        RAISERROR('Error: La especialidad médica ingresada no existe en el sistema.', 16, 1);
        RETURN;
    END;

  
    IF NOT EXISTS (
        SELECT 1 
        FROM MedicoEspecialidad 
        WHERE idMedico = @idMedico 
          AND idEspecialidad = @idEspecialidadEncontrada
    )
    BEGIN
        RAISERROR('Error: El médico seleccionado no tiene vinculada la especialidad solicitada.', 16, 1);
        RETURN;
    END;


    IF EXISTS
    (
        SELECT 1
        FROM Turnos
        WHERE idMedico = @idMedico
          AND FechaHora = @FechaHoraTurno
    )
    BEGIN
        RAISERROR('Error: El médico ya tiene una reserva confirmada para ese día y horario.', 16, 1);
        RETURN;
    END;

  
    BEGIN TRANSACTION;

    BEGIN TRY
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
            @idMedico,
            @idEspecialidadEncontrada,
            @FechaHoraTurno,
            @idConsultorio,
            @idTipoTurno,
            @idPaciente
        );

        COMMIT TRANSACTION;
        PRINT 'Turno reservado correctamente de forma segura.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO



EXEC sp_ReservarTurno
    @NumMatricula = 'MP1003',
    @DNIPaciente = '45111222',  
    @NroConsultorio = 102,               
    @idTipoTurno = 3,
   @NombreEspecialidad = 'Pediatría',
   @FechaHoraTurno = '2026-06-30 09:00:00';

   select * from Medico 
   select * from Especialidad
    select * from Turnos
    select * from Consultorio 
    select * from TipoTurno
    select * from Persona Per Inner join Paciente P on P.idPersona=Per.idPersona


DROP PROCEDURE sp_ReservarTurno
go 


CREATE VIEW vw_TurnosCompletos
AS
SELECT
    PP.Nombre + ' ' + PP.Apellido AS Paciente,

    PM.Nombre + ' ' + PM.Apellido AS Medico,

    E.Nombre AS Especialidad,

    C.Descripcion AS Consultorio,

    C.NroConsultorio As NumeroConsultorio, 

    C.Piso As Piso,

    T.FechaHora,

    TT.Descripcion
    

FROM Turnos T

INNER JOIN Paciente PA
    ON T.idPaciente = PA.idPersona

INNER JOIN Persona PP
    ON PA.idPersona = PP.idPersona

INNER JOIN Medico M
    ON T.idMedico = M.idMedico

INNER JOIN Persona PM
    ON M.idPersona = PM.idPersona

INNER JOIN Especialidad E
    ON T.idEspecialidad = E.idEspecialidad

INNER JOIN Consultorio C
    ON T.idConsultorio = C.idConsultorio

INNER JOIN TipoTurno TT
    ON T.idTipoTurno = TT.idTipoTurno;

GO



SELECT * FROM vw_TurnosCompletos;

Drop view vw_TurnosCompletos



---Ver estado del Turno Por paciente

go
CREATE PROCEDURE sp_VerEstadoTurnosPaciente
    @DNI VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        t.FechaHora,
        e.Nombre AS Especialidad,
        pMed.Nombre + ' ' + pMed.Apellido AS Medico,
        c.NroConsultorio,
        TT.Descripcion AS EstadoTurno
    FROM Turnos t

        INNER JOIN Paciente pa
            ON t.idPaciente = pa.idPersona

        INNER JOIN Persona pPac
            ON pa.idPersona = pPac.idPersona

        INNER JOIN Especialidad e
            ON t.idEspecialidad = e.idEspecialidad

        INNER JOIN Medico m
            ON t.idMedico = m.idMedico

        INNER JOIN Persona pMed
            ON m.idPersona = pMed.idPersona

        INNER JOIN Consultorio c
            ON t.idConsultorio = c.idConsultorio

        INNER JOIN TipoTurno TT
            ON t.idTipoTurno = TT.idTipoTurno

    WHERE pPac.DNI = @DNI

    ORDER BY t.FechaHora;
END;
GO
select * from Persona;

EXEC sp_VerEstadoTurnosPaciente '45111222' ; 
DROP PROCEDURE sp_VerEstadoTurnosPaciente;









--Ver Consultas anteriores de un paciente 
go
Create PROCEDURE sp_ConsultarHistorialPacientePorDNI
(
    @DNI VARCHAR(20)
)
AS
BEGIN

    SELECT
        P.Nombre + ' ' + P.Apellido AS Paciente,
        PM.Nombre + ' ' + PM.Apellido AS Medico,
        E.Nombre AS Especialidad,
        HM.FechaAtencion,
        HM.MotivoConsulta,
        HM.Diagnostico,
        HM.Tratamiento,
        HM.Observaciones
    FROM HistorialMedico HM
    INNER JOIN Turnos T ON HM.idTurno = T.idTurno
    INNER JOIN Paciente PA ON T.idPaciente = PA.idPersona
    INNER JOIN Persona P ON PA.idPersona = P.idPersona
    INNER JOIN Medico M ON T.idMedico = M.idMedico
    INNER JOIN Persona PM ON M.idPersona = PM.idPersona
    INNER JOIN Especialidad E ON T.idEspecialidad = E.idEspecialidad
    WHERE P.DNI = @DNI
    ORDER BY HM.FechaAtencion DESC;
END;
GO




GO 
SELECT * FROM HistorialMedico;


EXEC sp_ConsultarHistorialPacientePorDNI '45111222';
EXEC sp_ConsultarHistorialPacientePorDNI '42111555'; 



select * from HorarioAtencion 

select * from TurnosMedico 




GO

Create PROCEDURE sp_AsignarHorarioMedico
    @NumMatricula VARCHAR(50),
    @Fecha DATE,
    @HoraInicio TIME(0),
    @HoraFin TIME(0),
    @Cupos INT
AS
BEGIN
    SET NOCOUNT ON;

 

   
    DECLARE @idMedicoEncontrado INT;

    SELECT @idMedicoEncontrado = idMedico 
    FROM Medico 
    WHERE NumMatricula = @NumMatricula;

    
    IF @idMedicoEncontrado IS NULL
    BEGIN
        RAISERROR('Error: La matrícula ingresada no pertenece a ningún médico activo.', 16, 1);
        RETURN;
    END;


    IF @HoraInicio >= @HoraFin
    BEGIN
        RAISERROR('Error: La hora de inicio no puede ser mayor o igual a la hora de fin.', 16, 1);
        RETURN;
    END;


    IF @Fecha < CAST(GETDATE() AS DATE)
    BEGIN
        RAISERROR('Error: No se pueden asignar agendas para fechas del pasado.', 16, 1);
        RETURN; 
    END;

   
    IF EXISTS (
        SELECT 1 
        FROM MedicoHorario MH
        INNER JOIN HorarioAtencion HA ON MH.idHorario = HA.idHoraAtencion
        WHERE MH.idMedico = @idMedicoEncontrado 
          AND HA.Fecha = @Fecha
          AND HA.Activo = 1
    )
    BEGIN
        RAISERROR('Error: El médico ya tiene una agenda de atención asignada para la fecha seleccionada.', 16, 1);
        RETURN;
    END;


    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @idNuevoHorario INT;

      
        INSERT INTO HorarioAtencion (Fecha, horaInicio, horaFin, Cupos, Activo)
        VALUES (@Fecha, @HoraInicio, @HoraFin, @Cupos, 1);

        SET @idNuevoHorario = SCOPE_IDENTITY();

        
        INSERT INTO MedicoHorario (idMedico, idHorario)
        VALUES (@idMedicoEncontrado, @idNuevoHorario);

      
        DECLARE @FechaHoraActual DATETIME;
        DECLARE @FechaHoraFin DATETIME;

        SET @FechaHoraActual = DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00:00', @HoraInicio), CAST(@Fecha AS DATETIME));
        SET @FechaHoraFin = DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00:00', @HoraFin), CAST(@Fecha AS DATETIME));

        WHILE @FechaHoraActual < @FechaHoraFin
        BEGIN
            INSERT INTO TurnosMedico (idHoraAtencion, fechaHora)
            VALUES (@idNuevoHorario, @FechaHoraActual);

            SET @FechaHoraActual = DATEADD(MINUTE, 30, @FechaHoraActual);
        END;

        COMMIT TRANSACTION;
        PRINT 'Agenda y turnos creados exitosamente para el médico matriculado.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

EXEC sp_AsignarHorarioMedico 
    @NumMatricula = 'MP1003', 
    @Fecha = '2026-07-25', 
    @HoraInicio = '08:30', 
    @HoraFin = '10:00', 
    @Cupos = 3;


    
    select * from TurnosMedico  


   


