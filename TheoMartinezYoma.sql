--CONSULTAR MEDICOS Y SUS ESPECIALIDADES
EXEC sp_ConsultarMedicosyEspecialidades

GO
CREATE PROCEDURE sp_ConsultarMedicosyEspecialidades
AS
BEGIN
	SELECT
	M.NumMatricula as 'MATRICULA',
	P.Nombre as 'Nombre',
	P.Apellido as 'Apellido',
	E.Nombre as 'Especialidad'

	FROM Medico  M
	INNER JOIN Persona  P on p.idPersona = m.idPersona
	INNER JOIN MedicoEspecialidad ME on me.idMedico = m.idMedico
	INNER JOIN Especialidad E on e.idEspecialidad = me.idEspecialidad
	WHERE m.Activo = 1

	ORDER BY P.Apellido
END;

GO

--VIEW DE CONSULTAR TURNOS ASIGNADOS

CREATE VIEW vw_TurnosAsignados
AS
SELECT
    M.idMedico,
    TP.idTipoTurno,
    M.Activo,
    CONCAT(PM.Nombre, ' ', PM.Apellido) AS Medico,
    CONCAT(PP.Nombre, ' ', PP.Apellido) AS Paciente,
    T.FechaHora,
    TP.Descripcion AS Estado,
    C.NroConsultorio
FROM Turnos T
INNER JOIN Medico M ON M.idMedico = T.idMedico
INNER JOIN Persona PM ON PM.idPersona = M.idPersona
INNER JOIN TipoTurno TP ON TP.idTipoTurno = T.idTipoTurno
INNER JOIN Consultorio C ON C.idConsultorio = T.idConsultorio
INNER JOIN Paciente P ON P.idPersona = T.idPaciente
INNER JOIN Persona PP ON PP.idPersona = P.idPersona;
GO
--CONSULTAR TURNOS ASIGNADOS
SELECT P.Nombre,P.Apellido,M.idMedico FROM Medico M
INNER JOIN Persona P ON P.idPersona = M.idPersona 

GO
EXEC sp_ConsultarTurnosAsignados @idMedico = 3
GO

CREATE PROCEDURE sp_ConsultarTurnosAsignados
    @idMedico INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Medico,
        Paciente,
        FechaHora,
        Estado,
        NroConsultorio
    FROM vw_TurnosAsignados
    WHERE idTipoTurno = 1 
      AND Activo = 1 
      AND idMedico = @idMedico
    ORDER BY FechaHora;
END;

GO

--GESTIONAR MEDICOS Y ESPECIALIDADES ABML


CREATE PROCEDURE sp_AltaMedico
	@idPersona INT,
	@NumMatricula VARCHAR(255),
	@HorarioAtencion INT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			INSERT INTO Medico (idPersona,NumMatricula, HorarioAtencion, Activo)
			VALUES(@idPersona, @NumMatricula, @HorarioAtencion, 1);

		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW;
    END CATCH;
END;

GO
CREATE PROCEDURE sp_AltaEspecialidad
    @Nombre VARCHAR(255)
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Especialidad WHERE Nombre = @Nombre
    )
    BEGIN
        RAISERROR('Ya existe una especialidad con ese nombre.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION

        INSERT INTO Especialidad (Nombre)
        VALUES (@Nombre);

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW;
    END CATCH
END;

GO

CREATE PROCEDURE sp_BajaMedico
    @idMedico INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Medico WHERE idMedico = @idMedico)
    BEGIN
        RAISERROR('No existe un médico con ese id.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION

        UPDATE Medico
        SET Activo = 0
        WHERE idMedico = @idMedico;

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW;
    END CATCH
END;

GO

CREATE PROCEDURE sp_ModificarMedico
    @idMedico INT,
    @NumMatricula VARCHAR(255),
    @HorarioAtencion INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Medico WHERE idMedico = @idMedico)
    BEGIN
        RAISERROR('No existe un médico con ese id.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION

        UPDATE Medico
        SET NumMatricula = @NumMatricula,
            HorarioAtencion = @HorarioAtencion
        WHERE idMedico = @idMedico;

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW;
    END CATCH
END;

GO

CREATE PROCEDURE sp_ModificarEspecialidad
    @idEspecialidad INT,
    @Nombre VARCHAR(255)
    
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Especialidad WHERE idEspecialidad = @idEspecialidad)
    BEGIN
        RAISERROR('No existe la especialidad con ese id.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION

        UPDATE Especialidad
        SET Nombre = @Nombre
            
        WHERE idEspecialidad = @idEspecialidad;

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW;
    END CATCH
END;

GO

CREATE PROCEDURE sp_BajaEspecialidad
    @idEspecialidad INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Especialidad WHERE idEspecialidad = @idEspecialidad)
    BEGIN
        RAISERROR('No existe esa especialidad.', 16, 1);
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM MedicoEspecialidad WHERE idEspecialidad = @idEspecialidad)
    BEGIN
        RAISERROR('No se puede eliminar, hay medicos con esta especialidad asignada.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION

        DELETE FROM Especialidad
        WHERE idEspecialidad = @idEspecialidad;

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW;
    END CATCH
END;    

GO
SELECT * FROM MedicoEspecialidad
SELECT M.idMedico, E.idEspecialidad  FROM MedicoEspecialidad ME
INNER JOIN Especialidad E ON E.idEspecialidad = ME.idEspecialidad
INNER JOIN Medico M ON M.idMedico = ME.idMedico
GO
EXEC sp_AsignarEspecialidades @idEspecialidad = 2, @idMedico = 1
GO

CREATE PROCEDURE sp_AsignarEspecialidades
    @idEspecialidad INT,
    @idMedico INT

AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Especialidad WHERE idEspecialidad = @idEspecialidad)
    BEGIN
        RAISERROR('No existe esa especialidad.', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Medico WHERE idMedico = @idMedico)
    BEGIN
        RAISERROR('No existe ese medico.', 16, 1);
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM MedicoEspecialidad WHERE idEspecialidad = @idEspecialidad 
                AND idMedico = @idMedico)
    BEGIN
        RAISERROR('Ya existe esta asignatura', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION

        INSERT INTO MedicoEspecialidad(idMedico, idEspecialidad)
        VALUES (@idMedico, @idEspecialidad);

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW;
    END CATCH
END;

GO

CREATE PROCEDURE sp_EliminarEspecialidadDeMedico
    @idEspecialidad INT,
    @idMedico INT

AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Especialidad WHERE idEspecialidad = @idEspecialidad)
    BEGIN
        RAISERROR('No existe esa especialidad.', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Medico WHERE idMedico = @idMedico)
    BEGIN
        RAISERROR('No existe ese medico.', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM MedicoEspecialidad WHERE idEspecialidad = @idEspecialidad 
                AND idMedico = @idMedico)
    BEGIN
        RAISERROR('No existe esta asignatura', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION

        DELETE FROM MedicoEspecialidad
        WHERE idMedico = @idMedico
        AND idEspecialidad = @idEspecialidad;

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW;
    END CATCH
END;

GO
--Gestionar disponibilidad horaria y atención médica.

CREATE TRIGGER trg_TurnosMedico_
ON TurnosMedico
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM TurnosMedico 
    WHERE FechaHora < GETDATE();
END;
go
SELECT * FROM TurnosMedico
go
SELECT * FROM HorarioAtencion

go
EXEC sp_AsignacionTurnosx30Minutos @idHoraAtencion = 19;



GO

CREATE PROCEDURE sp_AsignacionTurnosx30Minutos
    @idHoraAtencion INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Fecha DATE;
    DECLARE @HoraInicio TIME;
    DECLARE @HoraFin TIME;
    DECLARE @Actual DATETIME;
    DECLARE @FINAL DATETIME;

    
    SELECT 
        @Fecha = Fecha,
        @HoraInicio = horaInicio,
        @HoraFin = horaFin
    FROM HorarioAtencion 
    WHERE idHoraAtencion = @idHoraAtencion;

    IF @HoraInicio IS NULL OR @HoraFin IS NULL
    BEGIN
        RAISERROR('ID de horario no encontrado', 16, 1);
        RETURN;
    END

    
    SET @Actual = CAST(@Fecha AS DATETIME) + CAST(@HoraInicio AS DATETIME);

    
    IF @HoraFin > @HoraInicio
        SET @FINAL = CAST(@Fecha AS DATETIME) + CAST(@HoraFin AS DATETIME);
    ELSE
        SET @FINAL = DATEADD(DAY, 1, CAST(@Fecha AS DATETIME)) + CAST(@HoraFin AS DATETIME);

    
    WHILE @Actual < @FINAL
    BEGIN
        IF NOT EXISTS (
            SELECT 1 
            FROM TurnosMedico 
            WHERE idHoraAtencion = @idHoraAtencion 
              AND FechaHora = @Actual
        )
        BEGIN
            INSERT INTO TurnosMedico (idHoraAtencion, FechaHora)
            VALUES (@idHoraAtencion, @Actual);
        END

        SET @Actual = DATEADD(MINUTE, 30, @Actual);
    END
END
